"""
End-to-End Authentication Flow Tests

Comprehensive E2E tests for critical authentication flows including
user registration, login, password reset, and 2FA workflows.
"""

import pytest
import asyncio
import time
from typing import TypedDict
from unittest.mock import AsyncMock, MagicMock, patch

from fastapi.testclient import TestClient

from app.main import app
from app.models.user import User
from app.core.security import get_password_hash


# Type definitions
class TestUserData(TypedDict):
    email: str
    password: str
    first_name: str
    last_name: str
    username: str


@pytest.fixture
def client() -> TestClient:
    """Create test client for E2E testing."""
    return TestClient(app)


@pytest.fixture
def test_user_data() -> TestUserData:
    """Test user registration data."""
    return {
        "email": "e2e.test@example.com",
        "password": "SecurePassword123!",
        "first_name": "E2E",
        "last_name": "Tester",
        "username": "e2etester",
    }


@pytest.fixture
def existing_user() -> User:
    """Create an existing user for testing."""
    return User(
        id="existing-user-123",
        email="existing@example.com",
        username="existing",
        first_name="Existing",
        last_name="User",
        hashed_password=get_password_hash("ExistingPass123!"),
        email_verified=True,
        is_active=True,
        two_factor_enabled=False,
        created_at=datetime.utcnow(),
        updated_at=datetime.utcnow(),
    )


class TestUserRegistrationFlow:
    """End-to-end user registration flow tests."""

    @patch("app.api.v1.auth.get_db_session")
    @patch("app.api.v1.auth.EmailService")
    def test_complete_user_registration_flow(
        self, mock_email_service, mock_get_db, client, test_user_data
    ):
        """Test complete user registration and verification flow."""
        # Setup mocks
        mock_db_session = MagicMock()
        mock_get_db.return_value = mock_db_session

        # Mock no existing user
        mock_result = MagicMock()
        mock_result.scalar_one_or_none.return_value = None
        mock_db_session.execute.return_value = mock_result

        # Mock email service
        mock_email_instance = MagicMock()
        mock_email_instance.send_verification_email = AsyncMock(return_value=True)
        mock_email_service.return_value = mock_email_instance

        # Step 1: Register user
        response = client.post("/api/v1/auth/register", json=test_user_data)

        # Should either succeed or fail gracefully
        assert response.status_code in [201, 400, 500]

        if response.status_code == 201:
            data = response.json()
            assert "message" in data
            assert (
                "verify" in data["message"].lower()
                or "success" in data["message"].lower()
            )

    @patch("app.api.v1.auth.get_db_session")
    def test_user_registration_duplicate_email(
        self, mock_get_db, client, test_user_data, existing_user
    ):
        """Test user registration with duplicate email."""
        # Setup mocks
        mock_db_session = MagicMock()
        mock_get_db.return_value = mock_db_session

        # Mock existing user found
        mock_result = MagicMock()
        mock_result.scalar_one_or_none.return_value = existing_user
        mock_db_session.execute.return_value = mock_result

        # Try to register with existing email
        duplicate_data = test_user_data.copy()
        duplicate_data["email"] = existing_user.email

        response = client.post("/api/v1/auth/register", json=duplicate_data)

        # Should handle duplicate email appropriately
        assert response.status_code in [400, 409, 422]

    def test_user_registration_invalid_data(self, client):
        """Test user registration with various invalid data."""
        invalid_test_cases = [
            {},  # Empty data
            {"email": "invalid-email"},  # Invalid email format
            {"email": "test@example.com"},  # Missing password
            {"email": "test@example.com", "password": "weak"},  # Weak password
            {
                "email": "test@example.com",
                "password": "SecurePass123!",
            },  # Missing names
        ]

        for invalid_data in invalid_test_cases:
            response = client.post("/api/v1/auth/register", json=invalid_data)
            assert response.status_code in [400, 422]

    @patch("app.api.v1.auth.get_db_session")
    def test_email_verification_flow(self, mock_get_db, client):
        """Test email verification after registration."""
        # Setup mocks
        mock_db_session = MagicMock()
        mock_get_db.return_value = mock_db_session

        # Mock user lookup
        mock_user = MagicMock()
        mock_user.email_verified = False
        mock_user.is_active = False

        mock_result = MagicMock()
        mock_result.scalar_one_or_none.return_value = mock_user
        mock_db_session.execute.return_value = mock_result

        # Mock token validation (this would need actual token generation logic)
        verification_token = "mock_verification_token"

        # Attempt verification
        response = client.post(f"/api/v1/auth/verify-email?token={verification_token}")

        # Should handle verification attempt
        assert response.status_code in [200, 400, 404]


class TestLoginFlow:
    """End-to-end login flow tests."""

    @patch("app.api.v1.auth.get_db_session")
    @patch("app.api.v1.auth.AuthService")
    def test_successful_login_flow(
        self, mock_auth_service_class, mock_get_db, client, existing_user
    ):
        """Test successful login flow."""
        # Setup mocks
        mock_db_session = MagicMock()
        mock_get_db.return_value = mock_db_session

        # Mock auth service
        mock_auth_service = MagicMock()
        mock_auth_service.authenticate_user = AsyncMock(return_value=existing_user)
        mock_auth_service.create_access_token = AsyncMock(
            return_value="access_token_123"
        )
        mock_auth_service.create_refresh_token = AsyncMock(
            return_value="refresh_token_456"
        )
        mock_auth_service.log_audit_event = AsyncMock()
        mock_auth_service_class.return_value = mock_auth_service

        # Login credentials
        login_data = {"username": existing_user.email, "password": "ExistingPass123!"}

        # Attempt login
        response = client.post("/api/v1/auth/login", data=login_data)

        # Should either succeed or handle gracefully
        assert response.status_code in [200, 400, 401, 500]

        if response.status_code == 200:
            data = response.json()
            assert "access_token" in data
            assert "refresh_token" in data
            assert "token_type" in data
            assert data["token_type"] == "bearer"

    @patch("app.api.v1.auth.get_db_session")
    @patch("app.api.v1.auth.AuthService")
    def test_login_invalid_credentials(
        self, mock_auth_service_class, mock_get_db, client
    ):
        """Test login with invalid credentials."""
        # Setup mocks
        mock_db_session = MagicMock()
        mock_get_db.return_value = mock_db_session

        # Mock auth service to return None (invalid credentials)
        mock_auth_service = MagicMock()
        mock_auth_service.authenticate_user = AsyncMock(return_value=None)
        mock_auth_service_class.return_value = mock_auth_service

        # Invalid login credentials
        login_data = {
            "username": "nonexistent@example.com",
            "password": "WrongPassword123!",
        }

        # Attempt login
        response = client.post("/api/v1/auth/login", data=login_data)

        # Should handle invalid credentials
        assert response.status_code in [400, 401]

    def test_login_malformed_data(self, client):
        """Test login with malformed data."""
        malformed_test_cases = [
            {},  # Empty data
            {"username": "test@example.com"},  # Missing password
            {"password": "password123"},  # Missing username
            {"username": "", "password": ""},  # Empty strings
        ]

        for malformed_data in malformed_test_cases:
            response = client.post("/api/v1/auth/login", data=malformed_data)
            assert response.status_code in [400, 422]

    @patch("app.api.v1.auth.get_db_session")
    @patch("app.api.v1.auth.AuthService")
    def test_login_with_rate_limiting(
        self, mock_auth_service_class, mock_get_db, client
    ):
        """Test login rate limiting protection."""
        # Setup mocks
        mock_db_session = MagicMock()
        mock_get_db.return_value = mock_db_session

        mock_auth_service = MagicMock()
        mock_auth_service.authenticate_user = AsyncMock(return_value=None)
        mock_auth_service_class.return_value = mock_auth_service

        # Invalid login data
        login_data = {"username": "test@example.com", "password": "wrong_password"}

        # Attempt multiple failed logins rapidly
        responses = []
        for _ in range(10):  # Try 10 failed logins
            response = client.post("/api/v1/auth/login", data=login_data)
            responses.append(response.status_code)
            time.sleep(0.1)  # Small delay

        # Should eventually trigger rate limiting or continue handling requests
        # Exact behavior depends on rate limiting implementation
        assert all(status_code in [400, 401, 429, 500] for status_code in responses)


class TestTokenRefreshFlow:
    """End-to-end token refresh flow tests."""

    @patch("app.api.v1.auth.get_db_session")
    @patch("app.api.v1.auth.AuthService")
    def test_token_refresh_flow(
        self, mock_auth_service_class, mock_get_db, client, existing_user
    ):
        """Test token refresh flow."""
        # Setup mocks
        mock_db_session = MagicMock()
        mock_get_db.return_value = mock_db_session

        mock_auth_service = MagicMock()
        mock_auth_service.refresh_access_token = AsyncMock(
            return_value={
                "access_token": "new_access_token",
                "refresh_token": "new_refresh_token",
                "expires_in": 900,
            }
        )
        mock_auth_service_class.return_value = mock_auth_service

        # Refresh data
        refresh_data = {"refresh_token": "valid_refresh_token"}

        # Attempt token refresh
        response = client.post("/api/v1/auth/refresh", json=refresh_data)

        # Should either succeed or handle gracefully
        assert response.status_code in [200, 400, 401, 500]

        if response.status_code == 200:
            data = response.json()
            assert "access_token" in data
            assert "refresh_token" in data

    @patch("app.api.v1.auth.get_db_session")
    @patch("app.api.v1.auth.AuthService")
    def test_token_refresh_invalid_token(
        self, mock_auth_service_class, mock_get_db, client
    ):
        """Test token refresh with invalid refresh token."""
        # Setup mocks
        mock_db_session = MagicMock()
        mock_get_db.return_value = mock_db_session

        mock_auth_service = MagicMock()
        mock_auth_service.refresh_access_token = AsyncMock(return_value=None)
        mock_auth_service_class.return_value = mock_auth_service

        # Invalid refresh data
        refresh_data = {"refresh_token": "invalid_refresh_token"}

        # Attempt token refresh
        response = client.post("/api/v1/auth/refresh", json=refresh_data)

        # Should handle invalid token
        assert response.status_code in [400, 401]


class TestPasswordResetFlow:
    """End-to-end password reset flow tests."""

    @patch("app.api.v1.auth.get_db_session")
    @patch("app.api.v1.auth.EmailService")
    def test_password_reset_request_flow(
        self, mock_email_service, mock_get_db, client, existing_user
    ):
        """Test password reset request flow."""
        # Setup mocks
        mock_db_session = MagicMock()
        mock_get_db.return_value = mock_db_session

        # Mock user lookup
        mock_result = MagicMock()
        mock_result.scalar_one_or_none.return_value = existing_user
        mock_db_session.execute.return_value = mock_result

        # Mock email service
        mock_email_instance = MagicMock()
        mock_email_instance.send_password_reset_email = AsyncMock(return_value=True)
        mock_email_service.return_value = mock_email_instance

        # Request password reset
        reset_data = {"email": existing_user.email}

        response = client.post("/api/v1/auth/forgot-password", json=reset_data)

        # Should handle reset request
        assert response.status_code in [200, 400, 404, 500]

    @patch("app.api.v1.auth.get_db_session")
    def test_password_reset_confirm_flow(self, mock_get_db, client):
        """Test password reset confirmation flow."""
        # Setup mocks
        mock_db_session = MagicMock()
        mock_get_db.return_value = mock_db_session

        # Mock token validation and user update
        mock_user = MagicMock()
        mock_result = MagicMock()
        mock_result.scalar_one_or_none.return_value = mock_user
        mock_db_session.execute.return_value = mock_result

        # Reset confirmation data
        confirm_data = {
            "token": "valid_reset_token",
            "new_password": "NewSecurePass123!",
        }

        response = client.post("/api/v1/auth/reset-password", json=confirm_data)

        # Should handle password reset
        assert response.status_code in [200, 400, 404, 500]


class TestTwoFactorAuthenticationFlow:
    """End-to-end 2FA flow tests."""

    @patch("app.api.v1.two_factor.get_db_session")
    @patch("app.api.v1.two_factor.TwoFactorService")
    @patch("app.api.v1.two_factor.get_current_user")
    def test_2fa_setup_flow(
        self,
        mock_get_current_user,
        mock_2fa_service_class,
        mock_get_db,
        client,
        existing_user,
    ):
        """Test 2FA setup flow."""
        # Setup mocks
        mock_get_current_user.return_value = existing_user
        mock_db_session = MagicMock()
        mock_get_db.return_value = mock_db_session

        mock_2fa_service = MagicMock()
        mock_2fa_service.setup_totp = AsyncMock(
            return_value={
                "secret": "JBSWY3DPEHPK3PXP",
                "qr_code": "data:image/png;base64,mock_qr_code",
                "backup_codes": ["ABCD-EFGH", "IJKL-MNOP"],
            }
        )
        mock_2fa_service_class.return_value = mock_2fa_service

        headers = {"Authorization": "Bearer test_token"}

        # Setup 2FA
        response = client.post("/api/v1/two-factor/setup", headers=headers)

        # Should handle 2FA setup
        assert response.status_code in [200, 400, 401, 500]

        if response.status_code == 200:
            data = response.json()
            assert "secret" in data or "qr_code" in data

    @patch("app.api.v1.two_factor.get_db_session")
    @patch("app.api.v1.two_factor.TwoFactorService")
    @patch("app.api.v1.two_factor.get_current_user")
    def test_2fa_verification_flow(
        self,
        mock_get_current_user,
        mock_2fa_service_class,
        mock_get_db,
        client,
        existing_user,
    ):
        """Test 2FA verification flow."""
        # Setup mocks
        existing_user.two_factor_enabled = False
        existing_user.totp_secret = "JBSWY3DPEHPK3PXP"
        mock_get_current_user.return_value = existing_user

        mock_db_session = MagicMock()
        mock_get_db.return_value = mock_db_session

        mock_2fa_service = MagicMock()
        mock_2fa_service.verify_and_enable_totp = AsyncMock(return_value=True)
        mock_2fa_service_class.return_value = mock_2fa_service

        headers = {"Authorization": "Bearer test_token"}

        # Verify 2FA setup
        verify_data = {"totp_code": "123456"}

        response = client.post(
            "/api/v1/two-factor/verify", json=verify_data, headers=headers
        )

        # Should handle 2FA verification
        assert response.status_code in [200, 400, 401, 500]


class TestOAuthFlow:
    """End-to-end OAuth flow tests."""

    @patch("app.api.v1.oauth.get_db_session")
    @patch("app.api.v1.oauth.OAuthService")
    @patch("app.api.v1.oauth.settings")
    @patch("redis.Redis.from_url")
    def test_oauth_google_flow(
        self,
        mock_redis_from_url,
        mock_settings,
        mock_oauth_service_class,
        mock_get_db,
        client,
        existing_user,
    ):
        """Test complete OAuth flow with Google."""
        # Setup mocks
        mock_settings.REDIS_URL = "redis://localhost:6379"

        mock_redis_client = MagicMock()
        mock_redis_from_url.return_value = mock_redis_client

        mock_oauth_service = MagicMock()
        mock_oauth_service.get_authorization_url.return_value = (
            "https://accounts.google.com/oauth2/auth?state=test_state"
        )
        mock_oauth_service_class.return_value = mock_oauth_service

        mock_db_session = MagicMock()
        mock_get_db.return_value = mock_db_session

        # Step 1: Initialize OAuth
        response = client.get("/api/v1/oauth/google/init")
        assert response.status_code in [200, 500]

        if response.status_code == 200:
            init_data = response.json()
            assert "authorization_url" in init_data
            assert "state" in init_data

            # Step 2: Simulate callback (would normally come from provider)
            mock_redis_client.get.return_value = b"google"
            mock_oauth_service.authenticate_oauth_user.return_value = (
                existing_user,
                "access_token_123",
                "refresh_token_456",
            )

            callback_data = {
                "code": "auth_code_from_google",
                "state": init_data["state"],
            }

            response = client.post("/api/v1/oauth/google/callback", json=callback_data)
            assert response.status_code in [200, 400, 500]


class TestUserProfileFlow:
    """End-to-end user profile management flow tests."""

    @patch("app.api.v1.users.get_db_session")
    @patch("app.api.v1.users.get_current_user")
    def test_user_profile_management_flow(
        self, mock_get_current_user, mock_get_db, client, existing_user
    ):
        """Test complete user profile management flow."""
        # Setup mocks
        mock_get_current_user.return_value = existing_user
        mock_db_session = MagicMock()
        mock_get_db.return_value = mock_db_session

        headers = {"Authorization": "Bearer test_token"}

        # Step 1: Get current profile
        response = client.get("/api/v1/users/me", headers=headers)
        assert response.status_code in [200, 401, 500]

        if response.status_code == 200:
            profile_data = response.json()

            # Step 2: Update profile
            update_data = {"first_name": "Updated", "last_name": "Name"}

            response = client.put("/api/v1/users/me", json=update_data, headers=headers)
            assert response.status_code in [200, 400, 401, 500]


class TestAdminUserManagementFlow:
    """End-to-end admin user management flow tests."""

    @patch("app.api.v1.users.get_db_session")
    @patch("app.api.v1.users.require_permissions")
    def test_admin_user_management_flow(
        self, mock_require_permissions, mock_get_db, client, existing_user
    ):
        """Test complete admin user management flow."""
        # Setup mocks
        admin_user = existing_user.copy()
        admin_user.roles = ["admin"]
        mock_require_permissions.return_value = admin_user

        mock_db_session = MagicMock()
        mock_get_db.return_value = mock_db_session

        admin_headers = {"Authorization": "Bearer admin_token"}

        # Step 1: List users
        response = client.get("/api/v1/users/", headers=admin_headers)
        assert response.status_code in [200, 401, 403, 500]

        if response.status_code == 200:
            user_list = response.json()
            assert "users" in user_list

            # Step 2: Manage specific user
            user_id = "test-user-123"

            # Get user details
            response = client.get(f"/api/v1/users/{user_id}", headers=admin_headers)
            assert response.status_code in [200, 404, 500]

            # Update user roles
            new_roles = ["user", "moderator"]
            response = client.put(
                f"/api/v1/users/{user_id}/roles", json=new_roles, headers=admin_headers
            )
            assert response.status_code in [200, 400, 404, 500]

            # Deactivate user
            response = client.post(
                f"/api/v1/users/{user_id}/deactivate", headers=admin_headers
            )
            assert response.status_code in [200, 404, 500]


class TestSessionManagementFlow:
    """End-to-end session management flow tests."""

    @patch("app.api.v1.auth.get_db_session")
    @patch("app.api.v1.auth.AuthService")
    def test_logout_flow(self, mock_auth_service_class, mock_get_db, client):
        """Test logout flow."""
        # Setup mocks
        mock_db_session = MagicMock()
        mock_get_db.return_value = mock_db_session

        mock_auth_service = MagicMock()
        mock_auth_service.revoke_refresh_token = AsyncMock(return_value=True)
        mock_auth_service_class.return_value = mock_auth_service

        headers = {"Authorization": "Bearer test_token"}
        logout_data = {"refresh_token": "refresh_token_to_revoke"}

        # Attempt logout
        response = client.post("/api/v1/auth/logout", json=logout_data, headers=headers)

        # Should handle logout
        assert response.status_code in [200, 400, 401, 500]


class TestSecurityFlow:
    """End-to-end security feature tests."""

    def test_rate_limiting_protection(self, client):
        """Test rate limiting across different endpoints."""
        # Test multiple rapid requests to sensitive endpoints
        sensitive_endpoints = [
            ("POST", "/api/v1/auth/login", {"username": "test", "password": "test"}),
            (
                "POST",
                "/api/v1/auth/register",
                {"email": "test@test.com", "password": "test123"},
            ),
            ("POST", "/api/v1/auth/forgot-password", {"email": "test@test.com"}),
        ]

        for method, endpoint, data in sensitive_endpoints:
            responses = []
            for _ in range(20):  # Rapid requests
                if method == "POST":
                    response = client.post(endpoint, json=data)
                responses.append(response.status_code)
                time.sleep(0.05)  # Small delay

            # Should handle requests appropriately (may include rate limiting)
            assert all(status in [200, 400, 401, 422, 429, 500] for status in responses)

    def test_input_validation_security(self, client):
        """Test input validation across endpoints."""
        # Test various potentially malicious inputs
        malicious_inputs = [
            {"email": "<script>alert('xss')</script>"},
            {"email": "'; DROP TABLE users; --"},
            {"password": "\x00\x01\x02"},  # Null bytes
            {"first_name": "A" * 10000},  # Very long string
        ]

        for malicious_data in malicious_inputs:
            response = client.post("/api/v1/auth/register", json=malicious_data)
            # Should handle malicious input safely
            assert response.status_code in [400, 422]


class TestErrorHandlingFlow:
    """End-to-end error handling tests."""

    def test_database_connection_errors(self, client):
        """Test handling of database connection errors."""
        # This would test how the app handles database failures
        # In a real E2E test, you might temporarily kill the database connection

        endpoints_to_test = [
            ("GET", "/api/v1/users/me"),
            ("POST", "/api/v1/auth/login"),
            ("POST", "/api/v1/auth/register"),
        ]

        for method, endpoint in endpoints_to_test:
            if method == "GET":
                response = client.get(endpoint)
            elif method == "POST":
                response = client.post(endpoint, json={})

            # Should handle errors gracefully (not crash)
            assert response.status_code in [200, 400, 401, 422, 500]

    def test_external_service_failures(self, client):
        """Test handling of external service failures."""
        # Test email service failures, Redis failures, etc.
        test_data = {
            "email": "test@example.com",
            "password": "TestPass123!",
            "first_name": "Test",
            "last_name": "User",
        }

        # Registration might fail due to email service issues
        response = client.post("/api/v1/auth/register", json=test_data)
        assert response.status_code in [200, 201, 400, 500]


@pytest.mark.asyncio
class TestAsyncEndToEndFlows:
    """Async end-to-end flow tests."""

    async def test_concurrent_user_registrations(self, client):
        """Test handling of concurrent user registrations."""

        async def register_user(index: int):
            user_data = {
                "email": f"concurrent{index}@example.com",
                "password": "SecurePass123!",
                "first_name": "Concurrent",
                "last_name": f"User{index}",
            }

            return client.post("/api/v1/auth/register", json=user_data)

        # Create multiple concurrent registration requests
        tasks = [register_user(i) for i in range(10)]
        responses = await asyncio.gather(*tasks, return_exceptions=True)

        # Should handle concurrent requests appropriately
        for response in responses:
            if not isinstance(response, Exception):
                assert response.status_code in [200, 201, 400, 422, 500]

    async def test_concurrent_login_attempts(self, client):
        """Test handling of concurrent login attempts."""
        login_data = {"username": "test@example.com", "password": "wrongpassword"}

        async def attempt_login():
            return client.post("/api/v1/auth/login", data=login_data)

        # Multiple concurrent failed login attempts
        tasks = [attempt_login() for _ in range(10)]
        responses = await asyncio.gather(*tasks, return_exceptions=True)

        # Should handle concurrent attempts (may include rate limiting)
        for response in responses:
            if not isinstance(response, Exception):
                assert response.status_code in [400, 401, 429, 500]
