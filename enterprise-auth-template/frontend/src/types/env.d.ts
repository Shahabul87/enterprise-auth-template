/**
 * Environment Variable Types for Enterprise Authentication Template
 * 
 * This file contains comprehensive type definitions for all environment
 * variables used in the frontend application, including Next.js built-in
 * variables and custom application-specific variables.
 * 
 * @fileoverview Environment variable TypeScript type definitions
 * @version 1.0.0
 */

// ================================
// Next.js Environment Variables
// ================================

/**
 * Next.js built-in environment variables
 * These are automatically provided by Next.js
 */
interface NextJsEnvironment {
  /** Current Node.js environment */
  readonly NODE_ENV: 'development' | 'production' | 'test';
  
  /** Next.js version */
  readonly NEXT_RUNTIME?: 'nodejs' | 'edge';
  
  /** Vercel deployment URL (if deployed on Vercel) */
  readonly VERCEL_URL?: string;
  
  /** Vercel deployment environment */
  readonly VERCEL_ENV?: 'development' | 'preview' | 'production';
  
  /** Vercel branch name */
  readonly VERCEL_GIT_COMMIT_REF?: string;
  
  /** Vercel commit SHA */
  readonly VERCEL_GIT_COMMIT_SHA?: string;
  
  /** Port the development server runs on */
  readonly PORT?: string;
  
  /** Hostname for the development server */
  readonly HOSTNAME?: string;
}

// ================================
// Application Configuration
// ================================

/**
 * Core application configuration variables
 */
interface ApplicationEnvironment {
  /** Application name */
  readonly NEXT_PUBLIC_APP_NAME: string;
  
  /** Application version */
  readonly NEXT_PUBLIC_APP_VERSION: string;
  
  /** Application environment */
  readonly NEXT_PUBLIC_APP_ENV: 'development' | 'staging' | 'production';
  
  /** Application description */
  readonly NEXT_PUBLIC_APP_DESCRIPTION?: string;
  
  /** Application URL (used for metadata, SEO, etc.) */
  readonly NEXT_PUBLIC_APP_URL: string;
  
  /** CDN base URL for static assets */
  readonly NEXT_PUBLIC_CDN_URL?: string;
  
  /** Asset prefix for static files */
  readonly NEXT_PUBLIC_ASSET_PREFIX?: string;
}

// ================================
// API Configuration
// ================================

/**
 * API and backend service configuration
 */
interface ApiEnvironment {
  /** Backend API base URL */
  readonly NEXT_PUBLIC_API_URL: string;
  
  /** Backend API version */
  readonly NEXT_PUBLIC_API_VERSION?: string;
  
  /** API request timeout in milliseconds */
  readonly NEXT_PUBLIC_API_TIMEOUT?: string;
  
  /** WebSocket server URL */
  readonly NEXT_PUBLIC_WS_URL?: string;
  
  /** GraphQL endpoint URL (if using GraphQL) */
  readonly NEXT_PUBLIC_GRAPHQL_URL?: string;
  
  /** Upload service URL (if separate from main API) */
  readonly NEXT_PUBLIC_UPLOAD_URL?: string;
  
  /** Maximum file upload size in bytes */
  readonly NEXT_PUBLIC_MAX_UPLOAD_SIZE?: string;
  
  /** Allowed file types for upload */
  readonly NEXT_PUBLIC_ALLOWED_FILE_TYPES?: string;
}

// ================================
// Authentication Configuration
// ================================

/**
 * Authentication and OAuth provider configuration
 */
interface AuthEnvironment {
  /** JWT secret (server-side only) */
  readonly JWT_SECRET?: string;
  
  /** JWT expiration time */
  readonly NEXT_PUBLIC_JWT_EXPIRY?: string;
  
  /** Cookie settings */
  readonly NEXT_PUBLIC_COOKIE_DOMAIN?: string;
  readonly NEXT_PUBLIC_COOKIE_SECURE?: 'true' | 'false';
  readonly NEXT_PUBLIC_COOKIE_SAME_SITE?: 'strict' | 'lax' | 'none';
  
  /** Session timeout in minutes */
  readonly NEXT_PUBLIC_SESSION_TIMEOUT?: string;
  
  /** OAuth2 Google configuration */
  readonly NEXT_PUBLIC_GOOGLE_CLIENT_ID?: string;
  readonly GOOGLE_CLIENT_SECRET?: string;
  readonly NEXT_PUBLIC_GOOGLE_REDIRECT_URI?: string;
  
  /** OAuth2 GitHub configuration */
  readonly NEXT_PUBLIC_GITHUB_CLIENT_ID?: string;
  readonly GITHUB_CLIENT_SECRET?: string;
  readonly NEXT_PUBLIC_GITHUB_REDIRECT_URI?: string;
  
  /** OAuth2 Microsoft configuration */
  readonly NEXT_PUBLIC_MICROSOFT_CLIENT_ID?: string;
  readonly MICROSOFT_CLIENT_SECRET?: string;
  readonly NEXT_PUBLIC_MICROSOFT_REDIRECT_URI?: string;
  
  /** OAuth2 LinkedIn configuration */
  readonly NEXT_PUBLIC_LINKEDIN_CLIENT_ID?: string;
  readonly LINKEDIN_CLIENT_SECRET?: string;
  readonly NEXT_PUBLIC_LINKEDIN_REDIRECT_URI?: string;
  
  /** OAuth2 Twitter configuration */
  readonly NEXT_PUBLIC_TWITTER_CLIENT_ID?: string;
  readonly TWITTER_CLIENT_SECRET?: string;
  readonly NEXT_PUBLIC_TWITTER_REDIRECT_URI?: string;
  
  /** OAuth2 Facebook configuration */
  readonly NEXT_PUBLIC_FACEBOOK_CLIENT_ID?: string;
  readonly FACEBOOK_CLIENT_SECRET?: string;
  readonly NEXT_PUBLIC_FACEBOOK_REDIRECT_URI?: string;
  
  /** SAML SSO configuration */
  readonly NEXT_PUBLIC_SAML_ENABLED?: 'true' | 'false';
  readonly SAML_CERT?: string;
  readonly SAML_KEY?: string;
  readonly NEXT_PUBLIC_SAML_ENTRY_POINT?: string;
  
  /** Magic link configuration */
  readonly NEXT_PUBLIC_MAGIC_LINK_ENABLED?: 'true' | 'false';
  readonly MAGIC_LINK_SECRET?: string;
  readonly NEXT_PUBLIC_MAGIC_LINK_EXPIRY?: string;
  
  /** WebAuthn/FIDO2 configuration */
  readonly NEXT_PUBLIC_WEBAUTHN_ENABLED?: 'true' | 'false';
  readonly NEXT_PUBLIC_WEBAUTHN_ORIGIN?: string;
  readonly NEXT_PUBLIC_WEBAUTHN_RP_NAME?: string;
  readonly NEXT_PUBLIC_WEBAUTHN_RP_ID?: string;
}

// ================================
// Third-Party Services
// ================================

/**
 * External service integrations
 */
interface ServicesEnvironment {
  /** Email service configuration */
  readonly SMTP_HOST?: string;
  readonly SMTP_PORT?: string;
  readonly SMTP_SECURE?: 'true' | 'false';
  readonly SMTP_USER?: string;
  readonly SMTP_PASS?: string;
  readonly SMTP_FROM?: string;
  
  /** SendGrid configuration */
  readonly SENDGRID_API_KEY?: string;
  readonly SENDGRID_FROM_EMAIL?: string;
  readonly SENDGRID_FROM_NAME?: string;
  
  /** AWS SES configuration */
  readonly AWS_ACCESS_KEY_ID?: string;
  readonly AWS_SECRET_ACCESS_KEY?: string;
  readonly AWS_REGION?: string;
  readonly AWS_SES_FROM_EMAIL?: string;
  
  /** Mailgun configuration */
  readonly MAILGUN_API_KEY?: string;
  readonly MAILGUN_DOMAIN?: string;
  readonly MAILGUN_FROM_EMAIL?: string;
  
  /** Twilio SMS configuration */
  readonly TWILIO_ACCOUNT_SID?: string;
  readonly TWILIO_AUTH_TOKEN?: string;
  readonly TWILIO_FROM_NUMBER?: string;
  
  /** Push notification services */
  readonly NEXT_PUBLIC_VAPID_PUBLIC_KEY?: string;
  readonly VAPID_PRIVATE_KEY?: string;
  readonly VAPID_SUBJECT?: string;
  
  /** Firebase configuration */
  readonly NEXT_PUBLIC_FIREBASE_API_KEY?: string;
  readonly NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN?: string;
  readonly NEXT_PUBLIC_FIREBASE_PROJECT_ID?: string;
  readonly NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET?: string;
  readonly NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID?: string;
  readonly NEXT_PUBLIC_FIREBASE_APP_ID?: string;
  readonly NEXT_PUBLIC_FIREBASE_MEASUREMENT_ID?: string;
  
  /** AWS S3 configuration */
  readonly NEXT_PUBLIC_AWS_S3_BUCKET?: string;
  readonly NEXT_PUBLIC_AWS_S3_REGION?: string;
  readonly AWS_S3_ACCESS_KEY?: string;
  readonly AWS_S3_SECRET_KEY?: string;
  
  /** CloudFlare configuration */
  readonly NEXT_PUBLIC_CLOUDFLARE_ZONE_ID?: string;
  readonly CLOUDFLARE_API_TOKEN?: string;
  
  /** Stripe payment configuration */
  readonly NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY?: string;
  readonly STRIPE_SECRET_KEY?: string;
  readonly STRIPE_WEBHOOK_SECRET?: string;
}

// ================================
// Analytics and Monitoring
// ================================

/**
 * Analytics, monitoring, and observability services
 */
interface AnalyticsEnvironment {
  /** Google Analytics configuration */
  readonly NEXT_PUBLIC_GA_MEASUREMENT_ID?: string;
  readonly NEXT_PUBLIC_GA_DEBUG?: 'true' | 'false';
  
  /** Google Tag Manager */
  readonly NEXT_PUBLIC_GTM_ID?: string;
  
  /** Microsoft Clarity */
  readonly NEXT_PUBLIC_CLARITY_PROJECT_ID?: string;
  
  /** Hotjar configuration */
  readonly NEXT_PUBLIC_HOTJAR_ID?: string;
  readonly NEXT_PUBLIC_HOTJAR_VERSION?: string;
  
  /** Mixpanel configuration */
  readonly NEXT_PUBLIC_MIXPANEL_TOKEN?: string;
  
  /** Amplitude configuration */
  readonly NEXT_PUBLIC_AMPLITUDE_API_KEY?: string;
  
  /** Segment configuration */
  readonly NEXT_PUBLIC_SEGMENT_WRITE_KEY?: string;
  
  /** PostHog configuration */
  readonly NEXT_PUBLIC_POSTHOG_KEY?: string;
  readonly NEXT_PUBLIC_POSTHOG_HOST?: string;
  
  /** Sentry error tracking */
  readonly NEXT_PUBLIC_SENTRY_DSN?: string;
  readonly NEXT_PUBLIC_SENTRY_ORG?: string;
  readonly NEXT_PUBLIC_SENTRY_PROJECT?: string;
  readonly NEXT_PUBLIC_SENTRY_AUTH_TOKEN?: string;
  readonly NEXT_PUBLIC_SENTRY_RELEASE?: string;
  readonly NEXT_PUBLIC_SENTRY_ENVIRONMENT?: string;
  readonly NEXT_PUBLIC_SENTRY_TRACE_SAMPLE_RATE?: string;
  
  /** LogRocket session replay */
  readonly NEXT_PUBLIC_LOGROCKET_APP_ID?: string;
  
  /** DataDog RUM */
  readonly NEXT_PUBLIC_DATADOG_CLIENT_TOKEN?: string;
  readonly NEXT_PUBLIC_DATADOG_APPLICATION_ID?: string;
  readonly NEXT_PUBLIC_DATADOG_SITE?: string;
  
  /** New Relic monitoring */
  readonly NEW_RELIC_LICENSE_KEY?: string;
  readonly NEXT_PUBLIC_NEW_RELIC_APP_ID?: string;
  
  /** Prometheus metrics */
  readonly NEXT_PUBLIC_PROMETHEUS_ENABLED?: 'true' | 'false';
  readonly NEXT_PUBLIC_METRICS_ENDPOINT?: string;
}

// ================================
// Security Configuration
// ================================

/**
 * Security-related environment variables
 */
interface SecurityEnvironment {
  /** CSRF protection */
  readonly CSRF_SECRET?: string;
  readonly NEXT_PUBLIC_CSRF_ENABLED?: 'true' | 'false';
  
  /** Content Security Policy */
  readonly NEXT_PUBLIC_CSP_ENABLED?: 'true' | 'false';
  readonly NEXT_PUBLIC_CSP_REPORT_URI?: string;
  
  /** Rate limiting */
  readonly NEXT_PUBLIC_RATE_LIMIT_ENABLED?: 'true' | 'false';
  readonly NEXT_PUBLIC_RATE_LIMIT_WINDOW?: string;
  readonly NEXT_PUBLIC_RATE_LIMIT_MAX?: string;
  
  /** IP filtering */
  readonly NEXT_PUBLIC_IP_WHITELIST?: string;
  readonly NEXT_PUBLIC_IP_BLACKLIST?: string;
  
  /** reCAPTCHA configuration */
  readonly NEXT_PUBLIC_RECAPTCHA_SITE_KEY?: string;
  readonly RECAPTCHA_SECRET_KEY?: string;
  readonly NEXT_PUBLIC_RECAPTCHA_VERSION?: '2' | '3';
  
  /** hCaptcha configuration */
  readonly NEXT_PUBLIC_HCAPTCHA_SITE_KEY?: string;
  readonly HCAPTCHA_SECRET_KEY?: string;
  
  /** Turnstile (Cloudflare) configuration */
  readonly NEXT_PUBLIC_TURNSTILE_SITE_KEY?: string;
  readonly TURNSTILE_SECRET_KEY?: string;
  
  /** Encryption keys */
  readonly ENCRYPTION_KEY?: string;
  readonly CRYPTO_ALGORITHM?: string;
  readonly HASH_ROUNDS?: string;
  
  /** TLS/SSL configuration */
  readonly TLS_CERT_PATH?: string;
  readonly TLS_KEY_PATH?: string;
  readonly TLS_CA_PATH?: string;
}

// ================================
// Development and Testing
// ================================

/**
 * Development and testing environment variables
 */
interface DevelopmentEnvironment {
  /** Debug flags */
  readonly NEXT_PUBLIC_DEBUG?: 'true' | 'false';
  readonly NEXT_PUBLIC_DEBUG_REDUX?: 'true' | 'false';
  readonly NEXT_PUBLIC_DEBUG_API?: 'true' | 'false';
  
  /** Mock data and testing */
  readonly NEXT_PUBLIC_USE_MOCK_DATA?: 'true' | 'false';
  readonly NEXT_PUBLIC_MOCK_API_DELAY?: string;
  
  /** Development server configuration */
  readonly NEXT_PUBLIC_DEV_SERVER_HOST?: string;
  readonly NEXT_PUBLIC_DEV_SERVER_PORT?: string;
  readonly NEXT_PUBLIC_DEV_SERVER_HTTPS?: 'true' | 'false';
  
  /** Hot reloading */
  readonly NEXT_PUBLIC_HOT_RELOAD?: 'true' | 'false';
  
  /** Source maps */
  readonly NEXT_PUBLIC_SOURCE_MAPS?: 'true' | 'false';
  
  /** Bundle analyzer */
  readonly ANALYZE_BUNDLE?: 'true' | 'false';
  
  /** Performance monitoring in development */
  readonly NEXT_PUBLIC_DEV_PERFORMANCE?: 'true' | 'false';
  
  /** Test environment configuration */
  readonly TEST_TIMEOUT?: string;
  readonly TEST_COVERAGE_THRESHOLD?: string;
  readonly JEST_VERBOSE?: 'true' | 'false';
  
  /** Storybook configuration */
  readonly STORYBOOK_PORT?: string;
  readonly STORYBOOK_HOST?: string;
  
  /** Cypress testing */
  readonly CYPRESS_BASE_URL?: string;
  readonly CYPRESS_VIDEO?: 'true' | 'false';
  readonly CYPRESS_SCREENSHOTS?: 'true' | 'false';
}

// ================================
// Feature Flags
// ================================

/**
 * Feature flag environment variables
 */
interface FeatureFlagsEnvironment {
  /** Authentication features */
  readonly NEXT_PUBLIC_FEATURE_OAUTH_LOGIN?: 'true' | 'false';
  readonly NEXT_PUBLIC_FEATURE_MAGIC_LINK?: 'true' | 'false';
  readonly NEXT_PUBLIC_FEATURE_TWO_FACTOR?: 'true' | 'false';
  readonly NEXT_PUBLIC_FEATURE_WEBAUTHN?: 'true' | 'false';
  readonly NEXT_PUBLIC_FEATURE_SSO?: 'true' | 'false';
  
  /** UI/UX features */
  readonly NEXT_PUBLIC_FEATURE_DARK_MODE?: 'true' | 'false';
  readonly NEXT_PUBLIC_FEATURE_PWA?: 'true' | 'false';
  readonly NEXT_PUBLIC_FEATURE_OFFLINE_MODE?: 'true' | 'false';
  readonly NEXT_PUBLIC_FEATURE_PUSH_NOTIFICATIONS?: 'true' | 'false';
  
  /** Admin features */
  readonly NEXT_PUBLIC_FEATURE_ADMIN_DASHBOARD?: 'true' | 'false';
  readonly NEXT_PUBLIC_FEATURE_USER_MANAGEMENT?: 'true' | 'false';
  readonly NEXT_PUBLIC_FEATURE_AUDIT_LOGS?: 'true' | 'false';
  readonly NEXT_PUBLIC_FEATURE_ANALYTICS?: 'true' | 'false';
  
  /** Payment features */
  readonly NEXT_PUBLIC_FEATURE_PAYMENTS?: 'true' | 'false';
  readonly NEXT_PUBLIC_FEATURE_SUBSCRIPTIONS?: 'true' | 'false';
  
  /** Communication features */
  readonly NEXT_PUBLIC_FEATURE_CHAT?: 'true' | 'false';
  readonly NEXT_PUBLIC_FEATURE_VIDEO_CALLS?: 'true' | 'false';
  readonly NEXT_PUBLIC_FEATURE_FILE_SHARING?: 'true' | 'false';
  
  /** Experimental features */
  readonly NEXT_PUBLIC_FEATURE_BETA_UI?: 'true' | 'false';
  readonly NEXT_PUBLIC_FEATURE_AI_ASSISTANT?: 'true' | 'false';
  readonly NEXT_PUBLIC_FEATURE_REAL_TIME_COLLAB?: 'true' | 'false';
}

// ================================
// Database Configuration
// ================================

/**
 * Database connection environment variables
 */
interface DatabaseEnvironment {
  /** PostgreSQL configuration */
  readonly DATABASE_URL?: string;
  readonly DB_HOST?: string;
  readonly DB_PORT?: string;
  readonly DB_USER?: string;
  readonly DB_PASSWORD?: string;
  readonly DB_NAME?: string;
  readonly DB_SCHEMA?: string;
  readonly DB_SSL?: 'true' | 'false';
  readonly DB_SSL_CERT?: string;
  
  /** Connection pool settings */
  readonly DB_POOL_MIN?: string;
  readonly DB_POOL_MAX?: string;
  readonly DB_POOL_IDLE_TIMEOUT?: string;
  readonly DB_POOL_CONNECTION_TIMEOUT?: string;
  
  /** Redis configuration */
  readonly REDIS_URL?: string;
  readonly REDIS_HOST?: string;
  readonly REDIS_PORT?: string;
  readonly REDIS_PASSWORD?: string;
  readonly REDIS_DB?: string;
  readonly REDIS_TLS?: 'true' | 'false';
  
  /** MongoDB configuration (if used) */
  readonly MONGODB_URL?: string;
  readonly MONGODB_DB_NAME?: string;
  
  /** Database migration settings */
  readonly RUN_MIGRATIONS?: 'true' | 'false';
  readonly MIGRATION_TABLE?: string;
}

// ================================
// Combined Environment Interface
// ================================

/**
 * Complete environment variables interface
 * Combines all environment variable categories
 */
interface EnvironmentVariables
  extends NextJsEnvironment,
    ApplicationEnvironment,
    ApiEnvironment,
    AuthEnvironment,
    ServicesEnvironment,
    AnalyticsEnvironment,
    SecurityEnvironment,
    DevelopmentEnvironment,
    FeatureFlagsEnvironment,
    DatabaseEnvironment {
  /** Allow additional custom environment variables */
  [key: string]: string | undefined;
}

// ================================
// Process Environment Augmentation
// ================================

declare global {
  namespace NodeJS {
    /**
     * Augment the ProcessEnv interface to include our typed environment variables
     */
    interface ProcessEnv extends EnvironmentVariables {}
  }
}

// ================================
// Environment Variable Utilities
// ================================

/**
 * Utility type to get all public environment variables
 * (those prefixed with NEXT_PUBLIC_)
 */
type PublicEnvironmentVariables = {
  [K in keyof EnvironmentVariables as K extends `NEXT_PUBLIC_${string}`
    ? K
    : never]: EnvironmentVariables[K];
};

/**
 * Utility type to get all server-side environment variables
 * (those NOT prefixed with NEXT_PUBLIC_)
 */
type ServerEnvironmentVariables = {
  [K in keyof EnvironmentVariables as K extends `NEXT_PUBLIC_${string}`
    ? never
    : K]: EnvironmentVariables[K];
};

/**
 * Utility type for feature flags
 */
type FeatureFlag = keyof FeatureFlagsEnvironment;

/**
 * Utility type for boolean environment variables
 */
type BooleanEnvVar = 'true' | 'false' | undefined;

/**
 * Environment variable validation schema type
 */
interface EnvValidationSchema {
  /** Required environment variables */
  required: (keyof EnvironmentVariables)[];
  /** Optional environment variables with default values */
  optional: Partial<Record<keyof EnvironmentVariables, string>>;
  /** Environment-specific overrides */
  environments: {
    development?: Partial<EnvironmentVariables>;
    staging?: Partial<EnvironmentVariables>;
    production?: Partial<EnvironmentVariables>;
    test?: Partial<EnvironmentVariables>;
  };
}

// ================================
// Runtime Environment Access
// ================================

/**
 * Type-safe environment variable getter for client-side code
 * Only returns NEXT_PUBLIC_ prefixed variables
 */
declare const getPublicEnvVar: <K extends keyof PublicEnvironmentVariables>(
  key: K
) => PublicEnvironmentVariables[K];

/**
 * Type-safe environment variable getter for server-side code
 * Returns any environment variable
 */
declare const getEnvVar: <K extends keyof EnvironmentVariables>(
  key: K,
  defaultValue?: string
) => EnvironmentVariables[K];

/**
 * Feature flag checker
 */
declare const isFeatureEnabled: (flag: FeatureFlag) => boolean;

/**
 * Environment checker
 */
declare const isEnvironment: (
  env: 'development' | 'staging' | 'production' | 'test'
) => boolean;

// ================================
// Export Types
// ================================

export type {
  EnvironmentVariables,
  PublicEnvironmentVariables,
  ServerEnvironmentVariables,
  NextJsEnvironment,
  ApplicationEnvironment,
  ApiEnvironment,
  AuthEnvironment,
  ServicesEnvironment,
  AnalyticsEnvironment,
  SecurityEnvironment,
  DevelopmentEnvironment,
  FeatureFlagsEnvironment,
  DatabaseEnvironment,
  FeatureFlag,
  BooleanEnvVar,
  EnvValidationSchema,
};

// Make this file a module
export {};