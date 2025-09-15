// Test script to simulate registration through the actual frontend API client
const fetch = require('node-fetch');

async function testRegistration() {
    const timestamp = Date.now();
    const testData = {
        email: `testuser${timestamp}@example.com`,
        password: "TestPass123!",
        confirm_password: "TestPass123!",
        name: "Test User",
        agree_to_terms: true
    };

    console.log('\n=== TESTING REGISTRATION FLOW ===\n');
    console.log('1. Testing with email:', testData.email);
    console.log('2. Request payload:', JSON.stringify(testData, null, 2));

    try {
        // Test backend directly
        console.log('\n3. Testing Backend API directly...');
        const backendResponse = await fetch('http://localhost:8000/api/v1/auth/register', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(testData)
        });

        const backendData = await backendResponse.json();
        console.log('   Status:', backendResponse.status);
        console.log('   Response:', JSON.stringify(backendData, null, 2));

        if (backendData.success) {
            console.log('\n✅ Backend registration successful!');
            console.log('   Message:', backendData.data?.message);
        } else {
            console.log('\n❌ Backend registration failed!');
            console.log('   Error:', backendData.error?.message);
        }

        // Test frontend endpoint (if exists)
        console.log('\n4. Testing Frontend API proxy (if exists)...');
        try {
            const frontendResponse = await fetch('http://localhost:3000/api/auth/register', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    ...testData,
                    email: `frontend${timestamp}@example.com`
                })
            });

            if (frontendResponse.ok) {
                const frontendData = await frontendResponse.json();
                console.log('   Frontend API Response:', JSON.stringify(frontendData, null, 2));
            } else {
                console.log('   Frontend API endpoint not found or error:', frontendResponse.status);
            }
        } catch (e) {
            console.log('   Frontend API endpoint not available');
        }

    } catch (error) {
        console.error('\n❌ Error during testing:', error.message);
    }

    console.log('\n=== DATA FLOW ANALYSIS ===\n');
    console.log('Expected flow:');
    console.log('1. User fills form → RegisterForm component');
    console.log('2. Form submission → calls registerUser from auth.store');
    console.log('3. Auth store → calls AuthAPI.register');
    console.log('4. AuthAPI → calls apiClient.post to backend');
    console.log('5. Backend → returns { success: true, data: { message: "..." } }');
    console.log('6. Auth store → returns response to form');
    console.log('7. Form → shows success message');
    console.log('8. Form → does NOT redirect (user needs to verify email)');

    console.log('\n=== ISSUE DIAGNOSIS ===\n');
    console.log('The registration flow should work as follows:');
    console.log('- If email is NEW → Shows success message');
    console.log('- If email EXISTS → Shows error "Email already registered"');
    console.log('- Success does NOT auto-login or redirect');
    console.log('- User must verify email before logging in');
}

testRegistration().catch(console.error);