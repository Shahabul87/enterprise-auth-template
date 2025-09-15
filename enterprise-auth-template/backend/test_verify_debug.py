#!/usr/bin/env python3
"""Debug script for email verification issue."""

import asyncio
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from sqlalchemy import text

DATABASE_URL = "postgresql+asyncpg://enterprise_user:enterprise_password_2024@localhost:5432/enterprise_auth"

async def check_verification_token(token: str):
    """Check what's happening with the verification token."""

    engine = create_async_engine(DATABASE_URL)
    async_session = sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)

    async with async_session() as session:
        try:
            # Check if token exists
            result = await session.execute(
                text("SELECT * FROM email_verification_tokens WHERE token = :token"),
                {"token": token}
            )
            token_row = result.fetchone()

            if not token_row:
                print("❌ Token not found in database")
                return

            print(f"✅ Token found:")
            print(f"   ID: {token_row.id}")
            print(f"   User ID: {token_row.user_id}")
            print(f"   Is Used: {token_row.is_used}")
            print(f"   Expires At: {token_row.expires_at}")
            print(f"   Created At: {token_row.created_at}")

            # Check user
            user_result = await session.execute(
                text("SELECT id, email, full_name, is_verified, is_active FROM users WHERE id = :user_id"),
                {"user_id": token_row.user_id}
            )
            user_row = user_result.fetchone()

            if not user_row:
                print(f"❌ User with ID {token_row.user_id} not found!")
                return

            print(f"\n✅ User found:")
            print(f"   ID: {user_row.id}")
            print(f"   Email: {user_row.email}")
            print(f"   Full Name: {user_row.full_name}")
            print(f"   Is Verified: {user_row.is_verified}")
            print(f"   Is Active: {user_row.is_active}")

            # Check if token is expired
            from datetime import datetime, timezone
            now = datetime.now(timezone.utc)
            if token_row.expires_at < now:
                print(f"\n❌ Token is expired! (Expired at: {token_row.expires_at})")
            else:
                print(f"\n✅ Token is still valid (Expires at: {token_row.expires_at})")

        except Exception as e:
            print(f"❌ Error: {e}")
        finally:
            await engine.dispose()

if __name__ == "__main__":
    token = "3XmJEqGIHpqdvRMrM8iDLDGZlZfoUxM9Hp0U7v4RsBw"
    asyncio.run(check_verification_token(token))