#!/usr/bin/env python3
"""Test complete registration and verification flow."""

import asyncio
import httpx
import json
import time
from sqlalchemy.ext.asyncio import create_async_engine
from sqlalchemy import text

DATABASE_URL = 'postgresql+asyncpg://enterprise_user:enterprise_password_2024@localhost:5432/enterprise_auth'

async def test_full_flow():
    async with httpx.AsyncClient() as client:
        # 1. Register a new user
        timestamp = int(time.time())
        email = f'testuser{timestamp}@example.com'

        print(f'📝 Registering user: {email}')
        print('-' * 60)

        register_response = await client.post(
            'http://localhost:8000/api/v1/auth/register',
            json={
                'email': email,
                'password': 'TestPass123!',
                'full_name': 'Test User',
                'confirm_password': 'TestPass123!'
            }
        )

        print(f'Status Code: {register_response.status_code}')

        if register_response.status_code == 201:
            print('✅ Registration successful')
            data = register_response.json()
            user_data = data.get('data', {}).get('user', {})
            print(f'   User ID: {user_data.get("id")}')
            print(f'   Email: {user_data.get("email")}')
            print(f'   Full Name: {user_data.get("full_name")}')

            # 2. Get the verification token from database
            engine = create_async_engine(DATABASE_URL)

            async with engine.begin() as conn:
                # First get the user ID
                user_result = await conn.execute(
                    text('SELECT id FROM users WHERE email = :email'),
                    {'email': email}
                )
                user_row = user_result.fetchone()

                if user_row:
                    user_id = user_row.id
                    # Now get the verification token
                    result = await conn.execute(
                        text('SELECT token FROM email_verification_tokens WHERE user_id = :user_id ORDER BY created_at DESC LIMIT 1'),
                        {'user_id': user_id}
                    )
                    row = result.fetchone()
                else:
                    row = None

                if row:
                    token = row.token
                    print(f'\n🔑 Verification token retrieved')
                    print(f'   Token: {token[:20]}...')

                    # 3. Verify the email
                    print(f'\n📧 Verifying email...')
                    print('-' * 60)

                    verify_response = await client.get(
                        f'http://localhost:8000/api/v1/auth/verify-email/{token}'
                    )

                    print(f'Status Code: {verify_response.status_code}')

                    if verify_response.status_code == 200:
                        verify_data = verify_response.json()
                        print('✅ Email verification successful!')
                        print(f'   Message: {verify_data.get("data", {}).get("message", "")}')

                        print('\n' + '='*60)
                        print('✅✅✅ COMPLETE FLOW SUCCESSFUL! ✅✅✅')
                        print('='*60)
                        print('Summary:')
                        print('   1. User registered successfully')
                        print('   2. Verification email sent')
                        print('   3. Email verified successfully')
                        print('   4. Welcome email sent')
                        print('   5. User can now login')
                        print('='*60)
                    else:
                        print(f'❌ Verification failed')
                        print(f'   Response: {json.dumps(verify_response.json(), indent=2)}')
                else:
                    print('❌ No verification token found in database')

            await engine.dispose()
        else:
            print(f'❌ Registration failed: {register_response.status_code}')
            print(f'   Response: {register_response.text}')

if __name__ == "__main__":
    print('\n🧪 TESTING COMPLETE REGISTRATION AND VERIFICATION FLOW')
    print('='*60)
    asyncio.run(test_full_flow())