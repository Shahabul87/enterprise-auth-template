"""
Magic Link Authentication Models

Models for managing passwordless authentication via magic links
sent to user email addresses.
"""

from datetime import datetime, timedelta, timezone
from typing import TYPE_CHECKING, Optional
from uuid import uuid4

from sqlalchemy import DateTime, ForeignKey, String, Text, Boolean, Integer
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy.sql import func

from app.core.database import Base

if TYPE_CHECKING:
    from app.models.user import User


class MagicLink(Base):
    """
    Magic link model for passwordless authentication.

    Stores secure tokens sent via email that allow users to login
    without passwords. Includes security features like expiration,
    usage tracking, and rate limiting.
    """

    __tablename__ = "magic_links"

    id: Mapped[UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid4, index=True
    )
    token: Mapped[str] = mapped_column(
        String(255), unique=True, nullable=False, index=True
    )
    user_id: Mapped[UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )

    # Email associated with this magic link
    email: Mapped[str] = mapped_column(String(255), nullable=False, index=True)

    # Token validity
    expires_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, index=True
    )
    is_used: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)

    # Security tracking
    ip_address: Mapped[Optional[str]] = mapped_column(
        String(45), nullable=True
    )  # IPv6 support
    user_agent: Mapped[Optional[str]] = mapped_column(Text, nullable=True)

    # Request tracking (for rate limiting)
    request_ip: Mapped[Optional[str]] = mapped_column(
        String(45), nullable=True
    )  # IP that requested the magic link
    request_user_agent: Mapped[Optional[str]] = mapped_column(Text, nullable=True)

    # Usage tracking
    attempt_count: Mapped[int] = mapped_column(
        Integer, default=0, nullable=False
    )  # Number of verification attempts
    max_attempts: Mapped[int] = mapped_column(
        Integer, default=3, nullable=False
    )  # Maximum allowed attempts

    # Timestamps
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    used_at: Mapped[Optional[datetime]] = mapped_column(
        DateTime(timezone=True), nullable=True
    )
    last_attempt_at: Mapped[Optional[datetime]] = mapped_column(
        DateTime(timezone=True), nullable=True
    )

    # Relationships
    user: Mapped["User"] = relationship("User", back_populates="magic_links")

    def __repr__(self) -> str:
        return (
            f"<MagicLink(id={self.id}, user_id={self.user_id}, "
            f"email={self.email}, expires_at={self.expires_at})>"
        )

    @property
    def is_expired(self) -> bool:
        """Check if the magic link has expired."""
        return datetime.now(timezone.utc) > self.expires_at

    @property
    def is_valid(self) -> bool:
        """
        Check if the magic link is valid.

        A link is valid if:
        - It hasn't expired
        - It hasn't been used
        - It hasn't exceeded max attempts
        """
        return (
            not self.is_expired
            and not self.is_used
            and self.attempt_count < self.max_attempts
        )

    @property
    def remaining_attempts(self) -> int:
        """Get the number of remaining verification attempts."""
        return max(0, self.max_attempts - self.attempt_count)

    def increment_attempts(self) -> None:
        """Increment the attempt counter and update last attempt timestamp."""
        self.attempt_count += 1
        self.last_attempt_at = datetime.now(timezone.utc)

    def mark_as_used(
        self, ip_address: Optional[str] = None, user_agent: Optional[str] = None
    ) -> None:
        """
        Mark the magic link as used.

        Args:
            ip_address: IP address that used the link
            user_agent: User agent that used the link
        """
        self.is_used = True
        self.used_at = datetime.now(timezone.utc)
        if ip_address:
            self.ip_address = ip_address
        if user_agent:
            self.user_agent = user_agent

    @classmethod
    def create_expires_at(cls, minutes: int = 15) -> datetime:
        """
        Create expiration datetime for magic link.

        Args:
            minutes: Number of minutes until expiration (default: 15)

        Returns:
            Expiration datetime
        """
        return datetime.now(timezone.utc) + timedelta(minutes=minutes)

    @classmethod
    def generate_token(cls) -> str:
        """
        Generate a secure random token for the magic link.

        Returns:
            Secure random token string
        """
        import secrets

        return secrets.token_urlsafe(32)
