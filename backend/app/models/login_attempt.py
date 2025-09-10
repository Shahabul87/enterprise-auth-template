"""
Login Attempt Model

Tracks authentication attempts for security monitoring and analysis.
Provides detailed logging of successful and failed login attempts.
"""

from datetime import datetime
from typing import TYPE_CHECKING, Optional
from uuid import uuid4

from sqlalchemy import (
    Boolean,
    DateTime,
    ForeignKey,
    Integer,
    String,
    Text,
)
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy.sql import func

from app.core.database import Base

if TYPE_CHECKING:
    from app.models.user import User


class LoginAttempt(Base):
    """
    Login attempt model for tracking authentication attempts.

    Stores detailed information about both successful and failed login attempts
    for security monitoring, rate limiting, and fraud detection.
    """

    __tablename__ = "login_attempts"

    # Primary key
    id: Mapped[UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid4, index=True
    )

    # User identification
    user_id: Mapped[Optional[UUID]] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="SET NULL"),
        nullable=True,
        index=True,
    )
    email: Mapped[str] = mapped_column(
        String(255), nullable=False, index=True
    )  # Email attempted regardless of user existence

    # Attempt details
    success: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    attempt_type: Mapped[str] = mapped_column(
        String(50), default="password", nullable=False, index=True
    )  # password, oauth, magic_link, 2fa, etc.
    
    # Network information
    ip_address: Mapped[Optional[str]] = mapped_column(String(45), nullable=True, index=True)  # IPv6 support
    user_agent: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    country_code: Mapped[Optional[str]] = mapped_column(String(2), nullable=True)
    city: Mapped[Optional[str]] = mapped_column(String(100), nullable=True)
    
    # Device information
    device_type: Mapped[Optional[str]] = mapped_column(String(50), nullable=True)  # mobile, desktop, tablet
    device_os: Mapped[Optional[str]] = mapped_column(String(50), nullable=True)
    browser: Mapped[Optional[str]] = mapped_column(String(50), nullable=True)
    
    # Failure analysis
    failure_reason: Mapped[Optional[str]] = mapped_column(
        String(100), nullable=True, index=True
    )  # wrong_password, account_locked, user_not_found, 2fa_failed, etc.
    failure_details: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    
    # Security metrics
    attempt_number: Mapped[int] = mapped_column(
        Integer, default=1, nullable=False
    )  # Consecutive attempts from same IP/user
    is_suspicious: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    risk_score: Mapped[Optional[int]] = mapped_column(
        Integer, nullable=True
    )  # 0-100 risk assessment
    blocked_by_rate_limit: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    
    # OAuth/External provider info
    oauth_provider: Mapped[Optional[str]] = mapped_column(String(50), nullable=True)
    oauth_provider_id: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)
    
    # Session information
    session_id: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)
    fingerprint_hash: Mapped[Optional[str]] = mapped_column(String(64), nullable=True)  # Device fingerprint
    
    # Metadata
    metadata_json: Mapped[Optional[dict]] = mapped_column(
        JSONB, nullable=True, default=dict
    )  # Additional context data
    
    # Timestamps
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False, index=True
    )
    processed_at: Mapped[Optional[datetime]] = mapped_column(
        DateTime(timezone=True), nullable=True
    )  # When security analysis was completed

    # Relationships
    user: Mapped[Optional["User"]] = relationship(
        "User",
        back_populates="login_attempts",
        foreign_keys=[user_id],
        lazy="selectin"
    )

    def __repr__(self) -> str:
        return f"<LoginAttempt(id={self.id}, email={self.email}, success={self.success})>"

    @property
    def is_failed_attempt(self) -> bool:
        """Check if this was a failed login attempt."""
        return not self.success

    @property
    def is_password_attempt(self) -> bool:
        """Check if this was a password-based login attempt."""
        return self.attempt_type == "password"

    @property
    def is_oauth_attempt(self) -> bool:
        """Check if this was an OAuth login attempt."""
        return self.attempt_type == "oauth"

    @property
    def is_high_risk(self) -> bool:
        """Check if this attempt is considered high risk."""
        return self.risk_score is not None and self.risk_score >= 70

    @property
    def duration_since_attempt(self) -> Optional[int]:
        """Get seconds since the attempt was made."""
        if self.created_at:
            return int((datetime.utcnow() - self.created_at.replace(tzinfo=None)).total_seconds())
        return None

    @classmethod
    def create_attempt(
        cls,
        email: str,
        success: bool,
        attempt_type: str = "password",
        ip_address: Optional[str] = None,
        user_agent: Optional[str] = None,
        user_id: Optional[UUID] = None,
        failure_reason: Optional[str] = None,
        failure_details: Optional[str] = None,
        oauth_provider: Optional[str] = None,
        session_id: Optional[str] = None,
        metadata: Optional[dict] = None,
    ) -> "LoginAttempt":
        """
        Create a new login attempt record.
        
        Args:
            email: Email address used for login
            success: Whether the login was successful
            attempt_type: Type of login attempt (password, oauth, etc.)
            ip_address: Client IP address
            user_agent: Client user agent
            user_id: User ID if user exists
            failure_reason: Reason for failure if applicable
            failure_details: Additional failure details
            oauth_provider: OAuth provider if applicable
            session_id: Session ID if applicable
            metadata: Additional metadata
            
        Returns:
            LoginAttempt: New login attempt instance
        """
        return cls(
            email=email,
            success=success,
            attempt_type=attempt_type,
            ip_address=ip_address,
            user_agent=user_agent,
            user_id=user_id,
            failure_reason=failure_reason,
            failure_details=failure_details,
            oauth_provider=oauth_provider,
            session_id=session_id,
            metadata_json=metadata or {},
            created_at=datetime.utcnow(),
        )

    def mark_as_processed(self, risk_score: Optional[int] = None) -> None:
        """
        Mark the login attempt as processed by security analysis.
        
        Args:
            risk_score: Calculated risk score (0-100)
        """
        self.processed_at = datetime.utcnow()
        if risk_score is not None:
            self.risk_score = risk_score
            self.is_suspicious = risk_score >= 50

    def add_security_flags(
        self,
        is_suspicious: bool = False,
        blocked_by_rate_limit: bool = False,
        risk_score: Optional[int] = None,
    ) -> None:
        """
        Add security analysis flags to the login attempt.
        
        Args:
            is_suspicious: Whether the attempt is considered suspicious
            blocked_by_rate_limit: Whether blocked by rate limiting
            risk_score: Risk assessment score (0-100)
        """
        self.is_suspicious = is_suspicious
        self.blocked_by_rate_limit = blocked_by_rate_limit
        if risk_score is not None:
            self.risk_score = risk_score

    def add_device_info(
        self,
        device_type: Optional[str] = None,
        device_os: Optional[str] = None,
        browser: Optional[str] = None,
        fingerprint_hash: Optional[str] = None,
    ) -> None:
        """
        Add device information to the login attempt.
        
        Args:
            device_type: Type of device (mobile, desktop, tablet)
            device_os: Operating system
            browser: Browser name
            fingerprint_hash: Device fingerprint hash
        """
        if device_type:
            self.device_type = device_type
        if device_os:
            self.device_os = device_os
        if browser:
            self.browser = browser
        if fingerprint_hash:
            self.fingerprint_hash = fingerprint_hash

    def add_location_info(
        self, country_code: Optional[str] = None, city: Optional[str] = None
    ) -> None:
        """
        Add location information to the login attempt.
        
        Args:
            country_code: ISO 2-letter country code
            city: City name
        """
        if country_code:
            self.country_code = country_code
        if city:
            self.city = city

    def to_dict(
        self,
        include_user: bool = False,
        include_sensitive: bool = False,
        include_metadata: bool = True,
    ) -> dict:
        """
        Convert login attempt to dictionary.
        
        Args:
            include_user: Whether to include user information
            include_sensitive: Whether to include sensitive data
            include_metadata: Whether to include metadata
            
        Returns:
            dict: Login attempt data
        """
        data = {
            "id": str(self.id),
            "email": self.email,
            "success": self.success,
            "attempt_type": self.attempt_type,
            "failure_reason": self.failure_reason,
            "attempt_number": self.attempt_number,
            "is_suspicious": self.is_suspicious,
            "blocked_by_rate_limit": self.blocked_by_rate_limit,
            "created_at": self.created_at.isoformat(),
        }

        # Add processed information
        if self.processed_at:
            data["processed_at"] = self.processed_at.isoformat()
        if self.risk_score is not None:
            data["risk_score"] = self.risk_score

        # Add location info if available
        if self.country_code:
            data["country_code"] = self.country_code
        if self.city:
            data["city"] = self.city

        # Add device info if available
        if self.device_type:
            data["device_type"] = self.device_type
        if self.device_os:
            data["device_os"] = self.device_os
        if self.browser:
            data["browser"] = self.browser

        # Add OAuth info if applicable
        if self.oauth_provider:
            data["oauth_provider"] = self.oauth_provider

        # Include sensitive data if requested
        if include_sensitive:
            data.update({
                "ip_address": self.ip_address,
                "user_agent": self.user_agent,
                "failure_details": self.failure_details,
                "session_id": self.session_id,
                "fingerprint_hash": self.fingerprint_hash,
            })

        # Include user info if requested and available
        if include_user and self.user:
            data["user"] = {
                "id": str(self.user.id),
                "email": self.user.email,
                "full_name": getattr(self.user, 'full_name', None),
                "is_active": getattr(self.user, 'is_active', None),
            }
        elif self.user_id:
            data["user_id"] = str(self.user_id)

        # Include metadata if requested
        if include_metadata and self.metadata_json:
            data["metadata"] = self.metadata_json

        # Add computed properties
        data.update({
            "is_failed_attempt": self.is_failed_attempt,
            "is_password_attempt": self.is_password_attempt,
            "is_oauth_attempt": self.is_oauth_attempt,
            "is_high_risk": self.is_high_risk,
            "duration_since_attempt": self.duration_since_attempt,
        })

        return data

    def to_security_dict(self) -> dict:
        """
        Convert to dictionary with security-focused information.
        
        Returns:
            dict: Security-relevant data for monitoring
        """
        return {
            "id": str(self.id),
            "email": self.email,
            "success": self.success,
            "attempt_type": self.attempt_type,
            "ip_address": self.ip_address,
            "failure_reason": self.failure_reason,
            "attempt_number": self.attempt_number,
            "is_suspicious": self.is_suspicious,
            "risk_score": self.risk_score,
            "blocked_by_rate_limit": self.blocked_by_rate_limit,
            "country_code": self.country_code,
            "city": self.city,
            "device_type": self.device_type,
            "created_at": self.created_at.isoformat(),
            "duration_since_attempt": self.duration_since_attempt,
        }

    def __str__(self) -> str:
        status = "SUCCESS" if self.success else "FAILED"
        return f"{status} login attempt for {self.email} from {self.ip_address or 'unknown'}"