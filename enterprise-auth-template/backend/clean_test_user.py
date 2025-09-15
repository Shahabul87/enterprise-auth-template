#!/usr/bin/env python3
"""
Clean test user from database
"""

import asyncio
from sqlalchemy import delete, select
from app.core.database import init_db, get_db_session
from app.models.user import User
from app.models.auth import EmailVerificationToken

async def clean_test_user():
    """Remove test user and associated data."""
    await init_db()
    async for db in get_db_session():
        # Find user
        result = await db.execute(
            select(User).where(User.email == "test@example.com")
        )
        user = result.scalar_one_or_none()

        if user:
            print(f"Found user: {user.email} (ID: {user.id})")

            # Delete verification tokens
            await db.execute(
                delete(EmailVerificationToken).where(EmailVerificationToken.user_id == user.id)
            )
            print("Deleted verification tokens")

            # Delete user
            await db.execute(
                delete(User).where(User.id == user.id)
            )
            print("Deleted user")

            await db.commit()
            print("✅ Test user cleaned up successfully")
        else:
            print("No test user found")
        break  # Exit after first iteration

if __name__ == "__main__":
    asyncio.run(clean_test_user())