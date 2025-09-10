"""
Permissions API endpoints for permission management
"""
from typing import List, Optional, Dict, Any
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.models.permission import Permission
from app.models.role import Role
from app.models.user import User
from app.services.permission_service import PermissionService
from app.services.audit_service import AuditService
from app.dependencies.auth import require_superuser, get_current_user
from app.schemas.permission import (
    PermissionCreate,
    PermissionUpdate,
    PermissionResponse,
    RolePermissionAssignment
)

router = APIRouter(prefix="/permissions", tags=["permissions"])

@router.get("/", response_model=List[PermissionResponse])
async def list_permissions(
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=1000),
    resource: Optional[str] = None,
    action: Optional[str] = None,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> List[PermissionResponse]:
    """List all permissions with optional filtering"""
    permission_service = PermissionService(db)

    filters = {}
    if resource:
        filters["resource"] = resource
    if action:
        filters["action"] = action

    permissions = await permission_service.get_permissions(
        skip=skip,
        limit=limit,
        filters=filters
    )

    return permissions

@router.post("/", response_model=PermissionResponse, status_code=status.HTTP_201_CREATED)
async def create_permission(
    permission_data: PermissionCreate,
    current_user: User = Depends(require_superuser),
    db: AsyncSession = Depends(get_db)
) -> PermissionResponse:
    """Create a new permission (admin only)"""
    permission_service = PermissionService(db)
    audit_service = AuditService(db)

    # Check if permission already exists
    existing = await permission_service.get_by_name(permission_data.name)
    if existing:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Permission with this name already exists"
        )

    permission = await permission_service.create_permission(permission_data)

    # Log the action
    await audit_service.log_activity(
        user_id=current_user.id,
        action="PERMISSION_CREATED",
        resource_type="permission",
        resource_id=permission.id,
        details=permission_data.dict()
    )

    return permission

@router.get("/{permission_id}", response_model=PermissionResponse)
async def get_permission(
    permission_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> PermissionResponse:
    """Get a specific permission by ID"""
    permission_service = PermissionService(db)

    permission = await permission_service.get_permission(permission_id)
    if not permission:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Permission not found"
        )

    return permission

@router.put("/{permission_id}", response_model=PermissionResponse)
async def update_permission(
    permission_id: str,
    permission_data: PermissionUpdate,
    current_user: User = Depends(require_superuser),
    db: AsyncSession = Depends(get_db)
) -> PermissionResponse:
    """Update a permission (admin only)"""
    permission_service = PermissionService(db)
    audit_service = AuditService(db)

    permission = await permission_service.update_permission(permission_id, permission_data)
    if not permission:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Permission not found"
        )

    # Log the action
    await audit_service.log_activity(
        user_id=current_user.id,
        action="PERMISSION_UPDATED",
        resource_type="permission",
        resource_id=permission_id,
        details=permission_data.dict(exclude_unset=True)
    )

    return permission

@router.delete("/{permission_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_permission(
    permission_id: str,
    current_user: User = Depends(require_superuser),
    db: AsyncSession = Depends(get_db)
) -> None:
    """Delete a permission (admin only)"""
    permission_service = PermissionService(db)
    audit_service = AuditService(db)

    success = await permission_service.delete_permission(permission_id)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Permission not found"
        )

    # Log the action
    await audit_service.log_activity(
        user_id=current_user.id,
        action="PERMISSION_DELETED",
        resource_type="permission",
        resource_id=permission_id,
        details={"deleted_by": current_user.id}
    )

@router.post("/assign-to-role", response_model=Dict[str, Any])
async def assign_permission_to_role(
    assignment: RolePermissionAssignment,
    current_user: User = Depends(require_superuser),
    db: AsyncSession = Depends(get_db)
) -> Dict[str, Any]:
    """Assign permissions to a role (admin only)"""
    permission_service = PermissionService(db)
    audit_service = AuditService(db)

    result = await permission_service.assign_permissions_to_role(
        role_id=assignment.role_id,
        permission_ids=assignment.permission_ids
    )

    # Log the action
    await audit_service.log_activity(
        user_id=current_user.id,
        action="PERMISSIONS_ASSIGNED_TO_ROLE",
        resource_type="role",
        resource_id=assignment.role_id,
        details={
            "permission_ids": assignment.permission_ids,
            "assigned_count": result["assigned_count"]
        }
    )

    return result

@router.post("/remove-from-role", response_model=Dict[str, Any])
async def remove_permission_from_role(
    assignment: RolePermissionAssignment,
    current_user: User = Depends(require_superuser),
    db: AsyncSession = Depends(get_db)
) -> Dict[str, Any]:
    """Remove permissions from a role (admin only)"""
    permission_service = PermissionService(db)
    audit_service = AuditService(db)

    result = await permission_service.remove_permissions_from_role(
        role_id=assignment.role_id,
        permission_ids=assignment.permission_ids
    )

    # Log the action
    await audit_service.log_activity(
        user_id=current_user.id,
        action="PERMISSIONS_REMOVED_FROM_ROLE",
        resource_type="role",
        resource_id=assignment.role_id,
        details={
            "permission_ids": assignment.permission_ids,
            "removed_count": result["removed_count"]
        }
    )

    return result

@router.get("/role/{role_id}", response_model=List[PermissionResponse])
async def get_role_permissions(
    role_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> List[PermissionResponse]:
    """Get all permissions assigned to a role"""
    permission_service = PermissionService(db)

    permissions = await permission_service.get_role_permissions(role_id)
    return permissions

@router.get("/user/{user_id}", response_model=List[PermissionResponse])
async def get_user_permissions(
    user_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> List[PermissionResponse]:
    """Get all permissions for a user (through their roles)"""
    # Check authorization
    if not current_user.is_superuser and user_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not authorized to view permissions for this user"
        )

    permission_service = PermissionService(db)
    permissions = await permission_service.get_user_permissions(user_id)

    return permissions

@router.post("/check", response_model=Dict[str, bool])
async def check_permission(
    user_id: str,
    permission_name: str,
    resource_id: Optional[str] = None,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> Dict[str, bool]:
    """Check if a user has a specific permission"""
    # Check authorization
    if not current_user.is_superuser and user_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not authorized to check permissions for this user"
        )

    permission_service = PermissionService(db)

    has_permission = await permission_service.check_user_permission(
        user_id=user_id,
        permission_name=permission_name,
        resource_id=resource_id
    )

    return {
        "has_permission": has_permission,
        "user_id": user_id,
        "permission": permission_name,
        "resource_id": resource_id
    }

@router.get("/resources/list", response_model=List[str])
async def list_resources(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> List[str]:
    """Get list of all unique resources"""
    permission_service = PermissionService(db)
    return await permission_service.get_unique_resources()

@router.get("/actions/list", response_model=List[str])
async def list_actions(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> List[str]:
    """Get list of all unique actions"""
    permission_service = PermissionService(db)
    return await permission_service.get_unique_actions()

@router.post("/bulk-check", response_model=Dict[str, Dict[str, bool]])
async def bulk_check_permissions(
    user_id: str,
    permission_names: List[str],
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> Dict[str, Dict[str, bool]]:
    """Check multiple permissions for a user at once"""
    # Check authorization
    if not current_user.is_superuser and user_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not authorized to check permissions for this user"
        )

    permission_service = PermissionService(db)

    results = {}
    for permission_name in permission_names:
        has_permission = await permission_service.check_user_permission(
            user_id=user_id,
            permission_name=permission_name
        )
        results[permission_name] = {"has_permission": has_permission}

    return results
