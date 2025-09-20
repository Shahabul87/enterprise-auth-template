import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_auth_template/core/constants/api_constants.dart';
import 'package:flutter_auth_template/core/network/api_client.dart';
import 'package:flutter_auth_template/core/errors/app_exception.dart';
import 'package:flutter_auth_template/data/models/webhook_models.dart';

final webhookApiServiceProvider = Provider<WebhookApiService>((ref) {
  return WebhookApiService(ref.read(apiClientProvider));
});

class WebhookApiService {
  final ApiClient _apiClient;

  WebhookApiService(this._apiClient);

  /// Get all webhooks
  Future<WebhookListResponse> getWebhooks({
    int page = 1,
    int limit = 20,
    bool? isActive,
    String? event,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (isActive != null) queryParams['is_active'] = isActive;
      if (event != null) queryParams['event'] = event;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.webhooksPath,
        queryParameters: queryParams,
      );

      if (response.data!['success'] == true) {
        return WebhookListResponse.fromJson(response.data!['data']);
      }

      throw ServerException(
        response.data!['error']?['message'] ?? 'Failed to get webhooks',
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get webhook by ID
  Future<Webhook> getWebhook(String webhookId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.webhooksPath}/$webhookId',
      );

      if (response.data!['success'] == true) {
        return Webhook.fromJson(response.data!['data']);
      }

      throw ServerException(
        response.data!['error']?['message'] ?? 'Failed to get webhook',
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Create new webhook
  Future<Webhook> createWebhook(WebhookCreateRequest request) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.webhooksPath,
        data: request.toJson(),
      );

      if (response.data!['success'] == true) {
        return Webhook.fromJson(response.data!['data']);
      }

      throw ServerException(
        response.data!['error']?['message'] ?? 'Failed to create webhook',
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Update webhook
  Future<Webhook> updateWebhook(
    String webhookId,
    WebhookUpdateRequest request,
  ) async {
    try {
      final response = await _apiClient.put<Map<String, dynamic>>(
        '${ApiConstants.webhooksPath}/$webhookId',
        data: request.toJson(),
      );

      if (response.data!['success'] == true) {
        return Webhook.fromJson(response.data!['data']);
      }

      throw ServerException(
        response.data!['error']?['message'] ?? 'Failed to update webhook',
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Delete webhook
  Future<void> deleteWebhook(String webhookId) async {
    try {
      final response = await _apiClient.delete<Map<String, dynamic>>(
        '${ApiConstants.webhooksPath}/$webhookId',
      );

      if (response.data!['success'] != true) {
        throw ServerException(
          response.data!['error']?['message'] ?? 'Failed to delete webhook',
          null,
          response.statusCode ?? 500,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Enable webhook
  Future<Webhook> enableWebhook(String webhookId) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '${ApiConstants.webhooksPath}/$webhookId/enable',
      );

      if (response.data!['success'] == true) {
        return Webhook.fromJson(response.data!['data']);
      }

      throw ServerException(
        response.data!['error']?['message'] ?? 'Failed to enable webhook',
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Disable webhook
  Future<Webhook> disableWebhook(String webhookId) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '${ApiConstants.webhooksPath}/$webhookId/disable',
      );

      if (response.data!['success'] == true) {
        return Webhook.fromJson(response.data!['data']);
      }

      throw ServerException(
        response.data!['error']?['message'] ?? 'Failed to disable webhook',
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Test webhook
  Future<WebhookTestResponse> testWebhook(
    String webhookId,
    WebhookTestRequest request,
  ) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '${ApiConstants.webhooksPath}/$webhookId/test',
        data: request.toJson(),
      );

      if (response.data!['success'] == true) {
        return WebhookTestResponse.fromJson(response.data!['data']);
      }

      throw ServerException(
        response.data!['error']?['message'] ?? 'Failed to test webhook',
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get webhook deliveries
  Future<List<WebhookDelivery>> getWebhookDeliveries(
    String webhookId, {
    int page = 1,
    int limit = 50,
    DateTime? startDate,
    DateTime? endDate,
    bool? success,
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
      if (success != null) queryParams['success'] = success;

      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.webhooksPath}/$webhookId/deliveries',
        queryParameters: queryParams,
      );

      if (response.data!['success'] == true) {
        final deliveryList = response.data!['data'] as List;
        return deliveryList
            .map((delivery) => WebhookDelivery.fromJson(delivery))
            .toList();
      }

      throw ServerException(
        response.data!['error']?['message'] ?? 'Failed to get deliveries',
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get webhook statistics
  Future<WebhookStats> getWebhookStats(
    String webhookId, {
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
        '${ApiConstants.webhooksPath}/$webhookId/stats',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.data!['success'] == true) {
        return WebhookStats.fromJson(response.data!['data']);
      }

      throw ServerException(
        response.data!['error']?['message'] ?? 'Failed to get webhook stats',
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Retry webhook delivery
  Future<WebhookDelivery> retryWebhookDelivery(
    String webhookId,
    String deliveryId,
  ) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '${ApiConstants.webhooksPath}/$webhookId/deliveries/$deliveryId/retry',
      );

      if (response.data!['success'] == true) {
        return WebhookDelivery.fromJson(response.data!['data']);
      }

      throw ServerException(
        response.data!['error']?['message'] ?? 'Failed to retry delivery',
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get available webhook events
  Future<List<WebhookEvent>> getAvailableEvents() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.webhooksPath}/events',
      );

      if (response.data!['success'] == true) {
        final eventList = response.data!['data'] as List;
        return eventList
            .map((event) => WebhookEvent.fromJson(event))
            .toList();
      }

      throw ServerException(
        response.data!['error']?['message'] ?? 'Failed to get available events',
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get webhook templates
  Future<List<WebhookTemplate>> getWebhookTemplates() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.webhooksPath}/templates',
      );

      if (response.data!['success'] == true) {
        final templateList = response.data!['data'] as List;
        return templateList
            .map((template) => WebhookTemplate.fromJson(template))
            .toList();
      }

      throw ServerException(
        response.data!['error']?['message'] ?? 'Failed to get webhook templates',
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Create webhook from template
  Future<Webhook> createWebhookFromTemplate(
    String templateId,
    Map<String, dynamic> config,
  ) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '${ApiConstants.webhooksPath}/templates/$templateId/create',
        data: config,
      );

      if (response.data!['success'] == true) {
        return Webhook.fromJson(response.data!['data']);
      }

      throw ServerException(
        response.data!['error']?['message'] ?? 'Failed to create webhook from template',
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Validate webhook URL
  Future<Map<String, dynamic>> validateWebhookUrl(String url) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '${ApiConstants.webhooksPath}/validate',
        data: {'url': url},
      );

      if (response.data!['success'] == true) {
        return response.data!['data'];
      }

      throw ServerException(
        response.data!['error']?['message'] ?? 'Failed to validate webhook URL',
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Generate webhook secret
  Future<String> generateWebhookSecret() async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '${ApiConstants.webhooksPath}/generate-secret',
      );

      if (response.data!['success'] == true) {
        return response.data!['data']['secret'];
      }

      throw ServerException(
        response.data!['error']?['message'] ?? 'Failed to generate webhook secret',
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