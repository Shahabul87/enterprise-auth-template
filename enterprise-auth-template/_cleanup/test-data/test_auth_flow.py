#!/usr/bin/env python3
"""
Test Authentication Flow
Tests the complete authentication flow including registration, login, protected endpoints, and logout.
"""

import requests
import json
import time
from typing import Dict, Optional

BASE_URL = "http://localhost:8000"
API_PREFIX = "/api/v1/v1"  # Note: double v1 due to routing config

# Generate unique test email
timestamp = str(time.time()).replace('.', '')
TEST_EMAIL = f"testuser{timestamp}@example.com"
TEST_PASSWORD = "SecurePass123!"
TEST_NAME = "Test User"


def print_response(response: requests.Response, endpoint: str):
    """Pretty print API response."""
    print(f"\n{'='*60}")
    print(f"Endpoint: {endpoint}")
    print(f"Status Code: {response.status_code}")

    try:
        data = response.json()
        print(f"Response: {json.dumps(data, indent=2)}")
    except:
        print(f"Response Text: {response.text[:500]}")

    print('='*60)


def test_health_check():
    """Test health endpoint."""
    print("\n🔍 Testing Health Check...")
    response = requests.get(f"{BASE_URL}/health")
    print_response(response, "/health")
    return response.status_code == 200


def test_register():
    """Test user registration."""
    print(f"\n📝 Testing Registration with email: {TEST_EMAIL}")

    data = {
        "email": TEST_EMAIL,
        "password": TEST_PASSWORD,
        "name": TEST_NAME
    }

    response = requests.post(
        f"{BASE_URL}{API_PREFIX}/register",
        json=data,
        headers={"Content-Type": "application/json"}
    )

    print_response(response, f"{API_PREFIX}/register")

    if response.status_code == 201:
        print("✅ Registration successful!")
        return True
    else:
        print("❌ Registration failed!")
        return False


def test_login() -> Optional[Dict[str, str]]:
    """Test user login and return tokens."""
    print(f"\n🔐 Testing Login with email: {TEST_EMAIL}")

    # OAuth2 compatible login format
    data = {
        "username": TEST_EMAIL,  # OAuth2 spec uses 'username' field
        "password": TEST_PASSWORD,
        "grant_type": "password"
    }

    response = requests.post(
        f"{BASE_URL}{API_PREFIX}/login",
        data=data,  # Use form data for OAuth2 compatibility
        headers={"Content-Type": "application/x-www-form-urlencoded"}
    )

    print_response(response, f"{API_PREFIX}/login")

    if response.status_code == 200:
        print("✅ Login successful!")
        tokens = response.json().get("data", {})

        # Check for cookies (web client)
        if response.cookies:
            print(f"Cookies received: {list(response.cookies.keys())}")

        return tokens
    else:
        print("❌ Login failed!")
        return None


def test_protected_endpoint(access_token: str):
    """Test accessing a protected endpoint."""
    print("\n🛡️ Testing Protected Endpoint (Get Current User)...")

    headers = {
        "Authorization": f"Bearer {access_token}"
    }

    response = requests.get(
        f"{BASE_URL}{API_PREFIX}/users/me",
        headers=headers
    )

    print_response(response, f"{API_PREFIX}/users/me")

    if response.status_code == 200:
        print("✅ Protected endpoint access successful!")
        return True
    else:
        print("❌ Protected endpoint access failed!")
        return False


def test_refresh_token(refresh_token: str) -> Optional[str]:
    """Test token refresh."""
    print("\n🔄 Testing Token Refresh...")

    data = {
        "refresh_token": refresh_token
    }

    response = requests.post(
        f"{BASE_URL}{API_PREFIX}/refresh",
        json=data,
        headers={"Content-Type": "application/json"}
    )

    print_response(response, f"{API_PREFIX}/refresh")

    if response.status_code == 200:
        print("✅ Token refresh successful!")
        return response.json().get("data", {}).get("access_token")
    else:
        print("❌ Token refresh failed!")
        return None


def test_logout(access_token: str):
    """Test user logout."""
    print("\n🚪 Testing Logout...")

    headers = {
        "Authorization": f"Bearer {access_token}"
    }

    response = requests.post(
        f"{BASE_URL}{API_PREFIX}/logout",
        headers=headers
    )

    print_response(response, f"{API_PREFIX}/logout")

    if response.status_code == 200:
        print("✅ Logout successful!")
        return True
    else:
        print("❌ Logout failed!")
        return False


def run_full_auth_flow():
    """Run the complete authentication flow test."""
    print("\n" + "="*60)
    print("🚀 STARTING AUTHENTICATION FLOW TEST")
    print("="*60)

    results = {
        "health": False,
        "register": False,
        "login": False,
        "protected": False,
        "refresh": False,
        "logout": False
    }

    # Test health check
    results["health"] = test_health_check()

    # Test registration
    results["register"] = test_register()

    if results["register"]:
        # Test login
        tokens = test_login()

        if tokens and tokens.get("access_token"):
            results["login"] = True
            access_token = tokens["access_token"]
            refresh_token = tokens.get("refresh_token")

            # Test protected endpoint
            results["protected"] = test_protected_endpoint(access_token)

            # Test token refresh if refresh token is available
            if refresh_token:
                new_access_token = test_refresh_token(refresh_token)
                if new_access_token:
                    results["refresh"] = True
                    access_token = new_access_token

            # Test logout
            results["logout"] = test_logout(access_token)

    # Print summary
    print("\n" + "="*60)
    print("📊 TEST RESULTS SUMMARY")
    print("="*60)

    for test_name, passed in results.items():
        status = "✅ PASSED" if passed else "❌ FAILED"
        print(f"{test_name.capitalize():15} {status}")

    total_passed = sum(1 for passed in results.values() if passed)
    total_tests = len(results)

    print(f"\nTotal: {total_passed}/{total_tests} tests passed")

    if total_passed == total_tests:
        print("\n🎉 ALL TESTS PASSED! Authentication flow is working correctly.")
    else:
        print("\n⚠️ Some tests failed. Please check the logs above for details.")

    return total_passed == total_tests


if __name__ == "__main__":
    try:
        success = run_full_auth_flow()
        exit(0 if success else 1)
    except requests.exceptions.ConnectionError:
        print("\n❌ ERROR: Cannot connect to the backend server.")
        print("Please ensure the backend is running on http://localhost:8000")
        print("Run: cd backend && uvicorn app.main:app --reload")
        exit(1)
    except Exception as e:
        print(f"\n❌ ERROR: {e}")
        exit(1)