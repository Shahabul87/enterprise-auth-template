"""
Organization model for multi-tenancy support.
"""

from datetime import datetime
from typing import TYPE_CHECKING, List, Optional
from sqlalchemy import Boolean, Column, DateTime, ForeignKey, String, Text, JSON
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship
import uuid

from app.core.database import Base

if TYPE_CHECKING:
    from app.models.user import User
    from app.models.api_key import APIKey


class Organization(Base):
    """Organization model for multi-tenancy."""

    __tablename__ = "organizations"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
        index=True
    )
    name: Mapped[str] = mapped_column(
        String(100),
        nullable=False,
        index=True
    )
    slug: Mapped[str] = mapped_column(
        String(100),
        unique=True,
        nullable=False,
        index=True,
        comment="URL-friendly unique identifier"
    )
    display_name: Mapped[str] = mapped_column(
        String(150),
        nullable=False
    )
    description: Mapped[Optional[str]] = mapped_column(
        Text,
        nullable=True
    )
    email: Mapped[str] = mapped_column(
        String(255),
        nullable=False
    )
    phone: Mapped[Optional[str]] = mapped_column(
        String(50),
        nullable=True
    )
    website: Mapped[Optional[str]] = mapped_column(
        String(255),
        nullable=True
    )
    logo_url: Mapped[Optional[str]] = mapped_column(
        String(500),
        nullable=True
    )

    # Organization settings
    settings: Mapped[Optional[dict]] = mapped_column(
        JSON,
        nullable=True,
        default=dict,
        comment="Organization-specific settings"
    )

    # Subscription/Plan information
    plan_type: Mapped[str] = mapped_column(
        String(50),
        default="free",
        nullable=False,
        comment="Subscription plan type"
    )
    max_users: Mapped[int] = mapped_column(
        default=5,
        nullable=False,
        comment="Maximum allowed users"
    )
    max_api_keys: Mapped[int] = mapped_column(
        default=2,
        nullable=False,
        comment="Maximum allowed API keys"
    )

    # Status
    is_active: Mapped[bool] = mapped_column(
        Boolean,
        default=True,
        nullable=False,
        index=True
    )
    is_verified: Mapped[bool] = mapped_column(
        Boolean,
        default=False,
        nullable=False,
        comment="Email verification status"
    )

    # Owner
    owner_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id"),
        nullable=False
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
    verified_at: Mapped[Optional[datetime]] = mapped_column(
        DateTime,
        nullable=True
    )

    # Relationships
    owner: Mapped["User"] = relationship(
        "User",
        foreign_keys=[owner_id],
        back_populates="owned_organizations"
    )

    users: Mapped[List["User"]] = relationship(
        "User",
        foreign_keys="User.organization_id",
        back_populates="organization",
        lazy="dynamic"
    )

    api_keys: Mapped[List["APIKey"]] = relationship(
        "APIKey",
        back_populates="organization",
        cascade="all, delete-orphan"
    )

    def __repr__(self) -> str:
        return f"<Organization {self.slug}>"

    def can_add_user(self) -> bool:
        """Check if organization can add more users."""
        current_user_count = len(list(self.users))  # type: ignore
        return current_user_count < self.max_users

    def get_user_count(self) -> int:
        """Get current user count."""
        return len(list(self.users))  # type: ignore

    def is_owner(self, user_id: uuid.UUID) -> bool:
        """Check if user is the organization owner."""
        return self.owner_id == user_id

    def to_dict(self) -> dict:
        """Convert organization to dictionary."""
        return {
            "id": str(self.id),
            "name": self.name,
            "slug": self.slug,
            "display_name": self.display_name,
            "description": self.description,
            "email": self.email,
            "phone": self.phone,
            "website": self.website,
            "logo_url": self.logo_url,
            "plan_type": self.plan_type,
            "max_users": self.max_users,
            "max_api_keys": self.max_api_keys,
            "is_active": self.is_active,
            "is_verified": self.is_verified,
            "owner_id": str(self.owner_id),
            "user_count": self.get_user_count(),
            "created_at": self.created_at.isoformat(),
            "updated_at": self.updated_at.isoformat(),
            "verified_at": self.verified_at.isoformat() if self.verified_at else None
        }


class PlanTypes:
    """Organization plan types."""
    FREE = "free"
    STARTER = "starter"
    PROFESSIONAL = "professional"
    ENTERPRISE = "enterprise"

    @classmethod
    def get_all(cls) -> List[str]:
        """Get all plan types."""
        return [cls.FREE, cls.STARTER, cls.PROFESSIONAL, cls.ENTERPRISE]

    @classmethod
    def get_limits(cls, plan_type: str) -> dict:
        """Get limits for a plan type."""
        limits = {
            cls.FREE: {"max_users": 5, "max_api_keys": 2},
            cls.STARTER: {"max_users": 20, "max_api_keys": 5},
            cls.PROFESSIONAL: {"max_users": 100, "max_api_keys": 20},
            cls.ENTERPRISE: {"max_users": -1, "max_api_keys": -1},  # -1 means unlimited
        }
        return limits.get(plan_type, limits[cls.FREE])
