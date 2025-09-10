"""
User CRUD Service

Handles all user creation, retrieval, update, and delete operations.
Focused on data persistence and basic user management operations.
"""

from datetime import datetime
from typing import Any, Dict, Optional

import structlog
from sqlalchemy import select, update, func
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.security import get_password_hash, is_password_strong
from app.models.user import User, UserRole
from app.models.role import Role
from app.schemas.auth import RegisterRequest, UserResponse
from app.services.cache_service import CacheService

logger = structlog.get_logger(__name__)


class UserCRUDService:
    """
    Service for user CRUD operations.

    Handles user creation, retrieval, updating, and deletion with
    proper validation, caching, and error handling.
    """

    def __init__(
        self, session: AsyncSession, cache_service: Optional[CacheService] = None
    ) -> None:
        """
        Initialize user CRUD service.

        Args:
            session: Database session
            cache_service: Cache service for performance optimization
        """
        self.session = session
        self.cache_service = cache_service or CacheService()

    async def create_user(
        self,
        registration_data: RegisterRequest,
        ip_address: Optional[str] = None,
    ) -> UserResponse:
        """
        Create a new user account.

        Args:
            registration_data: User registration information
            ip_address: Client IP address for audit logging

        Returns:
            UserResponse: Created user information

        Raises:
            ValueError: If email already exists or validation fails
        """
        try:
            # Check if email already exists
            stmt = select(User).where(User.email == registration_data.email)
            existing_user = await self.session.execute(stmt)
            if existing_user.scalar_one_or_none():
                logger.warning(
                    "Registration attempt with existing email",
                    email=registration_data.email,
                    ip_address=ip_address,
                )
                raise ValueError("Email address is already registered")

            # Validate password strength
            is_strong, issues = is_password_strong(registration_data.password)
            if not is_strong:
                logger.warning(
                    "Registration attempt with weak password",
                    email=registration_data.email,
                    issues=issues,
                )
                raise ValueError(f"Password requirements not met: {', '.join(issues)}")

            # Hash password
            password_hash = get_password_hash(registration_data.password)

            # Create user
            user = User(
                email=registration_data.email,
                hashed_password=password_hash,
                first_name=registration_data.first_name,
                last_name=registration_data.last_name,
                is_active=True,  # Temporarily set to active for testing
                is_verified=False,
                is_superuser=False,
            )

            self.session.add(user)
            await self.session.flush()

            # Assign default user role
            role_stmt = select(Role).where(Role.name == "user")
            result = await self.session.execute(role_stmt)
            user_role = result.scalar_one_or_none()

            if user_role:
                user_role_assignment = UserRole(user_id=user.id, role_id=user_role.id)
                self.session.add(user_role_assignment)
                await self.session.flush()

            await self.session.commit()

            logger.info(
                "User registered successfully",
                user_id=str(user.id),
                email=user.email,
                ip_address=ip_address,
            )

            return UserResponse(
                id=str(user.id),
                email=user.email,
                first_name=user.first_name,
                last_name=user.last_name,
                is_active=user.is_active,
                is_verified=user.is_verified,
                roles=["user"],
                created_at=user.created_at.isoformat(),
                updated_at=(user.updated_at.isoformat() if user.updated_at else None),
                last_login=None,
            )

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
            raise ValueError(f"Registration failed: {str(e)}")

    async def get_user_by_id(
        self, user_id: str, include_roles: bool = False, use_cache: bool = True
    ) -> Optional[User]:
        """
        Get user by ID with optional role loading and caching.

        Args:
            user_id: User ID
            include_roles: Whether to include roles and permissions
            use_cache: Whether to use cache for performance

        Returns:
            User or None: User object if found
        """
        try:
            if include_roles:
                # Use optimized query for roles and permissions
                user = await User.get_with_roles_and_permissions(self.session, user_id)
            else:
                # Simple user lookup
                stmt = select(User).where(User.id == user_id)
                result = await self.session.execute(stmt)
                user = result.scalar_one_or_none()

            if user and use_cache and include_roles:
                # Cache user permissions for future use
                permissions = user.get_permissions()
                await self.cache_service.cache_user_permissions(user_id, permissions)

            return user

        except Exception as e:
            logger.error("Failed to get user by ID", user_id=user_id, error=str(e))
            return None

    async def get_user_by_email(
        self, email: str, include_roles: bool = False
    ) -> Optional[User]:
        """
        Get user by email with optional role loading.

        Args:
            email: User email address
            include_roles: Whether to include roles and permissions

        Returns:
            User or None: User object if found
        """
        try:
            if include_roles:
                return await User.get_by_email_with_roles(self.session, email)
            else:
                stmt = select(User).where(User.email == email)
                result = await self.session.execute(stmt)
                return result.scalar_one_or_none()

        except Exception as e:
            logger.error("Failed to get user by email", email=email, error=str(e))
            return None

    async def update_user(
        self, user_id: str, update_data: Dict[str, Any], clear_cache: bool = True
    ) -> Optional[User]:
        """
        Update user information.

        Args:
            user_id: User ID
            update_data: Dictionary of fields to update
            clear_cache: Whether to clear user cache after update

        Returns:
            User or None: Updated user object
        """
        try:
            # Update user
            stmt = (
                update(User)
                .where(User.id == user_id)
                .values(**update_data, updated_at=datetime.utcnow())
                .returning(User)
            )
            result = await self.session.execute(stmt)
            user = result.scalar_one_or_none()

            if user:
                await self.session.commit()

                if clear_cache:
                    # Clear user cache after update
                    await self.cache_service.clear_user_cache(user_id)

                logger.info(
                    "User updated successfully",
                    user_id=user_id,
                    updated_fields=list(update_data.keys()),
                )

            return user

        except Exception as e:
            await self.session.rollback()
            logger.error("Failed to update user", user_id=user_id, error=str(e))
            return None

    async def get_users_paginated(
        self,
        page: int = 1,
        limit: int = 100,
        active_only: bool = True,
        include_roles: bool = False,
    ) -> Dict[str, Any]:
        """
        Get paginated list of users.

        Args:
            page: Page number (1-indexed)
            limit: Number of users per page
            active_only: Whether to include only active users
            include_roles: Whether to include user roles

        Returns:
            Dict: Paginated user data with total count
        """
        try:
            offset = (page - 1) * limit

            if active_only and include_roles:
                users = await User.get_active_users_with_roles(
                    self.session, limit=limit, offset=offset
                )
                # Count total active users
                count_stmt = select(func.count(User.id)).where(User.is_active == True)
            elif active_only:
                stmt = (
                    select(User)
                    .where(User.is_active == True)
                    .offset(offset)
                    .limit(limit)
                    .order_by(User.created_at.desc())
                )
                result = await self.session.execute(stmt)
                users = result.scalars().all()
                count_stmt = select(func.count(User.id)).where(User.is_active == True)
            else:
                stmt = (
                    select(User)
                    .offset(offset)
                    .limit(limit)
                    .order_by(User.created_at.desc())
                )
                result = await self.session.execute(stmt)
                users = result.scalars().all()
                count_stmt = select(func.count(User.id))

            # Get total count
            count_result = await self.session.execute(count_stmt)
            total_count = count_result.scalar()

            return {
                "users": [
                    UserResponse(
                        id=str(user.id),
                        email=user.email,
                        first_name=user.first_name,
                        last_name=user.last_name,
                        is_active=user.is_active,
                        is_verified=user.is_verified,
                        roles=(
                            [role.name for role in user.roles] if include_roles else []
                        ),
                        created_at=user.created_at.isoformat(),
                        updated_at=(
                            user.updated_at.isoformat() if user.updated_at else None
                        ),
                        last_login=(
                            user.last_login.isoformat() if user.last_login else None
                        ),
                    )
                    for user in users
                ],
                "total": total_count,
                "page": page,
                "limit": limit,
                "total_pages": (total_count + limit - 1) // limit,
            }

        except Exception as e:
            logger.error(
                "Failed to get paginated users", page=page, limit=limit, error=str(e)
            )
            return {
                "users": [],
                "total": 0,
                "page": page,
                "limit": limit,
                "total_pages": 0,
            }

    async def deactivate_user(self, user_id: str, reason: str = "") -> bool:
        """
        Deactivate user account.

        Args:
            user_id: User ID
            reason: Reason for deactivation

        Returns:
            bool: True if deactivated successfully
        """
        try:
            success = await self.update_user(
                user_id, {"is_active": False}, clear_cache=True
            )

            if success:
                logger.info("User deactivated", user_id=user_id, reason=reason)

            return success is not None

        except Exception as e:
            logger.error("Failed to deactivate user", user_id=user_id, error=str(e))
            return False

    async def activate_user(self, user_id: str) -> bool:
        """
        Activate user account.

        Args:
            user_id: User ID

        Returns:
            bool: True if activated successfully
        """
        try:
            success = await self.update_user(
                user_id, {"is_active": True}, clear_cache=True
            )

            if success:
                logger.info("User activated", user_id=user_id)

            return success is not None

        except Exception as e:
            logger.error("Failed to activate user", user_id=user_id, error=str(e))
            return False
