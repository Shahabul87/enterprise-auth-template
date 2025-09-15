#!/usr/bin/env python3
"""
Final test of login for verified user
"""

import json
import requests

BASE_URL = "http://localhost:8000/api/v1"

def test_login(email, password):
    """Test login."""
    print(f"\nTesting Login for {email}...")
    print("="*60)

    login_data = {
        "email": email,
        "password": password
    }

    response = requests.post(
        f"{BASE_URL}/auth/login",
        json=login_data
    )

    print(f"Status Code: {response.status_code}")
    if response.status_code == 200:
        data = response.json()
        if data.get("success"):
            print("\n✅ LOGIN SUCCESSFUL!")
            if "data" in data:
                if "access_token" in data["data"] and data["data"]["access_token"]:
                    print(f"   Access Token: {data['data']['access_token'][:50]}...")
                if "user" in data["data"]:
                    user = data["data"]["user"]
                    print(f"   User Email: {user.get('email')}")
                    print(f"   Full Name: {user.get('full_name')}")
                    print(f"   Email Verified: {user.get('email_verified')}")
                    print(f"   Roles: {user.get('roles', [])}")
        else:
            print("\n❌ Login failed - success=false")
    else:
        print(f"\n❌ Login failed with status {response.status_code}")
        print("Response:")
        print(json.dumps(response.json(), indent=2))

if __name__ == "__main__":
    # Test both users
    test_login("newtest@example.com", "SecurePass123!")
    test_login("test@example.com", "SecurePass123!")