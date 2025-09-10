"""
Role Service for RBAC operations.
"""

from typing import List, Optional, Dict, Any
from uuid import UUID
from datetime import datetime
from sqlalchemy import select, and_, or_, func
from sqlalchemy.orm import selectinload, joinedload
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.exc import IntegrityError

from app.models.role import Role, SystemRoles
from app.models.user import UserRole
from app.models.permission import Permission, SystemPermissions
from app.models.user import User
from app.core.database import get_db
from app.services.audit_service import AuditService
from app.core.config import get_settings
import logging

logger = logging.getLogger(__name__)


class RoleService:
    """Service for managing roles and role assignments."""

    def __init__(self, db: AsyncSession):
        """Initialize role service."""
        self.db = db
        self.audit_service = AuditService(db)

    async def create_role(
        self,
        name: str,
        display_name: str,
        description: Optional[str] = None,
        is_system: bool = False,
        priority: int = 0,
        permissions: Optional[List[str]] = None,
        current_user: Optional[User] = None
    ) -> Role:
        """
        Create a new role.

        Args:
            name: Unique role name
            display_name: Display name for the role
            description: Role description
            is_system: Whether this is a system role
            priority: Role priority for hierarchy
            permissions: List of permission names to assign
            current_user: User creating the role

        Returns:
            Created role
        """
        try:
            # Check if role already exists
            existing = await self.get_role_by_name(name)
            if existing:
                raise ValueError(f"Role with name '{name}' already exists")

            # Create role
            role = Role(
                name=name,
                display_name=display_name,
                description=description,
                is_system=is_system,
                priority=priority,
                is_active=True
            )

            # Assign permissions if provided
            if permissions:
                perms = await self._get_permissions_by_names(permissions)
                role.permissions = perms

            self.db.add(role)
            await self.db.commit()
            await self.db.refresh(role)

            # Audit log
            if current_user:
                await self.audit_service.log_action(
                    user_id=current_user.id,
                    action="role.create",
                    resource_type="role",
                    resource_id=str(role.id),
                    details={"role_name": name}
                )

            logger.info(f"Created role: {name}")
            return role

        except IntegrityError as e:
            await self.db.rollback()
            logger.error(f"Database integrity error creating role: {str(e)}")
            raise ValueError("Failed to create role due to database constraint")
        except Exception as e:
            await self.db.rollback()
            logger.error(f"Error creating role: {str(e)}")
            raise

    async def get_role_by_id(self, role_id: UUID) -> Optional[Role]:
        """Get role by ID with permissions."""
        query = select(Role).options(
            selectinload(Role.permissions)
        ).where(Role.id == role_id)

        result = await self.db.execute(query)
        return result.scalar_one_or_none()

    async def get_role_by_name(self, name: str) -> Optional[Role]:
        """Get role by name with permissions."""
        query = select(Role).options(
            selectinload(Role.permissions)
        ).where(Role.name == name)

        result = await self.db.execute(query)
        return result.scalar_one_or_none()

    async def get_all_roles(
        self,
        skip: int = 0,
        limit: int = 100,
        include_inactive: bool = False
    ) -> List[Role]:
        """
        Get all roles with pagination.

        Args:
            skip: Number of records to skip
            limit: Maximum number of records to return
            include_inactive: Whether to include inactive roles

        Returns:
            List of roles
        """
        query = select(Role).options(
            selectinload(Role.permissions)
        ).order_by(Role.priority.desc(), Role.name)

        if not include_inactive:
            query = query.where(Role.is_active == True)

        query = query.offset(skip).limit(limit)

        result = await self.db.execute(query)
        return result.scalars().all()

    async def update_role(
        self,
        role_id: UUID,
        display_name: Optional[str] = None,
        description: Optional[str] = None,
        priority: Optional[int] = None,
        is_active: Optional[bool] = None,
        current_user: Optional[User] = None
    ) -> Role:
        """
        Update role information.

        Args:
            role_id: Role ID
            display_name: New display name
            description: New description
            priority: New priority
            is_active: Active status
            current_user: User performing the update

        Returns:
            Updated role
        """
        role = await self.get_role_by_id(role_id)
        if not role:
            raise ValueError(f"Role with ID {role_id} not found")

        if role.is_system:
            raise ValueError("Cannot modify system roles")

        # Update fields
        if display_name is not None:
            role.display_name = display_name
        if description is not None:
            role.description = description
        if priority is not None:
            role.priority = priority
        if is_active is not None:
            role.is_active = is_active

        role.updated_at = datetime.utcnow()

        await self.db.commit()
        await self.db.refresh(role)

        # Audit log
        if current_user:
            await self.audit_service.log_action(
                user_id=current_user.id,
                action="role.update",
                resource_type="role",
                resource_id=str(role_id),
                details={"changes": {
                    "display_name": display_name,
                    "description": description,
                    "priority": priority,
                    "is_active": is_active
                }}
            )

        return role

    async def delete_role(
        self,
        role_id: UUID,
        current_user: Optional[User] = None
    ) -> bool:
        """
        Delete a role.

        Args:
            role_id: Role ID
            current_user: User performing the deletion

        Returns:
            Success status
        """
        role = await self.get_role_by_id(role_id)
        if not role:
            raise ValueError(f"Role with ID {role_id} not found")

        if role.is_system:
            raise ValueError("Cannot delete system roles")

        # Check if role is assigned to users
        user_count = await self.db.scalar(
            select(func.count()).select_from(UserRole).where(
                UserRole.role_id == role_id
            )
        )

        if user_count > 0:
            raise ValueError(f"Cannot delete role assigned to {user_count} users")

        await self.db.delete(role)
        await self.db.commit()

        # Audit log
        if current_user:
            await self.audit_service.log_action(
                user_id=current_user.id,
                action="role.delete",
                resource_type="role",
                resource_id=str(role_id),
                details={"role_name": role.name}
            )

        logger.info(f"Deleted role: {role.name}")
        return True

    async def assign_permissions_to_role(
        self,
        role_id: UUID,
        permission_names: List[str],
        current_user: Optional[User] = None
    ) -> Role:
        """
        Assign permissions to a role.

        Args:
            role_id: Role ID
            permission_names: List of permission names
            current_user: User performing the assignment

        Returns:
            Updated role
        """
        role = await self.get_role_by_id(role_id)
        if not role:
            raise ValueError(f"Role with ID {role_id} not found")

        permissions = await self._get_permissions_by_names(permission_names)

        # Add permissions not already assigned
        for permission in permissions:
            if permission not in role.permissions:
                role.permissions.append(permission)

        await self.db.commit()
        await self.db.refresh(role)

        # Audit log
        if current_user:
            await self.audit_service.log_action(
                user_id=current_user.id,
                action="role.assign_permissions",
                resource_type="role",
                resource_id=str(role_id),
                details={"permissions": permission_names}
            )

        return role

    async def remove_permissions_from_role(
        self,
        role_id: UUID,
        permission_names: List[str],
        current_user: Optional[User] = None
    ) -> Role:
        """
        Remove permissions from a role.

        Args:
            role_id: Role ID
            permission_names: List of permission names
            current_user: User performing the removal

        Returns:
            Updated role
        """
        role = await self.get_role_by_id(role_id)
        if not role:
            raise ValueError(f"Role with ID {role_id} not found")

        permissions = await self._get_permissions_by_names(permission_names)

        # Remove permissions
        for permission in permissions:
            if permission in role.permissions:
                role.permissions.remove(permission)

        await self.db.commit()
        await self.db.refresh(role)

        # Audit log
        if current_user:
            await self.audit_service.log_action(
                user_id=current_user.id,
                action="role.remove_permissions",
                resource_type="role",
                resource_id=str(role_id),
                details={"permissions": permission_names}
            )

        return role

    async def assign_role_to_user(
        self,
        user_id: UUID,
        role_id: UUID,
        assigned_by: Optional[UUID] = None
    ) -> bool:
        """
        Assign a role to a user.

        Args:
            user_id: User ID
            role_id: Role ID
            assigned_by: ID of user assigning the role

        Returns:
            Success status
        """
        # Get user and role
        user_query = select(User).where(User.id == user_id)
        user_result = await self.db.execute(user_query)
        user = user_result.scalar_one_or_none()

        if not user:
            raise ValueError(f"User with ID {user_id} not found")

        role = await self.get_role_by_id(role_id)
        if not role:
            raise ValueError(f"Role with ID {role_id} not found")

        # Check if already assigned
        existing = await self.db.execute(
            select(UserRole).where(
                and_(
                    UserRole.user_id == user_id,
                    UserRole.role_id == role_id
                )
            )
        )

        if existing.first():
            return True  # Already assigned

        # Assign role
        user_role = UserRole(
            user_id=user_id,
            role_id=role_id,
            assigned_by=assigned_by
        )
        self.db.add(user_role)

        await self.db.commit()

        # Audit log
        if assigned_by:
            await self.audit_service.log_action(
                user_id=assigned_by,
                action="role.assign_to_user",
                resource_type="user",
                resource_id=str(user_id),
                details={"role_name": role.name}
            )

        logger.info(f"Assigned role {role.name} to user {user.email}")
        return True

    async def remove_role_from_user(
        self,
        user_id: UUID,
        role_id: UUID,
        removed_by: Optional[UUID] = None
    ) -> bool:
        """
        Remove a role from a user.

        Args:
            user_id: User ID
            role_id: Role ID
            removed_by: ID of user removing the role

        Returns:
            Success status
        """
        # Delete the assignment
        user_role = await self.db.execute(
            select(UserRole).where(
                and_(
                    UserRole.user_id == user_id,
                    UserRole.role_id == role_id
                )
            )
        )
        user_role_instance = user_role.scalar_one_or_none()

        if not user_role_instance:
            return False  # Was not assigned

        await self.db.delete(user_role_instance)
        await self.db.commit()

        # Audit log
        if removed_by:
            await self.audit_service.log_action(
                user_id=removed_by,
                action="role.remove_from_user",
                resource_type="user",
                resource_id=str(user_id),
                details={"role_id": str(role_id)}
            )

        return True

    async def get_user_roles(self, user_id: UUID) -> List[Role]:
        """Get all roles assigned to a user."""
        query = (
            select(Role)
            .options(selectinload(Role.permissions))
            .join(UserRole)
            .where(UserRole.user_id == user_id)
            .order_by(Role.priority.desc())
        )

        result = await self.db.execute(query)
        return result.scalars().all()

    async def get_users_with_role(
        self,
        role_id: UUID,
        skip: int = 0,
        limit: int = 100
    ) -> List[User]:
        """Get all users with a specific role."""
        query = (
            select(User)
            .join(UserRole)
            .where(UserRole.role_id == role_id)
            .offset(skip)
            .limit(limit)
        )

        result = await self.db.execute(query)
        return result.scalars().all()

    async def user_has_permission(
        self,
        user_id: UUID,
        permission_name: str
    ) -> bool:
        """
        Check if a user has a specific permission through their roles.

        Args:
            user_id: User ID
            permission_name: Permission name to check

        Returns:
            Whether user has the permission
        """
        roles = await self.get_user_roles(user_id)

        for role in roles:
            if role.has_permission(permission_name):
                return True

        return False

    async def initialize_system_roles(self) -> None:
        """Initialize system roles with default permissions."""
        try:
            # Create system roles if they don't exist
            for role_name in SystemRoles.get_all():
                existing = await self.get_role_by_name(role_name)
                if not existing:
                    display_name = role_name.replace("_", " ").title()

                    # Determine default permissions based on role
                    permissions = []
                    if role_name == SystemRoles.SUPER_ADMIN:
                        # Super admin gets all permissions
                        permissions = [p["name"] for p in SystemPermissions.get_all_permissions()]
                    elif role_name == SystemRoles.ADMIN:
                        # Admin gets most permissions except system-level ones
                        permissions = [
                            SystemPermissions.USER_CREATE,
                            SystemPermissions.USER_READ,
                            SystemPermissions.USER_UPDATE,
                            SystemPermissions.USER_DELETE,
                            SystemPermissions.USER_LIST,
                            SystemPermissions.ROLE_READ,
                            SystemPermissions.ROLE_LIST,
                            SystemPermissions.ROLE_ASSIGN,
                            SystemPermissions.ADMIN_ACCESS,
                            SystemPermissions.ADMIN_DASHBOARD,
                        ]
                    elif role_name == SystemRoles.USER:
                        # Regular users get basic permissions
                        permissions = [
                            SystemPermissions.USER_READ,
                            SystemPermissions.SESSION_READ,
                            SystemPermissions.SESSION_DELETE,
                        ]

                    await self.create_role(
                        name=role_name,
                        display_name=display_name,
                        description=f"System role: {display_name}",
                        is_system=True,
                        priority=100 if role_name == SystemRoles.SUPER_ADMIN else 50,
                        permissions=permissions
                    )

                    logger.info(f"Created system role: {role_name}")

        except Exception as e:
            logger.error(f"Error initializing system roles: {str(e)}")
            raise

    async def _get_permissions_by_names(self, names: List[str]) -> List[Permission]:
        """Get permissions by their names."""
        query = select(Permission).where(Permission.name.in_(names))
        result = await self.db.execute(query)
        return result.scalars().all()
