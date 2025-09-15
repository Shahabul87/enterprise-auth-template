#!/usr/bin/env python3
"""
Comprehensive Authentication Flow Validation Test

This test validates the complete authentication flow including all recent fixes:
1. Registration → Email Verification → Login flow
2. Email verification enforcement in login
3. Correct field mappings (email_verified vs is_verified)
4. Redirect logic and data consistency
"""

import asyncio
import uuid
from datetime import datetime, timedelta
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database import get_async_session
from app.services.auth.registration_service import RegistrationService
from app.services.auth.email_verification_service import EmailVerificationService
from app.services.auth.authentication_service import AuthenticationService, EmailNotVerifiedError
from app.schemas.auth import RegisterRequest
from app.repositories.user_repository import UserRepository
from app.models.auth import EmailVerificationToken


class AuthFlowValidator:
    """Comprehensive authentication flow validation."""

    def __init__(self):
        self.session = None
        self.test_email = f"test+{uuid.uuid4().hex[:8]}@example.com"
        self.test_password = "SecureTestPass123!"
        self.test_name = "Test User"

    async def setup(self):
        """Setup test environment."""
        # Get database session
        session_gen = get_async_session()
        self.session = await session_gen.__anext__()

        # Initialize services
        self.registration_service = RegistrationService(self.session)
        self.email_verification_service = EmailVerificationService(self.session)
        self.authentication_service = AuthenticationService(self.session)
        self.user_repo = UserRepository(self.session)

        print(f"🔧 Test setup complete")
        print(f"📧 Test email: {self.test_email}")

    async def cleanup(self):
        """Clean up test data."""
        try:
            # Find and delete test user
            user = await self.user_repo.find_by_email(self.test_email)
            if user:
                await self.user_repo.delete(user.id)
                await self.session.commit()
                print(f"🗑️  Cleaned up test user: {self.test_email}")

            # Close session
            await self.session.close()
        except Exception as e:
            print(f"⚠️  Cleanup warning: {e}")

    async def test_1_user_registration(self):
        """Test 1: User registration creates inactive user."""
        print(f"\n🧪 TEST 1: User Registration")

        registration_data = RegisterRequest(
            email=self.test_email,
            password=self.test_password,
            full_name=self.test_name,
            agree_to_terms=True
        )

        # Register user
        response = await self.registration_service.register_user(registration_data)

        # Validate response
        assert response.id is not None, "User ID should be generated"
        assert response.email == self.test_email, "Email should match"
        assert response.full_name == self.test_name, "Name should match"
        assert response.isEmailVerified == False, "Email should NOT be verified"

        # Validate database state
        user = await self.user_repo.find_by_email(self.test_email)
        assert user is not None, "User should exist in database"
        assert user.is_active == False, "User should NOT be active"
        assert user.email_verified == False, "Email should NOT be verified"

        print(f"✅ Registration successful - User created as inactive/unverified")
        return user

    async def test_2_login_before_verification(self):
        """Test 2: Login before email verification should fail."""
        print(f"\n🧪 TEST 2: Login Before Email Verification")

        try:
            await self.authentication_service.authenticate_user(
                email=self.test_email,
                password=self.test_password
            )
            assert False, "Login should fail for unverified email"

        except EmailNotVerifiedError as e:
            print(f"✅ Login correctly blocked for unverified email: {str(e)}")

        except Exception as e:
            assert False, f"Unexpected error: {e}"

    async def test_3_email_verification(self):
        """Test 3: Email verification activates user."""
        print(f"\n🧪 TEST 3: Email Verification")

        # Find user and verification token
        user = await self.user_repo.find_by_email(self.test_email)

        # Get verification token from database
        from sqlalchemy import select
        stmt = select(EmailVerificationToken).where(
            EmailVerificationToken.user_id == user.id,
            EmailVerificationToken.is_used == False
        )
        result = await self.session.execute(stmt)
        token_record = result.scalar_one_or_none()

        assert token_record is not None, "Verification token should exist"

        # Verify email
        success = await self.email_verification_service.verify_email(token_record.token)
        assert success == True, "Email verification should succeed"

        # Validate database state after verification
        user = await self.user_repo.find_by_email(self.test_email)
        assert user.is_active == True, "User should be active after verification"
        assert user.email_verified == True, "Email should be verified"

        print(f"✅ Email verification successful - User activated")
        return user

    async def test_4_login_after_verification(self):
        """Test 4: Login after email verification should succeed."""
        print(f"\n🧪 TEST 4: Login After Email Verification")

        # Attempt login
        login_response = await self.authentication_service.authenticate_user(
            email=self.test_email,
            password=self.test_password
        )

        # Validate login response
        assert login_response.access_token is not None, "Access token should be provided"
        assert login_response.refresh_token is not None, "Refresh token should be provided"
        assert login_response.user is not None, "User data should be provided"

        # Validate user data in response uses correct field mapping
        assert login_response.user.email_verified == True, "User should show as email verified"
        assert login_response.user.email == self.test_email, "Email should match"

        print(f"✅ Login successful after email verification")
        print(f"   ↳ User email_verified: {login_response.user.email_verified}")
        print(f"   ↳ Access token provided: ✓")
        print(f"   ↳ Refresh token provided: ✓")

        return login_response

    async def test_5_data_consistency_validation(self):
        """Test 5: Validate data consistency across services."""
        print(f"\n🧪 TEST 5: Data Consistency Validation")

        # Get user from different services
        user_from_repo = await self.user_repo.find_by_email(self.test_email)

        # Test registration service response
        registration_data = RegisterRequest(
            email=f"temp+{uuid.uuid4().hex[:8]}@example.com",
            password=self.test_password,
            full_name="Temp User",
            agree_to_terms=True
        )
        temp_response = await self.registration_service.register_user(registration_data)

        # Validate field naming consistency
        assert hasattr(temp_response, 'isEmailVerified'), "Registration response should use isEmailVerified"
        assert temp_response.isEmailVerified == False, "New user should not be verified"

        # Clean up temp user
        temp_user = await self.user_repo.find_by_email(registration_data.email)
        if temp_user:
            await self.user_repo.delete(temp_user.id)

        print(f"✅ Data consistency validated across services")
        print(f"   ↳ Database field: email_verified = {user_from_repo.email_verified}")
        print(f"   ↳ API response field: isEmailVerified = {temp_response.isEmailVerified}")

    async def test_6_error_handling_validation(self):
        """Test 6: Validate proper error handling."""
        print(f"\n🧪 TEST 6: Error Handling Validation")

        # Test 1: Login with wrong password
        try:
            await self.authentication_service.authenticate_user(
                email=self.test_email,
                password="WrongPassword123!"
            )
            assert False, "Login should fail with wrong password"
        except Exception as e:
            assert "Invalid email or password" in str(e), f"Wrong error: {e}"
            print(f"✅ Wrong password correctly rejected")

        # Test 2: Login with non-existent user
        try:
            await self.authentication_service.authenticate_user(
                email="nonexistent@example.com",
                password=self.test_password
            )
            assert False, "Login should fail for non-existent user"
        except Exception as e:
            assert "Invalid email or password" in str(e), f"Wrong error: {e}"
            print(f"✅ Non-existent user correctly rejected")

        # Test 3: Email verification with invalid token
        try:
            await self.email_verification_service.verify_email("invalid-token")
            assert False, "Verification should fail with invalid token"
        except Exception as e:
            assert "Invalid or expired" in str(e), f"Wrong error: {e}"
            print(f"✅ Invalid verification token correctly rejected")

    async def run_all_tests(self):
        """Run all validation tests."""
        print(f"\n🚀 STARTING COMPREHENSIVE AUTHENTICATION FLOW VALIDATION")
        print(f"=" * 70)

        try:
            await self.setup()

            # Run all tests in sequence
            user = await self.test_1_user_registration()
            await self.test_2_login_before_verification()
            verified_user = await self.test_3_email_verification()
            login_response = await self.test_4_login_after_verification()
            await self.test_5_data_consistency_validation()
            await self.test_6_error_handling_validation()

            print(f"\n" + "=" * 70)
            print(f"🎉 ALL TESTS PASSED! Authentication flow is working correctly.")
            print(f"✅ Critical fixes validated:")
            print(f"   • Email verification enforcement in login")
            print(f"   • Correct field mappings (email_verified)")
            print(f"   • Proper user activation flow")
            print(f"   • Consistent error handling")
            print(f"   • Data consistency across services")

        except AssertionError as e:
            print(f"\n❌ TEST FAILED: {e}")
            raise
        except Exception as e:
            print(f"\n💥 UNEXPECTED ERROR: {e}")
            raise
        finally:
            await self.cleanup()


async def main():
    """Main test execution."""
    validator = AuthFlowValidator()
    await validator.run_all_tests()


if __name__ == "__main__":
    asyncio.run(main())