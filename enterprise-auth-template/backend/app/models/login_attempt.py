"""
Login attempt model for tracking authentication attempts
"""

from typing import Optional
from uuid import uuid4
from sqlalchemy import Column, String, Boolean, DateTime, Integer, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy.sql import func
from datetime import datetime

from app.core.database import Base


class LoginAttempt(Base):
    """Model for tracking login attempts for security monitoring"""

    __tablename__ = "login_attempts"

    id: Mapped[UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid4, index=True
    )
    user_id: Mapped[Optional[UUID]] = mapped_column(
        UUID(as_uuid=True), ForeignKey("users.id"), nullable=True, index=True
    )  # Null if user not found
    email: Mapped[str] = mapped_column(String(255), nullable=False, index=True)
    success: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    ip_address: Mapped[Optional[str]] = mapped_column(String(45), nullable=True)
    user_agent: Mapped[Optional[str]] = mapped_column(String(500), nullable=True)
    failure_reason: Mapped[Optional[str]] = mapped_column(
        String(100), nullable=True
    )  # wrong_password, account_locked, etc.
    attempt_number: Mapped[int] = mapped_column(Integer, default=1)  # Track consecutive attempts
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False, index=True
    )

    # Relationships
    user = relationship("User", backref="login_attempts", foreign_keys=[user_id])

    def __repr__(self):
        return f"<LoginAttempt(id='{self.id}', email='{self.email}', success={self.success})>"

    @classmethod
    def create_attempt(
        cls,
        email: str,
        success: bool,
        ip_address: Optional[str] = None,
        user_agent: Optional[str] = None,
        user_id: Optional[UUID] = None,
        failure_reason: Optional[str] = None,
    ):
        """Create a new login attempt record"""
        return cls(
            email=email,
            success=success,
            ip_address=ip_address,
            user_agent=user_agent,
            user_id=user_id,
            failure_reason=failure_reason,
        )
