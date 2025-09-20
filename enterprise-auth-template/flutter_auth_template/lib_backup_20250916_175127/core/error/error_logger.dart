import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'app_exception.dart';

final errorLoggerProvider = Provider<ErrorLogger>((ref) {
  return ErrorLogger();
});

enum LogLevel {
  debug,
  info,
  warning,
  error,
  critical,
}

class ErrorLogger {
  static const int _maxLogEntries = 1000;
  static const String _logFileName = 'app_errors.log';
  
  final List<LogEntry> _logEntries = [];
  File? _logFile;
  bool _isInitialized = false;

  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;
    
    try {
      final directory = await getApplicationDocumentsDirectory();
      _logFile = File('${directory.path}/$_logFileName');
      await _loadExistingLogs();
      _isInitialized = true;
    } catch (e) {
      debugPrint('Failed to initialize error logger: $e');
    }
  }

  Future<void> _loadExistingLogs() async {
    if (_logFile == null || !await _logFile!.exists()) return;
    
    try {
      final content = await _logFile!.readAsString();
      final lines = content.split('\n').where((line) => line.isNotEmpty);
      
      for (final line in lines) {
        try {
          final logData = json.decode(line);
          _logEntries.add(LogEntry.fromJson(logData));
        } catch (e) {
          // Skip malformed log entries
          continue;
        }
      }
      
      // Keep only recent entries
      if (_logEntries.length > _maxLogEntries) {
        _logEntries.removeRange(0, _logEntries.length - _maxLogEntries);
      }
    } catch (e) {
      debugPrint('Failed to load existing logs: $e');
    }
  }

  Future<void> _persistLogEntry(LogEntry entry) async {
    if (_logFile == null) return;
    
    try {
      await _logFile!.writeAsString(
        '${json.encode(entry.toJson())}\n',
        mode: FileMode.append,
      );
    } catch (e) {
      debugPrint('Failed to persist log entry: $e');
    }
  }

  Future<void> _addLogEntry(LogEntry entry) async {
    await _ensureInitialized();
    
    _logEntries.add(entry);
    
    // Maintain maximum log entries
    if (_logEntries.length > _maxLogEntries) {
      _logEntries.removeAt(0);
    }
    
    // Persist to file
    await _persistLogEntry(entry);
    
    // Print to console in debug mode
    if (kDebugMode) {
      final levelStr = entry.level.name.toUpperCase().padRight(8);
      final timestamp = entry.timestamp.toIso8601String();
      debugPrint('[$levelStr] $timestamp: ${entry.message}');
      if (entry.exception != null) {
        debugPrint('Exception: ${entry.exception!.technicalMessage}');
      }
      if (entry.stackTrace != null) {
        debugPrint('Stack trace: ${entry.stackTrace}');
      }
    }
  }

  /// Log an exception with full context
  Future<void> logException(
    AppException exception, [
    StackTrace? stackTrace,
    String? context,
    Map<String, dynamic>? additionalData,
  ]) async {
    final entry = LogEntry(
      timestamp: DateTime.now(),
      level: _getLogLevelForException(exception),
      message: exception.technicalMessage,
      exception: exception,
      stackTrace: stackTrace,
      context: context,
      additionalData: additionalData,
    );
    
    await _addLogEntry(entry);
  }

  /// Log a retry attempt
  Future<void> logRetryAttempt(
    AppException exception,
    int attempt,
    int maxAttempts,
    Duration delay,
  ) async {
    final entry = LogEntry(
      timestamp: DateTime.now(),
      level: LogLevel.warning,
      message: 'Retry attempt $attempt/$maxAttempts after ${delay.inSeconds}s',
      exception: exception,
      context: 'retry_mechanism',
      additionalData: {
        'attempt': attempt,
        'maxAttempts': maxAttempts,
        'delaySeconds': delay.inSeconds,
      },
    );
    
    await _addLogEntry(entry);
  }

  /// Log an error with context
  Future<void> logContextualError(
    AppException exception,
    String context, [
    Map<String, dynamic>? additionalData,
  ]) async {
    final entry = LogEntry(
      timestamp: DateTime.now(),
      level: _getLogLevelForException(exception),
      message: 'Error in $context: ${exception.technicalMessage}',
      exception: exception,
      context: context,
      additionalData: additionalData,
    );
    
    await _addLogEntry(entry);
  }

  /// Log a critical system error
  Future<void> logCriticalError(
    AppException exception,
    StackTrace stackTrace, [
    String? context,
  ]) async {
    final entry = LogEntry(
      timestamp: DateTime.now(),
      level: LogLevel.critical,
      message: 'CRITICAL ERROR: ${exception.technicalMessage}',
      exception: exception,
      stackTrace: stackTrace,
      context: context ?? 'global_error_handler',
      additionalData: {
        'isCritical': true,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
    
    await _addLogEntry(entry);
  }

  /// Log general information
  Future<void> logInfo(
    String message, [
    String? context,
    Map<String, dynamic>? additionalData,
  ]) async {
    final entry = LogEntry(
      timestamp: DateTime.now(),
      level: LogLevel.info,
      message: message,
      context: context,
      additionalData: additionalData,
    );
    
    await _addLogEntry(entry);
  }

  /// Log debug information
  Future<void> logDebug(
    String message, [
    String? context,
    Map<String, dynamic>? additionalData,
  ]) async {
    if (!kDebugMode) return; // Only log debug messages in debug mode
    
    final entry = LogEntry(
      timestamp: DateTime.now(),
      level: LogLevel.debug,
      message: message,
      context: context,
      additionalData: additionalData,
    );
    
    await _addLogEntry(entry);
  }

  /// Log a warning
  Future<void> logWarning(
    String message, [
    String? context,
    Map<String, dynamic>? additionalData,
  ]) async {
    final entry = LogEntry(
      timestamp: DateTime.now(),
      level: LogLevel.warning,
      message: message,
      context: context,
      additionalData: additionalData,
    );
    
    await _addLogEntry(entry);
  }

  /// Get all log entries
  List<LogEntry> getLogEntries({
    LogLevel? minLevel,
    DateTime? since,
    String? context,
  }) {
    return _logEntries.where((entry) {
      if (minLevel != null && entry.level.index < minLevel.index) {
        return false;
      }
      if (since != null && entry.timestamp.isBefore(since)) {
        return false;
      }
      if (context != null && entry.context != context) {
        return false;
      }
      return true;
    }).toList();
  }

  /// Get recent critical errors
  List<LogEntry> getCriticalErrors({int limit = 10}) {
    return _logEntries
        .where((entry) => entry.level == LogLevel.critical)
        .take(limit)
        .toList()
        .reversed
        .toList();
  }

  /// Get error statistics
  Map<String, int> getErrorStatistics() {
    final stats = <String, int>{};
    
    for (final entry in _logEntries) {
      final key = entry.exception?.runtimeType.toString() ?? entry.level.name;
      stats[key] = (stats[key] ?? 0) + 1;
    }
    
    return stats;
  }

  /// Export logs as JSON string
  Future<String> exportLogsAsJson() async {
    await _ensureInitialized();
    
    final exportData = {
      'exported_at': DateTime.now().toIso8601String(),
      'total_entries': _logEntries.length,
      'entries': _logEntries.map((entry) => entry.toJson()).toList(),
    };
    
    return json.encode(exportData);
  }

  /// Clear all logs
  Future<void> clearLogs() async {
    await _ensureInitialized();
    
    _logEntries.clear();
    
    if (_logFile != null && await _logFile!.exists()) {
      await _logFile!.delete();
    }
  }

  /// Get log level for exception type
  LogLevel _getLogLevelForException(AppException exception) {
    return exception.when(
      network: (message, statusCode, endpoint, details) => LogLevel.warning,
      authentication: (message, reason, details) => LogLevel.error,
      authorization: (message, requiredPermission, details) => LogLevel.error,
      validation: (message, fieldErrors, details) => LogLevel.warning,
      notFound: (message, resource, details) => LogLevel.info,
      server: (message, statusCode, errorCode, details) => LogLevel.error,
      timeout: (message, duration, details) => LogLevel.warning,
      connectivity: (message, type, details) => LogLevel.warning,
      storage: (message, operation, details) => LogLevel.error,
      permission: (message, permission, details) => LogLevel.error,
      rateLimited: (message, retryAfter, limit, details) => LogLevel.info,
      business: (message, code, details) => LogLevel.warning,
      unknown: (message, originalError, stackTrace, details) => LogLevel.critical,
    );
  }
}

class LogEntry {
  final DateTime timestamp;
  final LogLevel level;
  final String message;
  final AppException? exception;
  final StackTrace? stackTrace;
  final String? context;
  final Map<String, dynamic>? additionalData;

  LogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
    this.exception,
    this.stackTrace,
    this.context,
    this.additionalData,
  });

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'level': level.name,
      'message': message,
      if (exception != null) 'exception': exception!.toJson(),
      if (stackTrace != null) 'stackTrace': stackTrace.toString(),
      if (context != null) 'context': context,
      if (additionalData != null) 'additionalData': additionalData,
    };
  }

  factory LogEntry.fromJson(Map<String, dynamic> json) {
    return LogEntry(
      timestamp: DateTime.parse(json['timestamp']),
      level: LogLevel.values.firstWhere(
        (l) => l.name == json['level'],
        orElse: () => LogLevel.info,
      ),
      message: json['message'],
      context: json['context'],
      additionalData: json['additionalData'] != null
          ? Map<String, dynamic>.from(json['additionalData'])
          : null,
      // Note: We don't reconstruct exception and stackTrace from JSON
      // as they are complex objects that are better handled in memory
    );
  }

  @override
  String toString() {
    return '[${level.name.toUpperCase()}] $timestamp: $message${context != null ? ' (context: $context)' : ''}';
  }
}

// Extension for easy logging from anywhere in the app
extension ErrorLoggingExtension on WidgetRef {
  ErrorLogger get logger => read(errorLoggerProvider);
  
  Future<void> logError(AppException exception, [StackTrace? stackTrace, String? context]) async {
    await logger.logException(exception, stackTrace, context);
  }
  
  Future<void> logInfo(String message, [String? context]) async {
    await logger.logInfo(message, context);
  }
  
  Future<void> logWarning(String message, [String? context]) async {
    await logger.logWarning(message, context);
  }
  
  Future<void> logDebug(String message, [String? context]) async {
    await logger.logDebug(message, context);
  }
}