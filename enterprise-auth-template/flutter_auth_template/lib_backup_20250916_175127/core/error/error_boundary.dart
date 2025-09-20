import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../monitoring/crash_reporting.dart';

/// Error boundary widget to catch and handle errors in widget tree
class ErrorBoundary extends ConsumerStatefulWidget {
  final Widget child;
  final Widget Function(Object error, StackTrace? stack)? errorBuilder;
  final void Function(Object error, StackTrace? stack)? onError;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
    this.onError,
  });

  @override
  ConsumerState<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends ConsumerState<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;

  @override
  void initState() {
    super.initState();
    // Set up error handling for this widget tree
    ErrorWidget.builder = _errorWidgetBuilder;
  }

  Widget _errorWidgetBuilder(FlutterErrorDetails details) {
    // Capture the error
    _captureError(details.exception, details.stack);

    // Return error UI
    return _buildErrorWidget(details.exception, details.stack);
  }

  void _captureError(Object error, StackTrace? stack) {
    setState(() {
      _error = error;
      _stackTrace = stack;
    });

    // Report to crash reporting
    CrashReporting().captureException(
      error,
      stackTrace: stack,
      context: {
        'widget': widget.child.runtimeType.toString(),
        'boundary': 'ErrorBoundary',
      },
    );

    // Call custom error handler
    widget.onError?.call(error, stack);
  }

  Widget _buildErrorWidget(Object error, StackTrace? stack) {
    if (widget.errorBuilder != null) {
      return widget.errorBuilder!(error, stack);
    }

    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Something went wrong',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'We encountered an unexpected error. Please try again.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _retry,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: const Text('Retry'),
                  ),
                  if (const bool.fromEnvironment('dart.vm.product') == false) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Debug Info:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            error.toString(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _retry() {
    setState(() {
      _error = null;
      _stackTrace = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return _buildErrorWidget(_error!, _stackTrace);
    }

    // Wrap child in error handling
    return Builder(
      builder: (context) {
        ErrorWidget.builder = _errorWidgetBuilder;
        return widget.child;
      },
    );
  }
}

/// Global error handler for the app
class GlobalErrorHandler {
  static void initialize() {
    // Handle Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      CrashReporting().captureException(
        details.exception,
        stackTrace: details.stack,
        context: {
          'library': details.library,
          'context': details.context?.toString(),
        },
      );
    };

    // Handle async errors
    PlatformDispatcher.instance.onError = (error, stack) {
      CrashReporting().captureException(
        error,
        stackTrace: stack,
        level: ErrorLevel.error,
      );
      return true;
    };
  }

  /// Handle API errors
  static void handleApiError(dynamic error, {Map<String, dynamic>? context}) {
    CrashReporting().captureException(
      error,
      context: {
        'type': 'api_error',
        ...?context,
      },
      level: ErrorLevel.warning,
    );
  }

  /// Handle authentication errors
  static void handleAuthError(dynamic error, {Map<String, dynamic>? context}) {
    CrashReporting().captureException(
      error,
      context: {
        'type': 'auth_error',
        ...?context,
      },
      level: ErrorLevel.warning,
    );
  }

  /// Handle validation errors
  static void handleValidationError(String field, String message) {
    CrashReporting().captureMessage(
      'Validation error: $field - $message',
      level: ErrorLevel.info,
      extra: {
        'field': field,
        'message': message,
      },
    );
  }

  /// Log navigation errors
  static void handleNavigationError(String route, dynamic error) {
    CrashReporting().captureException(
      error,
      context: {
        'type': 'navigation_error',
        'route': route,
      },
      level: ErrorLevel.warning,
    );
  }
}

/// Extension to add error handling to Future
extension FutureErrorHandling<T> on Future<T> {
  Future<T?> withErrorHandling({
    Map<String, dynamic>? context,
    T? defaultValue,
  }) async {
    try {
      return await this;
    } catch (error, stack) {
      CrashReporting().captureException(
        error,
        stackTrace: stack,
        context: context,
      );
      return defaultValue;
    }
  }

  Future<T> withErrorHandlingOrThrow({
    Map<String, dynamic>? context,
  }) async {
    try {
      return await this;
    } catch (error, stack) {
      CrashReporting().captureException(
        error,
        stackTrace: stack,
        context: context,
      );
      rethrow;
    }
  }
}