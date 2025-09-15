#!/usr/bin/env python3
"""Direct test of email verification service."""

import asyncio
import sys
import traceback
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker

# Add app to path
sys.path.insert(0, '/Users/mdshahabulalam/basetemplate/enterprise-auth-template/backend')

from app.services.auth.email_verification_service import EmailVerificationService
from app.repositories.user_repository import UserRepository

DATABASE_URL = "postgresql+asyncpg://enterprise_user:enterprise_password_2024@localhost:5432/enterprise_auth"

async def test_verification(token: str):
    """Test the verification service directly."""

    engine = create_async_engine(DATABASE_URL)
    async_session = sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)

    async with async_session() as session:
        try:
            print("🧪 Testing EmailVerificationService directly...")
            print("=" * 50)

            # Initialize services
            user_repo = UserRepository(session)
            email_service = EmailVerificationService(session, user_repo)

            print(f"✅ Services initialized")
            print(f"   Token: {token[:8]}...")

            # Call verify_email
            result = await email_service.verify_email(
                verification_token=token,
                ip_address="127.0.0.1",
                user_agent="test-script"
            )

            print(f"✅ Verification successful: {result}")

        except Exception as e:
            print(f"❌ Error during verification:")
            print(f"   Error Type: {type(e).__name__}")
            print(f"   Error Message: {str(e)}")
            print(f"\n📝 Full Traceback:")
            traceback.print_exc()

        finally:
            await engine.dispose()

if __name__ == "__main__":
    token = "3XmJEqGIHpqdvRMrM8iDLDGZlZfoUxM9Hp0U7v4RsBw"
    asyncio.run(test_verification(token))