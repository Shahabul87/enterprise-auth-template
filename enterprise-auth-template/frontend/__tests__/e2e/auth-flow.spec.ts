/**
 * End-to-End Authentication Flow Tests
 *
 * Comprehensive E2E tests for the complete authentication flow
 * including registration, login, logout, password reset, and protected routes.
 */

import { test, expect, Page, BrowserContext, Browser, Route } from '@playwright/test';

// Test configuration
const BASE_URL = process.env.NEXT_PUBLIC_APP_URL || 'http://localhost:3000';
const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000';

// Test data
const testUser = {
  email: 'e2e-test@example.com',
  password: 'E2ETestPassword123!',
  firstName: 'E2E',
  lastName: 'Test',
};

const adminUser = {
  email: 'e2e-admin@example.com',
  password: 'E2EAdminPassword123!',
  firstName: 'E2E',
  lastName: 'Admin',
};

test.describe('Authentication Flow E2E', () => {
  let context: BrowserContext;
  let page: Page;

  test.beforeEach(async ({ browser }: { browser: Browser }) => {
    // Create a new browser context for each test
    context = await browser.newContext({
      viewport: { width: 1200, height: 800 },
    });
    page = await context.newPage();

    // Set up network interceptors for API calls
    await page.route(`${API_URL}/api/**`, (route: Route) => {
      // Log API calls for debugging
      // console.log(`API Call: ${route.request().method()} ${route.request().url()}`);
      route.continue();
    });
  });

  test.afterEach(async () => {
    await context.close();
  });

  test.describe('User Registration', () => {
    test('should complete user registration successfully', async () => {
      // Navigate to registration page
      await page.goto(`${BASE_URL}/auth/register`);
      await expect(page).toHaveTitle(/Register/);

      // Fill in registration form
      await page.fill('[data-testid="email-input"]', testUser.email);
      await page.fill('[data-testid="password-input"]', testUser.password);
      await page.fill('[data-testid="confirm-password-input"]', testUser.password);
      await page.fill('[data-testid="first-name-input"]', testUser.firstName);
      await page.fill('[data-testid="last-name-input"]', testUser.lastName);
      await page.check('[data-testid="agree-terms-checkbox"]');

      // Submit registration form
      await page.click('[data-testid="register-button"]');

      // Wait for registration to complete
      await expect(page.locator('[data-testid="registration-success"]')).toBeVisible();
      await expect(page).toHaveURL(/\/auth\/verify-email/);

      // Check for success message
      await expect(page.locator('text=Check your email')).toBeVisible();
    });

    test('should show validation errors for invalid registration data', async () => {
      await page.goto(`${BASE_URL}/auth/register`);

      // Try to submit with invalid data
      await page.fill('[data-testid="email-input"]', 'invalid-email');
      await page.fill('[data-testid="password-input"]', '123');
      await page.fill('[data-testid="confirm-password-input"]', '456');
      await page.click('[data-testid="register-button"]');

      // Check for validation errors
      await expect(page.locator('text=Invalid email format')).toBeVisible();
      await expect(page.locator('text=Password must be at least 8 characters')).toBeVisible();
      await expect(page.locator('text=Passwords do not match')).toBeVisible();
      await expect(page.locator('text=You must agree to the terms')).toBeVisible();
    });

    test('should handle duplicate email registration', async () => {
      await page.goto(`${BASE_URL}/auth/register`);

      // Try to register with existing email
      await page.fill('[data-testid="email-input"]', 'existing@example.com');
      await page.fill('[data-testid="password-input"]', testUser.password);
      await page.fill('[data-testid="confirm-password-input"]', testUser.password);
      await page.fill('[data-testid="first-name-input"]', testUser.firstName);
      await page.fill('[data-testid="last-name-input"]', testUser.lastName);
      await page.check('[data-testid="agree-terms-checkbox"]');

      await page.click('[data-testid="register-button"]');

      // Check for error message
      await expect(page.locator('text=An account with this email already exists')).toBeVisible();
    });
  });

  test.describe('User Login', () => {
    test('should login successfully with valid credentials', async () => {
      await page.goto(`${BASE_URL}/auth/login`);
      await expect(page).toHaveTitle(/Login/);

      // Fill in login form
      await page.fill('[data-testid="email-input"]', testUser.email);
      await page.fill('[data-testid="password-input"]', testUser.password);

      // Submit login form
      await page.click('[data-testid="login-button"]');

      // Wait for redirect to dashboard
      await expect(page).toHaveURL(/\/dashboard/);
      await expect(page.locator('text=Welcome back')).toBeVisible();

      // Check that user is authenticated
      await expect(page.locator('[data-testid="user-avatar"]')).toBeVisible();
      await expect(page.locator(`text=${testUser.firstName}`)).toBeVisible();
    });

    test('should show error for invalid credentials', async () => {
      await page.goto(`${BASE_URL}/auth/login`);

      // Try to login with wrong password
      await page.fill('[data-testid="email-input"]', testUser.email);
      await page.fill('[data-testid="password-input"]', 'WrongPassword123!');
      await page.click('[data-testid="login-button"]');

      // Check for error message
      await expect(page.locator('text=Invalid email or password')).toBeVisible();
      
      // Should still be on login page
      await expect(page).toHaveURL(/\/auth\/login/);
    });

    test('should handle rate limiting after multiple failed attempts', async () => {
      await page.goto(`${BASE_URL}/auth/login`);

      // Make multiple failed login attempts
      for (let i = 0; i < 6; i++) {
        await page.fill('[data-testid="email-input"]', testUser.email);
        await page.fill('[data-testid="password-input"]', `wrong-password-${i}`);
        await page.click('[data-testid="login-button"]');
        
        // Wait between attempts
        await page.waitForTimeout(500);
      }

      // Should show rate limiting message
      await expect(page.locator('text=Too many login attempts')).toBeVisible();
      await expect(page.locator('[data-testid="login-button"]')).toBeDisabled();
    });

    test('should remember user with "Remember Me" option', async () => {
      await page.goto(`${BASE_URL}/auth/login`);

      await page.fill('[data-testid="email-input"]', testUser.email);
      await page.fill('[data-testid="password-input"]', testUser.password);
      await page.check('[data-testid="remember-me-checkbox"]');
      await page.click('[data-testid="login-button"]');

      await expect(page).toHaveURL(/\/dashboard/);

      // Close and reopen browser to test persistence
      await context.close();
      context = await page.context().browser()!.newContext();
      page = await context.newPage();

      await page.goto(`${BASE_URL}/dashboard`);
      
      // Should still be logged in
      await expect(page.locator('text=Welcome back')).toBeVisible();
    });
  });

  test.describe('OAuth Authentication', () => {
    test('should display OAuth providers on login page', async () => {
      await page.goto(`${BASE_URL}/auth/login`);

      // Check for OAuth provider buttons
      await expect(page.locator('[data-testid="google-oauth-button"]')).toBeVisible();
      await expect(page.locator('[data-testid="github-oauth-button"]')).toBeVisible();
    });

    test('should initiate Google OAuth flow', async () => {
      await page.goto(`${BASE_URL}/auth/login`);

      // Click Google OAuth button
      const googleButton = page.locator('[data-testid="google-oauth-button"]');
      
      // Mock the OAuth redirect
      await page.route('**/api/auth/oauth/google/**', (route: Route) => {
        route.fulfill({
          status: 200,
          contentType: 'application/json',
          body: JSON.stringify({
            success: true,
            data: { auth_url: 'https://accounts.google.com/oauth/authorize?...' },
          }),
        });
      });

      await googleButton.click();

      // Should redirect to Google OAuth
      await page.waitForURL('https://accounts.google.com/**');
      expect(page.url()).toContain('accounts.google.com');
    });
  });

  test.describe('Password Reset', () => {
    test('should initiate password reset flow', async () => {
      await page.goto(`${BASE_URL}/auth/login`);

      // Click forgot password link
      await page.click('text=Forgot your password?');
      await expect(page).toHaveURL(/\/auth\/forgot-password/);

      // Fill in email and submit
      await page.fill('[data-testid="email-input"]', testUser.email);
      await page.click('[data-testid="reset-password-button"]');

      // Check for success message
      await expect(page.locator('text=Password reset email sent')).toBeVisible();
      await expect(page.locator('text=Check your email')).toBeVisible();
    });

    test('should complete password reset with valid token', async () => {
      const resetToken = 'mock-reset-token-123';
      await page.goto(`${BASE_URL}/auth/reset-password?token=${resetToken}`);

      const newPassword = 'NewE2EPassword123!';

      // Fill in new password form
      await page.fill('[data-testid="new-password-input"]', newPassword);
      await page.fill('[data-testid="confirm-password-input"]', newPassword);
      await page.click('[data-testid="reset-password-button"]');

      // Should redirect to login with success message
      await expect(page).toHaveURL(/\/auth\/login/);
      await expect(page.locator('text=Password reset successfully')).toBeVisible();

      // Try to login with new password
      await page.fill('[data-testid="email-input"]', testUser.email);
      await page.fill('[data-testid="password-input"]', newPassword);
      await page.click('[data-testid="login-button"]');

      await expect(page).toHaveURL(/\/dashboard/);
    });

    test('should handle invalid reset token', async () => {
      await page.goto(`${BASE_URL}/auth/reset-password?token=invalid-token`);

      await page.fill('[data-testid="new-password-input"]', 'NewPassword123!');
      await page.fill('[data-testid="confirm-password-input"]', 'NewPassword123!');
      await page.click('[data-testid="reset-password-button"]');

      // Should show error for invalid token
      await expect(page.locator('text=Invalid or expired reset token')).toBeVisible();
    });
  });

  test.describe('Protected Routes', () => {
    test('should redirect unauthenticated users to login', async () => {
      // Try to access protected route without authentication
      await page.goto(`${BASE_URL}/dashboard`);

      // Should redirect to login
      await expect(page).toHaveURL(/\/auth\/login/);
      await expect(page.locator('text=Please sign in to continue')).toBeVisible();
    });

    test('should allow authenticated users to access protected routes', async () => {
      // Login first
      await page.goto(`${BASE_URL}/auth/login`);
      await page.fill('[data-testid="email-input"]', testUser.email);
      await page.fill('[data-testid="password-input"]', testUser.password);
      await page.click('[data-testid="login-button"]');

      await expect(page).toHaveURL(/\/dashboard/);

      // Navigate to other protected routes
      await page.click('text=Profile');
      await expect(page).toHaveURL(/\/profile/);
      await expect(page.locator('text=Profile Information')).toBeVisible();

      await page.click('text=Settings');
      await expect(page).toHaveURL(/\/settings/);
      await expect(page.locator('text=Account Settings')).toBeVisible();
    });

    test('should restrict admin routes to admin users', async () => {
      // Login as regular user
      await page.goto(`${BASE_URL}/auth/login`);
      await page.fill('[data-testid="email-input"]', testUser.email);
      await page.fill('[data-testid="password-input"]', testUser.password);
      await page.click('[data-testid="login-button"]');

      // Try to access admin route
      await page.goto(`${BASE_URL}/admin`);

      // Should show access denied or redirect
      await expect(
        page.locator('text=Access denied').or(page.locator('text=Insufficient privileges'))
      ).toBeVisible();
    });

    test('should allow admin users to access admin routes', async () => {
      // Login as admin user
      await page.goto(`${BASE_URL}/auth/login`);
      await page.fill('[data-testid="email-input"]', adminUser.email);
      await page.fill('[data-testid="password-input"]', adminUser.password);
      await page.click('[data-testid="login-button"]');

      // Navigate to admin dashboard
      await page.goto(`${BASE_URL}/admin`);
      await expect(page.locator('text=Admin Dashboard')).toBeVisible();
      await expect(page.locator('text=User Management')).toBeVisible();
    });
  });

  test.describe('Session Management', () => {
    test('should maintain session across page refreshes', async () => {
      // Login
      await page.goto(`${BASE_URL}/auth/login`);
      await page.fill('[data-testid="email-input"]', testUser.email);
      await page.fill('[data-testid="password-input"]', testUser.password);
      await page.click('[data-testid="login-button"]');

      await expect(page).toHaveURL(/\/dashboard/);

      // Refresh page
      await page.reload();

      // Should still be authenticated
      await expect(page.locator('text=Welcome back')).toBeVisible();
      await expect(page.locator('[data-testid="user-avatar"]')).toBeVisible();
    });

    test('should handle token expiration gracefully', async () => {
      // Login
      await page.goto(`${BASE_URL}/auth/login`);
      await page.fill('[data-testid="email-input"]', testUser.email);
      await page.fill('[data-testid="password-input"]', testUser.password);
      await page.click('[data-testid="login-button"]');

      await expect(page).toHaveURL(/\/dashboard/);

      // Mock token expiration
      await page.evaluate(() => {
        // Clear tokens from storage
        localStorage.clear();
        sessionStorage.clear();
        // Clear cookies
        document.cookie.split(';').forEach(cookie => {
          const eqPos = cookie.indexOf('=');
          const name = eqPos > -1 ? cookie.substr(0, eqPos) : cookie;
          document.cookie = `${name}=;expires=Thu, 01 Jan 1970 00:00:00 GMT;path=/`;
        });
      });

      // Try to navigate to a protected route
      await page.goto(`${BASE_URL}/profile`);

      // Should redirect to login
      await expect(page).toHaveURL(/\/auth\/login/);
      await expect(page.locator('text=Your session has expired')).toBeVisible();
    });

    test('should auto-refresh tokens before expiration', async () => {
      // Login
      await page.goto(`${BASE_URL}/auth/login`);
      await page.fill('[data-testid="email-input"]', testUser.email);
      await page.fill('[data-testid="password-input"]', testUser.password);
      await page.click('[data-testid="login-button"]');

      await expect(page).toHaveURL(/\/dashboard/);

      // Mock successful token refresh
      await page.route('**/api/auth/refresh', (route: Route) => {
        route.fulfill({
          status: 200,
          contentType: 'application/json',
          body: JSON.stringify({
            success: true,
            data: {
              access_token: 'new-access-token',
              refresh_token: 'new-refresh-token',
              token_type: 'bearer',
              expires_in: 3600,
            },
          }),
        });
      });

      // Wait for token refresh to occur (this would happen automatically)
      await page.waitForTimeout(2000);

      // Navigate to another page to ensure tokens are still valid
      await page.goto(`${BASE_URL}/profile`);
      await expect(page.locator('text=Profile Information')).toBeVisible();
    });
  });

  test.describe('User Logout', () => {
    test('should logout user and redirect to login', async () => {
      // Login first
      await page.goto(`${BASE_URL}/auth/login`);
      await page.fill('[data-testid="email-input"]', testUser.email);
      await page.fill('[data-testid="password-input"]', testUser.password);
      await page.click('[data-testid="login-button"]');

      await expect(page).toHaveURL(/\/dashboard/);

      // Click logout button
      await page.click('[data-testid="logout-button"]');

      // Should redirect to login page
      await expect(page).toHaveURL(/\/auth\/login/);
      await expect(page.locator('text=You have been logged out')).toBeVisible();

      // Try to access protected route
      await page.goto(`${BASE_URL}/dashboard`);
      
      // Should redirect back to login
      await expect(page).toHaveURL(/\/auth\/login/);
    });

    test('should clear all session data on logout', async () => {
      // Login
      await page.goto(`${BASE_URL}/auth/login`);
      await page.fill('[data-testid="email-input"]', testUser.email);
      await page.fill('[data-testid="password-input"]', testUser.password);
      await page.click('[data-testid="login-button"]');

      await expect(page).toHaveURL(/\/dashboard/);

      // Logout
      await page.click('[data-testid="logout-button"]');
      await expect(page).toHaveURL(/\/auth\/login/);

      // Check that storage is cleared
      const storageIsEmpty = await page.evaluate(() => {
        return localStorage.length === 0 && sessionStorage.length === 0;
      });

      expect(storageIsEmpty).toBe(true);
    });
  });

  test.describe('Email Verification', () => {
    test('should display verification prompt for unverified users', async () => {
      // Mock unverified user response
      await page.route('**/api/auth/me', (route: Route) => {
        route.fulfill({
          status: 200,
          contentType: 'application/json',
          body: JSON.stringify({
            success: true,
            data: {
              ...testUser,
              is_verified: false,
            },
          }),
        });
      });

      await page.goto(`${BASE_URL}/auth/login`);
      await page.fill('[data-testid="email-input"]', testUser.email);
      await page.fill('[data-testid="password-input"]', testUser.password);
      await page.click('[data-testid="login-button"]');

      // Should show verification banner
      await expect(page.locator('text=Please verify your email')).toBeVisible();
      await expect(page.locator('text=Resend verification email')).toBeVisible();
    });

    test('should handle email verification with valid token', async () => {
      const verificationToken = 'mock-verification-token';
      await page.goto(`${BASE_URL}/auth/verify-email?token=${verificationToken}`);

      // Should show success message
      await expect(page.locator('text=Email verified successfully')).toBeVisible();
      await expect(page.locator('text=Continue to Dashboard')).toBeVisible();

      // Click continue button
      await page.click('text=Continue to Dashboard');
      await expect(page).toHaveURL(/\/dashboard/);
    });
  });

  test.describe('Error Handling', () => {
    test('should handle network errors gracefully', async () => {
      // Mock network error
      await page.route('**/api/auth/login', (route: Route) => {
        route.abort('failed');
      });

      await page.goto(`${BASE_URL}/auth/login`);
      await page.fill('[data-testid="email-input"]', testUser.email);
      await page.fill('[data-testid="password-input"]', testUser.password);
      await page.click('[data-testid="login-button"]');

      // Should show network error message
      await expect(page.locator('text=Network error')).toBeVisible();
      await expect(page.locator('text=Please check your connection')).toBeVisible();
    });

    test('should handle server errors gracefully', async () => {
      // Mock server error
      await page.route('**/api/auth/login', (route: Route) => {
        route.fulfill({
          status: 500,
          contentType: 'application/json',
          body: JSON.stringify({
            success: false,
            error: {
              code: 'INTERNAL_ERROR',
              message: 'Internal server error',
            },
          }),
        });
      });

      await page.goto(`${BASE_URL}/auth/login`);
      await page.fill('[data-testid="email-input"]', testUser.email);
      await page.fill('[data-testid="password-input"]', testUser.password);
      await page.click('[data-testid="login-button"]');

      // Should show server error message
      await expect(page.locator('text=Server error')).toBeVisible();
      await expect(page.locator('text=Please try again later')).toBeVisible();
    });
  });
});