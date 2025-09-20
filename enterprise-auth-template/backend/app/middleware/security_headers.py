"""
Enterprise Security Headers Middleware

Comprehensive security headers middleware that implements industry-standard
security headers to protect against various web vulnerabilities including
XSS, clickjacking, MIME type sniffing, and more.

Security Headers Implemented:
- Content Security Policy (CSP) with nonce support
- HTTP Strict Transport Security (HSTS)
- X-Frame-Options for clickjacking protection
- X-Content-Type-Options to prevent MIME sniffing
- X-XSS-Protection for legacy XSS protection
- Referrer-Policy for privacy protection
- Permissions-Policy for feature control
- Cross-Origin-Embedder-Policy (COEP)
- Cross-Origin-Opener-Policy (COOP)
- Cross-Origin-Resource-Policy (CORP)
"""

import secrets
from datetime import datetime, timezone
from typing import Dict, List, Optional, Set, Union

import structlog
from fastapi import Request, Response
from starlette.middleware.base import BaseHTTPMiddleware

from app.core.config import get_settings

settings = get_settings()
logger = structlog.get_logger(__name__)

# Default security header configurations
DEFAULT_FRAME_OPTIONS = "DENY"
DEFAULT_CONTENT_TYPE_OPTIONS = "nosniff"
DEFAULT_XSS_PROTECTION = "1; mode=block"
DEFAULT_REFERRER_POLICY = "strict-origin-when-cross-origin"

# HSTS configuration
DEFAULT_HSTS_MAX_AGE = 31536000  # 1 year in seconds
DEFAULT_HSTS_INCLUDE_SUBDOMAINS = True
DEFAULT_HSTS_PRELOAD = True

# CSP default configuration for APIs
DEFAULT_CSP_API = {
    "default-src": ["'none'"],
    "base-uri": ["'none'"],
    "form-action": ["'none'"],
    "frame-ancestors": ["'none'"],
    "upgrade-insecure-requests": [],
}

# CSP configuration for web applications
DEFAULT_CSP_WEB = {
    "default-src": ["'self'"],
    "script-src": ["'self'", "'unsafe-inline'"],
    "style-src": ["'self'", "'unsafe-inline'"],
    "img-src": ["'self'", "data:", "https:"],
    "connect-src": ["'self'"],
    "font-src": ["'self'"],
    "media-src": ["'self'"],
    "object-src": ["'none'"],
    "child-src": ["'self'"],
    "frame-src": ["'self'"],
    "worker-src": ["'self'"],
    "manifest-src": ["'self'"],
    "base-uri": ["'self'"],
    "form-action": ["'self'"],
    "frame-ancestors": ["'none'"],
    "upgrade-insecure-requests": [],
}

# Permissions Policy default configuration
DEFAULT_PERMISSIONS_POLICY = {
    "accelerometer": [],
    "ambient-light-sensor": [],
    "autoplay": [],
    "battery": [],
    "camera": [],
    "cross-origin-isolated": [],
    "display-capture": [],
    "document-domain": [],
    "encrypted-media": [],
    "execution-while-not-rendered": [],
    "execution-while-out-of-viewport": [],
    "fullscreen": ["self"],
    "geolocation": [],
    "gyroscope": [],
    "magnetometer": [],
    "microphone": [],
    "midi": [],
    "navigation-override": [],
    "payment": [],
    "picture-in-picture": [],
    "publickey-credentials-get": [],
    "screen-wake-lock": [],
    "sync-xhr": [],
    "usb": [],
    "web-share": [],
    "xr-spatial-tracking": [],
}

# Paths that require different security configurations
API_PATHS = ["/api/", "/docs", "/redoc", "/openapi.json", "/health", "/metrics"]
STATIC_PATHS = ["/static/", "/assets/", "/public/"]


class CSPBuilder:
    """Content Security Policy builder with nonce support."""

    def __init__(self, base_policy: Optional[Dict[str, List[str]]] = None):
        """Initialize CSP builder."""
        self.policy = base_policy or DEFAULT_CSP_API.copy()
        self.nonces: Dict[str, str] = {}

    def generate_nonce(self, directive: str = "script") -> str:
        """Generate cryptographic nonce for CSP."""
        nonce = secrets.token_urlsafe(16)
        self.nonces[directive] = nonce
        return nonce

    def add_nonce_to_directive(self, directive: str, nonce: str):
        """Add nonce to CSP directive."""
        if directive not in self.policy:
            self.policy[directive] = []

        nonce_value = f"'nonce-{nonce}'"
        if nonce_value not in self.policy[directive]:
            self.policy[directive].append(nonce_value)

    def add_source(self, directive: str, source: str):
        """Add source to CSP directive."""
        if directive not in self.policy:
            self.policy[directive] = []

        if source not in self.policy[directive]:
            self.policy[directive].append(source)

    def remove_source(self, directive: str, source: str):
        """Remove source from CSP directive."""
        if directive in self.policy and source in self.policy[directive]:
            self.policy[directive].remove(source)

    def build(self) -> str:
        """Build CSP header value."""
        policy_parts = []

        for directive, sources in self.policy.items():
            if sources:
                policy_parts.append(f"{directive} {' '.join(sources)}")
            else:
                # Some directives don't need sources (e.g., upgrade-insecure-requests)
                if directive in [
                    "upgrade-insecure-requests",
                    "block-all-mixed-content",
                ]:
                    policy_parts.append(directive)

        return "; ".join(policy_parts)

    def get_nonce(self, directive: str = "script") -> Optional[str]:
        """Get generated nonce for directive."""
        return self.nonces.get(directive)


class PermissionsPolicyBuilder:
    """Permissions Policy builder for feature control."""

    def __init__(self, base_policy: Optional[Dict[str, List[str]]] = None):
        """Initialize permissions policy builder."""
        self.policy = base_policy or DEFAULT_PERMISSIONS_POLICY.copy()

    def set_directive(self, directive: str, allowlist: List[str]):
        """Set permissions directive allowlist."""
        self.policy[directive] = allowlist.copy()

    def add_to_allowlist(self, directive: str, origin: str):
        """Add origin to directive allowlist."""
        if directive not in self.policy:
            self.policy[directive] = []

        if origin not in self.policy[directive]:
            self.policy[directive].append(origin)

    def build(self) -> str:
        """Build Permissions-Policy header value."""
        policy_parts = []

        for directive, allowlist in self.policy.items():
            if allowlist:
                # Format: directive=(origin1 origin2)
                origins = " ".join(
                    f'"{origin}"' if origin != "self" else origin
                    for origin in allowlist
                )
                policy_parts.append(f"{directive}=({origins})")
            else:
                # Empty allowlist means feature is disabled
                policy_parts.append(f"{directive}=()")

        return ", ".join(policy_parts)


class SecurityHeadersConfig:
    """Configuration for security headers."""

    def __init__(
        self,
        # HSTS configuration
        enable_hsts: bool = True,
        hsts_max_age: int = DEFAULT_HSTS_MAX_AGE,
        hsts_include_subdomains: bool = DEFAULT_HSTS_INCLUDE_SUBDOMAINS,
        hsts_preload: bool = DEFAULT_HSTS_PRELOAD,
        # Frame options
        frame_options: str = DEFAULT_FRAME_OPTIONS,
        # Content type options
        content_type_options: str = DEFAULT_CONTENT_TYPE_OPTIONS,
        # XSS protection
        xss_protection: str = DEFAULT_XSS_PROTECTION,
        # Referrer policy
        referrer_policy: str = DEFAULT_REFERRER_POLICY,
        # CSP configuration
        enable_csp: bool = True,
        csp_policy: Optional[Dict[str, List[str]]] = None,
        csp_report_uri: Optional[str] = None,
        csp_report_only: bool = False,
        # Permissions policy
        enable_permissions_policy: bool = True,
        permissions_policy: Optional[Dict[str, List[str]]] = None,
        # Cross-Origin policies
        enable_coep: bool = True,
        coep_policy: str = "same-origin",
        enable_coop: bool = True,
        coop_policy: str = "same-origin",
        enable_corp: bool = True,
        corp_policy: str = "same-origin",
        # Additional custom headers
        custom_headers: Optional[Dict[str, str]] = None,
        # Environment-specific settings
        force_https: Optional[bool] = None,
    ):
        """Initialize security headers configuration."""
        # Auto-detect HTTPS requirement based on environment
        if force_https is None:
            force_https = settings.ENVIRONMENT.lower() not in [
                "development",
                "dev",
                "local",
                "test",
            ]

        self.enable_hsts = enable_hsts and force_https
        self.hsts_max_age = hsts_max_age
        self.hsts_include_subdomains = hsts_include_subdomains
        self.hsts_preload = hsts_preload
        self.force_https = force_https

        self.frame_options = frame_options
        self.content_type_options = content_type_options
        self.xss_protection = xss_protection
        self.referrer_policy = referrer_policy

        self.enable_csp = enable_csp
        self.csp_report_uri = csp_report_uri
        self.csp_report_only = csp_report_only

        self.enable_permissions_policy = enable_permissions_policy

        self.enable_coep = enable_coep
        self.coep_policy = coep_policy
        self.enable_coop = enable_coop
        self.coop_policy = coop_policy
        self.enable_corp = enable_corp
        self.corp_policy = corp_policy

        self.custom_headers = custom_headers or {}

        # Initialize policy builders
        if enable_csp:
            self.csp_builder = CSPBuilder(csp_policy)

        if enable_permissions_policy:
            self.permissions_builder = PermissionsPolicyBuilder(permissions_policy)

    def get_security_headers(
        self, request_path: str, is_https: bool = False
    ) -> Dict[str, str]:
        """Generate security headers for the given request."""
        headers = {}

        # HSTS (only for HTTPS)
        if self.enable_hsts and (is_https or not self.force_https):
            hsts_value = f"max-age={self.hsts_max_age}"
            if self.hsts_include_subdomains:
                hsts_value += "; includeSubDomains"
            if self.hsts_preload:
                hsts_value += "; preload"
            headers["Strict-Transport-Security"] = hsts_value

        # Frame options (clickjacking protection)
        headers["X-Frame-Options"] = self.frame_options

        # Content type options (MIME sniffing protection)
        headers["X-Content-Type-Options"] = self.content_type_options

        # XSS protection (for legacy browsers)
        headers["X-XSS-Protection"] = self.xss_protection

        # Referrer policy
        headers["Referrer-Policy"] = self.referrer_policy

        # Content Security Policy
        if self.enable_csp:
            csp_header = (
                "Content-Security-Policy-Report-Only"
                if self.csp_report_only
                else "Content-Security-Policy"
            )

            # Adjust CSP based on request path
            if self._is_api_path(request_path):
                # Use strict API CSP
                self.csp_builder.policy = DEFAULT_CSP_API.copy()
            else:
                # Use web application CSP
                self.csp_builder.policy = DEFAULT_CSP_WEB.copy()

            # Add report URI if configured
            if self.csp_report_uri:
                self.csp_builder.add_source("report-uri", self.csp_report_uri)

            headers[csp_header] = self.csp_builder.build()

        # Permissions Policy
        if self.enable_permissions_policy:
            headers["Permissions-Policy"] = self.permissions_builder.build()

        # Cross-Origin Embedder Policy
        if self.enable_coep:
            headers["Cross-Origin-Embedder-Policy"] = self.coep_policy

        # Cross-Origin Opener Policy
        if self.enable_coop:
            headers["Cross-Origin-Opener-Policy"] = self.coop_policy

        # Cross-Origin Resource Policy
        if self.enable_corp:
            headers["Cross-Origin-Resource-Policy"] = self.corp_policy

        # Additional security headers
        headers.update(
            {
                "X-Permitted-Cross-Domain-Policies": "none",
                "X-Download-Options": "noopen",
                "X-Robots-Tag": "none",
                "Cache-Control": "no-store, no-cache, must-revalidate, private",
                "Pragma": "no-cache",
                "Expires": "0",
            }
        )

        # Custom headers
        headers.update(self.custom_headers)

        return headers

    def _is_api_path(self, path: str) -> bool:
        """Check if path is an API endpoint."""
        return any(path.startswith(api_path) for api_path in API_PATHS)

    def generate_csp_nonce(self, directive: str = "script") -> Optional[str]:
        """Generate CSP nonce for inline scripts/styles."""
        if self.enable_csp:
            nonce = self.csp_builder.generate_nonce(directive)
            self.csp_builder.add_nonce_to_directive(f"{directive}-src", nonce)
            return nonce
        return None


class SecurityHeadersMiddleware(BaseHTTPMiddleware):
    """
    Enterprise security headers middleware.

    Automatically applies comprehensive security headers to all responses
    with path-specific configurations and environment-aware settings.
    """

    def __init__(
        self,
        app,
        config: Optional[SecurityHeadersConfig] = None,
        path_configs: Optional[Dict[str, SecurityHeadersConfig]] = None,
        enable_security_logging: bool = True,
    ):
        """
        Initialize security headers middleware.

        Args:
            app: FastAPI application
            config: Default security headers configuration
            path_configs: Path-specific security configurations
            enable_security_logging: Enable security event logging
        """
        super().__init__(app)

        self.default_config = config or SecurityHeadersConfig()
        self.path_configs = path_configs or {}
        self.enable_security_logging = enable_security_logging

        logger.info(
            "Security headers middleware initialized",
            hsts_enabled=self.default_config.enable_hsts,
            csp_enabled=self.default_config.enable_csp,
            permissions_policy_enabled=self.default_config.enable_permissions_policy,
            path_configs=len(self.path_configs),
        )

    async def dispatch(self, request: Request, call_next):
        """Process request with security headers."""
        # Process the request
        response = await call_next(request)

        # Get appropriate security configuration
        security_config = self._get_security_config_for_path(request.url.path)

        # Determine if request is over HTTPS
        is_https = (
            request.url.scheme == "https"
            or request.headers.get("x-forwarded-proto") == "https"
        )

        # Generate security headers
        security_headers = security_config.get_security_headers(
            request.url.path, is_https
        )

        # Apply security headers to response
        for header_name, header_value in security_headers.items():
            response.headers[header_name] = header_value

        # Add security context to request state for other middleware
        request.state.security_headers_applied = True
        request.state.csp_nonce = getattr(security_config, "csp_builder", None)

        # Log security headers application
        if self.enable_security_logging:
            logger.debug(
                "Security headers applied",
                path=request.url.path,
                headers_count=len(security_headers),
                hsts_applied=is_https and security_config.enable_hsts,
                csp_applied=security_config.enable_csp,
            )

            # Log security violations if any
            self._check_security_violations(request, response)

        return response

    def _get_security_config_for_path(self, path: str) -> SecurityHeadersConfig:
        """Get security configuration for specific path."""
        # Check path-specific configurations
        for path_pattern, config in self.path_configs.items():
            if path.startswith(path_pattern):
                return config

        # Return default configuration
        return self.default_config

    def _check_security_violations(self, request: Request, response: Response):
        """Check for potential security violations."""
        violations = []

        # Check for missing HTTPS in production
        if (
            self.default_config.force_https
            and request.url.scheme != "https"
            and request.headers.get("x-forwarded-proto") != "https"
        ):
            violations.append("http_in_production")

        # Check for sensitive data in URL parameters
        if request.query_params:
            sensitive_params = ["password", "token", "secret", "key", "api_key"]
            for param in request.query_params:
                if any(sensitive in param.lower() for sensitive in sensitive_params):
                    violations.append(f"sensitive_param_in_url:{param}")

        # Check response headers for potential info disclosure
        server_header = response.headers.get("server", "")
        if server_header and (
            "apache" in server_header.lower() or "nginx" in server_header.lower()
        ):
            violations.append("server_version_disclosure")

        # Log violations
        if violations:
            logger.warning(
                "Security violations detected",
                path=request.url.path,
                violations=violations,
                client_ip=request.client.host if request.client else "unknown",
                user_agent=request.headers.get("user-agent", "")[:100],
            )


def create_security_headers_middleware(
    app,
    enable_hsts: Optional[bool] = None,
    enable_csp: Optional[bool] = None,
    csp_report_uri: Optional[str] = None,
    **kwargs,
) -> SecurityHeadersMiddleware:
    """
    Factory function to create security headers middleware.

    Args:
        app: FastAPI application
        enable_hsts: Enable HSTS (auto-detected based on environment if None)
        enable_csp: Enable CSP (default True)
        csp_report_uri: CSP report URI for violation reporting
        **kwargs: Additional security configuration options

    Returns:
        Configured security headers middleware
    """
    # Auto-detect HTTPS requirements based on environment
    if enable_hsts is None:
        enable_hsts = settings.ENVIRONMENT.lower() not in [
            "development",
            "dev",
            "local",
            "test",
        ]

    if enable_csp is None:
        enable_csp = True

    config = SecurityHeadersConfig(
        enable_hsts=enable_hsts,
        enable_csp=enable_csp,
        csp_report_uri=csp_report_uri,
        **kwargs,
    )

    return SecurityHeadersMiddleware(app, config=config)
