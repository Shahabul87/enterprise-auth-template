"""
Role model for Role-Based Access Control (RBAC).
"""

from datetime import datetime
from typing import TYPE_CHECKING, List, Optional
from sqlalchemy import Boolean, Column, DateTime, ForeignKey, String, Table, Text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship
import uuid

from app.core.database import Base

if TYPE_CHECKING:
    from app.models.user import User
    from app.models.permission import Permission

# Association table for many-to-many relationship between roles and permissions
# Using table name as string - actual model defined in user.py to avoid circular imports

# Association table for many-to-many relationship between users and roles
# Using table name as string - actual model defined in user.py to avoid circular imports


class Role(Base):
    """Role model for RBAC system."""

    __tablename__ = "roles"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
        index=True
    )
    name: Mapped[str] = mapped_column(
        String(50),
        unique=True,
        nullable=False,
        index=True
    )
    display_name: Mapped[str] = mapped_column(
        String(100),
        nullable=False
    )
    description: Mapped[Optional[str]] = mapped_column(
        Text,
        nullable=True
    )
    is_system: Mapped[bool] = mapped_column(
        Boolean,
        default=False,
        nullable=False,
        comment="System roles cannot be deleted"
    )
    is_active: Mapped[bool] = mapped_column(
        Boolean,
        default=True,
        nullable=False,
        index=True
    )
    priority: Mapped[int] = mapped_column(
        default=0,
        nullable=False,
        comment="Higher priority roles override lower ones"
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
    permissions: Mapped[List["Permission"]] = relationship(
        "Permission",
        secondary="role_permissions",
        back_populates="roles",
        lazy="selectin"
    )

    users: Mapped[List["User"]] = relationship(
        "User",
        secondary="user_roles_association",
        back_populates="roles",
        lazy="dynamic"
    )

    def __repr__(self) -> str:
        return f"<Role {self.name}>"

    def has_permission(self, permission_name: str) -> bool:
        """Check if role has a specific permission."""
        return any(p.name == permission_name for p in self.permissions if p.is_active)

    def add_permission(self, permission: "Permission") -> None:
        """Add a permission to this role."""
        if permission not in self.permissions:
            self.permissions.append(permission)

    def remove_permission(self, permission: "Permission") -> None:
        """Remove a permission from this role."""
        if permission in self.permissions:
            self.permissions.remove(permission)

    def to_dict(self) -> dict:
        """Convert role to dictionary."""
        return {
            "id": str(self.id),
            "name": self.name,
            "display_name": self.display_name,
            "description": self.description,
            "is_system": self.is_system,
            "is_active": self.is_active,
            "priority": self.priority,
            "permissions": [p.name for p in self.permissions if p.is_active],
            "created_at": self.created_at.isoformat(),
            "updated_at": self.updated_at.isoformat()
        }


# Predefined system roles
class SystemRoles:
    """System role constants."""
    SUPER_ADMIN = "super_admin"
    ADMIN = "admin"
    MODERATOR = "moderator"
    USER = "user"
    GUEST = "guest"

    @classmethod
    def get_all(cls) -> List[str]:
        """Get all system role names."""
        return [cls.SUPER_ADMIN, cls.ADMIN, cls.MODERATOR, cls.USER, cls.GUEST]

    @classmethod
    def get_default_role(cls) -> str:
        """Get default role for new users."""
        return cls.USER
