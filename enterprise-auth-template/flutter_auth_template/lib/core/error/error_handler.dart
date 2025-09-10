import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'app_exception.dart';
import 'error_logger.dart';

final errorHandlerProvider = Provider<ErrorHandler>((ref) {
  return ErrorHandler(ref.read(errorLoggerProvider));
});

class ErrorHandler {
  final ErrorLogger _logger;
  
  ErrorHandler(this._logger);

  /// Handles exceptions and converts them to AppException
  AppException handleException(dynamic error, [StackTrace? stackTrace]) {
    AppException appException;

    if (error is AppException) {
      appException = error;
    } else if (error is http.Response) {
      appException = _handleHttpResponse(error);
    } else if (error is SocketException) {
      appException = AppException.connectivity(
        message: 'No internet connection',
        type: 'socket',
        details: {'originalMessage': error.message},
      );
    } else if (error is TimeoutException) {
      appException = AppException.timeout(
        message: 'Request timed out',
        duration: error.duration,
      );
    } else if (error is FormatException) {
      appException = AppException.validation(
        message: 'Invalid data format',
        details: {'originalMessage': error.message},
      );
    } else if (error is HttpException) {
      appException = AppException.network(
        message: error.message,
        statusCode: error.statusCode,
      );
    } else {
      appException = AppException.unknown(
        message: 'An unexpected error occurred',
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    // Log the exception
    _logger.logException(appException, stackTrace);

    return appException;
  }

  /// Handles HTTP responses and creates appropriate exceptions
  AppException _handleHttpResponse(http.Response response) {
    final statusCode = response.statusCode;
    String message = 'HTTP Error $statusCode';
    Map<String, dynamic>? details;

    // Try to parse error details from response body
    try {
      final body = json.decode(response.body);
      if (body is Map<String, dynamic>) {
        message = body['message'] ?? body['error'] ?? message;
        details = body;
      }
    } catch (e) {
      // Ignore JSON parsing errors, use default message
    }

    return AppExceptions.fromHttpStatusCode(statusCode, message);
  }

  /// Shows user-friendly error message
  void showErrorToUser(BuildContext context, AppException exception) {
    final userMessage = exception.userMessage;
    
    // Determine the type of UI feedback based on exception type
    exception.when(
      network: (message, statusCode, endpoint, details) => 
          _showErrorSnackBar(context, userMessage, Icons.wifi_off),
      authentication: (message, reason, details) => 
          _showErrorDialog(context, 'Authentication Error', userMessage),
      authorization: (message, requiredPermission, details) => 
          _showErrorDialog(context, 'Access Denied', userMessage),
      validation: (message, fieldErrors, details) => 
          _showValidationErrors(context, userMessage, fieldErrors),
      notFound: (message, resource, details) => 
          _showErrorSnackBar(context, userMessage, Icons.search_off),
      server: (message, statusCode, errorCode, details) => 
          _showErrorSnackBar(context, userMessage, Icons.error),
      timeout: (message, duration, details) => 
          _showErrorSnackBar(context, userMessage, Icons.access_time),
      connectivity: (message, type, details) => 
          _showErrorSnackBar(context, userMessage, Icons.signal_wifi_off),
      storage: (message, operation, details) => 
          _showErrorSnackBar(context, userMessage, Icons.storage),
      permission: (message, permission, details) => 
          _showErrorDialog(context, 'Permission Required', userMessage),
      rateLimited: (message, retryAfter, limit, details) => 
          _showErrorSnackBar(context, userMessage, Icons.hourglass_empty),
      business: (message, code, details) => 
          _showErrorDialog(context, 'Error', userMessage),
      unknown: (message, originalError, stackTrace, details) => 
          _showErrorSnackBar(context, userMessage, Icons.error_outline),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error, color: Colors.red),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showValidationErrors(
    BuildContext context, 
    String message, 
    Map<String, List<String>>? fieldErrors,
  ) {
    if (fieldErrors?.isNotEmpty ?? false) {
      final errorList = <String>[];
      fieldErrors!.forEach((field, errors) {
        for (final error in errors) {
          errorList.add('$field: $error');
        }
      });
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 8),
              Text('Validation Errors'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: errorList.map((error) => 
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('• $error'),
                ),
              ).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      _showErrorSnackBar(context, message, Icons.warning);
    }
  }

  /// Creates a retry mechanism for retryable exceptions
  Future<T> withRetry<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration? baseDelay,
    bool Function(AppException)? shouldRetry,
  }) async {
    int attempt = 0;
    
    while (attempt <= maxRetries) {
      try {
        return await operation();
      } catch (error, stackTrace) {
        final appException = handleException(error, stackTrace);
        
        if (attempt == maxRetries || 
            (shouldRetry != null && !shouldRetry(appException)) ||
            (!appException.isRetryable)) {
          throw appException;
        }
        
        attempt++;
        final delay = baseDelay ?? 
                     appException.retryDelay ?? 
                     Duration(seconds: attempt * 2);
        
        _logger.logRetryAttempt(appException, attempt, maxRetries, delay);
        await Future.delayed(delay);
      }
    }
    
    throw AppException.unknown(message: 'Retry loop completed unexpectedly');
  }

  /// Wraps operations with comprehensive error handling
  Future<T> safeExecute<T>(
    Future<T> Function() operation, {
    String? context,
    T? fallbackValue,
    bool silent = false,
  }) async {
    try {
      return await operation();
    } catch (error, stackTrace) {
      final appException = handleException(error, stackTrace);
      
      if (context != null) {
        _logger.logContextualError(appException, context);
      }
      
      if (fallbackValue != null) {
        return fallbackValue;
      }
      
      if (!silent) {
        rethrow;
      }
      
      throw appException;
    }
  }

  /// Global error handler for uncaught exceptions
  void handleGlobalError(Object error, StackTrace stackTrace) {
    final appException = handleException(error, stackTrace);
    
    // Log critical error
    _logger.logCriticalError(appException, stackTrace);
    
    // In debug mode, also print to console
    if (kDebugMode) {
      debugPrint('Global Error: ${appException.technicalMessage}');
      debugPrintStack(stackTrace: stackTrace);
    }
    
    // Could also send to crash reporting service here
    // crashReporter.recordError(appException, stackTrace);
  }

  /// Handles specific API errors and converts them to appropriate exceptions
  AppException handleApiError(http.Response response) {
    final statusCode = response.statusCode;
    Map<String, dynamic>? errorData;
    
    try {
      final responseBody = json.decode(response.body);
      if (responseBody is Map<String, dynamic>) {
        errorData = responseBody;
      }
    } catch (e) {
      // JSON parsing failed, use default handling
    }
    
    final message = errorData?['message'] ?? 
                   errorData?['error'] ?? 
                   'HTTP Error $statusCode';
    
    switch (statusCode) {
      case 400:
        return AppException.validation(
          message: message,
          fieldErrors: _parseFieldErrors(errorData),
          details: errorData,
        );
      case 401:
        return AppException.authentication(
          message: message,
          reason: errorData?['reason'],
          details: errorData,
        );
      case 403:
        return AppException.authorization(
          message: message,
          requiredPermission: errorData?['required_permission'],
          details: errorData,
        );
      case 404:
        return AppException.notFound(
          message: message,
          resource: errorData?['resource'],
          details: errorData,
        );
      case 408:
        return AppException.timeout(
          message: message,
          details: errorData,
        );
      case 429:
        final retryAfterSeconds = errorData?['retry_after'] as int?;
        return AppException.rateLimited(
          message: message,
          retryAfter: retryAfterSeconds != null 
              ? Duration(seconds: retryAfterSeconds) 
              : null,
          limit: errorData?['limit'] as int?,
          details: errorData,
        );
      case 422:
        return AppException.validation(
          message: message,
          fieldErrors: _parseFieldErrors(errorData),
          details: errorData,
        );
      default:
        if (statusCode >= 500) {
          return AppException.server(
            message: message,
            statusCode: statusCode,
            errorCode: errorData?['error_code'],
            details: errorData,
          );
        } else {
          return AppException.network(
            message: message,
            statusCode: statusCode,
            details: errorData,
          );
        }
    }
  }
  
  Map<String, List<String>>? _parseFieldErrors(Map<String, dynamic>? errorData) {
    if (errorData == null) return null;
    
    // Handle different API error formats
    final errors = errorData['errors'] ?? errorData['field_errors'] ?? errorData['validation_errors'];
    
    if (errors is Map<String, dynamic>) {
      final fieldErrors = <String, List<String>>{};
      errors.forEach((field, fieldErrorData) {
        if (fieldErrorData is List) {
          fieldErrors[field] = fieldErrorData.map((e) => e.toString()).toList();
        } else if (fieldErrorData is String) {
          fieldErrors[field] = [fieldErrorData];
        }
      });
      return fieldErrors.isNotEmpty ? fieldErrors : null;
    }
    
    return null;
  }
}

/// Extension to easily handle exceptions in widgets
extension ErrorHandlingExtension on WidgetRef {
  void handleError(dynamic error, [StackTrace? stackTrace]) {
    final errorHandler = read(errorHandlerProvider);
    final appException = errorHandler.handleException(error, stackTrace);
    // The error is logged automatically by the error handler
    throw appException;
  }
  
  void showError(BuildContext context, dynamic error, [StackTrace? stackTrace]) {
    final errorHandler = read(errorHandlerProvider);
    final appException = errorHandler.handleException(error, stackTrace);
    errorHandler.showErrorToUser(context, appException);
  }
}