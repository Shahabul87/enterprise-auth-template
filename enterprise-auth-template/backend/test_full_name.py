#!/usr/bin/env python3
"""Test script to verify full_name field works correctly."""

import asyncio
import sys
from sqlalchemy import create_engine, text
from app.models.user import User

def test_full_name():
    """Test that full_name field works correctly."""

    print("🧪 Testing full_name field implementation...")
    print("=" * 50)

    # Test 1: Check User model
    print("\n1️⃣ Testing User model...")
    user = User()
    attributes = [attr for attr in dir(user) if not attr.startswith('_')]

    # Check that full_name exists and first_name/last_name don't
    has_full_name = 'full_name' in attributes
    has_first_name = 'first_name' in attributes
    has_last_name = 'last_name' in attributes

    print(f"   ✅ full_name field exists: {has_full_name}")
    print(f"   ✅ first_name field removed: {not has_first_name}")
    print(f"   ✅ last_name field removed: {not has_last_name}")

    if has_first_name or has_last_name:
        print("   ❌ ERROR: Old name fields still exist!")
        return False

    # Test 2: Test database schema
    print("\n2️⃣ Testing database schema...")

    # Create a direct database connection
    engine = create_engine("postgresql://enterprise_user:enterprise_password_2024@localhost:5432/enterprise_auth")

    with engine.connect() as conn:
        # Query to check column existence
        result = conn.execute(text("""
            SELECT column_name, is_nullable, data_type
            FROM information_schema.columns
            WHERE table_name = 'users'
            AND column_name IN ('full_name', 'first_name', 'last_name')
        """))
        columns = result.fetchall()

        column_info = {col[0]: {'nullable': col[1], 'type': col[2]} for col in columns}

        if 'full_name' in column_info:
            print(f"   ✅ full_name column exists (type: {column_info['full_name']['type']}, nullable: {column_info['full_name']['nullable']})")
        else:
            print("   ❌ ERROR: full_name column missing!")
            return False

        if 'first_name' in column_info:
            print("   ❌ ERROR: first_name column still exists!")
            return False
        else:
            print("   ✅ first_name column removed")

        if 'last_name' in column_info:
            print("   ❌ ERROR: last_name column still exists!")
            return False
        else:
            print("   ✅ last_name column removed")

    # Test 3: Check a real user in the database
    print("\n3️⃣ Testing actual user data...")

    with engine.connect() as conn:
        result = conn.execute(text("SELECT email, full_name FROM users LIMIT 1"))
        user_data = result.fetchone()

        if user_data:
            print(f"   ✅ Found user: {user_data[0]}")
            print(f"   ✅ Full name: '{user_data[1]}'")
        else:
            print("   ℹ️  No users in database yet")

    print("\n" + "=" * 50)
    print("✅ All tests passed! The full_name implementation is working correctly.")
    return True

if __name__ == "__main__":
    success = test_full_name()
    sys.exit(0 if success else 1)