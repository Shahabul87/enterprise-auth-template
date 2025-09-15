"""
Unit tests for UserRepository

Tests the repository pattern implementation for user data access.
"""

import pytest
from unittest.mock import AsyncMock, MagicMock, patch
from datetime import datetime
from uuid import uuid4
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.repositories.user_repository import UserRepository
from app.models.user import User


class TestUserRepository:
    """Test cases for UserRepository."""

    @pytest.fixture
    def mock_session(self):
        """Create a mock database session."""
        session = AsyncMock(spec=AsyncSession)
        session.execute = AsyncMock()
        session.add = MagicMock()
        session.commit = AsyncMock()
        session.refresh = AsyncMock()
        session.rollback = AsyncMock()
        return session

    @pytest.fixture
    def mock_user(self):
        """Create a mock user model."""
        user = MagicMock(spec=User)
        user.id = uuid4()
        user.email = "test@example.com"
        user.first_name = "Test"
        user.last_name = "User"
        user.is_active = True
        user.is_verified = True
        user.created_at = datetime.utcnow()
        user.updated_at = datetime.utcnow()
        return user

    @pytest.fixture
    def user_repository(self, mock_session):
        """Create a UserRepository instance."""
        return UserRepository(mock_session)

    @pytest.mark.asyncio
    async def test_get_by_id_success(self, user_repository, mock_session, mock_user):
        """Test getting user by ID."""
        # Arrange
        user_id = str(mock_user.id)
        mock_result = MagicMock()
        mock_result.scalar_one_or_none.return_value = mock_user
        mock_session.execute.return_value = mock_result

        # Act
        result = await user_repository.get_by_id(user_id)

        # Assert
        assert result == mock_user
        mock_session.execute.assert_called_once()

    @pytest.mark.asyncio
    async def test_get_by_id_not_found(self, user_repository, mock_session):
        """Test getting non-existent user by ID."""
        # Arrange
        user_id = str(uuid4())
        mock_result = MagicMock()
        mock_result.scalar_one_or_none.return_value = None
        mock_session.execute.return_value = mock_result

        # Act
        result = await user_repository.get_by_id(user_id)

        # Assert
        assert result is None
        mock_session.execute.assert_called_once()

    @pytest.mark.asyncio
    async def test_get_by_email_success(self, user_repository, mock_session, mock_user):
        """Test getting user by email."""
        # Arrange
        email = mock_user.email
        mock_result = MagicMock()
        mock_result.scalar_one_or_none.return_value = mock_user
        mock_session.execute.return_value = mock_result

        # Act
        result = await user_repository.get_by_email(email)

        # Assert
        assert result == mock_user
        mock_session.execute.assert_called_once()

    @pytest.mark.asyncio
    async def test_get_by_email_case_insensitive(self, user_repository, mock_session, mock_user):
        """Test getting user by email is case-insensitive."""
        # Arrange
        email = "TEST@EXAMPLE.COM"
        mock_user.email = "test@example.com"
        mock_result = MagicMock()
        mock_result.scalar_one_or_none.return_value = mock_user
        mock_session.execute.return_value = mock_result

        # Act
        result = await user_repository.get_by_email(email)

        # Assert
        assert result == mock_user
        mock_session.execute.assert_called_once()

    @pytest.mark.asyncio
    async def test_create_user_success(self, user_repository, mock_session):
        """Test creating a new user."""
        # Arrange
        user_data = {
            "email": "newuser@example.com",
            "first_name": "New",
            "last_name": "User",
            "hashed_password": "hashed_password_here",
        }

        new_user = MagicMock(spec=User)
        new_user.id = uuid4()
        new_user.email = user_data["email"]

        with patch('app.models.user.User', return_value=new_user):
            # Act
            result = await user_repository.create(user_data)

            # Assert
            assert result == new_user
            mock_session.add.assert_called_once_with(new_user)
            mock_session.commit.assert_called_once()
            mock_session.refresh.assert_called_once_with(new_user)

    @pytest.mark.asyncio
    async def test_update_user_success(self, user_repository, mock_session, mock_user):
        """Test updating a user."""
        # Arrange
        mock_user.first_name = "Updated"

        # Act
        result = await user_repository.update(mock_user)

        # Assert
        assert result == mock_user
        mock_session.add.assert_called_once_with(mock_user)
        mock_session.commit.assert_called_once()
        mock_session.refresh.assert_called_once_with(mock_user)

    @pytest.mark.asyncio
    async def test_delete_user_soft(self, user_repository, mock_session, mock_user):
        """Test soft deleting a user."""
        # Act
        result = await user_repository.delete(mock_user, soft=True)

        # Assert
        assert result is True
        assert mock_user.is_active is False
        mock_session.add.assert_called_once_with(mock_user)
        mock_session.commit.assert_called_once()

    @pytest.mark.asyncio
    async def test_delete_user_hard(self, user_repository, mock_session, mock_user):
        """Test hard deleting a user."""
        # Act
        result = await user_repository.delete(mock_user, soft=False)

        # Assert
        assert result is True
        mock_session.delete.assert_called_once_with(mock_user)
        mock_session.commit.assert_called_once()

    @pytest.mark.asyncio
    async def test_get_all_active_users(self, user_repository, mock_session):
        """Test getting all active users."""
        # Arrange
        mock_users = [MagicMock(spec=User) for _ in range(3)]
        mock_result = MagicMock()
        mock_result.scalars.return_value.all.return_value = mock_users
        mock_session.execute.return_value = mock_result

        # Act
        result = await user_repository.get_all_active()

        # Assert
        assert result == mock_users
        assert len(result) == 3
        mock_session.execute.assert_called_once()

    @pytest.mark.asyncio
    async def test_get_by_ids_success(self, user_repository, mock_session):
        """Test getting multiple users by IDs."""
        # Arrange
        user_ids = [str(uuid4()) for _ in range(3)]
        mock_users = [MagicMock(spec=User) for _ in range(3)]
        mock_result = MagicMock()
        mock_result.scalars.return_value.all.return_value = mock_users
        mock_session.execute.return_value = mock_result

        # Act
        result = await user_repository.get_by_ids(user_ids)

        # Assert
        assert result == mock_users
        assert len(result) == 3
        mock_session.execute.assert_called_once()

    @pytest.mark.asyncio
    async def test_count_users(self, user_repository, mock_session):
        """Test counting users."""
        # Arrange
        mock_result = MagicMock()
        mock_result.scalar.return_value = 42
        mock_session.execute.return_value = mock_result

        # Act
        result = await user_repository.count()

        # Assert
        assert result == 42
        mock_session.execute.assert_called_once()

    @pytest.mark.asyncio
    async def test_exists_by_email_true(self, user_repository, mock_session):
        """Test checking if user exists by email (exists)."""
        # Arrange
        email = "existing@example.com"
        mock_result = MagicMock()
        mock_result.scalar.return_value = 1
        mock_session.execute.return_value = mock_result

        # Act
        result = await user_repository.exists_by_email(email)

        # Assert
        assert result is True
        mock_session.execute.assert_called_once()

    @pytest.mark.asyncio
    async def test_exists_by_email_false(self, user_repository, mock_session):
        """Test checking if user exists by email (doesn't exist)."""
        # Arrange
        email = "nonexistent@example.com"
        mock_result = MagicMock()
        mock_result.scalar.return_value = None
        mock_session.execute.return_value = mock_result

        # Act
        result = await user_repository.exists_by_email(email)

        # Assert
        assert result is False
        mock_session.execute.assert_called_once()

    @pytest.mark.asyncio
    async def test_search_users(self, user_repository, mock_session):
        """Test searching users by query."""
        # Arrange
        search_query = "john"
        mock_users = [MagicMock(spec=User) for _ in range(2)]
        mock_result = MagicMock()
        mock_result.scalars.return_value.all.return_value = mock_users
        mock_session.execute.return_value = mock_result

        # Act
        result = await user_repository.search(search_query)

        # Assert
        assert result == mock_users
        assert len(result) == 2
        mock_session.execute.assert_called_once()

    @pytest.mark.asyncio
    async def test_get_users_paginated(self, user_repository, mock_session):
        """Test getting paginated users."""
        # Arrange
        skip = 10
        limit = 5
        mock_users = [MagicMock(spec=User) for _ in range(5)]
        mock_result = MagicMock()
        mock_result.scalars.return_value.all.return_value = mock_users
        mock_session.execute.return_value = mock_result

        # Act
        result = await user_repository.get_paginated(skip=skip, limit=limit)

        # Assert
        assert result == mock_users
        assert len(result) == 5
        mock_session.execute.assert_called_once()

    @pytest.mark.asyncio
    async def test_get_by_organization(self, user_repository, mock_session):
        """Test getting users by organization ID."""
        # Arrange
        org_id = str(uuid4())
        mock_users = [MagicMock(spec=User) for _ in range(3)]
        mock_result = MagicMock()
        mock_result.scalars.return_value.all.return_value = mock_users
        mock_session.execute.return_value = mock_result

        # Act
        result = await user_repository.get_by_organization(org_id)

        # Assert
        assert result == mock_users
        assert len(result) == 3
        mock_session.execute.assert_called_once()

    @pytest.mark.asyncio
    async def test_get_by_role(self, user_repository, mock_session):
        """Test getting users by role."""
        # Arrange
        role_name = "admin"
        mock_users = [MagicMock(spec=User) for _ in range(2)]
        mock_result = MagicMock()
        mock_result.scalars.return_value.all.return_value = mock_users
        mock_session.execute.return_value = mock_result

        # Act
        result = await user_repository.get_by_role(role_name)

        # Assert
        assert result == mock_users
        assert len(result) == 2
        mock_session.execute.assert_called_once()

    @pytest.mark.asyncio
    async def test_bulk_create_users(self, user_repository, mock_session):
        """Test bulk creating users."""
        # Arrange
        users_data = [
            {"email": f"user{i}@example.com", "first_name": f"User{i}"}
            for i in range(3)
        ]

        mock_users = []
        for data in users_data:
            user = MagicMock(spec=User)
            user.email = data["email"]
            mock_users.append(user)

        with patch('app.models.user.User', side_effect=mock_users):
            # Act
            result = await user_repository.bulk_create(users_data)

            # Assert
            assert len(result) == 3
            assert mock_session.add.call_count == 3
            mock_session.commit.assert_called_once()

    @pytest.mark.asyncio
    async def test_repository_transaction_rollback(self, user_repository, mock_session):
        """Test repository rollback on error."""
        # Arrange
        mock_session.commit.side_effect = Exception("Database error")
        user_data = {"email": "test@example.com"}

        # Act & Assert
        with pytest.raises(Exception):
            await user_repository.create(user_data)

        mock_session.rollback.assert_called_once()