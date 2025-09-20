"""
API Key Management Endpoints

Handles API key creation, management, authentication, and usage tracking
for programmatic access to the platform.
"""

from typing import Dict, List, Optional, Any
from datetime import datetime
from enum import Enum

import structlog
from fastapi import APIRouter, Depends, HTTPException, Query, status
from pydantic import BaseModel, Field, ConfigDict, field_validator
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db_session
from app.dependencies.auth import CurrentUser, require_permissions
from app.services.api_key_service import APIKeyService

logger = structlog.get_logger(__name__)

router = APIRouter()


class APIKeyScopeType(str, Enum):
    """Available API key scopes."""

    READ = "read"
    WRITE = "write"
    DELETE = "delete"
    ADMIN = "admin"
    USERS_READ = "users:read"
    USERS_WRITE = "users:write"
    METRICS_READ = "metrics:read"
    WEBHOOKS_MANAGE = "webhooks:manage"
    NOTIFICATIONS_SEND = "notifications:send"


class APIKeyCreateRequest(BaseModel):
    """Request model for creating API keys."""

    name: str = Field(..., min_length=1, max_length=100, description="API key name")
    description: Optional[str] = Field(
        None, max_length=500, description="API key description"
    )
    scopes: List[APIKeyScopeType] = Field(
        ..., min_length=1, description="List of scopes for the API key"
    )
    rate_limit: int = Field(
        1000, ge=100, le=10000, description="Requests per hour limit"
    )
    allowed_ips: Optional[List[str]] = Field(
        None, description="List of allowed IP addresses (CIDR notation)"
    )
    expires_in_days: Optional[int] = Field(
        None, ge=1, le=365, description="Days until expiration"
    )

    @field_validator("allowed_ips")
    @classmethod
    def validate_ips(cls, v):
        if v is not None:
            # Basic IP/CIDR validation
            import ipaddress

            for ip in v:
                try:
                    ipaddress.ip_network(ip, strict=False)
                except ValueError:
                    raise ValueError(f"Invalid IP address or CIDR notation: {ip}")
        return v

    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "name": "Analytics API Key",
                "description": "API key for accessing analytics data",
                "scopes": ["metrics:read", "users:read"],
                "rate_limit": 5000,
                "allowed_ips": ["192.168.1.0/24", "10.0.0.1"],
                "expires_in_days": 90,
            }
        }
    )


class APIKeyUpdateRequest(BaseModel):
    """Request model for updating API keys."""

    name: Optional[str] = Field(
        None, min_length=1, max_length=100, description="API key name"
    )
    description: Optional[str] = Field(
        None, max_length=500, description="API key description"
    )
    scopes: Optional[List[APIKeyScopeType]] = Field(
        None, description="List of scopes for the API key"
    )
    rate_limit: Optional[int] = Field(
        None, ge=100, le=10000, description="Requests per hour limit"
    )
    allowed_ips: Optional[List[str]] = Field(
        None, description="List of allowed IP addresses"
    )
    is_active: Optional[bool] = Field(None, description="Whether API key is active")

    @field_validator("allowed_ips")
    @classmethod
    def validate_ips(cls, v):
        if v is not None:
            import ipaddress

            for ip in v:
                try:
                    ipaddress.ip_network(ip, strict=False)
                except ValueError:
                    raise ValueError(f"Invalid IP address or CIDR notation: {ip}")
        return v


class APIKeyResponse(BaseModel):
    """Response model for API keys."""

    id: str = Field(..., description="API key ID")
    name: str = Field(..., description="API key name")
    description: Optional[str] = Field(None, description="API key description")
    key_prefix: str = Field(..., description="API key prefix (first 10 characters)")
    scopes: List[str] = Field(..., description="List of scopes")
    rate_limit: int = Field(..., description="Requests per hour limit")
    allowed_ips: List[str] = Field(..., description="List of allowed IP addresses")
    is_active: bool = Field(..., description="Whether API key is active")
    usage_count: int = Field(..., description="Number of times key has been used")
    last_used_at: Optional[str] = Field(None, description="Last usage timestamp")
    created_at: str = Field(..., description="Creation timestamp")
    updated_at: str = Field(..., description="Last update timestamp")
    expires_at: Optional[str] = Field(None, description="Expiration timestamp")
    days_until_expiry: Optional[int] = Field(None, description="Days until expiration")


class APIKeyCreateResponse(BaseModel):
    """Response model for API key creation."""

    api_key: APIKeyResponse = Field(..., description="API key information")
    key: str = Field(..., description="The actual API key (shown only once)")
    warning: str = Field(..., description="Security warning about key storage")


class APIKeyListResponse(BaseModel):
    """Response model for API key lists."""

    api_keys: List[APIKeyResponse] = Field(..., description="List of API keys")
    total: int = Field(..., description="Total number of API keys")
    has_more: bool = Field(..., description="Whether more API keys exist")


class APIKeyUsageResponse(BaseModel):
    """Response model for API key usage statistics."""

    api_key_id: str = Field(..., description="API key ID")
    period: str = Field(..., description="Usage period")
    total_requests: int = Field(..., description="Total requests made")
    successful_requests: int = Field(..., description="Successful requests")
    failed_requests: int = Field(..., description="Failed requests")
    rate_limit_hits: int = Field(..., description="Rate limit violations")
    unique_ips: int = Field(..., description="Number of unique IP addresses")
    most_used_endpoints: List[Dict[str, Any]] = Field(
        ..., description="Most used API endpoints"
    )
    daily_usage: List[Dict[str, Any]] = Field(..., description="Daily usage breakdown")
    error_breakdown: Dict[str, int] = Field(..., description="Errors by type")


class APIKeyStatsResponse(BaseModel):
    """Response model for API key system statistics."""

    total_keys: int = Field(..., description="Total number of API keys")
    active_keys: int = Field(..., description="Active API keys")
    expired_keys: int = Field(..., description="Expired API keys")
    keys_expiring_soon: int = Field(..., description="Keys expiring within 30 days")
    total_requests_today: int = Field(..., description="Total requests today")
    total_requests_month: int = Field(..., description="Total requests this month")
    top_keys_by_usage: List[Dict[str, Any]] = Field(
        ..., description="Top API keys by usage"
    )
    scope_distribution: Dict[str, int] = Field(..., description="API keys by scope")
    recent_activity: List[Dict[str, Any]] = Field(
        ..., description="Recent API key activity"
    )


class MessageResponse(BaseModel):
    """Generic message response."""

    message: str = Field(..., description="Response message")


@router.post("/", response_model=APIKeyCreateResponse)
async def create_api_key(
    api_key_request: APIKeyCreateRequest,
    current_user: CurrentUser = Depends(require_permissions(["api_keys:create"])),
    db: AsyncSession = Depends(get_db_session),
) -> APIKeyCreateResponse:
    """
    Create a new API key.

    Creates an API key for programmatic access to the platform.
    The actual key value is shown only once during creation.

    Args:
        api_key_request: API key creation data
        current_user: Current authenticated user
        db: Database session

    Returns:
        APIKeyCreateResponse: Created API key information including the key value
    """
    logger.info(
        "API key creation requested", user_id=current_user.id, name=api_key_request.name
    )

    try:
        api_key_service = APIKeyService(db)

        # Convert enum scopes to strings
        scopes = [scope.value for scope in api_key_request.scopes]

        # Create API key
        api_key, raw_key = await api_key_service.create_api_key(
            user_id=current_user.id,
            name=api_key_request.name,
            description=api_key_request.description,
            scopes=scopes,
            rate_limit=api_key_request.rate_limit,
            allowed_ips=api_key_request.allowed_ips,
            expires_in_days=api_key_request.expires_in_days,
        )

        # Calculate days until expiry
        days_until_expiry = None
        if api_key.expires_at:
            days_until_expiry = (api_key.expires_at - datetime.utcnow()).days

        logger.info("API key created", api_key_id=api_key.id, user_id=current_user.id)

        return APIKeyCreateResponse(
            api_key=APIKeyResponse(
                id=api_key.id,
                name=api_key.name,
                description=api_key.description,
                key_prefix=api_key.key_prefix,
                scopes=api_key.scopes,
                rate_limit=api_key.rate_limit,
                allowed_ips=api_key.allowed_ips or [],
                is_active=api_key.is_active,
                usage_count=0,
                last_used_at=None,
                created_at=api_key.created_at.isoformat(),
                updated_at=api_key.updated_at.isoformat(),
                expires_at=(
                    api_key.expires_at.isoformat() if api_key.expires_at else None
                ),
                days_until_expiry=days_until_expiry,
            ),
            key=raw_key,
            warning="Store this API key securely. It will not be shown again.",
        )

    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))
    except Exception as e:
        logger.error("Failed to create API key", error=str(e))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to create API key",
        )


@router.get("/", response_model=APIKeyListResponse)
async def list_api_keys(
    limit: int = Query(50, ge=1, le=100, description="Number of API keys to return"),
    offset: int = Query(0, ge=0, description="Number of API keys to skip"),
    is_active: Optional[bool] = Query(None, description="Filter by active status"),
    expires_soon: bool = Query(
        False, description="Show only keys expiring within 30 days"
    ),
    current_user: CurrentUser = Depends(require_permissions(["api_keys:read"])),
    db: AsyncSession = Depends(get_db_session),
) -> APIKeyListResponse:
    """
    List API keys.

    Retrieves API keys for the current user with filtering and pagination.

    Args:
        limit: Maximum number of API keys to return
        offset: Number of API keys to skip
        is_active: Filter by active status
        expires_soon: Show only keys expiring within 30 days
        current_user: Current authenticated user
        db: Database session

    Returns:
        APIKeyListResponse: Paginated API key list
    """
    logger.debug(
        "API keys list requested", user_id=current_user.id, limit=limit, offset=offset
    )

    try:
        api_key_service = APIKeyService(db)

        # Get API keys
        api_keys, total_count = await api_key_service.get_user_api_keys(
            user_id=current_user.id,
            limit=limit,
            offset=offset,
            is_active=is_active,
            expires_soon=expires_soon,
        )

        # Convert to response format
        api_key_responses = []
        for api_key in api_keys:
            # Calculate days until expiry
            days_until_expiry = None
            if api_key.expires_at:
                days_until_expiry = (api_key.expires_at - datetime.utcnow()).days

            # Get usage statistics
            usage_stats = await api_key_service.get_api_key_usage(api_key.id, days=1)

            api_key_responses.append(
                APIKeyResponse(
                    id=api_key.id,
                    name=api_key.name,
                    description=api_key.description,
                    key_prefix=api_key.key_prefix,
                    scopes=api_key.scopes,
                    rate_limit=api_key.rate_limit,
                    allowed_ips=api_key.allowed_ips or [],
                    is_active=api_key.is_active,
                    usage_count=usage_stats.get("total_requests", 0),
                    last_used_at=usage_stats.get("last_used_at"),
                    created_at=api_key.created_at.isoformat(),
                    updated_at=api_key.updated_at.isoformat(),
                    expires_at=(
                        api_key.expires_at.isoformat() if api_key.expires_at else None
                    ),
                    days_until_expiry=days_until_expiry,
                )
            )

        return APIKeyListResponse(
            api_keys=api_key_responses,
            total=total_count,
            has_more=(offset + limit) < total_count,
        )

    except Exception as e:
        logger.error("Failed to list API keys", error=str(e))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to retrieve API keys",
        )


@router.get("/{api_key_id}", response_model=APIKeyResponse)
async def get_api_key(
    api_key_id: str,
    current_user: CurrentUser = Depends(require_permissions(["api_keys:read"])),
    db: AsyncSession = Depends(get_db_session),
) -> APIKeyResponse:
    """
    Get API key details.

    Retrieves detailed information about a specific API key.

    Args:
        api_key_id: API key ID to retrieve
        current_user: Current authenticated user
        db: Database session

    Returns:
        APIKeyResponse: API key information
    """
    logger.debug(
        "API key details requested", user_id=current_user.id, api_key_id=api_key_id
    )

    try:
        api_key_service = APIKeyService(db)

        # Get API key
        api_key = await api_key_service.get_api_key(
            api_key_id=api_key_id, user_id=current_user.id
        )

        if not api_key:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND, detail="API key not found"
            )

        # Calculate days until expiry
        days_until_expiry = None
        if api_key.expires_at:
            days_until_expiry = (api_key.expires_at - datetime.utcnow()).days

        # Get usage statistics
        usage_stats = await api_key_service.get_api_key_usage(api_key.id, days=30)

        return APIKeyResponse(
            id=api_key.id,
            name=api_key.name,
            description=api_key.description,
            key_prefix=api_key.key_prefix,
            scopes=api_key.scopes,
            rate_limit=api_key.rate_limit,
            allowed_ips=api_key.allowed_ips or [],
            is_active=api_key.is_active,
            usage_count=usage_stats.get("total_requests", 0),
            last_used_at=usage_stats.get("last_used_at"),
            created_at=api_key.created_at.isoformat(),
            updated_at=api_key.updated_at.isoformat(),
            expires_at=api_key.expires_at.isoformat() if api_key.expires_at else None,
            days_until_expiry=days_until_expiry,
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error("Failed to get API key", error=str(e))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to retrieve API key",
        )


@router.put("/{api_key_id}", response_model=APIKeyResponse)
async def update_api_key(
    api_key_id: str,
    api_key_update: APIKeyUpdateRequest,
    current_user: CurrentUser = Depends(require_permissions(["api_keys:update"])),
    db: AsyncSession = Depends(get_db_session),
) -> APIKeyResponse:
    """
    Update API key.

    Updates API key configuration and settings.

    Args:
        api_key_id: API key ID to update
        api_key_update: API key update data
        current_user: Current authenticated user
        db: Database session

    Returns:
        APIKeyResponse: Updated API key information
    """
    logger.info(
        "API key update requested", user_id=current_user.id, api_key_id=api_key_id
    )

    try:
        api_key_service = APIKeyService(db)

        # Convert enum scopes to strings if provided
        update_data = api_key_update.dict(exclude_unset=True)
        if "scopes" in update_data:
            update_data["scopes"] = [scope.value for scope in api_key_update.scopes]

        # Update API key
        api_key = await api_key_service.update_api_key(
            api_key_id=api_key_id, user_id=current_user.id, update_data=update_data
        )

        if not api_key:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND, detail="API key not found"
            )

        # Calculate days until expiry
        days_until_expiry = None
        if api_key.expires_at:
            days_until_expiry = (api_key.expires_at - datetime.utcnow()).days

        # Get usage statistics
        usage_stats = await api_key_service.get_api_key_usage(api_key.id, days=30)

        logger.info("API key updated", api_key_id=api_key.id, user_id=current_user.id)

        return APIKeyResponse(
            id=api_key.id,
            name=api_key.name,
            description=api_key.description,
            key_prefix=api_key.key_prefix,
            scopes=api_key.scopes,
            rate_limit=api_key.rate_limit,
            allowed_ips=api_key.allowed_ips or [],
            is_active=api_key.is_active,
            usage_count=usage_stats.get("total_requests", 0),
            last_used_at=usage_stats.get("last_used_at"),
            created_at=api_key.created_at.isoformat(),
            updated_at=api_key.updated_at.isoformat(),
            expires_at=api_key.expires_at.isoformat() if api_key.expires_at else None,
            days_until_expiry=days_until_expiry,
        )

    except HTTPException:
        raise
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))
    except Exception as e:
        logger.error("Failed to update API key", error=str(e))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to update API key",
        )


@router.delete("/{api_key_id}", response_model=MessageResponse)
async def delete_api_key(
    api_key_id: str,
    current_user: CurrentUser = Depends(require_permissions(["api_keys:delete"])),
    db: AsyncSession = Depends(get_db_session),
) -> MessageResponse:
    """
    Delete API key.

    Permanently deletes an API key and revokes all access.

    Args:
        api_key_id: API key ID to delete
        current_user: Current authenticated user
        db: Database session

    Returns:
        MessageResponse: Success message
    """
    logger.warning(
        "API key deletion requested", user_id=current_user.id, api_key_id=api_key_id
    )

    try:
        api_key_service = APIKeyService(db)

        success = await api_key_service.delete_api_key(
            api_key_id=api_key_id, user_id=current_user.id
        )

        if not success:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND, detail="API key not found"
            )

        logger.warning(
            "API key deleted", api_key_id=api_key_id, user_id=current_user.id
        )

        return MessageResponse(message="API key deleted successfully")

    except HTTPException:
        raise
    except Exception as e:
        logger.error("Failed to delete API key", error=str(e))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to delete API key",
        )


@router.post("/{api_key_id}/rotate", response_model=Dict[str, str])
async def rotate_api_key(
    api_key_id: str,
    current_user: CurrentUser = Depends(require_permissions(["api_keys:rotate"])),
    db: AsyncSession = Depends(get_db_session),
) -> Dict[str, str]:
    """
    Rotate API key.

    Generates a new key value while preserving all other settings.
    The old key is immediately invalidated.

    Args:
        api_key_id: API key ID to rotate
        current_user: Current authenticated user
        db: Database session

    Returns:
        Dict: New API key value
    """
    logger.warning(
        "API key rotation requested", user_id=current_user.id, api_key_id=api_key_id
    )

    try:
        api_key_service = APIKeyService(db)

        new_key = await api_key_service.rotate_api_key(
            api_key_id=api_key_id, user_id=current_user.id
        )

        if not new_key:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND, detail="API key not found"
            )

        logger.warning(
            "API key rotated", api_key_id=api_key_id, user_id=current_user.id
        )

        return {
            "key": new_key,
            "message": "API key rotated successfully. Update your applications immediately.",
            "warning": "The old key has been invalidated and will no longer work.",
        }

    except HTTPException:
        raise
    except Exception as e:
        logger.error("Failed to rotate API key", error=str(e))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to rotate API key",
        )


@router.get("/{api_key_id}/usage", response_model=APIKeyUsageResponse)
async def get_api_key_usage(
    api_key_id: str,
    days: int = Query(
        30, ge=1, le=365, description="Number of days for usage statistics"
    ),
    current_user: CurrentUser = Depends(require_permissions(["api_keys:read"])),
    db: AsyncSession = Depends(get_db_session),
) -> APIKeyUsageResponse:
    """
    Get API key usage statistics.

    Provides detailed usage statistics for a specific API key.

    Args:
        api_key_id: API key ID
        days: Number of days to include in statistics
        current_user: Current authenticated user
        db: Database session

    Returns:
        APIKeyUsageResponse: Usage statistics
    """
    logger.debug(
        "API key usage requested",
        user_id=current_user.id,
        api_key_id=api_key_id,
        days=days,
    )

    try:
        api_key_service = APIKeyService(db)

        # Verify API key ownership
        api_key = await api_key_service.get_api_key(api_key_id, current_user.id)
        if not api_key:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND, detail="API key not found"
            )

        # Get usage statistics
        usage_stats = await api_key_service.get_detailed_api_key_usage(api_key_id, days)

        return APIKeyUsageResponse(
            api_key_id=api_key_id,
            period=f"{days} days",
            total_requests=usage_stats.get("total_requests", 0),
            successful_requests=usage_stats.get("successful_requests", 0),
            failed_requests=usage_stats.get("failed_requests", 0),
            rate_limit_hits=usage_stats.get("rate_limit_hits", 0),
            unique_ips=usage_stats.get("unique_ips", 0),
            most_used_endpoints=usage_stats.get("most_used_endpoints", []),
            daily_usage=usage_stats.get("daily_usage", []),
            error_breakdown=usage_stats.get("error_breakdown", {}),
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error("Failed to get API key usage", error=str(e))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to retrieve API key usage statistics",
        )


@router.get("/stats", response_model=APIKeyStatsResponse)
async def get_api_key_statistics(
    current_user: CurrentUser = Depends(require_permissions(["api_keys:stats"])),
    db: AsyncSession = Depends(get_db_session),
) -> APIKeyStatsResponse:
    """
    Get API key system statistics.

    Provides system-wide statistics about API key usage and management.

    Args:
        current_user: Current authenticated user
        db: Database session

    Returns:
        APIKeyStatsResponse: System API key statistics
    """
    logger.info("API key system statistics requested", user_id=current_user.id)

    try:
        api_key_service = APIKeyService(db)

        # Get system statistics
        stats = await api_key_service.get_system_api_key_statistics(current_user.id)

        return APIKeyStatsResponse(
            total_keys=stats.get("total_keys", 0),
            active_keys=stats.get("active_keys", 0),
            expired_keys=stats.get("expired_keys", 0),
            keys_expiring_soon=stats.get("keys_expiring_soon", 0),
            total_requests_today=stats.get("total_requests_today", 0),
            total_requests_month=stats.get("total_requests_month", 0),
            top_keys_by_usage=stats.get("top_keys_by_usage", []),
            scope_distribution=stats.get("scope_distribution", {}),
            recent_activity=stats.get("recent_activity", []),
        )

    except Exception as e:
        logger.error("Failed to get API key statistics", error=str(e))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to retrieve API key statistics",
        )


@router.post("/{api_key_id}/validate", response_model=Dict[str, Any])
async def validate_api_key(
    api_key_id: str,
    current_user: CurrentUser = Depends(require_permissions(["api_keys:validate"])),
    db: AsyncSession = Depends(get_db_session),
) -> Dict[str, Any]:
    """
    Validate API key.

    Performs comprehensive validation of an API key including
    expiration, rate limits, and IP restrictions.

    Args:
        api_key_id: API key ID to validate
        current_user: Current authenticated user
        db: Database session

    Returns:
        Dict: Validation results
    """
    logger.debug(
        "API key validation requested", user_id=current_user.id, api_key_id=api_key_id
    )

    try:
        api_key_service = APIKeyService(db)

        # Verify API key ownership
        api_key = await api_key_service.get_api_key(api_key_id, current_user.id)
        if not api_key:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND, detail="API key not found"
            )

        # Perform validation
        validation_result = await api_key_service.validate_api_key_comprehensive(
            api_key_id
        )

        return {
            "api_key_id": api_key_id,
            "is_valid": validation_result.get("is_valid", False),
            "checks": {
                "is_active": validation_result.get("is_active", False),
                "not_expired": validation_result.get("not_expired", False),
                "rate_limit_ok": validation_result.get("rate_limit_ok", False),
                "ip_allowed": validation_result.get("ip_allowed", True),
            },
            "issues": validation_result.get("issues", []),
            "expires_at": (
                api_key.expires_at.isoformat() if api_key.expires_at else None
            ),
            "days_until_expiry": validation_result.get("days_until_expiry"),
            "current_rate_usage": validation_result.get("current_rate_usage", 0),
        }

    except HTTPException:
        raise
    except Exception as e:
        logger.error("Failed to validate API key", error=str(e))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to validate API key",
        )
