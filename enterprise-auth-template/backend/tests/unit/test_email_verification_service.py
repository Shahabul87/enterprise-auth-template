"""
Unit tests for EmailVerificationService

Tests email verification token generation, validation, and verification flow.
"""

import pytest
from unittest.mock import AsyncMock, MagicMock, patch
from datetime import datetime, timedelta
from uuid import uuid4
import secrets

from app.services.auth.email_verification_service import (
    EmailVerificationService,
    EmailVerificationError,
)
from app.domain.user_domain import UserDomain


class TestEmailVerificationService:
    """Test cases for EmailVerificationService."""

    @pytest.fixture
    def mock_session(self):
        """Create a mock database session."""
        session = AsyncMock()
        session.commit = AsyncMock()
        session.rollback = AsyncMock()
        session.refresh = AsyncMock()
        return session

    @pytest.fixture
    def mock_user_repo(self):
        """Create a mock user repository."""
        repo = AsyncMock()
        repo.get_by_email = AsyncMock()
        repo.get_by_id = AsyncMock()
        repo.update = AsyncMock()
        return repo

    @pytest.fixture
    def mock_unverified_user(self):
        """Create a mock unverified user."""
        user = MagicMock(spec=UserDomain)
        user.id = uuid4()
        user.email = "unverified@example.com"
        user.first_name = "Unverified"
        user.last_name = "User"
        user.is_active = True
        user.is_verified = False
        user.verify_email = MagicMock()
        user.created_at = datetime.utcnow()
        return user

    @pytest.fixture
    def mock_verified_user(self):
        """Create a mock verified user."""
        user = MagicMock(spec=UserDomain)
        user.id = uuid4()
        user.email = "verified@example.com"
        user.first_name = "Verified"
        user.last_name = "User"
        user.is_active = True
        user.is_verified = True
        user.verified_at = datetime.utcnow()
        return user

    @pytest.fixture
    def email_service(self, mock_session, mock_user_repo):
        """Create an EmailVerificationService instance."""
        return EmailVerificationService(mock_session, mock_user_repo)

    @pytest.mark.asyncio
    async def test_create_verification_token_success(self, email_service, mock_user_repo, mock_unverified_user):
        """Test successful verification token creation."""
        # Arrange
        user_id = mock_unverified_user.id
        mock_user_repo.get_by_id.return_value = mock_unverified_user

        # Act
        token = await email_service.create_verification_token(str(user_id))

        # Assert
        assert token is not None
        assert len(token) > 20
        mock_user_repo.get_by_id.assert_called_once_with(str(user_id))

    @pytest.mark.asyncio
    async def test_create_verification_token_already_verified(self, email_service, mock_user_repo, mock_verified_user):
        """Test token creation for already verified user."""
        # Arrange
        user_id = mock_verified_user.id
        mock_user_repo.get_by_id.return_value = mock_verified_user

        # Act & Assert
        with pytest.raises(EmailVerificationError, match="already verified"):
            await email_service.create_verification_token(str(user_id))

    @pytest.mark.asyncio
    async def test_create_verification_token_user_not_found(self, email_service, mock_user_repo):
        """Test token creation for non-existent user."""
        # Arrange
        user_id = str(uuid4())
        mock_user_repo.get_by_id.return_value = None

        # Act & Assert
        with pytest.raises(EmailVerificationError, match="User not found"):
            await email_service.create_verification_token(user_id)

    @pytest.mark.asyncio
    async def test_verify_email_success(self, email_service, mock_user_repo, mock_unverified_user):
        """Test successful email verification."""
        # Arrange
        verification_token = secrets.token_urlsafe(32)
        user_id = mock_unverified_user.id

        with patch.object(email_service, 'validate_token', new_callable=AsyncMock) as mock_validate:
            mock_validate.return_value = str(user_id)
            mock_user_repo.get_by_id.return_value = mock_unverified_user

            # Act
            result = await email_service.verify_email(
                verification_token=verification_token,
                ip_address="127.0.0.1",
                user_agent="Test Browser",
            )

            # Assert
            assert result is True
            mock_validate.assert_called_once_with(verification_token)
            mock_unverified_user.verify_email.assert_called_once()
            mock_user_repo.update.assert_called_once_with(mock_unverified_user)

    @pytest.mark.asyncio
    async def test_verify_email_invalid_token(self, email_service):
        """Test email verification with invalid token."""
        # Arrange
        invalid_token = "invalid_token"

        with patch.object(email_service, 'validate_token', new_callable=AsyncMock) as mock_validate:
            mock_validate.return_value = None

            # Act & Assert
            with pytest.raises(EmailVerificationError, match="Invalid or expired verification token"):
                await email_service.verify_email(
                    verification_token=invalid_token,
                    ip_address="127.0.0.1",
                )

    @pytest.mark.asyncio
    async def test_verify_email_already_verified(self, email_service, mock_user_repo, mock_verified_user):
        """Test email verification for already verified user."""
        # Arrange
        verification_token = secrets.token_urlsafe(32)
        user_id = mock_verified_user.id

        with patch.object(email_service, 'validate_token', new_callable=AsyncMock) as mock_validate:
            mock_validate.return_value = str(user_id)
            mock_user_repo.get_by_id.return_value = mock_verified_user

            # Act & Assert
            with pytest.raises(EmailVerificationError, match="already verified"):
                await email_service.verify_email(
                    verification_token=verification_token,
                    ip_address="127.0.0.1",
                )

    @pytest.mark.asyncio
    async def test_verify_email_user_not_found(self, email_service, mock_user_repo):
        """Test email verification when user no longer exists."""
        # Arrange
        verification_token = secrets.token_urlsafe(32)
        user_id = str(uuid4())

        with patch.object(email_service, 'validate_token', new_callable=AsyncMock) as mock_validate:
            mock_validate.return_value = user_id
            mock_user_repo.get_by_id.return_value = None

            # Act & Assert
            with pytest.raises(EmailVerificationError, match="User not found"):
                await email_service.verify_email(
                    verification_token=verification_token,
                    ip_address="127.0.0.1",
                )

    @pytest.mark.asyncio
    async def test_resend_verification_email_success(self, email_service, mock_user_repo, mock_unverified_user):
        """Test successful verification email resend."""
        # Arrange
        email = mock_unverified_user.email
        mock_user_repo.get_by_email.return_value = mock_unverified_user

        with patch.object(email_service, '_send_verification_email', new_callable=AsyncMock) as mock_send:
            # Act
            result = await email_service.resend_verification_email(
                email=email,
                ip_address="127.0.0.1",
                user_agent="Test Browser",
            )

            # Assert
            assert result is True
            mock_user_repo.get_by_email.assert_called_once_with(email)
            mock_send.assert_called_once()

    @pytest.mark.asyncio
    async def test_resend_verification_email_already_verified(self, email_service, mock_user_repo, mock_verified_user):
        """Test resend for already verified user."""
        # Arrange
        email = mock_verified_user.email
        mock_user_repo.get_by_email.return_value = mock_verified_user

        # Act
        result = await email_service.resend_verification_email(
            email=email,
            ip_address="127.0.0.1",
        )

        # Assert
        assert result is False  # Should return False for already verified
        mock_user_repo.get_by_email.assert_called_once_with(email)

    @pytest.mark.asyncio
    async def test_resend_verification_email_user_not_found(self, email_service, mock_user_repo):
        """Test resend for non-existent user."""
        # Arrange
        email = "nonexistent@example.com"
        mock_user_repo.get_by_email.return_value = None

        # Act
        result = await email_service.resend_verification_email(
            email=email,
            ip_address="127.0.0.1",
        )

        # Assert
        assert result is False  # Should silently fail for security
        mock_user_repo.get_by_email.assert_called_once_with(email)

    @pytest.mark.asyncio
    async def test_resend_verification_email_rate_limiting(self, email_service, mock_user_repo, mock_unverified_user):
        """Test rate limiting for verification email resends."""
        # Arrange
        email = mock_unverified_user.email
        mock_user_repo.get_by_email.return_value = mock_unverified_user

        # Mock rate limiting
        with patch.object(email_service, '_check_rate_limit', return_value=False) as mock_rate:
            # Act & Assert
            with pytest.raises(EmailVerificationError, match="Rate limit exceeded"):
                await email_service.resend_verification_email(
                    email=email,
                    ip_address="127.0.0.1",
                )

            mock_rate.assert_called_once()

    @pytest.mark.asyncio
    async def test_validate_token_expired(self, email_service):
        """Test validation of expired verification token."""
        # Arrange
        expired_token = "expired_token"

        with patch.object(email_service, '_get_token_data', new_callable=AsyncMock) as mock_get:
            mock_get.return_value = {
                "user_id": str(uuid4()),
                "expires_at": datetime.utcnow() - timedelta(hours=1),
                "type": "email_verification",
            }

            # Act
            result = await email_service.validate_token(expired_token)

            # Assert
            assert result is None  # Expired token

    @pytest.mark.asyncio
    async def test_validate_token_valid(self, email_service):
        """Test validation of valid verification token."""
        # Arrange
        valid_token = "valid_token"
        user_id = uuid4()

        with patch.object(email_service, '_get_token_data', new_callable=AsyncMock) as mock_get:
            mock_get.return_value = {
                "user_id": str(user_id),
                "expires_at": datetime.utcnow() + timedelta(hours=1),
                "type": "email_verification",
            }

            # Act
            result = await email_service.validate_token(valid_token)

            # Assert
            assert result == str(user_id)

    @pytest.mark.asyncio
    async def test_validate_token_wrong_type(self, email_service):
        """Test validation of token with wrong type."""
        # Arrange
        wrong_type_token = "wrong_type_token"

        with patch.object(email_service, '_get_token_data', new_callable=AsyncMock) as mock_get:
            mock_get.return_value = {
                "user_id": str(uuid4()),
                "expires_at": datetime.utcnow() + timedelta(hours=1),
                "type": "password_reset",  # Wrong type
            }

            # Act
            result = await email_service.validate_token(wrong_type_token)

            # Assert
            assert result is None  # Wrong token type

    @pytest.mark.asyncio
    async def test_cleanup_expired_tokens(self, email_service):
        """Test cleanup of expired verification tokens."""
        # Arrange
        with patch.object(email_service, '_delete_expired_tokens', new_callable=AsyncMock) as mock_delete:
            mock_delete.return_value = 5  # Number of deleted tokens

            # Act
            deleted_count = await email_service.cleanup_expired_tokens()

            # Assert
            assert deleted_count == 5
            mock_delete.assert_called_once()

    @pytest.mark.asyncio
    async def test_verification_with_auto_activation(self, email_service, mock_user_repo, mock_unverified_user):
        """Test email verification with automatic account activation."""
        # Arrange
        verification_token = secrets.token_urlsafe(32)
        user_id = mock_unverified_user.id
        mock_unverified_user.is_active = False  # Inactive account

        with patch.object(email_service, 'validate_token', new_callable=AsyncMock) as mock_validate:
            mock_validate.return_value = str(user_id)
            mock_user_repo.get_by_id.return_value = mock_unverified_user

            # Act
            result = await email_service.verify_email(
                verification_token=verification_token,
                ip_address="127.0.0.1",
                auto_activate=True,
            )

            # Assert
            assert result is True
            mock_unverified_user.verify_email.assert_called_once()
            assert mock_unverified_user.is_active is True  # Should be activated

    @pytest.mark.asyncio
    async def test_verification_token_single_use(self, email_service, mock_user_repo, mock_unverified_user):
        """Test that verification tokens can only be used once."""
        # Arrange
        verification_token = secrets.token_urlsafe(32)
        user_id = mock_unverified_user.id

        with patch.object(email_service, 'validate_token', new_callable=AsyncMock) as mock_validate:
            with patch.object(email_service, '_invalidate_token', new_callable=AsyncMock) as mock_invalidate:
                mock_validate.return_value = str(user_id)
                mock_user_repo.get_by_id.return_value = mock_unverified_user

                # Act
                await email_service.verify_email(
                    verification_token=verification_token,
                    ip_address="127.0.0.1",
                )

                # Assert
                mock_invalidate.assert_called_once_with(verification_token)

    @pytest.mark.asyncio
    async def test_verification_audit_logging(self, email_service, mock_user_repo, mock_unverified_user):
        """Test that email verification creates audit log entries."""
        # Arrange
        verification_token = secrets.token_urlsafe(32)
        user_id = mock_unverified_user.id
        ip_address = "192.168.1.1"
        user_agent = "Mozilla/5.0"

        with patch.object(email_service, 'validate_token', new_callable=AsyncMock) as mock_validate:
            with patch.object(email_service, '_create_audit_log', new_callable=AsyncMock) as mock_audit:
                mock_validate.return_value = str(user_id)
                mock_user_repo.get_by_id.return_value = mock_unverified_user

                # Act
                await email_service.verify_email(
                    verification_token=verification_token,
                    ip_address=ip_address,
                    user_agent=user_agent,
                )

                # Assert
                mock_audit.assert_called_once()
                audit_call_args = mock_audit.call_args[1]
                assert audit_call_args["user_id"] == str(user_id)
                assert audit_call_args["action"] == "email_verified"
                assert audit_call_args["ip_address"] == ip_address