"""
Standardized API Response Schemas

This module provides standardized response formats that match the Flutter app expectations.
All API endpoints should use these response wrappers for consistency.
"""

from datetime import datetime
from typing import Any, Dict, Generic, List, Optional, TypeVar, Literal

from pydantic import BaseModel, Field

# Generic type for response data
T = TypeVar("T")


class ErrorResponse(BaseModel):
    """
    Standardized error response format.

    Matches Flutter app expectations for error handling.
    """

    code: str = Field(..., description="Error code identifier")
    message: str = Field(..., description="Human-readable error message")
    details: Optional[Dict[str, Any]] = Field(
        None, description="Additional error details"
    )


class ResponseMetadata(BaseModel):
    """
    Response metadata for tracking and debugging.
    """

    timestamp: datetime = Field(default_factory=datetime.utcnow)
    request_id: Optional[str] = Field(None, description="Request tracking ID")
    version: str = Field(default="1.0.0", description="API version")


class StandardResponse(BaseModel, Generic[T]):
    """
    Standardized API response wrapper.

    This matches the Flutter app's expected response format:
    ```
    interface ApiResponse<T> {
      success: boolean;
      data?: T;
      error?: {
        code: string;
        message: string;
        details?: Record<string, unknown>;
      };
      metadata?: {
        timestamp: string;
        request_id: string;
        version: string;
      };
    }
    ```
    """

    success: bool = Field(..., description="Operation success status")
    data: Optional[T] = Field(None, description="Response data when successful")
    error: Optional[ErrorResponse] = Field(
        None, description="Error information when failed"
    )
    metadata: Optional[ResponseMetadata] = Field(default_factory=ResponseMetadata)

    class Config:
        # Allow extra fields for backward compatibility
        extra = "allow"


class SuccessResponse(StandardResponse[T]):
    """
    Convenience class for successful responses.
    """

    success: Literal[True] = Field(default=True)

    def __init__(self, data: T, **kwargs):
        super().__init__(success=True, data=data, **kwargs)


class ErrorResponseModel(StandardResponse[None]):
    """
    Convenience class for error responses.
    """

    success: Literal[False] = Field(default=False)
    data: None = Field(default=None)

    def __init__(
        self,
        error_code: str,
        error_message: str,
        details: Optional[Dict[str, Any]] = None,
        **kwargs,
    ):
        error = ErrorResponse(code=error_code, message=error_message, details=details)
        super().__init__(success=False, data=None, error=error, **kwargs)


# Common error codes that match Flutter expectations
class ErrorCodes:
    """
    Standardized error codes that match Flutter app constants.

    These correspond to ApiErrors class in Flutter:
    lib/core/constants/api_constants.dart:114
    """

    NETWORK_ERROR = "NETWORK_ERROR"
    TIMEOUT_ERROR = "TIMEOUT_ERROR"
    INVALID_CREDENTIALS = "INVALID_CREDENTIALS"
    USER_NOT_FOUND = "USER_NOT_FOUND"
    EMAIL_ALREADY_EXISTS = "EMAIL_ALREADY_EXISTS"
    ACCOUNT_LOCKED = "ACCOUNT_LOCKED"
    EMAIL_NOT_VERIFIED = "EMAIL_NOT_VERIFIED"
    TWO_FACTOR_REQUIRED = "TWO_FACTOR_REQUIRED"
    INVALID_TWO_FACTOR_CODE = "INVALID_TWO_FACTOR_CODE"
    TOKEN_EXPIRED = "TOKEN_EXPIRED"
    INVALID_TOKEN = "INVALID_TOKEN"
    PERMISSION_DENIED = "PERMISSION_DENIED"
    SERVER_ERROR = "SERVER_ERROR"
    VALIDATION_ERROR = "VALIDATION_ERROR"
    RATE_LIMIT_EXCEEDED = "RATE_LIMIT_EXCEEDED"


# Pagination support
class PaginationMeta(BaseModel):
    """
    Pagination metadata for list responses.
    """

    page: int = Field(..., ge=1, description="Current page number")
    per_page: int = Field(..., ge=1, le=100, description="Items per page")
    total: int = Field(..., ge=0, description="Total number of items")
    pages: int = Field(..., ge=0, description="Total number of pages")
    has_next: bool = Field(..., description="Has next page")
    has_prev: bool = Field(..., description="Has previous page")


class PaginatedResponse(BaseModel, Generic[T]):
    """
    Paginated response wrapper.
    """

    items: List[T] = Field(..., description="List of items")
    pagination: PaginationMeta = Field(..., description="Pagination metadata")


# Authentication-specific response types
class TokenData(BaseModel):
    """
    Token response data structure.
    """

    access_token: str = Field(..., description="JWT access token")
    refresh_token: Optional[str] = Field(None, description="JWT refresh token")
    token_type: str = Field(default="bearer", description="Token type")
    expires_in: int = Field(..., description="Token expiration in seconds")


class LoginResponseData(BaseModel):
    """
    Login response data structure that matches Flutter expectations.
    """

    user: Dict[str, Any] = Field(..., description="User information")
    access_token: str = Field(..., description="JWT access token")
    refresh_token: Optional[str] = Field(None, description="JWT refresh token")
    token_type: str = Field(default="bearer", description="Token type")
    expires_in: int = Field(..., description="Token expiration in seconds")


# Type aliases for common response types
class LoginResponse(StandardResponse[LoginResponseData]):
    """Login response type."""

    pass


class TokenRefreshResponse(StandardResponse[TokenData]):
    """Token refresh response type."""

    pass


class MessageResponse(StandardResponse[Dict[str, str]]):
    """Simple message response type."""

    pass


class UserResponse(StandardResponse[Dict[str, Any]]):
    """User data response type."""

    pass


class PermissionsResponse(StandardResponse[List[str]]):
    """Permissions response type."""

    pass


def create_success_response(
    data: T, request_id: Optional[str] = None
) -> StandardResponse[T]:
    """
    Helper function to create standardized success responses.

    Args:
        data: Response data
        request_id: Optional request tracking ID

    Returns:
        StandardResponse: Standardized success response
    """
    metadata = (
        ResponseMetadata(request_id=request_id) if request_id else ResponseMetadata()
    )
    return StandardResponse(success=True, data=data, metadata=metadata)


def create_error_response(
    code: str,
    message: str,
    details: Optional[Dict[str, Any]] = None,
    request_id: Optional[str] = None,
) -> StandardResponse[None]:
    """
    Helper function to create standardized error responses.

    Args:
        code: Error code
        message: Error message
        details: Optional error details
        request_id: Optional request tracking ID

    Returns:
        StandardResponse: Standardized error response
    """
    error = ErrorResponse(code=code, message=message, details=details)
    metadata = (
        ResponseMetadata(request_id=request_id) if request_id else ResponseMetadata()
    )
    return StandardResponse(success=False, data=None, error=error, metadata=metadata)
