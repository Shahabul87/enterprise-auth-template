"""
Permission system for the application.
Provides role-based access control (RBAC) functionality.
"""
from typing import List, Set, Dict, Optional, Any
from enum import Enum
from functools import wraps
from fastapi import Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.exceptions import AuthorizationException
from app.models.user import User
from app.models.role import Role
from app.models.permission import Permission


class Resource(str, Enum):
    """System resources that can be protected."""
    USER = "user"
    ROLE = "role"
    PERMISSION = "permission"
    ORGANIZATION = "organization"
    API_KEY = "api_key"
    WEBHOOK = "webhook"
    AUDIT_LOG = "audit_log"
    SESSION = "session"
    NOTIFICATION = "notification"
    ADMIN = "admin"
    SYSTEM = "system"
    REPORT = "report"
    SETTINGS = "settings"
    PROFILE = "profile"


class Action(str, Enum):
    """Actions that can be performed on resources."""
    CREATE = "create"
    READ = "read"
    UPDATE = "update"
    DELETE = "delete"
    LIST = "list"
    EXECUTE = "execute"
    APPROVE = "approve"
    EXPORT = "export"
    IMPORT = "import"
    MANAGE = "manage"


class PermissionChecker:
    """Utility class for checking permissions."""
    
    def __init__(self, user: Optional[User] = None):
        self.user = user
        self._permissions_cache: Optional[Set[str]] = None
    
    async def load_permissions(self, db: AsyncSession) -> Set[str]:
        """Load user permissions from database."""
        if not self.user:
            return set()
        
        if self._permissions_cache is not None:
            return self._permissions_cache
        
        permissions = set()
        
        # Get permissions from user's roles
        for role in self.user.roles:
            for permission in role.permissions:
                permissions.add(permission.code)
        
        # Get direct user permissions
        for permission in self.user.permissions:
            permissions.add(permission.code)
        
        # Cache the permissions
        self._permissions_cache = permissions
        return permissions
    
    def has_permission(self, resource: Resource, action: Action) -> bool:
        """Check if user has specific permission."""
        if not self.user:
            return False
        
        if not self._permissions_cache:
            return False
        
        # Super admin has all permissions
        if "system:*" in self._permissions_cache:
            return True
        
        # Check for exact permission
        permission_code = f"{resource.value}:{action.value}"
        if permission_code in self._permissions_cache:
            return True
        
        # Check for wildcard resource permission
        if f"{resource.value}:*" in self._permissions_cache:
            return True
        
        # Check for wildcard action permission
        if f"*:{action.value}" in self._permissions_cache:
            return True
        
        return False
    
    def has_any_permission(self, permissions: List[tuple[Resource, Action]]) -> bool:
        """Check if user has any of the specified permissions."""
        return any(self.has_permission(resource, action) for resource, action in permissions)
    
    def has_all_permissions(self, permissions: List[tuple[Resource, Action]]) -> bool:
        """Check if user has all of the specified permissions."""
        return all(self.has_permission(resource, action) for resource, action in permissions)
    
    def can_access_resource(self, resource: Resource, action: Action, resource_owner_id: Optional[str] = None) -> bool:
        """
        Check if user can access a specific resource.
        Includes owner-based access control.
        """
        # Check general permission
        if self.has_permission(resource, action):
            return True
        
        # Check ownership-based access
        if resource_owner_id and self.user and str(self.user.id) == str(resource_owner_id):
            # Owner can perform certain actions on their own resources
            owner_allowed_actions = [Action.READ, Action.UPDATE, Action.DELETE]
            if action in owner_allowed_actions:
                return True
        
        return False


class PermissionManager:
    """Manager class for permission operations."""
    
    @staticmethod
    def create_permission_code(resource: Resource, action: Action) -> str:
        """Create a permission code from resource and action."""
        return f"{resource.value}:{action.value}"
    
    @staticmethod
    def parse_permission_code(code: str) -> tuple[str, str]:
        """Parse permission code into resource and action."""
        parts = code.split(":")
        if len(parts) != 2:
            raise ValueError(f"Invalid permission code format: {code}")
        return parts[0], parts[1]
    
    @staticmethod
    def get_default_permissions_for_role(role_name: str) -> List[str]:
        """Get default permissions for a role."""
        permissions_map = {
            "super_admin": ["system:*"],
            "admin": [
                "user:*",
                "role:*",
                "permission:*",
                "organization:*",
                "api_key:*",
                "webhook:*",
                "audit_log:read",
                "session:*",
                "notification:*",
                "admin:*",
                "report:*",
                "settings:*"
            ],
            "moderator": [
                "user:read",
                "user:list",
                "user:update",
                "role:read",
                "role:list",
                "audit_log:read",
                "session:read",
                "session:list",
                "notification:read",
                "notification:create",
                "report:read",
                "report:create"
            ],
            "user": [
                "profile:read",
                "profile:update",
                "session:read",
                "session:delete",
                "notification:read",
                "api_key:create",
                "api_key:read",
                "api_key:delete"
            ],
            "guest": [
                "profile:read"
            ]
        }
        
        return permissions_map.get(role_name, [])
    
    @staticmethod
    async def sync_permissions(db: AsyncSession) -> None:
        """Sync permissions with predefined list."""
        # Define all system permissions
        all_permissions = []
        
        for resource in Resource:
            for action in Action:
                # Skip certain combinations that don't make sense
                if resource == Resource.SYSTEM and action not in [Action.MANAGE, Action.EXECUTE]:
                    continue
                
                permission_code = PermissionManager.create_permission_code(resource, action)
                all_permissions.append({
                    "code": permission_code,
                    "name": f"{action.value.capitalize()} {resource.value.replace('_', ' ')}",
                    "description": f"Ability to {action.value} {resource.value.replace('_', ' ')}"
                })
        
        # Add wildcard permissions
        all_permissions.extend([
            {
                "code": "system:*",
                "name": "System Administrator",
                "description": "Full system access"
            },
            {
                "code": "*:read",
                "name": "Read All",
                "description": "Read access to all resources"
            }
        ])
        
        # Sync with database
        for perm_data in all_permissions:
            # Check if permission exists
            existing = await db.execute(
                f"SELECT id FROM permissions WHERE code = :code",
                {"code": perm_data["code"]}
            )
            if not existing.first():
                # Create new permission
                await db.execute(
                    """
                    INSERT INTO permissions (code, name, description)
                    VALUES (:code, :name, :description)
                    """,
                    perm_data
                )
        
        await db.commit()


# Dependency functions for FastAPI

async def get_current_user_permissions(
    current_user: User = Depends(),  # This would come from auth dependency
    db: AsyncSession = Depends(get_db)
) -> PermissionChecker:
    """Get permission checker for current user."""
    checker = PermissionChecker(current_user)
    await checker.load_permissions(db)
    return checker


def require_permission(resource: Resource, action: Action):
    """
    Decorator/dependency to require specific permission.
    
    Usage:
        @router.get("/admin/users")
        async def list_users(
            permissions: PermissionChecker = Depends(require_permission(Resource.USER, Action.LIST))
        ):
            ...
    """
    async def permission_dependency(
        checker: PermissionChecker = Depends(get_current_user_permissions)
    ) -> PermissionChecker:
        if not checker.has_permission(resource, action):
            raise AuthorizationException(
                message=f"Permission denied: {resource.value}:{action.value}",
                details={
                    "required_permission": f"{resource.value}:{action.value}",
                    "user_id": str(checker.user.id) if checker.user else None
                }
            )
        return checker
    
    return permission_dependency


def require_any_permission(*permissions: tuple[Resource, Action]):
    """
    Decorator/dependency to require any of the specified permissions.
    """
    async def permission_dependency(
        checker: PermissionChecker = Depends(get_current_user_permissions)
    ) -> PermissionChecker:
        if not checker.has_any_permission(list(permissions)):
            permission_codes = [f"{r.value}:{a.value}" for r, a in permissions]
            raise AuthorizationException(
                message="Permission denied",
                details={
                    "required_permissions": permission_codes,
                    "condition": "any",
                    "user_id": str(checker.user.id) if checker.user else None
                }
            )
        return checker
    
    return permission_dependency


def require_all_permissions(*permissions: tuple[Resource, Action]):
    """
    Decorator/dependency to require all of the specified permissions.
    """
    async def permission_dependency(
        checker: PermissionChecker = Depends(get_current_user_permissions)
    ) -> PermissionChecker:
        if not checker.has_all_permissions(list(permissions)):
            permission_codes = [f"{r.value}:{a.value}" for r, a in permissions]
            raise AuthorizationException(
                message="Permission denied",
                details={
                    "required_permissions": permission_codes,
                    "condition": "all",
                    "user_id": str(checker.user.id) if checker.user else None
                }
            )
        return checker
    
    return permission_dependency


class ResourceOwnershipChecker:
    """Check resource ownership for access control."""
    
    @staticmethod
    async def check_user_resource(
        resource_id: str,
        current_user: User,
        db: AsyncSession
    ) -> bool:
        """Check if current user owns the user resource."""
        return str(current_user.id) == str(resource_id)
    
    @staticmethod
    async def check_organization_resource(
        resource_id: str,
        current_user: User,
        db: AsyncSession
    ) -> bool:
        """Check if current user belongs to the organization."""
        # Check if user is member of organization
        result = await db.execute(
            """
            SELECT 1 FROM organization_members
            WHERE organization_id = :org_id AND user_id = :user_id
            """,
            {"org_id": resource_id, "user_id": current_user.id}
        )
        return result.first() is not None
    
    @staticmethod
    async def check_api_key_resource(
        resource_id: str,
        current_user: User,
        db: AsyncSession
    ) -> bool:
        """Check if current user owns the API key."""
        result = await db.execute(
            """
            SELECT user_id FROM api_keys
            WHERE id = :key_id
            """,
            {"key_id": resource_id}
        )
        row = result.first()
        return row and str(row[0]) == str(current_user.id)


def require_resource_owner(resource_type: Resource):
    """
    Decorator/dependency to require resource ownership.
    """
    async def ownership_dependency(
        resource_id: str,
        current_user: User = Depends(),  # This would come from auth dependency
        checker: PermissionChecker = Depends(get_current_user_permissions),
        db: AsyncSession = Depends(get_db)
    ) -> PermissionChecker:
        
        # Admins bypass ownership checks
        if checker.has_permission(Resource.ADMIN, Action.MANAGE):
            return checker
        
        # Check ownership based on resource type
        is_owner = False
        
        if resource_type == Resource.USER:
            is_owner = await ResourceOwnershipChecker.check_user_resource(
                resource_id, current_user, db
            )
        elif resource_type == Resource.ORGANIZATION:
            is_owner = await ResourceOwnershipChecker.check_organization_resource(
                resource_id, current_user, db
            )
        elif resource_type == Resource.API_KEY:
            is_owner = await ResourceOwnershipChecker.check_api_key_resource(
                resource_id, current_user, db
            )
        
        if not is_owner:
            raise AuthorizationException(
                message="Access denied: You don't own this resource",
                details={
                    "resource_type": resource_type.value,
                    "resource_id": resource_id
                }
            )
        
        return checker
    
    return ownership_dependency


# Utility functions

def check_permission_string(permission_string: str, user_permissions: Set[str]) -> bool:
    """
    Check if a permission string matches user permissions.
    Supports wildcards.
    """
    if permission_string in user_permissions:
        return True
    
    # Check for wildcards
    if "*" in permission_string:
        pattern = permission_string.replace("*", ".*")
        import re
        for user_perm in user_permissions:
            if re.match(pattern, user_perm):
                return True
    
    return False


def get_permission_hierarchy() -> Dict[str, List[str]]:
    """
    Get permission hierarchy for inheritance.
    Higher level permissions include lower level ones.
    """
    return {
        "system:*": ["*:*"],  # System admin has everything
        "admin:*": [
            "user:*", "role:*", "permission:*",
            "organization:*", "api_key:*", "webhook:*"
        ],
        "user:*": ["user:create", "user:read", "user:update", "user:delete", "user:list"],
        "role:*": ["role:create", "role:read", "role:update", "role:delete", "role:list"],
        # Add more hierarchies as needed
    }