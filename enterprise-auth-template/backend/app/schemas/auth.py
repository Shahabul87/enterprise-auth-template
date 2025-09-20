"""
Authentication Schemas

Pydantic models for authentication-related API requests and responses.
"""

import re
from enum import Enum
from typing import Optional

from pydantic import BaseModel, EmailStr, Field, field_validator, ConfigDict
from .response import StandardResponse, ErrorCodes


class LoginRequest(BaseModel):
    """User login credentials."""

    email: EmailStr = Field(..., description="User email address")
    password: str = Field(..., min_length=1, description="User password")
    remember_me: bool = Field(
        False, description="Keep user logged in for extended period"
    )

    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "email": "user@example.com",
                "password": "SecurePassword123!",
                "remember_me": False,
            }
        }
    )


class RegisterRequest(BaseModel):
    """User registration data - matches Flutter expectations."""

    email: EmailStr = Field(..., description="User email address")
    password: str = Field(..., min_length=8, description="User password")
    full_name: str = Field(..., min_length=2, max_length=100, description="Full name")
    confirm_password: Optional[str] = Field(None, description="Password confirmation")
    agree_to_terms: Optional[bool] = Field(
        True, description="Agreement to terms and conditions"
    )

    @field_validator("password")
    @classmethod
    def validate_password_strength(cls, v: str) -> str:
        """Validate password meets security requirements."""
        if len(v) < 8:
            raise ValueError("Password must be at least 8 characters long")

        if not re.search(r"[A-Z]", v):
            raise ValueError("Password must contain at least one uppercase letter")

        if not re.search(r"[a-z]", v):
            raise ValueError("Password must contain at least one lowercase letter")

        if not re.search(r"\d", v):
            raise ValueError("Password must contain at least one digit")

        if not re.search(r'[!@#$%^&*(),.?":{}|<>]', v):
            raise ValueError("Password must contain at least one special character")

        return v

    @field_validator("confirm_password")
    @classmethod
    def passwords_match(cls, v: str, info) -> str:
        """Validate password confirmation matches password."""
        if hasattr(info, "data") and info.data and "password" in info.data:
            if v != info.data["password"]:
                raise ValueError("Passwords do not match")
        return v

    @field_validator("agree_to_terms")
    @classmethod
    def validate_terms_agreement(cls, v: bool) -> bool:
        """Validate user agreed to terms."""
        if not v:
            raise ValueError("You must agree to the terms and conditions")
        return v

    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "email": "newuser@example.com",
                "password": "SecurePassword123!",
                "confirm_password": "SecurePassword123!",
                "full_name": "John Doe",
                "agree_to_terms": True,
            }
        }
    )


class UserResponse(BaseModel):
    """User information response - matches Flutter User entity."""

    id: str = Field(..., description="User ID")
    email: str = Field(..., description="User email address")
    full_name: str = Field(..., description="Full name")
    name: str = Field(..., description="Display name for Flutter compatibility")
    profile_picture: Optional[str] = Field(
        None, description="Profile picture URL", alias="profilePicture"
    )
    email_verified: bool = Field(
        ..., description="Whether email is verified", alias="isEmailVerified"
    )
    two_factor_enabled: bool = Field(
        False, description="Whether 2FA is enabled", alias="isTwoFactorEnabled"
    )
    roles: list[str] = Field(default_factory=list, description="User roles")
    permissions: list[str] = Field(default_factory=list, description="User permissions")
    created_at: str = Field(
        ..., description="Account creation timestamp", alias="createdAt"
    )
    updated_at: str = Field(..., description="Last update timestamp", alias="updatedAt")
    last_login_at: Optional[str] = Field(
        None, description="Last login timestamp", alias="lastLoginAt"
    )
    is_active: bool = Field(True, description="Whether user account is active")

    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "id": "123e4567-e89b-12d3-a456-426614174000",
                "email": "user@example.com",
                "full_name": "John Doe",
                "name": "John Doe",
                "email_verified": False,
                "two_factor_enabled": False,
                "is_active": True,
                "roles": ["user"],
                "permissions": ["user:read"],
                "created_at": "2024-01-01T00:00:00Z",
                "updated_at": "2024-01-01T00:00:00Z",
                "last_login_at": "2024-01-01T12:00:00Z",
            }
        }
    )

    @classmethod
    def from_db_user(cls, user, roles: list = None, permissions: list = None):
        """Create UserResponse from database User model."""
        # Compute display name
        display_name = user.full_name
        if not display_name:
            display_name = user.email.split("@")[0]  # Fallback to email username

        return cls(
            id=str(user.id),
            email=user.email,
            full_name=user.full_name,
            name=display_name,
            profile_picture=user.avatar_url,
            email_verified=user.email_verified,
            two_factor_enabled=user.two_factor_enabled,
            roles=roles or [],
            permissions=permissions or [],
            created_at=(
                user.created_at.isoformat()
                if hasattr(user, "created_at") and user.created_at
                else ""
            ),
            updated_at=(
                user.updated_at.isoformat()
                if hasattr(user, "updated_at") and user.updated_at
                else ""
            ),
            last_login_at=(
                user.last_login.isoformat()
                if hasattr(user, "last_login") and user.last_login
                else None
            ),
            is_active=user.is_active,
        )


class AuthResponseData(BaseModel):
    """Authentication response data that matches Flutter expectations."""

    user: UserResponse = Field(..., description="User information")
    access_token: str = Field(..., description="JWT access token", alias="accessToken")
    refresh_token: Optional[str] = Field(
        None, description="JWT refresh token", alias="refreshToken"
    )
    token_type: str = Field("bearer", description="Token type")
    expires_in: int = Field(..., description="Access token expiration in seconds")


class LoginResponse(BaseModel):
    """Successful login response with tokens - deprecated, use StandardResponse[AuthResponseData]."""

    access_token: str = Field(..., description="JWT access token")
    refresh_token: str = Field(..., description="JWT refresh token")
    token_type: str = Field("bearer", description="Token type")
    expires_in: int = Field(..., description="Access token expiration in seconds")
    user: UserResponse = Field(..., description="User information")
    requires_2fa: bool = Field(
        False, description="Whether 2FA verification is required"
    )
    temp_token: Optional[str] = Field(
        None, description="Temporary token for 2FA verification"
    )

    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
                "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
                "token_type": "bearer",
                "expires_in": 900,
                "user": {
                    "id": "123e4567-e89b-12d3-a456-426614174000",
                    "email": "user@example.com",
                    "first_name": "John",
                    "last_name": "Doe",
                    "is_active": True,
                    "is_verified": True,
                    "roles": ["user"],
                },
            }
        }
    )


class TokenRefreshRequest(BaseModel):
    """Token refresh request."""

    refresh_token: str = Field(..., description="Valid refresh token")

    model_config = ConfigDict(
        json_schema_extra={
            "example": {"refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."}
        }
    )


class TokenRefreshResponse(BaseModel):
    """Token refresh response."""

    access_token: str = Field(..., description="New JWT access token")
    token_type: str = Field("bearer", description="Token type")
    expires_in: int = Field(..., description="Access token expiration in seconds")

    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
                "token_type": "bearer",
                "expires_in": 900,
            }
        }
    )


class PasswordResetRequest(BaseModel):
    """Password reset request."""

    email: EmailStr = Field(..., description="User email address")

    model_config = ConfigDict(
        json_schema_extra={"example": {"email": "user@example.com"}}
    )


class PasswordResetConfirm(BaseModel):
    """Password reset confirmation."""

    token: str = Field(..., description="Password reset token")
    new_password: str = Field(..., min_length=8, description="New password")
    confirm_password: str = Field(..., description="Password confirmation")

    @field_validator("new_password")
    @classmethod
    def validate_password_strength(cls, v: str) -> str:
        """Validate password meets security requirements."""
        if len(v) < 8:
            raise ValueError("Password must be at least 8 characters long")

        if not re.search(r"[A-Z]", v):
            raise ValueError("Password must contain at least one uppercase letter")

        if not re.search(r"[a-z]", v):
            raise ValueError("Password must contain at least one lowercase letter")

        if not re.search(r"\d", v):
            raise ValueError("Password must contain at least one digit")

        if not re.search(r'[!@#$%^&*(),.?":{}|<>]', v):
            raise ValueError("Password must contain at least one special character")

        return v

    @field_validator("confirm_password")
    @classmethod
    def passwords_match(cls, v: str, info) -> str:
        """Validate password confirmation matches password."""
        if hasattr(info, "data") and info.data and "new_password" in info.data:
            if v != info.data["new_password"]:
                raise ValueError("Passwords do not match")
        return v

    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "token": "reset-token-here",
                "new_password": "NewSecurePassword123!",
                "confirm_password": "NewSecurePassword123!",
            }
        }
    )


class EmailVerificationRequest(BaseModel):
    """Email verification resend request."""

    email: EmailStr = Field(..., description="User email address")

    model_config = ConfigDict(
        json_schema_extra={"example": {"email": "user@example.com"}}
    )


class MessageResponse(BaseModel):
    """Generic message response."""

    message: str = Field(..., description="Response message")

    model_config = ConfigDict(
        json_schema_extra={"example": {"message": "Operation completed successfully"}}
    )


class OAuthProvider(str, Enum):
    """Supported OAuth providers."""

    GOOGLE = "google"
    GITHUB = "github"
    DISCORD = "discord"


class OAuthUserInfo(BaseModel):
    """OAuth user information from provider."""

    id: str = Field(..., description="OAuth provider user ID")
    email: Optional[str] = Field(None, description="User email from OAuth provider")
    name: Optional[str] = Field(None, description="User full name from OAuth provider")
    picture: Optional[str] = Field(
        None, description="User avatar URL from OAuth provider"
    )
    email_verified: bool = Field(
        False, description="Whether email is verified by OAuth provider"
    )
    provider: OAuthProvider = Field(..., description="OAuth provider type")


class OAuthCallbackRequest(BaseModel):
    """OAuth callback request."""

    code: str = Field(..., description="Authorization code from OAuth provider")
    state: Optional[str] = Field(
        None, description="State parameter for CSRF protection"
    )

    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "code": "authorization-code-from-provider",
                "state": "random-state-string",
            }
        }
    )


class OAuthInitResponse(BaseModel):
    """OAuth initialization response."""

    authorization_url: str = Field(
        ..., description="URL to redirect user for OAuth authorization"
    )
    state: str = Field(..., description="State parameter for CSRF protection")

    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "authorization_url": "https://accounts.google.com/o/oauth2/v2/auth?...",
                "state": "random-state-string",
            }
        }
    )


class TwoFactorLoginRequest(BaseModel):
    """Two-factor login verification request."""

    temp_token: str = Field(..., description="Temporary token from initial login")
    code: str = Field(
        ...,
        min_length=6,
        max_length=8,
        description="2FA code (TOTP or backup)",
    )
    is_backup: bool = Field(False, description="Whether the code is a backup code")

    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "temp_token": "temporary-token-from-login",
                "code": "123456",
                "is_backup": False,
            }
        }
    )


class TwoFactorSetupResponse(BaseModel):
    """Two-factor setup response."""

    secret: str = Field(..., description="TOTP secret key")
    qr_code: str = Field(..., description="QR code as data URL")
    backup_codes: list[str] = Field(..., description="Backup recovery codes")
    manual_entry_key: str = Field(..., description="Manual entry key")
    manual_entry_uri: str = Field(..., description="TOTP provisioning URI")

    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "secret": "JBSWY3DPEHPK3PXP",
                "qr_code": "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB...",
                "backup_codes": ["ABCD-1234", "EFGH-5678"],
                "manual_entry_key": "JBSWY3DPEHPK3PXP",
                "manual_entry_uri": "otpauth://totp/...",
            }
        }
    )


class TwoFactorVerifyRequest(BaseModel):
    """Two-factor verification request."""

    code: str = Field(..., min_length=6, max_length=6, description="TOTP code")

    @field_validator("code")
    @classmethod
    def validate_code(cls, v: str) -> str:
        """Validate TOTP code format."""
        if not v.isdigit():
            raise ValueError("Code must contain only digits")
        if len(v) != 6:
            raise ValueError("Code must be exactly 6 digits")
        return v

    model_config = ConfigDict(json_schema_extra={"example": {"code": "123456"}})


class TwoFactorStatusResponse(BaseModel):
    """Two-factor authentication status response."""

    enabled: bool = Field(..., description="Whether 2FA is enabled")
    verified_at: Optional[str] = Field(None, description="When 2FA was verified")
    backup_codes_remaining: int = Field(
        ..., description="Number of backup codes remaining"
    )
    methods: dict[str, bool] = Field(..., description="Available 2FA methods")

    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "enabled": True,
                "verified_at": "2024-01-01T12:00:00Z",
                "backup_codes_remaining": 8,
                "methods": {
                    "totp": True,
                    "backup_codes": True,
                    "webauthn": False,
                },
            }
        }
    )


class TwoFactorDisableRequest(BaseModel):
    """Two-factor disable request."""

    password: str = Field(..., description="Current user password")

    model_config = ConfigDict(
        json_schema_extra={"example": {"password": "current-password"}}
    )
