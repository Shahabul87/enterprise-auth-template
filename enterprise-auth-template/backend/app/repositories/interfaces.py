"""
Repository Interfaces

Defines abstract interfaces for all repository classes following the Repository Pattern.
These interfaces ensure consistent data access patterns and enable dependency inversion.
"""

from typing import Protocol, Optional, List, Dict, Any
from datetime import datetime
from uuid import UUID


class IUserRepository(Protocol):
    """Interface for User repository operations."""

    async def find_by_id(self, user_id: UUID) -> Optional[Any]:
        """Find a user by their ID."""
        ...

    async def find_by_email(self, email: str) -> Optional[Any]:
        """Find a user by their email address."""
        ...

    async def find_by_username(self, username: str) -> Optional[Any]:
        """Find a user by their username."""
        ...

    async def create(self, user_data: Dict[str, Any]) -> Any:
        """Create a new user."""
        ...

    async def update(self, user_id: UUID, user_data: Dict[str, Any]) -> Optional[Any]:
        """Update an existing user."""
        ...

    async def delete(self, user_id: UUID) -> bool:
        """Delete a user by their ID."""
        ...

    async def list_all(self, skip: int = 0, limit: int = 100) -> List[Any]:
        """List all users with pagination."""
        ...

    async def find_by_phone(self, phone_number: str) -> Optional[Any]:
        """Find a user by their phone number."""
        ...

    async def find_by_oauth_provider(
        self, provider: str, provider_id: str
    ) -> Optional[Any]:
        """Find a user by OAuth provider and provider ID."""
        ...

    async def count(self) -> int:
        """Count total number of users."""
        ...

    async def exists_by_email(self, email: str) -> bool:
        """Check if a user exists with the given email."""
        ...

    async def update_last_login(self, user_id: UUID, login_time: datetime) -> bool:
        """Update user's last login timestamp."""
        ...

    async def update_password(self, user_id: UUID, hashed_password: str) -> bool:
        """Update user's password."""
        ...

    async def increment_failed_attempts(self, user_id: UUID) -> int:
        """Increment failed login attempts and return new count."""
        ...

    async def reset_failed_attempts(self, user_id: UUID) -> bool:
        """Reset failed login attempts to zero."""
        ...

    async def lock_account(self, user_id: UUID, until: datetime) -> bool:
        """Lock user account until specified time."""
        ...


class IRoleRepository(Protocol):
    """Interface for Role repository operations."""

    async def find_by_id(self, role_id: UUID) -> Optional[Any]:
        """Find a role by ID."""
        ...

    async def find_by_name(self, name: str) -> Optional[Any]:
        """Find a role by name."""
        ...

    async def create(self, role_data: Dict[str, Any]) -> Any:
        """Create a new role."""
        ...

    async def update(self, role_id: UUID, role_data: Dict[str, Any]) -> Optional[Any]:
        """Update an existing role."""
        ...

    async def delete(self, role_id: UUID) -> bool:
        """Delete a role."""
        ...

    async def list_all(self) -> List[Any]:
        """List all roles."""
        ...

    async def assign_to_user(self, user_id: UUID, role_id: UUID) -> bool:
        """Assign a role to a user."""
        ...

    async def remove_from_user(self, user_id: UUID, role_id: UUID) -> bool:
        """Remove a role from a user."""
        ...

    async def get_user_roles(self, user_id: UUID) -> List[Any]:
        """Get all roles assigned to a user."""
        ...

    async def get_role_users(self, role_id: UUID) -> List[Any]:
        """Get all users with a specific role."""
        ...


class ISessionRepository(Protocol):
    """Interface for Session repository operations."""

    async def create(self, session_data: Dict[str, Any]) -> Any:
        """Create a new session."""
        ...

    async def find_by_id(self, session_id: str) -> Optional[Any]:
        """Find a session by ID."""
        ...

    async def find_by_user(self, user_id: UUID) -> List[Any]:
        """Find all sessions for a user."""
        ...

    async def update(
        self, session_id: str, session_data: Dict[str, Any]
    ) -> Optional[Any]:
        """Update session data."""
        ...

    async def delete(self, session_id: str) -> bool:
        """Delete a session."""
        ...

    async def delete_user_sessions(self, user_id: UUID) -> int:
        """Delete all sessions for a user. Returns count of deleted sessions."""
        ...

    async def find_active_sessions(self, user_id: UUID) -> List[Any]:
        """Find all active sessions for a user."""
        ...

    async def expire_session(self, session_id: str) -> bool:
        """Mark a session as expired."""
        ...

    async def extend_session(self, session_id: str, expires_at: datetime) -> bool:
        """Extend session expiration time."""
        ...

    async def cleanup_expired(self) -> int:
        """Clean up expired sessions. Returns count of deleted sessions."""
        ...


class IPermissionRepository(Protocol):
    """Interface for Permission repository operations."""

    async def find_by_id(self, permission_id: UUID) -> Optional[Any]:
        """Find a permission by ID."""
        ...

    async def find_by_name(self, resource: str, action: str) -> Optional[Any]:
        """Find a permission by resource and action."""
        ...

    async def create(self, permission_data: Dict[str, Any]) -> Any:
        """Create a new permission."""
        ...

    async def list_all(self) -> List[Any]:
        """List all permissions."""
        ...

    async def get_role_permissions(self, role_id: UUID) -> List[Any]:
        """Get all permissions for a role."""
        ...

    async def get_user_permissions(self, user_id: UUID) -> List[Any]:
        """Get all permissions for a user (through roles)."""
        ...

    async def assign_to_role(self, role_id: UUID, permission_id: UUID) -> bool:
        """Assign a permission to a role."""
        ...

    async def remove_from_role(self, role_id: UUID, permission_id: UUID) -> bool:
        """Remove a permission from a role."""
        ...

    async def user_has_permission(
        self, user_id: UUID, resource: str, action: str
    ) -> bool:
        """Check if a user has a specific permission."""
        ...


class IAuditLogRepository(Protocol):
    """Interface for Audit Log repository operations."""

    async def create(self, audit_data: Dict[str, Any]) -> Any:
        """Create a new audit log entry."""
        ...

    async def find_by_id(self, log_id: UUID) -> Optional[Any]:
        """Find an audit log entry by ID."""
        ...

    async def find_by_user(
        self,
        user_id: UUID,
        skip: int = 0,
        limit: int = 100,
        start_date: Optional[datetime] = None,
        end_date: Optional[datetime] = None,
    ) -> List[Any]:
        """Find audit logs for a specific user."""
        ...

    async def find_by_action(
        self,
        action: str,
        skip: int = 0,
        limit: int = 100,
        start_date: Optional[datetime] = None,
        end_date: Optional[datetime] = None,
    ) -> List[Any]:
        """Find audit logs by action type."""
        ...

    async def find_by_resource(
        self, resource_type: str, resource_id: str, skip: int = 0, limit: int = 100
    ) -> List[Any]:
        """Find audit logs for a specific resource."""
        ...

    async def find_by_ip_address(
        self, ip_address: str, skip: int = 0, limit: int = 100
    ) -> List[Any]:
        """Find audit logs from a specific IP address."""
        ...

    async def cleanup_old_logs(self, older_than: datetime) -> int:
        """Delete audit logs older than specified date. Returns count of deleted logs."""
        ...
