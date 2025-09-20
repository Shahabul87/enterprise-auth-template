import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Performance monitoring utility for tracking app performance
class PerformanceMonitor {
  static final Map<String, Stopwatch> _operations = {};
  static final Map<String, List<int>> _metrics = {};
  static final List<Duration> _frameTimes = [];
  static bool _isFrameTrackingActive = false;
  static DateTime? _frameTrackingStartTime;

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
    _frameTimes.clear();
    _isFrameTrackingActive = false;
    _frameTrackingStartTime = null;
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

  /// Start frame tracking for FPS monitoring
  static void startFrameTracking() {
    _isFrameTrackingActive = true;
    _frameTimes.clear();
    _frameTrackingStartTime = DateTime.now();
    if (kDebugMode) {
      developer.log('Started frame tracking', name: 'Performance');
    }
  }

  /// Stop frame tracking
  static void stopFrameTracking() {
    _isFrameTrackingActive = false;
    _frameTrackingStartTime = null;
    if (kDebugMode) {
      developer.log('Stopped frame tracking', name: 'Performance');
    }
  }

  /// Record frame timing
  static void onFrame(Duration frameDuration) {
    if (!_isFrameTrackingActive) return;

    _frameTimes.add(frameDuration);

    // Detect jank (frames taking longer than 16.67ms for 60fps)
    if (frameDuration.inMilliseconds > 16) {
      if (kDebugMode) {
        developer.log(
          'Jank detected: ${frameDuration.inMilliseconds}ms frame',
          name: 'Performance',
          level: 900,
        );
      }
    }
  }

  /// Calculate current FPS based on recorded frame times
  static double calculateFPS() {
    if (_frameTimes.isEmpty || _frameTrackingStartTime == null) return 0.0;

    final now = DateTime.now();
    final elapsedMilliseconds = now.difference(_frameTrackingStartTime!).inMilliseconds;

    // If less than 1ms has passed, estimate based on frame times
    if (elapsedMilliseconds < 1) {
      if (_frameTimes.isEmpty) return 0.0;
      final avgFrameTimeMs = _frameTimes.fold<int>(0, (sum, duration) => sum + duration.inMilliseconds) / _frameTimes.length;
      return avgFrameTimeMs > 0 ? 1000.0 / avgFrameTimeMs : 0.0;
    }

    final elapsedSeconds = elapsedMilliseconds / 1000.0;
    return _frameTimes.length / elapsedSeconds;
  }

  /// Get average frame time in milliseconds
  static double getAverageFrameTime() {
    if (_frameTimes.isEmpty) return 0.0;

    final totalMs = _frameTimes.fold<int>(0, (sum, duration) => sum + duration.inMilliseconds);
    return totalMs / _frameTimes.length;
  }

  /// Check if current FPS is below threshold (default 30fps)
  static bool isPerformancePoor({double threshold = 30.0}) {
    return calculateFPS() < threshold;
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