#!/usr/bin/env python3
"""
Test Authentication Flow Script
Tests backend, frontend, and mobile app authentication integration
"""

import requests
import json
import time
import random
import sys

BASE_URL = "http://localhost:8000"
API_PREFIX = "/api/v1/v1"  # Note: Backend has double v1 in routing

class AuthenticationTester:
    def __init__(self):
        self.session = requests.Session()
        self.test_email = f"testuser{int(time.time())}{random.randint(1000, 9999)}@example.com"
        self.test_password = "SecurePass123!"
        self.test_name = "Test User"
        self.access_token = None
        self.refresh_token = None

    def test_health(self):
        """Test health endpoint"""
        print("\n1. Testing Health Endpoint...")
        try:
            response = self.session.get(f"{BASE_URL}/health")
            if response.status_code == 200:
                data = response.json()
                print(f"✅ Health check passed: {data}")
                return True
            else:
                print(f"❌ Health check failed: {response.status_code}")
                return False
        except Exception as e:
            print(f"❌ Health check error: {e}")
            return False

    def test_registration(self):
        """Test user registration"""
        print("\n2. Testing Registration...")
        print(f"   Using email: {self.test_email}")

        try:
            response = self.session.post(
                f"{BASE_URL}{API_PREFIX}/register",
                json={
                    "email": self.test_email,
                    "password": self.test_password,
                    "name": self.test_name
                }
            )

            if response.status_code == 201:
                data = response.json()
                print(f"✅ Registration successful!")
                print(f"   Response: {json.dumps(data, indent=2)}")
                return True
            else:
                print(f"❌ Registration failed: {response.status_code}")
                print(f"   Response: {response.text}")
                return False
        except Exception as e:
            print(f"❌ Registration error: {e}")
            return False

    def test_login(self, for_mobile=False):
        """Test user login"""
        client_type = "mobile" if for_mobile else "web"
        print(f"\n3. Testing Login ({client_type} client)...")

        headers = {
            "Content-Type": "application/json"
        }

        if for_mobile:
            headers["User-Agent"] = "Flutter/1.0"
            headers["Accept"] = "application/json"

        try:
            params = {"prefer_json_tokens": "true"} if for_mobile else {}
            response = self.session.post(
                f"{BASE_URL}{API_PREFIX}/login",
                json={
                    "email": self.test_email,
                    "password": self.test_password
                },
                headers=headers,
                params=params
            )

            if response.status_code == 200:
                data = response.json()
                print(f"✅ Login successful!")

                # Extract tokens based on response structure
                if "data" in data:
                    auth_data = data["data"]
                    if "access_token" in auth_data:
                        self.access_token = auth_data["access_token"]
                        print(f"   Access token received: {self.access_token[:50]}...")
                    if "refresh_token" in auth_data:
                        self.refresh_token = auth_data["refresh_token"]
                        print(f"   Refresh token received: {self.refresh_token[:50]}...")

                    # Check for cookies (web client)
                    if not for_mobile and response.cookies:
                        print(f"   Cookies set: {list(response.cookies.keys())}")

                return True
            else:
                print(f"❌ Login failed: {response.status_code}")
                print(f"   Response: {response.text}")
                return False
        except Exception as e:
            print(f"❌ Login error: {e}")
            return False

    def test_protected_endpoint(self):
        """Test accessing protected endpoint"""
        print("\n4. Testing Protected Endpoint Access...")

        if not self.access_token:
            print("⚠️  No access token available, trying with cookies")

        headers = {}
        if self.access_token:
            headers["Authorization"] = f"Bearer {self.access_token}"

        try:
            response = self.session.get(
                f"{BASE_URL}{API_PREFIX}/me",
                headers=headers
            )

            if response.status_code == 200:
                data = response.json()
                print(f"✅ Protected endpoint access successful!")
                print(f"   User data: {json.dumps(data, indent=2)}")
                return True
            else:
                print(f"❌ Protected endpoint access failed: {response.status_code}")
                print(f"   Response: {response.text}")
                return False
        except Exception as e:
            print(f"❌ Protected endpoint error: {e}")
            return False

    def test_token_refresh(self):
        """Test token refresh"""
        print("\n5. Testing Token Refresh...")

        if not self.refresh_token:
            print("⚠️  No refresh token available, skipping")
            return False

        try:
            response = self.session.post(
                f"{BASE_URL}{API_PREFIX}/refresh",
                json={"refresh_token": self.refresh_token},
                headers={"Content-Type": "application/json"}
            )

            if response.status_code == 200:
                data = response.json()
                print(f"✅ Token refresh successful!")

                if "data" in data and "access_token" in data["data"]:
                    self.access_token = data["data"]["access_token"]
                    print(f"   New access token: {self.access_token[:50]}...")

                return True
            else:
                print(f"❌ Token refresh failed: {response.status_code}")
                print(f"   Response: {response.text}")
                return False
        except Exception as e:
            print(f"❌ Token refresh error: {e}")
            return False

    def test_logout(self):
        """Test logout"""
        print("\n6. Testing Logout...")

        headers = {}
        if self.access_token:
            headers["Authorization"] = f"Bearer {self.access_token}"

        try:
            response = self.session.post(
                f"{BASE_URL}{API_PREFIX}/logout",
                headers=headers
            )

            if response.status_code in [200, 204]:
                print(f"✅ Logout successful!")
                return True
            else:
                print(f"❌ Logout failed: {response.status_code}")
                print(f"   Response: {response.text}")
                return False
        except Exception as e:
            print(f"❌ Logout error: {e}")
            return False

    def run_all_tests(self):
        """Run all authentication tests"""
        print("=" * 60)
        print("AUTHENTICATION FLOW TEST")
        print("=" * 60)

        results = []

        # Test basic health
        results.append(("Health Check", self.test_health()))

        # Test registration
        results.append(("Registration", self.test_registration()))

        # Test web client login
        results.append(("Web Login", self.test_login(for_mobile=False)))

        # Test protected endpoint
        results.append(("Protected Endpoint", self.test_protected_endpoint()))

        # Test token refresh
        results.append(("Token Refresh", self.test_token_refresh()))

        # Test logout
        results.append(("Logout", self.test_logout()))

        # Create new session for mobile test
        self.session = requests.Session()

        # Test mobile client login
        results.append(("Mobile Login", self.test_login(for_mobile=True)))

        # Summary
        print("\n" + "=" * 60)
        print("TEST SUMMARY")
        print("=" * 60)

        for test_name, passed in results:
            status = "✅ PASSED" if passed else "❌ FAILED"
            print(f"{test_name:20} {status}")

        total = len(results)
        passed = sum(1 for _, p in results if p)
        print(f"\nTotal: {passed}/{total} tests passed")

        return passed == total

if __name__ == "__main__":
    tester = AuthenticationTester()
    success = tester.run_all_tests()
    sys.exit(0 if success else 1)