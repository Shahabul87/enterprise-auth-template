"""
Password Management Service

Handles all password-related operations following the Single Responsibility Principle.
This service focuses exclusively on password reset, change, and recovery operations.
"""

from datetime import datetime, timedelta
from typing import Optional
import secrets

import structlog
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, update

from app.core.security import generate_reset_token, get_password_hash
from app.domain.user_domain import UserDomain
from app.models.auth import PasswordResetToken
from app.models.user import User
from app.repositories.user_repository import UserRepository


logger = structlog.get_logger(__name__)


class PasswordManagementError(Exception):
    """Password management related errors."""
    pass


class PasswordManagementService:
    """
    Service dedicated to password management operations.

    Responsibilities:
    - Password reset request handling
    - Password reset token validation
    - Password change operations
    - Password recovery workflows
    """

    def __init__(
        self,
        session: AsyncSession,
        user_repository: Optional[UserRepository] = None,
    ) -> None:
        """
        Initialize password management service.

        Args:
            session: Database session
            user_repository: User repository for data access
        """
        self.session = session
        self.user_repo = user_repository or UserRepository(session)

    async def request_password_reset(
        self,
        email: str,
        ip_address: Optional[str] = None,
        user_agent: Optional[str] = None,
    ) -> bool:
        """
        Request password reset for user.

        Args:
            email: User email address
            ip_address: Client IP address
            user_agent: Client user agent

        Returns:
            bool: True if reset email sent (always returns True for security)
        """
        try:
            # Apply rate limiting for security
            await self._check_reset_rate_limit(email, ip_address)

            # Find user by email
            user = await self.user_repo.find_by_email(email)

            if user and user.is_active:
                # Convert to domain model to use business logic
                user_domain = UserDomain.from_entity(user)

                if not user_domain.can_reset_password():
                    logger.warning(
                        "Password reset blocked by business rules",
                        email=email,
                        user_id=str(user.id),
                        is_locked=user_domain.is_locked,
                    )
                    return True  # Don't reveal user state

                # Generate secure reset token
                reset_token = self._generate_secure_token()

                # Store reset token
                await self._create_reset_token(user.id, reset_token, ip_address)

                # Send reset email
                await self._send_reset_email(
                    user.email,
                    user.full_name,
                    reset_token
                )

                await self.session.commit()

                logger.info(
                    "Password reset requested",
                    user_id=str(user.id),
                    email=email,
                    ip_address=ip_address,
                )
            else:
                # User doesn't exist, but don't reveal this
                logger.warning(
                    "Password reset requested for non-existent user",
                    email=email,
                    ip_address=ip_address,
                )

            return True

        except Exception as e:
            await self.session.rollback()
            logger.error(
                "Password reset request failed",
                email=email,
                error=str(e),
                ip_address=ip_address,
            )
            # Still return True for security reasons
            return True

    async def reset_password(
        self,
        reset_token: str,
        new_password: str,
        ip_address: Optional[str] = None,
        user_agent: Optional[str] = None,
    ) -> bool:
        """
        Reset user password using reset token.

        Args:
            reset_token: Password reset token
            new_password: New password
            ip_address: Client IP address
            user_agent: Client user agent

        Returns:
            bool: True if password reset successful

        Raises:
            PasswordManagementError: If reset fails
            ValueError: If password validation fails
        """
        try:
            # Find and validate reset token
            reset_record = await self._find_valid_reset_token(reset_token)
            if not reset_record:
                raise PasswordManagementError("Invalid or expired reset token")

            # Get user
            user = await self.user_repo.find_by_id(reset_record.user_id)
            if not user:
                raise PasswordManagementError("User not found")

            # Use domain model for password validation
            user_domain = UserDomain.from_entity(user)
            user_domain.set_password(new_password)  # This validates the password

            # Update password in database
            await self.user_repo.update_password(
                user.id,
                user_domain.hashed_password
            )

            # Mark token as used
            await self._mark_token_used(reset_record.id)

            # Invalidate all sessions (force re-login)
            await self._invalidate_user_sessions(user.id)

            # Send confirmation email
            await self._send_password_changed_email(
                user.email,
                user.full_name
            )

            await self.session.commit()

            logger.info(
                "Password reset successful",
                user_id=str(user.id),
                email=user.email,
                ip_address=ip_address,
            )

            return True

        except (ValueError, PasswordManagementError):
            await self.session.rollback()
            raise
        except Exception as e:
            await self.session.rollback()
            logger.error(
                "Password reset failed",
                error=str(e),
                reset_token=reset_token[:8] + "...",
                ip_address=ip_address,
            )
            raise PasswordManagementError("Password reset failed")

    async def change_password(
        self,
        user_id: str,
        current_password: str,
        new_password: str,
        ip_address: Optional[str] = None,
    ) -> bool:
        """
        Change user password with current password verification.

        Args:
            user_id: User ID
            current_password: Current password for verification
            new_password: New password to set
            ip_address: Client IP address

        Returns:
            bool: True if password changed successfully

        Raises:
            PasswordManagementError: If change fails
            ValueError: If validation fails
        """
        try:
            # Get user
            user = await self.user_repo.find_by_id(user_id)
            if not user:
                raise PasswordManagementError("User not found")

            # Use domain model for password change
            user_domain = UserDomain.from_entity(user)
            success = user_domain.change_password(current_password, new_password)

            if not success:
                raise PasswordManagementError("Password change failed")

            # Update password in database
            await self.user_repo.update_password(
                user.id,
                user_domain.hashed_password
            )

            # Send confirmation email
            await self._send_password_changed_email(
                user.email,
                user.full_name
            )

            await self.session.commit()

            logger.info(
                "Password changed successfully",
                user_id=user_id,
                ip_address=ip_address,
            )

            return True

        except (ValueError, PasswordManagementError):
            await self.session.rollback()
            raise
        except Exception as e:
            await self.session.rollback()
            logger.error(
                "Password change failed",
                user_id=user_id,
                error=str(e),
                ip_address=ip_address,
            )
            raise PasswordManagementError("Password change failed")

    async def validate_reset_token(self, reset_token: str) -> bool:
        """
        Validate a password reset token.

        Args:
            reset_token: Token to validate

        Returns:
            bool: True if token is valid
        """
        try:
            reset_record = await self._find_valid_reset_token(reset_token)
            return reset_record is not None
        except Exception as e:
            logger.error(
                "Token validation error",
                error=str(e),
                token=reset_token[:8] + "...",
            )
            return False

    async def _check_reset_rate_limit(
        self,
        email: str,
        ip_address: Optional[str],
    ) -> None:
        """
        Check rate limiting for password reset requests.

        Args:
            email: User email
            ip_address: Client IP address

        Raises:
            PasswordManagementError: If rate limit exceeded
        """
        # Check recent reset requests (max 3 per hour)
        one_hour_ago = datetime.utcnow() - timedelta(hours=1)

        stmt = select(PasswordResetToken).where(
            PasswordResetToken.created_at > one_hour_ago
        )

        if ip_address:
            stmt = stmt.where(PasswordResetToken.ip_address == ip_address)

        result = await self.session.execute(stmt)
        recent_requests = len(result.scalars().all())

        if recent_requests >= 3:
            logger.warning(
                "Password reset rate limit exceeded",
                email=email,
                ip_address=ip_address,
                recent_requests=recent_requests,
            )
            raise PasswordManagementError("Too many reset requests. Please try again later.")

    async def _find_valid_reset_token(
        self,
        reset_token: str
    ) -> Optional[PasswordResetToken]:
        """
        Find and validate a reset token.

        Args:
            reset_token: Token to find

        Returns:
            PasswordResetToken if valid, None otherwise
        """
        stmt = (
            select(PasswordResetToken)
            .where(PasswordResetToken.token == reset_token)
            .where(PasswordResetToken.is_used == False)
            .where(PasswordResetToken.expires_at > datetime.utcnow())
        )
        result = await self.session.execute(stmt)
        return result.scalar_one_or_none()

    async def _create_reset_token(
        self,
        user_id: str,
        token: str,
        ip_address: Optional[str],
    ) -> PasswordResetToken:
        """
        Create a password reset token.

        Args:
            user_id: User ID
            token: Reset token
            ip_address: Client IP address

        Returns:
            Created PasswordResetToken
        """
        reset_token = PasswordResetToken(
            user_id=user_id,
            token=token,
            expires_at=datetime.utcnow() + timedelta(hours=1),
            ip_address=ip_address,
        )
        self.session.add(reset_token)
        return reset_token

    async def _mark_token_used(self, token_id: str) -> None:
        """
        Mark a reset token as used.

        Args:
            token_id: Token ID to mark as used
        """
        stmt = (
            update(PasswordResetToken)
            .where(PasswordResetToken.id == token_id)
            .values(
                is_used=True,
                used_at=datetime.utcnow()
            )
        )
        await self.session.execute(stmt)

    async def _invalidate_user_sessions(self, user_id: str) -> None:
        """
        Invalidate all user sessions after password change.

        Args:
            user_id: User ID
        """
        # This would be better handled by SessionRepository
        from app.models.auth import RefreshToken
        from app.models.session import UserSession

        # Revoke refresh tokens
        stmt = (
            update(RefreshToken)
            .where(RefreshToken.user_id == user_id)
            .where(RefreshToken.is_revoked == False)
            .values(
                is_revoked=True,
                revoked_at=datetime.utcnow()
            )
        )
        await self.session.execute(stmt)

        # End active sessions
        stmt = (
            update(UserSession)
            .where(UserSession.user_id == user_id)
            .where(UserSession.is_active == True)
            .values(
                is_active=False,
                ended_at=datetime.utcnow()
            )
        )
        await self.session.execute(stmt)

    def _generate_secure_token(self) -> str:
        """
        Generate a cryptographically secure reset token.

        Returns:
            Secure token string
        """
        return secrets.token_urlsafe(32)

    async def _send_reset_email(
        self,
        email: str,
        user_name: str,
        reset_token: str,
    ) -> None:
        """
        Send password reset email.

        Args:
            email: User email
            user_name: User's full name
            reset_token: Reset token
        """
        try:
            from app.services.email_service import email_service
            await email_service.send_password_reset_email(
                to_email=email,
                user_name=user_name,
                reset_token=reset_token,
            )
            logger.info("Password reset email sent", email=email)
        except Exception as e:
            logger.error(
                "Failed to send reset email",
                email=email,
                error=str(e),
            )

    async def _send_password_changed_email(
        self,
        email: str,
        user_name: str,
    ) -> None:
        """
        Send password changed confirmation email.

        Args:
            email: User email
            user_name: User's full name
        """
        try:
            from app.services.email_service import email_service
            await email_service.send_password_changed_email(
                to_email=email,
                user_name=user_name,
            )
            logger.info("Password changed email sent", email=email)
        except Exception as e:
            logger.error(
                "Failed to send password changed email",
                email=email,
                error=str(e),
            )