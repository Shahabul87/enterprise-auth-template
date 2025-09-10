import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

/// Environment configuration for different deployment targets
class Environment {
  static const String dev = 'development';
  static const String staging = 'staging';
  static const String production = 'production';
  static const String testing = 'testing';

  /// Current environment - can be overridden via --dart-define
  static String get current {
    return const String.fromEnvironment('ENV', defaultValue: dev);
  }

  /// Get the appropriate API base URL based on platform and environment
  static String get apiBaseUrl {
    switch (current) {
      case production:
        return 'https://api.yourdomain.com';
      case staging:
        return 'https://staging-api.yourdomain.com';
      case testing:
        return _getTestApiUrl();
      case dev:
      default:
        return _getDevApiUrl();
    }
  }

  /// Get development API URL based on platform
  static String _getDevApiUrl() {
    if (kIsWeb) {
      // Web app - use localhost directly
      return 'http://localhost:8000';
    }

    try {
      if (Platform.isAndroid) {
        // Android Emulator special IP for host machine
        return 'http://10.0.2.2:8000';
      } else if (Platform.isIOS) {
        // iOS Simulator can use localhost
        return 'http://localhost:8000';
      } else if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
        // Desktop apps
        return 'http://localhost:8000';
      }
    } catch (e) {
      // Platform not available (e.g., during web builds)
      return 'http://localhost:8000';
    }

    // Default fallback
    return 'http://localhost:8000';
  }

  /// Get testing API URL
  static String _getTestApiUrl() {
    if (kIsWeb) {
      return 'http://localhost:8001'; // Different port for test backend
    }

    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:8001';
      } else if (Platform.isIOS) {
        return 'http://localhost:8001';
      }
    } catch (e) {
      return 'http://localhost:8001';
    }

    return 'http://localhost:8001';
  }

  /// API version prefix
  static String get apiVersion => '/api/v1';

  /// Full API URL with version
  static String get apiUrl => '$apiBaseUrl$apiVersion';

  /// WebSocket URL for real-time features
  static String get wsUrl {
    final baseUrl = apiBaseUrl.replaceFirst('http', 'ws');
    return '$baseUrl/ws';
  }

  /// Check if running in debug mode
  static bool get isDebug => kDebugMode;

  /// Check if running in release mode
  static bool get isRelease => kReleaseMode;

  /// Check if running in profile mode
  static bool get isProfile => kProfileMode;

  /// OAuth redirect URLs
  static String get oauthRedirectUrl {
    if (kIsWeb) {
      return 'http://localhost:3000/auth/callback';
    } else {
      return 'com.enterprise.auth://callback';
    }
  }

  /// Deep link scheme
  static String get deepLinkScheme => 'com.enterprise.auth';

  /// Feature flags
  static bool get enableBiometric => !kIsWeb;
  static bool get enableWebAuthn => kIsWeb;
  static bool get enablePushNotifications => !kIsWeb;

  /// Logging configuration
  static bool get enableLogging => current != production;
  static bool get enableCrashlytics => current == production;

  /// Cache configuration
  static Duration get cacheTimeout => const Duration(minutes: 5);
  static int get maxCacheSize => 50 * 1024 * 1024; // 50 MB

  /// Retry configuration
  static int get maxRetries => 3;
  static Duration get retryDelay => const Duration(seconds: 1);

  /// Timeouts
  static Duration get connectionTimeout => const Duration(seconds: 30);
  static Duration get receiveTimeout => const Duration(seconds: 30);
}

/// Configuration for physical device testing
class DeviceTestConfig {
  /// Get API URL for physical device testing
  /// Update this with your development machine's IP address
  static String getMachineIP() {
    // TODO: Update with your machine's IP address when testing on physical devices
    // You can find this by running 'ifconfig' or 'ipconfig'
    return '192.168.1.100'; // Example IP - replace with your actual IP
  }

  /// Get API URL for physical device
  static String getPhysicalDeviceApiUrl() {
    return 'http://${getMachineIP()}:8000';
  }

  /// Instructions for setting up physical device testing
  static String get setupInstructions => '''
  Physical Device Testing Setup:
  
  1. Find your machine's IP address:
     - Mac/Linux: Run 'ifconfig' and look for your WiFi adapter
     - Windows: Run 'ipconfig' and look for IPv4 Address
  
  2. Update getMachineIP() with your IP address
  
  3. Ensure your device and development machine are on the same network
  
  4. For Android:
     - Enable Developer Mode
     - Enable USB Debugging
     - Run: adb reverse tcp:8000 tcp:8000 (for USB connection)
  
  5. For iOS:
     - Trust your development certificate
     - Ensure device is registered in provisioning profile
  
  6. Update backend CORS to allow your IP:
     CORS_ORIGINS: ["http://YOUR_IP:3000"]
  ''';
}
