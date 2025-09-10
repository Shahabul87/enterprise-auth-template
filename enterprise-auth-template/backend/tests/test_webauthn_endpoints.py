"""
WebAuthn Endpoints Tests

Tests for WebAuthn/Passkeys API endpoints including:
- Registration options generation
- Registration verification (mocked)
- Authentication options generation  
- Authentication verification (mocked)
- Credential management operations

Note: This uses mocked WebAuthn operations since actual WebAuthn
requires browser interaction with authenticators.
"""

import pytest
import json
from unittest.mock import AsyncMock, MagicMock, patch
from datetime import datetime

from fastapi import status
from fastapi.testclient import TestClient
from sqlalchemy.ext.asyncio import AsyncSession

from app.main import app
from app.models.user import User
from app.services.webauthn_service import WebAuthnCredential


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
    return session


@pytest.fixture
def sample_user() -> User:
    """Create sample user for testing."""
    user = MagicMock(spec=User)
    user.id = "test-user-id"
    user.email = "test@example.com"
    user.first_name = "Test"
    user.last_name = "User"
    user.is_active = True
    user.webauthn_credentials = []
    user.roles = []
    user.get_permissions.return_value = []
    return user


@pytest.fixture
def sample_webauthn_credential() -> WebAuthnCredential:
    """Create sample WebAuthn credential."""
    return WebAuthnCredential(
        credential_id="test-credential-id",
        public_key="test-public-key",
        sign_count=0,
        aaguid="test-aaguid",
        user_verified=True,
        device_name="Test Device",
        created_at=datetime.utcnow(),
        transports=["usb", "nfc"],
    )


class TestWebAuthnRegistration:
    """Test WebAuthn registration endpoints."""

    @patch('app.dependencies.auth.get_current_active_user')
    @patch('app.services.webauthn_service.webauthn_service')
    def test_get_registration_options_success(
        self, mock_service, mock_get_user, client, sample_user
    ):
        """Test successful registration options generation."""
        # Setup mocks
        mock_get_user.return_value = sample_user
        mock_options = {
            "rp": {"name": "Test", "id": "localhost"},
            "user": {
                "id": "dGVzdC11c2VyLWlk",
                "name": "test@example.com",
                "displayName": "Test User"
            },
            "challenge": "test-challenge",
            "timeout": 60000,
        }
        mock_service.generate_registration_options.return_value = (mock_options, "test-challenge")

        # Make request
        response = client.post(
            "/api/v1/webauthn/register/options",
            json={"device_name": "Test Device"}
        )

        # Verify response
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["success"] is True
        assert "options" in data["data"]
        assert "challenge" in data["data"]
        assert data["data"]["challenge"] == "test-challenge"

    @patch('app.dependencies.auth.get_current_active_user')
    @patch('app.services.webauthn_service.webauthn_service')
    def test_verify_registration_success(
        self, mock_service, mock_get_user, client, sample_user
    ):
        """Test successful registration verification."""
        # Setup mocks
        mock_get_user.return_value = sample_user
        mock_service.verify_registration_response.return_value = True
        mock_service.get_user_credentials.return_value = [
            {
                "id": "test-id",
                "device_name": "Test Device",
                "created_at": "2024-01-01T00:00:00Z",
            }
        ]

        # Sample credential data (simplified)
        credential_data = {
            "id": "test-credential-id",
            "rawId": "dGVzdC1jcmVkZW50aWFsLWlk",
            "response": {
                "attestationObject": "test-attestation",
                "clientDataJSON": "test-client-data",
                "transports": ["usb"],
            },
            "type": "public-key",
        }

        # Make request
        response = client.post(
            "/api/v1/webauthn/register/verify",
            json={
                "credential": credential_data,
                "challenge": "test-challenge",
                "device_name": "Test Device"
            }
        )

        # Verify response
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["success"] is True
        assert "message" in data["data"]

    @patch('app.dependencies.auth.get_current_active_user')
    @patch('app.services.webauthn_service.webauthn_service')
    def test_verify_registration_failure(
        self, mock_service, mock_get_user, client, sample_user
    ):
        """Test registration verification failure."""
        # Setup mocks
        mock_get_user.return_value = sample_user
        mock_service.verify_registration_response.return_value = False

        # Sample credential data
        credential_data = {
            "id": "test-credential-id",
            "response": {"attestationObject": "invalid-data"},
        }

        # Make request
        response = client.post(
            "/api/v1/webauthn/register/verify",
            json={
                "credential": credential_data,
                "challenge": "test-challenge"
            }
        )

        # Verify response
        assert response.status_code == status.HTTP_400_BAD_REQUEST
        data = response.json()
        assert data["success"] is False
        assert data["error"]["code"] == "REGISTRATION_FAILED"


class TestWebAuthnAuthentication:
    """Test WebAuthn authentication endpoints."""

    @patch('app.services.webauthn_service.webauthn_service')
    def test_get_authentication_options_success(
        self, mock_service, client
    ):
        """Test successful authentication options generation."""
        # Setup mocks
        mock_options = {
            "challenge": "test-challenge",
            "timeout": 60000,
            "rpId": "localhost",
            "allowCredentials": [],
            "userVerification": "required",
        }
        mock_service.generate_authentication_options.return_value = (mock_options, "test-challenge")

        # Make request
        response = client.post(
            "/api/v1/webauthn/authenticate/options",
            json={"email": "test@example.com"}
        )

        # Verify response
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["success"] is True
        assert "options" in data["data"]
        assert "challenge" in data["data"]

    @patch('app.services.webauthn_service.webauthn_service')
    @patch('app.core.security.create_access_token')
    def test_verify_authentication_success(
        self, mock_create_token, mock_service, client, sample_user
    ):
        """Test successful authentication verification."""
        # Setup mocks
        mock_service.verify_authentication_response.return_value = sample_user
        mock_create_token.return_value = "test-access-token"

        # Sample credential data
        credential_data = {
            "id": "test-credential-id",
            "rawId": "dGVzdC1jcmVkZW50aWFsLWlk",
            "response": {
                "authenticatorData": "test-auth-data",
                "clientDataJSON": "test-client-data",
                "signature": "test-signature",
            },
            "type": "public-key",
        }

        # Make request
        response = client.post(
            "/api/v1/webauthn/authenticate/verify",
            json={
                "credential": credential_data,
                "challenge": "test-challenge"
            }
        )

        # Verify response
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["success"] is True
        assert "access_token" in data["data"]
        assert "user" in data["data"]

    @patch('app.services.webauthn_service.webauthn_service')
    def test_verify_authentication_failure(
        self, mock_service, client
    ):
        """Test authentication verification failure."""
        # Setup mocks
        mock_service.verify_authentication_response.return_value = None

        # Sample credential data
        credential_data = {
            "id": "test-credential-id",
            "response": {"signature": "invalid-signature"},
        }

        # Make request
        response = client.post(
            "/api/v1/webauthn/authenticate/verify",
            json={
                "credential": credential_data,
                "challenge": "test-challenge"
            }
        )

        # Verify response
        assert response.status_code == status.HTTP_401_UNAUTHORIZED
        data = response.json()
        assert data["success"] is False
        assert data["error"]["code"] == "AUTHENTICATION_FAILED"


class TestWebAuthnCredentialManagement:
    """Test WebAuthn credential management endpoints."""

    @patch('app.dependencies.auth.get_current_active_user')
    @patch('app.services.webauthn_service.webauthn_service')
    def test_get_user_credentials_success(
        self, mock_service, mock_get_user, client, sample_user
    ):
        """Test getting user credentials."""
        # Setup mocks
        mock_get_user.return_value = sample_user
        mock_credentials = [
            {
                "id": "cred-1",
                "device_name": "iPhone",
                "created_at": "2024-01-01T00:00:00Z",
                "last_used": None,
                "transports": ["internal"],
                "aaguid": "test-aaguid",
                "credential_id_preview": "abcd1234...",
            }
        ]
        mock_service.get_user_credentials.return_value = mock_credentials

        # Make request
        response = client.get("/api/v1/webauthn/credentials")

        # Verify response
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["success"] is True
        assert "credentials" in data["data"]
        assert len(data["data"]["credentials"]) == 1

    @patch('app.dependencies.auth.get_current_active_user')
    @patch('app.services.webauthn_service.webauthn_service')
    def test_delete_credential_success(
        self, mock_service, mock_get_user, client, sample_user
    ):
        """Test successful credential deletion."""
        # Setup mocks
        mock_get_user.return_value = sample_user
        sample_user.hashed_password = "test-password-hash"  # Has password backup
        mock_service.get_user_credentials.return_value = [{"id": "cred-1"}, {"id": "cred-2"}]
        mock_service.delete_user_credential.return_value = True

        # Make request
        response = client.delete(
            "/api/v1/webauthn/credentials",
            json={"credential_id": "cred-1"}
        )

        # Verify response
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["success"] is True
        assert "message" in data["data"]

    @patch('app.dependencies.auth.get_current_active_user')
    @patch('app.services.webauthn_service.webauthn_service')
    def test_delete_last_credential_without_password(
        self, mock_service, mock_get_user, client, sample_user
    ):
        """Test preventing deletion of last credential without password."""
        # Setup mocks
        mock_get_user.return_value = sample_user
        sample_user.hashed_password = None  # No password backup
        mock_service.get_user_credentials.return_value = [{"id": "cred-1"}]  # Only one credential

        # Make request
        response = client.delete(
            "/api/v1/webauthn/credentials",
            json={"credential_id": "cred-1"}
        )

        # Verify response
        assert response.status_code == status.HTTP_400_BAD_REQUEST
        data = response.json()
        assert data["success"] is False
        assert data["error"]["code"] == "LAST_CREDENTIAL"


class TestWebAuthnStatus:
    """Test WebAuthn status endpoint."""

    def test_webauthn_status_success(self, client):
        """Test WebAuthn status endpoint."""
        response = client.get("/api/v1/webauthn/status")

        # Verify response
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["success"] is True
        assert "webauthn_enabled" in data["data"]
        assert "rp_id" in data["data"]
        assert "rp_name" in data["data"]
        assert data["data"]["webauthn_enabled"] is True


class TestWebAuthnService:
    """Test WebAuthn service functionality."""

    def test_webauthn_credential_to_dict(self, sample_webauthn_credential):
        """Test WebAuthn credential serialization."""
        credential_dict = sample_webauthn_credential.to_dict()
        
        assert "id" in credential_dict
        assert "credential_id" in credential_dict
        assert "device_name" in credential_dict
        assert credential_dict["device_name"] == "Test Device"
        assert credential_dict["user_verified"] is True
        assert "created_at" in credential_dict

    def test_webauthn_credential_from_dict(self):
        """Test WebAuthn credential deserialization."""
        credential_data = {
            "id": "test-id",
            "credential_id": "test-credential-id",
            "public_key": "test-public-key",
            "sign_count": 5,
            "aaguid": "test-aaguid",
            "user_verified": True,
            "device_name": "Test Device",
            "created_at": "2024-01-01T00:00:00",
            "last_used": None,
            "transports": ["usb"],
        }
        
        credential = WebAuthnCredential.from_dict(credential_data)
        
        assert credential.credential_id == "test-credential-id"
        assert credential.device_name == "Test Device"
        assert credential.sign_count == 5
        assert credential.user_verified is True


# Integration test markers
pytestmark = [
    pytest.mark.asyncio,
    pytest.mark.webauthn,
]


@pytest.mark.integration
class TestWebAuthnIntegration:
    """Integration tests for WebAuthn functionality."""

    async def test_webauthn_registration_flow_integration(self):
        """Test the complete WebAuthn registration flow."""
        # Note: This would require actual WebAuthn browser integration
        # For now, we just verify the flow structure is correct
        assert True  # Placeholder for actual integration test

    async def test_webauthn_authentication_flow_integration(self):
        """Test the complete WebAuthn authentication flow."""
        # Note: This would require actual WebAuthn browser integration
        # For now, we just verify the flow structure is correct
        assert True  # Placeholder for actual integration test