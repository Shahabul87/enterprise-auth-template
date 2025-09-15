"""
Authentication Dependencies

FastAPI dependencies for handling authentication and authorization
with proper type safety and error handling.
"""

from typing import List, Optional

import structlog
from fastapi import Depends, HTTPException, Request, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.core.database import get_db_session
from app.core.security import TokenData, check_permission, verify_token
from app.models.user import User
from app.models.role import Role

logger = structlog.get_logger(__name__)

# HTTP Bearer token scheme
bearer_scheme = HTTPBearer(auto_error=False)


class CurrentUser:
    """Type-safe current user data structure."""

    def __init__(
        self,
        id: str,
        email: str,
        first_name: str,
        last_name: str,
        is_active: bool,
        is_verified: bool,
        is_superuser: bool,
        roles: List[str],
        permissions: List[str],
    ) -> None:
        self.id = id
        self.email = email
        self.first_name = first_name
        self.last_name = last_name
        self.is_active = is_active
        self.is_verified = is_verified
        self.is_superuser = is_superuser
        self.roles = roles
        self.permissions = permissions

    def has_permission(self, required_permission: str) -> bool:
        """Check if user has specific permission."""
        return check_permission(self.permissions, required_permission)

    def has_role(self, required_role: str) -> bool:
        """Check if user has specific role."""
        return required_role in self.roles

    def has_any_role(self, required_roles: List[str]) -> bool:
        """Check if user has any of the specified roles."""
        return any(role in self.roles for role in required_roles)


async def get_current_user(
    request: Request,
    credentials: Optional[HTTPAuthorizationCredentials] = Depends(bearer_scheme),
    db: AsyncSession = Depends(get_db_session),
) -> CurrentUser:
    """
    Get current authenticated user from JWT token (Bearer header or httpOnly cookie).

    Enterprise authentication with multiple token sources:
    - Primary: httpOnly cookies (secure, XSS-resistant)
    - Fallback: Authorization Bearer header (for API clients)
    - Comprehensive token validation and user state verification

    Args:
        request: FastAPI request object
        credentials: HTTP bearer credentials (optional)
        db: Database session

    Returns:
        CurrentUser: Current user information

    Raises:
        HTTPException: If authentication fails
    """
    access_token: Optional[str] = None
    token_source = "unknown"

    # Try to get token from httpOnly cookie first (preferred method)
    cookie_token = request.cookies.get("access_token")
    if cookie_token:
        access_token = cookie_token
        token_source = "httpOnly_cookie"
        logger.debug("Token extracted from httpOnly cookie", path=request.url.path)

    # Fallback to Authorization header
    elif credentials and credentials.credentials:
        access_token = credentials.credentials
        token_source = "bearer_header"
        logger.debug("Token extracted from Authorization header", path=request.url.path)

    # No token found in either source
    if not access_token:
        logger.warning(
            "Missing authentication credentials",
            path=request.url.path,
            method=request.method,
            has_cookie=bool(cookie_token),
            has_bearer=bool(credentials),
        )
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authentication credentials required. Please log in.",
            headers={"WWW-Authenticate": "Bearer"},
        )

    # Verify access token
    token_data: Optional[TokenData] = verify_token(access_token, "access")
    if not token_data:
        logger.warning(
            "Invalid access token",
            path=request.url.path,
            method=request.method,
            token_source=token_source,
        )
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired token. Please log in again.",
            headers={"WWW-Authenticate": "Bearer"},
        )

    try:
        # Get user from database with current data
        stmt = (
            select(User)
            .options(selectinload(User.roles).selectinload(Role.permissions))
            .where(User.id == token_data.sub)
        )
        result = await db.execute(stmt)
        user = result.scalar_one_or_none()

        if not user:
            logger.warning(
                "User not found for valid token",
                user_id=token_data.sub,
                path=request.url.path,
            )
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="User not found",
                headers={"WWW-Authenticate": "Bearer"},
            )

        if not user.is_active:
            logger.warning(
                "Inactive user attempted access",
                user_id=str(user.id),
                email=user.email,
                path=request.url.path,
            )
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Account is not active",
                headers={"WWW-Authenticate": "Bearer"},
            )

        # Import settings to check if email verification is required
        from app.core.config import get_settings
        settings = get_settings()

        if settings.should_enforce_email_verification() and not user.email_verified:
            logger.warning(
                "Unverified user attempted access",
                user_id=str(user.id),
                email=user.email,
                path=request.url.path,
                verification_enforced=settings.should_enforce_email_verification(),
            )
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Email address is not verified",
                headers={"WWW-Authenticate": "Bearer"},
            )

        # Get current permissions (in case roles changed since token was issued)
        current_permissions = user.get_permissions()
        role_names = [role.name for role in user.roles]

        logger.debug(
            "User authenticated successfully",
            user_id=str(user.id),
            email=user.email,
            roles=role_names,
            path=request.url.path,
            token_source=token_source,
        )

        # Extract first_name and last_name from full_name
        full_name = user.full_name or ""
        name_parts = full_name.split()
        first_name = name_parts[0] if name_parts else ""
        last_name = " ".join(name_parts[1:]) if len(name_parts) > 1 else ""

        return CurrentUser(
            id=str(user.id),
            email=user.email,
            first_name=first_name,
            last_name=last_name,
            is_active=user.is_active,
            is_verified=user.email_verified,
            is_superuser=user.is_superuser,
            roles=role_names,
            permissions=current_permissions,
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(
            "Authentication error",
            user_id=token_data.sub,
            error=str(e),
            path=request.url.path,
        )
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Authentication service error",
        )


async def get_current_user_optional(
    request: Request,
    credentials: Optional[HTTPAuthorizationCredentials] = Depends(bearer_scheme),
    db: AsyncSession = Depends(get_db_session),
) -> Optional[CurrentUser]:
    """
    Get current authenticated user from JWT token (optional) - supports cookies and bearer.

    Returns None if no valid authentication is provided.
    Supports both httpOnly cookies and Authorization Bearer tokens.

    Args:
        request: FastAPI request object
        credentials: HTTP bearer credentials
        db: Database session

    Returns:
        Optional[CurrentUser]: Current user information or None
    """
    access_token: Optional[str] = None

    # Try to get token from httpOnly cookie first
    cookie_token = request.cookies.get("access_token")
    if cookie_token:
        access_token = cookie_token
    # Fallback to Authorization header
    elif credentials and credentials.credentials:
        access_token = credentials.credentials

    if not access_token:
        return None

    try:
        # Verify access token
        token_data: Optional[TokenData] = verify_token(access_token, "access")
        if not token_data:
            return None

        # Get user from database with roles
        stmt = (
            select(User)
            .where(User.id == token_data.sub)
            .options(selectinload(User.roles).selectinload(Role.permissions))
        )
        result = await db.execute(stmt)
        user = result.scalar_one_or_none()

        if not user or not user.is_active:
            return None

        # Extract roles and permissions
        roles = [role.name for role in user.roles] if user.roles else []
        permissions = []
        if user.roles:
            for role in user.roles:
                if role.permissions:
                    permissions.extend([perm.name for perm in role.permissions])
        permissions = list(set(permissions))  # Remove duplicates

        # Extract first_name and last_name from full_name
        full_name = user.full_name or ""
        name_parts = full_name.split()
        first_name = name_parts[0] if name_parts else ""
        last_name = " ".join(name_parts[1:]) if len(name_parts) > 1 else ""

        # Create CurrentUser instance
        return CurrentUser(
            id=str(user.id),
            email=user.email,
            first_name=first_name,
            last_name=last_name,
            is_active=user.is_active,
            is_verified=user.email_verified,
            is_superuser=user.is_superuser,
            roles=roles,
            permissions=permissions,
        )

    except Exception:
        # Any error means no valid authentication
        return None


async def get_current_active_user(
    current_user: CurrentUser = Depends(get_current_user),
) -> CurrentUser:
    """
    Get current active user (redundant check, but explicit).

    Args:
        current_user: Current user from authentication

    Returns:
        CurrentUser: Active user
    """
    # Additional check (though get_current_user already checks this)
    if not current_user.is_active:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Account is not active",
        )

    return current_user


def require_permissions(required_permissions: List[str]):
    """
    Create dependency that requires specific permissions.

    Args:
        required_permissions: List of required permissions

    Returns:
        Dependency function
    """

    async def permission_dependency(
        current_user: CurrentUser = Depends(get_current_user),
    ) -> CurrentUser:
        """Check if user has required permissions."""

        # Super users have all permissions
        if current_user.is_superuser:
            return current_user

        # Check each required permission
        missing_permissions: List[str] = []
        for permission in required_permissions:
            if not current_user.has_permission(permission):
                missing_permissions.append(permission)

        if missing_permissions:
            logger.warning(
                "Permission denied",
                user_id=current_user.id,
                email=current_user.email,
                required_permissions=required_permissions,
                missing_permissions=missing_permissions,
                user_permissions=current_user.permissions[
                    :10
                ],  # Log first 10 permissions
            )
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Insufficient permissions. Missing: {', '.join(missing_permissions)}",
            )

        logger.debug(
            "Permission check passed",
            user_id=current_user.id,
            required_permissions=required_permissions,
        )

        return current_user

    return permission_dependency


def require_roles(required_roles: List[str]):
    """
    Create dependency that requires specific roles.

    Args:
        required_roles: List of required roles

    Returns:
        Dependency function
    """

    async def role_dependency(
        current_user: CurrentUser = Depends(get_current_user),
    ) -> CurrentUser:
        """Check if user has required roles."""

        # Super users bypass role checks
        if current_user.is_superuser:
            return current_user

        # Check if user has any of the required roles
        if not current_user.has_any_role(required_roles):
            logger.warning(
                "Role requirement not met",
                user_id=current_user.id,
                email=current_user.email,
                required_roles=required_roles,
                user_roles=current_user.roles,
            )
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Insufficient role. Required one of: {', '.join(required_roles)}",
            )

        logger.debug(
            "Role check passed",
            user_id=current_user.id,
            required_roles=required_roles,
            user_roles=current_user.roles,
        )

        return current_user

    return role_dependency


def require_admin():
    """
    Create dependency that requires admin role.

    Returns:
        Dependency function
    """
    return require_roles(["admin", "super_admin"])


def require_superuser():
    """
    Create dependency that requires superuser status.

    Returns:
        Dependency function
    """

    async def superuser_dependency(
        current_user: CurrentUser = Depends(get_current_user),
    ) -> CurrentUser:
        """Check if user is superuser."""

        if not current_user.is_superuser:
            logger.warning(
                "Superuser access denied",
                user_id=current_user.id,
                email=current_user.email,
                is_superuser=current_user.is_superuser,
            )
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Superuser access required",
            )

        return current_user

    return superuser_dependency


async def get_optional_current_user(
    request: Request,
    credentials: Optional[HTTPAuthorizationCredentials] = Depends(bearer_scheme),
    db: AsyncSession = Depends(get_db_session),
) -> Optional[CurrentUser]:
    """
    Get current user if authenticated, None otherwise.

    Used for endpoints that work differently for authenticated vs anonymous users.

    Args:
        request: FastAPI request object
        credentials: HTTP bearer credentials
        db: Database session

    Returns:
        Optional[CurrentUser]: Current user if authenticated, None otherwise
    """
    if not credentials:
        return None

    try:
        return await get_current_user(request, credentials, db)
    except HTTPException:
        # Log but don't raise for optional authentication
        logger.debug(
            "Optional authentication failed",
            path=request.url.path,
            method=request.method,
        )
        return None
    except Exception as e:
        logger.warning(
            "Optional authentication error",
            error=str(e),
            path=request.url.path,
        )
        return None


async def require_permission(
    user: User,
    permission: str,
    db: AsyncSession
) -> None:
    """
    Check if a user has a specific permission through their roles.

    Args:
        user: Current user
        permission: Permission name to check
        db: Database session

    Raises:
        HTTPException: If user doesn't have the permission
    """
    # Superusers have all permissions
    if user.is_superuser:
        return

    # Import here to avoid circular dependency
    from app.services.role_service import RoleService

    service = RoleService(db)
    has_permission = await service.user_has_permission(user.id, permission)

    if not has_permission:
        logger.warning(
            "Permission denied",
            user_id=str(user.id),
            permission=permission
        )
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=f"Permission denied: {permission}"
        )
