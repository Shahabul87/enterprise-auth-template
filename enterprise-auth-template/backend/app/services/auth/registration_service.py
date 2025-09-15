"""
Registration Service

Handles user registration operations following the Single Responsibility Principle.
This service is focused exclusively on creating new user accounts.
"""

from datetime import datetime, timedelta
from typing import Optional

import structlog
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.security import get_password_hash, generate_verification_token
from app.models.auth import EmailVerificationToken
from app.models.user import User
from app.models.role import Role
from app.repositories.user_repository import UserRepository
from app.repositories.role_repository import RoleRepository
from app.schemas.auth import RegisterRequest, UserResponse


logger = structlog.get_logger(__name__)


class RegistrationError(Exception):
    """Registration-related errors."""
    pass


class RegistrationService:
    """
    Service dedicated to user registration operations.

    Responsibilities:
    - New user account creation
    - Initial role assignment
    - Verification token generation
    - Registration validation
    """

    def __init__(
        self,
        session: AsyncSession,
        user_repository: Optional[UserRepository] = None,
        role_repository: Optional[RoleRepository] = None,
    ) -> None:
        """
        Initialize registration service.

        Args:
            session: Database session
            user_repository: User repository for data access
            role_repository: Role repository for role management
        """
        self.session = session
        self.user_repo = user_repository or UserRepository(session)
        self.role_repo = role_repository or RoleRepository(session)

    async def register_user(
        self,
        registration_data: RegisterRequest,
        ip_address: Optional[str] = None,
        user_agent: Optional[str] = None,
    ) -> UserResponse:
        """
        Register a new user account.

        Args:
            registration_data: User registration information
            ip_address: Client IP address for audit logging
            user_agent: Client user agent

        Returns:
            UserResponse: Created user information

        Raises:
            RegistrationError: If registration fails
            ValueError: If validation fails
        """
        try:
            # Validate email uniqueness
            if await self.user_repo.exists_by_email(registration_data.email):
                logger.warning(
                    "Registration attempt with existing email",
                    email=registration_data.email,
                    ip_address=ip_address,
                )
                raise ValueError("Email address is already registered")

            # Create user domain object with validation
            user = await self._create_user_entity(registration_data)

            # Persist user
            created_user = await self.user_repo.create(user.to_dict())

            # Assign default role
            await self._assign_default_role(created_user.id)

            # Generate verification token
            verification_token = await self._create_verification_token(created_user.id)

            # Send verification email (delegated to email service)
            await self._send_verification_email(
                created_user.email,
                created_user.full_name,
                verification_token
            )

            await self.session.commit()

            logger.info(
                "User registered successfully",
                user_id=str(created_user.id),
                email=created_user.email,
                ip_address=ip_address,
            )

            return self._create_user_response(created_user)

        except ValueError:
            await self.session.rollback()
            raise
        except Exception as e:
            await self.session.rollback()
            logger.error(
                "User registration failed",
                email=registration_data.email,
                error=str(e),
                ip_address=ip_address,
            )
            raise RegistrationError(f"Registration failed: {str(e)}")

    async def _create_user_entity(self, registration_data: RegisterRequest) -> User:
        """
        Create a user entity with validation.

        Args:
            registration_data: Registration request data

        Returns:
            User: User domain object
        """
        # Get full name
        full_name = registration_data.full_name if hasattr(registration_data, 'full_name') and registration_data.full_name else None

        # If no name provided, use email prefix as fallback
        if not full_name:
            full_name = registration_data.email.split('@')[0]

        # Create user with domain validation
        user = User()
        user.email = registration_data.email
        user.full_name = full_name

        # Use domain method for password (will be enriched later)
        user.set_password(registration_data.password)

        # User is active but email not verified
        # is_active is for account suspension, not email verification
        user.is_active = True
        user.email_verified = False
        user.is_superuser = False

        return user

    async def _assign_default_role(self, user_id: str) -> None:
        """
        Assign default role to a new user.

        Args:
            user_id: User ID to assign role to
        """
        default_role = await self.role_repo.find_by_name("user")
        if default_role:
            await self.role_repo.assign_to_user(user_id, default_role.id)
            logger.debug(
                "Default role assigned",
                user_id=user_id,
                role="user"
            )

    async def _create_verification_token(self, user_id: str) -> str:
        """
        Create email verification token.

        Args:
            user_id: User ID for token

        Returns:
            str: Verification token
        """
        verification_token = generate_verification_token()

        email_verification = EmailVerificationToken(
            user_id=user_id,
            token=verification_token,
            expires_at=datetime.utcnow() + timedelta(hours=24),
        )
        self.session.add(email_verification)

        return verification_token

    async def _send_verification_email(
        self,
        email: str,
        user_name: str,
        token: str
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
                success = await enhanced_email_service.send_verification_email(
                    to_email=email,
                    user_name=user_name,
                    verification_token=token,
                )
                if not success:
                    raise Exception("Enhanced email service returned failure")
            except (ImportError, Exception) as e:
                # Fallback to basic email service
                from app.services.email_service import email_service
                success = await email_service.send_verification_email(
                    to_email=email,
                    user_name=user_name,
                    verification_token=token,
                )
                if not success:
                    raise Exception("Email service returned failure")

            logger.info(
                "Verification email sent successfully",
                email=email,
            )
        except Exception as e:
            # Get settings to check environment
            from app.core.config import get_settings
            settings = get_settings()

            logger.error(
                "Failed to send verification email",
                email=email,
                error=str(e),
                environment=settings.ENVIRONMENT,
            )

            # In production, we should fail the registration if email can't be sent
            # In development, we allow registration to proceed
            if settings.ENVIRONMENT == "production":
                raise Exception(f"Failed to send verification email: {str(e)}")
            else:
                logger.warning(
                    "Proceeding with registration despite email failure (development mode)",
                    email=email,
                )

    def _create_user_response(self, user: User) -> UserResponse:
        """
        Create user response from user entity.

        Args:
            user: User entity

        Returns:
            UserResponse: User response schema
        """
        full_name = user.full_name
        return UserResponse(
            id=str(user.id),
            email=user.email,
            full_name=full_name,
            name=full_name,  # Display name for Flutter compatibility
            profilePicture=user.avatar_url,  # Use alias field name
            isEmailVerified=user.email_verified,  # Use alias field name
            isTwoFactorEnabled=user.two_factor_enabled,  # Use alias field name
            roles=["user"],  # Default role
            permissions=[],  # Will be populated later from role
            createdAt=user.created_at.isoformat(),  # Use alias field name
            updatedAt=user.updated_at.isoformat() if user.updated_at else user.created_at.isoformat(),  # Use alias field name
        )

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
            bool: True if email sent (always returns True for security)
        """
        try:
            user = await self.user_repo.find_by_email(email)

            if user and not user.email_verified:
                # Generate new verification token
                verification_token = generate_verification_token()

                # Update or create verification token
                # This would be better handled by a dedicated repository
                from sqlalchemy import select
                stmt = (
                    select(EmailVerificationToken)
                    .where(EmailVerificationToken.user_id == user.id)
                    .where(EmailVerificationToken.is_used.is_(False))
                )
                result = await self.session.execute(stmt)
                existing_token = result.scalar_one_or_none()

                if existing_token:
                    existing_token.token = verification_token
                    existing_token.expires_at = datetime.utcnow() + timedelta(hours=24)
                else:
                    email_verification = EmailVerificationToken(
                        user_id=user.id,
                        token=verification_token,
                        expires_at=datetime.utcnow() + timedelta(hours=24),
                    )
                    self.session.add(email_verification)

                # Send verification email
                await self._send_verification_email(
                    user.email,
                    user.full_name,
                    verification_token
                )

                await self.session.commit()

                logger.info(
                    "Verification email resent",
                    user_id=str(user.id),
                    email=email,
                )
            else:
                logger.info(
                    "Verification email not needed",
                    email=email,
                    exists=user is not None,
                    verified=user.email_verified if user else None,
                )

            return True

        except Exception as e:
            await self.session.rollback()
            logger.error("Verification email resend failed", email=email, error=str(e))
            # Still return True for security reasons
            return True