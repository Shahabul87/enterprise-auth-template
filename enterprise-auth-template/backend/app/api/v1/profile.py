"""
User Profile Endpoints

Handles user profile operations including profile updates,
password changes, security settings, and account preferences.
"""

from typing import Dict, List, Optional, Any
from datetime import datetime

import structlog
from fastapi import APIRouter, Depends, HTTPException, Request, status
from pydantic import BaseModel, Field, EmailStr, ConfigDict
from sqlalchemy import select, update
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db_session
from app.dependencies.auth import CurrentUser, get_current_user
from app.models.user import User

# Import new refactored services
from app.services.auth.password_management_service import PasswordManagementService
from app.services.auth.email_verification_service import EmailVerificationService
from app.repositories.user_repository import UserRepository
from app.core.security import verify_password, get_password_hash
from app.services.user.user_crud_service import UserCRUDService
from app.services.notification_service import NotificationService
from app.services.audit_service import AuditService

logger = structlog.get_logger(__name__)

router = APIRouter()


class ProfileResponse(BaseModel):
    """User profile response model."""

    id: str = Field(..., description="User ID")
    email: str = Field(..., description="User email")
    full_name: str = Field(..., description="Full name")
    phone_number: Optional[str] = Field(None, description="Phone number")
    bio: Optional[str] = Field(None, description="User bio")
    avatar_url: Optional[str] = Field(None, description="Avatar image URL")
    timezone: Optional[str] = Field(None, description="User timezone")
    language: Optional[str] = Field(None, description="Preferred language")
    is_active: bool = Field(..., description="Account is active")
    is_verified: bool = Field(..., description="Email is verified")
    roles: List[str] = Field(..., description="User roles")
    created_at: str = Field(..., description="Account creation timestamp")
    updated_at: str = Field(..., description="Last profile update timestamp")
    last_login: Optional[str] = Field(None, description="Last login timestamp")


class ProfileUpdateRequest(BaseModel):
    """Profile update request model."""

    full_name: Optional[str] = Field(
        None, min_length=2, max_length=100, description="Full name"
    )
    phone_number: Optional[str] = Field(None, max_length=20, description="Phone number")
    bio: Optional[str] = Field(None, max_length=500, description="User bio")
    timezone: Optional[str] = Field(None, description="User timezone")
    language: Optional[str] = Field(None, description="Preferred language")

    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "full_name": "John Doe",
                "phone_number": "+1234567890",
                "bio": "Software developer with 5 years of experience",
                "timezone": "America/New_York",
                "language": "en",
            }
        }
    )


class PasswordChangeRequest(BaseModel):
    """Password change request model."""

    current_password: str = Field(..., min_length=8, description="Current password")
    new_password: str = Field(..., min_length=8, description="New password")

    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "current_password": "CurrentPass123!",
                "new_password": "NewSecurePass456!",
            }
        }
    )


class EmailChangeRequest(BaseModel):
    """Email change request model."""

    new_email: EmailStr = Field(..., description="New email address")
    password: str = Field(..., description="Current password for verification")

    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "new_email": "newemail@example.com",
                "password": "CurrentPass123!",
            }
        }
    )


class NotificationPreferencesRequest(BaseModel):
    """Notification preferences update request."""

    email_notifications: bool = Field(True, description="Enable email notifications")
    push_notifications: bool = Field(True, description="Enable push notifications")
    sms_notifications: bool = Field(False, description="Enable SMS notifications")
    marketing_emails: bool = Field(False, description="Enable marketing emails")
    security_alerts: bool = Field(True, description="Enable security alerts")

    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "email_notifications": True,
                "push_notifications": True,
                "sms_notifications": False,
                "marketing_emails": False,
                "security_alerts": True,
            }
        }
    )


class SecuritySettingsResponse(BaseModel):
    """Security settings response model."""

    two_factor_enabled: bool = Field(
        ..., description="Two-factor authentication enabled"
    )
    login_alerts: bool = Field(..., description="Login alerts enabled")
    session_timeout: int = Field(..., description="Session timeout in minutes")
    password_last_changed: Optional[str] = Field(
        None, description="Last password change"
    )
    active_sessions: int = Field(..., description="Number of active sessions")


class MessageResponse(BaseModel):
    """Generic message response model."""

    message: str = Field(..., description="Response message")


@router.get("/me", response_model=ProfileResponse)
async def get_profile(
    current_user: CurrentUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db_session),
) -> ProfileResponse:
    """
    Get current user profile.

    Retrieves complete profile information for the authenticated user
    including personal details, preferences, and account status.

    Returns:
        ProfileResponse: User profile information
    """
    logger.info("Profile requested", user_id=current_user.id)

    try:
        # Get full user data from database
        stmt = select(User).where(User.id == current_user.id)
        result = await db.execute(stmt)
        user = result.scalar_one_or_none()

        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND, detail="User not found"
            )

        return ProfileResponse(
            id=str(user.id),
            email=user.email,
            full_name=user.full_name,
            phone_number=getattr(user, "phone_number", None),
            bio=getattr(user, "bio", None),
            avatar_url=getattr(user, "avatar_url", None),
            timezone=getattr(user, "timezone", None),
            language=getattr(user, "language", "en"),
            is_active=user.is_active,
            is_verified=user.email_verified,  # Fix: use email_verified instead of is_verified
            roles=current_user.roles,
            created_at=user.created_at.isoformat() if user.created_at else "",
            updated_at=user.updated_at.isoformat() if user.updated_at else "",
            last_login=user.last_login.isoformat() if user.last_login else None,
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error("Failed to get profile", user_id=current_user.id, error=str(e))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to retrieve profile",
        )


@router.put("/me", response_model=ProfileResponse)
async def update_profile(
    profile_update: ProfileUpdateRequest,
    current_user: CurrentUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db_session),
    request: Request = None,
) -> ProfileResponse:
    """
    Update current user profile.

    Updates the authenticated user's profile information with
    audit logging and notification of changes.

    Args:
        profile_update: Profile update data
        current_user: Current authenticated user
        db: Database session
        request: FastAPI request object

    Returns:
        ProfileResponse: Updated profile information
    """
    logger.info("Profile update requested", user_id=current_user.id)

    try:
        user_service = UserCRUDService(db)
        audit_service = AuditService(db)

        # Build update data dictionary
        update_data = {}
        if profile_update.full_name is not None:
            update_data["full_name"] = profile_update.full_name
        if profile_update.phone_number is not None:
            update_data["phone_number"] = profile_update.phone_number
        if profile_update.bio is not None:
            update_data["bio"] = profile_update.bio
        if profile_update.timezone is not None:
            update_data["timezone"] = profile_update.timezone
        if profile_update.language is not None:
            update_data["language"] = profile_update.language

        if not update_data:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="No update data provided",
            )

        # Update user profile
        updated_user = await user_service.update_user_profile(
            user_id=current_user.id, update_data=update_data
        )

        # Log audit event
        await audit_service.log_event(
            user_id=current_user.id,
            action="profile.update",
            resource_type="user_profile",
            resource_id=current_user.id,
            details={
                "updated_fields": list(update_data.keys()),
                "ip_address": (
                    request.client.host if request and request.client else None
                ),
            },
        )

        logger.info(
            "Profile updated successfully",
            user_id=current_user.id,
            updated_fields=list(update_data.keys()),
        )

        return ProfileResponse(
            id=str(updated_user.id),
            email=updated_user.email,
            full_name=updated_user.full_name,
            phone_number=getattr(updated_user, "phone_number", None),
            bio=getattr(updated_user, "bio", None),
            avatar_url=getattr(updated_user, "avatar_url", None),
            timezone=getattr(updated_user, "timezone", None),
            language=getattr(updated_user, "language", "en"),
            is_active=updated_user.is_active,
            is_verified=updated_user.email_verified,  # Fix: use email_verified instead of is_verified
            roles=current_user.roles,
            created_at=(
                updated_user.created_at.isoformat() if updated_user.created_at else ""
            ),
            updated_at=(
                updated_user.updated_at.isoformat() if updated_user.updated_at else ""
            ),
            last_login=(
                updated_user.last_login.isoformat() if updated_user.last_login else None
            ),
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error("Failed to update profile", user_id=current_user.id, error=str(e))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to update profile",
        )


@router.post("/change-password", response_model=MessageResponse)
async def change_password(
    password_change: PasswordChangeRequest,
    current_user: CurrentUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db_session),
    request: Request = None,
) -> MessageResponse:
    """
    Change user password.

    Changes the authenticated user's password with current password verification,
    security validation, and audit logging.

    Args:
        password_change: Password change request data
        current_user: Current authenticated user
        db: Database session
        request: FastAPI request object

    Returns:
        MessageResponse: Success message
    """
    logger.info("Password change requested", user_id=current_user.id)

    try:
        # Use new password management service
        user_repo = UserRepository(db)
        password_service = PasswordManagementService(db, user_repo)
        audit_service = AuditService(db)
        notification_service = NotificationService(db)

        # Verify current password
        stmt = select(User).where(User.id == current_user.id)
        result = await db.execute(stmt)
        user = result.scalar_one_or_none()

        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND, detail="User not found"
            )

        # Verify current password
        if not verify_password(
            password_change.current_password, user.password_hash or user.hashed_password
        ):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Current password is incorrect",
            )

        # Validate new password strength
        await password_service.validate_password_strength(password_change.new_password)

        # Update password
        new_password_hash = get_password_hash(password_change.new_password)

        stmt = (
            update(User)
            .where(User.id == current_user.id)
            .values(
                password_hash=new_password_hash,
                password_changed_at=datetime.utcnow(),
                updated_at=datetime.utcnow(),
            )
        )
        await db.execute(stmt)
        await db.commit()

        # Log audit event
        await audit_service.log_event(
            user_id=current_user.id,
            action="password.change",
            resource_type="user_account",
            resource_id=current_user.id,
            details={
                "ip_address": (
                    request.client.host if request and request.client else None
                ),
                "user_agent": request.headers.get("user-agent") if request else None,
            },
        )

        # Send security notification
        await notification_service.send_security_notification(
            user_id=current_user.id,
            event_type="password_changed",
            details={
                "timestamp": datetime.utcnow().isoformat(),
                "ip_address": (
                    request.client.host if request and request.client else None
                ),
            },
        )

        logger.info("Password changed successfully", user_id=current_user.id)

        return MessageResponse(message="Password changed successfully")

    except HTTPException:
        raise
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))
    except Exception as e:
        logger.error("Failed to change password", user_id=current_user.id, error=str(e))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to change password",
        )


@router.post("/change-email", response_model=MessageResponse)
async def change_email(
    email_change: EmailChangeRequest,
    current_user: CurrentUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db_session),
    request: Request = None,
) -> MessageResponse:
    """
    Request email address change.

    Initiates email address change process with password verification
    and email confirmation to both old and new addresses.

    Args:
        email_change: Email change request data
        current_user: Current authenticated user
        db: Database session
        request: FastAPI request object

    Returns:
        MessageResponse: Success message
    """
    logger.info(
        "Email change requested",
        user_id=current_user.id,
        new_email=email_change.new_email,
    )

    try:
        # Use new password management service
        user_repo = UserRepository(db)
        password_service = PasswordManagementService(db, user_repo)
        user_service = UserCRUDService(db)
        audit_service = AuditService(db)

        # Verify password
        stmt = select(User).where(User.id == current_user.id)
        result = await db.execute(stmt)
        user = result.scalar_one_or_none()

        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND, detail="User not found"
            )

        if not verify_password(
            email_change.password, user.password_hash or user.hashed_password
        ):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST, detail="Password is incorrect"
            )

        # Check if new email is already in use
        existing_user = await user_service.get_user_by_email(email_change.new_email)
        if existing_user and existing_user.id != current_user.id:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Email address is already in use",
            )

        # Initiate email change process (would send verification emails)
        # Use email verification service for email change
        email_service = EmailVerificationService(db, user_repo)
        await email_service.initiate_email_change(
            user_id=current_user.id,
            new_email=email_change.new_email,
            ip_address=request.client.host if request and request.client else None,
        )

        # Log audit event
        await audit_service.log_event(
            user_id=current_user.id,
            action="email.change_requested",
            resource_type="user_account",
            resource_id=current_user.id,
            details={
                "old_email": user.email,
                "new_email": email_change.new_email,
                "ip_address": (
                    request.client.host if request and request.client else None
                ),
            },
        )

        logger.info("Email change initiated", user_id=current_user.id)

        return MessageResponse(
            message="Email change verification sent. Please check both your current and new email addresses."
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error("Failed to change email", user_id=current_user.id, error=str(e))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to initiate email change",
        )


@router.get("/security", response_model=SecuritySettingsResponse)
async def get_security_settings(
    current_user: CurrentUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db_session),
) -> SecuritySettingsResponse:
    """
    Get user security settings.

    Retrieves security-related settings and status for the authenticated user
    including 2FA status, session information, and security preferences.

    Returns:
        SecuritySettingsResponse: Security settings information
    """
    logger.info("Security settings requested", user_id=current_user.id)

    try:
        user_service = UserCRUDService(db)

        # Get user security information
        security_info = await user_service.get_user_security_info(current_user.id)

        return SecuritySettingsResponse(
            two_factor_enabled=security_info.get("two_factor_enabled", False),
            login_alerts=security_info.get("login_alerts", True),
            session_timeout=security_info.get("session_timeout", 30),
            password_last_changed=security_info.get("password_last_changed"),
            active_sessions=security_info.get("active_sessions", 1),
        )

    except Exception as e:
        logger.error(
            "Failed to get security settings", user_id=current_user.id, error=str(e)
        )
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to retrieve security settings",
        )


@router.put("/notifications", response_model=MessageResponse)
async def update_notification_preferences(
    preferences: NotificationPreferencesRequest,
    current_user: CurrentUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db_session),
) -> MessageResponse:
    """
    Update notification preferences.

    Updates the authenticated user's notification preferences across
    different channels and event types.

    Args:
        preferences: Notification preferences data
        current_user: Current authenticated user
        db: Database session

    Returns:
        MessageResponse: Success message
    """
    logger.info("Notification preferences update requested", user_id=current_user.id)

    try:
        user_service = UserCRUDService(db)

        # Update notification preferences
        await user_service.update_notification_preferences(
            user_id=current_user.id, preferences=preferences.dict()
        )

        logger.info("Notification preferences updated", user_id=current_user.id)

        return MessageResponse(message="Notification preferences updated successfully")

    except Exception as e:
        logger.error(
            "Failed to update notification preferences",
            user_id=current_user.id,
            error=str(e),
        )
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to update notification preferences",
        )


@router.delete("/me", response_model=MessageResponse)
async def delete_account(
    password: str,
    current_user: CurrentUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db_session),
    request: Request = None,
) -> MessageResponse:
    """
    Delete user account.

    Permanently deletes the authenticated user's account with password
    verification and proper cleanup of associated data.

    Args:
        password: Current password for verification
        current_user: Current authenticated user
        db: Database session
        request: FastAPI request object

    Returns:
        MessageResponse: Success message
    """
    logger.warning("Account deletion requested", user_id=current_user.id)

    try:
        # Use new password management service
        user_repo = UserRepository(db)
        password_service = PasswordManagementService(db, user_repo)
        user_service = UserCRUDService(db)
        audit_service = AuditService(db)

        # Verify password
        stmt = select(User).where(User.id == current_user.id)
        result = await db.execute(stmt)
        user = result.scalar_one_or_none()

        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND, detail="User not found"
            )

        if not verify_password(password, user.password_hash or user.hashed_password):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST, detail="Password is incorrect"
            )

        # Log audit event before deletion
        await audit_service.log_event(
            user_id=current_user.id,
            action="account.delete",
            resource_type="user_account",
            resource_id=current_user.id,
            details={
                "ip_address": (
                    request.client.host if request and request.client else None
                ),
                "user_agent": request.headers.get("user-agent") if request else None,
            },
        )

        # Delete user account (this would handle cleanup)
        await user_service.delete_user_account(current_user.id)

        logger.warning("Account deleted", user_id=current_user.id)

        return MessageResponse(message="Account deleted successfully")

    except HTTPException:
        raise
    except Exception as e:
        logger.error("Failed to delete account", user_id=current_user.id, error=str(e))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to delete account",
        )
