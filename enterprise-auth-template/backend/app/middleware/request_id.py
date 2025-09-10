"""
Enterprise Request ID Middleware

Request ID generation and tracking middleware for comprehensive request tracing
and correlation across distributed systems. Provides unique identifiers for
every request to enable effective logging, debugging, and monitoring.

Features:
- UUID-based request ID generation with multiple format options
- Custom request ID header support for client-provided IDs
- Request ID propagation through response headers
- Integration with logging systems for correlation
- Distributed tracing support with trace ID generation
- Performance tracking and request duration monitoring
- Request context storage for access throughout request lifecycle
"""

import time
import uuid
from datetime import datetime, timezone
from typing import Optional, Set, Union
from contextlib import contextmanager

import structlog
from fastapi import Request, Response
from starlette.middleware.base import BaseHTTPMiddleware

from app.core.config import get_settings

settings = get_settings()
logger = structlog.get_logger(__name__)

# Request ID configuration
REQUEST_ID_HEADER = "X-Request-ID"
CORRELATION_ID_HEADER = "X-Correlation-ID"
TRACE_ID_HEADER = "X-Trace-ID"
CLIENT_REQUEST_ID_HEADER = "X-Client-Request-ID"

# Alternative header names commonly used
ALTERNATIVE_HEADERS = {
    "x-request-id",
    "x-correlation-id",
    "x-trace-id",
    "request-id",
    "correlation-id",
    "trace-id",
}

# Request ID formats
ID_FORMAT_UUID4 = "uuid4"
ID_FORMAT_UUID1 = "uuid1"
ID_FORMAT_TIMESTAMP = "timestamp"
ID_FORMAT_CUSTOM = "custom"

# Thread-local storage alternative using contextvars (Python 3.7+)
import contextvars
request_id_context: contextvars.ContextVar[Optional[str]] = contextvars.ContextVar(
    'request_id', default=None
)
correlation_id_context: contextvars.ContextVar[Optional[str]] = contextvars.ContextVar(
    'correlation_id', default=None
)
trace_id_context: contextvars.ContextVar[Optional[str]] = contextvars.ContextVar(
    'trace_id', default=None
)


class RequestIDGenerator:
    """Generates unique request IDs in various formats."""

    def __init__(self, id_format: str = ID_FORMAT_UUID4, custom_prefix: str = ""):
        """
        Initialize request ID generator.

        Args:
            id_format: Format for generated IDs (uuid4, uuid1, timestamp, custom)
            custom_prefix: Optional prefix for generated IDs
        """
        self.id_format = id_format
        self.custom_prefix = custom_prefix

        # Validate format
        valid_formats = {ID_FORMAT_UUID4, ID_FORMAT_UUID1, ID_FORMAT_TIMESTAMP, ID_FORMAT_CUSTOM}
        if id_format not in valid_formats:
            raise ValueError(f"Invalid ID format: {id_format}. Must be one of {valid_formats}")

    def generate_request_id(self) -> str:
        """Generate a new request ID."""
        if self.id_format == ID_FORMAT_UUID4:
            id_value = str(uuid.uuid4())
        elif self.id_format == ID_FORMAT_UUID1:
            id_value = str(uuid.uuid1())
        elif self.id_format == ID_FORMAT_TIMESTAMP:
            timestamp = int(time.time() * 1000000)  # Microsecond precision
            random_suffix = str(uuid.uuid4()).split('-')[-1]
            id_value = f"{timestamp}-{random_suffix}"
        elif self.id_format == ID_FORMAT_CUSTOM:
            # Custom format: timestamp + uuid4 (shortened)
            timestamp = int(time.time())
            short_uuid = str(uuid.uuid4()).replace('-', '')[:12]
            id_value = f"{timestamp}-{short_uuid}"
        else:
            # Fallback to UUID4
            id_value = str(uuid.uuid4())

        if self.custom_prefix:
            return f"{self.custom_prefix}-{id_value}"
        return id_value

    def generate_trace_id(self, request_id: str) -> str:
        """Generate a trace ID based on request ID."""
        # Create a shorter trace ID for distributed tracing
        if self.id_format == ID_FORMAT_TIMESTAMP:
            # Extract timestamp and create shorter trace ID
            parts = request_id.replace(self.custom_prefix + "-" if self.custom_prefix else "", "").split('-')
            if len(parts) >= 2:
                return f"trace-{parts[0]}-{parts[1][:8]}"

        # Default: use first part of UUID
        base_id = request_id.replace(self.custom_prefix + "-" if self.custom_prefix else "", "")
        if '-' in base_id:
            trace_part = base_id.split('-')[0]
        else:
            trace_part = base_id[:16]

        return f"trace-{trace_part}"

    def validate_request_id(self, request_id: str) -> bool:
        """Validate that a request ID has the expected format."""
        if not request_id:
            return False

        # Remove custom prefix if present
        id_to_check = request_id
        if self.custom_prefix and request_id.startswith(self.custom_prefix + "-"):
            id_to_check = request_id[len(self.custom_prefix) + 1:]

        try:
            if self.id_format in [ID_FORMAT_UUID4, ID_FORMAT_UUID1]:
                # Try to parse as UUID
                uuid.UUID(id_to_check)
                return True
            elif self.id_format == ID_FORMAT_TIMESTAMP:
                # Check timestamp-random format
                parts = id_to_check.split('-')
                return len(parts) >= 2 and parts[0].isdigit()
            elif self.id_format == ID_FORMAT_CUSTOM:
                # Check custom timestamp-uuid format
                parts = id_to_check.split('-')
                return len(parts) >= 2 and parts[0].isdigit() and len(parts[1]) >= 8

            return True  # Accept any format for unknown types

        except (ValueError, AttributeError):
            return False


class RequestTracker:
    """Tracks request performance and metadata."""

    def __init__(self, request_id: str):
        """Initialize request tracker."""
        self.request_id = request_id
        self.start_time = time.time()
        self.end_time: Optional[float] = None
        self.metadata: dict = {}

    def set_metadata(self, key: str, value: Union[str, int, float, bool]):
        """Set request metadata."""
        self.metadata[key] = value

    def get_metadata(self, key: str) -> Optional[Union[str, int, float, bool]]:
        """Get request metadata."""
        return self.metadata.get(key)

    def finish_tracking(self):
        """Mark request as finished."""
        self.end_time = time.time()

    def get_duration(self) -> Optional[float]:
        """Get request duration in seconds."""
        if self.end_time is None:
            return None
        return self.end_time - self.start_time

    def get_summary(self) -> dict:
        """Get request tracking summary."""
        duration = self.get_duration()
        return {
            "request_id": self.request_id,
            "start_time": self.start_time,
            "end_time": self.end_time,
            "duration_seconds": duration,
            "duration_ms": round(duration * 1000, 3) if duration else None,
            "metadata": self.metadata.copy(),
        }


class RequestContext:
    """Request context manager for storing request-scoped data."""

    def __init__(self, request_id: str, correlation_id: str, trace_id: Optional[str] = None):
        """Initialize request context."""
        self.request_id = request_id
        self.correlation_id = correlation_id
        self.trace_id = trace_id
        self.tracker = RequestTracker(request_id)
        self.custom_data: dict = {}

    def set_data(self, key: str, value):
        """Set custom data in request context."""
        self.custom_data[key] = value

    def get_data(self, key: str, default=None):
        """Get custom data from request context."""
        return self.custom_data.get(key, default)

    def get_ids(self) -> dict:
        """Get all request IDs."""
        return {
            "request_id": self.request_id,
            "correlation_id": self.correlation_id,
            "trace_id": self.trace_id,
        }


# Global context accessors
def get_current_request_id() -> Optional[str]:
    """Get current request ID from context."""
    return request_id_context.get()


def get_current_correlation_id() -> Optional[str]:
    """Get current correlation ID from context."""
    return correlation_id_context.get()


def get_current_trace_id() -> Optional[str]:
    """Get current trace ID from context."""
    return trace_id_context.get()


def get_current_request_context() -> Optional[dict]:
    """Get current request context data."""
    return {
        "request_id": get_current_request_id(),
        "correlation_id": get_current_correlation_id(),
        "trace_id": get_current_trace_id(),
    }


class RequestIDMiddleware(BaseHTTPMiddleware):
    """
    Enterprise request ID middleware for request tracking and correlation.

    Features:
    - Automatic request ID generation with multiple format options
    - Client-provided request ID support with validation
    - Request ID propagation through headers
    - Context storage for access throughout request lifecycle
    - Performance tracking and request duration monitoring
    - Integration with structured logging
    """

    def __init__(
        self,
        app,
        id_format: str = ID_FORMAT_UUID4,
        custom_prefix: str = "",
        accept_client_id: bool = True,
        validate_client_id: bool = True,
        generate_trace_id: bool = True,
        enable_performance_tracking: bool = True,
        request_id_header: str = REQUEST_ID_HEADER,
        correlation_id_header: str = CORRELATION_ID_HEADER,
        trace_id_header: str = TRACE_ID_HEADER,
        client_request_id_header: str = CLIENT_REQUEST_ID_HEADER,
        log_request_ids: bool = True,
    ):
        """
        Initialize request ID middleware.

        Args:
            app: FastAPI application
            id_format: Format for generated request IDs
            custom_prefix: Optional prefix for generated IDs
            accept_client_id: Whether to accept client-provided request IDs
            validate_client_id: Whether to validate client-provided IDs
            generate_trace_id: Whether to generate trace IDs
            enable_performance_tracking: Enable request performance tracking
            request_id_header: Header name for request ID
            correlation_id_header: Header name for correlation ID
            trace_id_header: Header name for trace ID
            client_request_id_header: Header name for client-provided request ID
            log_request_ids: Whether to log request IDs
        """
        super().__init__(app)

        self.id_generator = RequestIDGenerator(id_format, custom_prefix)
        self.accept_client_id = accept_client_id
        self.validate_client_id = validate_client_id
        self.generate_trace_id = generate_trace_id
        self.enable_performance_tracking = enable_performance_tracking

        # Header configuration
        self.request_id_header = request_id_header
        self.correlation_id_header = correlation_id_header
        self.trace_id_header = trace_id_header
        self.client_request_id_header = client_request_id_header

        self.log_request_ids = log_request_ids

        # Active requests tracking
        self.active_requests: dict = {}

        logger.info(
            "Request ID middleware initialized",
            id_format=id_format,
            custom_prefix=custom_prefix,
            accept_client_id=accept_client_id,
            generate_trace_id=generate_trace_id,
            performance_tracking=enable_performance_tracking,
        )

    async def dispatch(self, request: Request, call_next):
        """Process request with ID generation and tracking."""
        # Generate or extract request ID
        request_id = await self._get_or_generate_request_id(request)
        correlation_id = request_id  # Use same ID for correlation by default

        # Generate trace ID if enabled
        trace_id = None
        if self.generate_trace_id:
            trace_id = self.id_generator.generate_trace_id(request_id)

        # Set context variables
        request_id_token = request_id_context.set(request_id)
        correlation_id_token = correlation_id_context.set(correlation_id)
        trace_id_token = trace_id_context.set(trace_id) if trace_id else None

        # Create request context
        request_context = RequestContext(request_id, correlation_id, trace_id)

        # Store in request state
        request.state.request_id = request_id
        request.state.correlation_id = correlation_id
        request.state.trace_id = trace_id
        request.state.request_context = request_context

        # Add to active requests tracking
        if self.enable_performance_tracking:
            self.active_requests[request_id] = request_context.tracker
            request_context.tracker.set_metadata("method", request.method)
            request_context.tracker.set_metadata("path", request.url.path)
            request_context.tracker.set_metadata("client_ip",
                request.client.host if request.client else "unknown")

        # Log request start
        if self.log_request_ids:
            logger.info(
                "Request started",
                request_id=request_id,
                correlation_id=correlation_id,
                trace_id=trace_id,
                method=request.method,
                path=request.url.path,
                client_ip=request.client.host if request.client else "unknown",
                user_agent=request.headers.get("user-agent", "")[:100],
            )

        try:
            # Process request
            response = await call_next(request)

            # Add request IDs to response headers
            response.headers[self.request_id_header] = request_id
            response.headers[self.correlation_id_header] = correlation_id
            if trace_id:
                response.headers[self.trace_id_header] = trace_id

            # Finish performance tracking
            if self.enable_performance_tracking and request_id in self.active_requests:
                request_context.tracker.finish_tracking()
                request_context.tracker.set_metadata("status_code", response.status_code)

                # Log request completion
                if self.log_request_ids:
                    summary = request_context.tracker.get_summary()
                    logger.info(
                        "Request completed",
                        request_id=request_id,
                        status_code=response.status_code,
                        duration_ms=summary.get("duration_ms"),
                        **summary.get("metadata", {})
                    )

            return response

        except Exception as e:
            # Log request failure
            logger.error(
                "Request failed",
                request_id=request_id,
                correlation_id=correlation_id,
                trace_id=trace_id,
                error=str(e),
                exception_type=type(e).__name__,
                method=request.method,
                path=request.url.path,
            )

            # Finish performance tracking even for errors
            if self.enable_performance_tracking and request_id in self.active_requests:
                request_context.tracker.finish_tracking()
                request_context.tracker.set_metadata("status_code", 500)
                request_context.tracker.set_metadata("error", str(e))

            # Re-raise the exception
            raise

        finally:
            # Clean up context
            request_id_context.reset(request_id_token)
            correlation_id_context.reset(correlation_id_token)
            if trace_id_token:
                trace_id_context.reset(trace_id_token)

            # Clean up active requests tracking
            if request_id in self.active_requests:
                del self.active_requests[request_id]

    async def _get_or_generate_request_id(self, request: Request) -> str:
        """Get existing request ID from headers or generate a new one."""
        # Check for client-provided request ID
        if self.accept_client_id:
            client_id = request.headers.get(self.client_request_id_header.lower())
            if not client_id:
                # Check alternative headers
                for header_name in request.headers:
                    if header_name.lower() in ALTERNATIVE_HEADERS:
                        client_id = request.headers[header_name]
                        break

            if client_id:
                # Validate client-provided ID if required
                if self.validate_client_id:
                    if self.id_generator.validate_request_id(client_id):
                        logger.debug("Using client-provided request ID", request_id=client_id)
                        return client_id
                    else:
                        logger.warning(
                            "Invalid client-provided request ID, generating new one",
                            client_request_id=client_id[:50],  # Limit length for logging
                        )
                else:
                    # Accept client ID without validation
                    logger.debug("Using client-provided request ID (unvalidated)", request_id=client_id)
                    return client_id

        # Generate new request ID
        request_id = self.id_generator.generate_request_id()
        logger.debug("Generated new request ID", request_id=request_id)
        return request_id

    def get_active_requests_count(self) -> int:
        """Get number of currently active requests."""
        return len(self.active_requests)

    def get_active_requests_summary(self) -> list:
        """Get summary of currently active requests."""
        summaries = []
        for request_id, tracker in self.active_requests.items():
            summary = tracker.get_summary()
            # Calculate current duration
            if summary["end_time"] is None:
                current_duration = time.time() - summary["start_time"]
                summary["current_duration_ms"] = round(current_duration * 1000, 3)
            summaries.append(summary)
        return summaries


def create_request_id_middleware(
    app,
    id_format: Optional[str] = None,
    custom_prefix: Optional[str] = None,
    **kwargs
) -> RequestIDMiddleware:
    """
    Factory function to create request ID middleware.

    Args:
        app: FastAPI application
        id_format: ID format (from settings if None)
        custom_prefix: Custom prefix (from settings if None)
        **kwargs: Additional middleware options

    Returns:
        Configured request ID middleware
    """
    # Use settings for configuration if not provided
    if id_format is None:
        id_format = getattr(settings, "REQUEST_ID_FORMAT", ID_FORMAT_UUID4)

    if custom_prefix is None:
        custom_prefix = getattr(settings, "REQUEST_ID_PREFIX", "")

    return RequestIDMiddleware(
        app,
        id_format=id_format,
        custom_prefix=custom_prefix,
        **kwargs
    )


@contextmanager
def request_context_manager(request_id: str, correlation_id: Optional[str] = None, trace_id: Optional[str] = None):
    """
    Context manager for setting request IDs in async contexts.

    Useful for background tasks or other async operations that need
    request context outside of the HTTP request/response cycle.
    """
    correlation_id = correlation_id or request_id

    request_id_token = request_id_context.set(request_id)
    correlation_id_token = correlation_id_context.set(correlation_id)
    trace_id_token = trace_id_context.set(trace_id) if trace_id else None

    try:
        yield {
            "request_id": request_id,
            "correlation_id": correlation_id,
            "trace_id": trace_id,
        }
    finally:
        request_id_context.reset(request_id_token)
        correlation_id_context.reset(correlation_id_token)
        if trace_id_token:
            trace_id_context.reset(trace_id_token)
