#!/usr/bin/env python3
"""Test complete authentication flow: register, verify, login."""

import asyncio
import httpx
import json
import time
from sqlalchemy.ext.asyncio import create_async_engine
from sqlalchemy import text

DATABASE_URL = 'postgresql+asyncpg://enterprise_user:enterprise_password_2024@localhost:5432/enterprise_auth'

async def test_full_auth_flow():
    async with httpx.AsyncClient() as client:
        # Generate unique email
        timestamp = int(time.time())
        email = f'authtest{timestamp}@example.com'
        password = 'SecurePass123!'

        print(f"📝 Step 1: Register new user")
        print(f"   Email: {email}")
        print("-" * 60)

        # 1. Register
        register_response = await client.post(
            'http://localhost:8000/api/v1/auth/register',
            json={
                'email': email,
                'password': password,
                'full_name': 'Auth Test User',
                'confirm_password': password
            }
        )

        if register_response.status_code == 201:
            print("✅ Registration successful")

            # 2. Get verification token from database
            engine = create_async_engine(DATABASE_URL)
            async with engine.begin() as conn:
                user_result = await conn.execute(
                    text('SELECT id FROM users WHERE email = :email'),
                    {'email': email}
                )
                user_row = user_result.fetchone()

                if user_row:
                    result = await conn.execute(
                        text('SELECT token FROM email_verification_tokens WHERE user_id = :user_id ORDER BY created_at DESC LIMIT 1'),
                        {'user_id': user_row.id}
                    )
                    token_row = result.fetchone()

                    if token_row:
                        token = token_row.token
                        print(f"\n📧 Step 2: Verify email")
                        print("-" * 60)

                        # 3. Verify email
                        verify_response = await client.get(
                            f'http://localhost:8000/api/v1/auth/verify-email/{token}'
                        )

                        if verify_response.status_code == 200:
                            print("✅ Email verified successfully")

                            # 4. Login
                            print(f"\n🔑 Step 3: Login")
                            print("-" * 60)

                            login_response = await client.post(
                                'http://localhost:8000/api/v1/auth/login',
                                json={
                                    'email': email,
                                    'password': password
                                }
                            )

                            if login_response.status_code == 200:
                                data = login_response.json()
                                if data.get("success"):
                                    print("✅ Login successful!")
                                    auth_data = data.get("data", {})
                                    print(f"   Access Token: {auth_data.get('access_token', '')[:50]}...")

                                    user_info = auth_data.get("user", {})
                                    print(f"\n👤 User Info:")
                                    print(f"   ID: {user_info.get('id', '')}")
                                    print(f"   Email: {user_info.get('email', '')}")
                                    print(f"   Full Name: {user_info.get('full_name', '')}")

                                    print("\n" + "="*60)
                                    print("✅✅✅ COMPLETE AUTH FLOW SUCCESSFUL! ✅✅✅")
                                    print("="*60)
                                    print("Summary:")
                                    print("   1. ✅ User registered")
                                    print("   2. ✅ Email verified")
                                    print("   3. ✅ User logged in")
                                    print("   4. ✅ JWT tokens received")
                                    print("="*60)
                                else:
                                    print("❌ Login failed")
                                    print(f"Response: {json.dumps(data, indent=2)}")
                            else:
                                print(f"❌ Login failed: {login_response.status_code}")
                                print(f"Response: {login_response.text}")
                        else:
                            print(f"❌ Verification failed: {verify_response.status_code}")
                    else:
                        print("❌ No verification token found")
                else:
                    print("❌ User not found in database")

            await engine.dispose()
        else:
            print(f"❌ Registration failed: {register_response.status_code}")
            print(f"Response: {register_response.text}")

if __name__ == "__main__":
    print("\n🧪 TESTING COMPLETE AUTHENTICATION FLOW")
    print("=" * 60)
    asyncio.run(test_full_auth_flow())