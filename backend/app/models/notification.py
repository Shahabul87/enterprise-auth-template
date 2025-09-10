"""
Notification model for notification system.
"""
from typing import List, Optional, TYPE_CHECKING, Dict, Any
from datetime import datetime
from sqlalchemy import Column, String, DateTime, Boolean, Text, ForeignKey, Integer, Enum
from sqlalchemy.orm import relationship, Mapped, mapped_column
from sqlalchemy.dialects.postgresql import UUID, JSON
import uuid
import enum

from app.core.database import Base

if TYPE_CHECKING:
    from app.models.user import User
    from app.models.organization import Organization


class NotificationType(str, enum.Enum):
    """Notification delivery types."""
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
    """Notification categories for organization."""
    SECURITY = "security"
    ACCOUNT = "account"
    BILLING = "billing"
    SYSTEM = "system"
    MARKETING = "marketing"
    GENERAL = "general"
    WEBHOOK = "webhook"
    API = "api"


class Notification(Base):
    """Notification model for system notifications."""
    
    __tablename__ = "notifications"
    
    # Primary key
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
    summary: Mapped[Optional[str]] = mapped_column(
        String(500),
        nullable=True,
        comment="Brief summary for previews"
    )
    
    # Rich content support
    html_content: Mapped[Optional[str]] = mapped_column(
        Text,
        nullable=True,
        comment="HTML version of the message"
    )
    data: Mapped[Optional[Dict[str, Any]]] = mapped_column(
        JSON,
        nullable=True,
        comment="Additional structured data/metadata"
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
    
    # Action/Link capabilities
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
    deep_link: Mapped[Optional[str]] = mapped_column(
        String(500),
        nullable=True,
        comment="Deep link for mobile app navigation"
    )
    
    # Recipient information
    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True
    )
    organization_id: Mapped[Optional[uuid.UUID]] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("organizations.id", ondelete="CASCADE"),
        nullable=True,
        index=True
    )
    
    # Channel-specific delivery details
    channel_data: Mapped[Optional[Dict[str, Any]]] = mapped_column(
        JSON,
        nullable=True,
        comment="Channel-specific data (email address, phone number, etc.)"
    )
    delivery_attempts: Mapped[int] = mapped_column(
        Integer,
        default=0,
        nullable=False
    )
    max_delivery_attempts: Mapped[int] = mapped_column(
        Integer,
        default=3,
        nullable=False
    )
    
    # Delivery tracking timestamps
    last_attempt_at: Mapped[Optional[datetime]] = mapped_column(
        DateTime,
        nullable=True
    )
    delivered_at: Mapped[Optional[datetime]] = mapped_column(
        DateTime,
        nullable=True,
        index=True
    )
    read_at: Mapped[Optional[datetime]] = mapped_column(
        DateTime,
        nullable=True,
        index=True
    )
    clicked_at: Mapped[Optional[datetime]] = mapped_column(
        DateTime,
        nullable=True,
        comment="When user clicked on the notification"
    )
    
    # Error handling
    error_message: Mapped[Optional[str]] = mapped_column(
        Text,
        nullable=True
    )
    error_code: Mapped[Optional[str]] = mapped_column(
        String(50),
        nullable=True
    )
    
    # Scheduling and expiration
    scheduled_for: Mapped[Optional[datetime]] = mapped_column(
        DateTime,
        nullable=True,
        index=True,
        comment="When to send the notification (null means immediate)"
    )
    expires_at: Mapped[Optional[datetime]] = mapped_column(
        DateTime,
        nullable=True,
        index=True,
        comment="When the notification expires and should not be sent"
    )
    
    # Template and personalization
    template_id: Mapped[Optional[str]] = mapped_column(
        String(100),
        nullable=True,
        comment="Template used to generate this notification"
    )
    template_variables: Mapped[Optional[Dict[str, Any]]] = mapped_column(
        JSON,
        nullable=True,
        comment="Variables used in template rendering"
    )
    
    # Grouping and threading
    thread_id: Mapped[Optional[str]] = mapped_column(
        String(100),
        nullable=True,
        index=True,
        comment="For grouping related notifications"
    )
    parent_id: Mapped[Optional[uuid.UUID]] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("notifications.id"),
        nullable=True,
        comment="Parent notification for replies/updates"
    )
    
    # Tracking and analytics
    source: Mapped[Optional[str]] = mapped_column(
        String(100),
        nullable=True,
        comment="Source system/component that generated this notification"
    )
    source_id: Mapped[Optional[str]] = mapped_column(
        String(100),
        nullable=True,
        comment="Source-specific identifier"
    )
    tracking_id: Mapped[Optional[str]] = mapped_column(
        String(100),
        nullable=True,
        index=True,
        comment="External tracking ID"
    )
    
    # Timestamps
    created_at: Mapped[datetime] = mapped_column(
        DateTime,
        default=datetime.utcnow,
        nullable=False,
        index=True
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime,
        default=datetime.utcnow,
        onupdate=datetime.utcnow,
        nullable=False
    )
    created_by: Mapped[Optional[uuid.UUID]] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="SET NULL"),
        nullable=True
    )
    
    # Relationships
    user: Mapped["User"] = relationship(
        "User",
        foreign_keys=[user_id],
        back_populates="notifications",
        lazy="selectin"
    )
    
    organization: Mapped[Optional["Organization"]] = relationship(
        "Organization",
        back_populates="notifications",
        lazy="selectin"
    )
    
    creator: Mapped[Optional["User"]] = relationship(
        "User",
        foreign_keys=[created_by],
        lazy="selectin"
    )
    
    parent: Mapped[Optional["Notification"]] = relationship(
        "Notification",
        remote_side=[id],
        backref="children"
    )
    
    # Properties
    @property
    def is_read(self) -> bool:
        """Check if notification has been read."""
        return self.read_at is not None or self.status == NotificationStatus.READ
    
    @property
    def is_clicked(self) -> bool:
        """Check if notification has been clicked."""
        return self.clicked_at is not None
    
    @property
    def is_expired(self) -> bool:
        """Check if notification has expired."""
        if self.expires_at is None:
            return False
        return datetime.utcnow() > self.expires_at
    
    @property
    def is_scheduled(self) -> bool:
        """Check if notification is scheduled for future delivery."""
        if self.scheduled_for is None:
            return False
        return datetime.utcnow() < self.scheduled_for
    
    @property
    def can_send(self) -> bool:
        """Check if notification can be sent now."""
        return (
            self.status == NotificationStatus.PENDING and
            not self.is_expired and
            not self.is_scheduled and
            self.delivery_attempts < self.max_delivery_attempts
        )
    
    @property
    def can_retry(self) -> bool:
        """Check if notification can be retried."""
        return (
            self.status == NotificationStatus.FAILED and
            not self.is_expired and
            self.delivery_attempts < self.max_delivery_attempts
        )
    
    @property
    def delivery_success_rate(self) -> float:
        """Calculate delivery success rate for analytics."""
        if self.delivery_attempts == 0:
            return 0.0
        return 1.0 if self.status in [NotificationStatus.SENT, NotificationStatus.DELIVERED] else 0.0
    
    # Methods
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
        if not self.is_read:
            self.status = NotificationStatus.READ
            self.read_at = datetime.utcnow()
    
    def mark_as_clicked(self) -> None:
        """Mark notification as clicked."""
        if not self.is_clicked:
            self.clicked_at = datetime.utcnow()
            # Also mark as read when clicked
            if not self.is_read:
                self.mark_as_read()
    
    def mark_as_failed(self, error_message: str, error_code: Optional[str] = None) -> None:
        """Mark notification as failed with error details."""
        self.status = NotificationStatus.FAILED
        self.error_message = error_message
        self.error_code = error_code
        self.delivery_attempts += 1
        self.last_attempt_at = datetime.utcnow()
    
    def cancel(self, reason: Optional[str] = None) -> None:
        """Cancel pending notification."""
        if self.status == NotificationStatus.PENDING:
            self.status = NotificationStatus.CANCELLED
            if reason:
                self.error_message = f"Cancelled: {reason}"
    
    def schedule(self, scheduled_time: datetime) -> None:
        """Schedule notification for future delivery."""
        if self.status == NotificationStatus.PENDING:
            self.scheduled_for = scheduled_time
    
    def set_expiration(self, expires_at: datetime) -> None:
        """Set notification expiration time."""
        self.expires_at = expires_at
    
    def add_tracking_data(self, key: str, value: Any) -> None:
        """Add tracking data to notification."""
        if self.data is None:
            self.data = {}
        self.data[key] = value
    
    def to_dict(self, include_content: bool = True, include_tracking: bool = False) -> dict:
        """Convert notification to dictionary."""
        data = {
            "id": str(self.id),
            "title": self.title,
            "summary": self.summary,
            "type": self.type.value,
            "category": self.category.value,
            "priority": self.priority.value,
            "status": self.status.value,
            "action_url": self.action_url,
            "action_text": self.action_text,
            "deep_link": self.deep_link,
            "is_read": self.is_read,
            "is_clicked": self.is_clicked,
            "is_expired": self.is_expired,
            "is_scheduled": self.is_scheduled,
            "user_id": str(self.user_id),
            "organization_id": str(self.organization_id) if self.organization_id else None,
            "delivery_attempts": self.delivery_attempts,
            "max_delivery_attempts": self.max_delivery_attempts,
            "delivered_at": self.delivered_at.isoformat() if self.delivered_at else None,
            "read_at": self.read_at.isoformat() if self.read_at else None,
            "clicked_at": self.clicked_at.isoformat() if self.clicked_at else None,
            "scheduled_for": self.scheduled_for.isoformat() if self.scheduled_for else None,
            "expires_at": self.expires_at.isoformat() if self.expires_at else None,
            "created_at": self.created_at.isoformat(),
            "updated_at": self.updated_at.isoformat(),
            "thread_id": self.thread_id,
            "parent_id": str(self.parent_id) if self.parent_id else None
        }
        
        if include_content:
            data.update({
                "message": self.message,
                "html_content": self.html_content,
                "data": self.data or {}
            })
        
        if include_tracking:
            data.update({
                "source": self.source,
                "source_id": self.source_id,
                "tracking_id": self.tracking_id,
                "template_id": self.template_id,
                "template_variables": self.template_variables or {},
                "channel_data": self.channel_data or {},
                "error_message": self.error_message,
                "error_code": self.error_code,
                "delivery_success_rate": self.delivery_success_rate
            })
        
        return data
    
    def __repr__(self) -> str:
        return f"<Notification(id={self.id}, type={self.type.value}, title='{self.title[:30]}...')>"
    
    def __str__(self) -> str:
        return self.title


class NotificationTemplate(Base):
    """Template for generating notifications with consistent formatting."""
    
    __tablename__ = "notification_templates"
    
    # Primary key
    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
        index=True
    )
    
    # Template identification
    name: Mapped[str] = mapped_column(
        String(100),
        unique=True,
        nullable=False,
        index=True
    )
    display_name: Mapped[str] = mapped_column(
        String(200),
        nullable=False
    )
    description: Mapped[Optional[str]] = mapped_column(
        Text,
        nullable=True
    )
    version: Mapped[str] = mapped_column(
        String(20),
        default="1.0",
        nullable=False
    )
    
    # Template content with variable support
    title_template: Mapped[str] = mapped_column(
        String(500),
        nullable=False,
        comment="Template for notification title (supports Jinja2 variables)"
    )
    message_template: Mapped[str] = mapped_column(
        Text,
        nullable=False,
        comment="Template for notification message (supports Jinja2 variables)"
    )
    html_template: Mapped[Optional[str]] = mapped_column(
        Text,
        nullable=True,
        comment="HTML template for rich content"
    )
    summary_template: Mapped[Optional[str]] = mapped_column(
        String(500),
        nullable=True,
        comment="Template for notification summary"
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
    
    # Template variables and validation
    required_variables: Mapped[List[str]] = mapped_column(
        JSON,
        nullable=False,
        default=list,
        comment="List of required template variables"
    )
    optional_variables: Mapped[List[str]] = mapped_column(
        JSON,
        nullable=False,
        default=list,
        comment="List of optional template variables"
    )
    variable_schemas: Mapped[Optional[Dict[str, Any]]] = mapped_column(
        JSON,
        nullable=True,
        comment="JSON schemas for variable validation"
    )
    
    # Template settings
    is_active: Mapped[bool] = mapped_column(
        Boolean,
        default=True,
        nullable=False,
        index=True
    )
    is_system: Mapped[bool] = mapped_column(
        Boolean,
        default=False,
        nullable=False,
        comment="System templates cannot be deleted"
    )
    
    # Delivery settings
    default_channel_data: Mapped[Optional[Dict[str, Any]]] = mapped_column(
        JSON,
        nullable=True,
        comment="Default channel-specific settings"
    )
    max_delivery_attempts: Mapped[int] = mapped_column(
        Integer,
        default=3,
        nullable=False
    )
    default_expiry_hours: Mapped[Optional[int]] = mapped_column(
        Integer,
        nullable=True,
        comment="Default expiry time in hours"
    )
    
    # Organization context
    organization_id: Mapped[Optional[uuid.UUID]] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("organizations.id", ondelete="CASCADE"),
        nullable=True,
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
    created_by: Mapped[Optional[uuid.UUID]] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="SET NULL"),
        nullable=True
    )
    
    # Relationships
    organization: Mapped[Optional["Organization"]] = relationship(
        "Organization",
        lazy="selectin"
    )
    
    creator: Mapped[Optional["User"]] = relationship(
        "User",
        lazy="selectin"
    )
    
    # Methods
    def validate_variables(self, variables: Dict[str, Any]) -> bool:
        """Validate template variables against schema."""
        # Check required variables
        for var in self.required_variables:
            if var not in variables:
                return False
        
        # TODO: Add JSON schema validation for variable_schemas
        return True
    
    def render(self, variables: Dict[str, Any]) -> Dict[str, str]:
        """Render template with provided variables."""
        if not self.validate_variables(variables):
            raise ValueError("Invalid template variables provided")
        
        # TODO: Implement Jinja2 template rendering
        # For now, simple string replacement
        rendered = {
            "title": self.title_template,
            "message": self.message_template,
            "html_content": self.html_template,
            "summary": self.summary_template
        }
        
        for key, template in rendered.items():
            if template:
                for var, value in variables.items():
                    template = template.replace(f"{{{{{var}}}}}", str(value))
                rendered[key] = template
        
        return rendered
    
    def to_dict(self) -> dict:
        """Convert template to dictionary."""
        return {
            "id": str(self.id),
            "name": self.name,
            "display_name": self.display_name,
            "description": self.description,
            "version": self.version,
            "title_template": self.title_template,
            "message_template": self.message_template,
            "html_template": self.html_template,
            "summary_template": self.summary_template,
            "type": self.type.value,
            "category": self.category.value,
            "default_priority": self.default_priority.value,
            "required_variables": self.required_variables,
            "optional_variables": self.optional_variables,
            "variable_schemas": self.variable_schemas or {},
            "is_active": self.is_active,
            "is_system": self.is_system,
            "default_channel_data": self.default_channel_data or {},
            "max_delivery_attempts": self.max_delivery_attempts,
            "default_expiry_hours": self.default_expiry_hours,
            "organization_id": str(self.organization_id) if self.organization_id else None,
            "created_at": self.created_at.isoformat(),
            "updated_at": self.updated_at.isoformat()
        }
    
    def __repr__(self) -> str:
        return f"<NotificationTemplate(id={self.id}, name={self.name})>"
    
    def __str__(self) -> str:
        return self.display_name or self.name


# Default notification templates
DEFAULT_NOTIFICATION_TEMPLATES = [
    {
        "name": "welcome_email",
        "display_name": "Welcome Email",
        "description": "Welcome email for new users",
        "title_template": "Welcome to {{app_name}}, {{user_name}}!",
        "message_template": "Thank you for joining {{app_name}}. Your account has been created successfully.",
        "type": NotificationType.EMAIL,
        "category": NotificationCategory.ACCOUNT,
        "required_variables": ["app_name", "user_name"],
        "is_system": True
    },
    {
        "name": "password_reset",
        "display_name": "Password Reset",
        "description": "Password reset notification",
        "title_template": "Password Reset Request",
        "message_template": "Click the link to reset your password: {{reset_link}}",
        "type": NotificationType.EMAIL,
        "category": NotificationCategory.SECURITY,
        "required_variables": ["reset_link"],
        "is_system": True
    },
    {
        "name": "login_alert",
        "display_name": "Login Alert",
        "description": "Security alert for new login",
        "title_template": "New Login Detected",
        "message_template": "A new login was detected from {{location}} at {{time}}",
        "type": NotificationType.EMAIL,
        "category": NotificationCategory.SECURITY,
        "required_variables": ["location", "time"],
        "is_system": True,
        "default_priority": NotificationPriority.HIGH
    }
]