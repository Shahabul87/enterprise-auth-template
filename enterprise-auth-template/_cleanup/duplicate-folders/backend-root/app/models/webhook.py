"""
Webhook model for external event notifications and integrations.
"""
from typing import List, Optional, TYPE_CHECKING, Dict, Any
from datetime import datetime, timedelta
from sqlalchemy import Column, String, DateTime, Boolean, Text, ForeignKey, Integer, Enum
from sqlalchemy.orm import relationship, Mapped, mapped_column
from sqlalchemy.dialects.postgresql import UUID, JSON
import uuid
import enum
import hmac
import hashlib
import secrets

from app.core.database import Base

if TYPE_CHECKING:
    from app.models.user import User
    from app.models.organization import Organization


class WebhookStatus(str, enum.Enum):
    """Webhook configuration status."""
    ACTIVE = "active"
    INACTIVE = "inactive"
    DISABLED = "disabled"
    ERROR = "error"


class WebhookDeliveryStatus(str, enum.Enum):
    """Webhook delivery status."""
    PENDING = "pending"
    SENDING = "sending"
    SUCCESS = "success"
    FAILED = "failed"
    RETRYING = "retrying"
    CANCELLED = "cancelled"


class WebhookEventType(str, enum.Enum):
    """Standard webhook event types."""
    # User events
    USER_CREATED = "user.created"
    USER_UPDATED = "user.updated"
    USER_DELETED = "user.deleted"
    USER_ACTIVATED = "user.activated"
    USER_DEACTIVATED = "user.deactivated"
    USER_LOGIN = "user.login"
    USER_LOGOUT = "user.logout"
    USER_PASSWORD_CHANGED = "user.password_changed"
    USER_EMAIL_VERIFIED = "user.email_verified"
    
    # Authentication events
    LOGIN_SUCCESS = "auth.login_success"
    LOGIN_FAILED = "auth.login_failed"
    LOGOUT = "auth.logout"
    PASSWORD_RESET = "auth.password_reset"
    TWO_FA_ENABLED = "auth.2fa_enabled"
    TWO_FA_DISABLED = "auth.2fa_disabled"
    ACCOUNT_LOCKED = "auth.account_locked"
    SUSPICIOUS_ACTIVITY = "auth.suspicious_activity"
    
    # Session events
    SESSION_CREATED = "session.created"
    SESSION_EXPIRED = "session.expired"
    SESSION_REVOKED = "session.revoked"
    
    # API Key events
    API_KEY_CREATED = "api_key.created"
    API_KEY_REVOKED = "api_key.revoked"
    API_KEY_EXPIRED = "api_key.expired"
    API_KEY_RATE_LIMITED = "api_key.rate_limited"
    
    # Organization events
    ORGANIZATION_CREATED = "organization.created"
    ORGANIZATION_UPDATED = "organization.updated"
    ORGANIZATION_MEMBER_ADDED = "organization.member_added"
    ORGANIZATION_MEMBER_REMOVED = "organization.member_removed"
    ORGANIZATION_ROLE_CHANGED = "organization.role_changed"
    
    # Role and Permission events
    ROLE_ASSIGNED = "role.assigned"
    ROLE_REVOKED = "role.revoked"
    PERMISSION_GRANTED = "permission.granted"
    PERMISSION_REVOKED = "permission.revoked"
    
    # Security events
    SECURITY_ALERT = "security.alert"
    BREACH_DETECTED = "security.breach_detected"
    COMPLIANCE_VIOLATION = "security.compliance_violation"
    
    # System events
    SYSTEM_MAINTENANCE = "system.maintenance"
    SYSTEM_ERROR = "system.error"
    BACKUP_COMPLETED = "system.backup_completed"
    
    # Custom events
    CUSTOM_EVENT = "custom.event"


class Webhook(Base):
    """Webhook configuration model for external event notifications."""
    
    __tablename__ = "webhooks"
    
    # Primary key
    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
        index=True
    )
    
    # Webhook identification
    name: Mapped[str] = mapped_column(
        String(100),
        nullable=False
    )
    description: Mapped[Optional[str]] = mapped_column(
        Text,
        nullable=True
    )
    
    # Endpoint configuration
    url: Mapped[str] = mapped_column(
        String(500),
        nullable=False,
        comment="Target URL for webhook delivery"
    )
    http_method: Mapped[str] = mapped_column(
        String(10),
        default="POST",
        nullable=False
    )
    content_type: Mapped[str] = mapped_column(
        String(50),
        default="application/json",
        nullable=False
    )
    
    # Security
    secret_key: Mapped[Optional[str]] = mapped_column(
        String(255),
        nullable=True,
        comment="Secret key for HMAC signature validation"
    )
    signature_header: Mapped[str] = mapped_column(
        String(50),
        default="X-Webhook-Signature",
        nullable=False
    )
    signature_algorithm: Mapped[str] = mapped_column(
        String(20),
        default="sha256",
        nullable=False
    )
    
    # Custom headers
    custom_headers: Mapped[Optional[Dict[str, str]]] = mapped_column(
        JSON,
        nullable=True,
        comment="Custom HTTP headers to include in requests"
    )
    
    # Event configuration
    events: Mapped[List[str]] = mapped_column(
        JSON,
        nullable=False,
        default=list,
        comment="List of event types to trigger webhook"
    )
    event_filter: Mapped[Optional[Dict[str, Any]]] = mapped_column(
        JSON,
        nullable=True,
        comment="Additional filtering criteria for events"
    )
    
    # Delivery configuration
    timeout_seconds: Mapped[int] = mapped_column(
        Integer,
        default=30,
        nullable=False
    )
    max_retries: Mapped[int] = mapped_column(
        Integer,
        default=3,
        nullable=False
    )
    retry_delay_seconds: Mapped[int] = mapped_column(
        Integer,
        default=60,
        nullable=False,
        comment="Initial delay between retries (exponential backoff)"
    )
    max_retry_delay_seconds: Mapped[int] = mapped_column(
        Integer,
        default=3600,
        nullable=False,
        comment="Maximum delay between retries"
    )
    
    # SSL/TLS configuration
    verify_ssl: Mapped[bool] = mapped_column(
        Boolean,
        default=True,
        nullable=False
    )
    ssl_cert_path: Mapped[Optional[str]] = mapped_column(
        String(255),
        nullable=True,
        comment="Path to client SSL certificate"
    )
    
    # Authentication
    auth_type: Mapped[Optional[str]] = mapped_column(
        String(20),
        nullable=True,
        comment="Authentication type: basic, bearer, api_key"
    )
    auth_config: Mapped[Optional[Dict[str, str]]] = mapped_column(
        JSON,
        nullable=True,
        comment="Authentication configuration (encrypted)"
    )
    
    # Status and health
    status: Mapped[WebhookStatus] = mapped_column(
        Enum(WebhookStatus),
        default=WebhookStatus.ACTIVE,
        nullable=False,
        index=True
    )
    is_active: Mapped[bool] = mapped_column(
        Boolean,
        default=True,
        nullable=False,
        index=True
    )
    
    # Health monitoring
    last_ping_at: Mapped[Optional[datetime]] = mapped_column(
        DateTime,
        nullable=True
    )
    last_ping_status: Mapped[Optional[int]] = mapped_column(
        Integer,
        nullable=True,
        comment="HTTP status code of last ping"
    )
    health_check_enabled: Mapped[bool] = mapped_column(
        Boolean,
        default=False,
        nullable=False
    )
    health_check_interval_minutes: Mapped[int] = mapped_column(
        Integer,
        default=60,
        nullable=False
    )
    
    # Statistics and monitoring
    total_deliveries: Mapped[int] = mapped_column(
        Integer,
        default=0,
        nullable=False
    )
    successful_deliveries: Mapped[int] = mapped_column(
        Integer,
        default=0,
        nullable=False
    )
    failed_deliveries: Mapped[int] = mapped_column(
        Integer,
        default=0,
        nullable=False
    )
    last_delivery_at: Mapped[Optional[datetime]] = mapped_column(
        DateTime,
        nullable=True,
        index=True
    )
    last_success_at: Mapped[Optional[datetime]] = mapped_column(
        DateTime,
        nullable=True
    )
    last_failure_at: Mapped[Optional[datetime]] = mapped_column(
        DateTime,
        nullable=True
    )
    average_response_time_ms: Mapped[Optional[int]] = mapped_column(
        Integer,
        nullable=True
    )
    
    # Rate limiting
    rate_limit_per_minute: Mapped[Optional[int]] = mapped_column(
        Integer,
        nullable=True,
        comment="Maximum deliveries per minute"
    )
    rate_limit_per_hour: Mapped[Optional[int]] = mapped_column(
        Integer,
        nullable=True,
        comment="Maximum deliveries per hour"
    )
    
    # Ownership and organization
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
    
    # Metadata and tags
    tags: Mapped[Optional[List[str]]] = mapped_column(
        JSON,
        nullable=True,
        comment="User-defined tags for organization"
    )
    metadata: Mapped[Optional[Dict[str, Any]]] = mapped_column(
        JSON,
        nullable=True,
        comment="Additional metadata"
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
    last_modified_by: Mapped[Optional[uuid.UUID]] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="SET NULL"),
        nullable=True
    )
    
    # Relationships
    user: Mapped["User"] = relationship(
        "User",
        foreign_keys=[user_id],
        back_populates="webhooks",
        lazy="selectin"
    )
    
    organization: Mapped[Optional["Organization"]] = relationship(
        "Organization",
        back_populates="webhooks",
        lazy="selectin"
    )
    
    modifier: Mapped[Optional["User"]] = relationship(
        "User",
        foreign_keys=[last_modified_by],
        lazy="selectin"
    )
    
    # Properties
    @property
    def success_rate(self) -> float:
        """Calculate delivery success rate."""
        if self.total_deliveries == 0:
            return 0.0
        return (self.successful_deliveries / self.total_deliveries) * 100
    
    @property
    def failure_rate(self) -> float:
        """Calculate delivery failure rate."""
        return 100.0 - self.success_rate
    
    @property
    def is_healthy(self) -> bool:
        """Check if webhook is healthy based on recent deliveries."""
        if not self.is_active or self.status != WebhookStatus.ACTIVE:
            return False
        
        # Check if there have been recent successful deliveries
        if self.last_success_at is None:
            return False
        
        # Consider healthy if success rate is above 80% and last success was recent
        recent_threshold = datetime.utcnow() - timedelta(hours=24)
        return (
            self.success_rate >= 80.0 and
            self.last_success_at >= recent_threshold
        )
    
    @property
    def needs_attention(self) -> bool:
        """Check if webhook needs attention (high failure rate)."""
        return (
            self.is_active and
            self.total_deliveries > 10 and
            self.failure_rate > 50.0
        )
    
    @property
    def is_rate_limited(self) -> bool:
        """Check if webhook is currently rate limited."""
        # This would need to be implemented with actual rate limiting logic
        # For now, just return False
        return False
    
    # Class methods
    @classmethod
    def generate_secret_key(cls) -> str:
        """Generate a new secret key for webhook signature verification."""
        return secrets.token_urlsafe(32)
    
    @classmethod
    def compute_signature(cls, payload: bytes, secret: str, algorithm: str = "sha256") -> str:
        """Compute HMAC signature for webhook payload."""
        signature = hmac.new(
            secret.encode(),
            payload,
            getattr(hashlib, algorithm)
        ).hexdigest()
        return f"{algorithm}={signature}"
    
    @classmethod
    def verify_signature(cls, payload: bytes, signature: str, secret: str) -> bool:
        """Verify webhook signature."""
        try:
            algorithm = signature.split('=')[0]
            expected_signature = cls.compute_signature(payload, secret, algorithm)
            return hmac.compare_digest(signature, expected_signature)
        except Exception:
            return False
    
    # Instance methods
    def should_trigger(self, event_type: str) -> bool:
        """Check if webhook should be triggered for given event type."""
        if not self.is_active or self.status != WebhookStatus.ACTIVE:
            return False
        
        # Check if event type is in subscribed events
        if "*" in self.events:  # Wildcard for all events
            return True
        
        return event_type in self.events
    
    def should_deliver_event(self, event_data: Dict[str, Any]) -> bool:
        """Check if event should be delivered based on filters."""
        if not self.event_filter:
            return True
        
        # TODO: Implement event filtering logic
        # For now, just return True
        return True
    
    def update_delivery_stats(self, success: bool, response_time_ms: Optional[int] = None) -> None:
        """Update delivery statistics."""
        now = datetime.utcnow()
        self.total_deliveries += 1
        self.last_delivery_at = now
        
        if success:
            self.successful_deliveries += 1
            self.last_success_at = now
        else:
            self.failed_deliveries += 1
            self.last_failure_at = now
        
        # Update average response time
        if response_time_ms is not None:
            if self.average_response_time_ms is None:
                self.average_response_time_ms = response_time_ms
            else:
                # Simple moving average
                self.average_response_time_ms = int(
                    (self.average_response_time_ms + response_time_ms) / 2
                )
    
    def add_event(self, event_type: str) -> None:
        """Add an event type to webhook subscriptions."""
        if event_type not in self.events:
            self.events.append(event_type)
    
    def remove_event(self, event_type: str) -> None:
        """Remove an event type from webhook subscriptions."""
        if event_type in self.events:
            self.events.remove(event_type)
    
    def set_custom_header(self, name: str, value: str) -> None:
        """Set a custom header."""
        if self.custom_headers is None:
            self.custom_headers = {}
        self.custom_headers[name] = value
    
    def remove_custom_header(self, name: str) -> None:
        """Remove a custom header."""
        if self.custom_headers and name in self.custom_headers:
            del self.custom_headers[name]
    
    def enable(self) -> None:
        """Enable the webhook."""
        self.is_active = True
        self.status = WebhookStatus.ACTIVE
    
    def disable(self, reason: Optional[str] = None) -> None:
        """Disable the webhook."""
        self.is_active = False
        self.status = WebhookStatus.DISABLED
        if reason and self.metadata is None:
            self.metadata = {}
        if reason:
            self.metadata["disabled_reason"] = reason
    
    def mark_error(self, error_message: str) -> None:
        """Mark webhook as having errors."""
        self.status = WebhookStatus.ERROR
        if self.metadata is None:
            self.metadata = {}
        self.metadata["last_error"] = error_message
        self.metadata["error_timestamp"] = datetime.utcnow().isoformat()
    
    def clear_error(self) -> None:
        """Clear error status."""
        if self.is_active:
            self.status = WebhookStatus.ACTIVE
        if self.metadata:
            self.metadata.pop("last_error", None)
            self.metadata.pop("error_timestamp", None)
    
    def ping(self) -> bool:
        """Send a ping/health check to the webhook endpoint."""
        # TODO: Implement actual HTTP ping
        # For now, just update last ping time
        self.last_ping_at = datetime.utcnow()
        self.last_ping_status = 200  # Assume success for now
        return True
    
    def to_dict(self, include_sensitive: bool = False, include_stats: bool = True) -> dict:
        """Convert webhook to dictionary."""
        data = {
            "id": str(self.id),
            "name": self.name,
            "description": self.description,
            "url": self.url,
            "http_method": self.http_method,
            "content_type": self.content_type,
            "events": self.events,
            "timeout_seconds": self.timeout_seconds,
            "max_retries": self.max_retries,
            "retry_delay_seconds": self.retry_delay_seconds,
            "verify_ssl": self.verify_ssl,
            "status": self.status.value,
            "is_active": self.is_active,
            "is_healthy": self.is_healthy,
            "needs_attention": self.needs_attention,
            "health_check_enabled": self.health_check_enabled,
            "health_check_interval_minutes": self.health_check_interval_minutes,
            "rate_limit_per_minute": self.rate_limit_per_minute,
            "rate_limit_per_hour": self.rate_limit_per_hour,
            "user_id": str(self.user_id),
            "organization_id": str(self.organization_id) if self.organization_id else None,
            "tags": self.tags or [],
            "created_at": self.created_at.isoformat(),
            "updated_at": self.updated_at.isoformat()
        }
        
        if include_stats:
            data.update({
                "total_deliveries": self.total_deliveries,
                "successful_deliveries": self.successful_deliveries,
                "failed_deliveries": self.failed_deliveries,
                "success_rate": self.success_rate,
                "failure_rate": self.failure_rate,
                "last_delivery_at": self.last_delivery_at.isoformat() if self.last_delivery_at else None,
                "last_success_at": self.last_success_at.isoformat() if self.last_success_at else None,
                "last_failure_at": self.last_failure_at.isoformat() if self.last_failure_at else None,
                "average_response_time_ms": self.average_response_time_ms,
                "last_ping_at": self.last_ping_at.isoformat() if self.last_ping_at else None,
                "last_ping_status": self.last_ping_status
            })
        
        if include_sensitive:
            data.update({
                "secret_key": self.secret_key,
                "signature_header": self.signature_header,
                "signature_algorithm": self.signature_algorithm,
                "custom_headers": self.custom_headers or {},
                "event_filter": self.event_filter or {},
                "auth_type": self.auth_type,
                "auth_config": self.auth_config or {},
                "ssl_cert_path": self.ssl_cert_path,
                "metadata": self.metadata or {}
            })
        
        return data
    
    def __repr__(self) -> str:
        return f"<Webhook(id={self.id}, name='{self.name}', url='{self.url}')>"
    
    def __str__(self) -> str:
        return f"{self.name} -> {self.url}"


class WebhookDelivery(Base):
    """Model for tracking webhook delivery attempts and results."""
    
    __tablename__ = "webhook_deliveries"
    
    # Primary key
    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
        index=True
    )
    
    # Webhook reference
    webhook_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("webhooks.id", ondelete="CASCADE"),
        nullable=False,
        index=True
    )
    
    # Event information
    event_type: Mapped[str] = mapped_column(
        String(100),
        nullable=False,
        index=True
    )
    event_id: Mapped[Optional[str]] = mapped_column(
        String(100),
        nullable=True,
        index=True,
        comment="Original event ID"
    )
    payload: Mapped[Dict[str, Any]] = mapped_column(
        JSON,
        nullable=False,
        comment="Event payload sent to webhook"
    )
    payload_size: Mapped[int] = mapped_column(
        Integer,
        default=0,
        nullable=False,
        comment="Payload size in bytes"
    )
    
    # Delivery attempt tracking
    status: Mapped[WebhookDeliveryStatus] = mapped_column(
        Enum(WebhookDeliveryStatus),
        default=WebhookDeliveryStatus.PENDING,
        nullable=False,
        index=True
    )
    attempt_count: Mapped[int] = mapped_column(
        Integer,
        default=0,
        nullable=False
    )
    max_attempts: Mapped[int] = mapped_column(
        Integer,
        default=3,
        nullable=False
    )
    
    # HTTP request/response details
    http_status_code: Mapped[Optional[int]] = mapped_column(
        Integer,
        nullable=True
    )
    response_headers: Mapped[Optional[Dict[str, str]]] = mapped_column(
        JSON,
        nullable=True
    )
    response_body: Mapped[Optional[str]] = mapped_column(
        Text,
        nullable=True
    )
    response_size: Mapped[Optional[int]] = mapped_column(
        Integer,
        nullable=True,
        comment="Response size in bytes"
    )
    response_time_ms: Mapped[Optional[int]] = mapped_column(
        Integer,
        nullable=True,
        comment="Response time in milliseconds"
    )
    
    # Error tracking
    error_message: Mapped[Optional[str]] = mapped_column(
        Text,
        nullable=True
    )
    error_code: Mapped[Optional[str]] = mapped_column(
        String(50),
        nullable=True
    )
    
    # Timing information
    scheduled_for: Mapped[Optional[datetime]] = mapped_column(
        DateTime,
        nullable=True,
        index=True,
        comment="When delivery was scheduled"
    )
    first_attempt_at: Mapped[Optional[datetime]] = mapped_column(
        DateTime,
        nullable=True,
        comment="When first attempt was made"
    )
    last_attempt_at: Mapped[Optional[datetime]] = mapped_column(
        DateTime,
        nullable=True,
        comment="When last attempt was made"
    )
    delivered_at: Mapped[Optional[datetime]] = mapped_column(
        DateTime,
        nullable=True,
        index=True,
        comment="When successfully delivered"
    )
    next_retry_at: Mapped[Optional[datetime]] = mapped_column(
        DateTime,
        nullable=True,
        index=True,
        comment="When next retry is scheduled"
    )
    expires_at: Mapped[Optional[datetime]] = mapped_column(
        DateTime,
        nullable=True,
        index=True,
        comment="When delivery attempts should stop"
    )
    
    # Request details
    request_headers: Mapped[Optional[Dict[str, str]]] = mapped_column(
        JSON,
        nullable=True,
        comment="Headers sent with request"
    )
    request_signature: Mapped[Optional[str]] = mapped_column(
        String(255),
        nullable=True,
        comment="HMAC signature of request"
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
    
    # Relationships
    webhook: Mapped["Webhook"] = relationship(
        "Webhook",
        back_populates="deliveries",
        lazy="selectin"
    )
    
    # Properties
    @property
    def is_successful(self) -> bool:
        """Check if delivery was successful."""
        return self.status == WebhookDeliveryStatus.SUCCESS
    
    @property
    def is_failed(self) -> bool:
        """Check if delivery has permanently failed."""
        return self.status == WebhookDeliveryStatus.FAILED
    
    @property
    def is_pending(self) -> bool:
        """Check if delivery is still pending."""
        return self.status in [
            WebhookDeliveryStatus.PENDING,
            WebhookDeliveryStatus.RETRYING
        ]
    
    @property
    def can_retry(self) -> bool:
        """Check if delivery can be retried."""
        return (
            self.status in [WebhookDeliveryStatus.FAILED, WebhookDeliveryStatus.RETRYING] and
            self.attempt_count < self.max_attempts and
            (self.expires_at is None or datetime.utcnow() < self.expires_at)
        )
    
    @property
    def is_expired(self) -> bool:
        """Check if delivery has expired."""
        return (
            self.expires_at is not None and
            datetime.utcnow() > self.expires_at
        )
    
    @property
    def total_time_ms(self) -> Optional[int]:
        """Get total time from creation to completion."""
        if self.delivered_at and self.created_at:
            delta = self.delivered_at - self.created_at
            return int(delta.total_seconds() * 1000)
        return None
    
    # Methods
    def mark_as_sending(self) -> None:
        """Mark delivery as currently being sent."""
        self.status = WebhookDeliveryStatus.SENDING
        if self.first_attempt_at is None:
            self.first_attempt_at = datetime.utcnow()
        self.last_attempt_at = datetime.utcnow()
        self.attempt_count += 1
    
    def mark_as_success(self, status_code: int, response_body: Optional[str] = None,
                       response_headers: Optional[Dict[str, str]] = None,
                       response_time_ms: Optional[int] = None,
                       response_size: Optional[int] = None) -> None:
        """Mark delivery as successful."""
        self.status = WebhookDeliveryStatus.SUCCESS
        self.delivered_at = datetime.utcnow()
        self.http_status_code = status_code
        self.response_body = response_body
        self.response_headers = response_headers
        self.response_time_ms = response_time_ms
        self.response_size = response_size
        self.next_retry_at = None  # Clear retry schedule
    
    def mark_as_failed(self, error_message: str, error_code: Optional[str] = None,
                      status_code: Optional[int] = None,
                      response_body: Optional[str] = None) -> None:
        """Mark delivery attempt as failed."""
        self.error_message = error_message
        self.error_code = error_code
        self.http_status_code = status_code
        self.response_body = response_body
        
        if self.can_retry:
            self.status = WebhookDeliveryStatus.RETRYING
            # Calculate next retry with exponential backoff
            delay_seconds = min(
                60 * (2 ** (self.attempt_count - 1)),  # Exponential backoff
                3600  # Max 1 hour delay
            )
            self.next_retry_at = datetime.utcnow() + timedelta(seconds=delay_seconds)
        else:
            self.status = WebhookDeliveryStatus.FAILED
            self.next_retry_at = None
    
    def cancel(self, reason: str) -> None:
        """Cancel pending delivery."""
        if self.is_pending:
            self.status = WebhookDeliveryStatus.CANCELLED
            self.error_message = f"Cancelled: {reason}"
            self.next_retry_at = None
    
    def set_expiry(self, expires_at: datetime) -> None:
        """Set delivery expiry time."""
        self.expires_at = expires_at
    
    def to_dict(self, include_payload: bool = False, include_response: bool = False) -> dict:
        """Convert delivery to dictionary."""
        data = {
            "id": str(self.id),
            "webhook_id": str(self.webhook_id),
            "event_type": self.event_type,
            "event_id": self.event_id,
            "payload_size": self.payload_size,
            "status": self.status.value,
            "attempt_count": self.attempt_count,
            "max_attempts": self.max_attempts,
            "is_successful": self.is_successful,
            "is_failed": self.is_failed,
            "is_pending": self.is_pending,
            "can_retry": self.can_retry,
            "is_expired": self.is_expired,
            "http_status_code": self.http_status_code,
            "response_time_ms": self.response_time_ms,
            "response_size": self.response_size,
            "total_time_ms": self.total_time_ms,
            "error_message": self.error_message,
            "error_code": self.error_code,
            "scheduled_for": self.scheduled_for.isoformat() if self.scheduled_for else None,
            "first_attempt_at": self.first_attempt_at.isoformat() if self.first_attempt_at else None,
            "last_attempt_at": self.last_attempt_at.isoformat() if self.last_attempt_at else None,
            "delivered_at": self.delivered_at.isoformat() if self.delivered_at else None,
            "next_retry_at": self.next_retry_at.isoformat() if self.next_retry_at else None,
            "expires_at": self.expires_at.isoformat() if self.expires_at else None,
            "created_at": self.created_at.isoformat(),
            "updated_at": self.updated_at.isoformat()
        }
        
        if include_payload:
            data["payload"] = self.payload
        
        if include_response:
            data.update({
                "response_headers": self.response_headers or {},
                "response_body": self.response_body,
                "request_headers": self.request_headers or {},
                "request_signature": self.request_signature
            })
        
        return data
    
    def __repr__(self) -> str:
        return f"<WebhookDelivery(id={self.id}, webhook_id={self.webhook_id}, status={self.status.value})>"
    
    def __str__(self) -> str:
        return f"Delivery {self.event_type} -> {self.status.value}"


# Standard webhook event data structures
class WebhookEventData:
    """Standard event data structures for webhooks."""
    
    @staticmethod
    def user_event(event_type: str, user_data: Dict[str, Any], 
                  metadata: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
        """Create user event data."""
        return {
            "event": event_type,
            "timestamp": datetime.utcnow().isoformat(),
            "data": {
                "user": user_data
            },
            "metadata": metadata or {}
        }
    
    @staticmethod
    def auth_event(event_type: str, user_id: str, ip_address: str,
                  user_agent: str, success: bool,
                  metadata: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
        """Create authentication event data."""
        return {
            "event": event_type,
            "timestamp": datetime.utcnow().isoformat(),
            "data": {
                "user_id": user_id,
                "ip_address": ip_address,
                "user_agent": user_agent,
                "success": success
            },
            "metadata": metadata or {}
        }
    
    @staticmethod
    def security_event(event_type: str, severity: str, description: str,
                      affected_user_id: Optional[str] = None,
                      metadata: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
        """Create security event data."""
        return {
            "event": event_type,
            "timestamp": datetime.utcnow().isoformat(),
            "data": {
                "severity": severity,
                "description": description,
                "affected_user_id": affected_user_id
            },
            "metadata": metadata or {}
        }