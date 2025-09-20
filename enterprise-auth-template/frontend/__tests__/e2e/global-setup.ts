import { FullConfig } from '@playwright/test';

/**
 * Global setup for Playwright E2E tests
 * This runs once before all tests
 */

async function globalSetup(config: FullConfig) {
  console.log('🚀 Starting E2E test setup...');

  // Set up environment variables
  process.env.NODE_ENV = 'test';
  process.env.TEST_URL = process.env.TEST_URL || 'http://localhost:3000';
  process.env.API_URL = process.env.API_URL || 'http://localhost:8000';

  // Wait for services to be ready (if needed)
  const maxRetries = 30;
  let retries = 0;

  // Check if frontend is ready
  while (retries < maxRetries) {
    try {
      const response = await fetch(process.env.TEST_URL);
      if (response.ok) {
        console.log('✅ Frontend is ready');
        break;
      }
    } catch (error) {
      retries++;
      if (retries === maxRetries) {
        throw new Error('Frontend service is not ready after 30 seconds');
      }
      await new Promise(resolve => setTimeout(resolve, 1000));
    }
  }

  // Check if backend is ready
  retries = 0;
  while (retries < maxRetries) {
    try {
      const response = await fetch(`${process.env.API_URL}/health`);
      if (response.ok) {
        console.log('✅ Backend is ready');
        break;
      }
    } catch (error) {
      retries++;
      if (retries === maxRetries) {
        console.warn('⚠️ Backend service is not ready - tests may fail');
        // Don't throw error as some tests might not need backend
      }
      await new Promise(resolve => setTimeout(resolve, 1000));
    }
  }

  // Create test users if needed
  await createTestUsers();

  console.log('✨ E2E test setup complete');
}

async function createTestUsers() {
  try {
    const testUsers = [
      {
        email: 'existing@example.com',
        password: 'ExistingPassword123!',
        full_name: 'Existing User'
      },
      {
        email: '2fa@example.com',
        password: 'TwoFactorPassword123!',
        full_name: '2FA User',
        two_factor_enabled: true
      }
    ];

    for (const user of testUsers) {
      try {
        const response = await fetch(`${process.env.API_URL}/api/auth/register`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify(user),
        });

        if (response.ok) {
          console.log(`✅ Created test user: ${user.email}`);
        } else if (response.status === 409) {
          console.log(`ℹ️ Test user already exists: ${user.email}`);
        }
      } catch (error) {
        console.warn(`⚠️ Could not create test user ${user.email}:`, error);
      }
    }
  } catch (error) {
    console.warn('⚠️ Could not create test users:', error);
  }
}

export default globalSetup;