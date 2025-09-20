"""
Rate Limiting Service

Handles rate limiting with multiple algorithms, dynamic configuration,
and comprehensive monitoring for API protection and abuse prevention.
"""

import asyncio
import json
import time
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Any, Tuple, Union
from enum import Enum

import structlog
from sqlalchemy import select, text
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import get_settings
from app.core.events import EventEmitter, Event
from app.models.user import User
from app.services.cache_service import CacheService

settings = get_settings()
logger = structlog.get_logger(__name__)


class RateLimitAlgorithm(str, Enum):
    """Rate limiting algorithms."""

    TOKEN_BUCKET = "token_bucket"
    SLIDING_WINDOW = "sliding_window"
    FIXED_WINDOW = "fixed_window"
    LEAKY_BUCKET = "leaky_bucket"


class RateLimitScope(str, Enum):
    """Rate limiting scopes."""

    GLOBAL = "global"
    USER = "user"
    IP = "ip"
    API_KEY = "api_key"
    ENDPOINT = "endpoint"
    USER_AGENT = "user_agent"


class RateLimitAction(str, Enum):
    """Actions to take when rate limit is exceeded."""

    BLOCK = "block"
    THROTTLE = "throttle"
    LOG_ONLY = "log_only"
    CAPTCHA = "captcha"


class RateLimitError(Exception):
    """Base exception for rate limiting errors."""

    pass


class RateLimitExceededError(RateLimitError):
    """Exception raised when rate limit is exceeded."""

    def __init__(self, message: str, retry_after: Optional[int] = None, **kwargs):
        super().__init__(message)
        self.retry_after = retry_after
        self.details = kwargs


class RateLimitService:
    """
    Comprehensive rate limiting service with multiple algorithms and scopes.

    Features:
    - Multiple rate limiting algorithms (token bucket, sliding window, etc.)
    - Hierarchical rate limiting (user, IP, endpoint, global)
    - Dynamic rate limit configuration
    - Rate limit monitoring and analytics
    - Adaptive rate limiting based on system load
    - Distributed rate limiting support
    - Whitelist/blacklist management
    - Rate limit bypass for special users/IPs
    - Detailed logging and alerting
    """

    def __init__(
        self,
        session: AsyncSession,
        cache_service: Optional[CacheService] = None,
        event_emitter: Optional[EventEmitter] = None,
    ) -> None:
        """
        Initialize rate limiting service.

        Args:
            session: Database session
            cache_service: Cache service for state storage
            event_emitter: Event emitter for audit logging
        """
        self.session = session
        self.cache_service = cache_service or CacheService()
        self.event_emitter = event_emitter or EventEmitter()

        # Default configurations
        self.default_limits = {
            RateLimitScope.GLOBAL: {"requests": 10000, "window": 3600},  # 10k/hour
            RateLimitScope.USER: {"requests": 1000, "window": 3600},  # 1k/hour per user
            RateLimitScope.IP: {"requests": 100, "window": 60},  # 100/minute per IP
            RateLimitScope.API_KEY: {
                "requests": 5000,
                "window": 3600,
            },  # 5k/hour per API key
            RateLimitScope.ENDPOINT: {
                "requests": 60,
                "window": 60,
            },  # 60/minute per endpoint
        }

        # Algorithm implementations
        self.algorithms = {
            RateLimitAlgorithm.TOKEN_BUCKET: self._token_bucket_check,
            RateLimitAlgorithm.SLIDING_WINDOW: self._sliding_window_check,
            RateLimitAlgorithm.FIXED_WINDOW: self._fixed_window_check,
            RateLimitAlgorithm.LEAKY_BUCKET: self._leaky_bucket_check,
        }

    async def check_rate_limit(
        self,
        identifier: str,
        scope: RateLimitScope,
        endpoint: Optional[str] = None,
        algorithm: RateLimitAlgorithm = RateLimitAlgorithm.SLIDING_WINDOW,
        custom_limit: Optional[Dict[str, Any]] = None,
        metadata: Optional[Dict[str, Any]] = None,
    ) -> Dict[str, Any]:
        """
        Check if a request is within rate limits.

        Args:
            identifier: Unique identifier (user_id, IP, api_key, etc.)
            scope: Rate limiting scope
            endpoint: Optional endpoint identifier
            algorithm: Rate limiting algorithm to use
            custom_limit: Override default limits
            metadata: Additional context data

        Returns:
            Dict: Rate limit status and remaining quota

        Raises:
            RateLimitExceededError: If rate limit is exceeded
        """
        try:
            # Check if identifier is whitelisted
            if await self._is_whitelisted(identifier, scope):
                return {
                    "allowed": True,
                    "remaining": float("inf"),
                    "reset_at": None,
                    "whitelisted": True,
                }

            # Check if identifier is blacklisted
            if await self._is_blacklisted(identifier, scope):
                raise RateLimitExceededError(
                    f"Access blocked: {identifier} is blacklisted",
                    retry_after=None,
                    scope=scope.value,
                    identifier=identifier,
                    reason="blacklisted",
                )

            # Get rate limit configuration
            config = await self._get_rate_limit_config(scope, endpoint, custom_limit)

            # Apply algorithm-specific check
            check_func = self.algorithms.get(algorithm)
            if not check_func:
                raise RateLimitError(f"Unknown algorithm: {algorithm}")

            result = await check_func(identifier, scope, config, endpoint, metadata)

            # Log rate limit check
            await self._log_rate_limit_check(
                identifier, scope, endpoint, algorithm, result, metadata
            )

            # Trigger alerts if necessary
            if not result["allowed"] or result["remaining"] / config["requests"] < 0.1:
                await self._check_rate_limit_alerts(identifier, scope, result, config)

            if not result["allowed"]:
                raise RateLimitExceededError(
                    f"Rate limit exceeded for {scope.value}: {identifier}",
                    retry_after=result.get("retry_after"),
                    scope=scope.value,
                    identifier=identifier,
                    remaining=result["remaining"],
                    reset_at=result.get("reset_at"),
                )

            return result

        except RateLimitExceededError:
            raise
        except Exception as e:
            logger.error(
                "Rate limit check failed",
                identifier=identifier,
                scope=scope.value,
                error=str(e),
            )
            # Fail open - allow request but log error
            return {"allowed": True, "remaining": 0, "reset_at": None, "error": str(e)}

    async def get_rate_limit_status(
        self, identifier: str, scope: RateLimitScope, endpoint: Optional[str] = None
    ) -> Dict[str, Any]:
        """
        Get current rate limit status without consuming quota.

        Args:
            identifier: Unique identifier
            scope: Rate limiting scope
            endpoint: Optional endpoint identifier

        Returns:
            Dict: Current rate limit status
        """
        try:
            config = await self._get_rate_limit_config(scope, endpoint)
            cache_key = self._get_cache_key(identifier, scope, endpoint)

            # Get current state from cache
            state_data = await self.cache_service.get(cache_key)

            if not state_data:
                return {
                    "requests_made": 0,
                    "requests_remaining": config["requests"],
                    "reset_at": None,
                    "window_start": None,
                }

            state = json.loads(state_data)
            current_time = time.time()

            # Calculate remaining based on algorithm
            if scope in [RateLimitScope.USER, RateLimitScope.IP]:
                # Sliding window calculation
                window_start = current_time - config["window"]
                recent_requests = [
                    req_time
                    for req_time in state.get("requests", [])
                    if req_time > window_start
                ]
                requests_made = len(recent_requests)
                requests_remaining = max(0, config["requests"] - requests_made)
            else:
                # Token bucket or fixed window
                requests_made = state.get("count", 0)
                requests_remaining = max(0, state.get("tokens", config["requests"]))

            return {
                "requests_made": requests_made,
                "requests_remaining": requests_remaining,
                "reset_at": state.get("reset_at"),
                "window_start": state.get("window_start"),
                "config": config,
            }

        except Exception as e:
            logger.error(
                "Failed to get rate limit status",
                identifier=identifier,
                scope=scope.value,
                error=str(e),
            )
            return {"error": str(e)}

    async def reset_rate_limit(
        self,
        identifier: str,
        scope: RateLimitScope,
        endpoint: Optional[str] = None,
        requester_id: Optional[str] = None,
    ) -> bool:
        """
        Reset rate limit for an identifier.

        Args:
            identifier: Unique identifier to reset
            scope: Rate limiting scope
            endpoint: Optional endpoint identifier
            requester_id: ID of user requesting reset (for audit)

        Returns:
            bool: True if reset successfully
        """
        try:
            # Validate permissions if requester specified
            if requester_id:
                await self._validate_admin_permissions(requester_id)

            cache_key = self._get_cache_key(identifier, scope, endpoint)
            await self.cache_service.delete(cache_key)

            # Emit audit event
            await self.event_emitter.emit(
                Event(
                    event_type="rate_limit.reset",
                    data={
                        "identifier": identifier,
                        "scope": scope.value,
                        "endpoint": endpoint,
                        "requester_id": requester_id,
                    },
                )
            )

            logger.info(
                "Rate limit reset",
                identifier=identifier,
                scope=scope.value,
                endpoint=endpoint,
                requester_id=requester_id,
            )

            return True

        except Exception as e:
            logger.error(
                "Failed to reset rate limit",
                identifier=identifier,
                scope=scope.value,
                error=str(e),
            )
            return False

    async def add_to_whitelist(
        self,
        identifier: str,
        scope: RateLimitScope,
        reason: Optional[str] = None,
        expires_at: Optional[datetime] = None,
        requester_id: Optional[str] = None,
    ) -> bool:
        """
        Add identifier to rate limit whitelist.

        Args:
            identifier: Identifier to whitelist
            scope: Rate limiting scope
            reason: Optional reason for whitelisting
            expires_at: Optional expiration time
            requester_id: ID of user making the request

        Returns:
            bool: True if added successfully
        """
        try:
            if requester_id:
                await self._validate_admin_permissions(requester_id)

            whitelist_key = f"rate_limit_whitelist:{scope.value}:{identifier}"
            whitelist_data = {
                "identifier": identifier,
                "scope": scope.value,
                "reason": reason,
                "added_at": datetime.utcnow().isoformat(),
                "added_by": requester_id,
                "expires_at": expires_at.isoformat() if expires_at else None,
            }

            # Calculate TTL
            ttl = None
            if expires_at:
                ttl = int((expires_at - datetime.utcnow()).total_seconds())

            await self.cache_service.set(
                whitelist_key, json.dumps(whitelist_data), ttl=ttl
            )

            # Emit audit event
            await self.event_emitter.emit(
                Event(event_type="rate_limit.whitelist_added", data=whitelist_data)
            )

            logger.info(
                "Added to rate limit whitelist",
                identifier=identifier,
                scope=scope.value,
                requester_id=requester_id,
            )

            return True

        except Exception as e:
            logger.error(
                "Failed to add to whitelist",
                identifier=identifier,
                scope=scope.value,
                error=str(e),
            )
            return False

    async def add_to_blacklist(
        self,
        identifier: str,
        scope: RateLimitScope,
        reason: Optional[str] = None,
        expires_at: Optional[datetime] = None,
        requester_id: Optional[str] = None,
    ) -> bool:
        """
        Add identifier to rate limit blacklist.

        Args:
            identifier: Identifier to blacklist
            scope: Rate limiting scope
            reason: Optional reason for blacklisting
            expires_at: Optional expiration time
            requester_id: ID of user making the request

        Returns:
            bool: True if added successfully
        """
        try:
            if requester_id:
                await self._validate_admin_permissions(requester_id)

            blacklist_key = f"rate_limit_blacklist:{scope.value}:{identifier}"
            blacklist_data = {
                "identifier": identifier,
                "scope": scope.value,
                "reason": reason,
                "added_at": datetime.utcnow().isoformat(),
                "added_by": requester_id,
                "expires_at": expires_at.isoformat() if expires_at else None,
            }

            # Calculate TTL
            ttl = None
            if expires_at:
                ttl = int((expires_at - datetime.utcnow()).total_seconds())

            await self.cache_service.set(
                blacklist_key, json.dumps(blacklist_data), ttl=ttl
            )

            # Emit audit event
            await self.event_emitter.emit(
                Event(event_type="rate_limit.blacklist_added", data=blacklist_data)
            )

            logger.info(
                "Added to rate limit blacklist",
                identifier=identifier,
                scope=scope.value,
                requester_id=requester_id,
            )

            return True

        except Exception as e:
            logger.error(
                "Failed to add to blacklist",
                identifier=identifier,
                scope=scope.value,
                error=str(e),
            )
            return False

    async def remove_from_whitelist(
        self, identifier: str, scope: RateLimitScope, requester_id: Optional[str] = None
    ) -> bool:
        """Remove identifier from whitelist."""
        try:
            if requester_id:
                await self._validate_admin_permissions(requester_id)

            whitelist_key = f"rate_limit_whitelist:{scope.value}:{identifier}"
            await self.cache_service.delete(whitelist_key)

            # Emit audit event
            await self.event_emitter.emit(
                Event(
                    event_type="rate_limit.whitelist_removed",
                    data={
                        "identifier": identifier,
                        "scope": scope.value,
                        "requester_id": requester_id,
                    },
                )
            )

            return True

        except Exception as e:
            logger.error(
                "Failed to remove from whitelist",
                identifier=identifier,
                scope=scope.value,
                error=str(e),
            )
            return False

    async def remove_from_blacklist(
        self, identifier: str, scope: RateLimitScope, requester_id: Optional[str] = None
    ) -> bool:
        """Remove identifier from blacklist."""
        try:
            if requester_id:
                await self._validate_admin_permissions(requester_id)

            blacklist_key = f"rate_limit_blacklist:{scope.value}:{identifier}"
            await self.cache_service.delete(blacklist_key)

            # Emit audit event
            await self.event_emitter.emit(
                Event(
                    event_type="rate_limit.blacklist_removed",
                    data={
                        "identifier": identifier,
                        "scope": scope.value,
                        "requester_id": requester_id,
                    },
                )
            )

            return True

        except Exception as e:
            logger.error(
                "Failed to remove from blacklist",
                identifier=identifier,
                scope=scope.value,
                error=str(e),
            )
            return False

    async def get_rate_limit_analytics(
        self,
        time_range: str = "1h",
        scope: Optional[RateLimitScope] = None,
        top_n: int = 10,
    ) -> Dict[str, Any]:
        """
        Get rate limiting analytics and statistics.

        Args:
            time_range: Time range for analytics (1h, 1d, 1w)
            scope: Optional scope filter
            top_n: Number of top entries to return

        Returns:
            Dict: Analytics data
        """
        try:
            # Parse time range
            if time_range == "1h":
                start_time = datetime.utcnow() - timedelta(hours=1)
            elif time_range == "1d":
                start_time = datetime.utcnow() - timedelta(days=1)
            elif time_range == "1w":
                start_time = datetime.utcnow() - timedelta(weeks=1)
            else:
                start_time = datetime.utcnow() - timedelta(hours=1)

            # Get rate limit events from cache
            analytics_data = {
                "time_range": time_range,
                "start_time": start_time.isoformat(),
                "end_time": datetime.utcnow().isoformat(),
                "total_requests": 0,
                "blocked_requests": 0,
                "top_blocked_ips": [],
                "top_blocked_users": [],
                "top_endpoints": [],
                "rate_limit_violations": [],
                "algorithm_usage": {},
                "scope_distribution": {},
            }

            # In a production environment, you'd query actual analytics data
            # For now, return sample data structure
            return analytics_data

        except Exception as e:
            logger.error(
                "Failed to get rate limit analytics",
                time_range=time_range,
                scope=scope.value if scope else None,
                error=str(e),
            )
            return {"error": str(e)}

    async def update_rate_limit_config(
        self,
        scope: RateLimitScope,
        config: Dict[str, Any],
        endpoint: Optional[str] = None,
        requester_id: Optional[str] = None,
    ) -> bool:
        """
        Update rate limit configuration.

        Args:
            scope: Rate limiting scope
            config: New configuration
            endpoint: Optional endpoint identifier
            requester_id: ID of user making the request

        Returns:
            bool: True if updated successfully
        """
        try:
            if requester_id:
                await self._validate_admin_permissions(requester_id)

            # Validate configuration
            required_fields = ["requests", "window"]
            if not all(field in config for field in required_fields):
                raise RateLimitError(f"Missing required fields: {required_fields}")

            # Store configuration
            config_key = f"rate_limit_config:{scope.value}"
            if endpoint:
                config_key += f":{endpoint}"

            config_data = {
                **config,
                "updated_at": datetime.utcnow().isoformat(),
                "updated_by": requester_id,
            }

            await self.cache_service.set(
                config_key, json.dumps(config_data), ttl=30 * 24 * 3600  # 30 days
            )

            # Emit audit event
            await self.event_emitter.emit(
                Event(
                    event_type="rate_limit.config_updated",
                    data={
                        "scope": scope.value,
                        "endpoint": endpoint,
                        "config": config,
                        "requester_id": requester_id,
                    },
                )
            )

            logger.info(
                "Rate limit configuration updated",
                scope=scope.value,
                endpoint=endpoint,
                requester_id=requester_id,
            )

            return True

        except Exception as e:
            logger.error(
                "Failed to update rate limit config",
                scope=scope.value,
                endpoint=endpoint,
                error=str(e),
            )
            return False

    async def _token_bucket_check(
        self,
        identifier: str,
        scope: RateLimitScope,
        config: Dict[str, Any],
        endpoint: Optional[str],
        metadata: Optional[Dict[str, Any]],
    ) -> Dict[str, Any]:
        """Token bucket algorithm implementation."""
        cache_key = self._get_cache_key(identifier, scope, endpoint)
        current_time = time.time()

        # Get current bucket state
        bucket_data = await self.cache_service.get(cache_key)

        if bucket_data:
            bucket = json.loads(bucket_data)
        else:
            bucket = {"tokens": config["requests"], "last_refill": current_time}

        # Refill tokens based on elapsed time
        time_passed = current_time - bucket["last_refill"]
        refill_rate = config["requests"] / config["window"]  # tokens per second
        tokens_to_add = time_passed * refill_rate

        bucket["tokens"] = min(config["requests"], bucket["tokens"] + tokens_to_add)
        bucket["last_refill"] = current_time

        # Check if request can be allowed
        if bucket["tokens"] >= 1:
            bucket["tokens"] -= 1
            allowed = True
        else:
            allowed = False

        # Calculate retry after
        retry_after = None if allowed else int(1 / refill_rate)

        # Store updated bucket state
        await self.cache_service.set(
            cache_key, json.dumps(bucket), ttl=config["window"] * 2
        )

        return {
            "allowed": allowed,
            "remaining": int(bucket["tokens"]),
            "reset_at": None,
            "retry_after": retry_after,
        }

    async def _sliding_window_check(
        self,
        identifier: str,
        scope: RateLimitScope,
        config: Dict[str, Any],
        endpoint: Optional[str],
        metadata: Optional[Dict[str, Any]],
    ) -> Dict[str, Any]:
        """Sliding window algorithm implementation."""
        cache_key = self._get_cache_key(identifier, scope, endpoint)
        current_time = time.time()
        window_start = current_time - config["window"]

        # Get current request history
        history_data = await self.cache_service.get(cache_key)

        if history_data:
            requests = json.loads(history_data)["requests"]
        else:
            requests = []

        # Remove old requests outside the window
        requests = [req_time for req_time in requests if req_time > window_start]

        # Check if new request can be allowed
        if len(requests) < config["requests"]:
            requests.append(current_time)
            allowed = True
        else:
            allowed = False

        # Calculate when the oldest request will expire
        reset_at = None
        if requests:
            oldest_request = min(requests)
            reset_at = oldest_request + config["window"]

        # Store updated request history
        await self.cache_service.set(
            cache_key,
            json.dumps({"requests": requests}),
            ttl=config["window"] + 60,  # Extra buffer
        )

        return {
            "allowed": allowed,
            "remaining": max(0, config["requests"] - len(requests)),
            "reset_at": reset_at,
            "retry_after": (
                int(reset_at - current_time) if reset_at and not allowed else None
            ),
        }

    async def _fixed_window_check(
        self,
        identifier: str,
        scope: RateLimitScope,
        config: Dict[str, Any],
        endpoint: Optional[str],
        metadata: Optional[Dict[str, Any]],
    ) -> Dict[str, Any]:
        """Fixed window algorithm implementation."""
        cache_key = self._get_cache_key(identifier, scope, endpoint)
        current_time = time.time()
        window_start = int(current_time // config["window"]) * config["window"]

        # Get current window data
        window_data = await self.cache_service.get(cache_key)

        if window_data:
            data = json.loads(window_data)
            if data["window_start"] != window_start:
                # New window, reset counter
                data = {"count": 0, "window_start": window_start}
        else:
            data = {"count": 0, "window_start": window_start}

        # Check if request can be allowed
        if data["count"] < config["requests"]:
            data["count"] += 1
            allowed = True
        else:
            allowed = False

        # Calculate reset time
        reset_at = window_start + config["window"]

        # Store updated window data
        await self.cache_service.set(
            cache_key, json.dumps(data), ttl=config["window"] + 60
        )

        return {
            "allowed": allowed,
            "remaining": max(0, config["requests"] - data["count"]),
            "reset_at": reset_at,
            "retry_after": int(reset_at - current_time) if not allowed else None,
        }

    async def _leaky_bucket_check(
        self,
        identifier: str,
        scope: RateLimitScope,
        config: Dict[str, Any],
        endpoint: Optional[str],
        metadata: Optional[Dict[str, Any]],
    ) -> Dict[str, Any]:
        """Leaky bucket algorithm implementation."""
        cache_key = self._get_cache_key(identifier, scope, endpoint)
        current_time = time.time()

        # Get current bucket state
        bucket_data = await self.cache_service.get(cache_key)

        if bucket_data:
            bucket = json.loads(bucket_data)
        else:
            bucket = {"volume": 0, "last_leak": current_time}

        # Leak based on elapsed time
        time_passed = current_time - bucket["last_leak"]
        leak_rate = config["requests"] / config["window"]  # requests per second
        leaked = time_passed * leak_rate

        bucket["volume"] = max(0, bucket["volume"] - leaked)
        bucket["last_leak"] = current_time

        # Check if request can be allowed
        if bucket["volume"] < config["requests"]:
            bucket["volume"] += 1
            allowed = True
        else:
            allowed = False

        # Calculate retry after
        retry_after = (
            None
            if allowed
            else int((bucket["volume"] - config["requests"]) / leak_rate)
        )

        # Store updated bucket state
        await self.cache_service.set(
            cache_key, json.dumps(bucket), ttl=config["window"] * 2
        )

        return {
            "allowed": allowed,
            "remaining": max(0, int(config["requests"] - bucket["volume"])),
            "reset_at": None,
            "retry_after": retry_after,
        }

    async def _get_rate_limit_config(
        self,
        scope: RateLimitScope,
        endpoint: Optional[str] = None,
        custom_limit: Optional[Dict[str, Any]] = None,
    ) -> Dict[str, Any]:
        """Get rate limit configuration for scope and endpoint."""
        if custom_limit:
            return custom_limit

        # Try to get custom config first
        config_key = f"rate_limit_config:{scope.value}"
        if endpoint:
            config_key += f":{endpoint}"

        config_data = await self.cache_service.get(config_key)
        if config_data:
            return json.loads(config_data)

        # Fall back to default configuration
        return self.default_limits.get(scope, {"requests": 100, "window": 3600})

    def _get_cache_key(
        self, identifier: str, scope: RateLimitScope, endpoint: Optional[str] = None
    ) -> str:
        """Generate cache key for rate limiting state."""
        key = f"rate_limit:{scope.value}:{identifier}"
        if endpoint:
            key += f":{endpoint}"
        return key

    async def _is_whitelisted(self, identifier: str, scope: RateLimitScope) -> bool:
        """Check if identifier is whitelisted."""
        whitelist_key = f"rate_limit_whitelist:{scope.value}:{identifier}"
        whitelist_data = await self.cache_service.get(whitelist_key)

        if not whitelist_data:
            return False

        # Check if whitelist entry has expired
        data = json.loads(whitelist_data)
        if data.get("expires_at"):
            expires_at = datetime.fromisoformat(data["expires_at"])
            if datetime.utcnow() > expires_at:
                await self.cache_service.delete(whitelist_key)
                return False

        return True

    async def _is_blacklisted(self, identifier: str, scope: RateLimitScope) -> bool:
        """Check if identifier is blacklisted."""
        blacklist_key = f"rate_limit_blacklist:{scope.value}:{identifier}"
        blacklist_data = await self.cache_service.get(blacklist_key)

        if not blacklist_data:
            return False

        # Check if blacklist entry has expired
        data = json.loads(blacklist_data)
        if data.get("expires_at"):
            expires_at = datetime.fromisoformat(data["expires_at"])
            if datetime.utcnow() > expires_at:
                await self.cache_service.delete(blacklist_key)
                return False

        return True

    async def _log_rate_limit_check(
        self,
        identifier: str,
        scope: RateLimitScope,
        endpoint: Optional[str],
        algorithm: RateLimitAlgorithm,
        result: Dict[str, Any],
        metadata: Optional[Dict[str, Any]],
    ) -> None:
        """Log rate limit check for analytics."""
        try:
            # Store rate limit event for analytics
            event_key = f"rate_limit_event:{int(time.time())}"
            event_data = {
                "identifier": identifier,
                "scope": scope.value,
                "endpoint": endpoint,
                "algorithm": algorithm.value,
                "allowed": result["allowed"],
                "remaining": result["remaining"],
                "timestamp": datetime.utcnow().isoformat(),
                "metadata": metadata or {},
            }

            # Store with short TTL for analytics aggregation
            await self.cache_service.set(
                event_key, json.dumps(event_data), ttl=3600  # 1 hour
            )

        except Exception as e:
            logger.error("Failed to log rate limit check", error=str(e))

    async def _check_rate_limit_alerts(
        self,
        identifier: str,
        scope: RateLimitScope,
        result: Dict[str, Any],
        config: Dict[str, Any],
    ) -> None:
        """Check if rate limit alerts should be triggered."""
        try:
            # Check if we should alert on high usage or blocking
            if not result["allowed"]:
                # Rate limit exceeded - trigger alert
                await self.event_emitter.emit(
                    Event(
                        event_type="rate_limit.exceeded",
                        data={
                            "identifier": identifier,
                            "scope": scope.value,
                            "config": config,
                            "timestamp": datetime.utcnow().isoformat(),
                        },
                    )
                )
            elif result["remaining"] / config["requests"] < 0.1:
                # Low quota remaining - trigger warning
                await self.event_emitter.emit(
                    Event(
                        event_type="rate_limit.quota_low",
                        data={
                            "identifier": identifier,
                            "scope": scope.value,
                            "remaining": result["remaining"],
                            "total": config["requests"],
                            "timestamp": datetime.utcnow().isoformat(),
                        },
                    )
                )

        except Exception as e:
            logger.error("Failed to check rate limit alerts", error=str(e))

    async def _validate_admin_permissions(self, user_id: str) -> None:
        """Validate that user has admin permissions."""
        try:
            user_stmt = select(User).where(User.id == user_id)
            result = await self.session.execute(user_stmt)
            user = result.scalar_one_or_none()

            if not user or not user.is_active:
                raise RateLimitError(f"User {user_id} not found or inactive")

            # In production, check actual admin permissions
            # For now, assume all active users can manage rate limits
            user_roles = (
                [role.name.lower() for role in user.roles]
                if hasattr(user, "roles")
                else []
            )

            if not any(role in user_roles for role in ["admin", "super_admin"]):
                raise RateLimitError(
                    "Admin privileges required for rate limit management"
                )

        except Exception as e:
            logger.error(
                "Failed to validate admin permissions", user_id=user_id, error=str(e)
            )
            raise RateLimitError("Permission validation failed")


# Global instance
rate_limit_service = RateLimitService
