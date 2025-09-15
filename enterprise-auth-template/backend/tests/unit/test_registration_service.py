"""
Unit tests for RegistrationService

Tests the user registration service with mocked dependencies.
"""

import pytest
from unittest.mock import AsyncMock, MagicMock, patch
from datetime import datetime
from uuid import uuid4

from app.services.auth.registration_service import (
    RegistrationService,
    RegistrationError,
)
from app.domain.user_domain import UserDomain


class TestRegistrationService:
    """Test cases for RegistrationService."""

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
        repo.get_by_email = AsyncMock(return_value=None)
        repo.create = AsyncMock()
        repo.update = AsyncMock()
        return repo

    @pytest.fixture
    def mock_role_repo(self):
        """Create a mock role repository."""
        repo = AsyncMock()
        default_role = MagicMock()
        default_role.id = uuid4()
        default_role.name = "user"
        repo.get_by_name = AsyncMock(return_value=default_role)
        return repo

    @pytest.fixture
    def registration_service(self, mock_session, mock_user_repo, mock_role_repo):
        """Create a RegistrationService instance with mocked dependencies."""
        return RegistrationService(mock_session, mock_user_repo, mock_role_repo)

    @pytest.mark.asyncio
    async def test_register_user_success(self, registration_service, mock_user_repo, mock_role_repo):
        """Test successful user registration."""
        # Arrange
        email = "newuser@example.com"
        password = "SecurePass123!"
        first_name = "John"
        last_name = "Doe"

        mock_user = MagicMock(spec=UserDomain)
        mock_user.id = uuid4()
        mock_user.email = email
        mock_user.first_name = first_name
        mock_user.last_name = last_name
        mock_user.is_active = True
        mock_user.is_verified = False
        mock_user.created_at = datetime.utcnow()

        mock_user_repo.create.return_value = mock_user

        # Act
        result = await registration_service.register_user(
            email=email,
            password=password,
            first_name=first_name,
            last_name=last_name,
        )

        # Assert
        assert result == mock_user
        mock_user_repo.get_by_email.assert_called_once_with(email)
        mock_user_repo.create.assert_called_once()
        mock_role_repo.get_by_name.assert_called_once_with("user")

    @pytest.mark.asyncio
    async def test_register_user_email_exists(self, registration_service, mock_user_repo):
        """Test registration with existing email."""
        # Arrange
        email = "existing@example.com"
        existing_user = MagicMock()
        mock_user_repo.get_by_email.return_value = existing_user

        # Act & Assert
        with pytest.raises(RegistrationError, match="Email already registered"):
            await registration_service.register_user(
                email=email,
                password="SecurePass123!",
                first_name="John",
                last_name="Doe",
            )

        mock_user_repo.get_by_email.assert_called_once_with(email)
        mock_user_repo.create.assert_not_called()

    @pytest.mark.asyncio
    async def test_register_user_weak_password(self, registration_service, mock_user_repo):
        """Test registration with weak password."""
        # Arrange
        email = "newuser@example.com"
        weak_password = "weak"

        # Act & Assert
        with pytest.raises(RegistrationError, match="Password validation failed"):
            await registration_service.register_user(
                email=email,
                password=weak_password,
                first_name="John",
                last_name="Doe",
            )

        mock_user_repo.create.assert_not_called()

    @pytest.mark.asyncio
    async def test_register_user_invalid_email(self, registration_service):
        """Test registration with invalid email format."""
        # Arrange
        invalid_email = "not-an-email"

        # Act & Assert
        with pytest.raises(RegistrationError, match="Invalid email format"):
            await registration_service.register_user(
                email=invalid_email,
                password="SecurePass123!",
                first_name="John",
                last_name="Doe",
            )

    @pytest.mark.asyncio
    async def test_register_user_missing_name(self, registration_service):
        """Test registration with missing first name."""
        # Act & Assert
        with pytest.raises(RegistrationError, match="First name is required"):
            await registration_service.register_user(
                email="test@example.com",
                password="SecurePass123!",
                first_name="",
                last_name="Doe",
            )

    @pytest.mark.asyncio
    async def test_register_user_with_organization(self, registration_service, mock_user_repo, mock_role_repo):
        """Test registration with organization ID."""
        # Arrange
        email = "user@company.com"
        password = "SecurePass123!"
        organization_id = uuid4()

        mock_user = MagicMock(spec=UserDomain)
        mock_user.id = uuid4()
        mock_user.email = email
        mock_user.organization_id = organization_id

        mock_user_repo.create.return_value = mock_user

        # Act
        result = await registration_service.register_user(
            email=email,
            password=password,
            first_name="John",
            last_name="Doe",
            organization_id=str(organization_id),
        )

        # Assert
        assert result == mock_user
        assert result.organization_id == organization_id

    @pytest.mark.asyncio
    async def test_register_user_with_custom_role(self, registration_service, mock_user_repo, mock_role_repo):
        """Test registration with custom role."""
        # Arrange
        email = "admin@example.com"
        password = "SecurePass123!"
        role_name = "admin"

        admin_role = MagicMock()
        admin_role.id = uuid4()
        admin_role.name = role_name
        mock_role_repo.get_by_name.return_value = admin_role

        mock_user = MagicMock(spec=UserDomain)
        mock_user.id = uuid4()
        mock_user.roles = [admin_role]
        mock_user_repo.create.return_value = mock_user

        # Act
        result = await registration_service.register_user(
            email=email,
            password=password,
            first_name="Admin",
            last_name="User",
            role=role_name,
        )

        # Assert
        assert result == mock_user
        mock_role_repo.get_by_name.assert_called_with(role_name)

    @pytest.mark.asyncio
    async def test_register_user_role_not_found(self, registration_service, mock_user_repo, mock_role_repo):
        """Test registration with non-existent role."""
        # Arrange
        mock_role_repo.get_by_name.return_value = None

        # Act & Assert
        with pytest.raises(RegistrationError, match="Role .* not found"):
            await registration_service.register_user(
                email="test@example.com",
                password="SecurePass123!",
                first_name="John",
                last_name="Doe",
                role="nonexistent",
            )

    @pytest.mark.asyncio
    async def test_register_user_send_verification_email(self, registration_service, mock_user_repo, mock_role_repo):
        """Test that verification email is sent after registration."""
        # Arrange
        email = "verify@example.com"

        mock_user = MagicMock(spec=UserDomain)
        mock_user.id = uuid4()
        mock_user.email = email
        mock_user.is_verified = False
        mock_user_repo.create.return_value = mock_user

        with patch.object(registration_service, '_send_verification_email', new_callable=AsyncMock) as mock_send:
            # Act
            result = await registration_service.register_user(
                email=email,
                password="SecurePass123!",
                first_name="John",
                last_name="Doe",
                send_verification=True,
            )

            # Assert
            assert result == mock_user
            mock_send.assert_called_once_with(mock_user)

    @pytest.mark.asyncio
    async def test_register_user_auto_verify(self, registration_service, mock_user_repo, mock_role_repo):
        """Test registration with auto-verification."""
        # Arrange
        email = "autoverify@example.com"

        mock_user = MagicMock(spec=UserDomain)
        mock_user.id = uuid4()
        mock_user.email = email
        mock_user.is_verified = True
        mock_user_repo.create.return_value = mock_user

        # Act
        result = await registration_service.register_user(
            email=email,
            password="SecurePass123!",
            first_name="John",
            last_name="Doe",
            auto_verify=True,
        )

        # Assert
        assert result == mock_user
        assert result.is_verified is True

    @pytest.mark.asyncio
    async def test_register_user_rollback_on_error(self, registration_service, mock_session, mock_user_repo):
        """Test that transaction is rolled back on error."""
        # Arrange
        mock_user_repo.create.side_effect = Exception("Database error")

        # Act & Assert
        with pytest.raises(RegistrationError, match="Registration failed"):
            await registration_service.register_user(
                email="test@example.com",
                password="SecurePass123!",
                first_name="John",
                last_name="Doe",
            )

        mock_session.rollback.assert_called_once()

    @pytest.mark.asyncio
    async def test_register_user_with_metadata(self, registration_service, mock_user_repo, mock_role_repo):
        """Test registration with additional metadata."""
        # Arrange
        email = "metadata@example.com"
        metadata = {
            "source": "mobile_app",
            "campaign": "summer_2024",
            "referrer": "friend",
        }

        mock_user = MagicMock(spec=UserDomain)
        mock_user.id = uuid4()
        mock_user.metadata = metadata
        mock_user_repo.create.return_value = mock_user

        # Act
        result = await registration_service.register_user(
            email=email,
            password="SecurePass123!",
            first_name="John",
            last_name="Doe",
            metadata=metadata,
        )

        # Assert
        assert result == mock_user
        assert result.metadata == metadata

    @pytest.mark.asyncio
    async def test_register_user_case_insensitive_email(self, registration_service, mock_user_repo, mock_role_repo):
        """Test that email comparison is case-insensitive."""
        # Arrange
        existing_email = "User@Example.COM"
        new_email = "user@example.com"

        existing_user = MagicMock()
        mock_user_repo.get_by_email.return_value = existing_user

        # Act & Assert
        with pytest.raises(RegistrationError, match="Email already registered"):
            await registration_service.register_user(
                email=existing_email,
                password="SecurePass123!",
                first_name="John",
                last_name="Doe",
            )

    @pytest.mark.asyncio
    async def test_register_bulk_users(self, registration_service, mock_user_repo, mock_role_repo):
        """Test bulk user registration."""
        # Arrange
        users_data = [
            {"email": "user1@example.com", "first_name": "User", "last_name": "One"},
            {"email": "user2@example.com", "first_name": "User", "last_name": "Two"},
            {"email": "user3@example.com", "first_name": "User", "last_name": "Three"},
        ]

        mock_users = []
        for data in users_data:
            mock_user = MagicMock(spec=UserDomain)
            mock_user.email = data["email"]
            mock_users.append(mock_user)

        mock_user_repo.create.side_effect = mock_users

        # Act
        results = []
        for data in users_data:
            user = await registration_service.register_user(
                email=data["email"],
                password="SecurePass123!",
                first_name=data["first_name"],
                last_name=data["last_name"],
            )
            results.append(user)

        # Assert
        assert len(results) == 3
        assert mock_user_repo.create.call_count == 3
        for i, result in enumerate(results):
            assert result.email == users_data[i]["email"]