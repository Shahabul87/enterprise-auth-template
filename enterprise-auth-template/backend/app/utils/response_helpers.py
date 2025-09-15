"""
Response Helper Utilities

Utility functions to create standardized API responses that match Flutter app expectations.
These helpers ensure consistent response format across all endpoints.
"""

from typing import Any, Dict, List, Optional, TypeVar, Union
from datetime import datetime
import uuid

from app.schemas.response import (
    StandardResponse,
    ErrorCodes,
    create_success_response,
    create_error_response,
)
from app.schemas.auth import UserResponse, AuthResponseData
from app.models.user import User

T = TypeVar("T")


def generate_request_id() -> str:
    """Generate a unique request ID for tracking."""
    return str(uuid.uuid4())[:8]


def success_response(
    data: T,
    request_id: Optional[str] = None,
    message: Optional[str] = None
) -> StandardResponse[T]:
    """
    Create a standardized success response.

    Args:
        data: Response data
        request_id: Optional request ID for tracking
        message: Optional success message

    Returns:
        StandardResponse: Standardized success response
    """
    if message:
        # Add message to metadata or data if needed
        pass

    return create_success_response(data, request_id)


def error_response(
    code: str,
    message: str,
    details: Optional[Dict[str, Any]] = None,
    request_id: Optional[str] = None,
    status_code: int = 400
) -> StandardResponse[None]:
    """
    Create a standardized error response.

    Args:
        code: Error code from ErrorCodes class
        message: Human-readable error message
        details: Optional error details
        request_id: Optional request ID for tracking
        status_code: HTTP status code (for logging, not included in response)

    Returns:
        StandardResponse: Standardized error response
    """
    return create_error_response(code, message, details, request_id)


def format_user_response(user: User, include_permissions: bool = False) -> Dict[str, Any]:
    """
    Format a User model to match Flutter expectations using the UserResponse schema.

    Args:
        user: SQLAlchemy User model instance
        include_permissions: Whether to include user permissions

    Returns:
        Dict: Formatted user data matching Flutter User entity
    """
    # Get permissions from roles if needed
    permissions = []
    if include_permissions:
        permissions_set = set()
        if hasattr(user, 'roles') and user.roles:
            for role in user.roles:
                if hasattr(role, 'permissions'):
                    for permission in role.permissions:
                        permissions_set.add(f"{permission.resource}:{permission.action}")

        # Add default permissions for authenticated users
        permissions_set.update(["profile:read", "profile:write"])

        # Add role-based permissions
        user_roles = [role.name for role in user.roles] if hasattr(user, 'roles') and user.roles else []
        for role_name in user_roles:
            if role_name in ["admin", "super_admin"]:
                permissions_set.update([
                    "users:read", "users:write", "users:delete",
                    "admin:access", "roles:manage"
                ])
            elif role_name == "moderator":
                permissions_set.update(["users:read", "content:manage"])

        permissions = list(permissions_set)

    # Get roles list
    roles = [role.name for role in user.roles] if hasattr(user, 'roles') and user.roles else []

    # Compute display name - User model only has full_name, not first_name/last_name
    full_name = user.full_name or ""
    if full_name:
        display_name = full_name
        # Try to split full_name into first and last
        name_parts = full_name.split()
        first_name = name_parts[0] if name_parts else ""
        last_name = " ".join(name_parts[1:]) if len(name_parts) > 1 else ""
    else:
        display_name = user.email.split("@")[0]  # Fallback to email username
        first_name = ""
        last_name = ""

    # Manually create the response dict with correct field names and aliases
    user_data = {
        "id": str(user.id),
        "email": user.email,
        "first_name": first_name,
        "last_name": last_name,
        "full_name": full_name,
        "name": display_name,
        "profilePicture": user.avatar_url,  # Use alias name directly
        "isEmailVerified": user.email_verified,  # Use alias name directly
        "isTwoFactorEnabled": user.two_factor_enabled,  # Use alias name directly
        "roles": roles,
        "permissions": permissions,
        "createdAt": user.created_at.isoformat() if user.created_at else "",  # Use alias name directly
        "updatedAt": user.updated_at.isoformat() if user.updated_at else "",  # Use alias name directly
        "lastLoginAt": user.last_login.isoformat() if user.last_login else None,  # Use alias name directly
        "is_active": user.is_active,
        # Backward compatibility fields
        "is_verified": user.email_verified,
        "last_login": user.last_login.isoformat() if user.last_login else None,
    }

    return user_data


def format_auth_response(user: User, access_token: str, refresh_token: Optional[str] = None, expires_in: int = 900) -> Dict[str, Any]:
    """
    Format authentication response data that matches Flutter expectations.

    Args:
        user: SQLAlchemy User model instance
        access_token: JWT access token
        refresh_token: Optional JWT refresh token
        expires_in: Token expiration time in seconds

    Returns:
        Dict: Formatted auth response data matching Flutter AuthResponseData
    """
    return {
        "user": format_user_response(user, include_permissions=True),
        "accessToken": access_token,
        "refreshToken": refresh_token,
        "tokenType": "bearer",
        "expiresIn": expires_in,
    }


def login_success_response(
    user: User,
    access_token: str,
    refresh_token: Optional[str] = None,
    expires_in: int = 900,
    request_id: Optional[str] = None
) -> StandardResponse[Dict[str, Any]]:
    """
    Create a standardized login success response.

    Args:
        user: SQLAlchemy User model instance
        access_token: JWT access token
        refresh_token: Optional JWT refresh token
        expires_in: Token expiration time in seconds
        request_id: Optional request ID for tracking

    Returns:
        StandardResponse: Standardized login response
    """
    auth_data = format_auth_response(user, access_token, refresh_token, expires_in)
    return success_response(auth_data, request_id)


def token_refresh_success_response(
    access_token: str,
    refresh_token: Optional[str] = None,
    expires_in: int = 900,
    request_id: Optional[str] = None
) -> StandardResponse[Dict[str, Any]]:
    """
    Create a standardized token refresh success response.

    Args:
        access_token: New JWT access token
        refresh_token: Optional new JWT refresh token (if rotated)
        expires_in: Token expiration time in seconds
        request_id: Optional request ID for tracking

    Returns:
        StandardResponse: Standardized token refresh response
    """
    token_data = {
        "accessToken": access_token,
        "refreshToken": refresh_token,
        "tokenType": "bearer",
        "expiresIn": expires_in,
    }
    return success_response(token_data, request_id)


def user_profile_response(
    user: User,
    request_id: Optional[str] = None
) -> StandardResponse[Dict[str, Any]]:
    """
    Create a standardized user profile response.

    Args:
        user: SQLAlchemy User model instance
        request_id: Optional request ID for tracking

    Returns:
        StandardResponse: Standardized user profile response
    """
    user_data = format_user_response(user, include_permissions=True)
    return success_response(user_data, request_id)


def message_response(
    message: str,
    request_id: Optional[str] = None
) -> StandardResponse[Dict[str, str]]:
    """
    Create a standardized message response.

    Args:
        message: Success message
        request_id: Optional request ID for tracking

    Returns:
        StandardResponse: Standardized message response
    """
    return success_response({"message": message}, request_id)


def permissions_response(
    permissions: List[str],
    request_id: Optional[str] = None
) -> StandardResponse[List[str]]:
    """
    Create a standardized permissions response.

    Args:
        permissions: List of permission strings
        request_id: Optional request ID for tracking

    Returns:
        StandardResponse: Standardized permissions response
    """
    return success_response(permissions, request_id)


# Error response helpers with common error codes
def invalid_credentials_error(request_id: Optional[str] = None) -> StandardResponse[None]:
    """Create invalid credentials error response."""
    return error_response(
        ErrorCodes.INVALID_CREDENTIALS,
        "Invalid email or password",
        request_id=request_id
    )


def email_already_exists_error(email: str, request_id: Optional[str] = None) -> StandardResponse[None]:
    """Create email already exists error response."""
    return error_response(
        ErrorCodes.EMAIL_ALREADY_EXISTS,
        "An account with this email already exists",
        details={"email": email},
        request_id=request_id
    )


def account_locked_error(request_id: Optional[str] = None) -> StandardResponse[None]:
    """Create account locked error response."""
    return error_response(
        ErrorCodes.ACCOUNT_LOCKED,
        "Account is temporarily locked due to multiple failed login attempts",
        request_id=request_id
    )


def email_not_verified_error(request_id: Optional[str] = None) -> StandardResponse[None]:
    """Create email not verified error response."""
    return error_response(
        ErrorCodes.EMAIL_NOT_VERIFIED,
        "Email address has not been verified. Please check your email and verify your account.",
        request_id=request_id
    )


def token_expired_error(request_id: Optional[str] = None) -> StandardResponse[None]:
    """Create token expired error response."""
    return error_response(
        ErrorCodes.TOKEN_EXPIRED,
        "Token has expired. Please log in again.",
        request_id=request_id
    )


def invalid_token_error(request_id: Optional[str] = None) -> StandardResponse[None]:
    """Create invalid token error response."""
    return error_response(
        ErrorCodes.INVALID_TOKEN,
        "Invalid token provided",
        request_id=request_id
    )


def validation_error(message: str, details: Optional[Dict[str, Any]] = None, request_id: Optional[str] = None) -> StandardResponse[None]:
    """Create validation error response."""
    return error_response(
        ErrorCodes.VALIDATION_ERROR,
        message,
        details=details,
        request_id=request_id
    )


def server_error(message: str = "An internal server error occurred", request_id: Optional[str] = None) -> StandardResponse[None]:
    """Create server error response."""
    return error_response(
        ErrorCodes.SERVER_ERROR,
        message,
        request_id=request_id
    )


def user_not_found_error(request_id: Optional[str] = None) -> StandardResponse[None]:
    """Create user not found error response."""
    return error_response(
        ErrorCodes.USER_NOT_FOUND,
        "User not found",
        request_id=request_id
    )


def permission_denied_error(request_id: Optional[str] = None) -> StandardResponse[None]:
    """Create permission denied error response."""
    return error_response(
        ErrorCodes.PERMISSION_DENIED,
        "Permission denied. You don't have access to this resource.",
        request_id=request_id
    )


def two_factor_required_error(temp_token: str, request_id: Optional[str] = None) -> StandardResponse[None]:
    """Create two-factor authentication required error response."""
    return error_response(
        ErrorCodes.TWO_FACTOR_REQUIRED,
        "Two-factor authentication is required",
        details={"temp_token": temp_token},
        request_id=request_id
    )


def rate_limit_exceeded_error(request_id: Optional[str] = None) -> StandardResponse[None]:
    """Create rate limit exceeded error response."""
    return error_response(
        ErrorCodes.RATE_LIMIT_EXCEEDED,
        "Too many requests. Please try again later.",
        request_id=request_id
    )
