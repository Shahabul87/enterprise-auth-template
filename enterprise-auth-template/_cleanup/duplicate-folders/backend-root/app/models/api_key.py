"""
API Key model for API authentication and management.
"""
from typing import List, Optional, TYPE_CHECKING, Dict, Any
from datetime import datetime, timedelta
from sqlalchemy import Column, String, DateTime, Boolean, Text, ForeignKey, Integer
from sqlalchemy.orm import relationship, Mapped, mapped_column
from sqlalchemy.dialects.postgresql import UUID, JSON
import uuid
import secrets
import hashlib
import hmac

from app.core.database import Base

if TYPE_CHECKING:
    from app.models.user import User
    from app.models.organization import Organization


class APIKey(Base):
    """API Key model for programmatic access authentication."""
    
    __tablename__ = "api_keys"
    
    # Primary key
    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
        index=True
    )
    
    # Key identification
    name: Mapped[str] = mapped_column(
        String(100),
        nullable=False
    )
    description: Mapped[Optional[str]] = mapped_column(
        Text,
        nullable=True
    )
    key_prefix: Mapped[str] = mapped_column(
        String(20),
        nullable=False,
        index=True,
        comment="First few characters of the key for identification (e.g., sk_live_abc123)"
    )
    key_hash: Mapped[str] = mapped_column(
        String(255),
        nullable=False,
        unique=True,
        comment="SHA-256 hash of the full API key"
    )
    
    # Key type and environment
    key_type: Mapped[str] = mapped_column(
        String(20),
        default="standard",
        nullable=False,
        comment="Key type: standard, restricted, service"
    )
    environment: Mapped[str] = mapped_column(
        String(20),
        default="production",
        nullable=False,
        comment="Environment: production, test, development"
    )
    
    # Permissions and scopes
    scopes: Mapped[List[str]] = mapped_column(
        JSON,
        nullable=False,
        default=list,
        comment="List of allowed scopes/permissions"
    )
    permissions: Mapped[Optional[Dict[str, Any]]] = mapped_column(
        JSON,
        nullable=True,
        comment="Detailed permission configuration"
    )
    
    # Rate limiting and quotas
    rate_limit_per_hour: Mapped[int] = mapped_column(
        Integer,
        default=1000,
        nullable=False,
        comment="Maximum requests per hour"
    )
    rate_limit_per_day: Mapped[int] = mapped_column(
        Integer,
        default=24000,
        nullable=False,
        comment="Maximum requests per day"
    )
    monthly_quota: Mapped[Optional[int]] = mapped_column(
        Integer,
        nullable=True,
        comment="Monthly request quota (null means unlimited)"
    )
    
    # IP and domain restrictions
    allowed_ips: Mapped[Optional[List[str]]] = mapped_column(
        JSON,
        nullable=True,
        comment="List of allowed IP addresses/CIDR blocks (null means all IPs allowed)"
    )
    allowed_domains: Mapped[Optional[List[str]]] = mapped_column(
        JSON,
        nullable=True,
        comment="List of allowed referrer domains"
    )
    allowed_origins: Mapped[Optional[List[str]]] = mapped_column(
        JSON,
        nullable=True,
        comment="List of allowed CORS origins"
    )
    
    # Usage tracking and analytics
    last_used_at: Mapped[Optional[datetime]] = mapped_column(
        DateTime,
        nullable=True,
        index=True
    )
    last_used_ip: Mapped[Optional[str]] = mapped_column(
        String(45),
        nullable=True,
        comment="IPv4 or IPv6 address"
    )
    last_used_user_agent: Mapped[Optional[str]] = mapped_column(
        String(500),
        nullable=True
    )
    usage_count_total: Mapped[int] = mapped_column(
        Integer,
        default=0,
        nullable=False,
        comment="Total number of requests made with this key"
    )
    usage_count_today: Mapped[int] = mapped_column(
        Integer,
        default=0,
        nullable=False
    )
    usage_count_this_month: Mapped[int] = mapped_column(
        Integer,
        default=0,
        nullable=False
    )
    last_reset_daily: Mapped[Optional[datetime]] = mapped_column(
        DateTime,
        nullable=True,
        comment="When daily usage counter was last reset"
    )
    last_reset_monthly: Mapped[Optional[datetime]] = mapped_column(
        DateTime,
        nullable=True,
        comment="When monthly usage counter was last reset"
    )
    
    # Expiration and lifecycle
    expires_at: Mapped[Optional[datetime]] = mapped_column(
        DateTime,
        nullable=True,
        index=True,
        comment="Key expiration date (null means never expires)"
    )
    auto_rotate: Mapped[bool] = mapped_column(
        Boolean,
        default=False,
        nullable=False,
        comment="Automatically rotate key before expiration"
    )
    rotation_period_days: Mapped[Optional[int]] = mapped_column(
        Integer,
        nullable=True,
        comment="Days between automatic rotations"
    )
    
    # Status and revocation
    is_active: Mapped[bool] = mapped_column(
        Boolean,
        default=True,
        nullable=False,
        index=True
    )
    is_revoked: Mapped[bool] = mapped_column(
        Boolean,
        default=False,
        nullable=False,
        index=True
    )
    revoked_at: Mapped[Optional[datetime]] = mapped_column(
        DateTime,
        nullable=True
    )
    revoked_reason: Mapped[Optional[str]] = mapped_column(
        Text,
        nullable=True
    )
    revoked_by: Mapped[Optional[uuid.UUID]] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="SET NULL"),
        nullable=True
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
    
    # Security and monitoring
    webhook_url: Mapped[Optional[str]] = mapped_column(
        String(500),
        nullable=True,
        comment="URL to notify on key usage/security events"
    )
    security_alerts_enabled: Mapped[bool] = mapped_column(
        Boolean,
        default=True,
        nullable=False
    )
    log_requests: Mapped[bool] = mapped_column(
        Boolean,
        default=False,
        nullable=False,
        comment="Log all requests made with this key"
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
    
    # Relationships
    user: Mapped["User"] = relationship(
        "User",
        foreign_keys=[user_id],
        back_populates="api_keys",
        lazy="selectin"
    )
    
    organization: Mapped[Optional["Organization"]] = relationship(
        "Organization",
        back_populates="api_keys",
        lazy="selectin"
    )
    
    revoker: Mapped[Optional["User"]] = relationship(
        "User",
        foreign_keys=[revoked_by],
        lazy="selectin"
    )
    
    # Properties
    @property
    def is_expired(self) -> bool:
        """Check if the API key has expired."""
        if self.expires_at is None:
            return False
        return datetime.utcnow() > self.expires_at
    
    @property
    def is_valid(self) -> bool:
        """Check if the API key is valid for use."""
        return (
            self.is_active and
            not self.is_expired and
            not self.is_revoked
        )
    
    @property
    def days_until_expiry(self) -> Optional[int]:
        """Get days until key expires."""
        if self.expires_at is None:
            return None
        delta = self.expires_at - datetime.utcnow()
        return max(0, delta.days)
    
    @property
    def usage_percentage_daily(self) -> float:
        """Get daily usage percentage."""
        if self.rate_limit_per_day <= 0:
            return 0.0
        return (self.usage_count_today / self.rate_limit_per_day) * 100
    
    @property
    def usage_percentage_monthly(self) -> Optional[float]:
        """Get monthly usage percentage."""
        if self.monthly_quota is None or self.monthly_quota <= 0:
            return None
        return (self.usage_count_this_month / self.monthly_quota) * 100
    
    @property
    def is_rate_limited(self) -> bool:
        """Check if key has exceeded rate limits."""
        # Check daily limit
        if self.usage_count_today >= self.rate_limit_per_day:
            return True
        
        # Check monthly quota
        if self.monthly_quota and self.usage_count_this_month >= self.monthly_quota:
            return True
        
        return False
    
    @property
    def needs_rotation(self) -> bool:
        """Check if key needs automatic rotation."""
        if not self.auto_rotate or not self.rotation_period_days:
            return False
        
        rotation_due = self.created_at + timedelta(days=self.rotation_period_days)
        return datetime.utcnow() >= rotation_due
    
    # Class methods
    @classmethod
    def generate_key(cls, environment: str = "production", key_type: str = "standard") -> str:
        """Generate a new API key with proper format."""
        # Generate prefix based on environment and type
        env_prefix = {
            "production": "sk_live",
            "test": "sk_test",
            "development": "sk_dev"
        }.get(environment, "sk_live")
        
        type_suffix = {
            "standard": "",
            "restricted": "_r",
            "service": "_svc"
        }.get(key_type, "")
        
        # Generate secure random key
        random_part = secrets.token_urlsafe(32)
        return f"{env_prefix}{type_suffix}_{random_part}"
    
    @classmethod
    def hash_key(cls, api_key: str) -> str:
        """Create SHA-256 hash of API key for storage."""
        return hashlib.sha256(api_key.encode()).hexdigest()
    
    @classmethod
    def extract_prefix(cls, api_key: str) -> str:
        """Extract prefix from API key for identification."""
        parts = api_key.split('_')
        if len(parts) >= 3:
            return f"{parts[0]}_{parts[1]}_{'*' * 8}"
        return api_key[:12] + "..." if len(api_key) > 12 else api_key
    
    @classmethod
    def verify_key(cls, provided_key: str, stored_hash: str) -> bool:
        """Verify API key against stored hash."""
        provided_hash = cls.hash_key(provided_key)
        return hmac.compare_digest(provided_hash, stored_hash)
    
    # Instance methods
    def can_access_scope(self, scope: str) -> bool:
        """Check if the API key has access to a specific scope."""
        if "*" in self.scopes:  # Wildcard for all scopes
            return True
        return scope in self.scopes
    
    def can_access_resource(self, resource: str, action: str) -> bool:
        """Check if key can access specific resource with action."""
        # Check wildcard permissions
        if "*" in self.scopes or f"{resource}:*" in self.scopes:
            return True
        
        # Check specific permission
        required_scope = f"{resource}:{action}"
        return required_scope in self.scopes
    
    def check_ip_allowed(self, ip_address: str) -> bool:
        """Check if the IP address is allowed."""
        if self.allowed_ips is None:
            return True
        
        # TODO: Implement CIDR block checking for allowed_ips
        return ip_address in self.allowed_ips
    
    def check_domain_allowed(self, domain: str) -> bool:
        """Check if the domain is allowed."""
        if self.allowed_domains is None:
            return True
        return domain in self.allowed_domains
    
    def check_origin_allowed(self, origin: str) -> bool:
        """Check if the origin is allowed for CORS."""
        if self.allowed_origins is None:
            return True
        return origin in self.allowed_origins
    
    def update_usage(self, ip_address: str, user_agent: Optional[str] = None) -> None:
        """Update usage statistics."""
        now = datetime.utcnow()
        
        # Update basic tracking
        self.last_used_at = now
        self.last_used_ip = ip_address
        if user_agent:
            self.last_used_user_agent = user_agent
        self.usage_count_total += 1
        
        # Reset daily counter if needed
        if (self.last_reset_daily is None or 
            now.date() > self.last_reset_daily.date()):
            self.usage_count_today = 1
            self.last_reset_daily = now
        else:
            self.usage_count_today += 1
        
        # Reset monthly counter if needed
        if (self.last_reset_monthly is None or
            now.month != self.last_reset_monthly.month or
            now.year != self.last_reset_monthly.year):
            self.usage_count_this_month = 1
            self.last_reset_monthly = now
        else:
            self.usage_count_this_month += 1
    
    def revoke(self, reason: str, revoked_by_user_id: Optional[uuid.UUID] = None) -> None:
        """Revoke the API key."""
        self.is_active = False
        self.is_revoked = True
        self.revoked_at = datetime.utcnow()
        self.revoked_reason = reason
        self.revoked_by = revoked_by_user_id
    
    def activate(self) -> None:
        """Activate a previously deactivated key."""
        if not self.is_revoked:
            self.is_active = True
    
    def deactivate(self) -> None:
        """Temporarily deactivate the key."""
        self.is_active = False
    
    def extend_expiry(self, days: int) -> None:
        """Extend key expiration by specified days."""
        if self.expires_at:
            self.expires_at += timedelta(days=days)
        else:
            self.expires_at = datetime.utcnow() + timedelta(days=days)
    
    def add_scope(self, scope: str) -> None:
        """Add a new scope to the API key."""
        if scope not in self.scopes:
            self.scopes.append(scope)
    
    def remove_scope(self, scope: str) -> None:
        """Remove a scope from the API key."""
        if scope in self.scopes:
            self.scopes.remove(scope)
    
    def add_tag(self, tag: str) -> None:
        """Add a tag to the API key."""
        if self.tags is None:
            self.tags = []
        if tag not in self.tags:
            self.tags.append(tag)
    
    def remove_tag(self, tag: str) -> None:
        """Remove a tag from the API key."""
        if self.tags and tag in self.tags:
            self.tags.remove(tag)
    
    def set_metadata(self, key: str, value: Any) -> None:
        """Set metadata value."""
        if self.metadata is None:
            self.metadata = {}
        self.metadata[key] = value
    
    def get_metadata(self, key: str, default: Any = None) -> Any:
        """Get metadata value."""
        if self.metadata is None:
            return default
        return self.metadata.get(key, default)
    
    def to_dict(self, include_sensitive: bool = False, include_stats: bool = True) -> dict:
        """Convert API key to dictionary."""
        data = {
            "id": str(self.id),
            "name": self.name,
            "description": self.description,
            "key_prefix": self.key_prefix,
            "key_type": self.key_type,
            "environment": self.environment,
            "scopes": self.scopes,
            "rate_limit_per_hour": self.rate_limit_per_hour,
            "rate_limit_per_day": self.rate_limit_per_day,
            "monthly_quota": self.monthly_quota,
            "allowed_ips": self.allowed_ips,
            "allowed_domains": self.allowed_domains,
            "allowed_origins": self.allowed_origins,
            "expires_at": self.expires_at.isoformat() if self.expires_at else None,
            "days_until_expiry": self.days_until_expiry,
            "auto_rotate": self.auto_rotate,
            "rotation_period_days": self.rotation_period_days,
            "is_active": self.is_active,
            "is_revoked": self.is_revoked,
            "is_valid": self.is_valid,
            "is_expired": self.is_expired,
            "needs_rotation": self.needs_rotation,
            "user_id": str(self.user_id),
            "organization_id": str(self.organization_id) if self.organization_id else None,
            "webhook_url": self.webhook_url,
            "security_alerts_enabled": self.security_alerts_enabled,
            "log_requests": self.log_requests,
            "tags": self.tags or [],
            "created_at": self.created_at.isoformat(),
            "updated_at": self.updated_at.isoformat()
        }
        
        if include_stats:
            data.update({
                "last_used_at": self.last_used_at.isoformat() if self.last_used_at else None,
                "last_used_ip": self.last_used_ip,
                "usage_count_total": self.usage_count_total,
                "usage_count_today": self.usage_count_today,
                "usage_count_this_month": self.usage_count_this_month,
                "usage_percentage_daily": self.usage_percentage_daily,
                "usage_percentage_monthly": self.usage_percentage_monthly,
                "is_rate_limited": self.is_rate_limited
            })
        
        if include_sensitive:
            data.update({
                "key_hash": self.key_hash,
                "permissions": self.permissions or {},
                "revoked_at": self.revoked_at.isoformat() if self.revoked_at else None,
                "revoked_reason": self.revoked_reason,
                "revoked_by": str(self.revoked_by) if self.revoked_by else None,
                "last_used_user_agent": self.last_used_user_agent,
                "metadata": self.metadata or {}
            })
        
        return data
    
    def __repr__(self) -> str:
        return f"<APIKey(id={self.id}, name='{self.name}', prefix='{self.key_prefix}')>"
    
    def __str__(self) -> str:
        return f"{self.name} ({self.key_prefix})"


class APIKeyScopes:
    """Standard API key scopes and permissions."""
    
    # Read scopes
    READ_PROFILE = "read:profile"
    READ_USERS = "read:users"
    READ_ORGANIZATIONS = "read:organizations"
    READ_ROLES = "read:roles"
    READ_PERMISSIONS = "read:permissions"
    READ_AUDIT_LOGS = "read:audit_logs"
    READ_API_KEYS = "read:api_keys"
    READ_WEBHOOKS = "read:webhooks"
    READ_NOTIFICATIONS = "read:notifications"
    READ_SESSIONS = "read:sessions"
    
    # Write scopes
    WRITE_PROFILE = "write:profile"
    WRITE_USERS = "write:users"
    WRITE_ORGANIZATIONS = "write:organizations"
    WRITE_ROLES = "write:roles"
    WRITE_PERMISSIONS = "write:permissions"
    WRITE_NOTIFICATIONS = "write:notifications"
    
    # Create scopes
    CREATE_USERS = "create:users"
    CREATE_ORGANIZATIONS = "create:organizations"
    CREATE_ROLES = "create:roles"
    CREATE_API_KEYS = "create:api_keys"
    CREATE_WEBHOOKS = "create:webhooks"
    CREATE_NOTIFICATIONS = "create:notifications"
    
    # Delete scopes
    DELETE_USERS = "delete:users"
    DELETE_ORGANIZATIONS = "delete:organizations"
    DELETE_ROLES = "delete:roles"
    DELETE_API_KEYS = "delete:api_keys"
    DELETE_WEBHOOKS = "delete:webhooks"
    DELETE_NOTIFICATIONS = "delete:notifications"
    
    # Admin scopes
    ADMIN_USERS = "admin:users"
    ADMIN_ORGANIZATIONS = "admin:organizations"
    ADMIN_SYSTEM = "admin:system"
    ADMIN_AUDIT = "admin:audit"
    
    # Special scopes
    FULL_ACCESS = "*"
    
    @classmethod
    def get_all_scopes(cls) -> List[str]:
        """Get all available scopes."""
        return [
            # Read scopes
            cls.READ_PROFILE, cls.READ_USERS, cls.READ_ORGANIZATIONS,
            cls.READ_ROLES, cls.READ_PERMISSIONS, cls.READ_AUDIT_LOGS,
            cls.READ_API_KEYS, cls.READ_WEBHOOKS, cls.READ_NOTIFICATIONS,
            cls.READ_SESSIONS,
            
            # Write scopes
            cls.WRITE_PROFILE, cls.WRITE_USERS, cls.WRITE_ORGANIZATIONS,
            cls.WRITE_ROLES, cls.WRITE_PERMISSIONS, cls.WRITE_NOTIFICATIONS,
            
            # Create scopes
            cls.CREATE_USERS, cls.CREATE_ORGANIZATIONS, cls.CREATE_ROLES,
            cls.CREATE_API_KEYS, cls.CREATE_WEBHOOKS, cls.CREATE_NOTIFICATIONS,
            
            # Delete scopes
            cls.DELETE_USERS, cls.DELETE_ORGANIZATIONS, cls.DELETE_ROLES,
            cls.DELETE_API_KEYS, cls.DELETE_WEBHOOKS, cls.DELETE_NOTIFICATIONS,
            
            # Admin scopes
            cls.ADMIN_USERS, cls.ADMIN_ORGANIZATIONS, cls.ADMIN_SYSTEM,
            cls.ADMIN_AUDIT
        ]
    
    @classmethod
    def get_read_only_scopes(cls) -> List[str]:
        """Get read-only scopes."""
        return [
            cls.READ_PROFILE, cls.READ_USERS, cls.READ_ORGANIZATIONS,
            cls.READ_ROLES, cls.READ_PERMISSIONS, cls.READ_AUDIT_LOGS,
            cls.READ_API_KEYS, cls.READ_WEBHOOKS, cls.READ_NOTIFICATIONS,
            cls.READ_SESSIONS
        ]
    
    @classmethod
    def get_default_scopes(cls) -> List[str]:
        """Get default scopes for new API keys."""
        return [cls.READ_PROFILE]
    
    @classmethod
    def get_admin_scopes(cls) -> List[str]:
        """Get admin-level scopes."""
        return [
            cls.ADMIN_USERS, cls.ADMIN_ORGANIZATIONS, 
            cls.ADMIN_SYSTEM, cls.ADMIN_AUDIT
        ]
    
    @classmethod
    def validate_scope(cls, scope: str) -> bool:
        """Validate if scope is recognized."""
        all_scopes = cls.get_all_scopes()
        return scope in all_scopes or scope == cls.FULL_ACCESS
    
    @classmethod
    def get_scopes_for_role(cls, role: str) -> List[str]:
        """Get appropriate scopes for a user role."""
        role_scopes = {
            "user": [cls.READ_PROFILE, cls.WRITE_PROFILE],
            "moderator": cls.get_read_only_scopes() + [
                cls.WRITE_USERS, cls.WRITE_NOTIFICATIONS
            ],
            "admin": cls.get_all_scopes(),
            "super_admin": [cls.FULL_ACCESS]
        }
        return role_scopes.get(role, cls.get_default_scopes())


# Usage tracking model for detailed analytics
class APIKeyUsage(Base):
    """Track detailed API key usage for analytics."""
    
    __tablename__ = "api_key_usage"
    
    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4
    )
    
    api_key_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("api_keys.id", ondelete="CASCADE"),
        nullable=False,
        index=True
    )
    
    # Request details
    endpoint: Mapped[str] = mapped_column(String(200), nullable=False)
    method: Mapped[str] = mapped_column(String(10), nullable=False)
    status_code: Mapped[int] = mapped_column(Integer, nullable=False)
    response_time_ms: Mapped[Optional[int]] = mapped_column(Integer, nullable=True)
    
    # Client information
    ip_address: Mapped[str] = mapped_column(String(45), nullable=False)
    user_agent: Mapped[Optional[str]] = mapped_column(String(500), nullable=True)
    referer: Mapped[Optional[str]] = mapped_column(String(500), nullable=True)
    
    # Timestamps
    timestamp: Mapped[datetime] = mapped_column(
        DateTime,
        default=datetime.utcnow,
        nullable=False,
        index=True
    )
    
    # Additional data
    request_size: Mapped[Optional[int]] = mapped_column(Integer, nullable=True)
    response_size: Mapped[Optional[int]] = mapped_column(Integer, nullable=True)
    error_message: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    
    # Relationships
    api_key: Mapped["APIKey"] = relationship(
        "APIKey",
        backref="usage_logs"
    )
    
    def to_dict(self) -> dict:
        """Convert usage record to dictionary."""
        return {
            "id": str(self.id),
            "api_key_id": str(self.api_key_id),
            "endpoint": self.endpoint,
            "method": self.method,
            "status_code": self.status_code,
            "response_time_ms": self.response_time_ms,
            "ip_address": self.ip_address,
            "user_agent": self.user_agent,
            "referer": self.referer,
            "timestamp": self.timestamp.isoformat(),
            "request_size": self.request_size,
            "response_size": self.response_size,
            "error_message": self.error_message
        }
    
    def __repr__(self) -> str:
        return f"<APIKeyUsage(api_key_id={self.api_key_id}, endpoint={self.endpoint})>"