"""
Notification Service

Handles all notification delivery operations including email, SMS, push notifications,
and in-app notifications with proper queuing, retry logic, and delivery tracking.
"""

import asyncio
import json
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Any, Tuple, Union
from uuid import uuid4

import structlog
from sqlalchemy import select, update, and_, or_, desc, func
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.core.config import get_settings
from app.core.events import EventEmitter, Event
from app.models.notification import (
    Notification,
    NotificationType,
    NotificationPriority,
    NotificationStatus,
    NotificationCategory,
)
from app.models.user import User
from app.services.cache_service import CacheService

settings = get_settings()
logger = structlog.get_logger(__name__)


class NotificationError(Exception):
    """Base exception for notification-related errors."""

    pass


class NotificationDeliveryError(NotificationError):
    """Exception raised when notification delivery fails."""

    pass


class NotificationValidationError(NotificationError):
    """Exception raised when notification data validation fails."""

    pass


class NotificationService:
    """
    Comprehensive notification service handling multiple delivery channels.

    Features:
    - Multiple delivery channels (email, SMS, push, in-app, webhook)
    - Priority-based queuing and delivery
    - Retry logic with exponential backoff
    - Delivery tracking and analytics
    - Batch notifications for performance
    - Template management and personalization
    - User preference management
    """

    def __init__(
        self,
        session: AsyncSession,
        cache_service: Optional[CacheService] = None,
        event_emitter: Optional[EventEmitter] = None,
    ) -> None:
        """
        Initialize notification service.

        Args:
            session: Database session
            cache_service: Cache service for performance optimization
            event_emitter: Event emitter for audit logging
        """
        self.session = session
        self.cache_service = cache_service or CacheService()
        self.event_emitter = event_emitter or EventEmitter()

        # Delivery providers
        self._providers: Dict[NotificationType, Any] = {}
        self._initialize_providers()

    def _initialize_providers(self) -> None:
        """Initialize notification delivery providers."""
        try:
            # Email provider
            from app.services.enhanced_email_service import enhanced_email_service

            self._providers[NotificationType.EMAIL] = enhanced_email_service

            # SMS provider (if configured)
            if hasattr(settings, "SMS_PROVIDER_URL") and settings.SMS_PROVIDER_URL:
                from app.services.sms_service import sms_service

                self._providers[NotificationType.SMS] = sms_service

            # Push notification provider (if configured)
            if (
                hasattr(settings, "PUSH_NOTIFICATION_KEY")
                and settings.PUSH_NOTIFICATION_KEY
            ):
                from app.services.push_service import push_service

                self._providers[NotificationType.PUSH] = push_service

        except ImportError as e:
            logger.warning(
                "Failed to initialize some notification providers", error=str(e)
            )

    async def create_notification(
        self,
        user_id: str,
        title: str,
        message: str,
        notification_type: NotificationType,
        priority: NotificationPriority = NotificationPriority.NORMAL,
        category: NotificationCategory = NotificationCategory.ACCOUNT,
        data: Optional[Dict[str, Any]] = None,
        template_id: Optional[str] = None,
        scheduled_at: Optional[datetime] = None,
        expires_at: Optional[datetime] = None,
        metadata: Optional[Dict[str, Any]] = None,
    ) -> Notification:
        """
        Create a new notification.

        Args:
            user_id: Target user ID
            title: Notification title
            message: Notification message
            notification_type: Type of notification to send
            priority: Notification priority level
            category: Notification category
            data: Additional structured data
            template_id: Template ID for styled notifications
            scheduled_at: When to deliver the notification
            expires_at: When the notification expires
            metadata: Additional metadata

        Returns:
            Notification: Created notification object

        Raises:
            NotificationValidationError: If validation fails
        """
        try:
            # Validate user exists
            user_stmt = select(User).where(User.id == user_id)
            result = await self.session.execute(user_stmt)
            user = result.scalar_one_or_none()

            if not user or not user.is_active:
                raise NotificationValidationError(
                    f"User {user_id} not found or inactive"
                )

            # Check user notification preferences
            user_preferences = await self._get_user_notification_preferences(user_id)
            if not self._is_notification_allowed(
                notification_type, category, user_preferences
            ):
                logger.info(
                    "Notification blocked by user preferences",
                    user_id=user_id,
                    type=notification_type,
                    category=category,
                )
                # Still create the notification but mark as cancelled
                notification_type = NotificationType.IN_APP
                priority = NotificationPriority.LOW

            # Create notification record
            notification = Notification(
                id=str(uuid4()),
                user_id=user_id,
                title=title,
                message=message,
                type=notification_type,
                priority=priority,
                category=category,
                status=NotificationStatus.PENDING,
                data=data or {},
                template_id=template_id,
                scheduled_at=scheduled_at or datetime.utcnow(),
                expires_at=expires_at,
                metadata=metadata or {},
                created_at=datetime.utcnow(),
                updated_at=datetime.utcnow(),
            )

            self.session.add(notification)
            await self.session.flush()

            # Emit event for audit logging
            await self.event_emitter.emit(
                Event(
                    type="notification.created",
                    data={
                        "notification_id": notification.id,
                        "user_id": user_id,
                        "type": notification_type,
                        "priority": priority,
                        "category": category,
                        "scheduled_at": (
                            scheduled_at.isoformat() if scheduled_at else None
                        ),
                    },
                )
            )

            # Schedule immediate delivery if not scheduled for later
            if not scheduled_at or scheduled_at <= datetime.utcnow():
                await self._queue_notification_for_delivery(notification)

            await self.session.commit()

            logger.info(
                "Notification created",
                notification_id=notification.id,
                user_id=user_id,
                type=notification_type,
                priority=priority,
            )

            return notification

        except NotificationValidationError:
            await self.session.rollback()
            raise
        except Exception as e:
            await self.session.rollback()
            logger.error(
                "Failed to create notification",
                user_id=user_id,
                type=notification_type,
                error=str(e),
            )
            raise NotificationError(f"Failed to create notification: {str(e)}")

    async def send_notification(
        self, notification_id: str, force_delivery: bool = False
    ) -> bool:
        """
        Send a specific notification immediately.

        Args:
            notification_id: Notification ID to send
            force_delivery: Override user preferences and rate limits

        Returns:
            bool: True if delivery was attempted successfully

        Raises:
            NotificationError: If notification not found or delivery fails
        """
        try:
            # Get notification with user data
            stmt = (
                select(Notification)
                .options(selectinload(Notification.user))
                .where(Notification.id == notification_id)
            )
            result = await self.session.execute(stmt)
            notification = result.scalar_one_or_none()

            if not notification:
                raise NotificationError(f"Notification {notification_id} not found")

            # Check if already sent
            if notification.status in [
                NotificationStatus.SENT,
                NotificationStatus.DELIVERED,
            ]:
                logger.info(
                    "Notification already sent", notification_id=notification_id
                )
                return True

            # Check if expired
            if notification.expires_at and notification.expires_at < datetime.utcnow():
                await self._update_notification_status(
                    notification_id,
                    NotificationStatus.CANCELLED,
                    "Notification expired",
                )
                return False

            # Apply rate limiting unless forced
            if not force_delivery:
                rate_limit_ok = await self._check_rate_limit(
                    notification.user_id, notification.type, notification.category
                )
                if not rate_limit_ok:
                    logger.warning(
                        "Notification delivery rate limited",
                        notification_id=notification_id,
                        user_id=notification.user_id,
                    )
                    # Reschedule for later
                    await self._reschedule_notification(notification, minutes=15)
                    return False

            # Attempt delivery
            success = await self._deliver_notification(notification)

            if success:
                await self._update_notification_status(
                    notification_id,
                    NotificationStatus.SENT,
                    f"Successfully delivered via {notification.type}",
                )

                # Update delivery statistics
                await self._update_delivery_stats(
                    notification.user_id, notification.type, True
                )

                logger.info(
                    "Notification delivered successfully",
                    notification_id=notification_id,
                    type=notification.type,
                )

            else:
                await self._handle_delivery_failure(notification)

            return success

        except NotificationError:
            raise
        except Exception as e:
            logger.error(
                "Notification delivery failed",
                notification_id=notification_id,
                error=str(e),
            )
            await self._handle_delivery_failure(
                notification if "notification" in locals() else None, error=str(e)
            )
            raise NotificationError(f"Notification delivery failed: {str(e)}")

    async def send_bulk_notifications(
        self, notifications: List[Dict[str, Any]], batch_size: int = 50
    ) -> Dict[str, Any]:
        """
        Send multiple notifications efficiently in batches.

        Args:
            notifications: List of notification data dictionaries
            batch_size: Number of notifications to process per batch

        Returns:
            Dict: Statistics about the bulk operation
        """
        try:
            total_count = len(notifications)
            success_count = 0
            failed_count = 0
            created_notifications: List[Notification] = []

            # Process in batches to avoid memory issues
            for i in range(0, total_count, batch_size):
                batch = notifications[i : i + batch_size]
                batch_results = await self._process_notification_batch(batch)

                created_notifications.extend(batch_results["created"])
                success_count += batch_results["success"]
                failed_count += batch_results["failed"]

                # Small delay between batches to prevent overwhelming the system
                if i + batch_size < total_count:
                    await asyncio.sleep(0.1)

            # Schedule delivery for all created notifications
            delivery_tasks = [
                self._queue_notification_for_delivery(notification)
                for notification in created_notifications
            ]

            if delivery_tasks:
                await asyncio.gather(*delivery_tasks, return_exceptions=True)

            await self.session.commit()

            logger.info(
                "Bulk notification creation completed",
                total=total_count,
                success=success_count,
                failed=failed_count,
                batches=len(range(0, total_count, batch_size)),
            )

            return {
                "total": total_count,
                "success": success_count,
                "failed": failed_count,
                "created_notifications": [n.id for n in created_notifications],
            }

        except Exception as e:
            await self.session.rollback()
            logger.error("Bulk notification creation failed", error=str(e))
            raise NotificationError(f"Bulk notification creation failed: {str(e)}")

    async def get_user_notifications(
        self,
        user_id: str,
        limit: int = 50,
        offset: int = 0,
        status_filter: Optional[NotificationStatus] = None,
        category_filter: Optional[NotificationCategory] = None,
        unread_only: bool = False,
    ) -> Tuple[List[Notification], int]:
        """
        Get notifications for a user with filtering and pagination.

        Args:
            user_id: User ID
            limit: Maximum number of notifications to return
            offset: Number of notifications to skip
            status_filter: Filter by notification status
            category_filter: Filter by notification category
            unread_only: Only return unread notifications

        Returns:
            Tuple[List[Notification], int]: Notifications and total count
        """
        try:
            # Build query conditions
            conditions = [Notification.user_id == user_id]

            if status_filter:
                conditions.append(Notification.status == status_filter)

            if category_filter:
                conditions.append(Notification.category == category_filter)

            if unread_only:
                conditions.append(Notification.read_at.is_(None))

            # Get total count
            count_stmt = select(func.count(Notification.id)).where(and_(*conditions))
            count_result = await self.session.execute(count_stmt)
            total_count = count_result.scalar()

            # Get notifications
            stmt = (
                select(Notification)
                .where(and_(*conditions))
                .order_by(desc(Notification.created_at))
                .limit(limit)
                .offset(offset)
            )
            result = await self.session.execute(stmt)
            notifications = result.scalars().all()

            return list(notifications), total_count

        except Exception as e:
            logger.error(
                "Failed to get user notifications", user_id=user_id, error=str(e)
            )
            raise NotificationError(f"Failed to get user notifications: {str(e)}")

    async def mark_notification_read(self, notification_id: str, user_id: str) -> bool:
        """
        Mark a notification as read.

        Args:
            notification_id: Notification ID
            user_id: User ID (for authorization)

        Returns:
            bool: True if marked as read successfully
        """
        try:
            stmt = (
                update(Notification)
                .where(
                    and_(
                        Notification.id == notification_id,
                        Notification.user_id == user_id,
                    )
                )
                .values(read_at=datetime.utcnow(), updated_at=datetime.utcnow())
            )
            result = await self.session.execute(stmt)
            await self.session.commit()

            success = result.rowcount > 0
            if success:
                logger.debug(
                    "Notification marked as read",
                    notification_id=notification_id,
                    user_id=user_id,
                )

            return success

        except Exception as e:
            await self.session.rollback()
            logger.error(
                "Failed to mark notification as read",
                notification_id=notification_id,
                user_id=user_id,
                error=str(e),
            )
            raise NotificationError(f"Failed to mark notification as read: {str(e)}")

    async def mark_all_notifications_read(self, user_id: str) -> int:
        """
        Mark all unread notifications as read for a user.

        Args:
            user_id: User ID

        Returns:
            int: Number of notifications marked as read
        """
        try:
            stmt = (
                update(Notification)
                .where(
                    and_(
                        Notification.user_id == user_id, Notification.read_at.is_(None)
                    )
                )
                .values(read_at=datetime.utcnow(), updated_at=datetime.utcnow())
            )
            result = await self.session.execute(stmt)
            await self.session.commit()

            count = result.rowcount
            logger.info(
                "All notifications marked as read", user_id=user_id, count=count
            )

            return count

        except Exception as e:
            await self.session.rollback()
            logger.error(
                "Failed to mark all notifications as read",
                user_id=user_id,
                error=str(e),
            )
            raise NotificationError(
                f"Failed to mark all notifications as read: {str(e)}"
            )

    async def delete_notification(self, notification_id: str, user_id: str) -> bool:
        """
        Delete a notification (soft delete by marking as cancelled).

        Args:
            notification_id: Notification ID
            user_id: User ID (for authorization)

        Returns:
            bool: True if deleted successfully
        """
        try:
            stmt = (
                update(Notification)
                .where(
                    and_(
                        Notification.id == notification_id,
                        Notification.user_id == user_id,
                    )
                )
                .values(
                    status=NotificationStatus.CANCELLED, updated_at=datetime.utcnow()
                )
            )
            result = await self.session.execute(stmt)
            await self.session.commit()

            success = result.rowcount > 0
            if success:
                logger.info(
                    "Notification deleted",
                    notification_id=notification_id,
                    user_id=user_id,
                )

            return success

        except Exception as e:
            await self.session.rollback()
            logger.error(
                "Failed to delete notification",
                notification_id=notification_id,
                user_id=user_id,
                error=str(e),
            )
            raise NotificationError(f"Failed to delete notification: {str(e)}")

    async def get_notification_statistics(
        self, user_id: Optional[str] = None, days: int = 30
    ) -> Dict[str, Any]:
        """
        Get notification delivery statistics.

        Args:
            user_id: User ID (None for system-wide stats)
            days: Number of days to include in statistics

        Returns:
            Dict: Statistics data
        """
        try:
            since_date = datetime.utcnow() - timedelta(days=days)
            conditions = [Notification.created_at >= since_date]

            if user_id:
                conditions.append(Notification.user_id == user_id)

            # Get overall counts
            base_query = select(Notification).where(and_(*conditions))

            # Count by status
            status_counts = {}
            for status in NotificationStatus:
                status_stmt = select(func.count()).select_from(
                    base_query.filter(Notification.status == status).subquery()
                )
                result = await self.session.execute(status_stmt)
                status_counts[status.value] = result.scalar()

            # Count by type
            type_counts = {}
            for ntype in NotificationType:
                type_stmt = select(func.count()).select_from(
                    base_query.filter(Notification.type == ntype).subquery()
                )
                result = await self.session.execute(type_stmt)
                type_counts[ntype.value] = result.scalar()

            # Count by category
            category_counts = {}
            for category in NotificationCategory:
                cat_stmt = select(func.count()).select_from(
                    base_query.filter(Notification.category == category).subquery()
                )
                result = await self.session.execute(cat_stmt)
                category_counts[category.value] = result.scalar()

            return {
                "period_days": days,
                "user_id": user_id,
                "status_counts": status_counts,
                "type_counts": type_counts,
                "category_counts": category_counts,
                "generated_at": datetime.utcnow().isoformat(),
            }

        except Exception as e:
            logger.error(
                "Failed to get notification statistics",
                user_id=user_id,
                days=days,
                error=str(e),
            )
            raise NotificationError(f"Failed to get notification statistics: {str(e)}")

    async def _deliver_notification(self, notification: Notification) -> bool:
        """
        Deliver notification using appropriate provider.

        Args:
            notification: Notification to deliver

        Returns:
            bool: True if delivery successful
        """
        try:
            provider = self._providers.get(notification.type)
            if not provider:
                logger.warning(
                    "No provider available for notification type",
                    type=notification.type,
                    notification_id=notification.id,
                )
                return False

            # Prepare delivery data based on type
            if notification.type == NotificationType.EMAIL:
                success = await self._deliver_email_notification(notification, provider)
            elif notification.type == NotificationType.SMS:
                success = await self._deliver_sms_notification(notification, provider)
            elif notification.type == NotificationType.PUSH:
                success = await self._deliver_push_notification(notification, provider)
            else:
                # In-app notifications are always "delivered" as they're stored in DB
                success = True

            return success

        except Exception as e:
            logger.error(
                "Notification delivery provider failed",
                notification_id=notification.id,
                type=notification.type,
                error=str(e),
            )
            return False

    async def _deliver_email_notification(
        self, notification: Notification, provider: Any
    ) -> bool:
        """Deliver email notification."""
        try:
            await provider.send_notification_email(
                to_email=notification.user.email,
                user_name=notification.user.full_name,
                title=notification.title,
                message=notification.message,
                category=notification.category,
                data=notification.data,
                template_id=notification.template_id,
            )
            return True
        except Exception as e:
            logger.error(
                "Email notification delivery failed",
                notification_id=notification.id,
                error=str(e),
            )
            return False

    async def _deliver_sms_notification(
        self, notification: Notification, provider: Any
    ) -> bool:
        """Deliver SMS notification."""
        try:
            # SMS delivery would depend on user having a phone number
            phone = getattr(notification.user, "phone_number", None)
            if not phone:
                logger.warning(
                    "Cannot send SMS - user has no phone number",
                    notification_id=notification.id,
                    user_id=notification.user_id,
                )
                return False

            await provider.send_sms(
                to_phone=phone,
                message=f"{notification.title}: {notification.message}",
                data=notification.data,
            )
            return True
        except Exception as e:
            logger.error(
                "SMS notification delivery failed",
                notification_id=notification.id,
                error=str(e),
            )
            return False

    async def _deliver_push_notification(
        self, notification: Notification, provider: Any
    ) -> bool:
        """Deliver push notification."""
        try:
            # Push delivery would require device tokens
            await provider.send_push(
                user_id=notification.user_id,
                title=notification.title,
                message=notification.message,
                data=notification.data,
            )
            return True
        except Exception as e:
            logger.error(
                "Push notification delivery failed",
                notification_id=notification.id,
                error=str(e),
            )
            return False

    async def _get_user_notification_preferences(self, user_id: str) -> Dict[str, Any]:
        """Get user notification preferences from cache or database."""
        cache_key = f"user_notification_prefs:{user_id}"

        preferences = await self.cache_service.get(cache_key)
        if preferences:
            return json.loads(preferences)

        # Default preferences if not set
        default_preferences = {
            "email_enabled": True,
            "sms_enabled": False,
            "push_enabled": True,
            "in_app_enabled": True,
            "categories": {
                "security": {"email": True, "sms": False, "push": True},
                "account": {"email": True, "sms": False, "push": False},
                "billing": {"email": True, "sms": False, "push": False},
                "marketing": {"email": False, "sms": False, "push": False},
            },
        }

        # Cache for 1 hour
        await self.cache_service.set(
            cache_key, json.dumps(default_preferences), ttl=3600
        )

        return default_preferences

    def _is_notification_allowed(
        self,
        notification_type: NotificationType,
        category: NotificationCategory,
        preferences: Dict[str, Any],
    ) -> bool:
        """Check if notification is allowed based on user preferences."""
        # Check global type preference
        type_key = f"{notification_type.value}_enabled"
        if not preferences.get(type_key, True):
            return False

        # Check category-specific preference
        category_prefs = preferences.get("categories", {}).get(category.value, {})
        return category_prefs.get(notification_type.value, True)

    async def _check_rate_limit(
        self,
        user_id: str,
        notification_type: NotificationType,
        category: NotificationCategory,
    ) -> bool:
        """Check rate limit for user/type/category combination."""
        cache_key = f"notification_rate_limit:{user_id}:{notification_type.value}:{category.value}"

        # Different limits based on type and category
        limits = {
            NotificationType.EMAIL: 100,  # per hour
            NotificationType.SMS: 10,  # per hour
            NotificationType.PUSH: 50,  # per hour
            NotificationType.IN_APP: 200,  # per hour
        }

        limit = limits.get(notification_type, 50)
        current_count = await self.cache_service.get(cache_key) or 0

        if int(current_count) >= limit:
            return False

        # Increment counter with 1-hour TTL
        await self.cache_service.set(cache_key, int(current_count) + 1, ttl=3600)
        return True

    async def _queue_notification_for_delivery(
        self, notification: Notification
    ) -> None:
        """Queue notification for immediate delivery."""
        # In a production environment, this would add to a message queue
        # For now, we'll use asyncio to deliver asynchronously
        asyncio.create_task(self._deliver_notification_async(notification.id))

    async def _deliver_notification_async(self, notification_id: str) -> None:
        """Asynchronously deliver a notification."""
        try:
            await asyncio.sleep(0.1)  # Small delay to prevent overwhelming
            await self.send_notification(notification_id)
        except Exception as e:
            logger.error(
                "Async notification delivery failed",
                notification_id=notification_id,
                error=str(e),
            )

    async def _update_notification_status(
        self,
        notification_id: str,
        status: NotificationStatus,
        error_message: Optional[str] = None,
    ) -> None:
        """Update notification status."""
        update_values = {"status": status, "updated_at": datetime.utcnow()}

        if status == NotificationStatus.SENT:
            update_values["sent_at"] = datetime.utcnow()
        elif status == NotificationStatus.DELIVERED:
            update_values["delivered_at"] = datetime.utcnow()
        elif status == NotificationStatus.FAILED:
            update_values["error_message"] = error_message

        stmt = (
            update(Notification)
            .where(Notification.id == notification_id)
            .values(**update_values)
        )
        await self.session.execute(stmt)
        await self.session.commit()

    async def _handle_delivery_failure(
        self, notification: Optional[Notification], error: Optional[str] = None
    ) -> None:
        """Handle notification delivery failure with retry logic."""
        if not notification:
            return

        # Increment retry count
        retry_count = notification.retry_count + 1
        max_retries = 3

        if retry_count < max_retries:
            # Schedule retry with exponential backoff
            delay_minutes = 2**retry_count  # 2, 4, 8 minutes
            retry_at = datetime.utcnow() + timedelta(minutes=delay_minutes)

            stmt = (
                update(Notification)
                .where(Notification.id == notification.id)
                .values(
                    retry_count=retry_count,
                    scheduled_at=retry_at,
                    error_message=error,
                    updated_at=datetime.utcnow(),
                )
            )
            await self.session.execute(stmt)

            logger.warning(
                "Notification delivery failed, scheduling retry",
                notification_id=notification.id,
                retry_count=retry_count,
                retry_at=retry_at.isoformat(),
                error=error,
            )
        else:
            # Max retries reached, mark as failed
            await self._update_notification_status(
                notification.id,
                NotificationStatus.FAILED,
                error or "Max retries exceeded",
            )

    async def _reschedule_notification(
        self, notification: Notification, minutes: int
    ) -> None:
        """Reschedule notification for later delivery."""
        new_time = datetime.utcnow() + timedelta(minutes=minutes)

        stmt = (
            update(Notification)
            .where(Notification.id == notification.id)
            .values(scheduled_at=new_time, updated_at=datetime.utcnow())
        )
        await self.session.execute(stmt)
        await self.session.commit()

    async def _update_delivery_stats(
        self, user_id: str, notification_type: NotificationType, success: bool
    ) -> None:
        """Update delivery statistics."""
        cache_key = f"notification_stats:{user_id}:{notification_type.value}"

        stats = await self.cache_service.get(cache_key)
        if stats:
            stats = json.loads(stats)
        else:
            stats = {"sent": 0, "delivered": 0, "failed": 0}

        if success:
            stats["delivered"] += 1
        else:
            stats["failed"] += 1

        # Cache for 24 hours
        await self.cache_service.set(cache_key, json.dumps(stats), ttl=86400)

    async def _process_notification_batch(
        self, batch: List[Dict[str, Any]]
    ) -> Dict[str, Any]:
        """Process a batch of notifications."""
        created = []
        success = 0
        failed = 0

        for notification_data in batch:
            try:
                notification = await self.create_notification(**notification_data)
                created.append(notification)
                success += 1
            except Exception as e:
                logger.error(
                    "Failed to create notification in batch",
                    data=notification_data,
                    error=str(e),
                )
                failed += 1

        return {"created": created, "success": success, "failed": failed}


# Global instance
notification_service = NotificationService
