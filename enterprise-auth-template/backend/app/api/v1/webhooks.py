"""
Webhook Management Endpoints

Handles webhook registration, delivery tracking, retry management,
and webhook event configuration for external system integrations.
"""

from typing import Dict, List, Optional, Any
from datetime import datetime
from enum import Enum
import hashlib
import hmac

import structlog
from fastapi import APIRouter, Depends, HTTPException, Query, status
from pydantic import BaseModel, Field, HttpUrl, ConfigDict, field_validator
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db_session
from app.dependencies.auth import CurrentUser, get_current_user, require_permissions
from app.models.webhook import WebhookEventType, WebhookStatus
from app.services.webhook_service import WebhookService

logger = structlog.get_logger(__name__)

router = APIRouter()


class WebhookCreateRequest(BaseModel):
    """Request model for creating webhooks."""

    name: str = Field(..., min_length=1, max_length=100, description="Webhook name")
    url: HttpUrl = Field(..., description="Webhook endpoint URL")
    description: Optional[str] = Field(None, max_length=500, description="Webhook description")
    events: List[WebhookEventType] = Field(..., min_length=1, description="List of events to subscribe to")
    secret: Optional[str] = Field(None, min_length=16, max_length=100, description="Secret for HMAC signing")
    headers: Optional[Dict[str, str]] = Field(None, description="Custom headers to send")
    timeout: int = Field(30, ge=5, le=120, description="Request timeout in seconds")
    retry_count: int = Field(3, ge=0, le=10, description="Number of retry attempts")
    is_active: bool = Field(True, description="Whether webhook is active")

    @field_validator('headers')
    @classmethod
    def validate_headers(cls, v):
        if v is not None:
            # Prevent override of critical headers
            forbidden_headers = {'authorization', 'content-type', 'content-length', 'host'}
            if any(header.lower() in forbidden_headers for header in v.keys()):
                raise ValueError(f"Headers cannot include: {', '.join(forbidden_headers)}")
        return v

    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "name": "User Activity Webhook",
                "url": "https://api.example.com/webhooks/user-activity",
                "description": "Receives user activity events for analytics",
                "events": ["user.created", "user.updated", "user.deleted"],
                "secret": "your-webhook-secret-key",
                "headers": {"X-Source": "enterprise-auth"},
                "timeout": 30,
                "retry_count": 3,
                "is_active": True
            }
        }
    )


class WebhookUpdateRequest(BaseModel):
    """Request model for updating webhooks."""

    name: Optional[str] = Field(None, min_length=1, max_length=100, description="Webhook name")
    url: Optional[HttpUrl] = Field(None, description="Webhook endpoint URL")
    description: Optional[str] = Field(None, max_length=500, description="Webhook description")
    events: Optional[List[WebhookEventType]] = Field(None, description="List of events to subscribe to")
    secret: Optional[str] = Field(None, min_length=16, max_length=100, description="Secret for HMAC signing")
    headers: Optional[Dict[str, str]] = Field(None, description="Custom headers to send")
    timeout: Optional[int] = Field(None, ge=5, le=120, description="Request timeout in seconds")
    retry_count: Optional[int] = Field(None, ge=0, le=10, description="Number of retry attempts")
    is_active: Optional[bool] = Field(None, description="Whether webhook is active")


class WebhookResponse(BaseModel):
    """Response model for webhooks."""

    id: str = Field(..., description="Webhook ID")
    name: str = Field(..., description="Webhook name")
    url: str = Field(..., description="Webhook endpoint URL")
    description: Optional[str] = Field(None, description="Webhook description")
    events: List[str] = Field(..., description="Subscribed events")
    status: str = Field(..., description="Webhook status")
    headers: Dict[str, str] = Field(..., description="Custom headers")
    timeout: int = Field(..., description="Request timeout")
    retry_count: int = Field(..., description="Retry attempts")
    is_active: bool = Field(..., description="Active status")
    created_at: str = Field(..., description="Creation timestamp")
    updated_at: str = Field(..., description="Last update timestamp")
    last_delivery: Optional[str] = Field(None, description="Last delivery timestamp")
    delivery_success_rate: float = Field(..., description="Delivery success rate")
    total_deliveries: int = Field(..., description="Total delivery attempts")


class WebhookListResponse(BaseModel):
    """Response model for webhook lists."""

    webhooks: List[WebhookResponse] = Field(..., description="List of webhooks")
    total: int = Field(..., description="Total number of webhooks")
    has_more: bool = Field(..., description="Whether more webhooks exist")


class WebhookDeliveryResponse(BaseModel):
    """Response model for webhook deliveries."""

    id: str = Field(..., description="Delivery ID")
    webhook_id: str = Field(..., description="Webhook ID")
    event_type: str = Field(..., description="Event type")
    payload: Dict[str, Any] = Field(..., description="Event payload")
    status: str = Field(..., description="Delivery status")
    http_status: Optional[int] = Field(None, description="HTTP response status")
    response_body: Optional[str] = Field(None, description="Response body")
    error_message: Optional[str] = Field(None, description="Error message if failed")
    attempt_count: int = Field(..., description="Number of attempts")
    created_at: str = Field(..., description="Creation timestamp")
    delivered_at: Optional[str] = Field(None, description="Delivery timestamp")
    next_retry_at: Optional[str] = Field(None, description="Next retry timestamp")


class WebhookDeliveryListResponse(BaseModel):
    """Response model for webhook delivery lists."""

    deliveries: List[WebhookDeliveryResponse] = Field(..., description="List of deliveries")
    total: int = Field(..., description="Total number of deliveries")
    has_more: bool = Field(..., description="Whether more deliveries exist")


class WebhookTestRequest(BaseModel):
    """Request model for testing webhooks."""

    event_type: WebhookEventType = Field(..., description="Event type to test")
    payload: Optional[Dict[str, Any]] = Field(None, description="Test payload data")


class WebhookStatsResponse(BaseModel):
    """Response model for webhook statistics."""

    total_webhooks: int = Field(..., description="Total number of webhooks")
    active_webhooks: int = Field(..., description="Active webhooks")
    total_deliveries: int = Field(..., description="Total delivery attempts")
    successful_deliveries: int = Field(..., description="Successful deliveries")
    failed_deliveries: int = Field(..., description="Failed deliveries")
    average_success_rate: float = Field(..., description="Average success rate")
    event_breakdown: Dict[str, int] = Field(..., description="Deliveries by event type")
    recent_activity: List[Dict[str, Any]] = Field(..., description="Recent webhook activity")


class MessageResponse(BaseModel):
    """Generic message response."""

    message: str = Field(..., description="Response message")


@router.post("/", response_model=WebhookResponse)
async def create_webhook(
    webhook_request: WebhookCreateRequest,
    current_user: CurrentUser = Depends(require_permissions(["webhooks:create"])),
    db: AsyncSession = Depends(get_db_session),
) -> WebhookResponse:
    """
    Create a new webhook.

    Creates a webhook endpoint for receiving event notifications.
    Requires webhook creation permissions.

    Args:
        webhook_request: Webhook creation data
        current_user: Current authenticated user
        db: Database session

    Returns:
        WebhookResponse: Created webhook information
    """
    logger.info("Webhook creation requested", user_id=current_user.id, name=webhook_request.name)

    try:
        webhook_service = WebhookService(db)

        # Create webhook
        webhook = await webhook_service.create_webhook(
            name=webhook_request.name,
            url=str(webhook_request.url),
            events=[event.value if hasattr(event, 'value') else event for event in webhook_request.events],
            created_by=str(current_user.id),
            description=webhook_request.description,
            secret=webhook_request.secret,
            headers=webhook_request.headers or {},
            retry_count=webhook_request.retry_count,
            timeout_seconds=webhook_request.timeout,
            organization_id=str(current_user.organization_id) if hasattr(current_user, 'organization_id') and current_user.organization_id else None
        )

        # Get delivery statistics
        stats = await webhook_service.get_webhook_statistics(webhook.id)

        logger.info("Webhook created", webhook_id=webhook.id, user_id=current_user.id)

        return WebhookResponse(
            id=webhook.id,
            name=webhook.name,
            url=webhook.url,
            description=webhook.description,
            events=webhook.events if isinstance(webhook.events, list) else [],
            status="active" if webhook.is_active else "inactive",
            headers=webhook.headers or {},
            timeout=webhook.timeout_seconds,
            retry_count=webhook.retry_count,
            is_active=webhook.is_active,
            created_at=webhook.created_at.isoformat(),
            updated_at=webhook.updated_at.isoformat(),
            last_delivery=stats.get('last_delivery'),
            delivery_success_rate=stats.get('success_rate', 0.0),
            total_deliveries=stats.get('total_deliveries', 0)
        )

    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        logger.error("Failed to create webhook", error=str(e))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to create webhook"
        )


@router.get("/", response_model=WebhookListResponse)
async def list_webhooks(
    limit: int = Query(50, ge=1, le=100, description="Number of webhooks to return"),
    offset: int = Query(0, ge=0, description="Number of webhooks to skip"),
    is_active: Optional[bool] = Query(None, description="Filter by active status"),
    current_user: CurrentUser = Depends(require_permissions(["webhooks:read"])),
    db: AsyncSession = Depends(get_db_session),
) -> WebhookListResponse:
    """
    List webhooks.

    Retrieves webhooks for the current user with filtering and pagination.

    Args:
        limit: Maximum number of webhooks to return
        offset: Number of webhooks to skip
        is_active: Filter by active status
        current_user: Current authenticated user
        db: Database session

    Returns:
        WebhookListResponse: Paginated webhook list
    """
    logger.debug("Webhooks list requested", user_id=current_user.id, limit=limit, offset=offset)

    try:
        webhook_service = WebhookService(db)

        # Get webhooks
        webhooks, total_count = await webhook_service.get_user_webhooks(
            user_id=current_user.id,
            limit=limit,
            offset=offset,
            is_active=is_active
        )

        # Convert to response format
        webhook_responses = []
        for webhook in webhooks:
            stats = await webhook_service.get_webhook_statistics(webhook.id)

            webhook_responses.append(WebhookResponse(
                id=webhook.id,
                name=webhook.name,
                url=webhook.url,
                description=webhook.description,
                events=[event.value for event in webhook.events],
                status=webhook.status.value,
                headers=webhook.headers,
                timeout=webhook.timeout,
                retry_count=webhook.retry_count,
                is_active=webhook.is_active,
                created_at=webhook.created_at.isoformat(),
                updated_at=webhook.updated_at.isoformat(),
                last_delivery=stats.get('last_delivery'),
                delivery_success_rate=stats.get('success_rate', 0.0),
                total_deliveries=stats.get('total_deliveries', 0)
            ))

        return WebhookListResponse(
            webhooks=webhook_responses,
            total=total_count,
            has_more=(offset + limit) < total_count
        )

    except Exception as e:
        logger.error("Failed to list webhooks", error=str(e))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to retrieve webhooks"
        )


@router.get("/{webhook_id}", response_model=WebhookResponse)
async def get_webhook(
    webhook_id: str,
    current_user: CurrentUser = Depends(require_permissions(["webhooks:read"])),
    db: AsyncSession = Depends(get_db_session),
) -> WebhookResponse:
    """
    Get webhook details.

    Retrieves detailed information about a specific webhook.

    Args:
        webhook_id: Webhook ID to retrieve
        current_user: Current authenticated user
        db: Database session

    Returns:
        WebhookResponse: Webhook information
    """
    logger.debug("Webhook details requested", user_id=current_user.id, webhook_id=webhook_id)

    try:
        webhook_service = WebhookService(db)

        # Get webhook
        webhook = await webhook_service.get_webhook(
            webhook_id=webhook_id,
            user_id=current_user.id
        )

        if not webhook:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Webhook not found"
            )

        # Get delivery statistics
        stats = await webhook_service.get_webhook_statistics(webhook.id)

        return WebhookResponse(
            id=webhook.id,
            name=webhook.name,
            url=webhook.url,
            description=webhook.description,
            events=webhook.events if isinstance(webhook.events, list) else [],
            status="active" if webhook.is_active else "inactive",
            headers=webhook.headers or {},
            timeout=webhook.timeout_seconds,
            retry_count=webhook.retry_count,
            is_active=webhook.is_active,
            created_at=webhook.created_at.isoformat(),
            updated_at=webhook.updated_at.isoformat(),
            last_delivery=stats.get('last_delivery'),
            delivery_success_rate=stats.get('success_rate', 0.0),
            total_deliveries=stats.get('total_deliveries', 0)
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error("Failed to get webhook", error=str(e))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to retrieve webhook"
        )


@router.put("/{webhook_id}", response_model=WebhookResponse)
async def update_webhook(
    webhook_id: str,
    webhook_update: WebhookUpdateRequest,
    current_user: CurrentUser = Depends(require_permissions(["webhooks:update"])),
    db: AsyncSession = Depends(get_db_session),
) -> WebhookResponse:
    """
    Update webhook.

    Updates webhook configuration and settings.

    Args:
        webhook_id: Webhook ID to update
        webhook_update: Webhook update data
        current_user: Current authenticated user
        db: Database session

    Returns:
        WebhookResponse: Updated webhook information
    """
    logger.info("Webhook update requested", user_id=current_user.id, webhook_id=webhook_id)

    try:
        webhook_service = WebhookService(db)

        # Update webhook
        webhook = await webhook_service.update_webhook(
            webhook_id=webhook_id,
            user_id=current_user.id,
            update_data=webhook_update.dict(exclude_unset=True)
        )

        if not webhook:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Webhook not found"
            )

        # Get delivery statistics
        stats = await webhook_service.get_webhook_statistics(webhook.id)

        logger.info("Webhook updated", webhook_id=webhook.id, user_id=current_user.id)

        return WebhookResponse(
            id=webhook.id,
            name=webhook.name,
            url=webhook.url,
            description=webhook.description,
            events=webhook.events if isinstance(webhook.events, list) else [],
            status="active" if webhook.is_active else "inactive",
            headers=webhook.headers or {},
            timeout=webhook.timeout_seconds,
            retry_count=webhook.retry_count,
            is_active=webhook.is_active,
            created_at=webhook.created_at.isoformat(),
            updated_at=webhook.updated_at.isoformat(),
            last_delivery=stats.get('last_delivery'),
            delivery_success_rate=stats.get('success_rate', 0.0),
            total_deliveries=stats.get('total_deliveries', 0)
        )

    except HTTPException:
        raise
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        logger.error("Failed to update webhook", error=str(e))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to update webhook"
        )


@router.delete("/{webhook_id}", response_model=MessageResponse)
async def delete_webhook(
    webhook_id: str,
    current_user: CurrentUser = Depends(require_permissions(["webhooks:delete"])),
    db: AsyncSession = Depends(get_db_session),
) -> MessageResponse:
    """
    Delete webhook.

    Permanently deletes a webhook and all its delivery history.

    Args:
        webhook_id: Webhook ID to delete
        current_user: Current authenticated user
        db: Database session

    Returns:
        MessageResponse: Success message
    """
    logger.warning("Webhook deletion requested", user_id=current_user.id, webhook_id=webhook_id)

    try:
        webhook_service = WebhookService(db)

        success = await webhook_service.delete_webhook(
            webhook_id=webhook_id,
            user_id=current_user.id
        )

        if not success:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Webhook not found"
            )

        logger.warning("Webhook deleted", webhook_id=webhook_id, user_id=current_user.id)

        return MessageResponse(message="Webhook deleted successfully")

    except HTTPException:
        raise
    except Exception as e:
        logger.error("Failed to delete webhook", error=str(e))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to delete webhook"
        )


@router.post("/{webhook_id}/test", response_model=MessageResponse)
async def test_webhook(
    webhook_id: str,
    test_request: WebhookTestRequest,
    current_user: CurrentUser = Depends(require_permissions(["webhooks:test"])),
    db: AsyncSession = Depends(get_db_session),
) -> MessageResponse:
    """
    Test webhook.

    Sends a test event to the webhook endpoint to verify configuration.

    Args:
        webhook_id: Webhook ID to test
        test_request: Test configuration
        current_user: Current authenticated user
        db: Database session

    Returns:
        MessageResponse: Test result message
    """
    logger.info("Webhook test requested", user_id=current_user.id, webhook_id=webhook_id)

    try:
        webhook_service = WebhookService(db)

        # Create test payload
        test_payload = test_request.payload or {
            "event_type": test_request.event_type.value,
            "test": True,
            "timestamp": datetime.utcnow().isoformat(),
            "user_id": current_user.id,
            "data": {"message": "This is a test webhook event"}
        }

        # Send test event
        delivery = await webhook_service.send_webhook_event(
            webhook_id=webhook_id,
            event_type=test_request.event_type,
            payload=test_payload,
            user_id=current_user.id
        )

        if delivery and delivery.status == "success":
            return MessageResponse(message="Test webhook sent successfully")
        else:
            error_msg = delivery.error_message if delivery else "Unknown error"
            return MessageResponse(message=f"Test webhook failed: {error_msg}")

    except HTTPException:
        raise
    except Exception as e:
        logger.error("Failed to test webhook", error=str(e))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to test webhook"
        )


@router.get("/{webhook_id}/deliveries", response_model=WebhookDeliveryListResponse)
async def get_webhook_deliveries(
    webhook_id: str,
    limit: int = Query(50, ge=1, le=100, description="Number of deliveries to return"),
    offset: int = Query(0, ge=0, description="Number of deliveries to skip"),
    status: Optional[str] = Query(None, description="Filter by delivery status"),
    current_user: CurrentUser = Depends(require_permissions(["webhooks:read"])),
    db: AsyncSession = Depends(get_db_session),
) -> WebhookDeliveryListResponse:
    """
    Get webhook deliveries.

    Retrieves delivery history for a specific webhook with filtering and pagination.

    Args:
        webhook_id: Webhook ID
        limit: Maximum number of deliveries to return
        offset: Number of deliveries to skip
        status: Filter by delivery status
        current_user: Current authenticated user
        db: Database session

    Returns:
        WebhookDeliveryListResponse: Paginated delivery list
    """
    logger.debug("Webhook deliveries requested", user_id=current_user.id, webhook_id=webhook_id)

    try:
        webhook_service = WebhookService(db)

        # Get deliveries
        deliveries, total_count = await webhook_service.get_webhook_deliveries(
            webhook_id=webhook_id,
            user_id=current_user.id,
            limit=limit,
            offset=offset,
            status=status
        )

        # Convert to response format
        delivery_responses = []
        for delivery in deliveries:
            delivery_responses.append(WebhookDeliveryResponse(
                id=delivery.id,
                webhook_id=delivery.webhook_id,
                event_type=delivery.event_type.value,
                payload=delivery.payload,
                status=delivery.status.value,
                http_status=delivery.http_status,
                response_body=delivery.response_body,
                error_message=delivery.error_message,
                attempt_count=delivery.attempt_count,
                created_at=delivery.created_at.isoformat(),
                delivered_at=delivery.delivered_at.isoformat() if delivery.delivered_at else None,
                next_retry_at=delivery.next_retry_at.isoformat() if delivery.next_retry_at else None
            ))

        return WebhookDeliveryListResponse(
            deliveries=delivery_responses,
            total=total_count,
            has_more=(offset + limit) < total_count
        )

    except Exception as e:
        logger.error("Failed to get webhook deliveries", error=str(e))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to retrieve webhook deliveries"
        )


@router.post("/{webhook_id}/deliveries/{delivery_id}/retry", response_model=MessageResponse)
async def retry_webhook_delivery(
    webhook_id: str,
    delivery_id: str,
    current_user: CurrentUser = Depends(require_permissions(["webhooks:retry"])),
    db: AsyncSession = Depends(get_db_session),
) -> MessageResponse:
    """
    Retry webhook delivery.

    Manually retries a failed webhook delivery.

    Args:
        webhook_id: Webhook ID
        delivery_id: Delivery ID to retry
        current_user: Current authenticated user
        db: Database session

    Returns:
        MessageResponse: Retry result message
    """
    logger.info(
        "Webhook delivery retry requested",
        user_id=current_user.id,
        webhook_id=webhook_id,
        delivery_id=delivery_id
    )

    try:
        webhook_service = WebhookService(db)

        success = await webhook_service.retry_delivery(
            delivery_id=delivery_id,
            webhook_id=webhook_id,
            user_id=current_user.id
        )

        if not success:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Delivery not found or cannot be retried"
            )

        return MessageResponse(message="Webhook delivery retry initiated")

    except HTTPException:
        raise
    except Exception as e:
        logger.error("Failed to retry webhook delivery", error=str(e))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to retry webhook delivery"
        )


@router.get("/stats", response_model=WebhookStatsResponse)
async def get_webhook_statistics(
    days: int = Query(30, ge=1, le=365, description="Number of days for statistics"),
    current_user: CurrentUser = Depends(require_permissions(["webhooks:stats"])),
    db: AsyncSession = Depends(get_db_session),
) -> WebhookStatsResponse:
    """
    Get webhook statistics.

    Provides statistics about webhook performance and delivery success rates.

    Args:
        days: Number of days to include in statistics
        current_user: Current authenticated user
        db: Database session

    Returns:
        WebhookStatsResponse: Webhook statistics
    """
    logger.info("Webhook statistics requested", user_id=current_user.id, days=days)

    try:
        webhook_service = WebhookService(db)

        stats = await webhook_service.get_system_webhook_statistics(
            user_id=current_user.id,
            days=days
        )

        return WebhookStatsResponse(
            total_webhooks=stats.get('total_webhooks', 0),
            active_webhooks=stats.get('active_webhooks', 0),
            total_deliveries=stats.get('total_deliveries', 0),
            successful_deliveries=stats.get('successful_deliveries', 0),
            failed_deliveries=stats.get('failed_deliveries', 0),
            average_success_rate=stats.get('average_success_rate', 0.0),
            event_breakdown=stats.get('event_breakdown', {}),
            recent_activity=stats.get('recent_activity', [])
        )

    except Exception as e:
        logger.error("Failed to get webhook statistics", error=str(e))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to retrieve webhook statistics"
        )


@router.post("/{webhook_id}/regenerate-secret", response_model=Dict[str, str])
async def regenerate_webhook_secret(
    webhook_id: str,
    current_user: CurrentUser = Depends(require_permissions(["webhooks:update"])),
    db: AsyncSession = Depends(get_db_session),
) -> Dict[str, str]:
    """
    Regenerate webhook secret.

    Generates a new HMAC secret for webhook payload signing.

    Args:
        webhook_id: Webhook ID
        current_user: Current authenticated user
        db: Database session

    Returns:
        Dict: New secret information
    """
    logger.info("Webhook secret regeneration requested", user_id=current_user.id, webhook_id=webhook_id)

    try:
        webhook_service = WebhookService(db)

        new_secret = await webhook_service.regenerate_webhook_secret(
            webhook_id=webhook_id,
            user_id=current_user.id
        )

        if not new_secret:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Webhook not found"
            )

        logger.info("Webhook secret regenerated", webhook_id=webhook_id, user_id=current_user.id)

        return {
            "secret": new_secret,
            "message": "Webhook secret regenerated successfully"
        }

    except HTTPException:
        raise
    except Exception as e:
        logger.error("Failed to regenerate webhook secret", error=str(e))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to regenerate webhook secret"
        )
