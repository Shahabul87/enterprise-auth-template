"""
User Authentication Service

Handles all authentication-related operations including login, logout,
token management, password reset, and email verification.
"""

from datetime import datetime, timedelta
from typing import Dict, Optional

import structlog
from sqlalchemy import select, update
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import get_settings
from app.core.security import (
    create_access_token,
    create_refresh_token,
    generate_reset_token,
    get_password_hash,
    is_password_strong,
    verify_password,
    verify_token,
)
from app.models.auth import (
    EmailVerificationToken,
    PasswordResetToken,
    RefreshToken,
)
from app.models.session import UserSession
from app.models.user import User
from app.schemas.auth import LoginResponse, UserResponse
from app.services.cache_service import CacheService

settings = get_settings()
logger = structlog.get_logger(__name__)


class AuthenticationError(Exception):
    """Authentication-related errors."""

    pass


class AuthorizationError(Exception):
    """Authorization-related errors."""

    pass


class AccountLockedError(AuthenticationError):
    """Account is locked due to too many failed attempts."""

    pass


class EmailNotVerifiedError(AuthenticationError):
    """Email address is not verified."""

    pass


class UserAuthService:
    """
    Service for user authentication operations.

    Handles login, logout, token management, password operations,
    and email verification with caching and security measures.
    """

    def __init__(
        self, session: AsyncSession, cache_service: Optional[CacheService] = None
    ) -> None:
        """
        Initialize user auth service.

        Args:
            session: Database session
            cache_service: Cache service for performance optimization
        """
        self.session = session
        self.cache_service = cache_service or CacheService()

    async def authenticate_user(
        self,
        email: str,
        password: str,
        ip_address: Optional[str] = None,
        user_agent: Optional[str] = None,
    ) -> LoginResponse:
        """
        Authenticate user with email and password.

        Args:
            email: User email
            password: User password
            ip_address: Client IP address
            user_agent: Client user agent

        Returns:
            LoginResponse: Authentication tokens and user info

        Raises:
            AuthenticationError: If authentication fails
            AccountLockedError: If account is locked
            EmailNotVerifiedError: If email is not verified
        """
        try:
            # Get user with roles and permissions in one optimized query
            user = await User.get_by_email_with_roles(self.session, email)

            if not user or not user.hashed_password:
                await self._handle_failed_login(
                    email, "Invalid credentials", ip_address, user_agent
                )
                raise AuthenticationError("Invalid email or password")

            # Check if account is locked
            if user.is_locked:
                logger.warning(
                    "Login attempt on locked account",
                    user_id=str(user.id),
                    email=email,
                    locked_until=(
                        user.locked_until.isoformat() if user.locked_until else None
                    ),
                    ip_address=ip_address,
                )
                raise AccountLockedError(f"Account is locked until {user.locked_until}")

            # Verify password
            if not verify_password(password, user.hashed_password):
                await self._handle_failed_login(
                    email, "Invalid password", ip_address, user_agent, user
                )
                raise AuthenticationError("Invalid email or password")

            # Check if account is active
            if not user.is_active:
                await self._handle_failed_login(
                    email, "Account not active", ip_address, user_agent, user
                )
                raise AuthenticationError("Account is not active")

            # Reset failed login attempts on successful login
            if user.failed_login_attempts > 0:
                await self.session.execute(
                    update(User)
                    .where(User.id == user.id)
                    .values(failed_login_attempts=0, locked_until=None)
                )

            # Update last login
            await self.session.execute(
                update(User)
                .where(User.id == user.id)
                .values(last_login=datetime.utcnow())
            )

            # Get user permissions from cache first
            permissions = await self.cache_service.get_user_permissions(str(user.id))
            if permissions is None:
                # Cache miss - compute permissions and cache them
                permissions = user.get_permissions()
                await self.cache_service.cache_user_permissions(
                    str(user.id), permissions
                )
                logger.debug(
                    "User permissions computed and cached",
                    user_id=str(user.id),
                    permission_count=len(permissions),
                )
            else:
                logger.debug(
                    "User permissions loaded from cache",
                    user_id=str(user.id),
                    permission_count=len(permissions),
                )

            role_names = [role.name for role in user.roles]

            # Create tokens
            access_token = create_access_token(
                user_id=str(user.id),
                email=user.email,
                roles=role_names,
                permissions=permissions,
            )

            refresh_token_jwt, refresh_token_id = create_refresh_token(str(user.id))

            await self.session.commit()

            logger.info(
                "User authenticated successfully",
                user_id=str(user.id),
                email=user.email,
                roles=role_names,
                ip_address=ip_address,
            )

            return LoginResponse(
                access_token=access_token,
                refresh_token=refresh_token_jwt,
                token_type="bearer",
                expires_in=settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60,
                requires_2fa=False,
                temp_token=None,
                user=UserResponse(
                    id=str(user.id),
                    email=user.email,
                    full_name=user.full_name,
                    name=user.full_name,
                    email_verified=user.is_verified,
                    roles=role_names,
                    created_at=user.created_at.isoformat(),
                    updated_at=(
                        user.updated_at.isoformat() if user.updated_at else None
                    ),
                    last_login=(
                        user.last_login.isoformat() if user.last_login else None
                    ),
                ),
            )

        except (
            AuthenticationError,
            AccountLockedError,
            EmailNotVerifiedError,
        ):
            await self.session.rollback()
            raise
        except Exception as e:
            await self.session.rollback()
            logger.error(
                "Authentication error",
                email=email,
                error=str(e),
                ip_address=ip_address,
            )
            raise AuthenticationError(f"Authentication failed: {str(e)}")

    async def _handle_failed_login(
        self,
        email: str,
        reason: str,
        ip_address: Optional[str] = None,
        user_agent: Optional[str] = None,
        user: Optional[User] = None,
    ) -> None:
        """
        Handle failed login attempts with account lockout.

        Args:
            email: User email
            reason: Failure reason
            ip_address: Client IP address
            user_agent: Client user agent
            user: User object if available
        """
        max_attempts = 5
        lockout_duration = timedelta(minutes=30)

        if user:
            # Increment failed attempts
            new_attempts = user.failed_login_attempts + 1

            update_values: Dict[str, object] = {"failed_login_attempts": new_attempts}

            if new_attempts >= max_attempts:
                # Lock account
                lockout_until = datetime.utcnow() + lockout_duration
                update_values["locked_until"] = lockout_until

                logger.warning(
                    "Account locked due to failed attempts",
                    user_id=str(user.id),
                    email=email,
                    attempts=new_attempts,
                    locked_until=lockout_until.isoformat(),
                    ip_address=ip_address,
                )

            await self.session.execute(
                update(User).where(User.id == user.id).values(**update_values)
            )

        logger.warning(
            "Login attempt failed",
            email=email,
            reason=reason,
            user_id=str(user.id) if user else None,
            ip_address=ip_address,
        )

    async def refresh_access_token(
        self,
        refresh_token: str,
        ip_address: Optional[str] = None,
        user_agent: Optional[str] = None,
    ) -> Dict[str, object]:
        """
        Refresh access token using refresh token.

        Args:
            refresh_token: Valid refresh token
            ip_address: Client IP address
            user_agent: Client user agent

        Returns:
            Dict: New access token information

        Raises:
            AuthenticationError: If refresh token is invalid
        """
        try:
            # Verify refresh token
            token_data = verify_token(refresh_token, "refresh")
            if not token_data or not token_data.jti:
                raise AuthenticationError("Invalid refresh token")

            # Check if refresh token exists in database and is not revoked
            stmt = (
                select(RefreshToken)
                .where(RefreshToken.token_id == token_data.jti)
                .where(RefreshToken.is_revoked == False)  # noqa: E712
            )
            result = await self.session.execute(stmt)
            db_token = result.scalar_one_or_none()

            if not db_token or not db_token.is_valid:
                raise AuthenticationError("Refresh token is invalid or expired")

            # Get user with roles and permissions using optimized query
            user = await User.get_with_roles_and_permissions(
                self.session, str(db_token.user_id)
            )

            if not user or not user.is_active:
                raise AuthenticationError("User account is not active")

            # Update token usage
            await self.session.execute(
                update(RefreshToken)
                .where(RefreshToken.token_id == token_data.jti)
                .values(used_at=datetime.utcnow())
            )

            # Get user permissions from cache or compute them
            permissions = await self.cache_service.get_user_permissions(str(user.id))
            if permissions is None:
                permissions = user.get_permissions()
                await self.cache_service.cache_user_permissions(
                    str(user.id), permissions
                )

            role_names = [role.name for role in user.roles]

            # Create new access token
            new_access_token = create_access_token(
                user_id=str(user.id),
                email=user.email,
                roles=role_names,
                permissions=permissions,
            )

            await self.session.commit()

            logger.debug(
                "Access token refreshed",
                user_id=str(user.id),
                token_id=token_data.jti,
                ip_address=ip_address,
            )

            return {
                "access_token": new_access_token,
                "token_type": "bearer",
                "expires_in": settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60,
            }

        except AuthenticationError:
            await self.session.rollback()
            raise
        except Exception as e:
            await self.session.rollback()
            logger.error("Token refresh failed", error=str(e), ip_address=ip_address)
            raise AuthenticationError(f"Token refresh failed: {str(e)}")

    async def logout_user(self, access_token: str) -> bool:
        """
        Logout user by invalidating tokens.

        Args:
            access_token: JWT access token to invalidate

        Returns:
            bool: True if logout successful
        """
        try:
            # Verify and decode the token
            token_data = verify_token(access_token, "access")

            if token_data:
                # Revoke all refresh tokens for this user
                stmt = (
                    update(RefreshToken)
                    .where(RefreshToken.user_id == token_data.sub)
                    .where(RefreshToken.is_revoked == False)  # noqa: E712
                    .values(is_revoked=True, revoked_at=datetime.utcnow())
                )
                await self.session.execute(stmt)

                # End all active sessions for this user
                stmt = (
                    update(UserSession)
                    .where(UserSession.user_id == token_data.sub)
                    .where(UserSession.is_active == True)  # noqa: E712
                    .values(is_active=False, ended_at=datetime.utcnow())
                )
                await self.session.execute(stmt)

                # Clear user cache
                await self.cache_service.clear_user_cache(token_data.sub)

                await self.session.commit()

                logger.info("User logged out successfully", user_id=token_data.sub)

                return True

            return False

        except Exception as e:
            await self.session.rollback()
            logger.error("Logout failed", error=str(e))
            return False

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
            # Find user by email
            stmt = select(User).where(User.email == email)
            result = await self.session.execute(stmt)
            user = result.scalar_one_or_none()

            if user and user.is_active:
                # Generate reset token
                reset_token = generate_reset_token()

                # Store reset token in database
                password_reset = PasswordResetToken(
                    user_id=user.id,
                    token=reset_token,
                    expires_at=datetime.utcnow() + timedelta(hours=1),
                    ip_address=ip_address,
                )
                self.session.add(password_reset)

                # Send reset email
                from app.services.email_service import email_service

                await email_service.send_password_reset_email(
                    to_email=user.email,
                    user_name=user.full_name,
                    reset_token=reset_token,
                )

                await self.session.commit()

                logger.info(
                    "Password reset requested",
                    user_id=str(user.id),
                    email=email,
                )
            else:
                # User doesn't exist, but don't reveal this
                logger.warning(
                    "Password reset requested for non-existent user",
                    email=email,
                )

            return True

        except Exception as e:
            await self.session.rollback()
            logger.error("Password reset request failed", email=email, error=str(e))
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
            ValueError: If password is weak
            AuthenticationError: If token is invalid or expired
        """
        try:
            # Validate password strength
            is_strong, issues = is_password_strong(new_password)
            if not is_strong:
                raise ValueError(f"Password is too weak: {', '.join(issues)}")

            # Find valid reset token
            stmt = (
                select(PasswordResetToken)
                .where(PasswordResetToken.token == reset_token)
                .where(PasswordResetToken.is_used == False)  # noqa: E712
                .where(PasswordResetToken.expires_at > datetime.utcnow())
            )
            result = await self.session.execute(stmt)
            reset_record = result.scalar_one_or_none()

            if not reset_record:
                raise AuthenticationError("Invalid or expired reset token")

            # Get user
            user_stmt = select(User).where(User.id == reset_record.user_id)
            user_result = await self.session.execute(user_stmt)
            user = user_result.scalar_one_or_none()

            if not user:
                raise AuthenticationError("User not found")

            # Update password
            user.password_hash = get_password_hash(new_password)
            user.updated_at = datetime.utcnow()

            # Mark token as used
            reset_record.is_used = True
            reset_record.used_at = datetime.utcnow()

            # Revoke all refresh tokens (force re-login)
            stmt = (
                update(RefreshToken)
                .where(RefreshToken.user_id == user.id)
                .where(RefreshToken.is_revoked == False)  # noqa: E712
                .values(is_revoked=True, revoked_at=datetime.utcnow())
            )
            await self.session.execute(stmt)

            # Clear user cache
            await self.cache_service.clear_user_cache(str(user.id))

            # Send confirmation email
            from app.services.email_service import email_service

            await email_service.send_password_changed_email(
                to_email=user.email, user_name=user.full_name
            )

            await self.session.commit()

            logger.info(
                "Password reset successful",
                user_id=str(user.id),
                email=user.email,
            )

            return True

        except (ValueError, AuthenticationError):
            await self.session.rollback()
            raise
        except Exception as e:
            await self.session.rollback()
            logger.error(
                "Password reset failed",
                error=str(e),
                reset_token=reset_token[:8] + "...",
            )
            raise AuthenticationError("Password reset failed")

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
            ValueError: If token is invalid or expired
        """
        try:
            # Find verification token
            stmt = (
                select(EmailVerificationToken)
                .where(EmailVerificationToken.token == verification_token)
                .where(EmailVerificationToken.is_used == False)  # noqa: E712
            )
            result = await self.session.execute(stmt)
            token = result.scalar_one_or_none()

            if not token or not token.is_valid:
                raise ValueError("Invalid or expired verification token")

            # Get user
            user_stmt = select(User).where(User.id == token.user_id)
            user_result = await self.session.execute(user_stmt)
            user = user_result.scalar_one_or_none()

            if not user:
                raise ValueError("User not found")

            # Update user verification status
            await self.session.execute(
                update(User)
                .where(User.id == user.id)
                .values(is_verified=True, is_active=True)
            )

            # Mark token as used
            await self.session.execute(
                update(EmailVerificationToken)
                .where(EmailVerificationToken.id == token.id)
                .values(is_used=True, used_at=datetime.utcnow())
            )

            # Clear user cache to refresh verification status
            await self.cache_service.clear_user_cache(str(user.id))

            await self.session.commit()

            logger.info(
                "Email verified successfully",
                user_id=str(user.id),
                email=user.email,
                ip_address=ip_address,
            )

            return True

        except ValueError:
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
            raise ValueError(f"Email verification failed: {str(e)}")
