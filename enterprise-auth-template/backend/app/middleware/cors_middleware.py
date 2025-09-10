"""
Enterprise CORS (Cross-Origin Resource Sharing) Middleware

Advanced CORS middleware for FastAPI applications that provides comprehensive
cross-origin request handling with security features, domain whitelisting,
and enterprise-grade configuration options.

Features:
- Dynamic origin validation with domain whitelisting
- Configurable CORS policies per endpoint/path
- Support for credentials and authentication
- Pre-flight request optimization
- Security headers integration
- Comprehensive logging and monitoring
- Environment-specific configuration
- Subdomain and wildcard support
"""

import re
from typing import Dict, List, Optional, Set, Union
from urllib.parse import urlparse

import structlog
from fastapi import Request, Response
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.responses import Response as StarletteResponse

from app.core.config import get_settings

settings = get_settings()
logger = structlog.get_logger(__name__)

# Default CORS configuration
DEFAULT_ALLOWED_METHODS = ["GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"]
DEFAULT_ALLOWED_HEADERS = [
    "accept",
    "accept-encoding",
    "authorization",
    "content-type",
    "dnt",
    "origin",
    "user-agent",
    "x-csrftoken",
    "x-requested-with",
    "x-correlation-id",
    "x-request-id",
    "cache-control",
    "pragma",
]
DEFAULT_EXPOSED_HEADERS = [
    "x-correlation-id",
    "x-request-id",
    "x-ratelimit-limit",
    "x-ratelimit-remaining",
    "x-ratelimit-reset",
    "content-range",
    "content-length",
]

# Security-related headers for CORS
SECURITY_HEADERS = [
    "x-csrf-token",
    "x-api-key",
    "x-auth-token",
    "x-session-id",
]

# Development and production origin patterns
DEVELOPMENT_ORIGINS = [
    "http://localhost:3000",
    "http://localhost:3001",
    "http://localhost:8000",
    "http://127.0.0.1:3000",
    "http://127.0.0.1:3001",
    "http://127.0.0.1:8000",
]

# Common patterns for allowed origins
COMMON_ORIGIN_PATTERNS = {
    "localhost_dev": r"^https?://localhost:\d+$",
    "local_ip": r"^https?://127\.0\.0\.1:\d+$",
    "local_network": r"^https?://192\.168\.\d+\.\d+:\d+$",
    "vercel_preview": r"^https://.*\.vercel\.app$",
    "netlify_preview": r"^https://.*\.netlify\.app$",
    "github_pages": r"^https://.*\.github\.io$",
}


class OriginValidator:
    """Validates origins against configured whitelist with pattern matching."""

    def __init__(
        self,
        allowed_origins: List[str],
        allow_origin_regex: Optional[List[str]] = None,
        allow_development: bool = False,
        allow_subdomains: bool = False,
    ):
        """
        Initialize origin validator.

        Args:
            allowed_origins: List of explicitly allowed origins
            allow_origin_regex: List of regex patterns for allowed origins
            allow_development: Whether to allow development origins
            allow_subdomains: Whether to allow subdomains of allowed origins
        """
        self.allowed_origins: Set[str] = set(allowed_origins)
        self.allow_development = allow_development
        self.allow_subdomains = allow_subdomains

        # Compile regex patterns
        self.regex_patterns: List[re.Pattern] = []
        if allow_origin_regex:
            for pattern in allow_origin_regex:
                try:
                    self.regex_patterns.append(re.compile(pattern))
                except re.error as e:
                    logger.error("Invalid CORS origin regex pattern", pattern=pattern, error=str(e))

        # Add development patterns if enabled
        if allow_development:
            self.allowed_origins.update(DEVELOPMENT_ORIGINS)
            for pattern_name, pattern in COMMON_ORIGIN_PATTERNS.items():
                try:
                    self.regex_patterns.append(re.compile(pattern))
                except re.error as e:
                    logger.error("Invalid development pattern", pattern=pattern, error=str(e))

        # Build subdomain patterns if enabled
        self.subdomain_patterns: List[re.Pattern] = []
        if allow_subdomains:
            for origin in self.allowed_origins:
                if origin.startswith(("http://", "https://")):
                    parsed = urlparse(origin)
                    # Create pattern for subdomains
                    escaped_domain = re.escape(parsed.netloc)
                    pattern = f"^{parsed.scheme}://([\\w-]+\\.)*{escaped_domain}$"
                    try:
                        self.subdomain_patterns.append(re.compile(pattern))
                    except re.error as e:
                        logger.error("Invalid subdomain pattern", origin=origin, error=str(e))

        logger.info(
            "CORS origin validator initialized",
            allowed_origins=len(self.allowed_origins),
            regex_patterns=len(self.regex_patterns),
            subdomain_patterns=len(self.subdomain_patterns),
            allow_development=allow_development,
        )

    def is_origin_allowed(self, origin: str) -> bool:
        """
        Check if origin is allowed based on configured rules.

        Args:
            origin: Origin header value

        Returns:
            True if origin is allowed, False otherwise
        """
        if not origin:
            return False

        # Normalize origin (remove trailing slash)
        normalized_origin = origin.rstrip("/")

        # Check exact matches first
        if normalized_origin in self.allowed_origins:
            return True

        # Check regex patterns
        for pattern in self.regex_patterns:
            if pattern.match(normalized_origin):
                return True

        # Check subdomain patterns
        for pattern in self.subdomain_patterns:
            if pattern.match(normalized_origin):
                return True

        return False

    def validate_and_log(self, origin: str, request_path: str) -> bool:
        """
        Validate origin and log the result for security monitoring.

        Args:
            origin: Origin header value
            request_path: Request path for context

        Returns:
            True if origin is allowed, False otherwise
        """
        is_allowed = self.is_origin_allowed(origin)

        if is_allowed:
            logger.debug("CORS origin validated", origin=origin, path=request_path)
        else:
            logger.warning(
                "CORS origin blocked",
                origin=origin,
                path=request_path,
                allowed_origins=list(self.allowed_origins)[:5],  # Log first 5 for debugging
            )

        return is_allowed


class CORSConfig:
    """CORS configuration for different endpoint patterns."""

    def __init__(
        self,
        allowed_origins: Optional[List[str]] = None,
        allowed_methods: Optional[List[str]] = None,
        allowed_headers: Optional[List[str]] = None,
        exposed_headers: Optional[List[str]] = None,
        allow_credentials: bool = True,
        max_age: int = 3600,
        allow_origin_regex: Optional[List[str]] = None,
        allow_development: bool = False,
        allow_subdomains: bool = False,
    ):
        """Initialize CORS configuration."""
        self.allowed_origins = allowed_origins or []
        self.allowed_methods = allowed_methods or DEFAULT_ALLOWED_METHODS
        self.allowed_headers = allowed_headers or DEFAULT_ALLOWED_HEADERS.copy()
        self.exposed_headers = exposed_headers or DEFAULT_EXPOSED_HEADERS.copy()
        self.allow_credentials = allow_credentials
        self.max_age = max_age

        # Add security headers if credentials are allowed
        if allow_credentials:
            self.allowed_headers.extend(SECURITY_HEADERS)

        # Remove duplicates and normalize
        self.allowed_methods = list(set(method.upper() for method in self.allowed_methods))
        self.allowed_headers = list(set(header.lower() for header in self.allowed_headers))
        self.exposed_headers = list(set(header.lower() for header in self.exposed_headers))

        # Initialize origin validator
        self.origin_validator = OriginValidator(
            allowed_origins=self.allowed_origins,
            allow_origin_regex=allow_origin_regex,
            allow_development=allow_development,
            allow_subdomains=allow_subdomains,
        )

    def get_cors_headers(self, origin: str, request_method: str) -> Dict[str, str]:
        """
        Generate CORS headers for the given origin and method.

        Args:
            origin: Request origin
            request_method: HTTP method

        Returns:
            Dictionary of CORS headers
        """
        headers = {}

        # Validate origin
        if self.origin_validator.is_origin_allowed(origin):
            headers["Access-Control-Allow-Origin"] = origin
        else:
            # Don't set CORS headers for disallowed origins
            return {}

        # Set credentials header
        if self.allow_credentials:
            headers["Access-Control-Allow-Credentials"] = "true"

        # For preflight requests
        if request_method.upper() == "OPTIONS":
            headers["Access-Control-Allow-Methods"] = ", ".join(self.allowed_methods)
            headers["Access-Control-Allow-Headers"] = ", ".join(self.allowed_headers)
            headers["Access-Control-Max-Age"] = str(self.max_age)

        # For actual requests
        if self.exposed_headers:
            headers["Access-Control-Expose-Headers"] = ", ".join(self.exposed_headers)

        # Add Vary header for proper caching
        headers["Vary"] = "Origin"

        return headers


class CORSMiddleware(BaseHTTPMiddleware):
    """
    Enterprise CORS middleware with advanced origin validation and security features.

    Features:
    - Dynamic origin validation with regex patterns
    - Path-specific CORS configuration
    - Development and production environment handling
    - Comprehensive security logging
    - Pre-flight request optimization
    - Subdomain support
    """

    def __init__(
        self,
        app,
        allowed_origins: Optional[List[str]] = None,
        allowed_methods: Optional[List[str]] = None,
        allowed_headers: Optional[List[str]] = None,
        exposed_headers: Optional[List[str]] = None,
        allow_credentials: bool = True,
        allow_origin_regex: Optional[List[str]] = None,
        max_age: int = 3600,
        path_configs: Optional[Dict[str, Dict]] = None,
        enable_development_mode: Optional[bool] = None,
        allow_subdomains: bool = False,
    ):
        """
        Initialize CORS middleware.

        Args:
            app: FastAPI application
            allowed_origins: List of allowed origins
            allowed_methods: List of allowed HTTP methods
            allowed_headers: List of allowed headers
            exposed_headers: List of headers to expose to the client
            allow_credentials: Whether to allow credentials
            allow_origin_regex: List of regex patterns for allowed origins
            max_age: Max age for preflight cache
            path_configs: Path-specific CORS configurations
            enable_development_mode: Enable development origins (auto-detected if None)
            allow_subdomains: Allow subdomains of configured origins
        """
        super().__init__(app)

        # Auto-detect development mode if not specified
        if enable_development_mode is None:
            enable_development_mode = settings.ENVIRONMENT.lower() in ["development", "dev", "local"]

        # Default CORS configuration
        self.default_config = CORSConfig(
            allowed_origins=allowed_origins or [],
            allowed_methods=allowed_methods,
            allowed_headers=allowed_headers,
            exposed_headers=exposed_headers,
            allow_credentials=allow_credentials,
            max_age=max_age,
            allow_origin_regex=allow_origin_regex,
            allow_development=enable_development_mode,
            allow_subdomains=allow_subdomains,
        )

        # Path-specific configurations
        self.path_configs: Dict[str, CORSConfig] = {}
        if path_configs:
            for path_pattern, config_dict in path_configs.items():
                self.path_configs[path_pattern] = CORSConfig(
                    **{**config_dict, "allow_development": enable_development_mode}
                )

        self.enable_development_mode = enable_development_mode

        logger.info(
            "CORS middleware initialized",
            default_origins=len(self.default_config.allowed_origins),
            development_mode=enable_development_mode,
            allow_credentials=allow_credentials,
            path_configs=len(self.path_configs),
        )

    async def dispatch(self, request: Request, call_next):
        """Process request with CORS handling."""
        origin = request.headers.get("origin", "")
        method = request.method
        path = request.url.path

        # Get appropriate CORS configuration
        cors_config = self._get_cors_config_for_path(path)

        # Handle preflight requests
        if method == "OPTIONS":
            return await self._handle_preflight(request, origin, cors_config)

        # Process actual request
        response = await call_next(request)

        # Add CORS headers to response
        cors_headers = cors_config.get_cors_headers(origin, method)
        for header_name, header_value in cors_headers.items():
            response.headers[header_name] = header_value

        # Log CORS activity for security monitoring
        if origin and cors_headers:
            logger.debug(
                "CORS headers added to response",
                origin=origin,
                method=method,
                path=path,
                status_code=response.status_code,
            )
        elif origin:
            logger.warning(
                "CORS request from disallowed origin",
                origin=origin,
                method=method,
                path=path,
                user_agent=request.headers.get("user-agent", ""),
            )

        return response

    def _get_cors_config_for_path(self, path: str) -> CORSConfig:
        """Get CORS configuration for specific path."""
        # Check path-specific configurations
        for path_pattern, config in self.path_configs.items():
            # Simple prefix matching (can be extended to regex)
            if path.startswith(path_pattern):
                return config

        # Return default configuration
        return self.default_config

    async def _handle_preflight(
        self,
        request: Request,
        origin: str,
        cors_config: CORSConfig
    ) -> StarletteResponse:
        """Handle CORS preflight requests."""
        # Validate origin
        if not cors_config.origin_validator.validate_and_log(origin, request.url.path):
            # Return minimal response for disallowed origins
            return StarletteResponse(
                status_code=204,
                headers={"Content-Length": "0"}
            )

        # Get requested method and headers
        requested_method = request.headers.get("access-control-request-method", "")
        requested_headers = request.headers.get("access-control-request-headers", "")

        # Validate requested method
        if requested_method.upper() not in cors_config.allowed_methods:
            logger.warning(
                "CORS preflight: method not allowed",
                origin=origin,
                method=requested_method,
                path=request.url.path,
            )
            return StarletteResponse(
                status_code=204,
                headers={"Content-Length": "0"}
            )

        # Validate requested headers
        if requested_headers:
            requested_header_list = [h.strip().lower() for h in requested_headers.split(",")]
            disallowed_headers = set(requested_header_list) - set(cors_config.allowed_headers)
            if disallowed_headers:
                logger.warning(
                    "CORS preflight: headers not allowed",
                    origin=origin,
                    disallowed_headers=list(disallowed_headers),
                    path=request.url.path,
                )
                return StarletteResponse(
                    status_code=204,
                    headers={"Content-Length": "0"}
                )

        # Generate CORS headers for successful preflight
        cors_headers = cors_config.get_cors_headers(origin, "OPTIONS")

        logger.debug(
            "CORS preflight successful",
            origin=origin,
            method=requested_method,
            path=request.url.path,
        )

        return StarletteResponse(
            status_code=204,
            headers={
                **cors_headers,
                "Content-Length": "0",
            }
        )


def create_cors_middleware(
    app,
    allowed_origins: Optional[List[str]] = None,
    enable_development_mode: Optional[bool] = None,
    **kwargs
) -> CORSMiddleware:
    """
    Factory function to create CORS middleware with environment-specific defaults.

    Args:
        app: FastAPI application
        allowed_origins: List of allowed origins (from settings if None)
        enable_development_mode: Enable development origins (auto-detected if None)
        **kwargs: Additional CORS middleware options

    Returns:
        Configured CORS middleware
    """
    # Use settings for allowed origins if not provided
    if allowed_origins is None:
        allowed_origins = []
        if hasattr(settings, "CORS_ORIGINS") and settings.CORS_ORIGINS:
            # Handle both string and list formats
            if isinstance(settings.CORS_ORIGINS, str):
                allowed_origins = [origin.strip() for origin in settings.CORS_ORIGINS.split(",")]
            elif isinstance(settings.CORS_ORIGINS, list):
                allowed_origins = settings.CORS_ORIGINS

    # Auto-detect development mode if not specified
    if enable_development_mode is None:
        enable_development_mode = settings.ENVIRONMENT.lower() in ["development", "dev", "local"]

    return CORSMiddleware(
        app,
        allowed_origins=allowed_origins,
        enable_development_mode=enable_development_mode,
        **kwargs
    )
