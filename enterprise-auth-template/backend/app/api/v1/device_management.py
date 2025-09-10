"""
Device Management API Endpoints

Provides endpoints for managing user devices and sessions,
including device registration, listing, and revocation.
"""

from datetime import datetime
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status, Request
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_, update

import structlog
from pydantic import BaseModel, Field

from app.core.database import get_db
from app.dependencies.auth import get_current_user
from app.models.user import User
from app.models.session import UserSession
from app.services.session_cleanup import session_cleanup_service
from app.services.audit_service import AuditService

router = APIRouter(prefix="/devices", tags=["Device Management"])
logger = structlog.get_logger(__name__)


class DeviceInfo(BaseModel):
    """Device information model."""

    device_id: str = Field(..., description="Unique device identifier")
    device_name: str = Field(..., description="Device name")
    device_type: str = Field(..., description="Device type (mobile, desktop, tablet)")
    os_name: Optional[str] = Field(None, description="Operating system name")
    os_version: Optional[str] = Field(None, description="Operating system version")
    browser_name: Optional[str] = Field(None, description="Browser name")
    browser_version: Optional[str] = Field(None, description="Browser version")
    is_trusted: bool = Field(False, description="Whether device is trusted")


class SessionInfo(BaseModel):
    """Session information model."""

    session_id: str = Field(..., description="Session ID")
    device_id: Optional[str] = Field(None, description="Device ID")
    device_name: Optional[str] = Field(None, description="Device name")
    device_type: Optional[str] = Field(None, description="Device type")
    ip_address: Optional[str] = Field(None, description="IP address")
    user_agent: Optional[str] = Field(None, description="User agent string")
    location: Optional[str] = Field(None, description="Location (city, country)")
    created_at: datetime = Field(..., description="Session creation time")
    last_activity: datetime = Field(..., description="Last activity time")
    is_current: bool = Field(False, description="Whether this is the current session")
    expires_at: Optional[datetime] = Field(None, description="Session expiration time")


class DeviceRegistrationRequest(BaseModel):
    """Device registration request model."""

    device_id: str = Field(..., description="Unique device identifier")
    device_name: str = Field(..., description="Device name")
    device_type: str = Field(..., description="Device type")
    os_name: Optional[str] = Field(None, description="Operating system name")
    os_version: Optional[str] = Field(None, description="Operating system version")
    browser_name: Optional[str] = Field(None, description="Browser name")
    browser_version: Optional[str] = Field(None, description="Browser version")
    push_token: Optional[str] = Field(None, description="Push notification token")


class DeviceListResponse(BaseModel):
    """Device list response model."""

    devices: List[DeviceInfo] = Field(..., description="List of devices")
    total: int = Field(..., description="Total number of devices")


class SessionListResponse(BaseModel):
    """Session list response model."""

    sessions: List[SessionInfo] = Field(..., description="List of sessions")
    total: int = Field(..., description="Total number of sessions")
    active_count: int = Field(0, description="Number of active sessions")


class DeviceTrustRequest(BaseModel):
    """Device trust request model."""

    device_id: str = Field(..., description="Device ID to trust/untrust")
    is_trusted: bool = Field(..., description="Trust status")
    require_2fa: bool = Field(True, description="Require 2FA for this action")


class ForceLogoutRequest(BaseModel):
    """Force logout request model."""

    session_ids: Optional[List[str]] = Field(None, description="Specific session IDs to logout")
    except_current: bool = Field(True, description="Keep current session active")
    reason: Optional[str] = Field(None, description="Reason for force logout")


@router.get("/sessions", response_model=SessionListResponse)
async def get_user_sessions(
    request: Request,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> SessionListResponse:
    """
    Get all sessions for the current user.

    Returns list of active and recent sessions with device information.
    """
    try:
        # Get current session token from request
        current_token = request.headers.get("Authorization", "").replace("Bearer ", "")

        # Fetch all sessions for user
        result = await db.execute(
            select(UserSession)
            .where(UserSession.user_id == current_user.id)
            .order_by(UserSession.last_activity.desc())
        )
        sessions = result.scalars().all()

        # Convert to response model
        session_list = []
        active_count = 0
        current_time = datetime.utcnow()

        for session in sessions:
            # Check if session is active (within last 24 hours)
            is_active = (current_time - session.last_activity).total_seconds() < 86400
            if is_active:
                active_count += 1

            # Parse device info from user agent
            device_info = _parse_user_agent(session.user_agent)

            session_info = SessionInfo(
                session_id=session.id,
                device_id=session.device_id,
                device_name=device_info.get("device_name", "Unknown Device"),
                device_type=device_info.get("device_type", "desktop"),
                ip_address=session.ip_address,
                user_agent=session.user_agent,
                location=session.location,
                created_at=session.created_at,
                last_activity=session.last_activity,
                is_current=(session.session_token == current_token),
                expires_at=session.expires_at,
            )
            session_list.append(session_info)

        return SessionListResponse(
            sessions=session_list,
            total=len(session_list),
            active_count=active_count,
        )

    except Exception as e:
        logger.error(
            "Error fetching user sessions",
            user_id=current_user.id,
            error=str(e),
        )
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to fetch sessions",
        )


@router.get("/devices", response_model=DeviceListResponse)
async def get_registered_devices(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> DeviceListResponse:
    """
    Get all registered devices for the current user.

    Returns list of devices that have been explicitly registered.
    """
    try:
        # Get unique devices from sessions
        result = await db.execute(
            select(UserSession.device_id, UserSession.user_agent, UserSession.device_name)
            .where(
                and_(
                    UserSession.user_id == current_user.id,
                    UserSession.device_id.isnot(None),
                )
            )
            .distinct(UserSession.device_id)
        )
        devices = result.all()

        device_list = []
        for device_id, user_agent, device_name in devices:
            device_info = _parse_user_agent(user_agent)

            device = DeviceInfo(
                device_id=device_id,
                device_name=device_name or device_info.get("device_name", "Unknown Device"),
                device_type=device_info.get("device_type", "desktop"),
                os_name=device_info.get("os_name"),
                os_version=device_info.get("os_version"),
                browser_name=device_info.get("browser_name"),
                browser_version=device_info.get("browser_version"),
                is_trusted=False,  # TODO: Implement trusted device logic
            )
            device_list.append(device)

        return DeviceListResponse(
            devices=device_list,
            total=len(device_list),
        )

    except Exception as e:
        logger.error(
            "Error fetching devices",
            user_id=current_user.id,
            error=str(e),
        )
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to fetch devices",
        )


@router.post("/register")
async def register_device(
    request: DeviceRegistrationRequest,
    req: Request,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> dict:
    """
    Register a new device for the current user.

    This associates a device with the user account for better
    security tracking and management.
    """
    try:
        # Get current session
        current_token = req.headers.get("Authorization", "").replace("Bearer ", "")

        result = await db.execute(
            select(UserSession)
            .where(
                and_(
                    UserSession.user_id == current_user.id,
                    UserSession.session_token == current_token,
                )
            )
        )
        session = result.scalar_one_or_none()

        if not session:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Session not found",
            )

        # Update session with device information
        session.device_id = request.device_id
        session.device_name = request.device_name
        session.device_type = request.device_type

        # Store additional device info in metadata
        device_metadata = {
            "os_name": request.os_name,
            "os_version": request.os_version,
            "browser_name": request.browser_name,
            "browser_version": request.browser_version,
            "push_token": request.push_token,
        }
        session.metadata = {**(session.metadata or {}), **device_metadata}

        await db.commit()

        # Log device registration
        await AuditService(db).log_activity(
            user_id=current_user.id,
            action="device.registered",
            resource_type="device",
            resource_id=request.device_id,
            details={
                "device_name": request.device_name,
                "device_type": request.device_type,
            },
        )

        logger.info(
            "Device registered",
            user_id=current_user.id,
            device_id=request.device_id,
        )

        return {
            "message": "Device registered successfully",
            "device_id": request.device_id,
        }

    except HTTPException:
        raise
    except Exception as e:
        await db.rollback()
        logger.error(
            "Error registering device",
            user_id=current_user.id,
            error=str(e),
        )
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to register device",
        )


@router.delete("/sessions/{session_id}")
async def revoke_session(
    session_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> dict:
    """
    Revoke a specific session.

    This will log out the user from that specific session/device.
    """
    try:
        # Find the session
        result = await db.execute(
            select(UserSession)
            .where(
                and_(
                    UserSession.id == session_id,
                    UserSession.user_id == current_user.id,
                )
            )
        )
        session = result.scalar_one_or_none()

        if not session:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Session not found",
            )

        # Delete the session
        await db.delete(session)
        await db.commit()

        # Log session revocation
        await AuditService(db).log_activity(
            user_id=current_user.id,
            action="session.revoked",
            resource_type="session",
            resource_id=session_id,
            details={
                "device_id": session.device_id,
                "ip_address": session.ip_address,
            },
        )

        logger.info(
            "Session revoked",
            user_id=current_user.id,
            session_id=session_id,
        )

        return {"message": "Session revoked successfully"}

    except HTTPException:
        raise
    except Exception as e:
        await db.rollback()
        logger.error(
            "Error revoking session",
            user_id=current_user.id,
            session_id=session_id,
            error=str(e),
        )
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to revoke session",
        )


@router.post("/force-logout")
async def force_logout(
    request: ForceLogoutRequest,
    req: Request,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> dict:
    """
    Force logout from all or specific sessions.

    This allows users to remotely log out from all devices
    or specific sessions.
    """
    try:
        current_token = None
        if request.except_current:
            # Get current session token
            current_token = req.headers.get("Authorization", "").replace("Bearer ", "")

        if request.session_ids:
            # Logout specific sessions
            terminated_count = 0
            for session_id in request.session_ids:
                result = await db.execute(
                    select(UserSession)
                    .where(
                        and_(
                            UserSession.id == session_id,
                            UserSession.user_id == current_user.id,
                        )
                    )
                )
                session = result.scalar_one_or_none()

                if session and session.session_token != current_token:
                    await db.delete(session)
                    terminated_count += 1

            await db.commit()
        else:
            # Logout all sessions (except current if specified)
            terminated_count = await session_cleanup_service.force_logout_user(
                user_id=current_user.id,
                except_session=current_token,
            )

        # Log force logout
        await AuditService(db).log_activity(
            user_id=current_user.id,
            action="session.force_logout",
            resource_type="session",
            details={
                "sessions_terminated": terminated_count,
                "except_current": request.except_current,
                "reason": request.reason,
            },
        )

        logger.info(
            "Force logout completed",
            user_id=current_user.id,
            sessions_terminated=terminated_count,
        )

        return {
            "message": "Force logout completed",
            "sessions_terminated": terminated_count,
        }

    except Exception as e:
        logger.error(
            "Error during force logout",
            user_id=current_user.id,
            error=str(e),
        )
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to force logout",
        )


@router.post("/trust")
async def trust_device(
    request: DeviceTrustRequest,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> dict:
    """
    Mark a device as trusted or untrusted.

    Trusted devices may have reduced authentication requirements
    or extended session durations.
    """
    try:
        # TODO: Implement 2FA verification if required
        if request.require_2fa:
            # This would verify 2FA before proceeding
            pass

        # Update device trust status in all sessions with this device
        result = await db.execute(
            update(UserSession)
            .where(
                and_(
                    UserSession.user_id == current_user.id,
                    UserSession.device_id == request.device_id,
                )
            )
            .values(
                metadata=UserSession.metadata.op("||")({"is_trusted": request.is_trusted})
            )
        )

        await db.commit()

        # Log trust change
        await AuditService(db).log_activity(
            user_id=current_user.id,
            action=f"device.{'trusted' if request.is_trusted else 'untrusted'}",
            resource_type="device",
            resource_id=request.device_id,
        )

        logger.info(
            f"Device {'trusted' if request.is_trusted else 'untrusted'}",
            user_id=current_user.id,
            device_id=request.device_id,
        )

        return {
            "message": f"Device {'trusted' if request.is_trusted else 'untrusted'} successfully",
            "device_id": request.device_id,
            "is_trusted": request.is_trusted,
        }

    except Exception as e:
        await db.rollback()
        logger.error(
            "Error updating device trust",
            user_id=current_user.id,
            device_id=request.device_id,
            error=str(e),
        )
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to update device trust",
        )


@router.get("/analytics")
async def get_session_analytics(
    current_user: User = Depends(get_current_user),
) -> dict:
    """
    Get session analytics for the current user.

    Returns statistics about user sessions and devices.
    """
    try:
        analytics = await session_cleanup_service.get_session_analytics(
            user_id=current_user.id
        )

        return analytics

    except Exception as e:
        logger.error(
            "Error fetching session analytics",
            user_id=current_user.id,
            error=str(e),
        )
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to fetch analytics",
        )


def _parse_user_agent(user_agent: Optional[str]) -> dict:
    """
    Parse user agent string to extract device information.

    Args:
        user_agent: User agent string

    Returns:
        Dict with device information
    """
    if not user_agent:
        return {}

    # Simple parsing logic - in production, use a library like user-agents
    device_info = {
        "device_name": "Unknown Device",
        "device_type": "desktop",
        "os_name": None,
        "os_version": None,
        "browser_name": None,
        "browser_version": None,
    }

    # Detect device type
    if "Mobile" in user_agent or "Android" in user_agent:
        device_info["device_type"] = "mobile"
    elif "Tablet" in user_agent or "iPad" in user_agent:
        device_info["device_type"] = "tablet"

    # Detect OS
    if "Windows" in user_agent:
        device_info["os_name"] = "Windows"
    elif "Mac OS" in user_agent or "Macintosh" in user_agent:
        device_info["os_name"] = "macOS"
    elif "Linux" in user_agent:
        device_info["os_name"] = "Linux"
    elif "Android" in user_agent:
        device_info["os_name"] = "Android"
    elif "iOS" in user_agent or "iPhone" in user_agent:
        device_info["os_name"] = "iOS"

    # Detect browser
    if "Chrome" in user_agent:
        device_info["browser_name"] = "Chrome"
    elif "Firefox" in user_agent:
        device_info["browser_name"] = "Firefox"
    elif "Safari" in user_agent:
        device_info["browser_name"] = "Safari"
    elif "Edge" in user_agent:
        device_info["browser_name"] = "Edge"

    # Generate device name
    if device_info["os_name"] and device_info["browser_name"]:
        device_info["device_name"] = f"{device_info['browser_name']} on {device_info['os_name']}"

    return device_info
