"""
Tests for User CRUD Service

Tests the user management operations implemented in the refactored
user_crud_service module, including CRUD operations and validation.
"""

import pytest
from unittest.mock import AsyncMock, patch
from sqlalchemy.ext.asyncio import AsyncSession

from app.services.user.user_crud_service import UserCRUDService
from app.models.user import User, Role, UserRole
from app.schemas.user import UserCreate, UserUpdate
from app.core.security import get_password_hash


class TestUserCRUDService:
    """Test suite for UserCRUDService functionality."""

    @pytest.fixture
    def user_crud_service(self):
        """User CRUD service instance."""
        return UserCRUDService()

    @pytest.fixture
    def sample_user_data(self):
        """Sample user creation data."""
        return UserCreate(
            email="test@example.com",
            password="TestPassword123!",
            first_name="Test",
            last_name="User",
            is_active=True,
            is_verified=False,
            is_superuser=False,
        )

    @pytest.fixture
    def sample_user(self, sample_user_data):
        """Sample user model instance."""
        return User(
            id="test-user-id",
            email=sample_user_data.email,
            hashed_password=get_password_hash(sample_user_data.password),
            first_name=sample_user_data.first_name,
            last_name=sample_user_data.last_name,
            is_active=sample_user_data.is_active,
            is_verified=sample_user_data.is_verified,
            is_superuser=sample_user_data.is_superuser,
        )

    @pytest.mark.asyncio
    async def test_create_user_success(self, user_crud_service, sample_user_data, db_session):
        """Test successful user creation."""
        # Create user role
        user_role = Role(name="user", description="Default user role", is_system=True)
        db_session.add(user_role)
        await db_session.flush()

        # Create user
        created_user = await user_crud_service.create_user(db_session, sample_user_data)

        assert created_user is not None
        assert created_user.email == sample_user_data.email
        assert created_user.first_name == sample_user_data.first_name
        assert created_user.last_name == sample_user_data.last_name
        assert created_user.is_active == sample_user_data.is_active
        assert created_user.is_verified == sample_user_data.is_verified
        assert created_user.is_superuser == sample_user_data.is_superuser
        assert created_user.hashed_password != sample_user_data.password  # Should be hashed

    @pytest.mark.asyncio
    async def test_create_user_duplicate_email(self, user_crud_service, sample_user_data, test_user, db_session):
        """Test user creation with duplicate email."""
        # Try to create user with existing email
        duplicate_data = sample_user_data.copy()
        duplicate_data.email = test_user.email

        with pytest.raises(ValueError, match="User with this email already exists"):
            await user_crud_service.create_user(db_session, duplicate_data)

    @pytest.mark.asyncio
    async def test_get_user_by_id_success(self, user_crud_service, test_user, db_session):
        """Test successful user retrieval by ID."""
        user = await user_crud_service.get_user_by_id(db_session, str(test_user.id))

        assert user is not None
        assert user.id == test_user.id
        assert user.email == test_user.email

    @pytest.mark.asyncio
    async def test_get_user_by_id_not_found(self, user_crud_service, db_session):
        """Test user retrieval with non-existent ID."""
        user = await user_crud_service.get_user_by_id(db_session, "non-existent-id")
        assert user is None

    @pytest.mark.asyncio
    async def test_get_user_by_email_success(self, user_crud_service, test_user, db_session):
        """Test successful user retrieval by email."""
        user = await user_crud_service.get_user_by_email(db_session, test_user.email)

        assert user is not None
        assert user.id == test_user.id
        assert user.email == test_user.email

    @pytest.mark.asyncio
    async def test_get_user_by_email_not_found(self, user_crud_service, db_session):
        """Test user retrieval with non-existent email."""
        user = await user_crud_service.get_user_by_email(db_session, "nonexistent@example.com")
        assert user is None

    @pytest.mark.asyncio
    async def test_update_user_success(self, user_crud_service, test_user, db_session):
        """Test successful user update."""
        update_data = UserUpdate(
            first_name="Updated",
            last_name="Name",
            is_verified=True
        )

        updated_user = await user_crud_service.update_user(db_session, str(test_user.id), update_data)

        assert updated_user is not None
        assert updated_user.first_name == "Updated"
        assert updated_user.last_name == "Name"
        assert updated_user.is_verified is True
        assert updated_user.email == test_user.email  # Unchanged

    @pytest.mark.asyncio
    async def test_update_user_not_found(self, user_crud_service, db_session):
        """Test user update with non-existent ID."""
        update_data = UserUpdate(first_name="Updated")

        with pytest.raises(ValueError, match="User not found"):
            await user_crud_service.update_user(db_session, "non-existent-id", update_data)

    @pytest.mark.asyncio
    async def test_update_user_email_conflict(self, user_crud_service, test_user, db_session):
        """Test user update with conflicting email."""
        # Create another user
        other_user = User(
            email="other@example.com",
            hashed_password=get_password_hash("password"),
            first_name="Other",
            last_name="User",
            is_active=True,
            is_verified=False,
            is_superuser=False,
        )
        db_session.add(other_user)
        await db_session.flush()

        # Try to update test_user with other_user's email
        update_data = UserUpdate(email="other@example.com")

        with pytest.raises(ValueError, match="User with this email already exists"):
            await user_crud_service.update_user(db_session, str(test_user.id), update_data)

    @pytest.mark.asyncio
    async def test_delete_user_success(self, user_crud_service, test_user, db_session):
        """Test successful user deletion."""
        user_id = str(test_user.id)

        result = await user_crud_service.delete_user(db_session, user_id)
        assert result is True

        # Verify user is deleted
        deleted_user = await user_crud_service.get_user_by_id(db_session, user_id)
        assert deleted_user is None

    @pytest.mark.asyncio
    async def test_delete_user_not_found(self, user_crud_service, db_session):
        """Test user deletion with non-existent ID."""
        with pytest.raises(ValueError, match="User not found"):
            await user_crud_service.delete_user(db_session, "non-existent-id")

    @pytest.mark.asyncio
    async def test_list_users_with_pagination(self, user_crud_service, populated_database, db_session):
        """Test user listing with pagination."""
        # Test first page
        users_page1, total = await user_crud_service.list_users(
            db_session, skip=0, limit=5
        )

        assert len(users_page1) <= 5
        assert total >= 10  # From populated_database fixture

        # Test second page
        users_page2, _ = await user_crud_service.list_users(
            db_session, skip=5, limit=5
        )

        assert len(users_page2) <= 5
        # Ensure different users on different pages
        page1_ids = {user.id for user in users_page1}
        page2_ids = {user.id for user in users_page2}
        assert page1_ids.isdisjoint(page2_ids)

    @pytest.mark.asyncio
    async def test_list_users_with_filters(self, user_crud_service, populated_database, db_session):
        """Test user listing with filters."""
        # Filter by active status
        active_users, total_active = await user_crud_service.list_users(
            db_session, is_active=True
        )

        assert all(user.is_active for user in active_users)
        assert total_active > 0

        # Filter by email search
        search_users, search_total = await user_crud_service.list_users(
            db_session, search="user1@example.com"
        )

        assert search_total >= 1
        assert any("user1@example.com" in user.email for user in search_users)

    @pytest.mark.asyncio
    async def test_assign_role_to_user(self, user_crud_service, test_user, populated_database, db_session):
        """Test assigning role to user."""
        # Get a role from populated database
        editor_role = await db_session.execute(
            "SELECT * FROM roles WHERE name = 'editor'"
        )
        role = editor_role.first()

        if role:
            success = await user_crud_service.assign_role_to_user(
                db_session, str(test_user.id), str(role.id)
            )

            assert success is True

            # Verify role assignment
            user_with_roles = await user_crud_service.get_user_with_roles(
                db_session, str(test_user.id)
            )
            role_names = [role.name for role in user_with_roles.roles]
            assert "editor" in role_names

    @pytest.mark.asyncio
    async def test_remove_role_from_user(self, user_crud_service, test_user, populated_database, db_session):
        """Test removing role from user."""
        # First assign a role
        editor_role = await db_session.execute(
            "SELECT * FROM roles WHERE name = 'editor'"
        )
        role = editor_role.first()

        if role:
            await user_crud_service.assign_role_to_user(
                db_session, str(test_user.id), str(role.id)
            )

            # Now remove the role
            success = await user_crud_service.remove_role_from_user(
                db_session, str(test_user.id), str(role.id)
            )

            assert success is True

            # Verify role removal
            user_with_roles = await user_crud_service.get_user_with_roles(
                db_session, str(test_user.id)
            )
            role_names = [role.name for role in user_with_roles.roles]
            assert "editor" not in role_names

    @pytest.mark.asyncio
    async def test_bulk_update_users(self, user_crud_service, populated_database, db_session):
        """Test bulk user operations."""
        # Get some user IDs
        users, _ = await user_crud_service.list_users(db_session, limit=3)
        user_ids = [str(user.id) for user in users[:2]]

        # Bulk activate users
        updated_count = await user_crud_service.bulk_update_users(
            db_session, user_ids, {"is_active": True}
        )

        assert updated_count == 2

        # Verify updates
        for user_id in user_ids:
            user = await user_crud_service.get_user_by_id(db_session, user_id)
            assert user.is_active is True

    @pytest.mark.asyncio
    async def test_get_user_with_roles_optimized(self, user_crud_service, test_user, db_session):
        """Test optimized user query with roles (no N+1 queries)."""
        with patch('sqlalchemy.engine.Engine.execute') as mock_execute:
            user_with_roles = await user_crud_service.get_user_with_roles(
                db_session, str(test_user.id)
            )

            assert user_with_roles is not None
            assert user_with_roles.id == test_user.id
            # Should load roles in the same query (no N+1)
            assert hasattr(user_with_roles, 'roles')

    @pytest.mark.asyncio
    async def test_get_users_with_role_count(self, user_crud_service, populated_database, db_session):
        """Test getting users with role count statistics."""
        stats = await user_crud_service.get_users_statistics(db_session)

        assert 'total_users' in stats
        assert 'active_users' in stats
        assert 'verified_users' in stats
        assert 'superusers' in stats
        assert stats['total_users'] > 0

    @pytest.mark.asyncio
    async def test_service_error_handling(self, user_crud_service, db_session):
        """Test service error handling for database errors."""
        with patch.object(db_session, 'execute', side_effect=Exception("Database error")):
            with pytest.raises(Exception, match="Database error"):
                await user_crud_service.get_user_by_id(db_session, "test-id")

    @pytest.mark.asyncio
    async def test_input_validation(self, user_crud_service, db_session):
        """Test input validation in service methods."""
        # Test invalid user ID format
        user = await user_crud_service.get_user_by_id(db_session, "")
        assert user is None

        # Test invalid email format in search
        users, total = await user_crud_service.list_users(db_session, search="invalid-email")
        assert total == 0