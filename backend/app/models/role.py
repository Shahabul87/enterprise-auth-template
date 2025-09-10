"""
Role model for RBAC system.
"""
from typing import List, Optional, TYPE_CHECKING
from datetime import datetime
from sqlalchemy import Column, String, DateTime, Boolean, Text, Table, ForeignKey, Integer
from sqlalchemy.orm import relationship, Mapped, mapped_column
from sqlalchemy.dialects.postgresql import UUID
import uuid

from app.core.database import Base

if TYPE_CHECKING:
    from app.models.user import User
    from app.models.permission import Permission
    from app.models.organization import Organization


# Association tables
user_roles = Table(
    'user_roles',
    Base.metadata,
    Column('user_id', UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), primary_key=True),
    Column('role_id', UUID(as_uuid=True), ForeignKey('roles.id', ondelete='CASCADE'), primary_key=True),
    Column('assigned_at', DateTime, default=datetime.utcnow),
    Column('assigned_by', UUID(as_uuid=True), ForeignKey('users.id'), nullable=True),
    Column('expires_at', DateTime, nullable=True)
)

role_permissions = Table(
    'role_permissions',
    Base.metadata,
    Column('role_id', UUID(as_uuid=True), ForeignKey('roles.id', ondelete='CASCADE'), primary_key=True),
    Column('permission_id', UUID(as_uuid=True), ForeignKey('permissions.id', ondelete='CASCADE'), primary_key=True),
    Column('granted_at', DateTime, default=datetime.utcnow),
    Column('granted_by', UUID(as_uuid=True), ForeignKey('users.id'), nullable=True)
)


class Role(Base):
    """Role model for RBAC."""
    
    __tablename__ = 'roles'
    
    # Primary key
    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4
    )
    
    # Basic fields
    name: Mapped[str] = mapped_column(String(50), unique=True, nullable=False, index=True)
    display_name: Mapped[str] = mapped_column(String(100), nullable=False)
    description: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    
    # Role type and hierarchy
    role_type: Mapped[str] = mapped_column(
        String(20),
        default='custom',
        nullable=False
    )  # system, organization, custom
    parent_role_id: Mapped[Optional[uuid.UUID]] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey('roles.id', ondelete='SET NULL'),
        nullable=True
    )
    hierarchy_level: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    
    # Organization-specific role
    organization_id: Mapped[Optional[uuid.UUID]] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey('organizations.id', ondelete='CASCADE'),
        nullable=True,
        index=True
    )
    
    # Status and flags
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    is_system: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    is_default: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    is_assignable: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    
    # Limits and constraints
    max_users: Mapped[Optional[int]] = mapped_column(Integer, nullable=True)  # Max users with this role
    priority: Mapped[int] = mapped_column(Integer, default=0, nullable=False)  # For conflict resolution
    
    # Metadata
    metadata_json: Mapped[Optional[str]] = mapped_column(Text, nullable=True)  # JSON string for extra data
    
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
        ForeignKey('users.id', ondelete='SET NULL'),
        nullable=True
    )
    updated_by: Mapped[Optional[uuid.UUID]] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey('users.id', ondelete='SET NULL'),
        nullable=True
    )
    
    # Relationships
    users: Mapped[List['User']] = relationship(
        'User',
        secondary=user_roles,
        back_populates='roles',
        lazy='selectin',
        foreign_keys=[user_roles.c.user_id, user_roles.c.role_id]
    )
    
    permissions: Mapped[List['Permission']] = relationship(
        'Permission',
        secondary=role_permissions,
        back_populates='roles',
        lazy='selectin'
    )
    
    organization: Mapped[Optional['Organization']] = relationship(
        'Organization',
        back_populates='roles',
        lazy='selectin'
    )
    
    parent_role: Mapped[Optional['Role']] = relationship(
        'Role',
        remote_side=[id],
        backref='child_roles'
    )
    
    # Properties
    @property
    def user_count(self) -> int:
        """Get number of users with this role."""
        return len(self.users)
    
    @property
    def permission_count(self) -> int:
        """Get number of permissions in this role."""
        return len(self.permissions)
    
    @property
    def is_full(self) -> bool:
        """Check if role has reached max users limit."""
        if self.max_users is None:
            return False
        return self.user_count >= self.max_users
    
    @property
    def permission_codes(self) -> List[str]:
        """Get list of permission codes."""
        return [p.code for p in self.permissions]
    
    @property
    def inherited_permissions(self) -> List['Permission']:
        """Get permissions including inherited from parent roles."""
        permissions = list(self.permissions)
        
        if self.parent_role:
            permissions.extend(self.parent_role.inherited_permissions)
        
        # Remove duplicates while preserving order
        seen = set()
        unique_permissions = []
        for p in permissions:
            if p.id not in seen:
                seen.add(p.id)
                unique_permissions.append(p)
        
        return unique_permissions
    
    # Methods
    def has_permission(self, permission_code: str) -> bool:
        """Check if role has specific permission."""
        for permission in self.inherited_permissions:
            if permission.code == permission_code:
                return True
            # Check for wildcard permissions
            if permission.code.endswith(':*'):
                resource = permission.code.split(':')[0]
                if permission_code.startswith(f"{resource}:"):
                    return True
            if permission.code == '*:*' or permission.code == 'system:*':
                return True
        return False
    
    def add_permission(self, permission: 'Permission') -> None:
        """Add permission to role."""
        if permission not in self.permissions:
            self.permissions.append(permission)
    
    def remove_permission(self, permission: 'Permission') -> None:
        """Remove permission from role."""
        if permission in self.permissions:
            self.permissions.remove(permission)
    
    def add_user(self, user: 'User') -> None:
        """Add user to role."""
        if self.is_full:
            raise ValueError(f"Role {self.name} has reached maximum user limit")
        if user not in self.users:
            self.users.append(user)
    
    def remove_user(self, user: 'User') -> None:
        """Remove user from role."""
        if user in self.users:
            self.users.remove(user)
    
    def clone(self, new_name: str, new_organization_id: Optional[uuid.UUID] = None) -> 'Role':
        """Clone this role with a new name."""
        new_role = Role(
            name=new_name,
            display_name=f"Copy of {self.display_name}",
            description=self.description,
            role_type='custom',
            parent_role_id=self.parent_role_id,
            hierarchy_level=self.hierarchy_level,
            organization_id=new_organization_id or self.organization_id,
            is_active=True,
            is_system=False,
            is_default=False,
            is_assignable=self.is_assignable,
            max_users=self.max_users,
            priority=self.priority
        )
        
        # Copy permissions
        for permission in self.permissions:
            new_role.permissions.append(permission)
        
        return new_role
    
    def to_dict(self, include_permissions: bool = False, include_users: bool = False) -> dict:
        """Convert role to dictionary."""
        data = {
            'id': str(self.id),
            'name': self.name,
            'display_name': self.display_name,
            'description': self.description,
            'role_type': self.role_type,
            'parent_role_id': str(self.parent_role_id) if self.parent_role_id else None,
            'hierarchy_level': self.hierarchy_level,
            'organization_id': str(self.organization_id) if self.organization_id else None,
            'is_active': self.is_active,
            'is_system': self.is_system,
            'is_default': self.is_default,
            'is_assignable': self.is_assignable,
            'max_users': self.max_users,
            'priority': self.priority,
            'user_count': self.user_count,
            'permission_count': self.permission_count,
            'is_full': self.is_full,
            'created_at': self.created_at.isoformat(),
            'updated_at': self.updated_at.isoformat()
        }
        
        if include_permissions:
            data['permissions'] = [p.to_dict() for p in self.permissions]
            data['permission_codes'] = self.permission_codes
        
        if include_users:
            data['users'] = [
                {
                    'id': str(u.id),
                    'email': u.email,
                    'name': u.full_name
                }
                for u in self.users
            ]
        
        return data
    
    def __repr__(self) -> str:
        return f"<Role(id={self.id}, name={self.name}, type={self.role_type})>"
    
    def __str__(self) -> str:
        return self.display_name or self.name


# Default system roles
DEFAULT_ROLES = [
    {
        'name': 'super_admin',
        'display_name': 'Super Administrator',
        'description': 'Full system access with all permissions',
        'role_type': 'system',
        'hierarchy_level': 0,
        'is_system': True,
        'is_assignable': False,
        'priority': 1000
    },
    {
        'name': 'admin',
        'display_name': 'Administrator',
        'description': 'Administrative access to most system features',
        'role_type': 'system',
        'hierarchy_level': 1,
        'is_system': True,
        'is_assignable': True,
        'priority': 900
    },
    {
        'name': 'moderator',
        'display_name': 'Moderator',
        'description': 'Moderate content and manage users',
        'role_type': 'system',
        'hierarchy_level': 2,
        'is_system': True,
        'is_assignable': True,
        'priority': 800
    },
    {
        'name': 'user',
        'display_name': 'User',
        'description': 'Standard user with basic permissions',
        'role_type': 'system',
        'hierarchy_level': 3,
        'is_system': True,
        'is_default': True,
        'is_assignable': True,
        'priority': 100
    },
    {
        'name': 'guest',
        'display_name': 'Guest',
        'description': 'Limited read-only access',
        'role_type': 'system',
        'hierarchy_level': 4,
        'is_system': True,
        'is_assignable': True,
        'priority': 10
    }
]