/// Environment configuration for different build environments
class Environment {
  static const String development = 'development';
  static const String staging = 'staging';
  static const String production = 'production';

  /// Current environment - should be set via build configuration
  static const String current = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: development,
  );

  /// API base URL for current environment
  static String get apiBaseUrl {
    switch (current) {
      case production:
        return const String.fromEnvironment(
          'API_BASE_URL',
          defaultValue: 'https://api.yourdomain.com',
        );
      case staging:
        return const String.fromEnvironment(
          'API_BASE_URL',
          defaultValue: 'https://staging-api.yourdomain.com',
        );
      case development:
      default:
        return const String.fromEnvironment(
          'API_BASE_URL',
          defaultValue: 'http://localhost:8000',
        );
    }
  }

  /// Whether this is a development environment
  static bool get isDevelopment => current == development;

  /// Whether this is a staging environment
  static bool get isStaging => current == staging;

  /// Whether this is a production environment
  static bool get isProduction => current == production;

  /// Whether debug mode is enabled
  static bool get isDebugMode => isDevelopment || isStaging;

  /// Whether analytics should be enabled
  static bool get enableAnalytics => isProduction || isStaging;

  /// Whether crash reporting should be enabled
  static bool get enableCrashReporting => isProduction || isStaging;

  /// Whether detailed logging should be enabled
  static bool get enableDetailedLogging => isDevelopment;
}