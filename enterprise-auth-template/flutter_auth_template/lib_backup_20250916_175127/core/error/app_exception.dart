import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_exception.freezed.dart';

@freezed
abstract class AppException with _$AppException implements Exception {
  const factory AppException.network({
    required String message,
    int? statusCode,
    String? endpoint,
    Map<String, dynamic>? details,
  }) = NetworkException;

  const factory AppException.authentication({
    required String message,
    String? reason,
    Map<String, dynamic>? details,
  }) = AuthenticationException;

  const factory AppException.authorization({
    required String message,
    String? requiredPermission,
    Map<String, dynamic>? details,
  }) = AuthorizationException;

  const factory AppException.validation({
    required String message,
    Map<String, List<String>>? fieldErrors,
    Map<String, dynamic>? details,
  }) = ValidationException;

  const factory AppException.notFound({
    required String message,
    String? resource,
    Map<String, dynamic>? details,
  }) = NotFoundException;

  const factory AppException.server({
    required String message,
    int? statusCode,
    String? errorCode,
    Map<String, dynamic>? details,
  }) = ServerException;

  const factory AppException.timeout({
    required String message,
    Duration? duration,
    Map<String, dynamic>? details,
  }) = TimeoutException;

  const factory AppException.connectivity({
    required String message,
    String? type,
    Map<String, dynamic>? details,
  }) = ConnectivityException;

  const factory AppException.storage({
    required String message,
    String? operation,
    Map<String, dynamic>? details,
  }) = StorageException;

  const factory AppException.permission({
    required String message,
    String? permission,
    Map<String, dynamic>? details,
  }) = PermissionException;

  const factory AppException.rateLimited({
    required String message,
    Duration? retryAfter,
    int? limit,
    Map<String, dynamic>? details,
  }) = RateLimitedException;

  const factory AppException.business({
    required String message,
    String? code,
    Map<String, dynamic>? details,
  }) = BusinessException;

  const factory AppException.unknown({
    required String message,
    Object? originalError,
    StackTrace? stackTrace,
    Map<String, dynamic>? details,
  }) = UnknownException;
}

extension AppExceptionX on AppException {
  String get userMessage {
    return when(
      network: (message, statusCode, endpoint, details) {
        if (statusCode != null) {
          switch (statusCode) {
            case 400:
              return 'Invalid request. Please check your input and try again.';
            case 401:
              return 'Session expired. Please log in again.';
            case 403:
              return 'Access denied. You don\'t have permission to perform this action.';
            case 404:
              return 'The requested resource was not found.';
            case 429:
              return 'Too many requests. Please wait a moment and try again.';
            case 500:
              return 'Server error. Please try again later.';
            case 503:
              return 'Service temporarily unavailable. Please try again later.';
            default:
              return message;
          }
        }
        return 'Network error. Please check your connection and try again.';
      },
      authentication: (message, reason, details) {
        return 'Authentication failed. Please check your credentials and try again.';
      },
      authorization: (message, requiredPermission, details) {
        return 'Access denied. You don\'t have permission to perform this action.';
      },
      validation: (message, fieldErrors, details) {
        if (fieldErrors?.isNotEmpty ?? false) {
          final firstError = fieldErrors!.values.first.first;
          return 'Validation error: $firstError';
        }
        return 'Please check your input and try again.';
      },
      notFound: (message, resource, details) {
        return 'The requested ${resource ?? 'resource'} was not found.';
      },
      server: (message, statusCode, errorCode, details) {
        return 'Server error. Please try again later.';
      },
      timeout: (message, duration, details) {
        return 'Request timed out. Please check your connection and try again.';
      },
      connectivity: (message, type, details) {
        return 'No internet connection. Please check your network settings.';
      },
      storage: (message, operation, details) {
        return 'Storage error. Please try again.';
      },
      permission: (message, permission, details) {
        return 'Permission denied. Please grant the required permissions.';
      },
      rateLimited: (message, retryAfter, limit, details) {
        if (retryAfter != null) {
          return 'Too many requests. Please wait ${retryAfter.inSeconds} seconds and try again.';
        }
        return 'Too many requests. Please wait a moment and try again.';
      },
      business: (message, code, details) {
        return message;
      },
      unknown: (message, originalError, stackTrace, details) {
        return 'An unexpected error occurred. Please try again.';
      },
    );
  }

  String get technicalMessage {
    return when(
      network: (message, statusCode, endpoint, details) {
        return 'Network error: $message${statusCode != null ? ' (HTTP $statusCode)' : ''}${endpoint != null ? ' at $endpoint' : ''}';
      },
      authentication: (message, reason, details) {
        return 'Authentication error: $message${reason != null ? ' - $reason' : ''}';
      },
      authorization: (message, requiredPermission, details) {
        return 'Authorization error: $message${requiredPermission != null ? ' (required: $requiredPermission)' : ''}';
      },
      validation: (message, fieldErrors, details) {
        return 'Validation error: $message';
      },
      notFound: (message, resource, details) {
        return 'Not found: $message${resource != null ? ' ($resource)' : ''}';
      },
      server: (message, statusCode, errorCode, details) {
        return 'Server error: $message${statusCode != null ? ' (HTTP $statusCode)' : ''}${errorCode != null ? ' [$errorCode]' : ''}';
      },
      timeout: (message, duration, details) {
        return 'Timeout error: $message${duration != null ? ' (${duration.inSeconds}s)' : ''}';
      },
      connectivity: (message, type, details) {
        return 'Connectivity error: $message${type != null ? ' ($type)' : ''}';
      },
      storage: (message, operation, details) {
        return 'Storage error: $message${operation != null ? ' during $operation' : ''}';
      },
      permission: (message, permission, details) {
        return 'Permission error: $message${permission != null ? ' ($permission)' : ''}';
      },
      rateLimited: (message, retryAfter, limit, details) {
        return 'Rate limited: $message${limit != null ? ' (limit: $limit)' : ''}${retryAfter != null ? ' (retry after: ${retryAfter.inSeconds}s)' : ''}';
      },
      business: (message, code, details) {
        return 'Business logic error: $message${code != null ? ' [$code]' : ''}';
      },
      unknown: (message, originalError, stackTrace, details) {
        return 'Unknown error: $message${originalError != null ? ' - Original: $originalError' : ''}';
      },
    );
  }

  bool get isRetryable {
    return when(
      network: (message, statusCode, endpoint, details) {
        if (statusCode != null) {
          return statusCode >= 500 || statusCode == 408 || statusCode == 429;
        }
        return true;
      },
      authentication: (message, reason, details) => false,
      authorization: (message, requiredPermission, details) => false,
      validation: (message, fieldErrors, details) => false,
      notFound: (message, resource, details) => false,
      server: (message, statusCode, errorCode, details) => true,
      timeout: (message, duration, details) => true,
      connectivity: (message, type, details) => true,
      storage: (message, operation, details) => true,
      permission: (message, permission, details) => false,
      rateLimited: (message, retryAfter, limit, details) => true,
      business: (message, code, details) => false,
      unknown: (message, originalError, stackTrace, details) => true,
    );
  }

  Duration? get retryDelay {
    return when(
      network: (message, statusCode, endpoint, details) {
        if (statusCode == 429) {
          return const Duration(seconds: 60);
        } else if (statusCode != null && statusCode >= 500) {
          return const Duration(seconds: 30);
        }
        return const Duration(seconds: 5);
      },
      server: (message, statusCode, errorCode, details) => const Duration(seconds: 30),
      timeout: (message, duration, details) => const Duration(seconds: 10),
      connectivity: (message, type, details) => const Duration(seconds: 5),
      storage: (message, operation, details) => const Duration(seconds: 5),
      rateLimited: (message, retryAfter, limit, details) => retryAfter ?? const Duration(seconds: 60),
      unknown: (message, originalError, stackTrace, details) => const Duration(seconds: 10),
      authentication: (message, reason, details) => null,
      authorization: (message, requiredPermission, details) => null,
      validation: (message, fieldErrors, details) => null,
      notFound: (message, resource, details) => null,
      permission: (message, permission, details) => null,
      business: (message, code, details) => null,
    );
  }

  Map<String, dynamic> toJson() {
    return when(
      network: (message, statusCode, endpoint, details) => {
        'type': 'network',
        'message': message,
        if (statusCode != null) 'statusCode': statusCode,
        if (endpoint != null) 'endpoint': endpoint,
        if (details != null) 'details': details,
      },
      authentication: (message, reason, details) => {
        'type': 'authentication',
        'message': message,
        if (reason != null) 'reason': reason,
        if (details != null) 'details': details,
      },
      authorization: (message, requiredPermission, details) => {
        'type': 'authorization',
        'message': message,
        if (requiredPermission != null) 'requiredPermission': requiredPermission,
        if (details != null) 'details': details,
      },
      validation: (message, fieldErrors, details) => {
        'type': 'validation',
        'message': message,
        if (fieldErrors != null) 'fieldErrors': fieldErrors,
        if (details != null) 'details': details,
      },
      notFound: (message, resource, details) => {
        'type': 'notFound',
        'message': message,
        if (resource != null) 'resource': resource,
        if (details != null) 'details': details,
      },
      server: (message, statusCode, errorCode, details) => {
        'type': 'server',
        'message': message,
        if (statusCode != null) 'statusCode': statusCode,
        if (errorCode != null) 'errorCode': errorCode,
        if (details != null) 'details': details,
      },
      timeout: (message, duration, details) => {
        'type': 'timeout',
        'message': message,
        if (duration != null) 'duration': duration.inMilliseconds,
        if (details != null) 'details': details,
      },
      connectivity: (message, type, details) => {
        'type': 'connectivity',
        'message': message,
        if (type != null) 'connectivityType': type,
        if (details != null) 'details': details,
      },
      storage: (message, operation, details) => {
        'type': 'storage',
        'message': message,
        if (operation != null) 'operation': operation,
        if (details != null) 'details': details,
      },
      permission: (message, permission, details) => {
        'type': 'permission',
        'message': message,
        if (permission != null) 'permission': permission,
        if (details != null) 'details': details,
      },
      rateLimited: (message, retryAfter, limit, details) => {
        'type': 'rateLimited',
        'message': message,
        if (retryAfter != null) 'retryAfter': retryAfter.inSeconds,
        if (limit != null) 'limit': limit,
        if (details != null) 'details': details,
      },
      business: (message, code, details) => {
        'type': 'business',
        'message': message,
        if (code != null) 'code': code,
        if (details != null) 'details': details,
      },
      unknown: (message, originalError, stackTrace, details) => {
        'type': 'unknown',
        'message': message,
        if (originalError != null) 'originalError': originalError.toString(),
        if (stackTrace != null) 'stackTrace': stackTrace.toString(),
        if (details != null) 'details': details,
      },
    );
  }
}

// Helper class for creating common exceptions
class AppExceptions {
  AppExceptions._();

  static AppException networkError(String message, {int? statusCode, String? endpoint}) {
    return AppException.network(
      message: message,
      statusCode: statusCode,
      endpoint: endpoint,
    );
  }

  static AppException unauthorized(String message, {String? reason}) {
    return AppException.authentication(
      message: message,
      reason: reason,
    );
  }

  static AppException forbidden(String message, {String? requiredPermission}) {
    return AppException.authorization(
      message: message,
      requiredPermission: requiredPermission,
    );
  }

  static AppException validationError(String message, {Map<String, List<String>>? fieldErrors}) {
    return AppException.validation(
      message: message,
      fieldErrors: fieldErrors,
    );
  }

  static AppException notFound(String message, {String? resource}) {
    return AppException.notFound(
      message: message,
      resource: resource,
    );
  }

  static AppException serverError(String message, {int? statusCode, String? errorCode}) {
    return AppException.server(
      message: message,
      statusCode: statusCode,
      errorCode: errorCode,
    );
  }

  static AppException timeoutError(String message, {Duration? duration}) {
    return AppException.timeout(
      message: message,
      duration: duration,
    );
  }

  static AppException connectivityError(String message, {String? type}) {
    return AppException.connectivity(
      message: message,
      type: type,
    );
  }

  static AppException storageError(String message, {String? operation}) {
    return AppException.storage(
      message: message,
      operation: operation,
    );
  }

  static AppException permissionError(String message, {String? permission}) {
    return AppException.permission(
      message: message,
      permission: permission,
    );
  }

  static AppException rateLimitedError(String message, {Duration? retryAfter, int? limit}) {
    return AppException.rateLimited(
      message: message,
      retryAfter: retryAfter,
      limit: limit,
    );
  }

  static AppException businessError(String message, {String? code}) {
    return AppException.business(
      message: message,
      code: code,
    );
  }

  static AppException unknownError(String message, {Object? originalError, StackTrace? stackTrace}) {
    return AppException.unknown(
      message: message,
      originalError: originalError,
      stackTrace: stackTrace,
    );
  }

  // Helper method to convert HTTP status codes to appropriate exceptions
  static AppException fromHttpStatusCode(int statusCode, String message, {String? endpoint}) {
    switch (statusCode) {
      case 400:
        return AppException.validation(message: message);
      case 401:
        return AppException.authentication(message: message);
      case 403:
        return AppException.authorization(message: message);
      case 404:
        return AppException.notFound(message: message);
      case 408:
        return AppException.timeout(message: message);
      case 429:
        return AppException.rateLimited(message: message);
      case 500:
      case 502:
      case 503:
      case 504:
        return AppException.server(message: message, statusCode: statusCode);
      default:
        return AppException.network(
          message: message,
          statusCode: statusCode,
          endpoint: endpoint,
        );
    }
  }

  // Helper method to convert generic exceptions to AppException
  static AppException fromException(dynamic exception, [StackTrace? stackTrace]) {
    if (exception is AppException) {
      return exception;
    }

    if (exception is FormatException) {
      return AppException.validation(message: 'Invalid data format: ${exception.message}');
    }

    if (exception is TypeError) {
      return AppException.validation(message: 'Type error: ${exception.toString()}');
    }

    if (exception is ArgumentError) {
      return AppException.validation(message: 'Invalid argument: ${exception.message}');
    }

    if (exception is StateError) {
      return AppException.business(message: 'Invalid state: ${exception.message}');
    }

    if (exception is UnsupportedError) {
      return AppException.business(message: 'Unsupported operation: ${exception.message}');
    }

    return AppException.unknown(
      message: 'An unexpected error occurred',
      originalError: exception,
      stackTrace: stackTrace,
    );
  }
}