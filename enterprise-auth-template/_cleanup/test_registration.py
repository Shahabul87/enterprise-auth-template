#!/usr/bin/env python3
"""
Test the registration endpoint to identify issues with response handling and redirects
"""
import json
import uuid
import requests

def test_registration():
    """Test user registration endpoint"""
    print("=== Testing Registration Endpoint ===")

    # Generate unique test data
    test_email = f"test-{uuid.uuid4().hex[:8]}@example.com"

    registration_data = {
        "email": test_email,
        "password": "SecurePassword123!@#",
        "confirm_password": "SecurePassword123!@#",
        "name": "Test User Registration",
        "agree_to_terms": True
    }

    print(f"Registering user with email: {test_email}")
    print(f"Registration data: {json.dumps(registration_data, indent=2)}")

    try:
        # Test registration endpoint
        response = requests.post(
            "http://localhost:8000/api/v1/auth/register",
            json=registration_data,
            headers={"Content-Type": "application/json"}
        )

        print(f"\n=== Backend Response ===")
        print(f"Status Code: {response.status_code}")
        print(f"Headers: {dict(response.headers)}")

        try:
            response_data = response.json()
            print(f"Response Body: {json.dumps(response_data, indent=2)}")

            # Analyze the response structure
            if response.status_code == 201:
                print(f"\n=== Success Response Analysis ===")
                print(f"Success: {response_data.get('success', 'Not present')}")
                print(f"Data: {response_data.get('data', 'Not present')}")
                print(f"Error: {response_data.get('error', 'Not present')}")

                # Check for message in data
                if 'data' in response_data and isinstance(response_data['data'], dict):
                    message = response_data['data'].get('message')
                    if message:
                        print(f"Success Message: {message}")
                    else:
                        print("No success message found in data")
                        print(f"Data keys: {list(response_data['data'].keys()) if response_data['data'] else 'None'}")

            else:
                print(f"\n=== Error Response Analysis ===")
                print(f"Failed with status: {response.status_code}")

        except json.JSONDecodeError:
            print(f"Response Body (non-JSON): {response.text}")

    except Exception as e:
        print(f"Error during registration: {e}")

if __name__ == "__main__":
    test_registration()
