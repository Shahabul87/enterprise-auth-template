"""
Role management service for RBAC system.

This service handles all role-related operations including CRUD operations,
role assignment, permission management, and business logic validation.
"""
import json
import logging
from typing import List, Optional, Dict, Any, Tuple
from uuid import UUID
from datetime import datetime, timedelta
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_, or_, delete, func, update, desc, asc
from sqlalchemy.orm import selectinload, joinedload
from sqlalchemy.exc import IntegrityError
import redis.asyncio as redis

from app.models.role import Role, user_roles, role_permissions
from app.models.permission import Permission
from app.models.user import User
from app.models.organization import Organization
from app.core.exceptions import (
    ResourceNotFoundException,
    ValidationException,
    ConflictException,
    BusinessLogicException,
    AuthorizationException,
    DatabaseException
)
from app.core.events import EventEmitter
from app.core.constants import (
    ROLE_CACHE_TTL,
    MAX_ROLES_PER_USER,
    SYSTEM_ROLES,
    ROLE_HIERARCHY_LEVELS
)

logger = logging.getLogger(__name__)


class RoleService:
    """Service for managing roles and role assignments."""
    
    def __init__(self, db: AsyncSession, redis_client: Optional[redis.Redis] = None, event_emitter: Optional[EventEmitter] = None):
        """
        Initialize role service.
        
        Args:
            db: Database session
            redis_client: Redis client for caching
            event_emitter: Event emitter for audit logging
        """
        self.db = db
        self.redis = redis_client
        self.event_emitter = event_emitter
    
    # CRUD Operations
    
    async def create_role(
        self,
        name: str,
        display_name: str,
        description: Optional[str] = None,
        role_type: str = "custom",
        parent_role_id: Optional[UUID] = None,
        organization_id: Optional[UUID] = None,
        permissions: Optional[List[UUID]] = None,
        max_users: Optional[int] = None,
        priority: int = 0,
        metadata: Optional[Dict[str, Any]] = None,
        created_by: Optional[UUID] = None
    ) -> Role:
        """
        Create a new role.
        
        Args:
            name: Unique role name
            display_name: Human-readable display name
            description: Role description
            role_type: Type of role (system, organization, custom)
            parent_role_id: Parent role for inheritance
            organization_id: Organization this role belongs to
            permissions: List of permission IDs to assign
            max_users: Maximum users that can have this role
            priority: Role priority for conflict resolution
            metadata: Additional metadata
            created_by: User creating the role
            
        Returns:
            Created Role instance
            
        Raises:
            ValidationException: If validation fails
            ConflictException: If role name already exists
            DatabaseException: If database operation fails
        """
        try:
            # Validate role name uniqueness in scope
            existing_role = await self._get_role_by_name(name, organization_id)
            if existing_role:
                raise ConflictException(
                    f"Role with name '{name}' already exists",
                    {"name": name, "organization_id": str(organization_id) if organization_id else None}
                )
            
            # Validate parent role exists and hierarchy
            parent_role = None
            hierarchy_level = 0
            if parent_role_id:
                parent_role = await self.get_role_by_id(parent_role_id)
                if not parent_role:
                    raise ValidationException("Parent role not found", {"parent_role_id": str(parent_role_id)})
                hierarchy_level = parent_role.hierarchy_level + 1
                
                # Prevent circular dependencies
                if await self._would_create_circular_dependency(parent_role_id, None):
                    raise ValidationException("Would create circular dependency", {"parent_role_id": str(parent_role_id)})
            
            # Validate organization exists if specified
            if organization_id:
                org_query = select(Organization).where(Organization.id == organization_id)
                org_result = await self.db.execute(org_query)
                if not org_result.scalar_one_or_none():
                    raise ValidationException("Organization not found", {"organization_id": str(organization_id)})
            
            # Create role
            role_data = {
                "name": name,
                "display_name": display_name,
                "description": description,
                "role_type": role_type,
                "parent_role_id": parent_role_id,
                "hierarchy_level": hierarchy_level,
                "organization_id": organization_id,
                "max_users": max_users,
                "priority": priority,
                "metadata_json": json.dumps(metadata) if metadata else None,
                "created_by": created_by,
                "is_system": role_type == "system",
                "is_assignable": True
            }
            
            role = Role(**role_data)
            self.db.add(role)
            await self.db.flush()  # Get the ID
            
            # Assign permissions if provided
            if permissions:
                await self._assign_permissions_to_role(role.id, permissions)
            
            await self.db.commit()
            
            # Clear cache
            await self._clear_role_cache(role.id)
            
            # Emit event
            if self.event_emitter:
                await self.event_emitter.emit("role.created", {
                    "role_id": str(role.id),
                    "name": name,
                    "role_type": role_type,
                    "created_by": str(created_by) if created_by else None,
                    "organization_id": str(organization_id) if organization_id else None
                })
            
            logger.info(f"Role created: {name} (ID: {role.id})")
            return role
            
        except IntegrityError as e:
            await self.db.rollback()
            logger.error(f"Integrity error creating role {name}: {e}")
            raise ConflictException("Role creation failed due to constraint violation")
        except Exception as e:
            await self.db.rollback()
            logger.error(f"Error creating role {name}: {e}")
            raise DatabaseException("Failed to create role")
    
    async def get_role_by_id(
        self,
        role_id: UUID,
        include_permissions: bool = False,
        include_users: bool = False,
        use_cache: bool = True
    ) -> Optional[Role]:
        """
        Get role by ID.
        
        Args:
            role_id: Role ID
            include_permissions: Include role permissions
            include_users: Include role users
            use_cache: Use Redis cache if available
            
        Returns:
            Role instance or None if not found
        """
        # Try cache first
        if use_cache and self.redis:
            cache_key = f"role:{role_id}"
            cached_data = await self.redis.get(cache_key)
            if cached_data:
                # Note: Cached data might not include relationships
                # For full data with relationships, skip cache
                if not include_permissions and not include_users:
                    try:
                        role_dict = json.loads(cached_data)
                        # Return a basic role object from cache
                        # In production, you might want to reconstruct the full object
                        pass
                    except (json.JSONDecodeError, KeyError):
                        pass
        
        try:
            query = select(Role).where(Role.id == role_id)
            
            if include_permissions:
                query = query.options(selectinload(Role.permissions))
            if include_users:
                query = query.options(selectinload(Role.users))
            
            result = await self.db.execute(query)
            role = result.scalar_one_or_none()
            
            # Cache the result
            if role and use_cache and self.redis and not include_permissions and not include_users:
                cache_data = {
                    "id": str(role.id),
                    "name": role.name,
                    "display_name": role.display_name,
                    "role_type": role.role_type,
                    "is_active": role.is_active,
                    "hierarchy_level": role.hierarchy_level
                }
                await self.redis.setex(
                    f"role:{role_id}",
                    ROLE_CACHE_TTL,
                    json.dumps(cache_data, default=str)
                )
            
            return role
            
        except Exception as e:
            logger.error(f"Error fetching role {role_id}: {e}")
            return None
    
    async def get_role_by_name(
        self,
        name: str,
        organization_id: Optional[UUID] = None,
        include_permissions: bool = False
    ) -> Optional[Role]:
        """
        Get role by name and optional organization.
        
        Args:
            name: Role name
            organization_id: Organization ID (None for global roles)
            include_permissions: Include role permissions
            
        Returns:
            Role instance or None if not found
        """
        return await self._get_role_by_name(name, organization_id, include_permissions)
    
    async def list_roles(
        self,
        skip: int = 0,
        limit: int = 100,
        role_type: Optional[str] = None,
        organization_id: Optional[UUID] = None,
        is_active: Optional[bool] = None,
        search: Optional[str] = None,
        sort_by: str = "created_at",
        sort_order: str = "desc",
        include_permissions: bool = False
    ) -> Tuple[List[Role], int]:
        """
        List roles with filtering and pagination.
        
        Args:
            skip: Number of records to skip
            limit: Maximum number of records to return
            role_type: Filter by role type
            organization_id: Filter by organization
            is_active: Filter by active status
            search: Search in name and description
            sort_by: Field to sort by
            sort_order: Sort order (asc/desc)
            include_permissions: Include permissions in results
            
        Returns:
            Tuple of (roles list, total count)
        """
        try:
            # Base query
            query = select(Role)
            count_query = select(func.count(Role.id))
            
            # Filters
            filters = []
            
            if role_type:
                filters.append(Role.role_type == role_type)
            
            if organization_id is not None:
                filters.append(Role.organization_id == organization_id)
            
            if is_active is not None:
                filters.append(Role.is_active == is_active)
            
            if search:
                search_filter = or_(
                    Role.name.ilike(f"%{search}%"),
                    Role.display_name.ilike(f"%{search}%"),
                    Role.description.ilike(f"%{search}%")
                )
                filters.append(search_filter)
            
            if filters:
                query = query.where(and_(*filters))
                count_query = count_query.where(and_(*filters))
            
            # Include permissions if requested
            if include_permissions:
                query = query.options(selectinload(Role.permissions))
            
            # Sorting
            sort_column = getattr(Role, sort_by, Role.created_at)
            if sort_order.lower() == "desc":
                query = query.order_by(desc(sort_column))
            else:
                query = query.order_by(asc(sort_column))
            
            # Pagination
            query = query.offset(skip).limit(limit)
            
            # Execute queries
            result = await self.db.execute(query)
            roles = result.scalars().all()
            
            count_result = await self.db.execute(count_query)
            total_count = count_result.scalar()
            
            return list(roles), total_count
            
        except Exception as e:
            logger.error(f"Error listing roles: {e}")
            raise DatabaseException("Failed to list roles")
    
    async def update_role(
        self,
        role_id: UUID,
        update_data: Dict[str, Any],
        updated_by: Optional[UUID] = None
    ) -> Role:
        """
        Update role information.
        
        Args:
            role_id: Role ID to update
            update_data: Fields to update
            updated_by: User performing the update
            
        Returns:
            Updated Role instance
            
        Raises:
            ResourceNotFoundException: If role not found
            ValidationException: If validation fails
            ConflictException: If update would create conflict
        """
        try:
            role = await self.get_role_by_id(role_id)
            if not role:
                raise ResourceNotFoundException("Role", role_id)
            
            # Prevent modification of system roles
            if role.is_system and "name" in update_data:
                raise ValidationException("Cannot modify system role name", {"role_id": str(role_id)})
            
            # Validate name uniqueness if changing name
            if "name" in update_data and update_data["name"] != role.name:
                existing = await self._get_role_by_name(update_data["name"], role.organization_id)
                if existing and existing.id != role_id:
                    raise ConflictException(
                        f"Role with name '{update_data['name']}' already exists",
                        {"name": update_data["name"]}
                    )
            
            # Validate parent role changes
            if "parent_role_id" in update_data:
                new_parent_id = update_data["parent_role_id"]
                if new_parent_id and new_parent_id != role.parent_role_id:
                    # Check if new parent exists
                    parent_role = await self.get_role_by_id(new_parent_id)
                    if not parent_role:
                        raise ValidationException("Parent role not found", {"parent_role_id": str(new_parent_id)})
                    
                    # Check for circular dependency
                    if await self._would_create_circular_dependency(new_parent_id, role_id):
                        raise ValidationException(
                            "Would create circular dependency",
                            {"parent_role_id": str(new_parent_id), "role_id": str(role_id)}
                        )
                    
                    # Update hierarchy level
                    update_data["hierarchy_level"] = parent_role.hierarchy_level + 1
            
            # Handle metadata
            if "metadata" in update_data:
                update_data["metadata_json"] = json.dumps(update_data.pop("metadata"))
            
            # Set updated timestamp and user
            update_data["updated_at"] = datetime.utcnow()
            if updated_by:
                update_data["updated_by"] = updated_by
            
            # Update role
            for key, value in update_data.items():
                if hasattr(role, key):
                    setattr(role, key, value)
            
            await self.db.commit()
            
            # Clear cache
            await self._clear_role_cache(role_id)
            
            # Emit event
            if self.event_emitter:
                await self.event_emitter.emit("role.updated", {
                    "role_id": str(role_id),
                    "updated_fields": list(update_data.keys()),
                    "updated_by": str(updated_by) if updated_by else None
                })
            
            logger.info(f"Role updated: {role.name} (ID: {role_id})")
            return role
            
        except Exception as e:
            await self.db.rollback()
            logger.error(f"Error updating role {role_id}: {e}")
            if isinstance(e, (ResourceNotFoundException, ValidationException, ConflictException)):
                raise
            raise DatabaseException("Failed to update role")
    
    async def delete_role(
        self,
        role_id: UUID,
        deleted_by: Optional[UUID] = None,
        force: bool = False
    ) -> bool:
        """
        Delete a role.
        
        Args:
            role_id: Role ID to delete
            deleted_by: User performing the deletion
            force: Force deletion even if role has users
            
        Returns:
            True if deleted successfully
            
        Raises:
            ResourceNotFoundException: If role not found
            BusinessLogicException: If role cannot be deleted
        """
        try:
            role = await self.get_role_by_id(role_id, include_users=True)
            if not role:
                raise ResourceNotFoundException("Role", role_id)
            
            # Prevent deletion of system roles
            if role.is_system:
                raise BusinessLogicException(
                    "Cannot delete system role",
                    {"role_id": str(role_id), "role_name": role.name}
                )
            
            # Check if role has users assigned
            if role.users and not force:
                raise BusinessLogicException(
                    f"Cannot delete role with {len(role.users)} assigned users. Use force=True to override.",
                    {"role_id": str(role_id), "user_count": len(role.users)}
                )
            
            # Check if role is a parent to other roles
            child_roles_query = select(func.count(Role.id)).where(Role.parent_role_id == role_id)
            child_count_result = await self.db.execute(child_roles_query)
            child_count = child_count_result.scalar()
            
            if child_count > 0:
                raise BusinessLogicException(
                    f"Cannot delete role that is parent to {child_count} other roles",
                    {"role_id": str(role_id), "child_count": child_count}
                )
            
            # Remove all user assignments
            if role.users:
                for user in role.users:
                    await self._remove_user_from_role(user.id, role_id, deleted_by)
            
            # Delete the role
            await self.db.delete(role)
            await self.db.commit()
            
            # Clear cache
            await self._clear_role_cache(role_id)
            
            # Emit event
            if self.event_emitter:
                await self.event_emitter.emit("role.deleted", {
                    "role_id": str(role_id),
                    "role_name": role.name,
                    "deleted_by": str(deleted_by) if deleted_by else None,
                    "force": force
                })
            
            logger.info(f"Role deleted: {role.name} (ID: {role_id})")
            return True
            
        except Exception as e:
            await self.db.rollback()
            logger.error(f"Error deleting role {role_id}: {e}")
            if isinstance(e, (ResourceNotFoundException, BusinessLogicException)):
                raise
            raise DatabaseException("Failed to delete role")
    
    # Role Assignment Operations
    
    async def assign_role_to_user(
        self,
        user_id: UUID,
        role_id: UUID,
        assigned_by: Optional[UUID] = None,
        expires_at: Optional[datetime] = None
    ) -> bool:
        """
        Assign a role to a user.
        
        Args:
            user_id: User ID
            role_id: Role ID
            assigned_by: User performing the assignment
            expires_at: When the assignment expires
            
        Returns:
            True if assigned successfully
            
        Raises:
            ResourceNotFoundException: If user or role not found
            BusinessLogicException: If assignment is not allowed
        """
        try:
            # Validate user exists
            user_query = select(User).where(User.id == user_id)
            user_result = await self.db.execute(user_query)
            user = user_result.scalar_one_or_none()
            if not user:
                raise ResourceNotFoundException("User", user_id)
            
            # Validate role exists and is assignable
            role = await self.get_role_by_id(role_id, include_users=True)
            if not role:
                raise ResourceNotFoundException("Role", role_id)
            
            if not role.is_assignable:
                raise BusinessLogicException(
                    "Role is not assignable",
                    {"role_id": str(role_id), "role_name": role.name}
                )
            
            if not role.is_active:
                raise BusinessLogicException(
                    "Cannot assign inactive role",
                    {"role_id": str(role_id), "role_name": role.name}
                )
            
            # Check if role is full
            if role.is_full:
                raise BusinessLogicException(
                    f"Role has reached maximum user limit of {role.max_users}",
                    {"role_id": str(role_id), "max_users": role.max_users}
                )
            
            # Check if user already has this role
            if user in role.users:
                return True  # Already assigned
            
            # Check user role limit
            user_role_count_query = select(func.count()).select_from(user_roles).where(user_roles.c.user_id == user_id)
            user_role_count_result = await self.db.execute(user_role_count_query)
            user_role_count = user_role_count_result.scalar()
            
            if user_role_count >= MAX_ROLES_PER_USER:
                raise BusinessLogicException(
                    f"User has reached maximum role limit of {MAX_ROLES_PER_USER}",
                    {"user_id": str(user_id), "current_roles": user_role_count}
                )
            
            # Add user to role
            role.users.append(user)
            
            # Update the association table with metadata
            stmt = update(user_roles).where(
                and_(user_roles.c.user_id == user_id, user_roles.c.role_id == role_id)
            ).values(
                assigned_by=assigned_by,
                expires_at=expires_at,
                assigned_at=datetime.utcnow()
            )
            await self.db.execute(stmt)
            
            await self.db.commit()
            
            # Clear cache
            await self._clear_role_cache(role_id)
            await self._clear_user_roles_cache(user_id)
            
            # Emit event
            if self.event_emitter:
                await self.event_emitter.emit("role.assigned", {
                    "user_id": str(user_id),
                    "role_id": str(role_id),
                    "role_name": role.name,
                    "assigned_by": str(assigned_by) if assigned_by else None,
                    "expires_at": expires_at.isoformat() if expires_at else None
                })
            
            logger.info(f"Role {role.name} assigned to user {user_id}")
            return True
            
        except Exception as e:
            await self.db.rollback()
            logger.error(f"Error assigning role {role_id} to user {user_id}: {e}")
            if isinstance(e, (ResourceNotFoundException, BusinessLogicException)):
                raise
            raise DatabaseException("Failed to assign role")
    
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
            removed_by: User performing the removal
            
        Returns:
            True if removed successfully
        """
        return await self._remove_user_from_role(user_id, role_id, removed_by)
    
    async def bulk_assign_roles(
        self,
        assignments: List[Dict[str, Any]],
        assigned_by: Optional[UUID] = None
    ) -> Dict[str, Any]:
        """
        Bulk assign roles to users.
        
        Args:
            assignments: List of assignment dictionaries
            assigned_by: User performing the assignments
            
        Returns:
            Dictionary with success/failure counts and details
        """
        results = {
            "success_count": 0,
            "error_count": 0,
            "errors": []
        }
        
        for assignment in assignments:
            try:
                user_id = UUID(assignment["user_id"])
                role_id = UUID(assignment["role_id"])
                expires_at = assignment.get("expires_at")
                if expires_at and isinstance(expires_at, str):
                    expires_at = datetime.fromisoformat(expires_at)
                
                await self.assign_role_to_user(user_id, role_id, assigned_by, expires_at)
                results["success_count"] += 1
                
            except Exception as e:
                results["error_count"] += 1
                results["errors"].append({
                    "assignment": assignment,
                    "error": str(e)
                })
                logger.error(f"Bulk assignment failed for {assignment}: {e}")
        
        return results
    
    # Permission Management
    
    async def add_permission_to_role(
        self,
        role_id: UUID,
        permission_id: UUID,
        granted_by: Optional[UUID] = None
    ) -> bool:
        """
        Add a permission to a role.
        
        Args:
            role_id: Role ID
            permission_id: Permission ID
            granted_by: User granting the permission
            
        Returns:
            True if added successfully
        """
        try:
            # Validate role and permission exist
            role = await self.get_role_by_id(role_id, include_permissions=True)
            if not role:
                raise ResourceNotFoundException("Role", role_id)
            
            permission_query = select(Permission).where(Permission.id == permission_id)
            permission_result = await self.db.execute(permission_query)
            permission = permission_result.scalar_one_or_none()
            if not permission:
                raise ResourceNotFoundException("Permission", permission_id)
            
            # Check if permission already assigned
            if permission in role.permissions:
                return True  # Already assigned
            
            # Add permission to role
            role.permissions.append(permission)
            
            # Update the association table with metadata
            stmt = update(role_permissions).where(
                and_(role_permissions.c.role_id == role_id, role_permissions.c.permission_id == permission_id)
            ).values(
                granted_by=granted_by,
                granted_at=datetime.utcnow()
            )
            await self.db.execute(stmt)
            
            await self.db.commit()
            
            # Clear cache
            await self._clear_role_cache(role_id)
            
            # Emit event
            if self.event_emitter:
                await self.event_emitter.emit("permission.granted.role", {
                    "role_id": str(role_id),
                    "role_name": role.name,
                    "permission_id": str(permission_id),
                    "permission_code": permission.code,
                    "granted_by": str(granted_by) if granted_by else None
                })
            
            logger.info(f"Permission {permission.code} added to role {role.name}")
            return True
            
        except Exception as e:
            await self.db.rollback()
            logger.error(f"Error adding permission {permission_id} to role {role_id}: {e}")
            if isinstance(e, ResourceNotFoundException):
                raise
            raise DatabaseException("Failed to add permission to role")
    
    async def remove_permission_from_role(
        self,
        role_id: UUID,
        permission_id: UUID,
        revoked_by: Optional[UUID] = None
    ) -> bool:
        """
        Remove a permission from a role.
        
        Args:
            role_id: Role ID
            permission_id: Permission ID
            revoked_by: User revoking the permission
            
        Returns:
            True if removed successfully
        """
        try:
            role = await self.get_role_by_id(role_id, include_permissions=True)
            if not role:
                raise ResourceNotFoundException("Role", role_id)
            
            permission_query = select(Permission).where(Permission.id == permission_id)
            permission_result = await self.db.execute(permission_query)
            permission = permission_result.scalar_one_or_none()
            if not permission:
                raise ResourceNotFoundException("Permission", permission_id)
            
            # Remove permission from role
            if permission in role.permissions:
                role.permissions.remove(permission)
                await self.db.commit()
                
                # Clear cache
                await self._clear_role_cache(role_id)
                
                # Emit event
                if self.event_emitter:
                    await self.event_emitter.emit("permission.revoked.role", {
                        "role_id": str(role_id),
                        "role_name": role.name,
                        "permission_id": str(permission_id),
                        "permission_code": permission.code,
                        "revoked_by": str(revoked_by) if revoked_by else None
                    })
                
                logger.info(f"Permission {permission.code} removed from role {role.name}")
            
            return True
            
        except Exception as e:
            await self.db.rollback()
            logger.error(f"Error removing permission {permission_id} from role {role_id}: {e}")
            if isinstance(e, ResourceNotFoundException):
                raise
            raise DatabaseException("Failed to remove permission from role")
    
    # Query Operations
    
    async def get_user_roles(
        self,
        user_id: UUID,
        include_permissions: bool = False,
        include_inherited: bool = True
    ) -> List[Role]:
        """
        Get all roles assigned to a user.
        
        Args:
            user_id: User ID
            include_permissions: Include role permissions
            include_inherited: Include inherited permissions from parent roles
            
        Returns:
            List of Role instances
        """
        try:
            query = (
                select(Role)
                .join(user_roles)
                .where(user_roles.c.user_id == user_id)
                .where(Role.is_active == True)
            )
            
            if include_permissions:
                query = query.options(selectinload(Role.permissions))
            
            result = await self.db.execute(query)
            roles = list(result.scalars().all())
            
            # Add inherited permissions if requested
            if include_permissions and include_inherited:
                for role in roles:
                    role._inherited_permissions = role.inherited_permissions
            
            return roles
            
        except Exception as e:
            logger.error(f"Error getting user roles for {user_id}: {e}")
            return []
    
    async def get_role_users(
        self,
        role_id: UUID,
        skip: int = 0,
        limit: int = 100
    ) -> Tuple[List[User], int]:
        """
        Get users assigned to a role.
        
        Args:
            role_id: Role ID
            skip: Number of records to skip
            limit: Maximum number of records to return
            
        Returns:
            Tuple of (users list, total count)
        """
        try:
            # Count query
            count_query = select(func.count()).select_from(user_roles).where(user_roles.c.role_id == role_id)
            count_result = await self.db.execute(count_query)
            total_count = count_result.scalar()
            
            # Users query
            query = (
                select(User)
                .join(user_roles)
                .where(user_roles.c.role_id == role_id)
                .offset(skip)
                .limit(limit)
            )
            
            result = await self.db.execute(query)
            users = list(result.scalars().all())
            
            return users, total_count
            
        except Exception as e:
            logger.error(f"Error getting role users for {role_id}: {e}")
            return [], 0
    
    async def check_user_has_role(
        self,
        user_id: UUID,
        role_name: str,
        organization_id: Optional[UUID] = None
    ) -> bool:
        """
        Check if user has a specific role.
        
        Args:
            user_id: User ID
            role_name: Role name to check
            organization_id: Organization context
            
        Returns:
            True if user has the role
        """
        try:
            query = (
                select(func.count())
                .select_from(user_roles.join(Role))
                .where(
                    and_(
                        user_roles.c.user_id == user_id,
                        Role.name == role_name,
                        Role.is_active == True,
                        Role.organization_id == organization_id
                    )
                )
            )
            
            result = await self.db.execute(query)
            count = result.scalar()
            
            return count > 0
            
        except Exception as e:
            logger.error(f"Error checking user role {user_id}/{role_name}: {e}")
            return False
    
    # Clone and Template Operations
    
    async def clone_role(
        self,
        role_id: UUID,
        new_name: str,
        new_display_name: Optional[str] = None,
        organization_id: Optional[UUID] = None,
        created_by: Optional[UUID] = None
    ) -> Role:
        """
        Clone an existing role.
        
        Args:
            role_id: Role ID to clone
            new_name: New role name
            new_display_name: New display name
            organization_id: Target organization
            created_by: User creating the clone
            
        Returns:
            Cloned Role instance
        """
        try:
            original_role = await self.get_role_by_id(role_id, include_permissions=True)
            if not original_role:
                raise ResourceNotFoundException("Role", role_id)
            
            # Clone the role
            cloned_role = original_role.clone(new_name, organization_id)
            if new_display_name:
                cloned_role.display_name = new_display_name
            if created_by:
                cloned_role.created_by = created_by
            
            self.db.add(cloned_role)
            await self.db.commit()
            
            # Emit event
            if self.event_emitter:
                await self.event_emitter.emit("role.cloned", {
                    "original_role_id": str(role_id),
                    "cloned_role_id": str(cloned_role.id),
                    "new_name": new_name,
                    "created_by": str(created_by) if created_by else None
                })
            
            logger.info(f"Role cloned: {original_role.name} -> {new_name}")
            return cloned_role
            
        except Exception as e:
            await self.db.rollback()
            logger.error(f"Error cloning role {role_id}: {e}")
            if isinstance(e, ResourceNotFoundException):
                raise
            raise DatabaseException("Failed to clone role")
    
    # Helper Methods
    
    async def _get_role_by_name(
        self,
        name: str,
        organization_id: Optional[UUID] = None,
        include_permissions: bool = False
    ) -> Optional[Role]:
        """Get role by name within organization scope."""
        try:
            query = select(Role).where(
                and_(
                    Role.name == name,
                    Role.organization_id == organization_id
                )
            )
            
            if include_permissions:
                query = query.options(selectinload(Role.permissions))
            
            result = await self.db.execute(query)
            return result.scalar_one_or_none()
            
        except Exception as e:
            logger.error(f"Error getting role by name {name}: {e}")
            return None
    
    async def _assign_permissions_to_role(self, role_id: UUID, permission_ids: List[UUID]) -> None:
        """Assign multiple permissions to a role."""
        for permission_id in permission_ids:
            await self.add_permission_to_role(role_id, permission_id)
    
    async def _remove_user_from_role(
        self,
        user_id: UUID,
        role_id: UUID,
        removed_by: Optional[UUID] = None
    ) -> bool:
        """Remove user from role."""
        try:
            # Delete from association table
            stmt = delete(user_roles).where(
                and_(user_roles.c.user_id == user_id, user_roles.c.role_id == role_id)
            )
            result = await self.db.execute(stmt)
            await self.db.commit()
            
            if result.rowcount > 0:
                # Clear cache
                await self._clear_role_cache(role_id)
                await self._clear_user_roles_cache(user_id)
                
                # Emit event
                if self.event_emitter:
                    role = await self.get_role_by_id(role_id)
                    await self.event_emitter.emit("role.removed", {
                        "user_id": str(user_id),
                        "role_id": str(role_id),
                        "role_name": role.name if role else "Unknown",
                        "removed_by": str(removed_by) if removed_by else None
                    })
                
                return True
            
            return False
            
        except Exception as e:
            await self.db.rollback()
            logger.error(f"Error removing role {role_id} from user {user_id}: {e}")
            raise DatabaseException("Failed to remove role from user")
    
    async def _would_create_circular_dependency(
        self,
        parent_role_id: UUID,
        child_role_id: Optional[UUID] = None
    ) -> bool:
        """Check if setting parent would create circular dependency."""
        if not child_role_id:
            return False
        
        # Walk up the parent chain from the proposed parent
        current_id = parent_role_id
        visited = set()
        
        while current_id and current_id not in visited:
            if current_id == child_role_id:
                return True  # Would create circular dependency
            
            visited.add(current_id)
            
            # Get parent of current role
            query = select(Role.parent_role_id).where(Role.id == current_id)
            result = await self.db.execute(query)
            current_id = result.scalar_one_or_none()
        
        return False
    
    async def _clear_role_cache(self, role_id: UUID) -> None:
        """Clear role-related cache entries."""
        if self.redis:
            try:
                cache_keys = [
                    f"role:{role_id}",
                    f"role_permissions:{role_id}",
                    f"role_users:{role_id}"
                ]
                if cache_keys:
                    await self.redis.delete(*cache_keys)
            except Exception as e:
                logger.warning(f"Failed to clear role cache: {e}")
    
    async def _clear_user_roles_cache(self, user_id: UUID) -> None:
        """Clear user roles cache."""
        if self.redis:
            try:
                await self.redis.delete(f"user_roles:{user_id}")
            except Exception as e:
                logger.warning(f"Failed to clear user roles cache: {e}")