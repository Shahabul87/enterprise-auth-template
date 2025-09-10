"""
Webhook Service

Handles webhook management and delivery with retry logic, security features,
and delivery tracking for external system integrations.
"""

import asyncio
import hashlib
import hmac
import json
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Any, Tuple
from uuid import uuid4
import aiohttp

import structlog
from sqlalchemy import select, update, and_, or_, desc, func, case
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.core.config import get_settings
from app.core.events import EventEmitter, Event
from app.models.webhook import Webhook, WebhookDelivery
from app.models.user import User
from app.services.cache_service import CacheService

settings = get_settings()
logger = structlog.get_logger(__name__)


class WebhookError(Exception):
    """Base exception for webhook-related errors."""
    pass


class WebhookValidationError(WebhookError):
    """Exception raised when webhook validation fails."""
    pass


class WebhookDeliveryError(WebhookError):
    """Exception raised when webhook delivery fails."""
    pass


class WebhookService:
    """
    Comprehensive webhook service for external integrations.

    Features:
    - Webhook registration and management
    - Secure payload signing with HMAC
    - Retry logic with exponential backoff
    - Delivery tracking and analytics
    - Event filtering and transformation
    - Rate limiting and circuit breaker pattern
    - Bulk webhook operations
    """

    def __init__(
        self,
        session: AsyncSession,
        cache_service: Optional[CacheService] = None,
        event_emitter: Optional[EventEmitter] = None
    ) -> None:
        """
        Initialize webhook service.

        Args:
            session: Database session
            cache_service: Cache service for performance optimization
            event_emitter: Event emitter for audit logging
        """
        self.session = session
        self.cache_service = cache_service or CacheService()
        self.event_emitter = event_emitter or EventEmitter()

        # HTTP client for webhook delivery
        self._http_session: Optional[aiohttp.ClientSession] = None

    async def get_http_session(self) -> aiohttp.ClientSession:
        """Get HTTP session, creating it if needed."""
        if self._http_session is None:
            connector = aiohttp.TCPConnector(
                limit=100,
                limit_per_host=20,
                ttl_dns_cache=300,
                use_dns_cache=True
            )
            timeout = aiohttp.ClientTimeout(total=30, connect=10)
            self._http_session = aiohttp.ClientSession(
                connector=connector,
                timeout=timeout,
                headers={
                    'User-Agent': f'{settings.PROJECT_NAME}/webhook-service',
                    'Content-Type': 'application/json'
                }
            )
        return self._http_session

    async def close(self) -> None:
        """Close HTTP session."""
        if self._http_session:
            await self._http_session.close()

    async def create_webhook(
        self,
        name: str,
        url: str,
        events: List[str],
        created_by: str,
        description: Optional[str] = None,
        secret: Optional[str] = None,
        headers: Optional[Dict[str, str]] = None,
        retry_count: int = 3,
        timeout_seconds: int = 30,
        organization_id: Optional[str] = None,
        metadata: Optional[Dict[str, Any]] = None
    ) -> Webhook:
        """
        Create a new webhook configuration.

        Args:
            name: Webhook name
            url: Target URL
            events: List of event types to trigger webhook
            created_by: User ID who created the webhook
            description: Optional description
            secret: Secret for HMAC signature generation
            headers: Additional headers to include
            retry_count: Number of retry attempts
            timeout_seconds: Request timeout
            organization_id: Organization ID for multi-tenancy
            metadata: Additional metadata

        Returns:
            Webhook: Created webhook object

        Raises:
            WebhookValidationError: If validation fails
        """
        try:
            # Validate creator exists
            user_stmt = select(User).where(User.id == created_by)
            result = await self.session.execute(user_stmt)
            user = result.scalar_one_or_none()

            if not user or not user.is_active:
                raise WebhookValidationError(f"User {created_by} not found or inactive")

            # Validate URL
            if not url.startswith(('http://', 'https://')):
                raise WebhookValidationError("Webhook URL must use HTTP or HTTPS")

            # Validate events
            if not events or not isinstance(events, list):
                raise WebhookValidationError("Events list cannot be empty")

            # Generate secret if not provided
            if not secret:
                secret = self._generate_webhook_secret()

            # Create webhook record
            webhook = Webhook(
                id=str(uuid4()),
                name=name,
                description=description,
                url=url,
                secret=secret,
                events=events,
                headers=headers or {},
                is_active=True,
                retry_count=retry_count,
                timeout_seconds=timeout_seconds,
                organization_id=organization_id,
                created_by=created_by,
                created_at=datetime.utcnow(),
                updated_at=datetime.utcnow(),
                success_count=0,
                failure_count=0
            )

            self.session.add(webhook)
            await self.session.flush()

            # Emit event for audit logging
            await self.event_emitter.emit(Event(
                event_type="webhook.created",
                data={
                    "webhook_id": webhook.id,
                    "name": name,
                    "url": url,
                    "events": events,
                    "created_by": created_by,
                    "organization_id": organization_id
                }
            ))

            await self.session.commit()

            logger.info(
                "Webhook created",
                webhook_id=webhook.id,
                name=name,
                url=url,
                events=events,
                created_by=created_by
            )

            return webhook

        except WebhookValidationError:
            await self.session.rollback()
            raise
        except Exception as e:
            await self.session.rollback()
            logger.error(
                "Failed to create webhook",
                name=name,
                url=url,
                created_by=created_by,
                error=str(e)
            )
            raise WebhookError(f"Failed to create webhook: {str(e)}")

    async def get_webhook(self, webhook_id: str) -> Optional[Webhook]:
        """
        Get a webhook by ID.

        Args:
            webhook_id: Webhook ID

        Returns:
            Webhook object or None if not found
        """
        try:
            stmt = select(Webhook).where(Webhook.id == webhook_id)
            result = await self.session.execute(stmt)
            return result.scalar_one_or_none()
        except Exception as e:
            logger.error("Failed to get webhook", webhook_id=webhook_id, error=str(e))
            return None

    async def get_user_webhooks(
        self,
        user_id: str,
        skip: int = 0,
        limit: int = 100,
        filters: Optional[Dict[str, Any]] = None
    ) -> Tuple[List[Webhook], int]:
        """
        Get webhooks for a specific user.

        Args:
            user_id: User ID
            skip: Number of records to skip
            limit: Maximum number of records to return
            filters: Optional filters

        Returns:
            Tuple of (webhooks list, total count)
        """
        try:
            # Build base query
            query = select(Webhook).where(Webhook.created_by == user_id)

            # Apply filters if provided
            if filters:
                if "is_active" in filters:
                    query = query.where(Webhook.is_active == filters["is_active"])
                if "event_type" in filters:
                    query = query.where(Webhook.events.contains([filters["event_type"]]))

            # Get total count
            count_stmt = select(func.count()).select_from(query.subquery())
            total_result = await self.session.execute(count_stmt)
            total_count = total_result.scalar() or 0

            # Get paginated results
            query = query.offset(skip).limit(limit).order_by(Webhook.created_at.desc())
            result = await self.session.execute(query)
            webhooks = list(result.scalars().all())

            return webhooks, total_count

        except Exception as e:
            logger.error("Failed to get user webhooks", user_id=user_id, error=str(e))
            return [], 0

    async def send_webhook_event(
        self,
        event_type: str,
        payload: Dict[str, Any],
        webhook_ids: Optional[List[str]] = None,
        user_id: Optional[str] = None,
        organization_id: Optional[str] = None
    ) -> List[str]:
        """
        Send webhook event to matching webhooks.

        Args:
            event_type: Type of event to send
            payload: Event payload
            webhook_ids: Optional list of specific webhook IDs to send to
            user_id: Optional user ID to filter webhooks
            organization_id: Optional organization ID to filter webhooks

        Returns:
            List of delivery IDs created
        """
        try:
            # Build query to find matching webhooks
            query = select(Webhook).where(
                Webhook.is_active == True,
                Webhook.events.contains([event_type])
            )

            if webhook_ids:
                query = query.where(Webhook.id.in_(webhook_ids))
            if user_id:
                query = query.where(Webhook.created_by == user_id)
            if organization_id:
                query = query.where(Webhook.organization_id == organization_id)

            result = await self.session.execute(query)
            webhooks = result.scalars().all()

            delivery_ids = []
            for webhook in webhooks:
                # Create a delivery record directly for each webhook
                delivery = WebhookDelivery(
                    id=str(uuid4()),
                    webhook_id=webhook.id,
                    event_type=event_type,
                    payload=payload,
                    status="pending",
                    attempt_count=0,
                    created_at=datetime.utcnow()
                )
                self.session.add(delivery)
                await self.session.flush()

                # Queue or deliver immediately
                await self._queue_webhook_delivery(delivery.id)
                delivery_ids.append(delivery.id)

            await self.session.commit()
            return delivery_ids

        except Exception as e:
            logger.error("Failed to send webhook event", event_type=event_type, error=str(e))
            return []

    async def retry_delivery(self, delivery_id: str) -> bool:
        """
        Retry a failed webhook delivery.

        Args:
            delivery_id: Delivery ID to retry

        Returns:
            True if retry was successful
        """
        try:
            # Get delivery
            stmt = select(WebhookDelivery).where(WebhookDelivery.id == delivery_id)
            result = await self.session.execute(stmt)
            delivery = result.scalar_one_or_none()

            if not delivery:
                logger.warning("Delivery not found for retry", delivery_id=delivery_id)
                return False

            # Reset status and attempt delivery
            delivery.status = "retrying"
            delivery.attempt_count += 1
            await self.session.commit()

            # Deliver webhook
            success = await self.deliver_webhook(delivery_id)

            return success

        except Exception as e:
            logger.error("Failed to retry delivery", delivery_id=delivery_id, error=str(e))
            return False

    async def get_system_webhook_statistics(
        self,
        time_range: str = "24h"
    ) -> Dict[str, Any]:
        """
        Get system-wide webhook statistics.

        Args:
            time_range: Time range for statistics (e.g., "24h", "7d", "30d")

        Returns:
            Dictionary containing system webhook statistics
        """
        try:
            # Parse time range
            hours_map = {"24h": 24, "7d": 168, "30d": 720}
            hours = hours_map.get(time_range, 24)
            since = datetime.utcnow() - timedelta(hours=hours)

            # Get total webhooks
            total_stmt = select(func.count(Webhook.id))
            total_result = await self.session.execute(total_stmt)
            total_webhooks = total_result.scalar() or 0

            # Get active webhooks
            active_stmt = select(func.count(Webhook.id)).where(Webhook.is_active == True)
            active_result = await self.session.execute(active_stmt)
            active_webhooks = active_result.scalar() or 0

            # Get delivery statistics
            deliveries_stmt = select(
                func.count(WebhookDelivery.id).label("total"),
                func.sum(case((WebhookDelivery.status == "success", 1), else_=0)).label("success"),
                func.sum(case((WebhookDelivery.status == "failed", 1), else_=0)).label("failed")
            ).where(WebhookDelivery.created_at >= since)

            deliveries_result = await self.session.execute(deliveries_stmt)
            delivery_stats = deliveries_result.one()

            return {
                "total_webhooks": total_webhooks,
                "active_webhooks": active_webhooks,
                "time_range": time_range,
                "deliveries": {
                    "total": delivery_stats.total or 0,
                    "success": delivery_stats.success or 0,
                    "failed": delivery_stats.failed or 0,
                    "success_rate": (
                        (delivery_stats.success / delivery_stats.total * 100)
                        if delivery_stats.total > 0 else 0
                    )
                }
            }

        except Exception as e:
            logger.error("Failed to get system webhook statistics", error=str(e))
            return {
                "total_webhooks": 0,
                "active_webhooks": 0,
                "time_range": time_range,
                "deliveries": {"total": 0, "success": 0, "failed": 0, "success_rate": 0}
            }

    async def regenerate_webhook_secret(self, webhook_id: str) -> Optional[str]:
        """
        Regenerate the secret for a webhook.

        Args:
            webhook_id: Webhook ID

        Returns:
            New secret or None if failed
        """
        try:
            # Get webhook
            stmt = select(Webhook).where(Webhook.id == webhook_id)
            result = await self.session.execute(stmt)
            webhook = result.scalar_one_or_none()

            if not webhook:
                logger.warning("Webhook not found for secret regeneration", webhook_id=webhook_id)
                return None

            # Generate new secret
            new_secret = self._generate_webhook_secret()
            webhook.secret = new_secret
            webhook.updated_at = datetime.utcnow()

            await self.session.commit()

            logger.info("Webhook secret regenerated", webhook_id=webhook_id)
            return new_secret

        except Exception as e:
            logger.error("Failed to regenerate webhook secret", webhook_id=webhook_id, error=str(e))
            await self.session.rollback()
            return None

    async def update_webhook(
        self,
        webhook_id: str,
        name: Optional[str] = None,
        description: Optional[str] = None,
        url: Optional[str] = None,
        events: Optional[List[str]] = None,
        secret: Optional[str] = None,
        headers: Optional[Dict[str, str]] = None,
        is_active: Optional[bool] = None,
        retry_count: Optional[int] = None,
        timeout_seconds: Optional[int] = None
    ) -> Webhook:
        """
        Update webhook configuration.

        Args:
            webhook_id: Webhook ID to update
            name: New name
            description: New description
            url: New URL
            events: New events list
            secret: New secret
            headers: New headers
            is_active: Active status
            retry_count: New retry count
            timeout_seconds: New timeout

        Returns:
            Webhook: Updated webhook object

        Raises:
            WebhookError: If webhook not found or update fails
        """
        try:
            # Get existing webhook
            stmt = select(Webhook).where(Webhook.id == webhook_id)
            result = await self.session.execute(stmt)
            webhook = result.scalar_one_or_none()

            if not webhook:
                raise WebhookError(f"Webhook {webhook_id} not found")

            # Update fields
            update_values = {"updated_at": datetime.utcnow()}

            if name is not None:
                update_values["name"] = name
            if description is not None:
                update_values["description"] = description
            if url is not None:
                if not url.startswith(('http://', 'https://')):
                    raise WebhookValidationError("Webhook URL must use HTTP or HTTPS")
                update_values["url"] = url
            if events is not None:
                if not events or not isinstance(events, list):
                    raise WebhookValidationError("Events list cannot be empty")
                update_values["events"] = events
            if secret is not None:
                update_values["secret"] = secret
            if headers is not None:
                update_values["headers"] = headers
            if is_active is not None:
                update_values["is_active"] = is_active
            if retry_count is not None:
                update_values["retry_count"] = retry_count
            if timeout_seconds is not None:
                update_values["timeout_seconds"] = timeout_seconds

            # Apply updates
            stmt = (
                update(Webhook)
                .where(Webhook.id == webhook_id)
                .values(**update_values)
            )
            await self.session.execute(stmt)

            # Get updated webhook
            stmt = select(Webhook).where(Webhook.id == webhook_id)
            result = await self.session.execute(stmt)
            updated_webhook = result.scalar_one()

            # Emit event for audit logging
            await self.event_emitter.emit(Event(
                event_type="webhook.updated",
                data={
                    "webhook_id": webhook_id,
                    "changes": list(update_values.keys()),
                    "updated_by": webhook.created_by  # In a full implementation, this would come from current user
                }
            ))

            await self.session.commit()

            logger.info(
                "Webhook updated",
                webhook_id=webhook_id,
                changes=list(update_values.keys())
            )

            return updated_webhook

        except (WebhookError, WebhookValidationError):
            await self.session.rollback()
            raise
        except Exception as e:
            await self.session.rollback()
            logger.error(
                "Failed to update webhook",
                webhook_id=webhook_id,
                error=str(e)
            )
            raise WebhookError(f"Failed to update webhook: {str(e)}")

    async def delete_webhook(self, webhook_id: str) -> bool:
        """
        Delete a webhook configuration.

        Args:
            webhook_id: Webhook ID to delete

        Returns:
            bool: True if deleted successfully
        """
        try:
            # Check if webhook exists
            stmt = select(Webhook).where(Webhook.id == webhook_id)
            result = await self.session.execute(stmt)
            webhook = result.scalar_one_or_none()

            if not webhook:
                return False

            # Soft delete by marking as inactive
            stmt = (
                update(Webhook)
                .where(Webhook.id == webhook_id)
                .values(
                    is_active=False,
                    updated_at=datetime.utcnow()
                )
            )
            await self.session.execute(stmt)

            # Emit event for audit logging
            await self.event_emitter.emit(Event(
                event_type="webhook.deleted",
                data={
                    "webhook_id": webhook_id,
                    "name": webhook.name,
                    "url": webhook.url
                }
            ))

            await self.session.commit()

            logger.info("Webhook deleted", webhook_id=webhook_id)
            return True

        except Exception as e:
            await self.session.rollback()
            logger.error(
                "Failed to delete webhook",
                webhook_id=webhook_id,
                error=str(e)
            )
            raise WebhookError(f"Failed to delete webhook: {str(e)}")

    async def trigger_webhook(
        self,
        event_type: str,
        payload: Dict[str, Any],
        organization_id: Optional[str] = None,
        immediate: bool = False
    ) -> List[str]:
        """
        Trigger webhooks for a specific event type.

        Args:
            event_type: Type of event that occurred
            payload: Event payload data
            organization_id: Organization ID for filtering webhooks
            immediate: Whether to deliver immediately or queue

        Returns:
            List[str]: List of webhook delivery IDs
        """
        try:
            # Find matching active webhooks
            conditions = [
                Webhook.is_active == True,
                Webhook.events.op('@>')([event_type])  # PostgreSQL array contains
            ]

            if organization_id:
                conditions.append(
                    or_(
                        Webhook.organization_id == organization_id,
                        Webhook.organization_id.is_(None)
                    )
                )

            stmt = select(Webhook).where(and_(*conditions))
            result = await self.session.execute(stmt)
            webhooks = result.scalars().all()

            if not webhooks:
                logger.debug(
                    "No webhooks found for event type",
                    event_type=event_type,
                    organization_id=organization_id
                )
                return []

            delivery_ids = []

            # Create delivery records for each webhook
            for webhook in webhooks:
                # Check circuit breaker status
                if await self._is_circuit_breaker_open(webhook.id):
                    logger.warning(
                        "Webhook circuit breaker is open, skipping delivery",
                        webhook_id=webhook.id,
                        event_type=event_type
                    )
                    continue

                # Create delivery record
                delivery = WebhookDelivery(
                    id=str(uuid4()),
                    webhook_id=webhook.id,
                    event_type=event_type,
                    payload=payload,
                    status="pending",
                    attempt_count=0,
                    created_at=datetime.utcnow()
                )

                self.session.add(delivery)
                delivery_ids.append(delivery.id)

                # Queue for delivery
                if immediate:
                    asyncio.create_task(self._deliver_webhook_async(delivery.id))
                else:
                    await self._queue_webhook_delivery(delivery.id)

            await self.session.commit()

            logger.info(
                "Webhooks triggered",
                event_type=event_type,
                webhook_count=len(webhooks),
                delivery_count=len(delivery_ids),
                organization_id=organization_id
            )

            return delivery_ids

        except Exception as e:
            await self.session.rollback()
            logger.error(
                "Failed to trigger webhooks",
                event_type=event_type,
                organization_id=organization_id,
                error=str(e)
            )
            raise WebhookError(f"Failed to trigger webhooks: {str(e)}")

    async def deliver_webhook(self, delivery_id: str) -> bool:
        """
        Deliver a specific webhook.

        Args:
            delivery_id: Webhook delivery ID

        Returns:
            bool: True if delivery successful
        """
        try:
            # Get delivery with webhook data
            stmt = (
                select(WebhookDelivery)
                .options(selectinload(WebhookDelivery.webhook))
                .where(WebhookDelivery.id == delivery_id)
            )
            result = await self.session.execute(stmt)
            delivery = result.scalar_one_or_none()

            if not delivery:
                raise WebhookError(f"Webhook delivery {delivery_id} not found")

            webhook = delivery.webhook
            if not webhook or not webhook.is_active:
                logger.warning(
                    "Webhook is inactive, cancelling delivery",
                    delivery_id=delivery_id,
                    webhook_id=webhook.id if webhook else None
                )
                await self._update_delivery_status(delivery_id, "failed", "Webhook inactive")
                return False

            # Prepare payload and headers
            payload_data = {
                "id": delivery.id,
                "event_type": delivery.event_type,
                "timestamp": delivery.created_at.isoformat(),
                "data": delivery.payload
            }

            headers = dict(webhook.headers) if webhook.headers else {}

            # Add signature if secret is configured
            if webhook.secret:
                signature = self._generate_signature(webhook.secret, json.dumps(payload_data))
                headers["X-Webhook-Signature"] = signature

            # Attempt delivery
            http_session = await self.get_http_session()

            try:
                async with http_session.post(
                    webhook.url,
                    json=payload_data,
                    headers=headers,
                    timeout=aiohttp.ClientTimeout(total=webhook.timeout_seconds)
                ) as response:
                    response_body = await response.text()

                    # Update delivery record
                    await self._update_delivery_status(
                        delivery_id,
                        "success" if response.status < 400 else "failed",
                        response_body,
                        response.status,
                        delivery.attempt_count + 1
                    )

                    # Update webhook statistics
                    if response.status < 400:
                        await self._update_webhook_stats(webhook.id, success=True)
                        await self._reset_circuit_breaker(webhook.id)

                        logger.info(
                            "Webhook delivered successfully",
                            delivery_id=delivery_id,
                            webhook_id=webhook.id,
                            status_code=response.status
                        )
                        return True
                    else:
                        await self._update_webhook_stats(webhook.id, success=False)
                        await self._increment_circuit_breaker(webhook.id)

                        logger.warning(
                            "Webhook delivery failed",
                            delivery_id=delivery_id,
                            webhook_id=webhook.id,
                            status_code=response.status,
                            response=response_body[:500]  # Limit response logging
                        )

                        # Schedule retry if attempts remaining
                        if delivery.attempt_count < webhook.retry_count:
                            await self._schedule_webhook_retry(delivery_id, delivery.attempt_count + 1)

                        return False

            except asyncio.TimeoutError:
                error_msg = f"Request timeout after {webhook.timeout_seconds}s"
                await self._handle_delivery_error(delivery_id, webhook.id, error_msg)
                return False
            except Exception as e:
                error_msg = f"HTTP request failed: {str(e)}"
                await self._handle_delivery_error(delivery_id, webhook.id, error_msg)
                return False

        except WebhookError:
            raise
        except Exception as e:
            logger.error(
                "Webhook delivery failed",
                delivery_id=delivery_id,
                error=str(e)
            )
            raise WebhookError(f"Webhook delivery failed: {str(e)}")

    async def get_webhook_deliveries(
        self,
        webhook_id: Optional[str] = None,
        event_type: Optional[str] = None,
        status: Optional[str] = None,
        limit: int = 50,
        offset: int = 0
    ) -> Tuple[List[WebhookDelivery], int]:
        """
        Get webhook deliveries with filtering.

        Args:
            webhook_id: Filter by webhook ID
            event_type: Filter by event type
            status: Filter by delivery status
            limit: Maximum number of deliveries to return
            offset: Number of deliveries to skip

        Returns:
            Tuple[List[WebhookDelivery], int]: Deliveries and total count
        """
        try:
            # Build query conditions
            conditions = []

            if webhook_id:
                conditions.append(WebhookDelivery.webhook_id == webhook_id)
            if event_type:
                conditions.append(WebhookDelivery.event_type == event_type)
            if status:
                conditions.append(WebhookDelivery.status == status)

            # Get total count
            count_stmt = select(func.count(WebhookDelivery.id))
            if conditions:
                count_stmt = count_stmt.where(and_(*conditions))

            count_result = await self.session.execute(count_stmt)
            total_count = count_result.scalar()

            # Get deliveries
            stmt = select(WebhookDelivery).options(selectinload(WebhookDelivery.webhook))
            if conditions:
                stmt = stmt.where(and_(*conditions))

            stmt = (
                stmt
                .order_by(desc(WebhookDelivery.created_at))
                .limit(limit)
                .offset(offset)
            )

            result = await self.session.execute(stmt)
            deliveries = result.scalars().all()

            return list(deliveries), total_count

        except Exception as e:
            logger.error(
                "Failed to get webhook deliveries",
                webhook_id=webhook_id,
                event_type=event_type,
                error=str(e)
            )
            raise WebhookError(f"Failed to get webhook deliveries: {str(e)}")

    async def get_webhook_statistics(
        self,
        webhook_id: str,
        days: int = 30
    ) -> Dict[str, Any]:
        """
        Get webhook delivery statistics.

        Args:
            webhook_id: Webhook ID
            days: Number of days to include in statistics

        Returns:
            Dict: Statistics data
        """
        try:
            since_date = datetime.utcnow() - timedelta(days=days)

            # Get delivery counts by status
            status_stmt = (
                select(
                    WebhookDelivery.status,
                    func.count(WebhookDelivery.id).label('count')
                )
                .where(
                    and_(
                        WebhookDelivery.webhook_id == webhook_id,
                        WebhookDelivery.created_at >= since_date
                    )
                )
                .group_by(WebhookDelivery.status)
            )

            result = await self.session.execute(status_stmt)
            status_counts = {row.status: row.count for row in result}

            # Get event type counts
            event_stmt = (
                select(
                    WebhookDelivery.event_type,
                    func.count(WebhookDelivery.id).label('count')
                )
                .where(
                    and_(
                        WebhookDelivery.webhook_id == webhook_id,
                        WebhookDelivery.created_at >= since_date
                    )
                )
                .group_by(WebhookDelivery.event_type)
            )

            result = await self.session.execute(event_stmt)
            event_counts = {row.event_type: row.count for row in result}

            # Get webhook info
            webhook_stmt = select(Webhook).where(Webhook.id == webhook_id)
            result = await self.session.execute(webhook_stmt)
            webhook = result.scalar_one_or_none()

            if not webhook:
                raise WebhookError(f"Webhook {webhook_id} not found")

            return {
                "webhook_id": webhook_id,
                "webhook_name": webhook.name,
                "period_days": days,
                "status_counts": status_counts,
                "event_counts": event_counts,
                "total_success": webhook.success_count,
                "total_failures": webhook.failure_count,
                "is_active": webhook.is_active,
                "last_triggered": webhook.last_triggered_at.isoformat() if webhook.last_triggered_at else None,
                "generated_at": datetime.utcnow().isoformat()
            }

        except WebhookError:
            raise
        except Exception as e:
            logger.error(
                "Failed to get webhook statistics",
                webhook_id=webhook_id,
                error=str(e)
            )
            raise WebhookError(f"Failed to get webhook statistics: {str(e)}")

    def _generate_webhook_secret(self) -> str:
        """Generate a secure webhook secret."""
        import secrets
        return secrets.token_urlsafe(32)

    def _generate_signature(self, secret: str, payload: str) -> str:
        """Generate HMAC signature for webhook payload."""
        signature = hmac.new(
            secret.encode('utf-8'),
            payload.encode('utf-8'),
            hashlib.sha256
        ).hexdigest()
        return f"sha256={signature}"

    async def _queue_webhook_delivery(self, delivery_id: str) -> None:
        """Queue webhook delivery for background processing."""
        # In production, this would add to a message queue (Redis, RabbitMQ, etc.)
        # For now, we'll use asyncio to deliver asynchronously
        asyncio.create_task(self._deliver_webhook_async(delivery_id))

    async def _deliver_webhook_async(self, delivery_id: str) -> None:
        """Asynchronously deliver a webhook."""
        try:
            # Small delay to prevent overwhelming external services
            await asyncio.sleep(0.5)
            await self.deliver_webhook(delivery_id)
        except Exception as e:
            logger.error(
                "Async webhook delivery failed",
                delivery_id=delivery_id,
                error=str(e)
            )

    async def _update_delivery_status(
        self,
        delivery_id: str,
        status: str,
        response_body: Optional[str] = None,
        status_code: Optional[int] = None,
        attempt_count: Optional[int] = None
    ) -> None:
        """Update webhook delivery status."""
        update_values = {
            "status": status,
        }

        if response_body is not None:
            update_values["response_body"] = response_body[:1000]  # Limit size
        if status_code is not None:
            update_values["response_status"] = status_code
        if attempt_count is not None:
            update_values["attempt_count"] = attempt_count

        if status == "success":
            update_values["delivered_at"] = datetime.utcnow()

        stmt = (
            update(WebhookDelivery)
            .where(WebhookDelivery.id == delivery_id)
            .values(**update_values)
        )
        await self.session.execute(stmt)
        await self.session.commit()

    async def _update_webhook_stats(self, webhook_id: str, success: bool) -> None:
        """Update webhook success/failure statistics."""
        if success:
            update_values = {
                "success_count": Webhook.success_count + 1,
                "last_triggered_at": datetime.utcnow()
            }
        else:
            update_values = {
                "failure_count": Webhook.failure_count + 1
            }

        stmt = (
            update(Webhook)
            .where(Webhook.id == webhook_id)
            .values(**update_values)
        )
        await self.session.execute(stmt)
        await self.session.commit()

    async def _handle_delivery_error(
        self,
        delivery_id: str,
        webhook_id: str,
        error_message: str
    ) -> None:
        """Handle webhook delivery error."""
        await self._update_delivery_status(delivery_id, "failed", error_message)
        await self._update_webhook_stats(webhook_id, success=False)
        await self._increment_circuit_breaker(webhook_id)

    async def _schedule_webhook_retry(
        self,
        delivery_id: str,
        attempt_count: int
    ) -> None:
        """Schedule webhook retry with exponential backoff."""
        # Exponential backoff: 2^attempt minutes (2, 4, 8 minutes)
        delay_minutes = min(2 ** attempt_count, 60)  # Cap at 1 hour
        retry_at = datetime.utcnow() + timedelta(minutes=delay_minutes)

        stmt = (
            update(WebhookDelivery)
            .where(WebhookDelivery.id == delivery_id)
            .values(
                next_retry_at=retry_at,
                attempt_count=attempt_count
            )
        )
        await self.session.execute(stmt)
        await self.session.commit()

        # Schedule the retry
        asyncio.create_task(self._retry_webhook_after_delay(delivery_id, delay_minutes * 60))

    async def _retry_webhook_after_delay(self, delivery_id: str, delay_seconds: int) -> None:
        """Retry webhook delivery after delay."""
        await asyncio.sleep(delay_seconds)
        try:
            await self.deliver_webhook(delivery_id)
        except Exception as e:
            logger.error(
                "Webhook retry failed",
                delivery_id=delivery_id,
                error=str(e)
            )

    async def _is_circuit_breaker_open(self, webhook_id: str) -> bool:
        """Check if circuit breaker is open for webhook."""
        cache_key = f"webhook_circuit_breaker:{webhook_id}"
        failure_count = await self.cache_service.get(cache_key)

        if failure_count is None:
            return False

        # Open circuit if more than 10 failures in the last hour
        return int(failure_count) > 10

    async def _increment_circuit_breaker(self, webhook_id: str) -> None:
        """Increment circuit breaker failure count."""
        cache_key = f"webhook_circuit_breaker:{webhook_id}"
        current_count = await self.cache_service.get(cache_key) or 0
        await self.cache_service.set(cache_key, int(current_count) + 1, ttl=3600)

    async def _reset_circuit_breaker(self, webhook_id: str) -> None:
        """Reset circuit breaker for webhook."""
        cache_key = f"webhook_circuit_breaker:{webhook_id}"
        await self.cache_service.delete(cache_key)


# Global instance
webhook_service = WebhookService
