#!/usr/bin/env python3
"""Debug authentication issue by directly testing the authentication service."""

import asyncio
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from app.services.auth.authentication_service import AuthenticationService
from app.repositories.user_repository import UserRepository
from app.repositories.session_repository import SessionRepository
from app.repositories.role_repository import RoleRepository

DATABASE_URL = 'postgresql+asyncpg://enterprise_user:enterprise_password_2024@localhost:5432/enterprise_auth'

async def test_auth_directly():
    engine = create_async_engine(DATABASE_URL)
    async_session = sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)

    async with async_session() as session:
        try:
            # Initialize repositories
            user_repo = UserRepository(session)
            session_repo = SessionRepository(session)
            role_repo = RoleRepository(session)

            # Initialize auth service
            auth_service = AuthenticationService(session, user_repo, session_repo, role_repo)

            # Test authentication
            email = "authtest1757885662@example.com"
            password = "SecurePass123!"

            print(f"🔑 Testing authentication directly")
            print(f"   Email: {email}")
            print(f"   Password: {password}")
            print("-" * 60)

            try:
                result = await auth_service.authenticate(
                    email=email,
                    password=password,
                    ip_address="127.0.0.1",
                    user_agent="test-script"
                )

                print("✅ Authentication successful!")
                print(f"   Access Token: {result.access_token[:50]}...")
                print(f"   User: {result.user.email}")

            except Exception as e:
                print(f"❌ Authentication failed: {e}")
                print(f"   Error type: {type(e).__name__}")

                # Try to get more details
                user = await user_repo.find_by_email(email)
                if user:
                    print(f"\n👤 User details:")
                    print(f"   Found: Yes")
                    print(f"   ID: {user.id}")
                    print(f"   Email: {user.email}")
                    print(f"   Is Active: {user.is_active}")
                    print(f"   Is Verified: {user.is_verified}")
                    print(f"   Has Password: {bool(user.hashed_password)}")

                    # Test password directly
                    from app.core.security import verify_password
                    is_valid = verify_password(password, user.hashed_password)
                    print(f"   Password Valid (direct check): {is_valid}")
                else:
                    print(f"\n👤 User not found")

        except Exception as e:
            print(f"❌ Test error: {e}")
            import traceback
            traceback.print_exc()

        finally:
            await engine.dispose()

if __name__ == "__main__":
    print("\n🔍 DEBUGGING AUTHENTICATION SERVICE")
    print("=" * 60)
    asyncio.run(test_auth_directly())