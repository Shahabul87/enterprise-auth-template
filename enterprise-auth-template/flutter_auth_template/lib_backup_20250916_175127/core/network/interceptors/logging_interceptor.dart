import 'dart:convert';
import 'dart:developer' as developer;
import 'package:dio/dio.dart';

class LoggingInterceptor extends Interceptor {
  static const String _logTag = 'HTTP';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logRequest(options);
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logResponse(response);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logError(err);
    handler.next(err);
  }

  void _logRequest(RequestOptions options) {
    final uri = options.uri;
    final method = options.method.toUpperCase();

    developer.log('┌── $method $uri', name: _logTag);

    // Log headers (excluding sensitive ones)
    if (options.headers.isNotEmpty) {
      developer.log('├── Headers:', name: _logTag);
      options.headers.forEach((key, value) {
        if (!_isSensitiveHeader(key)) {
          developer.log('│   $key: $value', name: _logTag);
        } else {
          developer.log('│   $key: [HIDDEN]', name: _logTag);
        }
      });
    }

    // Log query parameters
    if (options.queryParameters.isNotEmpty) {
      developer.log('├── Query Parameters:', name: _logTag);
      options.queryParameters.forEach((key, value) {
        developer.log('│   $key: $value', name: _logTag);
      });
    }

    // Log request body (excluding sensitive data)
    if (options.data != null) {
      developer.log('├── Request Body:', name: _logTag);
      final body = _formatRequestBody(options.data);
      developer.log('│   $body', name: _logTag);
    }

    developer.log('└──', name: _logTag);
  }

  void _logResponse(Response response) {
    final uri = response.requestOptions.uri;
    final method = response.requestOptions.method.toUpperCase();
    final statusCode = response.statusCode;
    final statusMessage = response.statusMessage ?? '';

    developer.log(
      '┌── $method $uri ($statusCode $statusMessage)',
      name: _logTag,
    );

    // Log response headers (excluding sensitive ones)
    if (response.headers.map.isNotEmpty) {
      developer.log('├── Response Headers:', name: _logTag);
      response.headers.map.forEach((key, values) {
        if (!_isSensitiveHeader(key)) {
          developer.log('│   $key: ${values.join(', ')}', name: _logTag);
        } else {
          developer.log('│   $key: [HIDDEN]', name: _logTag);
        }
      });
    }

    // Log response body (truncated if too long)
    if (response.data != null) {
      developer.log('├── Response Body:', name: _logTag);
      final body = _formatResponseBody(response.data);
      developer.log('│   $body', name: _logTag);
    }

    developer.log('└──', name: _logTag);
  }

  void _logError(DioException err) {
    final uri = err.requestOptions.uri;
    final method = err.requestOptions.method.toUpperCase();
    final statusCode = err.response?.statusCode;

    developer.log(
      '┌── ERROR: $method $uri${statusCode != null ? ' ($statusCode)' : ''}',
      name: _logTag,
      level: 1000, // Error level
    );

    developer.log('├── Error Type: ${err.type}', name: _logTag, level: 1000);
    developer.log(
      '├── Error Message: ${err.message}',
      name: _logTag,
      level: 1000,
    );

    if (err.response?.data != null) {
      developer.log('├── Error Response:', name: _logTag, level: 1000);
      final body = _formatResponseBody(err.response!.data);
      developer.log('│   $body', name: _logTag, level: 1000);
    }

    developer.log('└──', name: _logTag, level: 1000);
  }

  String _formatRequestBody(dynamic data) {
    if (data is FormData) {
      return 'FormData with ${data.fields.length} fields and ${data.files.length} files';
    }

    if (data is Map<String, dynamic>) {
      // Hide sensitive fields
      final sanitized = Map<String, dynamic>.from(data);
      _sanitizeData(sanitized);
      return _prettyJson(sanitized);
    }

    return data.toString();
  }

  String _formatResponseBody(dynamic data) {
    if (data is String) {
      if (data.length > 1000) {
        return '${data.substring(0, 1000)}... [truncated]';
      }
      try {
        final decoded = jsonDecode(data);
        return _prettyJson(decoded);
      } catch (e) {
        return data;
      }
    }

    if (data is Map || data is List) {
      final jsonString = _prettyJson(data);
      if (jsonString.length > 1000) {
        return '${jsonString.substring(0, 1000)}... [truncated]';
      }
      return jsonString;
    }

    return data.toString();
  }

  String _prettyJson(dynamic json) {
    try {
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(json);
    } catch (e) {
      return json.toString();
    }
  }

  void _sanitizeData(Map<String, dynamic> data) {
    const sensitiveKeys = [
      'password',
      'confirmPassword',
      'token',
      'accessToken',
      'refreshToken',
      'secret',
      'key',
      'authorization',
    ];

    for (final key in data.keys.toList()) {
      if (sensitiveKeys.any(
        (sensitive) => key.toLowerCase().contains(sensitive.toLowerCase()),
      )) {
        data[key] = '[HIDDEN]';
      } else if (data[key] is Map<String, dynamic>) {
        _sanitizeData(data[key] as Map<String, dynamic>);
      } else if (data[key] is List) {
        final list = data[key] as List;
        for (var i = 0; i < list.length; i++) {
          if (list[i] is Map<String, dynamic>) {
            _sanitizeData(list[i] as Map<String, dynamic>);
          }
        }
      }
    }
  }

  bool _isSensitiveHeader(String key) {
    const sensitiveHeaders = [
      'authorization',
      'cookie',
      'set-cookie',
      'x-api-key',
      'x-auth-token',
    ];

    return sensitiveHeaders.any(
      (header) => key.toLowerCase().contains(header.toLowerCase()),
    );
  }
}
