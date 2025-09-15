#!/usr/bin/env python3
"""
Test password reset flow with real email
"""

import requests
import json
import time

def test_forgot_password():
    """Test forgot password endpoint - request reset email"""

    url = "http://localhost:8000/api/v1/auth/forgot-password"

    # Test with the registered email
    data = {
        "email": "shahabul7115+test1@gmail.com"
    }

    print(f"📧 Testing forgot password for: {data['email']}")
    print(f"   URL: {url}")
    print()

    try:
        response = requests.post(url, json=data)

        print(f"📬 Response Status: {response.status_code}")
        print(f"📄 Response Body:")
        print(json.dumps(response.json(), indent=2))

        if response.status_code == 200:
            print("\n✅ Password reset email sent successfully!")
            print("📧 Check your email (shahabul7115@gmail.com) for the reset link")
            print("   Subject: 'Reset your password'")
            return True
        else:
            print(f"\n❌ Failed with status {response.status_code}")
            return False

    except requests.exceptions.ConnectionError:
        print("❌ Error: Could not connect to backend server")
        print("   Make sure the backend is running: uvicorn app.main:app --reload")
        return False
    except Exception as e:
        print(f"❌ Unexpected error: {e}")
        return False

def test_reset_password_with_token(token, new_password):
    """Test password reset with token"""

    url = "http://localhost:8000/api/v1/auth/reset-password"

    data = {
        "token": token,
        "new_password": new_password
    }

    print(f"\n🔐 Testing password reset with token")
    print(f"   URL: {url}")
    print(f"   New password: {new_password}")
    print()

    try:
        response = requests.post(url, json=data)

        print(f"📬 Response Status: {response.status_code}")
        print(f"📄 Response Body:")
        print(json.dumps(response.json(), indent=2))

        if response.status_code == 200:
            print("\n✅ Password reset successful!")
            print("🔐 You can now login with your new password")
            return True
        else:
            print(f"\n❌ Password reset failed with status {response.status_code}")
            return False

    except Exception as e:
        print(f"❌ Unexpected error: {e}")
        return False

def test_login_with_new_password(email, password):
    """Test login with the new password"""

    url = "http://localhost:8000/api/v1/auth/login"

    data = {
        "username": email,  # API expects username field for email
        "password": password
    }

    print(f"\n🔑 Testing login with new password")
    print(f"   Email: {email}")
    print()

    try:
        response = requests.post(url, data=data)  # Form data, not JSON

        print(f"📬 Response Status: {response.status_code}")

        if response.status_code == 200:
            result = response.json()
            print(f"📄 Response Body:")
            print(json.dumps(result, indent=2))
            print("\n✅ Login successful with new password!")
            return True
        else:
            print(f"📄 Response Body:")
            print(json.dumps(response.json(), indent=2))
            print(f"\n❌ Login failed with status {response.status_code}")
            return False

    except Exception as e:
        print(f"❌ Unexpected error: {e}")
        return False

if __name__ == "__main__":
    print("=" * 60)
    print("Testing Password Reset Flow with Real Email")
    print("=" * 60)

    # Step 1: Request password reset email
    success = test_forgot_password()

    if success:
        print("\n" + "=" * 60)
        print("📋 NEXT STEPS:")
        print("=" * 60)
        print("1. Check your Gmail inbox for the password reset email")
        print("2. The reset link will look like:")
        print("   http://localhost:3000/auth/reset-password?token=...")
        print()
        print("3. Copy the token from the URL (after token=)")
        print()
        print("4. Run this command with your token:")
        print("   python3 test_password_reset.py --token YOUR_TOKEN")
        print()
        print("OR manually test the reset:")
        print()
        print("# Reset password with token from email:")
        print('curl -X POST http://localhost:8000/api/v1/auth/reset-password \\')
        print('  -H "Content-Type: application/json" \\')
        print('  -d \'{"token": "YOUR_TOKEN", "new_password": "NewPassword456!"}\'')
        print("=" * 60)

        # If token is provided as command line argument, test it
        import sys
        if len(sys.argv) > 2 and sys.argv[1] == '--token':
            token = sys.argv[2]
            new_password = "NewTestPassword456!"

            print(f"\n🔄 Testing password reset with provided token...")
            time.sleep(2)

            if test_reset_password_with_token(token, new_password):
                print("\n⏳ Waiting 2 seconds before testing login...")
                time.sleep(2)

                test_login_with_new_password("shahabul7115+test1@gmail.com", new_password)