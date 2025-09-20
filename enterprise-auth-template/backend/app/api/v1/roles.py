"""
Role management API endpoints.
"""

from typing import List, Optional
from uuid import UUID
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.ext.asyncio import AsyncSession
from pydantic import BaseModel, Field, ConfigDict

from app.core.database import get_db
from app.dependencies.auth import get_current_active_user, require_permission
from app.models.user import User
from app.services.role_service import RoleService
from app.services.permission_service import PermissionService

router = APIRouter(prefix="/roles", tags=["roles"])


# Request/Response schemas
class RoleCreateRequest(BaseModel):
    """Request schema for creating a role."""

    name: str = Field(..., min_length=3, max_length=50, description="Unique role name")
    display_name: str = Field(
        ..., min_length=3, max_length=100, description="Display name"
    )
    description: Optional[str] = Field(
        None, max_length=500, description="Role description"
    )
    priority: int = Field(0, ge=0, le=999, description="Role priority")
    permissions: Optional[List[str]] = Field(
        None, description="List of permission names"
    )


class RoleUpdateRequest(BaseModel):
    """Request schema for updating a role."""

    display_name: Optional[str] = Field(None, min_length=3, max_length=100)
    description: Optional[str] = Field(None, max_length=500)
    priority: Optional[int] = Field(None, ge=0, le=999)
    is_active: Optional[bool] = None


class RolePermissionRequest(BaseModel):
    """Request schema for managing role permissions."""

    permissions: List[str] = Field(..., description="List of permission names")


class AssignRoleRequest(BaseModel):
    """Request schema for assigning a role to a user."""

    user_id: UUID = Field(..., description="User ID")
    role_id: UUID = Field(..., description="Role ID")


class RoleResponse(BaseModel):
    """Response schema for role data."""

    id: UUID
    name: str
    display_name: str
    description: Optional[str]
    is_system: bool
    is_active: bool
    priority: int
    permissions: List[str]
    created_at: str
    updated_at: str

    model_config = ConfigDict(from_attributes=True)


@router.get("/", response_model=List[RoleResponse])
async def list_roles(
    skip: int = Query(0, ge=0, description="Number of records to skip"),
    limit: int = Query(100, ge=1, le=1000, description="Number of records to return"),
    include_inactive: bool = Query(False, description="Include inactive roles"),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
) -> List[RoleResponse]:
    """
    List all roles.

    Requires: role.list permission
    """
    # Check permission
    await require_permission(current_user, "role.list", db)

    service = RoleService(db)
    roles = await service.get_all_roles(
        skip=skip, limit=limit, include_inactive=include_inactive
    )

    return [
        RoleResponse(
            id=role.id,
            name=role.name,
            display_name=role.display_name,
            description=role.description,
            is_system=role.is_system,
            is_active=role.is_active,
            priority=role.priority,
            permissions=[p.name for p in role.permissions],
            created_at=role.created_at.isoformat(),
            updated_at=role.updated_at.isoformat(),
        )
        for role in roles
    ]


@router.get("/{role_id}", response_model=RoleResponse)
async def get_role(
    role_id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
) -> RoleResponse:
    """
    Get a specific role by ID.

    Requires: role.read permission
    """
    # Check permission
    await require_permission(current_user, "role.read", db)

    service = RoleService(db)
    role = await service.get_role_by_id(role_id)

    if not role:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Role with ID {role_id} not found",
        )

    return RoleResponse(
        id=role.id,
        name=role.name,
        display_name=role.display_name,
        description=role.description,
        is_system=role.is_system,
        is_active=role.is_active,
        priority=role.priority,
        permissions=[p.name for p in role.permissions],
        created_at=role.created_at.isoformat(),
        updated_at=role.updated_at.isoformat(),
    )


@router.post("/", response_model=RoleResponse, status_code=status.HTTP_201_CREATED)
async def create_role(
    request: RoleCreateRequest,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
) -> RoleResponse:
    """
    Create a new role.

    Requires: role.create permission
    """
    # Check permission
    await require_permission(current_user, "role.create", db)

    service = RoleService(db)

    try:
        role = await service.create_role(
            name=request.name,
            display_name=request.display_name,
            description=request.description,
            priority=request.priority,
            permissions=request.permissions,
            current_user=current_user,
        )

        return RoleResponse(
            id=role.id,
            name=role.name,
            display_name=role.display_name,
            description=role.description,
            is_system=role.is_system,
            is_active=role.is_active,
            priority=role.priority,
            permissions=[p.name for p in role.permissions],
            created_at=role.created_at.isoformat(),
            updated_at=role.updated_at.isoformat(),
        )
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))


@router.put("/{role_id}", response_model=RoleResponse)
async def update_role(
    role_id: UUID,
    request: RoleUpdateRequest,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
) -> RoleResponse:
    """
    Update a role.

    Requires: role.update permission
    """
    # Check permission
    await require_permission(current_user, "role.update", db)

    service = RoleService(db)

    try:
        role = await service.update_role(
            role_id=role_id,
            display_name=request.display_name,
            description=request.description,
            priority=request.priority,
            is_active=request.is_active,
            current_user=current_user,
        )

        return RoleResponse(
            id=role.id,
            name=role.name,
            display_name=role.display_name,
            description=role.description,
            is_system=role.is_system,
            is_active=role.is_active,
            priority=role.priority,
            permissions=[p.name for p in role.permissions],
            created_at=role.created_at.isoformat(),
            updated_at=role.updated_at.isoformat(),
        )
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))


@router.delete("/{role_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_role(
    role_id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
) -> None:
    """
    Delete a role.

    Requires: role.delete permission
    """
    # Check permission
    await require_permission(current_user, "role.delete", db)

    service = RoleService(db)

    try:
        await service.delete_role(role_id, current_user)
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))


@router.post("/{role_id}/permissions", response_model=RoleResponse)
async def add_permissions_to_role(
    role_id: UUID,
    request: RolePermissionRequest,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
) -> RoleResponse:
    """
    Add permissions to a role.

    Requires: permission.assign permission
    """
    # Check permission
    await require_permission(current_user, "permission.assign", db)

    service = RoleService(db)

    try:
        role = await service.assign_permissions_to_role(
            role_id=role_id,
            permission_names=request.permissions,
            current_user=current_user,
        )

        return RoleResponse(
            id=role.id,
            name=role.name,
            display_name=role.display_name,
            description=role.description,
            is_system=role.is_system,
            is_active=role.is_active,
            priority=role.priority,
            permissions=[p.name for p in role.permissions],
            created_at=role.created_at.isoformat(),
            updated_at=role.updated_at.isoformat(),
        )
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))


@router.delete("/{role_id}/permissions", response_model=RoleResponse)
async def remove_permissions_from_role(
    role_id: UUID,
    request: RolePermissionRequest,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
) -> RoleResponse:
    """
    Remove permissions from a role.

    Requires: permission.assign permission
    """
    # Check permission
    await require_permission(current_user, "permission.assign", db)

    service = RoleService(db)

    try:
        role = await service.remove_permissions_from_role(
            role_id=role_id,
            permission_names=request.permissions,
            current_user=current_user,
        )

        return RoleResponse(
            id=role.id,
            name=role.name,
            display_name=role.display_name,
            description=role.description,
            is_system=role.is_system,
            is_active=role.is_active,
            priority=role.priority,
            permissions=[p.name for p in role.permissions],
            created_at=role.created_at.isoformat(),
            updated_at=role.updated_at.isoformat(),
        )
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))


@router.post("/assign", status_code=status.HTTP_200_OK)
async def assign_role_to_user(
    request: AssignRoleRequest,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
) -> dict:
    """
    Assign a role to a user.

    Requires: role.assign permission
    """
    # Check permission
    await require_permission(current_user, "role.assign", db)

    service = RoleService(db)

    try:
        success = await service.assign_role_to_user(
            user_id=request.user_id,
            role_id=request.role_id,
            assigned_by=current_user.id,
        )

        return {"success": success, "message": "Role assigned successfully"}
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))


@router.delete("/assign", status_code=status.HTTP_200_OK)
async def remove_role_from_user(
    request: AssignRoleRequest,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
) -> dict:
    """
    Remove a role from a user.

    Requires: role.assign permission
    """
    # Check permission
    await require_permission(current_user, "role.assign", db)

    service = RoleService(db)

    success = await service.remove_role_from_user(
        user_id=request.user_id, role_id=request.role_id, removed_by=current_user.id
    )

    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Role assignment not found"
        )

    return {"success": success, "message": "Role removed successfully"}


@router.get("/user/{user_id}", response_model=List[RoleResponse])
async def get_user_roles(
    user_id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
) -> List[RoleResponse]:
    """
    Get all roles for a specific user.

    Requires: user.read permission or being the user themselves
    """
    # Check permission - users can see their own roles
    if user_id != current_user.id:
        await require_permission(current_user, "user.read", db)

    service = RoleService(db)
    roles = await service.get_user_roles(user_id)

    return [
        RoleResponse(
            id=role.id,
            name=role.name,
            display_name=role.display_name,
            description=role.description,
            is_system=role.is_system,
            is_active=role.is_active,
            priority=role.priority,
            permissions=[p.name for p in role.permissions],
            created_at=role.created_at.isoformat(),
            updated_at=role.updated_at.isoformat(),
        )
        for role in roles
    ]
