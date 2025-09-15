#!/usr/bin/env python3
"""Debug password verification issue."""

import asyncio
from sqlalchemy.ext.asyncio import create_async_engine
from sqlalchemy import text
import bcrypt

DATABASE_URL = 'postgresql+asyncpg://enterprise_user:enterprise_password_2024@localhost:5432/enterprise_auth'

async def debug_password():
    engine = create_async_engine(DATABASE_URL)

    async with engine.begin() as conn:
        # Get a recent test user
        result = await conn.execute(
            text("""
                SELECT id, email, hashed_password, is_verified, is_active
                FROM users
                WHERE email LIKE 'authtest%'
                ORDER BY created_at DESC
                LIMIT 1
            """)
        )
        user = result.fetchone()

        if user:
            print(f"👤 User found:")
            print(f"   Email: {user.email}")
            print(f"   Is Verified: {user.is_verified}")
            print(f"   Is Active: {user.is_active}")
            print(f"   Hashed Password: {user.hashed_password[:20]}...")

            # Test password verification
            test_password = "SecurePass123!"
            password_bytes = test_password.encode('utf-8')
            hashed_bytes = user.hashed_password.encode('utf-8')

            print(f"\n🔑 Testing password verification:")
            print(f"   Test Password: {test_password}")

            try:
                is_valid = bcrypt.checkpw(password_bytes, hashed_bytes)
                print(f"   Password Valid: {is_valid}")
            except Exception as e:
                print(f"   Error checking password: {e}")

            # Also check if password was double-hashed
            print(f"\n🔍 Checking for double-hashing:")
            try:
                # Try to verify the hash as if it was the plain password
                is_double_hashed = bcrypt.checkpw(user.hashed_password.encode('utf-8'), hashed_bytes)
                print(f"   Double-hashed: {is_double_hashed}")
            except:
                print(f"   Not double-hashed (good)")

        else:
            print("❌ No test user found")

    await engine.dispose()

if __name__ == "__main__":
    print("\n🔍 DEBUGGING PASSWORD VERIFICATION")
    print("=" * 60)
    asyncio.run(debug_password())