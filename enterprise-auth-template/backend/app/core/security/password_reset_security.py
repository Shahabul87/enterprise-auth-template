"""
Password Reset Security Manager

Handles secure password reset operations with rate limiting,
token generation, and validation.
"""

from datetime import datetime, timedelta
from typing import Optional, Dict, Any
import hashlib
import secrets
from uuid import UUID

from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, delete
import structlog

from app.services.cache_service import CacheService

logger = structlog.get_logger(__name__)


class PasswordResetSecurityManager:
    """
    Manages password reset security including rate limiting,
    secure token generation, and validation.
    """

    def __init__(
        self,
        db_session: AsyncSession,
        cache_service: Optional[CacheService] = None,
        max_attempts: int = 3,
        cooldown_minutes: int = 30,
        token_expiry_minutes: int = 60,
    ):
        """
        Initialize PasswordResetSecurityManager.

        Args:
            db_session: Database session for persistence
            cache_service: Optional cache service for rate limiting
            max_attempts: Maximum reset attempts within cooldown period
            cooldown_minutes: Cooldown period in minutes
            token_expiry_minutes: Token expiry time in minutes
        """
        self.db = db_session
        self.cache = cache_service
        self.max_attempts = max_attempts
        self.cooldown_minutes = cooldown_minutes
        self.token_expiry_minutes = token_expiry_minutes

    async def can_request_reset(self, email: str) -> tuple[bool, Optional[str]]:
        """
        Check if a user can request a password reset.

        Args:
            email: User email address

        Returns:
            Tuple of (can_request, error_message)
        """
        if not self.cache:
            # If no cache, always allow (but log warning)
            logger.warning(
                "Password reset rate limiting disabled - no cache service", email=email
            )
            return True, None

        # Check rate limiting
        rate_limit_key = f"password_reset:attempts:{email}"
        attempts = await self.cache.get(rate_limit_key) or 0

        if attempts >= self.max_attempts:
            remaining_time = await self._get_remaining_cooldown(email)
            return (
                False,
                f"Too many reset attempts. Please try again in {remaining_time} minutes.",
            )

        return True, None

    async def generate_reset_token(self, user_id: UUID, email: str) -> str:
        """
        Generate a secure password reset token.

        Args:
            user_id: User ID
            email: User email

        Returns:
            Reset token
        """
        # Generate secure token
        token = secrets.token_urlsafe(32)
        token_hash = hashlib.sha256(token.encode()).hexdigest()

        # Store token with expiry
        if self.cache:
            token_data = {
                "user_id": str(user_id),
                "email": email,
                "created_at": datetime.utcnow().isoformat(),
                "expires_at": (
                    datetime.utcnow() + timedelta(minutes=self.token_expiry_minutes)
                ).isoformat(),
            }

            await self.cache.set(
                f"password_reset:token:{token_hash}",
                token_data,
                ttl=self.token_expiry_minutes * 60,
            )

            # Update rate limiting
            rate_limit_key = f"password_reset:attempts:{email}"
            attempts = await self.cache.get(rate_limit_key) or 0
            await self.cache.set(
                rate_limit_key, attempts + 1, ttl=self.cooldown_minutes * 60
            )

        logger.info(
            "Password reset token generated",
            user_id=str(user_id),
            email=email,
            token_hash=token_hash[:8],
        )

        return token

    async def validate_reset_token(
        self, token: str
    ) -> tuple[bool, Optional[UUID], Optional[str]]:
        """
        Validate a password reset token.

        Args:
            token: Reset token to validate

        Returns:
            Tuple of (is_valid, user_id, email)
        """
        if not self.cache:
            logger.error("Cannot validate token without cache service")
            return False, None, None

        token_hash = hashlib.sha256(token.encode()).hexdigest()
        token_key = f"password_reset:token:{token_hash}"

        token_data = await self.cache.get(token_key)

        if not token_data:
            logger.warning("Invalid or expired reset token", token_hash=token_hash[:8])
            return False, None, None

        # Check expiry
        expires_at = datetime.fromisoformat(token_data["expires_at"])
        if expires_at < datetime.utcnow():
            logger.warning(
                "Expired reset token",
                token_hash=token_hash[:8],
                expired_at=expires_at.isoformat(),
            )
            await self.cache.delete(token_key)
            return False, None, None

        user_id = UUID(token_data["user_id"])
        email = token_data["email"]

        logger.info(
            "Reset token validated", token_hash=token_hash[:8], user_id=str(user_id)
        )

        return True, user_id, email

    async def consume_reset_token(self, token: str) -> bool:
        """
        Consume a password reset token (use once).

        Args:
            token: Reset token to consume

        Returns:
            True if token was consumed
        """
        if not self.cache:
            return False

        token_hash = hashlib.sha256(token.encode()).hexdigest()
        token_key = f"password_reset:token:{token_hash}"

        # Delete token after use
        deleted = await self.cache.delete(token_key)

        if deleted:
            logger.info("Reset token consumed", token_hash=token_hash[:8])

        return deleted

    async def clear_user_reset_attempts(self, email: str):
        """
        Clear reset attempts for a user after successful reset.

        Args:
            email: User email
        """
        if not self.cache:
            return

        rate_limit_key = f"password_reset:attempts:{email}"
        await self.cache.delete(rate_limit_key)

        logger.info("Reset attempts cleared", email=email)

    async def _get_remaining_cooldown(self, email: str) -> int:
        """
        Get remaining cooldown time in minutes.

        Args:
            email: User email

        Returns:
            Remaining minutes
        """
        if not self.cache:
            return 0

        rate_limit_key = f"password_reset:attempts:{email}"
        ttl = await self.cache.ttl(rate_limit_key)

        if ttl and ttl > 0:
            return (ttl // 60) + 1  # Round up to next minute

        return 0

    async def get_reset_statistics(self, email: str) -> Dict[str, Any]:
        """
        Get password reset statistics for a user.

        Args:
            email: User email

        Returns:
            Statistics dictionary
        """
        if not self.cache:
            return {"attempts": 0, "remaining_cooldown": 0, "can_request": True}

        rate_limit_key = f"password_reset:attempts:{email}"
        attempts = await self.cache.get(rate_limit_key) or 0
        remaining_cooldown = await self._get_remaining_cooldown(email)

        return {
            "attempts": attempts,
            "max_attempts": self.max_attempts,
            "remaining_cooldown": remaining_cooldown,
            "can_request": attempts < self.max_attempts,
        }
