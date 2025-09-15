#!/usr/bin/env python3
"""Test login functionality."""

import asyncio
import httpx
import json

async def test_login():
    async with httpx.AsyncClient() as client:
        # Test with the user we created earlier
        login_data = {
            "email": "logintest1757885960@example.com",
            "password": "TestPassword123!"
        }

        print(f"🔑 Testing login for: {login_data['email']}")
        print("-" * 60)

        response = await client.post(
            'http://localhost:8000/api/v1/auth/login',
            json=login_data
        )

        print(f"Status Code: {response.status_code}")

        if response.status_code == 200:
            data = response.json()
            if data.get("success"):
                print("✅ Login successful!")
                auth_data = data.get("data", {})
                print(f"   Access Token: {auth_data.get('access_token', '')[:50]}...")
                print(f"   Token Type: {auth_data.get('token_type', '')}")
                print(f"   Expires In: {auth_data.get('expires_in', '')} seconds")

                user_info = auth_data.get("user", {})
                print(f"\n👤 User Info:")
                print(f"   ID: {user_info.get('id', '')}")
                print(f"   Email: {user_info.get('email', '')}")
                print(f"   Full Name: {user_info.get('full_name', '')}")
                print(f"   Roles: {user_info.get('roles', [])}")

                print("\n✅✅✅ LOGIN TEST SUCCESSFUL! ✅✅✅")
            else:
                print("❌ Login failed (success=false)")
                print(f"Response: {json.dumps(data, indent=2)}")
        else:
            print(f"❌ Login failed with status {response.status_code}")
            print(f"Response: {response.text}")

if __name__ == "__main__":
    print("\n🧪 TESTING LOGIN FUNCTIONALITY")
    print("=" * 60)
    asyncio.run(test_login())