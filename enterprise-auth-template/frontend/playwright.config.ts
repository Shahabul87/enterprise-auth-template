import { defineConfig, devices } from '@playwright/test';

/**
 * Playwright Configuration for E2E Testing
 */

// Read environment variables
const CI = process.env.CI === 'true';
const BASE_URL = process.env.TEST_URL || 'http://localhost:3000';

export default defineConfig({
  // Test directory
  testDir: './__tests__/e2e',

  // Test file patterns
  testMatch: ['**/*.spec.ts', '**/*.e2e.ts'],

  // Maximum time one test can run
  timeout: 30 * 1000,

  // Global timeout for the whole test run
  globalTimeout: 60 * 60 * 1000, // 1 hour

  // Number of parallel workers
  workers: CI ? 1 : undefined,

  // Reporter configuration
  reporter: CI
    ? [['github'], ['html', { open: 'never' }]]
    : [['html', { open: 'on-failure' }]],

  // Retry configuration
  retries: CI ? 2 : 0,

  // Shared settings for all projects
  use: {
    // Base URL for navigation
    baseURL: BASE_URL,

    // Collect trace when test fails
    trace: 'on-first-retry',

    // Take screenshot on failure
    screenshot: 'only-on-failure',

    // Video recording
    video: 'retain-on-failure',

    // Action timeout
    actionTimeout: 15 * 1000,

    // Navigation timeout
    navigationTimeout: 30 * 1000,

    // Emulate user agent
    userAgent: 'Playwright E2E Testing',

    // Ignore HTTPS errors
    ignoreHTTPSErrors: true,

    // Viewport size
    viewport: { width: 1280, height: 720 },

    // Locale
    locale: 'en-US',

    // Timezone
    timezoneId: 'America/New_York',

    // Permissions
    permissions: ['geolocation', 'notifications'],

    // Color scheme
    colorScheme: 'light',

    // Extra HTTP headers
    extraHTTPHeaders: {
      'Accept-Language': 'en-US,en;q=0.9',
    },
  },

  // Configure projects for different browsers
  projects: [
    {
      name: 'chromium',
      use: {
        ...devices['Desktop Chrome'],
        // Chrome-specific configuration
        launchOptions: {
          args: ['--disable-blink-features=AutomationControlled'],
        },
      },
    },

    {
      name: 'firefox',
      use: {
        ...devices['Desktop Firefox'],
      },
    },

    {
      name: 'webkit',
      use: {
        ...devices['Desktop Safari'],
      },
    },

    // Mobile testing
    {
      name: 'mobile-chrome',
      use: {
        ...devices['Pixel 5'],
      },
    },

    {
      name: 'mobile-safari',
      use: {
        ...devices['iPhone 12'],
      },
    },

    // Test specific viewport sizes
    {
      name: 'tablet',
      use: {
        ...devices['iPad Pro'],
      },
    },

    // API testing project
    {
      name: 'api',
      use: {
        baseURL: process.env.API_URL || 'http://localhost:8000',
        extraHTTPHeaders: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      },
      testMatch: ['**/*.api.spec.ts'],
    },
  ],

  // Global setup and teardown
  globalSetup: './__tests__/e2e/global-setup.ts',
  globalTeardown: './__tests__/e2e/global-teardown.ts',

  // Web server configuration
  webServer: CI
    ? undefined
    : [
        {
          command: 'npm run dev',
          port: 3000,
          reuseExistingServer: true,
          timeout: 120 * 1000,
          env: {
            NODE_ENV: 'test',
          },
        },
        {
          command: 'cd ../backend && uvicorn app.main:app --reload --port 8000',
          port: 8000,
          reuseExistingServer: true,
          timeout: 120 * 1000,
          env: {
            ENVIRONMENT: 'test',
          },
        },
      ],

  // Output folder for test results
  outputDir: './test-results',

  // Folder for test artifacts
  preserveOutput: 'failures-only',

  // Expect configuration
  expect: {
    // Maximum time expect() should wait for the condition to be met
    timeout: 10 * 1000,

    toHaveScreenshot: {
      // Screenshot comparison threshold
      threshold: 0.2,
      maxDiffPixels: 100,
      animations: 'disabled',
    },
  },

  // Forbid test.only in CI
  forbidOnly: !!CI,

  // Fail on console errors
  use: {
    ...{},
    // Listen for console messages
    acceptDownloads: true,
    bypassCSP: false,
    launchOptions: {
      slowMo: CI ? 0 : 100,
    },
  },
});