"""
Organization model for multi-tenancy support.
"""
from typing import List, Optional, TYPE_CHECKING, Dict, Any
from datetime import datetime, date
from sqlalchemy import Column, String, DateTime, Boolean, Text, Table, ForeignKey, Integer, Date, JSON, Numeric
from sqlalchemy.orm import relationship, Mapped, mapped_column
from sqlalchemy.dialects.postgresql import UUID
import uuid

from app.core.database import Base
from app.core.constants import OrganizationRole

if TYPE_CHECKING:
    from app.models.user import User
    from app.models.role import Role
    from app.models.api_key import APIKey
    from app.models.webhook import Webhook


# Association table for organization members
organization_members = Table(
    'organization_members',
    Base.metadata,
    Column('organization_id', UUID(as_uuid=True), ForeignKey('organizations.id', ondelete='CASCADE'), primary_key=True),
    Column('user_id', UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), primary_key=True),
    Column('role', String(20), default=OrganizationRole.MEMBER.value, nullable=False),
    Column('joined_at', DateTime, default=datetime.utcnow),
    Column('invited_by', UUID(as_uuid=True), ForeignKey('users.id'), nullable=True),
    Column('is_active', Boolean, default=True, nullable=False),
    Column('permissions_json', Text, nullable=True)  # JSON string for custom permissions
)


class Organization(Base):
    """Organization model for multi-tenancy."""
    
    __tablename__ = 'organizations'
    
    # Primary key
    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4
    )
    
    # Basic information
    name: Mapped[str] = mapped_column(String(100), unique=True, nullable=False, index=True)
    display_name: Mapped[str] = mapped_column(String(200), nullable=False)
    slug: Mapped[str] = mapped_column(String(100), unique=True, nullable=False, index=True)
    description: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    
    # Contact information
    email: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)
    phone: Mapped[Optional[str]] = mapped_column(String(50), nullable=True)
    website: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)
    
    # Address
    address_line1: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)
    address_line2: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)
    city: Mapped[Optional[str]] = mapped_column(String(100), nullable=True)
    state: Mapped[Optional[str]] = mapped_column(String(100), nullable=True)
    country: Mapped[Optional[str]] = mapped_column(String(100), nullable=True)
    postal_code: Mapped[Optional[str]] = mapped_column(String(20), nullable=True)
    
    # Organization type and status
    org_type: Mapped[str] = mapped_column(
        String(50),
        default='standard',
        nullable=False
    )  # standard, enterprise, partner, internal
    industry: Mapped[Optional[str]] = mapped_column(String(100), nullable=True)
    size: Mapped[Optional[str]] = mapped_column(String(20), nullable=True)  # 1-10, 11-50, 51-200, 201-500, 500+
    
    # Status and flags
    status: Mapped[str] = mapped_column(
        String(20),
        default='active',
        nullable=False,
        index=True
    )  # active, inactive, suspended, pending, deleted
    is_verified: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    is_internal: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    
    # Billing and subscription
    billing_plan: Mapped[str] = mapped_column(
        String(50),
        default='free',
        nullable=False
    )  # free, starter, professional, enterprise
    billing_status: Mapped[str] = mapped_column(
        String(20),
        default='active',
        nullable=False
    )  # active, past_due, cancelled
    trial_ends_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)
    subscription_ends_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)
    
    # Limits and quotas
    max_users: Mapped[int] = mapped_column(Integer, default=5, nullable=False)
    max_api_keys: Mapped[int] = mapped_column(Integer, default=10, nullable=False)
    max_webhooks: Mapped[int] = mapped_column(Integer, default=5, nullable=False)
    max_roles: Mapped[int] = mapped_column(Integer, default=10, nullable=False)
    storage_quota_gb: Mapped[int] = mapped_column(Integer, default=10, nullable=False)
    api_rate_limit: Mapped[int] = mapped_column(Integer, default=1000, nullable=False)  # requests per hour
    
    # Usage tracking
    current_users: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    current_api_keys: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    current_storage_gb: Mapped[Numeric] = mapped_column(Numeric(10, 2), default=0, nullable=False)
    
    # Customization
    logo_url: Mapped[Optional[str]] = mapped_column(String(500), nullable=True)
    brand_color: Mapped[Optional[str]] = mapped_column(String(7), nullable=True)  # Hex color
    custom_domain: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)
    theme_preferences: Mapped[Optional[Dict]] = mapped_column(JSON, nullable=True)
    
    # Settings and configuration
    settings: Mapped[Optional[Dict]] = mapped_column(JSON, nullable=True)
    features: Mapped[Optional[Dict]] = mapped_column(JSON, nullable=True)  # Feature flags
    metadata: Mapped[Optional[Dict]] = mapped_column(JSON, nullable=True)
    
    # Security
    allowed_domains: Mapped[Optional[List[str]]] = mapped_column(JSON, nullable=True)  # Email domains for auto-join
    ip_whitelist: Mapped[Optional[List[str]]] = mapped_column(JSON, nullable=True)
    require_2fa: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    sso_enabled: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    sso_config: Mapped[Optional[Dict]] = mapped_column(JSON, nullable=True)
    
    # Owner and timestamps
    owner_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey('users.id', ondelete='RESTRICT'),
        nullable=False
    )
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
    deleted_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)
    
    # Relationships
    owner: Mapped['User'] = relationship(
        'User',
        foreign_keys=[owner_id],
        back_populates='owned_organizations'
    )
    
    members: Mapped[List['User']] = relationship(
        'User',
        secondary=organization_members,
        back_populates='organizations',
        lazy='selectin'
    )
    
    roles: Mapped[List['Role']] = relationship(
        'Role',
        back_populates='organization',
        cascade='all, delete-orphan',
        lazy='selectin'
    )
    
    api_keys: Mapped[List['APIKey']] = relationship(
        'APIKey',
        back_populates='organization',
        cascade='all, delete-orphan',
        lazy='selectin'
    )
    
    webhooks: Mapped[List['Webhook']] = relationship(
        'Webhook',
        back_populates='organization',
        cascade='all, delete-orphan',
        lazy='selectin'
    )
    
    # Properties
    @property
    def member_count(self) -> int:
        """Get number of members."""
        return len(self.members)
    
    @property
    def is_full(self) -> bool:
        """Check if organization has reached max users limit."""
        return self.current_users >= self.max_users
    
    @property
    def is_trial(self) -> bool:
        """Check if organization is in trial period."""
        if not self.trial_ends_at:
            return False
        return datetime.utcnow() < self.trial_ends_at
    
    @property
    def is_expired(self) -> bool:
        """Check if subscription has expired."""
        if not self.subscription_ends_at:
            return False
        return datetime.utcnow() > self.subscription_ends_at
    
    @property
    def days_until_expiry(self) -> Optional[int]:
        """Get days until subscription expires."""
        if not self.subscription_ends_at:
            return None
        delta = self.subscription_ends_at - datetime.utcnow()
        return delta.days if delta.days > 0 else 0
    
    @property
    def usage_percentage(self) -> Dict[str, float]:
        """Get usage percentages for quotas."""
        return {
            'users': (self.current_users / self.max_users * 100) if self.max_users > 0 else 0,
            'api_keys': (self.current_api_keys / self.max_api_keys * 100) if self.max_api_keys > 0 else 0,
            'storage': (float(self.current_storage_gb) / self.storage_quota_gb * 100) if self.storage_quota_gb > 0 else 0
        }
    
    # Methods
    def add_member(self, user: 'User', role: OrganizationRole = OrganizationRole.MEMBER, invited_by: Optional['User'] = None) -> None:
        """Add a member to organization."""
        if self.is_full:
            raise ValueError(f"Organization {self.name} has reached maximum user limit")
        
        if user not in self.members:
            self.members.append(user)
            self.current_users += 1
    
    def remove_member(self, user: 'User') -> None:
        """Remove a member from organization."""
        if user == self.owner:
            raise ValueError("Cannot remove organization owner")
        
        if user in self.members:
            self.members.remove(user)
            self.current_users = max(0, self.current_users - 1)
    
    def change_member_role(self, user: 'User', new_role: OrganizationRole) -> None:
        """Change a member's role in the organization."""
        if user not in self.members:
            raise ValueError(f"User {user.email} is not a member of organization {self.name}")
        
        # Update role in association table
        # This would need to be done via a database update query
        pass
    
    def transfer_ownership(self, new_owner: 'User') -> None:
        """Transfer organization ownership to another member."""
        if new_owner not in self.members:
            raise ValueError(f"New owner must be a member of the organization")
        
        old_owner = self.owner
        self.owner = new_owner
        self.owner_id = new_owner.id
        
        # Update roles
        self.change_member_role(old_owner, OrganizationRole.ADMIN)
        self.change_member_role(new_owner, OrganizationRole.OWNER)
    
    def can_add_users(self, count: int = 1) -> bool:
        """Check if organization can add more users."""
        return (self.current_users + count) <= self.max_users
    
    def can_add_api_keys(self, count: int = 1) -> bool:
        """Check if organization can add more API keys."""
        return (self.current_api_keys + count) <= self.max_api_keys
    
    def update_usage(self) -> None:
        """Update current usage statistics."""
        self.current_users = len(self.members)
        self.current_api_keys = len(self.api_keys)
        # Storage would need to be calculated based on actual usage
    
    def to_dict(self, include_members: bool = False, include_settings: bool = False) -> dict:
        """Convert organization to dictionary."""
        data = {
            'id': str(self.id),
            'name': self.name,
            'display_name': self.display_name,
            'slug': self.slug,
            'description': self.description,
            'email': self.email,
            'phone': self.phone,
            'website': self.website,
            'org_type': self.org_type,
            'industry': self.industry,
            'size': self.size,
            'status': self.status,
            'is_verified': self.is_verified,
            'billing_plan': self.billing_plan,
            'billing_status': self.billing_status,
            'is_trial': self.is_trial,
            'is_expired': self.is_expired,
            'days_until_expiry': self.days_until_expiry,
            'limits': {
                'max_users': self.max_users,
                'max_api_keys': self.max_api_keys,
                'max_webhooks': self.max_webhooks,
                'max_roles': self.max_roles,
                'storage_quota_gb': self.storage_quota_gb,
                'api_rate_limit': self.api_rate_limit
            },
            'usage': {
                'current_users': self.current_users,
                'current_api_keys': self.current_api_keys,
                'current_storage_gb': float(self.current_storage_gb),
                'usage_percentage': self.usage_percentage
            },
            'logo_url': self.logo_url,
            'brand_color': self.brand_color,
            'custom_domain': self.custom_domain,
            'require_2fa': self.require_2fa,
            'sso_enabled': self.sso_enabled,
            'owner_id': str(self.owner_id),
            'member_count': self.member_count,
            'created_at': self.created_at.isoformat(),
            'updated_at': self.updated_at.isoformat()
        }
        
        if include_members:
            data['members'] = [
                {
                    'id': str(m.id),
                    'email': m.email,
                    'name': m.full_name,
                    'role': 'member'  # Would need to get from association table
                }
                for m in self.members
            ]
        
        if include_settings:
            data['settings'] = self.settings or {}
            data['features'] = self.features or {}
            data['metadata'] = self.metadata or {}
        
        return data
    
    def __repr__(self) -> str:
        return f"<Organization(id={self.id}, name={self.name}, plan={self.billing_plan})>"
    
    def __str__(self) -> str:
        return self.display_name or self.name