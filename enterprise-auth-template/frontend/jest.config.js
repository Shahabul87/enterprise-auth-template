const nextJest = require('next/jest');

const createJestConfig = nextJest({
  // Provide the path to your Next.js app to load next.config.js and .env files in your test environment
  dir: './',
});

// Add any custom config to be passed to Jest
const customJestConfig = {
  // Add more setup options before each test is run
  setupFilesAfterEnv: ['<rootDir>/jest.setup.js'],
  
  // Test environment
  testEnvironment: 'jest-environment-jsdom',
  
  // Module name mapper for path aliases
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/src/$1',
    '^@/components/(.*)$': '<rootDir>/src/components/$1',
    '^@/lib/(.*)$': '<rootDir>/src/lib/$1',
    '^@/contexts/(.*)$': '<rootDir>/src/contexts/$1',
    '^@/hooks/(.*)$': '<rootDir>/src/hooks/$1',
    '^@/types/(.*)$': '<rootDir>/src/types/$1',
    '^@/stores/(.*)$': '<rootDir>/src/stores/$1',
    
    // Handle CSS imports (with CSS modules)
    '^.+\\.module\\.(css|sass|scss)$': 'identity-obj-proxy',
    
    // Handle CSS imports (without CSS modules)
    '^.+\\.(css|sass|scss)$': '<rootDir>/__mocks__/styleMock.js',
    
    // Handle image imports
    '^.+\\.(png|jpg|jpeg|gif|webp|avif|ico|bmp|svg)$/i': '<rootDir>/__mocks__/fileMock.js',
  },
  
  // Module directories
  moduleDirectories: ['node_modules', '<rootDir>/'],
  
  // Test path ignore patterns
  testPathIgnorePatterns: [
    '<rootDir>/.next/',
    '<rootDir>/node_modules/',
    '<rootDir>/coverage/',
    '<rootDir>/build/',
    '<rootDir>/dist/',
    '<rootDir>/__tests__/e2e/', // Exclude E2E tests that should run with Playwright
  ],
  
  // Transform ignore patterns
  transformIgnorePatterns: [
    'node_modules/(?!(react-markdown|remark-*|unified|bail|is-plain-obj|trough|vfile|unist-*|mdast-*|micromark|decode-named-character-reference|character-entities|property-information|hast-*|space-separated-tokens|comma-separated-tokens|pretty-bytes)/)',
  ],
  
  // Coverage configuration
  collectCoverageFrom: [
    'src/**/*.{js,jsx,ts,tsx}',
    '!src/**/*.d.ts',
    '!src/**/*.stories.{js,jsx,ts,tsx}',
    '!src/**/_*.{js,jsx,ts,tsx}',
    '!src/**/index.ts',
    '!src/app/**/*.{js,jsx,ts,tsx}', // Exclude Next.js app directory pages
    '!src/app/**/layout.tsx', // Exclude layout files
    '!src/app/**/page.tsx', // Exclude page files
    '!src/app/**/loading.tsx', // Exclude loading files
    '!src/app/**/error.tsx', // Exclude error files
    '!src/app/**/not-found.tsx', // Exclude not-found files
    '!src/middleware.ts', // Exclude Next.js middleware
    '!src/**/*.config.{js,ts}', // Exclude config files
    '!src/**/__mocks__/**', // Exclude mock files
    '!src/**/__fixtures__/**', // Exclude fixture files
  ],

  // Coverage providers
  coverageProvider: 'v8',
  
  // Coverage directory
  coverageDirectory: 'coverage',
  
  // Coverage reporters
  coverageReporters: [
    'text',
    'text-summary',
    'html',
    'lcov',
    'json-summary'
  ],
  
  // Coverage threshold - Enhanced for enterprise standards
  coverageThreshold: {
    global: {
      branches: 75,
      functions: 75,
      lines: 75,
      statements: 75,
    },
    // Specific thresholds for critical areas
    'src/components/auth/**/*.{js,jsx,ts,tsx}': {
      branches: 85,
      functions: 85,
      lines: 85,
      statements: 85,
    },
    'src/stores/**/*.{js,jsx,ts,tsx}': {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80,
    },
    'src/lib/**/*.{js,jsx,ts,tsx}': {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80,
    },
    'src/hooks/**/*.{js,jsx,ts,tsx}': {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80,
    },
  },
  
  // Test match patterns
  testMatch: [
    '**/__tests__/**/*.{js,jsx,ts,tsx}',
    '**/?(*.)+(spec|test).{js,jsx,ts,tsx}',
  ],
  
  // Watch plugins for better development experience
  watchPlugins: [
    'jest-watch-typeahead/filename',
    'jest-watch-typeahead/testname',
  ],
  
  // Global setup/teardown
  globalSetup: undefined,
  globalTeardown: undefined,
  
  // Maximum worker processes
  maxWorkers: '50%',
  
  // Clear mocks automatically
  clearMocks: true,
  
  // Restore mocks automatically
  restoreMocks: true,
  
  // Error on deprecated features
  errorOnDeprecated: true,
  
  // Fail fast on first test failure (useful for CI)
  bail: process.env.CI ? 1 : 0,
  
  // Verbose output
  verbose: true,
  
  // Notify mode for watching tests
  notify: false,
  
  // Force exit after tests complete
  forceExit: false,
  
  // Detect open handles
  detectOpenHandles: true,
};

// createJestConfig is exported this way to ensure that next/jest can load the Next.js config which is async
module.exports = createJestConfig(customJestConfig);