"""
User and Role Models

Defines the user authentication and authorization models including
users, roles, permissions, and their relationships.
"""

from datetime import datetime
from typing import TYPE_CHECKING, List, Optional
from uuid import uuid4

from sqlalchemy import (
    Boolean,
    DateTime,
    ForeignKey,
    Integer,
    String,
    Text,
    UniqueConstraint,
)
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy.sql import func

from app.core.database import Base

if TYPE_CHECKING:
    from app.models.audit import AuditLog
    from app.models.auth import RefreshToken
    from app.models.magic_link import MagicLink
    from app.models.session import UserSession
    from app.models.organization import Organization
    from app.models.api_key import APIKey
    from app.models.notification import Notification
    from app.models.role import Role
    from app.models.permission import Permission


class User(Base):
    """
    User model for authentication and user management.

    Stores user account information, authentication details,
    and account status tracking.
    """

    __tablename__ = "users"

    # Primary fields
    id: Mapped[UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid4, index=True
    )
    email: Mapped[str] = mapped_column(
        String(255), unique=True, index=True, nullable=False
    )
    hashed_password: Mapped[Optional[str]] = mapped_column(
        String(255), nullable=True  # Nullable for OAuth-only accounts
    )

    # Profile information
    first_name: Mapped[str] = mapped_column(String(100), nullable=False)
    last_name: Mapped[str] = mapped_column(String(100), nullable=False)
    username: Mapped[Optional[str]] = mapped_column(
        String(100), unique=True, nullable=True
    )
    full_name: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)
    avatar_url: Mapped[Optional[str]] = mapped_column(String(500), nullable=True)

    # OAuth provider IDs
    google_id: Mapped[Optional[str]] = mapped_column(
        String(255), unique=True, nullable=True, index=True
    )
    github_id: Mapped[Optional[str]] = mapped_column(
        String(255), unique=True, nullable=True, index=True
    )
    discord_id: Mapped[Optional[str]] = mapped_column(
        String(255), unique=True, nullable=True, index=True
    )

    # Account status
    is_active: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    is_verified: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    is_superuser: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    email_verified: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    email_verified_at: Mapped[Optional[datetime]] = mapped_column(
        DateTime(timezone=True), nullable=True
    )

    # Two-Factor Authentication
    totp_secret: Mapped[Optional[str]] = mapped_column(String(32), nullable=True)
    two_factor_enabled: Mapped[bool] = mapped_column(
        Boolean, default=False, nullable=False
    )
    two_factor_verified_at: Mapped[Optional[datetime]] = mapped_column(
        DateTime(timezone=True), nullable=True
    )
    backup_codes: Mapped[Optional[str]] = mapped_column(
        Text, nullable=True
    )  # JSON array of encrypted codes
    two_factor_recovery_codes_used: Mapped[int] = mapped_column(
        Integer, default=0, nullable=False
    )

    # WebAuthn/Passkeys (for future implementation)
    webauthn_credentials: Mapped[Optional[dict]] = mapped_column(
        JSONB, nullable=True, default=dict
    )

    # Security tracking
    failed_login_attempts: Mapped[int] = mapped_column(
        Integer, default=0, nullable=False
    )
    locked_until: Mapped[Optional[datetime]] = mapped_column(
        DateTime(timezone=True), nullable=True
    )
    failed_2fa_attempts: Mapped[int] = mapped_column(Integer, default=0, nullable=False)

    # Timestamps
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        onupdate=func.now(),
        nullable=False,
    )
    last_login: Mapped[Optional[datetime]] = mapped_column(
        DateTime(timezone=True), nullable=True
    )

    # Flexible metadata storage (renamed to avoid SQLAlchemy conflict)
    user_metadata: Mapped[Optional[dict]] = mapped_column(
        JSONB, nullable=True, default=dict
    )

    # Organization for multi-tenancy
    organization_id: Mapped[Optional[UUID]] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("organizations.id"),
        nullable=True,
        index=True
    )

    # Relationships
    roles: Mapped[List["Role"]] = relationship(
        "Role",
        secondary="user_roles",
        back_populates="users",
        lazy="selectin",
        primaryjoin="User.id == user_roles.c.user_id",
        secondaryjoin="user_roles.c.role_id == Role.id",
    )

    user_roles: Mapped[List["UserRole"]] = relationship(
        "UserRole",
        back_populates="user",
        cascade="all, delete-orphan",
        foreign_keys="[UserRole.user_id]",
    )

    refresh_tokens: Mapped[List["RefreshToken"]] = relationship(
        "RefreshToken", back_populates="user", cascade="all, delete-orphan"
    )

    sessions: Mapped[List["UserSession"]] = relationship(
        "UserSession", back_populates="user", cascade="all, delete-orphan"
    )

    audit_logs: Mapped[List["AuditLog"]] = relationship(
        "AuditLog", back_populates="user", cascade="all, delete-orphan"
    )

    magic_links: Mapped[List["MagicLink"]] = relationship(
        "MagicLink", back_populates="user", cascade="all, delete-orphan"
    )

    # New relationships for enhanced features
    organization: Mapped[Optional["Organization"]] = relationship(
        "Organization",
        foreign_keys="User.organization_id",
        back_populates="users"
    )

    owned_organizations: Mapped[List["Organization"]] = relationship(
        "Organization",
        foreign_keys="Organization.owner_id",
        back_populates="owner"
    )

    api_keys: Mapped[List["APIKey"]] = relationship(
        "APIKey", back_populates="user", cascade="all, delete-orphan"
    )

    notifications: Mapped[List["Notification"]] = relationship(
        "Notification", back_populates="user", cascade="all, delete-orphan"
    )

    def __repr__(self) -> str:
        return f"<User(id={self.id}, email={self.email})>"

    @property
    def is_locked(self) -> bool:
        """Check if account is currently locked."""
        if self.locked_until is None:
            return False
        return datetime.utcnow() < self.locked_until

    def get_permissions(self) -> List[str]:
        """Get all permissions for this user from their roles."""
        permissions = set()
        for role in self.roles:
            for permission in role.permissions:
                permissions.add(f"{permission.resource}:{permission.action}")
        return list(permissions)

    @classmethod
    async def get_with_roles_and_permissions(cls, db: AsyncSession, user_id: str):
        """
        Get user with roles and permissions in a single optimized query.

        This method prevents N+1 queries by eagerly loading all related data
        in one database round-trip using selectinload.

        Args:
            db: Database session
            user_id: User ID

        Returns:
            User: User with loaded roles and permissions
        """
        from sqlalchemy import select
        from sqlalchemy.orm import selectinload

        stmt = (
            select(cls)
            .options(selectinload(cls.roles).selectinload(Role.permissions))
            .where(cls.id == user_id)
        )
        result = await db.execute(stmt)
        return result.scalar_one_or_none()

    @classmethod
    async def get_by_email_with_roles(cls, db: AsyncSession, email: str):
        """
        Get user by email with roles and permissions in a single query.

        Optimized for authentication flows to prevent N+1 queries.

        Args:
            db: Database session
            email: User email

        Returns:
            User: User with loaded roles and permissions
        """
        from sqlalchemy import select
        from sqlalchemy.orm import selectinload

        stmt = (
            select(cls)
            .options(selectinload(cls.roles).selectinload(Role.permissions))
            .where(cls.email == email)
        )
        result = await db.execute(stmt)
        return result.scalar_one_or_none()

    @classmethod
    async def get_active_users_with_roles(
        cls, db: AsyncSession, limit: int = 100, offset: int = 0
    ):
        """
        Get active users with their roles in an optimized query.

        Args:
            db: Database session
            limit: Maximum number of users to return
            offset: Number of users to skip

        Returns:
            List[User]: Users with loaded roles
        """
        from sqlalchemy import select
        from sqlalchemy.orm import selectinload

        stmt = (
            select(cls)
            .options(selectinload(cls.roles))
            .where(cls.is_active == True)
            .offset(offset)
            .limit(limit)
            .order_by(cls.created_at.desc())
        )
        result = await db.execute(stmt)
        return result.scalars().all()





class UserRole(Base):
    """
    Association table for User-Role many-to-many relationship.

    Tracks when roles were assigned and by whom for audit purposes.
    """

    __tablename__ = "user_roles"

    id: Mapped[UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid4
    )
    user_id: Mapped[UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
    )
    role_id: Mapped[UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("roles.id", ondelete="CASCADE"),
        nullable=False,
    )

    # Audit fields
    assigned_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    assigned_by: Mapped[Optional[UUID]] = mapped_column(
        UUID(as_uuid=True), ForeignKey("users.id"), nullable=True
    )

    # Relationships
    user: Mapped["User"] = relationship(
        "User", back_populates="user_roles", foreign_keys=[user_id]
    )
    role: Mapped["Role"] = relationship("Role", back_populates="user_roles")
    assigned_by_user: Mapped[Optional["User"]] = relationship(
        "User", foreign_keys=[assigned_by]
    )

    def __repr__(self) -> str:
        return f"<UserRole(user_id={self.user_id}, role_id={self.role_id})>"


class RolePermission(Base):
    """
    Association table for Role-Permission many-to-many relationship.

    Tracks permission assignments to roles.
    """

    __tablename__ = "role_permissions"

    role_id: Mapped[UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("roles.id", ondelete="CASCADE"),
        primary_key=True,
    )
    permission_id: Mapped[UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("permissions.id", ondelete="CASCADE"),
        primary_key=True,
    )

    # Timestamps
    assigned_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )

    # Relationships
    role: Mapped["Role"] = relationship("Role", back_populates="role_permissions")
    permission: Mapped["Permission"] = relationship(
        "Permission", back_populates="role_permissions"
    )

    def __repr__(self) -> str:
        return f"<RolePermission(role_id={self.role_id}, permission_id={self.permission_id})>"
