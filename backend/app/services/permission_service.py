"""
Permission management service for RBAC system.

This service handles all permission-related operations including CRUD operations,
permission validation, condition checking, and permission inheritance logic.
"""
import json
import logging
from typing import List, Optional, Dict, Any, Tuple, Set
from uuid import UUID
from datetime import datetime
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_, or_, delete, func, update, desc, asc, exists
from sqlalchemy.orm import selectinload, joinedload
from sqlalchemy.exc import IntegrityError
import redis.asyncio as redis

from app.models.permission import Permission, user_permissions
from app.models.role import Role, role_permissions
from app.models.user import User
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
    PERMISSION_CACHE_TTL,
    MAX_PERMISSIONS_PER_USER,
    HIGH_RISK_PERMISSIONS,
    DANGEROUS_PERMISSIONS
)

logger = logging.getLogger(__name__)


class PermissionService:
    """Service for managing permissions and permission assignments."""
    
    def __init__(self, db: AsyncSession, redis_client: Optional[redis.Redis] = None, event_emitter: Optional[EventEmitter] = None):
        """
        Initialize permission service.
        
        Args:
            db: Database session
            redis_client: Redis client for caching
            event_emitter: Event emitter for audit logging
        """
        self.db = db
        self.redis = redis_client
        self.event_emitter = event_emitter
    
    # CRUD Operations
    
    async def create_permission(
        self,
        code: str,
        name: str,
        description: Optional[str] = None,
        resource: str = "general",
        action: str = "access",
        scope: str = "global",
        category: str = "general",
        module: Optional[str] = None,
        risk_level: str = "low",
        conditions: Optional[Dict[str, Any]] = None,
        requires_2fa: bool = False,
        requires_approval: bool = False,
        depends_on_permission_id: Optional[UUID] = None,
        ui_config: Optional[Dict[str, str]] = None,
        metadata: Optional[Dict[str, Any]] = None
    ) -> Permission:
        """
        Create a new permission.
        
        Args:
            code: Unique permission code (e.g., 'user:create')
            name: Human-readable permission name
            description: Permission description
            resource: Resource this permission applies to
            action: Action this permission allows
            scope: Permission scope (global, organization, team, user)
            category: Permission category for grouping
            module: Module this permission belongs to
            risk_level: Risk level (low, medium, high, critical)
            conditions: JSON conditions for permission validation
            requires_2fa: Whether permission requires 2FA
            requires_approval: Whether permission requires approval
            depends_on_permission_id: Permission this one depends on
            ui_config: UI configuration (label, icon, color, order)
            metadata: Additional metadata
            
        Returns:
            Created Permission instance
            
        Raises:
            ConflictException: If permission code already exists
            ValidationException: If validation fails
        """
        try:
            # Validate permission code uniqueness within scope
            existing = await self._get_permission_by_code_and_scope(code, scope)
            if existing:
                raise ConflictException(
                    f"Permission with code '{code}' already exists in scope '{scope}'",
                    {"code": code, "scope": scope}
                )
            
            # Validate depends_on permission exists
            if depends_on_permission_id:
                dep_permission = await self.get_permission_by_id(depends_on_permission_id)
                if not dep_permission:
                    raise ValidationException(
                        "Dependency permission not found",
                        {"depends_on_permission_id": str(depends_on_permission_id)}
                    )
            
            # Validate risk level
            valid_risk_levels = ["low", "medium", "high", "critical"]
            if risk_level not in valid_risk_levels:
                raise ValidationException(
                    f"Invalid risk level. Must be one of: {valid_risk_levels}",
                    {"risk_level": risk_level}
                )
            
            # Auto-set flags for high-risk permissions
            if risk_level in ["high", "critical"]:
                requires_2fa = True
            if risk_level == "critical":
                requires_approval = True
            
            # Create permission
            permission_data = {
                "code": code,
                "name": name,
                "description": description,
                "resource": resource,
                "action": action,
                "scope": scope,
                "category": category,
                "module": module,
                "risk_level": risk_level,
                "conditions_json": json.dumps(conditions) if conditions else None,
                "requires_2fa": requires_2fa,
                "requires_approval": requires_approval,
                "depends_on_permission_id": depends_on_permission_id,
                "metadata_json": json.dumps(metadata) if metadata else None,
                "is_dangerous": code in DANGEROUS_PERMISSIONS or risk_level == "critical"
            }
            
            # Add UI configuration
            if ui_config:
                permission_data.update({
                    "ui_label": ui_config.get("label"),
                    "ui_icon": ui_config.get("icon"),
                    "ui_color": ui_config.get("color"),
                    "ui_order": ui_config.get("order", 0)
                })
            
            permission = Permission(**permission_data)
            self.db.add(permission)
            await self.db.commit()
            
            # Clear cache
            await self._clear_permission_cache(permission.id)
            
            # Emit event
            if self.event_emitter:
                await self.event_emitter.emit("permission.created", {
                    "permission_id": str(permission.id),
                    "code": code,
                    "resource": resource,
                    "action": action,
                    "risk_level": risk_level
                })
            
            logger.info(f"Permission created: {code} (ID: {permission.id})")
            return permission
            
        except IntegrityError as e:
            await self.db.rollback()
            logger.error(f"Integrity error creating permission {code}: {e}")
            raise ConflictException("Permission creation failed due to constraint violation")
        except Exception as e:
            await self.db.rollback()
            logger.error(f"Error creating permission {code}: {e}")
            if isinstance(e, (ConflictException, ValidationException)):
                raise
            raise DatabaseException("Failed to create permission")
    
    async def get_permission_by_id(
        self,
        permission_id: UUID,
        include_roles: bool = False,
        include_users: bool = False,
        use_cache: bool = True
    ) -> Optional[Permission]:
        """
        Get permission by ID.
        
        Args:
            permission_id: Permission ID
            include_roles: Include roles that have this permission
            include_users: Include users that have this permission
            use_cache: Use Redis cache if available
            
        Returns:
            Permission instance or None if not found
        """
        # Try cache first
        if use_cache and self.redis and not include_roles and not include_users:
            cache_key = f"permission:{permission_id}"
            cached_data = await self.redis.get(cache_key)
            if cached_data:
                try:
                    # Note: This is a simplified cache approach
                    # In production, you might want to cache the full object
                    pass
                except (json.JSONDecodeError, KeyError):
                    pass
        
        try:
            query = select(Permission).where(Permission.id == permission_id)
            
            if include_roles:
                query = query.options(selectinload(Permission.roles))
            if include_users:
                query = query.options(selectinload(Permission.users))
            
            result = await self.db.execute(query)
            permission = result.scalar_one_or_none()
            
            # Cache the result
            if permission and use_cache and self.redis and not include_roles and not include_users:
                cache_data = {
                    "id": str(permission.id),
                    "code": permission.code,
                    "name": permission.name,
                    "resource": permission.resource,
                    "action": permission.action,
                    "scope": permission.scope,
                    "risk_level": permission.risk_level,
                    "is_active": permission.is_active
                }
                await self.redis.setex(
                    f"permission:{permission_id}",
                    PERMISSION_CACHE_TTL,
                    json.dumps(cache_data, default=str)
                )
            
            return permission
            
        except Exception as e:
            logger.error(f"Error fetching permission {permission_id}: {e}")
            return None
    
    async def get_permission_by_code(
        self,
        code: str,
        scope: str = "global",
        include_roles: bool = False
    ) -> Optional[Permission]:
        """
        Get permission by code and scope.
        
        Args:
            code: Permission code
            scope: Permission scope
            include_roles: Include roles that have this permission
            
        Returns:
            Permission instance or None if not found
        """
        return await self._get_permission_by_code_and_scope(code, scope, include_roles)
    
    async def list_permissions(
        self,
        skip: int = 0,
        limit: int = 100,
        resource: Optional[str] = None,
        action: Optional[str] = None,
        scope: Optional[str] = None,
        category: Optional[str] = None,
        module: Optional[str] = None,
        risk_level: Optional[str] = None,
        is_active: Optional[bool] = None,
        is_system: Optional[bool] = None,
        search: Optional[str] = None,
        sort_by: str = "created_at",
        sort_order: str = "desc",
        include_roles: bool = False
    ) -> Tuple[List[Permission], int]:
        """
        List permissions with filtering and pagination.
        
        Args:
            skip: Number of records to skip
            limit: Maximum number of records to return
            resource: Filter by resource
            action: Filter by action
            scope: Filter by scope
            category: Filter by category
            module: Filter by module
            risk_level: Filter by risk level
            is_active: Filter by active status
            is_system: Filter by system status
            search: Search in code, name, and description
            sort_by: Field to sort by
            sort_order: Sort order (asc/desc)
            include_roles: Include roles in results
            
        Returns:
            Tuple of (permissions list, total count)
        """
        try:
            # Base queries
            query = select(Permission)
            count_query = select(func.count(Permission.id))
            
            # Filters
            filters = []
            
            if resource:
                filters.append(Permission.resource == resource)
            
            if action:
                filters.append(Permission.action == action)
            
            if scope:
                filters.append(Permission.scope == scope)
            
            if category:
                filters.append(Permission.category == category)
            
            if module:
                filters.append(Permission.module == module)
            
            if risk_level:
                filters.append(Permission.risk_level == risk_level)
            
            if is_active is not None:
                filters.append(Permission.is_active == is_active)
            
            if is_system is not None:
                filters.append(Permission.is_system == is_system)
            
            if search:
                search_filter = or_(
                    Permission.code.ilike(f"%{search}%"),
                    Permission.name.ilike(f"%{search}%"),
                    Permission.description.ilike(f"%{search}%")
                )
                filters.append(search_filter)
            
            if filters:
                query = query.where(and_(*filters))
                count_query = count_query.where(and_(*filters))
            
            # Include roles if requested
            if include_roles:
                query = query.options(selectinload(Permission.roles))
            
            # Sorting
            sort_column = getattr(Permission, sort_by, Permission.created_at)
            if sort_order.lower() == "desc":
                query = query.order_by(desc(sort_column))
            else:
                query = query.order_by(asc(sort_column))
            
            # Pagination
            query = query.offset(skip).limit(limit)
            
            # Execute queries
            result = await self.db.execute(query)
            permissions = result.scalars().all()
            
            count_result = await self.db.execute(count_query)
            total_count = count_result.scalar()
            
            return list(permissions), total_count
            
        except Exception as e:
            logger.error(f"Error listing permissions: {e}")
            raise DatabaseException("Failed to list permissions")
    
    async def update_permission(
        self,
        permission_id: UUID,
        update_data: Dict[str, Any]
    ) -> Permission:
        """
        Update permission information.
        
        Args:
            permission_id: Permission ID to update
            update_data: Fields to update
            
        Returns:
            Updated Permission instance
            
        Raises:
            ResourceNotFoundException: If permission not found
            ValidationException: If validation fails
            ConflictException: If update would create conflict
        """
        try:
            permission = await self.get_permission_by_id(permission_id)
            if not permission:
                raise ResourceNotFoundException("Permission", permission_id)
            
            # Prevent modification of system permissions
            if permission.is_system and "code" in update_data:
                raise ValidationException(
                    "Cannot modify system permission code",
                    {"permission_id": str(permission_id)}
                )
            
            # Validate code uniqueness if changing code
            if "code" in update_data and update_data["code"] != permission.code:
                existing = await self._get_permission_by_code_and_scope(
                    update_data["code"],
                    update_data.get("scope", permission.scope)
                )
                if existing and existing.id != permission_id:
                    raise ConflictException(
                        f"Permission with code '{update_data['code']}' already exists",
                        {"code": update_data["code"]}
                    )
            
            # Handle JSON fields
            if "conditions" in update_data:
                update_data["conditions_json"] = json.dumps(update_data.pop("conditions"))
            
            if "metadata" in update_data:
                update_data["metadata_json"] = json.dumps(update_data.pop("metadata"))
            
            # Handle UI configuration
            if "ui_config" in update_data:
                ui_config = update_data.pop("ui_config")
                if ui_config:
                    update_data.update({
                        "ui_label": ui_config.get("label"),
                        "ui_icon": ui_config.get("icon"),
                        "ui_color": ui_config.get("color"),
                        "ui_order": ui_config.get("order", 0)
                    })
            
            # Auto-set flags for risk level changes
            if "risk_level" in update_data:
                risk_level = update_data["risk_level"]
                if risk_level in ["high", "critical"]:
                    update_data["requires_2fa"] = True
                if risk_level == "critical":
                    update_data["requires_approval"] = True
                    update_data["is_dangerous"] = True
            
            # Set updated timestamp
            update_data["updated_at"] = datetime.utcnow()
            
            # Update permission
            for key, value in update_data.items():
                if hasattr(permission, key):
                    setattr(permission, key, value)
            
            await self.db.commit()
            
            # Clear cache
            await self._clear_permission_cache(permission_id)
            
            # Emit event
            if self.event_emitter:
                await self.event_emitter.emit("permission.updated", {
                    "permission_id": str(permission_id),
                    "code": permission.code,
                    "updated_fields": list(update_data.keys())
                })
            
            logger.info(f"Permission updated: {permission.code} (ID: {permission_id})")
            return permission
            
        except Exception as e:
            await self.db.rollback()
            logger.error(f"Error updating permission {permission_id}: {e}")
            if isinstance(e, (ResourceNotFoundException, ValidationException, ConflictException)):
                raise
            raise DatabaseException("Failed to update permission")
    
    async def delete_permission(
        self,
        permission_id: UUID,
        force: bool = False
    ) -> bool:
        """
        Delete a permission.
        
        Args:
            permission_id: Permission ID to delete
            force: Force deletion even if permission is assigned
            
        Returns:
            True if deleted successfully
            
        Raises:
            ResourceNotFoundException: If permission not found
            BusinessLogicException: If permission cannot be deleted
        """
        try:
            permission = await self.get_permission_by_id(
                permission_id,
                include_roles=True,
                include_users=True
            )
            if not permission:
                raise ResourceNotFoundException("Permission", permission_id)
            
            # Prevent deletion of system permissions
            if permission.is_system:
                raise BusinessLogicException(
                    "Cannot delete system permission",
                    {"permission_id": str(permission_id), "code": permission.code}
                )
            
            # Check if permission is assigned
            if (permission.roles or permission.users) and not force:
                raise BusinessLogicException(
                    f"Cannot delete permission assigned to {len(permission.roles)} roles and {len(permission.users)} users. Use force=True to override.",
                    {
                        "permission_id": str(permission_id),
                        "role_count": len(permission.roles),
                        "user_count": len(permission.users)
                    }
                )
            
            # Check if other permissions depend on this one
            dependent_count_query = select(func.count(Permission.id)).where(
                Permission.depends_on_permission_id == permission_id
            )
            dependent_result = await self.db.execute(dependent_count_query)
            dependent_count = dependent_result.scalar()
            
            if dependent_count > 0:
                raise BusinessLogicException(
                    f"Cannot delete permission that {dependent_count} other permissions depend on",
                    {"permission_id": str(permission_id), "dependent_count": dependent_count}
                )
            
            # Remove all assignments if force is True
            if force:
                # Remove from roles
                await self.db.execute(
                    delete(role_permissions).where(role_permissions.c.permission_id == permission_id)
                )
                
                # Remove from users
                await self.db.execute(
                    delete(user_permissions).where(user_permissions.c.permission_id == permission_id)
                )
            
            # Delete the permission
            await self.db.delete(permission)
            await self.db.commit()
            
            # Clear cache
            await self._clear_permission_cache(permission_id)
            
            # Emit event
            if self.event_emitter:
                await self.event_emitter.emit("permission.deleted", {
                    "permission_id": str(permission_id),
                    "code": permission.code,
                    "force": force
                })
            
            logger.info(f"Permission deleted: {permission.code} (ID: {permission_id})")
            return True
            
        except Exception as e:
            await self.db.rollback()
            logger.error(f"Error deleting permission {permission_id}: {e}")
            if isinstance(e, (ResourceNotFoundException, BusinessLogicException)):
                raise
            raise DatabaseException("Failed to delete permission")
    
    # Permission Assignment Operations
    
    async def grant_permission_to_user(
        self,
        user_id: UUID,
        permission_id: UUID,
        granted_by: Optional[UUID] = None,
        expires_at: Optional[datetime] = None,
        reason: Optional[str] = None
    ) -> bool:
        """
        Grant a permission directly to a user.
        
        Args:
            user_id: User ID
            permission_id: Permission ID
            granted_by: User granting the permission
            expires_at: When the permission expires
            reason: Reason for granting the permission
            
        Returns:
            True if granted successfully
            
        Raises:
            ResourceNotFoundException: If user or permission not found
            BusinessLogicException: If permission cannot be granted
        """
        try:
            # Validate user exists
            user_query = select(User).where(User.id == user_id)
            user_result = await self.db.execute(user_query)
            user = user_result.scalar_one_or_none()
            if not user:
                raise ResourceNotFoundException("User", user_id)
            
            # Validate permission exists
            permission = await self.get_permission_by_id(permission_id, include_users=True)
            if not permission:
                raise ResourceNotFoundException("Permission", permission_id)
            
            if not permission.is_active:
                raise BusinessLogicException(
                    "Cannot grant inactive permission",
                    {"permission_id": str(permission_id), "code": permission.code}
                )
            
            # Check if user already has this permission
            if user in permission.users:
                return True  # Already granted
            
            # Check user permission limit
            user_permission_count_query = select(func.count()).select_from(user_permissions).where(
                user_permissions.c.user_id == user_id
            )
            user_permission_count_result = await self.db.execute(user_permission_count_query)
            user_permission_count = user_permission_count_result.scalar()
            
            if user_permission_count >= MAX_PERMISSIONS_PER_USER:
                raise BusinessLogicException(
                    f"User has reached maximum direct permission limit of {MAX_PERMISSIONS_PER_USER}",
                    {"user_id": str(user_id), "current_permissions": user_permission_count}
                )
            
            # Check if permission requires approval (would need workflow in production)
            if permission.requires_approval:
                logger.warning(f"Permission {permission.code} requires approval but granted directly")
            
            # Add user to permission
            permission.users.append(user)
            
            # Update the association table with metadata
            stmt = update(user_permissions).where(
                and_(user_permissions.c.user_id == user_id, user_permissions.c.permission_id == permission_id)
            ).values(
                granted_by=granted_by,
                expires_at=expires_at,
                reason=reason,
                granted_at=datetime.utcnow()
            )
            await self.db.execute(stmt)
            
            await self.db.commit()
            
            # Clear cache
            await self._clear_permission_cache(permission_id)
            await self._clear_user_permissions_cache(user_id)
            
            # Emit event
            if self.event_emitter:
                await self.event_emitter.emit("permission.granted.user", {
                    "user_id": str(user_id),
                    "permission_id": str(permission_id),
                    "permission_code": permission.code,
                    "granted_by": str(granted_by) if granted_by else None,
                    "expires_at": expires_at.isoformat() if expires_at else None,
                    "reason": reason
                })
            
            logger.info(f"Permission {permission.code} granted to user {user_id}")
            return True
            
        except Exception as e:
            await self.db.rollback()
            logger.error(f"Error granting permission {permission_id} to user {user_id}: {e}")
            if isinstance(e, (ResourceNotFoundException, BusinessLogicException)):
                raise
            raise DatabaseException("Failed to grant permission")
    
    async def revoke_permission_from_user(
        self,
        user_id: UUID,
        permission_id: UUID,
        revoked_by: Optional[UUID] = None
    ) -> bool:
        """
        Revoke a permission from a user.
        
        Args:
            user_id: User ID
            permission_id: Permission ID
            revoked_by: User revoking the permission
            
        Returns:
            True if revoked successfully
        """
        try:
            # Delete from association table
            stmt = delete(user_permissions).where(
                and_(user_permissions.c.user_id == user_id, user_permissions.c.permission_id == permission_id)
            )
            result = await self.db.execute(stmt)
            await self.db.commit()
            
            if result.rowcount > 0:
                # Clear cache
                await self._clear_permission_cache(permission_id)
                await self._clear_user_permissions_cache(user_id)
                
                # Emit event
                if self.event_emitter:
                    permission = await self.get_permission_by_id(permission_id)
                    await self.event_emitter.emit("permission.revoked.user", {
                        "user_id": str(user_id),
                        "permission_id": str(permission_id),
                        "permission_code": permission.code if permission else "Unknown",
                        "revoked_by": str(revoked_by) if revoked_by else None
                    })
                
                return True
            
            return False
            
        except Exception as e:
            await self.db.rollback()
            logger.error(f"Error revoking permission {permission_id} from user {user_id}: {e}")
            raise DatabaseException("Failed to revoke permission")
    
    # Permission Checking Operations
    
    async def check_user_permission(
        self,
        user_id: UUID,
        permission_code: str,
        context: Optional[Dict[str, Any]] = None,
        include_role_permissions: bool = True
    ) -> bool:
        """
        Check if user has a specific permission.
        
        Args:
            user_id: User ID
            permission_code: Permission code to check
            context: Context for conditional permissions
            include_role_permissions: Include permissions from user's roles
            
        Returns:
            True if user has the permission
        """
        try:
            # Check direct permissions
            direct_permissions = await self.get_user_direct_permissions(user_id)
            for permission in direct_permissions:
                if permission.matches(permission_code):
                    # Check conditions if present
                    if context and permission.conditions_json:
                        if not permission.validate_conditions(context):
                            continue
                    return True
            
            # Check role-based permissions if requested
            if include_role_permissions:
                role_permissions = await self.get_user_role_permissions(user_id)
                for permission in role_permissions:
                    if permission.matches(permission_code):
                        # Check conditions if present
                        if context and permission.conditions_json:
                            if not permission.validate_conditions(context):
                                continue
                        return True
            
            return False
            
        except Exception as e:
            logger.error(f"Error checking permission {permission_code} for user {user_id}: {e}")
            return False
    
    async def get_user_permissions(
        self,
        user_id: UUID,
        include_role_permissions: bool = True,
        include_inherited: bool = True
    ) -> List[Permission]:
        """
        Get all permissions for a user.
        
        Args:
            user_id: User ID
            include_role_permissions: Include permissions from roles
            include_inherited: Include inherited permissions from parent roles
            
        Returns:
            List of Permission instances
        """
        try:
            permissions = []
            
            # Get direct permissions
            direct_permissions = await self.get_user_direct_permissions(user_id)
            permissions.extend(direct_permissions)
            
            # Get role permissions
            if include_role_permissions:
                role_permissions = await self.get_user_role_permissions(user_id, include_inherited)
                permissions.extend(role_permissions)
            
            # Remove duplicates while preserving order
            seen = set()
            unique_permissions = []
            for permission in permissions:
                if permission.id not in seen:
                    seen.add(permission.id)
                    unique_permissions.append(permission)
            
            return unique_permissions
            
        except Exception as e:
            logger.error(f"Error getting user permissions for {user_id}: {e}")
            return []
    
    async def get_user_direct_permissions(self, user_id: UUID) -> List[Permission]:
        """Get permissions directly assigned to a user."""
        try:
            query = (
                select(Permission)
                .join(user_permissions)
                .where(user_permissions.c.user_id == user_id)
                .where(Permission.is_active == True)
            )
            
            result = await self.db.execute(query)
            return list(result.scalars().all())
            
        except Exception as e:
            logger.error(f"Error getting direct permissions for user {user_id}: {e}")
            return []
    
    async def get_user_role_permissions(
        self,
        user_id: UUID,
        include_inherited: bool = True
    ) -> List[Permission]:
        """Get permissions from user's roles."""
        try:
            # Import here to avoid circular imports
            from app.services.role_service import RoleService
            
            role_service = RoleService(self.db, self.redis, self.event_emitter)
            user_roles = await role_service.get_user_roles(user_id, include_permissions=True, include_inherited=include_inherited)
            
            permissions = []
            for role in user_roles:
                if include_inherited:
                    permissions.extend(role.inherited_permissions)
                else:
                    permissions.extend(role.permissions)
            
            # Remove duplicates
            seen = set()
            unique_permissions = []
            for permission in permissions:
                if permission.id not in seen:
                    seen.add(permission.id)
                    unique_permissions.append(permission)
            
            return unique_permissions
            
        except Exception as e:
            logger.error(f"Error getting role permissions for user {user_id}: {e}")
            return []
    
    async def get_effective_permissions(
        self,
        user_id: UUID,
        context: Optional[Dict[str, Any]] = None
    ) -> List[Permission]:
        """
        Get effective permissions for a user (after applying conditions).
        
        Args:
            user_id: User ID
            context: Context for conditional permissions
            
        Returns:
            List of effective Permission instances
        """
        all_permissions = await self.get_user_permissions(user_id)
        
        if not context:
            return all_permissions
        
        # Filter permissions based on conditions
        effective_permissions = []
        for permission in all_permissions:
            if not permission.conditions_json or permission.validate_conditions(context):
                effective_permissions.append(permission)
        
        return effective_permissions
    
    # Bulk Operations
    
    async def bulk_grant_permissions(
        self,
        grants: List[Dict[str, Any]],
        granted_by: Optional[UUID] = None
    ) -> Dict[str, Any]:
        """
        Bulk grant permissions to users.
        
        Args:
            grants: List of grant dictionaries
            granted_by: User granting the permissions
            
        Returns:
            Dictionary with success/failure counts and details
        """
        results = {
            "success_count": 0,
            "error_count": 0,
            "errors": []
        }
        
        for grant in grants:
            try:
                user_id = UUID(grant["user_id"])
                permission_id = UUID(grant["permission_id"])
                expires_at = grant.get("expires_at")
                if expires_at and isinstance(expires_at, str):
                    expires_at = datetime.fromisoformat(expires_at)
                reason = grant.get("reason")
                
                await self.grant_permission_to_user(
                    user_id, permission_id, granted_by, expires_at, reason
                )
                results["success_count"] += 1
                
            except Exception as e:
                results["error_count"] += 1
                results["errors"].append({
                    "grant": grant,
                    "error": str(e)
                })
                logger.error(f"Bulk grant failed for {grant}: {e}")
        
        return results
    
    # Analytics and Reporting
    
    async def get_permission_usage_stats(self, permission_id: UUID) -> Dict[str, Any]:
        """Get usage statistics for a permission."""
        try:
            permission = await self.get_permission_by_id(
                permission_id, include_roles=True, include_users=True
            )
            if not permission:
                raise ResourceNotFoundException("Permission", permission_id)
            
            # Count users through roles
            role_user_count_query = select(func.count(func.distinct(user_roles.c.user_id))).select_from(
                role_permissions.join(user_roles, role_permissions.c.role_id == user_roles.c.role_id)
            ).where(role_permissions.c.permission_id == permission_id)
            
            role_user_count_result = await self.db.execute(role_user_count_query)
            role_user_count = role_user_count_result.scalar() or 0
            
            return {
                "permission_id": str(permission_id),
                "code": permission.code,
                "direct_user_count": len(permission.users),
                "role_count": len(permission.roles),
                "role_user_count": role_user_count,
                "total_user_count": len(permission.users) + role_user_count,
                "risk_level": permission.risk_level,
                "is_dangerous": permission.is_dangerous
            }
            
        except Exception as e:
            logger.error(f"Error getting permission usage stats {permission_id}: {e}")
            if isinstance(e, ResourceNotFoundException):
                raise
            return {}
    
    async def get_high_risk_permissions(self) -> List[Permission]:
        """Get all high-risk permissions."""
        try:
            query = select(Permission).where(
                or_(
                    Permission.risk_level.in_(["high", "critical"]),
                    Permission.is_dangerous == True
                )
            ).where(Permission.is_active == True)
            
            result = await self.db.execute(query)
            return list(result.scalars().all())
            
        except Exception as e:
            logger.error(f"Error getting high-risk permissions: {e}")
            return []
    
    # Helper Methods
    
    async def _get_permission_by_code_and_scope(
        self,
        code: str,
        scope: str = "global",
        include_roles: bool = False
    ) -> Optional[Permission]:
        """Get permission by code and scope."""
        try:
            query = select(Permission).where(
                and_(Permission.code == code, Permission.scope == scope)
            )
            
            if include_roles:
                query = query.options(selectinload(Permission.roles))
            
            result = await self.db.execute(query)
            return result.scalar_one_or_none()
            
        except Exception as e:
            logger.error(f"Error getting permission by code {code}: {e}")
            return None
    
    async def _clear_permission_cache(self, permission_id: UUID) -> None:
        """Clear permission-related cache entries."""
        if self.redis:
            try:
                cache_keys = [
                    f"permission:{permission_id}",
                    f"permission_roles:{permission_id}",
                    f"permission_users:{permission_id}"
                ]
                if cache_keys:
                    await self.redis.delete(*cache_keys)
            except Exception as e:
                logger.warning(f"Failed to clear permission cache: {e}")
    
    async def _clear_user_permissions_cache(self, user_id: UUID) -> None:
        """Clear user permissions cache."""
        if self.redis:
            try:
                cache_keys = [
                    f"user_permissions:{user_id}",
                    f"user_direct_permissions:{user_id}",
                    f"user_role_permissions:{user_id}"
                ]
                await self.redis.delete(*cache_keys)
            except Exception as e:
                logger.warning(f"Failed to clear user permissions cache: {e}")