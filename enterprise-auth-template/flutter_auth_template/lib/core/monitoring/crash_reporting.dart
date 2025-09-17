import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Crash reporting service for production error tracking
class CrashReporting {
  static final CrashReporting _instance = CrashReporting._internal();
  factory CrashReporting() => _instance;
  CrashReporting._internal();

  bool _isInitialized = false;
  String? _userId;
  Map<String, dynamic> _userContext = {};
  final List<Breadcrumb> _breadcrumbs = [];
  static const int _maxBreadcrumbs = 100;

  /// Initialize crash reporting
  Future<void> initialize({
    required String dsn,
    required String environment,
    bool debug = false,
  }) async {
    if (_isInitialized) return;

    try {
      // In production, this would initialize Sentry or similar service
      // For now, we'll set up local error handling

      // Capture Flutter errors
      FlutterError.onError = (FlutterErrorDetails details) {
        captureException(
          details.exception,
          stackTrace: details.stack,
          context: {
            'library': details.library ?? 'unknown',
            'summary': details.summary.toString(),
          },
        );
      };

      // Capture async errors
      PlatformDispatcher.instance.onError = (error, stack) {
        captureException(error, stackTrace: stack);
        return true;
      };

      await _collectDeviceInfo();
      _isInitialized = true;

      if (debug) {
        debugPrint('Crash reporting initialized for environment: $environment');
      }
    } catch (e) {
      debugPrint('Failed to initialize crash reporting: $e');
    }
  }

  /// Set user context for error reports
  void setUser({
    required String id,
    String? email,
    String? username,
    Map<String, dynamic>? extra,
  }) {
    _userId = id;
    _userContext = {
      'id': id,
      if (email != null) 'email': email,
      if (username != null) 'username': username,
      if (extra != null) ...extra,
    };
  }

  /// Clear user context (on logout)
  void clearUser() {
    _userId = null;
    _userContext = {};
  }

  /// Add breadcrumb for error context
  void addBreadcrumb({
    required String message,
    String? category,
    BreadcrumbLevel level = BreadcrumbLevel.info,
    Map<String, dynamic>? data,
  }) {
    final breadcrumb = Breadcrumb(
      message: message,
      category: category ?? 'custom',
      level: level,
      timestamp: DateTime.now(),
      data: data,
    );

    _breadcrumbs.add(breadcrumb);

    // Keep only the last N breadcrumbs
    if (_breadcrumbs.length > _maxBreadcrumbs) {
      _breadcrumbs.removeAt(0);
    }
  }

  /// Capture an exception
  Future<void> captureException(
    dynamic exception, {
    dynamic stackTrace,
    Map<String, dynamic>? context,
    ErrorLevel level = ErrorLevel.error,
  }) async {
    if (!_isInitialized) return;

    try {
      final report = ErrorReport(
        exception: exception.toString(),
        stackTrace: stackTrace?.toString(),
        level: level,
        timestamp: DateTime.now(),
        userId: _userId,
        userContext: _userContext,
        context: context ?? {},
        breadcrumbs: List.from(_breadcrumbs),
        deviceInfo: await _getDeviceInfo(),
        appInfo: await _getAppInfo(),
      );

      // In production, send to crash reporting service
      await _sendReport(report);

      // In debug mode, also print to console
      if (kDebugMode) {
        debugPrint('=== CRASH REPORT ===');
        debugPrint('Exception: ${report.exception}');
        debugPrint('Level: ${report.level}');
        debugPrint('User: ${report.userId}');
        debugPrint('Context: ${report.context}');
        debugPrint('StackTrace: ${report.stackTrace}');
      }
    } catch (e) {
      debugPrint('Failed to capture exception: $e');
    }
  }

  /// Capture a message
  Future<void> captureMessage(
    String message, {
    ErrorLevel level = ErrorLevel.info,
    Map<String, dynamic>? extra,
  }) async {
    if (!_isInitialized) return;

    final report = ErrorReport(
      exception: message,
      level: level,
      timestamp: DateTime.now(),
      userId: _userId,
      userContext: _userContext,
      context: extra ?? {},
      breadcrumbs: List.from(_breadcrumbs),
      deviceInfo: await _getDeviceInfo(),
      appInfo: await _getAppInfo(),
    );

    await _sendReport(report);
  }

  /// Collect device information
  Future<void> _collectDeviceInfo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        _deviceContext = {
          'platform': 'android',
          'model': androidInfo.model,
          'manufacturer': androidInfo.manufacturer,
          'version': androidInfo.version.release,
          'sdk': androidInfo.version.sdkInt,
        };
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        _deviceContext = {
          'platform': 'ios',
          'model': iosInfo.model,
          'systemName': iosInfo.systemName,
          'systemVersion': iosInfo.systemVersion,
        };
      }
    } catch (e) {
      debugPrint('Failed to collect device info: $e');
    }
  }

  Map<String, dynamic> _deviceContext = {};

  Future<Map<String, dynamic>> _getDeviceInfo() async {
    return _deviceContext;
  }

  Future<Map<String, dynamic>> _getAppInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return {
        'version': packageInfo.version,
        'buildNumber': packageInfo.buildNumber,
        'packageName': packageInfo.packageName,
      };
    } catch (e) {
      return {};
    }
  }

  /// Send report to crash reporting service
  Future<void> _sendReport(ErrorReport report) async {
    // In production, this would send to Sentry, Crashlytics, etc.
    // For now, we'll store locally or send to a custom endpoint

    if (kDebugMode) {
      // Log to console in debug mode
      debugPrint('Would send crash report: ${report.toJson()}');
    } else {
      // TODO: Implement actual crash reporting service integration
      // Example: await _sentryClient.captureException(report);
    }
  }

  /// Wrap async operations with error handling
  static Future<T?> runGuarded<T>(
    Future<T> Function() body, {
    Map<String, dynamic>? context,
  }) async {
    try {
      return await body();
    } catch (error, stackTrace) {
      CrashReporting().captureException(
        error,
        stackTrace: stackTrace,
        context: context,
      );
      return null;
    }
  }

  /// Wrap sync operations with error handling
  static T? runGuardedSync<T>(
    T Function() body, {
    Map<String, dynamic>? context,
  }) {
    try {
      return body();
    } catch (error, stackTrace) {
      CrashReporting().captureException(
        error,
        stackTrace: stackTrace,
        context: context,
      );
      return null;
    }
  }
}

/// Error severity levels
enum ErrorLevel {
  debug,
  info,
  warning,
  error,
  fatal,
}

/// Breadcrumb levels
enum BreadcrumbLevel {
  debug,
  info,
  navigation,
  http,
  error,
  critical,
}

/// Breadcrumb for error context
class Breadcrumb {
  final String message;
  final String category;
  final BreadcrumbLevel level;
  final DateTime timestamp;
  final Map<String, dynamic>? data;

  const Breadcrumb({
    required this.message,
    required this.category,
    required this.level,
    required this.timestamp,
    this.data,
  });

  Map<String, dynamic> toJson() => {
        'message': message,
        'category': category,
        'level': level.toString(),
        'timestamp': timestamp.toIso8601String(),
        if (data != null) 'data': data,
      };
}

/// Error report model
class ErrorReport {
  final String exception;
  final String? stackTrace;
  final ErrorLevel level;
  final DateTime timestamp;
  final String? userId;
  final Map<String, dynamic> userContext;
  final Map<String, dynamic> context;
  final List<Breadcrumb> breadcrumbs;
  final Map<String, dynamic> deviceInfo;
  final Map<String, dynamic> appInfo;

  const ErrorReport({
    required this.exception,
    this.stackTrace,
    required this.level,
    required this.timestamp,
    this.userId,
    required this.userContext,
    required this.context,
    required this.breadcrumbs,
    required this.deviceInfo,
    required this.appInfo,
  });

  Map<String, dynamic> toJson() => {
        'exception': exception,
        'stackTrace': stackTrace,
        'level': level.toString(),
        'timestamp': timestamp.toIso8601String(),
        'userId': userId,
        'userContext': userContext,
        'context': context,
        'breadcrumbs': breadcrumbs.map((b) => b.toJson()).toList(),
        'deviceInfo': deviceInfo,
        'appInfo': appInfo,
      };
}