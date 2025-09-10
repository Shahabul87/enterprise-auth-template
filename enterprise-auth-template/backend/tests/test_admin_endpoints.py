"""
Admin Endpoint Tests

Comprehensive tests for admin endpoints including user management,
role assignments, permission management, and system administration features.
"""

import pytest
from datetime import datetime, timedelta
from unittest.mock import AsyncMock, MagicMock, patch
from typing import Dict, List, Any

from fastapi import status
from fastapi.testclient import TestClient
from sqlalchemy.ext.asyncio import AsyncSession

from app.main import app
from app.models.user import User, Role, Permission
from app.core.security import get_password_hash


@pytest.fixture
def admin_user_data() -> Dict[str, Any]:
    """Admin user data for testing."""
    return {
        "email": "admin@example.com",
        "password": "AdminPassword123!",
        "first_name": "Admin",
        "last_name": "User",
        "is_superuser": True,
        "is_active": True,
        "is_verified": True,
    }


@pytest.fixture
def regular_user_data() -> Dict[str, Any]:
    """Regular user data for testing."""
    return {
        "email": "user@example.com",
        "password": "UserPassword123!",
        "first_name": "Regular",
        "last_name": "User",
        "is_superuser": False,
        "is_active": True,
        "is_verified": True,
    }


@pytest.fixture
def mock_admin_user() -> User:
    """Create mock admin user."""
    user = MagicMock(spec=User)
    user.id = "admin-user-id"
    user.email = "admin@example.com"
    user.first_name = "Admin"
    user.last_name = "User"
    user.is_superuser = True
    user.is_active = True
    user.is_verified = True
    user.created_at = datetime.utcnow()
    user.updated_at = datetime.utcnow()
    user.roles = [{"name": "admin", "permissions": ["admin:manage"]}]
    return user


@pytest.fixture
def admin_headers() -> Dict[str, str]:
    """Admin authorization headers."""
    return {"Authorization": "Bearer admin-access-token"}


class TestAdminUserManagement:
    """Test admin user management endpoints."""

    def test_get_all_users_success(
        self, client: TestClient, admin_headers: Dict[str, str]
    ) -> None:
        """Test successful retrieval of all users."""
        with patch("app.api.v1.admin.get_db_session"):
            with patch("app.api.v1.admin.AdminService") as MockAdminService:
                mock_service = MockAdminService.return_value
                mock_service.get_all_users = AsyncMock(
                    return_value={
                        "users": [
                            {
                                "id": "user1-id",
                                "email": "user1@example.com",
                                "first_name": "User",
                                "last_name": "One",
                                "is_active": True,
                                "is_verified": True,
                                "created_at": "2024-01-01T00:00:00Z",
                                "last_login": "2024-01-02T00:00:00Z",
                                "roles": ["user"],
                            },
                            {
                                "id": "user2-id",
                                "email": "user2@example.com",
                                "first_name": "User",
                                "last_name": "Two",
                                "is_active": False,
                                "is_verified": True,
                                "created_at": "2024-01-01T00:00:00Z",
                                "last_login": None,
                                "roles": ["editor"],
                            },
                        ],
                        "total": 2,
                        "page": 1,
                        "per_page": 10,
                        "pages": 1,
                    }
                )

                response = client.get(
                    "/api/v1/admin/users", headers=admin_headers
                )

                assert response.status_code == status.HTTP_200_OK
                data = response.json()
                assert "users" in data
                assert data["total"] == 2
                assert len(data["users"]) == 2
                assert data["users"][0]["email"] == "user1@example.com"

    def test_get_all_users_with_pagination(
        self, client: TestClient, admin_headers: Dict[str, str]
    ) -> None:
        """Test user retrieval with pagination."""
        with patch("app.api.v1.admin.get_db_session"):
            with patch("app.api.v1.admin.AdminService") as MockAdminService:
                mock_service = MockAdminService.return_value
                mock_service.get_all_users = AsyncMock(
                    return_value={
                        "users": [],
                        "total": 50,
                        "page": 2,
                        "per_page": 20,
                        "pages": 3,
                    }
                )

                response = client.get(
                    "/api/v1/admin/users?page=2&per_page=20",
                    headers=admin_headers,
                )

                assert response.status_code == status.HTTP_200_OK
                data = response.json()
                assert data["page"] == 2
                assert data["per_page"] == 20
                assert data["total"] == 50

    def test_get_all_users_with_filters(
        self, client: TestClient, admin_headers: Dict[str, str]
    ) -> None:
        """Test user retrieval with filters."""
        with patch("app.api.v1.admin.get_db_session"):
            with patch("app.api.v1.admin.AdminService") as MockAdminService:
                mock_service = MockAdminService.return_value
                mock_service.get_all_users = AsyncMock(
                    return_value={
                        "users": [
                            {
                                "id": "user1-id",
                                "email": "active@example.com",
                                "is_active": True,
                                "is_verified": True,
                            }
                        ],
                        "total": 1,
                        "page": 1,
                        "per_page": 10,
                        "pages": 1,
                    }
                )

                response = client.get(
                    "/api/v1/admin/users?is_active=true&role=editor",
                    headers=admin_headers,
                )

                assert response.status_code == status.HTTP_200_OK
                data = response.json()
                assert len(data["users"]) == 1

    def test_get_all_users_unauthorized(self, client: TestClient) -> None:
        """Test user retrieval without admin privileges."""
        response = client.get("/api/v1/admin/users")
        assert response.status_code == status.HTTP_401_UNAUTHORIZED

    def test_get_user_by_id_success(
        self, client: TestClient, admin_headers: Dict[str, str]
    ) -> None:
        """Test successful user retrieval by ID."""
        user_id = "test-user-id"
        
        with patch("app.api.v1.admin.get_db_session"):
            with patch("app.api.v1.admin.AdminService") as MockAdminService:
                mock_service = MockAdminService.return_value
                mock_service.get_user_by_id = AsyncMock(
                    return_value={
                        "id": user_id,
                        "email": "user@example.com",
                        "first_name": "Test",
                        "last_name": "User",
                        "is_active": True,
                        "is_verified": True,
                        "created_at": "2024-01-01T00:00:00Z",
                        "last_login": "2024-01-02T00:00:00Z",
                        "roles": [
                            {
                                "name": "user",
                                "permissions": ["posts:read"],
                            }
                        ],
                        "login_history": [
                            {
                                "timestamp": "2024-01-02T00:00:00Z",
                                "ip_address": "192.168.1.1",
                                "user_agent": "Mozilla/5.0...",
                                "success": True,
                            }
                        ],
                    }
                )

                response = client.get(
                    f"/api/v1/admin/users/{user_id}", headers=admin_headers
                )

                assert response.status_code == status.HTTP_200_OK
                data = response.json()
                assert data["id"] == user_id
                assert data["email"] == "user@example.com"
                assert "login_history" in data

    def test_get_user_by_id_not_found(
        self, client: TestClient, admin_headers: Dict[str, str]
    ) -> None:
        """Test user retrieval for non-existent user."""
        user_id = "non-existent-id"
        
        with patch("app.api.v1.admin.get_db_session"):
            with patch("app.api.v1.admin.AdminService") as MockAdminService:
                mock_service = MockAdminService.return_value
                mock_service.get_user_by_id = AsyncMock(
                    side_effect=ValueError("User not found")
                )

                response = client.get(
                    f"/api/v1/admin/users/{user_id}", headers=admin_headers
                )

                assert response.status_code == status.HTTP_404_NOT_FOUND
                assert "User not found" in response.json()["detail"]

    def test_create_user_success(
        self, client: TestClient, admin_headers: Dict[str, str]
    ) -> None:
        """Test successful user creation by admin."""
        user_data = {
            "email": "newuser@example.com",
            "password": "SecurePassword123!",
            "first_name": "New",
            "last_name": "User",
            "roles": ["editor"],
        }

        with patch("app.api.v1.admin.get_db_session"):
            with patch("app.api.v1.admin.AdminService") as MockAdminService:
                mock_service = MockAdminService.return_value
                mock_service.create_user = AsyncMock(
                    return_value={
                        "id": "new-user-id",
                        "email": user_data["email"],
                        "first_name": user_data["first_name"],
                        "last_name": user_data["last_name"],
                        "is_active": True,
                        "is_verified": False,
                        "roles": ["editor"],
                        "created_at": datetime.utcnow().isoformat(),
                    }
                )

                response = client.post(
                    "/api/v1/admin/users", json=user_data, headers=admin_headers
                )

                assert response.status_code == status.HTTP_201_CREATED
                data = response.json()
                assert data["email"] == user_data["email"]
                assert "editor" in data["roles"]

    def test_create_user_duplicate_email(
        self, client: TestClient, admin_headers: Dict[str, str]
    ) -> None:
        """Test user creation with duplicate email."""
        user_data = {
            "email": "existing@example.com",
            "password": "SecurePassword123!",
            "first_name": "Test",
            "last_name": "User",
        }

        with patch("app.api.v1.admin.get_db_session"):
            with patch("app.api.v1.admin.AdminService") as MockAdminService:
                mock_service = MockAdminService.return_value
                mock_service.create_user = AsyncMock(
                    side_effect=ValueError("Email already exists")
                )

                response = client.post(
                    "/api/v1/admin/users", json=user_data, headers=admin_headers
                )

                assert response.status_code == status.HTTP_400_BAD_REQUEST
                assert "Email already exists" in response.json()["detail"]

    def test_update_user_success(
        self, client: TestClient, admin_headers: Dict[str, str]
    ) -> None:
        """Test successful user update by admin."""
        user_id = "test-user-id"
        update_data = {
            "first_name": "Updated",
            "last_name": "Name",
            "is_active": False,
        }

        with patch("app.api.v1.admin.get_db_session"):
            with patch("app.api.v1.admin.AdminService") as MockAdminService:
                mock_service = MockAdminService.return_value
                mock_service.update_user = AsyncMock(
                    return_value={
                        "id": user_id,
                        "email": "user@example.com",
                        "first_name": "Updated",
                        "last_name": "Name",
                        "is_active": False,
                        "updated_at": datetime.utcnow().isoformat(),
                    }
                )

                response = client.patch(
                    f"/api/v1/admin/users/{user_id}",
                    json=update_data,
                    headers=admin_headers,
                )

                assert response.status_code == status.HTTP_200_OK
                data = response.json()
                assert data["first_name"] == "Updated"
                assert data["is_active"] is False

    def test_delete_user_success(
        self, client: TestClient, admin_headers: Dict[str, str]
    ) -> None:
        """Test successful user deletion by admin."""
        user_id = "test-user-id"

        with patch("app.api.v1.admin.get_db_session"):
            with patch("app.api.v1.admin.AdminService") as MockAdminService:
                mock_service = MockAdminService.return_value
                mock_service.delete_user = AsyncMock(return_value=True)

                response = client.delete(
                    f"/api/v1/admin/users/{user_id}", headers=admin_headers
                )

                assert response.status_code == status.HTTP_200_OK
                assert "User deleted successfully" in response.json()["message"]


class TestAdminRoleManagement:
    """Test admin role management endpoints."""

    def test_assign_role_to_user_success(
        self, client: TestClient, admin_headers: Dict[str, str]
    ) -> None:
        """Test successful role assignment."""
        user_id = "test-user-id"
        role_data = {"role_name": "editor"}

        with patch("app.api.v1.admin.get_db_session"):
            with patch("app.api.v1.admin.AdminService") as MockAdminService:
                mock_service = MockAdminService.return_value
                mock_service.assign_role_to_user = AsyncMock(
                    return_value={
                        "user_id": user_id,
                        "roles": ["user", "editor"],
                        "message": "Role assigned successfully",
                    }
                )

                response = client.post(
                    f"/api/v1/admin/users/{user_id}/roles",
                    json=role_data,
                    headers=admin_headers,
                )

                assert response.status_code == status.HTTP_200_OK
                data = response.json()
                assert "editor" in data["roles"]
                assert "Role assigned successfully" in data["message"]

    def test_revoke_role_from_user_success(
        self, client: TestClient, admin_headers: Dict[str, str]
    ) -> None:
        """Test successful role revocation."""
        user_id = "test-user-id"
        role_name = "editor"

        with patch("app.api.v1.admin.get_db_session"):
            with patch("app.api.v1.admin.AdminService") as MockAdminService:
                mock_service = MockAdminService.return_value
                mock_service.revoke_role_from_user = AsyncMock(
                    return_value={
                        "user_id": user_id,
                        "roles": ["user"],
                        "message": "Role revoked successfully",
                    }
                )

                response = client.delete(
                    f"/api/v1/admin/users/{user_id}/roles/{role_name}",
                    headers=admin_headers,
                )

                assert response.status_code == status.HTTP_200_OK
                data = response.json()
                assert "editor" not in data["roles"]
                assert "Role revoked successfully" in data["message"]


class TestAdminSystemEndpoints:
    """Test admin system management endpoints."""

    def test_get_system_stats_success(
        self, client: TestClient, admin_headers: Dict[str, str]
    ) -> None:
        """Test successful system statistics retrieval."""
        with patch("app.api.v1.admin.get_db_session"):
            with patch("app.api.v1.admin.AdminService") as MockAdminService:
                mock_service = MockAdminService.return_value
                mock_service.get_system_stats = AsyncMock(
                    return_value={
                        "total_users": 1250,
                        "active_users": 1180,
                        "verified_users": 1100,
                        "total_sessions": 350,
                        "failed_login_attempts_24h": 25,
                        "database_size": "125MB",
                        "cache_hit_rate": 0.85,
                        "uptime": "5d 12h 30m",
                        "system_load": {
                            "cpu": 0.65,
                            "memory": 0.75,
                            "disk": 0.45,
                        },
                    }
                )

                response = client.get(
                    "/api/v1/admin/system/stats", headers=admin_headers
                )

                assert response.status_code == status.HTTP_200_OK
                data = response.json()
                assert data["total_users"] == 1250
                assert data["cache_hit_rate"] == 0.85
                assert "system_load" in data

    def test_get_audit_logs_success(
        self, client: TestClient, admin_headers: Dict[str, str]
    ) -> None:
        """Test successful audit logs retrieval."""
        with patch("app.api.v1.admin.get_db_session"):
            with patch("app.api.v1.admin.AdminService") as MockAdminService:
                mock_service = MockAdminService.return_value
                mock_service.get_audit_logs = AsyncMock(
                    return_value={
                        "logs": [
                            {
                                "id": "log1",
                                "timestamp": "2024-01-01T12:00:00Z",
                                "user_id": "user123",
                                "action": "user_login",
                                "resource": "auth",
                                "ip_address": "192.168.1.1",
                                "user_agent": "Mozilla/5.0...",
                                "success": True,
                            },
                            {
                                "id": "log2",
                                "timestamp": "2024-01-01T11:00:00Z",
                                "user_id": "admin456",
                                "action": "user_created",
                                "resource": "admin",
                                "ip_address": "192.168.1.2",
                                "user_agent": "Mozilla/5.0...",
                                "success": True,
                            },
                        ],
                        "total": 2,
                        "page": 1,
                        "per_page": 50,
                        "pages": 1,
                    }
                )

                response = client.get(
                    "/api/v1/admin/system/audit-logs", headers=admin_headers
                )

                assert response.status_code == status.HTTP_200_OK
                data = response.json()
                assert len(data["logs"]) == 2
                assert data["logs"][0]["action"] == "user_login"

    def test_get_audit_logs_with_filters(
        self, client: TestClient, admin_headers: Dict[str, str]
    ) -> None:
        """Test audit logs retrieval with filters."""
        with patch("app.api.v1.admin.get_db_session"):
            with patch("app.api.v1.admin.AdminService") as MockAdminService:
                mock_service = MockAdminService.return_value
                mock_service.get_audit_logs = AsyncMock(
                    return_value={
                        "logs": [
                            {
                                "id": "log1",
                                "action": "user_login",
                                "user_id": "specific-user",
                                "success": False,
                            }
                        ],
                        "total": 1,
                        "page": 1,
                        "per_page": 50,
                        "pages": 1,
                    }
                )

                response = client.get(
                    "/api/v1/admin/system/audit-logs?user_id=specific-user&action=user_login&success=false",
                    headers=admin_headers,
                )

                assert response.status_code == status.HTTP_200_OK
                data = response.json()
                assert len(data["logs"]) == 1
                assert data["logs"][0]["user_id"] == "specific-user"

    def test_clear_cache_success(
        self, client: TestClient, admin_headers: Dict[str, str]
    ) -> None:
        """Test successful cache clearing."""
        with patch("app.api.v1.admin.get_db_session"):
            with patch("app.api.v1.admin.AdminService") as MockAdminService:
                mock_service = MockAdminService.return_value
                mock_service.clear_cache = AsyncMock(
                    return_value={
                        "message": "Cache cleared successfully",
                        "keys_cleared": 1250,
                        "memory_freed": "45MB",
                    }
                )

                response = client.post(
                    "/api/v1/admin/system/clear-cache", headers=admin_headers
                )

                assert response.status_code == status.HTTP_200_OK
                data = response.json()
                assert "Cache cleared successfully" in data["message"]
                assert data["keys_cleared"] == 1250

    def test_backup_database_success(
        self, client: TestClient, admin_headers: Dict[str, str]
    ) -> None:
        """Test successful database backup."""
        with patch("app.api.v1.admin.get_db_session"):
            with patch("app.api.v1.admin.AdminService") as MockAdminService:
                mock_service = MockAdminService.return_value
                mock_service.create_backup = AsyncMock(
                    return_value={
                        "message": "Backup created successfully",
                        "backup_id": "backup_20240101_120000",
                        "filename": "backup_20240101_120000.sql",
                        "size": "125MB",
                        "created_at": "2024-01-01T12:00:00Z",
                    }
                )

                response = client.post(
                    "/api/v1/admin/system/backup", headers=admin_headers
                )

                assert response.status_code == status.HTTP_201_CREATED
                data = response.json()
                assert "Backup created successfully" in data["message"]
                assert data["size"] == "125MB"


class TestAdminBulkOperations:
    """Test admin bulk operations."""

    def test_bulk_user_update_success(
        self, client: TestClient, admin_headers: Dict[str, str]
    ) -> None:
        """Test successful bulk user update."""
        bulk_data = {
            "user_ids": ["user1", "user2", "user3"],
            "updates": {"is_verified": True, "is_active": True},
        }

        with patch("app.api.v1.admin.get_db_session"):
            with patch("app.api.v1.admin.AdminService") as MockAdminService:
                mock_service = MockAdminService.return_value
                mock_service.bulk_update_users = AsyncMock(
                    return_value={
                        "message": "Bulk update completed",
                        "updated_count": 3,
                        "failed_count": 0,
                        "results": [
                            {"user_id": "user1", "success": True},
                            {"user_id": "user2", "success": True},
                            {"user_id": "user3", "success": True},
                        ],
                    }
                )

                response = client.patch(
                    "/api/v1/admin/users/bulk",
                    json=bulk_data,
                    headers=admin_headers,
                )

                assert response.status_code == status.HTTP_200_OK
                data = response.json()
                assert data["updated_count"] == 3
                assert data["failed_count"] == 0

    def test_bulk_user_delete_success(
        self, client: TestClient, admin_headers: Dict[str, str]
    ) -> None:
        """Test successful bulk user deletion."""
        delete_data = {"user_ids": ["user1", "user2"]}

        with patch("app.api.v1.admin.get_db_session"):
            with patch("app.api.v1.admin.AdminService") as MockAdminService:
                mock_service = MockAdminService.return_value
                mock_service.bulk_delete_users = AsyncMock(
                    return_value={
                        "message": "Bulk deletion completed",
                        "deleted_count": 2,
                        "failed_count": 0,
                        "results": [
                            {"user_id": "user1", "success": True},
                            {"user_id": "user2", "success": True},
                        ],
                    }
                )

                response = client.delete(
                    "/api/v1/admin/users/bulk",
                    json=delete_data,
                    headers=admin_headers,
                )

                assert response.status_code == status.HTTP_200_OK
                data = response.json()
                assert data["deleted_count"] == 2
                assert data["failed_count"] == 0


# Performance and stress tests
@pytest.mark.performance
class TestAdminPerformance:
    """Performance tests for admin endpoints."""

    def test_large_user_list_performance(
        self, client: TestClient, admin_headers: Dict[str, str]
    ) -> None:
        """Test performance with large user list."""
        with patch("app.api.v1.admin.get_db_session"):
            with patch("app.api.v1.admin.AdminService") as MockAdminService:
                # Simulate large dataset
                mock_users = [
                    {
                        "id": f"user-{i}",
                        "email": f"user{i}@example.com",
                        "first_name": f"User{i}",
                        "last_name": "Test",
                        "is_active": True,
                    }
                    for i in range(1000)
                ]

                mock_service = MockAdminService.return_value
                mock_service.get_all_users = AsyncMock(
                    return_value={
                        "users": mock_users[:100],  # Paginated result
                        "total": 1000,
                        "page": 1,
                        "per_page": 100,
                        "pages": 10,
                    }
                )

                response = client.get(
                    "/api/v1/admin/users?per_page=100", headers=admin_headers
                )

                assert response.status_code == status.HTTP_200_OK
                data = response.json()
                assert data["total"] == 1000
                assert len(data["users"]) == 100

    def test_bulk_operation_performance(
        self, client: TestClient, admin_headers: Dict[str, str]
    ) -> None:
        """Test performance of bulk operations."""
        bulk_data = {
            "user_ids": [f"user-{i}" for i in range(100)],
            "updates": {"is_verified": True},
        }

        with patch("app.api.v1.admin.get_db_session"):
            with patch("app.api.v1.admin.AdminService") as MockAdminService:
                mock_service = MockAdminService.return_value
                mock_service.bulk_update_users = AsyncMock(
                    return_value={
                        "updated_count": 100,
                        "failed_count": 0,
                        "execution_time": "2.5s",
                    }
                )

                response = client.patch(
                    "/api/v1/admin/users/bulk",
                    json=bulk_data,
                    headers=admin_headers,
                )

                assert response.status_code == status.HTTP_200_OK
                data = response.json()
                assert data["updated_count"] == 100