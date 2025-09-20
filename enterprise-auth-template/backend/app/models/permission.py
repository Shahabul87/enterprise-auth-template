"""
Permission model for Role-Based Access Control (RBAC).
"""

from datetime import datetime
from typing import TYPE_CHECKING, List, Optional
from sqlalchemy import Boolean, Column, DateTime, String, Text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship
import uuid

from app.core.database import Base

if TYPE_CHECKING:
    from app.models.role import Role


class Permission(Base):
    """Permission model for RBAC system."""

    __tablename__ = "permissions"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, index=True
    )
    name: Mapped[str] = mapped_column(
        String(100), unique=True, nullable=False, index=True
    )
    display_name: Mapped[str] = mapped_column(String(150), nullable=False)
    description: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    resource: Mapped[str] = mapped_column(
        String(50),
        nullable=False,
        index=True,
        comment="Resource this permission applies to (e.g., 'user', 'role', 'post')",
    )
    action: Mapped[str] = mapped_column(
        String(50),
        nullable=False,
        index=True,
        comment="Action this permission allows (e.g., 'create', 'read', 'update', 'delete')",
    )
    scope: Mapped[Optional[str]] = mapped_column(
        String(50),
        nullable=True,
        comment="Scope of permission (e.g., 'own', 'team', 'all')",
    )
    is_system: Mapped[bool] = mapped_column(
        Boolean,
        default=False,
        nullable=False,
        comment="System permissions cannot be deleted",
    )
    is_active: Mapped[bool] = mapped_column(
        Boolean, default=True, nullable=False, index=True
    )

    # Timestamps
    created_at: Mapped[datetime] = mapped_column(
        DateTime, default=datetime.utcnow, nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False
    )

    # Relationships - Import role_permissions from role.py to avoid circular import
    roles: Mapped[List["Role"]] = relationship(
        "Role",
        secondary="role_permissions",
        back_populates="permissions",
        lazy="dynamic",
    )

    def __repr__(self) -> str:
        return f"<Permission {self.name}>"

    def to_dict(self) -> dict:
        """Convert permission to dictionary."""
        return {
            "id": str(self.id),
            "name": self.name,
            "display_name": self.display_name,
            "description": self.description,
            "resource": self.resource,
            "action": self.action,
            "scope": self.scope,
            "is_system": self.is_system,
            "is_active": self.is_active,
            "created_at": self.created_at.isoformat(),
            "updated_at": self.updated_at.isoformat(),
        }


class SystemPermissions:
    """System permission constants."""

    # User permissions
    USER_CREATE = "user.create"
    USER_READ = "user.read"
    USER_UPDATE = "user.update"
    USER_DELETE = "user.delete"
    USER_LIST = "user.list"

    # Role permissions
    ROLE_CREATE = "role.create"
    ROLE_READ = "role.read"
    ROLE_UPDATE = "role.update"
    ROLE_DELETE = "role.delete"
    ROLE_LIST = "role.list"
    ROLE_ASSIGN = "role.assign"

    # Permission permissions
    PERMISSION_CREATE = "permission.create"
    PERMISSION_READ = "permission.read"
    PERMISSION_UPDATE = "permission.update"
    PERMISSION_DELETE = "permission.delete"
    PERMISSION_LIST = "permission.list"
    PERMISSION_ASSIGN = "permission.assign"

    # Session permissions
    SESSION_READ = "session.read"
    SESSION_DELETE = "session.delete"
    SESSION_LIST = "session.list"

    # Audit permissions
    AUDIT_READ = "audit.read"
    AUDIT_LIST = "audit.list"
    AUDIT_EXPORT = "audit.export"

    # Admin permissions
    ADMIN_ACCESS = "admin.access"
    ADMIN_DASHBOARD = "admin.dashboard"
    ADMIN_SETTINGS = "admin.settings"
    ADMIN_ANALYTICS = "admin.analytics"

    # API Key permissions
    API_KEY_CREATE = "api_key.create"
    API_KEY_READ = "api_key.read"
    API_KEY_UPDATE = "api_key.update"
    API_KEY_DELETE = "api_key.delete"
    API_KEY_LIST = "api_key.list"

    # Notification permissions
    NOTIFICATION_CREATE = "notification.create"
    NOTIFICATION_READ = "notification.read"
    NOTIFICATION_UPDATE = "notification.update"
    NOTIFICATION_DELETE = "notification.delete"
    NOTIFICATION_SEND = "notification.send"

    @classmethod
    def get_all_permissions(cls) -> List[dict]:
        """Get all system permissions with metadata."""
        permissions = [
            # User permissions
            {
                "name": cls.USER_CREATE,
                "resource": "user",
                "action": "create",
                "display_name": "Create Users",
            },
            {
                "name": cls.USER_READ,
                "resource": "user",
                "action": "read",
                "display_name": "View Users",
            },
            {
                "name": cls.USER_UPDATE,
                "resource": "user",
                "action": "update",
                "display_name": "Update Users",
            },
            {
                "name": cls.USER_DELETE,
                "resource": "user",
                "action": "delete",
                "display_name": "Delete Users",
            },
            {
                "name": cls.USER_LIST,
                "resource": "user",
                "action": "list",
                "display_name": "List Users",
            },
            # Role permissions
            {
                "name": cls.ROLE_CREATE,
                "resource": "role",
                "action": "create",
                "display_name": "Create Roles",
            },
            {
                "name": cls.ROLE_READ,
                "resource": "role",
                "action": "read",
                "display_name": "View Roles",
            },
            {
                "name": cls.ROLE_UPDATE,
                "resource": "role",
                "action": "update",
                "display_name": "Update Roles",
            },
            {
                "name": cls.ROLE_DELETE,
                "resource": "role",
                "action": "delete",
                "display_name": "Delete Roles",
            },
            {
                "name": cls.ROLE_LIST,
                "resource": "role",
                "action": "list",
                "display_name": "List Roles",
            },
            {
                "name": cls.ROLE_ASSIGN,
                "resource": "role",
                "action": "assign",
                "display_name": "Assign Roles",
            },
            # Permission permissions
            {
                "name": cls.PERMISSION_CREATE,
                "resource": "permission",
                "action": "create",
                "display_name": "Create Permissions",
            },
            {
                "name": cls.PERMISSION_READ,
                "resource": "permission",
                "action": "read",
                "display_name": "View Permissions",
            },
            {
                "name": cls.PERMISSION_UPDATE,
                "resource": "permission",
                "action": "update",
                "display_name": "Update Permissions",
            },
            {
                "name": cls.PERMISSION_DELETE,
                "resource": "permission",
                "action": "delete",
                "display_name": "Delete Permissions",
            },
            {
                "name": cls.PERMISSION_LIST,
                "resource": "permission",
                "action": "list",
                "display_name": "List Permissions",
            },
            {
                "name": cls.PERMISSION_ASSIGN,
                "resource": "permission",
                "action": "assign",
                "display_name": "Assign Permissions",
            },
            # Session permissions
            {
                "name": cls.SESSION_READ,
                "resource": "session",
                "action": "read",
                "display_name": "View Sessions",
            },
            {
                "name": cls.SESSION_DELETE,
                "resource": "session",
                "action": "delete",
                "display_name": "Terminate Sessions",
            },
            {
                "name": cls.SESSION_LIST,
                "resource": "session",
                "action": "list",
                "display_name": "List Sessions",
            },
            # Audit permissions
            {
                "name": cls.AUDIT_READ,
                "resource": "audit",
                "action": "read",
                "display_name": "View Audit Logs",
            },
            {
                "name": cls.AUDIT_LIST,
                "resource": "audit",
                "action": "list",
                "display_name": "List Audit Logs",
            },
            {
                "name": cls.AUDIT_EXPORT,
                "resource": "audit",
                "action": "export",
                "display_name": "Export Audit Logs",
            },
            # Admin permissions
            {
                "name": cls.ADMIN_ACCESS,
                "resource": "admin",
                "action": "access",
                "display_name": "Access Admin Panel",
            },
            {
                "name": cls.ADMIN_DASHBOARD,
                "resource": "admin",
                "action": "dashboard",
                "display_name": "View Admin Dashboard",
            },
            {
                "name": cls.ADMIN_SETTINGS,
                "resource": "admin",
                "action": "settings",
                "display_name": "Manage Admin Settings",
            },
            {
                "name": cls.ADMIN_ANALYTICS,
                "resource": "admin",
                "action": "analytics",
                "display_name": "View Analytics",
            },
            # API Key permissions
            {
                "name": cls.API_KEY_CREATE,
                "resource": "api_key",
                "action": "create",
                "display_name": "Create API Keys",
            },
            {
                "name": cls.API_KEY_READ,
                "resource": "api_key",
                "action": "read",
                "display_name": "View API Keys",
            },
            {
                "name": cls.API_KEY_UPDATE,
                "resource": "api_key",
                "action": "update",
                "display_name": "Update API Keys",
            },
            {
                "name": cls.API_KEY_DELETE,
                "resource": "api_key",
                "action": "delete",
                "display_name": "Delete API Keys",
            },
            {
                "name": cls.API_KEY_LIST,
                "resource": "api_key",
                "action": "list",
                "display_name": "List API Keys",
            },
            # Notification permissions
            {
                "name": cls.NOTIFICATION_CREATE,
                "resource": "notification",
                "action": "create",
                "display_name": "Create Notifications",
            },
            {
                "name": cls.NOTIFICATION_READ,
                "resource": "notification",
                "action": "read",
                "display_name": "View Notifications",
            },
            {
                "name": cls.NOTIFICATION_UPDATE,
                "resource": "notification",
                "action": "update",
                "display_name": "Update Notifications",
            },
            {
                "name": cls.NOTIFICATION_DELETE,
                "resource": "notification",
                "action": "delete",
                "display_name": "Delete Notifications",
            },
            {
                "name": cls.NOTIFICATION_SEND,
                "resource": "notification",
                "action": "send",
                "display_name": "Send Notifications",
            },
        ]

        return permissions
