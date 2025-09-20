"""
Device Model

Tracks user devices for fingerprinting and trust management.
"""

from datetime import datetime
from typing import TYPE_CHECKING, Optional
from uuid import uuid4

from sqlalchemy import Boolean, DateTime, ForeignKey, Integer, String, Text
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base

if TYPE_CHECKING:
    from app.models.user import User


class UserDevice(Base):
    """
    Model for tracking user devices and their trust status.
    """

    __tablename__ = "user_devices"

    # Primary fields
    id: Mapped[UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid4, index=True
    )
    user_id: Mapped[UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False
    )
    device_hash: Mapped[str] = mapped_column(String(64), nullable=False, index=True)

    # Device information
    device_name: Mapped[Optional[str]] = mapped_column(String(100), nullable=True)
    device_type: Mapped[str] = mapped_column(
        String(20), nullable=False  # mobile, tablet, desktop, unknown
    )
    browser: Mapped[Optional[str]] = mapped_column(String(50), nullable=True)
    browser_version: Mapped[Optional[str]] = mapped_column(String(20), nullable=True)
    os: Mapped[Optional[str]] = mapped_column(String(50), nullable=True)
    os_version: Mapped[Optional[str]] = mapped_column(String(20), nullable=True)

    # Fingerprint data
    fingerprint_data: Mapped[Optional[dict]] = mapped_column(
        JSONB, nullable=True, default=dict
    )

    # Location information
    last_ip_address: Mapped[Optional[str]] = mapped_column(
        String(45), nullable=True  # Supports IPv6
    )
    last_country: Mapped[Optional[str]] = mapped_column(String(2), nullable=True)
    last_city: Mapped[Optional[str]] = mapped_column(String(100), nullable=True)

    # Trust and verification
    is_trusted: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    trust_score: Mapped[float] = mapped_column(
        Integer, default=50, nullable=False  # 0-100
    )
    is_verified: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    verified_at: Mapped[Optional[datetime]] = mapped_column(
        DateTime(timezone=True), nullable=True
    )
    verification_method: Mapped[Optional[str]] = mapped_column(
        String(20), nullable=True  # email, sms, push, manual
    )

    # Usage tracking
    first_seen_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, default=datetime.utcnow
    )
    last_seen_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, default=datetime.utcnow
    )
    seen_count: Mapped[int] = mapped_column(Integer, default=1, nullable=False)

    # Security flags
    is_blocked: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    blocked_at: Mapped[Optional[datetime]] = mapped_column(
        DateTime(timezone=True), nullable=True
    )
    blocked_reason: Mapped[Optional[str]] = mapped_column(Text, nullable=True)

    # Push notification token (for mobile devices)
    push_token: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)

    # Timestamps
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, server_default="now()"
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        server_default="now()",
        onupdate=datetime.utcnow,
    )

    # Relationships
    user: Mapped["User"] = relationship("User", back_populates="devices", lazy="joined")

    def __repr__(self) -> str:
        return f"<UserDevice(id={self.id}, user_id={self.user_id}, type={self.device_type})>"
