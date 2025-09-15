import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/errors/app_exception.dart';
import '../models/api_key_models.dart';

final apiKeyServiceProvider = Provider<ApiKeyService>((ref) {
  return ApiKeyService(ref.read(apiClientProvider));
});

class ApiKeyService {
  final ApiClient _apiClient;

  ApiKeyService(this._apiClient);

  /// Get all API keys for current user
  Future<ApiKeyListResponse> getApiKeys({
    int page = 1,
    int limit = 20,
    bool? isActive,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (isActive != null) queryParams['is_active'] = isActive;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.apiKeysPath,
        queryParameters: queryParams,
      );

      if (response.data!['success'] == true) {
        return ApiKeyListResponse.fromJson(response.data!['data']);
      }

      throw ServerException(
        response.data!['error']?['message'] ?? 'Failed to get API keys',
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get API key by ID
  Future<ApiKey> getApiKey(String apiKeyId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.apiKeysPath}/$apiKeyId',
      );

      if (response.data!['success'] == true) {
        return ApiKey.fromJson(response.data!['data']);
      }

      throw ServerException(
        response.data!['error']?['message'] ?? 'Failed to get API key',
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Create new API key
  Future<ApiKeyCreateResponse> createApiKey(ApiKeyCreateRequest request) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.apiKeysPath,
        data: request.toJson(),
      );

      if (response.data!['success'] == true) {
        return ApiKeyCreateResponse.fromJson(response.data!['data']);
      }

      throw ServerException(
        response.data!['error']?['message'] ?? 'Failed to create API key',
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Update API key
  Future<ApiKey> updateApiKey(
    String apiKeyId,
    ApiKeyUpdateRequest request,
  ) async {
    try {
      final response = await _apiClient.put<Map<String, dynamic>>(
        '${ApiConstants.apiKeysPath}/$apiKeyId',
        data: request.toJson(),
      );

      if (response.data!['success'] == true) {
        return ApiKey.fromJson(response.data!['data']);
      }

      throw ServerException(
        response.data!['error']?['message'] ?? 'Failed to update API key',
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Delete API key
  Future<void> deleteApiKey(String apiKeyId) async {
    try {
      final response = await _apiClient.delete<Map<String, dynamic>>(
        '${ApiConstants.apiKeysPath}/$apiKeyId',
      );

      if (response.data!['success'] != true) {
        throw ServerException(
          response.data!['error']?['message'] ?? 'Failed to delete API key',
          null,
          response.statusCode ?? 500,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Activate API key
  Future<ApiKey> activateApiKey(String apiKeyId) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '${ApiConstants.apiKeysPath}/$apiKeyId/activate',
      );

      if (response.data!['success'] == true) {
        return ApiKey.fromJson(response.data!['data']);
      }

      throw ServerException(
        response.data!['error']?['message'] ?? 'Failed to activate API key',
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Deactivate API key
  Future<ApiKey> deactivateApiKey(String apiKeyId) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '${ApiConstants.apiKeysPath}/$apiKeyId/deactivate',
      );

      if (response.data!['success'] == true) {
        return ApiKey.fromJson(response.data!['data']);
      }

      throw ServerException(
        response.data!['error']?['message'] ?? 'Failed to deactivate API key',
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Rotate API key
  Future<ApiKeyCreateResponse> rotateApiKey(String apiKeyId) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '${ApiConstants.apiKeysPath}/$apiKeyId/rotate',
      );

      if (response.data!['success'] == true) {
        return ApiKeyCreateResponse.fromJson(response.data!['data']);
      }

      throw ServerException(
        response.data!['error']?['message'] ?? 'Failed to rotate API key',
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get API key usage statistics
  Future<ApiKeyUsageStats> getApiKeyUsageStats(
    String apiKeyId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String();
      }

      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.apiKeysPath}/$apiKeyId/usage',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.data!['success'] == true) {
        return ApiKeyUsageStats.fromJson(response.data!['data']);
      }

      throw ServerException(
        response.data!['error']?['message'] ?? 'Failed to get usage stats',
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get API key activity logs
  Future<List<ApiKeyActivity>> getApiKeyActivity(
    String apiKeyId, {
    int page = 1,
    int limit = 50,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String();
      }

      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.apiKeysPath}/$apiKeyId/activity',
        queryParameters: queryParams,
      );

      if (response.data!['success'] == true) {
        final activityList = response.data!['data'] as List;
        return activityList
            .map((activity) => ApiKeyActivity.fromJson(activity))
            .toList();
      }

      throw ServerException(
        response.data!['error']?['message'] ?? 'Failed to get activity logs',
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get available permissions for API keys
  Future<List<ApiKeyPermission>> getAvailablePermissions() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.apiKeysPath}/permissions',
      );

      if (response.data!['success'] == true) {
        final permissionList = response.data!['data'] as List;
        return permissionList
            .map((permission) => ApiKeyPermission.fromJson(permission))
            .toList();
      }

      throw ServerException(
        response.data!['error']?['message'] ?? 'Failed to get permissions',
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get available scopes for API keys
  Future<List<ApiKeyScope>> getAvailableScopes() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.apiKeysPath}/scopes',
      );

      if (response.data!['success'] == true) {
        final scopeList = response.data!['data'] as List;
        return scopeList
            .map((scope) => ApiKeyScope.fromJson(scope))
            .toList();
      }

      throw ServerException(
        response.data!['error']?['message'] ?? 'Failed to get scopes',
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Test API key
  Future<Map<String, dynamic>> testApiKey(String apiKey) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '${ApiConstants.apiKeysPath}/test',
        data: {'api_key': apiKey},
      );

      if (response.data!['success'] == true) {
        return response.data!['data'];
      }

      throw ServerException(
        response.data!['error']?['message'] ?? 'API key test failed',
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
      final message = data['error']?['message'] ?? 'Unknown error occurred';
      return ServerException(message, null, exception.response?.statusCode ?? 500);
    }

    return NetworkException(
      exception.message ?? 'Network error occurred',
      exception.requestOptions.path,
    );
  }
}