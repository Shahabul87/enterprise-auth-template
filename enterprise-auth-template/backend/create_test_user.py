#!/usr/bin/env python3
"""Create a test user with all proper settings for authentication."""

import asyncio
from sqlalchemy.ext.asyncio import create_async_engine
from sqlalchemy import text
from app.core.security import get_password_hash
import uuid

DATABASE_URL = 'postgresql+asyncpg://enterprise_user:enterprise_password_2024@localhost:5432/enterprise_auth'

async def create_test_user():
    """Create a fully functional test user."""

    email = "test@example.com"
    password = "Test123!"

    engine = create_async_engine(DATABASE_URL)
    async with engine.begin() as conn:
        # First check if user exists and delete if so
        await conn.execute(
            text('DELETE FROM users WHERE email = :email'),
            {'email': email}
        )

        # Create user with all necessary fields
        user_id = str(uuid.uuid4())
        hashed_password = get_password_hash(password)

        await conn.execute(
            text('''
                INSERT INTO users (
                    id, email, hashed_password, full_name,
                    is_active, is_verified, email_verified,
                    is_superuser, failed_login_attempts,
                    two_factor_enabled, is_phone_verified,
                    created_at, updated_at
                ) VALUES (
                    :id, :email, :hashed_password, :full_name,
                    true, true, true,
                    false, 0,
                    false, false,
                    NOW(), NOW()
                )
            '''),
            {
                'id': user_id,
                'email': email,
                'hashed_password': hashed_password,
                'full_name': 'Test User'
            }
        )

        # Check if we have a 'user' role, if not create it
        role_result = await conn.execute(
            text("SELECT id FROM roles WHERE name = 'user'")
        )
        role = role_result.fetchone()

        if not role:
            role_id = str(uuid.uuid4())
            await conn.execute(
                text('''
                    INSERT INTO roles (id, name, display_name, description, is_active, created_at, updated_at)
                    VALUES (:id, 'user', 'User', 'Standard user role', true, NOW(), NOW())
                '''),
                {'id': role_id}
            )
        else:
            role_id = role.id

        # Assign role to user
        await conn.execute(
            text('''
                INSERT INTO user_roles_association (user_id, role_id)
                VALUES (:user_id, :role_id)
                ON CONFLICT DO NOTHING
            '''),
            {'user_id': user_id, 'role_id': role_id}
        )

        print("✅ Test user created successfully!")
        print(f"   Email: {email}")
        print(f"   Password: {password}")
        print(f"   User ID: {user_id}")
        print("   Status: Active, Verified, With User Role")

    await engine.dispose()

if __name__ == "__main__":
    print("🔧 Creating test user...")
    asyncio.run(create_test_user())