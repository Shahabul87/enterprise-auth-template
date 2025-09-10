import 'package:freezed_annotation/freezed_annotation.dart';

part &apos;export_models.freezed.dart&apos;;
part &apos;export_models.g.dart&apos;;

@freezed
class ExportRequest with _$ExportRequest {
  const factory ExportRequest({
    required ExportType type,
    required ExportFormat format,
    ExportFilters? filters,
    ExportOptions? options,
    DateTime? startDate,
    DateTime? endDate,
    List&lt;String&gt;? includedFields,
    List&lt;String&gt;? excludedFields,
    Map&lt;String, dynamic&gt;? metadata,
  }) = _ExportRequest;

  factory ExportRequest.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
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
    Map&lt;String, dynamic&gt;? metadata,
  }) = _ExportJob;

  factory ExportJob.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
      _$ExportJobFromJson(json);
}

@freezed
class ExportFilters with _$ExportFilters {
  const factory ExportFilters({
    DateTime? dateFrom,
    DateTime? dateTo,
    List&lt;String&gt;? userIds,
    List&lt;String&gt;? roles,
    List&lt;String&gt;? statuses,
    String? searchQuery,
    Map&lt;String, dynamic&gt;? customFilters,
  }) = _ExportFilters;

  factory ExportFilters.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
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
    @Default(&apos;,&apos;) String csvDelimiter,
    @Default(&apos;&quot;&apos;) String csvQuoteChar,
    @Default(true) bool includeSoftDeleted,
    @Default(false) bool includeSystemFields,
    Map&lt;String, dynamic&gt;? formatOptions,
  }) = _ExportOptions;

  factory ExportOptions.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
      _$ExportOptionsFromJson(json);
}

@freezed
class ExportJobList with _$ExportJobList {
  const factory ExportJobList({
    required List&lt;ExportJob&gt; jobs,
    required int total,
    required int page,
    required int limit,
    required bool hasNext,
    required bool hasPrevious,
  }) = _ExportJobList;

  factory ExportJobList.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
      _$ExportJobListFromJson(json);
}

@freezed
class ExportStats with _$ExportStats {
  const factory ExportStats({
    required int totalJobs,
    required int completedJobs,
    required int failedJobs,
    required int runningJobs,
    required Map&lt;String, int&gt; jobsByType,
    required Map&lt;String, int&gt; jobsByFormat,
    required List&lt;ExportJob&gt; recentJobs,
    required double averageExportTime,
    required int totalExportedRecords,
  }) = _ExportStats;

  factory ExportStats.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
      _$ExportStatsFromJson(json);
}

@freezed
class BackupRequest with _$BackupRequest {
  const factory BackupRequest({
    required BackupType type,
    required String name,
    String? description,
    BackupOptions? options,
    List&lt;String&gt;? includedTables,
    List&lt;String&gt;? excludedTables,
    Map&lt;String, dynamic&gt;? metadata,
  }) = _BackupRequest;

  factory BackupRequest.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
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
    Map&lt;String, dynamic&gt;? metadata,
  }) = _BackupJob;

  factory BackupJob.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
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
    Map&lt;String, dynamic&gt;? customOptions,
  }) = _BackupOptions;

  factory BackupOptions.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
      _$BackupOptionsFromJson(json);
}

@freezed
class RestoreRequest with _$RestoreRequest {
  const factory RestoreRequest({
    required String backupId,
    required RestoreOptions options,
    Map&lt;String, dynamic&gt;? metadata,
  }) = _RestoreRequest;

  factory RestoreRequest.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
      _$RestoreRequestFromJson(json);
}

@freezed
class RestoreOptions with _$RestoreOptions {
  const factory RestoreOptions({
    @Default(false) bool overwriteExisting,
    @Default(true) bool validateBeforeRestore,
    @Default(true) bool createBackupBeforeRestore,
    List&lt;String&gt;? includedTables,
    List&lt;String&gt;? excludedTables,
    Map&lt;String, dynamic&gt;? customOptions,
  }) = _RestoreOptions;

  factory RestoreOptions.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
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
    Map&lt;String, dynamic&gt;? metadata,
  }) = _RestoreJob;

  factory RestoreJob.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
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
        return &apos;Users&apos;;
      case ExportType.auditLogs:
        return &apos;Audit Logs&apos;;
      case ExportType.sessions:
        return &apos;Sessions&apos;;
      case ExportType.devices:
        return &apos;Devices&apos;;
      case ExportType.roles:
        return &apos;Roles&apos;;
      case ExportType.permissions:
        return &apos;Permissions&apos;;
      case ExportType.organizations:
        return &apos;Organizations&apos;;
      case ExportType.apiKeys:
        return &apos;API Keys&apos;;
      case ExportType.webhooks:
        return &apos;Webhooks&apos;;
      case ExportType.analytics:
        return &apos;Analytics&apos;;
      case ExportType.fullSystem:
        return &apos;Full System&apos;;
    }
  }

  String get description {
    switch (this) {
      case ExportType.users:
        return &apos;Export all user data and profiles&apos;;
      case ExportType.auditLogs:
        return &apos;Export audit logs and system events&apos;;
      case ExportType.sessions:
        return &apos;Export user sessions and login data&apos;;
      case ExportType.devices:
        return &apos;Export registered devices and security info&apos;;
      case ExportType.roles:
        return &apos;Export roles and hierarchies&apos;;
      case ExportType.permissions:
        return &apos;Export permissions and access controls&apos;;
      case ExportType.organizations:
        return &apos;Export organization data&apos;;
      case ExportType.apiKeys:
        return &apos;Export API keys and usage data&apos;;
      case ExportType.webhooks:
        return &apos;Export webhooks and delivery logs&apos;;
      case ExportType.analytics:
        return &apos;Export analytics and metrics&apos;;
      case ExportType.fullSystem:
        return &apos;Export complete system data&apos;;
    }
  }
}

extension ExportFormatExtension on ExportFormat {
  String get displayName {
    switch (this) {
      case ExportFormat.csv:
        return &apos;CSV&apos;;
      case ExportFormat.json:
        return &apos;JSON&apos;;
      case ExportFormat.xlsx:
        return &apos;Excel (XLSX)&apos;;
      case ExportFormat.xml:
        return &apos;XML&apos;;
      case ExportFormat.pdf:
        return &apos;PDF&apos;;
      case ExportFormat.sql:
        return &apos;SQL&apos;;
    }
  }

  String get fileExtension {
    switch (this) {
      case ExportFormat.csv:
        return &apos;.csv&apos;;
      case ExportFormat.json:
        return &apos;.json&apos;;
      case ExportFormat.xlsx:
        return &apos;.xlsx&apos;;
      case ExportFormat.xml:
        return &apos;.xml&apos;;
      case ExportFormat.pdf:
        return &apos;.pdf&apos;;
      case ExportFormat.sql:
        return &apos;.sql&apos;;
    }
  }

  String get mimeType {
    switch (this) {
      case ExportFormat.csv:
        return &apos;text/csv&apos;;
      case ExportFormat.json:
        return &apos;application/json&apos;;
      case ExportFormat.xlsx:
        return &apos;application/vnd.openxmlformats-officedocument.spreadsheetml.sheet&apos;;
      case ExportFormat.xml:
        return &apos;application/xml&apos;;
      case ExportFormat.pdf:
        return &apos;application/pdf&apos;;
      case ExportFormat.sql:
        return &apos;application/sql&apos;;
    }
  }
}

extension ExportStatusExtension on ExportStatus {
  String get displayName {
    switch (this) {
      case ExportStatus.pending:
        return &apos;Pending&apos;;
      case ExportStatus.running:
        return &apos;Running&apos;;
      case ExportStatus.completed:
        return &apos;Completed&apos;;
      case ExportStatus.failed:
        return &apos;Failed&apos;;
      case ExportStatus.cancelled:
        return &apos;Cancelled&apos;;
    }
  }

  String get colorName {
    switch (this) {
      case ExportStatus.pending:
        return &apos;orange&apos;;
      case ExportStatus.running:
        return &apos;blue&apos;;
      case ExportStatus.completed:
        return &apos;green&apos;;
      case ExportStatus.failed:
        return &apos;red&apos;;
      case ExportStatus.cancelled:
        return &apos;gray&apos;;
    }
  }
}

extension BackupTypeExtension on BackupType {
  String get displayName {
    switch (this) {
      case BackupType.full:
        return &apos;Full Backup&apos;;
      case BackupType.incremental:
        return &apos;Incremental Backup&apos;;
      case BackupType.differential:
        return &apos;Differential Backup&apos;;
      case BackupType.custom:
        return &apos;Custom Backup&apos;;
    }
  }

  String get description {
    switch (this) {
      case BackupType.full:
        return &apos;Complete backup of all data&apos;;
      case BackupType.incremental:
        return &apos;Backup of changes since last backup&apos;;
      case BackupType.differential:
        return &apos;Backup of changes since last full backup&apos;;
      case BackupType.custom:
        return &apos;Custom selective backup&apos;;
    }
  }
}