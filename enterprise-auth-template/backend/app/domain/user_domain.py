"""
User Domain Model

Rich domain model for User entity with business logic and validation.
This follows Domain-Driven Design principles by encapsulating business rules.
"""

from datetime import datetime, timedelta
from typing import List, Optional, Tuple, Set
import re
from uuid import UUID, uuid4

from app.core.security import get_password_hash, verify_password


class PasswordPolicy:
    """Password policy rules and validation."""

    MIN_LENGTH = 8
    MAX_LENGTH = 128
    REQUIRE_UPPERCASE = True
    REQUIRE_LOWERCASE = True
    REQUIRE_DIGIT = True
    REQUIRE_SPECIAL = True
    SPECIAL_CHARS = "!@#$%^&*()_+-=[]{}|;:,.<>?"

    @classmethod
    def validate(cls, password: str) -> Tuple[bool, List[str]]:
        """
        Validate password against policy.

        Args:
            password: Password to validate

        Returns:
            Tuple of (is_valid, list_of_issues)
        """
        issues = []

        if len(password) < cls.MIN_LENGTH:
            issues.append(f"Password must be at least {cls.MIN_LENGTH} characters")

        if len(password) > cls.MAX_LENGTH:
            issues.append(f"Password must be less than {cls.MAX_LENGTH} characters")

        if cls.REQUIRE_UPPERCASE and not re.search(r"[A-Z]", password):
            issues.append("Password must contain at least one uppercase letter")

        if cls.REQUIRE_LOWERCASE and not re.search(r"[a-z]", password):
            issues.append("Password must contain at least one lowercase letter")

        if cls.REQUIRE_DIGIT and not re.search(r"\d", password):
            issues.append("Password must contain at least one digit")

        if cls.REQUIRE_SPECIAL and not re.search(
            f"[{re.escape(cls.SPECIAL_CHARS)}]", password
        ):
            issues.append("Password must contain at least one special character")

        return len(issues) == 0, issues


class UserDomain:
    """
    Rich domain model for User entity.

    Encapsulates business logic and validation rules for users.
    """

    def __init__(
        self,
        email: str,
        full_name: str,
        id: Optional[UUID] = None,
        hashed_password: Optional[str] = None,
        is_active: bool = True,
        is_verified: bool = False,
        is_superuser: bool = False,
        roles: Optional[List] = None,
        permissions: Optional[Set[str]] = None,
        failed_login_attempts: int = 0,
        locked_until: Optional[datetime] = None,
        created_at: Optional[datetime] = None,
        updated_at: Optional[datetime] = None,
        last_login: Optional[datetime] = None,
    ):
        """Initialize user domain model with validation."""
        self.id = id or uuid4()
        self.email = self._validate_email(email)
        self.full_name = self._validate_name(full_name, "Full name")
        self.hashed_password = hashed_password
        self.is_active = is_active
        self.is_verified = is_verified
        self.is_superuser = is_superuser
        self.roles = roles or []
        self.permissions = permissions or set()
        self.failed_login_attempts = failed_login_attempts
        self.locked_until = locked_until
        self.created_at = created_at or datetime.utcnow()
        self.updated_at = updated_at
        self.last_login = last_login

    @staticmethod
    def _validate_email(email: str) -> str:
        """
        Validate email format.

        Args:
            email: Email to validate

        Returns:
            Validated email

        Raises:
            ValueError: If email is invalid
        """
        email = email.strip().lower()
        email_regex = r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"

        if not re.match(email_regex, email):
            raise ValueError("Invalid email format")

        if len(email) > 255:
            raise ValueError("Email must be less than 255 characters")

        return email

    @staticmethod
    def _validate_name(name: str, field: str, required: bool = True) -> str:
        """
        Validate name fields.

        Args:
            name: Name to validate
            field: Field name for error messages
            required: Whether field is required

        Returns:
            Validated name

        Raises:
            ValueError: If name is invalid
        """
        if not name and not required:
            return ""

        if not name and required:
            raise ValueError(f"{field} is required")

        name = name.strip()

        if len(name) > 100:
            raise ValueError(f"{field} must be less than 100 characters")

        if not re.match(r"^[a-zA-Z\s\-']+$", name):
            raise ValueError(f"{field} contains invalid characters")

        return name

    @property
    def is_locked(self) -> bool:
        """Check if account is currently locked."""
        if not self.locked_until:
            return False
        return datetime.utcnow() < self.locked_until

    def set_password(self, password: str) -> None:
        """
        Set user password with validation.

        Args:
            password: Plain text password

        Raises:
            ValueError: If password doesn't meet policy
        """
        is_valid, issues = PasswordPolicy.validate(password)
        if not is_valid:
            raise ValueError(f"Password validation failed: {', '.join(issues)}")

        self.hashed_password = get_password_hash(password)
        self.updated_at = datetime.utcnow()

    def verify_password(self, password: str) -> bool:
        """
        Verify password against hash.

        Args:
            password: Plain text password to verify

        Returns:
            bool: True if password matches
        """
        if not self.hashed_password:
            return False
        return verify_password(password, self.hashed_password)

    def change_password(self, current_password: str, new_password: str) -> bool:
        """
        Change user password with verification.

        Args:
            current_password: Current password for verification
            new_password: New password to set

        Returns:
            bool: True if password changed successfully

        Raises:
            ValueError: If validation fails
        """
        if not self.verify_password(current_password):
            raise ValueError("Current password is incorrect")

        if current_password == new_password:
            raise ValueError("New password must be different from current password")

        self.set_password(new_password)
        return True

    def has_permission(self, permission: str) -> bool:
        """
        Check if user has a specific permission.

        Args:
            permission: Permission to check (format: "resource:action")

        Returns:
            bool: True if user has permission
        """
        # Superuser has all permissions
        if self.is_superuser:
            return True

        # Check direct permissions
        if permission in self.permissions:
            return True

        # Check wildcard permissions
        resource, action = (
            permission.split(":") if ":" in permission else (permission, "*")
        )

        # Check for resource-level wildcard
        if f"{resource}:*" in self.permissions:
            return True

        # Check for global wildcard
        if "*:*" in self.permissions or "*" in self.permissions:
            return True

        return False

    def has_any_permission(self, permissions: List[str]) -> bool:
        """
        Check if user has any of the specified permissions.

        Args:
            permissions: List of permissions to check

        Returns:
            bool: True if user has at least one permission
        """
        return any(self.has_permission(perm) for perm in permissions)

    def has_all_permissions(self, permissions: List[str]) -> bool:
        """
        Check if user has all specified permissions.

        Args:
            permissions: List of permissions to check

        Returns:
            bool: True if user has all permissions
        """
        return all(self.has_permission(perm) for perm in permissions)

    def has_role(self, role_name: str) -> bool:
        """
        Check if user has a specific role.

        Args:
            role_name: Role name to check

        Returns:
            bool: True if user has role
        """
        return any(role.name == role_name for role in self.roles)

    def has_any_role(self, role_names: List[str]) -> bool:
        """
        Check if user has any of the specified roles.

        Args:
            role_names: List of role names to check

        Returns:
            bool: True if user has at least one role
        """
        return any(self.has_role(role) for role in role_names)

    def record_failed_login(
        self, max_attempts: int = 5
    ) -> Tuple[bool, Optional[datetime]]:
        """
        Record a failed login attempt.

        Args:
            max_attempts: Maximum attempts before lockout

        Returns:
            Tuple of (should_lock, lock_until)
        """
        self.failed_login_attempts += 1

        if self.failed_login_attempts >= max_attempts:
            lock_until = datetime.utcnow() + timedelta(minutes=30)
            self.locked_until = lock_until
            return True, lock_until

        return False, None

    def reset_failed_attempts(self) -> None:
        """Reset failed login attempts after successful login."""
        self.failed_login_attempts = 0
        self.locked_until = None

    def record_login(self, ip_address: Optional[str] = None) -> None:
        """
        Record successful login.

        Args:
            ip_address: IP address of login
        """
        self.last_login = datetime.utcnow()
        self.reset_failed_attempts()

    def can_reset_password(self) -> bool:
        """
        Check if user can reset password.

        Returns:
            bool: True if password reset is allowed
        """
        if not self.is_active:
            return False

        if self.is_locked:
            return False

        return True

    def activate(self) -> None:
        """Activate user account."""
        self.is_active = True
        self.updated_at = datetime.utcnow()

    def deactivate(self) -> None:
        """Deactivate user account."""
        self.is_active = False
        self.updated_at = datetime.utcnow()

    def verify_email(self) -> None:
        """Mark email as verified."""
        self.is_verified = True
        self.is_active = True  # Auto-activate on verification
        self.updated_at = datetime.utcnow()

    def to_dict(self) -> dict:
        """
        Convert domain model to dictionary for persistence.

        Returns:
            Dictionary representation
        """
        return {
            "id": self.id,
            "email": self.email,
            "full_name": self.full_name,
            "hashed_password": self.hashed_password,
            "is_active": self.is_active,
            "is_verified": self.is_verified,
            "is_superuser": self.is_superuser,
            "failed_login_attempts": self.failed_login_attempts,
            "locked_until": self.locked_until,
            "created_at": self.created_at,
            "updated_at": self.updated_at,
            "last_login": self.last_login,
        }

    @classmethod
    def from_entity(cls, entity) -> "UserDomain":
        """
        Create domain model from database entity.

        Args:
            entity: Database entity

        Returns:
            UserDomain instance
        """
        return cls(
            id=entity.id,
            email=entity.email,
            full_name=entity.full_name,
            hashed_password=entity.hashed_password,
            is_active=entity.is_active,
            is_verified=entity.is_verified,
            is_superuser=entity.is_superuser,
            roles=entity.roles if hasattr(entity, "roles") else [],
            permissions=(
                set(entity.get_permissions())
                if hasattr(entity, "get_permissions")
                else set()
            ),
            failed_login_attempts=entity.failed_login_attempts,
            locked_until=entity.locked_until,
            created_at=entity.created_at,
            updated_at=entity.updated_at,
            last_login=entity.last_login,
        )
