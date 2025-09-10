"""
Environment-specific Rate Limiting Configuration

Provides flexible rate limiting configurations based on environment
and endpoint requirements.
"""

from enum import Enum
from typing import Dict, Optional

from app.core.config import get_settings

settings = get_settings()


class RateLimitTier(Enum):
    """Rate limit tiers for different user types."""

    PUBLIC = "public"  # Unauthenticated users
    BASIC = "basic"  # Basic authenticated users
    PREMIUM = "premium"  # Premium users
    ENTERPRISE = "enterprise"  # Enterprise users
    ADMIN = "admin"  # Admin users
    API = "api"  # API key access


class EnvironmentConfig:
    """Environment-specific rate limit configurations."""

    DEVELOPMENT = {
        "global_multiplier": 10.0,  # 10x more lenient in dev
        "progressive_penalties_enabled": False,
        "blacklist_enabled": False,
        "suspicious_activity_threshold": 500,
        "max_violations_before_blacklist": 100,
    }

    STAGING = {
        "global_multiplier": 2.0,  # 2x more lenient in staging
        "progressive_penalties_enabled": True,
        "blacklist_enabled": True,
        "suspicious_activity_threshold": 100,
        "max_violations_before_blacklist": 20,
    }

    PRODUCTION = {
        "global_multiplier": 1.0,  # Standard limits
        "progressive_penalties_enabled": True,
        "blacklist_enabled": True,
        "suspicious_activity_threshold": 50,
        "max_violations_before_blacklist": 10,
    }


class EndpointRateLimits:
    """
    Endpoint-specific rate limit configurations.

    Format: {requests: number, window: seconds}
    """

    # Authentication endpoints
    AUTH_LOGIN = {
        RateLimitTier.PUBLIC: {"requests": 5, "window": 300},  # 5 per 5 min
        RateLimitTier.BASIC: {"requests": 10, "window": 300},
        RateLimitTier.PREMIUM: {"requests": 20, "window": 300},
        RateLimitTier.ENTERPRISE: {"requests": 50, "window": 300},
        RateLimitTier.ADMIN: {"requests": 100, "window": 300},
    }

    AUTH_REGISTER = {
        RateLimitTier.PUBLIC: {"requests": 3, "window": 3600},  # 3 per hour
        RateLimitTier.BASIC: {"requests": 5, "window": 3600},
        RateLimitTier.PREMIUM: {"requests": 10, "window": 3600},
        RateLimitTier.ENTERPRISE: {"requests": 50, "window": 3600},
        RateLimitTier.ADMIN: {"requests": 100, "window": 3600},
    }

    PASSWORD_RESET = {
        RateLimitTier.PUBLIC: {"requests": 3, "window": 3600},  # 3 per hour
        RateLimitTier.BASIC: {"requests": 5, "window": 3600},
        RateLimitTier.PREMIUM: {"requests": 10, "window": 3600},
        RateLimitTier.ENTERPRISE: {"requests": 20, "window": 3600},
        RateLimitTier.ADMIN: {"requests": 50, "window": 3600},
    }

    # API endpoints
    API_READ = {
        RateLimitTier.PUBLIC: {"requests": 100, "window": 3600},  # 100 per hour
        RateLimitTier.BASIC: {"requests": 1000, "window": 3600},
        RateLimitTier.PREMIUM: {"requests": 5000, "window": 3600},
        RateLimitTier.ENTERPRISE: {"requests": 20000, "window": 3600},
        RateLimitTier.ADMIN: {"requests": 100000, "window": 3600},
        RateLimitTier.API: {"requests": 10000, "window": 3600},
    }

    API_WRITE = {
        RateLimitTier.PUBLIC: {"requests": 10, "window": 3600},  # 10 per hour
        RateLimitTier.BASIC: {"requests": 100, "window": 3600},
        RateLimitTier.PREMIUM: {"requests": 500, "window": 3600},
        RateLimitTier.ENTERPRISE: {"requests": 2000, "window": 3600},
        RateLimitTier.ADMIN: {"requests": 10000, "window": 3600},
        RateLimitTier.API: {"requests": 1000, "window": 3600},
    }

    # File operations
    FILE_UPLOAD = {
        RateLimitTier.PUBLIC: {"requests": 5, "window": 3600},  # 5 per hour
        RateLimitTier.BASIC: {"requests": 20, "window": 3600},
        RateLimitTier.PREMIUM: {"requests": 100, "window": 3600},
        RateLimitTier.ENTERPRISE: {"requests": 500, "window": 3600},
        RateLimitTier.ADMIN: {"requests": 1000, "window": 3600},
    }

    # Search operations
    SEARCH = {
        RateLimitTier.PUBLIC: {"requests": 30, "window": 60},  # 30 per minute
        RateLimitTier.BASIC: {"requests": 60, "window": 60},
        RateLimitTier.PREMIUM: {"requests": 120, "window": 60},
        RateLimitTier.ENTERPRISE: {"requests": 300, "window": 60},
        RateLimitTier.ADMIN: {"requests": 1000, "window": 60},
    }

    # Default for unspecified endpoints
    DEFAULT = {
        RateLimitTier.PUBLIC: {"requests": 60, "window": 60},  # 60 per minute
        RateLimitTier.BASIC: {"requests": 120, "window": 60},
        RateLimitTier.PREMIUM: {"requests": 300, "window": 60},
        RateLimitTier.ENTERPRISE: {"requests": 600, "window": 60},
        RateLimitTier.ADMIN: {"requests": 2000, "window": 60},
        RateLimitTier.API: {"requests": 500, "window": 60},
    }


class RateLimitManager:
    """
    Manager for rate limit configurations.

    Provides methods to get appropriate rate limits based on
    environment, endpoint, and user tier.
    """

    def __init__(self):
        """Initialize rate limit manager."""
        self.environment = settings.ENVIRONMENT.lower()
        self.env_config = self._get_environment_config()

    def _get_environment_config(self) -> Dict:
        """Get environment-specific configuration."""
        if self.environment in ["development", "dev", "local"]:
            return EnvironmentConfig.DEVELOPMENT
        elif self.environment in ["staging", "stage", "test"]:
            return EnvironmentConfig.STAGING
        else:
            return EnvironmentConfig.PRODUCTION

    def get_rate_limit(
        self,
        endpoint: str,
        user_tier: RateLimitTier = RateLimitTier.PUBLIC,
    ) -> Dict[str, int]:
        """
        Get rate limit for endpoint and user tier.

        Args:
            endpoint: API endpoint path
            user_tier: User tier

        Returns:
            Rate limit configuration
        """
        # Map endpoint to configuration
        if "login" in endpoint.lower():
            config = EndpointRateLimits.AUTH_LOGIN
        elif "register" in endpoint.lower():
            config = EndpointRateLimits.AUTH_REGISTER
        elif "password" in endpoint.lower() or "reset" in endpoint.lower():
            config = EndpointRateLimits.PASSWORD_RESET
        elif "upload" in endpoint.lower():
            config = EndpointRateLimits.FILE_UPLOAD
        elif "search" in endpoint.lower():
            config = EndpointRateLimits.SEARCH
        elif any(method in endpoint.lower() for method in ["post", "put", "patch", "delete"]):
            config = EndpointRateLimits.API_WRITE
        elif "get" in endpoint.lower():
            config = EndpointRateLimits.API_READ
        else:
            config = EndpointRateLimits.DEFAULT

        # Get tier-specific limits
        limits = config.get(user_tier, config[RateLimitTier.PUBLIC])

        # Apply environment multiplier
        multiplier = self.env_config["global_multiplier"]

        return {
            "requests": int(limits["requests"] * multiplier),
            "window": limits["window"],
        }

    def get_user_tier(self, user: Optional[Dict]) -> RateLimitTier:
        """
        Determine user tier from user object.

        Args:
            user: User data

        Returns:
            User's rate limit tier
        """
        if not user:
            return RateLimitTier.PUBLIC

        # Check for admin
        if user.get("is_superuser") or user.get("is_admin"):
            return RateLimitTier.ADMIN

        # Check for API key
        if user.get("api_key"):
            return RateLimitTier.API

        # Check for subscription tier
        subscription = user.get("subscription_tier", "").lower()
        if subscription == "enterprise":
            return RateLimitTier.ENTERPRISE
        elif subscription == "premium":
            return RateLimitTier.PREMIUM

        # Default to basic for authenticated users
        return RateLimitTier.BASIC

    def is_progressive_penalties_enabled(self) -> bool:
        """Check if progressive penalties are enabled."""
        return self.env_config["progressive_penalties_enabled"]

    def is_blacklist_enabled(self) -> bool:
        """Check if blacklisting is enabled."""
        return self.env_config["blacklist_enabled"]

    def get_suspicious_activity_threshold(self) -> int:
        """Get suspicious activity threshold."""
        return self.env_config["suspicious_activity_threshold"]

    def get_max_violations_before_blacklist(self) -> int:
        """Get maximum violations before blacklisting."""
        return self.env_config["max_violations_before_blacklist"]

    def get_rate_limit_message(
        self,
        endpoint: str,
        user_tier: RateLimitTier,
        retry_after: int,
    ) -> str:
        """
        Get user-friendly rate limit message.

        Args:
            endpoint: API endpoint
            user_tier: User tier
            retry_after: Seconds until retry

        Returns:
            User-friendly message
        """
        if "login" in endpoint.lower():
            return f"Too many login attempts. Please try again in {retry_after} seconds."
        elif "register" in endpoint.lower():
            return f"Registration limit reached. Please try again in {retry_after} seconds."
        elif "password" in endpoint.lower():
            return f"Too many password reset requests. Please try again in {retry_after} seconds."
        elif user_tier == RateLimitTier.PUBLIC:
            return f"Rate limit exceeded. Please sign in or try again in {retry_after} seconds."
        elif user_tier in [RateLimitTier.BASIC, RateLimitTier.PREMIUM]:
            return f"Rate limit exceeded. Consider upgrading your plan or try again in {retry_after} seconds."
        else:
            return f"Rate limit exceeded. Please try again in {retry_after} seconds."


# Singleton instance
rate_limit_manager = RateLimitManager()
