"""
Session Domain Model

Rich domain model for Session entity with business logic and validation.
This follows Domain-Driven Design principles by encapsulating session management rules.
"""

from datetime import datetime, timedelta
from typing import Optional, Dict, Any
from uuid import UUID
from enum import Enum
import hashlib
import secrets


class SessionStatus(Enum):
    """Session status enumeration."""

    ACTIVE = "active"
    EXPIRED = "expired"
    REVOKED = "revoked"
    IDLE = "idle"


class SessionDomain:
    """
    Rich domain model for Session entity.

    Encapsulates business logic and validation rules for user sessions.
    """

    # Session configuration constants
    DEFAULT_DURATION_HOURS = 24
    DEFAULT_IDLE_TIMEOUT_MINUTES = 30
    MAX_DURATION_DAYS = 30
    MIN_DURATION_MINUTES = 5

    def __init__(
        self,
        id: str,
        user_id: UUID,
        ip_address: str,
        user_agent: str,
        created_at: Optional[datetime] = None,
        expires_at: Optional[datetime] = None,
        last_activity: Optional[datetime] = None,
        is_active: bool = True,
        ended_at: Optional[datetime] = None,
        privilege_level: Optional[str] = None,
        metadata: Optional[Dict[str, Any]] = None,
    ):
        """Initialize session domain model with validation."""
        self.id = self._validate_session_id(id)
        self.user_id = user_id
        self.ip_address = self._validate_ip_address(ip_address)
        self.user_agent = self._validate_user_agent(user_agent)
        self.created_at = created_at or datetime.utcnow()
        self.expires_at = expires_at or self._calculate_expiration()
        self.last_activity = last_activity or self.created_at
        self.is_active = is_active
        self.ended_at = ended_at
        self.privilege_level = privilege_level or "user"
        self.metadata = metadata or {}

        # Validate session consistency
        self._validate_session_consistency()

    @staticmethod
    def _validate_session_id(session_id: str) -> str:
        """
        Validate session ID format.

        Args:
            session_id: Session ID to validate

        Returns:
            Validated session ID

        Raises:
            ValueError: If session ID is invalid
        """
        if not session_id:
            raise ValueError("Session ID is required")

        if len(session_id) < 32:
            raise ValueError("Session ID must be at least 32 characters")

        if len(session_id) > 256:
            raise ValueError("Session ID must be less than 256 characters")

        return session_id

    @staticmethod
    def _validate_ip_address(ip_address: str) -> str:
        """
        Validate IP address format.

        Args:
            ip_address: IP address to validate

        Returns:
            Validated IP address

        Raises:
            ValueError: If IP address is invalid
        """
        if not ip_address:
            return "unknown"

        # Basic validation - could be enhanced with proper IP validation
        if len(ip_address) > 45:  # Max length for IPv6
            raise ValueError("Invalid IP address format")

        return ip_address

    @staticmethod
    def _validate_user_agent(user_agent: str) -> str:
        """
        Validate and sanitize user agent string.

        Args:
            user_agent: User agent to validate

        Returns:
            Validated user agent

        Raises:
            ValueError: If user agent is invalid
        """
        if not user_agent:
            return "unknown"

        # Truncate if too long
        if len(user_agent) > 500:
            user_agent = user_agent[:500]

        return user_agent

    def _calculate_expiration(self) -> datetime:
        """
        Calculate default session expiration time.

        Returns:
            Expiration datetime
        """
        return self.created_at + timedelta(hours=self.DEFAULT_DURATION_HOURS)

    def _validate_session_consistency(self) -> None:
        """
        Validate session data consistency.

        Raises:
            ValueError: If session data is inconsistent
        """
        if self.expires_at <= self.created_at:
            raise ValueError("Session expiration must be after creation time")

        if self.ended_at and self.ended_at < self.created_at:
            raise ValueError("Session end time cannot be before creation time")

        if self.last_activity < self.created_at:
            raise ValueError("Last activity cannot be before session creation")

        if not self.is_active and not self.ended_at:
            self.ended_at = datetime.utcnow()

    @property
    def status(self) -> SessionStatus:
        """
        Get current session status.

        Returns:
            SessionStatus: Current status of the session
        """
        if not self.is_active:
            return SessionStatus.REVOKED

        if datetime.utcnow() > self.expires_at:
            return SessionStatus.EXPIRED

        if self.is_idle():
            return SessionStatus.IDLE

        return SessionStatus.ACTIVE

    @property
    def is_valid(self) -> bool:
        """
        Check if session is currently valid.

        Returns:
            bool: True if session is valid
        """
        return self.status == SessionStatus.ACTIVE

    @property
    def time_remaining(self) -> timedelta:
        """
        Get time remaining until session expires.

        Returns:
            timedelta: Time remaining
        """
        if self.status != SessionStatus.ACTIVE:
            return timedelta(0)

        return self.expires_at - datetime.utcnow()

    @property
    def duration(self) -> timedelta:
        """
        Get total session duration.

        Returns:
            timedelta: Session duration
        """
        end_time = self.ended_at or datetime.utcnow()
        return end_time - self.created_at

    def is_idle(self, idle_timeout_minutes: Optional[int] = None) -> bool:
        """
        Check if session is idle.

        Args:
            idle_timeout_minutes: Custom idle timeout (default: 30 minutes)

        Returns:
            bool: True if session is idle
        """
        timeout = idle_timeout_minutes or self.DEFAULT_IDLE_TIMEOUT_MINUTES
        idle_threshold = datetime.utcnow() - timedelta(minutes=timeout)
        return self.last_activity < idle_threshold

    def extend(self, hours: Optional[int] = None) -> None:
        """
        Extend session expiration.

        Args:
            hours: Hours to extend (default: DEFAULT_DURATION_HOURS)

        Raises:
            ValueError: If extension would exceed maximum duration
        """
        if self.status != SessionStatus.ACTIVE:
            raise ValueError("Cannot extend inactive session")

        extension_hours = hours or self.DEFAULT_DURATION_HOURS
        new_expiration = datetime.utcnow() + timedelta(hours=extension_hours)

        # Check maximum duration
        max_expiration = self.created_at + timedelta(days=self.MAX_DURATION_DAYS)
        if new_expiration > max_expiration:
            raise ValueError(
                f"Session cannot be extended beyond {self.MAX_DURATION_DAYS} days"
            )

        self.expires_at = new_expiration
        self.record_activity()

    def record_activity(self, ip_address: Optional[str] = None) -> None:
        """
        Record session activity.

        Args:
            ip_address: Optional IP address if changed
        """
        self.last_activity = datetime.utcnow()

        # Track IP address changes
        if ip_address and ip_address != self.ip_address:
            if "ip_history" not in self.metadata:
                self.metadata["ip_history"] = []

            self.metadata["ip_history"].append(
                {"ip": self.ip_address, "until": datetime.utcnow().isoformat()}
            )
            self.ip_address = ip_address

    def revoke(self, reason: Optional[str] = None) -> None:
        """
        Revoke the session.

        Args:
            reason: Optional reason for revocation
        """
        self.is_active = False
        self.ended_at = datetime.utcnow()

        if reason:
            self.metadata["revocation_reason"] = reason

    def validate_fingerprint(self, fingerprint: str) -> bool:
        """
        Validate session fingerprint for additional security.

        Args:
            fingerprint: Client fingerprint to validate

        Returns:
            bool: True if fingerprint matches
        """
        if "fingerprint_hash" not in self.metadata:
            return True  # No fingerprint stored

        stored_hash = self.metadata["fingerprint_hash"]
        provided_hash = self._hash_fingerprint(fingerprint)
        return stored_hash == provided_hash

    def set_fingerprint(self, fingerprint: str) -> None:
        """
        Set session fingerprint for additional security.

        Args:
            fingerprint: Client fingerprint
        """
        self.metadata["fingerprint_hash"] = self._hash_fingerprint(fingerprint)

    def _hash_fingerprint(self, fingerprint: str) -> str:
        """
        Hash a fingerprint for secure storage.

        Args:
            fingerprint: Fingerprint to hash

        Returns:
            str: Hashed fingerprint
        """
        salt = self.metadata.get("fingerprint_salt")
        if not salt:
            salt = secrets.token_hex(16)
            self.metadata["fingerprint_salt"] = salt

        combined = f"{fingerprint}{salt}{self.id}"
        return hashlib.sha256(combined.encode()).hexdigest()

    def should_refresh_token(self, threshold_percentage: float = 0.75) -> bool:
        """
        Check if session token should be refreshed.

        Args:
            threshold_percentage: Percentage of duration before refresh (default: 75%)

        Returns:
            bool: True if token should be refreshed
        """
        if self.status != SessionStatus.ACTIVE:
            return False

        elapsed = (datetime.utcnow() - self.created_at).total_seconds()
        total = (self.expires_at - self.created_at).total_seconds()

        if total == 0:
            return False

        return (elapsed / total) >= threshold_percentage

    def requires_reauthentication(self, sensitive_action: bool = False) -> bool:
        """
        Check if reauthentication is required.

        Args:
            sensitive_action: Whether this is for a sensitive action

        Returns:
            bool: True if reauthentication is required
        """
        # Always require for inactive sessions
        if self.status != SessionStatus.ACTIVE:
            return True

        # For sensitive actions, require if session is older than 15 minutes
        if sensitive_action:
            age = datetime.utcnow() - self.created_at
            return age > timedelta(minutes=15)

        # For elevated privileges, require if idle for more than 5 minutes
        if self.privilege_level in ["admin", "super_admin"]:
            return self.is_idle(idle_timeout_minutes=5)

        return False

    def to_dict(self) -> Dict[str, Any]:
        """
        Convert domain model to dictionary for persistence.

        Returns:
            Dictionary representation
        """
        return {
            "id": self.id,
            "user_id": self.user_id,
            "ip_address": self.ip_address,
            "user_agent": self.user_agent,
            "created_at": self.created_at,
            "expires_at": self.expires_at,
            "last_activity": self.last_activity,
            "is_active": self.is_active,
            "ended_at": self.ended_at,
            "privilege_level": self.privilege_level,
            "metadata": self.metadata,
        }

    @classmethod
    def create_secure_session(
        cls,
        user_id: UUID,
        ip_address: str,
        user_agent: str,
        privilege_level: Optional[str] = None,
        duration_hours: Optional[int] = None,
    ) -> "SessionDomain":
        """
        Create a new secure session.

        Args:
            user_id: User ID
            ip_address: Client IP address
            user_agent: Client user agent
            privilege_level: User privilege level
            duration_hours: Custom session duration

        Returns:
            SessionDomain: New session instance
        """
        session_id = cls._generate_secure_session_id()
        created_at = datetime.utcnow()

        duration = duration_hours or cls.DEFAULT_DURATION_HOURS
        expires_at = created_at + timedelta(hours=duration)

        return cls(
            id=session_id,
            user_id=user_id,
            ip_address=ip_address,
            user_agent=user_agent,
            created_at=created_at,
            expires_at=expires_at,
            privilege_level=privilege_level,
        )

    @staticmethod
    def _generate_secure_session_id() -> str:
        """
        Generate a cryptographically secure session ID.

        Returns:
            str: Secure session ID
        """
        # Generate 256-bit random token
        random_bytes = secrets.token_bytes(32)
        # Add timestamp for uniqueness
        timestamp = str(datetime.utcnow().timestamp()).encode()
        # Combine and hash
        combined = random_bytes + timestamp
        session_id = hashlib.sha256(combined).hexdigest()
        return session_id

    @classmethod
    def from_entity(cls, entity) -> "SessionDomain":
        """
        Create domain model from database entity.

        Args:
            entity: Database entity

        Returns:
            SessionDomain instance
        """
        return cls(
            id=entity.id,
            user_id=entity.user_id,
            ip_address=entity.ip_address,
            user_agent=entity.user_agent,
            created_at=entity.created_at,
            expires_at=entity.expires_at,
            last_activity=entity.last_activity,
            is_active=entity.is_active,
            ended_at=entity.ended_at,
            privilege_level=getattr(entity, "privilege_level", "user"),
            metadata=getattr(entity, "metadata", {}),
        )
