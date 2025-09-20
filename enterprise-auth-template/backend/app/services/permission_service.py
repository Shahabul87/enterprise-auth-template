"""
Permission Service for RBAC operations.
"""

from typing import List, Optional, Dict, Any
from uuid import UUID
from datetime import datetime
from sqlalchemy import select, and_, or_, func
from sqlalchemy.orm import selectinload
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.exc import IntegrityError

from app.models.permission import Permission, SystemPermissions
from app.models.role import Role
from app.services.audit_service import AuditService
from app.core.config import get_settings
import logging

logger = logging.getLogger(__name__)


class PermissionService:
    """Service for managing permissions."""

    def __init__(self, db: AsyncSession):
        """Initialize permission service."""
        self.db = db
        self.audit_service = AuditService(db)

    async def create_permission(
        self,
        name: str,
        display_name: str,
        resource: str,
        action: str,
        description: Optional[str] = None,
        scope: Optional[str] = None,
        is_system: bool = False,
        current_user: Optional[Any] = None,
    ) -> Permission:
        """
        Create a new permission.

        Args:
            name: Unique permission name
            display_name: Display name for the permission
            resource: Resource this permission applies to
            action: Action this permission allows
            description: Permission description
            scope: Permission scope (own, team, all)
            is_system: Whether this is a system permission
            current_user: User creating the permission

        Returns:
            Created permission
        """
        try:
            # Check if permission already exists
            existing = await self.get_permission_by_name(name)
            if existing:
                raise ValueError(f"Permission with name '{name}' already exists")

            # Create permission
            permission = Permission(
                name=name,
                display_name=display_name,
                description=description,
                resource=resource,
                action=action,
                scope=scope,
                is_system=is_system,
                is_active=True,
            )

            self.db.add(permission)
            await self.db.commit()
            await self.db.refresh(permission)

            # Audit log
            if current_user:
                await self.audit_service.log_action(
                    user_id=current_user.id,
                    action="permission.create",
                    resource_type="permission",
                    resource_id=str(permission.id),
                    details={"permission_name": name},
                )

            logger.info(f"Created permission: {name}")
            return permission

        except IntegrityError as e:
            await self.db.rollback()
            logger.error(f"Database integrity error creating permission: {str(e)}")
            raise ValueError("Failed to create permission due to database constraint")
        except Exception as e:
            await self.db.rollback()
            logger.error(f"Error creating permission: {str(e)}")
            raise

    async def get_permission_by_id(self, permission_id: UUID) -> Optional[Permission]:
        """Get permission by ID."""
        query = select(Permission).where(Permission.id == permission_id)
        result = await self.db.execute(query)
        return result.scalar_one_or_none()

    async def get_permission_by_name(self, name: str) -> Optional[Permission]:
        """Get permission by name."""
        query = select(Permission).where(Permission.name == name)
        result = await self.db.execute(query)
        return result.scalar_one_or_none()

    async def get_permissions_by_resource(
        self, resource: str, include_inactive: bool = False
    ) -> List[Permission]:
        """Get all permissions for a specific resource."""
        query = select(Permission).where(Permission.resource == resource)

        if not include_inactive:
            query = query.where(Permission.is_active == True)

        query = query.order_by(Permission.action)

        result = await self.db.execute(query)
        return result.scalars().all()

    async def get_permissions_by_action(
        self, action: str, include_inactive: bool = False
    ) -> List[Permission]:
        """Get all permissions for a specific action."""
        query = select(Permission).where(Permission.action == action)

        if not include_inactive:
            query = query.where(Permission.is_active == True)

        query = query.order_by(Permission.resource)

        result = await self.db.execute(query)
        return result.scalars().all()

    async def get_all_permissions(
        self,
        skip: int = 0,
        limit: int = 100,
        include_inactive: bool = False,
        resource_filter: Optional[str] = None,
        action_filter: Optional[str] = None,
    ) -> List[Permission]:
        """
        Get all permissions with pagination and filters.

        Args:
            skip: Number of records to skip
            limit: Maximum number of records to return
            include_inactive: Whether to include inactive permissions
            resource_filter: Filter by resource
            action_filter: Filter by action

        Returns:
            List of permissions
        """
        query = select(Permission).order_by(Permission.resource, Permission.action)

        if not include_inactive:
            query = query.where(Permission.is_active == True)

        if resource_filter:
            query = query.where(Permission.resource == resource_filter)

        if action_filter:
            query = query.where(Permission.action == action_filter)

        query = query.offset(skip).limit(limit)

        result = await self.db.execute(query)
        return result.scalars().all()

    async def update_permission(
        self,
        permission_id: UUID,
        display_name: Optional[str] = None,
        description: Optional[str] = None,
        scope: Optional[str] = None,
        is_active: Optional[bool] = None,
        current_user: Optional[Any] = None,
    ) -> Permission:
        """
        Update permission information.

        Args:
            permission_id: Permission ID
            display_name: New display name
            description: New description
            scope: New scope
            is_active: Active status
            current_user: User performing the update

        Returns:
            Updated permission
        """
        permission = await self.get_permission_by_id(permission_id)
        if not permission:
            raise ValueError(f"Permission with ID {permission_id} not found")

        if permission.is_system:
            raise ValueError("Cannot modify system permissions")

        # Update fields
        if display_name is not None:
            permission.display_name = display_name
        if description is not None:
            permission.description = description
        if scope is not None:
            permission.scope = scope
        if is_active is not None:
            permission.is_active = is_active

        permission.updated_at = datetime.utcnow()

        await self.db.commit()
        await self.db.refresh(permission)

        # Audit log
        if current_user:
            await self.audit_service.log_action(
                user_id=current_user.id,
                action="permission.update",
                resource_type="permission",
                resource_id=str(permission_id),
                details={
                    "changes": {
                        "display_name": display_name,
                        "description": description,
                        "scope": scope,
                        "is_active": is_active,
                    }
                },
            )

        return permission

    async def delete_permission(
        self, permission_id: UUID, current_user: Optional[Any] = None
    ) -> bool:
        """
        Delete a permission.

        Args:
            permission_id: Permission ID
            current_user: User performing the deletion

        Returns:
            Success status
        """
        permission = await self.get_permission_by_id(permission_id)
        if not permission:
            raise ValueError(f"Permission with ID {permission_id} not found")

        if permission.is_system:
            raise ValueError("Cannot delete system permissions")

        # Check if permission is assigned to any roles
        query = (
            select(Role).join(Role.permissions).where(Permission.id == permission_id)
        )
        result = await self.db.execute(query)
        roles = result.scalars().all()

        if roles:
            role_names = [r.name for r in roles]
            raise ValueError(
                f"Cannot delete permission assigned to roles: {', '.join(role_names)}"
            )

        await self.db.delete(permission)
        await self.db.commit()

        # Audit log
        if current_user:
            await self.audit_service.log_action(
                user_id=current_user.id,
                action="permission.delete",
                resource_type="permission",
                resource_id=str(permission_id),
                details={"permission_name": permission.name},
            )

        logger.info(f"Deleted permission: {permission.name}")
        return True

    async def get_roles_with_permission(self, permission_id: UUID) -> List[Role]:
        """Get all roles that have a specific permission."""
        query = (
            select(Role)
            .options(selectinload(Role.permissions))
            .join(Role.permissions)
            .where(Permission.id == permission_id)
        )

        result = await self.db.execute(query)
        return result.scalars().all()

    async def get_grouped_permissions(self) -> Dict[str, List[Dict[str, Any]]]:
        """
        Get permissions grouped by resource.

        Returns:
            Dictionary with resources as keys and lists of permissions as values
        """
        permissions = await self.get_all_permissions(limit=1000)

        grouped = {}
        for perm in permissions:
            if perm.resource not in grouped:
                grouped[perm.resource] = []

            grouped[perm.resource].append(
                {
                    "id": str(perm.id),
                    "name": perm.name,
                    "display_name": perm.display_name,
                    "action": perm.action,
                    "scope": perm.scope,
                    "description": perm.description,
                    "is_system": perm.is_system,
                    "is_active": perm.is_active,
                }
            )

        return grouped

    async def initialize_system_permissions(self) -> None:
        """Initialize system permissions."""
        try:
            # Get all system permissions
            system_perms = SystemPermissions.get_all_permissions()

            for perm_data in system_perms:
                existing = await self.get_permission_by_name(perm_data["name"])
                if not existing:
                    await self.create_permission(
                        name=perm_data["name"],
                        display_name=perm_data["display_name"],
                        resource=perm_data["resource"],
                        action=perm_data["action"],
                        description=f"System permission: {perm_data['display_name']}",
                        is_system=True,
                    )
                    logger.info(f"Created system permission: {perm_data['name']}")

        except Exception as e:
            logger.error(f"Error initializing system permissions: {str(e)}")
            raise

    async def check_permission_consistency(self) -> Dict[str, Any]:
        """
        Check for permission consistency issues.

        Returns:
            Dictionary with consistency check results
        """
        issues = []

        # Check for duplicate names
        query = (
            select(Permission.name, func.count(Permission.id).label("count"))
            .group_by(Permission.name)
            .having(func.count(Permission.id) > 1)
        )

        result = await self.db.execute(query)
        duplicates = result.all()

        if duplicates:
            issues.append(
                {
                    "type": "duplicate_names",
                    "permissions": [
                        {"name": d.name, "count": d.count} for d in duplicates
                    ],
                }
            )

        # Check for orphaned permissions (not assigned to any role)
        all_perms = await self.get_all_permissions(limit=1000, include_inactive=True)
        orphaned = []

        for perm in all_perms:
            roles = await self.get_roles_with_permission(perm.id)
            if not roles and not perm.is_system:
                orphaned.append(perm.name)

        if orphaned:
            issues.append({"type": "orphaned_permissions", "permissions": orphaned})

        return {
            "has_issues": len(issues) > 0,
            "issues": issues,
            "checked_at": datetime.utcnow().isoformat(),
        }
