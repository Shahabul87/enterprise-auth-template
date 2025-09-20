"""
Enterprise Middleware Package

Comprehensive collection of FastAPI middleware components for enterprise applications.
Provides authentication, logging, security, CORS, rate limiting, and request tracking.

Available Middleware:
- AuthenticationMiddleware: JWT-based authentication with session management
- LoggingMiddleware: Comprehensive request/response logging with sanitization
- CORSMiddleware: Advanced CORS handling with origin validation
- SecurityHeadersMiddleware: Complete security headers implementation
- RequestIDMiddleware: Request ID generation and tracking
- RateLimitMiddleware: Advanced rate limiting with Redis backend
- CSRFProtectionMiddleware: CSRF protection for web applications
- PerformanceMiddleware: Performance monitoring and optimization

Usage:
    from app.middleware import (
        AuthenticationMiddleware,
        LoggingMiddleware,
        CORSMiddleware,
        SecurityHeadersMiddleware,
        RequestIDMiddleware,
        create_auth_middleware,
        create_logging_middleware,
        create_cors_middleware,
        create_security_headers_middleware,
        create_request_id_middleware,
    )
"""

from typing import Optional

# Import all middleware classes
from .auth_middleware import (
    AuthenticationMiddleware,
    AuthenticationError,
    JWTTokenManager,
    DeviceFingerprinter,
    create_auth_middleware,
)

from .logging_middleware import (
    LoggingMiddleware,
    DataSanitizer,
    PerformanceTracker,
    RequestLogger,
    create_logging_middleware,
)

from .cors_middleware import (
    CORSMiddleware,
    CORSConfig,
    OriginValidator,
    create_cors_middleware,
)

from .security_headers import (
    SecurityHeadersMiddleware,
    SecurityHeadersConfig,
    CSPBuilder,
    PermissionsPolicyBuilder,
    create_security_headers_middleware,
)

from .request_id import (
    RequestIDMiddleware,
    RequestIDGenerator,
    RequestTracker,
    RequestContext,
    get_current_request_id,
    get_current_correlation_id,
    get_current_trace_id,
    get_current_request_context,
    request_context_manager,
    create_request_id_middleware,
)

# Import existing middleware
from .rate_limiter import (
    RateLimitMiddleware,
    RateLimiter,
    RateLimitConfig,
)

from .csrf_protection import (
    CSRFProtectionMiddleware,
)

from .performance_middleware import (
    PerformanceMiddleware,
)

# Middleware factory functions for easy setup
__all__ = [
    # Authentication
    "AuthenticationMiddleware",
    "AuthenticationError",
    "JWTTokenManager",
    "DeviceFingerprinter",
    "create_auth_middleware",
    # Logging
    "LoggingMiddleware",
    "DataSanitizer",
    "PerformanceTracker",
    "RequestLogger",
    "create_logging_middleware",
    # CORS
    "CORSMiddleware",
    "CORSConfig",
    "OriginValidator",
    "create_cors_middleware",
    # Security Headers
    "SecurityHeadersMiddleware",
    "SecurityHeadersConfig",
    "CSPBuilder",
    "PermissionsPolicyBuilder",
    "create_security_headers_middleware",
    # Request ID
    "RequestIDMiddleware",
    "RequestIDGenerator",
    "RequestTracker",
    "RequestContext",
    "get_current_request_id",
    "get_current_correlation_id",
    "get_current_trace_id",
    "get_current_request_context",
    "request_context_manager",
    "create_request_id_middleware",
    # Existing middleware
    "RateLimitMiddleware",
    "RateLimiter",
    "RateLimitConfig",
    "CSRFProtectionMiddleware",
    "PerformanceMiddleware",
]


def create_enterprise_middleware_stack(
    app,
    redis_url: Optional[str] = None,
    cors_origins: Optional[list] = None,
    enable_auth: bool = True,
    enable_logging: bool = True,
    enable_cors: bool = True,
    enable_security_headers: bool = True,
    enable_request_id: bool = True,
    enable_rate_limiting: bool = True,
    enable_csrf: bool = False,  # Usually for web apps, not APIs
    enable_performance: bool = True,
    **kwargs,
) -> list:
    """
    Create a complete enterprise middleware stack with all components.

    This factory function creates and configures all middleware components
    in the correct order for maximum compatibility and security.

    Args:
        app: FastAPI application instance
        redis_url: Redis URL for session storage and rate limiting
        cors_origins: List of allowed CORS origins
        enable_auth: Enable authentication middleware
        enable_logging: Enable request/response logging
        enable_cors: Enable CORS middleware
        enable_security_headers: Enable security headers
        enable_request_id: Enable request ID generation
        enable_rate_limiting: Enable rate limiting
        enable_csrf: Enable CSRF protection
        enable_performance: Enable performance monitoring
        **kwargs: Additional configuration options

    Returns:
        List of configured middleware instances in proper order

    Example:
        ```python
        from fastapi import FastAPI
        from app.middleware import create_enterprise_middleware_stack

        app = FastAPI()

        # Add all enterprise middleware
        middleware_stack = create_enterprise_middleware_stack(
            app,
            redis_url="redis://localhost:6379",
            cors_origins=["https://myapp.com"],
            enable_auth=True,
            enable_logging=True,
        )

        # Apply middleware in reverse order (FastAPI requirement)
        for middleware in reversed(middleware_stack):
            app.add_middleware(type(middleware), **middleware.__dict__)
        ```
    """
    middleware_stack: list = []

    # Middleware order is important - add in reverse order of execution
    # (FastAPI applies middleware in reverse order)

    # 1. Performance middleware (outermost, measures total time)
    if enable_performance:
        middleware_stack.append(PerformanceMiddleware(app))

    # 2. Request ID middleware (early for correlation)
    if enable_request_id:
        middleware_stack.append(create_request_id_middleware(app, **kwargs))

    # 3. Logging middleware (after request ID is available)
    if enable_logging:
        middleware_stack.append(create_logging_middleware(app, **kwargs))

    # 4. Security headers middleware
    if enable_security_headers:
        middleware_stack.append(create_security_headers_middleware(app, **kwargs))

    # 5. CORS middleware (before auth, handles preflight)
    if enable_cors:
        middleware_stack.append(
            create_cors_middleware(app, allowed_origins=cors_origins, **kwargs)
        )

    # 6. Rate limiting middleware (before auth to prevent abuse)
    if enable_rate_limiting:
        middleware_stack.append(RateLimitMiddleware(app, redis_url=redis_url))

    # 7. CSRF protection (if enabled, before auth)
    if enable_csrf:
        from app.core.config import get_settings

        settings = get_settings()
        middleware_stack.append(
            CSRFProtectionMiddleware(app, secret_key=settings.SECRET_KEY)
        )

    # 8. Authentication middleware (after rate limiting and CSRF)
    if enable_auth:
        middleware_stack.append(
            create_auth_middleware(app, redis_url=redis_url, **kwargs)
        )

    return middleware_stack


# Convenience imports for common configurations
def create_api_middleware_stack(app, redis_url: Optional[str] = None, **kwargs) -> list:
    """Create middleware stack optimized for REST APIs."""
    return create_enterprise_middleware_stack(
        app,
        redis_url=redis_url,
        enable_csrf=False,  # APIs typically don't need CSRF
        enable_cors=True,  # APIs often need CORS
        enable_auth=True,  # APIs need authentication
        **kwargs,
    )


def create_web_middleware_stack(app, redis_url: Optional[str] = None, **kwargs) -> list:
    """Create middleware stack optimized for web applications."""
    return create_enterprise_middleware_stack(
        app,
        redis_url=redis_url,
        enable_csrf=True,  # Web apps need CSRF protection
        enable_cors=True,  # May need CORS for SPA
        enable_auth=True,  # Web apps need authentication
        **kwargs,
    )


def create_minimal_middleware_stack(app, **kwargs) -> list:
    """Create minimal middleware stack for development/testing."""
    return create_enterprise_middleware_stack(
        app,
        enable_auth=False,
        enable_rate_limiting=False,
        enable_csrf=False,
        enable_performance=False,
        **kwargs,
    )
