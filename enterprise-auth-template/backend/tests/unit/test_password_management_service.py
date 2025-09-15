"""
Unit tests for PasswordManagementService

Tests password reset, change, and validation functionality.
"""

import pytest
from unittest.mock import AsyncMock, MagicMock, patch
from datetime import datetime, timedelta
from uuid import uuid4
import secrets

from app.services.auth.password_management_service import (
    PasswordManagementService,
    PasswordManagementError,
)
from app.domain.user_domain import UserDomain


class TestPasswordManagementService:
    """Test cases for PasswordManagementService."""

    @pytest.fixture
    def mock_session(self):
        """Create a mock database session."""
        session = AsyncMock()
        session.commit = AsyncMock()
        session.rollback = AsyncMock()
        session.refresh = AsyncMock()
        return session

    @pytest.fixture
    def mock_user_repo(self):
        """Create a mock user repository."""
        repo = AsyncMock()
        repo.get_by_email = AsyncMock()
        repo.get_by_id = AsyncMock()
        repo.update = AsyncMock()
        return repo

    @pytest.fixture
    def mock_user(self):
        """Create a mock user."""
        user = MagicMock(spec=UserDomain)
        user.id = uuid4()
        user.email = "test@example.com"
        user.first_name = "Test"
        user.last_name = "User"
        user.is_active = True
        user.is_verified = True
        user.hashed_password = "hashed_old_password"
        user.verify_password = MagicMock(return_value=True)
        user.set_password = MagicMock()
        user.change_password = MagicMock(return_value=True)
        return user

    @pytest.fixture
    def password_service(self, mock_session, mock_user_repo):
        """Create a PasswordManagementService instance."""
        return PasswordManagementService(mock_session, mock_user_repo)

    @pytest.mark.asyncio
    async def test_request_password_reset_success(self, password_service, mock_user_repo, mock_user):
        """Test successful password reset request."""
        # Arrange
        email = "test@example.com"
        mock_user_repo.get_by_email.return_value = mock_user

        with patch.object(password_service, '_send_reset_email', new_callable=AsyncMock) as mock_send:
            # Act
            token = await password_service.request_password_reset(
                email=email,
                ip_address="127.0.0.1",
                user_agent="Test Browser",
            )

            # Assert
            assert token is not None
            assert len(token) > 20
            mock_user_repo.get_by_email.assert_called_once_with(email)
            mock_send.assert_called_once()

    @pytest.mark.asyncio
    async def test_request_password_reset_user_not_found(self, password_service, mock_user_repo):
        """Test password reset request for non-existent user."""
        # Arrange
        email = "nonexistent@example.com"
        mock_user_repo.get_by_email.return_value = None

        # Act
        result = await password_service.request_password_reset(
            email=email,
            ip_address="127.0.0.1",
        )

        # Assert
        assert result is None  # Should silently fail for security
        mock_user_repo.get_by_email.assert_called_once_with(email)

    @pytest.mark.asyncio
    async def test_request_password_reset_inactive_user(self, password_service, mock_user_repo, mock_user):
        """Test password reset request for inactive user."""
        # Arrange
        mock_user.is_active = False
        mock_user_repo.get_by_email.return_value = mock_user

        # Act
        result = await password_service.request_password_reset(
            email=mock_user.email,
            ip_address="127.0.0.1",
        )

        # Assert
        assert result is None  # Should silently fail
        mock_user_repo.get_by_email.assert_called_once()

    @pytest.mark.asyncio
    async def test_request_password_reset_locked_user(self, password_service, mock_user_repo, mock_user):
        """Test password reset request for locked user."""
        # Arrange
        mock_user.is_locked = True
        mock_user.locked_until = datetime.utcnow() + timedelta(hours=1)
        mock_user_repo.get_by_email.return_value = mock_user

        # Act
        result = await password_service.request_password_reset(
            email=mock_user.email,
            ip_address="127.0.0.1",
        )

        # Assert
        assert result is None  # Should silently fail
        mock_user_repo.get_by_email.assert_called_once()

    @pytest.mark.asyncio
    async def test_reset_password_success(self, password_service, mock_user_repo, mock_user):
        """Test successful password reset."""
        # Arrange
        reset_token = secrets.token_urlsafe(32)
        new_password = "NewSecurePass123!"

        # Store token first
        with patch.object(password_service, '_store_reset_token', new_callable=AsyncMock):
            await password_service._store_reset_token(mock_user.id, reset_token)

        with patch.object(password_service, '_validate_reset_token', new_callable=AsyncMock) as mock_validate:
            mock_validate.return_value = mock_user.id
            mock_user_repo.get_by_id.return_value = mock_user

            # Act
            result = await password_service.reset_password(
                reset_token=reset_token,
                new_password=new_password,
                ip_address="127.0.0.1",
            )

            # Assert
            assert result is True
            mock_validate.assert_called_once_with(reset_token)
            mock_user.set_password.assert_called_once_with(new_password)
            mock_user_repo.update.assert_called_once_with(mock_user)

    @pytest.mark.asyncio
    async def test_reset_password_invalid_token(self, password_service):
        """Test password reset with invalid token."""
        # Arrange
        invalid_token = "invalid_token"
        new_password = "NewSecurePass123!"

        with patch.object(password_service, '_validate_reset_token', new_callable=AsyncMock) as mock_validate:
            mock_validate.return_value = None

            # Act & Assert
            with pytest.raises(PasswordManagementError, match="Invalid or expired reset token"):
                await password_service.reset_password(
                    reset_token=invalid_token,
                    new_password=new_password,
                    ip_address="127.0.0.1",
                )

    @pytest.mark.asyncio
    async def test_reset_password_weak_password(self, password_service):
        """Test password reset with weak password."""
        # Arrange
        reset_token = secrets.token_urlsafe(32)
        weak_password = "weak"

        with patch.object(password_service, '_validate_reset_token', new_callable=AsyncMock) as mock_validate:
            mock_validate.return_value = uuid4()

            # Act & Assert
            with pytest.raises(PasswordManagementError, match="Password validation failed"):
                await password_service.reset_password(
                    reset_token=reset_token,
                    new_password=weak_password,
                    ip_address="127.0.0.1",
                )

    @pytest.mark.asyncio
    async def test_reset_password_user_not_found(self, password_service, mock_user_repo):
        """Test password reset when user no longer exists."""
        # Arrange
        reset_token = secrets.token_urlsafe(32)
        new_password = "NewSecurePass123!"
        user_id = uuid4()

        with patch.object(password_service, '_validate_reset_token', new_callable=AsyncMock) as mock_validate:
            mock_validate.return_value = user_id
            mock_user_repo.get_by_id.return_value = None

            # Act & Assert
            with pytest.raises(PasswordManagementError, match="User not found"):
                await password_service.reset_password(
                    reset_token=reset_token,
                    new_password=new_password,
                    ip_address="127.0.0.1",
                )

    @pytest.mark.asyncio
    async def test_change_password_success(self, password_service, mock_user_repo, mock_user):
        """Test successful password change."""
        # Arrange
        user_id = mock_user.id
        current_password = "CurrentPass123!"
        new_password = "NewSecurePass123!"

        mock_user_repo.get_by_id.return_value = mock_user
        mock_user.verify_password.return_value = True
        mock_user.change_password.return_value = True

        # Act
        result = await password_service.change_password(
            user_id=str(user_id),
            current_password=current_password,
            new_password=new_password,
        )

        # Assert
        assert result is True
        mock_user_repo.get_by_id.assert_called_once_with(str(user_id))
        mock_user.change_password.assert_called_once_with(current_password, new_password)
        mock_user_repo.update.assert_called_once_with(mock_user)

    @pytest.mark.asyncio
    async def test_change_password_wrong_current(self, password_service, mock_user_repo, mock_user):
        """Test password change with wrong current password."""
        # Arrange
        user_id = mock_user.id
        wrong_password = "WrongPass123!"
        new_password = "NewSecurePass123!"

        mock_user_repo.get_by_id.return_value = mock_user
        mock_user.verify_password.return_value = False
        mock_user.change_password.side_effect = ValueError("Current password is incorrect")

        # Act & Assert
        with pytest.raises(PasswordManagementError, match="Current password is incorrect"):
            await password_service.change_password(
                user_id=str(user_id),
                current_password=wrong_password,
                new_password=new_password,
            )

    @pytest.mark.asyncio
    async def test_change_password_same_as_current(self, password_service, mock_user_repo, mock_user):
        """Test password change with same password."""
        # Arrange
        user_id = mock_user.id
        current_password = "CurrentPass123!"

        mock_user_repo.get_by_id.return_value = mock_user
        mock_user.verify_password.return_value = True
        mock_user.change_password.side_effect = ValueError("New password must be different")

        # Act & Assert
        with pytest.raises(PasswordManagementError, match="must be different"):
            await password_service.change_password(
                user_id=str(user_id),
                current_password=current_password,
                new_password=current_password,
            )

    @pytest.mark.asyncio
    async def test_validate_reset_token_expired(self, password_service):
        """Test validation of expired reset token."""
        # Arrange
        expired_token = "expired_token"

        with patch.object(password_service, '_get_token_data', new_callable=AsyncMock) as mock_get:
            mock_get.return_value = {
                "user_id": str(uuid4()),
                "expires_at": datetime.utcnow() - timedelta(hours=1),
            }

            # Act
            result = await password_service._validate_reset_token(expired_token)

            # Assert
            assert result is None  # Expired token

    @pytest.mark.asyncio
    async def test_validate_reset_token_valid(self, password_service):
        """Test validation of valid reset token."""
        # Arrange
        valid_token = "valid_token"
        user_id = uuid4()

        with patch.object(password_service, '_get_token_data', new_callable=AsyncMock) as mock_get:
            mock_get.return_value = {
                "user_id": str(user_id),
                "expires_at": datetime.utcnow() + timedelta(hours=1),
            }

            # Act
            result = await password_service._validate_reset_token(valid_token)

            # Assert
            assert result == str(user_id)

    @pytest.mark.asyncio
    async def test_password_history_check(self, password_service, mock_user_repo, mock_user):
        """Test password history validation."""
        # Arrange
        user_id = mock_user.id
        mock_user_repo.get_by_id.return_value = mock_user

        # Mock password history
        mock_user.password_history = [
            "hashed_password_1",
            "hashed_password_2",
            "hashed_password_3",
        ]

        with patch.object(password_service, '_check_password_history', return_value=False) as mock_check:
            # Act & Assert
            with pytest.raises(PasswordManagementError, match="recently used"):
                await password_service.change_password(
                    user_id=str(user_id),
                    current_password="CurrentPass123!",
                    new_password="RecentlyUsedPass123!",
                )

    @pytest.mark.asyncio
    async def test_password_complexity_requirements(self, password_service):
        """Test various password complexity requirements."""
        # Test cases for different password patterns
        test_cases = [
            ("short", False, "at least 8 characters"),
            ("nouppercase123!", False, "uppercase letter"),
            ("NOLOWERCASE123!", False, "lowercase letter"),
            ("NoDigits!", False, "one digit"),
            ("NoSpecialChar123", False, "special character"),
            ("ValidPass123!", True, None),
            ("C0mpl3x!P@ssw0rd", True, None),
        ]

        for password, should_pass, error_msg in test_cases:
            if should_pass:
                # Should not raise
                result = await password_service._validate_password_strength(password)
                assert result is True
            else:
                # Should raise with specific message
                with pytest.raises(PasswordManagementError, match=error_msg):
                    await password_service._validate_password_strength(password)

    @pytest.mark.asyncio
    async def test_concurrent_reset_requests(self, password_service, mock_user_repo, mock_user):
        """Test handling of concurrent password reset requests."""
        # Arrange
        email = mock_user.email
        mock_user_repo.get_by_email.return_value = mock_user

        # Simulate concurrent requests
        with patch.object(password_service, '_send_reset_email', new_callable=AsyncMock):
            # Act
            tokens = []
            for _ in range(3):
                token = await password_service.request_password_reset(
                    email=email,
                    ip_address="127.0.0.1",
                )
                tokens.append(token)

            # Assert
            assert len(set(tokens)) == 3  # All tokens should be unique
            assert mock_user_repo.get_by_email.call_count == 3