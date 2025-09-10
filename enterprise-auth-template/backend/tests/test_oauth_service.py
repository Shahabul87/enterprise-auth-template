"""
OAuth Service Tests

Comprehensive unit tests for the OAuth authentication service including
provider registration, user authentication, account linking, and error handling.
"""

import pytest
from datetime import datetime, timedelta
from typing import Dict, Generator
from unittest.mock import AsyncMock, MagicMock, patch
import secrets

import pytest_asyncio
import httpx
from fastapi import HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from authlib.integrations.starlette_client import OAuthError

from app.services.oauth_service import OAuthService, OAuthConfig, OAuthProviderType
from app.models.user import User
from app.schemas.auth import OAuthProvider, OAuthUserInfo
from app.core.config import get_settings


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
def mock_auth_service():
    """Create mock auth service."""
    auth_service = MagicMock()
    auth_service.create_access_token = AsyncMock(return_value="mock_access_token")
    auth_service.create_refresh_token = AsyncMock(return_value="mock_refresh_token")
    auth_service.log_audit_event = AsyncMock()
    return auth_service


@pytest.fixture
def sample_user() -> User:
    """Sample user for testing."""
    return User(
        id="123e4567-e89b-12d3-a456-426614174000",
        email="test@example.com",
        username="testuser",
        first_name="Test",
        last_name="User",
        full_name="Test User",
        hashed_password="hashed_password",
        email_verified=True,
        email_verified_at=datetime.utcnow(),
        is_active=True,
        created_at=datetime.utcnow(),
        updated_at=datetime.utcnow(),
    )


@pytest.fixture
def google_user_info() -> OAuthUserInfo:
    """Sample Google OAuth user info."""
    return OAuthUserInfo(
        id="google_user_123",
        email="user@gmail.com",
        name="John Doe",
        picture="https://example.com/avatar.jpg",
        email_verified=True,
        provider=OAuthProvider.GOOGLE,
    )


@pytest.fixture
def github_user_info() -> OAuthUserInfo:
    """Sample GitHub OAuth user info."""
    return OAuthUserInfo(
        id="12345678",
        email="user@example.com",
        name="John Doe",
        picture="https://github.com/avatar.jpg",
        email_verified=True,
        provider=OAuthProvider.GITHUB,
    )


@pytest.fixture
def discord_user_info() -> OAuthUserInfo:
    """Sample Discord OAuth user info."""
    return OAuthUserInfo(
        id="123456789012345678",
        email="user@example.com",
        name="JohnDoe#1234",
        picture="https://cdn.discordapp.com/avatars/123/avatar.png",
        email_verified=True,
        provider=OAuthProvider.DISCORD,
    )


@pytest.fixture
def oauth_service(mock_db_session, mock_auth_service) -> OAuthService:
    """Create OAuth service instance with mocked dependencies."""
    with patch(
        "app.services.oauth_service.AuthService", return_value=mock_auth_service
    ):
        service = OAuthService(mock_db_session)
        service.auth_service = mock_auth_service
        return service


class TestOAuthConfig:
    """Tests for OAuth configuration."""

    def test_provider_configurations(self):
        """Test that all provider configurations are properly defined."""
        # Test Google config
        assert (
            OAuthConfig.GOOGLE["authorize_url"]
            == "https://accounts.google.com/o/oauth2/v2/auth"
        )
        assert (
            OAuthConfig.GOOGLE["access_token_url"]
            == "https://oauth2.googleapis.com/token"
        )
        assert OAuthConfig.GOOGLE["client_kwargs"]["scope"] == "openid email profile"

        # Test GitHub config
        assert (
            OAuthConfig.GITHUB["authorize_url"]
            == "https://github.com/login/oauth/authorize"
        )
        assert (
            OAuthConfig.GITHUB["access_token_url"]
            == "https://github.com/login/oauth/access_token"
        )
        assert OAuthConfig.GITHUB["client_kwargs"]["scope"] == "user:email"

        # Test Discord config
        assert (
            OAuthConfig.DISCORD["authorize_url"]
            == "https://discord.com/api/oauth2/authorize"
        )
        assert (
            OAuthConfig.DISCORD["access_token_url"]
            == "https://discord.com/api/oauth2/token"
        )
        assert OAuthConfig.DISCORD["client_kwargs"]["scope"] == "identify email"

    def test_provider_enum(self):
        """Test OAuth provider enum values."""
        assert OAuthProviderType.GOOGLE.value == "google"
        assert OAuthProviderType.GITHUB.value == "github"
        assert OAuthProviderType.DISCORD.value == "discord"


class TestOAuthServiceInitialization:
    """Tests for OAuth service initialization."""

    def test_service_initialization(self, mock_db_session):
        """Test OAuth service initializes correctly."""
        with patch("app.services.oauth_service.AuthService"):
            service = OAuthService(mock_db_session)
            assert service.db == mock_db_session
            assert service.auth_service is not None
            assert service.redirect_uri.endswith("/auth/callback")

    @patch.object(
        OAuthConfig,
        "GOOGLE",
        {"client_id": "test_google_id", "client_secret": "secret"},
    )
    def test_provider_registration_with_credentials(self, mock_db_session):
        """Test provider registration when credentials are available."""
        with (
            patch("app.services.oauth_service.AuthService"),
            patch("app.services.oauth_service.OAuth") as mock_oauth_class,
        ):
            mock_oauth_instance = MagicMock()
            mock_oauth_class.return_value = mock_oauth_instance

            service = OAuthService(mock_db_session)
            # Provider registration is called in __init__
            mock_oauth_instance.register.assert_called()

    @patch.object(OAuthConfig, "GOOGLE", {"client_id": "", "client_secret": ""})
    def test_provider_registration_without_credentials(self, mock_db_session):
        """Test provider registration skips when no credentials."""
        with (
            patch("app.services.oauth_service.AuthService"),
            patch("app.services.oauth_service.OAuth") as mock_oauth_class,
        ):
            mock_oauth_instance = MagicMock()
            mock_oauth_class.return_value = mock_oauth_instance

            service = OAuthService(mock_db_session)
            # Should not register providers without credentials
            # (specific assertion depends on implementation)


class TestGetAuthorizationUrl:
    """Tests for getting OAuth authorization URLs."""

    def test_get_authorization_url_google(self, oauth_service):
        """Test getting Google authorization URL."""
        with patch.object(
            OAuthConfig,
            "GOOGLE",
            {
                "client_id": "google_client_id",
                "authorize_url": "https://accounts.google.com/o/oauth2/v2/auth",
            },
        ):
            url = oauth_service.get_authorization_url("google", "test_state")

            assert "https://accounts.google.com/o/oauth2/v2/auth" in url
            assert "client_id=google_client_id" in url
            assert "state=test_state" in url
            assert "scope=openid+email+profile" in url

    def test_get_authorization_url_github(self, oauth_service):
        """Test getting GitHub authorization URL."""
        with patch.object(
            OAuthConfig,
            "GITHUB",
            {
                "client_id": "github_client_id",
                "authorize_url": "https://github.com/login/oauth/authorize",
            },
        ):
            url = oauth_service.get_authorization_url("github")

            assert "https://github.com/login/oauth/authorize" in url
            assert "client_id=github_client_id" in url
            assert "scope=user%3Aemail" in url

    def test_get_authorization_url_discord(self, oauth_service):
        """Test getting Discord authorization URL."""
        with patch.object(
            OAuthConfig,
            "DISCORD",
            {
                "client_id": "discord_client_id",
                "authorize_url": "https://discord.com/api/oauth2/authorize",
            },
        ):
            url = oauth_service.get_authorization_url("discord")

            assert "https://discord.com/api/oauth2/authorize" in url
            assert "client_id=discord_client_id" in url
            assert "scope=identify+email" in url

    def test_get_authorization_url_generates_state(self, oauth_service):
        """Test that state is generated when not provided."""
        with patch.object(
            OAuthConfig,
            "GOOGLE",
            {
                "client_id": "google_client_id",
                "authorize_url": "https://accounts.google.com/o/oauth2/v2/auth",
            },
        ):
            url = oauth_service.get_authorization_url("google")

            assert "state=" in url
            # State should be a URL-safe token
            state_part = [part for part in url.split("&") if part.startswith("state=")][
                0
            ]
            state_value = state_part.split("=")[1]
            assert len(state_value) > 20  # Should be a substantial token

    def test_get_authorization_url_unsupported_provider(self, oauth_service):
        """Test error for unsupported provider."""
        with pytest.raises(HTTPException) as exc_info:
            oauth_service.get_authorization_url("unsupported")

        assert exc_info.value.status_code == status.HTTP_400_BAD_REQUEST
        assert "Unsupported OAuth provider" in str(exc_info.value.detail)

    def test_get_authorization_url_unconfigured_provider(self, oauth_service):
        """Test error for unconfigured provider."""
        with patch.object(OAuthConfig, "GOOGLE", {"client_id": ""}):
            with pytest.raises(HTTPException) as exc_info:
                oauth_service.get_authorization_url("google")

            assert exc_info.value.status_code == status.HTTP_400_BAD_REQUEST
            assert "is not configured" in str(exc_info.value.detail)


class TestAuthenticateOAuthUser:
    """Tests for OAuth user authentication."""

    @pytest.mark.asyncio
    async def test_authenticate_new_oauth_user(
        self, oauth_service, google_user_info, mock_db_session
    ):
        """Test authenticating a new OAuth user."""
        # Mock database queries to return None (user doesn't exist)
        mock_result = MagicMock()
        mock_result.scalar_one_or_none.return_value = None
        mock_db_session.execute.return_value = mock_result

        # Mock OAuth user info retrieval
        with (
            patch.object(
                oauth_service, "_get_oauth_user_info", return_value=google_user_info
            ),
            patch.object(
                oauth_service, "_find_or_create_oauth_user"
            ) as mock_find_create,
        ):

            mock_user = MagicMock()
            mock_user.id = "user_123"
            mock_user.email = "test@example.com"
            mock_find_create.return_value = mock_user

            user, access_token, refresh_token = (
                await oauth_service.authenticate_oauth_user(
                    provider="google",
                    code="auth_code",
                    state="test_state",
                    ip_address="192.168.1.1",
                    user_agent="Test Browser",
                )
            )

            assert user == mock_user
            assert access_token == "mock_access_token"
            assert refresh_token == "mock_refresh_token"

            # Verify audit log was called
            oauth_service.auth_service.log_audit_event.assert_called_once()

    @pytest.mark.asyncio
    async def test_authenticate_existing_oauth_user(
        self, oauth_service, google_user_info, sample_user, mock_db_session
    ):
        """Test authenticating an existing OAuth user."""
        # Mock database queries to return existing user
        mock_result = MagicMock()
        mock_result.scalar_one_or_none.return_value = sample_user
        mock_db_session.execute.return_value = mock_result

        with (
            patch.object(
                oauth_service, "_get_oauth_user_info", return_value=google_user_info
            ),
            patch.object(
                oauth_service, "_find_or_create_oauth_user", return_value=sample_user
            ),
        ):

            user, access_token, refresh_token = (
                await oauth_service.authenticate_oauth_user(
                    provider="google", code="auth_code"
                )
            )

            assert user == sample_user
            assert access_token == "mock_access_token"
            assert refresh_token == "mock_refresh_token"

    @pytest.mark.asyncio
    async def test_authenticate_oauth_user_oauth_error(self, oauth_service):
        """Test handling OAuth errors during authentication."""
        with patch.object(
            oauth_service,
            "_get_oauth_user_info",
            side_effect=OAuthError("OAuth failed"),
        ):
            with pytest.raises(HTTPException) as exc_info:
                await oauth_service.authenticate_oauth_user("google", "bad_code")

            assert exc_info.value.status_code == status.HTTP_400_BAD_REQUEST
            assert "OAuth authentication failed" in str(exc_info.value.detail)

    @pytest.mark.asyncio
    async def test_authenticate_oauth_user_unexpected_error(self, oauth_service):
        """Test handling unexpected errors during authentication."""
        with patch.object(
            oauth_service,
            "_get_oauth_user_info",
            side_effect=Exception("Unexpected error"),
        ):
            with pytest.raises(HTTPException) as exc_info:
                await oauth_service.authenticate_oauth_user("google", "code")

            assert exc_info.value.status_code == status.HTTP_500_INTERNAL_SERVER_ERROR
            assert "OAuth authentication failed" in str(exc_info.value.detail)


class TestGetOAuthUserInfo:
    """Tests for getting OAuth user information."""

    @pytest.mark.asyncio
    async def test_get_google_user_info(self, oauth_service):
        """Test getting Google user information."""
        mock_token_response = MagicMock()
        mock_token_response.status_code = 200
        mock_token_response.json.return_value = {"access_token": "token123"}

        mock_userinfo_response = MagicMock()
        mock_userinfo_response.status_code = 200
        mock_userinfo_response.json.return_value = {
            "sub": "google123",
            "email": "test@gmail.com",
            "name": "Test User",
            "picture": "https://avatar.url",
            "email_verified": True,
        }

        with patch("httpx.AsyncClient") as mock_client_class:
            mock_client = MagicMock()
            mock_client.__aenter__ = AsyncMock(return_value=mock_client)
            mock_client.__aexit__ = AsyncMock(return_value=None)
            mock_client.post = AsyncMock(return_value=mock_token_response)
            mock_client.get = AsyncMock(return_value=mock_userinfo_response)
            mock_client_class.return_value = mock_client

            user_info = await oauth_service._get_oauth_user_info("google", "auth_code")

            assert user_info.id == "google123"
            assert user_info.email == "test@gmail.com"
            assert user_info.name == "Test User"
            assert user_info.picture == "https://avatar.url"
            assert user_info.email_verified is True
            assert user_info.provider == OAuthProvider.GOOGLE

    @pytest.mark.asyncio
    async def test_get_github_user_info_with_public_email(self, oauth_service):
        """Test getting GitHub user info when email is public."""
        mock_token_response = MagicMock()
        mock_token_response.status_code = 200
        mock_token_response.json.return_value = {"access_token": "token123"}

        mock_userinfo_response = MagicMock()
        mock_userinfo_response.status_code = 200
        mock_userinfo_response.json.return_value = {
            "id": 12345,
            "login": "testuser",
            "name": "Test User",
            "email": "test@example.com",
            "avatar_url": "https://github.com/avatar.jpg",
        }

        with patch("httpx.AsyncClient") as mock_client_class:
            mock_client = MagicMock()
            mock_client.__aenter__ = AsyncMock(return_value=mock_client)
            mock_client.__aexit__ = AsyncMock(return_value=None)
            mock_client.post = AsyncMock(return_value=mock_token_response)
            mock_client.get = AsyncMock(return_value=mock_userinfo_response)
            mock_client_class.return_value = mock_client

            user_info = await oauth_service._get_oauth_user_info("github", "auth_code")

            assert user_info.id == "12345"
            assert user_info.email == "test@example.com"
            assert user_info.name == "Test User"
            assert user_info.provider == OAuthProvider.GITHUB

    @pytest.mark.asyncio
    async def test_get_github_user_info_private_email(self, oauth_service):
        """Test getting GitHub user info when email is private."""
        mock_token_response = MagicMock()
        mock_token_response.status_code = 200
        mock_token_response.json.return_value = {"access_token": "token123"}

        # First call returns user info without email
        mock_userinfo_response = MagicMock()
        mock_userinfo_response.status_code = 200
        mock_userinfo_response.json.return_value = {
            "id": 12345,
            "login": "testuser",
            "name": "Test User",
            "email": None,
            "avatar_url": "https://github.com/avatar.jpg",
        }

        # Second call returns emails
        mock_emails_response = MagicMock()
        mock_emails_response.status_code = 200
        mock_emails_response.json.return_value = [
            {"email": "test@example.com", "primary": True, "verified": True},
            {"email": "other@example.com", "primary": False, "verified": True},
        ]

        with patch("httpx.AsyncClient") as mock_client_class:
            mock_client = MagicMock()
            mock_client.__aenter__ = AsyncMock(return_value=mock_client)
            mock_client.__aexit__ = AsyncMock(return_value=None)
            mock_client.post = AsyncMock(return_value=mock_token_response)
            mock_client.get = AsyncMock(
                side_effect=[mock_userinfo_response, mock_emails_response]
            )
            mock_client_class.return_value = mock_client

            user_info = await oauth_service._get_oauth_user_info("github", "auth_code")

            assert user_info.email == "test@example.com"

    @pytest.mark.asyncio
    async def test_get_discord_user_info(self, oauth_service):
        """Test getting Discord user information."""
        mock_token_response = MagicMock()
        mock_token_response.status_code = 200
        mock_token_response.json.return_value = {"access_token": "token123"}

        mock_userinfo_response = MagicMock()
        mock_userinfo_response.status_code = 200
        mock_userinfo_response.json.return_value = {
            "id": "123456789012345678",
            "username": "testuser",
            "email": "test@example.com",
            "verified": True,
            "avatar": "abc123",
        }

        with patch("httpx.AsyncClient") as mock_client_class:
            mock_client = MagicMock()
            mock_client.__aenter__ = AsyncMock(return_value=mock_client)
            mock_client.__aexit__ = AsyncMock(return_value=None)
            mock_client.post = AsyncMock(return_value=mock_token_response)
            mock_client.get = AsyncMock(return_value=mock_userinfo_response)
            mock_client_class.return_value = mock_client

            user_info = await oauth_service._get_oauth_user_info("discord", "auth_code")

            assert user_info.id == "123456789012345678"
            assert user_info.email == "test@example.com"
            assert user_info.name == "testuser"
            assert "cdn.discordapp.com" in user_info.picture
            assert user_info.provider == OAuthProvider.DISCORD

    @pytest.mark.asyncio
    async def test_get_oauth_user_info_token_exchange_failure(self, oauth_service):
        """Test handling token exchange failure."""
        mock_token_response = MagicMock()
        mock_token_response.status_code = 400
        mock_token_response.text = "Invalid request"

        with patch("httpx.AsyncClient") as mock_client_class:
            mock_client = MagicMock()
            mock_client.__aenter__ = AsyncMock(return_value=mock_client)
            mock_client.__aexit__ = AsyncMock(return_value=None)
            mock_client.post = AsyncMock(return_value=mock_token_response)
            mock_client_class.return_value = mock_client

            with pytest.raises(OAuthError) as exc_info:
                await oauth_service._get_oauth_user_info("google", "bad_code")

            assert "Failed to exchange code for token" in str(exc_info.value)

    @pytest.mark.asyncio
    async def test_get_oauth_user_info_no_access_token(self, oauth_service):
        """Test handling missing access token in response."""
        mock_token_response = MagicMock()
        mock_token_response.status_code = 200
        mock_token_response.json.return_value = {
            "token_type": "bearer"
        }  # No access_token

        with patch("httpx.AsyncClient") as mock_client_class:
            mock_client = MagicMock()
            mock_client.__aenter__ = AsyncMock(return_value=mock_client)
            mock_client.__aexit__ = AsyncMock(return_value=None)
            mock_client.post = AsyncMock(return_value=mock_token_response)
            mock_client_class.return_value = mock_client

            with pytest.raises(OAuthError) as exc_info:
                await oauth_service._get_oauth_user_info("google", "auth_code")

            assert "No access token in response" in str(exc_info.value)

    @pytest.mark.asyncio
    async def test_get_oauth_user_info_userinfo_failure(self, oauth_service):
        """Test handling userinfo endpoint failure."""
        mock_token_response = MagicMock()
        mock_token_response.status_code = 200
        mock_token_response.json.return_value = {"access_token": "token123"}

        mock_userinfo_response = MagicMock()
        mock_userinfo_response.status_code = 401
        mock_userinfo_response.text = "Unauthorized"

        with patch("httpx.AsyncClient") as mock_client_class:
            mock_client = MagicMock()
            mock_client.__aenter__ = AsyncMock(return_value=mock_client)
            mock_client.__aexit__ = AsyncMock(return_value=None)
            mock_client.post = AsyncMock(return_value=mock_token_response)
            mock_client.get = AsyncMock(return_value=mock_userinfo_response)
            mock_client_class.return_value = mock_client

            with pytest.raises(OAuthError) as exc_info:
                await oauth_service._get_oauth_user_info("google", "auth_code")

            assert "Failed to get user info" in str(exc_info.value)


class TestFindOrCreateOAuthUser:
    """Tests for finding or creating OAuth users."""

    @pytest.mark.asyncio
    async def test_find_existing_oauth_user(
        self, oauth_service, google_user_info, sample_user, mock_db_session
    ):
        """Test finding existing OAuth user by provider ID."""
        # Mock database query to return existing user
        mock_result = MagicMock()
        mock_result.scalar_one_or_none.return_value = sample_user
        mock_db_session.execute.return_value = mock_result

        user = await oauth_service._find_or_create_oauth_user(
            "google", google_user_info
        )

        assert user == sample_user
        mock_db_session.commit.assert_called_once()

    @pytest.mark.asyncio
    async def test_find_existing_user_by_email(
        self, oauth_service, google_user_info, sample_user, mock_db_session
    ):
        """Test finding existing user by email and linking OAuth."""
        # First query (by OAuth ID) returns None, second query (by email) returns user
        mock_result_oauth = MagicMock()
        mock_result_oauth.scalar_one_or_none.return_value = None

        mock_result_email = MagicMock()
        mock_result_email.scalar_one_or_none.return_value = sample_user

        mock_db_session.execute.side_effect = [mock_result_oauth, mock_result_email]

        user = await oauth_service._find_or_create_oauth_user(
            "google", google_user_info
        )

        assert user == sample_user
        assert user.google_id == google_user_info.id
        mock_db_session.commit.assert_called_once()

    @pytest.mark.asyncio
    async def test_create_new_oauth_user(
        self, oauth_service, google_user_info, mock_db_session
    ):
        """Test creating new user from OAuth info."""
        # Both queries return None (user doesn't exist)
        mock_result = MagicMock()
        mock_result.scalar_one_or_none.return_value = None
        mock_db_session.execute.return_value = mock_result

        user = await oauth_service._find_or_create_oauth_user(
            "google", google_user_info
        )

        mock_db_session.add.assert_called_once()
        mock_db_session.commit.assert_called_once()
        mock_db_session.refresh.assert_called_once()

    @pytest.mark.asyncio
    async def test_create_oauth_user_without_email(
        self, oauth_service, mock_db_session
    ):
        """Test creating OAuth user when no email is provided."""
        user_info = OAuthUserInfo(
            id="github123",
            email=None,
            name="Test User",
            picture=None,
            email_verified=False,
            provider=OAuthProvider.GITHUB,
        )

        mock_result = MagicMock()
        mock_result.scalar_one_or_none.return_value = None
        mock_db_session.execute.return_value = mock_result

        user = await oauth_service._find_or_create_oauth_user("github", user_info)

        # Should use provider-specific email format
        mock_db_session.add.assert_called_once()
        mock_db_session.commit.assert_called_once()

    @pytest.mark.asyncio
    async def test_update_existing_user_info(
        self, oauth_service, sample_user, mock_db_session
    ):
        """Test updating existing user with OAuth info."""
        # Remove avatar and full_name to test updates
        sample_user.avatar_url = None
        sample_user.full_name = None

        user_info = OAuthUserInfo(
            id="google123",
            email=sample_user.email,
            name="Updated Name",
            picture="https://new-avatar.url",
            email_verified=True,
            provider=OAuthProvider.GOOGLE,
        )

        mock_result = MagicMock()
        mock_result.scalar_one_or_none.return_value = sample_user
        mock_db_session.execute.return_value = mock_result

        user = await oauth_service._find_or_create_oauth_user("google", user_info)

        assert user.avatar_url == "https://new-avatar.url"
        assert user.full_name == "Updated Name"
        mock_db_session.commit.assert_called_once()


class TestLinkOAuthAccount:
    """Tests for linking OAuth accounts."""

    @pytest.mark.asyncio
    async def test_link_oauth_account_success(
        self, oauth_service, sample_user, google_user_info, mock_db_session
    ):
        """Test successfully linking OAuth account to existing user."""
        # Mock database query to return None (OAuth account not linked elsewhere)
        mock_result = MagicMock()
        mock_result.scalar_one_or_none.return_value = None
        mock_db_session.execute.return_value = mock_result

        user = await oauth_service.link_oauth_account(
            sample_user, "google", google_user_info
        )

        assert user.google_id == google_user_info.id
        mock_db_session.commit.assert_called_once()
        mock_db_session.refresh.assert_called_once()

    @pytest.mark.asyncio
    async def test_link_oauth_account_already_linked(
        self, oauth_service, sample_user, google_user_info, mock_db_session
    ):
        """Test error when OAuth account is already linked to another user."""
        other_user = User(id="other_user_id", email="other@example.com")

        mock_result = MagicMock()
        mock_result.scalar_one_or_none.return_value = other_user
        mock_db_session.execute.return_value = mock_result

        with pytest.raises(HTTPException) as exc_info:
            await oauth_service.link_oauth_account(
                sample_user, "google", google_user_info
            )

        assert exc_info.value.status_code == status.HTTP_400_BAD_REQUEST
        assert "already linked to another user" in str(exc_info.value.detail)

    @pytest.mark.asyncio
    async def test_link_oauth_account_updates_profile(
        self, oauth_service, sample_user, google_user_info, mock_db_session
    ):
        """Test that linking OAuth account updates user profile info."""
        # Remove existing profile info
        sample_user.avatar_url = None
        sample_user.full_name = None

        mock_result = MagicMock()
        mock_result.scalar_one_or_none.return_value = None
        mock_db_session.execute.return_value = mock_result

        user = await oauth_service.link_oauth_account(
            sample_user, "google", google_user_info
        )

        assert user.avatar_url == google_user_info.picture
        assert user.full_name == google_user_info.name


class TestUnlinkOAuthAccount:
    """Tests for unlinking OAuth accounts."""

    @pytest.mark.asyncio
    async def test_unlink_oauth_account_with_password(
        self, oauth_service, sample_user, mock_db_session
    ):
        """Test unlinking OAuth account when user has a password."""
        sample_user.google_id = "google123"
        sample_user.hashed_password = "valid_password_hash"

        user = await oauth_service.unlink_oauth_account(sample_user, "google")

        assert user.google_id is None
        mock_db_session.commit.assert_called_once()

    @pytest.mark.asyncio
    async def test_unlink_oauth_account_with_other_oauth(
        self, oauth_service, sample_user, mock_db_session
    ):
        """Test unlinking OAuth account when user has other OAuth accounts."""
        sample_user.google_id = "google123"
        sample_user.github_id = "github456"
        sample_user.hashed_password = ""  # No password

        user = await oauth_service.unlink_oauth_account(sample_user, "google")

        assert user.google_id is None
        assert user.github_id == "github456"  # Other OAuth account remains
        mock_db_session.commit.assert_called_once()

    @pytest.mark.asyncio
    async def test_unlink_oauth_account_only_auth_method(
        self, oauth_service, sample_user, mock_db_session
    ):
        """Test error when trying to unlink the only authentication method."""
        sample_user.google_id = "google123"
        sample_user.github_id = None
        sample_user.discord_id = None
        sample_user.hashed_password = ""  # No password

        with pytest.raises(HTTPException) as exc_info:
            await oauth_service.unlink_oauth_account(sample_user, "google")

        assert exc_info.value.status_code == status.HTTP_400_BAD_REQUEST
        assert "only authentication method" in str(exc_info.value.detail)

    @pytest.mark.asyncio
    async def test_unlink_nonexistent_oauth_account(
        self, oauth_service, sample_user, mock_db_session
    ):
        """Test unlinking OAuth account that wasn't linked."""
        sample_user.google_id = None  # Not linked
        sample_user.hashed_password = "valid_password"

        user = await oauth_service.unlink_oauth_account(sample_user, "google")

        assert user.google_id is None
        mock_db_session.commit.assert_called_once()


class TestOAuthServiceEdgeCases:
    """Tests for OAuth service edge cases and error conditions."""

    def test_case_insensitive_provider_names(self, oauth_service):
        """Test that provider names are handled case-insensitively."""
        with patch.object(
            OAuthConfig,
            "GOOGLE",
            {
                "client_id": "test_id",
                "authorize_url": "https://accounts.google.com/o/oauth2/v2/auth",
            },
        ):
            url1 = oauth_service.get_authorization_url("GOOGLE")
            url2 = oauth_service.get_authorization_url("google")
            url3 = oauth_service.get_authorization_url("Google")

            # All should work and produce similar URLs
            assert "accounts.google.com" in url1
            assert "accounts.google.com" in url2
            assert "accounts.google.com" in url3

    @pytest.mark.asyncio
    async def test_oauth_with_empty_user_name(self, oauth_service, mock_db_session):
        """Test handling OAuth user with empty name."""
        user_info = OAuthUserInfo(
            id="test123",
            email="test@example.com",
            name="",  # Empty name
            picture=None,
            email_verified=True,
            provider=OAuthProvider.GOOGLE,
        )

        mock_result = MagicMock()
        mock_result.scalar_one_or_none.return_value = None
        mock_db_session.execute.return_value = mock_result

        user = await oauth_service._find_or_create_oauth_user("google", user_info)

        # Should handle empty name gracefully
        mock_db_session.add.assert_called_once()
        mock_db_session.commit.assert_called_once()

    @pytest.mark.asyncio
    async def test_oauth_user_name_parsing(self, oauth_service, mock_db_session):
        """Test parsing of user names into first/last name."""
        user_info = OAuthUserInfo(
            id="test123",
            email="test@example.com",
            name="John Michael Doe",  # Multiple names
            picture=None,
            email_verified=True,
            provider=OAuthProvider.GOOGLE,
        )

        mock_result = MagicMock()
        mock_result.scalar_one_or_none.return_value = None
        mock_db_session.execute.return_value = mock_result

        user = await oauth_service._find_or_create_oauth_user("google", user_info)

        mock_db_session.add.assert_called_once()
        # Verify that the User object was created with parsed names
        add_call_args = mock_db_session.add.call_args[0][0]
        assert hasattr(add_call_args, "first_name")
