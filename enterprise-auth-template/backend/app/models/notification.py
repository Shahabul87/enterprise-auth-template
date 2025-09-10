"""
Notification model for notification system.
"""

from datetime import datetime
from typing import TYPE_CHECKING, Optional, Dict, Any, List
from sqlalchemy import Boolean, Column, DateTime, ForeignKey, String, Text, JSON, Enum
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship
import uuid
import enum

from app.core.database import Base

if TYPE_CHECKING:
    from app.models.user import User


class NotificationType(str, enum.Enum):
    """Notification types."""
    EMAIL = "email"
    SMS = "sms"
    PUSH = "push"
    IN_APP = "in_app"
    WEBHOOK = "webhook"


class NotificationPriority(str, enum.Enum):
    """Notification priority levels."""
    LOW = "low"
    NORMAL = "normal"
    HIGH = "high"
    URGENT = "urgent"


class NotificationStatus(str, enum.Enum):
    """Notification delivery status."""
    PENDING = "pending"
    SENT = "sent"
    DELIVERED = "delivered"
    FAILED = "failed"
    CANCELLED = "cancelled"
    READ = "read"


class NotificationCategory(str, enum.Enum):
    """Notification categories."""
    SECURITY = "security"
    ACCOUNT = "account"
    BILLING = "billing"
    SYSTEM = "system"
    MARKETING = "marketing"
    GENERAL = "general"


class Notification(Base):
    """Notification model for system notifications."""

    __tablename__ = "notifications"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
        index=True
    )

    # Notification content
    title: Mapped[str] = mapped_column(
        String(200),
        nullable=False
    )
    message: Mapped[str] = mapped_column(
        Text,
        nullable=False
    )
    data: Mapped[Optional[Dict[str, Any]]] = mapped_column(
        JSON,
        nullable=True,
        comment="Additional data/metadata for the notification"
    )

    # Notification properties
    type: Mapped[NotificationType] = mapped_column(
        Enum(NotificationType),
        nullable=False,
        index=True
    )
    category: Mapped[NotificationCategory] = mapped_column(
        Enum(NotificationCategory),
        nullable=False,
        index=True
    )
    priority: Mapped[NotificationPriority] = mapped_column(
        Enum(NotificationPriority),
        default=NotificationPriority.NORMAL,
        nullable=False,
        index=True
    )
    status: Mapped[NotificationStatus] = mapped_column(
        Enum(NotificationStatus),
        default=NotificationStatus.PENDING,
        nullable=False,
        index=True
    )

    # Action/Link
    action_url: Mapped[Optional[str]] = mapped_column(
        String(500),
        nullable=True,
        comment="URL for notification action"
    )
    action_text: Mapped[Optional[str]] = mapped_column(
        String(100),
        nullable=True,
        comment="Text for action button"
    )

    # Recipient
    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id"),
        nullable=False,
        index=True
    )

    # Delivery details
    channel_data: Mapped[Optional[Dict[str, Any]]] = mapped_column(
        JSON,
        nullable=True,
        comment="Channel-specific data (e.g., email address, phone number)"
    )
    delivery_attempts: Mapped[int] = mapped_column(
        default=0,
        nullable=False
    )
    last_attempt_at: Mapped[Optional[datetime]] = mapped_column(
        DateTime,
        nullable=True
    )
    delivered_at: Mapped[Optional[datetime]] = mapped_column(
        DateTime,
        nullable=True
    )
    read_at: Mapped[Optional[datetime]] = mapped_column(
        DateTime,
        nullable=True
    )
    error_message: Mapped[Optional[str]] = mapped_column(
        Text,
        nullable=True
    )

    # Scheduling
    scheduled_for: Mapped[Optional[datetime]] = mapped_column(
        DateTime,
        nullable=True,
        index=True,
        comment="When to send the notification (null means immediate)"
    )
    expires_at: Mapped[Optional[datetime]] = mapped_column(
        DateTime,
        nullable=True,
        comment="When the notification expires and should not be sent"
    )

    # Timestamps
    created_at: Mapped[datetime] = mapped_column(
        DateTime,
        default=datetime.utcnow,
        nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime,
        default=datetime.utcnow,
        onupdate=datetime.utcnow,
        nullable=False
    )

    # Relationships
    user: Mapped["User"] = relationship(
        "User",
        back_populates="notifications"
    )

    def __repr__(self) -> str:
        return f"<Notification {self.type.value}: {self.title[:30]}...>"

    def is_read(self) -> bool:
        """Check if notification has been read."""
        return self.read_at is not None or self.status == NotificationStatus.READ

    def is_expired(self) -> bool:
        """Check if notification has expired."""
        if self.expires_at is None:
            return False
        return datetime.utcnow() > self.expires_at

    def can_send(self) -> bool:
        """Check if notification can be sent."""
        return (
            self.status == NotificationStatus.PENDING and
            not self.is_expired() and
            (self.scheduled_for is None or datetime.utcnow() >= self.scheduled_for)
        )

    def mark_as_sent(self) -> None:
        """Mark notification as sent."""
        self.status = NotificationStatus.SENT
        self.delivery_attempts += 1
        self.last_attempt_at = datetime.utcnow()

    def mark_as_delivered(self) -> None:
        """Mark notification as delivered."""
        self.status = NotificationStatus.DELIVERED
        self.delivered_at = datetime.utcnow()

    def mark_as_read(self) -> None:
        """Mark notification as read."""
        self.status = NotificationStatus.READ
        self.read_at = datetime.utcnow()

    def mark_as_failed(self, error_message: str) -> None:
        """Mark notification as failed."""
        self.status = NotificationStatus.FAILED
        self.error_message = error_message
        self.delivery_attempts += 1
        self.last_attempt_at = datetime.utcnow()

    def to_dict(self) -> dict:
        """Convert notification to dictionary."""
        return {
            "id": str(self.id),
            "title": self.title,
            "message": self.message,
            "type": self.type.value,
            "category": self.category.value,
            "priority": self.priority.value,
            "status": self.status.value,
            "action_url": self.action_url,
            "action_text": self.action_text,
            "is_read": self.is_read(),
            "user_id": str(self.user_id),
            "delivery_attempts": self.delivery_attempts,
            "delivered_at": self.delivered_at.isoformat() if self.delivered_at else None,
            "read_at": self.read_at.isoformat() if self.read_at else None,
            "scheduled_for": self.scheduled_for.isoformat() if self.scheduled_for else None,
            "expires_at": self.expires_at.isoformat() if self.expires_at else None,
            "created_at": self.created_at.isoformat(),
            "updated_at": self.updated_at.isoformat()
        }


class NotificationTemplate(Base):
    """Template for notifications."""

    __tablename__ = "notification_templates"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
        index=True
    )
    name: Mapped[str] = mapped_column(
        String(100),
        unique=True,
        nullable=False,
        index=True
    )
    description: Mapped[Optional[str]] = mapped_column(
        Text,
        nullable=True
    )

    # Template content
    title_template: Mapped[str] = mapped_column(
        String(500),
        nullable=False,
        comment="Template for notification title (supports variables)"
    )
    message_template: Mapped[str] = mapped_column(
        Text,
        nullable=False,
        comment="Template for notification message (supports variables)"
    )

    # Template properties
    type: Mapped[NotificationType] = mapped_column(
        Enum(NotificationType),
        nullable=False
    )
    category: Mapped[NotificationCategory] = mapped_column(
        Enum(NotificationCategory),
        nullable=False
    )
    default_priority: Mapped[NotificationPriority] = mapped_column(
        Enum(NotificationPriority),
        default=NotificationPriority.NORMAL,
        nullable=False
    )

    # Variables
    required_variables: Mapped[List[str]] = mapped_column(
        JSON,
        nullable=False,
        default=list,
        comment="List of required template variables"
    )

    # Status
    is_active: Mapped[bool] = mapped_column(
        Boolean,
        default=True,
        nullable=False,
        index=True
    )

    # Timestamps
    created_at: Mapped[datetime] = mapped_column(
        DateTime,
        default=datetime.utcnow,
        nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime,
        default=datetime.utcnow,
        onupdate=datetime.utcnow,
        nullable=False
    )

    def __repr__(self) -> str:
        return f"<NotificationTemplate {self.name}>"
