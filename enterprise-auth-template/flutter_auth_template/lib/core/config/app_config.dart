/// Application configuration management
class AppConfig {
  static const String appName = 'Enterprise Auth Template';
  static const String appVersion = '1.0.0';

  // API Configuration
  static const String baseUrl = 'http://localhost:8000';
  static const String apiBaseUrl = 'http://localhost:8000';
  static const String apiVersion = '/api/v1';
  static String get apiUrl => '$baseUrl$apiVersion';

  // Feature Flags
  static const bool enableBiometricAuth = true;
  static const bool enableOAuth = true;
  static const bool enableWebAuthn = true;
  static const bool enableMagicLink = true;
  static const bool enablePasskey = true;
  static const bool enable2FA = true;

  // Security Configuration
  static const int maxLoginAttempts = 5;
  static const int sessionTimeout = 3600; // seconds
  static const int tokenRefreshInterval = 300; // seconds

  // Cache Configuration
  static const int cacheMaxAge = 3600; // seconds
  static const int cacheMaxSize = 100; // MB

  // Analytics Configuration
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;

  // Development Configuration
  static const bool isDevelopment = true;
  static const bool enableLogging = true;
  static const bool enableDebugBanner = false;
}