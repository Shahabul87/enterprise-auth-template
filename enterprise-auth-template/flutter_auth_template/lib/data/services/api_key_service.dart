import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/errors/app_exception.dart';
import '../models/api_key_models.dart';

final apiKeyServiceProvider = Provider&lt;ApiKeyService&gt;((ref) {
  return ApiKeyService(ref.read(apiClientProvider));
});

class ApiKeyService {
  final ApiClient _apiClient;

  ApiKeyService(this._apiClient);

  /// Get all API keys for current user
  Future&lt;ApiKeyListResponse&gt; getApiKeys({
    int page = 1,
    int limit = 20,
    bool? isActive,
    String? search,
  }) async {
    try {
      final queryParams = &lt;String, dynamic&gt;{
        &apos;page&apos;: page,
        &apos;limit&apos;: limit,
      };

      if (isActive != null) queryParams[&apos;is_active&apos;] = isActive;
      if (search != null &amp;&amp; search.isNotEmpty) queryParams[&apos;search&apos;] = search;

      final response = await _apiClient.get&lt;Map&lt;String, dynamic&gt;&gt;(
        ApiConstants.apiKeysPath,
        queryParameters: queryParams,
      );

      if (response.data![&apos;success&apos;] == true) {
        return ApiKeyListResponse.fromJson(response.data![&apos;data&apos;]);
      }

      throw ServerException(
        response.data![&apos;error&apos;]?[&apos;message&apos;] ?? &apos;Failed to get API keys&apos;,
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get API key by ID
  Future&lt;ApiKey&gt; getApiKey(String apiKeyId) async {
    try {
      final response = await _apiClient.get&lt;Map&lt;String, dynamic&gt;&gt;(
        &apos;${ApiConstants.apiKeysPath}/$apiKeyId&apos;,
      );

      if (response.data![&apos;success&apos;] == true) {
        return ApiKey.fromJson(response.data![&apos;data&apos;]);
      }

      throw ServerException(
        response.data![&apos;error&apos;]?[&apos;message&apos;] ?? &apos;Failed to get API key&apos;,
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Create new API key
  Future&lt;ApiKeyCreateResponse&gt; createApiKey(ApiKeyCreateRequest request) async {
    try {
      final response = await _apiClient.post&lt;Map&lt;String, dynamic&gt;&gt;(
        ApiConstants.apiKeysPath,
        data: request.toJson(),
      );

      if (response.data![&apos;success&apos;] == true) {
        return ApiKeyCreateResponse.fromJson(response.data![&apos;data&apos;]);
      }

      throw ServerException(
        response.data![&apos;error&apos;]?[&apos;message&apos;] ?? &apos;Failed to create API key&apos;,
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Update API key
  Future&lt;ApiKey&gt; updateApiKey(
    String apiKeyId,
    ApiKeyUpdateRequest request,
  ) async {
    try {
      final response = await _apiClient.put&lt;Map&lt;String, dynamic&gt;&gt;(
        &apos;${ApiConstants.apiKeysPath}/$apiKeyId&apos;,
        data: request.toJson(),
      );

      if (response.data![&apos;success&apos;] == true) {
        return ApiKey.fromJson(response.data![&apos;data&apos;]);
      }

      throw ServerException(
        response.data![&apos;error&apos;]?[&apos;message&apos;] ?? &apos;Failed to update API key&apos;,
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Delete API key
  Future&lt;void&gt; deleteApiKey(String apiKeyId) async {
    try {
      final response = await _apiClient.delete&lt;Map&lt;String, dynamic&gt;&gt;(
        &apos;${ApiConstants.apiKeysPath}/$apiKeyId&apos;,
      );

      if (response.data![&apos;success&apos;] != true) {
        throw ServerException(
          response.data![&apos;error&apos;]?[&apos;message&apos;] ?? &apos;Failed to delete API key&apos;,
          null,
          response.statusCode ?? 500,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Activate API key
  Future&lt;ApiKey&gt; activateApiKey(String apiKeyId) async {
    try {
      final response = await _apiClient.post&lt;Map&lt;String, dynamic&gt;&gt;(
        &apos;${ApiConstants.apiKeysPath}/$apiKeyId/activate&apos;,
      );

      if (response.data![&apos;success&apos;] == true) {
        return ApiKey.fromJson(response.data![&apos;data&apos;]);
      }

      throw ServerException(
        response.data![&apos;error&apos;]?[&apos;message&apos;] ?? &apos;Failed to activate API key&apos;,
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Deactivate API key
  Future&lt;ApiKey&gt; deactivateApiKey(String apiKeyId) async {
    try {
      final response = await _apiClient.post&lt;Map&lt;String, dynamic&gt;&gt;(
        &apos;${ApiConstants.apiKeysPath}/$apiKeyId/deactivate&apos;,
      );

      if (response.data![&apos;success&apos;] == true) {
        return ApiKey.fromJson(response.data![&apos;data&apos;]);
      }

      throw ServerException(
        response.data![&apos;error&apos;]?[&apos;message&apos;] ?? &apos;Failed to deactivate API key&apos;,
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Rotate API key
  Future&lt;ApiKeyCreateResponse&gt; rotateApiKey(String apiKeyId) async {
    try {
      final response = await _apiClient.post&lt;Map&lt;String, dynamic&gt;&gt;(
        &apos;${ApiConstants.apiKeysPath}/$apiKeyId/rotate&apos;,
      );

      if (response.data![&apos;success&apos;] == true) {
        return ApiKeyCreateResponse.fromJson(response.data![&apos;data&apos;]);
      }

      throw ServerException(
        response.data![&apos;error&apos;]?[&apos;message&apos;] ?? &apos;Failed to rotate API key&apos;,
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get API key usage statistics
  Future&lt;ApiKeyUsageStats&gt; getApiKeyUsageStats(
    String apiKeyId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = &lt;String, dynamic&gt;{};

      if (startDate != null) {
        queryParams[&apos;start_date&apos;] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams[&apos;end_date&apos;] = endDate.toIso8601String();
      }

      final response = await _apiClient.get&lt;Map&lt;String, dynamic&gt;&gt;(
        &apos;${ApiConstants.apiKeysPath}/$apiKeyId/usage&apos;,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.data![&apos;success&apos;] == true) {
        return ApiKeyUsageStats.fromJson(response.data![&apos;data&apos;]);
      }

      throw ServerException(
        response.data![&apos;error&apos;]?[&apos;message&apos;] ?? &apos;Failed to get usage stats&apos;,
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get API key activity logs
  Future&lt;List&lt;ApiKeyActivity&gt;&gt; getApiKeyActivity(
    String apiKeyId, {
    int page = 1,
    int limit = 50,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = &lt;String, dynamic&gt;{
        &apos;page&apos;: page,
        &apos;limit&apos;: limit,
      };

      if (startDate != null) {
        queryParams[&apos;start_date&apos;] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams[&apos;end_date&apos;] = endDate.toIso8601String();
      }

      final response = await _apiClient.get&lt;Map&lt;String, dynamic&gt;&gt;(
        &apos;${ApiConstants.apiKeysPath}/$apiKeyId/activity&apos;,
        queryParameters: queryParams,
      );

      if (response.data![&apos;success&apos;] == true) {
        final activityList = response.data![&apos;data&apos;] as List;
        return activityList
            .map((activity) =&gt; ApiKeyActivity.fromJson(activity))
            .toList();
      }

      throw ServerException(
        response.data![&apos;error&apos;]?[&apos;message&apos;] ?? &apos;Failed to get activity logs&apos;,
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get available permissions for API keys
  Future&lt;List&lt;ApiKeyPermission&gt;&gt; getAvailablePermissions() async {
    try {
      final response = await _apiClient.get&lt;Map&lt;String, dynamic&gt;&gt;(
        &apos;${ApiConstants.apiKeysPath}/permissions&apos;,
      );

      if (response.data![&apos;success&apos;] == true) {
        final permissionList = response.data![&apos;data&apos;] as List;
        return permissionList
            .map((permission) =&gt; ApiKeyPermission.fromJson(permission))
            .toList();
      }

      throw ServerException(
        response.data![&apos;error&apos;]?[&apos;message&apos;] ?? &apos;Failed to get permissions&apos;,
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get available scopes for API keys
  Future&lt;List&lt;ApiKeyScope&gt;&gt; getAvailableScopes() async {
    try {
      final response = await _apiClient.get&lt;Map&lt;String, dynamic&gt;&gt;(
        &apos;${ApiConstants.apiKeysPath}/scopes&apos;,
      );

      if (response.data![&apos;success&apos;] == true) {
        final scopeList = response.data![&apos;data&apos;] as List;
        return scopeList
            .map((scope) =&gt; ApiKeyScope.fromJson(scope))
            .toList();
      }

      throw ServerException(
        response.data![&apos;error&apos;]?[&apos;message&apos;] ?? &apos;Failed to get scopes&apos;,
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Test API key
  Future&lt;Map&lt;String, dynamic&gt;&gt; testApiKey(String apiKey) async {
    try {
      final response = await _apiClient.post&lt;Map&lt;String, dynamic&gt;&gt;(
        &apos;${ApiConstants.apiKeysPath}/test&apos;,
        data: {&apos;api_key&apos;: apiKey},
      );

      if (response.data![&apos;success&apos;] == true) {
        return response.data![&apos;data&apos;];
      }

      throw ServerException(
        response.data![&apos;error&apos;]?[&apos;message&apos;] ?? &apos;API key test failed&apos;,
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  AppException _handleDioException(DioException exception) {
    if (exception.response?.data != null) {
      final data = exception.response!.data;
      final message = data[&apos;error&apos;]?[&apos;message&apos;] ?? &apos;Unknown error occurred&apos;;
      return ServerException(message, null, exception.response?.statusCode ?? 500);
    }

    return NetworkException(
      exception.message ?? &apos;Network error occurred&apos;,
      exception.requestOptions.path,
    );
  }
}