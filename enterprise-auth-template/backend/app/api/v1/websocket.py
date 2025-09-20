"""
WebSocket API endpoints
"""

from fastapi import APIRouter, WebSocket, WebSocketDisconnect, Depends, Query, status
from fastapi.responses import HTMLResponse
from sqlalchemy.ext.asyncio import AsyncSession
from typing import Optional
import jwt
from datetime import datetime
import logging

from app.core.config import get_settings
from app.core.database import get_db_session
from app.core.redis_client import get_redis_client
from app.services.websocket_manager import manager
from app.models.user import User
from app.models.session import UserSession
from redis.asyncio import Redis

logger = logging.getLogger(__name__)

router = APIRouter(tags=["websocket"])


async def get_current_user_ws(
    token: str = Query(...), db: AsyncSession = Depends(get_db_session)
) -> Optional[User]:
    """Get current user from WebSocket token"""
    try:
        settings = get_settings()
        # Decode JWT token
        payload = jwt.decode(
            token, settings.JWT_SECRET_KEY, algorithms=[settings.JWT_ALGORITHM]
        )
        user_id = payload.get("sub")

        if not user_id:
            return None

        # Get user from database
        user = await db.get(User, int(user_id))
        if not user or not user.is_active:
            return None

        return user
    except jwt.ExpiredSignatureError:
        logger.warning("WebSocket token expired")
        return None
    except jwt.InvalidTokenError as e:
        logger.warning(f"Invalid WebSocket token: {e}")
        return None
    except Exception as e:
        logger.error(f"Error validating WebSocket token: {e}")
        return None


@router.websocket("/ws")
async def websocket_endpoint(
    websocket: WebSocket,
    token: str = Query(...),
    session_id: Optional[str] = Query(None),
    db: AsyncSession = Depends(get_db_session),
    # redis_client: Redis = Depends(get_redis_client)  # Redis disabled for tests
):
    """Main WebSocket endpoint"""
    # Authenticate user
    user = await get_current_user_ws(token, db)
    if not user:
        await websocket.close(
            code=status.WS_1008_POLICY_VIOLATION, reason="Unauthorized"
        )
        return

    # Validate session if provided
    if session_id:
        session = await db.get(UserSession, session_id)
        if not session or session.user_id != user.id or not session.is_active:
            await websocket.close(
                code=status.WS_1008_POLICY_VIOLATION, reason="Invalid session"
            )
            return
    else:
        # Generate a temporary session ID for this WebSocket connection
        session_id = f"ws_{user.id}_{datetime.utcnow().timestamp()}"

    # Set Redis client for the manager
    if not manager.redis_client:
        redis_client = await get_redis_client()
        manager.redis_client = redis_client

    # Connect the WebSocket
    await manager.connect(
        websocket=websocket,
        user_id=str(user.id),
        session_id=session_id,
        metadata={
            "user_email": user.email,
            "user_name": user.full_name or user.email,
            "connected_at": datetime.utcnow().isoformat(),
        },
    )

    try:
        # Send initial data
        await manager.send_personal_message(
            user_id=str(user.id),
            message={
                "type": "welcome",
                "user": {
                    "id": user.id,
                    "email": user.email,
                    "name": user.full_name or user.email,
                },
                "timestamp": datetime.utcnow().isoformat(),
            },
            websocket=websocket,
        )

        # Main message loop
        while True:
            data = await websocket.receive_json()

            # Add user context to message
            data["user_id"] = user.id
            data["session_id"] = session_id

            # Handle the message
            await manager.handle_message(websocket, data)

    except WebSocketDisconnect:
        logger.info(f"WebSocket disconnected for user {user.id}")
    except Exception as e:
        logger.error(f"WebSocket error for user {user.id}: {e}")
    finally:
        await manager.disconnect(websocket)


@router.websocket("/ws/admin")
async def admin_websocket_endpoint(
    websocket: WebSocket,
    token: str = Query(...),
    db: AsyncSession = Depends(get_db_session),
    # redis_client: Redis = Depends(get_redis_client)  # Redis disabled for tests
):
    """Admin WebSocket endpoint for system monitoring"""
    # Authenticate admin user
    user = await get_current_user_ws(token, db)
    if not user or not user.is_superuser:
        await websocket.close(
            code=status.WS_1008_POLICY_VIOLATION, reason="Admin access required"
        )
        return

    session_id = f"admin_ws_{user.id}_{datetime.utcnow().timestamp()}"

    # Set Redis client for the manager
    if not manager.redis_client:
        redis_client = await get_redis_client()
        manager.redis_client = redis_client

    # Connect the WebSocket
    await manager.connect(
        websocket=websocket,
        user_id=f"admin_{user.id}",
        session_id=session_id,
        metadata={
            "admin": True,
            "user_email": user.email,
            "user_name": user.full_name or user.email,
            "connected_at": datetime.utcnow().isoformat(),
        },
    )

    try:
        # Send initial admin data
        await manager.send_personal_message(
            user_id=f"admin_{user.id}",
            message={
                "type": "admin_connected",
                "connections": manager.get_connection_count(),
                "connected_users": manager.get_connected_users(),
                "timestamp": datetime.utcnow().isoformat(),
            },
            websocket=websocket,
        )

        # Admin message loop
        while True:
            data = await websocket.receive_json()
            command = data.get("command")

            # Handle admin commands
            if command == "get_stats":
                await websocket.send_json(
                    {
                        "type": "stats",
                        "total_connections": manager.get_connection_count(),
                        "connected_users": manager.get_connected_users(),
                        "timestamp": datetime.utcnow().isoformat(),
                    }
                )

            elif command == "broadcast":
                message = data.get("message", {})
                await manager.broadcast(message)
                await websocket.send_json(
                    {
                        "type": "broadcast_sent",
                        "timestamp": datetime.utcnow().isoformat(),
                    }
                )

            elif command == "send_to_user":
                target_user = data.get("target_user")
                message = data.get("message", {})
                if target_user:
                    await manager.send_personal_message(target_user, message)
                    await websocket.send_json(
                        {
                            "type": "message_sent",
                            "target_user": target_user,
                            "timestamp": datetime.utcnow().isoformat(),
                        }
                    )

            elif command == "system_alert":
                alert_type = data.get("alert_type")
                alert_data = data.get("alert_data", {})
                target_users = data.get("target_users")
                await manager.send_system_alert(alert_type, alert_data, target_users)
                await websocket.send_json(
                    {"type": "alert_sent", "timestamp": datetime.utcnow().isoformat()}
                )

            else:
                await websocket.send_json(
                    {
                        "type": "error",
                        "error": "Unknown command",
                        "timestamp": datetime.utcnow().isoformat(),
                    }
                )

    except WebSocketDisconnect:
        logger.info(f"Admin WebSocket disconnected for user {user.id}")
    except Exception as e:
        logger.error(f"Admin WebSocket error for user {user.id}: {e}")
    finally:
        await manager.disconnect(websocket)


@router.get("/ws/test")
async def websocket_test_page():
    """Simple HTML page for testing WebSocket connection"""
    html = """
    <!DOCTYPE html>
    <html>
    <head>
        <title>WebSocket Test</title>
    </head>
    <body>
        <h1>WebSocket Test</h1>
        <form id="tokenForm">
            <input type="text" id="token" placeholder="JWT Token" style="width: 500px;" />
            <button type="submit">Connect</button>
        </form>
        <button id="disconnect" disabled>Disconnect</button>
        <br><br>
        <div id="status">Disconnected</div>
        <br>
        <form id="messageForm">
            <input type="text" id="messageText" placeholder="Enter message" />
            <button type="submit" disabled>Send</button>
        </form>
        <ul id="messages"></ul>

        <script>
            let ws = null;
            const tokenForm = document.getElementById('tokenForm');
            const messageForm = document.getElementById('messageForm');
            const disconnectBtn = document.getElementById('disconnect');
            const status = document.getElementById('status');
            const messages = document.getElementById('messages');

            tokenForm.onsubmit = function(event) {
                event.preventDefault();
                const token = document.getElementById('token').value;
                if (!token) {
                    alert('Please enter a JWT token');
                    return;
                }

                ws = new WebSocket(`ws://localhost:8000/api/v1/ws?token=${token}`);

                ws.onopen = function() {
                    status.textContent = 'Connected';
                    status.style.color = 'green';
                    messageForm.querySelector('button').disabled = false;
                    disconnectBtn.disabled = false;
                    tokenForm.querySelector('button').disabled = true;
                };

                ws.onmessage = function(event) {
                    const message = document.createElement('li');
                    const data = JSON.parse(event.data);
                    message.textContent = `${new Date().toLocaleTimeString()}: ${JSON.stringify(data)}`;
                    messages.appendChild(message);
                };

                ws.onclose = function() {
                    status.textContent = 'Disconnected';
                    status.style.color = 'red';
                    messageForm.querySelector('button').disabled = true;
                    disconnectBtn.disabled = true;
                    tokenForm.querySelector('button').disabled = false;
                };

                ws.onerror = function(error) {
                    console.error('WebSocket error:', error);
                    status.textContent = 'Error';
                    status.style.color = 'red';
                };
            };

            messageForm.onsubmit = function(event) {
                event.preventDefault();
                const input = document.getElementById('messageText');
                if (ws && ws.readyState === WebSocket.OPEN) {
                    ws.send(JSON.stringify({
                        type: 'message',
                        content: input.value
                    }));
                    input.value = '';
                }
            };

            disconnectBtn.onclick = function() {
                if (ws) {
                    ws.close();
                }
            };
        </script>
    </body>
    </html>
    """
    return HTMLResponse(content=html)
