import 'package:freezed_annotation/freezed_annotation.dart';

part 'export_models.freezed.dart';
part 'export_models.g.dart';

@freezed
class ExportRequest with _$ExportRequest {
  const factory ExportRequest({
    required ExportType type,
    required ExportFormat format,
    ExportFilters? filters,
    ExportOptions? options,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? includedFields,
    List<String>? excludedFields,
    Map<String, dynamic>? metadata,
  }) = _ExportRequest;

  factory ExportRequest.fromJson(Map<String, dynamic> json) =>
      _$ExportRequestFromJson(json);
}

@freezed
class ExportJob with _$ExportJob {
  const factory ExportJob({
    required String id,
    required String userId,
    required ExportType type,
    required ExportFormat format,
    required ExportStatus status,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? startedAt,
    DateTime? completedAt,
    String? downloadUrl,
    String? fileName,
    int? fileSize,
    int? recordCount,
    String? error,
    double? progress,
    ExportFilters? filters,
    ExportOptions? options,
    Map<String, dynamic>? metadata,
  }) = _ExportJob;

  factory ExportJob.fromJson(Map<String, dynamic> json) =>
      _$ExportJobFromJson(json);
}

@freezed
class ExportFilters with _$ExportFilters {
  const factory ExportFilters({
    DateTime? dateFrom,
    DateTime? dateTo,
    List<String>? userIds,
    List<String>? roles,
    List<String>? statuses,
    String? searchQuery,
    Map<String, dynamic>? customFilters,
  }) = _ExportFilters;

  factory ExportFilters.fromJson(Map<String, dynamic> json) =>
      _$ExportFiltersFromJson(json);
}

@freezed
class ExportOptions with _$ExportOptions {
  const factory ExportOptions({
    @Default(true) bool includeHeaders,
    @Default(false) bool compressFile,
    @Default(false) bool encryptFile,
    String? password,
    @Default(10000) int batchSize,
    @Default(',') String csvDelimiter,
    @Default('"') String csvQuoteChar,
    @Default(true) bool includeSoftDeleted,
    @Default(false) bool includeSystemFields,
    Map<String, dynamic>? formatOptions,
  }) = _ExportOptions;

  factory ExportOptions.fromJson(Map<String, dynamic> json) =>
      _$ExportOptionsFromJson(json);
}

@freezed
class ExportJobList with _$ExportJobList {
  const factory ExportJobList({
    required List<ExportJob> jobs,
    required int total,
    required int page,
    required int limit,
    required bool hasNext,
    required bool hasPrevious,
  }) = _ExportJobList;

  factory ExportJobList.fromJson(Map<String, dynamic> json) =>
      _$ExportJobListFromJson(json);
}

@freezed
class ExportStats with _$ExportStats {
  const factory ExportStats({
    required int totalJobs,
    required int completedJobs,
    required int failedJobs,
    required int runningJobs,
    required Map<String, int> jobsByType,
    required Map<String, int> jobsByFormat,
    required List<ExportJob> recentJobs,
    required double averageExportTime,
    required int totalExportedRecords,
  }) = _ExportStats;

  factory ExportStats.fromJson(Map<String, dynamic> json) =>
      _$ExportStatsFromJson(json);
}

@freezed
class BackupRequest with _$BackupRequest {
  const factory BackupRequest({
    required BackupType type,
    required String name,
    String? description,
    BackupOptions? options,
    List<String>? includedTables,
    List<String>? excludedTables,
    Map<String, dynamic>? metadata,
  }) = _BackupRequest;

  factory BackupRequest.fromJson(Map<String, dynamic> json) =>
      _$BackupRequestFromJson(json);
}

@freezed
class BackupJob with _$BackupJob {
  const factory BackupJob({
    required String id,
    required String userId,
    required String name,
    String? description,
    required BackupType type,
    required BackupStatus status,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? startedAt,
    DateTime? completedAt,
    String? downloadUrl,
    String? fileName,
    int? fileSize,
    String? checksum,
    String? error,
    double? progress,
    BackupOptions? options,
    Map<String, dynamic>? metadata,
  }) = _BackupJob;

  factory BackupJob.fromJson(Map<String, dynamic> json) =>
      _$BackupJobFromJson(json);
}

@freezed
class BackupOptions with _$BackupOptions {
  const factory BackupOptions({
    @Default(true) bool compressBackup,
    @Default(true) bool encryptBackup,
    String? password,
    @Default(true) bool includeUserData,
    @Default(true) bool includeSystemData,
    @Default(false) bool includeAuditLogs,
    @Default(false) bool includeSessions,
    Map<String, dynamic>? customOptions,
  }) = _BackupOptions;

  factory BackupOptions.fromJson(Map<String, dynamic> json) =>
      _$BackupOptionsFromJson(json);
}

@freezed
class RestoreRequest with _$RestoreRequest {
  const factory RestoreRequest({
    required String backupId,
    required RestoreOptions options,
    Map<String, dynamic>? metadata,
  }) = _RestoreRequest;

  factory RestoreRequest.fromJson(Map<String, dynamic> json) =>
      _$RestoreRequestFromJson(json);
}

@freezed
class RestoreOptions with _$RestoreOptions {
  const factory RestoreOptions({
    @Default(false) bool overwriteExisting,
    @Default(true) bool validateBeforeRestore,
    @Default(true) bool createBackupBeforeRestore,
    List<String>? includedTables,
    List<String>? excludedTables,
    Map<String, dynamic>? customOptions,
  }) = _RestoreOptions;

  factory RestoreOptions.fromJson(Map<String, dynamic> json) =>
      _$RestoreOptionsFromJson(json);
}

@freezed
class RestoreJob with _$RestoreJob {
  const factory RestoreJob({
    required String id,
    required String userId,
    required String backupId,
    required RestoreStatus status,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? startedAt,
    DateTime? completedAt,
    String? error,
    double? progress,
    RestoreOptions? options,
    Map<String, dynamic>? metadata,
  }) = _RestoreJob;

  factory RestoreJob.fromJson(Map<String, dynamic> json) =>
      _$RestoreJobFromJson(json);
}

enum ExportType {
  users,
  auditLogs,
  sessions,
  devices,
  roles,
  permissions,
  organizations,
  apiKeys,
  webhooks,
  analytics,
  fullSystem,
}

enum ExportFormat {
  csv,
  json,
  xlsx,
  xml,
  pdf,
  sql,
}

enum ExportStatus {
  pending,
  running,
  completed,
  failed,
  cancelled,
}

enum BackupType {
  full,
  incremental,
  differential,
  custom,
}

enum BackupStatus {
  pending,
  running,
  completed,
  failed,
  cancelled,
}

enum RestoreStatus {
  pending,
  validating,
  running,
  completed,
  failed,
  cancelled,
}

extension ExportTypeExtension on ExportType {
  String get displayName {
    switch (this) {
      case ExportType.users:
        return 'Users';
      case ExportType.auditLogs:
        return 'Audit Logs';
      case ExportType.sessions:
        return 'Sessions';
      case ExportType.devices:
        return 'Devices';
      case ExportType.roles:
        return 'Roles';
      case ExportType.permissions:
        return 'Permissions';
      case ExportType.organizations:
        return 'Organizations';
      case ExportType.apiKeys:
        return 'API Keys';
      case ExportType.webhooks:
        return 'Webhooks';
      case ExportType.analytics:
        return 'Analytics';
      case ExportType.fullSystem:
        return 'Full System';
    }
  }

  String get description {
    switch (this) {
      case ExportType.users:
        return 'Export all user data and profiles';
      case ExportType.auditLogs:
        return 'Export audit logs and system events';
      case ExportType.sessions:
        return 'Export user sessions and login data';
      case ExportType.devices:
        return 'Export registered devices and security info';
      case ExportType.roles:
        return 'Export roles and hierarchies';
      case ExportType.permissions:
        return 'Export permissions and access controls';
      case ExportType.organizations:
        return 'Export organization data';
      case ExportType.apiKeys:
        return 'Export API keys and usage data';
      case ExportType.webhooks:
        return 'Export webhooks and delivery logs';
      case ExportType.analytics:
        return 'Export analytics and metrics';
      case ExportType.fullSystem:
        return 'Export complete system data';
    }
  }
}

extension ExportFormatExtension on ExportFormat {
  String get displayName {
    switch (this) {
      case ExportFormat.csv:
        return 'CSV';
      case ExportFormat.json:
        return 'JSON';
      case ExportFormat.xlsx:
        return 'Excel (XLSX)';
      case ExportFormat.xml:
        return 'XML';
      case ExportFormat.pdf:
        return 'PDF';
      case ExportFormat.sql:
        return 'SQL';
    }
  }

  String get fileExtension {
    switch (this) {
      case ExportFormat.csv:
        return '.csv';
      case ExportFormat.json:
        return '.json';
      case ExportFormat.xlsx:
        return '.xlsx';
      case ExportFormat.xml:
        return '.xml';
      case ExportFormat.pdf:
        return '.pdf';
      case ExportFormat.sql:
        return '.sql';
    }
  }

  String get mimeType {
    switch (this) {
      case ExportFormat.csv:
        return 'text/csv';
      case ExportFormat.json:
        return 'application/json';
      case ExportFormat.xlsx:
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case ExportFormat.xml:
        return 'application/xml';
      case ExportFormat.pdf:
        return 'application/pdf';
      case ExportFormat.sql:
        return 'application/sql';
    }
  }
}

extension ExportStatusExtension on ExportStatus {
  String get displayName {
    switch (this) {
      case ExportStatus.pending:
        return 'Pending';
      case ExportStatus.running:
        return 'Running';
      case ExportStatus.completed:
        return 'Completed';
      case ExportStatus.failed:
        return 'Failed';
      case ExportStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get colorName {
    switch (this) {
      case ExportStatus.pending:
        return 'orange';
      case ExportStatus.running:
        return 'blue';
      case ExportStatus.completed:
        return 'green';
      case ExportStatus.failed:
        return 'red';
      case ExportStatus.cancelled:
        return 'gray';
    }
  }
}

extension BackupTypeExtension on BackupType {
  String get displayName {
    switch (this) {
      case BackupType.full:
        return 'Full Backup';
      case BackupType.incremental:
        return 'Incremental Backup';
      case BackupType.differential:
        return 'Differential Backup';
      case BackupType.custom:
        return 'Custom Backup';
    }
  }

  String get description {
    switch (this) {
      case BackupType.full:
        return 'Complete backup of all data';
      case BackupType.incremental:
        return 'Backup of changes since last backup';
      case BackupType.differential:
        return 'Backup of changes since last full backup';
      case BackupType.custom:
        return 'Custom selective backup';
    }
  }
}