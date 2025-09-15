#!/usr/bin/env python3
"""
Test Complete Frontend Authentication Flow

This script tests the complete authentication flow from the frontend perspective:
1. Registration
2. Email verification
3. Login
4. Profile access
"""

import asyncio
import aiohttp
import json
import sys
from datetime import datetime

# Configuration
FRONTEND_URL = "http://localhost:3000"
BACKEND_URL = "http://localhost:8000"

class FrontendAuthFlowTester:
    def __init__(self):
        self.session = None
        self.test_user = {
            "email": "frontend-test-user@example.com",
            "password": "SecurePassword123!",
            "full_name": "Frontend Test User",
            "confirm_password": "SecurePassword123!",
            "agree_to_terms": True
        }
        self.tokens = {}

    async def __aenter__(self):
        self.session = aiohttp.ClientSession()
        return self

    async def __aexit__(self, exc_type, exc_val, exc_tb):
        if self.session:
            await self.session.close()

    async def test_frontend_registration(self):
        """Test user registration through frontend API"""
        print("🔄 Testing frontend registration...")

        # First check if the user already exists and clean up
        try:
            await self.cleanup_test_user()
        except:
            pass  # User doesn't exist, that's fine

        # Register user via frontend API endpoint (which proxies to backend)
        registration_data = {
            "email": self.test_user["email"],
            "password": self.test_user["password"],
            "full_name": self.test_user["full_name"],
            "confirm_password": self.test_user["confirm_password"],
            "agree_to_terms": self.test_user["agree_to_terms"]
        }

        async with self.session.post(
            f"{BACKEND_URL}/api/v1/auth/register",
            json=registration_data,
            headers={"Content-Type": "application/json"}
        ) as response:
            result = await response.json()

            if response.status == 201 and result.get("success"):
                print("✅ Frontend registration successful!")
                print(f"   Message: {result['data']['message']}")
                return True
            else:
                print(f"❌ Frontend registration failed: {result}")
                return False

    async def get_verification_token(self):
        """Get verification token from backend database (simulating email click)"""
        print("🔄 Getting verification token from database...")

        async with self.session.get(
            f"{BACKEND_URL}/debug/get-verification-token/{self.test_user['email']}"
        ) as response:
            if response.status == 200:
                result = await response.json()
                token = result.get("token")
                if token:
                    print(f"✅ Found verification token: {token[:20]}...")
                    return token
                else:
                    print("❌ No verification token found")
                    return None
            else:
                print(f"❌ Failed to get verification token: {response.status}")
                return None

    async def test_email_verification(self, token):
        """Test email verification through frontend API"""
        print("🔄 Testing email verification...")

        async with self.session.get(
            f"{BACKEND_URL}/api/v1/auth/verify-email/{token}"
        ) as response:
            result = await response.json()

            if response.status == 200 and result.get("success"):
                print("✅ Email verification successful!")
                print(f"   Message: {result['data']['message']}")
                return True
            else:
                print(f"❌ Email verification failed: {result}")
                return False

    async def test_frontend_login(self):
        """Test user login through frontend API"""
        print("🔄 Testing frontend login...")

        login_data = {
            "email": self.test_user["email"],
            "password": self.test_user["password"]
        }

        async with self.session.post(
            f"{BACKEND_URL}/api/v1/auth/login?prefer_json_tokens=true",
            json=login_data,
            headers={"Content-Type": "application/json"}
        ) as response:
            result = await response.json()

            if response.status == 200 and result.get("success"):
                auth_data = result.get("data", {})
                self.tokens = {
                    "access_token": auth_data.get("access_token"),
                    "refresh_token": auth_data.get("refresh_token"),
                    "token_type": auth_data.get("token_type", "bearer")
                }

                user_data = auth_data.get("user", {})
                print("✅ Frontend login successful!")
                print(f"   User ID: {user_data.get('id')}")
                print(f"   Email: {user_data.get('email')}")
                print(f"   Name: {user_data.get('full_name')}")
                print(f"   Email Verified: {user_data.get('isEmailVerified')}")
                print(f"   Token Type: {self.tokens['token_type']}")
                print(f"   Access Token: {self.tokens['access_token'][:20]}...")
                return True
            else:
                print(f"❌ Frontend login failed: {result}")
                return False

    async def test_protected_route_access(self):
        """Test accessing protected routes with the token"""
        print("🔄 Testing protected route access...")

        if not self.tokens.get("access_token"):
            print("❌ No access token available")
            return False

        headers = {
            "Authorization": f"{self.tokens['token_type']} {self.tokens['access_token']}",
            "Content-Type": "application/json"
        }

        async with self.session.get(
            f"{BACKEND_URL}/api/v1/profile/me",
            headers=headers
        ) as response:
            result = await response.json()

            if response.status == 200 and result.get("success"):
                user_data = result.get("data", {})
                print("✅ Protected route access successful!")
                print(f"   Profile retrieved for: {user_data.get('email')}")
                print(f"   Full name: {user_data.get('full_name')}")
                print(f"   Email verified: {user_data.get('email_verified')}")
                return True
            else:
                print(f"❌ Protected route access failed: {result}")
                return False

    async def test_token_refresh(self):
        """Test token refresh functionality"""
        print("🔄 Testing token refresh...")

        if not self.tokens.get("refresh_token"):
            print("❌ No refresh token available")
            return False

        refresh_data = {
            "refresh_token": self.tokens["refresh_token"]
        }

        async with self.session.post(
            f"{BACKEND_URL}/api/v1/auth/refresh?prefer_json_tokens=true",
            json=refresh_data,
            headers={"Content-Type": "application/json"}
        ) as response:
            result = await response.json()

            if response.status == 200 and result.get("success"):
                new_token_data = result.get("data", {})
                print("✅ Token refresh successful!")
                print(f"   New access token: {new_token_data.get('access_token', '')[:20]}...")
                return True
            else:
                print(f"❌ Token refresh failed: {result}")
                return False

    async def test_logout(self):
        """Test user logout"""
        print("🔄 Testing logout...")

        if not self.tokens.get("access_token"):
            print("❌ No access token available")
            return False

        headers = {
            "Authorization": f"{self.tokens['token_type']} {self.tokens['access_token']}",
            "Content-Type": "application/json"
        }

        async with self.session.post(
            f"{BACKEND_URL}/api/v1/auth/logout",
            headers=headers
        ) as response:
            result = await response.json()

            if response.status == 200 and result.get("success"):
                print("✅ Logout successful!")
                print(f"   Message: {result['data']['message']}")
                return True
            else:
                print(f"❌ Logout failed: {result}")
                return False

    async def cleanup_test_user(self):
        """Clean up test user for repeated testing"""
        async with self.session.delete(
            f"{BACKEND_URL}/debug/cleanup-user/{self.test_user['email']}"
        ) as response:
            if response.status == 200:
                print("🧹 Cleaned up existing test user")

async def main():
    print("🚀 Starting Frontend Authentication Flow Test")
    print("=" * 60)

    async with FrontendAuthFlowTester() as tester:
        # Test registration
        if not await tester.test_frontend_registration():
            print("❌ Registration failed, stopping test")
            return False

        print("\n" + "-" * 40)

        # Get verification token (simulating email click)
        verification_token = await tester.get_verification_token()
        if not verification_token:
            print("❌ Could not get verification token, stopping test")
            return False

        print("\n" + "-" * 40)

        # Test email verification
        if not await tester.test_email_verification(verification_token):
            print("❌ Email verification failed, stopping test")
            return False

        print("\n" + "-" * 40)

        # Test login
        if not await tester.test_frontend_login():
            print("❌ Login failed, stopping test")
            return False

        print("\n" + "-" * 40)

        # Test protected route access
        if not await tester.test_protected_route_access():
            print("❌ Protected route access failed")

        print("\n" + "-" * 40)

        # Test token refresh
        if not await tester.test_token_refresh():
            print("❌ Token refresh failed")

        print("\n" + "-" * 40)

        # Test logout
        if not await tester.test_logout():
            print("❌ Logout failed")

        print("\n" + "=" * 60)
        print("🎉 Frontend Authentication Flow Test Complete!")
        return True

if __name__ == "__main__":
    try:
        result = asyncio.run(main())
        sys.exit(0 if result else 1)
    except KeyboardInterrupt:
        print("\n🛑 Test interrupted by user")
        sys.exit(1)
    except Exception as e:
        print(f"\n💥 Test failed with error: {e}")
        sys.exit(1)