"""
User Schemas

Pydantic models for user-related API requests and responses.
"""

from typing import List, Optional

from pydantic import BaseModel, EmailStr, Field, ConfigDict


class UserBase(BaseModel):
    """Base user model with common fields."""

    email: EmailStr = Field(..., description="User email address")
    full_name: str = Field(..., min_length=2, max_length=255, description="Full name")


class UserUpdate(BaseModel):
    """User profile update data."""

    full_name: Optional[str] = Field(
        None, min_length=2, max_length=255, description="Full name"
    )

    model_config = ConfigDict(
        json_schema_extra={"example": {"full_name": "John Doe"}}
    )


class UserResponse(BaseModel):
    """User information response."""

    id: str = Field(..., description="User ID")
    email: str = Field(..., description="User email address")
    full_name: str = Field(..., description="Full name")
    is_active: bool = Field(..., description="Whether user account is active")
    email_verified: bool = Field(..., description="Whether email is verified")
    roles: List[str] = Field(..., description="User roles")
    created_at: Optional[str] = Field(None, description="Account creation timestamp")
    updated_at: Optional[str] = Field(None, description="Last update timestamp")
    last_login: Optional[str] = Field(None, description="Last login timestamp")

    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "id": "123e4567-e89b-12d3-a456-426614174000",
                "email": "user@example.com",
                "full_name": "John Doe",
                "is_active": True,
                "email_verified": True,
                "roles": ["user"],
                "created_at": "2024-01-01T00:00:00Z",
                "updated_at": "2024-01-01T12:00:00Z",
                "last_login": "2024-01-01T12:00:00Z",
            }
        }
    )


class UserListResponse(BaseModel):
    """Paginated user list response."""

    users: List[UserResponse] = Field(..., description="List of users")
    total: int = Field(..., description="Total number of users")
    skip: int = Field(..., description="Number of users skipped")
    limit: int = Field(..., description="Number of users returned")

    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "users": [
                    {
                        "id": "123e4567-e89b-12d3-a456-426614174000",
                        "email": "user1@example.com",
                        "full_name": "John Doe",
                        "is_active": True,
                        "email_verified": True,
                        "roles": ["user"],
                    },
                    {
                        "id": "123e4567-e89b-12d3-a456-426614174001",
                        "email": "admin@example.com",
                        "full_name": "Admin User",
                        "is_active": True,
                        "email_verified": True,
                        "roles": ["admin", "user"],
                    },
                ],
                "total": 50,
                "skip": 0,
                "limit": 10,
            }
        }
    )


class UserRoleUpdate(BaseModel):
    """User role update request."""

    roles: List[str] = Field(..., description="List of role names to assign")

    model_config = ConfigDict(
        json_schema_extra={"example": {"roles": ["user", "moderator"]}}
    )


class UserAdminUpdate(BaseModel):
    """Admin user update data (more fields than regular user update)."""

    email: Optional[EmailStr] = Field(None, description="User email address")
    full_name: Optional[str] = Field(
        None, min_length=2, max_length=100, description="Full name"
    )
    is_active: Optional[bool] = Field(
        None, description="Whether user account is active"
    )
    is_verified: Optional[bool] = Field(None, description="Whether email is verified")
    roles: Optional[List[str]] = Field(None, description="User roles")

    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "email": "user@example.com",
                "full_name": "John Doe",
                "is_active": True,
                "email_verified": True,
                "roles": ["user", "moderator"],
            }
        }
    )
