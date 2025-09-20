"""
Enterprise Request/Response Logging Middleware

Comprehensive logging middleware for FastAPI applications that provides detailed
request and response logging with security, performance, and compliance features.

Features:
- Detailed request/response logging with configurable levels
- Performance metrics tracking (response time, payload sizes)
- Security event logging (authentication failures, suspicious activity)
- PII data sanitization and compliance-ready audit trails
- Structured logging with correlation IDs
- Error tracking and exception logging
- Configurable log levels and filtering
- Integration with monitoring systems
"""

import asyncio
import json
import time
import uuid
from datetime import datetime, timezone
from typing import Any, Dict, List, Optional, Set, Union
from urllib.parse import urlparse, parse_qs

import structlog
from fastapi import Request, Response
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.responses import StreamingResponse

from app.core.config import get_settings

settings = get_settings()
logger = structlog.get_logger(__name__)

# Logging configuration
MAX_BODY_LOG_SIZE = 10000  # Maximum request/response body size to log
MAX_HEADER_VALUE_SIZE = 500  # Maximum header value size to log
LOG_LEVEL_INFO = "info"
LOG_LEVEL_DEBUG = "debug"
LOG_LEVEL_WARNING = "warning"
LOG_LEVEL_ERROR = "error"

# Sensitive data patterns to sanitize
SENSITIVE_HEADERS: Set[str] = {
    "authorization",
    "cookie",
    "x-api-key",
    "x-auth-token",
    "x-csrf-token",
    "set-cookie",
    "www-authenticate",
}

SENSITIVE_FIELDS: Set[str] = {
    "password",
    "passwd",
    "secret",
    "token",
    "api_key",
    "access_token",
    "refresh_token",
    "csrf_token",
    "credit_card",
    "card_number",
    "cvv",
    "ssn",
    "social_security",
    "pin",
    "otp",
    "verification_code",
}

# Endpoints that should have minimal logging for performance
HIGH_FREQUENCY_ENDPOINTS: Set[str] = {
    "/health",
    "/metrics",
    "/ping",
    "/status",
}

# Endpoints that require detailed security logging
SECURITY_SENSITIVE_ENDPOINTS: Set[str] = {
    "/api/v1/auth/login",
    "/api/v1/auth/register",
    "/api/v1/auth/logout",
    "/api/v1/auth/refresh",
    "/api/v1/auth/forgot-password",
    "/api/v1/auth/reset-password",
    "/api/v1/admin",
    "/api/v1/users/admin",
}


class DataSanitizer:
    """Utility class for sanitizing sensitive data in logs."""

    @staticmethod
    def sanitize_headers(headers: Dict[str, str]) -> Dict[str, str]:
        """Sanitize sensitive headers for logging."""
        sanitized = {}
        for key, value in headers.items():
            key_lower = key.lower()
            if key_lower in SENSITIVE_HEADERS:
                # Show partial value for debugging while hiding sensitive part
                if len(value) > 10:
                    sanitized[key] = f"{value[:6]}...{value[-4:]}"
                else:
                    sanitized[key] = "***"
            else:
                # Truncate long header values
                sanitized[key] = (
                    value[:MAX_HEADER_VALUE_SIZE]
                    if len(value) > MAX_HEADER_VALUE_SIZE
                    else value
                )
        return sanitized

    @staticmethod
    def sanitize_json_data(
        data: Union[Dict, List, str], max_depth: int = 10
    ) -> Union[Dict, List, str]:
        """Recursively sanitize sensitive fields in JSON data."""
        if max_depth <= 0:
            return "[DEPTH_LIMIT_REACHED]"

        if isinstance(data, dict):
            sanitized = {}
            for key, value in data.items():
                key_lower = key.lower()
                if any(sensitive in key_lower for sensitive in SENSITIVE_FIELDS):
                    sanitized[key] = "***SANITIZED***"
                elif isinstance(value, (dict, list)):
                    sanitized[key] = DataSanitizer.sanitize_json_data(
                        value, max_depth - 1
                    )
                else:
                    sanitized[key] = value
            return sanitized
        elif isinstance(data, list):
            return [
                DataSanitizer.sanitize_json_data(item, max_depth - 1) for item in data
            ]
        else:
            return data

    @staticmethod
    def sanitize_query_params(
        query_params: Dict[str, List[str]],
    ) -> Dict[str, List[str]]:
        """Sanitize sensitive query parameters."""
        sanitized = {}
        for key, values in query_params.items():
            key_lower = key.lower()
            if any(sensitive in key_lower for sensitive in SENSITIVE_FIELDS):
                sanitized[key] = ["***SANITIZED***"] * len(values)
            else:
                sanitized[key] = values
        return sanitized


class PerformanceTracker:
    """Track performance metrics for requests."""

    def __init__(self):
        self.start_time: float = 0
        self.end_time: float = 0
        self.request_size: int = 0
        self.response_size: int = 0

    def start_tracking(self, request_size: int = 0):
        """Start performance tracking."""
        self.start_time = time.time()
        self.request_size = request_size

    def end_tracking(self, response_size: int = 0):
        """End performance tracking."""
        self.end_time = time.time()
        self.response_size = response_size

    def get_metrics(self) -> Dict[str, Any]:
        """Get performance metrics."""
        duration = (
            self.end_time - self.start_time if self.end_time > self.start_time else 0
        )
        return {
            "duration_ms": round(duration * 1000, 3),
            "start_time": self.start_time,
            "end_time": self.end_time,
            "request_size_bytes": self.request_size,
            "response_size_bytes": self.response_size,
            "throughput_kb_per_sec": (
                round((self.request_size + self.response_size) / 1024 / duration, 2)
                if duration > 0
                else 0
            ),
        }


class RequestLogger:
    """Handles detailed request logging with security and compliance features."""

    def __init__(
        self, enable_body_logging: bool = True, enable_performance_tracking: bool = True
    ):
        """Initialize request logger."""
        self.enable_body_logging = enable_body_logging
        self.enable_performance_tracking = enable_performance_tracking
        self.sanitizer = DataSanitizer()

    async def log_request(
        self,
        request: Request,
        correlation_id: str,
        performance_tracker: Optional[PerformanceTracker] = None,
    ) -> Dict[str, Any]:
        """Log incoming request with comprehensive details."""
        try:
            # Extract basic request info
            request_data = {
                "correlation_id": correlation_id,
                "timestamp": datetime.now(timezone.utc).isoformat(),
                "method": request.method,
                "url": str(request.url),
                "path": request.url.path,
                "query_params": dict(request.query_params),
                "client_ip": self._get_client_ip(request),
                "user_agent": request.headers.get("user-agent", ""),
                "headers": dict(request.headers),
                "content_type": request.headers.get("content-type", ""),
                "content_length": request.headers.get("content-length", "0"),
            }

            # Sanitize sensitive data
            request_data["headers"] = self.sanitizer.sanitize_headers(
                request_data["headers"]
            )
            request_data["query_params"] = self.sanitizer.sanitize_query_params(
                {k: [v] for k, v in request_data["query_params"].items()}
            )

            # Extract and log request body if enabled and appropriate
            if self.enable_body_logging and self._should_log_body(request):
                body_data = await self._extract_request_body(request)
                if body_data:
                    request_data["body"] = body_data
                    if performance_tracker:
                        performance_tracker.start_tracking(len(str(body_data)))

            # Determine log level based on endpoint sensitivity
            log_level = self._get_request_log_level(request.url.path)

            # Log with appropriate level
            if log_level == LOG_LEVEL_DEBUG:
                logger.debug("Incoming request", **request_data)
            elif log_level == LOG_LEVEL_WARNING:
                logger.warning("Security-sensitive request", **request_data)
            else:
                logger.info("Incoming request", **request_data)

            return request_data

        except Exception as e:
            logger.error(
                "Failed to log request", error=str(e), correlation_id=correlation_id
            )
            return {"correlation_id": correlation_id, "error": "Failed to log request"}

    async def log_response(
        self,
        request: Request,
        response: Response,
        correlation_id: str,
        performance_tracker: Optional[PerformanceTracker] = None,
        exception: Optional[Exception] = None,
    ):
        """Log outgoing response with performance metrics."""
        try:
            # Extract basic response info
            response_data = {
                "correlation_id": correlation_id,
                "timestamp": datetime.now(timezone.utc).isoformat(),
                "status_code": response.status_code,
                "headers": dict(response.headers),
                "content_type": response.headers.get("content-type", ""),
                "content_length": response.headers.get("content-length", "0"),
            }

            # Sanitize response headers
            response_data["headers"] = self.sanitizer.sanitize_headers(
                response_data["headers"]
            )

            # Add performance metrics
            if performance_tracker and self.enable_performance_tracking:
                content_length = response.headers.get("content-length")
                response_size = int(content_length) if content_length else 0
                performance_tracker.end_tracking(response_size)
                response_data["performance"] = performance_tracker.get_metrics()

            # Add exception info if present
            if exception:
                response_data["exception"] = {
                    "type": type(exception).__name__,
                    "message": str(exception),
                }

            # Add user context if available
            if hasattr(request.state, "user_id"):
                response_data["user_id"] = request.state.user_id
            if hasattr(request.state, "session_id"):
                response_data["session_id"] = request.state.session_id[
                    :16
                ]  # Partial for security

            # Determine log level based on status code and endpoint
            log_level = self._get_response_log_level(
                response.status_code, request.url.path
            )

            # Log with appropriate level
            if log_level == LOG_LEVEL_ERROR:
                logger.error("Response completed with error", **response_data)
            elif log_level == LOG_LEVEL_WARNING:
                logger.warning("Response completed with warning", **response_data)
            elif log_level == LOG_LEVEL_DEBUG:
                logger.debug("Response completed", **response_data)
            else:
                logger.info("Response completed", **response_data)

        except Exception as e:
            logger.error(
                "Failed to log response", error=str(e), correlation_id=correlation_id
            )

    def _get_client_ip(self, request: Request) -> str:
        """Extract client IP from request with proxy awareness."""
        # Check standard proxy headers
        forwarded_for = request.headers.get("x-forwarded-for")
        if forwarded_for:
            return forwarded_for.split(",")[0].strip()

        real_ip = request.headers.get("x-real-ip")
        if real_ip:
            return real_ip.strip()

        # Cloudflare
        cf_connecting_ip = request.headers.get("cf-connecting-ip")
        if cf_connecting_ip:
            return cf_connecting_ip.strip()

        # Fallback to direct client IP
        return request.client.host if request.client else "unknown"

    def _should_log_body(self, request: Request) -> bool:
        """Determine if request body should be logged."""
        # Don't log body for high-frequency endpoints
        if request.url.path in HIGH_FREQUENCY_ENDPOINTS:
            return False

        # Don't log body for large payloads
        content_length = request.headers.get("content-length")
        if content_length and int(content_length) > MAX_BODY_LOG_SIZE:
            return False

        # Don't log body for file uploads
        content_type = request.headers.get("content-type", "")
        if (
            "multipart/form-data" in content_type
            or "application/octet-stream" in content_type
        ):
            return False

        return True

    async def _extract_request_body(
        self, request: Request
    ) -> Optional[Union[Dict, str]]:
        """Extract and sanitize request body."""
        try:
            content_type = request.headers.get("content-type", "")

            # Handle JSON payloads
            if "application/json" in content_type:
                body = await request.body()
                if body:
                    json_data = json.loads(body)
                    return self.sanitizer.sanitize_json_data(json_data)

            # Handle form data
            elif "application/x-www-form-urlencoded" in content_type:
                body = await request.body()
                if body:
                    # Parse form data and sanitize
                    form_data = parse_qs(body.decode())
                    return self.sanitizer.sanitize_query_params(form_data)

            # Handle plain text (with size limit)
            elif "text/" in content_type:
                body = await request.body()
                if body and len(body) <= MAX_BODY_LOG_SIZE:
                    return body.decode()[:MAX_BODY_LOG_SIZE]

            return None

        except Exception as e:
            logger.warning("Failed to extract request body", error=str(e))
            return {"error": "Failed to parse body"}

    def _get_request_log_level(self, path: str) -> str:
        """Get appropriate log level for request based on path."""
        if path in HIGH_FREQUENCY_ENDPOINTS:
            return LOG_LEVEL_DEBUG
        elif any(
            path.startswith(sensitive) for sensitive in SECURITY_SENSITIVE_ENDPOINTS
        ):
            return LOG_LEVEL_WARNING
        else:
            return LOG_LEVEL_INFO

    def _get_response_log_level(self, status_code: int, path: str) -> str:
        """Get appropriate log level for response."""
        if status_code >= 500:
            return LOG_LEVEL_ERROR
        elif status_code >= 400:
            return LOG_LEVEL_WARNING
        elif path in HIGH_FREQUENCY_ENDPOINTS:
            return LOG_LEVEL_DEBUG
        else:
            return LOG_LEVEL_INFO


class LoggingMiddleware(BaseHTTPMiddleware):
    """
    Enterprise logging middleware for comprehensive request/response logging.

    Features:
    - Detailed request/response logging with sanitization
    - Performance metrics tracking
    - Security event logging
    - Configurable logging levels
    - Correlation ID tracking
    - Exception handling and logging
    """

    def __init__(
        self,
        app,
        enable_body_logging: bool = True,
        enable_performance_tracking: bool = True,
        log_high_frequency_endpoints: bool = False,
        custom_sensitive_fields: Optional[Set[str]] = None,
    ):
        """
        Initialize logging middleware.

        Args:
            app: FastAPI application
            enable_body_logging: Whether to log request/response bodies
            enable_performance_tracking: Whether to track performance metrics
            log_high_frequency_endpoints: Whether to log high-frequency endpoints
            custom_sensitive_fields: Additional sensitive fields to sanitize
        """
        super().__init__(app)

        # Update sensitive fields if custom ones provided
        if custom_sensitive_fields:
            global SENSITIVE_FIELDS
            SENSITIVE_FIELDS = SENSITIVE_FIELDS.union(custom_sensitive_fields)

        # Initialize components
        self.request_logger = RequestLogger(
            enable_body_logging, enable_performance_tracking
        )
        self.log_high_frequency = log_high_frequency_endpoints
        self.enable_performance_tracking = enable_performance_tracking

        logger.info(
            "Logging middleware initialized",
            body_logging=enable_body_logging,
            performance_tracking=enable_performance_tracking,
            high_frequency_logging=log_high_frequency_endpoints,
        )

    async def dispatch(self, request: Request, call_next):
        """Process request with comprehensive logging."""
        # Generate correlation ID for request tracking
        correlation_id = str(uuid.uuid4())
        request.state.correlation_id = correlation_id

        # Initialize performance tracking
        performance_tracker = (
            PerformanceTracker() if self.enable_performance_tracking else None
        )

        # Skip logging for high-frequency endpoints if disabled
        should_log = (
            self.log_high_frequency or request.url.path not in HIGH_FREQUENCY_ENDPOINTS
        )

        response = None
        exception = None

        try:
            # Log incoming request
            if should_log:
                await self.request_logger.log_request(
                    request, correlation_id, performance_tracker
                )

            # Process request
            response = await call_next(request)

            # Add correlation ID to response headers
            response.headers["X-Correlation-ID"] = correlation_id
            response.headers["X-Request-ID"] = correlation_id  # Alternative header name

            return response

        except Exception as e:
            exception = e
            logger.error(
                "Request processing failed",
                correlation_id=correlation_id,
                error=str(e),
                exception_type=type(e).__name__,
                path=request.url.path,
                method=request.method,
            )

            # Create error response
            from fastapi.responses import JSONResponse

            response = JSONResponse(
                status_code=500,
                content={
                    "success": False,
                    "error": {
                        "code": "INTERNAL_SERVER_ERROR",
                        "message": "An internal server error occurred",
                        "details": "The server encountered an error while processing your request",
                    },
                    "metadata": {
                        "correlation_id": correlation_id,
                        "timestamp": datetime.now(timezone.utc).isoformat(),
                    },
                },
                headers={
                    "X-Correlation-ID": correlation_id,
                    "X-Request-ID": correlation_id,
                },
            )

            return response

        finally:
            # Log response (even for exceptions)
            if should_log and response:
                await self.request_logger.log_response(
                    request, response, correlation_id, performance_tracker, exception
                )


def create_logging_middleware(
    app,
    enable_body_logging: Optional[bool] = None,
    enable_performance_tracking: Optional[bool] = None,
    **kwargs,
) -> LoggingMiddleware:
    """
    Factory function to create logging middleware.

    Args:
        app: FastAPI application
        enable_body_logging: Whether to enable body logging (from settings)
        enable_performance_tracking: Whether to enable performance tracking
        **kwargs: Additional middleware options

    Returns:
        Configured logging middleware
    """
    # Use settings defaults if not specified
    if enable_body_logging is None:
        enable_body_logging = settings.DEBUG or settings.ENVIRONMENT.lower() in [
            "development",
            "dev",
        ]

    if enable_performance_tracking is None:
        enable_performance_tracking = True

    return LoggingMiddleware(
        app,
        enable_body_logging=enable_body_logging,
        enable_performance_tracking=enable_performance_tracking,
        **kwargs,
    )
