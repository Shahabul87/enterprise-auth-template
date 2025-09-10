import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/errors/app_exception.dart';
import '../models/webhook_models.dart';

final webhookApiServiceProvider = Provider&lt;WebhookApiService&gt;((ref) {
  return WebhookApiService(ref.read(apiClientProvider));
});

class WebhookApiService {
  final ApiClient _apiClient;

  WebhookApiService(this._apiClient);

  /// Get all webhooks
  Future&lt;WebhookListResponse&gt; getWebhooks({
    int page = 1,
    int limit = 20,
    bool? isActive,
    String? event,
    String? search,
  }) async {
    try {
      final queryParams = &lt;String, dynamic&gt;{
        &apos;page&apos;: page,
        &apos;limit&apos;: limit,
      };

      if (isActive != null) queryParams[&apos;is_active&apos;] = isActive;
      if (event != null) queryParams[&apos;event&apos;] = event;
      if (search != null &amp;&amp; search.isNotEmpty) queryParams[&apos;search&apos;] = search;

      final response = await _apiClient.get&lt;Map&lt;String, dynamic&gt;&gt;(
        ApiConstants.webhooksPath,
        queryParameters: queryParams,
      );

      if (response.data![&apos;success&apos;] == true) {
        return WebhookListResponse.fromJson(response.data![&apos;data&apos;]);
      }

      throw ServerException(
        response.data![&apos;error&apos;]?[&apos;message&apos;] ?? &apos;Failed to get webhooks&apos;,
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get webhook by ID
  Future&lt;Webhook&gt; getWebhook(String webhookId) async {
    try {
      final response = await _apiClient.get&lt;Map&lt;String, dynamic&gt;&gt;(
        &apos;${ApiConstants.webhooksPath}/$webhookId&apos;,
      );

      if (response.data![&apos;success&apos;] == true) {
        return Webhook.fromJson(response.data![&apos;data&apos;]);
      }

      throw ServerException(
        response.data![&apos;error&apos;]?[&apos;message&apos;] ?? &apos;Failed to get webhook&apos;,
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Create new webhook
  Future&lt;Webhook&gt; createWebhook(WebhookCreateRequest request) async {
    try {
      final response = await _apiClient.post&lt;Map&lt;String, dynamic&gt;&gt;(
        ApiConstants.webhooksPath,
        data: request.toJson(),
      );

      if (response.data![&apos;success&apos;] == true) {
        return Webhook.fromJson(response.data![&apos;data&apos;]);
      }

      throw ServerException(
        response.data![&apos;error&apos;]?[&apos;message&apos;] ?? &apos;Failed to create webhook&apos;,
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Update webhook
  Future&lt;Webhook&gt; updateWebhook(
    String webhookId,
    WebhookUpdateRequest request,
  ) async {
    try {
      final response = await _apiClient.put&lt;Map&lt;String, dynamic&gt;&gt;(
        &apos;${ApiConstants.webhooksPath}/$webhookId&apos;,
        data: request.toJson(),
      );

      if (response.data![&apos;success&apos;] == true) {
        return Webhook.fromJson(response.data![&apos;data&apos;]);
      }

      throw ServerException(
        response.data![&apos;error&apos;]?[&apos;message&apos;] ?? &apos;Failed to update webhook&apos;,
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Delete webhook
  Future&lt;void&gt; deleteWebhook(String webhookId) async {
    try {
      final response = await _apiClient.delete&lt;Map&lt;String, dynamic&gt;&gt;(
        &apos;${ApiConstants.webhooksPath}/$webhookId&apos;,
      );

      if (response.data![&apos;success&apos;] != true) {
        throw ServerException(
          response.data![&apos;error&apos;]?[&apos;message&apos;] ?? &apos;Failed to delete webhook&apos;,
          null,
          response.statusCode ?? 500,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Enable webhook
  Future&lt;Webhook&gt; enableWebhook(String webhookId) async {
    try {
      final response = await _apiClient.post&lt;Map&lt;String, dynamic&gt;&gt;(
        &apos;${ApiConstants.webhooksPath}/$webhookId/enable&apos;,
      );

      if (response.data![&apos;success&apos;] == true) {
        return Webhook.fromJson(response.data![&apos;data&apos;]);
      }

      throw ServerException(
        response.data![&apos;error&apos;]?[&apos;message&apos;] ?? &apos;Failed to enable webhook&apos;,
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Disable webhook
  Future&lt;Webhook&gt; disableWebhook(String webhookId) async {
    try {
      final response = await _apiClient.post&lt;Map&lt;String, dynamic&gt;&gt;(
        &apos;${ApiConstants.webhooksPath}/$webhookId/disable&apos;,
      );

      if (response.data![&apos;success&apos;] == true) {
        return Webhook.fromJson(response.data![&apos;data&apos;]);
      }

      throw ServerException(
        response.data![&apos;error&apos;]?[&apos;message&apos;] ?? &apos;Failed to disable webhook&apos;,
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Test webhook
  Future&lt;WebhookTestResponse&gt; testWebhook(
    String webhookId,
    WebhookTestRequest request,
  ) async {
    try {
      final response = await _apiClient.post&lt;Map&lt;String, dynamic&gt;&gt;(
        &apos;${ApiConstants.webhooksPath}/$webhookId/test&apos;,
        data: request.toJson(),
      );

      if (response.data![&apos;success&apos;] == true) {
        return WebhookTestResponse.fromJson(response.data![&apos;data&apos;]);
      }

      throw ServerException(
        response.data![&apos;error&apos;]?[&apos;message&apos;] ?? &apos;Failed to test webhook&apos;,
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get webhook deliveries
  Future&lt;List&lt;WebhookDelivery&gt;&gt; getWebhookDeliveries(
    String webhookId, {
    int page = 1,
    int limit = 50,
    DateTime? startDate,
    DateTime? endDate,
    bool? success,
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
      if (success != null) queryParams[&apos;success&apos;] = success;

      final response = await _apiClient.get&lt;Map&lt;String, dynamic&gt;&gt;(
        &apos;${ApiConstants.webhooksPath}/$webhookId/deliveries&apos;,
        queryParameters: queryParams,
      );

      if (response.data![&apos;success&apos;] == true) {
        final deliveryList = response.data![&apos;data&apos;] as List;
        return deliveryList
            .map((delivery) =&gt; WebhookDelivery.fromJson(delivery))
            .toList();
      }

      throw ServerException(
        response.data![&apos;error&apos;]?[&apos;message&apos;] ?? &apos;Failed to get deliveries&apos;,
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get webhook statistics
  Future&lt;WebhookStats&gt; getWebhookStats(
    String webhookId, {
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
        &apos;${ApiConstants.webhooksPath}/$webhookId/stats&apos;,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.data![&apos;success&apos;] == true) {
        return WebhookStats.fromJson(response.data![&apos;data&apos;]);
      }

      throw ServerException(
        response.data![&apos;error&apos;]?[&apos;message&apos;] ?? &apos;Failed to get webhook stats&apos;,
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Retry webhook delivery
  Future&lt;WebhookDelivery&gt; retryWebhookDelivery(
    String webhookId,
    String deliveryId,
  ) async {
    try {
      final response = await _apiClient.post&lt;Map&lt;String, dynamic&gt;&gt;(
        &apos;${ApiConstants.webhooksPath}/$webhookId/deliveries/$deliveryId/retry&apos;,
      );

      if (response.data![&apos;success&apos;] == true) {
        return WebhookDelivery.fromJson(response.data![&apos;data&apos;]);
      }

      throw ServerException(
        response.data![&apos;error&apos;]?[&apos;message&apos;] ?? &apos;Failed to retry delivery&apos;,
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get available webhook events
  Future&lt;List&lt;WebhookEvent&gt;&gt; getAvailableEvents() async {
    try {
      final response = await _apiClient.get&lt;Map&lt;String, dynamic&gt;&gt;(
        &apos;${ApiConstants.webhooksPath}/events&apos;,
      );

      if (response.data![&apos;success&apos;] == true) {
        final eventList = response.data![&apos;data&apos;] as List;
        return eventList
            .map((event) =&gt; WebhookEvent.fromJson(event))
            .toList();
      }

      throw ServerException(
        response.data![&apos;error&apos;]?[&apos;message&apos;] ?? &apos;Failed to get available events&apos;,
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get webhook templates
  Future&lt;List&lt;WebhookTemplate&gt;&gt; getWebhookTemplates() async {
    try {
      final response = await _apiClient.get&lt;Map&lt;String, dynamic&gt;&gt;(
        &apos;${ApiConstants.webhooksPath}/templates&apos;,
      );

      if (response.data![&apos;success&apos;] == true) {
        final templateList = response.data![&apos;data&apos;] as List;
        return templateList
            .map((template) =&gt; WebhookTemplate.fromJson(template))
            .toList();
      }

      throw ServerException(
        response.data![&apos;error&apos;]?[&apos;message&apos;] ?? &apos;Failed to get webhook templates&apos;,
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Create webhook from template
  Future&lt;Webhook&gt; createWebhookFromTemplate(
    String templateId,
    Map&lt;String, dynamic&gt; config,
  ) async {
    try {
      final response = await _apiClient.post&lt;Map&lt;String, dynamic&gt;&gt;(
        &apos;${ApiConstants.webhooksPath}/templates/$templateId/create&apos;,
        data: config,
      );

      if (response.data![&apos;success&apos;] == true) {
        return Webhook.fromJson(response.data![&apos;data&apos;]);
      }

      throw ServerException(
        response.data![&apos;error&apos;]?[&apos;message&apos;] ?? &apos;Failed to create webhook from template&apos;,
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Validate webhook URL
  Future&lt;Map&lt;String, dynamic&gt;&gt; validateWebhookUrl(String url) async {
    try {
      final response = await _apiClient.post&lt;Map&lt;String, dynamic&gt;&gt;(
        &apos;${ApiConstants.webhooksPath}/validate&apos;,
        data: {&apos;url&apos;: url},
      );

      if (response.data![&apos;success&apos;] == true) {
        return response.data![&apos;data&apos;];
      }

      throw ServerException(
        response.data![&apos;error&apos;]?[&apos;message&apos;] ?? &apos;Failed to validate webhook URL&apos;,
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Generate webhook secret
  Future&lt;String&gt; generateWebhookSecret() async {
    try {
      final response = await _apiClient.post&lt;Map&lt;String, dynamic&gt;&gt;(
        &apos;${ApiConstants.webhooksPath}/generate-secret&apos;,
      );

      if (response.data![&apos;success&apos;] == true) {
        return response.data![&apos;data&apos;][&apos;secret&apos;];
      }

      throw ServerException(
        response.data![&apos;error&apos;]?[&apos;message&apos;] ?? &apos;Failed to generate webhook secret&apos;,
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