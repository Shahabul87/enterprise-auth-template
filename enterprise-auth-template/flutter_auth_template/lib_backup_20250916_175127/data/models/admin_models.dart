import 'package:freezed_annotation/freezed_annotation.dart';

part 'admin_models.freezed.dart';
part 'admin_models.g.dart';

/// System statistics
@freezed
class SystemStats with _$SystemStats {
  const factory SystemStats({
    required Map<String, int> users,
    required Map<String, int> sessions,
    required Map<String, int> organizations,
    required Map<String, int> apiKeys,
    required Map<String, int> auditLogs,
  }) = _SystemStats;

  factory SystemStats.fromJson(Map<String, dynamic> json) =>
      _$SystemStatsFromJson(json);
}

/// User management request model
@freezed
class UserManagementRequest with _$UserManagementRequest {
  const factory UserManagementRequest({
    String? email,
    String? name,
    String? password,
    bool? isActive,
    bool? isSuperuser,
    bool? isVerified,
    bool? twoFactorEnabled,
    List<String>? roles,
    String? organizationId,
  }) = _UserManagementRequest;

  factory UserManagementRequest.fromJson(Map<String, dynamic> json) =>
      _$UserManagementRequestFromJson(json);
}

/// User management response model
@freezed
class UserManagementResponse with _$UserManagementResponse {
  const factory UserManagementResponse({
    required String id,
    required String email,
    String? name,
    required bool isActive,
    required bool isVerified,
    required bool isSuperuser,
    required bool isSuspended,
    required bool twoFactorEnabled,
    required List<Map<String, String>> roles,
    String? organizationId,
    required DateTime createdAt,
    DateTime? lastLogin,
    String? suspensionReason,
    DateTime? suspendedUntil,
  }) = _UserManagementResponse;

  factory UserManagementResponse.fromJson(Map<String, dynamic> json) =>
      _$UserManagementResponseFromJson(json);
}

/// Bulk user operation model
@freezed
class BulkUserOperation with _$BulkUserOperation {
  const factory BulkUserOperation({
    required List<String> userIds,
    required String action,
    String? reason,
  }) = _BulkUserOperation;

  factory BulkUserOperation.fromJson(Map<String, dynamic> json) =>
      _$BulkUserOperationFromJson(json);
}

/// System configuration update model
@freezed
class SystemConfigUpdate with _$SystemConfigUpdate {
  const factory SystemConfigUpdate({
    Map<String, dynamic>? authConfig,
    Map<String, bool>? featureFlags,
    Map<String, int>? rateLimits,
    bool? maintenanceMode,
    String? maintenanceMessage,
  }) = _SystemConfigUpdate;

  factory SystemConfigUpdate.fromJson(Map<String, dynamic> json) =>
      _$SystemConfigUpdateFromJson(json);
}

/// Admin dashboard data model
@freezed
class AdminDashboardData with _$AdminDashboardData {
  const factory AdminDashboardData({
    required int totalUsers,
    required int activeUsers,
    required int suspendedUsers,
    required int activeSessions,
    required int recentRegistrations,
    required int failedLoginAttempts,
    required Map<String, int> roleDistribution,
    required List<Map<String, dynamic>> recentAuditLogs,
    required Map<String, dynamic> systemHealth,
  }) = _AdminDashboardData;

  factory AdminDashboardData.fromJson(Map<String, dynamic> json) =>
      _$AdminDashboardDataFromJson(json);
}

/// User activity report model
@freezed
class UserActivityReport with _$UserActivityReport {
  const factory UserActivityReport({
    required int periodDays,
    required int totalActions,
    required Map<String, int> actionsByType,
    required List<Map<String, dynamic>> dailyActivity,
    required List<Map<String, dynamic>> mostActiveUsers,
  }) = _UserActivityReport;

  factory UserActivityReport.fromJson(Map<String, dynamic> json) =>
      _$UserActivityReportFromJson(json);
}

/// Security report model
@freezed
class SecurityReport with _$SecurityReport {
  const factory SecurityReport({
    required int periodDays,
    required int failedLoginAttempts,
    required List<Map<String, dynamic>> suspiciousIps,
    required int lockedAccounts,
    required double twoFaAdoptionRate,
    required List<Map<String, dynamic>> recentSecurityEvents,
  }) = _SecurityReport;

  factory SecurityReport.fromJson(Map<String, dynamic> json) =>
      _$SecurityReportFromJson(json);
}

/// System health check model
@freezed
class SystemHealthCheck with _$SystemHealthCheck {
  const factory SystemHealthCheck({
    required String status,
    required Map<String, Map<String, dynamic>> components,
    required String uptime,
    required String version,
    required String lastCheck,
  }) = _SystemHealthCheck;

  factory SystemHealthCheck.fromJson(Map<String, dynamic> json) =>
      _$SystemHealthCheckFromJson(json);
}

/// Session data model
@freezed
class SessionData with _$SessionData {
  const factory SessionData({
    required String id,
    required String userId,
    required String deviceInfo,
    required String ipAddress,
    required DateTime createdAt,
    required DateTime lastActivity,
    required bool isActive,
  }) = _SessionData;

  factory SessionData.fromJson(Map<String, dynamic> json) =>
      _$SessionDataFromJson(json);
}

/// Audit log entry model
@freezed
class AuditLogEntry with _$AuditLogEntry {
  const factory AuditLogEntry({
    required String id,
    required String userId,
    required String action,
    required String resourceType,
    String? resourceId,
    required Map<String, dynamic> details,
    required DateTime timestamp,
    required String userEmail,
    required String ipAddress,
  }) = _AuditLogEntry;

  factory AuditLogEntry.fromJson(Map<String, dynamic> json) =>
      _$AuditLogEntryFromJson(json);
}

/// Bulk operation result model
@freezed
class BulkOperationResult with _$BulkOperationResult {
  const factory BulkOperationResult({
    required int totalProcessed,
    required int successful,
    required int failed,
    required List<String> errors,
    required String message,
  }) = _BulkOperationResult;

  factory BulkOperationResult.fromJson(Map<String, dynamic> json) =>
      _$BulkOperationResultFromJson(json);
}

/// Admin operation actions enum
enum AdminAction {
  suspend,
  unsuspend,
  activate,
  deactivate,
  delete,
  resetPassword,
  forceLogout,
}

extension AdminActionExtension on AdminAction {
  String get value {
    switch (this) {
      case AdminAction.suspend:
        return 'suspend';
      case AdminAction.unsuspend:
        return 'unsuspend';
      case AdminAction.activate:
        return 'activate';
      case AdminAction.deactivate:
        return 'deactivate';
      case AdminAction.delete:
        return 'delete';
      case AdminAction.resetPassword:
        return 'reset_password';
      case AdminAction.forceLogout:
        return 'force_logout';
    }
  }

  String get displayName {
    switch (this) {
      case AdminAction.suspend:
        return 'Suspend User';
      case AdminAction.unsuspend:
        return 'Unsuspend User';
      case AdminAction.activate:
        return 'Activate User';
      case AdminAction.deactivate:
        return 'Deactivate User';
      case AdminAction.delete:
        return 'Delete User';
      case AdminAction.resetPassword:
        return 'Reset Password';
      case AdminAction.forceLogout:
        return 'Force Logout';
    }
  }

  String get description {
    switch (this) {
      case AdminAction.suspend:
        return 'Temporarily disable user access';
      case AdminAction.unsuspend:
        return 'Restore user access';
      case AdminAction.activate:
        return 'Enable user account';
      case AdminAction.deactivate:
        return 'Disable user account';
      case AdminAction.delete:
        return 'Permanently remove user';
      case AdminAction.resetPassword:
        return 'Force password reset';
      case AdminAction.forceLogout:
        return 'Terminate all user sessions';
    }
  }
}

/// System health status enum
enum HealthStatus { healthy, degraded, unhealthy }

extension HealthStatusExtension on HealthStatus {
  String get value {
    switch (this) {
      case HealthStatus.healthy:
        return 'healthy';
      case HealthStatus.degraded:
        return 'degraded';
      case HealthStatus.unhealthy:
        return 'unhealthy';
    }
  }

  String get displayName {
    switch (this) {
      case HealthStatus.healthy:
        return 'Healthy';
      case HealthStatus.degraded:
        return 'Degraded';
      case HealthStatus.unhealthy:
        return 'Unhealthy';
    }
  }
}
