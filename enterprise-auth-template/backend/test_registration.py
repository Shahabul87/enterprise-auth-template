#!/usr/bin/env python3
"""
Test user registration with email verification
"""

import requests
import json

def test_registration():
    """Test user registration endpoint"""

    url = "http://localhost:8000/api/v1/auth/register"

    # Test data
    user_data = {
        "email": "shahabul7115+test2@gmail.com",
        "password": "TestPassword123!",
        "name": "Test User Two"
    }

    print(f"📧 Testing registration for: {user_data['email']}")
    print(f"   URL: {url}")
    print()

    try:
        # Make the registration request
        response = requests.post(url, json=user_data)

        print(f"📬 Response Status: {response.status_code}")
        print(f"📄 Response Body:")
        print(json.dumps(response.json(), indent=2))

        if response.status_code == 200 or response.status_code == 201:
            print("\n✅ Registration successful!")
            print("📧 Check your email (shahabul7115@gmail.com) for the verification email")
            print("   The email will be sent to your main inbox")
            print("   Subject: 'Verify your email address'")
            return True
        else:
            print(f"\n❌ Registration failed with status {response.status_code}")
            return False

    except requests.exceptions.ConnectionError:
        print("❌ Error: Could not connect to backend server")
        print("   Make sure the backend is running: uvicorn app.main:app --reload")
        return False
    except Exception as e:
        print(f"❌ Unexpected error: {e}")
        return False

if __name__ == "__main__":
    print("=" * 50)
    print("Testing User Registration with Email Verification")
    print("=" * 50)

    success = test_registration()

    if success:
        print("\n" + "=" * 50)
        print("Next steps:")
        print("1. Check your Gmail inbox for the verification email")
        print("2. Click the verification link in the email")
        print("3. Try logging in after verification")
        print("=" * 50)