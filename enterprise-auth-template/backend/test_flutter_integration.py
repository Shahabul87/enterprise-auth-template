#!/usr/bin/env python3
"""
Flutter-Backend Integration Test Suite

This script tests the integration between the Flutter app and the backend API
to ensure all endpoints return the expected response format and data structure.
"""

import asyncio
import json
import sys
from typing import Dict, Any, Optional
import httpx
from datetime import datetime
import time

# Test configuration
API_BASE_URL = "http://localhost:8000"
API_VERSION = "v1"
API_PREFIX = f"/api/{API_VERSION}"

# Test user data
TEST_USER = {
    "email": "flutter.test@example.com",
    "password": "TestPassword123!",
    "name": "Flutter Test User",
    "confirm_password": "TestPassword123!",
    "agree_to_terms": True
}


class FlutterIntegrationTester:
    """Test suite for Flutter-Backend integration."""
    
    def __init__(self, base_url: str = API_BASE_URL):
        self.base_url = base_url
        self.api_url = f"{base_url}{API_PREFIX}"
        self.client = httpx.AsyncClient(timeout=30.0)
        self.access_token: Optional[str] = None
        self.refresh_token: Optional[str] = None
        self.test_results = []
    
    async def __aenter__(self):
        return self
    
    async def __aexit__(self, exc_type, exc_val, exc_tb):
        await self.client.aclose()
    
    def log_test(self, test_name: str, success: bool, details: str = ""):
        """Log test result."""
        status = "✅ PASS" if success else "❌ FAIL"
        print(f"{status} {test_name}")
        if details:
            print(f"    {details}")
        
        self.test_results.append({
            "test": test_name,
            "success": success,
            "details": details,
            "timestamp": datetime.now().isoformat()
        })
    
    def validate_standard_response(self, response_data: Dict[str, Any], test_name: str) -> bool:
        """Validate that response follows standardized format."""
        required_fields = ["success", "metadata"]
        
        for field in required_fields:
            if field not in response_data:
                self.log_test(test_name, False, f"Missing required field: {field}")
                return False
        
        if not isinstance(response_data["success"], bool):
            self.log_test(test_name, False, "Field 'success' must be boolean")
            return False
        
        if response_data["success"]:
            if "data" not in response_data:
                self.log_test(test_name, False, "Success response missing 'data' field")
                return False
        else:
            if "error" not in response_data:
                self.log_test(test_name, False, "Error response missing 'error' field")
                return False
            
            error = response_data["error"]
            if not all(field in error for field in ["code", "message"]):
                self.log_test(test_name, False, "Error missing required fields (code, message)")
                return False
        
        # Validate metadata
        metadata = response_data.get("metadata", {})
        if "request_id" not in metadata:
            self.log_test(test_name, False, "Missing request_id in metadata")
            return False
        
        return True
    
    def validate_user_structure(self, user_data: Dict[str, Any], test_name: str) -> bool:
        """Validate user data structure matches Flutter expectations."""
        required_fields = [
            "id", "email", "name", "isEmailVerified", "isTwoFactorEnabled",
            "roles", "permissions", "createdAt", "updatedAt"
        ]
        
        for field in required_fields:
            if field not in user_data:
                self.log_test(f"{test_name} - User Structure", False, f"Missing user field: {field}")
                return False
        
        # Validate field types
        if not isinstance(user_data["roles"], list):
            self.log_test(f"{test_name} - User Structure", False, "'roles' must be array")
            return False
        
        if not isinstance(user_data["permissions"], list):
            self.log_test(f"{test_name} - User Structure", False, "'permissions' must be array")
            return False
        
        if not isinstance(user_data["isEmailVerified"], bool):
            self.log_test(f"{test_name} - User Structure", False, "'isEmailVerified' must be boolean")
            return False
        
        return True
    
    async def test_health_endpoint(self):
        """Test health endpoint (should not be standardized)."""
        try:
            response = await self.client.get(f"{self.base_url}/health")
            
            if response.status_code != 200:
                self.log_test("Health Endpoint", False, f"Status: {response.status_code}")
                return
            
            data = response.json()
            if data.get("status") == "healthy":
                self.log_test("Health Endpoint", True, "Service is healthy")
            else:
                self.log_test("Health Endpoint", False, "Service not healthy")
        
        except Exception as e:
            self.log_test("Health Endpoint", False, f"Exception: {str(e)}")
    
    async def test_user_registration(self):
        """Test user registration with Flutter-compatible request/response."""
        try:
            # Test with Flutter-style request (name field instead of first_name/last_name)
            flutter_request = {
                "email": TEST_USER["email"],
                "password": TEST_USER["password"],
                "name": TEST_USER["name"]  # Flutter sends 'name' not first_name/last_name
            }
            
            response = await self.client.post(
                f"{self.api_url}/auth/register",
                json=flutter_request,
                headers={
                    "Content-Type": "application/json",
                    "User-Agent": "Flutter/3.0.0 (Mobile; iOS)"  # Identify as Flutter client
                }
            )
            
            if response.status_code != 201:
                self.log_test("User Registration", False, f"Status: {response.status_code}, Body: {response.text}")
                return
            
            data = response.json()
            
            # Validate standardized response format
            if not self.validate_standard_response(data, "User Registration - Format"):
                return
            
            # Validate user structure
            user_data = data["data"]
            if self.validate_user_structure(user_data, "User Registration"):
                self.log_test("User Registration", True, "User registered successfully with Flutter format")
        
        except Exception as e:
            self.log_test("User Registration", False, f"Exception: {str(e)}")
    
    async def test_user_login_json_tokens(self):
        """Test login with JSON tokens (Flutter mode)."""
        try:
            login_request = {
                "email": TEST_USER["email"],
                "password": TEST_USER["password"]
            }
            
            response = await self.client.post(
                f"{self.api_url}/auth/login",
                json=login_request,
                headers={
                    "Content-Type": "application/json",
                    "User-Agent": "Flutter/3.0.0 (Mobile; iOS)"  # Identify as Flutter client
                }
            )
            
            if response.status_code != 200:
                self.log_test("Login JSON Tokens", False, f"Status: {response.status_code}, Body: {response.text}")
                return
            
            data = response.json()
            
            # Validate standardized response format
            if not self.validate_standard_response(data, "Login JSON Tokens - Format"):
                return
            
            auth_data = data["data"]
            
            # Validate auth response structure
            required_fields = ["user", "accessToken", "tokenType", "expiresIn"]
            for field in required_fields:
                if field not in auth_data:
                    self.log_test("Login JSON Tokens", False, f"Missing auth field: {field}")
                    return
            
            # Store tokens for subsequent tests
            self.access_token = auth_data["accessToken"]
            self.refresh_token = auth_data.get("refreshToken")
            
            # Validate user structure
            if self.validate_user_structure(auth_data["user"], "Login JSON Tokens"):
                self.log_test("Login JSON Tokens", True, "Login successful with JSON tokens")
        
        except Exception as e:
            self.log_test("Login JSON Tokens", False, f"Exception: {str(e)}")
    
    async def test_token_refresh(self):
        """Test token refresh with JSON tokens."""
        if not self.refresh_token:
            self.log_test("Token Refresh", False, "No refresh token available")
            return
        
        try:
            # Test refresh with JSON body (Flutter style)
            refresh_request = {
                "refresh_token": self.refresh_token
            }
            
            response = await self.client.post(
                f"{self.api_url}/auth/refresh",
                json=refresh_request,
                headers={
                    "Content-Type": "application/json",
                    "User-Agent": "Flutter/3.0.0 (Mobile; iOS)"
                }
            )
            
            if response.status_code != 200:
                self.log_test("Token Refresh", False, f"Status: {response.status_code}, Body: {response.text}")
                return
            
            data = response.json()
            
            # Validate standardized response format
            if not self.validate_standard_response(data, "Token Refresh - Format"):
                return
            
            token_data = data["data"]
            
            # Validate token response structure
            required_fields = ["accessToken", "tokenType", "expiresIn"]
            for field in required_fields:
                if field not in token_data:
                    self.log_test("Token Refresh", False, f"Missing token field: {field}")
                    return
            
            # Update access token
            self.access_token = token_data["accessToken"]
            self.log_test("Token Refresh", True, "Token refreshed successfully")
        
        except Exception as e:
            self.log_test("Token Refresh", False, f"Exception: {str(e)}")
    
    async def test_get_user_profile(self):
        """Test getting user profile with standardized response."""
        if not self.access_token:
            self.log_test("Get User Profile", False, "No access token available")
            return
        
        try:
            response = await self.client.get(
                f"{self.api_url}/users/me",
                headers={
                    "Authorization": f"Bearer {self.access_token}",
                    "User-Agent": "Flutter/3.0.0 (Mobile; iOS)"
                }
            )
            
            if response.status_code != 200:
                self.log_test("Get User Profile", False, f"Status: {response.status_code}, Body: {response.text}")
                return
            
            data = response.json()
            
            # Validate standardized response format
            if not self.validate_standard_response(data, "Get User Profile - Format"):
                return
            
            # Validate user structure
            if self.validate_user_structure(data["data"], "Get User Profile"):
                self.log_test("Get User Profile", True, "Profile retrieved successfully")
        
        except Exception as e:
            self.log_test("Get User Profile", False, f"Exception: {str(e)}")
    
    async def test_get_permissions(self):
        """Test getting user permissions with standardized response."""
        if not self.access_token:
            self.log_test("Get Permissions", False, "No access token available")
            return
        
        try:
            response = await self.client.get(
                f"{self.api_url}/auth/permissions",
                headers={
                    "Authorization": f"Bearer {self.access_token}",
                    "User-Agent": "Flutter/3.0.0 (Mobile; iOS)"
                }
            )
            
            if response.status_code != 200:
                self.log_test("Get Permissions", False, f"Status: {response.status_code}, Body: {response.text}")
                return
            
            data = response.json()
            
            # Validate standardized response format
            if not self.validate_standard_response(data, "Get Permissions - Format"):
                return
            
            permissions = data["data"]
            if isinstance(permissions, list):
                self.log_test("Get Permissions", True, f"Retrieved {len(permissions)} permissions")
            else:
                self.log_test("Get Permissions", False, "Permissions should be an array")
        
        except Exception as e:
            self.log_test("Get Permissions", False, f"Exception: {str(e)}")
    
    async def test_logout(self):
        """Test logout functionality."""
        if not self.access_token:
            self.log_test("Logout", False, "No access token available")
            return
        
        try:
            response = await self.client.post(
                f"{self.api_url}/auth/logout",
                headers={
                    "Authorization": f"Bearer {self.access_token}",
                    "User-Agent": "Flutter/3.0.0 (Mobile; iOS)"
                }
            )
            
            if response.status_code != 200:
                self.log_test("Logout", False, f"Status: {response.status_code}, Body: {response.text}")
                return
            
            data = response.json()
            
            # Validate standardized response format
            if self.validate_standard_response(data, "Logout - Format"):
                self.log_test("Logout", True, "Logout successful")
        
        except Exception as e:
            self.log_test("Logout", False, f"Exception: {str(e)}")
    
    async def test_error_response_format(self):
        """Test that error responses follow standardized format."""
        try:
            # Test with invalid credentials
            response = await self.client.post(
                f"{self.api_url}/auth/login",
                json={
                    "email": "invalid@example.com",
                    "password": "wrongpassword"
                },
                headers={
                    "Content-Type": "application/json",
                    "User-Agent": "Flutter/3.0.0 (Mobile; iOS)"
                }
            )
            
            if response.status_code == 401:
                data = response.json()
                
                # Should still follow standardized error format
                if self.validate_standard_response(data, "Error Response Format"):
                    error = data["error"]
                    if error["code"] == "INVALID_CREDENTIALS":
                        self.log_test("Error Response Format", True, "Error response properly standardized")
                    else:
                        self.log_test("Error Response Format", False, f"Unexpected error code: {error['code']}")
                else:
                    self.log_test("Error Response Format", False, "Error response not standardized")
            else:
                self.log_test("Error Response Format", False, f"Unexpected status code: {response.status_code}")
        
        except Exception as e:
            self.log_test("Error Response Format", False, f"Exception: {str(e)}")
    
    async def run_all_tests(self):
        """Run all integration tests."""
        print("🚀 Starting Flutter-Backend Integration Tests")
        print(f"   API Base URL: {self.base_url}")
        print(f"   Test User: {TEST_USER['email']}")
        print("=" * 50)
        
        # Test health endpoint first
        await self.test_health_endpoint()
        
        # Test authentication flow
        await self.test_user_registration()
        await self.test_user_login_json_tokens()
        await self.test_token_refresh()
        
        # Test authenticated endpoints
        await self.test_get_user_profile()
        await self.test_get_permissions()
        
        # Test logout
        await self.test_logout()
        
        # Test error handling
        await self.test_error_response_format()
        
        # Print summary
        await self.print_test_summary()
    
    async def print_test_summary(self):
        """Print test summary."""
        print("\n" + "=" * 50)
        print("📊 TEST SUMMARY")
        print("=" * 50)
        
        passed = sum(1 for result in self.test_results if result["success"])
        total = len(self.test_results)
        
        print(f"Total Tests: {total}")
        print(f"Passed: {passed}")
        print(f"Failed: {total - passed}")
        print(f"Success Rate: {(passed/total*100):.1f}%" if total > 0 else "0%")
        
        if total - passed > 0:
            print("\n❌ FAILED TESTS:")
            for result in self.test_results:
                if not result["success"]:
                    print(f"  - {result['test']}: {result['details']}")
        
        print("\n" + "=" * 50)
        
        # Save detailed results to file
        with open("flutter_integration_test_results.json", "w") as f:
            json.dump({
                "summary": {
                    "total": total,
                    "passed": passed,
                    "failed": total - passed,
                    "success_rate": passed/total*100 if total > 0 else 0
                },
                "results": self.test_results,
                "timestamp": datetime.now().isoformat()
            }, f, indent=2)
        
        print("📄 Detailed results saved to: flutter_integration_test_results.json")
        
        return passed == total


async def main():
    """Main test runner."""
    if len(sys.argv) > 1:
        api_url = sys.argv[1]
    else:
        api_url = API_BASE_URL
    
    print("🧪 Flutter-Backend Integration Test Suite")
    print(f"   Testing against: {api_url}")
    print(f"   Timestamp: {datetime.now().isoformat()}")
    
    async with FlutterIntegrationTester(api_url) as tester:
        success = await tester.run_all_tests()
        
        if success:
            print("\n🎉 All tests passed! Flutter-Backend integration is working correctly.")
            sys.exit(0)
        else:
            print("\n💥 Some tests failed. Please check the results and fix the issues.")
            sys.exit(1)


if __name__ == "__main__":
    asyncio.run(main())