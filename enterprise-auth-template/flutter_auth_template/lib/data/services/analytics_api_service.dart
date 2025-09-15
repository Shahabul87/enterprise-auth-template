import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/errors/app_exception.dart';
import '../models/analytics_models.dart';

final analyticsApiServiceProvider = Provider<AnalyticsApiService>((ref) {
  return AnalyticsApiService(ref.read(apiClientProvider));
});

class AnalyticsApiService {
  final ApiClient _apiClient;

  AnalyticsApiService(this._apiClient);

  /// Get analytics dashboard data
  Future<AnalyticsDashboard> getDashboardAnalytics({
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
        '${ApiConstants.adminBasePath}/analytics/dashboard',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.data!['success'] == true) {
        return AnalyticsDashboard.fromJson(response.data!['data']);
      }

      throw ServerException(
        response.data!['error']?['message'] ?? 'Failed to get dashboard analytics',
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get user analytics
  Future<UserAnalytics> getUserAnalytics({
    DateTime? startDate,
    DateTime? endDate,
    String? groupBy,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String();
      }
      if (groupBy != null) {
        queryParams['group_by'] = groupBy;
      }

      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.adminBasePath}/analytics/users',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.data!['success'] == true) {
        return UserAnalytics.fromJson(response.data!['data']);
      }

      throw ServerException(
        response.data!['error']?['message'] ?? 'Failed to get user analytics',
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get authentication analytics
  Future<AuthenticationAnalytics> getAuthenticationAnalytics({
    DateTime? startDate,
    DateTime? endDate,
    String? groupBy,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String();
      }
      if (groupBy != null) {
        queryParams['group_by'] = groupBy;
      }

      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.adminBasePath}/analytics/authentication',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.data!['success'] == true) {
        return AuthenticationAnalytics.fromJson(response.data!['data']);
      }

      throw ServerException(
        response.data!['error']?['message'] ?? 'Failed to get authentication analytics',
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get security analytics
  Future<SecurityAnalytics> getSecurityAnalytics({
    DateTime? startDate,
    DateTime? endDate,
    String? groupBy,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String();
      }
      if (groupBy != null) {
        queryParams['group_by'] = groupBy;
      }

      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.adminBasePath}/analytics/security',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.data!['success'] == true) {
        return SecurityAnalytics.fromJson(response.data!['data']);
      }

      throw ServerException(
        response.data!['error']?['message'] ?? 'Failed to get security analytics',
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get API usage analytics
  Future<ApiUsageAnalytics> getApiUsageAnalytics({
    DateTime? startDate,
    DateTime? endDate,
    String? groupBy,
    String? apiKeyId,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String();
      }
      if (groupBy != null) {
        queryParams['group_by'] = groupBy;
      }
      if (apiKeyId != null) {
        queryParams['api_key_id'] = apiKeyId;
      }

      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.adminBasePath}/analytics/api-usage',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.data!['success'] == true) {
        return ApiUsageAnalytics.fromJson(response.data!['data']);
      }

      throw ServerException(
        response.data!['error']?['message'] ?? 'Failed to get API usage analytics',
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get system performance analytics
  Future<SystemPerformance> getSystemPerformance({
    DateTime? startDate,
    DateTime? endDate,
    String? interval,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String();
      }
      if (interval != null) {
        queryParams['interval'] = interval;
      }

      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.adminBasePath}/analytics/system-performance',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.data!['success'] == true) {
        return SystemPerformance.fromJson(response.data!['data']);
      }

      throw ServerException(
        response.data!['error']?['message'] ?? 'Failed to get system performance',
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Execute custom analytics query
  Future<Map<String, dynamic>> executeCustomQuery(
    CustomAnalyticsQuery query,
  ) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '${ApiConstants.adminBasePath}/analytics/custom',
        data: query.toJson(),
      );

      if (response.data!['success'] == true) {
        return response.data!['data'];
      }

      throw ServerException(
        response.data!['error']?['message'] ?? 'Failed to execute custom query',
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get available analytics metrics
  Future<List<String>> getAvailableMetrics() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.adminBasePath}/analytics/metrics',
      );

      if (response.data!['success'] == true) {
        return (response.data!['data'] as List).cast<String>();
      }

      throw ServerException(
        response.data!['error']?['message'] ?? 'Failed to get available metrics',
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Export analytics data
  Future<String> exportAnalytics({
    required String reportType,
    DateTime? startDate,
    DateTime? endDate,
    String? format = 'csv',
    List<String>? filters,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'report_type': reportType,
        'format': format,
      };

      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String();
      }
      if (filters != null && filters.isNotEmpty) {
        queryParams['filters'] = filters;
      }

      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.adminBasePath}/analytics/export',
        queryParameters: queryParams,
      );

      if (response.data!['success'] == true) {
        return response.data!['data']['download_url'];
      }

      throw ServerException(
        response.data!['error']?['message'] ?? 'Failed to export analytics',
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get real-time analytics
  Stream<Map<String, dynamic>> getRealTimeAnalytics() async* {
    // This would typically use WebSocket or Server-Sent Events
    // For now, we'll implement a polling mechanism
    while (true) {
      try {
        final response = await _apiClient.get<Map<String, dynamic>>(
          '${ApiConstants.adminBasePath}/analytics/realtime',
        );

        if (response.data!['success'] == true) {
          yield response.data!['data'];
        }
      } catch (e) {
        // Handle error silently in real-time stream
      }

      // Poll every 5 seconds
      await Future.delayed(const Duration(seconds: 5));
    }
  }

  /// Get analytics alerts
  Future<List<Map<String, dynamic>>> getAnalyticsAlerts() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.adminBasePath}/analytics/alerts',
      );

      if (response.data!['success'] == true) {
        return (response.data!['data'] as List).cast<Map<String, dynamic>>();
      }

      throw ServerException(
        response.data!['error']?['message'] ?? 'Failed to get analytics alerts',
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Create analytics alert
  Future<Map<String, dynamic>> createAnalyticsAlert({
    required String metric,
    required String operator,
    required double threshold,
    required String alertName,
    String? description,
  }) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '${ApiConstants.adminBasePath}/analytics/alerts',
        data: {
          'metric': metric,
          'operator': operator,
          'threshold': threshold,
          'alert_name': alertName,
          if (description != null) 'description': description,
        },
      );

      if (response.data!['success'] == true) {
        return response.data!['data'];
      }

      throw ServerException(
        response.data!['error']?['message'] ?? 'Failed to create analytics alert',
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