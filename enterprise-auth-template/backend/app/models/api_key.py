"""
API Key model for API authentication.
"""

from datetime import datetime, timedelta
from typing import TYPE_CHECKING, Optional, List
from sqlalchemy import (
    Boolean,
    Column,
    DateTime,
    ForeignKey,
    String,
    Text,
    JSON,
    Integer,
)
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship
import uuid
import secrets

from app.core.database import Base

if TYPE_CHECKING:
    from app.models.user import User
    from app.models.organization import Organization


class APIKey(Base):
    """API Key model for programmatic access."""

    __tablename__ = "api_keys"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, index=True
    )
    name: Mapped[str] = mapped_column(String(100), nullable=False)
    key_prefix: Mapped[str] = mapped_column(
        String(10),
        nullable=False,
        index=True,
        comment="First few characters of the key for identification",
    )
    key_hash: Mapped[str] = mapped_column(
        String(255),
        nullable=False,
        unique=True,
        comment="Hashed version of the API key",
    )
    description: Mapped[Optional[str]] = mapped_column(Text, nullable=True)

    # Scopes and permissions
    scopes: Mapped[List[str]] = mapped_column(
        JSON, nullable=False, default=list, comment="List of allowed scopes/permissions"
    )

    # Rate limiting
    rate_limit: Mapped[int] = mapped_column(
        Integer, default=1000, nullable=False, comment="Requests per hour"
    )

    # IP restrictions
    allowed_ips: Mapped[Optional[List[str]]] = mapped_column(
        JSON,
        nullable=True,
        comment="List of allowed IP addresses (null means all IPs allowed)",
    )

    # Usage tracking
    last_used_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)
    last_used_ip: Mapped[Optional[str]] = mapped_column(String(45), nullable=True)
    usage_count: Mapped[int] = mapped_column(Integer, default=0, nullable=False)

    # Expiration
    expires_at: Mapped[Optional[datetime]] = mapped_column(
        DateTime,
        nullable=True,
        comment="Key expiration date (null means never expires)",
    )

    # Status
    is_active: Mapped[bool] = mapped_column(
        Boolean, default=True, nullable=False, index=True
    )
    revoked_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)
    revoked_reason: Mapped[Optional[str]] = mapped_column(Text, nullable=True)

    # Ownership
    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("users.id"), nullable=False
    )
    organization_id: Mapped[Optional[uuid.UUID]] = mapped_column(
        UUID(as_uuid=True), ForeignKey("organizations.id"), nullable=True
    )

    # Timestamps
    created_at: Mapped[datetime] = mapped_column(
        DateTime, default=datetime.utcnow, nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False
    )

    # Relationships
    user: Mapped["User"] = relationship("User", back_populates="api_keys")

    organization: Mapped[Optional["Organization"]] = relationship(
        "Organization", back_populates="api_keys"
    )

    def __repr__(self) -> str:
        return f"<APIKey {self.name} ({self.key_prefix}...)>"

    @classmethod
    def generate_key(cls) -> str:
        """Generate a new API key."""
        # Generate a secure random key with prefix
        prefix = "sk_live" if not cls._is_test_environment() else "sk_test"
        random_part = secrets.token_urlsafe(32)
        return f"{prefix}_{random_part}"

    @classmethod
    def _is_test_environment(cls) -> bool:
        """Check if running in test environment."""
        import os

        return os.getenv("ENVIRONMENT", "production").lower() in ["test", "development"]

    def is_expired(self) -> bool:
        """Check if the API key has expired."""
        if self.expires_at is None:
            return False
        return datetime.utcnow() > self.expires_at

    def is_valid(self) -> bool:
        """Check if the API key is valid for use."""
        return self.is_active and not self.is_expired() and self.revoked_at is None

    def can_access_scope(self, scope: str) -> bool:
        """Check if the API key has access to a specific scope."""
        if "*" in self.scopes:  # Wildcard for all scopes
            return True
        return scope in self.scopes

    def check_ip_allowed(self, ip_address: str) -> bool:
        """Check if the IP address is allowed."""
        if self.allowed_ips is None:
            return True
        return ip_address in self.allowed_ips

    def update_usage(self, ip_address: str) -> None:
        """Update usage statistics."""
        self.last_used_at = datetime.utcnow()
        self.last_used_ip = ip_address
        self.usage_count += 1

    def revoke(self, reason: str) -> None:
        """Revoke the API key."""
        self.is_active = False
        self.revoked_at = datetime.utcnow()
        self.revoked_reason = reason

    def to_dict(self, include_sensitive: bool = False) -> dict:
        """Convert API key to dictionary."""
        data = {
            "id": str(self.id),
            "name": self.name,
            "key_prefix": self.key_prefix,
            "description": self.description,
            "scopes": self.scopes,
            "rate_limit": self.rate_limit,
            "allowed_ips": self.allowed_ips,
            "last_used_at": (
                self.last_used_at.isoformat() if self.last_used_at else None
            ),
            "last_used_ip": self.last_used_ip,
            "usage_count": self.usage_count,
            "expires_at": self.expires_at.isoformat() if self.expires_at else None,
            "is_active": self.is_active,
            "is_valid": self.is_valid(),
            "user_id": str(self.user_id),
            "organization_id": (
                str(self.organization_id) if self.organization_id else None
            ),
            "created_at": self.created_at.isoformat(),
            "updated_at": self.updated_at.isoformat(),
        }

        if include_sensitive:
            data.update(
                {
                    "revoked_at": (
                        self.revoked_at.isoformat() if self.revoked_at else None
                    ),
                    "revoked_reason": self.revoked_reason,
                }
            )

        return data


class APIKeyScopes:
    """Standard API key scopes."""

    # Read scopes
    READ_PROFILE = "read:profile"
    READ_USERS = "read:users"
    READ_ORGANIZATIONS = "read:organizations"
    READ_AUDIT_LOGS = "read:audit_logs"

    # Write scopes
    WRITE_PROFILE = "write:profile"
    WRITE_USERS = "write:users"
    WRITE_ORGANIZATIONS = "write:organizations"

    # Admin scopes
    ADMIN_USERS = "admin:users"
    ADMIN_ORGANIZATIONS = "admin:organizations"
    ADMIN_SYSTEM = "admin:system"

    # Special scopes
    FULL_ACCESS = "*"

    @classmethod
    def get_all_scopes(cls) -> List[str]:
        """Get all available scopes."""
        return [
            cls.READ_PROFILE,
            cls.READ_USERS,
            cls.READ_ORGANIZATIONS,
            cls.READ_AUDIT_LOGS,
            cls.WRITE_PROFILE,
            cls.WRITE_USERS,
            cls.WRITE_ORGANIZATIONS,
            cls.ADMIN_USERS,
            cls.ADMIN_ORGANIZATIONS,
            cls.ADMIN_SYSTEM,
        ]

    @classmethod
    def get_default_scopes(cls) -> List[str]:
        """Get default scopes for new API keys."""
        return [cls.READ_PROFILE]
