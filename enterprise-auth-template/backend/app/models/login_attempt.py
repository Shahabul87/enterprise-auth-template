"""
Login attempt model for tracking authentication attempts
"""
from typing import Optional
from sqlalchemy import Column, String, Boolean, DateTime, Integer, ForeignKey
from sqlalchemy.orm import relationship
from datetime import datetime
import uuid

from app.core.database import Base

class LoginAttempt(Base):
    """Model for tracking login attempts for security monitoring"""
    __tablename__ = "login_attempts"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String, ForeignKey("users.id"), nullable=True)  # Null if user not found
    email = Column(String, nullable=False, index=True)
    success = Column(Boolean, default=False, nullable=False)
    ip_address = Column(String, nullable=True)
    user_agent = Column(String, nullable=True)
    failure_reason = Column(String, nullable=True)  # wrong_password, account_locked, etc.
    attempt_number = Column(Integer, default=1)  # Track consecutive attempts
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False, index=True)

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
        user_id: Optional[str] = None,
        failure_reason: Optional[str] = None
    ):
        """Create a new login attempt record"""
        return cls(
            email=email,
            success=success,
            ip_address=ip_address,
            user_agent=user_agent,
            user_id=user_id,
            failure_reason=failure_reason,
            created_at=datetime.utcnow()
        )
