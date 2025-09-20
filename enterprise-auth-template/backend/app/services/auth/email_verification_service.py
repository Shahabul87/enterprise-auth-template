"""
Email Verification Service

Handles email verification operations following the Single Responsibility Principle.
This service focuses exclusively on email verification workflows.
"""

from datetime import datetime, timedelta
from typing import Optional

import structlog
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, update

from app.core.security import generate_verification_token
from app.models.auth import EmailVerificationToken
from app.repositories.user_repository import UserRepository


logger = structlog.get_logger(__name__)


class EmailVerificationError(Exception):
    """Email verification related errors."""

    pass


class EmailVerificationService:
    """
    Service dedicated to email verification operations.

    Responsibilities:
    - Email verification token generation
    - Email verification token validation
    - Email verification processing
    - Verification email resending
    """

    def __init__(
        self,
        session: AsyncSession,
        user_repository: Optional[UserRepository] = None,
    ) -> None:
        """
        Initialize email verification service.

        Args:
            session: Database session
            user_repository: User repository for data access
        """
        self.session = session
        self.user_repo = user_repository or UserRepository(session)

    async def verify_email(
        self,
        verification_token: str,
        ip_address: Optional[str] = None,
        user_agent: Optional[str] = None,
    ) -> bool:
        """
        Verify user email address.

        Args:
            verification_token: Email verification token
            ip_address: Client IP address
            user_agent: Client user agent

        Returns:
            bool: True if verification successful

        Raises:
            EmailVerificationError: If verification fails
        """
        try:
            # Find and validate verification token
            token = await self._find_valid_verification_token(verification_token)
            if not token:
                raise EmailVerificationError("Invalid or expired verification token")

            # Get user
            user = await self.user_repo.find_by_id(token.user_id)
            if not user:
                raise EmailVerificationError("User not found")

            # Check if already verified
            if user.email_verified:
                logger.info(
                    "Email already verified",
                    user_id=str(user.id),
                    email=user.email,
                )
                return True

            # Mark email as verified
            await self.user_repo.verify_email(user.id)

            # Mark token as used
            await self._mark_token_used(token.id)

            # Send welcome email
            await self._send_welcome_email(user.email, user.full_name)

            await self.session.commit()

            logger.info(
                "Email verified successfully",
                user_id=str(user.id),
                email=user.email,
                ip_address=ip_address,
            )

            return True

        except EmailVerificationError:
            await self.session.rollback()
            raise
        except Exception as e:
            await self.session.rollback()
            logger.error(
                "Email verification failed",
                error=str(e),
                token=verification_token[:8] + "...",
                ip_address=ip_address,
            )
            raise EmailVerificationError(f"Email verification failed: {str(e)}")

    async def resend_verification_email(
        self,
        email: str,
        ip_address: Optional[str] = None,
    ) -> bool:
        """
        Resend email verification link.

        Args:
            email: User email address
            ip_address: Client IP address

        Returns:
            bool: True if verification email sent (always returns True for security)
        """
        try:
            # Check rate limiting
            await self._check_resend_rate_limit(email, ip_address)

            # Find user by email
            user = await self.user_repo.find_by_email(email)

            if user and not user.email_verified:
                # Generate new verification token
                verification_token = generate_verification_token()

                # Update or create verification token
                existing_token = await self._find_user_verification_token(user.id)

                if existing_token:
                    # Update existing token
                    await self._update_verification_token(
                        existing_token.id, verification_token
                    )
                else:
                    # Create new token
                    await self._create_verification_token(user.id, verification_token)

                # Send verification email
                await self._send_verification_email(
                    user.email, user.full_name, verification_token
                )

                await self.session.commit()

                logger.info(
                    "Verification email resent",
                    user_id=str(user.id),
                    email=email,
                    ip_address=ip_address,
                )
            else:
                # User doesn't exist or already verified
                logger.info(
                    "Verification email not needed",
                    email=email,
                    exists=user is not None,
                    verified=user.email_verified if user else None,
                )

            return True

        except Exception as e:
            await self.session.rollback()
            logger.error(
                "Verification email resend failed",
                email=email,
                error=str(e),
                ip_address=ip_address,
            )
            # Still return True for security reasons
            return True

    async def create_verification_token(
        self,
        user_id: str,
        email: Optional[str] = None,
    ) -> str:
        """
        Create a new verification token for a user.

        Args:
            user_id: User ID
            email: User email (optional)

        Returns:
            str: Verification token
        """
        verification_token = generate_verification_token()

        email_verification = EmailVerificationToken(
            user_id=user_id,
            token=verification_token,
            email=email,
            expires_at=datetime.utcnow() + timedelta(hours=24),
        )
        self.session.add(email_verification)

        logger.debug(
            "Verification token created",
            user_id=user_id,
            token=verification_token[:8] + "...",
        )

        return verification_token

    async def validate_token(self, verification_token: str) -> bool:
        """
        Validate a verification token without using it.

        Args:
            verification_token: Token to validate

        Returns:
            bool: True if token is valid
        """
        try:
            token = await self._find_valid_verification_token(verification_token)
            return token is not None
        except Exception as e:
            logger.error(
                "Token validation error",
                error=str(e),
                token=verification_token[:8] + "...",
            )
            return False

    async def cleanup_expired_tokens(self) -> int:
        """
        Clean up expired verification tokens.

        Returns:
            int: Number of tokens cleaned up
        """
        try:
            from sqlalchemy import delete

            stmt = delete(EmailVerificationToken).where(
                EmailVerificationToken.expires_at < datetime.utcnow()
            )
            result = await self.session.execute(stmt)
            count = result.rowcount

            await self.session.commit()

            logger.info(
                "Expired verification tokens cleaned up",
                count=count,
            )

            return count

        except Exception as e:
            await self.session.rollback()
            logger.error(
                "Failed to cleanup expired tokens",
                error=str(e),
            )
            return 0

    async def _find_valid_verification_token(
        self, verification_token: str
    ) -> Optional[EmailVerificationToken]:
        """
        Find and validate a verification token.

        Args:
            verification_token: Token to find

        Returns:
            EmailVerificationToken if valid, None otherwise
        """
        stmt = (
            select(EmailVerificationToken)
            .where(EmailVerificationToken.token == verification_token)
            .where(EmailVerificationToken.is_used == False)
            .where(EmailVerificationToken.expires_at > datetime.utcnow())
        )
        result = await self.session.execute(stmt)
        return result.scalar_one_or_none()

    async def _find_user_verification_token(
        self, user_id: str
    ) -> Optional[EmailVerificationToken]:
        """
        Find active verification token for a user.

        Args:
            user_id: User ID

        Returns:
            EmailVerificationToken if exists, None otherwise
        """
        stmt = (
            select(EmailVerificationToken)
            .where(EmailVerificationToken.user_id == user_id)
            .where(EmailVerificationToken.is_used == False)
            .order_by(EmailVerificationToken.created_at.desc())
        )
        result = await self.session.execute(stmt)
        return result.scalar_one_or_none()

    async def _create_verification_token(
        self,
        user_id: str,
        token: str,
    ) -> EmailVerificationToken:
        """
        Create a new verification token.

        Args:
            user_id: User ID
            token: Verification token

        Returns:
            Created EmailVerificationToken
        """
        email_verification = EmailVerificationToken(
            user_id=user_id,
            token=token,
            expires_at=datetime.utcnow() + timedelta(hours=24),
        )
        self.session.add(email_verification)
        return email_verification

    async def _update_verification_token(
        self,
        token_id: str,
        new_token: str,
    ) -> None:
        """
        Update an existing verification token.

        Args:
            token_id: Token ID to update
            new_token: New token value
        """
        stmt = (
            update(EmailVerificationToken)
            .where(EmailVerificationToken.id == token_id)
            .values(
                token=new_token,
                expires_at=datetime.utcnow() + timedelta(hours=24),
                created_at=datetime.utcnow(),
            )
        )
        await self.session.execute(stmt)

    async def _mark_token_used(self, token_id: str) -> None:
        """
        Mark a verification token as used.

        Args:
            token_id: Token ID to mark as used
        """
        stmt = (
            update(EmailVerificationToken)
            .where(EmailVerificationToken.id == token_id)
            .values(is_used=True, used_at=datetime.utcnow())
        )
        await self.session.execute(stmt)

    async def _check_resend_rate_limit(
        self,
        email: str,
        ip_address: Optional[str],
    ) -> None:
        """
        Check rate limiting for verification email resends.

        Args:
            email: User email
            ip_address: Client IP address

        Raises:
            EmailVerificationError: If rate limit exceeded
        """
        # Allow max 3 resends per hour
        one_hour_ago = datetime.utcnow() - timedelta(hours=1)

        # Check recent resend attempts
        user = await self.user_repo.find_by_email(email)
        if user:
            stmt = (
                select(EmailVerificationToken)
                .where(EmailVerificationToken.user_id == user.id)
                .where(EmailVerificationToken.created_at > one_hour_ago)
            )
            result = await self.session.execute(stmt)
            recent_requests = len(result.scalars().all())

            if recent_requests >= 3:
                logger.warning(
                    "Verification email rate limit exceeded",
                    email=email,
                    ip_address=ip_address,
                    recent_requests=recent_requests,
                )
                raise EmailVerificationError(
                    "Too many verification email requests. Please try again later."
                )

    async def _send_verification_email(
        self,
        email: str,
        user_name: str,
        token: str,
    ) -> None:
        """
        Send verification email to user.

        Args:
            email: User email
            user_name: User's full name
            token: Verification token
        """
        try:
            # Try enhanced email service first
            try:
                from app.services.enhanced_email_service import enhanced_email_service

                await enhanced_email_service.send_verification_email(
                    to_email=email,
                    user_name=user_name,
                    verification_token=token,
                )
            except ImportError:
                # Fallback to basic email service
                from app.services.email_service import email_service

                await email_service.send_verification_email(
                    to_email=email,
                    user_name=user_name,
                    verification_token=token,
                )

            logger.info(
                "Verification email sent",
                email=email,
            )
        except Exception as e:
            logger.error(
                "Failed to send verification email",
                email=email,
                error=str(e),
            )

    async def _send_welcome_email(
        self,
        email: str,
        user_name: str,
    ) -> None:
        """
        Send welcome email after successful verification.

        Args:
            email: User email
            user_name: User's full name
        """
        try:
            from app.services.email_service import email_service

            # Send welcome email if method exists
            if hasattr(email_service, "send_welcome_email"):
                await email_service.send_welcome_email(
                    to_email=email,
                    user_name=user_name,
                )
                logger.info("Welcome email sent", email=email)
        except Exception as e:
            logger.error(
                "Failed to send welcome email",
                email=email,
                error=str(e),
            )
