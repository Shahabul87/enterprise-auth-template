"""
User Management Endpoints

Handles user profile operations, user listing for admins,
and user role management.
"""

from typing import List, Optional

import structlog
from fastapi import APIRouter, Depends, Query, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db_session
from app.dependencies.auth import (
    CurrentUser,
    get_current_user,
    require_permissions,
)
from app.schemas.user import UserListResponse, UserResponse, UserUpdate
from app.schemas.response import StandardResponse
from app.utils.response_helpers import (
    generate_request_id,
    user_profile_response,
    format_user_response,
    message_response,
)
from app.repositories.user_repository import UserRepository
from app.repositories.role_repository import RoleRepository
from app.models.user import User
from sqlalchemy import select, func
from sqlalchemy.orm import selectinload

logger = structlog.get_logger(__name__)

router = APIRouter()


@router.get("/me", response_model=StandardResponse[dict])
async def get_current_user_profile(
    current_user: CurrentUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db_session),
) -> StandardResponse[dict]:
    """
    Get current user profile.

    Returns the profile information for the authenticated user.

    Args:
        current_user: Current authenticated user
        db: Database session

    Returns:
        UserResponse: Current user information
    """
    logger.debug("Current user profile requested", user_id=current_user.id)

    # Use repository pattern to get full user data
    user_repo = UserRepository(db)
    user = await user_repo.get_by_id(current_user.id)

    if not user:
        # Fallback to CurrentUser data if not found
        from types import SimpleNamespace

        user = SimpleNamespace(
            id=current_user.id,
            email=current_user.email,
            full_name=current_user.full_name,
            is_active=current_user.is_active,
            is_verified=current_user.is_verified,
            roles=[SimpleNamespace(name=role) for role in current_user.roles],
            created_at=None,
            updated_at=None,
            last_login=None,
            profile_picture=None,
            is_2fa_enabled=False,
        )

    request_id = generate_request_id()
    return user_profile_response(user, request_id)


@router.put("/me", response_model=UserResponse)
async def update_current_user(
    user_update: UserUpdate,
    current_user: CurrentUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db_session),
) -> UserResponse:
    """
    Update current user profile.

    Updates the authenticated user's profile information.

    Args:
        user_update: User update data
        current_user: Current authenticated user
        db: Database session

    Returns:
        UserResponse: Updated user information

    Raises:
        HTTPException: If validation fails
    """
    logger.info("User profile update", user_id=current_user.id)

    # Use repository pattern for user updates
    user_repo = UserRepository(db)

    # Get the user
    user = await user_repo.get_by_id(current_user.id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    # Update user fields
    update_data = user_update.dict(exclude_unset=True)
    for field, value in update_data.items():
        if hasattr(user, field):
            setattr(user, field, value)

    # Save changes
    updated_user = await user_repo.update(user)
    await db.commit()

    return UserResponse(
        id=updated_user.id,
        email=updated_user.email,
        full_name=updated_user.full_name,
        is_active=updated_user.is_active,
        is_verified=updated_user.is_verified,
        roles=[role.name for role in updated_user.roles] if updated_user.roles else [],
        created_at=(
            updated_user.created_at.isoformat() if updated_user.created_at else None
        ),
        updated_at=(
            updated_user.updated_at.isoformat() if updated_user.updated_at else None
        ),
        last_login=(
            updated_user.last_login.isoformat() if updated_user.last_login else None
        ),
    )


@router.get("/", response_model=UserListResponse)
async def list_users(
    skip: int = Query(0, ge=0, description="Number of users to skip"),
    limit: int = Query(100, ge=1, le=1000, description="Number of users to return"),
    search: Optional[str] = Query(None, description="Search users by email or name"),
    role: Optional[str] = Query(None, description="Filter by role"),
    is_active: Optional[bool] = Query(None, description="Filter by active status"),
    current_user: CurrentUser = Depends(require_permissions(["users:read"])),
    db: AsyncSession = Depends(get_db_session),
) -> UserListResponse:
    """
    List users (Admin only).

    Returns paginated list of users with optional filtering.
    Requires admin permissions.

    Args:
        skip: Number of users to skip for pagination
        limit: Maximum number of users to return
        search: Search term for email or name
        role: Filter by user role
        is_active: Filter by active status
        db: Database session

    Returns:
        UserListResponse: Paginated list of users

    Raises:
        HTTPException: If user doesn't have admin permissions
    """
    logger.info(
        "User list requested",
        skip=skip,
        limit=limit,
        search=search,
        role=role,
        is_active=is_active,
    )

    # Use repository pattern for user listing
    user_repo = UserRepository(db)

    # Build query with filters
    query = select(User).options(selectinload(User.roles))

    if search:
        search_filter = f"%{search}%"
        query = query.where(
            (User.email.ilike(search_filter))
            | (User.full_name.ilike(search_filter))
            | (User.first_name.ilike(search_filter))
            | (User.last_name.ilike(search_filter))
        )

    if is_active is not None:
        query = query.where(User.is_active == is_active)

    # Get total count
    count_query = select(func.count()).select_from(User)
    if search or is_active is not None:
        count_query = query.with_only_columns(func.count())
    total_result = await db.execute(count_query)
    total = total_result.scalar()

    # Apply pagination
    query = query.offset(skip).limit(limit)

    # Execute query
    result = await db.execute(query)
    users_db = result.scalars().all()

    # Convert to response format
    users = [
        UserResponse(
            id=str(user.id),
            email=user.email,
            full_name=user.full_name,
            is_active=user.is_active,
            is_verified=user.is_verified,
            roles=[role.name for role in user.roles] if user.roles else [],
            created_at=user.created_at.isoformat() if user.created_at else None,
            updated_at=user.updated_at.isoformat() if user.updated_at else None,
            last_login=user.last_login.isoformat() if user.last_login else None,
        )
        for user in users_db
    ]

    return UserListResponse(users=users, total=total, skip=skip, limit=limit)


@router.get("/{user_id}", response_model=UserResponse)
async def get_user(
    user_id: str,
    current_user: CurrentUser = Depends(require_permissions(["users:read"])),
    db: AsyncSession = Depends(get_db_session),
) -> UserResponse:
    """
    Get user by ID (Admin only).

    Returns user information by ID. Requires admin permissions.

    Args:
        user_id: User ID to retrieve
        current_user: Current authenticated user with permissions
        db: Database session

    Returns:
        UserResponse: User information

    Raises:
        HTTPException: If user not found or insufficient permissions
    """
    logger.info("User details requested", user_id=user_id)

    # Use repository pattern to get user
    user_repo = UserRepository(db)
    user = await user_repo.get_by_id(user_id)

    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    return UserResponse(
        id=str(user.id),
        email=user.email,
        full_name=user.full_name,
        is_active=user.is_active,
        is_verified=user.is_verified,
        roles=[role.name for role in user.roles] if user.roles else [],
        created_at=user.created_at.isoformat() if user.created_at else None,
        updated_at=user.updated_at.isoformat() if user.updated_at else None,
        last_login=user.last_login.isoformat() if user.last_login else None,
    )


@router.put("/{user_id}", response_model=UserResponse)
async def update_user(
    user_id: str,
    user_update: UserUpdate,
    current_user: CurrentUser = Depends(require_permissions(["users:write"])),
    db: AsyncSession = Depends(get_db_session),
) -> UserResponse:
    """
    Update user by ID (Admin only).

    Updates user information by ID. Requires admin permissions.

    Args:
        user_id: User ID to update
        user_update: User update data
        current_user: Current authenticated user with permissions
        db: Database session

    Returns:
        UserResponse: Updated user information

    Raises:
        HTTPException: If user not found or insufficient permissions
    """
    logger.info("User update requested", user_id=user_id)

    # Use repository pattern for user updates
    user_repo = UserRepository(db)

    # Get the user
    user = await user_repo.get_by_id(user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    # Update user fields
    update_data = user_update.dict(exclude_unset=True)
    for field, value in update_data.items():
        if hasattr(user, field):
            setattr(user, field, value)

    # Save changes
    updated_user = await user_repo.update(user)
    await db.commit()

    return UserResponse(
        id=str(updated_user.id),
        email=updated_user.email,
        full_name=updated_user.full_name,
        is_active=updated_user.is_active,
        is_verified=updated_user.is_verified,
        roles=[role.name for role in updated_user.roles] if updated_user.roles else [],
        created_at=(
            updated_user.created_at.isoformat() if updated_user.created_at else None
        ),
        updated_at=(
            updated_user.updated_at.isoformat() if updated_user.updated_at else None
        ),
        last_login=(
            updated_user.last_login.isoformat() if updated_user.last_login else None
        ),
    )


@router.delete("/{user_id}")
async def delete_user(
    user_id: str,
    current_user: CurrentUser = Depends(require_permissions(["users:delete"])),
    db: AsyncSession = Depends(get_db_session),
) -> dict:
    """
    Delete user by ID (Admin only).

    Soft deletes user account. Requires admin permissions.

    Args:
        user_id: User ID to delete
        current_user: Current authenticated user with permissions
        db: Database session

    Returns:
        dict: Success message

    Raises:
        HTTPException: If user not found or insufficient permissions
    """
    logger.info("User deletion requested", user_id=user_id)

    # Use repository pattern for user deletion
    user_repo = UserRepository(db)

    # Get the user
    user = await user_repo.get_by_id(user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    # Soft delete user (set is_active=False)
    user.is_active = False
    await user_repo.update(user)

    # TODO: Invalidate all user sessions using SessionRepository

    await db.commit()

    return {"message": f"User {user_id} has been deleted"}


@router.post("/{user_id}/activate")
async def activate_user(
    user_id: str,
    current_user: CurrentUser = Depends(require_permissions(["users:write"])),
    db: AsyncSession = Depends(get_db_session),
) -> dict:
    """
    Activate user account (Admin only).

    Activates a deactivated user account. Requires admin permissions.

    Args:
        user_id: User ID to activate
        db: Database session

    Returns:
        dict: Success message

    Raises:
        HTTPException: If user not found or insufficient permissions
    """
    logger.info("User activation requested", user_id=user_id)

    # Use repository pattern for user activation
    user_repo = UserRepository(db)

    # Get the user
    user = await user_repo.get_by_id(user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    # Activate user
    user.is_active = True
    user.is_verified = True  # Also verify on activation
    await user_repo.update(user)
    await db.commit()

    return {"message": f"User {user_id} has been activated"}


@router.post("/{user_id}/deactivate")
async def deactivate_user(
    user_id: str,
    current_user: CurrentUser = Depends(require_permissions(["users:write"])),
    db: AsyncSession = Depends(get_db_session),
) -> dict:
    """
    Deactivate user account (Admin only).

    Deactivates a user account. Requires admin permissions.

    Args:
        user_id: User ID to deactivate
        current_user: Current authenticated user with permissions
        db: Database session

    Returns:
        dict: Success message

    Raises:
        HTTPException: If user not found or insufficient permissions
    """
    logger.info("User deactivation requested", user_id=user_id)

    # Use repository pattern for user deactivation
    user_repo = UserRepository(db)

    # Get the user
    user = await user_repo.get_by_id(user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    # Deactivate user
    user.is_active = False
    await user_repo.update(user)

    # TODO: Invalidate all user sessions using SessionRepository

    await db.commit()

    return {"message": f"User {user_id} has been deactivated"}


@router.put("/{user_id}/roles")
async def update_user_roles(
    user_id: str,
    roles: List[str],
    current_user: CurrentUser = Depends(require_permissions(["roles:manage"])),
    db: AsyncSession = Depends(get_db_session),
) -> UserResponse:
    """
    Update user roles (Admin only).

    Updates user role assignments. Requires admin permissions.

    Args:
        user_id: User ID to update
        roles: List of role names to assign
        current_user: Current authenticated user with permissions
        db: Database session

    Returns:
        UserResponse: Updated user information

    Raises:
        HTTPException: If user not found, invalid roles, or insufficient permissions
    """
    logger.info("User roles update requested", user_id=user_id, roles=roles)

    # Use repository pattern for role updates
    user_repo = UserRepository(db)
    role_repo = RoleRepository(db)

    # Get the user
    user = await user_repo.get_by_id(user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    # Validate and get role objects
    role_objects = []
    for role_name in roles:
        role = await role_repo.get_by_name(role_name)
        if not role:
            raise HTTPException(status_code=400, detail=f"Role '{role_name}' not found")
        role_objects.append(role)

    # Update user roles
    user.roles = role_objects
    updated_user = await user_repo.update(user)
    await db.commit()

    return UserResponse(
        id=str(updated_user.id),
        email=updated_user.email,
        full_name=updated_user.full_name,
        is_active=updated_user.is_active,
        is_verified=updated_user.is_verified,
        roles=[role.name for role in updated_user.roles] if updated_user.roles else [],
        created_at=(
            updated_user.created_at.isoformat() if updated_user.created_at else None
        ),
        updated_at=(
            updated_user.updated_at.isoformat() if updated_user.updated_at else None
        ),
        last_login=(
            updated_user.last_login.isoformat() if updated_user.last_login else None
        ),
    )
