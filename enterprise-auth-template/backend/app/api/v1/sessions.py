"""
Session management API endpoints.
"""

from typing import List, Optional
from uuid import UUID
from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_, func
from pydantic import BaseModel, Field, ConfigDict

from app.core.database import get_db
from app.dependencies.auth import get_current_active_user, require_permission
from app.models.user import User
from app.models.session import UserSession
from app.services.session_service import SessionService
from app.services.audit_service import AuditService

router = APIRouter(prefix="/sessions", tags=["sessions"])


# Request/Response schemas
class SessionResponse(BaseModel):
    """Response schema for session data."""

    id: UUID
    user_id: UUID
    user_email: str
    ip_address: str
    user_agent: str
    device_type: Optional[str]
    device_name: Optional[str]
    location: Optional[str]
    is_active: bool
    created_at: str
    last_activity: str
    expires_at: str

    model_config = ConfigDict(from_attributes=True)


class RevokeSessionRequest(BaseModel):
    """Request schema for revoking a session."""

    session_id: UUID = Field(..., description="Session ID to revoke")
    reason: Optional[str] = Field(None, description="Reason for revocation")


class SessionsStatisticsResponse(BaseModel):
    """Response schema for session statistics."""

    total_sessions: int
    active_sessions: int
    expired_sessions: int
    revoked_sessions: int
    unique_users: int
    unique_ips: int
    device_breakdown: dict
    location_breakdown: dict


@router.get("/my-sessions", response_model=List[SessionResponse])
async def get_my_sessions(
    include_inactive: bool = Query(False, description="Include inactive sessions"),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
) -> List[SessionResponse]:
    """
    Get all sessions for the current user.
    """
    service = SessionService(db)
    sessions = await service.get_user_sessions(
        user_id=current_user.id, include_inactive=include_inactive
    )

    return [
        SessionResponse(
            id=session.id,
            user_id=session.user_id,
            user_email=current_user.email,
            ip_address=session.ip_address,
            user_agent=session.user_agent,
            device_type=session.device_type,
            device_name=session.device_name,
            location=session.location,
            is_active=session.is_active,
            created_at=session.created_at.isoformat(),
            last_activity=session.last_activity.isoformat(),
            expires_at=session.expires_at.isoformat(),
        )
        for session in sessions
    ]


@router.get("/", response_model=List[SessionResponse])
async def list_all_sessions(
    skip: int = Query(0, ge=0, description="Number of records to skip"),
    limit: int = Query(100, ge=1, le=1000, description="Number of records to return"),
    user_id: Optional[UUID] = Query(None, description="Filter by user ID"),
    include_inactive: bool = Query(False, description="Include inactive sessions"),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
) -> List[SessionResponse]:
    """
    List all sessions (admin only).

    Requires: session.list permission
    """
    # Check permission
    await require_permission(current_user, "session.list", db)

    service = SessionService(db)

    if user_id:
        sessions = await service.get_user_sessions(
            user_id=user_id, include_inactive=include_inactive
        )
    else:
        sessions = await service.get_all_active_sessions(skip=skip, limit=limit)

    # Get user emails for display
    user_emails = {}
    for session in sessions:
        if session.user_id not in user_emails:
            user_query = select(User).where(User.id == session.user_id)
            user_result = await db.execute(user_query)
            user = user_result.scalar_one_or_none()
            if user:
                user_emails[session.user_id] = user.email

    return [
        SessionResponse(
            id=session.id,
            user_id=session.user_id,
            user_email=user_emails.get(session.user_id, "Unknown"),
            ip_address=session.ip_address,
            user_agent=session.user_agent,
            device_type=session.device_type,
            device_name=session.device_name,
            location=session.location,
            is_active=session.is_active,
            created_at=session.created_at.isoformat(),
            last_activity=session.last_activity.isoformat(),
            expires_at=session.expires_at.isoformat(),
        )
        for session in sessions
    ]


@router.get("/{session_id}", response_model=SessionResponse)
async def get_session(
    session_id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
) -> SessionResponse:
    """
    Get a specific session by ID.

    Users can only view their own sessions unless they have session.read permission.
    """
    service = SessionService(db)
    session = await service.get_session(session_id)

    if not session:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Session with ID {session_id} not found",
        )

    # Check if user can view this session
    if session.user_id != current_user.id:
        await require_permission(current_user, "session.read", db)

    # Get user email
    user_query = select(User).where(User.id == session.user_id)
    user_result = await db.execute(user_query)
    user = user_result.scalar_one_or_none()

    return SessionResponse(
        id=session.id,
        user_id=session.user_id,
        user_email=user.email if user else "Unknown",
        ip_address=session.ip_address,
        user_agent=session.user_agent,
        device_type=session.device_type,
        device_name=session.device_name,
        location=session.location,
        is_active=session.is_active,
        created_at=session.created_at.isoformat(),
        last_activity=session.last_activity.isoformat(),
        expires_at=session.expires_at.isoformat(),
    )


@router.post("/revoke", status_code=status.HTTP_200_OK)
async def revoke_session(
    request: RevokeSessionRequest,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
) -> dict:
    """
    Revoke a session.

    Users can revoke their own sessions. Admins can revoke any session with session.delete permission.
    """
    service = SessionService(db)
    audit_service = AuditService(db)

    # Get the session
    session = await service.get_session(request.session_id)
    if not session:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Session with ID {request.session_id} not found",
        )

    # Check if user can revoke this session
    if session.user_id != current_user.id:
        await require_permission(current_user, "session.delete", db)

    # Revoke the session
    success = await service.revoke_session(
        session_id=request.session_id, reason=request.reason or "Manual revocation"
    )

    if success:
        # Audit log
        await audit_service.log_action(
            user_id=current_user.id,
            action="session.revoke",
            resource_type="session",
            resource_id=str(request.session_id),
            details={"reason": request.reason, "revoked_user_id": str(session.user_id)},
        )

    return {"success": success, "message": "Session revoked successfully"}


@router.post("/revoke-all", status_code=status.HTTP_200_OK)
async def revoke_all_user_sessions(
    user_id: Optional[UUID] = None,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
) -> dict:
    """
    Revoke all sessions for a user.

    If user_id is not provided, revokes all sessions for the current user.
    Admins can revoke sessions for any user with session.delete permission.
    """
    service = SessionService(db)
    audit_service = AuditService(db)

    target_user_id = user_id or current_user.id

    # Check if user can revoke sessions for target user
    if target_user_id != current_user.id:
        await require_permission(current_user, "session.delete", db)

    # Revoke all sessions
    count = await service.revoke_user_sessions(
        user_id=target_user_id, reason="Bulk revocation"
    )

    # Audit log
    await audit_service.log_action(
        user_id=current_user.id,
        action="session.revoke_all",
        resource_type="user",
        resource_id=str(target_user_id),
        details={"sessions_revoked": count},
    )

    return {"success": True, "message": f"Revoked {count} sessions", "count": count}


@router.delete("/cleanup", status_code=status.HTTP_200_OK)
async def cleanup_expired_sessions(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
) -> dict:
    """
    Clean up expired sessions (admin only).

    Requires: admin.system permission
    """
    # Check permission
    await require_permission(current_user, "admin.system", db)

    service = SessionService(db)
    count = await service.cleanup_expired_sessions()

    # Audit log
    audit_service = AuditService(db)
    await audit_service.log_action(
        user_id=current_user.id,
        action="session.cleanup",
        resource_type="system",
        resource_id="sessions",
        details={"expired_sessions_removed": count},
    )

    return {
        "success": True,
        "message": f"Cleaned up {count} expired sessions",
        "count": count,
    }


@router.get("/statistics/summary", response_model=SessionsStatisticsResponse)
async def get_session_statistics(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
) -> SessionsStatisticsResponse:
    """
    Get session statistics (admin only).

    Requires: admin.analytics permission
    """
    # Check permission
    await require_permission(current_user, "admin.analytics", db)

    # Get all sessions for statistics
    query = select(UserSession)
    result = await db.execute(query)
    sessions = result.scalars().all()

    # Calculate statistics
    total_sessions = len(sessions)
    active_sessions = len([s for s in sessions if s.is_active and not s.is_expired()])
    expired_sessions = len([s for s in sessions if s.is_expired()])
    revoked_sessions = len([s for s in sessions if s.revoked_at])

    unique_users = len(set(s.user_id for s in sessions))
    unique_ips = len(set(s.ip_address for s in sessions))

    # Device breakdown
    device_breakdown = {}
    for session in sessions:
        device = session.device_type or "Unknown"
        device_breakdown[device] = device_breakdown.get(device, 0) + 1

    # Location breakdown (simplified)
    location_breakdown = {}
    for session in sessions:
        location = session.location or "Unknown"
        location_breakdown[location] = location_breakdown.get(location, 0) + 1

    return SessionsStatisticsResponse(
        total_sessions=total_sessions,
        active_sessions=active_sessions,
        expired_sessions=expired_sessions,
        revoked_sessions=revoked_sessions,
        unique_users=unique_users,
        unique_ips=unique_ips,
        device_breakdown=device_breakdown,
        location_breakdown=location_breakdown,
    )


@router.get("/active/count", response_model=dict)
async def get_active_session_count(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
) -> dict:
    """
    Get count of active sessions for the current user.
    """
    service = SessionService(db)
    sessions = await service.get_user_sessions(
        user_id=current_user.id, include_inactive=False
    )

    active_count = len([s for s in sessions if s.is_active and not s.is_expired()])

    return {
        "user_id": str(current_user.id),
        "active_sessions": active_count,
        "max_allowed": 10,  # Configure based on your needs
    }
