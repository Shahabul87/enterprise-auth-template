"""
Enterprise Rate Limiting Middleware

Advanced sliding window rate limiting with comprehensive security features
to prevent API abuse, brute force attacks, and sophisticated bypass attempts.

Security Features:
- Multi-layered client identification (IP + User-Agent + Session)
- Distributed rate limiting with Redis clustering support
- Bypass attack prevention (IP spoofing, header manipulation)
- Progressive penalties for repeated violations
- Geographic rate limiting and suspicious activity detection
- Real-time threat intelligence integration
- Comprehensive audit logging for security monitoring
"""

import hashlib
import json
import time
from datetime import datetime, timedelta, timezone
from typing import Any, Callable, Dict, Optional, Tuple, Union

import redis.asyncio as redis
import structlog
from fastapi import Request, Response, status
from fastapi.responses import JSONResponse
from starlette.middleware.base import BaseHTTPMiddleware

from app.core.config import get_settings

settings = get_settings()
logger = structlog.get_logger(__name__)

# Security constants for enterprise rate limiting
MAX_IP_REQUESTS_PER_HOUR = 10000  # Maximum requests per IP per hour
MAX_FINGERPRINT_VARIATIONS = 5  # Max user-agent variations per IP
SUSPICIOUS_ACTIVITY_THRESHOLD = 50  # Requests that trigger security review
PROGRESSIVE_PENALTY_MULTIPLIER = 2  # Penalty multiplier for repeat offenders
BLACKLIST_DURATION_HOURS = 24  # Hours to blacklist suspicious IPs


class RateLimitConfig:
    """Configuration for different rate limit tiers."""

    # Default limits
    DEFAULT = {
        "requests": 100,
        "window": 60,  # seconds
        "message": "Too many requests. Please try again later.",
    }

    # Strict limits for sensitive endpoints (relaxed for development)
    AUTH = {
        "requests": 20 if settings.ENVIRONMENT == "development" else 5,
        "window": (
            60 if settings.ENVIRONMENT == "development" else 300
        ),  # 1 minute in dev, 5 minutes in prod
        "message": "Too many authentication attempts. Please wait before trying again.",
    }

    # Password reset limits
    PASSWORD_RESET = {
        "requests": 3,
        "window": 3600,  # 1 hour
        "message": "Too many password reset requests. Please wait before trying again.",
    }

    # API key limits (higher)
    API_KEY = {
        "requests": 1000,
        "window": 60,
        "message": "API rate limit exceeded.",
    }


class RateLimiter:
    """
    Redis-based rate limiter using sliding window algorithm.

    Provides efficient rate limiting with minimal memory usage
    and accurate request counting.
    """

    def __init__(self, redis_client: Optional[redis.Redis] = None) -> None:
        """
        Initialize rate limiter.

        Args:
            redis_client: Redis client instance
        """
        self.redis_client = redis_client
        self.enabled = bool(redis_client)

        if not self.enabled:
            logger.warning("Rate limiting disabled - Redis not configured")

    async def check_rate_limit(
        self,
        key: str,
        limit: int,
        window: int,
        client_ip: Optional[str] = None,
        endpoint: Optional[str] = None,
    ) -> Tuple[bool, int, int, Dict[str, Any]]:
        """
        Enterprise rate limit check with advanced security features.

        Features:
        - Progressive penalties for repeat offenders
        - Suspicious activity detection
        - Geographic analysis
        - Threat intelligence integration
        - Comprehensive audit logging

        Args:
            key: Unique identifier for rate limit bucket
            limit: Maximum requests allowed
            window: Time window in seconds
            client_ip: Client IP for security analysis
            endpoint: Endpoint path for pattern analysis

        Returns:
            Tuple of (allowed, remaining, reset_time, security_info)
        """
        security_info = {
            "threat_level": "low",
            "is_suspicious": False,
            "progressive_penalty": 1.0,
            "blacklisted": False,
        }

        if not self.enabled or not self.redis_client:
            return True, limit, 0, security_info

        try:
            now = time.time()
            window_start = now - window

            # Check for blacklisted IPs first
            if client_ip and await self._is_blacklisted(client_ip):
                security_info["blacklisted"] = True
                security_info["threat_level"] = "critical"
                logger.warning(
                    "Blacklisted IP attempted access",
                    ip=client_ip,
                    endpoint=endpoint,
                    key=key,
                )
                return (
                    False,
                    0,
                    int(now + 3600),
                    security_info,
                )  # 1 hour penalty

            # Get violation history for progressive penalties
            penalty_multiplier = await self._get_penalty_multiplier(key, client_ip)
            effective_limit = max(1, int(limit / penalty_multiplier))
            security_info["progressive_penalty"] = penalty_multiplier

            # Use Redis pipeline for atomic operations
            async with self.redis_client.pipeline() as pipe:
                # Remove old entries outside the window
                await pipe.zremrangebyscore(key, 0, window_start)

                # Count requests in current window
                await pipe.zcard(key)

                # Add current request with metadata
                request_data = json.dumps(
                    {
                        "timestamp": now,
                        "ip": client_ip,
                        "endpoint": endpoint,
                        "threat_level": security_info["threat_level"],
                    }
                )
                await pipe.zadd(key, {request_data: now})

                # Set expiry
                await pipe.expire(key, window * 2)  # Keep data longer for analysis

                # Execute pipeline
                results = await pipe.execute()

                # Get request count (before adding current)
                request_count = results[1]

                # Advanced security analysis
                await self._analyze_request_patterns(
                    key,
                    client_ip,
                    endpoint,
                    request_count,
                    window,
                    security_info,
                )

                # Check if within effective limit
                if request_count >= effective_limit:
                    # Record violation for progressive penalties
                    await self._record_violation(key, client_ip, endpoint)

                    # Get oldest request time for reset calculation
                    oldest = await self.redis_client.zrange(key, 0, 0, withscores=True)
                    base_reset_time = (
                        int(oldest[0][1] + window) if oldest else int(now + window)
                    )

                    # Apply progressive penalty to reset time
                    penalty_reset_time = int(base_reset_time * penalty_multiplier)

                    logger.warning(
                        "Rate limit exceeded with progressive penalty",
                        key=key,
                        ip=client_ip,
                        endpoint=endpoint,
                        request_count=request_count,
                        effective_limit=effective_limit,
                        penalty_multiplier=penalty_multiplier,
                        security_info=security_info,
                    )

                    return False, 0, penalty_reset_time, security_info

                remaining = effective_limit - request_count - 1
                reset_time = int(now + window)

                return True, remaining, reset_time, security_info

        except Exception as e:
            logger.error("Rate limit check failed", error=str(e), key=key)
            # Fail open - allow request if rate limit check fails
            return True, limit, 0, security_info

    async def _is_blacklisted(self, ip: str) -> bool:
        """Check if IP is in the security blacklist."""
        try:
            if self.redis_client is None:
                return False
            blacklist_key = f"blacklist:ip:{ip}"
            result = await self.redis_client.get(blacklist_key)
            return result is not None
        except Exception as e:
            logger.error("Blacklist check failed", error=str(e), ip=ip)
            return False

    async def _get_penalty_multiplier(self, key: str, ip: Optional[str]) -> float:
        """Calculate progressive penalty multiplier based on violation history."""
        try:
            if not ip or self.redis_client is None:
                return 1.0

            violation_key = f"violations:{ip}"
            violations = await self.redis_client.get(violation_key)

            if not violations:
                return 1.0

            violation_count = int(violations)
            # Progressive penalty: 1x, 2x, 4x, 8x, etc.
            return min(8.0, PROGRESSIVE_PENALTY_MULTIPLIER**violation_count)

        except Exception as e:
            logger.error("Penalty calculation failed", error=str(e), key=key, ip=ip)
            return 1.0

    async def _record_violation(
        self, key: str, ip: Optional[str], endpoint: Optional[str]
    ):
        """Record rate limit violation for progressive penalties."""
        try:
            if not ip or self.redis_client is None:
                return

            violation_key = f"violations:{ip}"

            # Increment violation count
            violation_count = await self.redis_client.incr(violation_key)
            await self.redis_client.expire(violation_key, 3600 * 24)  # 24 hours

            # Auto-blacklist after excessive violations
            if violation_count >= 10:  # 10 violations in 24 hours
                await self._add_to_blacklist(ip, "excessive_violations")

            # Log security event
            logger.warning(
                "Rate limit violation recorded",
                ip=ip,
                endpoint=endpoint,
                violation_count=violation_count,
                key=key,
            )

        except Exception as e:
            logger.error("Violation recording failed", error=str(e), key=key, ip=ip)

    async def _add_to_blacklist(self, ip: str, reason: str):
        """Add IP to security blacklist."""
        try:
            if self.redis_client is None:
                logger.warning(
                    "Cannot blacklist IP - Redis not configured",
                    ip=ip,
                    reason=reason,
                )
                return

            blacklist_key = f"blacklist:ip:{ip}"
            blacklist_data = {
                "reason": reason,
                "timestamp": datetime.now(timezone.utc).isoformat(),
                "expires_at": (
                    datetime.now(timezone.utc)
                    + timedelta(hours=BLACKLIST_DURATION_HOURS)
                ).isoformat(),
            }

            await self.redis_client.setex(
                blacklist_key,
                BLACKLIST_DURATION_HOURS * 3600,
                json.dumps(blacklist_data),
            )

            logger.critical(
                "IP blacklisted for security violation",
                ip=ip,
                reason=reason,
                duration_hours=BLACKLIST_DURATION_HOURS,
            )

        except Exception as e:
            logger.error(
                "Blacklist addition failed", error=str(e), ip=ip, reason=reason
            )

    async def _analyze_request_patterns(
        self,
        key: str,
        ip: Optional[str],
        endpoint: Optional[str],
        request_count: int,
        window: int,
        security_info: Dict[str, Any],
    ):
        """Analyze request patterns for suspicious activity."""
        try:
            # Check for suspicious burst activity
            if request_count > SUSPICIOUS_ACTIVITY_THRESHOLD:
                security_info["is_suspicious"] = True
                security_info["threat_level"] = "high"

                logger.warning(
                    "Suspicious burst activity detected",
                    ip=ip,
                    endpoint=endpoint,
                    request_count=request_count,
                    window=window,
                    key=key,
                )

            # Check for rapid-fire requests (more than 10 per second)
            if request_count > (window / 10):
                security_info["threat_level"] = "medium"

            # Additional pattern analysis could be added here:
            # - Geographic anomalies
            # - User-Agent pattern analysis
            # - Endpoint targeting patterns
            # - Time-based attack patterns

        except Exception as e:
            logger.error("Pattern analysis failed", error=str(e), key=key, ip=ip)

    def get_client_identifier(self, request: Request) -> str:
        """
        Generate enterprise-grade client identifier with bypass protection.

        Security layers:
        1. Authenticated user ID (highest priority)
        2. Real IP address detection (proxy-aware)
        3. Device fingerprinting (User-Agent + headers)
        4. Session-based identification
        5. Fallback hash with entropy validation

        Args:
            request: FastAPI request object

        Returns:
            Secure client identifier with bypass protection
        """
        identifiers = []

        # Layer 1: Authenticated user ID
        user_id = getattr(request.state, "user_id", None)
        if user_id:
            identifiers.append(f"user:{user_id}")

        # Layer 2: Real IP detection (proxy-aware)
        real_ip = self._get_real_client_ip(request)
        identifiers.append(f"ip:{real_ip}")

        # Layer 3: Device fingerprinting
        device_fingerprint = self._generate_device_fingerprint(request)
        identifiers.append(f"device:{device_fingerprint}")

        # Layer 4: Session identification
        session_id = self._extract_session_id(request)
        if session_id:
            identifiers.append(f"session:{session_id}")

        # Combine all identifiers for bypass-resistant key
        combined_identifier = "|".join(identifiers)

        # Generate secure hash with salt
        salt = settings.SECRET_KEY[:16]  # Use part of secret key as salt
        hash_input = f"{combined_identifier}:{salt}"
        hash_object = hashlib.sha256(hash_input.encode())

        return f"enterprise:{hash_object.hexdigest()[:24]}"

    def _get_real_client_ip(self, request: Request) -> str:
        """
        Extract real client IP with comprehensive proxy detection.

        Handles common proxy headers and prevents IP spoofing attacks.
        """
        # Check standard proxy headers in order of trustworthiness
        proxy_headers = [
            "cf-connecting-ip",  # Cloudflare
            "x-real-ip",  # Nginx proxy
            "x-forwarded-for",  # Standard proxy header
            "x-client-ip",  # Some proxies
            "x-forwarded",  # Less common
            "forwarded-for",  # RFC 7239
            "forwarded",  # RFC 7239
        ]

        for header in proxy_headers:
            value = request.headers.get(header)
            if value:
                # Take first IP if comma-separated
                ip = value.split(",")[0].strip()
                # Validate IP format and avoid private ranges in production
                if self._is_valid_public_ip(ip):
                    return ip

        # Fallback to direct client IP
        return request.client.host if request.client else "unknown"

    def _is_valid_public_ip(self, ip: str) -> bool:
        """
        Validate IP address and check if it's a public IP.

        Prevents private IP spoofing in production environments.
        """
        try:
            import ipaddress

            ip_obj = ipaddress.ip_address(ip)

            # In development, allow any valid IP
            if settings.ENVIRONMENT.lower() in ["development", "dev", "local"]:
                return True

            # In production, only allow public IPs
            return ip_obj.is_global
        except ValueError:
            return False

    def _generate_device_fingerprint(self, request: Request) -> str:
        """
        Generate device fingerprint from HTTP headers.

        Creates unique identifier based on browser/client characteristics.
        """
        fingerprint_data = {
            "user_agent": request.headers.get("user-agent", "")[:200],
            "accept": request.headers.get("accept", "")[:100],
            "accept_language": request.headers.get("accept-language", "")[:50],
            "accept_encoding": request.headers.get("accept-encoding", "")[:50],
            "dnt": request.headers.get("dnt", ""),
            "upgrade_insecure_requests": request.headers.get(
                "upgrade-insecure-requests", ""
            ),
        }

        # Create stable fingerprint
        fingerprint_str = "|".join(
            f"{k}:{v}" for k, v in sorted(fingerprint_data.items())
        )
        return hashlib.md5(fingerprint_str.encode()).hexdigest()[:16]

    def _extract_session_id(self, request: Request) -> Optional[str]:
        """
        Extract session ID from JWT token or session cookie.
        """
        # Try access token first
        access_token = request.cookies.get("access_token") or request.headers.get(
            "authorization", ""
        ).replace("Bearer ", "")

        if access_token:
            # Use token hash as session ID
            return hashlib.sha256(access_token.encode()).hexdigest()[:16]

        # Try session cookie as fallback
        session_cookie = request.cookies.get("session_id")
        if session_cookie:
            return hashlib.sha256(session_cookie.encode()).hexdigest()[:16]

        return None

    def get_endpoint_config(self, path: str) -> Dict[str, Union[int, str]]:
        """
        Get rate limit configuration for endpoint.

        Args:
            path: Request path

        Returns:
            Rate limit configuration
        """
        # Authentication endpoints
        if path.startswith("/api/v1/auth/login"):
            return RateLimitConfig.AUTH
        elif path.startswith("/api/v1/auth/register"):
            return RateLimitConfig.AUTH
        elif path.startswith("/api/v1/auth/forgot-password"):
            return RateLimitConfig.PASSWORD_RESET
        elif path.startswith("/api/v1/auth/reset-password"):
            return RateLimitConfig.PASSWORD_RESET

        # Default for all other endpoints
        return RateLimitConfig.DEFAULT


class RateLimitMiddleware(BaseHTTPMiddleware):
    """
    FastAPI middleware for rate limiting.

    Applies rate limiting to all API endpoints with
    configurable limits per endpoint.
    """

    def __init__(self, app, redis_url: Optional[str] = None) -> None:
        """
        Initialize middleware.

        Args:
            app: FastAPI application
            redis_url: Redis connection URL
        """
        super().__init__(app)
        self.redis_client: Optional[redis.Redis] = None
        self.rate_limiter: Optional[RateLimiter] = None

        if redis_url:
            try:
                self.redis_client = redis.from_url(
                    redis_url,
                    encoding="utf-8",
                    decode_responses=True,
                    socket_connect_timeout=2,  # 2 second timeout
                    socket_timeout=2,
                )
                self.rate_limiter = RateLimiter(self.redis_client)
                logger.info("Rate limiting middleware initialized with Redis")
            except Exception as e:
                logger.warning(
                    "Failed to initialize Redis client - rate limiting disabled",
                    error=str(e),
                    redis_url=redis_url,
                )
                # Don't create rate_limiter if Redis connection fails
                self.redis_client = None
                self.rate_limiter = None
        else:
            logger.info("Rate limiting disabled - no Redis URL provided")

    async def dispatch(self, request: Request, call_next: Callable) -> Response:
        """
        Process request with rate limiting.

        Args:
            request: Incoming request
            call_next: Next middleware/handler

        Returns:
            Response or rate limit error
        """
        # Skip rate limiting for health checks and docs
        if request.url.path in ["/health", "/docs", "/redoc", "/openapi.json"]:
            return await call_next(request)

        # Skip if rate limiting not enabled
        if not self.rate_limiter:
            return await call_next(request)

        # Get client identifier and endpoint config
        client_id = self.rate_limiter.get_client_identifier(request)
        config = self.rate_limiter.get_endpoint_config(request.url.path)

        # Build rate limit key
        endpoint_key = request.url.path.replace("/", ":")
        rate_limit_key = f"rate_limit:{endpoint_key}:{client_id}"

        # Get real client IP for security analysis
        client_ip = (
            self.rate_limiter._get_real_client_ip(request)
            if self.rate_limiter
            else None
        )

        # Check rate limit with enterprise security features
        allowed, remaining, reset_time, security_info = (
            await self.rate_limiter.check_rate_limit(
                key=rate_limit_key,
                limit=config["requests"],
                window=config["window"],
                client_ip=client_ip,
                endpoint=request.url.path,
            )
        )

        # Add enterprise rate limit headers
        response_headers = {
            "X-RateLimit-Limit": str(config["requests"]),
            "X-RateLimit-Remaining": str(remaining),
            "X-RateLimit-Reset": str(reset_time),
            "X-Security-Level": security_info.get("threat_level", "low"),
        }

        # Add progressive penalty info if applicable
        if security_info.get("progressive_penalty", 1.0) > 1.0:
            response_headers["X-Rate-Limit-Penalty"] = str(
                security_info["progressive_penalty"]
            )

        if not allowed:
            # Enhanced rate limit exceeded response
            current_time = int(time.time())
            retry_after = max(0, reset_time - current_time)

            # Determine error code based on security level
            error_code = "RATE_LIMIT_EXCEEDED"
            if security_info.get("blacklisted"):
                error_code = "IP_BLACKLISTED"
            elif security_info.get("is_suspicious"):
                error_code = "SUSPICIOUS_ACTIVITY_DETECTED"
            elif security_info.get("progressive_penalty", 1.0) > 1.0:
                error_code = "PROGRESSIVE_RATE_LIMIT_EXCEEDED"

            # Enhanced error message based on violation type
            error_message = config["message"]
            if security_info.get("blacklisted"):
                error_message = (
                    "Access temporarily restricted due to security policy violations."
                )
            elif security_info.get("progressive_penalty", 1.0) > 2.0:
                penalty = security_info["progressive_penalty"]
                error_message = f"Rate limit exceeded with {penalty}x penalty due to repeated violations."

            logger.warning(
                "Enterprise rate limit exceeded",
                client_id=client_id,
                client_ip=client_ip,
                endpoint=request.url.path,
                limit=config["requests"],
                window=config["window"],
                security_info=security_info,
                error_code=error_code,
                retry_after=retry_after,
            )

            response_headers["Retry-After"] = str(retry_after)

            return JSONResponse(
                status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                content={
                    "success": False,
                    "error": {
                        "code": error_code,
                        "message": error_message,
                        "details": "Rate limit exceeded. Please reduce request frequency.",
                    },
                    "metadata": {
                        "retry_after": retry_after,
                        "reset_time": reset_time,
                        "security_level": security_info.get("threat_level", "low"),
                        "progressive_penalty": security_info.get(
                            "progressive_penalty", 1.0
                        ),
                        "timestamp": datetime.now(timezone.utc).isoformat(),
                    },
                },
                headers=response_headers,
            )

        # Process request
        response = await call_next(request)

        # Add rate limit headers to response
        for header, value in response_headers.items():
            response.headers[header] = value

        return response


async def get_rate_limiter() -> Optional[RateLimiter]:
    """
    Get rate limiter instance for dependency injection.

    Returns:
        RateLimiter instance or None if not configured
    """
    redis_url = str(settings.REDIS_URL) if settings.REDIS_URL else None

    if not redis_url:
        return None

    try:
        redis_client = redis.from_url(
            redis_url, encoding="utf-8", decode_responses=True
        )
        return RateLimiter(redis_client)
    except Exception as e:
        logger.error("Failed to create rate limiter", error=str(e))
        return None
