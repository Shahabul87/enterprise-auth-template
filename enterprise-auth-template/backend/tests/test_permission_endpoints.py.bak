"""
Permission Endpoint Tests

Comprehensive tests for permission management endpoints including
permission creation, modification, resource-action validation, and access control.
"""

import pytest
from datetime import datetime
from unittest.mock import AsyncMock, MagicMock, patch
from typing import Dict, List, Any

from fastapi import status
from fastapi.testclient import TestClient
from sqlalchemy.ext.asyncio import AsyncSession

from app.main import app
from app.models.user import Permission, Role, RolePermission


@pytest.fixture
def permission_data() -> Dict[str, Any]:
    """Sample permission data for testing."""
    return {
        "resource": "posts",
        "action": "write",
        "description": "Write posts permission",
        "conditions": {
            "owner_only": True,
            "time_restricted": False,
        },
    }


@pytest.fixture
def system_permission_data() -> Dict[str, Any]:
    """Sample system permission data for testing."""
    return {
        "resource": "system",
        "action": "manage",
        "description": "System management permission",
        "is_system": True,
        "conditions": {},
    }


@pytest.fixture
def mock_permission() -> Permission:
    """Create mock permission object."""
    permission = MagicMock(spec=Permission)
    permission.id = "perm-123"
    permission.resource = "posts"
    permission.action = "write"
    permission.description = "Write posts permission"
    permission.is_system = False
    permission.conditions = {"owner_only": True}
    permission.created_at = datetime.utcnow()
    permission.updated_at = datetime.utcnow()
    return permission


@pytest.fixture
def admin_headers() -> Dict[str, str]:
    """Admin authorization headers."""
    return {"Authorization": "Bearer admin-access-token"}


class TestPermissionEndpoints:
    """Test permission management endpoints."""

    def test_get_all_permissions_success(
        self, client: TestClient, admin_headers: Dict[str, str]
    ) -> None:
        """Test successful retrieval of all permissions."""
        with patch("app.api.v1.permissions.get_db_session"):
            with patch("app.api.v1.permissions.PermissionService") as MockPermissionService:
                mock_service = MockPermissionService.return_value
                mock_service.get_all_permissions = AsyncMock(
                    return_value=[
                        {
                            "id": "perm-1",
                            "resource": "posts",
                            "action": "read",
                            "description": "Read posts",
                            "is_system": False,
                            "created_at": "2024-01-01T00:00:00Z",
                            "conditions": {},
                            "role_count": 3,
                            "user_count": 150,
                        },
                        {
                            "id": "perm-2",
                            "resource": "posts",
                            "action": "write",
                            "description": "Write posts",
                            "is_system": False,
                            "created_at": "2024-01-01T00:00:00Z",
                            "conditions": {"owner_only": True},
                            "role_count": 2,
                            "user_count": 25,
                        },
                        {
                            "id": "perm-3",
                            "resource": "system",
                            "action": "manage",
                            "description": "System management",
                            "is_system": True,
                            "created_at": "2024-01-01T00:00:00Z",
                            "conditions": {},
                            "role_count": 1,
                            "user_count": 5,
                        },
                    ]
                )

                response = client.get("/api/v1/permissions", headers=admin_headers)

                assert response.status_code == status.HTTP_200_OK
                data = response.json()
                assert len(data) == 3
                assert data[0]["resource"] == "posts"
                assert data[1]["conditions"]["owner_only"] is True
                assert data[2]["is_system"] is True

    def test_get_all_permissions_with_filters(
        self, client: TestClient, admin_headers: Dict[str, str]
    ) -> None:
        """Test permission retrieval with filters."""
        with patch("app.api.v1.permissions.get_db_session"):
            with patch("app.api.v1.permissions.PermissionService") as MockPermissionService:
                mock_service = MockPermissionService.return_value
                mock_service.get_all_permissions = AsyncMock(
                    return_value=[
                        {
                            "id": "perm-2",
                            "resource": "posts",
                            "action": "write",
                            "description": "Write posts",
                            "is_system": False,
                            "conditions": {"owner_only": True},
                        }
                    ]
                )

                response = client.get(
                    "/api/v1/permissions?resource=posts&action=write&is_system=false",
                    headers=admin_headers,
                )

                assert response.status_code == status.HTTP_200_OK
                data = response.json()
                assert len(data) == 1
                assert data[0]["resource"] == "posts"
                assert data[0]["action"] == "write"
                assert data[0]["is_system"] is False

    def test_get_permissions_by_resource(
        self, client: TestClient, admin_headers: Dict[str, str]
    ) -> None:
        """Test permission retrieval by resource."""
        resource = "posts"

        with patch("app.api.v1.permissions.get_db_session"):
            with patch("app.api.v1.permissions.PermissionService") as MockPermissionService:
                mock_service = MockPermissionService.return_value
                mock_service.get_permissions_by_resource = AsyncMock(
                    return_value={
                        "resource": "posts",
                        "permissions": [
                            {
                                "id": "perm-1",
                                "action": "read",
                                "description": "Read posts",
                                "conditions": {},
                            },
                            {
                                "id": "perm-2",
                                "action": "write",
                                "description": "Write posts",
                                "conditions": {"owner_only": True},
                            },
                            {
                                "id": "perm-3",
                                "action": "delete",
                                "description": "Delete posts",
                                "conditions": {"owner_only": True, "time_limit": "24h"},
                            },
                        ],
                        "total_permissions": 3,
                        "available_actions": ["read", "write", "delete", "publish"],
                    }
                )

                response = client.get(
                    f"/api/v1/permissions/resource/{resource}", headers=admin_headers
                )

                assert response.status_code == status.HTTP_200_OK
                data = response.json()
                assert data["resource"] == "posts"
                assert len(data["permissions"]) == 3
                assert len(data["available_actions"]) == 4

    def test_get_all_permissions_unauthorized(self, client: TestClient) -> None:
        """Test permission retrieval without admin privileges."""
        response = client.get("/api/v1/permissions")
        assert response.status_code == status.HTTP_401_UNAUTHORIZED

    def test_get_permission_by_id_success(
        self, client: TestClient, admin_headers: Dict[str, str]
    ) -> None:
        """Test successful permission retrieval by ID."""
        permission_id = "perm-123"

        with patch("app.api.v1.permissions.get_db_session"):
            with patch("app.api.v1.permissions.PermissionService") as MockPermissionService:
                mock_service = MockPermissionService.return_value
                mock_service.get_permission_by_id = AsyncMock(
                    return_value={
                        "id": permission_id,
                        "resource": "posts",
                        "action": "write",
                        "description": "Write posts permission",
                        "is_system": False,
                        "created_at": "2024-01-01T00:00:00Z",
                        "updated_at": "2024-01-01T00:00:00Z",
                        "conditions": {
                            "owner_only": True,
                            "time_restricted": False,
                        },
                        "roles": [
                            {
                                "id": "role-1",
                                "name": "editor",
                                "description": "Content editor",
                            },
                            {
                                "id": "role-2",
                                "name": "author",
                                "description": "Content author",
                            },
                        ],
                        "role_count": 2,
                        "user_count": 25,
                        "usage_stats": {
                            "last_used": "2024-01-05T10:30:00Z",
                            "usage_frequency": "high",
                            "common_contexts": ["dashboard", "editor"],
                        },
                    }
                )

                response = client.get(
                    f"/api/v1/permissions/{permission_id}", headers=admin_headers
                )

                assert response.status_code == status.HTTP_200_OK
                data = response.json()
                assert data["id"] == permission_id
                assert data["resource"] == "posts"
                assert data["action"] == "write"
                assert len(data["roles"]) == 2
                assert data["conditions"]["owner_only"] is True
                assert "usage_stats" in data

    def test_get_permission_by_id_not_found(
        self, client: TestClient, admin_headers: Dict[str, str]
    ) -> None:
        """Test permission retrieval for non-existent permission."""
        permission_id = "non-existent-perm"

        with patch("app.api.v1.permissions.get_db_session"):
            with patch("app.api.v1.permissions.PermissionService") as MockPermissionService:
                mock_service = MockPermissionService.return_value
                mock_service.get_permission_by_id = AsyncMock(
                    side_effect=ValueError("Permission not found")
                )

                response = client.get(
                    f"/api/v1/permissions/{permission_id}", headers=admin_headers
                )

                assert response.status_code == status.HTTP_404_NOT_FOUND
                assert "Permission not found" in response.json()["detail"]

    def test_create_permission_success(
        self, client: TestClient, admin_headers: Dict[str, str], permission_data: Dict[str, Any]
    ) -> None:
        """Test successful permission creation."""
        with patch("app.api.v1.permissions.get_db_session"):
            with patch("app.api.v1.permissions.PermissionService") as MockPermissionService:
                mock_service = MockPermissionService.return_value
                mock_service.create_permission = AsyncMock(
                    return_value={
                        "id": "new-perm-id",
                        "resource": permission_data["resource"],
                        "action": permission_data["action"],
                        "description": permission_data["description"],
                        "is_system": False,
                        "created_at": datetime.utcnow().isoformat(),
                        "conditions": permission_data["conditions"],
                    }
                )

                response = client.post(
                    "/api/v1/permissions", json=permission_data, headers=admin_headers
                )

                assert response.status_code == status.HTTP_201_CREATED
                data = response.json()
                assert data["resource"] == permission_data["resource"]
                assert data["action"] == permission_data["action"]
                assert data["conditions"]["owner_only"] is True

    def test_create_permission_duplicate(
        self, client: TestClient, admin_headers: Dict[str, str], permission_data: Dict[str, Any]
    ) -> None:
        """Test permission creation with duplicate resource-action combination."""
        with patch("app.api.v1.permissions.get_db_session"):
            with patch("app.api.v1.permissions.PermissionService") as MockPermissionService:
                mock_service = MockPermissionService.return_value
                mock_service.create_permission = AsyncMock(
                    side_effect=ValueError("Permission already exists for this resource-action combination")
                )

                response = client.post(
                    "/api/v1/permissions", json=permission_data, headers=admin_headers
                )

                assert response.status_code == status.HTTP_400_BAD_REQUEST
                assert "Permission already exists" in response.json()["detail"]

    def test_create_permission_invalid_resource(
        self, client: TestClient, admin_headers: Dict[str, str]
    ) -> None:
        """Test permission creation with invalid resource."""
        invalid_permission_data = {
            "resource": "invalid_resource!",  # Invalid characters
            "action": "read",
            "description": "Invalid permission",
        }

        with patch("app.api.v1.permissions.get_db_session"):
            with patch("app.api.v1.permissions.PermissionService") as MockPermissionService:
                mock_service = MockPermissionService.return_value
                mock_service.create_permission = AsyncMock(
                    side_effect=ValueError("Invalid resource name format")
                )

                response = client.post(
                    "/api/v1/permissions", json=invalid_permission_data, headers=admin_headers
                )

                assert response.status_code == status.HTTP_400_BAD_REQUEST
                assert "Invalid resource name" in response.json()["detail"]

    def test_create_permission_invalid_action(
        self, client: TestClient, admin_headers: Dict[str, str]
    ) -> None:
        """Test permission creation with invalid action."""
        invalid_permission_data = {
            "resource": "posts",
            "action": "invalid_action!",  # Invalid characters
            "description": "Invalid permission",
        }

        with patch("app.api.v1.permissions.get_db_session"):
            with patch("app.api.v1.permissions.PermissionService") as MockPermissionService:
                mock_service = MockPermissionService.return_value
                mock_service.create_permission = AsyncMock(
                    side_effect=ValueError("Invalid action name format")
                )

                response = client.post(
                    "/api/v1/permissions", json=invalid_permission_data, headers=admin_headers
                )

                assert response.status_code == status.HTTP_400_BAD_REQUEST
                assert "Invalid action name" in response.json()["detail"]

    def test_update_permission_success(
        self, client: TestClient, admin_headers: Dict[str, str]
    ) -> None:
        """Test successful permission update."""
        permission_id = "perm-123"
        update_data = {
            "description": "Updated write posts permission",
            "conditions": {
                "owner_only": False,
                "time_restricted": True,
                "business_hours_only": True,
            },
        }

        with patch("app.api.v1.permissions.get_db_session"):
            with patch("app.api.v1.permissions.PermissionService") as MockPermissionService:
                mock_service = MockPermissionService.return_value
                mock_service.update_permission = AsyncMock(
                    return_value={
                        "id": permission_id,
                        "resource": "posts",
                        "action": "write",
                        "description": "Updated write posts permission",
                        "is_system": False,
                        "updated_at": datetime.utcnow().isoformat(),
                        "conditions": update_data["conditions"],
                    }
                )

                response = client.patch(
                    f"/api/v1/permissions/{permission_id}",
                    json=update_data,
                    headers=admin_headers,
                )

                assert response.status_code == status.HTTP_200_OK
                data = response.json()
                assert data["description"] == "Updated write posts permission"
                assert data["conditions"]["owner_only"] is False
                assert data["conditions"]["time_restricted"] is True

    def test_update_system_permission_forbidden(
        self, client: TestClient, admin_headers: Dict[str, str]
    ) -> None:
        """Test updating system permission should be restricted."""
        permission_id = "system-perm-123"
        update_data = {"description": "Modified system permission"}

        with patch("app.api.v1.permissions.get_db_session"):
            with patch("app.api.v1.permissions.PermissionService") as MockPermissionService:
                mock_service = MockPermissionService.return_value
                mock_service.update_permission = AsyncMock(
                    side_effect=ValueError("Cannot modify system permission")
                )

                response = client.patch(
                    f"/api/v1/permissions/{permission_id}",
                    json=update_data,
                    headers=admin_headers,
                )

                assert response.status_code == status.HTTP_400_BAD_REQUEST
                assert "Cannot modify system permission" in response.json()["detail"]

    def test_delete_permission_success(
        self, client: TestClient, admin_headers: Dict[str, str]
    ) -> None:
        """Test successful permission deletion."""
        permission_id = "perm-123"

        with patch("app.api.v1.permissions.get_db_session"):
            with patch("app.api.v1.permissions.PermissionService") as MockPermissionService:
                mock_service = MockPermissionService.return_value
                mock_service.delete_permission = AsyncMock(
                    return_value={
                        "message": "Permission deleted successfully",
                        "affected_roles": ["editor", "author"],
                        "affected_users": 25,
                        "cleanup_actions": [
                            "Removed from 2 roles",
                            "Updated 25 user permissions",
                            "Cleared permission cache",
                        ],
                    }
                )

                response = client.delete(
                    f"/api/v1/permissions/{permission_id}", headers=admin_headers
                )

                assert response.status_code == status.HTTP_200_OK
                data = response.json()
                assert "Permission deleted successfully" in data["message"]
                assert len(data["affected_roles"]) == 2
                assert data["affected_users"] == 25

    def test_delete_system_permission_forbidden(
        self, client: TestClient, admin_headers: Dict[str, str]
    ) -> None:
        """Test deleting system permission should be forbidden."""
        permission_id = "system-perm-123"

        with patch("app.api.v1.permissions.get_db_session"):
            with patch("app.api.v1.permissions.PermissionService") as MockPermissionService:
                mock_service = MockPermissionService.return_value
                mock_service.delete_permission = AsyncMock(
                    side_effect=ValueError("Cannot delete system permission")
                )

                response = client.delete(
                    f"/api/v1/permissions/{permission_id}", headers=admin_headers
                )

                assert response.status_code == status.HTTP_400_BAD_REQUEST
                assert "Cannot delete system permission" in response.json()["detail"]

    def test_delete_permission_in_use(
        self, client: TestClient, admin_headers: Dict[str, str]
    ) -> None:
        """Test permission deletion when it's actively used."""
        permission_id = "perm-123"

        with patch("app.api.v1.permissions.get_db_session"):
            with patch("app.api.v1.permissions.PermissionService") as MockPermissionService:
                mock_service = MockPermissionService.return_value
                mock_service.delete_permission = AsyncMock(
                    return_value={
                        "message": "Permission deleted successfully",
                        "affected_roles": ["editor", "author", "manager"],
                        "affected_users": 150,
                        "cleanup_actions": [
                            "Removed from 3 roles",
                            "Updated 150 user permissions",
                            "Cleared permission cache",
                            "Notified affected users",
                        ],
                        "warning": "Permission was heavily used - consider gradual removal",
                    }
                )

                response = client.delete(
                    f"/api/v1/permissions/{permission_id}", headers=admin_headers
                )

                assert response.status_code == status.HTTP_200_OK
                data = response.json()
                assert data["affected_users"] == 150
                assert "warning" in data


class TestPermissionValidation:
    """Test permission validation and business rules."""

    def test_get_available_resources(
        self, client: TestClient, admin_headers: Dict[str, str]
    ) -> None:
        """Test retrieval of available resources."""
        with patch("app.api.v1.permissions.get_db_session"):
            with patch("app.api.v1.permissions.PermissionService") as MockPermissionService:
                mock_service = MockPermissionService.return_value
                mock_service.get_available_resources = AsyncMock(
                    return_value={
                        "resources": [
                            {
                                "name": "posts",
                                "description": "Blog posts and articles",
                                "available_actions": ["read", "write", "delete", "publish"],
                                "permission_count": 4,
                                "is_system": False,
                            },
                            {
                                "name": "users",
                                "description": "User management",
                                "available_actions": ["read", "write", "delete", "manage"],
                                "permission_count": 8,
                                "is_system": False,
                            },
                            {
                                "name": "system",
                                "description": "System administration",
                                "available_actions": ["*"],
                                "permission_count": 1,
                                "is_system": True,
                            },
                        ],
                        "total_resources": 3,
                        "custom_resources": 2,
                        "system_resources": 1,
                    }
                )

                response = client.get("/api/v1/permissions/resources", headers=admin_headers)

                assert response.status_code == status.HTTP_200_OK
                data = response.json()
                assert len(data["resources"]) == 3
                assert data["total_resources"] == 3
                assert data["custom_resources"] == 2

    def test_get_available_actions_for_resource(
        self, client: TestClient, admin_headers: Dict[str, str]
    ) -> None:
        """Test retrieval of available actions for a specific resource."""
        resource = "posts"

        with patch("app.api.v1.permissions.get_db_session"):
            with patch("app.api.v1.permissions.PermissionService") as MockPermissionService:
                mock_service = MockPermissionService.return_value
                mock_service.get_available_actions = AsyncMock(
                    return_value={
                        "resource": "posts",
                        "standard_actions": ["read", "write", "delete"],
                        "custom_actions": ["publish", "featured", "archive"],
                        "all_actions": ["read", "write", "delete", "publish", "featured", "archive"],
                        "action_descriptions": {
                            "read": "View posts",
                            "write": "Create and edit posts",
                            "delete": "Delete posts",
                            "publish": "Publish posts",
                            "featured": "Mark posts as featured",
                            "archive": "Archive posts",
                        },
                        "existing_permissions": ["read", "write", "delete"],
                        "available_for_creation": ["publish", "featured", "archive"],
                    }
                )

                response = client.get(
                    f"/api/v1/permissions/resources/{resource}/actions",
                    headers=admin_headers,
                )

                assert response.status_code == status.HTTP_200_OK
                data = response.json()
                assert data["resource"] == "posts"
                assert len(data["standard_actions"]) == 3
                assert len(data["custom_actions"]) == 3
                assert len(data["available_for_creation"]) == 3

    def test_validate_permission_format(
        self, client: TestClient, admin_headers: Dict[str, str]
    ) -> None:
        """Test permission format validation."""
        validation_data = {
            "permissions": [
                "posts:read",
                "posts:write",
                "users:manage",
                "invalid:action!",  # Invalid format
                "system:*",
            ]
        }

        with patch("app.api.v1.permissions.get_db_session"):
            with patch("app.api.v1.permissions.PermissionService") as MockPermissionService:
                mock_service = MockPermissionService.return_value
                mock_service.validate_permissions = AsyncMock(
                    return_value={
                        "valid_permissions": [
                            {"permission": "posts:read", "status": "valid"},
                            {"permission": "posts:write", "status": "valid"},
                            {"permission": "users:manage", "status": "valid"},
                            {"permission": "system:*", "status": "valid"},
                        ],
                        "invalid_permissions": [
                            {
                                "permission": "invalid:action!",
                                "status": "invalid",
                                "error": "Action contains invalid characters",
                            }
                        ],
                        "total_valid": 4,
                        "total_invalid": 1,
                    }
                )

                response = client.post(
                    "/api/v1/permissions/validate",
                    json=validation_data,
                    headers=admin_headers,
                )

                assert response.status_code == status.HTTP_200_OK
                data = response.json()
                assert data["total_valid"] == 4
                assert data["total_invalid"] == 1
                assert len(data["invalid_permissions"]) == 1


class TestPermissionConditions:
    """Test permission condition management."""

    def test_create_permission_with_complex_conditions(
        self, client: TestClient, admin_headers: Dict[str, str]
    ) -> None:
        """Test creating permission with complex conditions."""
        complex_permission_data = {
            "resource": "documents",
            "action": "edit",
            "description": "Edit documents with conditions",
            "conditions": {
                "owner_only": True,
                "time_restricted": True,
                "allowed_hours": {"start": "09:00", "end": "17:00"},
                "ip_whitelist": ["192.168.1.0/24", "10.0.0.0/8"],
                "user_attributes": {
                    "department": ["engineering", "product"],
                    "seniority": ["senior", "lead"],
                },
                "resource_attributes": {
                    "status": ["draft", "review"],
                    "confidentiality": ["public", "internal"],
                },
            },
        }

        with patch("app.api.v1.permissions.get_db_session"):
            with patch("app.api.v1.permissions.PermissionService") as MockPermissionService:
                mock_service = MockPermissionService.return_value
                mock_service.create_permission = AsyncMock(
                    return_value={
                        "id": "complex-perm-id",
                        **complex_permission_data,
                        "created_at": datetime.utcnow().isoformat(),
                        "validation_rules": {
                            "condition_count": 6,
                            "complexity_score": 8.5,
                            "estimated_performance_impact": "medium",
                        },
                    }
                )

                response = client.post(
                    "/api/v1/permissions",
                    json=complex_permission_data,
                    headers=admin_headers,
                )

                assert response.status_code == status.HTTP_201_CREATED
                data = response.json()
                assert data["conditions"]["owner_only"] is True
                assert len(data["conditions"]["ip_whitelist"]) == 2
                assert data["validation_rules"]["complexity_score"] == 8.5

    def test_validate_permission_conditions(
        self, client: TestClient, admin_headers: Dict[str, str]
    ) -> None:
        """Test validation of permission conditions."""
        condition_data = {
            "conditions": {
                "time_restricted": True,
                "allowed_hours": {"start": "25:00", "end": "17:00"},  # Invalid time
                "ip_whitelist": ["invalid_ip", "192.168.1.0/24"],
                "user_attributes": {
                    "department": [],  # Empty array
                    "seniority": ["invalid_level"],
                },
            }
        }

        with patch("app.api.v1.permissions.get_db_session"):
            with patch("app.api.v1.permissions.PermissionService") as MockPermissionService:
                mock_service = MockPermissionService.return_value
                mock_service.validate_conditions = AsyncMock(
                    return_value={
                        "valid": False,
                        "errors": [
                            {"field": "allowed_hours.start", "error": "Invalid time format"},
                            {"field": "ip_whitelist[0]", "error": "Invalid IP address format"},
                            {"field": "user_attributes.department", "error": "Cannot be empty array"},
                            {"field": "user_attributes.seniority[0]", "error": "Invalid seniority level"},
                        ],
                        "warnings": [
                            {"field": "time_restricted", "warning": "May impact performance"},
                        ],
                        "suggestions": [
                            "Use standard time format HH:MM",
                            "Verify IP address formats",
                            "Consider using wildcards for flexible matching",
                        ],
                    }
                )

                response = client.post(
                    "/api/v1/permissions/validate-conditions",
                    json=condition_data,
                    headers=admin_headers,
                )

                assert response.status_code == status.HTTP_200_OK
                data = response.json()
                assert data["valid"] is False
                assert len(data["errors"]) == 4
                assert len(data["warnings"]) == 1
                assert len(data["suggestions"]) == 3


# Performance and edge case tests
@pytest.mark.performance
class TestPermissionPerformance:
    """Performance tests for permission endpoints."""

    def test_large_permission_list_performance(
        self, client: TestClient, admin_headers: Dict[str, str]
    ) -> None:
        """Test performance with large number of permissions."""
        with patch("app.api.v1.permissions.get_db_session"):
            with patch("app.api.v1.permissions.PermissionService") as MockPermissionService:
                # Simulate large dataset
                mock_permissions = [
                    {
                        "id": f"perm-{i}",
                        "resource": f"resource_{i // 10}",
                        "action": f"action_{i % 5}",
                        "description": f"Permission {i}",
                        "is_system": i % 20 == 0,
                        "conditions": {} if i % 3 == 0 else {"owner_only": True},
                        "role_count": i % 10,
                        "user_count": i * 5,
                    }
                    for i in range(500)
                ]

                mock_service = MockPermissionService.return_value
                mock_service.get_all_permissions = AsyncMock(return_value=mock_permissions)

                response = client.get("/api/v1/permissions", headers=admin_headers)

                assert response.status_code == status.HTTP_200_OK
                data = response.json()
                assert len(data) == 500

    def test_complex_permission_creation_performance(
        self, client: TestClient, admin_headers: Dict[str, str]
    ) -> None:
        """Test performance of creating permission with complex conditions."""
        complex_conditions = {
            "resource": "complex_resource",
            "action": "complex_action",
            "description": "Complex permission with many conditions",
            "conditions": {
                f"condition_{i}": f"value_{i}" for i in range(50)
            },
        }

        with patch("app.api.v1.permissions.get_db_session"):
            with patch("app.api.v1.permissions.PermissionService") as MockPermissionService:
                mock_service = MockPermissionService.return_value
                mock_service.create_permission = AsyncMock(
                    return_value={
                        **complex_conditions,
                        "id": "complex-perm-id",
                        "created_at": datetime.utcnow().isoformat(),
                        "performance_metrics": {
                            "creation_time": "2.1s",
                            "condition_validation_time": "0.8s",
                            "database_write_time": "1.3s",
                        },
                    }
                )

                response = client.post(
                    "/api/v1/permissions",
                    json=complex_conditions,
                    headers=admin_headers,
                )

                assert response.status_code == status.HTTP_201_CREATED
                data = response.json()
                assert len(data["conditions"]) == 50
                assert "performance_metrics" in data