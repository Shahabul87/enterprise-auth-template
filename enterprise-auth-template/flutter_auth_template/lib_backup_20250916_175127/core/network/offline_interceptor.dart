import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../services/offline_service.dart';

class OfflineInterceptor extends Interceptor {
  final OfflineService _offlineService;
  
  static const Duration _cacheMaxAge = Duration(hours: 24);
  static const List<String> _cacheableMethods = ['GET'];
  static const List<String> _offlineQueueableMethods = ['POST', 'PUT', 'PATCH', 'DELETE'];

  OfflineInterceptor(this._offlineService);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Add offline indicator to headers
    options.headers['X-Offline-Mode'] = _offlineService.isOffline.toString();
    
    if (_offlineService.isOffline) {
      await _handleOfflineRequest(options, handler);
    } else {
      handler.next(options);
    }
  }

  @override
  Future<void> onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    // Cache successful GET responses when online
    if (_offlineService.isOnline && 
        _cacheableMethods.contains(response.requestOptions.method.toUpperCase()) &&
        response.statusCode == 200) {
      await _cacheResponse(response);
    }
    
    handler.next(response);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // If error is due to network issues, try to serve from cache or queue action
    if (_isNetworkError(err)) {
      final cachedResponse = await _tryServeFromCache(err.requestOptions);
      if (cachedResponse != null) {
        handler.resolve(cachedResponse);
        return;
      }
      
      // Queue action for later if it's a modifying operation
      if (_offlineQueueableMethods.contains(err.requestOptions.method.toUpperCase())) {
        await _queueAction(err.requestOptions);
        
        // Return a success response indicating the action was queued
        final queuedResponse = Response(
          requestOptions: err.requestOptions,
          statusCode: 202, // Accepted
          statusMessage: 'Action queued for offline sync',
          data: {
            'success': true,
            'message': 'Your action has been saved and will be synced when you\'re back online',
            'queued': true,
            'timestamp': DateTime.now().toIso8601String(),
          },
        );
        
        handler.resolve(queuedResponse);
        return;
      }
    }
    
    handler.next(err);
  }

  Future<void> _handleOfflineRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final method = options.method.toUpperCase();
    
    if (_cacheableMethods.contains(method)) {
      // Try to serve GET requests from cache
      final cachedResponse = await _tryServeFromCache(options);
      if (cachedResponse != null) {
        handler.resolve(cachedResponse);
        return;
      }
    }
    
    if (_offlineQueueableMethods.contains(method)) {
      // Queue modifying operations for later sync
      await _queueAction(options);
      
      final queuedResponse = Response(
        requestOptions: options,
        statusCode: 202,
        statusMessage: 'Action queued for offline sync',
        data: {
          'success': true,
          'message': 'Your action has been saved and will be synced when you\'re back online',
          'queued': true,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      
      handler.resolve(queuedResponse);
      return;
    }
    
    // For non-cacheable and non-queueable requests, return offline error
    handler.reject(
      DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
        message: 'No internet connection',
        error: 'Device is offline',
      ),
    );
  }

  Future<void> _cacheResponse(Response response) async {
    try {
      final cacheKey = _generateCacheKey(response.requestOptions);
      final cacheData = {
        'statusCode': response.statusCode,
        'statusMessage': response.statusMessage,
        'headers': response.headers.map,
        'data': response.data,
        'cachedAt': DateTime.now().toIso8601String(),
      };
      
      await _offlineService.cacheData(cacheKey, cacheData);
      
      if (kDebugMode) {
        print('Cached response for: ${response.requestOptions.uri}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to cache response: $e');
      }
    }
  }

  Future<Response?> _tryServeFromCache(RequestOptions options) async {
    try {
      final cacheKey = _generateCacheKey(options);
      final cachedData = await _offlineService.getCachedData(
        cacheKey,
        maxAge: _cacheMaxAge,
      );
      
      if (cachedData != null) {
        final response = Response(
          requestOptions: options,
          statusCode: cachedData['statusCode'] ?? 200,
          statusMessage: cachedData['statusMessage'] ?? 'OK (Cached)',
          headers: Headers.fromMap(
            Map<String, List<String>>.from(cachedData['headers'] ?? {}),
          ),
          data: cachedData['data'],
        );
        
        // Add cache indicators to headers
        response.headers.add('X-Served-From-Cache', 'true');
        response.headers.add('X-Cache-Date', cachedData['cachedAt'] ?? '');
        
        if (kDebugMode) {
          print('Served from cache: ${options.uri}');
        }
        
        return response;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to serve from cache: $e');
      }
    }
    
    return null;
  }

  Future<void> _queueAction(RequestOptions options) async {
    try {
      final actionType = _getActionType(options.method);
      final endpoint = options.uri.toString();
      
      final data = <String, dynamic>{
        'method': options.method,
        'path': options.path,
        'queryParameters': options.queryParameters,
        'data': options.data,
      };
      
      final headers = Map<String, String>.from(
        options.headers.map((key, value) => MapEntry(key, value.toString())),
      );
      
      await _offlineService.queueAction(
        actionType,
        endpoint,
        data,
        headers: headers,
      );
      
      if (kDebugMode) {
        print('Queued action: ${options.method} ${options.uri}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to queue action: $e');
      }
    }
  }

  String _generateCacheKey(RequestOptions options) {
    final uri = options.uri.toString();
    final method = options.method.toUpperCase();
    final queryParams = options.queryParameters.isNotEmpty 
        ? '?${Uri(queryParameters: options.queryParameters).query}'
        : '';
    
    return '${method}_$uri$queryParams';
  }

  OfflineActionType _getActionType(String method) {
    switch (method.toUpperCase()) {
      case 'POST':
        return OfflineActionType.create;
      case 'PUT':
      case 'PATCH':
        return OfflineActionType.update;
      case 'DELETE':
        return OfflineActionType.delete;
      default:
        return OfflineActionType.sync;
    }
  }

  bool _isNetworkError(DioException error) {
    return error.type == DioExceptionType.connectionTimeout ||
           error.type == DioExceptionType.receiveTimeout ||
           error.type == DioExceptionType.sendTimeout ||
           error.type == DioExceptionType.connectionError ||
           (error.type == DioExceptionType.unknown && 
            (error.error.toString().contains('SocketException') ||
             error.error.toString().contains('Network is unreachable')));
  }
}

class OfflineAwareApiClient {
  late final Dio _dio;
  final OfflineService _offlineService;

  OfflineAwareApiClient(this._offlineService) {
    _dio = Dio();
    _dio.interceptors.add(OfflineInterceptor(_offlineService));
    
    // Add other interceptors as needed
    _setupDefaultOptions();
  }

  void _setupDefaultOptions() {
    _dio.options.baseUrl = 'http://localhost:8000/api';
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.sendTimeout = const Duration(seconds: 30);
    
    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.headers['Accept'] = 'application/json';
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  void addInterceptor(Interceptor interceptor) {
    _dio.interceptors.add(interceptor);
  }

  void close() {
    _dio.close();
  }
}