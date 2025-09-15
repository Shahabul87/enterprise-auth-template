#!/usr/bin/env python3
"""
Check database tables and row counts
"""

import asyncio
import os
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from sqlalchemy import text
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Database URL
DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "postgresql+asyncpg://enterprise_user:enterprise_password_2024@localhost:5432/enterprise_auth"
)

async def check_database():
    """Check all tables and their row counts"""

    engine = create_async_engine(DATABASE_URL, echo=False)
    async_session = sessionmaker(
        engine, class_=AsyncSession, expire_on_commit=False
    )

    try:
        async with async_session() as session:
            print("=" * 60)
            print("DATABASE STATUS CHECK")
            print("=" * 60)

            # Get all tables in the public schema
            result = await session.execute(text("""
                SELECT table_name
                FROM information_schema.tables
                WHERE table_schema = 'public'
                AND table_type = 'BASE TABLE'
                ORDER BY table_name;
            """))

            tables = [row[0] for row in result]

            if not tables:
                print("❌ No tables found in the database!")
                print("   Run migrations: cd backend && alembic upgrade head")
                return

            print(f"\n📋 Found {len(tables)} tables in the database:\n")

            total_rows = 0
            for table in tables:
                try:
                    result = await session.execute(text(f'SELECT COUNT(*) FROM "{table}"'))
                    count = result.scalar()
                    total_rows += count

                    # Format output based on count
                    if count == 0:
                        status = "✅"
                        color = "\033[92m"  # Green
                    else:
                        status = "📊"
                        color = "\033[93m"  # Yellow

                    print(f"   {status} {color}{table:30}\033[0m {count:>6} rows")
                except Exception as e:
                    print(f"   ❌ {table:30} Error: {str(e)[:40]}")

            print("\n" + "=" * 60)
            print(f"📈 Total rows across all tables: {total_rows}")

            if total_rows == 0:
                print("✅ Database is completely clean!")
                print("\n💡 Next steps:")
                print("   1. Seed test data: python scripts/seed_dev_data.py")
                print("   2. Start backend: uvicorn app.main:app --reload")
                print("   3. Start frontend: cd ../frontend && npm run dev")
            else:
                print("⚠️  Database contains data")
                print("\n💡 To clean all data: python clean_database.py")

            print("=" * 60)

    except Exception as e:
        print(f"❌ Error checking database: {e}")
    finally:
        await engine.dispose()

if __name__ == "__main__":
    asyncio.run(check_database())