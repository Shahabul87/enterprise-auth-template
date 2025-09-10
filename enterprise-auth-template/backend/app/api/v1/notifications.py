"""
Notification System Endpoints

Handles notification management including creation, delivery tracking,
user preferences, and bulk notification operations.
"""

from typing import Dict, List, Optional, Any
from datetime import datetime
from enum import Enum

import structlog
from fastapi import APIRouter, Depends, HTTPException, Query, status
from pydantic import BaseModel, Field, ConfigDict
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db_session
from app.dependencies.auth import CurrentUser, get_current_user, require_permissions
from app.models.notification import (
    NotificationType,
    NotificationPriority,
    NotificationStatus,
    NotificationCategory
)
from app.services.notification_service import NotificationService

logger = structlog.get_logger(__name__)

router = APIRouter()


class NotificationRequest(BaseModel):
    """Request model for creating notifications."""

    user_id: Optional[str] = Field(None, description="Target user ID (admin only)")
    title: str = Field(..., min_length=1, max_length=200, description="Notification title")
    message: str = Field(..., min_length=1, max_length=1000, description="Notification message")
    notification_type: NotificationType = Field(..., description="Notification delivery type")
    priority: NotificationPriority = Field(NotificationPriority.NORMAL, description="Notification priority")
    category: NotificationCategory = Field(NotificationCategory.ACCOUNT, description="Notification category")
    data: Optional[Dict[str, Any]] = Field(None, description="Additional structured data")
    template_id: Optional[str] = Field(None, description="Template ID for styled notifications")
    scheduled_at: Optional[datetime] = Field(None, description="Schedule delivery time")
    expires_at: Optional[datetime] = Field(None, description="Expiration time")

    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "title": "Welcome to Our Platform",
                "message": "Thank you for joining us! Get started by completing your profile.",
                "notification_type": "email",
                "priority": "normal",
                "category": "account",
                "data": {"action_url": "/profile", "button_text": "Complete Profile"}
            }
        }
    )


class BulkNotificationRequest(BaseModel):
    """Request model for bulk notifications."""

    user_ids: List[str] = Field(..., min_length=1, description="List of target user IDs")
    title: str = Field(..., min_length=1, max_length=200, description="Notification title")
    message: str = Field(..., min_length=1, max_length=1000, description="Notification message")
    notification_type: NotificationType = Field(..., description="Notification delivery type")
    priority: NotificationPriority = Field(NotificationPriority.NORMAL, description="Notification priority")
    category: NotificationCategory = Field(NotificationCategory.ACCOUNT, description="Notification category")
    data: Optional[Dict[str, Any]] = Field(None, description="Additional structured data")
    template_id: Optional[str] = Field(None, description="Template ID for styled notifications")
    scheduled_at: Optional[datetime] = Field(None, description="Schedule delivery time")

    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "user_ids": ["user1-id", "user2-id", "user3-id"],
                "title": "System Maintenance Notice",
                "message": "We will be performing scheduled maintenance on Sunday at 2 AM UTC.",
                "notification_type": "email",
                "priority": "high",
                "category": "system"
            }
        }
    )


class NotificationResponse(BaseModel):
    """Response model for notifications."""

    id: str = Field(..., description="Notification ID")
    title: str = Field(..., description="Notification title")
    message: str = Field(..., description="Notification message")
    type: str = Field(..., description="Notification type")
    priority: str = Field(..., description="Notification priority")
    category: str = Field(..., description="Notification category")
    status: str = Field(..., description="Notification status")
    data: Dict[str, Any] = Field(..., description="Additional data")
    read_at: Optional[str] = Field(None, description="Read timestamp")
    sent_at: Optional[str] = Field(None, description="Sent timestamp")
    delivered_at: Optional[str] = Field(None, description="Delivered timestamp")
    created_at: str = Field(..., description="Creation timestamp")
    expires_at: Optional[str] = Field(None, description="Expiration timestamp")


class NotificationListResponse(BaseModel):
    """Response model for notification lists."""

    notifications: List[NotificationResponse] = Field(..., description="List of notifications")
    total: int = Field(..., description="Total number of notifications")
    unread_count: int = Field(..., description="Number of unread notifications")
    has_more: bool = Field(..., description="Whether more notifications exist")


class NotificationStatsResponse(BaseModel):
    """Response model for notification statistics."""

    total_notifications: int = Field(..., description="Total notifications")
    sent_notifications: int = Field(..., description="Successfully sent")
    failed_notifications: int = Field(..., description="Failed deliveries")
    pending_notifications: int = Field(..., description="Pending delivery")
    delivery_rate: float = Field(..., description="Overall delivery rate")
    type_breakdown: Dict[str, int] = Field(..., description="Notifications by type")
    category_breakdown: Dict[str, int] = Field(..., description="Notifications by category")
    recent_activity: List[Dict[str, Any]] = Field(..., description="Recent notification activity")


class NotificationPreferencesResponse(BaseModel):
    """Response model for user notification preferences."""

    email_notifications: bool = Field(..., description="Email notifications enabled")
    push_notifications: bool = Field(..., description="Push notifications enabled")
    sms_notifications: bool = Field(..., description="SMS notifications enabled")
    in_app_notifications: bool = Field(..., description="In-app notifications enabled")
    marketing_emails: bool = Field(..., description="Marketing emails enabled")
    security_alerts: bool = Field(..., description="Security alerts enabled")
    frequency_settings: Dict[str, str] = Field(..., description="Frequency settings by category")


class MessageResponse(BaseModel):
    """Generic message response."""

    message: str = Field(..., description="Response message")


@router.post("/", response_model=NotificationResponse)
async def create_notification(
    notification_request: NotificationRequest,
    current_user: CurrentUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db_session),
) -> NotificationResponse:
    """
    Create a new notification.

    Creates a notification for the current user or specified user (admin only).
    Supports scheduling and various delivery channels.

    Args:
        notification_request: Notification creation data
        current_user: Current authenticated user
        db: Database session

    Returns:
        NotificationResponse: Created notification information
    """
    logger.info("Notification creation requested", user_id=current_user.id)

    try:
        notification_service = NotificationService(db)

        # Determine target user
        target_user_id = notification_request.user_id
        if target_user_id and target_user_id != current_user.id:
            # Only admins can create notifications for other users
            if "admin:access" not in current_user.permissions:
                raise HTTPException(
                    status_code=status.HTTP_403_FORBIDDEN,
                    detail="Insufficient permissions to create notifications for other users"
                )
        else:
            target_user_id = current_user.id

        # Create notification
        notification = await notification_service.create_notification(
            user_id=target_user_id,
            title=notification_request.title,
            message=notification_request.message,
            notification_type=notification_request.notification_type,
            priority=notification_request.priority,
            category=notification_request.category,
            data=notification_request.data,
            template_id=notification_request.template_id,
            scheduled_at=notification_request.scheduled_at,
            expires_at=notification_request.expires_at
        )

        logger.info("Notification created", notification_id=notification.id, user_id=target_user_id)

        return NotificationResponse(
            id=notification.id,
            title=notification.title,
            message=notification.message,
            type=notification.type.value,
            priority=notification.priority.value,
            category=notification.category.value,
            status=notification.status.value,
            data=notification.data,
            read_at=notification.read_at.isoformat() if notification.read_at else None,
            sent_at=notification.sent_at.isoformat() if notification.sent_at else None,
            delivered_at=notification.delivered_at.isoformat() if notification.delivered_at else None,
            created_at=notification.created_at.isoformat(),
            expires_at=notification.expires_at.isoformat() if notification.expires_at else None
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error("Failed to create notification", error=str(e))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to create notification"
        )


@router.post("/bulk", response_model=Dict[str, Any])
async def create_bulk_notifications(
    bulk_request: BulkNotificationRequest,
    current_user: CurrentUser = Depends(require_permissions(["notifications:bulk", "admin:access"])),
    db: AsyncSession = Depends(get_db_session),
) -> Dict[str, Any]:
    """
    Create bulk notifications.

    Creates notifications for multiple users simultaneously.
    Requires admin permissions.

    Args:
        bulk_request: Bulk notification creation data
        current_user: Current authenticated user
        db: Database session

    Returns:
        Dict: Bulk operation results
    """
    logger.info("Bulk notification creation requested", user_id=current_user.id, count=len(bulk_request.user_ids))

    try:
        notification_service = NotificationService(db)

        # Prepare notification data for each user
        notifications = []
        for user_id in bulk_request.user_ids:
            notifications.append({
                "user_id": user_id,
                "title": bulk_request.title,
                "message": bulk_request.message,
                "notification_type": bulk_request.notification_type,
                "priority": bulk_request.priority,
                "category": bulk_request.category,
                "data": bulk_request.data,
                "template_id": bulk_request.template_id,
                "scheduled_at": bulk_request.scheduled_at
            })

        # Create bulk notifications
        result = await notification_service.send_bulk_notifications(notifications)

        logger.info("Bulk notifications created", user_id=current_user.id, result=result)

        return result

    except Exception as e:
        logger.error("Failed to create bulk notifications", error=str(e))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to create bulk notifications"
        )


@router.get("/", response_model=NotificationListResponse)
async def get_notifications(
    limit: int = Query(50, ge=1, le=100, description="Number of notifications to return"),
    offset: int = Query(0, ge=0, description="Number of notifications to skip"),
    status_filter: Optional[NotificationStatus] = Query(None, description="Filter by status"),
    category_filter: Optional[NotificationCategory] = Query(None, description="Filter by category"),
    unread_only: bool = Query(False, description="Show only unread notifications"),
    current_user: CurrentUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db_session),
) -> NotificationListResponse:
    """
    Get user notifications.

    Retrieves notifications for the current user with filtering and pagination.
    Supports filtering by status, category, and read state.

    Args:
        limit: Maximum number of notifications to return
        offset: Number of notifications to skip
        status_filter: Filter by notification status
        category_filter: Filter by notification category
        unread_only: Show only unread notifications
        current_user: Current authenticated user
        db: Database session

    Returns:
        NotificationListResponse: Paginated notification list
    """
    logger.debug("Notifications requested", user_id=current_user.id, limit=limit, offset=offset)

    try:
        notification_service = NotificationService(db)

        # Get notifications
        notifications, total_count = await notification_service.get_user_notifications(
            user_id=current_user.id,
            limit=limit,
            offset=offset,
            status_filter=status_filter,
            category_filter=category_filter,
            unread_only=unread_only
        )

        # Get unread count
        if not unread_only:
            _, unread_count = await notification_service.get_user_notifications(
                user_id=current_user.id,
                limit=1,
                offset=0,
                unread_only=True
            )
        else:
            unread_count = total_count

        # Convert to response format
        notification_responses = []
        for notification in notifications:
            notification_responses.append(NotificationResponse(
                id=notification.id,
                title=notification.title,
                message=notification.message,
                type=notification.type.value,
                priority=notification.priority.value,
                category=notification.category.value,
                status=notification.status.value,
                data=notification.data,
                read_at=notification.read_at.isoformat() if notification.read_at else None,
                sent_at=notification.sent_at.isoformat() if notification.sent_at else None,
                delivered_at=notification.delivered_at.isoformat() if notification.delivered_at else None,
                created_at=notification.created_at.isoformat(),
                expires_at=notification.expires_at.isoformat() if notification.expires_at else None
            ))

        return NotificationListResponse(
            notifications=notification_responses,
            total=total_count,
            unread_count=unread_count,
            has_more=(offset + limit) < total_count
        )

    except Exception as e:
        logger.error("Failed to get notifications", user_id=current_user.id, error=str(e))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to retrieve notifications"
        )


@router.put("/{notification_id}/read", response_model=MessageResponse)
async def mark_notification_read(
    notification_id: str,
    current_user: CurrentUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db_session),
) -> MessageResponse:
    """
    Mark notification as read.

    Marks a specific notification as read for the current user.

    Args:
        notification_id: Notification ID to mark as read
        current_user: Current authenticated user
        db: Database session

    Returns:
        MessageResponse: Success message
    """
    logger.debug("Mark notification read requested", user_id=current_user.id, notification_id=notification_id)

    try:
        notification_service = NotificationService(db)

        success = await notification_service.mark_notification_read(
            notification_id=notification_id,
            user_id=current_user.id
        )

        if not success:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Notification not found"
            )

        return MessageResponse(message="Notification marked as read")

    except HTTPException:
        raise
    except Exception as e:
        logger.error("Failed to mark notification as read", error=str(e))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to mark notification as read"
        )


@router.put("/read-all", response_model=MessageResponse)
async def mark_all_notifications_read(
    current_user: CurrentUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db_session),
) -> MessageResponse:
    """
    Mark all notifications as read.

    Marks all unread notifications as read for the current user.

    Args:
        current_user: Current authenticated user
        db: Database session

    Returns:
        MessageResponse: Success message with count
    """
    logger.info("Mark all notifications read requested", user_id=current_user.id)

    try:
        notification_service = NotificationService(db)

        count = await notification_service.mark_all_notifications_read(current_user.id)

        return MessageResponse(message=f"Marked {count} notifications as read")

    except Exception as e:
        logger.error("Failed to mark all notifications as read", error=str(e))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to mark all notifications as read"
        )


@router.delete("/{notification_id}", response_model=MessageResponse)
async def delete_notification(
    notification_id: str,
    current_user: CurrentUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db_session),
) -> MessageResponse:
    """
    Delete notification.

    Deletes (soft deletes) a specific notification for the current user.

    Args:
        notification_id: Notification ID to delete
        current_user: Current authenticated user
        db: Database session

    Returns:
        MessageResponse: Success message
    """
    logger.info("Delete notification requested", user_id=current_user.id, notification_id=notification_id)

    try:
        notification_service = NotificationService(db)

        success = await notification_service.delete_notification(
            notification_id=notification_id,
            user_id=current_user.id
        )

        if not success:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Notification not found"
            )

        return MessageResponse(message="Notification deleted")

    except HTTPException:
        raise
    except Exception as e:
        logger.error("Failed to delete notification", error=str(e))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to delete notification"
        )


@router.get("/stats", response_model=NotificationStatsResponse)
async def get_notification_statistics(
    days: int = Query(30, ge=1, le=365, description="Number of days for statistics"),
    current_user: CurrentUser = Depends(require_permissions(["notifications:stats", "admin:access"])),
    db: AsyncSession = Depends(get_db_session),
) -> NotificationStatsResponse:
    """
    Get notification statistics.

    Provides statistics about notification delivery and performance.
    Requires admin permissions.

    Args:
        days: Number of days to include in statistics
        current_user: Current authenticated user
        db: Database session

    Returns:
        NotificationStatsResponse: Notification statistics
    """
    logger.info("Notification statistics requested", user_id=current_user.id, days=days)

    try:
        notification_service = NotificationService(db)

        stats = await notification_service.get_notification_statistics(days=days)

        return NotificationStatsResponse(
            total_notifications=stats.get('total_notifications', 0),
            sent_notifications=stats.get('sent_notifications', 0),
            failed_notifications=stats.get('failed_notifications', 0),
            pending_notifications=stats.get('pending_notifications', 0),
            delivery_rate=stats.get('delivery_rate', 0.0),
            type_breakdown=stats.get('type_breakdown', {}),
            category_breakdown=stats.get('category_breakdown', {}),
            recent_activity=stats.get('recent_activity', [])
        )

    except Exception as e:
        logger.error("Failed to get notification statistics", error=str(e))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to retrieve notification statistics"
        )


@router.get("/preferences", response_model=NotificationPreferencesResponse)
async def get_notification_preferences(
    current_user: CurrentUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db_session),
) -> NotificationPreferencesResponse:
    """
    Get user notification preferences.

    Retrieves the current user's notification preferences across
    different channels and categories.

    Args:
        current_user: Current authenticated user
        db: Database session

    Returns:
        NotificationPreferencesResponse: User notification preferences
    """
    logger.debug("Notification preferences requested", user_id=current_user.id)

    try:
        notification_service = NotificationService(db)

        # This would typically get preferences from user profile or separate table
        preferences = await notification_service._get_user_notification_preferences(current_user.id)

        return NotificationPreferencesResponse(
            email_notifications=preferences.get('email_enabled', True),
            push_notifications=preferences.get('push_enabled', True),
            sms_notifications=preferences.get('sms_enabled', False),
            in_app_notifications=preferences.get('in_app_enabled', True),
            marketing_emails=preferences.get('marketing_enabled', False),
            security_alerts=preferences.get('security_enabled', True),
            frequency_settings=preferences.get('frequency_settings', {
                'security': 'immediate',
                'account': 'immediate',
                'billing': 'daily',
                'marketing': 'weekly'
            })
        )

    except Exception as e:
        logger.error("Failed to get notification preferences", error=str(e))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to retrieve notification preferences"
        )


@router.put("/preferences", response_model=MessageResponse)
async def update_notification_preferences(
    preferences: NotificationPreferencesResponse,
    current_user: CurrentUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db_session),
) -> MessageResponse:
    """
    Update user notification preferences.

    Updates the current user's notification preferences across
    different channels and categories.

    Args:
        preferences: Updated notification preferences
        current_user: Current authenticated user
        db: Database session

    Returns:
        MessageResponse: Success message
    """
    logger.info("Notification preferences update requested", user_id=current_user.id)

    try:
        notification_service = NotificationService(db)

        # Update user notification preferences
        # This would typically update user profile or separate preferences table
        preference_data = {
            'email_enabled': preferences.email_notifications,
            'push_enabled': preferences.push_notifications,
            'sms_enabled': preferences.sms_notifications,
            'in_app_enabled': preferences.in_app_notifications,
            'marketing_enabled': preferences.marketing_emails,
            'security_enabled': preferences.security_alerts,
            'frequency_settings': preferences.frequency_settings
        }

        # Cache updated preferences
        await notification_service.cache_service.set(
            f"user_notification_prefs:{current_user.id}",
            preference_data,
            ttl=3600
        )

        logger.info("Notification preferences updated", user_id=current_user.id)

        return MessageResponse(message="Notification preferences updated successfully")

    except Exception as e:
        logger.error("Failed to update notification preferences", error=str(e))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to update notification preferences"
        )
