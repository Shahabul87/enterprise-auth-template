"""
FastAPI Application Entry Point

This module sets up the FastAPI application with all necessary middleware,
routers, and configuration for the enterprise authentication template.
"""

from contextlib import asynccontextmanager
from typing import AsyncGenerator

import structlog
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.trustedhost import TrustedHostMiddleware

from app.core.config import get_settings
from app.core.database import close_db, init_db
from app.core.log_config import setup_logging
from app.middleware.rate_limiter import RateLimitMiddleware
from app.middleware.performance_middleware import (
    PerformanceMiddleware,
    get_metrics
)
from app.middleware.response_standardization import ResponseStandardizationMiddleware
from app.core.database_monitoring import setup_database_monitoring
from app.core.logging_config import (
    setup_logging as setup_json_logging,
    set_request_id,
    clear_context
)

# Initialize structured logging
setup_logging()
# Also setup JSON logging for production
if get_settings().ENVIRONMENT == "production":
    setup_json_logging(
        log_level="INFO",
        enable_json=True,
        enable_security_filter=True
    )
logger = structlog.get_logger(__name__)

settings = get_settings()


@asynccontextmanager
async def lifespan(app: FastAPI) -> AsyncGenerator[None, None]:
    """
    Application lifespan manager.

    Handles startup and shutdown events for the FastAPI application.
    """
    # Startup
    logger.info("Starting Enterprise Auth Template API", version=settings.VERSION)

    # Initialize database
    await init_db()
    logger.info("Database initialized")

    yield

    # Shutdown
    logger.info("Shutting down Enterprise Auth Template API")
    await close_db()
    logger.info("Database connections closed")


def create_application() -> FastAPI:
    """
    Create and configure the FastAPI application.

    Returns:
        FastAPI: Configured FastAPI application instance
    """
    app = FastAPI(
        title=settings.PROJECT_NAME,
        description="Enterprise-grade authentication template with FastAPI",
        version=settings.VERSION,
        docs_url=(settings.DOCS_URL if settings.ENVIRONMENT == "development" else None),
        redoc_url=(
            settings.REDOC_URL if settings.ENVIRONMENT == "development" else None
        ),
        openapi_url=f"{settings.API_V1_PREFIX}/openapi.json",
        lifespan=lifespan,
    )

    # Set up CORS middleware
    if settings.ALLOWED_ORIGINS:
        # Remove trailing slashes from origins for proper CORS matching
        origins = [str(origin).rstrip("/") for origin in settings.ALLOWED_ORIGINS]
        app.add_middleware(
            CORSMiddleware,
            allow_origins=origins,
            allow_credentials=True,
            allow_methods=settings.ALLOWED_METHODS,
            allow_headers=settings.ALLOWED_HEADERS,
        )

    # Add trusted host middleware for security
    if settings.ENVIRONMENT == "production":
        app.add_middleware(
            TrustedHostMiddleware,
            allowed_hosts=settings.ALLOWED_HOSTS or ["*"],
        )

    # Add response standardization middleware (first for proper request tracking)
    app.add_middleware(
        ResponseStandardizationMiddleware,
        exclude_paths=["/docs", "/redoc", "/openapi.json", "/health", "/metrics", "/favicon.ico"]
    )
    logger.info("Response standardization middleware enabled")

    # Add performance monitoring middleware
    app.add_middleware(
        PerformanceMiddleware,
        slow_request_threshold=1.0  # Log requests slower than 1 second
    )
    logger.info("Performance monitoring enabled")

    # Add rate limiting middleware (disabled in development)
    if settings.ENVIRONMENT != "development":
        redis_url = str(settings.REDIS_URL) if settings.REDIS_URL else None
        if redis_url:
            app.add_middleware(RateLimitMiddleware, redis_url=redis_url)
            logger.info("Rate limiting enabled")
        else:
            logger.warning("Rate limiting disabled - Redis not configured")
    else:
        logger.info("Rate limiting disabled in development mode")

    # Include API routers
    from app.api import api_router

    app.include_router(api_router, prefix=settings.API_V1_PREFIX)

    # Health check endpoint
    @app.get("/health")
    async def health_check():
        """Health check endpoint for load balancers and monitoring."""
        return {
            "status": "healthy",
            "service": "enterprise-auth-backend",
            "version": settings.VERSION,
            "environment": settings.ENVIRONMENT,
        }

    # Prometheus metrics endpoint
    @app.get("/metrics")
    async def metrics():
        """
        Prometheus metrics endpoint for monitoring.

        Returns metrics in Prometheus text format.
        """
        from fastapi.responses import PlainTextResponse
        metrics_data = await get_metrics()
        return PlainTextResponse(
            content=metrics_data,
            media_type="text/plain; charset=utf-8"
        )

    # Root endpoint
    @app.get("/")
    async def root():
        """Root endpoint with basic API information."""
        return {
            "message": "Enterprise Authentication Template API",
            "version": settings.VERSION,
            "docs_url": (
                f"{settings.API_V1_PREFIX}/docs"
                if settings.ENVIRONMENT == "development"
                else None
            ),
            "health_url": "/health",
        }

    return app


# Create the FastAPI application
app = create_application()

if __name__ == "__main__":
    import uvicorn

    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=8000,
        reload=settings.ENVIRONMENT == "development",
        log_level="info",
        access_log=True,
    )
