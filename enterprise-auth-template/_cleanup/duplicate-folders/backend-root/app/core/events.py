"""
Event system for the application.
Provides event publishing and subscription functionality for decoupled communication.
"""
import asyncio
from typing import Dict, List, Callable, Any, Optional, Set
from datetime import datetime
from dataclasses import dataclass, asdict
from enum import Enum
import logging
import json
from functools import wraps

logger = logging.getLogger(__name__)


class EventType(str, Enum):
    """System event types."""
    # User events
    USER_REGISTERED = "user.registered"
    USER_LOGGED_IN = "user.logged_in"
    USER_LOGGED_OUT = "user.logged_out"
    USER_UPDATED = "user.updated"
    USER_DELETED = "user.deleted"
    USER_VERIFIED = "user.verified"
    USER_PASSWORD_CHANGED = "user.password_changed"
    USER_PASSWORD_RESET = "user.password_reset"
    USER_LOCKED = "user.locked"
    USER_UNLOCKED = "user.unlocked"
    
    # Authentication events
    AUTH_FAILED = "auth.failed"
    AUTH_2FA_ENABLED = "auth.2fa_enabled"
    AUTH_2FA_DISABLED = "auth.2fa_disabled"
    AUTH_TOKEN_CREATED = "auth.token_created"
    AUTH_TOKEN_REVOKED = "auth.token_revoked"
    
    # Session events
    SESSION_CREATED = "session.created"
    SESSION_EXPIRED = "session.expired"
    SESSION_REVOKED = "session.revoked"
    
    # Role and permission events
    ROLE_CREATED = "role.created"
    ROLE_UPDATED = "role.updated"
    ROLE_DELETED = "role.deleted"
    ROLE_ASSIGNED = "role.assigned"
    ROLE_REVOKED = "role.revoked"
    PERMISSION_GRANTED = "permission.granted"
    PERMISSION_REVOKED = "permission.revoked"
    
    # Organization events
    ORG_CREATED = "organization.created"
    ORG_UPDATED = "organization.updated"
    ORG_DELETED = "organization.deleted"
    ORG_MEMBER_ADDED = "organization.member_added"
    ORG_MEMBER_REMOVED = "organization.member_removed"
    
    # API key events
    API_KEY_CREATED = "api_key.created"
    API_KEY_REVOKED = "api_key.revoked"
    API_KEY_USED = "api_key.used"
    
    # Webhook events
    WEBHOOK_CREATED = "webhook.created"
    WEBHOOK_UPDATED = "webhook.updated"
    WEBHOOK_DELETED = "webhook.deleted"
    WEBHOOK_TRIGGERED = "webhook.triggered"
    WEBHOOK_FAILED = "webhook.failed"
    
    # Notification events
    NOTIFICATION_SENT = "notification.sent"
    NOTIFICATION_FAILED = "notification.failed"
    NOTIFICATION_READ = "notification.read"
    
    # Security events
    SECURITY_ALERT = "security.alert"
    SECURITY_BREACH_ATTEMPT = "security.breach_attempt"
    RATE_LIMIT_EXCEEDED = "security.rate_limit_exceeded"
    SUSPICIOUS_ACTIVITY = "security.suspicious_activity"
    
    # System events
    SYSTEM_STARTUP = "system.startup"
    SYSTEM_SHUTDOWN = "system.shutdown"
    SYSTEM_ERROR = "system.error"
    SYSTEM_MAINTENANCE = "system.maintenance"
    
    # Database events
    DATABASE_BACKUP_STARTED = "database.backup_started"
    DATABASE_BACKUP_COMPLETED = "database.backup_completed"
    DATABASE_MIGRATION_STARTED = "database.migration_started"
    DATABASE_MIGRATION_COMPLETED = "database.migration_completed"


@dataclass
class Event:
    """Base event class."""
    type: EventType
    timestamp: datetime
    data: Dict[str, Any]
    metadata: Optional[Dict[str, Any]] = None
    user_id: Optional[str] = None
    organization_id: Optional[str] = None
    session_id: Optional[str] = None
    correlation_id: Optional[str] = None
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert event to dictionary."""
        return {
            "type": self.type.value,
            "timestamp": self.timestamp.isoformat(),
            "data": self.data,
            "metadata": self.metadata or {},
            "user_id": self.user_id,
            "organization_id": self.organization_id,
            "session_id": self.session_id,
            "correlation_id": self.correlation_id
        }
    
    def to_json(self) -> str:
        """Convert event to JSON string."""
        return json.dumps(self.to_dict(), default=str)


class EventBus:
    """Central event bus for publishing and subscribing to events."""
    
    _instance: Optional['EventBus'] = None
    
    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
            cls._instance._initialized = False
        return cls._instance
    
    def __init__(self):
        if self._initialized:
            return
        
        self._subscribers: Dict[EventType, List[Callable]] = {}
        self._async_subscribers: Dict[EventType, List[Callable]] = {}
        self._middleware: List[Callable] = []
        self._event_history: List[Event] = []
        self._max_history_size = 1000
        self._initialized = True
    
    def subscribe(self, event_type: EventType, handler: Callable) -> None:
        """Subscribe to an event type."""
        if asyncio.iscoroutinefunction(handler):
            if event_type not in self._async_subscribers:
                self._async_subscribers[event_type] = []
            self._async_subscribers[event_type].append(handler)
        else:
            if event_type not in self._subscribers:
                self._subscribers[event_type] = []
            self._subscribers[event_type].append(handler)
        
        logger.debug(f"Subscribed handler {handler.__name__} to event {event_type.value}")
    
    def unsubscribe(self, event_type: EventType, handler: Callable) -> None:
        """Unsubscribe from an event type."""
        if asyncio.iscoroutinefunction(handler):
            if event_type in self._async_subscribers:
                self._async_subscribers[event_type].remove(handler)
        else:
            if event_type in self._subscribers:
                self._subscribers[event_type].remove(handler)
        
        logger.debug(f"Unsubscribed handler {handler.__name__} from event {event_type.value}")
    
    def add_middleware(self, middleware: Callable) -> None:
        """Add middleware to process events before handlers."""
        self._middleware.append(middleware)
    
    async def publish(self, event: Event) -> None:
        """Publish an event to all subscribers."""
        # Store in history
        self._event_history.append(event)
        if len(self._event_history) > self._max_history_size:
            self._event_history.pop(0)
        
        # Apply middleware
        for middleware in self._middleware:
            if asyncio.iscoroutinefunction(middleware):
                event = await middleware(event)
            else:
                event = middleware(event)
            
            if event is None:
                logger.debug(f"Event {event.type.value} filtered by middleware")
                return
        
        logger.info(
            f"Publishing event: {event.type.value}",
            extra={
                "event_data": event.data,
                "user_id": event.user_id,
                "correlation_id": event.correlation_id
            }
        )
        
        # Call sync subscribers
        if event.type in self._subscribers:
            for handler in self._subscribers[event.type]:
                try:
                    handler(event)
                except Exception as e:
                    logger.error(
                        f"Error in event handler {handler.__name__}: {str(e)}",
                        exc_info=True
                    )
        
        # Call async subscribers
        if event.type in self._async_subscribers:
            tasks = []
            for handler in self._async_subscribers[event.type]:
                tasks.append(self._call_async_handler(handler, event))
            
            if tasks:
                await asyncio.gather(*tasks, return_exceptions=True)
    
    async def _call_async_handler(self, handler: Callable, event: Event) -> None:
        """Call an async event handler with error handling."""
        try:
            await handler(event)
        except Exception as e:
            logger.error(
                f"Error in async event handler {handler.__name__}: {str(e)}",
                exc_info=True
            )
    
    def get_history(self, event_type: Optional[EventType] = None, limit: int = 100) -> List[Event]:
        """Get event history."""
        history = self._event_history
        
        if event_type:
            history = [e for e in history if e.type == event_type]
        
        return history[-limit:]
    
    def clear_history(self) -> None:
        """Clear event history."""
        self._event_history.clear()
    
    def get_subscribers_count(self, event_type: EventType) -> int:
        """Get number of subscribers for an event type."""
        sync_count = len(self._subscribers.get(event_type, []))
        async_count = len(self._async_subscribers.get(event_type, []))
        return sync_count + async_count


# Global event bus instance
event_bus = EventBus()


# Decorator for event handlers
def on_event(event_type: EventType):
    """
    Decorator to register a function as an event handler.
    
    Usage:
        @on_event(EventType.USER_REGISTERED)
        async def handle_user_registration(event: Event):
            # Handle the event
            pass
    """
    def decorator(func: Callable):
        event_bus.subscribe(event_type, func)
        return func
    return decorator


# Event publishing helpers
async def publish_event(
    event_type: EventType,
    data: Dict[str, Any],
    user_id: Optional[str] = None,
    organization_id: Optional[str] = None,
    session_id: Optional[str] = None,
    correlation_id: Optional[str] = None,
    metadata: Optional[Dict[str, Any]] = None
) -> None:
    """Helper function to publish an event."""
    event = Event(
        type=event_type,
        timestamp=datetime.utcnow(),
        data=data,
        metadata=metadata,
        user_id=user_id,
        organization_id=organization_id,
        session_id=session_id,
        correlation_id=correlation_id
    )
    await event_bus.publish(event)


# Event handlers for system events
class SystemEventHandlers:
    """Default system event handlers."""
    
    @staticmethod
    @on_event(EventType.USER_REGISTERED)
    async def handle_user_registration(event: Event):
        """Handle user registration event."""
        logger.info(f"New user registered: {event.data.get('email')}")
        
        # Send welcome email
        from app.services.notification_service import NotificationService
        notification_service = NotificationService()
        await notification_service.send_welcome_email(
            event.data.get('email'),
            event.data.get('name')
        )
    
    @staticmethod
    @on_event(EventType.SECURITY_ALERT)
    async def handle_security_alert(event: Event):
        """Handle security alert event."""
        logger.warning(
            f"Security alert: {event.data.get('message')}",
            extra={"event_data": event.data}
        )
        
        # Notify administrators
        from app.services.notification_service import NotificationService
        notification_service = NotificationService()
        await notification_service.notify_admins_security_alert(event.data)
    
    @staticmethod
    @on_event(EventType.RATE_LIMIT_EXCEEDED)
    async def handle_rate_limit(event: Event):
        """Handle rate limit exceeded event."""
        logger.warning(
            f"Rate limit exceeded for user {event.user_id}",
            extra={"event_data": event.data}
        )
        
        # Track in audit log
        from app.services.audit_service import AuditService
        audit_service = AuditService()
        await audit_service.log_rate_limit_exceeded(
            user_id=event.user_id,
            endpoint=event.data.get('endpoint'),
            limit=event.data.get('limit')
        )


# Event middleware
class EventLoggingMiddleware:
    """Middleware to log all events."""
    
    def __call__(self, event: Event) -> Event:
        """Log event details."""
        logger.debug(
            f"Event: {event.type.value}",
            extra={
                "event_type": event.type.value,
                "user_id": event.user_id,
                "correlation_id": event.correlation_id,
                "data": event.data
            }
        )
        return event


class EventFilterMiddleware:
    """Middleware to filter events based on criteria."""
    
    def __init__(self, excluded_types: Optional[Set[EventType]] = None):
        self.excluded_types = excluded_types or set()
    
    def __call__(self, event: Event) -> Optional[Event]:
        """Filter events."""
        if event.type in self.excluded_types:
            return None
        return event


class EventEnrichmentMiddleware:
    """Middleware to enrich events with additional data."""
    
    async def __call__(self, event: Event) -> Event:
        """Enrich event with additional metadata."""
        if event.metadata is None:
            event.metadata = {}
        
        # Add server information
        import platform
        event.metadata.update({
            "server_hostname": platform.node(),
            "server_platform": platform.platform(),
            "python_version": platform.python_version()
        })
        
        # Add timing information
        event.metadata["processing_time"] = datetime.utcnow().isoformat()
        
        return event


# Initialize middleware
event_bus.add_middleware(EventLoggingMiddleware())


# Utility functions
def create_correlation_id() -> str:
    """Create a unique correlation ID for tracking events."""
    import uuid
    return str(uuid.uuid4())


async def replay_events(
    event_types: List[EventType],
    handler: Callable,
    start_time: Optional[datetime] = None,
    end_time: Optional[datetime] = None
) -> None:
    """
    Replay historical events through a handler.
    Useful for debugging or reprocessing.
    """
    history = event_bus.get_history()
    
    for event in history:
        if event.type not in event_types:
            continue
        
        if start_time and event.timestamp < start_time:
            continue
        
        if end_time and event.timestamp > end_time:
            continue
        
        if asyncio.iscoroutinefunction(handler):
            await handler(event)
        else:
            handler(event)