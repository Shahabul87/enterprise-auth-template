"""
Unit tests for UserDomain model

Tests the rich domain model with business logic and validation.
"""

import pytest
from datetime import datetime, timedelta
from uuid import uuid4

from app.domain.user_domain import UserDomain, PasswordPolicy


class TestPasswordPolicy:
    """Test cases for PasswordPolicy."""

    def test_validate_strong_password(self):
        """Test validation of a strong password."""
        is_valid, issues = PasswordPolicy.validate("StrongP@ssw0rd123")
        assert is_valid is True
        assert len(issues) == 0

    def test_validate_too_short(self):
        """Test validation of too short password."""
        is_valid, issues = PasswordPolicy.validate("Short1!")
        assert is_valid is False
        assert "at least 8 characters" in str(issues)

    def test_validate_no_uppercase(self):
        """Test validation of password without uppercase."""
        is_valid, issues = PasswordPolicy.validate("password123!")
        assert is_valid is False
        assert "uppercase letter" in str(issues)

    def test_validate_no_lowercase(self):
        """Test validation of password without lowercase."""
        is_valid, issues = PasswordPolicy.validate("PASSWORD123!")
        assert is_valid is False
        assert "lowercase letter" in str(issues)

    def test_validate_no_digit(self):
        """Test validation of password without digit."""
        is_valid, issues = PasswordPolicy.validate("StrongPassword!")
        assert is_valid is False
        assert "one digit" in str(issues)

    def test_validate_no_special_char(self):
        """Test validation of password without special character."""
        is_valid, issues = PasswordPolicy.validate("StrongPassword123")
        assert is_valid is False
        assert "special character" in str(issues)

    def test_validate_too_long(self):
        """Test validation of too long password."""
        long_password = "A" * 129 + "1!"
        is_valid, issues = PasswordPolicy.validate(long_password)
        assert is_valid is False
        assert "less than 128 characters" in str(issues)


class TestUserDomain:
    """Test cases for UserDomain model."""

    def test_create_user_valid(self):
        """Test creating a user with valid data."""
        user = UserDomain(
            email="test@example.com",
            first_name="John",
            last_name="Doe"
        )

        assert user.email == "test@example.com"
        assert user.first_name == "John"
        assert user.last_name == "Doe"
        assert user.full_name == "John Doe"
        assert user.is_active is True
        assert user.is_verified is False
        assert user.is_superuser is False

    def test_create_user_email_validation(self):
        """Test email validation during user creation."""
        # Invalid email format
        with pytest.raises(ValueError, match="Invalid email format"):
            UserDomain(
                email="invalid-email",
                first_name="John",
                last_name="Doe"
            )

        # Email too long
        long_email = "a" * 250 + "@example.com"
        with pytest.raises(ValueError, match="less than 255 characters"):
            UserDomain(
                email=long_email,
                first_name="John",
                last_name="Doe"
            )

    def test_create_user_name_validation(self):
        """Test name validation during user creation."""
        # First name required
        with pytest.raises(ValueError, match="First name is required"):
            UserDomain(
                email="test@example.com",
                first_name="",
                last_name="Doe"
            )

        # Name too long
        long_name = "A" * 101
        with pytest.raises(ValueError, match="less than 100 characters"):
            UserDomain(
                email="test@example.com",
                first_name=long_name,
                last_name="Doe"
            )

        # Invalid characters
        with pytest.raises(ValueError, match="invalid characters"):
            UserDomain(
                email="test@example.com",
                first_name="John123",
                last_name="Doe"
            )

    def test_email_normalization(self):
        """Test email normalization."""
        user = UserDomain(
            email="  TEST@EXAMPLE.COM  ",
            first_name="John",
            last_name="Doe"
        )
        assert user.email == "test@example.com"

    def test_set_password(self):
        """Test setting a password."""
        user = UserDomain(
            email="test@example.com",
            first_name="John",
            last_name="Doe"
        )

        user.set_password("StrongP@ssw0rd123")
        assert user.hashed_password is not None
        assert user.hashed_password != "StrongP@ssw0rd123"  # Should be hashed

    def test_set_password_weak(self):
        """Test setting a weak password."""
        user = UserDomain(
            email="test@example.com",
            first_name="John",
            last_name="Doe"
        )

        with pytest.raises(ValueError, match="Password validation failed"):
            user.set_password("weak")

    def test_verify_password(self):
        """Test password verification."""
        user = UserDomain(
            email="test@example.com",
            first_name="John",
            last_name="Doe"
        )

        user.set_password("StrongP@ssw0rd123")
        assert user.verify_password("StrongP@ssw0rd123") is True
        assert user.verify_password("WrongPassword") is False

    def test_change_password(self):
        """Test changing password."""
        user = UserDomain(
            email="test@example.com",
            first_name="John",
            last_name="Doe"
        )

        user.set_password("OldP@ssw0rd123")

        # Change with correct current password
        result = user.change_password("OldP@ssw0rd123", "NewP@ssw0rd456")
        assert result is True
        assert user.verify_password("NewP@ssw0rd456") is True
        assert user.verify_password("OldP@ssw0rd123") is False

    def test_change_password_wrong_current(self):
        """Test changing password with wrong current password."""
        user = UserDomain(
            email="test@example.com",
            first_name="John",
            last_name="Doe"
        )

        user.set_password("CurrentP@ssw0rd123")

        with pytest.raises(ValueError, match="Current password is incorrect"):
            user.change_password("WrongPassword", "NewP@ssw0rd456")

    def test_change_password_same_as_current(self):
        """Test changing password to same as current."""
        user = UserDomain(
            email="test@example.com",
            first_name="John",
            last_name="Doe"
        )

        user.set_password("CurrentP@ssw0rd123")

        with pytest.raises(ValueError, match="must be different"):
            user.change_password("CurrentP@ssw0rd123", "CurrentP@ssw0rd123")

    def test_has_permission(self):
        """Test permission checking."""
        user = UserDomain(
            email="test@example.com",
            first_name="John",
            last_name="Doe",
            permissions={"users:read", "users:write", "posts:*"}
        )

        # Direct permission
        assert user.has_permission("users:read") is True
        assert user.has_permission("users:write") is True

        # Wildcard permission
        assert user.has_permission("posts:read") is True
        assert user.has_permission("posts:write") is True
        assert user.has_permission("posts:delete") is True

        # No permission
        assert user.has_permission("admin:access") is False

    def test_has_permission_superuser(self):
        """Test superuser has all permissions."""
        user = UserDomain(
            email="test@example.com",
            first_name="John",
            last_name="Doe",
            is_superuser=True
        )

        assert user.has_permission("any:permission") is True
        assert user.has_permission("admin:nuclear_codes") is True

    def test_has_any_permission(self):
        """Test checking for any of multiple permissions."""
        user = UserDomain(
            email="test@example.com",
            first_name="John",
            last_name="Doe",
            permissions={"users:read", "posts:write"}
        )

        assert user.has_any_permission(["users:read", "admin:access"]) is True
        assert user.has_any_permission(["admin:access", "posts:write"]) is True
        assert user.has_any_permission(["admin:access", "admin:delete"]) is False

    def test_has_all_permissions(self):
        """Test checking for all permissions."""
        user = UserDomain(
            email="test@example.com",
            first_name="John",
            last_name="Doe",
            permissions={"users:read", "users:write", "posts:read"}
        )

        assert user.has_all_permissions(["users:read", "users:write"]) is True
        assert user.has_all_permissions(["users:read", "posts:read"]) is True
        assert user.has_all_permissions(["users:read", "admin:access"]) is False

    def test_has_role(self):
        """Test role checking."""
        mock_role = type('Role', (), {'name': 'admin'})()
        user = UserDomain(
            email="test@example.com",
            first_name="John",
            last_name="Doe",
            roles=[mock_role]
        )

        assert user.has_role("admin") is True
        assert user.has_role("user") is False

    def test_record_failed_login(self):
        """Test recording failed login attempts."""
        user = UserDomain(
            email="test@example.com",
            first_name="John",
            last_name="Doe"
        )

        # First attempts don't lock
        should_lock, lock_until = user.record_failed_login()
        assert should_lock is False
        assert lock_until is None
        assert user.failed_login_attempts == 1

        # Continue until max attempts
        for i in range(3):
            should_lock, lock_until = user.record_failed_login()

        assert user.failed_login_attempts == 4
        assert should_lock is False

        # Max attempts reached - should lock
        should_lock, lock_until = user.record_failed_login()
        assert should_lock is True
        assert lock_until is not None
        assert user.locked_until is not None
        assert user.failed_login_attempts == 5

    def test_reset_failed_attempts(self):
        """Test resetting failed login attempts."""
        user = UserDomain(
            email="test@example.com",
            first_name="John",
            last_name="Doe",
            failed_login_attempts=3,
            locked_until=datetime.utcnow() + timedelta(minutes=30)
        )

        user.reset_failed_attempts()
        assert user.failed_login_attempts == 0
        assert user.locked_until is None

    def test_is_locked(self):
        """Test account lock status."""
        user = UserDomain(
            email="test@example.com",
            first_name="John",
            last_name="Doe"
        )

        # Not locked initially
        assert user.is_locked is False

        # Locked with future time
        user.locked_until = datetime.utcnow() + timedelta(minutes=30)
        assert user.is_locked is True

        # Lock expired
        user.locked_until = datetime.utcnow() - timedelta(minutes=1)
        assert user.is_locked is False

    def test_can_reset_password(self):
        """Test password reset eligibility."""
        user = UserDomain(
            email="test@example.com",
            first_name="John",
            last_name="Doe"
        )

        # Active user can reset
        assert user.can_reset_password() is True

        # Inactive user cannot reset
        user.is_active = False
        assert user.can_reset_password() is False

        # Locked user cannot reset
        user.is_active = True
        user.locked_until = datetime.utcnow() + timedelta(minutes=30)
        assert user.can_reset_password() is False

    def test_activate_deactivate(self):
        """Test account activation/deactivation."""
        user = UserDomain(
            email="test@example.com",
            first_name="John",
            last_name="Doe",
            is_active=False
        )

        user.activate()
        assert user.is_active is True
        assert user.updated_at is not None

        user.deactivate()
        assert user.is_active is False

    def test_verify_email(self):
        """Test email verification."""
        user = UserDomain(
            email="test@example.com",
            first_name="John",
            last_name="Doe",
            is_verified=False,
            is_active=False
        )

        user.verify_email()
        assert user.is_verified is True
        assert user.is_active is True  # Auto-activated
        assert user.updated_at is not None

    def test_record_login(self):
        """Test recording successful login."""
        user = UserDomain(
            email="test@example.com",
            first_name="John",
            last_name="Doe",
            failed_login_attempts=3
        )

        user.record_login(ip_address="127.0.0.1")
        assert user.last_login is not None
        assert user.failed_login_attempts == 0
        assert user.locked_until is None

    def test_to_dict(self):
        """Test conversion to dictionary."""
        user = UserDomain(
            email="test@example.com",
            first_name="John",
            last_name="Doe"
        )

        user_dict = user.to_dict()
        assert user_dict["email"] == "test@example.com"
        assert user_dict["first_name"] == "John"
        assert user_dict["last_name"] == "Doe"
        assert "id" in user_dict
        assert "created_at" in user_dict