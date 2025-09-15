#!/usr/bin/env python3
"""Test complete authentication flow that ACTUALLY WORKS."""

import asyncio
import httpx
import json
import time

async def working_auth_test():
    """Create a user properly through the API and test login."""

    async with httpx.AsyncClient() as client:
        # Generate unique email
        timestamp = int(time.time())
        email = f"working{timestamp}@example.com"
        password = "WorkingPass123!"

        print("🔧 COMPLETE WORKING AUTHENTICATION TEST")
        print("=" * 60)

        # 1. Register through API
        print("1️⃣ REGISTRATION")
        print("-" * 40)
        print(f"   Email: {email}")
        print(f"   Password: {password}")

        register_response = await client.post(
            'http://localhost:8000/api/v1/auth/register',
            json={
                'email': email,
                'password': password,
                'full_name': 'Working Test User',
                'confirm_password': password
            }
        )

        print(f"   Status: {register_response.status_code}")

        if register_response.status_code == 201:
            print("   ✅ Registration successful")

            # 2. Get verification token and verify
            from sqlalchemy.ext.asyncio import create_async_engine
            from sqlalchemy import text

            DATABASE_URL = 'postgresql+asyncpg://enterprise_user:enterprise_password_2024@localhost:5432/enterprise_auth'
            engine = create_async_engine(DATABASE_URL)

            async with engine.begin() as conn:
                # Get user id
                user_result = await conn.execute(
                    text('SELECT id FROM users WHERE email = :email'),
                    {'email': email}
                )
                user_row = user_result.fetchone()

                if user_row:
                    # Get verification token
                    token_result = await conn.execute(
                        text('SELECT token FROM email_verification_tokens WHERE user_id = :user_id'),
                        {'user_id': user_row.id}
                    )
                    token_row = token_result.fetchone()

                    if token_row:
                        # 3. Verify email
                        print("\n2️⃣ EMAIL VERIFICATION")
                        print("-" * 40)

                        verify_response = await client.get(
                            f'http://localhost:8000/api/v1/auth/verify-email/{token_row.token}'
                        )

                        print(f"   Status: {verify_response.status_code}")
                        if verify_response.status_code == 200:
                            print("   ✅ Email verified")

                            # 4. Test login
                            print("\n3️⃣ LOGIN")
                            print("-" * 40)

                            # Wait a moment to avoid rate limiting
                            await asyncio.sleep(1)

                            login_response = await client.post(
                                'http://localhost:8000/api/v1/auth/login',
                                json={'email': email, 'password': password}
                            )

                            print(f"   Status: {login_response.status_code}")

                            if login_response.status_code == 200:
                                data = login_response.json()
                                if data.get('success'):
                                    print("   ✅ Login successful!")

                                    auth_data = data.get('data', {})
                                    user_data = auth_data.get('user', {})

                                    print("\n" + "=" * 60)
                                    print("🎉🎉🎉 AUTHENTICATION SYSTEM WORKING! 🎉🎉🎉")
                                    print("=" * 60)
                                    print("✅ Registration: WORKING")
                                    print("✅ Email Verification: WORKING")
                                    print("✅ Login: WORKING")
                                    print("\n📋 User Details:")
                                    print(f"   Email: {user_data.get('email')}")
                                    print(f"   Name: {user_data.get('full_name')}")
                                    print(f"   Verified: {user_data.get('email_verified')}")
                                    print("\n🔑 Authentication Token:")
                                    print(f"   {auth_data.get('access_token', '')[:50]}...")
                                    print("=" * 60)
                                else:
                                    print("   ❌ Login failed (success=false)")
                            elif login_response.status_code == 429:
                                print("   ⚠️ Rate limited (try again in a minute)")
                            elif login_response.status_code == 401:
                                # Try to understand why
                                error_data = login_response.json()
                                print(f"   ❌ Authentication failed")
                                print(f"   Error: {error_data}")
                            else:
                                print(f"   ❌ Unexpected status: {login_response.status_code}")
                        else:
                            print(f"   ❌ Verification failed: {verify_response.status_code}")
                    else:
                        print("   ❌ No verification token found")
                else:
                    print("   ❌ User not found in database")

            await engine.dispose()
        else:
            print(f"   ❌ Registration failed: {register_response.status_code}")
            print(f"   Response: {register_response.text}")

if __name__ == "__main__":
    asyncio.run(working_auth_test())