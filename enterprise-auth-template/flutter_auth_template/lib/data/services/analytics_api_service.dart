import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/errors/app_exception.dart';
import '../models/analytics_models.dart';

final analyticsApiServiceProvider = Provider&lt;AnalyticsApiService&gt;((ref) {
  return AnalyticsApiService(ref.read(apiClientProvider));
});

class AnalyticsApiService {
  final ApiClient _apiClient;

  AnalyticsApiService(this._apiClient);

  /// Get analytics dashboard data
  Future&lt;AnalyticsDashboard&gt; getDashboardAnalytics({
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
        &apos;${ApiConstants.adminBasePath}/analytics/dashboard&apos;,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.data![&apos;success&apos;] == true) {
        return AnalyticsDashboard.fromJson(response.data![&apos;data&apos;]);
      }

      throw ServerException(
        response.data![&apos;error&apos;]?[&apos;message&apos;] ?? &apos;Failed to get dashboard analytics&apos;,
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get user analytics
  Future&lt;UserAnalytics&gt; getUserAnalytics({
    DateTime? startDate,
    DateTime? endDate,
    String? groupBy,
  }) async {
    try {
      final queryParams = &lt;String, dynamic&gt;{};

      if (startDate != null) {
        queryParams[&apos;start_date&apos;] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams[&apos;end_date&apos;] = endDate.toIso8601String();
      }
      if (groupBy != null) {
        queryParams[&apos;group_by&apos;] = groupBy;
      }

      final response = await _apiClient.get&lt;Map&lt;String, dynamic&gt;&gt;(
        &apos;${ApiConstants.adminBasePath}/analytics/users&apos;,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.data![&apos;success&apos;] == true) {
        return UserAnalytics.fromJson(response.data![&apos;data&apos;]);
      }

      throw ServerException(
        response.data![&apos;error&apos;]?[&apos;message&apos;] ?? &apos;Failed to get user analytics&apos;,
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get authentication analytics
  Future&lt;AuthenticationAnalytics&gt; getAuthenticationAnalytics({
    DateTime? startDate,
    DateTime? endDate,
    String? groupBy,
  }) async {
    try {
      final queryParams = &lt;String, dynamic&gt;{};

      if (startDate != null) {
        queryParams[&apos;start_date&apos;] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams[&apos;end_date&apos;] = endDate.toIso8601String();
      }
      if (groupBy != null) {
        queryParams[&apos;group_by&apos;] = groupBy;
      }

      final response = await _apiClient.get&lt;Map&lt;String, dynamic&gt;&gt;(
        &apos;${ApiConstants.adminBasePath}/analytics/authentication&apos;,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.data![&apos;success&apos;] == true) {
        return AuthenticationAnalytics.fromJson(response.data![&apos;data&apos;]);
      }

      throw ServerException(
        response.data![&apos;error&apos;]?[&apos;message&apos;] ?? &apos;Failed to get authentication analytics&apos;,
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get security analytics
  Future&lt;SecurityAnalytics&gt; getSecurityAnalytics({
    DateTime? startDate,
    DateTime? endDate,
    String? groupBy,
  }) async {
    try {
      final queryParams = &lt;String, dynamic&gt;{};

      if (startDate != null) {
        queryParams[&apos;start_date&apos;] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams[&apos;end_date&apos;] = endDate.toIso8601String();
      }
      if (groupBy != null) {
        queryParams[&apos;group_by&apos;] = groupBy;
      }

      final response = await _apiClient.get&lt;Map&lt;String, dynamic&gt;&gt;(
        &apos;${ApiConstants.adminBasePath}/analytics/security&apos;,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.data![&apos;success&apos;] == true) {
        return SecurityAnalytics.fromJson(response.data![&apos;data&apos;]);
      }

      throw ServerException(
        response.data![&apos;error&apos;]?[&apos;message&apos;] ?? &apos;Failed to get security analytics&apos;,
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get API usage analytics
  Future&lt;ApiUsageAnalytics&gt; getApiUsageAnalytics({
    DateTime? startDate,
    DateTime? endDate,
    String? groupBy,
    String? apiKeyId,
  }) async {
    try {
      final queryParams = &lt;String, dynamic&gt;{};

      if (startDate != null) {
        queryParams[&apos;start_date&apos;] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams[&apos;end_date&apos;] = endDate.toIso8601String();
      }
      if (groupBy != null) {
        queryParams[&apos;group_by&apos;] = groupBy;
      }
      if (apiKeyId != null) {
        queryParams[&apos;api_key_id&apos;] = apiKeyId;
      }

      final response = await _apiClient.get&lt;Map&lt;String, dynamic&gt;&gt;(
        &apos;${ApiConstants.adminBasePath}/analytics/api-usage&apos;,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.data![&apos;success&apos;] == true) {
        return ApiUsageAnalytics.fromJson(response.data![&apos;data&apos;]);
      }

      throw ServerException(
        response.data![&apos;error&apos;]?[&apos;message&apos;] ?? &apos;Failed to get API usage analytics&apos;,
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get system performance analytics
  Future&lt;SystemPerformance&gt; getSystemPerformance({
    DateTime? startDate,
    DateTime? endDate,
    String? interval,
  }) async {
    try {
      final queryParams = &lt;String, dynamic&gt;{};

      if (startDate != null) {
        queryParams[&apos;start_date&apos;] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams[&apos;end_date&apos;] = endDate.toIso8601String();
      }
      if (interval != null) {
        queryParams[&apos;interval&apos;] = interval;
      }

      final response = await _apiClient.get&lt;Map&lt;String, dynamic&gt;&gt;(
        &apos;${ApiConstants.adminBasePath}/analytics/system-performance&apos;,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.data![&apos;success&apos;] == true) {
        return SystemPerformance.fromJson(response.data![&apos;data&apos;]);
      }

      throw ServerException(
        response.data![&apos;error&apos;]?[&apos;message&apos;] ?? &apos;Failed to get system performance&apos;,
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Execute custom analytics query
  Future&lt;Map&lt;String, dynamic&gt;&gt; executeCustomQuery(
    CustomAnalyticsQuery query,
  ) async {
    try {
      final response = await _apiClient.post&lt;Map&lt;String, dynamic&gt;&gt;(
        &apos;${ApiConstants.adminBasePath}/analytics/custom&apos;,
        data: query.toJson(),
      );

      if (response.data![&apos;success&apos;] == true) {
        return response.data![&apos;data&apos;];
      }

      throw ServerException(
        response.data![&apos;error&apos;]?[&apos;message&apos;] ?? &apos;Failed to execute custom query&apos;,
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get available analytics metrics
  Future&lt;List&lt;String&gt;&gt; getAvailableMetrics() async {
    try {
      final response = await _apiClient.get&lt;Map&lt;String, dynamic&gt;&gt;(
        &apos;${ApiConstants.adminBasePath}/analytics/metrics&apos;,
      );

      if (response.data![&apos;success&apos;] == true) {
        return (response.data![&apos;data&apos;] as List).cast&lt;String&gt;();
      }

      throw ServerException(
        response.data![&apos;error&apos;]?[&apos;message&apos;] ?? &apos;Failed to get available metrics&apos;,
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Export analytics data
  Future&lt;String&gt; exportAnalytics({
    required String reportType,
    DateTime? startDate,
    DateTime? endDate,
    String? format = &apos;csv&apos;,
    List&lt;String&gt;? filters,
  }) async {
    try {
      final queryParams = &lt;String, dynamic&gt;{
        &apos;report_type&apos;: reportType,
        &apos;format&apos;: format,
      };

      if (startDate != null) {
        queryParams[&apos;start_date&apos;] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams[&apos;end_date&apos;] = endDate.toIso8601String();
      }
      if (filters != null &amp;&amp; filters.isNotEmpty) {
        queryParams[&apos;filters&apos;] = filters;
      }

      final response = await _apiClient.get&lt;Map&lt;String, dynamic&gt;&gt;(
        &apos;${ApiConstants.adminBasePath}/analytics/export&apos;,
        queryParameters: queryParams,
      );

      if (response.data![&apos;success&apos;] == true) {
        return response.data![&apos;data&apos;][&apos;download_url&apos;];
      }

      throw ServerException(
        response.data![&apos;error&apos;]?[&apos;message&apos;] ?? &apos;Failed to export analytics&apos;,
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get real-time analytics
  Stream&lt;Map&lt;String, dynamic&gt;&gt; getRealTimeAnalytics() async* {
    // This would typically use WebSocket or Server-Sent Events
    // For now, we&apos;ll implement a polling mechanism
    while (true) {
      try {
        final response = await _apiClient.get&lt;Map&lt;String, dynamic&gt;&gt;(
          &apos;${ApiConstants.adminBasePath}/analytics/realtime&apos;,
        );

        if (response.data![&apos;success&apos;] == true) {
          yield response.data![&apos;data&apos;];
        }
      } catch (e) {
        // Handle error silently in real-time stream
      }

      // Poll every 5 seconds
      await Future.delayed(const Duration(seconds: 5));
    }
  }

  /// Get analytics alerts
  Future&lt;List&lt;Map&lt;String, dynamic&gt;&gt;&gt; getAnalyticsAlerts() async {
    try {
      final response = await _apiClient.get&lt;Map&lt;String, dynamic&gt;&gt;(
        &apos;${ApiConstants.adminBasePath}/analytics/alerts&apos;,
      );

      if (response.data![&apos;success&apos;] == true) {
        return (response.data![&apos;data&apos;] as List).cast&lt;Map&lt;String, dynamic&gt;&gt;();
      }

      throw ServerException(
        response.data![&apos;error&apos;]?[&apos;message&apos;] ?? &apos;Failed to get analytics alerts&apos;,
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Create analytics alert
  Future&lt;Map&lt;String, dynamic&gt;&gt; createAnalyticsAlert({
    required String metric,
    required String operator,
    required double threshold,
    required String alertName,
    String? description,
  }) async {
    try {
      final response = await _apiClient.post&lt;Map&lt;String, dynamic&gt;&gt;(
        &apos;${ApiConstants.adminBasePath}/analytics/alerts&apos;,
        data: {
          &apos;metric&apos;: metric,
          &apos;operator&apos;: operator,
          &apos;threshold&apos;: threshold,
          &apos;alert_name&apos;: alertName,
          if (description != null) &apos;description&apos;: description,
        },
      );

      if (response.data![&apos;success&apos;] == true) {
        return response.data![&apos;data&apos;];
      }

      throw ServerException(
        response.data![&apos;error&apos;]?[&apos;message&apos;] ?? &apos;Failed to create analytics alert&apos;,
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