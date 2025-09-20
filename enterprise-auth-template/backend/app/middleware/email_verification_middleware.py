"""
Email Verification Middleware

Middleware to enforce email verification for protected routes.
This provides an additional layer of security beyond the authentication service.
"""

from typing import Optional, List, Set
from fastapi import Request, HTTPException, status
from fastapi.responses import JSONResponse
import structlog

from app.core.config import get_settings
from app.dependencies.auth import get_current_user
from app.models.user import User

settings = get_settings()
logger = structlog.get_logger(__name__)


class EmailVerificationMiddleware:
    """
    Middleware to enforce email verification for specific routes.

    This middleware provides route-level protection to ensure only users
    with verified emails can access sensitive endpoints.
    """

    def __init__(
        self,
        protected_paths: Optional[Set[str]] = None,
        excluded_paths: Optional[Set[str]] = None,
        bypass_in_development: bool = True,
    ):
        """
        Initialize email verification middleware.

        Args:
            protected_paths: Set of paths that require email verification
            excluded_paths: Set of paths to exclude from verification
            bypass_in_development: Whether to bypass verification in development
        """
        self.protected_paths = protected_paths or {
            "/api/v1/users/me",
            "/api/v1/profile",
            "/api/v1/admin",
            "/api/v1/organizations",
            "/api/v1/roles",
            "/api/v1/permissions",
            "/api/v1/sessions",
            "/api/v1/api-keys",
            "/api/v1/webhooks",
            "/api/v1/analytics",
            "/api/v1/export",
            "/api/v1/backup",
            "/api/v1/monitoring",
        }

        self.excluded_paths = excluded_paths or {
            "/api/v1/auth/login",
            "/api/v1/auth/register",
            "/api/v1/auth/verify-email",
            "/api/v1/auth/verify-email/resend",
            "/api/v1/auth/refresh",
            "/api/v1/auth/logout",
            "/api/v1/auth/reset-password",
            "/api/v1/auth/reset-password/confirm",
            "/api/v1/health",
            "/docs",
            "/redoc",
            "/openapi.json",
        }

        self.bypass_in_development = bypass_in_development

    def should_check_verification(self, path: str) -> bool:
        """
        Determine if a path requires email verification.

        Args:
            path: Request path

        Returns:
            bool: True if verification should be checked
        """
        # Skip if email verification is not enforced according to settings
        if not settings.should_enforce_email_verification():
            return False

        # Skip if in development mode and bypass is enabled
        if self.bypass_in_development and settings.ENVIRONMENT == "development":
            return False

        # Skip excluded paths
        if any(path.startswith(excluded) for excluded in self.excluded_paths):
            return False

        # Check protected paths
        return any(path.startswith(protected) for protected in self.protected_paths)

    async def __call__(self, request: Request, call_next):
        """
        Process request and enforce email verification if required.

        Args:
            request: FastAPI request object
            call_next: Next middleware/endpoint in chain

        Returns:
            Response from next middleware or error response
        """
        path = request.url.path

        # Skip verification check if not required for this path
        if not self.should_check_verification(path):
            return await call_next(request)

        try:
            # Get current user from request (if authenticated)
            user = await self._get_current_user_from_request(request)

            if user:
                # Check if email is verified
                if not user.email_verified:
                    logger.warning(
                        "Access denied - email not verified",
                        user_id=str(user.id),
                        email=user.email,
                        path=path,
                        ip_address=self._get_client_ip(request),
                    )

                    return JSONResponse(
                        status_code=status.HTTP_403_FORBIDDEN,
                        content={
                            "success": False,
                            "error": {
                                "code": "EMAIL_NOT_VERIFIED",
                                "message": "Email verification required to access this resource. Please verify your email address.",
                                "details": {
                                    "verification_required": True,
                                    "user_email": user.email,
                                    "resend_endpoint": "/api/v1/auth/verify-email/resend",
                                },
                            },
                            "metadata": {
                                "timestamp": settings.get_current_timestamp(),
                                "request_id": self._get_request_id(request),
                            },
                        },
                    )

                # Log successful verification check
                logger.debug(
                    "Email verification passed",
                    user_id=str(user.id),
                    email=user.email,
                    path=path,
                )

            # Continue to next middleware/endpoint
            return await call_next(request)

        except Exception as e:
            logger.error(
                "Email verification middleware error",
                error=str(e),
                path=path,
                ip_address=self._get_client_ip(request),
            )

            # Continue on middleware errors to avoid blocking legitimate requests
            return await call_next(request)

    async def _get_current_user_from_request(self, request: Request) -> Optional[User]:
        """
        Extract current user from request if authenticated.

        Args:
            request: FastAPI request object

        Returns:
            User object if authenticated, None otherwise
        """
        try:
            # Check if authorization header exists
            authorization = request.headers.get("Authorization")
            if not authorization or not authorization.startswith("Bearer "):
                return None

            # Extract token
            token = authorization.split(" ")[1]

            # Use existing dependency to get user
            # Note: This is a simplified approach - in production you might
            # want to implement token verification directly here
            from app.core.security import verify_token
            from app.repositories.user_repository import UserRepository
            from app.core.database import get_async_session

            # Verify token
            token_data = verify_token(token, "access")
            if not token_data:
                return None

            # Get user from database
            async for session in get_async_session():
                user_repo = UserRepository(session)
                user = await user_repo.find_by_email(token_data.email)
                return user

        except Exception as e:
            logger.debug(
                "Could not extract user from request",
                error=str(e),
                path=request.url.path,
            )
            return None

    def _get_client_ip(self, request: Request) -> str:
        """Get client IP address from request."""
        return (
            request.headers.get("X-Forwarded-For", "").split(",")[0].strip()
            or request.headers.get("X-Real-IP", "").strip()
            or request.client.host
            or "unknown"
        )

    def _get_request_id(self, request: Request) -> str:
        """Get or generate request ID."""
        return request.headers.get("X-Request-ID", "unknown")


# Pre-configured middleware instances for common use cases

# Standard protection for API endpoints
api_email_verification_middleware = EmailVerificationMiddleware(
    protected_paths={
        "/api/v1/users",
        "/api/v1/profile",
        "/api/v1/admin",
        "/api/v1/organizations",
        "/api/v1/roles",
        "/api/v1/permissions",
        "/api/v1/sessions",
        "/api/v1/api-keys",
        "/api/v1/webhooks",
        "/api/v1/analytics",
        "/api/v1/export",
        "/api/v1/backup",
        "/api/v1/monitoring",
    },
    bypass_in_development=True,
)

# Strict protection for admin endpoints only
admin_email_verification_middleware = EmailVerificationMiddleware(
    protected_paths={
        "/api/v1/admin",
        "/api/v1/organizations",
        "/api/v1/roles",
        "/api/v1/permissions",
        "/api/v1/analytics",
        "/api/v1/export",
        "/api/v1/backup",
        "/api/v1/monitoring",
    },
    bypass_in_development=False,  # Always enforce for admin routes
)

# Minimal protection for critical operations only
critical_email_verification_middleware = EmailVerificationMiddleware(
    protected_paths={
        "/api/v1/admin",
        "/api/v1/export",
        "/api/v1/backup",
    },
    bypass_in_development=False,
)
