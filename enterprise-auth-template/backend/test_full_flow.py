#!/usr/bin/env python3
"""
Test complete authentication flow with a fresh user
"""

import json
import requests
import asyncio
from sqlalchemy import delete, select
from app.core.database import init_db, get_db_session
from app.models.user import User
from app.models.auth import EmailVerificationToken

BASE_URL = "http://localhost:8000/api/v1"
TEST_EMAIL = "newtest@example.com"
TEST_PASSWORD = "SecurePass123!"

async def cleanup_test_user():
    """Clean up any existing test user."""
    await init_db()
    async for db in get_db_session():
        # Delete existing test user
        await db.execute(delete(User).where(User.email == TEST_EMAIL))
        await db.commit()
        print(f"✅ Cleaned up any existing user with email {TEST_EMAIL}")
        break

async def get_verification_token():
    """Get verification token for test user."""
    await init_db()
    async for db in get_db_session():
        # Find user
        result = await db.execute(
            select(User).where(User.email == TEST_EMAIL)
        )
        user = result.scalar_one_or_none()

        if user:
            # Get verification token
            token_result = await db.execute(
                select(EmailVerificationToken).where(EmailVerificationToken.user_id == user.id)
            )
            token = token_result.scalar_one_or_none()
            if token:
                return token.token
        break
    return None

def test_full_flow():
    """Test complete authentication flow."""
    print("\n" + "="*80)
    print("TESTING COMPLETE AUTHENTICATION FLOW WITH FRESH USER")
    print("="*80)

    # 1. Register new user
    print("\n1. REGISTERING NEW USER...")
    register_data = {
        "email": TEST_EMAIL,
        "password": TEST_PASSWORD,
        "full_name": "New Test User"
    }

    response = requests.post(
        f"{BASE_URL}/auth/register",
        json=register_data
    )

    print(f"   Status: {response.status_code}")
    if response.status_code in [200, 201]:
        print("   ✅ Registration successful")
    else:
        print(f"   ❌ Registration failed: {response.json()}")
        return

    # 2. Try login before verification
    print("\n2. ATTEMPTING LOGIN BEFORE VERIFICATION...")
    login_data = {
        "email": TEST_EMAIL,
        "password": TEST_PASSWORD
    }

    response = requests.post(
        f"{BASE_URL}/auth/login",
        json=login_data
    )

    print(f"   Status: {response.status_code}")
    if response.status_code == 401:
        print("   ✅ Login correctly blocked before verification")
    else:
        print(f"   ⚠️  Unexpected response: {response.status_code}")

    # 3. Get verification token
    print("\n3. GETTING VERIFICATION TOKEN...")
    token = asyncio.run(get_verification_token())
    if token:
        print(f"   ✅ Got token: {token[:20]}...")
    else:
        print("   ❌ Could not get verification token")
        return

    # 4. Verify email
    print("\n4. VERIFYING EMAIL...")
    response = requests.get(
        f"{BASE_URL}/auth/verify-email/{token}"
    )

    print(f"   Status: {response.status_code}")
    if response.status_code == 200:
        print("   ✅ Email verified successfully")
    else:
        print(f"   ❌ Verification failed: {response.json()}")
        return

    # 5. Try login after verification
    print("\n5. ATTEMPTING LOGIN AFTER VERIFICATION...")
    response = requests.post(
        f"{BASE_URL}/auth/login",
        json=login_data
    )

    print(f"   Status: {response.status_code}")
    if response.status_code == 200:
        data = response.json()
        if data.get("success"):
            print("   ✅ LOGIN SUCCESSFUL!")
            if "data" in data and "access_token" in data["data"]:
                print(f"      Token: {data['data']['access_token'][:50]}...")
            if "data" in data and "user" in data["data"]:
                user = data["data"]["user"]
                print(f"      User: {user.get('email')}")
                print(f"      Name: {user.get('full_name')}")
        else:
            print("   ❌ Login response indicates failure")
    else:
        print(f"   ❌ Login failed: {response.json()}")

    print("\n" + "="*80)
    print("TEST COMPLETE")
    print("="*80)

if __name__ == "__main__":
    # Clean up first
    asyncio.run(cleanup_test_user())

    # Run the test
    test_full_flow()