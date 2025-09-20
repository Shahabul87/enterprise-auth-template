"""
Performance monitoring middleware for FastAPI application.
Tracks request duration, counts, and slow queries.
"""

import time
import logging
from typing import Callable, Optional, Dict, Any
from fastapi import Request, Response
from fastapi.routing import APIRoute
from prometheus_client import Histogram, Counter, Gauge, generate_latest
from prometheus_client.core import CollectorRegistry
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.responses import Response as StarletteResponse
import asyncio
from datetime import datetime

# Create a custom registry for metrics
REGISTRY = CollectorRegistry()

# Define Prometheus metrics
REQUEST_DURATION = Histogram(
    "http_request_duration_seconds",
    "HTTP request duration in seconds",
    ["method", "endpoint", "status_code"],
    registry=REGISTRY,
    buckets=(0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1.0, 2.5, 5.0, 10.0),
)

REQUEST_COUNT = Counter(
    "http_requests_total",
    "Total HTTP requests",
    ["method", "endpoint", "status_code"],
    registry=REGISTRY,
)

ACTIVE_REQUESTS = Gauge(
    "http_requests_active",
    "Active HTTP requests",
    ["method", "endpoint"],
    registry=REGISTRY,
)

ERROR_COUNT = Counter(
    "http_errors_total",
    "Total HTTP errors",
    ["method", "endpoint", "error_type"],
    registry=REGISTRY,
)

RESPONSE_SIZE = Histogram(
    "http_response_size_bytes",
    "HTTP response size in bytes",
    ["method", "endpoint", "status_code"],
    registry=REGISTRY,
    buckets=(100, 1000, 10000, 100000, 1000000, 10000000),
)

# Database metrics
DB_QUERY_DURATION = Histogram(
    "database_query_duration_seconds",
    "Database query duration in seconds",
    ["operation", "table"],
    registry=REGISTRY,
    buckets=(0.001, 0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1.0, 2.5),
)

DB_CONNECTION_POOL = Gauge(
    "database_connection_pool_size",
    "Database connection pool metrics",
    ["pool_type"],
    registry=REGISTRY,
)

# Cache metrics
CACHE_HIT_RATE = Counter(
    "cache_hits_total",
    "Cache hit count",
    ["cache_type", "operation"],
    registry=REGISTRY,
)

CACHE_MISS_RATE = Counter(
    "cache_misses_total",
    "Cache miss count",
    ["cache_type", "operation"],
    registry=REGISTRY,
)

# Business metrics
USER_LOGIN_ATTEMPTS = Counter(
    "user_login_attempts_total",
    "User login attempts",
    ["status", "method"],
    registry=REGISTRY,
)

USER_REGISTRATIONS = Counter(
    "user_registrations_total", "User registrations", ["status"], registry=REGISTRY
)

# Configure logging
logger = logging.getLogger(__name__)


class PerformanceMiddleware(BaseHTTPMiddleware):
    """
    Middleware to track performance metrics for all HTTP requests.
    """

    def __init__(self, app, slow_request_threshold: float = 1.0):
        super().__init__(app)
        self.slow_request_threshold = slow_request_threshold

    async def dispatch(self, request: Request, call_next: Callable) -> Response:
        """
        Process request and track performance metrics.
        """
        # Extract endpoint path (normalize for metrics)
        endpoint = self._normalize_endpoint(request.url.path)
        method = request.method

        # Track active requests
        ACTIVE_REQUESTS.labels(method=method, endpoint=endpoint).inc()

        # Start timing
        start_time = time.time()

        # Store request start time in request state for other middlewares
        request.state.start_time = start_time

        try:
            # Process request
            response = await call_next(request)

            # Calculate duration
            duration = time.time() - start_time

            # Get response size if available
            response_size = self._get_response_size(response)

            # Record metrics
            status_code = str(response.status_code)
            REQUEST_DURATION.labels(
                method=method, endpoint=endpoint, status_code=status_code
            ).observe(duration)

            REQUEST_COUNT.labels(
                method=method, endpoint=endpoint, status_code=status_code
            ).inc()

            if response_size:
                RESPONSE_SIZE.labels(
                    method=method, endpoint=endpoint, status_code=status_code
                ).observe(response_size)

            # Log slow requests
            if duration > self.slow_request_threshold:
                logger.warning(
                    f"Slow request detected",
                    extra={
                        "method": method,
                        "endpoint": endpoint,
                        "duration": f"{duration:.3f}s",
                        "status_code": status_code,
                        "client_ip": self._get_client_ip(request),
                        "user_agent": request.headers.get("user-agent", "unknown"),
                    },
                )

            # Track business metrics for specific endpoints
            self._track_business_metrics(endpoint, method, status_code)

            return response

        except Exception as e:
            # Track errors
            duration = time.time() - start_time
            error_type = type(e).__name__

            ERROR_COUNT.labels(
                method=method, endpoint=endpoint, error_type=error_type
            ).inc()

            logger.error(
                f"Request failed",
                extra={
                    "method": method,
                    "endpoint": endpoint,
                    "duration": f"{duration:.3f}s",
                    "error": str(e),
                    "error_type": error_type,
                    "client_ip": self._get_client_ip(request),
                },
                exc_info=True,
            )

            raise

        finally:
            # Decrement active requests
            ACTIVE_REQUESTS.labels(method=method, endpoint=endpoint).dec()

    def _normalize_endpoint(self, path: str) -> str:
        """
        Normalize endpoint path for metrics to avoid high cardinality.
        Replace dynamic path parameters with placeholders.
        """
        # Common patterns to normalize
        import re

        # Replace UUIDs
        path = re.sub(
            r"/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}",
            "/{id}",
            path,
            flags=re.IGNORECASE,
        )

        # Replace numeric IDs
        path = re.sub(r"/\d+", "/{id}", path)

        # Replace email-like patterns
        path = re.sub(r"/[^/]+@[^/]+", "/{email}", path)

        # Group common endpoints
        if path.startswith("/api/v1/users/"):
            if path.endswith("/permissions"):
                return "/api/v1/users/{id}/permissions"
            elif path.endswith("/roles"):
                return "/api/v1/users/{id}/roles"
            elif path != "/api/v1/users/":
                return "/api/v1/users/{id}"

        return path

    def _get_response_size(self, response: Response) -> Optional[int]:
        """
        Get response size from headers if available.
        """
        if hasattr(response, "headers"):
            content_length = response.headers.get("content-length")
            if content_length:
                try:
                    return int(content_length)
                except (ValueError, TypeError):
                    pass
        return None

    def _get_client_ip(self, request: Request) -> str:
        """
        Get client IP address from request.
        """
        # Check for proxy headers
        forwarded = request.headers.get("x-forwarded-for")
        if forwarded:
            return forwarded.split(",")[0].strip()

        real_ip = request.headers.get("x-real-ip")
        if real_ip:
            return real_ip

        # Fallback to direct connection
        if request.client:
            return request.client.host

        return "unknown"

    def _track_business_metrics(self, endpoint: str, method: str, status_code: str):
        """
        Track business-specific metrics based on endpoint.
        """
        # Track login attempts
        if endpoint == "/api/v1/auth/login" and method == "POST":
            status = "success" if status_code.startswith("2") else "failure"
            USER_LOGIN_ATTEMPTS.labels(status=status, method="password").inc()

        # Track OAuth logins
        elif "/oauth/" in endpoint and method == "GET":
            provider = endpoint.split("/oauth/")[1].split("/")[0]
            status = "success" if status_code.startswith("2") else "failure"
            USER_LOGIN_ATTEMPTS.labels(status=status, method=provider).inc()

        # Track registrations
        elif endpoint == "/api/v1/auth/register" and method == "POST":
            status = "success" if status_code == "201" else "failure"
            USER_REGISTRATIONS.labels(status=status).inc()


class MetricsRoute(APIRoute):
    """
    Custom route class to add per-route metrics.
    """

    def get_route_handler(self) -> Callable:
        original_route_handler = super().get_route_handler()

        async def custom_route_handler(request: Request) -> Response:
            # Add route-specific metrics here if needed
            return await original_route_handler(request)

        return custom_route_handler


def track_db_query(operation: str, table: str):
    """
    Decorator to track database query performance.
    """

    def decorator(func: Callable):
        async def wrapper(*args, **kwargs):
            start_time = time.time()
            try:
                result = await func(*args, **kwargs)
                duration = time.time() - start_time
                DB_QUERY_DURATION.labels(operation=operation, table=table).observe(
                    duration
                )

                if duration > 0.1:  # Log slow queries
                    logger.warning(
                        f"Slow database query",
                        extra={
                            "operation": operation,
                            "table": table,
                            "duration": f"{duration:.3f}s",
                        },
                    )

                return result
            except Exception as e:
                duration = time.time() - start_time
                logger.error(
                    f"Database query failed",
                    extra={
                        "operation": operation,
                        "table": table,
                        "duration": f"{duration:.3f}s",
                        "error": str(e),
                    },
                )
                raise

        return wrapper

    return decorator


def track_cache_operation(cache_type: str, operation: str):
    """
    Decorator to track cache hit/miss rates.
    """

    def decorator(func: Callable):
        async def wrapper(*args, **kwargs):
            result = await func(*args, **kwargs)

            # Determine if it was a hit or miss based on result
            if result is not None:
                CACHE_HIT_RATE.labels(cache_type=cache_type, operation=operation).inc()
            else:
                CACHE_MISS_RATE.labels(cache_type=cache_type, operation=operation).inc()

            return result

        return wrapper

    return decorator


def update_connection_pool_metrics(active: int, idle: int, total: int):
    """
    Update database connection pool metrics.
    """
    DB_CONNECTION_POOL.labels(pool_type="active").set(active)
    DB_CONNECTION_POOL.labels(pool_type="idle").set(idle)
    DB_CONNECTION_POOL.labels(pool_type="total").set(total)


async def get_metrics() -> str:
    """
    Generate Prometheus metrics in text format.
    """
    return generate_latest(REGISTRY).decode("utf-8")


# Export metrics for use in other modules
__all__ = [
    "PerformanceMiddleware",
    "MetricsRoute",
    "track_db_query",
    "track_cache_operation",
    "update_connection_pool_metrics",
    "get_metrics",
    "REQUEST_DURATION",
    "REQUEST_COUNT",
    "DB_QUERY_DURATION",
    "CACHE_HIT_RATE",
    "CACHE_MISS_RATE",
    "USER_LOGIN_ATTEMPTS",
    "USER_REGISTRATIONS",
]
