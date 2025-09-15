"""
Repository Pattern Implementation

This module provides abstract repository interfaces and concrete implementations
following the Repository Pattern to abstract data access from business logic.
"""

from typing import Protocol, Optional, List, Any, Dict
from abc import abstractmethod
from uuid import UUID

# Re-export all repository interfaces and implementations
from .interfaces import (
    IUserRepository,
    IRoleRepository,
    ISessionRepository,
    IPermissionRepository,
    IAuditLogRepository,
)

from .user_repository import UserRepository
from .role_repository import RoleRepository
from .session_repository import SessionRepository

__all__ = [
    # Interfaces
    "IUserRepository",
    "IRoleRepository",
    "ISessionRepository",
    "IPermissionRepository",
    "IAuditLogRepository",
    # Implementations
    "UserRepository",
    "RoleRepository",
    "SessionRepository",
]