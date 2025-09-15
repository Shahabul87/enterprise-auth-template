"""
Authentication Service

Handles user authentication operations including login, logout, and token management.
This service follows the Single Responsibility Principle by focusing only on authentication.
"""

from datetime import datetime, timedelta, timezone
from typing import Dict, Optional, Tuple
from enum import Enum

import structlog
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import get_settings
from app.core.security import (
    create_access_token,
    create_refresh_token,
    verify_password,
    verify_token,
    create_secure_session_id,
)
from app.models.auth import RefreshToken
from app.models.session import UserSession
from app.models.user import User
from app.repositories.user_repository import UserRepository
from app.repositories.session_repository import SessionRepository
from app.schemas.auth import LoginResponse, UserResponse
from app.services.cache_service import CacheService

settings = get_settings()
logger = structlog.get_logger(__name__)


class PrivilegeLevel(str, Enum):
    """User privilege levels for session security."""
    SUPER_ADMIN = "super_admin"
    ADMIN = "admin"
    MODERATOR = "moderator"
    PREMIUM = "premium"
    USER = "user"
    GUEST = "guest"


class AuthenticationError(Exception):
    """Authentication-related errors."""
    pass


class AccountLockedError(AuthenticationError):
    """Account is locked due to too many failed attempts."""
    pass


class EmailNotVerifiedError(AuthenticationError):
    """Email address is not verified."""
    pass


class AuthenticationService:
    """
    Service dedicated to user authentication operations.

    Responsibilities:
    - User login/logout
    - Token generation and refresh
    - Session management
    - Failed login attempt tracking
    """

    def __init__(
        self,
        session: AsyncSession,
        user_repository: Optional[UserRepository] = None,
        session_repository: Optional[SessionRepository] = None,
        cache_service: Optional[CacheService] = None,
    ) -> None:
        """
        Initialize authentication service.

        Args:
            session: Database session
            user_repository: User repository for data access
            session_repository: Session repository for session management
            cache_service: Cache service for performance optimization
        """
        self.session = session
        self.user_repo = user_repository or UserRepository(session)
        self.session_repo = session_repository or SessionRepository(session)
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
            # Get user with roles
            user = await self.user_repo.find_by_email_with_roles(email)

            if not user:
                logger.warning(f"Authentication failed - User not found: {email}")
                await self._handle_failed_login(email, ip_address)
                raise AuthenticationError("Invalid email or password")

            if not user.hashed_password:
                logger.warning(f"Authentication failed - User has no password set: {email}")
                await self._handle_failed_login(email, ip_address)
                raise AuthenticationError("Invalid email or password")

            # Check if account is locked
            if user.is_locked:
                logger.warning(
                    "Login attempt on locked account",
                    user_id=str(user.id),
                    email=email,
                    locked_until=user.locked_until.isoformat() if user.locked_until else None,
                    ip_address=ip_address,
                )
                raise AccountLockedError(f"Account is locked until {user.locked_until}")

            # Verify password
            password_valid = verify_password(password, user.hashed_password)
            logger.warning(f"Password verification for {email}: valid={password_valid}, is_active={user.is_active}, email_verified={user.email_verified}")

            if not password_valid:
                logger.warning(f"Authentication failed - Invalid password for: {email}")
                await self._handle_failed_login(email, ip_address, user)
                raise AuthenticationError("Invalid email or password")

            # Check if account is active
            if not user.is_active:
                raise AuthenticationError("Account is not active")

            # Check if email is verified (critical security requirement)
            # Use configuration settings to determine if verification should be enforced
            if settings.should_enforce_email_verification() and not user.email_verified:
                logger.warning(
                    "Login attempt with unverified email",
                    user_id=str(user.id),
                    email=email,
                    ip_address=ip_address,
                )
                raise EmailNotVerifiedError(
                    "Please verify your email address before logging in. "
                    "Check your inbox for a verification link or request a new one."
                )

            # Reset failed login attempts on successful login
            if user.failed_login_attempts > 0:
                await self.user_repo.reset_failed_attempts(user.id)

            # Extract all user data before any database operations
            user_id = user.id
            user_email = user.email
            user_full_name = user.full_name
            user_avatar_url = user.avatar_url
            user_email_verified = user.email_verified
            user_two_factor_enabled = user.two_factor_enabled
            user_is_active = user.is_active
            user_created_at = user.created_at
            user_updated_at = user.updated_at
            user_last_login = user.last_login

            # Update last login
            await self.user_repo.update_last_login(user_id, datetime.now(timezone.utc))

            # Generate tokens and create session with extracted data
            tokens = await self._create_user_session_with_data(
                user_id=user_id,
                user_email=user_email,
                user_full_name=user_full_name,
                user_avatar_url=user_avatar_url,
                user_email_verified=user_email_verified,
                user_two_factor_enabled=user_two_factor_enabled,
                user_is_active=user_is_active,
                user_created_at=user_created_at,
                user_updated_at=user_updated_at,
                user_last_login=user_last_login,
                user_roles=user.roles,
                ip_address=ip_address,
                user_agent=user_agent
            )

            # Don't commit here - let the session handler manage it
            # await self.session.commit()

            logger.info(
                "User authenticated successfully",
                user_id=str(user.id),
                email=user.email,
                ip_address=ip_address,
            )

            return tokens

        except (AuthenticationError, AccountLockedError, EmailNotVerifiedError):
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

            # Get refresh token from repository
            db_token = await self.session_repo.find_refresh_token(token_data.jti)
            if not db_token or not db_token.is_valid:
                raise AuthenticationError("Refresh token is invalid or expired")

            # Get user with roles
            user = await self.user_repo.find_with_roles(db_token.user_id)
            if not user or not user.is_active:
                raise AuthenticationError("User account is not active")

            # Mark token as used
            await self.session_repo.mark_token_used(token_data.jti)

            # Get user permissions from cache or compute them
            permissions = await self._get_user_permissions(user)
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
        Logout user by invalidating tokens and sessions.

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
                await self.session_repo.revoke_user_tokens(token_data.sub)

                # End all active sessions for this user
                await self.session_repo.end_user_sessions(token_data.sub)

                await self.session.commit()

                logger.info("User logged out successfully", user_id=token_data.sub)
                return True

            return False

        except Exception as e:
            await self.session.rollback()
            logger.error("Logout failed", error=str(e))
            return False

    async def _handle_failed_login(
        self,
        email: str,
        ip_address: Optional[str] = None,
        user: Optional[User] = None,
    ) -> None:
        """
        Handle failed login attempts with account lockout.

        Args:
            email: User email
            ip_address: Client IP address
            user: User object if available
        """
        max_attempts = 5
        lockout_duration = timedelta(minutes=30)

        if user:
            # Increment failed attempts
            new_attempts = await self.user_repo.increment_failed_attempts(user.id)

            if new_attempts >= max_attempts:
                # Lock account
                lockout_until = datetime.now(timezone.utc) + lockout_duration
                await self.user_repo.lock_account(user.id, lockout_until)

                logger.warning(
                    "Account locked due to failed attempts",
                    user_id=str(user.id),
                    email=email,
                    attempts=new_attempts,
                    locked_until=lockout_until.isoformat(),
                    ip_address=ip_address,
                )

        logger.warning(
            "Login attempt failed",
            email=email,
            user_id=str(user.id) if user else None,
            ip_address=ip_address,
        )

    async def _create_user_session_with_data(
        self,
        user_id,
        user_email: str,
        user_full_name: str,
        user_avatar_url: str,
        user_email_verified: bool,
        user_two_factor_enabled: bool,
        user_is_active: bool,
        user_created_at,
        user_updated_at,
        user_last_login,
        user_roles,
        ip_address: Optional[str] = None,
        user_agent: Optional[str] = None,
    ) -> LoginResponse:
        """
        Create user session and generate authentication tokens from extracted data.

        Args:
            user_id: User ID
            user_email: User email
            user_full_name: User full name
            user_avatar_url: User avatar URL
            user_email_verified: Email verification status
            user_two_factor_enabled: 2FA status
            user_is_active: Active status
            user_created_at: Created timestamp
            user_updated_at: Updated timestamp
            user_last_login: Last login timestamp
            user_roles: User roles
            ip_address: Client IP address
            user_agent: Client user agent

        Returns:
            LoginResponse: Authentication tokens and user info
        """
        # Get permissions and role names
        permissions = []
        role_names = [role.name for role in user_roles] if user_roles else []

        # Calculate privilege level
        privilege_level = self._calculate_privilege_level(role_names)

        # Create session ID
        session_id = create_secure_session_id()

        # Create session in database
        session_data = {
            "session_id": session_id,
            "user_id": user_id,
            "ip_address": ip_address or "unknown",
            "user_agent": user_agent or "unknown",
            "expires_at": datetime.now(timezone.utc) + timedelta(hours=24),
            "is_active": True,
        }
        await self.session_repo.create(session_data)

        # Create tokens
        access_token = create_access_token(
            user_id=str(user_id),
            email=user_email,
            roles=role_names,
            permissions=permissions,
            session_id=session_id,
        )

        refresh_token_jwt, refresh_token_id = create_refresh_token(
            str(user_id),
            session_id=session_id
        )

        # Store refresh token
        await self.session_repo.create_refresh_token({
            "token_hash": refresh_token_id,
            "user_id": user_id,
            "expires_at": datetime.now(timezone.utc) + timedelta(days=7),
        })

        # Create UserResponse from extracted data
        display_name = user_full_name or user_email.split("@")[0]
        user_response = UserResponse(
            id=str(user_id),
            email=user_email,
            full_name=user_full_name,
            name=display_name,
            profilePicture=user_avatar_url,
            isEmailVerified=user_email_verified,
            isTwoFactorEnabled=user_two_factor_enabled,
            roles=role_names,
            permissions=permissions,
            createdAt=user_created_at.isoformat() if user_created_at else "",
            updatedAt=user_updated_at.isoformat() if user_updated_at else "",
            lastLoginAt=user_last_login.isoformat() if user_last_login else None,
            is_active=user_is_active
        )

        return LoginResponse(
            access_token=access_token,
            refresh_token=refresh_token_jwt,
            token_type="bearer",
            expires_in=settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60,
            requires_2fa=False,
            temp_token=None,
            user=user_response,
        )

    async def _create_user_session(
        self,
        user: User,
        ip_address: Optional[str] = None,
        user_agent: Optional[str] = None,
    ) -> LoginResponse:
        """
        Create user session and generate authentication tokens.

        Args:
            user: Authenticated user
            ip_address: Client IP address
            user_agent: Client user agent

        Returns:
            LoginResponse: Authentication tokens and user info
        """
        # Get user permissions
        permissions = await self._get_user_permissions(user)
        role_names = [role.name for role in user.roles]

        # Calculate privilege level
        privilege_level = self._calculate_privilege_level(role_names)

        # Create session ID
        session_id = create_secure_session_id()

        # Create session in database - only include columns that exist
        session_data = {
            "session_id": session_id,  # This will map to session_token
            "user_id": user.id,
            "ip_address": ip_address or "unknown",
            "user_agent": user_agent or "unknown",
            "expires_at": datetime.now(timezone.utc) + timedelta(hours=24),
            "is_active": True,
        }
        # Skip session_metadata and other columns that don't exist in DB yet
        await self.session_repo.create(session_data)

        # Extract user data while session is active
        user_data = {
            "id": str(user.id),
            "email": user.email,
            "full_name": user.full_name,
            "avatar_url": user.avatar_url,
            "email_verified": user.email_verified,
            "two_factor_enabled": user.two_factor_enabled,
            "is_active": user.is_active,
            "created_at": user.created_at.isoformat() if user.created_at else "",
            "updated_at": user.updated_at.isoformat() if user.updated_at else "",
            "last_login": user.last_login.isoformat() if user.last_login else None,
        }

        # Create tokens
        access_token = create_access_token(
            user_id=str(user.id),
            email=user.email,
            roles=role_names,
            permissions=permissions,
            session_id=session_id,
        )

        refresh_token_jwt, refresh_token_id = create_refresh_token(
            str(user.id),
            session_id=session_id
        )

        # Store refresh token (using token_hash field to match database schema)
        await self.session_repo.create_refresh_token({
            "token_hash": refresh_token_id,
            "user_id": user.id,
            "expires_at": datetime.now(timezone.utc) + timedelta(days=7),
        })

        # Create UserResponse from extracted data
        display_name = user_data["full_name"] or user_data["email"].split("@")[0]
        user_response = UserResponse(
            id=user_data["id"],
            email=user_data["email"],
            full_name=user_data["full_name"],
            name=display_name,
            profile_picture=user_data["avatar_url"],
            email_verified=user_data["email_verified"],
            two_factor_enabled=user_data["two_factor_enabled"],
            roles=role_names,
            permissions=permissions,
            created_at=user_data["created_at"],
            updated_at=user_data["updated_at"],
            last_login_at=user_data["last_login"],
            is_active=user_data["is_active"]
        )

        return LoginResponse(
            access_token=access_token,
            refresh_token=refresh_token_jwt,
            token_type="bearer",
            expires_in=settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60,
            requires_2fa=False,
            temp_token=None,
            user=user_response,
        )

    async def _get_user_permissions(self, user: User) -> list[str]:
        """
        Get user permissions from cache or compute them.

        Args:
            user: User object

        Returns:
            List of permission strings
        """
        permissions = await self.cache_service.get_user_permissions(str(user.id))
        if permissions is None:
            permissions = user.get_permissions()
            await self.cache_service.cache_user_permissions(str(user.id), permissions)
        return permissions

    def _calculate_privilege_level(self, roles: list[str]) -> str:
        """
        Calculate privilege level from user roles.

        Args:
            roles: List of role names

        Returns:
            str: Calculated privilege level
        """
        role_names = [role.lower() for role in roles]

        if "super_admin" in role_names or "superuser" in role_names:
            return PrivilegeLevel.SUPER_ADMIN.value
        elif "admin" in role_names or "administrator" in role_names:
            return PrivilegeLevel.ADMIN.value
        elif "moderator" in role_names:
            return PrivilegeLevel.MODERATOR.value
        elif "premium" in role_names or "pro" in role_names:
            return PrivilegeLevel.PREMIUM.value
        elif "user" in role_names or "member" in role_names:
            return PrivilegeLevel.USER.value
        else:
            return PrivilegeLevel.GUEST.value