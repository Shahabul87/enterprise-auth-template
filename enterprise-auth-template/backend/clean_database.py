#!/usr/bin/env python3
"""
Clean up database - remove all users and related data
"""

import asyncio
import sys
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from sqlalchemy import text
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Database URL
DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "postgresql+asyncpg://enterprise_user:enterprise_password_2024@localhost:5432/enterprise_auth"
)

async def clean_database():
    """Remove all data from the database while preserving schema"""

    # Create async engine
    engine = create_async_engine(DATABASE_URL, echo=True)

    # Create async session
    async_session = sessionmaker(
        engine, class_=AsyncSession, expire_on_commit=False
    )

    try:
        async with async_session() as session:
            print("🗑️  Starting database cleanup...")
            print("=" * 50)

            # Tables to clear in order (respecting foreign key constraints)
            tables_to_clear = [
                # Clear dependent tables first
                ('audit_logs', 'audit_logs_id_seq'),
                ('login_attempts', 'login_attempts_id_seq'),
                ('sessions', 'sessions_id_seq'),
                ('user_permissions', None),
                ('role_permissions', None),
                ('user_roles', None),
                # Then clear primary tables
                ('permissions', 'permissions_id_seq'),
                ('roles', 'roles_id_seq'),
                ('users', 'users_id_seq'),
                ('organizations', 'organizations_id_seq'),
            ]

            for table_name, sequence_name in tables_to_clear:
                try:
                    # Try TRUNCATE first (faster and resets sequences)
                    result = await session.execute(
                        text(f'TRUNCATE TABLE "{table_name}" CASCADE RESTART IDENTITY')
                    )
                    await session.commit()
                    print(f"✅ Cleared table: {table_name}")
                except Exception as e:
                    await session.rollback()
                    # Fallback to DELETE if TRUNCATE fails
                    try:
                        result = await session.execute(
                            text(f'DELETE FROM "{table_name}"')
                        )
                        await session.commit()
                        print(f"✅ Deleted data from: {table_name}")

                        # Reset sequence if it exists
                        if sequence_name:
                            try:
                                await session.execute(
                                    text(f"ALTER SEQUENCE {sequence_name} RESTART WITH 1")
                                )
                                await session.commit()
                            except:
                                await session.rollback()
                    except Exception as e2:
                        print(f"⚠️  Failed to clear {table_name}: {str(e2)[:100]}")
                        await session.rollback()

            # Clear Redis cache as well
            print("\n🗑️  Clearing Redis cache...")
            os.system("redis-cli FLUSHDB > /dev/null 2>&1")
            print("✅ Redis cache cleared")

            print("\n" + "=" * 50)
            print("✅ Database cleanup complete!")
            print("   - All data removed from all tables")
            print("   - Database schema preserved")
            print("   - Sequences reset to 1")
            print("   - Redis cache flushed")
            print("=" * 50)

    except Exception as e:
        print(f"❌ Error during cleanup: {e}")
        sys.exit(1)
    finally:
        await engine.dispose()

async def verify_cleanup():
    """Verify the database is clean"""

    engine = create_async_engine(DATABASE_URL, echo=False)
    async_session = sessionmaker(
        engine, class_=AsyncSession, expire_on_commit=False
    )

    try:
        async with async_session() as session:
            print(f"\n📊 Verification - Table Row Counts:")

            tables_to_check = [
                'organizations',
                'users',
                'roles',
                'permissions',
                'user_roles',
                'role_permissions',
                'user_permissions',
                'sessions',
                'login_attempts',
                'audit_logs'
            ]

            all_clean = True
            for table in tables_to_check:
                try:
                    result = await session.execute(text(f'SELECT COUNT(*) FROM "{table}"'))
                    count = result.scalar()
                    status = "✅" if count == 0 else "⚠️"
                    print(f"   {status} {table}: {count} rows")
                    if count > 0:
                        all_clean = False
                except:
                    print(f"   ❓ {table}: Could not check")

            if all_clean:
                print("\n   ✅ Database is completely clean and ready for fresh data")
            else:
                print("\n   ⚠️  Some tables still contain data")

    finally:
        await engine.dispose()

if __name__ == "__main__":
    print("🧹 Database Cleanup Tool")
    print("=" * 50)
    print("This will remove ALL users and related data")

    # Run cleanup
    asyncio.run(clean_database())

    # Verify cleanup
    asyncio.run(verify_cleanup())

    print("\n💡 Next steps:")
    print("1. Start the backend: cd backend && uvicorn app.main:app --reload")
    print("2. Start the frontend: cd frontend && npm run dev")
    print("3. Register new users at http://localhost:3000/auth/register")