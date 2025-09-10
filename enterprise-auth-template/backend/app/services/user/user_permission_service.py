"""
User Permission Service

Handles all permission checking, role management, and authorization operations.
Focused on access control and permission validation with caching.
"""

from typing import List, Optional

import structlog
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.security import check_permission
from app.models.user import User
from app.services.cache_service import CacheService

logger = structlog.get_logger(__name__)


class UserPermissionService:
    """
    Service for user permission and role management.

    Handles permission checking, role validation, and access control
    with intelligent caching to optimize performance.
    """

    def __init__(
        self, session: AsyncSession, cache_service: Optional[CacheService] = None
    ) -> None:
        """
        Initialize user permission service.

        Args:
            session: Database session
            cache_service: Cache service for performance optimization
        """
        self.session = session
        self.cache_service = cache_service or CacheService()

    async def check_user_permission(
        self, user_id: str, required_permission: str
    ) -> bool:
        """
        Check if user has specific permission with caching optimization.

        Args:
            user_id: User ID
            required_permission: Required permission in 'resource:action' format

        Returns:
            bool: True if user has permission
        """
        try:
            # First try to get permissions from cache
            permissions = await self.cache_service.get_user_permissions(user_id)

            if permissions is None:
                # Cache miss - load user with roles and permissions
                user = await User.get_with_roles_and_permissions(self.session, user_id)

                if not user or not user.is_active:
                    logger.warning(
                        "Permission check failed - user not found or inactive",
                        user_id=user_id,
                        permission=required_permission,
                    )
                    return False

                permissions = user.get_permissions()
                # Cache the permissions for future use
                await self.cache_service.cache_user_permissions(user_id, permissions)

                logger.debug(
                    "User permissions computed and cached for permission check",
                    user_id=user_id,
                    permission_count=len(permissions),
                )
            else:
                logger.debug(
                    "User permissions loaded from cache for permission check",
                    user_id=user_id,
                    permission_count=len(permissions),
                )

            has_permission = check_permission(permissions, required_permission)

            logger.debug(
                "Permission check completed",
                user_id=user_id,
                permission=required_permission,
                has_permission=has_permission,
            )

            return has_permission

        except Exception as e:
            logger.error(
                "Permission check failed",
                user_id=user_id,
                permission=required_permission,
                error=str(e),
            )
            return False

    async def get_user_permissions(
        self, user_id: str, use_cache: bool = True
    ) -> List[str]:
        """
        Get all permissions for a user.

        Args:
            user_id: User ID
            use_cache: Whether to use cache for performance

        Returns:
            List[str]: List of user permissions in 'resource:action' format
        """
        try:
            if use_cache:
                # Try cache first
                permissions = await self.cache_service.get_user_permissions(user_id)
                if permissions is not None:
                    logger.debug(
                        "User permissions loaded from cache",
                        user_id=user_id,
                        permission_count=len(permissions),
                    )
                    return permissions

            # Cache miss or cache disabled - load from database
            user = await User.get_with_roles_and_permissions(self.session, user_id)

            if not user:
                logger.warning("User not found for permissions", user_id=user_id)
                return []

            permissions = user.get_permissions()

            if use_cache:
                # Cache for future use
                await self.cache_service.cache_user_permissions(user_id, permissions)
                logger.debug(
                    "User permissions computed and cached",
                    user_id=user_id,
                    permission_count=len(permissions),
                )

            return permissions

        except Exception as e:
            logger.error(
                "Failed to get user permissions", user_id=user_id, error=str(e)
            )
            return []

    async def get_user_roles(self, user_id: str, use_cache: bool = True) -> List[str]:
        """
        Get all role names for a user.

        Args:
            user_id: User ID
            use_cache: Whether to use cache for performance

        Returns:
            List[str]: List of role names
        """
        try:
            if use_cache:
                # Try to get roles from cache
                cached_roles = await self.cache_service.get_user_roles(user_id)
                if cached_roles is not None:
                    role_names = [role["name"] for role in cached_roles]
                    logger.debug(
                        "User roles loaded from cache",
                        user_id=user_id,
                        role_count=len(role_names),
                    )
                    return role_names

            # Load user with roles
            user = await User.get_with_roles_and_permissions(self.session, user_id)

            if not user:
                logger.warning("User not found for roles", user_id=user_id)
                return []

            role_names = [role.name for role in user.roles]

            if use_cache:
                # Cache roles data
                roles_data = [
                    {
                        "id": str(role.id),
                        "name": role.name,
                        "description": role.description,
                        "permissions": [
                            {"resource": perm.resource, "action": perm.action}
                            for perm in role.permissions
                        ],
                    }
                    for role in user.roles
                ]
                await self.cache_service.cache_user_roles(user_id, roles_data)
                logger.debug(
                    "User roles computed and cached",
                    user_id=user_id,
                    role_count=len(role_names),
                )

            return role_names

        except Exception as e:
            logger.error("Failed to get user roles", user_id=user_id, error=str(e))
            return []

    async def user_has_role(
        self, user_id: str, role_name: str, use_cache: bool = True
    ) -> bool:
        """
        Check if user has a specific role.

        Args:
            user_id: User ID
            role_name: Role name to check
            use_cache: Whether to use cache for performance

        Returns:
            bool: True if user has the role
        """
        try:
            user_roles = await self.get_user_roles(user_id, use_cache=use_cache)
            has_role = role_name in user_roles

            logger.debug(
                "Role check completed",
                user_id=user_id,
                role_name=role_name,
                has_role=has_role,
            )

            return has_role

        except Exception as e:
            logger.error(
                "Role check failed", user_id=user_id, role_name=role_name, error=str(e)
            )
            return False

    async def user_has_any_role(
        self, user_id: str, role_names: List[str], use_cache: bool = True
    ) -> bool:
        """
        Check if user has any of the specified roles.

        Args:
            user_id: User ID
            role_names: List of role names to check
            use_cache: Whether to use cache for performance

        Returns:
            bool: True if user has at least one of the roles
        """
        try:
            user_roles = await self.get_user_roles(user_id, use_cache=use_cache)
            user_roles_set = set(user_roles)
            required_roles_set = set(role_names)

            has_any_role = bool(user_roles_set.intersection(required_roles_set))

            logger.debug(
                "Multiple role check completed",
                user_id=user_id,
                required_roles=role_names,
                user_roles=user_roles,
                has_any_role=has_any_role,
            )

            return has_any_role

        except Exception as e:
            logger.error(
                "Multiple role check failed",
                user_id=user_id,
                role_names=role_names,
                error=str(e),
            )
            return False

    async def user_has_all_roles(
        self, user_id: str, role_names: List[str], use_cache: bool = True
    ) -> bool:
        """
        Check if user has all of the specified roles.

        Args:
            user_id: User ID
            role_names: List of role names to check
            use_cache: Whether to use cache for performance

        Returns:
            bool: True if user has all the roles
        """
        try:
            user_roles = await self.get_user_roles(user_id, use_cache=use_cache)
            user_roles_set = set(user_roles)
            required_roles_set = set(role_names)

            has_all_roles = required_roles_set.issubset(user_roles_set)

            logger.debug(
                "All roles check completed",
                user_id=user_id,
                required_roles=role_names,
                user_roles=user_roles,
                has_all_roles=has_all_roles,
            )

            return has_all_roles

        except Exception as e:
            logger.error(
                "All roles check failed",
                user_id=user_id,
                role_names=role_names,
                error=str(e),
            )
            return False

    async def check_multiple_permissions(
        self, user_id: str, required_permissions: List[str]
    ) -> dict[str, bool]:
        """
        Check multiple permissions at once for efficiency.

        Args:
            user_id: User ID
            required_permissions: List of permissions to check

        Returns:
            dict[str, bool]: Mapping of permission to whether user has it
        """
        try:
            user_permissions = await self.get_user_permissions(user_id, use_cache=True)

            results = {}
            for permission in required_permissions:
                results[permission] = check_permission(user_permissions, permission)

            logger.debug(
                "Multiple permission check completed",
                user_id=user_id,
                checked_permissions=len(required_permissions),
                granted_permissions=sum(results.values()),
            )

            return results

        except Exception as e:
            logger.error(
                "Multiple permission check failed",
                user_id=user_id,
                permissions=required_permissions,
                error=str(e),
            )
            return {perm: False for perm in required_permissions}

    async def is_superuser(self, user_id: str) -> bool:
        """
        Check if user is a superuser.

        Args:
            user_id: User ID

        Returns:
            bool: True if user is a superuser
        """
        try:
            stmt = select(User.is_superuser).where(User.id == user_id)
            result = await self.session.execute(stmt)
            is_super = result.scalar_one_or_none()

            logger.debug(
                "Superuser check completed",
                user_id=user_id,
                is_superuser=bool(is_super),
            )

            return bool(is_super)

        except Exception as e:
            logger.error("Superuser check failed", user_id=user_id, error=str(e))
            return False

    async def invalidate_user_permissions_cache(self, user_id: str) -> bool:
        """
        Invalidate cached permissions for a user.

        Call this when user roles or permissions change.

        Args:
            user_id: User ID

        Returns:
            bool: True if cache was invalidated successfully
        """
        try:
            success = await self.cache_service.clear_user_cache(user_id)

            if success:
                logger.info("User permissions cache invalidated", user_id=user_id)

            return success

        except Exception as e:
            logger.error(
                "Failed to invalidate user permissions cache",
                user_id=user_id,
                error=str(e),
            )
            return False
