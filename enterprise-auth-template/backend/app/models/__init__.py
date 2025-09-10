"""
Database Models

SQLAlchemy models for the enterprise authentication system.
All models inherit from the Base class defined in core.database.
"""

from app.models.audit import AuditLog
from app.models.auth import (
    EmailVerificationToken,
    PasswordResetToken,
    RefreshToken,
)
from app.models.magic_link import MagicLink
from app.models.session import UserSession
from app.models.user import RolePermission, User, UserRole
from app.models.role import Role
from app.models.permission import Permission
from app.models.organization import Organization, PlanTypes
from app.models.api_key import APIKey, APIKeyScopes
from app.models.notification import (
    Notification,
    NotificationTemplate,
    NotificationType,
    NotificationPriority,
    NotificationStatus,
    NotificationCategory
)

# Note: Using enhanced models from separate files for new features
# The basic Role/Permission models in user.py will be migrated in future updates

# Export all models for Alembic auto-generation
__all__ = [
    "User",
    "Role",
    "Permission",
    "UserRole",
    "RolePermission",
    "RefreshToken",
    "PasswordResetToken",
    "EmailVerificationToken",
    "MagicLink",
    "AuditLog",
    "UserSession",
    "Organization",
    "PlanTypes",
    "APIKey",
    "APIKeyScopes",
    "Notification",
    "NotificationTemplate",
    "NotificationType",
    "NotificationPriority",
    "NotificationStatus",
    "NotificationCategory",
]
