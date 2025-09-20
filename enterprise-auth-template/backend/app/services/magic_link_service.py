"""
Magic Link Service

Service layer for managing passwordless authentication via magic links.
Handles creation, validation, and consumption of magic link tokens.
"""

from datetime import datetime, timedelta, timezone
from typing import Optional, Tuple

import structlog
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.core.config import get_settings
from app.core.security import create_access_token, create_refresh_token
from app.models.magic_link import MagicLink
from app.models.user import User
from app.services.audit_service import AuditService, AuditAction
from app.services.email_service import email_service

settings = get_settings()
logger = structlog.get_logger(__name__)


class MagicLinkError(Exception):
    """Magic link service related errors."""

    pass


class MagicLinkService:
    """
    Service for managing magic link authentication.

    Provides methods for creating, sending, and validating magic links
    for passwordless authentication.
    """

    def __init__(self, db: AsyncSession):
        """
        Initialize magic link service.

        Args:
            db: Database session
        """
        self.db = db
        self.audit_service = AuditService(db)
        self.expiry_minutes = 15  # Magic links expire after 15 minutes
        self.max_attempts = 3  # Maximum verification attempts

    async def request_magic_link(
        self,
        email: str,
        request_ip: Optional[str] = None,
        request_user_agent: Optional[str] = None,
    ) -> bool:
        """
        Request a magic link for the given email address.

        Args:
            email: Email address to send magic link to
            request_ip: IP address of the requester
            request_user_agent: User agent of the requester

        Returns:
            bool: True if magic link was sent successfully

        Raises:
            MagicLinkError: If unable to create or send magic link
        """
        try:
            # Check if user exists
            stmt = select(User).where(User.email == email)
            result = await self.db.execute(stmt)
            user = result.scalar_one_or_none()

            if not user:
                # Don't reveal if user exists or not for security
                logger.info("Magic link requested for non-existent user", email=email)
                # Still return True to prevent email enumeration
                return True

            # Check for existing valid magic links
            stmt = select(MagicLink).where(
                MagicLink.user_id == user.id,
                MagicLink.email == email,
                MagicLink.is_used == False,
                MagicLink.expires_at > datetime.now(timezone.utc),
            )
            result = await self.db.execute(stmt)
            existing_link = result.scalar_one_or_none()

            if existing_link:
                # Invalidate existing link
                existing_link.is_used = True
                logger.info("Invalidated existing magic link", user_id=str(user.id))

            # Create new magic link
            magic_link = MagicLink(
                token=MagicLink.generate_token(),
                user_id=user.id,
                email=email,
                expires_at=MagicLink.create_expires_at(self.expiry_minutes),
                request_ip=request_ip,
                request_user_agent=request_user_agent,
                max_attempts=self.max_attempts,
            )

            self.db.add(magic_link)
            await self.db.commit()

            # Send magic link email
            success = await self._send_magic_link_email(
                email=email,
                user_name=user.full_name or user.email,
                token=magic_link.token,
            )

            if not success:
                logger.error("Failed to send magic link email", email=email)
                raise MagicLinkError("Failed to send magic link email")

            # Log audit event
            # TODO: Fix audit_logs table schema mismatch
            # await self.audit_service.log_action(
            #     action=AuditAction.MAGIC_LINK_REQUESTED,
            #     user_id=user.id,
            #     details={
            #         "email": email,
            #         "expires_at": magic_link.expires_at.isoformat(),
            #     },
            #     ip_address=request_ip,
            #     user_agent=request_user_agent,
            # )

            logger.info(
                "Magic link created and sent", user_id=str(user.id), email=email
            )
            return True

        except Exception as e:
            logger.error("Failed to create magic link", email=email, error=str(e))
            await self.db.rollback()
            raise MagicLinkError(f"Failed to create magic link: {str(e)}")

    async def verify_magic_link(
        self,
        token: str,
        ip_address: Optional[str] = None,
        user_agent: Optional[str] = None,
    ) -> Tuple[Optional[str], Optional[str], Optional[User]]:
        """
        Verify and consume a magic link token.

        Args:
            token: Magic link token to verify
            ip_address: IP address of the verifier
            user_agent: User agent of the verifier

        Returns:
            Tuple of (access_token, refresh_token, user) if successful,
            (None, None, None) if verification fails
        """
        try:
            # Find magic link by token
            stmt = (
                select(MagicLink)
                .where(MagicLink.token == token)
                .options(selectinload(MagicLink.user))
            )
            result = await self.db.execute(stmt)
            magic_link = result.scalar_one_or_none()

            if not magic_link:
                logger.warning("Invalid magic link token", token=token)
                return None, None, None

            # Increment attempt count
            magic_link.increment_attempts()

            # Check if link is valid
            if not magic_link.is_valid:
                if magic_link.is_expired:
                    reason = "expired"
                elif magic_link.is_used:
                    reason = "already_used"
                else:
                    reason = "max_attempts_exceeded"

                logger.warning(
                    "Invalid magic link",
                    token=token,
                    reason=reason,
                    attempts=magic_link.attempt_count,
                )

                # Log audit event for failed attempt
                # TODO: Fix audit_logs table schema mismatch
                # await self.audit_service.log_action(
                #     action=AuditAction.MAGIC_LINK_FAILED,
                #     user_id=magic_link.user_id,
                #     details={"reason": reason, "attempts": magic_link.attempt_count},
                #     ip_address=ip_address,
                #     user_agent=user_agent,
                # )

                await self.db.commit()
                return None, None, None

            # Get user
            user = magic_link.user
            if not user:
                logger.error("Magic link has no associated user", token=token)
                return None, None, None

            # Check if user is active
            if not user.is_active:
                logger.warning("Magic link for inactive user", user_id=str(user.id))
                return None, None, None

            # Mark magic link as used
            magic_link.mark_as_used(ip_address, user_agent)

            # Update user's last login
            user.last_login = datetime.now(timezone.utc)

            # If user's email wasn't verified, verify it now
            if not user.email_verified:
                user.email_verified = True
                user.email_verified_at = datetime.now(timezone.utc)

            # Create tokens
            access_token = create_access_token(
                user_id=str(user.id),
                email=user.email,
                roles=[role.name for role in user.roles] if user.roles else [],
                permissions=user.get_permissions(),
            )
            refresh_token_jwt, refresh_token_id = create_refresh_token(str(user.id))

            # TODO: Store refresh token in database when schema is fixed
            # from app.models.auth import RefreshToken
            # refresh_token_db = RefreshToken(
            #     token_id=refresh_token_id,
            #     user_id=user.id,
            #     expires_at=datetime.utcnow() + timedelta(days=settings.REFRESH_TOKEN_EXPIRE_DAYS),
            #     ip_address=ip_address,
            #     user_agent=user_agent,
            #     device_info="Magic Link Login"
            # )
            # self.db.add(refresh_token_db)

            # Log audit event
            # TODO: Fix audit_logs table schema mismatch
            # await self.audit_service.log_action(
            #     action=AuditAction.MAGIC_LINK_USED,
            #     user_id=user.id,
            #     details={"email": user.email, "token_id": str(magic_link.id)},
            #     ip_address=ip_address,
            #     user_agent=user_agent,
            # )

            await self.db.commit()

            logger.info("Magic link verified successfully", user_id=str(user.id))
            return access_token, refresh_token_jwt, user

        except Exception as e:
            logger.error("Failed to verify magic link", token=token, error=str(e))
            await self.db.rollback()
            return None, None, None

    async def cleanup_expired_links(self) -> int:
        """
        Clean up expired magic links from the database.

        Returns:
            Number of links deleted
        """
        try:
            # Find expired links older than 24 hours
            cutoff_time = datetime.now(timezone.utc) - timedelta(hours=24)
            stmt = select(MagicLink).where(MagicLink.expires_at < cutoff_time)
            result = await self.db.execute(stmt)
            expired_links = result.scalars().all()

            count = len(expired_links)
            for link in expired_links:
                await self.db.delete(link)

            await self.db.commit()

            if count > 0:
                logger.info(f"Cleaned up {count} expired magic links")

            return count

        except Exception as e:
            logger.error("Failed to cleanup expired magic links", error=str(e))
            await self.db.rollback()
            return 0

    async def _send_magic_link_email(
        self, email: str, user_name: str, token: str
    ) -> bool:
        """
        Send magic link email to user.

        Args:
            email: Recipient email address
            user_name: User's name
            token: Magic link token

        Returns:
            bool: True if email sent successfully
        """
        try:
            return await email_service.send_magic_link_email(
                to_email=email, user_name=user_name, magic_link_token=token
            )
        except Exception as e:
            logger.error("Failed to send magic link email", email=email, error=str(e))
            return False
