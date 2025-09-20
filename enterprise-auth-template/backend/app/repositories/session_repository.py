"""
Session Repository Implementation

Concrete implementation of the ISessionRepository interface for session data access.
"""

from typing import Optional, List, Dict, Any
from datetime import datetime
from uuid import UUID

from sqlalchemy import select, update, delete, and_
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.session import UserSession
from app.models.auth import RefreshToken
from app.repositories.interfaces import ISessionRepository


class SessionRepository(ISessionRepository):
    """Concrete implementation of the Session repository."""

    def __init__(self, session: AsyncSession):
        """
        Initialize the session repository.

        Args:
            session: SQLAlchemy async session
        """
        self.session = session

    async def create(self, session_data: Dict[str, Any]) -> UserSession:
        """Create a new session."""
        user_session = UserSession(**session_data)
        self.session.add(user_session)
        await self.session.flush()
        return user_session

    async def find_by_id(self, session_id: str) -> Optional[UserSession]:
        """Find a session by ID."""
        stmt = select(UserSession).where(UserSession.id == session_id)
        result = await self.session.execute(stmt)
        return result.scalar_one_or_none()

    async def find_by_user(self, user_id: UUID) -> List[UserSession]:
        """Find all sessions for a user."""
        stmt = select(UserSession).where(UserSession.user_id == user_id)
        result = await self.session.execute(stmt)
        return list(result.scalars().all())

    async def update(
        self, session_id: str, session_data: Dict[str, Any]
    ) -> Optional[UserSession]:
        """Update session data."""
        stmt = (
            update(UserSession)
            .where(UserSession.id == session_id)
            .values(**session_data)
            .returning(UserSession)
        )
        result = await self.session.execute(stmt)
        return result.scalar_one_or_none()

    async def delete(self, session_id: str) -> bool:
        """Delete a session."""
        stmt = delete(UserSession).where(UserSession.id == session_id)
        result = await self.session.execute(stmt)
        return result.rowcount > 0

    async def delete_user_sessions(self, user_id: UUID) -> int:
        """Delete all sessions for a user. Returns count of deleted sessions."""
        stmt = delete(UserSession).where(UserSession.user_id == user_id)
        result = await self.session.execute(stmt)
        return result.rowcount

    async def find_active_sessions(self, user_id: UUID) -> List[UserSession]:
        """Find all active sessions for a user."""
        stmt = select(UserSession).where(
            and_(
                UserSession.user_id == user_id,
                UserSession.is_active == True,
                UserSession.expires_at > datetime.utcnow(),
            )
        )
        result = await self.session.execute(stmt)
        return list(result.scalars().all())

    async def expire_session(self, session_id: str) -> bool:
        """Mark a session as expired."""
        stmt = (
            update(UserSession)
            .where(UserSession.id == session_id)
            .values(is_active=False, ended_at=datetime.utcnow())
        )
        result = await self.session.execute(stmt)
        return result.rowcount > 0

    async def extend_session(self, session_id: str, expires_at: datetime) -> bool:
        """Extend session expiration time."""
        stmt = (
            update(UserSession)
            .where(UserSession.id == session_id)
            .values(expires_at=expires_at, last_activity=datetime.utcnow())
        )
        result = await self.session.execute(stmt)
        return result.rowcount > 0

    async def cleanup_expired(self) -> int:
        """Clean up expired sessions. Returns count of deleted sessions."""
        stmt = delete(UserSession).where(UserSession.expires_at < datetime.utcnow())
        result = await self.session.execute(stmt)
        return result.rowcount

    # Additional methods specific to authentication flow

    async def find_refresh_token(self, token_id: str) -> Optional[RefreshToken]:
        """Find a refresh token by hash."""
        stmt = (
            select(RefreshToken)
            .where(RefreshToken.token_hash == token_id)
            .where(RefreshToken.revoked_at.is_(None))
        )
        result = await self.session.execute(stmt)
        return result.scalar_one_or_none()

    async def create_refresh_token(self, token_data: Dict[str, Any]) -> RefreshToken:
        """Create a new refresh token."""
        refresh_token = RefreshToken(**token_data)
        self.session.add(refresh_token)
        await self.session.flush()
        return refresh_token

    async def mark_token_used(self, token_id: str) -> bool:
        """Mark a refresh token as revoked."""
        stmt = (
            update(RefreshToken)
            .where(RefreshToken.token_hash == token_id)
            .values(revoked_at=datetime.utcnow())
        )
        result = await self.session.execute(stmt)
        return result.rowcount > 0

    async def revoke_user_tokens(self, user_id: UUID) -> int:
        """Revoke all refresh tokens for a user."""
        stmt = (
            update(RefreshToken)
            .where(RefreshToken.user_id == user_id)
            .where(RefreshToken.revoked_at.is_(None))
            .values(revoked_at=datetime.utcnow())
        )
        result = await self.session.execute(stmt)
        return result.rowcount

    async def end_user_sessions(self, user_id: UUID) -> int:
        """End all active sessions for a user."""
        stmt = (
            update(UserSession)
            .where(UserSession.user_id == user_id)
            .where(UserSession.is_active == True)
            .values(is_active=False, ended_at=datetime.utcnow())
        )
        result = await self.session.execute(stmt)
        return result.rowcount
