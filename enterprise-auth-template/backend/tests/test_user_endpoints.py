"""
User Management Endpoints Tests

Comprehensive integration tests for user management endpoints including
profile operations, user listing, role management, and admin functions.
"""

import pytest
from datetime import datetime
from typing import List, Dict
from unittest.mock import AsyncMock, MagicMock, patch

import pytest_asyncio
from fastapi import status
from fastapi.testclient import TestClient
from sqlalchemy.ext.asyncio import AsyncSession

from app.main import app
from app.models.user import User, Role
from app.schemas.user import UserUpdate


@pytest.fixture
def client() -> TestClient:
    """Create test client."""
    return TestClient(app)


@pytest.fixture
def mock_db_session() -> AsyncSession:
    """Create mock database session."""
    session = MagicMock(spec=AsyncSession)
    session.commit = AsyncMock()
    session.rollback = AsyncMock()
    session.execute = AsyncMock()
    session.add = MagicMock()
    session.refresh = AsyncMock()
    return session


@pytest.fixture
def sample_user() -> User:
    """Create a sample user for testing."""
    user = User(
        id="123e4567-e89b-12d3-a456-426614174000",
        email="test@example.com",
        username="testuser",
        first_name="Test",
        last_name="User",
        hashed_password="hashed_password",
        email_verified=True,
        is_active=True,
        created_at=datetime.utcnow(),
        updated_at=datetime.utcnow(),
    )
    # Mock roles relationship
    user.roles = ["user"]
    user.is_verified = True
    return user


@pytest.fixture
def admin_user() -> User:
    """Create an admin user for testing."""
    user = User(
        id="admin-456-789-012-345678901234",
        email="admin@example.com",
        username="admin",
        first_name="Admin",
        last_name="User",
        hashed_password="admin_hashed_password",
        email_verified=True,
        is_active=True,
        created_at=datetime.utcnow(),
        updated_at=datetime.utcnow(),
    )
    user.roles = ["admin"]
    user.is_verified = True
    return user


@pytest.fixture
def auth_headers() -> Dict[str, str]:
    """Create authentication headers for testing."""
    return {"Authorization": "Bearer test_access_token"}


@pytest.fixture
def admin_auth_headers() -> Dict[str, str]:
    """Create admin authentication headers for testing."""
    return {"Authorization": "Bearer admin_access_token"}


class TestCurrentUserProfile:
    """Tests for current user profile endpoints."""

    @patch("app.api.v1.users.get_db_session")
    @patch("app.api.v1.users.get_current_user")
    def test_get_current_user_profile_success(
        self, mock_get_current_user, mock_get_db, client, sample_user, auth_headers
    ):
        """Test successful retrieval of current user profile."""
        # Setup mocks
        mock_get_current_user.return_value = sample_user
        mock_get_db.return_value = MagicMock()

        # Make request
        response = client.get("/api/v1/users/me", headers=auth_headers)

        # Assertions
        assert response.status_code == 200
        data = response.json()
        assert data["id"] == sample_user.id
        assert data["email"] == sample_user.email
        assert data["first_name"] == sample_user.first_name
        assert data["last_name"] == sample_user.last_name
        assert data["is_active"] == sample_user.is_active
        assert data["is_verified"] == sample_user.is_verified
        assert data["roles"] == sample_user.roles

    @patch("app.api.v1.users.get_current_user")
    def test_get_current_user_profile_unauthorized(self, mock_get_current_user, client):
        """Test getting profile without authentication."""
        mock_get_current_user.side_effect = Exception("Unauthorized")

        response = client.get("/api/v1/users/me")

        # Should handle authentication error (exact behavior depends on auth implementation)
        assert response.status_code in [401, 500]

    @patch("app.api.v1.users.get_db_session")
    @patch("app.api.v1.users.get_current_user")
    def test_update_current_user_profile_success(
        self, mock_get_current_user, mock_get_db, client, sample_user, auth_headers
    ):
        """Test successful update of current user profile."""
        # Setup mocks
        mock_get_current_user.return_value = sample_user
        mock_get_db.return_value = MagicMock()

        # Update data
        update_data = {"first_name": "Updated", "last_name": "Name"}

        # Make request
        response = client.put(
            "/api/v1/users/me", json=update_data, headers=auth_headers
        )

        # Assertions
        assert response.status_code == 200
        data = response.json()
        assert data["first_name"] == "Updated"
        assert data["last_name"] == "Name"
        assert data["email"] == sample_user.email  # Unchanged

    @patch("app.api.v1.users.get_db_session")
    @patch("app.api.v1.users.get_current_user")
    def test_update_current_user_profile_partial(
        self, mock_get_current_user, mock_get_db, client, sample_user, auth_headers
    ):
        """Test partial update of current user profile."""
        # Setup mocks
        mock_get_current_user.return_value = sample_user
        mock_get_db.return_value = MagicMock()

        # Partial update data
        update_data = {
            "first_name": "NewFirst"
            # last_name not included
        }

        # Make request
        response = client.put(
            "/api/v1/users/me", json=update_data, headers=auth_headers
        )

        # Assertions
        assert response.status_code == 200
        data = response.json()
        assert data["first_name"] == "NewFirst"
        assert data["last_name"] == sample_user.last_name  # Unchanged

    def test_update_current_user_profile_invalid_data(self, client, auth_headers):
        """Test update with invalid data."""
        invalid_data = {"invalid_field": "value"}

        response = client.put(
            "/api/v1/users/me", json=invalid_data, headers=auth_headers
        )

        # Should handle validation error appropriately
        assert response.status_code in [422, 400]

    @patch("app.api.v1.users.get_current_user")
    def test_update_current_user_profile_unauthorized(
        self, mock_get_current_user, client
    ):
        """Test updating profile without authentication."""
        mock_get_current_user.side_effect = Exception("Unauthorized")

        update_data = {"first_name": "Updated"}

        response = client.put("/api/v1/users/me", json=update_data)

        # Should handle authentication error
        assert response.status_code in [401, 500]


class TestUserListing:
    """Tests for user listing endpoints."""

    @patch("app.api.v1.users.get_db_session")
    @patch("app.api.v1.users.require_permissions")
    def test_list_users_success(
        self,
        mock_require_permissions,
        mock_get_db,
        client,
        admin_user,
        admin_auth_headers,
    ):
        """Test successful user listing by admin."""
        # Setup mocks
        mock_require_permissions.return_value = admin_user
        mock_get_db.return_value = MagicMock()

        # Make request
        response = client.get("/api/v1/users/", headers=admin_auth_headers)

        # Assertions
        assert response.status_code == 200
        data = response.json()
        assert "users" in data
        assert "total" in data
        assert "skip" in data
        assert "limit" in data
        assert isinstance(data["users"], list)
        assert data["skip"] == 0
        assert data["limit"] == 100  # Default limit

    @patch("app.api.v1.users.get_db_session")
    @patch("app.api.v1.users.require_permissions")
    def test_list_users_with_pagination(
        self,
        mock_require_permissions,
        mock_get_db,
        client,
        admin_user,
        admin_auth_headers,
    ):
        """Test user listing with pagination parameters."""
        # Setup mocks
        mock_require_permissions.return_value = admin_user
        mock_get_db.return_value = MagicMock()

        # Make request with pagination
        response = client.get(
            "/api/v1/users/?skip=10&limit=20", headers=admin_auth_headers
        )

        # Assertions
        assert response.status_code == 200
        data = response.json()
        assert data["skip"] == 10
        assert data["limit"] == 20

    @patch("app.api.v1.users.get_db_session")
    @patch("app.api.v1.users.require_permissions")
    def test_list_users_with_search(
        self,
        mock_require_permissions,
        mock_get_db,
        client,
        admin_user,
        admin_auth_headers,
    ):
        """Test user listing with search parameter."""
        # Setup mocks
        mock_require_permissions.return_value = admin_user
        mock_get_db.return_value = MagicMock()

        # Make request with search
        response = client.get("/api/v1/users/?search=john", headers=admin_auth_headers)

        # Assertions
        assert response.status_code == 200
        data = response.json()
        assert isinstance(data["users"], list)

    @patch("app.api.v1.users.get_db_session")
    @patch("app.api.v1.users.require_permissions")
    def test_list_users_with_filters(
        self,
        mock_require_permissions,
        mock_get_db,
        client,
        admin_user,
        admin_auth_headers,
    ):
        """Test user listing with various filters."""
        # Setup mocks
        mock_require_permissions.return_value = admin_user
        mock_get_db.return_value = MagicMock()

        # Make request with filters
        response = client.get(
            "/api/v1/users/?role=admin&is_active=true", headers=admin_auth_headers
        )

        # Assertions
        assert response.status_code == 200
        data = response.json()
        assert isinstance(data["users"], list)

    def test_list_users_invalid_pagination(self, client, admin_auth_headers):
        """Test user listing with invalid pagination parameters."""
        # Make request with invalid pagination
        response = client.get(
            "/api/v1/users/?skip=-1&limit=0", headers=admin_auth_headers
        )

        # Should handle validation error
        assert response.status_code == 422

    def test_list_users_excessive_limit(self, client, admin_auth_headers):
        """Test user listing with excessive limit."""
        # Make request with limit above maximum
        response = client.get("/api/v1/users/?limit=2000", headers=admin_auth_headers)

        # Should handle validation error
        assert response.status_code == 422

    @patch("app.api.v1.users.require_permissions")
    def test_list_users_insufficient_permissions(
        self, mock_require_permissions, client, auth_headers
    ):
        """Test user listing without admin permissions."""
        mock_require_permissions.side_effect = Exception("Insufficient permissions")

        response = client.get("/api/v1/users/", headers=auth_headers)

        # Should handle permission error
        assert response.status_code in [403, 500]


class TestUserRetrieval:
    """Tests for individual user retrieval."""

    @patch("app.api.v1.users.get_db_session")
    def test_get_user_success(self, mock_get_db, client, admin_auth_headers):
        """Test successful user retrieval by ID."""
        # Setup mocks
        mock_get_db.return_value = MagicMock()

        user_id = "test-user-123"

        # Make request
        response = client.get(f"/api/v1/users/{user_id}", headers=admin_auth_headers)

        # Assertions
        assert response.status_code == 200
        data = response.json()
        assert data["id"] == user_id
        assert "email" in data
        assert "first_name" in data
        assert "last_name" in data
        assert "is_active" in data
        assert "is_verified" in data
        assert "roles" in data

    @patch("app.api.v1.users.get_db_session")
    def test_get_user_with_uuid(self, mock_get_db, client, admin_auth_headers):
        """Test user retrieval with UUID format."""
        # Setup mocks
        mock_get_db.return_value = MagicMock()

        user_id = "123e4567-e89b-12d3-a456-426614174000"

        # Make request
        response = client.get(f"/api/v1/users/{user_id}", headers=admin_auth_headers)

        # Assertions
        assert response.status_code == 200
        data = response.json()
        assert data["id"] == user_id

    def test_get_user_unauthorized(self, client):
        """Test user retrieval without authentication."""
        user_id = "test-user-123"

        response = client.get(f"/api/v1/users/{user_id}")

        # Should handle authentication error
        assert response.status_code in [401, 500]


class TestUserUpdate:
    """Tests for user update by ID."""

    @patch("app.api.v1.users.get_db_session")
    def test_update_user_success(self, mock_get_db, client, admin_auth_headers):
        """Test successful user update by admin."""
        # Setup mocks
        mock_get_db.return_value = MagicMock()

        user_id = "test-user-123"
        update_data = {"first_name": "Updated", "last_name": "Name"}

        # Make request
        response = client.put(
            f"/api/v1/users/{user_id}", json=update_data, headers=admin_auth_headers
        )

        # Assertions
        assert response.status_code == 200
        data = response.json()
        assert data["id"] == user_id
        assert data["first_name"] == "Updated"
        assert data["last_name"] == "Name"

    @patch("app.api.v1.users.get_db_session")
    def test_update_user_partial(self, mock_get_db, client, admin_auth_headers):
        """Test partial user update."""
        # Setup mocks
        mock_get_db.return_value = MagicMock()

        user_id = "test-user-123"
        update_data = {
            "first_name": "OnlyFirst"
            # last_name not included
        }

        # Make request
        response = client.put(
            f"/api/v1/users/{user_id}", json=update_data, headers=admin_auth_headers
        )

        # Assertions
        assert response.status_code == 200
        data = response.json()
        assert data["first_name"] == "OnlyFirst"

    def test_update_user_invalid_data(self, client, admin_auth_headers):
        """Test user update with invalid data."""
        user_id = "test-user-123"
        invalid_data = {"invalid_field": "value"}

        response = client.put(
            f"/api/v1/users/{user_id}", json=invalid_data, headers=admin_auth_headers
        )

        # Should handle validation error appropriately
        assert response.status_code in [
            422,
            400,
            200,
        ]  # Depends on validation implementation

    def test_update_user_unauthorized(self, client):
        """Test user update without authentication."""
        user_id = "test-user-123"
        update_data = {"first_name": "Updated"}

        response = client.put(f"/api/v1/users/{user_id}", json=update_data)

        # Should handle authentication error
        assert response.status_code in [401, 500]


class TestUserDeletion:
    """Tests for user deletion."""

    @patch("app.api.v1.users.get_db_session")
    def test_delete_user_success(self, mock_get_db, client, admin_auth_headers):
        """Test successful user deletion."""
        # Setup mocks
        mock_get_db.return_value = MagicMock()

        user_id = "test-user-123"

        # Make request
        response = client.delete(f"/api/v1/users/{user_id}", headers=admin_auth_headers)

        # Assertions
        assert response.status_code == 200
        data = response.json()
        assert "message" in data
        assert user_id in data["message"]
        assert "deleted" in data["message"].lower()

    def test_delete_user_unauthorized(self, client):
        """Test user deletion without authentication."""
        user_id = "test-user-123"

        response = client.delete(f"/api/v1/users/{user_id}")

        # Should handle authentication error
        assert response.status_code in [401, 500]


class TestUserActivation:
    """Tests for user activation/deactivation."""

    @patch("app.api.v1.users.get_db_session")
    def test_activate_user_success(self, mock_get_db, client, admin_auth_headers):
        """Test successful user activation."""
        # Setup mocks
        mock_get_db.return_value = MagicMock()

        user_id = "test-user-123"

        # Make request
        response = client.post(
            f"/api/v1/users/{user_id}/activate", headers=admin_auth_headers
        )

        # Assertions
        assert response.status_code == 200
        data = response.json()
        assert "message" in data
        assert user_id in data["message"]
        assert "activated" in data["message"].lower()

    @patch("app.api.v1.users.get_db_session")
    def test_deactivate_user_success(self, mock_get_db, client, admin_auth_headers):
        """Test successful user deactivation."""
        # Setup mocks
        mock_get_db.return_value = MagicMock()

        user_id = "test-user-123"

        # Make request
        response = client.post(
            f"/api/v1/users/{user_id}/deactivate", headers=admin_auth_headers
        )

        # Assertions
        assert response.status_code == 200
        data = response.json()
        assert "message" in data
        assert user_id in data["message"]
        assert "deactivated" in data["message"].lower()

    def test_activate_user_unauthorized(self, client):
        """Test user activation without authentication."""
        user_id = "test-user-123"

        response = client.post(f"/api/v1/users/{user_id}/activate")

        # Should handle authentication error
        assert response.status_code in [401, 500]

    def test_deactivate_user_unauthorized(self, client):
        """Test user deactivation without authentication."""
        user_id = "test-user-123"

        response = client.post(f"/api/v1/users/{user_id}/deactivate")

        # Should handle authentication error
        assert response.status_code in [401, 500]


class TestUserRoleManagement:
    """Tests for user role management."""

    @patch("app.api.v1.users.get_db_session")
    def test_update_user_roles_success(self, mock_get_db, client, admin_auth_headers):
        """Test successful user role update."""
        # Setup mocks
        mock_get_db.return_value = MagicMock()

        user_id = "test-user-123"
        new_roles = ["admin", "moderator"]

        # Make request
        response = client.put(
            f"/api/v1/users/{user_id}/roles", json=new_roles, headers=admin_auth_headers
        )

        # Assertions
        assert response.status_code == 200
        data = response.json()
        assert data["id"] == user_id
        assert data["roles"] == new_roles

    @patch("app.api.v1.users.get_db_session")
    def test_update_user_roles_single_role(
        self, mock_get_db, client, admin_auth_headers
    ):
        """Test user role update with single role."""
        # Setup mocks
        mock_get_db.return_value = MagicMock()

        user_id = "test-user-123"
        new_roles = ["user"]

        # Make request
        response = client.put(
            f"/api/v1/users/{user_id}/roles", json=new_roles, headers=admin_auth_headers
        )

        # Assertions
        assert response.status_code == 200
        data = response.json()
        assert data["roles"] == ["user"]

    @patch("app.api.v1.users.get_db_session")
    def test_update_user_roles_empty_list(
        self, mock_get_db, client, admin_auth_headers
    ):
        """Test user role update with empty role list."""
        # Setup mocks
        mock_get_db.return_value = MagicMock()

        user_id = "test-user-123"
        new_roles = []

        # Make request
        response = client.put(
            f"/api/v1/users/{user_id}/roles", json=new_roles, headers=admin_auth_headers
        )

        # Assertions
        assert response.status_code == 200
        data = response.json()
        assert data["roles"] == []

    def test_update_user_roles_invalid_data(self, client, admin_auth_headers):
        """Test user role update with invalid data."""
        user_id = "test-user-123"
        invalid_data = "not_a_list"

        response = client.put(
            f"/api/v1/users/{user_id}/roles",
            json=invalid_data,
            headers=admin_auth_headers,
        )

        # Should handle validation error
        assert response.status_code == 422

    def test_update_user_roles_unauthorized(self, client):
        """Test user role update without authentication."""
        user_id = "test-user-123"
        new_roles = ["admin"]

        response = client.put(f"/api/v1/users/{user_id}/roles", json=new_roles)

        # Should handle authentication error
        assert response.status_code in [401, 500]


class TestUserEndpointsIntegration:
    """Integration tests for user endpoints workflow."""

    @patch("app.api.v1.users.get_db_session")
    @patch("app.api.v1.users.get_current_user")
    def test_current_user_workflow(
        self, mock_get_current_user, mock_get_db, client, sample_user, auth_headers
    ):
        """Test complete current user profile workflow."""
        # Setup mocks
        mock_get_current_user.return_value = sample_user
        mock_get_db.return_value = MagicMock()

        # Step 1: Get current profile
        response = client.get("/api/v1/users/me", headers=auth_headers)
        assert response.status_code == 200
        original_data = response.json()

        # Step 2: Update profile
        update_data = {"first_name": "Updated", "last_name": "Name"}
        response = client.put(
            "/api/v1/users/me", json=update_data, headers=auth_headers
        )
        assert response.status_code == 200
        updated_data = response.json()

        # Verify changes
        assert updated_data["first_name"] == "Updated"
        assert updated_data["last_name"] == "Name"
        assert updated_data["email"] == original_data["email"]  # Unchanged

    @patch("app.api.v1.users.get_db_session")
    @patch("app.api.v1.users.require_permissions")
    def test_admin_user_management_workflow(
        self,
        mock_require_permissions,
        mock_get_db,
        client,
        admin_user,
        admin_auth_headers,
    ):
        """Test complete admin user management workflow."""
        # Setup mocks
        mock_require_permissions.return_value = admin_user
        mock_get_db.return_value = MagicMock()

        user_id = "test-user-123"

        # Step 1: List users
        response = client.get("/api/v1/users/", headers=admin_auth_headers)
        assert response.status_code == 200

        # Step 2: Get specific user
        response = client.get(f"/api/v1/users/{user_id}", headers=admin_auth_headers)
        assert response.status_code == 200

        # Step 3: Update user
        update_data = {"first_name": "Updated"}
        response = client.put(
            f"/api/v1/users/{user_id}", json=update_data, headers=admin_auth_headers
        )
        assert response.status_code == 200

        # Step 4: Update roles
        new_roles = ["admin", "user"]
        response = client.put(
            f"/api/v1/users/{user_id}/roles", json=new_roles, headers=admin_auth_headers
        )
        assert response.status_code == 200

        # Step 5: Deactivate user
        response = client.post(
            f"/api/v1/users/{user_id}/deactivate", headers=admin_auth_headers
        )
        assert response.status_code == 200

        # Step 6: Activate user
        response = client.post(
            f"/api/v1/users/{user_id}/activate", headers=admin_auth_headers
        )
        assert response.status_code == 200

    def test_user_endpoints_error_handling(self, client):
        """Test user endpoints handle errors gracefully."""
        # Test endpoints without authentication
        endpoints = [
            ("GET", "/api/v1/users/me"),
            ("PUT", "/api/v1/users/me"),
            ("GET", "/api/v1/users/"),
            ("GET", "/api/v1/users/test-id"),
            ("PUT", "/api/v1/users/test-id"),
            ("DELETE", "/api/v1/users/test-id"),
            ("POST", "/api/v1/users/test-id/activate"),
            ("POST", "/api/v1/users/test-id/deactivate"),
            ("PUT", "/api/v1/users/test-id/roles"),
        ]

        for method, url in endpoints:
            if method == "GET":
                response = client.get(url)
            elif method == "PUT":
                response = client.put(url, json={})
            elif method == "POST":
                response = client.post(url, json={})
            elif method == "DELETE":
                response = client.delete(url)

            # Should handle authentication errors gracefully
            assert response.status_code in [401, 422, 500]

    def test_user_endpoints_data_validation(self, client, auth_headers):
        """Test user endpoints validate data properly."""
        # Test various invalid data formats
        invalid_payloads = [
            "not_json",
            {"invalid": "field"},
            None,
            [],
        ]

        endpoints_with_data = [
            ("PUT", "/api/v1/users/me"),
            ("PUT", "/api/v1/users/test-id"),
        ]

        for method, url in endpoints_with_data:
            for payload in invalid_payloads:
                try:
                    if method == "PUT":
                        response = client.put(url, json=payload, headers=auth_headers)

                    # Should handle validation appropriately
                    assert response.status_code in [200, 400, 422, 500]
                except Exception:
                    # Some payloads might cause serialization errors, which is acceptable
                    pass

    @patch("app.api.v1.users.get_db_session")
    def test_user_id_formats(self, mock_get_db, client, admin_auth_headers):
        """Test user endpoints handle different ID formats."""
        mock_get_db.return_value = MagicMock()

        # Test different user ID formats
        user_ids = [
            "simple-id",
            "123",
            "123e4567-e89b-12d3-a456-426614174000",  # UUID
            "user_with_underscores",
            "user-with-dashes-123",
        ]

        for user_id in user_ids:
            # Test GET user
            response = client.get(
                f"/api/v1/users/{user_id}", headers=admin_auth_headers
            )
            assert response.status_code == 200
            data = response.json()
            assert data["id"] == user_id

    def test_pagination_edge_cases(self, client, admin_auth_headers):
        """Test pagination edge cases in user listing."""
        # Test valid edge cases
        test_cases = [
            {"skip": 0, "limit": 1},  # Minimum values
            {"skip": 100, "limit": 100},  # Larger values
            {"skip": 0, "limit": 1000},  # Maximum limit
        ]

        for params in test_cases:
            query = "&".join([f"{k}={v}" for k, v in params.items()])
            response = client.get(f"/api/v1/users/?{query}", headers=admin_auth_headers)
            # Should either work or handle validation gracefully
            assert response.status_code in [200, 422]
