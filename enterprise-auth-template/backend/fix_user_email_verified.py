#!/usr/bin/env python3
"""
Fix email_verified field for test user
"""

import asyncio
from datetime import datetime
from sqlalchemy import update
from app.core.database import init_db, get_db_session
from app.models.user import User

async def fix_email_verified():
    """Fix email_verified field for test user."""
    await init_db()
    async for db in get_db_session():
        # Update user's email_verified field
        stmt = (
            update(User)
            .where(User.email == "test@example.com")
            .values(
                email_verified=True,
                email_verified_at=datetime.utcnow()
            )
        )
        result = await db.execute(stmt)
        await db.commit()

        if result.rowcount > 0:
            print("✅ Fixed email_verified field for test@example.com")
        else:
            print("❌ No user found with email test@example.com")
        break

if __name__ == "__main__":
    asyncio.run(fix_email_verified())