#!/usr/bin/env python3
"""
Test login after email verification
"""

import json
import requests

BASE_URL = "http://localhost:8000/api/v1"

def test_login():
    """Test login after email verification."""
    print("\nTesting Login After Email Verification...")
    print("="*60)

    login_data = {
        "email": "test@example.com",
        "password": "SecurePass123!"
    }

    response = requests.post(
        f"{BASE_URL}/auth/login",
        json=login_data
    )

    print(f"Status Code: {response.status_code}")
    print(f"Response:")
    print(json.dumps(response.json(), indent=2))

    if response.status_code == 200:
        data = response.json()
        if data.get("success"):
            print("\n✅ Login successful after email verification!")
            if "data" in data and "access_token" in data["data"]:
                print(f"   Access Token: {data['data']['access_token'][:50]}...")
            if "data" in data and "user" in data["data"]:
                user = data["data"]["user"]
                print(f"   User: {user.get('email')}")
                print(f"   Full Name: {user.get('full_name')}")
                print(f"   Email Verified: {user.get('email_verified')}")
                print(f"   Active: {user.get('is_active', 'N/A')}")
        else:
            print("\n❌ Login failed even after email verification!")
    else:
        print("\n❌ Login failed with error!")

if __name__ == "__main__":
    test_login()