"""
Unit tests for AuthenticationService

Tests authentication, login, logout, and token management functionality.
"""

import pytest
from datetime import datetime, timedelta, timezone
from unittest.mock import AsyncMock, MagicMock, patch
from uuid import uuid4

from app.services.auth.authentication_service import (
    AuthenticationService,
    AuthenticationError,
    AccountLockedError,
    EmailNotVerifiedError,
)
from app.domain.user_domain import UserDomain


@pytest.fixture
def mock_session():
    """Create a mock database session."""
    session = AsyncMock()
    session.commit = AsyncMock()
    session.rollback = AsyncMock()
    return session


@pytest.fixture
def mock_user_repository():
    """Create a mock user repository."""
    repo = AsyncMock()
    return repo


@pytest.fixture
def mock_session_repository():
    """Create a mock session repository."""
    repo = AsyncMock()
    return repo


@pytest.fixture
def mock_cache_service():
    """Create a mock cache service."""
    cache = AsyncMock()
    cache.get_user_permissions = AsyncMock(return_value=["users:read", "users:write"])
    cache.cache_user_permissions = AsyncMock()
    return cache


@pytest.fixture
def auth_service(mock_session, mock_user_repository, mock_session_repository, mock_cache_service):
    """Create an AuthenticationService instance with mocked dependencies."""
    return AuthenticationService(
        session=mock_session,
        user_repository=mock_user_repository,
        session_repository=mock_session_repository,
        cache_service=mock_cache_service,
    )


@pytest.fixture
def sample_user():
    """Create a sample user for testing."""
    user = MagicMock()
    user.id = uuid4()
    user.email = "test@example.com"
    user.first_name = "Test"
    user.last_name = "User"
    user.full_name = "Test User"
    user.name = "Test User"  # Add name field for UserResponse
    user.hashed_password = "$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewYpF3UYjCZJ0yJa"  # password: Test123!
    user.is_active = True
    user.is_verified = True
    user.isEmailVerified = True  # Add camelCase field for response
    user.is_locked = False
    user.failed_login_attempts = 0
    user.locked_until = None
    # Create proper role mock with serializable attributes
    role_mock = MagicMock()
    role_mock.name = "user"
    role_mock.id = "role-123"
    user.roles = [role_mock]
    user.get_permissions = MagicMock(return_value=["users:read", "users:write"])
    user.created_at = datetime.now(timezone.utc)
    user.updated_at = datetime.now(timezone.utc)
    # Add camelCase fields for response compatibility
    user.createdAt = datetime.now(timezone.utc)
    user.updatedAt = datetime.now(timezone.utc)
    user.last_login = None
    return user


class TestAuthenticationService:
    """Test cases for AuthenticationService."""

    @pytest.mark.asyncio
    async def test_authenticate_user_success(self, auth_service, mock_user_repository, sample_user):
        """Test successful user authentication."""
        # Arrange
        mock_user_repository.find_by_email_with_roles.return_value = sample_user
        mock_user_repository.reset_failed_attempts.return_value = True
        mock_user_repository.update_last_login.return_value = True

        with patch("app.services.auth.authentication_service.verify_password", return_value=True):
            # Act
            result = await auth_service.authenticate_user(
                email="test@example.com",
                password="Test123!",
                ip_address="127.0.0.1",
                user_agent="TestBrowser"
            )

            # Assert
            assert result.access_token is not None
            assert result.refresh_token is not None
            assert result.token_type == "bearer"
            assert result.user.email == "test@example.com"
            mock_user_repository.find_by_email_with_roles.assert_called_once_with("test@example.com")
            mock_user_repository.update_last_login.assert_called_once()

    @pytest.mark.asyncio
    async def test_authenticate_user_invalid_email(self, auth_service, mock_user_repository):
        """Test authentication with invalid email."""
        # Arrange
        mock_user_repository.find_by_email_with_roles.return_value = None

        # Act & Assert
        with pytest.raises(AuthenticationError, match="Invalid email or password"):
            await auth_service.authenticate_user(
                email="nonexistent@example.com",
                password="Test123!",
                ip_address="127.0.0.1",
                user_agent="TestBrowser"
            )

        mock_user_repository.find_by_email_with_roles.assert_called_once()

    @pytest.mark.asyncio
    async def test_authenticate_user_wrong_password(self, auth_service, mock_user_repository, sample_user):
        """Test authentication with wrong password."""
        # Arrange
        mock_user_repository.find_by_email_with_roles.return_value = sample_user

        with patch("app.services.auth.authentication_service.verify_password", return_value=False):
            # Act & Assert
            with pytest.raises(AuthenticationError, match="Invalid email or password"):
                await auth_service.authenticate_user(
                    email="test@example.com",
                    password="WrongPassword",
                    ip_address="127.0.0.1",
                    user_agent="TestBrowser"
                )

    @pytest.mark.asyncio
    async def test_authenticate_user_account_locked(self, auth_service, mock_user_repository, sample_user):
        """Test authentication with locked account."""
        # Arrange
        sample_user.is_locked = True
        sample_user.locked_until = datetime.now(timezone.utc) + timedelta(minutes=30)
        mock_user_repository.find_by_email_with_roles.return_value = sample_user

        # Act & Assert
        with pytest.raises(AccountLockedError):
            await auth_service.authenticate_user(
                email="test@example.com",
                password="Test123!",
                ip_address="127.0.0.1",
                user_agent="TestBrowser"
            )

    @pytest.mark.asyncio
    async def test_authenticate_user_inactive_account(self, auth_service, mock_user_repository, sample_user):
        """Test authentication with inactive account."""
        # Arrange
        sample_user.is_active = False
        mock_user_repository.find_by_email_with_roles.return_value = sample_user

        with patch("app.services.auth.authentication_service.verify_password", return_value=True):
            # Act & Assert
            with pytest.raises(AuthenticationError, match="Account is not active"):
                await auth_service.authenticate_user(
                    email="test@example.com",
                    password="Test123!",
                    ip_address="127.0.0.1",
                    user_agent="TestBrowser"
                )

    @pytest.mark.asyncio
    async def test_refresh_access_token_success(self, auth_service, mock_session_repository, mock_user_repository, sample_user):
        """Test successful token refresh."""
        # Arrange
        mock_token = MagicMock()
        mock_token.is_valid = True
        mock_token.user_id = sample_user.id

        mock_session_repository.find_refresh_token.return_value = mock_token
        mock_user_repository.find_with_roles.return_value = sample_user
        mock_session_repository.mark_token_used.return_value = True

        with patch("app.services.auth.authentication_service.verify_token") as mock_verify:
            mock_verify.return_value = MagicMock(jti="token_id", sub=str(sample_user.id))

            # Act
            result = await auth_service.refresh_access_token(
                refresh_token="valid_refresh_token",
                ip_address="127.0.0.1",
                user_agent="TestBrowser"
            )

            # Assert
            assert result["access_token"] is not None
            assert result["token_type"] == "bearer"
            assert result["expires_in"] > 0
            mock_session_repository.find_refresh_token.assert_called_once()
            mock_session_repository.mark_token_used.assert_called_once()

    @pytest.mark.asyncio
    async def test_refresh_access_token_invalid_token(self, auth_service):
        """Test token refresh with invalid token."""
        # Arrange
        with patch("app.services.auth.authentication_service.verify_token", return_value=None):
            # Act & Assert
            with pytest.raises(AuthenticationError, match="Invalid refresh token"):
                await auth_service.refresh_access_token(
                    refresh_token="invalid_token",
                    ip_address="127.0.0.1",
                    user_agent="TestBrowser"
                )

    @pytest.mark.asyncio
    async def test_logout_user_success(self, auth_service, mock_session_repository):
        """Test successful user logout."""
        # Arrange
        mock_session_repository.revoke_user_tokens.return_value = 3
        mock_session_repository.end_user_sessions.return_value = 2

        with patch("app.services.auth.authentication_service.verify_token") as mock_verify:
            mock_verify.return_value = MagicMock(sub="user_id", email="test@example.com")

            # Act
            result = await auth_service.logout_user("valid_access_token")

            # Assert
            assert result is True
            mock_session_repository.revoke_user_tokens.assert_called_once_with("user_id")
            mock_session_repository.end_user_sessions.assert_called_once_with("user_id")

    @pytest.mark.asyncio
    async def test_handle_failed_login_increment_attempts(self, auth_service, mock_user_repository, sample_user):
        """Test handling failed login attempts."""
        # Arrange
        mock_user_repository.increment_failed_attempts.return_value = 3

        # Act
        await auth_service._handle_failed_login(
            email="test@example.com",
            ip_address="127.0.0.1",
            user=sample_user
        )

        # Assert
        mock_user_repository.increment_failed_attempts.assert_called_once_with(sample_user.id)

    @pytest.mark.asyncio
    async def test_handle_failed_login_lock_account(self, auth_service, mock_user_repository, sample_user):
        """Test account locking after max failed attempts."""
        # Arrange
        mock_user_repository.increment_failed_attempts.return_value = 5  # Max attempts reached

        # Act
        await auth_service._handle_failed_login(
            email="test@example.com",
            ip_address="127.0.0.1",
            user=sample_user
        )

        # Assert
        mock_user_repository.increment_failed_attempts.assert_called_once_with(sample_user.id)
        mock_user_repository.lock_account.assert_called_once()

    @pytest.mark.asyncio
    async def test_calculate_privilege_level(self, auth_service):
        """Test privilege level calculation."""
        # Test super admin
        assert auth_service._calculate_privilege_level(["super_admin"]) == "super_admin"
        assert auth_service._calculate_privilege_level(["superuser"]) == "super_admin"

        # Test admin
        assert auth_service._calculate_privilege_level(["admin"]) == "admin"
        assert auth_service._calculate_privilege_level(["administrator"]) == "admin"

        # Test moderator
        assert auth_service._calculate_privilege_level(["moderator"]) == "moderator"

        # Test premium
        assert auth_service._calculate_privilege_level(["premium"]) == "premium"
        assert auth_service._calculate_privilege_level(["pro"]) == "premium"

        # Test user
        assert auth_service._calculate_privilege_level(["user"]) == "user"
        assert auth_service._calculate_privilege_level(["member"]) == "user"

        # Test guest
        assert auth_service._calculate_privilege_level([]) == "guest"
        assert auth_service._calculate_privilege_level(["unknown"]) == "guest"