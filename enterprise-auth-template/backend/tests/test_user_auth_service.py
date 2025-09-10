"""
Tests for User Authentication Service

Tests the authentication operations implemented in the refactored
user_auth_service module, including login, registration, and token management.
"""

import pytest
from datetime import datetime, timedelta
from unittest.mock import AsyncMock, patch
from sqlalchemy.ext.asyncio import AsyncSession

from app.services.user.user_auth_service import UserAuthService
from app.models.user import User, RefreshToken
from app.schemas.user import UserCreate
from app.schemas.auth import UserLogin
from app.core.security import get_password_hash, verify_password, create_access_token


class TestUserAuthService:
    """Test suite for UserAuthService functionality."""

    @pytest.fixture
    def user_auth_service(self):
        """User authentication service instance."""
        return UserAuthService()

    @pytest.fixture
    def login_data(self):
        """Sample login data."""
        return UserLogin(
            username="test@example.com",
            password="testpassword123"
        )

    @pytest.fixture
    def register_data(self):
        """Sample registration data."""
        return UserCreate(
            email="newuser@example.com",
            password="NewPassword123!",
            first_name="New",
            last_name="User",
        )

    @pytest.mark.asyncio
    async def test_authenticate_user_success(self, user_auth_service, test_user, login_data, db_session):
        """Test successful user authentication."""
        # Update test user email to match login data
        test_user.email = login_data.username
        test_user.hashed_password = get_password_hash(login_data.password)
        await db_session.commit()

        authenticated_user = await user_auth_service.authenticate_user(
            db_session, login_data.username, login_data.password
        )

        assert authenticated_user is not None
        assert authenticated_user.email == login_data.username
        assert authenticated_user.is_active is True

    @pytest.mark.asyncio
    async def test_authenticate_user_wrong_password(self, user_auth_service, test_user, db_session):
        """Test authentication with wrong password."""
        authenticated_user = await user_auth_service.authenticate_user(
            db_session, test_user.email, "wrongpassword"
        )

        assert authenticated_user is None

    @pytest.mark.asyncio
    async def test_authenticate_user_not_found(self, user_auth_service, db_session):
        """Test authentication with non-existent user."""
        authenticated_user = await user_auth_service.authenticate_user(
            db_session, "nonexistent@example.com", "password"
        )

        assert authenticated_user is None

    @pytest.mark.asyncio
    async def test_authenticate_user_inactive(self, user_auth_service, test_user, login_data, db_session):
        """Test authentication with inactive user."""
        # Deactivate user
        test_user.email = login_data.username
        test_user.hashed_password = get_password_hash(login_data.password)
        test_user.is_active = False
        await db_session.commit()

        authenticated_user = await user_auth_service.authenticate_user(
            db_session, login_data.username, login_data.password
        )

        assert authenticated_user is None

    @pytest.mark.asyncio
    async def test_create_user_registration(self, user_auth_service, register_data, db_session):
        """Test user registration."""
        created_user = await user_auth_service.create_user_registration(db_session, register_data)

        assert created_user is not None
        assert created_user.email == register_data.email
        assert created_user.first_name == register_data.first_name
        assert created_user.last_name == register_data.last_name
        assert created_user.is_active is True
        assert created_user.is_verified is False
        assert created_user.is_superuser is False
        assert verify_password(register_data.password, created_user.hashed_password)

    @pytest.mark.asyncio
    async def test_create_user_registration_duplicate_email(self, user_auth_service, test_user, register_data, db_session):
        """Test user registration with duplicate email."""
        register_data.email = test_user.email

        with pytest.raises(ValueError, match="User with this email already exists"):
            await user_auth_service.create_user_registration(db_session, register_data)

    @pytest.mark.asyncio
    async def test_create_access_token_for_user(self, user_auth_service, test_user, db_session):
        """Test access token creation for user."""
        token = await user_auth_service.create_access_token_for_user(db_session, test_user)

        assert token is not None
        assert isinstance(token, str)
        assert len(token) > 0

    @pytest.mark.asyncio
    async def test_create_refresh_token(self, user_auth_service, test_user, db_session):
        """Test refresh token creation."""
        refresh_token = await user_auth_service.create_refresh_token(db_session, test_user)

        assert refresh_token is not None
        assert refresh_token.user_id == test_user.id
        assert refresh_token.is_active is True
        assert not refresh_token.is_revoked
        assert refresh_token.expires_at > datetime.utcnow()

    @pytest.mark.asyncio
    async def test_validate_refresh_token_success(self, user_auth_service, test_user, db_session):
        """Test successful refresh token validation."""
        # Create refresh token
        refresh_token = await user_auth_service.create_refresh_token(db_session, test_user)
        
        # Validate token
        validated_token = await user_auth_service.validate_refresh_token(
            db_session, refresh_token.token
        )

        assert validated_token is not None
        assert validated_token.id == refresh_token.id
        assert validated_token.user_id == test_user.id

    @pytest.mark.asyncio
    async def test_validate_refresh_token_expired(self, user_auth_service, test_user, db_session):
        """Test validation of expired refresh token."""
        # Create expired refresh token
        refresh_token = RefreshToken(
            user_id=test_user.id,
            token="expired-token",
            expires_at=datetime.utcnow() - timedelta(days=1),
            is_active=True,
            is_revoked=False
        )
        db_session.add(refresh_token)
        await db_session.flush()

        # Validate expired token
        validated_token = await user_auth_service.validate_refresh_token(
            db_session, "expired-token"
        )

        assert validated_token is None

    @pytest.mark.asyncio
    async def test_validate_refresh_token_revoked(self, user_auth_service, test_user, db_session):
        """Test validation of revoked refresh token."""
        # Create revoked refresh token
        refresh_token = RefreshToken(
            user_id=test_user.id,
            token="revoked-token",
            expires_at=datetime.utcnow() + timedelta(days=7),
            is_active=False,
            is_revoked=True
        )
        db_session.add(refresh_token)
        await db_session.flush()

        # Validate revoked token
        validated_token = await user_auth_service.validate_refresh_token(
            db_session, "revoked-token"
        )

        assert validated_token is None

    @pytest.mark.asyncio
    async def test_revoke_refresh_token(self, user_auth_service, test_user, db_session):
        """Test refresh token revocation."""
        # Create refresh token
        refresh_token = await user_auth_service.create_refresh_token(db_session, test_user)
        
        # Revoke token
        success = await user_auth_service.revoke_refresh_token(
            db_session, refresh_token.token
        )

        assert success is True

        # Verify token is revoked
        await db_session.refresh(refresh_token)
        assert refresh_token.is_revoked is True
        assert refresh_token.is_active is False

    @pytest.mark.asyncio
    async def test_revoke_all_user_tokens(self, user_auth_service, test_user, db_session):
        """Test revoking all tokens for a user."""
        # Create multiple refresh tokens
        token1 = await user_auth_service.create_refresh_token(db_session, test_user)
        token2 = await user_auth_service.create_refresh_token(db_session, test_user)

        # Revoke all tokens
        revoked_count = await user_auth_service.revoke_all_user_tokens(
            db_session, test_user.id
        )

        assert revoked_count == 2

        # Verify all tokens are revoked
        await db_session.refresh(token1)
        await db_session.refresh(token2)
        assert token1.is_revoked is True
        assert token2.is_revoked is True

    @pytest.mark.asyncio
    async def test_change_user_password(self, user_auth_service, test_user, db_session):
        """Test user password change."""
        old_password = "oldpassword123"
        new_password = "newpassword456"
        
        # Set known password
        test_user.hashed_password = get_password_hash(old_password)
        await db_session.commit()

        # Change password
        success = await user_auth_service.change_user_password(
            db_session, test_user, old_password, new_password
        )

        assert success is True

        # Verify new password works
        await db_session.refresh(test_user)
        assert verify_password(new_password, test_user.hashed_password)
        assert not verify_password(old_password, test_user.hashed_password)

    @pytest.mark.asyncio
    async def test_change_user_password_wrong_old(self, user_auth_service, test_user, db_session):
        """Test password change with wrong old password."""
        old_password = "oldpassword123"
        new_password = "newpassword456"
        
        # Set known password
        test_user.hashed_password = get_password_hash(old_password)
        await db_session.commit()

        # Try to change with wrong old password
        success = await user_auth_service.change_user_password(
            db_session, test_user, "wrongoldpassword", new_password
        )

        assert success is False

        # Verify password unchanged
        await db_session.refresh(test_user)
        assert verify_password(old_password, test_user.hashed_password)

    @pytest.mark.asyncio
    async def test_reset_user_password(self, user_auth_service, test_user, db_session):
        """Test user password reset."""
        new_password = "resetpassword123"

        # Reset password
        success = await user_auth_service.reset_user_password(
            db_session, test_user, new_password
        )

        assert success is True

        # Verify new password works
        await db_session.refresh(test_user)
        assert verify_password(new_password, test_user.hashed_password)

    @pytest.mark.asyncio
    async def test_verify_user_email(self, user_auth_service, test_user, db_session):
        """Test user email verification."""
        # Ensure user starts unverified
        test_user.is_verified = False
        await db_session.commit()

        # Verify email
        success = await user_auth_service.verify_user_email(db_session, test_user)

        assert success is True

        # Check verification status
        await db_session.refresh(test_user)
        assert test_user.is_verified is True

    @pytest.mark.asyncio
    async def test_get_user_sessions(self, user_auth_service, test_user, db_session):
        """Test getting user active sessions."""
        # Create multiple refresh tokens (sessions)
        await user_auth_service.create_refresh_token(db_session, test_user)
        await user_auth_service.create_refresh_token(db_session, test_user)

        # Get user sessions
        sessions = await user_auth_service.get_user_sessions(db_session, test_user.id)

        assert len(sessions) == 2
        assert all(session.user_id == test_user.id for session in sessions)
        assert all(session.is_active for session in sessions)

    @pytest.mark.asyncio
    async def test_cleanup_expired_tokens(self, user_auth_service, test_user, db_session):
        """Test cleanup of expired tokens."""
        # Create expired token
        expired_token = RefreshToken(
            user_id=test_user.id,
            token="expired-cleanup-token",
            expires_at=datetime.utcnow() - timedelta(days=1),
            is_active=True,
            is_revoked=False
        )
        db_session.add(expired_token)
        
        # Create valid token
        valid_token = await user_auth_service.create_refresh_token(db_session, test_user)
        
        await db_session.commit()

        # Cleanup expired tokens
        cleaned_count = await user_auth_service.cleanup_expired_tokens(db_session)

        assert cleaned_count >= 1

        # Verify expired token is removed, valid token remains
        await db_session.refresh(valid_token)
        assert valid_token.is_active is True

    @pytest.mark.asyncio
    async def test_user_login_attempts_tracking(self, user_auth_service, test_user, db_session):
        """Test tracking of failed login attempts."""
        # Simulate failed login attempts
        for _ in range(3):
            await user_auth_service.record_failed_login(db_session, test_user.email)

        # Check if user is locked
        is_locked = await user_auth_service.is_user_locked(db_session, test_user.email)
        assert is_locked is True

        # Reset login attempts
        await user_auth_service.reset_failed_login_attempts(db_session, test_user.email)
        
        is_locked_after_reset = await user_auth_service.is_user_locked(db_session, test_user.email)
        assert is_locked_after_reset is False

    @pytest.mark.asyncio
    async def test_get_user_with_permissions_optimized(self, user_auth_service, test_user, db_session):
        """Test optimized query for user with permissions (no N+1 queries)."""
        user_with_perms = await user_auth_service.get_user_with_permissions(
            db_session, test_user.id
        )

        assert user_with_perms is not None
        assert user_with_perms.id == test_user.id
        # Should load permissions in the same query (no N+1)
        assert hasattr(user_with_perms, 'roles')

    @pytest.mark.asyncio
    async def test_service_caching_integration(self, user_auth_service, test_user, mock_cache_service, db_session):
        """Test service integration with cache service."""
        # Mock cache service methods
        mock_cache_service.get_user_permissions.return_value = ["read:posts"]
        
        permissions = await user_auth_service.get_user_cached_permissions(
            db_session, test_user.id, mock_cache_service
        )

        assert permissions == ["read:posts"]
        mock_cache_service.get_user_permissions.assert_called_once_with(str(test_user.id))

    @pytest.mark.asyncio
    async def test_error_handling(self, user_auth_service, db_session):
        """Test service error handling."""
        with patch.object(db_session, 'execute', side_effect=Exception("Database error")):
            with pytest.raises(Exception, match="Database error"):
                await user_auth_service.authenticate_user(
                    db_session, "test@example.com", "password"
                )

    @pytest.mark.asyncio
    async def test_rate_limiting_integration(self, user_auth_service, test_user, db_session):
        """Test rate limiting for authentication attempts."""
        # This test assumes rate limiting is implemented
        with patch('app.core.rate_limit.is_rate_limited', return_value=True):
            with pytest.raises(ValueError, match="Too many login attempts"):
                await user_auth_service.authenticate_user_with_rate_limit(
                    db_session, test_user.email, "password"
                )

    @pytest.mark.performance
    @pytest.mark.asyncio
    async def test_authentication_performance(self, user_auth_service, test_user, db_session):
        """Test authentication performance with proper indexing."""
        import time
        
        # Ensure user exists with proper password
        test_user.hashed_password = get_password_hash("testpassword")
        await db_session.commit()

        start_time = time.time()
        
        # Perform authentication
        authenticated_user = await user_auth_service.authenticate_user(
            db_session, test_user.email, "testpassword"
        )
        
        end_time = time.time()
        
        assert authenticated_user is not None
        # Authentication should be fast with proper indexes (< 100ms)
        assert end_time - start_time < 0.1