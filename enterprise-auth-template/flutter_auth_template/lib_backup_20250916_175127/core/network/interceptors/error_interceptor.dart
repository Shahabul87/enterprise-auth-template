import 'dart:io';
import 'package:dio/dio.dart';
import '../../constants/api_constants.dart';
import '../../errors/app_exception.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final exception = _handleError(err);
    handler.next(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: exception,
        message: exception.message,
      ),
    );
  }

  AppException _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException(
          'Request timeout. Please check your internet connection.',
          error.requestOptions.path,
        );

      case DioExceptionType.badResponse:
        return _handleResponseError(error);

      case DioExceptionType.connectionError:
        if (error.error is SocketException) {
          return NetworkException(
            'No internet connection. Please check your network settings.',
            error.requestOptions.path,
          );
        }
        return NetworkException(
          'Connection failed. Please try again.',
          error.requestOptions.path,
        );

      case DioExceptionType.cancel:
        return RequestCancelledException(
          'Request was cancelled.',
          error.requestOptions.path,
        );

      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          return NetworkException(
            'No internet connection. Please check your network settings.',
            error.requestOptions.path,
          );
        }
        return UnknownException(
          'An unexpected error occurred: ${error.message}',
          error.requestOptions.path,
        );

      default:
        return UnknownException(
          'An unknown error occurred.',
          error.requestOptions.path,
        );
    }
  }

  AppException _handleResponseError(DioException error) {
    final statusCode = error.response?.statusCode ?? 0;
    final path = error.requestOptions.path;
    final responseData = error.response?.data;

    // Try to extract error message from response
    String errorMessage = 'An error occurred';
    String? errorCode;

    if (responseData is Map<String, dynamic>) {
      if (responseData.containsKey('error')) {
        final errorData = responseData['error'];
        if (errorData is Map<String, dynamic>) {
          errorMessage = errorData['message'] ?? errorMessage;
          errorCode = errorData['code'];
        } else if (errorData is String) {
          errorMessage = errorData;
        }
      } else if (responseData.containsKey('message')) {
        errorMessage = responseData['message'] ?? errorMessage;
      }
    }

    switch (statusCode) {
      case 400:
        return BadRequestException(errorMessage, path, errorCode);

      case 401:
        return UnauthorizedException(
          errorCode == ApiErrors.emailNotVerified
              ? 'Please verify your email address to continue.'
              : errorCode == ApiErrors.twoFactorRequired
              ? 'Two-factor authentication is required.'
              : 'Authentication failed. Please login again.',
          path,
          errorCode,
        );

      case 403:
        return ForbiddenException(
          errorCode == ApiErrors.accountLocked
              ? 'Your account has been locked due to multiple failed login attempts.'
              : 'You don\'t have permission to access this resource.',
          path,
          errorCode,
        );

      case 404:
        return NotFoundException(
          errorCode == ApiErrors.userNotFound
              ? 'User account not found.'
              : 'The requested resource was not found.',
          path,
          errorCode,
        );

      case 409:
        return ConflictException(
          errorCode == ApiErrors.emailAlreadyExists
              ? 'An account with this email already exists.'
              : errorMessage,
          path,
          errorCode,
        );

      case 422:
        return ValidationException(
          'Please check your input and try again.',
          path,
          errorCode,
          responseData,
        );

      case 429:
        return TooManyRequestsException(
          'Too many requests. Please wait before trying again.',
          path,
          errorCode,
        );

      case 500:
      case 501:
      case 502:
      case 503:
      case 504:
        return ServerException(
          'Server error occurred. Please try again later.',
          path,
          statusCode,
        );

      default:
        return HttpException(errorMessage, path, statusCode, errorCode);
    }
  }
}
