import 'package:freezed_annotation/freezed_annotation.dart';

part &apos;analytics_models.freezed.dart&apos;;
part &apos;analytics_models.g.dart&apos;;

@freezed
class AnalyticsDashboard with _$AnalyticsDashboard {
  const factory AnalyticsDashboard({
    required UserAnalytics userAnalytics,
    required AuthenticationAnalytics authenticationAnalytics,
    required SecurityAnalytics securityAnalytics,
    required ApiUsageAnalytics apiUsageAnalytics,
    required SystemPerformance systemPerformance,
  }) = _AnalyticsDashboard;

  factory AnalyticsDashboard.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
      _$AnalyticsDashboardFromJson(json);
}

@freezed
class UserAnalytics with _$UserAnalytics {
  const factory UserAnalytics({
    required int totalUsers,
    required int activeUsers,
    required int newUsersToday,
    required int newUsersThisWeek,
    required int newUsersThisMonth,
    required double userGrowthRate,
    required Map&lt;String, int&gt; usersByRole,
    required Map&lt;String, int&gt; usersByStatus,
    required List&lt;UserGrowthData&gt; userGrowthChart,
    required List&lt;UserActivityData&gt; userActivityChart,
  }) = _UserAnalytics;

  factory UserAnalytics.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
      _$UserAnalyticsFromJson(json);
}

@freezed
class AuthenticationAnalytics with _$AuthenticationAnalytics {
  const factory AuthenticationAnalytics({
    required int totalLogins,
    required int successfulLogins,
    required int failedLogins,
    required double loginSuccessRate,
    required Map&lt;String, int&gt; loginsByMethod,
    required Map&lt;String, int&gt; loginsByDevice,
    required List&lt;LoginTrendData&gt; loginTrends,
    required List&lt;AuthMethodUsage&gt; authMethodUsage,
  }) = _AuthenticationAnalytics;

  factory AuthenticationAnalytics.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
      _$AuthenticationAnalyticsFromJson(json);
}

@freezed
class SecurityAnalytics with _$SecurityAnalytics {
  const factory SecurityAnalytics({
    required int securityIncidents,
    required int blockedAttempts,
    required int suspiciousActivities,
    required int activeDevices,
    required int trustedDevices,
    required List&lt;SecurityIncident&gt; recentIncidents,
    required Map&lt;String, int&gt; threatsByType,
    required List&lt;SecurityTrendData&gt; securityTrends,
  }) = _SecurityAnalytics;

  factory SecurityAnalytics.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
      _$SecurityAnalyticsFromJson(json);
}

@freezed
class ApiUsageAnalytics with _$ApiUsageAnalytics {
  const factory ApiUsageAnalytics({
    required int totalRequests,
    required int successfulRequests,
    required int failedRequests,
    required double averageResponseTime,
    required int activeApiKeys,
    required Map&lt;String, int&gt; requestsByEndpoint,
    required Map&lt;String, int&gt; requestsByStatusCode,
    required List&lt;ApiUsageTrend&gt; usageTrends,
    required List&lt;EndpointPerformance&gt; topEndpoints,
  }) = _ApiUsageAnalytics;

  factory ApiUsageAnalytics.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
      _$ApiUsageAnalyticsFromJson(json);
}

@freezed
class SystemPerformance with _$SystemPerformance {
  const factory SystemPerformance({
    required double cpuUsage,
    required double memoryUsage,
    required double diskUsage,
    required int activeConnections,
    required double averageResponseTime,
    required double uptime,
    required List&lt;PerformanceMetric&gt; performanceHistory,
    required SystemHealthStatus healthStatus,
  }) = _SystemPerformance;

  factory SystemPerformance.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
      _$SystemPerformanceFromJson(json);
}

@freezed
class UserGrowthData with _$UserGrowthData {
  const factory UserGrowthData({
    required DateTime date,
    required int newUsers,
    required int totalUsers,
  }) = _UserGrowthData;

  factory UserGrowthData.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
      _$UserGrowthDataFromJson(json);
}

@freezed
class UserActivityData with _$UserActivityData {
  const factory UserActivityData({
    required DateTime timestamp,
    required int activeUsers,
    required int loginCount,
  }) = _UserActivityData;

  factory UserActivityData.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
      _$UserActivityDataFromJson(json);
}

@freezed
class LoginTrendData with _$LoginTrendData {
  const factory LoginTrendData({
    required DateTime date,
    required int successful,
    required int failed,
    required int total,
  }) = _LoginTrendData;

  factory LoginTrendData.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
      _$LoginTrendDataFromJson(json);
}

@freezed
class AuthMethodUsage with _$AuthMethodUsage {
  const factory AuthMethodUsage({
    required String method,
    required int count,
    required double percentage,
    required String displayName,
  }) = _AuthMethodUsage;

  factory AuthMethodUsage.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
      _$AuthMethodUsageFromJson(json);
}

@freezed
class SecurityIncident with _$SecurityIncident {
  const factory SecurityIncident({
    required String id,
    required String type,
    required String severity,
    required String description,
    required DateTime timestamp,
    required String status,
    String? userId,
    String? ipAddress,
    Map&lt;String, dynamic&gt;? metadata,
  }) = _SecurityIncident;

  factory SecurityIncident.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
      _$SecurityIncidentFromJson(json);
}

@freezed
class SecurityTrendData with _$SecurityTrendData {
  const factory SecurityTrendData({
    required DateTime date,
    required int incidents,
    required int blockedAttempts,
    required int suspiciousActivities,
  }) = _SecurityTrendData;

  factory SecurityTrendData.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
      _$SecurityTrendDataFromJson(json);
}

@freezed
class ApiUsageTrend with _$ApiUsageTrend {
  const factory ApiUsageTrend({
    required DateTime timestamp,
    required int requests,
    required int errors,
    required double responseTime,
  }) = _ApiUsageTrend;

  factory ApiUsageTrend.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
      _$ApiUsageTrendFromJson(json);
}

@freezed
class EndpointPerformance with _$EndpointPerformance {
  const factory EndpointPerformance({
    required String endpoint,
    required String method,
    required int requestCount,
    required double averageResponseTime,
    required int errorCount,
    required double errorRate,
  }) = _EndpointPerformance;

  factory EndpointPerformance.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
      _$EndpointPerformanceFromJson(json);
}

@freezed
class PerformanceMetric with _$PerformanceMetric {
  const factory PerformanceMetric({
    required DateTime timestamp,
    required double cpuUsage,
    required double memoryUsage,
    required double responseTime,
    required int activeConnections,
  }) = _PerformanceMetric;

  factory PerformanceMetric.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
      _$PerformanceMetricFromJson(json);
}

@freezed
class AnalyticsTimeRange with _$AnalyticsTimeRange {
  const factory AnalyticsTimeRange({
    required DateTime startDate,
    required DateTime endDate,
    required String displayName,
  }) = _AnalyticsTimeRange;

  factory AnalyticsTimeRange.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
      _$AnalyticsTimeRangeFromJson(json);
}

@freezed
class CustomAnalyticsQuery with _$CustomAnalyticsQuery {
  const factory CustomAnalyticsQuery({
    required String metric,
    required String aggregation,
    required List&lt;AnalyticsFilter&gt; filters,
    required String timeRange,
    String? groupBy,
  }) = _CustomAnalyticsQuery;

  factory CustomAnalyticsQuery.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
      _$CustomAnalyticsQueryFromJson(json);
}

@freezed
class AnalyticsFilter with _$AnalyticsFilter {
  const factory AnalyticsFilter({
    required String field,
    required String operator,
    required dynamic value,
  }) = _AnalyticsFilter;

  factory AnalyticsFilter.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
      _$AnalyticsFilterFromJson(json);
}

enum SystemHealthStatus {
  healthy,
  warning,
  critical,
  unknown,
}

enum AnalyticsMetricType {
  userGrowth,
  authenticationTrends,
  securityIncidents,
  apiUsage,
  systemPerformance,
}

enum AnalyticsTimeRangeType {
  realTime,
  last24Hours,
  last7Days,
  last30Days,
  last90Days,
  custom,
}

extension SystemHealthStatusExtension on SystemHealthStatus {
  String get displayName {
    switch (this) {
      case SystemHealthStatus.healthy:
        return &apos;Healthy&apos;;
      case SystemHealthStatus.warning:
        return &apos;Warning&apos;;
      case SystemHealthStatus.critical:
        return &apos;Critical&apos;;
      case SystemHealthStatus.unknown:
        return &apos;Unknown&apos;;
    }
  }

  String get colorName {
    switch (this) {
      case SystemHealthStatus.healthy:
        return &apos;green&apos;;
      case SystemHealthStatus.warning:
        return &apos;orange&apos;;
      case SystemHealthStatus.critical:
        return &apos;red&apos;;
      case SystemHealthStatus.unknown:
        return &apos;gray&apos;;
    }
  }
}

extension AnalyticsTimeRangeTypeExtension on AnalyticsTimeRangeType {
  String get displayName {
    switch (this) {
      case AnalyticsTimeRangeType.realTime:
        return &apos;Real Time&apos;;
      case AnalyticsTimeRangeType.last24Hours:
        return &apos;Last 24 Hours&apos;;
      case AnalyticsTimeRangeType.last7Days:
        return &apos;Last 7 Days&apos;;
      case AnalyticsTimeRangeType.last30Days:
        return &apos;Last 30 Days&apos;;
      case AnalyticsTimeRangeType.last90Days:
        return &apos;Last 90 Days&apos;;
      case AnalyticsTimeRangeType.custom:
        return &apos;Custom Range&apos;;
    }
  }
}