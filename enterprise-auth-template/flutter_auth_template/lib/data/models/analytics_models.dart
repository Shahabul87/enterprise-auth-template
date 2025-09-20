import 'package:freezed_annotation/freezed_annotation.dart';

part 'analytics_models.freezed.dart';
part 'analytics_models.g.dart';

@freezed
class AnalyticsDashboard with _$AnalyticsDashboard {
  const factory AnalyticsDashboard({
    required UserAnalytics userAnalytics,
    required AuthenticationAnalytics authenticationAnalytics,
    required SecurityAnalytics securityAnalytics,
    required ApiUsageAnalytics apiUsageAnalytics,
    required SystemPerformance systemPerformance,
  }) = _AnalyticsDashboard;

  factory AnalyticsDashboard.fromJson(Map<String, dynamic> json) =>
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
    required Map<String, int> usersByRole,
    required Map<String, int> usersByStatus,
    required List<UserGrowthData> userGrowthChart,
    required List<UserActivityData> userActivityChart,
  }) = _UserAnalytics;

  factory UserAnalytics.fromJson(Map<String, dynamic> json) =>
      _$UserAnalyticsFromJson(json);
}

@freezed
class AuthenticationAnalytics with _$AuthenticationAnalytics {
  const factory AuthenticationAnalytics({
    required int totalLogins,
    required int successfulLogins,
    required int failedLogins,
    required double loginSuccessRate,
    required Map<String, int> loginsByMethod,
    required Map<String, int> loginsByDevice,
    required List<LoginTrendData> loginTrends,
    required List<AuthMethodUsage> authMethodUsage,
  }) = _AuthenticationAnalytics;

  factory AuthenticationAnalytics.fromJson(Map<String, dynamic> json) =>
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
    required List<SecurityIncident> recentIncidents,
    required Map<String, int> threatsByType,
    required List<SecurityTrendData> securityTrends,
  }) = _SecurityAnalytics;

  factory SecurityAnalytics.fromJson(Map<String, dynamic> json) =>
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
    required Map<String, int> requestsByEndpoint,
    required Map<String, int> requestsByStatusCode,
    required List<ApiUsageTrend> usageTrends,
    required List<EndpointPerformance> topEndpoints,
  }) = _ApiUsageAnalytics;

  factory ApiUsageAnalytics.fromJson(Map<String, dynamic> json) =>
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
    required List<PerformanceMetric> performanceHistory,
    required SystemHealthStatus healthStatus,
  }) = _SystemPerformance;

  factory SystemPerformance.fromJson(Map<String, dynamic> json) =>
      _$SystemPerformanceFromJson(json);
}

@freezed
class UserGrowthData with _$UserGrowthData {
  const factory UserGrowthData({
    required DateTime date,
    required int newUsers,
    required int totalUsers,
  }) = _UserGrowthData;

  factory UserGrowthData.fromJson(Map<String, dynamic> json) =>
      _$UserGrowthDataFromJson(json);
}

@freezed
class UserActivityData with _$UserActivityData {
  const factory UserActivityData({
    required DateTime timestamp,
    required int activeUsers,
    required int loginCount,
  }) = _UserActivityData;

  factory UserActivityData.fromJson(Map<String, dynamic> json) =>
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

  factory LoginTrendData.fromJson(Map<String, dynamic> json) =>
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

  factory AuthMethodUsage.fromJson(Map<String, dynamic> json) =>
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
    Map<String, dynamic>? metadata,
  }) = _SecurityIncident;

  factory SecurityIncident.fromJson(Map<String, dynamic> json) =>
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

  factory SecurityTrendData.fromJson(Map<String, dynamic> json) =>
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

  factory ApiUsageTrend.fromJson(Map<String, dynamic> json) =>
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

  factory EndpointPerformance.fromJson(Map<String, dynamic> json) =>
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

  factory PerformanceMetric.fromJson(Map<String, dynamic> json) =>
      _$PerformanceMetricFromJson(json);
}

@freezed
class AnalyticsTimeRange with _$AnalyticsTimeRange {
  const factory AnalyticsTimeRange({
    required DateTime startDate,
    required DateTime endDate,
    required String displayName,
  }) = _AnalyticsTimeRange;

  factory AnalyticsTimeRange.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsTimeRangeFromJson(json);
}

@freezed
class CustomAnalyticsQuery with _$CustomAnalyticsQuery {
  const factory CustomAnalyticsQuery({
    required String metric,
    required String aggregation,
    required List<AnalyticsFilter> filters,
    required String timeRange,
    String? groupBy,
  }) = _CustomAnalyticsQuery;

  factory CustomAnalyticsQuery.fromJson(Map<String, dynamic> json) =>
      _$CustomAnalyticsQueryFromJson(json);
}

@freezed
class AnalyticsFilter with _$AnalyticsFilter {
  const factory AnalyticsFilter({
    required String field,
    required String operator,
    required dynamic value,
  }) = _AnalyticsFilter;

  factory AnalyticsFilter.fromJson(Map<String, dynamic> json) =>
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
        return 'Healthy';
      case SystemHealthStatus.warning:
        return 'Warning';
      case SystemHealthStatus.critical:
        return 'Critical';
      case SystemHealthStatus.unknown:
        return 'Unknown';
    }
  }

  String get colorName {
    switch (this) {
      case SystemHealthStatus.healthy:
        return 'green';
      case SystemHealthStatus.warning:
        return 'orange';
      case SystemHealthStatus.critical:
        return 'red';
      case SystemHealthStatus.unknown:
        return 'gray';
    }
  }
}

extension AnalyticsTimeRangeTypeExtension on AnalyticsTimeRangeType {
  String get displayName {
    switch (this) {
      case AnalyticsTimeRangeType.realTime:
        return 'Real Time';
      case AnalyticsTimeRangeType.last24Hours:
        return 'Last 24 Hours';
      case AnalyticsTimeRangeType.last7Days:
        return 'Last 7 Days';
      case AnalyticsTimeRangeType.last30Days:
        return 'Last 30 Days';
      case AnalyticsTimeRangeType.last90Days:
        return 'Last 90 Days';
      case AnalyticsTimeRangeType.custom:
        return 'Custom Range';
    }
  }
}

// Security specific models for Advanced Security Settings
@freezed
class SecurityConfiguration with _$SecurityConfiguration {
  const factory SecurityConfiguration({
    required bool enableTwoFactor,
    required bool enableBiometric,
    required bool enableIpBlocking,
    required bool enableRateLimit,
    required int maxLoginAttempts,
    required int sessionTimeout,
  }) = _SecurityConfiguration;

  factory SecurityConfiguration.fromJson(Map<String, dynamic> json) =>
      _$SecurityConfigurationFromJson(json);
}

@freezed
class IpBlockRule with _$IpBlockRule {
  const factory IpBlockRule({
    required String id,
    required String ipAddress,
    required String cidr,
    required IpRuleType type,
    required String reason,
    required DateTime createdAt,
    DateTime? expiresAt,
    required bool isActive,
  }) = _IpBlockRule;

  factory IpBlockRule.fromJson(Map<String, dynamic> json) =>
      _$IpBlockRuleFromJson(json);
}

enum IpRuleType {
  block,
  allow,
  monitor,
}

@freezed
class RateLimitRule with _$RateLimitRule {
  const factory RateLimitRule({
    required String id,
    required String endpoint,
    required int maxRequests,
    required int timeWindowSeconds,
    required String action,
    required DateTime createdAt,
    required bool isActive,
  }) = _RateLimitRule;

  factory RateLimitRule.fromJson(Map<String, dynamic> json) =>
      _$RateLimitRuleFromJson(json);
}

@freezed
class SecurityEvent with _$SecurityEvent {
  const factory SecurityEvent({
    required String id,
    required String type,
    required SecurityEventSeverity severity,
    required String description,
    required String ipAddress,
    String? userId,
    required Map<String, dynamic> metadata,
    required DateTime timestamp,
    required bool resolved,
  }) = _SecurityEvent;

  factory SecurityEvent.fromJson(Map<String, dynamic> json) =>
      _$SecurityEventFromJson(json);
}

enum SecurityEventSeverity {
  low,
  medium,
  high,
  critical,
}