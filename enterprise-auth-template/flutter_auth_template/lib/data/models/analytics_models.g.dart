// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AnalyticsDashboardImpl _$$AnalyticsDashboardImplFromJson(
  Map<String, dynamic> json,
) => _$AnalyticsDashboardImpl(
  userAnalytics: UserAnalytics.fromJson(
    json['userAnalytics'] as Map<String, dynamic>,
  ),
  authenticationAnalytics: AuthenticationAnalytics.fromJson(
    json['authenticationAnalytics'] as Map<String, dynamic>,
  ),
  securityAnalytics: SecurityAnalytics.fromJson(
    json['securityAnalytics'] as Map<String, dynamic>,
  ),
  apiUsageAnalytics: ApiUsageAnalytics.fromJson(
    json['apiUsageAnalytics'] as Map<String, dynamic>,
  ),
  systemPerformance: SystemPerformance.fromJson(
    json['systemPerformance'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$$AnalyticsDashboardImplToJson(
  _$AnalyticsDashboardImpl instance,
) => <String, dynamic>{
  'userAnalytics': instance.userAnalytics.toJson(),
  'authenticationAnalytics': instance.authenticationAnalytics.toJson(),
  'securityAnalytics': instance.securityAnalytics.toJson(),
  'apiUsageAnalytics': instance.apiUsageAnalytics.toJson(),
  'systemPerformance': instance.systemPerformance.toJson(),
};

_$UserAnalyticsImpl _$$UserAnalyticsImplFromJson(Map<String, dynamic> json) =>
    _$UserAnalyticsImpl(
      totalUsers: (json['totalUsers'] as num).toInt(),
      activeUsers: (json['activeUsers'] as num).toInt(),
      newUsersToday: (json['newUsersToday'] as num).toInt(),
      newUsersThisWeek: (json['newUsersThisWeek'] as num).toInt(),
      newUsersThisMonth: (json['newUsersThisMonth'] as num).toInt(),
      userGrowthRate: (json['userGrowthRate'] as num).toDouble(),
      usersByRole: Map<String, int>.from(json['usersByRole'] as Map),
      usersByStatus: Map<String, int>.from(json['usersByStatus'] as Map),
      userGrowthChart: (json['userGrowthChart'] as List<dynamic>)
          .map((e) => UserGrowthData.fromJson(e as Map<String, dynamic>))
          .toList(),
      userActivityChart: (json['userActivityChart'] as List<dynamic>)
          .map((e) => UserActivityData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$UserAnalyticsImplToJson(
  _$UserAnalyticsImpl instance,
) => <String, dynamic>{
  'totalUsers': instance.totalUsers,
  'activeUsers': instance.activeUsers,
  'newUsersToday': instance.newUsersToday,
  'newUsersThisWeek': instance.newUsersThisWeek,
  'newUsersThisMonth': instance.newUsersThisMonth,
  'userGrowthRate': instance.userGrowthRate,
  'usersByRole': instance.usersByRole,
  'usersByStatus': instance.usersByStatus,
  'userGrowthChart': instance.userGrowthChart.map((e) => e.toJson()).toList(),
  'userActivityChart': instance.userActivityChart
      .map((e) => e.toJson())
      .toList(),
};

_$AuthenticationAnalyticsImpl _$$AuthenticationAnalyticsImplFromJson(
  Map<String, dynamic> json,
) => _$AuthenticationAnalyticsImpl(
  totalLogins: (json['totalLogins'] as num).toInt(),
  successfulLogins: (json['successfulLogins'] as num).toInt(),
  failedLogins: (json['failedLogins'] as num).toInt(),
  loginSuccessRate: (json['loginSuccessRate'] as num).toDouble(),
  loginsByMethod: Map<String, int>.from(json['loginsByMethod'] as Map),
  loginsByDevice: Map<String, int>.from(json['loginsByDevice'] as Map),
  loginTrends: (json['loginTrends'] as List<dynamic>)
      .map((e) => LoginTrendData.fromJson(e as Map<String, dynamic>))
      .toList(),
  authMethodUsage: (json['authMethodUsage'] as List<dynamic>)
      .map((e) => AuthMethodUsage.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$$AuthenticationAnalyticsImplToJson(
  _$AuthenticationAnalyticsImpl instance,
) => <String, dynamic>{
  'totalLogins': instance.totalLogins,
  'successfulLogins': instance.successfulLogins,
  'failedLogins': instance.failedLogins,
  'loginSuccessRate': instance.loginSuccessRate,
  'loginsByMethod': instance.loginsByMethod,
  'loginsByDevice': instance.loginsByDevice,
  'loginTrends': instance.loginTrends.map((e) => e.toJson()).toList(),
  'authMethodUsage': instance.authMethodUsage.map((e) => e.toJson()).toList(),
};

_$SecurityAnalyticsImpl _$$SecurityAnalyticsImplFromJson(
  Map<String, dynamic> json,
) => _$SecurityAnalyticsImpl(
  securityIncidents: (json['securityIncidents'] as num).toInt(),
  blockedAttempts: (json['blockedAttempts'] as num).toInt(),
  suspiciousActivities: (json['suspiciousActivities'] as num).toInt(),
  activeDevices: (json['activeDevices'] as num).toInt(),
  trustedDevices: (json['trustedDevices'] as num).toInt(),
  recentIncidents: (json['recentIncidents'] as List<dynamic>)
      .map((e) => SecurityIncident.fromJson(e as Map<String, dynamic>))
      .toList(),
  threatsByType: Map<String, int>.from(json['threatsByType'] as Map),
  securityTrends: (json['securityTrends'] as List<dynamic>)
      .map((e) => SecurityTrendData.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$$SecurityAnalyticsImplToJson(
  _$SecurityAnalyticsImpl instance,
) => <String, dynamic>{
  'securityIncidents': instance.securityIncidents,
  'blockedAttempts': instance.blockedAttempts,
  'suspiciousActivities': instance.suspiciousActivities,
  'activeDevices': instance.activeDevices,
  'trustedDevices': instance.trustedDevices,
  'recentIncidents': instance.recentIncidents.map((e) => e.toJson()).toList(),
  'threatsByType': instance.threatsByType,
  'securityTrends': instance.securityTrends.map((e) => e.toJson()).toList(),
};

_$ApiUsageAnalyticsImpl _$$ApiUsageAnalyticsImplFromJson(
  Map<String, dynamic> json,
) => _$ApiUsageAnalyticsImpl(
  totalRequests: (json['totalRequests'] as num).toInt(),
  successfulRequests: (json['successfulRequests'] as num).toInt(),
  failedRequests: (json['failedRequests'] as num).toInt(),
  averageResponseTime: (json['averageResponseTime'] as num).toDouble(),
  activeApiKeys: (json['activeApiKeys'] as num).toInt(),
  requestsByEndpoint: Map<String, int>.from(json['requestsByEndpoint'] as Map),
  requestsByStatusCode: Map<String, int>.from(
    json['requestsByStatusCode'] as Map,
  ),
  usageTrends: (json['usageTrends'] as List<dynamic>)
      .map((e) => ApiUsageTrend.fromJson(e as Map<String, dynamic>))
      .toList(),
  topEndpoints: (json['topEndpoints'] as List<dynamic>)
      .map((e) => EndpointPerformance.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$$ApiUsageAnalyticsImplToJson(
  _$ApiUsageAnalyticsImpl instance,
) => <String, dynamic>{
  'totalRequests': instance.totalRequests,
  'successfulRequests': instance.successfulRequests,
  'failedRequests': instance.failedRequests,
  'averageResponseTime': instance.averageResponseTime,
  'activeApiKeys': instance.activeApiKeys,
  'requestsByEndpoint': instance.requestsByEndpoint,
  'requestsByStatusCode': instance.requestsByStatusCode,
  'usageTrends': instance.usageTrends.map((e) => e.toJson()).toList(),
  'topEndpoints': instance.topEndpoints.map((e) => e.toJson()).toList(),
};

_$SystemPerformanceImpl _$$SystemPerformanceImplFromJson(
  Map<String, dynamic> json,
) => _$SystemPerformanceImpl(
  cpuUsage: (json['cpuUsage'] as num).toDouble(),
  memoryUsage: (json['memoryUsage'] as num).toDouble(),
  diskUsage: (json['diskUsage'] as num).toDouble(),
  activeConnections: (json['activeConnections'] as num).toInt(),
  averageResponseTime: (json['averageResponseTime'] as num).toDouble(),
  uptime: (json['uptime'] as num).toDouble(),
  performanceHistory: (json['performanceHistory'] as List<dynamic>)
      .map((e) => PerformanceMetric.fromJson(e as Map<String, dynamic>))
      .toList(),
  healthStatus: $enumDecode(_$SystemHealthStatusEnumMap, json['healthStatus']),
);

Map<String, dynamic> _$$SystemPerformanceImplToJson(
  _$SystemPerformanceImpl instance,
) => <String, dynamic>{
  'cpuUsage': instance.cpuUsage,
  'memoryUsage': instance.memoryUsage,
  'diskUsage': instance.diskUsage,
  'activeConnections': instance.activeConnections,
  'averageResponseTime': instance.averageResponseTime,
  'uptime': instance.uptime,
  'performanceHistory': instance.performanceHistory
      .map((e) => e.toJson())
      .toList(),
  'healthStatus': _$SystemHealthStatusEnumMap[instance.healthStatus]!,
};

const _$SystemHealthStatusEnumMap = {
  SystemHealthStatus.healthy: 'healthy',
  SystemHealthStatus.warning: 'warning',
  SystemHealthStatus.critical: 'critical',
  SystemHealthStatus.unknown: 'unknown',
};

_$UserGrowthDataImpl _$$UserGrowthDataImplFromJson(Map<String, dynamic> json) =>
    _$UserGrowthDataImpl(
      date: DateTime.parse(json['date'] as String),
      newUsers: (json['newUsers'] as num).toInt(),
      totalUsers: (json['totalUsers'] as num).toInt(),
    );

Map<String, dynamic> _$$UserGrowthDataImplToJson(
  _$UserGrowthDataImpl instance,
) => <String, dynamic>{
  'date': instance.date.toIso8601String(),
  'newUsers': instance.newUsers,
  'totalUsers': instance.totalUsers,
};

_$UserActivityDataImpl _$$UserActivityDataImplFromJson(
  Map<String, dynamic> json,
) => _$UserActivityDataImpl(
  timestamp: DateTime.parse(json['timestamp'] as String),
  activeUsers: (json['activeUsers'] as num).toInt(),
  loginCount: (json['loginCount'] as num).toInt(),
);

Map<String, dynamic> _$$UserActivityDataImplToJson(
  _$UserActivityDataImpl instance,
) => <String, dynamic>{
  'timestamp': instance.timestamp.toIso8601String(),
  'activeUsers': instance.activeUsers,
  'loginCount': instance.loginCount,
};

_$LoginTrendDataImpl _$$LoginTrendDataImplFromJson(Map<String, dynamic> json) =>
    _$LoginTrendDataImpl(
      date: DateTime.parse(json['date'] as String),
      successful: (json['successful'] as num).toInt(),
      failed: (json['failed'] as num).toInt(),
      total: (json['total'] as num).toInt(),
    );

Map<String, dynamic> _$$LoginTrendDataImplToJson(
  _$LoginTrendDataImpl instance,
) => <String, dynamic>{
  'date': instance.date.toIso8601String(),
  'successful': instance.successful,
  'failed': instance.failed,
  'total': instance.total,
};

_$AuthMethodUsageImpl _$$AuthMethodUsageImplFromJson(
  Map<String, dynamic> json,
) => _$AuthMethodUsageImpl(
  method: json['method'] as String,
  count: (json['count'] as num).toInt(),
  percentage: (json['percentage'] as num).toDouble(),
  displayName: json['displayName'] as String,
);

Map<String, dynamic> _$$AuthMethodUsageImplToJson(
  _$AuthMethodUsageImpl instance,
) => <String, dynamic>{
  'method': instance.method,
  'count': instance.count,
  'percentage': instance.percentage,
  'displayName': instance.displayName,
};

_$SecurityIncidentImpl _$$SecurityIncidentImplFromJson(
  Map<String, dynamic> json,
) => _$SecurityIncidentImpl(
  id: json['id'] as String,
  type: json['type'] as String,
  severity: json['severity'] as String,
  description: json['description'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  status: json['status'] as String,
  userId: json['userId'] as String?,
  ipAddress: json['ipAddress'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$$SecurityIncidentImplToJson(
  _$SecurityIncidentImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'severity': instance.severity,
  'description': instance.description,
  'timestamp': instance.timestamp.toIso8601String(),
  'status': instance.status,
  if (instance.userId case final value?) 'userId': value,
  if (instance.ipAddress case final value?) 'ipAddress': value,
  if (instance.metadata case final value?) 'metadata': value,
};

_$SecurityTrendDataImpl _$$SecurityTrendDataImplFromJson(
  Map<String, dynamic> json,
) => _$SecurityTrendDataImpl(
  date: DateTime.parse(json['date'] as String),
  incidents: (json['incidents'] as num).toInt(),
  blockedAttempts: (json['blockedAttempts'] as num).toInt(),
  suspiciousActivities: (json['suspiciousActivities'] as num).toInt(),
);

Map<String, dynamic> _$$SecurityTrendDataImplToJson(
  _$SecurityTrendDataImpl instance,
) => <String, dynamic>{
  'date': instance.date.toIso8601String(),
  'incidents': instance.incidents,
  'blockedAttempts': instance.blockedAttempts,
  'suspiciousActivities': instance.suspiciousActivities,
};

_$ApiUsageTrendImpl _$$ApiUsageTrendImplFromJson(Map<String, dynamic> json) =>
    _$ApiUsageTrendImpl(
      timestamp: DateTime.parse(json['timestamp'] as String),
      requests: (json['requests'] as num).toInt(),
      errors: (json['errors'] as num).toInt(),
      responseTime: (json['responseTime'] as num).toDouble(),
    );

Map<String, dynamic> _$$ApiUsageTrendImplToJson(_$ApiUsageTrendImpl instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp.toIso8601String(),
      'requests': instance.requests,
      'errors': instance.errors,
      'responseTime': instance.responseTime,
    };

_$EndpointPerformanceImpl _$$EndpointPerformanceImplFromJson(
  Map<String, dynamic> json,
) => _$EndpointPerformanceImpl(
  endpoint: json['endpoint'] as String,
  method: json['method'] as String,
  requestCount: (json['requestCount'] as num).toInt(),
  averageResponseTime: (json['averageResponseTime'] as num).toDouble(),
  errorCount: (json['errorCount'] as num).toInt(),
  errorRate: (json['errorRate'] as num).toDouble(),
);

Map<String, dynamic> _$$EndpointPerformanceImplToJson(
  _$EndpointPerformanceImpl instance,
) => <String, dynamic>{
  'endpoint': instance.endpoint,
  'method': instance.method,
  'requestCount': instance.requestCount,
  'averageResponseTime': instance.averageResponseTime,
  'errorCount': instance.errorCount,
  'errorRate': instance.errorRate,
};

_$PerformanceMetricImpl _$$PerformanceMetricImplFromJson(
  Map<String, dynamic> json,
) => _$PerformanceMetricImpl(
  timestamp: DateTime.parse(json['timestamp'] as String),
  cpuUsage: (json['cpuUsage'] as num).toDouble(),
  memoryUsage: (json['memoryUsage'] as num).toDouble(),
  responseTime: (json['responseTime'] as num).toDouble(),
  activeConnections: (json['activeConnections'] as num).toInt(),
);

Map<String, dynamic> _$$PerformanceMetricImplToJson(
  _$PerformanceMetricImpl instance,
) => <String, dynamic>{
  'timestamp': instance.timestamp.toIso8601String(),
  'cpuUsage': instance.cpuUsage,
  'memoryUsage': instance.memoryUsage,
  'responseTime': instance.responseTime,
  'activeConnections': instance.activeConnections,
};

_$AnalyticsTimeRangeImpl _$$AnalyticsTimeRangeImplFromJson(
  Map<String, dynamic> json,
) => _$AnalyticsTimeRangeImpl(
  startDate: DateTime.parse(json['startDate'] as String),
  endDate: DateTime.parse(json['endDate'] as String),
  displayName: json['displayName'] as String,
);

Map<String, dynamic> _$$AnalyticsTimeRangeImplToJson(
  _$AnalyticsTimeRangeImpl instance,
) => <String, dynamic>{
  'startDate': instance.startDate.toIso8601String(),
  'endDate': instance.endDate.toIso8601String(),
  'displayName': instance.displayName,
};

_$CustomAnalyticsQueryImpl _$$CustomAnalyticsQueryImplFromJson(
  Map<String, dynamic> json,
) => _$CustomAnalyticsQueryImpl(
  metric: json['metric'] as String,
  aggregation: json['aggregation'] as String,
  filters: (json['filters'] as List<dynamic>)
      .map((e) => AnalyticsFilter.fromJson(e as Map<String, dynamic>))
      .toList(),
  timeRange: json['timeRange'] as String,
  groupBy: json['groupBy'] as String?,
);

Map<String, dynamic> _$$CustomAnalyticsQueryImplToJson(
  _$CustomAnalyticsQueryImpl instance,
) => <String, dynamic>{
  'metric': instance.metric,
  'aggregation': instance.aggregation,
  'filters': instance.filters.map((e) => e.toJson()).toList(),
  'timeRange': instance.timeRange,
  if (instance.groupBy case final value?) 'groupBy': value,
};

_$AnalyticsFilterImpl _$$AnalyticsFilterImplFromJson(
  Map<String, dynamic> json,
) => _$AnalyticsFilterImpl(
  field: json['field'] as String,
  operator: json['operator'] as String,
  value: json['value'],
);

Map<String, dynamic> _$$AnalyticsFilterImplToJson(
  _$AnalyticsFilterImpl instance,
) => <String, dynamic>{
  'field': instance.field,
  'operator': instance.operator,
  if (instance.value case final value?) 'value': value,
};
