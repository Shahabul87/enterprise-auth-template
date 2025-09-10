"""
Webhook model for external event notifications
"""
from sqlalchemy import Column, String, Boolean, DateTime, Integer, Text, JSON, ForeignKey
from sqlalchemy.orm import relationship
from datetime import datetime
import uuid
import enum

from app.core.database import Base


class WebhookEventType(str, enum.Enum):
    """Webhook event types."""
    USER_CREATED = "user.created"
    USER_UPDATED = "user.updated"
    USER_DELETED = "user.deleted"
    USER_LOGIN = "user.login"
    USER_LOGOUT = "user.logout"
    ROLE_ASSIGNED = "role.assigned"
    ROLE_REVOKED = "role.revoked"
    SESSION_CREATED = "session.created"
    SESSION_EXPIRED = "session.expired"
    AUDIT_LOG_CREATED = "audit.created"


class WebhookStatus(str, enum.Enum):
    """Webhook delivery status."""
    PENDING = "pending"
    SUCCESS = "success"
    FAILED = "failed"
    RETRYING = "retrying"

class Webhook(Base):
    """Model for webhook configurations"""
    __tablename__ = "webhooks"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    name = Column(String, nullable=False)
    description = Column(Text, nullable=True)
    url = Column(String, nullable=False)
    secret = Column(String, nullable=True)  # For HMAC signature validation
    events = Column(JSON, nullable=False, default=list)  # List of event types to trigger
    headers = Column(JSON, nullable=True)  # Custom headers to include
    is_active = Column(Boolean, default=True, nullable=False)
    retry_count = Column(Integer, default=3)
    timeout_seconds = Column(Integer, default=30)

    # Organization association for multi-tenancy
    organization_id = Column(String, ForeignKey("organizations.id"), nullable=True)
    created_by = Column(String, ForeignKey("users.id"), nullable=False)

    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)
    last_triggered_at = Column(DateTime, nullable=True)

    # Statistics
    success_count = Column(Integer, default=0)
    failure_count = Column(Integer, default=0)

    # Relationships
    organization = relationship("Organization", backref="webhooks", foreign_keys=[organization_id])
    creator = relationship("User", backref="created_webhooks", foreign_keys=[created_by])
    deliveries = relationship("WebhookDelivery", back_populates="webhook", cascade="all, delete-orphan")

    def __repr__(self):
        return f"<Webhook(id='{self.id}', name='{self.name}', url='{self.url}')>"

    def should_trigger(self, event_type: str) -> bool:
        """Check if webhook should be triggered for given event type"""
        return bool(event_type in self.events and self.is_active)


class WebhookDelivery(Base):
    """Model for tracking webhook delivery attempts"""
    __tablename__ = "webhook_deliveries"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    webhook_id = Column(String, ForeignKey("webhooks.id"), nullable=False)
    event_type = Column(String, nullable=False)
    payload = Column(JSON, nullable=False)

    # Delivery status
    status = Column(String, nullable=False)  # pending, success, failed, retrying
    attempt_count = Column(Integer, default=0)
    response_status = Column(Integer, nullable=True)
    response_body = Column(Text, nullable=True)
    error_message = Column(Text, nullable=True)

    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    delivered_at = Column(DateTime, nullable=True)
    next_retry_at = Column(DateTime, nullable=True)

    # Relationships
    webhook = relationship("Webhook", back_populates="deliveries")

    def __repr__(self):
        return f"<WebhookDelivery(id='{self.id}', webhook_id='{self.webhook_id}', status='{self.status}')>"
