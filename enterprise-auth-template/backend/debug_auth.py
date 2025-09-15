#!/usr/bin/env python3
"""
Debug authentication issue
"""

import asyncio
from sqlalchemy import select
from app.core.database import init_db, get_db_session
from app.models.user import User
from app.core.security import verify_password, get_password_hash

async def debug_auth():
    """Debug authentication for test user."""
    await init_db()
    async for db in get_db_session():
        # Find user
        result = await db.execute(
            select(User).where(User.email == "test@example.com")
        )
        user = result.scalar_one_or_none()

        if user:
            print(f"User found: {user.email}")
            print(f"  ID: {user.id}")
            print(f"  is_active: {user.is_active}")
            print(f"  is_verified: {user.is_verified}")
            print(f"  email_verified: {user.email_verified}")
            print(f"  has password: {bool(user.hashed_password)}")

            if user.hashed_password:
                print(f"\nTesting password verification:")
                test_password = "SecurePass123!"

                # Test password verification
                is_valid = verify_password(test_password, user.hashed_password)
                print(f"  Password '{test_password}' is valid: {is_valid}")

                # Let's also verify with a fresh hash
                fresh_hash = get_password_hash(test_password)
                print(f"\n  Fresh hash verification:")
                fresh_valid = verify_password(test_password, fresh_hash)
                print(f"  Fresh hash validates: {fresh_valid}")

                # Show hash prefix for debugging (not full hash for security)
                print(f"\n  Stored hash prefix: {user.hashed_password[:20]}...")
                print(f"  Fresh hash prefix: {fresh_hash[:20]}...")
            else:
                print("\n❌ User has no password hash stored!")
        else:
            print("No test user found")
        break

if __name__ == "__main__":
    asyncio.run(debug_auth())