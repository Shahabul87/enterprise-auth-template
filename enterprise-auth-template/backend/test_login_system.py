#!/usr/bin/env python3
"""
Test login system with actual user credentials
"""

import asyncio
import json
import httpx
from datetime import datetime

# Test credentials
EMAIL = "sham251087@gmail.com"
PASSWORD = "ShaM2510*##&*"
API_BASE_URL = "http://localhost:8000"

async def test_login():
    """Test the complete login flow"""

    print("=" * 60)
    print("LOGIN SYSTEM TEST")
    print("=" * 60)
    print(f"Testing with user: {EMAIL}")
    print(f"API URL: {API_BASE_URL}")
    print("-" * 60)

    async with httpx.AsyncClient() as client:
        # 1. Test login endpoint
        print("\n1. Testing Login Endpoint...")
        login_data = {
            "username": EMAIL,  # OAuth2PasswordRequestForm expects 'username'
            "password": PASSWORD,
            "grant_type": "password"
        }

        try:
            response = await client.post(
                f"{API_BASE_URL}/api/v1/auth/login",
                data=login_data,  # Use form data, not JSON
                headers={"Content-Type": "application/x-www-form-urlencoded"}
            )

            print(f"   Status Code: {response.status_code}")

            if response.status_code == 200:
                data = response.json()
                print("   ✅ LOGIN SUCCESSFUL!")
                print(f"   Response: {json.dumps(data, indent=2)}")

                # Extract tokens
                if "data" in data:
                    access_token = data["data"].get("access_token")
                    token_type = data["data"].get("token_type", "Bearer")
                    user_info = data["data"].get("user", {})

                    print(f"\n   User Info:")
                    print(f"   - ID: {user_info.get('id')}")
                    print(f"   - Email: {user_info.get('email')}")
                    print(f"   - Name: {user_info.get('full_name')}")
                    print(f"   - Active: {user_info.get('is_active')}")
                    print(f"   - Verified: {user_info.get('email_verified')}")

                    # 2. Test authenticated endpoint
                    if access_token:
                        print("\n2. Testing Authenticated Access...")
                        headers = {"Authorization": f"{token_type} {access_token}"}

                        # Get current user profile
                        me_response = await client.get(
                            f"{API_BASE_URL}/api/v1/auth/me",
                            headers=headers
                        )

                        if me_response.status_code == 200:
                            me_data = me_response.json()
                            print("   ✅ Profile Retrieved Successfully!")
                            print(f"   Profile: {json.dumps(me_data, indent=2)}")
                        else:
                            print(f"   ❌ Profile request failed: {me_response.status_code}")
                            print(f"   Error: {me_response.text}")

                    return True
                else:
                    print("   ⚠️ Unexpected response format")
                    return False

            else:
                print(f"   ❌ LOGIN FAILED!")
                error_data = response.json()
                print(f"   Error: {json.dumps(error_data, indent=2)}")

                # Common issues
                if response.status_code == 401:
                    print("\n   Possible issues:")
                    print("   - Incorrect password")
                    print("   - Account not found")
                    print("   - Account locked")
                elif response.status_code == 403:
                    print("\n   Possible issues:")
                    print("   - Email not verified")
                    print("   - Account suspended")
                elif response.status_code == 422:
                    print("\n   Validation error - check request format")

                return False

        except httpx.ConnectError:
            print("   ❌ Cannot connect to server!")
            print("   Make sure the backend is running on port 8000")
            print("   Run: cd backend && uvicorn app.main:app --reload")
            return False
        except Exception as e:
            print(f"   ❌ Error: {e}")
            return False

    print("\n" + "=" * 60)

async def check_database_user():
    """Check if user exists in database"""
    print("\n3. Checking Database...")

    from sqlalchemy import create_engine, text
    from app.core.config import get_settings

    settings = get_settings()

    # Use sync engine for simple query
    engine = create_engine(str(settings.DATABASE_URL).replace("+asyncpg", ""))

    with engine.connect() as conn:
        result = conn.execute(
            text("SELECT email, email_verified, is_active, failed_login_attempts FROM users WHERE email = :email"),
            {"email": EMAIL}
        )
        user = result.fetchone()

        if user:
            print(f"   ✅ User found in database")
            print(f"   - Email: {user.email}")
            print(f"   - Email Verified: {user.email_verified}")
            print(f"   - Active: {user.is_active}")
            print(f"   - Failed Attempts: {user.failed_login_attempts}")
        else:
            print(f"   ❌ User not found in database")

    engine.dispose()

if __name__ == "__main__":
    print("\nStarting login system test...")
    print("Make sure the backend server is running!")
    print("If not, run: cd backend && uvicorn app.main:app --reload\n")

    # Run tests
    asyncio.run(test_login())
    asyncio.run(check_database_user())

    print("\nTest complete!")