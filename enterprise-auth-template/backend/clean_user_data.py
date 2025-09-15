#!/usr/bin/env python3
"""
Script to clean all user data from the database.
This will remove all users and related data while preserving the schema.
"""

import asyncio
import sys
from pathlib import Path

# Add the backend directory to the path
sys.path.insert(0, str(Path(__file__).parent))

from sqlalchemy import text
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from app.core.config import get_settings
import structlog

logger = structlog.get_logger(__name__)
settings = get_settings()

# Create engine and session maker
DATABASE_URL = settings.DATABASE_URL or "postgresql+asyncpg://enterprise_user:enterprise_password_2024@localhost:5432/enterprise_auth"
engine = create_async_engine(DATABASE_URL, echo=False)
async_session_maker = sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)


async def clean_user_data():
    """Remove all user data from the database."""

    async with async_session_maker() as session:
        try:
            logger.info("Starting database cleanup...")

            # Delete in order to handle foreign key dependencies
            # Order is important - delete child tables first
            tables_to_clean = [
                "audit_logs",
                "login_attempts",
                "user_devices",
                "api_keys",
                "notifications",
                "webhook_events",
                "webhooks",
                "magic_links",
                "user_sessions",
                "refresh_tokens",
                "user_roles_association",
                "users"  # Delete users last due to foreign key constraints
            ]

            for table in tables_to_clean:
                try:
                    result = await session.execute(text(f"DELETE FROM {table}"))
                    await session.commit()
                    logger.info(f"Cleaned table: {table}", rows_deleted=result.rowcount)
                except Exception as e:
                    logger.warning(f"Could not clean table {table}: {e}")
                    await session.rollback()

            # Verify cleanup
            result = await session.execute(text("SELECT COUNT(*) FROM users"))
            user_count = result.scalar()

            if user_count == 0:
                logger.info("✅ Database cleanup successful! All user data removed.")
            else:
                logger.warning(f"⚠️ Database still contains {user_count} users")

            # Reset any sequences if needed
            await session.execute(text("ALTER SEQUENCE IF EXISTS users_id_seq RESTART WITH 1"))
            await session.commit()

            logger.info("Database is ready for fresh data!")

        except Exception as e:
            logger.error(f"Error during cleanup: {e}")
            await session.rollback()
            raise
        finally:
            await session.close()


async def main():
    """Main function."""
    print("\n⚠️  WARNING: This will DELETE ALL USER DATA from the database!")
    print("This action cannot be undone.")

    confirm = input("\nType 'yes' to confirm deletion: ")

    if confirm.lower() != 'yes':
        print("Cleanup cancelled.")
        return

    try:
        await clean_user_data()
        print("\n✅ All user data has been removed from the database.")
        print("You can now create new users.")
    except Exception as e:
        print(f"\n❌ Error during cleanup: {e}")
        sys.exit(1)
    finally:
        await engine.dispose()


if __name__ == "__main__":
    asyncio.run(main())