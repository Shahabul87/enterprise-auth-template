"""
User Service Module

Refactored user services split into focused, single-responsibility classes:
- UserCRUDService: User creation, retrieval, updating operations
- UserAuthService: Authentication, password management, token handling
- UserPermissionService: Permission checking and role management

This refactoring addresses the code quality issue of having 1000+ line service files
by breaking them into focused, maintainable modules.
"""

from .user_auth_service import UserAuthService
from .user_crud_service import UserCRUDService
from .user_permission_service import UserPermissionService

__all__ = ["UserCRUDService", "UserAuthService", "UserPermissionService"]
