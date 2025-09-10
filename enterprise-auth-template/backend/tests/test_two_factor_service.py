"""
Two-Factor Authentication Service Tests

Comprehensive unit tests for the 2FA service including TOTP setup,
verification, backup codes, and security mechanisms.
"""

import pytest
import json
import base64
import secrets
from datetime import datetime, timedelta
from typing import Dict, List
from unittest.mock import AsyncMock, MagicMock, patch, Mock
from io import BytesIO

import pytest_asyncio
import pyotp
import qrcode
from cryptography.fernet import Fernet
from sqlalchemy.ext.asyncio import AsyncSession

from app.services.two_factor_service import TwoFactorService, TwoFactorError
from app.models.user import User
from app.core.security import get_password_hash, verify_password


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
def mock_settings():
    """Mock settings with encryption key."""
    settings = MagicMock()
    settings.ENCRYPTION_KEY = Fernet.generate_key().decode()
    settings.ENVIRONMENT = "development"
    return settings


@pytest.fixture
def sample_user() -> User:
    """Create a sample user for testing."""
    return User(
        id="123e4567-e89b-12d3-a456-426614174000",
        email="test@example.com",
        username="testuser",
        first_name="Test",
        last_name="User",
        hashed_password=get_password_hash("password123"),
        email_verified=True,
        is_active=True,
        two_factor_enabled=False,
        totp_secret=None,
        backup_codes=None,
        two_factor_recovery_codes_used=0,
        failed_2fa_attempts=0,
        two_factor_verified_at=None,
        created_at=datetime.utcnow(),
        updated_at=datetime.utcnow(),
    )


@pytest.fixture
def user_with_2fa_enabled(sample_user) -> User:
    """Create a user with 2FA already enabled."""
    sample_user.two_factor_enabled = True
    sample_user.totp_secret = "JBSWY3DPEHPK3PXP"
    sample_user.two_factor_verified_at = datetime.utcnow()
    return sample_user


@pytest.fixture
def mock_cipher():
    """Create a mock Fernet cipher."""
    key = Fernet.generate_key()
    return Fernet(key)


@pytest.fixture
def two_factor_service(mock_db_session, mock_settings, mock_cipher):
    """Create TwoFactorService instance with mocked dependencies."""
    with (
        patch(
            "app.services.two_factor_service.get_settings", return_value=mock_settings
        ),
        patch("app.services.two_factor_service.Fernet", return_value=mock_cipher),
    ):
        service = TwoFactorService(mock_db_session)
        service.cipher = mock_cipher
        return service


class TestTwoFactorServiceInitialization:
    """Tests for TwoFactorService initialization."""

    def test_initialization_with_encryption_key(self, mock_db_session, mock_settings):
        """Test service initialization with proper encryption key."""
        with patch(
            "app.services.two_factor_service.get_settings", return_value=mock_settings
        ):
            service = TwoFactorService(mock_db_session)

            assert service.db == mock_db_session
            assert service.cipher is not None
            assert service.TOTP_ISSUER == "Enterprise Auth"
            assert service.BACKUP_CODES_COUNT == 10
            assert service.MAX_2FA_ATTEMPTS == 5

    def test_initialization_without_encryption_key_development(self, mock_db_session):
        """Test service initialization without encryption key in development."""
        mock_settings = MagicMock()
        mock_settings.ENCRYPTION_KEY = None
        mock_settings.ENVIRONMENT = "development"

        with (
            patch(
                "app.services.two_factor_service.get_settings",
                return_value=mock_settings,
            ),
            patch("app.services.two_factor_service.Fernet") as mock_fernet_class,
        ):

            mock_fernet_instance = MagicMock()
            mock_fernet_class.generate_key.return_value = b"test-key"
            mock_fernet_class.return_value = mock_fernet_instance

            service = TwoFactorService(mock_db_session)

            assert service.cipher == mock_fernet_instance

    def test_initialization_without_encryption_key_production(self, mock_db_session):
        """Test service initialization fails without encryption key in production."""
        mock_settings = MagicMock()
        mock_settings.ENCRYPTION_KEY = None
        mock_settings.ENVIRONMENT = "production"

        with patch(
            "app.services.two_factor_service.get_settings", return_value=mock_settings
        ):
            with pytest.raises(ValueError) as exc_info:
                TwoFactorService(mock_db_session)

            assert "ENCRYPTION_KEY must be configured in production" in str(
                exc_info.value
            )

    def test_initialization_invalid_encryption_key(self, mock_db_session):
        """Test service initialization with invalid encryption key."""
        mock_settings = MagicMock()
        mock_settings.ENCRYPTION_KEY = "invalid-key"
        mock_settings.ENVIRONMENT = "development"

        with (
            patch(
                "app.services.two_factor_service.get_settings",
                return_value=mock_settings,
            ),
            patch(
                "app.services.two_factor_service.Fernet",
                side_effect=Exception("Invalid key format"),
            ),
        ):

            with pytest.raises(ValueError) as exc_info:
                TwoFactorService(mock_db_session)

            assert "Invalid ENCRYPTION_KEY format" in str(exc_info.value)


class TestTOTPSetup:
    """Tests for TOTP setup functionality."""

    @pytest.mark.asyncio
    async def test_setup_totp_success(
        self, two_factor_service, sample_user, mock_db_session
    ):
        """Test successful TOTP setup."""
        with (
            patch("pyotp.random_base32", return_value="JBSWY3DPEHPK3PXP"),
            patch("qrcode.QRCode") as mock_qr_class,
            patch.object(
                two_factor_service,
                "_generate_backup_codes",
                return_value=["CODE1-TEST", "CODE2-TEST"],
            ),
        ):

            # Mock QR code generation
            mock_qr = MagicMock()
            mock_img = MagicMock()
            mock_qr.make_image.return_value = mock_img
            mock_qr_class.return_value = mock_qr

            # Mock image save
            mock_img.save = MagicMock()

            with patch("base64.b64encode", return_value=b"test-qr-code"):
                result = await two_factor_service.setup_totp(sample_user)

            assert "secret" in result
            assert "qr_code" in result
            assert "backup_codes" in result
            assert result["secret"] == "JBSWY3DPEHPK3PXP"
            assert sample_user.totp_secret == "JBSWY3DPEHPK3PXP"
            assert sample_user.backup_codes is not None
            mock_db_session.commit.assert_called_once()

    @pytest.mark.asyncio
    async def test_setup_totp_already_enabled(
        self, two_factor_service, user_with_2fa_enabled
    ):
        """Test TOTP setup when 2FA is already enabled."""
        with pytest.raises(TwoFactorError) as exc_info:
            await two_factor_service.setup_totp(user_with_2fa_enabled)

        assert "already enabled" in str(exc_info.value)

    @pytest.mark.asyncio
    async def test_setup_totp_qr_code_generation(self, two_factor_service, sample_user):
        """Test QR code generation during TOTP setup."""
        with (
            patch("pyotp.random_base32", return_value="JBSWY3DPEHPK3PXP"),
            patch("pyotp.TOTP") as mock_totp_class,
            patch("qrcode.QRCode") as mock_qr_class,
            patch.object(two_factor_service, "_generate_backup_codes", return_value=[]),
        ):

            mock_totp = MagicMock()
            mock_totp.provisioning_uri.return_value = "otpauth://totp/test"
            mock_totp_class.return_value = mock_totp

            mock_qr = MagicMock()
            mock_img = MagicMock()
            mock_qr.make_image.return_value = mock_img
            mock_qr_class.return_value = mock_qr

            # Mock BytesIO and base64 encoding
            with (
                patch("io.BytesIO") as mock_bytesio,
                patch("base64.b64encode", return_value=b"encoded-qr"),
            ):

                mock_buffer = MagicMock()
                mock_bytesio.return_value = mock_buffer
                mock_buffer.getvalue.return_value = b"qr-image-data"

                result = await two_factor_service.setup_totp(sample_user)

                assert result["qr_code"] == "data:image/png;base64,encoded-qr"
                mock_qr.add_data.assert_called_with("otpauth://totp/test")
                mock_img.save.assert_called_with(mock_buffer, format="PNG")

    @pytest.mark.asyncio
    async def test_setup_totp_backup_codes_encryption(
        self, two_factor_service, sample_user
    ):
        """Test backup codes are properly encrypted during setup."""
        backup_codes = ["ABC1-DEF2", "GHI3-JKL4"]

        with (
            patch("pyotp.random_base32"),
            patch("qrcode.QRCode"),
            patch("base64.b64encode"),
            patch.object(
                two_factor_service, "_generate_backup_codes", return_value=backup_codes
            ),
            patch(
                "app.services.two_factor_service.get_password_hash",
                side_effect=lambda x: f"hashed_{x}",
            ),
            patch.object(two_factor_service.cipher, "encrypt") as mock_encrypt,
        ):

            mock_encrypt.return_value = b"encrypted-backup-codes"

            await two_factor_service.setup_totp(sample_user)

            # Verify encryption was called with hashed codes
            mock_encrypt.assert_called_once()
            encrypted_data = mock_encrypt.call_args[0][0]
            decrypted_list = json.loads(encrypted_data.decode())
            assert decrypted_list == ["hashed_ABC1-DEF2", "hashed_GHI3-JKL4"]


class TestTOTPVerification:
    """Tests for TOTP verification functionality."""

    def test_verify_totp_success(self, two_factor_service):
        """Test successful TOTP verification."""
        with patch("pyotp.TOTP") as mock_totp_class:
            mock_totp = MagicMock()
            mock_totp.verify.return_value = True
            mock_totp_class.return_value = mock_totp

            result = two_factor_service.verify_totp("JBSWY3DPEHPK3PXP", "123456")

            assert result is True
            mock_totp.verify.assert_called_with("123456", valid_window=1)

    def test_verify_totp_failure(self, two_factor_service):
        """Test TOTP verification failure."""
        with patch("pyotp.TOTP") as mock_totp_class:
            mock_totp = MagicMock()
            mock_totp.verify.return_value = False
            mock_totp_class.return_value = mock_totp

            result = two_factor_service.verify_totp("JBSWY3DPEHPK3PXP", "000000")

            assert result is False

    def test_verify_totp_exception(self, two_factor_service):
        """Test TOTP verification with exception."""
        with patch("pyotp.TOTP", side_effect=Exception("Invalid secret")):
            result = two_factor_service.verify_totp("INVALID", "123456")

            assert result is False

    def test_verify_totp_custom_window(self, two_factor_service):
        """Test TOTP verification with custom time window."""
        with patch("pyotp.TOTP") as mock_totp_class:
            mock_totp = MagicMock()
            mock_totp.verify.return_value = True
            mock_totp_class.return_value = mock_totp

            result = two_factor_service.verify_totp(
                "JBSWY3DPEHPK3PXP", "123456", window=2
            )

            assert result is True
            mock_totp.verify.assert_called_with("123456", valid_window=2)

    @pytest.mark.asyncio
    async def test_verify_and_enable_totp_success(
        self, two_factor_service, sample_user, mock_db_session
    ):
        """Test successful TOTP verification and enabling."""
        sample_user.totp_secret = "JBSWY3DPEHPK3PXP"

        with patch.object(two_factor_service, "verify_totp", return_value=True):
            result = await two_factor_service.verify_and_enable_totp(
                sample_user, "123456"
            )

            assert result is True
            assert sample_user.two_factor_enabled is True
            assert sample_user.two_factor_verified_at is not None
            assert sample_user.failed_2fa_attempts == 0
            mock_db_session.commit.assert_called_once()

    @pytest.mark.asyncio
    async def test_verify_and_enable_totp_invalid_code(
        self, two_factor_service, sample_user
    ):
        """Test TOTP verification failure during enabling."""
        sample_user.totp_secret = "JBSWY3DPEHPK3PXP"

        with patch.object(two_factor_service, "verify_totp", return_value=False):
            with pytest.raises(TwoFactorError) as exc_info:
                await two_factor_service.verify_and_enable_totp(sample_user, "000000")

            assert "Invalid verification code" in str(exc_info.value)

    @pytest.mark.asyncio
    async def test_verify_and_enable_totp_already_enabled(
        self, two_factor_service, user_with_2fa_enabled
    ):
        """Test enabling TOTP when already enabled."""
        with pytest.raises(TwoFactorError) as exc_info:
            await two_factor_service.verify_and_enable_totp(
                user_with_2fa_enabled, "123456"
            )

        assert "already enabled" in str(exc_info.value)

    @pytest.mark.asyncio
    async def test_verify_and_enable_totp_not_setup(
        self, two_factor_service, sample_user
    ):
        """Test enabling TOTP when not set up."""
        with pytest.raises(TwoFactorError) as exc_info:
            await two_factor_service.verify_and_enable_totp(sample_user, "123456")

        assert "TOTP has not been set up" in str(exc_info.value)


class TestTwoFactorCodeVerification:
    """Tests for 2FA code verification."""

    @pytest.mark.asyncio
    async def test_verify_2fa_code_totp_success(
        self, two_factor_service, user_with_2fa_enabled, mock_db_session
    ):
        """Test successful TOTP code verification."""
        with patch.object(two_factor_service, "verify_totp", return_value=True):
            result = await two_factor_service.verify_2fa_code(
                user_with_2fa_enabled, "123456"
            )

            assert result is True
            assert user_with_2fa_enabled.failed_2fa_attempts == 0
            mock_db_session.commit.assert_called_once()

    @pytest.mark.asyncio
    async def test_verify_2fa_code_totp_failure(
        self, two_factor_service, user_with_2fa_enabled, mock_db_session
    ):
        """Test failed TOTP code verification."""
        with patch.object(two_factor_service, "verify_totp", return_value=False):
            result = await two_factor_service.verify_2fa_code(
                user_with_2fa_enabled, "000000"
            )

            assert result is False
            assert user_with_2fa_enabled.failed_2fa_attempts == 1
            mock_db_session.commit.assert_called_once()

    @pytest.mark.asyncio
    async def test_verify_2fa_code_backup_success(
        self, two_factor_service, user_with_2fa_enabled, mock_db_session
    ):
        """Test successful backup code verification."""
        with patch.object(two_factor_service, "_verify_backup_code", return_value=True):
            result = await two_factor_service.verify_2fa_code(
                user_with_2fa_enabled, "ABCD-EFGH", is_backup=True
            )

            assert result is True
            assert user_with_2fa_enabled.failed_2fa_attempts == 0

    @pytest.mark.asyncio
    async def test_verify_2fa_code_not_enabled(self, two_factor_service, sample_user):
        """Test 2FA code verification when 2FA is not enabled."""
        with pytest.raises(TwoFactorError) as exc_info:
            await two_factor_service.verify_2fa_code(sample_user, "123456")

        assert "not enabled" in str(exc_info.value)

    @pytest.mark.asyncio
    async def test_verify_2fa_code_lockout(
        self, two_factor_service, user_with_2fa_enabled
    ):
        """Test 2FA code verification during lockout."""
        user_with_2fa_enabled.failed_2fa_attempts = 5
        user_with_2fa_enabled.two_factor_verified_at = datetime.utcnow()

        with pytest.raises(TwoFactorError) as exc_info:
            await two_factor_service.verify_2fa_code(user_with_2fa_enabled, "123456")

        assert "Account locked" in str(exc_info.value)

    @pytest.mark.asyncio
    async def test_verify_2fa_code_lockout_expired(
        self, two_factor_service, user_with_2fa_enabled, mock_db_session
    ):
        """Test 2FA code verification after lockout period expires."""
        user_with_2fa_enabled.failed_2fa_attempts = 5
        user_with_2fa_enabled.two_factor_verified_at = datetime.utcnow() - timedelta(
            hours=1
        )  # Lockout expired

        with patch.object(two_factor_service, "verify_totp", return_value=True):
            result = await two_factor_service.verify_2fa_code(
                user_with_2fa_enabled, "123456"
            )

            assert result is True
            assert user_with_2fa_enabled.failed_2fa_attempts == 0  # Reset after expiry

    @pytest.mark.asyncio
    async def test_verify_2fa_code_exponential_backoff(
        self, two_factor_service, user_with_2fa_enabled
    ):
        """Test exponential backoff for repeated failed attempts."""
        user_with_2fa_enabled.failed_2fa_attempts = 7  # Beyond max attempts
        user_with_2fa_enabled.two_factor_verified_at = datetime.utcnow()

        with pytest.raises(TwoFactorError) as exc_info:
            await two_factor_service.verify_2fa_code(user_with_2fa_enabled, "123456")

        # Should include exponential backoff message
        assert "Account locked" in str(exc_info.value)


class TestBackupCodes:
    """Tests for backup code functionality."""

    def test_generate_backup_codes(self, two_factor_service):
        """Test backup code generation."""
        codes = two_factor_service._generate_backup_codes()

        assert len(codes) == 10
        assert all(len(code) == 9 for code in codes)  # Format: XXXX-XXXX
        assert all("-" in code for code in codes)
        assert len(set(codes)) == 10  # All unique

        # Test format
        for code in codes:
            parts = code.split("-")
            assert len(parts) == 2
            assert len(parts[0]) == 4
            assert len(parts[1]) == 4
            assert all(
                c in "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
                for c in code.replace("-", "")
            )

    def test_generate_backup_codes_uniqueness(self, two_factor_service):
        """Test backup code uniqueness across multiple generations."""
        codes1 = two_factor_service._generate_backup_codes()
        codes2 = two_factor_service._generate_backup_codes()

        # Should be different sets
        assert set(codes1) != set(codes2)

    @pytest.mark.asyncio
    async def test_verify_backup_code_success(
        self, two_factor_service, user_with_2fa_enabled, mock_db_session
    ):
        """Test successful backup code verification."""
        # Set up encrypted backup codes
        backup_codes = ["ABCD-EFGH", "IJKL-MNOP"]
        hashed_codes = [get_password_hash(code) for code in backup_codes]

        with (
            patch.object(two_factor_service.cipher, "decrypt") as mock_decrypt,
            patch.object(two_factor_service.cipher, "encrypt") as mock_encrypt,
        ):

            mock_decrypt.return_value = json.dumps(hashed_codes).encode()
            mock_encrypt.return_value = b"updated-encrypted-codes"

            user_with_2fa_enabled.backup_codes = "encrypted-backup-codes"
            user_with_2fa_enabled.two_factor_recovery_codes_used = 0

            result = await two_factor_service._verify_backup_code(
                user_with_2fa_enabled, "ABCD-EFGH"
            )

            assert result is True
            assert user_with_2fa_enabled.two_factor_recovery_codes_used == 1
            mock_db_session.commit.assert_called_once()

    @pytest.mark.asyncio
    async def test_verify_backup_code_failure(
        self, two_factor_service, user_with_2fa_enabled
    ):
        """Test failed backup code verification."""
        hashed_codes = [get_password_hash("VALID-CODE")]

        with patch.object(two_factor_service.cipher, "decrypt") as mock_decrypt:
            mock_decrypt.return_value = json.dumps(hashed_codes).encode()
            user_with_2fa_enabled.backup_codes = "encrypted-backup-codes"

            result = await two_factor_service._verify_backup_code(
                user_with_2fa_enabled, "WRONG-CODE"
            )

            assert result is False

    @pytest.mark.asyncio
    async def test_verify_backup_code_no_codes(
        self, two_factor_service, user_with_2fa_enabled
    ):
        """Test backup code verification when no codes exist."""
        user_with_2fa_enabled.backup_codes = None

        result = await two_factor_service._verify_backup_code(
            user_with_2fa_enabled, "ABCD-EFGH"
        )

        assert result is False

    @pytest.mark.asyncio
    async def test_verify_backup_code_already_used(
        self, two_factor_service, user_with_2fa_enabled
    ):
        """Test verification of already used backup code."""
        hashed_codes = [
            None,
            get_password_hash("VALID-CODE"),
        ]  # First code already used (None)

        with patch.object(two_factor_service.cipher, "decrypt") as mock_decrypt:
            mock_decrypt.return_value = json.dumps(hashed_codes).encode()
            user_with_2fa_enabled.backup_codes = "encrypted-backup-codes"

            # Try to use a code that's been marked as used (None)
            result = await two_factor_service._verify_backup_code(
                user_with_2fa_enabled, "USED-CODE"
            )

            assert result is False

    @pytest.mark.asyncio
    async def test_verify_backup_code_decryption_error(
        self, two_factor_service, user_with_2fa_enabled
    ):
        """Test backup code verification with decryption error."""
        with patch.object(
            two_factor_service.cipher,
            "decrypt",
            side_effect=Exception("Decryption failed"),
        ):
            user_with_2fa_enabled.backup_codes = "invalid-encrypted-data"

            result = await two_factor_service._verify_backup_code(
                user_with_2fa_enabled, "ABCD-EFGH"
            )

            assert result is False

    @pytest.mark.asyncio
    async def test_regenerate_backup_codes(
        self, two_factor_service, user_with_2fa_enabled, mock_db_session
    ):
        """Test backup code regeneration."""
        with (
            patch.object(
                two_factor_service,
                "_generate_backup_codes",
                return_value=["NEW1-CODE", "NEW2-CODE"],
            ) as mock_generate,
            patch.object(
                two_factor_service.cipher,
                "encrypt",
                return_value=b"new-encrypted-codes",
            ),
        ):

            codes = await two_factor_service.regenerate_backup_codes(
                user_with_2fa_enabled
            )

            assert codes == ["NEW1-CODE", "NEW2-CODE"]
            assert user_with_2fa_enabled.backup_codes == "new-encrypted-codes"
            assert user_with_2fa_enabled.two_factor_recovery_codes_used == 0
            mock_generate.assert_called_once()
            mock_db_session.commit.assert_called_once()

    @pytest.mark.asyncio
    async def test_regenerate_backup_codes_not_enabled(
        self, two_factor_service, sample_user
    ):
        """Test backup code regeneration when 2FA is not enabled."""
        with pytest.raises(TwoFactorError) as exc_info:
            await two_factor_service.regenerate_backup_codes(sample_user)

        assert "not enabled" in str(exc_info.value)


class TestTwoFactorDisabling:
    """Tests for two-factor authentication disabling."""

    @pytest.mark.asyncio
    async def test_disable_two_factor_success(
        self, two_factor_service, user_with_2fa_enabled, mock_db_session
    ):
        """Test successful 2FA disabling."""
        result = await two_factor_service.disable_two_factor(
            user_with_2fa_enabled, "password123"
        )

        assert result is True
        assert user_with_2fa_enabled.two_factor_enabled is False
        assert user_with_2fa_enabled.totp_secret is None
        assert user_with_2fa_enabled.backup_codes is None
        assert user_with_2fa_enabled.two_factor_recovery_codes_used == 0
        assert user_with_2fa_enabled.failed_2fa_attempts == 0
        assert user_with_2fa_enabled.two_factor_verified_at is None
        mock_db_session.commit.assert_called_once()

    @pytest.mark.asyncio
    async def test_disable_two_factor_wrong_password(
        self, two_factor_service, user_with_2fa_enabled
    ):
        """Test 2FA disabling with wrong password."""
        with pytest.raises(TwoFactorError) as exc_info:
            await two_factor_service.disable_two_factor(
                user_with_2fa_enabled, "wrongpassword"
            )

        assert "Invalid password" in str(exc_info.value)

    @pytest.mark.asyncio
    async def test_disable_two_factor_not_enabled(
        self, two_factor_service, sample_user
    ):
        """Test disabling 2FA when not enabled."""
        with pytest.raises(TwoFactorError) as exc_info:
            await two_factor_service.disable_two_factor(sample_user, "password123")

        assert "not enabled" in str(exc_info.value)


class TestTwoFactorStatus:
    """Tests for 2FA status reporting."""

    @pytest.mark.asyncio
    async def test_get_2fa_status_disabled(self, two_factor_service, sample_user):
        """Test 2FA status when disabled."""
        status = await two_factor_service.get_2fa_status(sample_user)

        assert status["enabled"] is False
        assert status["verified_at"] is None
        assert status["backup_codes_remaining"] == 0
        assert status["methods"]["totp"] is False
        assert status["methods"]["backup_codes"] is False

    @pytest.mark.asyncio
    async def test_get_2fa_status_enabled(
        self, two_factor_service, user_with_2fa_enabled
    ):
        """Test 2FA status when enabled."""
        user_with_2fa_enabled.backup_codes = "encrypted-codes"
        user_with_2fa_enabled.two_factor_recovery_codes_used = 3

        status = await two_factor_service.get_2fa_status(user_with_2fa_enabled)

        assert status["enabled"] is True
        assert status["verified_at"] is not None
        assert status["backup_codes_remaining"] == 7  # 10 - 3
        assert status["methods"]["totp"] is True
        assert status["methods"]["backup_codes"] is True

    @pytest.mark.asyncio
    async def test_get_2fa_status_all_backup_codes_used(
        self, two_factor_service, user_with_2fa_enabled
    ):
        """Test 2FA status when all backup codes are used."""
        user_with_2fa_enabled.backup_codes = "encrypted-codes"
        user_with_2fa_enabled.two_factor_recovery_codes_used = 10

        status = await two_factor_service.get_2fa_status(user_with_2fa_enabled)

        assert status["backup_codes_remaining"] == 0


class TestTwoFactorRecovery:
    """Tests for 2FA recovery functionality."""

    @pytest.mark.asyncio
    async def test_send_2fa_recovery_email_password_reset(
        self, two_factor_service, user_with_2fa_enabled
    ):
        """Test sending 2FA recovery email for password reset."""
        result = await two_factor_service.send_2fa_recovery_email(
            user_with_2fa_enabled, "password_reset"
        )

        # Currently just returns True (placeholder implementation)
        assert result is True

    @pytest.mark.asyncio
    async def test_send_2fa_recovery_email_disable_2fa(
        self, two_factor_service, user_with_2fa_enabled
    ):
        """Test sending 2FA recovery email for disabling 2FA."""
        result = await two_factor_service.send_2fa_recovery_email(
            user_with_2fa_enabled, "disable_2fa"
        )

        # Currently just returns True (placeholder implementation)
        assert result is True


class TestTwoFactorServiceEdgeCases:
    """Tests for edge cases and error conditions."""

    def test_backup_code_format(self, two_factor_service):
        """Test backup code format compliance."""
        codes = two_factor_service._generate_backup_codes()

        for code in codes:
            # Test format: XXXX-XXXX where X is alphanumeric
            assert len(code) == 9
            assert code[4] == "-"
            parts = code.split("-")
            assert len(parts[0]) == 4
            assert len(parts[1]) == 4
            # Test characters are from expected charset
            charset = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
            for char in code.replace("-", ""):
                assert char in charset

    def test_backup_code_entropy(self, two_factor_service):
        """Test backup codes have sufficient entropy."""
        codes = two_factor_service._generate_backup_codes()

        # With 36 characters and 8 positions, we have 36^8 possibilities
        # Let's test that we don't get obvious patterns
        assert len(set(codes)) == len(codes)  # All unique

        # Test that codes don't follow obvious patterns
        for code in codes:
            clean_code = code.replace("-", "")
            assert clean_code != "00000000"  # Not all zeros
            assert clean_code != "AAAAAAAA"  # Not all same character
            assert clean_code != "01234567"  # Not sequential

    @pytest.mark.asyncio
    async def test_multiple_failed_attempts_reset(
        self, two_factor_service, user_with_2fa_enabled, mock_db_session
    ):
        """Test that failed attempts reset on successful verification."""
        user_with_2fa_enabled.failed_2fa_attempts = 3

        with patch.object(two_factor_service, "verify_totp", return_value=True):
            result = await two_factor_service.verify_2fa_code(
                user_with_2fa_enabled, "123456"
            )

            assert result is True
            assert user_with_2fa_enabled.failed_2fa_attempts == 0

    def test_constants_defined(self, two_factor_service):
        """Test that service constants are properly defined."""
        assert two_factor_service.TOTP_ISSUER == "Enterprise Auth"
        assert two_factor_service.BACKUP_CODES_COUNT == 10
        assert two_factor_service.BACKUP_CODE_LENGTH == 8
        assert two_factor_service.MAX_2FA_ATTEMPTS == 5
        assert two_factor_service.LOCKOUT_DURATION == 300

    @pytest.mark.asyncio
    async def test_concurrent_backup_code_usage(
        self, two_factor_service, user_with_2fa_enabled, mock_db_session
    ):
        """Test handling of concurrent backup code usage attempts."""
        # This tests the edge case where multiple processes might try to use
        # the same backup code simultaneously

        backup_codes = ["ABCD-EFGH", "IJKL-MNOP"]
        hashed_codes = [get_password_hash(code) for code in backup_codes]

        with (
            patch.object(two_factor_service.cipher, "decrypt") as mock_decrypt,
            patch.object(two_factor_service.cipher, "encrypt") as mock_encrypt,
        ):

            mock_decrypt.return_value = json.dumps(hashed_codes).encode()
            mock_encrypt.return_value = b"updated-encrypted-codes"

            user_with_2fa_enabled.backup_codes = "encrypted-backup-codes"

            # First usage should succeed
            result1 = await two_factor_service._verify_backup_code(
                user_with_2fa_enabled, "ABCD-EFGH"
            )
            assert result1 is True

            # Second usage of same code should fail (code marked as None)
            mock_decrypt.return_value = json.dumps([None, hashed_codes[1]]).encode()
            result2 = await two_factor_service._verify_backup_code(
                user_with_2fa_enabled, "ABCD-EFGH"
            )
            assert result2 is False


class TestTwoFactorServiceIntegration:
    """Integration tests for two-factor authentication service."""

    @pytest.mark.asyncio
    async def test_complete_2fa_setup_flow(
        self, two_factor_service, sample_user, mock_db_session
    ):
        """Test complete 2FA setup and verification flow."""
        # Step 1: Setup TOTP
        with (
            patch("pyotp.random_base32", return_value="JBSWY3DPEHPK3PXP"),
            patch("qrcode.QRCode"),
            patch("base64.b64encode"),
        ):

            setup_result = await two_factor_service.setup_totp(sample_user)
            assert "secret" in setup_result
            assert sample_user.totp_secret == "JBSWY3DPEHPK3PXP"

        # Step 2: Verify and enable
        with patch.object(two_factor_service, "verify_totp", return_value=True):
            enable_result = await two_factor_service.verify_and_enable_totp(
                sample_user, "123456"
            )
            assert enable_result is True
            assert sample_user.two_factor_enabled is True

        # Step 3: Verify code works
        with patch.object(two_factor_service, "verify_totp", return_value=True):
            verify_result = await two_factor_service.verify_2fa_code(
                sample_user, "654321"
            )
            assert verify_result is True

        # Step 4: Check status
        status = await two_factor_service.get_2fa_status(sample_user)
        assert status["enabled"] is True

    @pytest.mark.asyncio
    async def test_2fa_lockout_and_recovery_flow(
        self, two_factor_service, user_with_2fa_enabled, mock_db_session
    ):
        """Test 2FA lockout and recovery flow."""
        # Fail multiple times
        with patch.object(two_factor_service, "verify_totp", return_value=False):
            for i in range(5):
                result = await two_factor_service.verify_2fa_code(
                    user_with_2fa_enabled, "000000"
                )
                assert result is False
                assert user_with_2fa_enabled.failed_2fa_attempts == i + 1

        # Should be locked out now
        with pytest.raises(TwoFactorError):
            await two_factor_service.verify_2fa_code(user_with_2fa_enabled, "123456")

        # Simulate lockout expiry
        user_with_2fa_enabled.two_factor_verified_at = datetime.utcnow() - timedelta(
            hours=1
        )

        # Should work again after expiry
        with patch.object(two_factor_service, "verify_totp", return_value=True):
            result = await two_factor_service.verify_2fa_code(
                user_with_2fa_enabled, "123456"
            )
            assert result is True
            assert user_with_2fa_enabled.failed_2fa_attempts == 0  # Reset
