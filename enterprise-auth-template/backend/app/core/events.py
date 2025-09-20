"""
Event System for Application-wide Event Handling

Simple event emitter system for audit logging and system notifications.
"""

from typing import Any, Dict, Optional, Callable, List
from datetime import datetime
import asyncio
import structlog

logger = structlog.get_logger(__name__)


class Event:
    """Simple event class to hold event data."""

    def __init__(
        self,
        event_type: str,
        data: Optional[Dict[str, Any]] = None,
        user_id: Optional[str] = None,
        timestamp: Optional[datetime] = None,
    ):
        self.event_type = event_type
        self.data = data or {}
        self.user_id = user_id
        self.timestamp = timestamp or datetime.utcnow()


class EventEmitter:
    """Simple event emitter for application events."""

    def __init__(self):
        self.listeners: Dict[str, List[Callable]] = {}

    def on(self, event_type: str, callback: Callable) -> None:
        """Register an event listener."""
        if event_type not in self.listeners:
            self.listeners[event_type] = []
        self.listeners[event_type].append(callback)

    async def emit(self, event: Event) -> None:
        """Emit an event to all registered listeners."""
        try:
            # Log the event
            logger.info(
                "Event emitted",
                event_type=event.event_type,
                user_id=event.user_id,
                timestamp=event.timestamp.isoformat(),
                data=event.data,
            )

            # Call registered listeners
            if event.event_type in self.listeners:
                for callback in self.listeners[event.event_type]:
                    try:
                        if asyncio.iscoroutinefunction(callback):
                            await callback(event)
                        else:
                            callback(event)
                    except Exception as e:
                        logger.error(
                            "Error in event listener",
                            event_type=event.event_type,
                            error=str(e),
                        )
        except Exception as e:
            logger.error(
                "Error emitting event", event_type=event.event_type, error=str(e)
            )
