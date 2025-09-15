"""
Session Security Manager

Handles session security operations including privilege escalation detection,
session fixation prevention, and abnormal activity monitoring.
"""

from datetime import datetime, timedelta
from typing import Optional, Dict, Any, List
from enum import Enum
import hashlib
import secrets
from uuid import UUID

from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, update
import structlog

from app.models.session import UserSession
from app.services.cache_service import CacheService

logger = structlog.get_logger(__name__)


class PrivilegeLevel(Enum):
    """User privilege levels for session security."""
    GUEST = 0
    USER = 1
    MODERATOR = 2
    ADMIN = 3
    SUPER_ADMIN = 4


class SessionSecurityEvent(Enum):
    """Security events that can occur during a session."""
    PRIVILEGE_ESCALATION = "privilege_escalation"
    SESSION_HIJACK_ATTEMPT = "session_hijack_attempt"
    ABNORMAL_ACTIVITY = "abnormal_activity"
    CONCURRENT_LOGIN = "concurrent_login"
    GEOLOCATION_CHANGE = "geolocation_change"
    USER_AGENT_CHANGE = "user_agent_change"
    IP_ADDRESS_CHANGE = "ip_address_change"


class SessionSecurityManager:
    """
    Manages session security including detection of session attacks
    and abnormal user behavior.
    """

    def __init__(
        self,
        db_session: AsyncSession,
        cache_service: Optional[CacheService] = None
    ):
        """
        Initialize SessionSecurityManager.

        Args:
            db_session: Database session for persistence
            cache_service: Optional cache service for performance
        """
        self.db = db_session
        self.cache = cache_service
        self.security_events: List[Dict[str, Any]] = []

    async def create_secure_session(
        self,
        user_id: UUID,
        ip_address: str,
        user_agent: str,
        privilege_level: PrivilegeLevel = PrivilegeLevel.USER
    ) -> str:
        """
        Create a new secure session with proper initialization.

        Args:
            user_id: User ID for the session
            ip_address: Client IP address
            user_agent: Client user agent
            privilege_level: Initial privilege level

        Returns:
            Session token
        """
        # Generate secure session token
        session_token = secrets.token_urlsafe(32)
        session_id = hashlib.sha256(session_token.encode()).hexdigest()

        # Create session record
        session = UserSession(
            user_id=user_id,
            session_token=session_id,
            ip_address=ip_address,
            user_agent=user_agent,
            is_active=True,
            last_activity=datetime.utcnow(),
            expires_at=datetime.utcnow() + timedelta(hours=24)
        )

        self.db.add(session)
        await self.db.commit()

        # Cache session data if cache service available
        if self.cache:
            await self.cache.set(
                f"session:{session_id}",
                {
                    "user_id": str(user_id),
                    "ip_address": ip_address,
                    "user_agent": user_agent,
                    "privilege_level": privilege_level.value,
                    "created_at": datetime.utcnow().isoformat()
                },
                ttl=86400  # 24 hours
            )

        logger.info(
            "Secure session created",
            user_id=str(user_id),
            session_id=session_id[:8],
            ip_address=ip_address
        )

        return session_token

    async def validate_session(
        self,
        session_token: str,
        ip_address: str,
        user_agent: str
    ) -> tuple[bool, Optional[SessionSecurityEvent]]:
        """
        Validate a session and check for security issues.

        Args:
            session_token: Session token to validate
            ip_address: Current client IP
            user_agent: Current client user agent

        Returns:
            Tuple of (is_valid, security_event)
        """
        session_id = hashlib.sha256(session_token.encode()).hexdigest()

        # Try to get from cache first
        if self.cache:
            cached_session = await self.cache.get(f"session:{session_id}")
            if cached_session:
                return await self._validate_cached_session(
                    cached_session, ip_address, user_agent
                )

        # Fallback to database
        stmt = select(UserSession).where(
            UserSession.session_token == session_id,
            UserSession.is_active == True
        )
        result = await self.db.execute(stmt)
        session = result.scalar_one_or_none()

        if not session:
            return False, None

        # Check for session hijacking attempts
        if session.ip_address != ip_address:
            await self._record_security_event(
                SessionSecurityEvent.IP_ADDRESS_CHANGE,
                session.user_id,
                {"old_ip": session.ip_address, "new_ip": ip_address}
            )
            return False, SessionSecurityEvent.SESSION_HIJACK_ATTEMPT

        if session.user_agent != user_agent:
            await self._record_security_event(
                SessionSecurityEvent.USER_AGENT_CHANGE,
                session.user_id,
                {"old_agent": session.user_agent, "new_agent": user_agent}
            )
            return False, SessionSecurityEvent.SESSION_HIJACK_ATTEMPT

        # Check expiration
        if session.expires_at < datetime.utcnow():
            return False, None

        # Update last activity
        session.last_activity = datetime.utcnow()
        await self.db.commit()

        return True, None

    async def detect_privilege_escalation(
        self,
        session_token: str,
        requested_privilege: PrivilegeLevel,
        current_privilege: PrivilegeLevel
    ) -> bool:
        """
        Detect unauthorized privilege escalation attempts.

        Args:
            session_token: Session token
            requested_privilege: Privilege level being requested
            current_privilege: Current privilege level

        Returns:
            True if escalation detected
        """
        if requested_privilege.value > current_privilege.value:
            session_id = hashlib.sha256(session_token.encode()).hexdigest()

            # Log privilege escalation attempt
            logger.warning(
                "Privilege escalation detected",
                session_id=session_id[:8],
                current=current_privilege.name,
                requested=requested_privilege.name
            )

            await self._record_security_event(
                SessionSecurityEvent.PRIVILEGE_ESCALATION,
                None,  # We don't have user_id here
                {
                    "session_id": session_id[:8],
                    "current_privilege": current_privilege.name,
                    "requested_privilege": requested_privilege.name
                }
            )

            return True

        return False

    async def rotate_session(
        self,
        old_session_token: str,
        ip_address: str,
        user_agent: str
    ) -> Optional[str]:
        """
        Rotate session token to prevent fixation attacks.

        Args:
            old_session_token: Current session token
            ip_address: Client IP address
            user_agent: Client user agent

        Returns:
            New session token or None if rotation failed
        """
        old_session_id = hashlib.sha256(old_session_token.encode()).hexdigest()

        # Get existing session
        stmt = select(UserSession).where(
            UserSession.session_token == old_session_id,
            UserSession.is_active == True
        )
        result = await self.db.execute(stmt)
        session = result.scalar_one_or_none()

        if not session:
            return None

        # Validate IP and user agent
        if session.ip_address != ip_address or session.user_agent != user_agent:
            logger.warning(
                "Session rotation denied due to mismatch",
                session_id=old_session_id[:8]
            )
            return None

        # Generate new token
        new_token = secrets.token_urlsafe(32)
        new_session_id = hashlib.sha256(new_token.encode()).hexdigest()

        # Update session
        session.session_token = new_session_id
        session.last_activity = datetime.utcnow()
        session.expires_at = datetime.utcnow() + timedelta(hours=24)

        await self.db.commit()

        # Update cache if available
        if self.cache:
            # Remove old session
            await self.cache.delete(f"session:{old_session_id}")

            # Add new session
            await self.cache.set(
                f"session:{new_session_id}",
                {
                    "user_id": str(session.user_id),
                    "ip_address": ip_address,
                    "user_agent": user_agent,
                    "created_at": datetime.utcnow().isoformat()
                },
                ttl=86400
            )

        logger.info(
            "Session rotated",
            old_session=old_session_id[:8],
            new_session=new_session_id[:8]
        )

        return new_token

    async def invalidate_session(self, session_token: str) -> bool:
        """
        Invalidate a session.

        Args:
            session_token: Session token to invalidate

        Returns:
            True if session was invalidated
        """
        session_id = hashlib.sha256(session_token.encode()).hexdigest()

        # Update database
        stmt = update(UserSession).where(
            UserSession.session_token == session_id
        ).values(is_active=False)

        result = await self.db.execute(stmt)
        await self.db.commit()

        # Remove from cache
        if self.cache:
            await self.cache.delete(f"session:{session_id}")

        logger.info("Session invalidated", session_id=session_id[:8])

        return result.rowcount > 0

    async def detect_concurrent_sessions(
        self,
        user_id: UUID,
        max_sessions: int = 3
    ) -> List[str]:
        """
        Detect concurrent sessions for a user.

        Args:
            user_id: User ID to check
            max_sessions: Maximum allowed concurrent sessions

        Returns:
            List of session IDs that should be terminated
        """
        stmt = select(UserSession).where(
            UserSession.user_id == user_id,
            UserSession.is_active == True
        ).order_by(UserSession.created_at.desc())

        result = await self.db.execute(stmt)
        sessions = result.scalars().all()

        sessions_to_terminate = []

        if len(sessions) > max_sessions:
            # Keep only the most recent sessions
            for session in sessions[max_sessions:]:
                sessions_to_terminate.append(session.session_token)
                session.is_active = False

            await self.db.commit()

            logger.warning(
                "Concurrent session limit exceeded",
                user_id=str(user_id),
                total_sessions=len(sessions),
                terminated=len(sessions_to_terminate)
            )

            await self._record_security_event(
                SessionSecurityEvent.CONCURRENT_LOGIN,
                user_id,
                {
                    "total_sessions": len(sessions),
                    "terminated": len(sessions_to_terminate)
                }
            )

        return sessions_to_terminate

    async def _validate_cached_session(
        self,
        cached_session: Dict[str, Any],
        ip_address: str,
        user_agent: str
    ) -> tuple[bool, Optional[SessionSecurityEvent]]:
        """
        Validate a cached session.

        Args:
            cached_session: Cached session data
            ip_address: Current client IP
            user_agent: Current client user agent

        Returns:
            Tuple of (is_valid, security_event)
        """
        if cached_session["ip_address"] != ip_address:
            return False, SessionSecurityEvent.IP_ADDRESS_CHANGE

        if cached_session["user_agent"] != user_agent:
            return False, SessionSecurityEvent.USER_AGENT_CHANGE

        return True, None

    async def _record_security_event(
        self,
        event: SessionSecurityEvent,
        user_id: Optional[UUID],
        details: Dict[str, Any]
    ):
        """
        Record a security event.

        Args:
            event: Type of security event
            user_id: User ID if available
            details: Event details
        """
        event_record = {
            "event": event.value,
            "user_id": str(user_id) if user_id else None,
            "timestamp": datetime.utcnow().isoformat(),
            "details": details
        }

        self.security_events.append(event_record)

        # Log to structured logger
        logger.warning(
            "Security event recorded",
            event_type=event.value,
            user_id=str(user_id) if user_id else None,
            **details
        )

        # TODO: Send to monitoring system
        # TODO: Trigger alerts if needed

    def get_security_events(self) -> List[Dict[str, Any]]:
        """Get all recorded security events."""
        return self.security_events.copy()

    def clear_security_events(self):
        """Clear recorded security events."""
        self.security_events.clear()