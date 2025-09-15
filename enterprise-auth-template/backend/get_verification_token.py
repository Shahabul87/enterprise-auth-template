#!/usr/bin/env python3
"""
Get verification token for test user
"""

import asyncio
from sqlalchemy import select
from app.core.database import init_db, get_db_session
from app.models.user import User
from app.models.auth import EmailVerificationToken

async def get_verification_token():
    """Get verification token for test user."""
    await init_db()
    async for db in get_db_session():
        # Find user
        result = await db.execute(
            select(User).where(User.email == "test@example.com")
        )
        user = result.scalar_one_or_none()

        if user:
            print(f"Found user: {user.email} (ID: {user.id})")
            print(f"  is_active: {user.is_active}")
            print(f"  is_verified: {user.is_verified}")
            print(f"  email_verified: {user.email_verified}")

            # Get verification token
            token_result = await db.execute(
                select(EmailVerificationToken).where(EmailVerificationToken.user_id == user.id)
            )
            token = token_result.scalar_one_or_none()

            if token:
                print(f"\n✅ Verification token: {token.token}")
                print(f"   Expires at: {token.expires_at}")
                print(f"   Used: {token.is_used if hasattr(token, 'is_used') else 'N/A'}")
                print(f"\nTo verify, use:")
                print(f"curl -X GET http://localhost:8000/api/v1/auth/verify-email/{token.token}")
            else:
                print("❌ No verification token found")
        else:
            print("No test user found")
        break

if __name__ == "__main__":
    asyncio.run(get_verification_token())