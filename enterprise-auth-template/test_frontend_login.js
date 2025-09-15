/**
 * Test frontend login flow
 */

const FRONTEND_URL = 'http://localhost:3003';
const BACKEND_URL = 'http://localhost:8000';

// User credentials
const EMAIL = 'sham251087@gmail.com';
const PASSWORD = 'ShaM2510*##&*';

console.log('=====================================');
console.log('FRONTEND LOGIN TEST');
console.log('=====================================');
console.log(`Frontend URL: ${FRONTEND_URL}`);
console.log(`Backend URL: ${BACKEND_URL}`);
console.log(`Testing with: ${EMAIL}`);
console.log('-------------------------------------\n');

async function testLogin() {
    try {
        // Test backend directly first
        console.log('1. Testing Backend Login Endpoint Directly...');

        const backendResponse = await fetch(`${BACKEND_URL}/api/v1/auth/login`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                email: EMAIL,
                password: PASSWORD,
                remember_me: false
            })
        });

        console.log(`   Backend Status: ${backendResponse.status}`);

        if (backendResponse.ok) {
            const data = await backendResponse.json();
            console.log('   ✅ Backend Login Successful!');
            console.log(`   User: ${data.data?.user?.email}`);
            console.log(`   Token Type: ${data.data?.token_type}`);
            console.log(`   Has Access Token: ${!!data.data?.access_token}`);
        } else {
            const error = await backendResponse.json();
            console.log('   ❌ Backend Login Failed!');
            console.log('   Error:', JSON.stringify(error, null, 2));
        }

        // Test frontend API route
        console.log('\n2. Testing Frontend API Route...');

        const frontendResponse = await fetch(`${FRONTEND_URL}/api/auth/login`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                email: EMAIL,
                password: PASSWORD,
            })
        });

        console.log(`   Frontend Status: ${frontendResponse.status}`);

        if (frontendResponse.ok) {
            const data = await frontendResponse.json();
            console.log('   ✅ Frontend Login Successful!');
            console.log('   Response:', JSON.stringify(data, null, 2));
        } else {
            const error = await frontendResponse.text();
            console.log('   ❌ Frontend Login Failed!');
            console.log('   Error:', error);
        }

        // Instructions for manual UI testing
        console.log('\n3. Manual UI Testing Instructions:');
        console.log('   1. Open browser to: ' + FRONTEND_URL);
        console.log('   2. Click "Login" or navigate to /auth/login');
        console.log('   3. Enter email: ' + EMAIL);
        console.log('   4. Enter password: ' + PASSWORD);
        console.log('   5. Click "Sign In" button');
        console.log('   6. You should be redirected to dashboard');

    } catch (error) {
        console.error('Test failed:', error.message);
        if (error.cause) {
            console.error('Cause:', error.cause);
        }
    }
}

// Run the test
testLogin().then(() => {
    console.log('\n=====================================');
    console.log('TEST COMPLETE');
    console.log('=====================================');
});