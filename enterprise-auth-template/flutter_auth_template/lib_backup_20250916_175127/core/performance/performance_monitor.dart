import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Performance monitoring utility for tracking app performance
class PerformanceMonitor {
  static final Map<String, Stopwatch> _operations = {};
  static final Map<String, List<int>> _metrics = {};

  /// Start tracking a performance operation
  static void startOperation(String operationName) {
    _operations[operationName] = Stopwatch()..start();
    if (kDebugMode) {
      developer.log('Started operation: $operationName', name: 'Performance');
    }
  }

  /// End tracking a performance operation
  static int? endOperation(String operationName) {
    final stopwatch = _operations[operationName];
    if (stopwatch == null) return null;

    stopwatch.stop();
    final duration = stopwatch.elapsedMilliseconds;

    // Store metrics for analysis
    _metrics[operationName] ??= [];
    _metrics[operationName]!.add(duration);

    // Clean up
    _operations.remove(operationName);

    if (kDebugMode) {
      developer.log(
        'Completed operation: $operationName in ${duration}ms',
        name: 'Performance',
      );
    }

    // Log warning if operation took too long
    if (duration > 1000) {
      developer.log(
        '⚠️ Slow operation detected: $operationName took ${duration}ms',
        name: 'Performance',
        level: 900,
      );
    }

    return duration;
  }

  /// Track a synchronous operation
  static T trackSync<T>(String operationName, T Function() operation) {
    startOperation(operationName);
    try {
      return operation();
    } finally {
      endOperation(operationName);
    }
  }

  /// Track an asynchronous operation
  static Future<T> trackAsync<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    startOperation(operationName);
    try {
      return await operation();
    } finally {
      endOperation(operationName);
    }
  }

  /// Get average duration for an operation
  static double? getAverageDuration(String operationName) {
    final metrics = _metrics[operationName];
    if (metrics == null || metrics.isEmpty) return null;

    final sum = metrics.reduce((a, b) => a + b);
    return sum / metrics.length;
  }

  /// Get performance report
  static Map<String, dynamic> getReport() {
    final report = <String, dynamic>{};

    for (final entry in _metrics.entries) {
      final metrics = entry.value;
      if (metrics.isEmpty) continue;

      final sum = metrics.reduce((a, b) => a + b);
      final average = sum / metrics.length;
      final max = metrics.reduce((a, b) => a > b ? a : b);
      final min = metrics.reduce((a, b) => a < b ? a : b);

      report[entry.key] = {
        'count': metrics.length,
        'average': average.toStringAsFixed(2),
        'max': max,
        'min': min,
        'total': sum,
      };
    }

    return report;
  }

  /// Clear all metrics
  static void clearMetrics() {
    _operations.clear();
    _metrics.clear();
  }

  /// Log memory usage
  static void logMemoryUsage() {
    if (kDebugMode) {
      developer.log(
        'Memory usage tracking (requires platform-specific implementation)',
        name: 'Performance',
      );
    }
  }

  /// Track widget build time
  static void trackWidgetBuild(String widgetName, VoidCallback buildMethod) {
    trackSync('Widget build: $widgetName', buildMethod);
  }

  /// Track API call performance
  static Future<T> trackApiCall<T>(
    String endpoint,
    Future<T> Function() apiCall,
  ) {
    return trackAsync('API call: $endpoint', apiCall);
  }

  /// Track database operation
  static Future<T> trackDatabaseOperation<T>(
    String operation,
    Future<T> Function() dbOperation,
  ) {
    return trackAsync('DB: $operation', dbOperation);
  }

  /// Track navigation
  static void trackNavigation(String fromRoute, String toRoute) {
    if (kDebugMode) {
      developer.log(
        'Navigation: $fromRoute → $toRoute',
        name: 'Performance',
      );
    }
  }

  /// Export metrics for external analysis
  static String exportMetrics() {
    final report = getReport();
    final buffer = StringBuffer();

    buffer.writeln('Performance Report');
    buffer.writeln('=' * 50);

    for (final entry in report.entries) {
      buffer.writeln('\n${entry.key}:');
      final metrics = entry.value as Map<String, dynamic>;
      for (final metric in metrics.entries) {
        buffer.writeln('  ${metric.key}: ${metric.value}');
      }
    }

    return buffer.toString();
  }
}

/// Performance tracking mixin for StatefulWidgets
mixin PerformanceTrackingMixin<T extends StatefulWidget> on State<T> {
  late final String _widgetName;

  @override
  void initState() {
    super.initState();
    _widgetName = T.toString();
    PerformanceMonitor.startOperation('Init: $_widgetName');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    PerformanceMonitor.endOperation('Init: $_widgetName');
  }

  @override
  void dispose() {
    PerformanceMonitor.trackSync('Dispose: $_widgetName', () {
      super.dispose();
    });
  }
}