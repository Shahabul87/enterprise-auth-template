"""
WebSocket Manager for real-time communication
"""

from typing import Dict, Set, List, Optional, Any
import json
import asyncio
from datetime import datetime
from fastapi import WebSocket, WebSocketDisconnect, status
from redis.asyncio import Redis
import logging

logger = logging.getLogger(__name__)


class ConnectionManager:
    """Manages WebSocket connections and message broadcasting"""

    def __init__(self, redis_client: Optional[Redis] = None):
        # Store active connections by user_id
        self.active_connections: Dict[str, Set[WebSocket]] = {}
        # Store connection metadata
        self.connection_metadata: Dict[WebSocket, Dict[str, Any]] = {}
        # Redis for pub/sub across multiple servers
        self.redis_client = redis_client
        # Subscription tasks
        self.subscription_tasks: Dict[str, asyncio.Task] = {}

    async def connect(
        self,
        websocket: WebSocket,
        user_id: str,
        session_id: str,
        metadata: Optional[Dict[str, Any]] = None,
    ) -> None:
        """Accept and register a new WebSocket connection"""
        await websocket.accept()

        # Add to active connections
        if user_id not in self.active_connections:
            self.active_connections[user_id] = set()
        self.active_connections[user_id].add(websocket)

        # Store metadata
        self.connection_metadata[websocket] = {
            "user_id": user_id,
            "session_id": session_id,
            "connected_at": datetime.utcnow().isoformat(),
            "metadata": metadata or {},
        }

        # Subscribe to user's Redis channel if using Redis
        if self.redis_client:
            await self._subscribe_to_user_channel(user_id)

        # Send connection confirmation
        await self.send_personal_message(
            user_id=user_id,
            message={
                "type": "connection",
                "status": "connected",
                "session_id": session_id,
                "timestamp": datetime.utcnow().isoformat(),
            },
            websocket=websocket,
        )

        # Notify about connection
        await self.broadcast_user_status(user_id, "online")

        logger.info(f"WebSocket connected: user={user_id}, session={session_id}")

    async def disconnect(self, websocket: WebSocket) -> None:
        """Remove a WebSocket connection"""
        metadata = self.connection_metadata.get(websocket)
        if not metadata:
            return

        user_id = metadata["user_id"]
        session_id = metadata["session_id"]

        # Remove from active connections
        if user_id in self.active_connections:
            self.active_connections[user_id].discard(websocket)

            # If no more connections for this user
            if not self.active_connections[user_id]:
                del self.active_connections[user_id]

                # Unsubscribe from Redis channel
                if self.redis_client and user_id in self.subscription_tasks:
                    self.subscription_tasks[user_id].cancel()
                    del self.subscription_tasks[user_id]

                # Notify about disconnection
                await self.broadcast_user_status(user_id, "offline")

        # Remove metadata
        if websocket in self.connection_metadata:
            del self.connection_metadata[websocket]

        logger.info(f"WebSocket disconnected: user={user_id}, session={session_id}")

    async def send_personal_message(
        self,
        user_id: str,
        message: Dict[str, Any],
        websocket: Optional[WebSocket] = None,
    ) -> None:
        """Send a message to a specific user (all their connections or specific one)"""
        if websocket:
            # Send to specific connection
            try:
                await websocket.send_json(message)
            except Exception as e:
                logger.error(f"Error sending message to websocket: {e}")
                await self.disconnect(websocket)
        else:
            # Send to all user's connections
            if user_id in self.active_connections:
                disconnected = []
                for connection in self.active_connections[user_id]:
                    try:
                        await connection.send_json(message)
                    except Exception as e:
                        logger.error(f"Error sending message to user {user_id}: {e}")
                        disconnected.append(connection)

                # Clean up disconnected connections
                for conn in disconnected:
                    await self.disconnect(conn)

            # Also publish to Redis for other servers
            if self.redis_client:
                await self.redis_client.publish(f"user:{user_id}", json.dumps(message))

    async def broadcast(
        self, message: Dict[str, Any], exclude_user: Optional[str] = None
    ) -> None:
        """Broadcast a message to all connected users"""
        disconnected = []

        for user_id, connections in self.active_connections.items():
            if exclude_user and user_id == exclude_user:
                continue

            for connection in connections:
                try:
                    await connection.send_json(message)
                except Exception as e:
                    logger.error(f"Error broadcasting to user {user_id}: {e}")
                    disconnected.append(connection)

        # Clean up disconnected connections
        for conn in disconnected:
            await self.disconnect(conn)

        # Also publish to Redis for other servers
        if self.redis_client:
            await self.redis_client.publish("broadcast", json.dumps(message))

    async def broadcast_to_group(
        self, group_id: str, message: Dict[str, Any], user_ids: List[str]
    ) -> None:
        """Broadcast a message to a specific group of users"""
        for user_id in user_ids:
            await self.send_personal_message(user_id, message)

    async def broadcast_user_status(self, user_id: str, status: str) -> None:
        """Broadcast user online/offline status"""
        message = {
            "type": "user_status",
            "user_id": user_id,
            "status": status,
            "timestamp": datetime.utcnow().isoformat(),
        }
        await self.broadcast(message, exclude_user=user_id)

    async def send_notification(
        self, user_id: str, notification: Dict[str, Any]
    ) -> None:
        """Send a notification to a user"""
        message = {
            "type": "notification",
            "data": notification,
            "timestamp": datetime.utcnow().isoformat(),
        }
        await self.send_personal_message(user_id, message)

    async def send_session_update(
        self, user_id: str, session_data: Dict[str, Any]
    ) -> None:
        """Send session update to a user"""
        message = {
            "type": "session_update",
            "data": session_data,
            "timestamp": datetime.utcnow().isoformat(),
        }
        await self.send_personal_message(user_id, message)

    async def send_system_alert(
        self,
        alert_type: str,
        alert_data: Dict[str, Any],
        target_users: Optional[List[str]] = None,
    ) -> None:
        """Send system alert to specific users or all users"""
        message = {
            "type": "system_alert",
            "alert_type": alert_type,
            "data": alert_data,
            "timestamp": datetime.utcnow().isoformat(),
        }

        if target_users:
            for user_id in target_users:
                await self.send_personal_message(user_id, message)
        else:
            await self.broadcast(message)

    async def handle_message(
        self, websocket: WebSocket, message: Dict[str, Any]
    ) -> None:
        """Handle incoming WebSocket messages"""
        metadata = self.connection_metadata.get(websocket)
        if not metadata:
            return

        user_id = metadata["user_id"]
        message_type = message.get("type")

        # Handle different message types
        if message_type == "ping":
            await websocket.send_json(
                {"type": "pong", "timestamp": datetime.utcnow().isoformat()}
            )

        elif message_type == "subscribe":
            # Handle subscription to specific channels/topics
            topics = message.get("topics", [])
            metadata["metadata"]["subscriptions"] = topics
            await websocket.send_json(
                {
                    "type": "subscription_confirmed",
                    "topics": topics,
                    "timestamp": datetime.utcnow().isoformat(),
                }
            )

        elif message_type == "unsubscribe":
            # Handle unsubscription
            topics = message.get("topics", [])
            current_subs = metadata["metadata"].get("subscriptions", [])
            metadata["metadata"]["subscriptions"] = [
                s for s in current_subs if s not in topics
            ]
            await websocket.send_json(
                {
                    "type": "unsubscription_confirmed",
                    "topics": topics,
                    "timestamp": datetime.utcnow().isoformat(),
                }
            )

        elif message_type == "message":
            # Handle user-to-user messages (if applicable)
            target_user = message.get("target_user")
            if target_user:
                await self.send_personal_message(
                    target_user,
                    {
                        "type": "user_message",
                        "from_user": user_id,
                        "content": message.get("content"),
                        "timestamp": datetime.utcnow().isoformat(),
                    },
                )

        else:
            # Unknown message type
            await websocket.send_json(
                {
                    "type": "error",
                    "error": "Unknown message type",
                    "timestamp": datetime.utcnow().isoformat(),
                }
            )

    async def _subscribe_to_user_channel(self, user_id: str) -> None:
        """Subscribe to user's Redis channel for cross-server communication"""
        if not self.redis_client or user_id in self.subscription_tasks:
            return

        async def listen_to_channel():
            try:
                pubsub = self.redis_client.pubsub()
                await pubsub.subscribe(f"user:{user_id}")

                async for message in pubsub.listen():
                    if message["type"] == "message":
                        data = json.loads(message["data"])
                        # Send to all local connections for this user
                        if user_id in self.active_connections:
                            for connection in self.active_connections[user_id]:
                                try:
                                    await connection.send_json(data)
                                except Exception as e:
                                    logger.error(f"Error forwarding Redis message: {e}")
            except asyncio.CancelledError:
                await pubsub.unsubscribe(f"user:{user_id}")
                await pubsub.close()
            except Exception as e:
                logger.error(f"Error in Redis subscription for user {user_id}: {e}")

        # Create and store the subscription task
        task = asyncio.create_task(listen_to_channel())
        self.subscription_tasks[user_id] = task

    def get_connection_count(self, user_id: Optional[str] = None) -> int:
        """Get number of active connections for a user or all users"""
        if user_id:
            return len(self.active_connections.get(user_id, set()))
        return sum(len(conns) for conns in self.active_connections.values())

    def get_connected_users(self) -> List[str]:
        """Get list of all connected user IDs"""
        return list(self.active_connections.keys())

    def is_user_connected(self, user_id: str) -> bool:
        """Check if a user has any active connections"""
        return (
            user_id in self.active_connections
            and len(self.active_connections[user_id]) > 0
        )

    async def close_all_connections(self) -> None:
        """Close all active WebSocket connections"""
        for user_id in list(self.active_connections.keys()):
            for connection in list(self.active_connections[user_id]):
                try:
                    await connection.close(code=status.WS_1000_NORMAL_CLOSURE)
                except Exception as e:
                    logger.error(f"Error closing connection: {e}")
                await self.disconnect(connection)

        # Cancel all Redis subscription tasks
        for task in self.subscription_tasks.values():
            task.cancel()
        self.subscription_tasks.clear()


# Global connection manager instance
manager = ConnectionManager()


async def websocket_endpoint(
    websocket: WebSocket,
    user_id: str,
    session_id: str,
    redis_client: Optional[Redis] = None,
):
    """WebSocket endpoint handler"""
    # Set Redis client if provided
    if redis_client and not manager.redis_client:
        manager.redis_client = redis_client

    # Connect the WebSocket
    await manager.connect(websocket, user_id, session_id)

    try:
        while True:
            # Receive messages from the client
            data = await websocket.receive_json()
            await manager.handle_message(websocket, data)
    except WebSocketDisconnect:
        await manager.disconnect(websocket)
    except Exception as e:
        logger.error(f"WebSocket error for user {user_id}: {e}")
        await manager.disconnect(websocket)
