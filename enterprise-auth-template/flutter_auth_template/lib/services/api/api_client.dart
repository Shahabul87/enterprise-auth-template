import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/api_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../core/security/csrf_protection.dart';

// API Client Provider
final apiClientProvider = Provider<ApiClient>((ref) {
  final secureStorage = ref.watch(secureStorageServiceProvider);
  return ApiClient(secureStorage);
});

/// HTTP API client for making authenticated requests
class ApiClient {
  final SecureStorageService _secureStorage;
  late Dio _dio;
  late CSRFProtectionService _csrfService;
  late CSRFInterceptor _csrfInterceptor;

  ApiClient(this._secureStorage) {
    _csrfService = CSRFProtectionService(_secureStorage);
    _csrfInterceptor = CSRFInterceptor(_csrfService);
    _initializeDio();
  }

  void _initializeDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(_createAuthInterceptor());
    _dio.interceptors.add(_createCSRFInterceptor());
    _dio.interceptors.add(_createErrorInterceptor());

    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: true,
          responseHeader: false,
        ),
      );
    }
  }

  /// Create CSRF interceptor
  Interceptor _createCSRFInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add CSRF token for state-changing requests
        if (_csrfInterceptor.requiresCSRF(options.method)) {
          final intercepted = await _csrfInterceptor.interceptRequest(
            method: options.method,
            headers: options.headers.map(
              (key, value) => MapEntry(key, value.toString()),
            ),
            body: options.data,
          );

          // Update headers with CSRF token
          intercepted['headers']?.forEach((key, value) {
            options.headers[key] = value;
          });
        }
        handler.next(options);
      },
    );
  }

  /// Create authentication interceptor
  Interceptor _createAuthInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add authentication token if available
        final token = await _secureStorage.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        // Handle token refresh on 401
        if (error.response?.statusCode == 401) {
          try {
            final refreshed = await _refreshToken();
            if (refreshed) {
              // Retry the original request with new token
              final token = await _secureStorage.getAccessToken();
              error.requestOptions.headers['Authorization'] = 'Bearer $token';

              final response = await _dio.fetch(error.requestOptions);
              return handler.resolve(response);
            }
          } catch (e) {
            // Refresh failed, continue with original error
            debugPrint('Token refresh failed: $e');
          }
        }
        handler.next(error);
      },
    );
  }

  /// Create error interceptor
  Interceptor _createErrorInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) {
        final exception = _handleDioError(error);
        handler.reject(
          DioException(requestOptions: error.requestOptions, error: exception),
        );
      },
    );
  }

  /// Handle Dio errors and convert to app exceptions
  AppException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException(
          'Request timeout. Please try again.',
          null,
        );

      case DioExceptionType.connectionError:
        return const NetworkException(
          'Network connection failed. Please check your internet connection.',
          null,
        );

      case DioExceptionType.badResponse:
        return _handleHttpError(error.response);

      case DioExceptionType.cancel:
        return const UnknownException('Request was cancelled', null);

      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          return const NetworkException('No internet connection', null);
        }
        return UnknownException(
          error.message ?? 'Unknown error occurred',
          null,
        );

      default:
        return UnknownException(
          error.message ?? 'Unknown error occurred',
          null,
        );
    }
  }

  /// Handle HTTP response errors
  AppException _handleHttpError(Response? response) {
    if (response == null) {
      return const UnknownException('No response received', null);
    }

    final statusCode = response.statusCode ?? 500;
    final data = response.data;

    // Try to extract error from response
    String message = 'An error occurred';
    String? errorCode;

    if (data is Map<String, dynamic>) {
      if (data.containsKey('error')) {
        final error = data['error'];
        if (error is Map<String, dynamic>) {
          message = error['message'] ?? message;
          errorCode = error['code'];
        } else if (error is String) {
          message = error;
        }
      } else if (data.containsKey('message')) {
        message = data['message'] ?? message;
      }
    }

    switch (statusCode) {
      case 400:
        return ValidationException(message, null, errorCode, data);
      case 401:
        return UnauthorizedException(
          message,
          null,
          errorCode ?? 'UNAUTHORIZED',
        );
      case 403:
        return ForbiddenException(message, null, errorCode ?? 'FORBIDDEN');
      case 404:
        return NotFoundException(message, null);
      case 409:
        return ConflictException(message, null, errorCode ?? 'CONFLICT');
      case 422:
        return ValidationException(
          message,
          null,
          errorCode ?? 'VALIDATION_ERROR',
          data,
        );
      case 429:
        return TooManyRequestsException(message, null, '429');
      case 500:
      case 502:
      case 503:
      case 504:
        return ServerException(message, null, statusCode);
      default:
        return UnknownException(message, null);
    }
  }

  /// Refresh authentication token
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null) {
        return false;
      }

      final response = await _dio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
        options: Options(
          headers: {'Authorization': null}, // Don't use old token
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['success'] == true) {
          final tokenData = data['data'];
          if (tokenData != null) {
            await _secureStorage.storeAccessToken(tokenData['access_token']);
            if (tokenData['refresh_token'] != null) {
              await _secureStorage.storeRefreshToken(
                tokenData['refresh_token'],
              );
            }
            return true;
          }
        }
      }
      return false;
    } catch (e) {
      debugPrint('Token refresh error: $e');
      return false;
    }
  }

  /// Make GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Make POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Make PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Make PATCH request
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.patch(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Make DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Upload file
  Future<Response> uploadFile(
    String path,
    String filePath, {
    String? fileName,
    Map<String, dynamic>? additionalData,
    ProgressCallback? onProgress,
  }) async {
    final formData = FormData();

    // Add file
    formData.files.add(
      MapEntry(
        'file',
        await MultipartFile.fromFile(filePath, filename: fileName),
      ),
    );

    // Add additional data
    if (additionalData != null) {
      additionalData.forEach((key, value) {
        formData.fields.add(MapEntry(key, value.toString()));
      });
    }

    return await _dio.post(
      path,
      data: formData,
      options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      onSendProgress: onProgress,
    );
  }

  /// Download file
  Future<Response> downloadFile(
    String path,
    String savePath, {
    ProgressCallback? onProgress,
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.download(
      path,
      savePath,
      queryParameters: queryParameters,
      onReceiveProgress: onProgress,
    );
  }

  /// Cancel all pending requests
  void cancelRequests([String? reason]) {
    _dio.close(force: true);
    _initializeDio(); // Reinitialize after closing
  }

  /// Get current base URL
  String get baseUrl => _dio.options.baseUrl;

  /// Update base URL
  void updateBaseUrl(String newBaseUrl) {
    _dio.options.baseUrl = newBaseUrl;
  }

  /// Add custom header
  void addHeader(String key, String value) {
    _dio.options.headers[key] = value;
  }

  /// Remove custom header
  void removeHeader(String key) {
    _dio.options.headers.remove(key);
  }

  /// Clear all custom headers
  void clearHeaders() {
    _dio.options.headers.clear();
    _dio.options.headers.addAll({
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    });
  }
}
