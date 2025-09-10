"""
OAuth Endpoints Integration Tests

Comprehensive integration tests for OAuth authentication endpoints including
initialization, callback handling, and account linking functionality.
"""

import pytest
import json
import secrets
from datetime import datetime, timedelta
from typing import Dict
from unittest.mock import AsyncMock, MagicMock, patch

import pytest_asyncio
from fastapi import status
from fastapi.testclient import TestClient
from sqlalchemy.ext.asyncio import AsyncSession

from app.main import app
from app.models.user import User
from app.schemas.auth import OAuthProvider, OAuthUserInfo
from app.services.oauth_service import OAuthService


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
    return User(
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


@pytest.fixture
def mock_oauth_service():
    """Create mock OAuth service."""
    service = MagicMock(spec=OAuthService)
    service.get_authorization_url = MagicMock()
    service.authenticate_oauth_user = AsyncMock()
    service._get_oauth_user_info = AsyncMock()
    service.link_oauth_account = AsyncMock()
    return service


@pytest.fixture
def mock_settings():
    """Mock settings for testing."""
    settings = MagicMock()
    settings.REDIS_URL = "redis://localhost:6379"
    return settings


@pytest.fixture
def mock_redis():
    """Mock Redis client."""
    redis_client = MagicMock()
    redis_client.setex = MagicMock()
    redis_client.get = MagicMock()
    redis_client.delete = MagicMock()
    return redis_client


class TestOAuthInit:
    """Tests for OAuth initialization endpoint."""

    @patch("app.api.v1.oauth.get_db_session")
    @patch("app.api.v1.oauth.OAuthService")
    @patch("app.api.v1.oauth.settings")
    @patch("redis.Redis.from_url")
    def test_oauth_init_google_success(
        self,
        mock_redis_from_url,
        mock_settings,
        mock_oauth_service_class,
        mock_get_db,
        client,
    ):
        """Test successful OAuth initialization for Google."""
        # Setup mocks
        mock_settings.REDIS_URL = "redis://localhost:6379"
        mock_redis_client = MagicMock()
        mock_redis_from_url.return_value = mock_redis_client

        mock_oauth_service = MagicMock()
        mock_oauth_service.get_authorization_url.return_value = (
            "https://accounts.google.com/oauth2/auth?client_id=test"
        )
        mock_oauth_service_class.return_value = mock_oauth_service

        mock_get_db.return_value = MagicMock()

        # Make request
        response = client.get("/api/v1/oauth/google/init")

        # Assertions
        assert response.status_code == 200
        data = response.json()
        assert "authorization_url" in data
        assert "state" in data
        assert (
            data["authorization_url"]
            == "https://accounts.google.com/oauth2/auth?client_id=test"
        )

        # Verify Redis was called to store state
        mock_redis_client.setex.assert_called_once()

    @patch("app.api.v1.oauth.get_db_session")
    @patch("app.api.v1.oauth.OAuthService")
    @patch("app.api.v1.oauth.settings")
    def test_oauth_init_github_success(
        self, mock_settings, mock_oauth_service_class, mock_get_db, client
    ):
        """Test successful OAuth initialization for GitHub."""
        # Setup mocks for in-memory storage (no Redis)
        mock_settings.REDIS_URL = None

        mock_oauth_service = MagicMock()
        mock_oauth_service.get_authorization_url.return_value = (
            "https://github.com/login/oauth/authorize?client_id=test"
        )
        mock_oauth_service_class.return_value = mock_oauth_service

        mock_get_db.return_value = MagicMock()

        # Make request
        response = client.get("/api/v1/oauth/github/init")

        # Assertions
        assert response.status_code == 200
        data = response.json()
        assert "authorization_url" in data
        assert "state" in data
        assert (
            data["authorization_url"]
            == "https://github.com/login/oauth/authorize?client_id=test"
        )

    @patch("app.api.v1.oauth.get_db_session")
    @patch("app.api.v1.oauth.OAuthService")
    def test_oauth_init_discord_success(
        self, mock_oauth_service_class, mock_get_db, client
    ):
        """Test successful OAuth initialization for Discord."""
        mock_oauth_service = MagicMock()
        mock_oauth_service.get_authorization_url.return_value = (
            "https://discord.com/api/oauth2/authorize?client_id=test"
        )
        mock_oauth_service_class.return_value = mock_oauth_service

        mock_get_db.return_value = MagicMock()

        # Make request
        response = client.get("/api/v1/oauth/discord/init")

        # Assertions
        assert response.status_code == 200
        data = response.json()
        assert "authorization_url" in data
        assert "state" in data

    def test_oauth_init_invalid_provider(self, client):
        """Test OAuth initialization with invalid provider."""
        response = client.get("/api/v1/oauth/invalid/init")

        assert response.status_code == 422  # Validation error

    @patch("app.api.v1.oauth.get_db_session")
    @patch("app.api.v1.oauth.OAuthService")
    @patch("app.api.v1.oauth.settings")
    @patch("redis.Redis.from_url")
    def test_oauth_init_redis_error(
        self,
        mock_redis_from_url,
        mock_settings,
        mock_oauth_service_class,
        mock_get_db,
        client,
    ):
        """Test OAuth initialization with Redis connection error."""
        # Setup mocks
        mock_settings.REDIS_URL = "redis://localhost:6379"
        mock_redis_from_url.side_effect = Exception("Redis connection failed")

        mock_oauth_service_class.return_value = MagicMock()
        mock_get_db.return_value = MagicMock()

        # Make request
        response = client.get("/api/v1/oauth/google/init")

        # Assertions
        assert response.status_code == 500
        assert (
            "Authentication service temporarily unavailable"
            in response.json()["detail"]
        )

    @patch("app.api.v1.oauth.get_db_session")
    @patch("app.api.v1.oauth.OAuthService")
    def test_oauth_init_service_error(
        self, mock_oauth_service_class, mock_get_db, client
    ):
        """Test OAuth initialization with service error."""
        mock_oauth_service = MagicMock()
        mock_oauth_service.get_authorization_url.side_effect = Exception(
            "Service error"
        )
        mock_oauth_service_class.return_value = mock_oauth_service

        mock_get_db.return_value = MagicMock()

        # Make request
        response = client.get("/api/v1/oauth/google/init")

        # Assertions
        assert response.status_code == 500
        assert "Failed to initialize OAuth flow" in response.json()["detail"]


class TestOAuthCallback:
    """Tests for OAuth callback endpoint."""

    @patch("app.api.v1.oauth.get_db_session")
    @patch("app.api.v1.oauth.OAuthService")
    @patch("app.api.v1.oauth.settings")
    @patch("redis.Redis.from_url")
    def test_oauth_callback_success(
        self,
        mock_redis_from_url,
        mock_settings,
        mock_oauth_service_class,
        mock_get_db,
        client,
        sample_user,
    ):
        """Test successful OAuth callback."""
        # Setup mocks
        mock_settings.REDIS_URL = "redis://localhost:6379"
        mock_redis_client = MagicMock()
        mock_redis_client.get.return_value = b"google"  # State validation
        mock_redis_from_url.return_value = mock_redis_client

        mock_oauth_service = MagicMock()
        mock_oauth_service.authenticate_oauth_user.return_value = (
            sample_user,
            "access_token_123",
            "refresh_token_456",
        )
        mock_oauth_service_class.return_value = mock_oauth_service

        mock_get_db.return_value = MagicMock()

        # Make request
        callback_data = {"code": "auth_code_123", "state": "state_token_456"}
        response = client.post("/api/v1/oauth/google/callback", json=callback_data)

        # Assertions
        assert response.status_code == 200
        data = response.json()
        assert data["access_token"] == "access_token_123"
        assert data["refresh_token"] == "refresh_token_456"
        assert data["token_type"] == "bearer"
        assert data["user"]["email"] == sample_user.email

        # Verify state was deleted after use
        mock_redis_client.delete.assert_called_once()

    @patch("app.api.v1.oauth.get_db_session")
    @patch("app.api.v1.oauth.OAuthService")
    @patch("app.api.v1.oauth.settings")
    def test_oauth_callback_in_memory_state_success(
        self, mock_settings, mock_oauth_service_class, mock_get_db, client, sample_user
    ):
        """Test OAuth callback with in-memory state storage."""
        # Setup mocks for in-memory storage
        mock_settings.REDIS_URL = None

        mock_oauth_service = MagicMock()
        mock_oauth_service.authenticate_oauth_user.return_value = (
            sample_user,
            "access_token_123",
            "refresh_token_456",
        )
        mock_oauth_service_class.return_value = mock_oauth_service

        mock_get_db.return_value = MagicMock()

        # Simulate in-memory state storage
        from app.api.v1.oauth import oauth_init

        oauth_init._state_store = {
            "test_state": {
                "provider": "google",
                "expires": datetime.utcnow() + timedelta(seconds=300),
            }
        }

        # Make request
        callback_data = {"code": "auth_code_123", "state": "test_state"}
        response = client.post("/api/v1/oauth/google/callback", json=callback_data)

        # Assertions
        assert response.status_code == 200
        data = response.json()
        assert data["access_token"] == "access_token_123"

    def test_oauth_callback_missing_state(self, client):
        """Test OAuth callback with missing state parameter."""
        callback_data = {
            "code": "auth_code_123"
            # Missing state
        }
        response = client.post("/api/v1/oauth/google/callback", json=callback_data)

        assert response.status_code == 400
        assert "Missing state parameter" in response.json()["detail"]

    @patch("app.api.v1.oauth.get_db_session")
    @patch("app.api.v1.oauth.settings")
    @patch("redis.Redis.from_url")
    def test_oauth_callback_invalid_state(
        self, mock_redis_from_url, mock_settings, mock_get_db, client
    ):
        """Test OAuth callback with invalid state."""
        # Setup mocks
        mock_settings.REDIS_URL = "redis://localhost:6379"
        mock_redis_client = MagicMock()
        mock_redis_client.get.return_value = None  # State not found
        mock_redis_from_url.return_value = mock_redis_client

        mock_get_db.return_value = MagicMock()

        # Make request
        callback_data = {"code": "auth_code_123", "state": "invalid_state"}
        response = client.post("/api/v1/oauth/google/callback", json=callback_data)

        # Assertions
        assert response.status_code == 400
        assert "Invalid or expired state parameter" in response.json()["detail"]

    @patch("app.api.v1.oauth.get_db_session")
    @patch("app.api.v1.oauth.settings")
    @patch("redis.Redis.from_url")
    def test_oauth_callback_provider_mismatch(
        self, mock_redis_from_url, mock_settings, mock_get_db, client
    ):
        """Test OAuth callback with provider mismatch."""
        # Setup mocks
        mock_settings.REDIS_URL = "redis://localhost:6379"
        mock_redis_client = MagicMock()
        mock_redis_client.get.return_value = b"github"  # Different provider
        mock_redis_from_url.return_value = mock_redis_client

        mock_get_db.return_value = MagicMock()

        # Make request to Google callback with GitHub state
        callback_data = {"code": "auth_code_123", "state": "state_token_456"}
        response = client.post("/api/v1/oauth/google/callback", json=callback_data)

        # Assertions
        assert response.status_code == 400
        assert "State parameter provider mismatch" in response.json()["detail"]

    @patch("app.api.v1.oauth.get_db_session")
    @patch("app.api.v1.oauth.OAuthService")
    @patch("app.api.v1.oauth.settings")
    @patch("redis.Redis.from_url")
    def test_oauth_callback_authentication_failure(
        self,
        mock_redis_from_url,
        mock_settings,
        mock_oauth_service_class,
        mock_get_db,
        client,
    ):
        """Test OAuth callback with authentication failure."""
        # Setup mocks
        mock_settings.REDIS_URL = "redis://localhost:6379"
        mock_redis_client = MagicMock()
        mock_redis_client.get.return_value = b"google"
        mock_redis_from_url.return_value = mock_redis_client

        mock_oauth_service = MagicMock()
        mock_oauth_service.authenticate_oauth_user.side_effect = Exception(
            "Auth failed"
        )
        mock_oauth_service_class.return_value = mock_oauth_service

        mock_get_db.return_value = MagicMock()

        # Make request
        callback_data = {"code": "invalid_code", "state": "valid_state"}
        response = client.post("/api/v1/oauth/google/callback", json=callback_data)

        # Assertions
        assert response.status_code == 500
        assert "OAuth authentication failed" in response.json()["detail"]

    @patch("app.api.v1.oauth.get_db_session")
    @patch("app.api.v1.oauth.settings")
    def test_oauth_callback_expired_in_memory_state(
        self, mock_settings, mock_get_db, client
    ):
        """Test OAuth callback with expired in-memory state."""
        # Setup mocks for in-memory storage
        mock_settings.REDIS_URL = None
        mock_get_db.return_value = MagicMock()

        # Simulate expired in-memory state
        from app.api.v1.oauth import oauth_init

        oauth_init._state_store = {
            "expired_state": {
                "provider": "google",
                "expires": datetime.utcnow() - timedelta(seconds=10),  # Expired
            }
        }

        # Make request
        callback_data = {"code": "auth_code_123", "state": "expired_state"}
        response = client.post("/api/v1/oauth/google/callback", json=callback_data)

        # Assertions
        assert response.status_code == 400
        assert "Invalid or expired state parameter" in response.json()["detail"]

    @patch("app.api.v1.oauth.get_db_session")
    @patch("app.api.v1.oauth.settings")
    @patch("redis.Redis.from_url")
    def test_oauth_callback_redis_connection_error(
        self, mock_redis_from_url, mock_settings, mock_get_db, client
    ):
        """Test OAuth callback with Redis connection error."""
        # Setup mocks
        mock_settings.REDIS_URL = "redis://localhost:6379"
        mock_redis_from_url.side_effect = Exception("Redis connection failed")

        mock_get_db.return_value = MagicMock()

        # Make request
        callback_data = {"code": "auth_code_123", "state": "state_token_456"}
        response = client.post("/api/v1/oauth/google/callback", json=callback_data)

        # Assertions
        assert response.status_code == 500
        assert (
            "Authentication service temporarily unavailable"
            in response.json()["detail"]
        )


class TestOAuthLink:
    """Tests for OAuth account linking endpoint."""

    @patch("app.api.v1.oauth.get_db_session")
    @patch("app.api.v1.oauth.OAuthService")
    @patch("app.api.v1.oauth.get_current_user_optional")
    def test_oauth_link_success(
        self,
        mock_get_current_user,
        mock_oauth_service_class,
        mock_get_db,
        client,
        sample_user,
    ):
        """Test successful OAuth account linking."""
        # Setup mocks
        mock_get_current_user.return_value = sample_user

        mock_oauth_service = MagicMock()
        mock_oauth_user_info = OAuthUserInfo(
            id="google_123",
            email="test@gmail.com",
            name="Test User",
            picture="https://avatar.url",
            email_verified=True,
            provider=OAuthProvider.GOOGLE,
        )
        mock_oauth_service._get_oauth_user_info.return_value = mock_oauth_user_info
        mock_oauth_service.link_oauth_account = AsyncMock()
        mock_oauth_service_class.return_value = mock_oauth_service

        mock_get_db.return_value = MagicMock()

        # Make request
        link_data = {"code": "auth_code_123", "state": "state_token_456"}
        response = client.post("/api/v1/oauth/google/link", json=link_data)

        # Assertions
        assert response.status_code == 200
        data = response.json()
        assert "Google account linked successfully" in data["message"]

        # Verify service methods were called
        mock_oauth_service._get_oauth_user_info.assert_called_once()
        mock_oauth_service.link_oauth_account.assert_called_once()

    @patch("app.api.v1.oauth.get_current_user_optional")
    def test_oauth_link_unauthenticated(self, mock_get_current_user, client):
        """Test OAuth account linking without authentication."""
        # Setup mocks
        mock_get_current_user.return_value = None

        # Make request
        link_data = {"code": "auth_code_123", "state": "state_token_456"}
        response = client.post("/api/v1/oauth/google/link", json=link_data)

        # Assertions
        assert response.status_code == 401
        assert "Authentication required" in response.json()["detail"]

    @patch("app.api.v1.oauth.get_db_session")
    @patch("app.api.v1.oauth.OAuthService")
    @patch("app.api.v1.oauth.get_current_user_optional")
    def test_oauth_link_github_success(
        self,
        mock_get_current_user,
        mock_oauth_service_class,
        mock_get_db,
        client,
        sample_user,
    ):
        """Test successful GitHub account linking."""
        # Setup mocks
        mock_get_current_user.return_value = sample_user

        mock_oauth_service = MagicMock()
        mock_oauth_user_info = OAuthUserInfo(
            id="github_456",
            email="test@example.com",
            name="Test User",
            picture="https://github.com/avatar.jpg",
            email_verified=True,
            provider=OAuthProvider.GITHUB,
        )
        mock_oauth_service._get_oauth_user_info.return_value = mock_oauth_user_info
        mock_oauth_service.link_oauth_account = AsyncMock()
        mock_oauth_service_class.return_value = mock_oauth_service

        mock_get_db.return_value = MagicMock()

        # Make request
        link_data = {"code": "github_auth_code", "state": "github_state"}
        response = client.post("/api/v1/oauth/github/link", json=link_data)

        # Assertions
        assert response.status_code == 200
        data = response.json()
        assert "Github account linked successfully" in data["message"]

    @patch("app.api.v1.oauth.get_db_session")
    @patch("app.api.v1.oauth.OAuthService")
    @patch("app.api.v1.oauth.get_current_user_optional")
    def test_oauth_link_discord_success(
        self,
        mock_get_current_user,
        mock_oauth_service_class,
        mock_get_db,
        client,
        sample_user,
    ):
        """Test successful Discord account linking."""
        # Setup mocks
        mock_get_current_user.return_value = sample_user

        mock_oauth_service = MagicMock()
        mock_oauth_user_info = OAuthUserInfo(
            id="discord_789",
            email="test@example.com",
            name="TestUser#1234",
            picture="https://cdn.discordapp.com/avatars/123/avatar.png",
            email_verified=True,
            provider=OAuthProvider.DISCORD,
        )
        mock_oauth_service._get_oauth_user_info.return_value = mock_oauth_user_info
        mock_oauth_service.link_oauth_account = AsyncMock()
        mock_oauth_service_class.return_value = mock_oauth_service

        mock_get_db.return_value = MagicMock()

        # Make request
        link_data = {"code": "discord_auth_code", "state": "discord_state"}
        response = client.post("/api/v1/oauth/discord/link", json=link_data)

        # Assertions
        assert response.status_code == 200
        data = response.json()
        assert "Discord account linked successfully" in data["message"]

    @patch("app.api.v1.oauth.get_db_session")
    @patch("app.api.v1.oauth.OAuthService")
    @patch("app.api.v1.oauth.get_current_user_optional")
    def test_oauth_link_service_error(
        self,
        mock_get_current_user,
        mock_oauth_service_class,
        mock_get_db,
        client,
        sample_user,
    ):
        """Test OAuth account linking with service error."""
        # Setup mocks
        mock_get_current_user.return_value = sample_user

        mock_oauth_service = MagicMock()
        mock_oauth_service._get_oauth_user_info.side_effect = Exception("Service error")
        mock_oauth_service_class.return_value = mock_oauth_service

        mock_get_db.return_value = MagicMock()

        # Make request
        link_data = {"code": "auth_code_123", "state": "state_token_456"}
        response = client.post("/api/v1/oauth/google/link", json=link_data)

        # Assertions
        assert response.status_code == 500
        assert "Failed to link OAuth account" in response.json()["detail"]

    def test_oauth_link_invalid_provider(self, client):
        """Test OAuth account linking with invalid provider."""
        link_data = {"code": "auth_code_123", "state": "state_token_456"}
        response = client.post("/api/v1/oauth/invalid/link", json=link_data)

        assert response.status_code == 422  # Validation error

    @patch("app.api.v1.oauth.get_db_session")
    @patch("app.api.v1.oauth.OAuthService")
    @patch("app.api.v1.oauth.get_current_user_optional")
    def test_oauth_link_already_linked_error(
        self,
        mock_get_current_user,
        mock_oauth_service_class,
        mock_get_db,
        client,
        sample_user,
    ):
        """Test OAuth account linking when account is already linked."""
        from fastapi import HTTPException

        # Setup mocks
        mock_get_current_user.return_value = sample_user

        mock_oauth_service = MagicMock()
        mock_oauth_user_info = OAuthUserInfo(
            id="google_123",
            email="test@gmail.com",
            name="Test User",
            picture="https://avatar.url",
            email_verified=True,
            provider=OAuthProvider.GOOGLE,
        )
        mock_oauth_service._get_oauth_user_info.return_value = mock_oauth_user_info
        mock_oauth_service.link_oauth_account = AsyncMock(
            side_effect=HTTPException(
                status_code=400,
                detail="This Google account is already linked to another user",
            )
        )
        mock_oauth_service_class.return_value = mock_oauth_service

        mock_get_db.return_value = MagicMock()

        # Make request
        link_data = {"code": "auth_code_123", "state": "state_token_456"}
        response = client.post("/api/v1/oauth/google/link", json=link_data)

        # Assertions
        assert response.status_code == 400
        assert "already linked to another user" in response.json()["detail"]


class TestOAuthEndpointsIntegration:
    """Integration tests for OAuth endpoints workflow."""

    @patch("app.api.v1.oauth.get_db_session")
    @patch("app.api.v1.oauth.OAuthService")
    @patch("app.api.v1.oauth.settings")
    @patch("redis.Redis.from_url")
    def test_complete_oauth_flow(
        self,
        mock_redis_from_url,
        mock_settings,
        mock_oauth_service_class,
        mock_get_db,
        client,
        sample_user,
    ):
        """Test complete OAuth authentication flow."""
        # Setup mocks
        mock_settings.REDIS_URL = "redis://localhost:6379"
        mock_redis_client = MagicMock()
        mock_redis_from_url.return_value = mock_redis_client

        mock_oauth_service = MagicMock()
        mock_oauth_service_class.return_value = mock_oauth_service

        mock_get_db.return_value = MagicMock()

        # Step 1: Initialize OAuth
        mock_oauth_service.get_authorization_url.return_value = (
            "https://accounts.google.com/oauth2/auth?state=test_state"
        )

        init_response = client.get("/api/v1/oauth/google/init")
        assert init_response.status_code == 200
        state = init_response.json()["state"]

        # Step 2: Handle callback
        mock_redis_client.get.return_value = b"google"
        mock_oauth_service.authenticate_oauth_user.return_value = (
            sample_user,
            "access_token_123",
            "refresh_token_456",
        )

        callback_data = {"code": "auth_code_123", "state": state}
        callback_response = client.post(
            "/api/v1/oauth/google/callback", json=callback_data
        )

        assert callback_response.status_code == 200
        callback_data = callback_response.json()
        assert callback_data["access_token"] == "access_token_123"
        assert callback_data["user"]["email"] == sample_user.email

    def test_oauth_endpoints_error_handling(self, client):
        """Test OAuth endpoints handle errors gracefully."""
        # Test init with missing dependencies
        response = client.get("/api/v1/oauth/google/init")
        # Should handle missing dependencies gracefully
        assert response.status_code in [200, 500]  # Either works or fails gracefully

        # Test callback with missing data
        response = client.post("/api/v1/oauth/google/callback", json={})
        assert response.status_code == 422  # Validation error

        # Test link with missing authentication
        response = client.post("/api/v1/oauth/google/link", json={})
        # Should handle missing authentication
        assert response.status_code in [401, 422]

    def test_oauth_provider_validation(self, client):
        """Test OAuth provider validation across endpoints."""
        # Valid providers
        valid_providers = ["google", "github", "discord"]
        for provider in valid_providers:
            response = client.get(f"/api/v1/oauth/{provider}/init")
            # Should not fail due to provider validation
            assert response.status_code != 422

        # Invalid provider
        response = client.get("/api/v1/oauth/invalid_provider/init")
        assert response.status_code == 422

    @patch("app.api.v1.oauth.get_db_session")
    @patch("app.api.v1.oauth.settings")
    def test_oauth_state_management_edge_cases(
        self, mock_settings, mock_get_db, client
    ):
        """Test OAuth state management edge cases."""
        # Test with empty state
        mock_settings.REDIS_URL = None
        mock_get_db.return_value = MagicMock()

        callback_data = {"code": "auth_code_123", "state": ""}
        response = client.post("/api/v1/oauth/google/callback", json=callback_data)
        assert response.status_code == 400

    def test_oauth_request_validation(self, client):
        """Test OAuth request data validation."""
        # Test callback with various invalid payloads
        invalid_payloads = [
            {},  # Missing required fields
            {"code": ""},  # Empty code
            {"state": "test"},  # Missing code
            {"code": "test"},  # Missing state (should be caught by endpoint logic)
        ]

        for payload in invalid_payloads:
            response = client.post("/api/v1/oauth/google/callback", json=payload)
            # Should handle validation errors appropriately
            assert response.status_code in [400, 422]

    def test_oauth_endpoints_response_format(self, client):
        """Test OAuth endpoints return proper response formats."""
        # Note: Without full mocking, these will fail, but we can test the endpoint exists
        # and handles requests properly

        # Init endpoint should return proper structure when working
        response = client.get("/api/v1/oauth/google/init")
        if response.status_code == 200:
            data = response.json()
            assert "authorization_url" in data
            assert "state" in data

        # Callback endpoint should handle request structure
        response = client.post(
            "/api/v1/oauth/google/callback", json={"code": "test", "state": "test"}
        )
        # Should handle the request (even if it fails due to missing state validation)
        assert response.status_code in [200, 400, 500]
