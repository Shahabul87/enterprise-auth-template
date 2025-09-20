// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SystemStatsImpl _$$SystemStatsImplFromJson(Map<String, dynamic> json) =>
    _$SystemStatsImpl(
      users: Map<String, int>.from(json['users'] as Map),
      sessions: Map<String, int>.from(json['sessions'] as Map),
      organizations: Map<String, int>.from(json['organizations'] as Map),
      apiKeys: Map<String, int>.from(json['apiKeys'] as Map),
      auditLogs: Map<String, int>.from(json['auditLogs'] as Map),
    );

Map<String, dynamic> _$$SystemStatsImplToJson(_$SystemStatsImpl instance) =>
    <String, dynamic>{
      'users': instance.users,
      'sessions': instance.sessions,
      'organizations': instance.organizations,
      'apiKeys': instance.apiKeys,
      'auditLogs': instance.auditLogs,
    };

_$UserManagementRequestImpl _$$UserManagementRequestImplFromJson(
  Map<String, dynamic> json,
) => _$UserManagementRequestImpl(
  email: json['email'] as String?,
  name: json['name'] as String?,
  password: json['password'] as String?,
  isActive: json['isActive'] as bool?,
  isSuperuser: json['isSuperuser'] as bool?,
  isVerified: json['isVerified'] as bool?,
  twoFactorEnabled: json['twoFactorEnabled'] as bool?,
  roles: (json['roles'] as List<dynamic>?)?.map((e) => e as String).toList(),
  organizationId: json['organizationId'] as String?,
);

Map<String, dynamic> _$$UserManagementRequestImplToJson(
  _$UserManagementRequestImpl instance,
) => <String, dynamic>{
  if (instance.email case final value?) 'email': value,
  if (instance.name case final value?) 'name': value,
  if (instance.password case final value?) 'password': value,
  if (instance.isActive case final value?) 'isActive': value,
  if (instance.isSuperuser case final value?) 'isSuperuser': value,
  if (instance.isVerified case final value?) 'isVerified': value,
  if (instance.twoFactorEnabled case final value?) 'twoFactorEnabled': value,
  if (instance.roles case final value?) 'roles': value,
  if (instance.organizationId case final value?) 'organizationId': value,
};

_$UserManagementResponseImpl _$$UserManagementResponseImplFromJson(
  Map<String, dynamic> json,
) => _$UserManagementResponseImpl(
  id: json['id'] as String,
  email: json['email'] as String,
  name: json['name'] as String?,
  isActive: json['isActive'] as bool,
  isVerified: json['isVerified'] as bool,
  isSuperuser: json['isSuperuser'] as bool,
  isSuspended: json['isSuspended'] as bool,
  twoFactorEnabled: json['twoFactorEnabled'] as bool,
  roles: (json['roles'] as List<dynamic>)
      .map((e) => Map<String, String>.from(e as Map))
      .toList(),
  organizationId: json['organizationId'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  lastLogin: json['lastLogin'] == null
      ? null
      : DateTime.parse(json['lastLogin'] as String),
  suspensionReason: json['suspensionReason'] as String?,
  suspendedUntil: json['suspendedUntil'] == null
      ? null
      : DateTime.parse(json['suspendedUntil'] as String),
);

Map<String, dynamic> _$$UserManagementResponseImplToJson(
  _$UserManagementResponseImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  if (instance.name case final value?) 'name': value,
  'isActive': instance.isActive,
  'isVerified': instance.isVerified,
  'isSuperuser': instance.isSuperuser,
  'isSuspended': instance.isSuspended,
  'twoFactorEnabled': instance.twoFactorEnabled,
  'roles': instance.roles,
  if (instance.organizationId case final value?) 'organizationId': value,
  'createdAt': instance.createdAt.toIso8601String(),
  if (instance.lastLogin?.toIso8601String() case final value?)
    'lastLogin': value,
  if (instance.suspensionReason case final value?) 'suspensionReason': value,
  if (instance.suspendedUntil?.toIso8601String() case final value?)
    'suspendedUntil': value,
};

_$BulkUserOperationImpl _$$BulkUserOperationImplFromJson(
  Map<String, dynamic> json,
) => _$BulkUserOperationImpl(
  userIds: (json['userIds'] as List<dynamic>).map((e) => e as String).toList(),
  action: json['action'] as String,
  reason: json['reason'] as String?,
);

Map<String, dynamic> _$$BulkUserOperationImplToJson(
  _$BulkUserOperationImpl instance,
) => <String, dynamic>{
  'userIds': instance.userIds,
  'action': instance.action,
  if (instance.reason case final value?) 'reason': value,
};

_$SystemConfigUpdateImpl _$$SystemConfigUpdateImplFromJson(
  Map<String, dynamic> json,
) => _$SystemConfigUpdateImpl(
  authConfig: json['authConfig'] as Map<String, dynamic>?,
  featureFlags: (json['featureFlags'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as bool),
  ),
  rateLimits: (json['rateLimits'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, (e as num).toInt()),
  ),
  maintenanceMode: json['maintenanceMode'] as bool?,
  maintenanceMessage: json['maintenanceMessage'] as String?,
);

Map<String, dynamic> _$$SystemConfigUpdateImplToJson(
  _$SystemConfigUpdateImpl instance,
) => <String, dynamic>{
  if (instance.authConfig case final value?) 'authConfig': value,
  if (instance.featureFlags case final value?) 'featureFlags': value,
  if (instance.rateLimits case final value?) 'rateLimits': value,
  if (instance.maintenanceMode case final value?) 'maintenanceMode': value,
  if (instance.maintenanceMessage case final value?)
    'maintenanceMessage': value,
};

_$AdminDashboardDataImpl _$$AdminDashboardDataImplFromJson(
  Map<String, dynamic> json,
) => _$AdminDashboardDataImpl(
  totalUsers: (json['totalUsers'] as num).toInt(),
  activeUsers: (json['activeUsers'] as num).toInt(),
  suspendedUsers: (json['suspendedUsers'] as num).toInt(),
  activeSessions: (json['activeSessions'] as num).toInt(),
  recentRegistrations: (json['recentRegistrations'] as num).toInt(),
  failedLoginAttempts: (json['failedLoginAttempts'] as num).toInt(),
  roleDistribution: Map<String, int>.from(json['roleDistribution'] as Map),
  recentAuditLogs: (json['recentAuditLogs'] as List<dynamic>)
      .map((e) => e as Map<String, dynamic>)
      .toList(),
  systemHealth: json['systemHealth'] as Map<String, dynamic>,
);

Map<String, dynamic> _$$AdminDashboardDataImplToJson(
  _$AdminDashboardDataImpl instance,
) => <String, dynamic>{
  'totalUsers': instance.totalUsers,
  'activeUsers': instance.activeUsers,
  'suspendedUsers': instance.suspendedUsers,
  'activeSessions': instance.activeSessions,
  'recentRegistrations': instance.recentRegistrations,
  'failedLoginAttempts': instance.failedLoginAttempts,
  'roleDistribution': instance.roleDistribution,
  'recentAuditLogs': instance.recentAuditLogs,
  'systemHealth': instance.systemHealth,
};

_$UserActivityReportImpl _$$UserActivityReportImplFromJson(
  Map<String, dynamic> json,
) => _$UserActivityReportImpl(
  periodDays: (json['periodDays'] as num).toInt(),
  totalActions: (json['totalActions'] as num).toInt(),
  actionsByType: Map<String, int>.from(json['actionsByType'] as Map),
  dailyActivity: (json['dailyActivity'] as List<dynamic>)
      .map((e) => e as Map<String, dynamic>)
      .toList(),
  mostActiveUsers: (json['mostActiveUsers'] as List<dynamic>)
      .map((e) => e as Map<String, dynamic>)
      .toList(),
);

Map<String, dynamic> _$$UserActivityReportImplToJson(
  _$UserActivityReportImpl instance,
) => <String, dynamic>{
  'periodDays': instance.periodDays,
  'totalActions': instance.totalActions,
  'actionsByType': instance.actionsByType,
  'dailyActivity': instance.dailyActivity,
  'mostActiveUsers': instance.mostActiveUsers,
};

_$SecurityReportImpl _$$SecurityReportImplFromJson(Map<String, dynamic> json) =>
    _$SecurityReportImpl(
      periodDays: (json['periodDays'] as num).toInt(),
      failedLoginAttempts: (json['failedLoginAttempts'] as num).toInt(),
      suspiciousIps: (json['suspiciousIps'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
      lockedAccounts: (json['lockedAccounts'] as num).toInt(),
      twoFaAdoptionRate: (json['twoFaAdoptionRate'] as num).toDouble(),
      recentSecurityEvents: (json['recentSecurityEvents'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
    );

Map<String, dynamic> _$$SecurityReportImplToJson(
  _$SecurityReportImpl instance,
) => <String, dynamic>{
  'periodDays': instance.periodDays,
  'failedLoginAttempts': instance.failedLoginAttempts,
  'suspiciousIps': instance.suspiciousIps,
  'lockedAccounts': instance.lockedAccounts,
  'twoFaAdoptionRate': instance.twoFaAdoptionRate,
  'recentSecurityEvents': instance.recentSecurityEvents,
};

_$SystemHealthCheckImpl _$$SystemHealthCheckImplFromJson(
  Map<String, dynamic> json,
) => _$SystemHealthCheckImpl(
  status: json['status'] as String,
  components: (json['components'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, e as Map<String, dynamic>),
  ),
  uptime: json['uptime'] as String,
  version: json['version'] as String,
  lastCheck: json['lastCheck'] as String,
);

Map<String, dynamic> _$$SystemHealthCheckImplToJson(
  _$SystemHealthCheckImpl instance,
) => <String, dynamic>{
  'status': instance.status,
  'components': instance.components,
  'uptime': instance.uptime,
  'version': instance.version,
  'lastCheck': instance.lastCheck,
};

_$SessionDataImpl _$$SessionDataImplFromJson(Map<String, dynamic> json) =>
    _$SessionDataImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      deviceInfo: json['deviceInfo'] as String,
      ipAddress: json['ipAddress'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastActivity: DateTime.parse(json['lastActivity'] as String),
      isActive: json['isActive'] as bool,
    );

Map<String, dynamic> _$$SessionDataImplToJson(_$SessionDataImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'deviceInfo': instance.deviceInfo,
      'ipAddress': instance.ipAddress,
      'createdAt': instance.createdAt.toIso8601String(),
      'lastActivity': instance.lastActivity.toIso8601String(),
      'isActive': instance.isActive,
    };

_$AuditLogEntryImpl _$$AuditLogEntryImplFromJson(Map<String, dynamic> json) =>
    _$AuditLogEntryImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      action: json['action'] as String,
      resourceType: json['resourceType'] as String,
      resourceId: json['resourceId'] as String?,
      details: json['details'] as Map<String, dynamic>,
      timestamp: DateTime.parse(json['timestamp'] as String),
      userEmail: json['userEmail'] as String,
      ipAddress: json['ipAddress'] as String,
    );

Map<String, dynamic> _$$AuditLogEntryImplToJson(_$AuditLogEntryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'action': instance.action,
      'resourceType': instance.resourceType,
      if (instance.resourceId case final value?) 'resourceId': value,
      'details': instance.details,
      'timestamp': instance.timestamp.toIso8601String(),
      'userEmail': instance.userEmail,
      'ipAddress': instance.ipAddress,
    };

_$BulkOperationResultImpl _$$BulkOperationResultImplFromJson(
  Map<String, dynamic> json,
) => _$BulkOperationResultImpl(
  totalProcessed: (json['totalProcessed'] as num).toInt(),
  successful: (json['successful'] as num).toInt(),
  failed: (json['failed'] as num).toInt(),
  errors: (json['errors'] as List<dynamic>).map((e) => e as String).toList(),
  message: json['message'] as String,
);

Map<String, dynamic> _$$BulkOperationResultImplToJson(
  _$BulkOperationResultImpl instance,
) => <String, dynamic>{
  'totalProcessed': instance.totalProcessed,
  'successful': instance.successful,
  'failed': instance.failed,
  'errors': instance.errors,
  'message': instance.message,
};

_$CreateIpBlockRuleRequestImpl _$$CreateIpBlockRuleRequestImplFromJson(
  Map<String, dynamic> json,
) => _$CreateIpBlockRuleRequestImpl(
  ipAddress: json['ipAddress'] as String,
  description: json['description'] as String?,
  isActive: json['isActive'] as bool? ?? true,
  expiresAt: json['expiresAt'] == null
      ? null
      : DateTime.parse(json['expiresAt'] as String),
);

Map<String, dynamic> _$$CreateIpBlockRuleRequestImplToJson(
  _$CreateIpBlockRuleRequestImpl instance,
) => <String, dynamic>{
  'ipAddress': instance.ipAddress,
  if (instance.description case final value?) 'description': value,
  'isActive': instance.isActive,
  if (instance.expiresAt?.toIso8601String() case final value?)
    'expiresAt': value,
};

_$CreateRateLimitRuleRequestImpl _$$CreateRateLimitRuleRequestImplFromJson(
  Map<String, dynamic> json,
) => _$CreateRateLimitRuleRequestImpl(
  endpoint: json['endpoint'] as String,
  maxRequests: (json['maxRequests'] as num).toInt(),
  windowSeconds: (json['windowSeconds'] as num).toInt(),
  description: json['description'] as String?,
  isActive: json['isActive'] as bool? ?? true,
);

Map<String, dynamic> _$$CreateRateLimitRuleRequestImplToJson(
  _$CreateRateLimitRuleRequestImpl instance,
) => <String, dynamic>{
  'endpoint': instance.endpoint,
  'maxRequests': instance.maxRequests,
  'windowSeconds': instance.windowSeconds,
  if (instance.description case final value?) 'description': value,
  'isActive': instance.isActive,
};

_$RestorePointImpl _$$RestorePointImplFromJson(Map<String, dynamic> json) =>
    _$RestorePointImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      size: (json['size'] as num).toInt(),
      description: json['description'] as String,
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$$RestorePointImplToJson(_$RestorePointImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'createdAt': instance.createdAt.toIso8601String(),
      'size': instance.size,
      'description': instance.description,
      'metadata': instance.metadata,
    };

_$CreateExportRequestImpl _$$CreateExportRequestImplFromJson(
  Map<String, dynamic> json,
) => _$CreateExportRequestImpl(
  format: json['format'] as String,
  tables: (json['tables'] as List<dynamic>).map((e) => e as String).toList(),
  includeMetadata: json['includeMetadata'] as bool? ?? true,
  startDate: json['startDate'] == null
      ? null
      : DateTime.parse(json['startDate'] as String),
  endDate: json['endDate'] == null
      ? null
      : DateTime.parse(json['endDate'] as String),
);

Map<String, dynamic> _$$CreateExportRequestImplToJson(
  _$CreateExportRequestImpl instance,
) => <String, dynamic>{
  'format': instance.format,
  'tables': instance.tables,
  'includeMetadata': instance.includeMetadata,
  if (instance.startDate?.toIso8601String() case final value?)
    'startDate': value,
  if (instance.endDate?.toIso8601String() case final value?) 'endDate': value,
};

_$CreateBackupRequestImpl _$$CreateBackupRequestImplFromJson(
  Map<String, dynamic> json,
) => _$CreateBackupRequestImpl(
  name: json['name'] as String,
  description: json['description'] as String,
  includeUserData: json['includeUserData'] as bool? ?? true,
  includeSystemData: json['includeSystemData'] as bool? ?? true,
  compress: json['compress'] as bool? ?? true,
);

Map<String, dynamic> _$$CreateBackupRequestImplToJson(
  _$CreateBackupRequestImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
  'includeUserData': instance.includeUserData,
  'includeSystemData': instance.includeSystemData,
  'compress': instance.compress,
};

_$BackupScheduleImpl _$$BackupScheduleImplFromJson(Map<String, dynamic> json) =>
    _$BackupScheduleImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      cronExpression: json['cronExpression'] as String,
      isActive: json['isActive'] as bool? ?? true,
      lastRun: json['lastRun'] == null
          ? null
          : DateTime.parse(json['lastRun'] as String),
      nextRun: json['nextRun'] == null
          ? null
          : DateTime.parse(json['nextRun'] as String),
    );

Map<String, dynamic> _$$BackupScheduleImplToJson(
  _$BackupScheduleImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'cronExpression': instance.cronExpression,
  'isActive': instance.isActive,
  if (instance.lastRun?.toIso8601String() case final value?) 'lastRun': value,
  if (instance.nextRun?.toIso8601String() case final value?) 'nextRun': value,
};

_$RetentionPolicyImpl _$$RetentionPolicyImplFromJson(
  Map<String, dynamic> json,
) => _$RetentionPolicyImpl(
  daysToKeep: (json['daysToKeep'] as num).toInt(),
  maxBackups: (json['maxBackups'] as num).toInt(),
  autoDelete: json['autoDelete'] as bool? ?? false,
  notifyBeforeDelete: json['notifyBeforeDelete'] as bool? ?? true,
);

Map<String, dynamic> _$$RetentionPolicyImplToJson(
  _$RetentionPolicyImpl instance,
) => <String, dynamic>{
  'daysToKeep': instance.daysToKeep,
  'maxBackups': instance.maxBackups,
  'autoDelete': instance.autoDelete,
  'notifyBeforeDelete': instance.notifyBeforeDelete,
};

_$SessionAnalyticsImpl _$$SessionAnalyticsImplFromJson(
  Map<String, dynamic> json,
) => _$SessionAnalyticsImpl(
  totalSessions: (json['totalSessions'] as num).toInt(),
  activeSessions: (json['activeSessions'] as num).toInt(),
  averageSessionDuration: (json['averageSessionDuration'] as num).toDouble(),
  sessionsByPlatform: Map<String, int>.from(json['sessionsByPlatform'] as Map),
  sessionsByLocation: Map<String, int>.from(json['sessionsByLocation'] as Map),
);

Map<String, dynamic> _$$SessionAnalyticsImplToJson(
  _$SessionAnalyticsImpl instance,
) => <String, dynamic>{
  'totalSessions': instance.totalSessions,
  'activeSessions': instance.activeSessions,
  'averageSessionDuration': instance.averageSessionDuration,
  'sessionsByPlatform': instance.sessionsByPlatform,
  'sessionsByLocation': instance.sessionsByLocation,
};

_$UserSessionDetailsImpl _$$UserSessionDetailsImplFromJson(
  Map<String, dynamic> json,
) => _$UserSessionDetailsImpl(
  sessionId: json['sessionId'] as String,
  userId: json['userId'] as String,
  startTime: DateTime.parse(json['startTime'] as String),
  endTime: json['endTime'] == null
      ? null
      : DateTime.parse(json['endTime'] as String),
  status: $enumDecode(_$SessionStatusEnumMap, json['status']),
  ipAddress: json['ipAddress'] as String,
  userAgent: json['userAgent'] as String,
  location: json['location'] as String?,
);

Map<String, dynamic> _$$UserSessionDetailsImplToJson(
  _$UserSessionDetailsImpl instance,
) => <String, dynamic>{
  'sessionId': instance.sessionId,
  'userId': instance.userId,
  'startTime': instance.startTime.toIso8601String(),
  if (instance.endTime?.toIso8601String() case final value?) 'endTime': value,
  'status': _$SessionStatusEnumMap[instance.status]!,
  'ipAddress': instance.ipAddress,
  'userAgent': instance.userAgent,
  if (instance.location case final value?) 'location': value,
};

const _$SessionStatusEnumMap = {
  SessionStatus.active: 'active',
  SessionStatus.inactive: 'inactive',
  SessionStatus.expired: 'expired',
  SessionStatus.terminated: 'terminated',
  SessionStatus.suspicious: 'suspicious',
};

_$SessionSecurityAlertImpl _$$SessionSecurityAlertImplFromJson(
  Map<String, dynamic> json,
) => _$SessionSecurityAlertImpl(
  id: json['id'] as String,
  sessionId: json['sessionId'] as String,
  userId: json['userId'] as String,
  alertType: json['alertType'] as String,
  message: json['message'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  severity: json['severity'] as String,
  isResolved: json['isResolved'] as bool? ?? false,
);

Map<String, dynamic> _$$SessionSecurityAlertImplToJson(
  _$SessionSecurityAlertImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'sessionId': instance.sessionId,
  'userId': instance.userId,
  'alertType': instance.alertType,
  'message': instance.message,
  'timestamp': instance.timestamp.toIso8601String(),
  'severity': instance.severity,
  'isResolved': instance.isResolved,
};
