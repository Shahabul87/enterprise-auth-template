"""
Role Management Endpoint Tests

Comprehensive tests for role management endpoints including
role creation, modification, permission assignments, and hierarchy management.
"""

import pytest
from datetime import datetime
from unittest.mock import AsyncMock, MagicMock, patch
from typing import Dict, List, Any

from fastapi import status
from fastapi.testclient import TestClient
from sqlalchemy.ext.asyncio import AsyncSession

from app.main import app
from app.models.user import Role, Permission, RolePermission


@pytest.fixture
def role_data() -> Dict[str, Any]:
    """Sample role data for testing."""
    return {
        "name": "editor",
        "description": "Content editor role",
        "is_system": False,
        "permissions": ["posts:write", "posts:read", "posts:delete"],
    }


@pytest.fixture
def system_role_data() -> Dict[str, Any]:
    """Sample system role data for testing."""
    return {
        "name": "admin",
        "description": "System administrator role",
        "is_system": True,
        "permissions": ["*:*"],  # All permissions
    }


@pytest.fixture
def mock_role() -> Role:
    """Create mock role object."""
    role = MagicMock(spec=Role)
    role.id = "role-123"
    role.name = "editor"
    role.description = "Content editor role"
    role.is_system = False
    role.created_at = datetime.utcnow()
    role.updated_at = datetime.utcnow()
    role.permissions = [
        MagicMock(resource="posts", action="read"),
        MagicMock(resource="posts", action="write"),
    ]
    return role


@pytest.fixture
def admin_headers() -> Dict[str, str]:
    """Admin authorization headers."""
    return {"Authorization": "Bearer admin-access-token"}


class TestRoleEndpoints:
    """Test role management endpoints."""

    def test_get_all_roles_success(
        self, client: TestClient, admin_headers: Dict[str, str]
    ) -> None:
        """Test successful retrieval of all roles."""
        with patch("app.api.v1.roles.get_db_session"):
            with patch("app.api.v1.roles.RoleService") as MockRoleService:
                mock_service = MockRoleService.return_value
                mock_service.get_all_roles = AsyncMock(
                    return_value=[
                        {
                            "id": "role-1",
                            "name": "user",
                            "description": "Basic user role",
                            "is_system": True,
                            "created_at": "2024-01-01T00:00:00Z",
                            "permissions": ["posts:read"],
                            "user_count": 150,
                        },
                        {
                            "id": "role-2",
                            "name": "editor",
                            "description": "Content editor role",
                            "is_system": False,
                            "created_at": "2024-01-01T00:00:00Z",
                            "permissions": ["posts:read", "posts:write"],
                            "user_count": 25,
                        },
                        {
                            "id": "role-3",
                            "name": "admin",
                            "description": "System administrator",
                            "is_system": True,
                            "created_at": "2024-01-01T00:00:00Z",
                            "permissions": ["*:*"],
                            "user_count": 5,
                        },
                    ]
                )

                response = client.get("/api/v1/roles", headers=admin_headers)

                assert response.status_code == status.HTTP_200_OK
                data = response.json()
                assert len(data) == 3
                assert data[0]["name"] == "user"
                assert data[1]["user_count"] == 25
                assert data[2]["is_system"] is True

    def test_get_all_roles_with_filters(
        self, client: TestClient, admin_headers: Dict[str, str]
    ) -> None:
        """Test role retrieval with filters."""
        with patch("app.api.v1.roles.get_db_session"):
            with patch("app.api.v1.roles.RoleService") as MockRoleService:
                mock_service = MockRoleService.return_value
                mock_service.get_all_roles = AsyncMock(
                    return_value=[
                        {
                            "id": "role-2",
                            "name": "editor",
                            "description": "Content editor role",
                            "is_system": False,
                            "permissions": ["posts:read", "posts:write"],
                        }
                    ]
                )

                response = client.get(
                    "/api/v1/roles?is_system=false&has_permission=posts:write",
                    headers=admin_headers,
                )

                assert response.status_code == status.HTTP_200_OK
                data = response.json()
                assert len(data) == 1
                assert data[0]["name"] == "editor"
                assert data[0]["is_system"] is False

    def test_get_all_roles_unauthorized(self, client: TestClient) -> None:
        """Test role retrieval without admin privileges."""
        response = client.get("/api/v1/roles")
        assert response.status_code == status.HTTP_401_UNAUTHORIZED

    def test_get_role_by_id_success(
        self, client: TestClient, admin_headers: Dict[str, str]
    ) -> None:
        """Test successful role retrieval by ID."""
        role_id = "role-123"

        with patch("app.api.v1.roles.get_db_session"):
            with patch("app.api.v1.roles.RoleService") as MockRoleService:
                mock_service = MockRoleService.return_value
                mock_service.get_role_by_id = AsyncMock(
                    return_value={
                        "id": role_id,
                        "name": "editor",
                        "description": "Content editor role",
                        "is_system": False,
                        "created_at": "2024-01-01T00:00:00Z",
                        "updated_at": "2024-01-01T00:00:00Z",
                        "permissions": [
                            {
                                "id": "perm-1",
                                "resource": "posts",
                                "action": "read",
                                "description": "Read posts",
                            },
                            {
                                "id": "perm-2",
                                "resource": "posts",
                                "action": "write",
                                "description": "Write posts",
                            },
                        ],
                        "users": [
                            {
                                "id": "user-1",
                                "email": "editor1@example.com",
                                "first_name": "Editor",
                                "last_name": "One",
                            },
                            {
                                "id": "user-2",
                                "email": "editor2@example.com",
                                "first_name": "Editor",
                                "last_name": "Two",
                            },
                        ],
                        "user_count": 2,
                    }
                )

                response = client.get(f"/api/v1/roles/{role_id}", headers=admin_headers)

                assert response.status_code == status.HTTP_200_OK
                data = response.json()
                assert data["id"] == role_id
                assert data["name"] == "editor"
                assert len(data["permissions"]) == 2
                assert len(data["users"]) == 2
                assert data["user_count"] == 2

    def test_get_role_by_id_not_found(
        self, client: TestClient, admin_headers: Dict[str, str]
    ) -> None:
        """Test role retrieval for non-existent role."""
        role_id = "non-existent-role"

        with patch("app.api.v1.roles.get_db_session"):
            with patch("app.api.v1.roles.RoleService") as MockRoleService:
                mock_service = MockRoleService.return_value
                mock_service.get_role_by_id = AsyncMock(
                    side_effect=ValueError("Role not found")
                )

                response = client.get(f"/api/v1/roles/{role_id}", headers=admin_headers)

                assert response.status_code == status.HTTP_404_NOT_FOUND
                assert "Role not found" in response.json()["detail"]

    def test_create_role_success(
        self, client: TestClient, admin_headers: Dict[str, str], role_data: Dict[str, Any]
    ) -> None:
        """Test successful role creation."""
        with patch("app.api.v1.roles.get_db_session"):
            with patch("app.api.v1.roles.RoleService") as MockRoleService:
                mock_service = MockRoleService.return_value
                mock_service.create_role = AsyncMock(
                    return_value={
                        "id": "new-role-id",
                        "name": role_data["name"],
                        "description": role_data["description"],
                        "is_system": role_data["is_system"],
                        "created_at": datetime.utcnow().isoformat(),
                        "permissions": [
                            {"resource": "posts", "action": "write"},
                            {"resource": "posts", "action": "read"},
                            {"resource": "posts", "action": "delete"},
                        ],
                    }
                )

                response = client.post(
                    "/api/v1/roles", json=role_data, headers=admin_headers
                )

                assert response.status_code == status.HTTP_201_CREATED
                data = response.json()
                assert data["name"] == role_data["name"]
                assert data["description"] == role_data["description"]
                assert len(data["permissions"]) == 3

    def test_create_role_duplicate_name(
        self, client: TestClient, admin_headers: Dict[str, str], role_data: Dict[str, Any]
    ) -> None:
        """Test role creation with duplicate name."""
        with patch("app.api.v1.roles.get_db_session"):
            with patch("app.api.v1.roles.RoleService") as MockRoleService:
                mock_service = MockRoleService.return_value
                mock_service.create_role = AsyncMock(
                    side_effect=ValueError("Role name already exists")
                )

                response = client.post(
                    "/api/v1/roles", json=role_data, headers=admin_headers
                )

                assert response.status_code == status.HTTP_400_BAD_REQUEST
                assert "Role name already exists" in response.json()["detail"]

    def test_create_role_invalid_permissions(
        self, client: TestClient, admin_headers: Dict[str, str]
    ) -> None:
        """Test role creation with invalid permissions."""
        invalid_role_data = {
            "name": "invalid_role",
            "description": "Role with invalid permissions",
            "permissions": ["invalid:permission"],
        }

        with patch("app.api.v1.roles.get_db_session"):
            with patch("app.api.v1.roles.RoleService") as MockRoleService:
                mock_service = MockRoleService.return_value
                mock_service.create_role = AsyncMock(
                    side_effect=ValueError("Invalid permission: invalid:permission")
                )

                response = client.post(
                    "/api/v1/roles", json=invalid_role_data, headers=admin_headers
                )

                assert response.status_code == status.HTTP_400_BAD_REQUEST
                assert "Invalid permission" in response.json()["detail"]

    def test_update_role_success(
        self, client: TestClient, admin_headers: Dict[str, str]
    ) -> None:
        """Test successful role update."""
        role_id = "role-123"
        update_data = {
            "description": "Updated content editor role",
            "permissions": ["posts:read", "posts:write", "posts:publish"],
        }

        with patch("app.api.v1.roles.get_db_session"):
            with patch("app.api.v1.roles.RoleService") as MockRoleService:
                mock_service = MockRoleService.return_value
                mock_service.update_role = AsyncMock(
                    return_value={
                        "id": role_id,
                        "name": "editor",
                        "description": "Updated content editor role",
                        "is_system": False,
                        "updated_at": datetime.utcnow().isoformat(),
                        "permissions": [
                            {"resource": "posts", "action": "read"},
                            {"resource": "posts", "action": "write"},
                            {"resource": "posts", "action": "publish"},
                        ],
                    }
                )

                response = client.patch(
                    f"/api/v1/roles/{role_id}", json=update_data, headers=admin_headers
                )

                assert response.status_code == status.HTTP_200_OK
                data = response.json()
                assert data["description"] == "Updated content editor role"
                assert len(data["permissions"]) == 3

    def test_update_system_role_forbidden(
        self, client: TestClient, admin_headers: Dict[str, str]
    ) -> None:
        """Test updating system role should be restricted."""
        role_id = "system-role-123"
        update_data = {"description": "Modified system role"}

        with patch("app.api.v1.roles.get_db_session"):
            with patch("app.api.v1.roles.RoleService") as MockRoleService:
                mock_service = MockRoleService.return_value
                mock_service.update_role = AsyncMock(
                    side_effect=ValueError("Cannot modify system role")
                )

                response = client.patch(
                    f"/api/v1/roles/{role_id}", json=update_data, headers=admin_headers
                )

                assert response.status_code == status.HTTP_400_BAD_REQUEST
                assert "Cannot modify system role" in response.json()["detail"]

    def test_delete_role_success(
        self, client: TestClient, admin_headers: Dict[str, str]
    ) -> None:
        """Test successful role deletion."""
        role_id = "role-123"

        with patch("app.api.v1.roles.get_db_session"):
            with patch("app.api.v1.roles.RoleService") as MockRoleService:
                mock_service = MockRoleService.return_value
                mock_service.delete_role = AsyncMock(
                    return_value={
                        "message": "Role deleted successfully",
                        "reassigned_users": 3,
                        "default_role": "user",
                    }
                )

                response = client.delete(f"/api/v1/roles/{role_id}", headers=admin_headers)

                assert response.status_code == status.HTTP_200_OK
                data = response.json()
                assert "Role deleted successfully" in data["message"]
                assert data["reassigned_users"] == 3

    def test_delete_system_role_forbidden(
        self, client: TestClient, admin_headers: Dict[str, str]
    ) -> None:
        """Test deleting system role should be forbidden."""
        role_id = "system-role-123"

        with patch("app.api.v1.roles.get_db_session"):
            with patch("app.api.v1.roles.RoleService") as MockRoleService:
                mock_service = MockRoleService.return_value
                mock_service.delete_role = AsyncMock(
                    side_effect=ValueError("Cannot delete system role")
                )

                response = client.delete(f"/api/v1/roles/{role_id}", headers=admin_headers)

                assert response.status_code == status.HTTP_400_BAD_REQUEST
                assert "Cannot delete system role" in response.json()["detail"]

    def test_delete_role_with_users(
        self, client: TestClient, admin_headers: Dict[str, str]
    ) -> None:
        """Test role deletion when users are assigned to it."""
        role_id = "role-123"

        with patch("app.api.v1.roles.get_db_session"):
            with patch("app.api.v1.roles.RoleService") as MockRoleService:
                mock_service = MockRoleService.return_value
                mock_service.delete_role = AsyncMock(
                    return_value={
                        "message": "Role deleted successfully",
                        "reassigned_users": 5,
                        "default_role": "user",
                        "warning": "Users were reassigned to default role",
                    }
                )

                response = client.delete(f"/api/v1/roles/{role_id}", headers=admin_headers)

                assert response.status_code == status.HTTP_200_OK
                data = response.json()
                assert data["reassigned_users"] == 5
                assert "warning" in data


class TestRolePermissionManagement:
    """Test role permission management."""

    def test_assign_permission_to_role_success(
        self, client: TestClient, admin_headers: Dict[str, str]
    ) -> None:
        """Test successful permission assignment to role."""
        role_id = "role-123"
        permission_data = {"permission_id": "perm-456"}

        with patch("app.api.v1.roles.get_db_session"):
            with patch("app.api.v1.roles.RoleService") as MockRoleService:
                mock_service = MockRoleService.return_value
                mock_service.assign_permission_to_role = AsyncMock(
                    return_value={
                        "role_id": role_id,
                        "permission_id": "perm-456",
                        "message": "Permission assigned successfully",
                        "permissions": [
                            {"resource": "posts", "action": "read"},
                            {"resource": "posts", "action": "write"},
                            {"resource": "posts", "action": "publish"},
                        ],
                    }
                )

                response = client.post(
                    f"/api/v1/roles/{role_id}/permissions",
                    json=permission_data,
                    headers=admin_headers,
                )

                assert response.status_code == status.HTTP_200_OK
                data = response.json()
                assert "Permission assigned successfully" in data["message"]
                assert len(data["permissions"]) == 3

    def test_revoke_permission_from_role_success(
        self, client: TestClient, admin_headers: Dict[str, str]
    ) -> None:
        """Test successful permission revocation from role."""
        role_id = "role-123"
        permission_id = "perm-456"

        with patch("app.api.v1.roles.get_db_session"):
            with patch("app.api.v1.roles.RoleService") as MockRoleService:
                mock_service = MockRoleService.return_value
                mock_service.revoke_permission_from_role = AsyncMock(
                    return_value={
                        "role_id": role_id,
                        "permission_id": permission_id,
                        "message": "Permission revoked successfully",
                        "permissions": [
                            {"resource": "posts", "action": "read"},
                            {"resource": "posts", "action": "write"},
                        ],
                    }
                )

                response = client.delete(
                    f"/api/v1/roles/{role_id}/permissions/{permission_id}",
                    headers=admin_headers,
                )

                assert response.status_code == status.HTTP_200_OK
                data = response.json()
                assert "Permission revoked successfully" in data["message"]
                assert len(data["permissions"]) == 2

    def test_bulk_assign_permissions_success(
        self, client: TestClient, admin_headers: Dict[str, str]
    ) -> None:
        """Test bulk permission assignment to role."""
        role_id = "role-123"
        bulk_data = {
            "permission_ids": ["perm-1", "perm-2", "perm-3"],
            "replace_existing": True,
        }

        with patch("app.api.v1.roles.get_db_session"):
            with patch("app.api.v1.roles.RoleService") as MockRoleService:
                mock_service = MockRoleService.return_value
                mock_service.bulk_assign_permissions = AsyncMock(
                    return_value={
                        "role_id": role_id,
                        "message": "Permissions updated successfully",
                        "assigned_count": 3,
                        "removed_count": 2,
                        "permissions": [
                            {"id": "perm-1", "resource": "posts", "action": "read"},
                            {"id": "perm-2", "resource": "posts", "action": "write"},
                            {"id": "perm-3", "resource": "posts", "action": "delete"},
                        ],
                    }
                )

                response = client.post(
                    f"/api/v1/roles/{role_id}/permissions/bulk",
                    json=bulk_data,
                    headers=admin_headers,
                )

                assert response.status_code == status.HTTP_200_OK
                data = response.json()
                assert data["assigned_count"] == 3
                assert data["removed_count"] == 2
                assert len(data["permissions"]) == 3


class TestRoleHierarchy:
    """Test role hierarchy and inheritance."""

    def test_get_role_hierarchy_success(
        self, client: TestClient, admin_headers: Dict[str, str]
    ) -> None:
        """Test successful role hierarchy retrieval."""
        with patch("app.api.v1.roles.get_db_session"):
            with patch("app.api.v1.roles.RoleService") as MockRoleService:
                mock_service = MockRoleService.return_value
                mock_service.get_role_hierarchy = AsyncMock(
                    return_value={
                        "hierarchy": [
                            {
                                "name": "admin",
                                "level": 1,
                                "children": [
                                    {
                                        "name": "manager",
                                        "level": 2,
                                        "children": [
                                            {
                                                "name": "editor",
                                                "level": 3,
                                                "children": [
                                                    {
                                                        "name": "user",
                                                        "level": 4,
                                                        "children": [],
                                                    }
                                                ],
                                            }
                                        ],
                                    }
                                ],
                            }
                        ],
                        "total_levels": 4,
                    }
                )

                response = client.get("/api/v1/roles/hierarchy", headers=admin_headers)

                assert response.status_code == status.HTTP_200_OK
                data = response.json()
                assert data["total_levels"] == 4
                assert len(data["hierarchy"]) == 1
                assert data["hierarchy"][0]["name"] == "admin"

    def test_set_role_parent_success(
        self, client: TestClient, admin_headers: Dict[str, str]
    ) -> None:
        """Test setting role parent relationship."""
        role_id = "child-role-id"
        parent_data = {"parent_role_id": "parent-role-id"}

        with patch("app.api.v1.roles.get_db_session"):
            with patch("app.api.v1.roles.RoleService") as MockRoleService:
                mock_service = MockRoleService.return_value
                mock_service.set_role_parent = AsyncMock(
                    return_value={
                        "role_id": role_id,
                        "parent_role_id": "parent-role-id",
                        "message": "Role hierarchy updated successfully",
                        "inherited_permissions": [
                            {"resource": "posts", "action": "read"},
                            {"resource": "users", "action": "read"},
                        ],
                    }
                )

                response = client.post(
                    f"/api/v1/roles/{role_id}/parent",
                    json=parent_data,
                    headers=admin_headers,
                )

                assert response.status_code == status.HTTP_200_OK
                data = response.json()
                assert "Role hierarchy updated successfully" in data["message"]
                assert len(data["inherited_permissions"]) == 2


class TestRoleValidation:
    """Test role validation and business rules."""

    def test_create_role_invalid_name_format(
        self, client: TestClient, admin_headers: Dict[str, str]
    ) -> None:
        """Test role creation with invalid name format."""
        invalid_role_data = {
            "name": "Invalid Role Name!",  # Contains invalid characters
            "description": "Test role",
        }

        response = client.post(
            "/api/v1/roles", json=invalid_role_data, headers=admin_headers
        )

        # This would typically be caught by pydantic validation
        assert response.status_code in [status.HTTP_422_UNPROCESSABLE_ENTITY, status.HTTP_400_BAD_REQUEST]

    def test_create_role_reserved_name(
        self, client: TestClient, admin_headers: Dict[str, str]
    ) -> None:
        """Test role creation with reserved name."""
        reserved_role_data = {
            "name": "system",  # Reserved name
            "description": "System role",
        }

        with patch("app.api.v1.roles.get_db_session"):
            with patch("app.api.v1.roles.RoleService") as MockRoleService:
                mock_service = MockRoleService.return_value
                mock_service.create_role = AsyncMock(
                    side_effect=ValueError("Role name 'system' is reserved")
                )

                response = client.post(
                    "/api/v1/roles", json=reserved_role_data, headers=admin_headers
                )

                assert response.status_code == status.HTTP_400_BAD_REQUEST
                assert "reserved" in response.json()["detail"]

    def test_circular_hierarchy_prevention(
        self, client: TestClient, admin_headers: Dict[str, str]
    ) -> None:
        """Test prevention of circular role hierarchy."""
        role_id = "parent-role-id"
        parent_data = {"parent_role_id": "child-role-id"}  # Would create circular reference

        with patch("app.api.v1.roles.get_db_session"):
            with patch("app.api.v1.roles.RoleService") as MockRoleService:
                mock_service = MockRoleService.return_value
                mock_service.set_role_parent = AsyncMock(
                    side_effect=ValueError("Circular hierarchy detected")
                )

                response = client.post(
                    f"/api/v1/roles/{role_id}/parent",
                    json=parent_data,
                    headers=admin_headers,
                )

                assert response.status_code == status.HTTP_400_BAD_REQUEST
                assert "Circular hierarchy" in response.json()["detail"]


# Performance and edge case tests
@pytest.mark.performance
class TestRolePerformance:
    """Performance tests for role endpoints."""

    def test_large_role_list_performance(
        self, client: TestClient, admin_headers: Dict[str, str]
    ) -> None:
        """Test performance with large number of roles."""
        with patch("app.api.v1.roles.get_db_session"):
            with patch("app.api.v1.roles.RoleService") as MockRoleService:
                # Simulate large dataset
                mock_roles = [
                    {
                        "id": f"role-{i}",
                        "name": f"role_{i}",
                        "description": f"Role {i}",
                        "permissions": [f"resource_{i}:read"],
                        "user_count": i * 10,
                    }
                    for i in range(100)
                ]

                mock_service = MockRoleService.return_value
                mock_service.get_all_roles = AsyncMock(return_value=mock_roles)

                response = client.get("/api/v1/roles", headers=admin_headers)

                assert response.status_code == status.HTTP_200_OK
                data = response.json()
                assert len(data) == 100

    def test_complex_permission_assignment_performance(
        self, client: TestClient, admin_headers: Dict[str, str]
    ) -> None:
        """Test performance of complex permission assignments."""
        role_id = "complex-role"
        bulk_data = {
            "permission_ids": [f"perm-{i}" for i in range(50)],
            "replace_existing": True,
        }

        with patch("app.api.v1.roles.get_db_session"):
            with patch("app.api.v1.roles.RoleService") as MockRoleService:
                mock_service = MockRoleService.return_value
                mock_service.bulk_assign_permissions = AsyncMock(
                    return_value={
                        "assigned_count": 50,
                        "removed_count": 0,
                        "execution_time": "0.8s",
                        "permissions": [
                            {"id": f"perm-{i}", "resource": f"res_{i}", "action": "read"}
                            for i in range(50)
                        ],
                    }
                )

                response = client.post(
                    f"/api/v1/roles/{role_id}/permissions/bulk",
                    json=bulk_data,
                    headers=admin_headers,
                )

                assert response.status_code == status.HTTP_200_OK
                data = response.json()
                assert data["assigned_count"] == 50
                assert len(data["permissions"]) == 50