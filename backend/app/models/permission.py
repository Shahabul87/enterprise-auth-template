"""
Permission model for RBAC system.
"""
from typing import List, Optional, TYPE_CHECKING, Dict, Any
from datetime import datetime
from sqlalchemy import Column, String, DateTime, Boolean, Text, Table, ForeignKey, Integer, UniqueConstraint
from sqlalchemy.orm import relationship, Mapped, mapped_column
from sqlalchemy.dialects.postgresql import UUID
import uuid

from app.core.database import Base

if TYPE_CHECKING:
    from app.models.user import User
    from app.models.role import Role


# Association table for direct user permissions
user_permissions = Table(
    'user_permissions',
    Base.metadata,
    Column('user_id', UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), primary_key=True),
    Column('permission_id', UUID(as_uuid=True), ForeignKey('permissions.id', ondelete='CASCADE'), primary_key=True),
    Column('granted_at', DateTime, default=datetime.utcnow),
    Column('granted_by', UUID(as_uuid=True), ForeignKey('users.id'), nullable=True),
    Column('expires_at', DateTime, nullable=True),
    Column('reason', Text, nullable=True)
)


class Permission(Base):
    """Permission model for RBAC."""
    
    __tablename__ = 'permissions'
    __table_args__ = (
        UniqueConstraint('code', 'scope', name='uq_permission_code_scope'),
    )
    
    # Primary key
    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4
    )
    
    # Basic fields
    code: Mapped[str] = mapped_column(String(100), nullable=False, index=True)
    name: Mapped[str] = mapped_column(String(100), nullable=False)
    description: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    
    # Permission categorization
    resource: Mapped[str] = mapped_column(String(50), nullable=False, index=True)
    action: Mapped[str] = mapped_column(String(50), nullable=False, index=True)
    scope: Mapped[str] = mapped_column(
        String(20),
        default='global',
        nullable=False
    )  # global, organization, team, user
    
    # Permission grouping
    category: Mapped[str] = mapped_column(String(50), default='general', nullable=False)
    module: Mapped[Optional[str]] = mapped_column(String(50), nullable=True)
    
    # Conditions and constraints
    conditions_json: Mapped[Optional[str]] = mapped_column(
        Text,
        nullable=True
    )  # JSON string for permission conditions
    
    # Risk and importance
    risk_level: Mapped[str] = mapped_column(
        String(20),
        default='low',
        nullable=False
    )  # low, medium, high, critical
    requires_2fa: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    requires_approval: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    
    # Status and flags
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    is_system: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    is_deprecated: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    is_dangerous: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    
    # UI configuration
    ui_label: Mapped[Optional[str]] = mapped_column(String(100), nullable=True)
    ui_icon: Mapped[Optional[str]] = mapped_column(String(50), nullable=True)
    ui_color: Mapped[Optional[str]] = mapped_column(String(20), nullable=True)
    ui_order: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    
    # Dependencies
    depends_on_permission_id: Mapped[Optional[uuid.UUID]] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey('permissions.id', ondelete='SET NULL'),
        nullable=True
    )
    
    # Metadata
    metadata_json: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    
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
    roles: Mapped[List['Role']] = relationship(
        'Role',
        secondary='role_permissions',
        back_populates='permissions',
        lazy='selectin'
    )
    
    users: Mapped[List['User']] = relationship(
        'User',
        secondary=user_permissions,
        back_populates='direct_permissions',
        lazy='selectin'
    )
    
    depends_on: Mapped[Optional['Permission']] = relationship(
        'Permission',
        remote_side=[id],
        backref='dependent_permissions'
    )
    
    # Properties
    @property
    def full_code(self) -> str:
        """Get full permission code including scope."""
        if self.scope != 'global':
            return f"{self.scope}:{self.code}"
        return self.code
    
    @property
    def is_wildcard(self) -> bool:
        """Check if this is a wildcard permission."""
        return '*' in self.code
    
    @property
    def role_count(self) -> int:
        """Get number of roles with this permission."""
        return len(self.roles)
    
    @property
    def user_count(self) -> int:
        """Get number of users with direct permission."""
        return len(self.users)
    
    @property
    def is_high_risk(self) -> bool:
        """Check if permission is high risk."""
        return self.risk_level in ['high', 'critical'] or self.is_dangerous
    
    # Methods
    def matches(self, permission_code: str) -> bool:
        """Check if this permission matches a given code."""
        if self.code == permission_code:
            return True
        
        # Check wildcard matching
        if self.is_wildcard:
            import re
            pattern = self.code.replace('*', '.*')
            return bool(re.match(f"^{pattern}$", permission_code))
        
        return False
    
    def implies(self, other_permission: 'Permission') -> bool:
        """Check if this permission implies another permission."""
        # System-wide permissions imply everything
        if self.code == 'system:*' or self.code == '*:*':
            return True
        
        # Check resource wildcard
        if self.code.endswith(':*'):
            resource = self.code.split(':')[0]
            return other_permission.resource == resource
        
        # Check action wildcard
        if self.code.startswith('*:'):
            action = self.code.split(':')[1]
            return other_permission.action == action
        
        # Direct match
        return self.code == other_permission.code
    
    def validate_conditions(self, context: Dict[str, Any]) -> bool:
        """Validate permission conditions against context."""
        if not self.conditions_json:
            return True
        
        import json
        try:
            conditions = json.loads(self.conditions_json)
            
            # Check each condition
            for key, expected_value in conditions.items():
                if key not in context:
                    return False
                
                context_value = context[key]
                
                # Handle different condition types
                if isinstance(expected_value, dict):
                    # Complex conditions
                    if '$in' in expected_value:
                        if context_value not in expected_value['$in']:
                            return False
                    if '$gt' in expected_value:
                        if context_value <= expected_value['$gt']:
                            return False
                    if '$lt' in expected_value:
                        if context_value >= expected_value['$lt']:
                            return False
                    if '$regex' in expected_value:
                        import re
                        if not re.match(expected_value['$regex'], str(context_value)):
                            return False
                else:
                    # Simple equality check
                    if context_value != expected_value:
                        return False
            
            return True
            
        except (json.JSONDecodeError, KeyError, TypeError):
            # If conditions are malformed, deny permission
            return False
    
    def to_dict(self, include_roles: bool = False) -> dict:
        """Convert permission to dictionary."""
        data = {
            'id': str(self.id),
            'code': self.code,
            'name': self.name,
            'description': self.description,
            'resource': self.resource,
            'action': self.action,
            'scope': self.scope,
            'category': self.category,
            'module': self.module,
            'full_code': self.full_code,
            'is_wildcard': self.is_wildcard,
            'risk_level': self.risk_level,
            'requires_2fa': self.requires_2fa,
            'requires_approval': self.requires_approval,
            'is_active': self.is_active,
            'is_system': self.is_system,
            'is_deprecated': self.is_deprecated,
            'is_dangerous': self.is_dangerous,
            'is_high_risk': self.is_high_risk,
            'role_count': self.role_count,
            'user_count': self.user_count,
            'ui_label': self.ui_label,
            'ui_icon': self.ui_icon,
            'ui_color': self.ui_color,
            'ui_order': self.ui_order,
            'created_at': self.created_at.isoformat(),
            'updated_at': self.updated_at.isoformat()
        }
        
        if self.conditions_json:
            import json
            try:
                data['conditions'] = json.loads(self.conditions_json)
            except json.JSONDecodeError:
                data['conditions'] = None
        
        if include_roles:
            data['roles'] = [
                {
                    'id': str(r.id),
                    'name': r.name,
                    'display_name': r.display_name
                }
                for r in self.roles
            ]
        
        return data
    
    def __repr__(self) -> str:
        return f"<Permission(id={self.id}, code={self.code}, scope={self.scope})>"
    
    def __str__(self) -> str:
        return self.name or self.code


# Default system permissions
DEFAULT_PERMISSIONS = [
    # System permissions
    {
        'code': 'system:*',
        'name': 'System Administrator',
        'description': 'Full system access',
        'resource': 'system',
        'action': '*',
        'category': 'system',
        'risk_level': 'critical',
        'is_system': True,
        'is_dangerous': True
    },
    {
        'code': 'system:manage',
        'name': 'System Management',
        'description': 'Manage system settings and configuration',
        'resource': 'system',
        'action': 'manage',
        'category': 'system',
        'risk_level': 'critical',
        'is_system': True,
        'requires_2fa': True
    },
    
    # User permissions
    {
        'code': 'user:create',
        'name': 'Create Users',
        'description': 'Create new user accounts',
        'resource': 'user',
        'action': 'create',
        'category': 'user_management',
        'risk_level': 'medium'
    },
    {
        'code': 'user:read',
        'name': 'View Users',
        'description': 'View user information',
        'resource': 'user',
        'action': 'read',
        'category': 'user_management',
        'risk_level': 'low'
    },
    {
        'code': 'user:update',
        'name': 'Update Users',
        'description': 'Update user information',
        'resource': 'user',
        'action': 'update',
        'category': 'user_management',
        'risk_level': 'medium'
    },
    {
        'code': 'user:delete',
        'name': 'Delete Users',
        'description': 'Delete user accounts',
        'resource': 'user',
        'action': 'delete',
        'category': 'user_management',
        'risk_level': 'high',
        'requires_approval': True
    },
    {
        'code': 'user:list',
        'name': 'List Users',
        'description': 'List all users',
        'resource': 'user',
        'action': 'list',
        'category': 'user_management',
        'risk_level': 'low'
    },
    
    # Role permissions
    {
        'code': 'role:create',
        'name': 'Create Roles',
        'description': 'Create new roles',
        'resource': 'role',
        'action': 'create',
        'category': 'role_management',
        'risk_level': 'high',
        'requires_2fa': True
    },
    {
        'code': 'role:read',
        'name': 'View Roles',
        'description': 'View role information',
        'resource': 'role',
        'action': 'read',
        'category': 'role_management',
        'risk_level': 'low'
    },
    {
        'code': 'role:update',
        'name': 'Update Roles',
        'description': 'Update role information',
        'resource': 'role',
        'action': 'update',
        'category': 'role_management',
        'risk_level': 'high',
        'requires_2fa': True
    },
    {
        'code': 'role:delete',
        'name': 'Delete Roles',
        'description': 'Delete roles',
        'resource': 'role',
        'action': 'delete',
        'category': 'role_management',
        'risk_level': 'critical',
        'requires_approval': True,
        'requires_2fa': True
    },
    {
        'code': 'role:assign',
        'name': 'Assign Roles',
        'description': 'Assign roles to users',
        'resource': 'role',
        'action': 'assign',
        'category': 'role_management',
        'risk_level': 'high'
    },
    
    # Permission management
    {
        'code': 'permission:grant',
        'name': 'Grant Permissions',
        'description': 'Grant permissions to roles or users',
        'resource': 'permission',
        'action': 'grant',
        'category': 'permission_management',
        'risk_level': 'critical',
        'requires_2fa': True,
        'is_dangerous': True
    },
    {
        'code': 'permission:revoke',
        'name': 'Revoke Permissions',
        'description': 'Revoke permissions from roles or users',
        'resource': 'permission',
        'action': 'revoke',
        'category': 'permission_management',
        'risk_level': 'high',
        'requires_2fa': True
    },
    {
        'code': 'permission:read',
        'name': 'View Permissions',
        'description': 'View permission information',
        'resource': 'permission',
        'action': 'read',
        'category': 'permission_management',
        'risk_level': 'low'
    },
    
    # Profile permissions (for own profile)
    {
        'code': 'profile:read',
        'name': 'View Profile',
        'description': 'View own profile',
        'resource': 'profile',
        'action': 'read',
        'category': 'profile',
        'risk_level': 'low'
    },
    {
        'code': 'profile:update',
        'name': 'Update Profile',
        'description': 'Update own profile',
        'resource': 'profile',
        'action': 'update',
        'category': 'profile',
        'risk_level': 'low'
    },
    
    # Session management
    {
        'code': 'session:read',
        'name': 'View Sessions',
        'description': 'View session information',
        'resource': 'session',
        'action': 'read',
        'category': 'session',
        'risk_level': 'low'
    },
    {
        'code': 'session:revoke',
        'name': 'Revoke Sessions',
        'description': 'Revoke active sessions',
        'resource': 'session',
        'action': 'revoke',
        'category': 'session',
        'risk_level': 'medium'
    },
    
    # API key management
    {
        'code': 'api_key:create',
        'name': 'Create API Keys',
        'description': 'Create API keys',
        'resource': 'api_key',
        'action': 'create',
        'category': 'api_key',
        'risk_level': 'medium'
    },
    {
        'code': 'api_key:read',
        'name': 'View API Keys',
        'description': 'View API key information',
        'resource': 'api_key',
        'action': 'read',
        'category': 'api_key',
        'risk_level': 'low'
    },
    {
        'code': 'api_key:revoke',
        'name': 'Revoke API Keys',
        'description': 'Revoke API keys',
        'resource': 'api_key',
        'action': 'revoke',
        'category': 'api_key',
        'risk_level': 'medium'
    },
    
    # Audit log
    {
        'code': 'audit_log:read',
        'name': 'View Audit Logs',
        'description': 'View audit log entries',
        'resource': 'audit_log',
        'action': 'read',
        'category': 'audit',
        'risk_level': 'low'
    },
    {
        'code': 'audit_log:export',
        'name': 'Export Audit Logs',
        'description': 'Export audit log data',
        'resource': 'audit_log',
        'action': 'export',
        'category': 'audit',
        'risk_level': 'medium'
    },
    
    # Admin permissions
    {
        'code': 'admin:access',
        'name': 'Admin Dashboard Access',
        'description': 'Access admin dashboard',
        'resource': 'admin',
        'action': 'access',
        'category': 'admin',
        'risk_level': 'medium',
        'requires_2fa': True
    }
]