import { test, expect, Page } from '@playwright/test';

/**
 * E2E Authentication Flow Tests
 *
 * Comprehensive end-to-end tests for authentication workflows including:
 * - User registration
 * - Login/logout
 * - Password reset
 * - 2FA setup
 * - Session management
 */

// Test configuration
const TEST_URL = process.env.TEST_URL || 'http://localhost:3000';
const API_URL = process.env.API_URL || 'http://localhost:8000';

// Test data interfaces matching the actual data structures
interface TestUser {
  email: string;
  password: string;
  full_name: string;
}

interface LoginFormData {
  email: string;
  password: string;
  rememberMe?: boolean;
}

// Helper functions
async function fillLoginForm(page: Page, data: LoginFormData) {
  // Wait for the form to be visible
  await page.waitForSelector('input[placeholder="name@company.com"]', { state: 'visible' });

  // Fill email field
  await page.fill('input[placeholder="name@company.com"]', data.email);

  // Fill password field
  await page.fill('input[placeholder="••••••••"]', data.password);

  // Check remember me if specified
  if (data.rememberMe) {
    await page.check('input[type="checkbox"]#remember');
  }
}

async function fillRegisterForm(page: Page, user: TestUser) {
  // Fill full name
  await page.fill('input[placeholder="John Doe"]', user.full_name);

  // Fill email
  await page.fill('input[placeholder="name@company.com"]', user.email);

  // Fill password
  await page.fill('input[placeholder="••••••••"]', user.password);

  // Confirm password
  const confirmPasswordInput = page.locator('input[placeholder="••••••••"]').nth(1);
  await confirmPasswordInput.fill(user.password);

  // Agree to terms
  await page.check('input[type="checkbox"]#terms');
}

// Test fixtures
const testUser: TestUser = {
  email: `test.user.${Date.now()}@example.com`,
  password: 'SecurePassword123!',
  full_name: 'Test User'
};

const existingUser: TestUser = {
  email: 'existing@example.com',
  password: 'ExistingPassword123!',
  full_name: 'Existing User'
};

// Main test suite
test.describe('Authentication Flow E2E Tests', () => {
  test.beforeEach(async ({ page }) => {
    // Navigate to the application
    await page.goto(TEST_URL);

    // Wait for the page to fully load
    await page.waitForLoadState('networkidle');
  });

  test.describe('User Registration', () => {
    test('should successfully register a new user', async ({ page }) => {
      // Navigate to registration page
      await page.goto(`${TEST_URL}/auth/register`);

      // Verify registration page loaded
      await expect(page).toHaveTitle(/Register|Sign Up|Create Account/i);
      await expect(page.locator('h1')).toContainText(/Create.*account|Sign up|Register/i);

      // Fill registration form
      await fillRegisterForm(page, testUser);

      // Submit the form
      await page.click('button:has-text("Create account")');

      // Wait for navigation or success message
      await page.waitForURL(/\/dashboard|\/auth\/verify-email/, { timeout: 10000 });

      // Verify successful registration
      const url = page.url();
      if (url.includes('verify-email')) {
        // Email verification required
        await expect(page.locator('text=/verify.*email/i')).toBeVisible();
      } else if (url.includes('dashboard')) {
        // Direct login after registration
        await expect(page.locator('h1')).toContainText(/Dashboard|Welcome/i);
      }
    });

    test('should show validation errors for invalid input', async ({ page }) => {
      await page.goto(`${TEST_URL}/auth/register`);

      // Try to submit empty form
      await page.click('button:has-text("Create account")');

      // Check for validation errors
      await expect(page.locator('text=/required/i').first()).toBeVisible();

      // Test invalid email
      await page.fill('input[placeholder="name@company.com"]', 'invalid-email');
      await page.click('button:has-text("Create account")');
      await expect(page.locator('text=/valid.*email/i')).toBeVisible();

      // Test password mismatch
      await page.fill('input[placeholder="name@company.com"]', 'test@example.com');
      await page.locator('input[placeholder="••••••••"]').first().fill('Password123!');
      await page.locator('input[placeholder="••••••••"]').nth(1).fill('DifferentPassword123!');
      await page.click('button:has-text("Create account")');
      await expect(page.locator('text=/password.*match/i')).toBeVisible();
    });

    test('should prevent duplicate registration', async ({ page }) => {
      await page.goto(`${TEST_URL}/auth/register`);

      // Try to register with existing email
      await fillRegisterForm(page, existingUser);
      await page.click('button:has-text("Create account")');

      // Check for error message
      await expect(page.locator('text=/already.*registered|exists/i')).toBeVisible({ timeout: 10000 });
    });
  });

  test.describe('User Login', () => {
    test('should successfully login with valid credentials', async ({ page }) => {
      // Navigate to login page
      await page.goto(`${TEST_URL}/auth/login`);

      // Verify login page loaded
      await expect(page.locator('h1')).toContainText('Welcome back');

      // Fill login form
      await fillLoginForm(page, {
        email: existingUser.email,
        password: existingUser.password,
        rememberMe: true
      });

      // Submit the form
      await page.click('button:has-text("Sign in")');

      // Wait for successful login
      await page.waitForURL('**/dashboard', { timeout: 10000 });

      // Verify dashboard is loaded
      await expect(page.locator('h1')).toContainText(/Dashboard|Welcome/i);

      // Verify user menu is visible
      await expect(page.locator('[data-testid="user-menu"], [aria-label="User menu"]')).toBeVisible();
    });

    test('should show error for invalid credentials', async ({ page }) => {
      await page.goto(`${TEST_URL}/auth/login`);

      // Fill with invalid credentials
      await fillLoginForm(page, {
        email: 'wrong@example.com',
        password: 'WrongPassword123!'
      });

      // Submit the form
      await page.click('button:has-text("Sign in")');

      // Check for error message
      await expect(page.locator('[role="alert"], [data-testid="alert"]')).toContainText(/Invalid.*credentials|email.*password.*incorrect/i);

      // Ensure still on login page
      await expect(page).toHaveURL(/\/auth\/login/);
    });

    test('should handle 2FA verification if enabled', async ({ page }) => {
      // This test assumes a user with 2FA enabled
      const twoFAUser = {
        email: '2fa@example.com',
        password: 'TwoFactorPassword123!'
      };

      await page.goto(`${TEST_URL}/auth/login`);
      await fillLoginForm(page, twoFAUser);
      await page.click('button:has-text("Sign in")');

      // Check if 2FA page appears
      const has2FA = await page.locator('text=/verification.*code|two.*factor/i').isVisible({ timeout: 5000 }).catch(() => false);

      if (has2FA) {
        // Verify 2FA form is shown
        await expect(page.locator('input[placeholder="000000"]')).toBeVisible();
        await expect(page.locator('button:has-text("Verify")')).toBeVisible();

        // Test switching to backup code
        await page.click('button:has-text("Backup Code")');
        await expect(page.locator('input[placeholder="XXXX-XXXX"]')).toBeVisible();
      }
    });

    test('should handle OAuth login providers', async ({ page }) => {
      await page.goto(`${TEST_URL}/auth/login`);

      // Check OAuth providers are visible
      await expect(page.locator('text=/continue with/i')).toBeVisible();

      // Check for Google OAuth button
      const googleButton = page.locator('button:has-text("Google"), button:has-text("Continue with Google")');
      await expect(googleButton).toBeVisible();

      // Check for GitHub OAuth button (if configured)
      const githubButton = page.locator('button:has-text("GitHub"), button:has-text("Continue with GitHub")');
      if (await githubButton.isVisible()) {
        await expect(githubButton).toBeEnabled();
      }
    });
  });

  test.describe('Password Reset', () => {
    test('should navigate to forgot password page', async ({ page }) => {
      await page.goto(`${TEST_URL}/auth/login`);

      // Click forgot password link
      await page.click('a:has-text("Forgot password")');

      // Verify forgot password page
      await page.waitForURL('**/auth/forgot-password');
      await expect(page.locator('h1')).toContainText(/Forgot.*password|Reset.*password/i);

      // Check for email input
      await expect(page.locator('input[type="email"]')).toBeVisible();
      await expect(page.locator('button:has-text("Send reset link")')).toBeVisible();
    });

    test('should send password reset email', async ({ page }) => {
      await page.goto(`${TEST_URL}/auth/forgot-password`);

      // Enter email
      await page.fill('input[type="email"]', existingUser.email);

      // Submit form
      await page.click('button:has-text("Send reset link")');

      // Check for success message
      await expect(page.locator('text=/email.*sent|check.*inbox/i')).toBeVisible({ timeout: 10000 });
    });

    test('should validate reset token and allow password change', async ({ page }) => {
      // This would typically use a test token
      const resetToken = 'test-reset-token';

      await page.goto(`${TEST_URL}/auth/reset-password?token=${resetToken}`);

      // Check reset form is visible
      const hasResetForm = await page.locator('input[type="password"]').isVisible({ timeout: 5000 }).catch(() => false);

      if (hasResetForm) {
        // Fill new password
        await page.locator('input[type="password"]').first().fill('NewPassword123!');
        await page.locator('input[type="password"]').nth(1).fill('NewPassword123!');

        // Submit
        await page.click('button:has-text("Reset password")');

        // Check for success or redirect
        await expect(page).toHaveURL(/\/auth\/login|\/dashboard/, { timeout: 10000 });
      }
    });
  });

  test.describe('User Logout', () => {
    test('should successfully logout', async ({ page, context }) => {
      // First login
      await page.goto(`${TEST_URL}/auth/login`);
      await fillLoginForm(page, existingUser);
      await page.click('button:has-text("Sign in")');
      await page.waitForURL('**/dashboard');

      // Find and click logout
      const userMenu = page.locator('[data-testid="user-menu"], [aria-label="User menu"], button:has-text("Account")');
      if (await userMenu.isVisible()) {
        await userMenu.click();
        await page.click('button:has-text("Logout"), button:has-text("Sign out")');
      } else {
        // Direct logout button
        await page.click('button:has-text("Logout"), button:has-text("Sign out")');
      }

      // Verify redirected to login
      await page.waitForURL(/\/auth\/login|\/$/);

      // Try to access protected route
      await page.goto(`${TEST_URL}/dashboard`);

      // Should redirect to login
      await expect(page).toHaveURL(/\/auth\/login/);
    });
  });

  test.describe('Session Management', () => {
    test('should maintain session across page refreshes', async ({ page }) => {
      // Login
      await page.goto(`${TEST_URL}/auth/login`);
      await fillLoginForm(page, existingUser);
      await page.click('button:has-text("Sign in")');
      await page.waitForURL('**/dashboard');

      // Refresh page
      await page.reload();

      // Should still be on dashboard
      await expect(page).toHaveURL(/\/dashboard/);
      await expect(page.locator('h1')).toContainText(/Dashboard|Welcome/i);
    });

    test('should redirect to login when session expires', async ({ page, context }) => {
      // This test would need to simulate session expiry
      // For now, we'll test unauthorized access

      // Clear all cookies to simulate expired session
      await context.clearCookies();

      // Try to access protected route
      await page.goto(`${TEST_URL}/dashboard`);

      // Should redirect to login
      await expect(page).toHaveURL(/\/auth\/login/);
    });
  });

  test.describe('Form Validation', () => {
    test('should show real-time validation feedback', async ({ page }) => {
      await page.goto(`${TEST_URL}/auth/register`);

      // Test email validation
      const emailInput = page.locator('input[placeholder="name@company.com"]');
      await emailInput.fill('invalid');
      await emailInput.blur();
      await expect(page.locator('text=/valid.*email/i')).toBeVisible();

      // Test password strength
      const passwordInput = page.locator('input[placeholder="••••••••"]').first();
      await passwordInput.fill('weak');
      await passwordInput.blur();

      // Check for password strength indicator or error
      const strengthIndicator = page.locator('[data-testid="password-strength"], [aria-label="Password strength"]');
      if (await strengthIndicator.isVisible({ timeout: 1000 }).catch(() => false)) {
        await expect(strengthIndicator).toContainText(/weak|poor/i);
      } else {
        await expect(page.locator('text=/password.*must.*be/i')).toBeVisible();
      }
    });

    test('should disable submit button when form is invalid', async ({ page }) => {
      await page.goto(`${TEST_URL}/auth/login`);

      const submitButton = page.locator('button:has-text("Sign in")');

      // Button should be disabled initially
      await expect(submitButton).toBeDisabled();

      // Fill only email
      await page.fill('input[placeholder="name@company.com"]', 'test@example.com');

      // Button should still be disabled
      await expect(submitButton).toBeDisabled();

      // Fill password
      await page.fill('input[placeholder="••••••••"]', 'Password123!');

      // Button should now be enabled
      await expect(submitButton).toBeEnabled();
    });
  });

  test.describe('Accessibility', () => {
    test('should be keyboard navigable', async ({ page }) => {
      await page.goto(`${TEST_URL}/auth/login`);

      // Tab through form fields
      await page.keyboard.press('Tab'); // Focus first field
      await expect(page.locator('input[placeholder="name@company.com"]')).toBeFocused();

      await page.keyboard.press('Tab'); // Focus password field
      await expect(page.locator('input[placeholder="••••••••"]')).toBeFocused();

      await page.keyboard.press('Tab'); // Focus remember me
      await page.keyboard.press('Tab'); // Focus forgot password link
      await page.keyboard.press('Tab'); // Focus submit button

      // Submit with Enter key
      await page.keyboard.press('Enter');
    });

    test('should have proper ARIA labels', async ({ page }) => {
      await page.goto(`${TEST_URL}/auth/login`);

      // Check for ARIA labels
      const emailInput = page.locator('input[placeholder="name@company.com"]');
      const emailLabel = await emailInput.getAttribute('aria-label') || await page.locator('label:has-text("Email")').textContent();
      expect(emailLabel).toBeTruthy();

      const passwordInput = page.locator('input[placeholder="••••••••"]');
      const passwordLabel = await passwordInput.getAttribute('aria-label') || await page.locator('label:has-text("Password")').textContent();
      expect(passwordLabel).toBeTruthy();
    });
  });

  test.describe('Mobile Responsiveness', () => {
    test('should work on mobile viewport', async ({ page }) => {
      // Set mobile viewport
      await page.setViewportSize({ width: 375, height: 667 });

      await page.goto(`${TEST_URL}/auth/login`);

      // Check form is still accessible
      await expect(page.locator('input[placeholder="name@company.com"]')).toBeVisible();
      await expect(page.locator('input[placeholder="••••••••"]')).toBeVisible();
      await expect(page.locator('button:has-text("Sign in")')).toBeVisible();

      // Test form interaction
      await fillLoginForm(page, existingUser);
      await page.click('button:has-text("Sign in")');
    });
  });
});

// Performance tests
test.describe('Performance', () => {
  test('login page should load quickly', async ({ page }) => {
    const startTime = Date.now();
    await page.goto(`${TEST_URL}/auth/login`);
    await page.waitForSelector('button:has-text("Sign in")');
    const loadTime = Date.now() - startTime;

    // Page should load in under 3 seconds
    expect(loadTime).toBeLessThan(3000);
  });

  test('form submission should be responsive', async ({ page }) => {
    await page.goto(`${TEST_URL}/auth/login`);
    await fillLoginForm(page, existingUser);

    const startTime = Date.now();
    await page.click('button:has-text("Sign in")');

    // Should show loading state immediately
    await expect(page.locator('text=/signing.*in|loading/i')).toBeVisible({ timeout: 500 });

    const responseTime = Date.now() - startTime;
    expect(responseTime).toBeLessThan(500);
  });
});