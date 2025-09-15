#!/usr/bin/env python3
"""
Database Data Reset Script
Clears all data from database tables while preserving schema structure.
"""

import asyncio
import sys
from pathlib import Path
from sqlalchemy import text, MetaData
from sqlalchemy.ext.asyncio import create_async_engine

# Add project root to path
sys.path.insert(0, str(Path(__file__).parent))

from app.core.config import get_settings
from app.core.database import Base

settings = get_settings()


async def reset_database_data():
    """Reset all data in database while preserving schema."""

    # Create engine with the database URL
    # Convert sync database URL to async
    database_url = str(settings.DATABASE_URL)
    if database_url.startswith("postgresql://"):
        database_url = database_url.replace("postgresql://", "postgresql+asyncpg://")
    elif database_url.startswith("postgresql+psycopg2://"):
        database_url = database_url.replace("postgresql+psycopg2://", "postgresql+asyncpg://")

    engine = create_async_engine(
        database_url,
        echo=True,
        future=True
    )

    async with engine.begin() as conn:
        print("🔄 Starting database data reset...")
        print("⚠️  WARNING: This will DELETE ALL DATA from your database!")
        print("✅ Schema and table structures will be preserved.")

        # Get user confirmation
        confirm = input("\nType 'RESET' to confirm data deletion: ")
        if confirm != 'RESET':
            print("❌ Operation cancelled.")
            return

        try:
            # Disable foreign key checks temporarily
            await conn.execute(text("SET session_replication_role = 'replica';"))

            # Get all table names from the Base metadata
            metadata = MetaData()
            await conn.run_sync(metadata.reflect)

            # Tables to exclude from deletion (system tables)
            exclude_tables = {'alembic_version'}  # Keep migration history

            # Delete data from all tables in reverse dependency order
            tables_to_clear = [
                'audit_logs',
                'login_attempts',
                'sessions',
                'user_permissions',
                'role_permissions',
                'user_roles',
                'permissions',
                'roles',
                'users',
                'organizations',
                # Add any other tables here in reverse dependency order
            ]

            print("\n📊 Clearing data from tables...")
            for table_name in tables_to_clear:
                if table_name not in exclude_tables:
                    try:
                        result = await conn.execute(text(f'DELETE FROM "{table_name}" CASCADE;'))
                        print(f"  ✓ Cleared table: {table_name}")
                    except Exception as e:
                        print(f"  ⚠️  Skipped {table_name}: {str(e)}")

            # Reset sequences (PostgreSQL specific)
            print("\n🔢 Resetting sequences...")
            sequence_reset_queries = [
                "SELECT setval(pg_get_serial_sequence('users', 'id'), 1, false);",
                "SELECT setval(pg_get_serial_sequence('roles', 'id'), 1, false);",
                "SELECT setval(pg_get_serial_sequence('permissions', 'id'), 1, false);",
                "SELECT setval(pg_get_serial_sequence('organizations', 'id'), 1, false);",
                "SELECT setval(pg_get_serial_sequence('sessions', 'id'), 1, false);",
                "SELECT setval(pg_get_serial_sequence('audit_logs', 'id'), 1, false);",
                "SELECT setval(pg_get_serial_sequence('login_attempts', 'id'), 1, false);",
            ]

            for query in sequence_reset_queries:
                try:
                    await conn.execute(text(query))
                    print(f"  ✓ Reset sequence")
                except Exception as e:
                    print(f"  ⚠️  Sequence reset skipped: {str(e)}")

            # Re-enable foreign key checks
            await conn.execute(text("SET session_replication_role = 'origin';"))

            print("\n✅ Database data reset completed successfully!")
            print("📝 Schema and table structures have been preserved.")
            print("\n💡 To seed with test data, run: python seed_dev_data.py")

        except Exception as e:
            print(f"\n❌ Error during reset: {str(e)}")
            await conn.execute(text("SET session_replication_role = 'origin';"))
            raise

    await engine.dispose()


async def verify_schema_intact():
    """Verify that database schema is still intact after reset."""

    # Convert sync database URL to async
    database_url = str(settings.DATABASE_URL)
    if database_url.startswith("postgresql://"):
        database_url = database_url.replace("postgresql://", "postgresql+asyncpg://")
    elif database_url.startswith("postgresql+psycopg2://"):
        database_url = database_url.replace("postgresql+psycopg2://", "postgresql+asyncpg://")

    engine = create_async_engine(
        database_url,
        echo=False,
        future=True
    )

    async with engine.begin() as conn:
        print("\n🔍 Verifying schema integrity...")

        # Check if all expected tables exist
        result = await conn.execute(text("""
            SELECT table_name
            FROM information_schema.tables
            WHERE table_schema = 'public'
            ORDER BY table_name;
        """))

        tables = [row[0] for row in result]

        expected_tables = [
            'alembic_version',
            'audit_logs',
            'login_attempts',
            'organizations',
            'permissions',
            'role_permissions',
            'roles',
            'sessions',
            'user_permissions',
            'user_roles',
            'users'
        ]

        print("\n📋 Found tables:")
        for table in tables:
            status = "✓" if table in expected_tables else "?"
            print(f"  {status} {table}")

        missing_tables = set(expected_tables) - set(tables)
        if missing_tables:
            print(f"\n⚠️  Missing expected tables: {missing_tables}")
        else:
            print("\n✅ All expected tables are present!")

        # Check row counts
        print("\n📊 Table row counts:")
        for table in tables:
            if table != 'alembic_version':  # Skip migration table
                result = await conn.execute(text(f'SELECT COUNT(*) FROM "{table}";'))
                count = result.scalar()
                print(f"  {table}: {count} rows")

    await engine.dispose()


async def main():
    """Main function to run the reset process."""
    try:
        await reset_database_data()
        await verify_schema_intact()
    except Exception as e:
        print(f"\n❌ Fatal error: {str(e)}")
        sys.exit(1)


if __name__ == "__main__":
    print("=" * 60)
    print("DATABASE DATA RESET UTILITY")
    print("=" * 60)
    asyncio.run(main())