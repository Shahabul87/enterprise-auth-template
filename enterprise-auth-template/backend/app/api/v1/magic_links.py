"""
Magic Link API Endpoints

API endpoints for passwordless authentication via magic links.
"""

from typing import Dict, Any

import structlog
from fastapi import APIRouter, BackgroundTasks, Depends, HTTPException, Request, status
from fastapi.responses import JSONResponse
from pydantic import BaseModel, EmailStr, Field, ConfigDict
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.middleware.rate_limiter import RateLimiter
from app.services.magic_link_service import MagicLinkService, MagicLinkError

logger = structlog.get_logger(__name__)

router = APIRouter(prefix="/magic-links", tags=["magic-links"])

# Initialize rate limiter
try:
    import redis.asyncio as redis
    from app.core.config import get_settings

    settings = get_settings()
    redis_client = (
        redis.from_url(str(settings.REDIS_URL)) if settings.REDIS_URL else None
    )
    rate_limiter = RateLimiter(redis_client=redis_client)
except Exception:
    rate_limiter = RateLimiter(redis_client=None)


async def magic_link_request_rate_limit(request: Request):
    """Rate limit for magic link requests: 5 requests per 15 minutes per IP."""
    client_ip = request.client.host if request.client else "unknown"
    key = f"magic_link_request:{client_ip}"

    allowed, remaining, reset_time, security_info = await rate_limiter.check_rate_limit(
        key=key,
        limit=5,
        window=900,  # 15 minutes
        client_ip=client_ip,
        endpoint="/magic-links/request",
    )

    if not allowed:
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail="Too many magic link requests. Please wait before trying again.",
        )


async def magic_link_verify_rate_limit(request: Request):
    """Rate limit for magic link verification: 10 requests per 5 minutes per IP."""
    client_ip = request.client.host if request.client else "unknown"
    key = f"magic_link_verify:{client_ip}"

    allowed, remaining, reset_time, security_info = await rate_limiter.check_rate_limit(
        key=key,
        limit=10,
        window=300,  # 5 minutes
        client_ip=client_ip,
        endpoint="/magic-links/verify",
    )

    if not allowed:
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail="Too many magic link verification attempts. Please wait before trying again.",
        )


class MagicLinkRequest(BaseModel):
    """Request model for magic link generation."""

    email: EmailStr = Field(..., description="Email address to send magic link to")

    model_config = ConfigDict(
        json_schema_extra={"example": {"email": "user@example.com"}}
    )


class MagicLinkVerify(BaseModel):
    """Request model for magic link verification."""

    token: str = Field(..., description="Magic link token from email")

    model_config = ConfigDict(
        json_schema_extra={"example": {"token": "your-magic-link-token-from-email"}}
    )


class MagicLinkResponse(BaseModel):
    """Response model for magic link request."""

    success: bool = Field(..., description="Whether the request was successful")
    message: str = Field(..., description="Status message")

    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "success": True,
                "message": "Magic link sent to your email address",
            }
        }
    )


class MagicLinkVerifyResponse(BaseModel):
    """Response model for magic link verification."""

    success: bool = Field(..., description="Whether verification was successful")
    access_token: str = Field(None, description="JWT access token")
    refresh_token: str = Field(None, description="JWT refresh token")
    token_type: str = Field(default="bearer", description="Token type")
    user: Dict[str, Any] = Field(None, description="User information")

    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "success": True,
                "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
                "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
                "token_type": "bearer",
                "user": {
                    "id": "123e4567-e89b-12d3-a456-426614174000",
                    "email": "user@example.com",
                    "name": "John Doe",
                },
            }
        }
    )


@router.post(
    "/request",
    response_model=MagicLinkResponse,
    status_code=status.HTTP_200_OK,
    dependencies=[Depends(magic_link_request_rate_limit)],
    summary="Request a magic link",
    description="Send a magic link to the specified email address for passwordless authentication",
)
async def request_magic_link(
    request: Request,
    magic_link_data: MagicLinkRequest,
    background_tasks: BackgroundTasks,
    db: AsyncSession = Depends(get_db),
) -> MagicLinkResponse:
    """
    Request a magic link for passwordless authentication.

    A magic link will be sent to the provided email address if it exists in the system.
    For security reasons, the response will always indicate success even if the email doesn't exist.

    Args:
        request: FastAPI request object
        magic_link_data: Email address to send magic link to
        background_tasks: Background task manager
        db: Database session

    Returns:
        Success response regardless of whether email exists

    Raises:
        HTTPException: If rate limited or service error
    """
    try:
        # Get request metadata
        client_ip = request.client.host if request.client else None
        user_agent = request.headers.get("User-Agent", "Unknown")

        # Create service instance
        service = MagicLinkService(db)

        # Request magic link (this handles email sending)
        success = await service.request_magic_link(
            email=magic_link_data.email,
            request_ip=client_ip,
            request_user_agent=user_agent,
        )

        # Always return success to prevent email enumeration
        return MagicLinkResponse(
            success=True,
            message="If an account exists with this email, a magic link has been sent. Please check your inbox.",
        )

    except MagicLinkError as e:
        logger.error(
            "Magic link request failed", email=magic_link_data.email, error=str(e)
        )
        # Still return success to prevent email enumeration
        return MagicLinkResponse(
            success=True,
            message="If an account exists with this email, a magic link has been sent. Please check your inbox.",
        )
    except Exception as e:
        logger.error("Unexpected error in magic link request", error=str(e))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An error occurred processing your request",
        )


@router.post(
    "/verify",
    response_model=MagicLinkVerifyResponse,
    status_code=status.HTTP_200_OK,
    dependencies=[Depends(magic_link_verify_rate_limit)],
    summary="Verify a magic link",
    description="Verify a magic link token and authenticate the user",
)
async def verify_magic_link(
    request: Request, verify_data: MagicLinkVerify, db: AsyncSession = Depends(get_db)
) -> MagicLinkVerifyResponse:
    """
    Verify a magic link token and authenticate the user.

    If the token is valid, returns JWT tokens and user information.

    Args:
        request: FastAPI request object
        verify_data: Magic link token to verify
        db: Database session

    Returns:
        Authentication tokens and user info if successful

    Raises:
        HTTPException: If token is invalid or expired
    """
    try:
        # Get request metadata
        client_ip = request.client.host if request.client else None
        user_agent = request.headers.get("User-Agent", "Unknown")

        # Create service instance
        service = MagicLinkService(db)

        # Verify magic link
        access_token, refresh_token, user = await service.verify_magic_link(
            token=verify_data.token, ip_address=client_ip, user_agent=user_agent
        )

        if not access_token or not user:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid or expired magic link",
            )

        # Prepare user data for response
        user_data = {
            "id": str(user.id),
            "email": user.email,
            "name": user.full_name or user.email,
            "is_active": user.is_active,
            "email_verified": user.email_verified,
            "roles": [role.name for role in user.roles] if user.roles else [],
        }

        # Create response with Set-Cookie header for refresh token
        response = JSONResponse(
            content={
                "success": True,
                "access_token": access_token,
                "refresh_token": refresh_token,
                "token_type": "bearer",
                "user": user_data,
            }
        )

        # Set refresh token as HTTP-only cookie
        response.set_cookie(
            key="refresh_token",
            value=refresh_token,
            httponly=True,
            secure=True,  # Use HTTPS in production
            samesite="lax",
            max_age=30 * 24 * 60 * 60,  # 30 days
            path="/api",
        )

        logger.info("Magic link verified successfully", user_id=str(user.id))
        return response

    except HTTPException:
        raise
    except Exception as e:
        logger.error("Failed to verify magic link", error=str(e))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An error occurred verifying the magic link",
        )


@router.post(
    "/cleanup",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Clean up expired magic links",
    description="Remove expired magic links from the database (admin only)",
    include_in_schema=False,  # Hide from public API docs
)
async def cleanup_expired_links(db: AsyncSession = Depends(get_db)) -> None:
    """
    Clean up expired magic links from the database.

    This endpoint should be called periodically (e.g., via cron job) to remove
    expired magic links and keep the database clean.

    Args:
        db: Database session
    """
    try:
        service = MagicLinkService(db)
        count = await service.cleanup_expired_links()
        logger.info(f"Cleaned up {count} expired magic links")
    except Exception as e:
        logger.error("Failed to cleanup expired links", error=str(e))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to cleanup expired links",
        )
