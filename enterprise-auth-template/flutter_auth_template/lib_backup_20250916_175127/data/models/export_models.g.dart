// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExportRequestImpl _$$ExportRequestImplFromJson(Map<String, dynamic> json) =>
    _$ExportRequestImpl(
      type: $enumDecode(_$ExportTypeEnumMap, json['type']),
      format: $enumDecode(_$ExportFormatEnumMap, json['format']),
      filters: json['filters'] == null
          ? null
          : ExportFilters.fromJson(json['filters'] as Map<String, dynamic>),
      options: json['options'] == null
          ? null
          : ExportOptions.fromJson(json['options'] as Map<String, dynamic>),
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      includedFields: (json['includedFields'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      excludedFields: (json['excludedFields'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$ExportRequestImplToJson(
  _$ExportRequestImpl instance,
) => <String, dynamic>{
  'type': _$ExportTypeEnumMap[instance.type]!,
  'format': _$ExportFormatEnumMap[instance.format]!,
  if (instance.filters?.toJson() case final value?) 'filters': value,
  if (instance.options?.toJson() case final value?) 'options': value,
  if (instance.startDate?.toIso8601String() case final value?)
    'startDate': value,
  if (instance.endDate?.toIso8601String() case final value?) 'endDate': value,
  if (instance.includedFields case final value?) 'includedFields': value,
  if (instance.excludedFields case final value?) 'excludedFields': value,
  if (instance.metadata case final value?) 'metadata': value,
};

const _$ExportTypeEnumMap = {
  ExportType.users: 'users',
  ExportType.auditLogs: 'auditLogs',
  ExportType.sessions: 'sessions',
  ExportType.devices: 'devices',
  ExportType.roles: 'roles',
  ExportType.permissions: 'permissions',
  ExportType.organizations: 'organizations',
  ExportType.apiKeys: 'apiKeys',
  ExportType.webhooks: 'webhooks',
  ExportType.analytics: 'analytics',
  ExportType.fullSystem: 'fullSystem',
};

const _$ExportFormatEnumMap = {
  ExportFormat.csv: 'csv',
  ExportFormat.json: 'json',
  ExportFormat.xlsx: 'xlsx',
  ExportFormat.xml: 'xml',
  ExportFormat.pdf: 'pdf',
  ExportFormat.sql: 'sql',
};

_$ExportJobImpl _$$ExportJobImplFromJson(Map<String, dynamic> json) =>
    _$ExportJobImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: $enumDecode(_$ExportTypeEnumMap, json['type']),
      format: $enumDecode(_$ExportFormatEnumMap, json['format']),
      status: $enumDecode(_$ExportStatusEnumMap, json['status']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      startedAt: json['startedAt'] == null
          ? null
          : DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      downloadUrl: json['downloadUrl'] as String?,
      fileName: json['fileName'] as String?,
      fileSize: (json['fileSize'] as num?)?.toInt(),
      recordCount: (json['recordCount'] as num?)?.toInt(),
      error: json['error'] as String?,
      progress: (json['progress'] as num?)?.toDouble(),
      filters: json['filters'] == null
          ? null
          : ExportFilters.fromJson(json['filters'] as Map<String, dynamic>),
      options: json['options'] == null
          ? null
          : ExportOptions.fromJson(json['options'] as Map<String, dynamic>),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$ExportJobImplToJson(_$ExportJobImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'type': _$ExportTypeEnumMap[instance.type]!,
      'format': _$ExportFormatEnumMap[instance.format]!,
      'status': _$ExportStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      if (instance.startedAt?.toIso8601String() case final value?)
        'startedAt': value,
      if (instance.completedAt?.toIso8601String() case final value?)
        'completedAt': value,
      if (instance.downloadUrl case final value?) 'downloadUrl': value,
      if (instance.fileName case final value?) 'fileName': value,
      if (instance.fileSize case final value?) 'fileSize': value,
      if (instance.recordCount case final value?) 'recordCount': value,
      if (instance.error case final value?) 'error': value,
      if (instance.progress case final value?) 'progress': value,
      if (instance.filters?.toJson() case final value?) 'filters': value,
      if (instance.options?.toJson() case final value?) 'options': value,
      if (instance.metadata case final value?) 'metadata': value,
    };

const _$ExportStatusEnumMap = {
  ExportStatus.pending: 'pending',
  ExportStatus.running: 'running',
  ExportStatus.completed: 'completed',
  ExportStatus.failed: 'failed',
  ExportStatus.cancelled: 'cancelled',
};

_$ExportFiltersImpl _$$ExportFiltersImplFromJson(Map<String, dynamic> json) =>
    _$ExportFiltersImpl(
      dateFrom: json['dateFrom'] == null
          ? null
          : DateTime.parse(json['dateFrom'] as String),
      dateTo: json['dateTo'] == null
          ? null
          : DateTime.parse(json['dateTo'] as String),
      userIds: (json['userIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      roles: (json['roles'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      statuses: (json['statuses'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      searchQuery: json['searchQuery'] as String?,
      customFilters: json['customFilters'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$ExportFiltersImplToJson(
  _$ExportFiltersImpl instance,
) => <String, dynamic>{
  if (instance.dateFrom?.toIso8601String() case final value?) 'dateFrom': value,
  if (instance.dateTo?.toIso8601String() case final value?) 'dateTo': value,
  if (instance.userIds case final value?) 'userIds': value,
  if (instance.roles case final value?) 'roles': value,
  if (instance.statuses case final value?) 'statuses': value,
  if (instance.searchQuery case final value?) 'searchQuery': value,
  if (instance.customFilters case final value?) 'customFilters': value,
};

_$ExportOptionsImpl _$$ExportOptionsImplFromJson(Map<String, dynamic> json) =>
    _$ExportOptionsImpl(
      includeHeaders: json['includeHeaders'] as bool? ?? true,
      compressFile: json['compressFile'] as bool? ?? false,
      encryptFile: json['encryptFile'] as bool? ?? false,
      password: json['password'] as String?,
      batchSize: (json['batchSize'] as num?)?.toInt() ?? 10000,
      csvDelimiter: json['csvDelimiter'] as String? ?? ',',
      csvQuoteChar: json['csvQuoteChar'] as String? ?? '"',
      includeSoftDeleted: json['includeSoftDeleted'] as bool? ?? true,
      includeSystemFields: json['includeSystemFields'] as bool? ?? false,
      formatOptions: json['formatOptions'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$ExportOptionsImplToJson(_$ExportOptionsImpl instance) =>
    <String, dynamic>{
      'includeHeaders': instance.includeHeaders,
      'compressFile': instance.compressFile,
      'encryptFile': instance.encryptFile,
      if (instance.password case final value?) 'password': value,
      'batchSize': instance.batchSize,
      'csvDelimiter': instance.csvDelimiter,
      'csvQuoteChar': instance.csvQuoteChar,
      'includeSoftDeleted': instance.includeSoftDeleted,
      'includeSystemFields': instance.includeSystemFields,
      if (instance.formatOptions case final value?) 'formatOptions': value,
    };

_$ExportJobListImpl _$$ExportJobListImplFromJson(Map<String, dynamic> json) =>
    _$ExportJobListImpl(
      jobs: (json['jobs'] as List<dynamic>)
          .map((e) => ExportJob.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      limit: (json['limit'] as num).toInt(),
      hasNext: json['hasNext'] as bool,
      hasPrevious: json['hasPrevious'] as bool,
    );

Map<String, dynamic> _$$ExportJobListImplToJson(_$ExportJobListImpl instance) =>
    <String, dynamic>{
      'jobs': instance.jobs.map((e) => e.toJson()).toList(),
      'total': instance.total,
      'page': instance.page,
      'limit': instance.limit,
      'hasNext': instance.hasNext,
      'hasPrevious': instance.hasPrevious,
    };

_$ExportStatsImpl _$$ExportStatsImplFromJson(Map<String, dynamic> json) =>
    _$ExportStatsImpl(
      totalJobs: (json['totalJobs'] as num).toInt(),
      completedJobs: (json['completedJobs'] as num).toInt(),
      failedJobs: (json['failedJobs'] as num).toInt(),
      runningJobs: (json['runningJobs'] as num).toInt(),
      jobsByType: Map<String, int>.from(json['jobsByType'] as Map),
      jobsByFormat: Map<String, int>.from(json['jobsByFormat'] as Map),
      recentJobs: (json['recentJobs'] as List<dynamic>)
          .map((e) => ExportJob.fromJson(e as Map<String, dynamic>))
          .toList(),
      averageExportTime: (json['averageExportTime'] as num).toDouble(),
      totalExportedRecords: (json['totalExportedRecords'] as num).toInt(),
    );

Map<String, dynamic> _$$ExportStatsImplToJson(_$ExportStatsImpl instance) =>
    <String, dynamic>{
      'totalJobs': instance.totalJobs,
      'completedJobs': instance.completedJobs,
      'failedJobs': instance.failedJobs,
      'runningJobs': instance.runningJobs,
      'jobsByType': instance.jobsByType,
      'jobsByFormat': instance.jobsByFormat,
      'recentJobs': instance.recentJobs.map((e) => e.toJson()).toList(),
      'averageExportTime': instance.averageExportTime,
      'totalExportedRecords': instance.totalExportedRecords,
    };

_$BackupRequestImpl _$$BackupRequestImplFromJson(Map<String, dynamic> json) =>
    _$BackupRequestImpl(
      type: $enumDecode(_$BackupTypeEnumMap, json['type']),
      name: json['name'] as String,
      description: json['description'] as String?,
      options: json['options'] == null
          ? null
          : BackupOptions.fromJson(json['options'] as Map<String, dynamic>),
      includedTables: (json['includedTables'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      excludedTables: (json['excludedTables'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$BackupRequestImplToJson(_$BackupRequestImpl instance) =>
    <String, dynamic>{
      'type': _$BackupTypeEnumMap[instance.type]!,
      'name': instance.name,
      if (instance.description case final value?) 'description': value,
      if (instance.options?.toJson() case final value?) 'options': value,
      if (instance.includedTables case final value?) 'includedTables': value,
      if (instance.excludedTables case final value?) 'excludedTables': value,
      if (instance.metadata case final value?) 'metadata': value,
    };

const _$BackupTypeEnumMap = {
  BackupType.full: 'full',
  BackupType.incremental: 'incremental',
  BackupType.differential: 'differential',
  BackupType.custom: 'custom',
};

_$BackupJobImpl _$$BackupJobImplFromJson(Map<String, dynamic> json) =>
    _$BackupJobImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      type: $enumDecode(_$BackupTypeEnumMap, json['type']),
      status: $enumDecode(_$BackupStatusEnumMap, json['status']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      startedAt: json['startedAt'] == null
          ? null
          : DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      downloadUrl: json['downloadUrl'] as String?,
      fileName: json['fileName'] as String?,
      fileSize: (json['fileSize'] as num?)?.toInt(),
      checksum: json['checksum'] as String?,
      error: json['error'] as String?,
      progress: (json['progress'] as num?)?.toDouble(),
      options: json['options'] == null
          ? null
          : BackupOptions.fromJson(json['options'] as Map<String, dynamic>),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$BackupJobImplToJson(_$BackupJobImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'name': instance.name,
      if (instance.description case final value?) 'description': value,
      'type': _$BackupTypeEnumMap[instance.type]!,
      'status': _$BackupStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      if (instance.startedAt?.toIso8601String() case final value?)
        'startedAt': value,
      if (instance.completedAt?.toIso8601String() case final value?)
        'completedAt': value,
      if (instance.downloadUrl case final value?) 'downloadUrl': value,
      if (instance.fileName case final value?) 'fileName': value,
      if (instance.fileSize case final value?) 'fileSize': value,
      if (instance.checksum case final value?) 'checksum': value,
      if (instance.error case final value?) 'error': value,
      if (instance.progress case final value?) 'progress': value,
      if (instance.options?.toJson() case final value?) 'options': value,
      if (instance.metadata case final value?) 'metadata': value,
    };

const _$BackupStatusEnumMap = {
  BackupStatus.pending: 'pending',
  BackupStatus.running: 'running',
  BackupStatus.completed: 'completed',
  BackupStatus.failed: 'failed',
  BackupStatus.cancelled: 'cancelled',
};

_$BackupOptionsImpl _$$BackupOptionsImplFromJson(Map<String, dynamic> json) =>
    _$BackupOptionsImpl(
      compressBackup: json['compressBackup'] as bool? ?? true,
      encryptBackup: json['encryptBackup'] as bool? ?? true,
      password: json['password'] as String?,
      includeUserData: json['includeUserData'] as bool? ?? true,
      includeSystemData: json['includeSystemData'] as bool? ?? true,
      includeAuditLogs: json['includeAuditLogs'] as bool? ?? false,
      includeSessions: json['includeSessions'] as bool? ?? false,
      customOptions: json['customOptions'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$BackupOptionsImplToJson(_$BackupOptionsImpl instance) =>
    <String, dynamic>{
      'compressBackup': instance.compressBackup,
      'encryptBackup': instance.encryptBackup,
      if (instance.password case final value?) 'password': value,
      'includeUserData': instance.includeUserData,
      'includeSystemData': instance.includeSystemData,
      'includeAuditLogs': instance.includeAuditLogs,
      'includeSessions': instance.includeSessions,
      if (instance.customOptions case final value?) 'customOptions': value,
    };

_$RestoreRequestImpl _$$RestoreRequestImplFromJson(Map<String, dynamic> json) =>
    _$RestoreRequestImpl(
      backupId: json['backupId'] as String,
      options: RestoreOptions.fromJson(json['options'] as Map<String, dynamic>),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$RestoreRequestImplToJson(
  _$RestoreRequestImpl instance,
) => <String, dynamic>{
  'backupId': instance.backupId,
  'options': instance.options.toJson(),
  if (instance.metadata case final value?) 'metadata': value,
};

_$RestoreOptionsImpl _$$RestoreOptionsImplFromJson(Map<String, dynamic> json) =>
    _$RestoreOptionsImpl(
      overwriteExisting: json['overwriteExisting'] as bool? ?? false,
      validateBeforeRestore: json['validateBeforeRestore'] as bool? ?? true,
      createBackupBeforeRestore:
          json['createBackupBeforeRestore'] as bool? ?? true,
      includedTables: (json['includedTables'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      excludedTables: (json['excludedTables'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      customOptions: json['customOptions'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$RestoreOptionsImplToJson(
  _$RestoreOptionsImpl instance,
) => <String, dynamic>{
  'overwriteExisting': instance.overwriteExisting,
  'validateBeforeRestore': instance.validateBeforeRestore,
  'createBackupBeforeRestore': instance.createBackupBeforeRestore,
  if (instance.includedTables case final value?) 'includedTables': value,
  if (instance.excludedTables case final value?) 'excludedTables': value,
  if (instance.customOptions case final value?) 'customOptions': value,
};

_$RestoreJobImpl _$$RestoreJobImplFromJson(Map<String, dynamic> json) =>
    _$RestoreJobImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      backupId: json['backupId'] as String,
      status: $enumDecode(_$RestoreStatusEnumMap, json['status']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      startedAt: json['startedAt'] == null
          ? null
          : DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      error: json['error'] as String?,
      progress: (json['progress'] as num?)?.toDouble(),
      options: json['options'] == null
          ? null
          : RestoreOptions.fromJson(json['options'] as Map<String, dynamic>),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$RestoreJobImplToJson(_$RestoreJobImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'backupId': instance.backupId,
      'status': _$RestoreStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      if (instance.startedAt?.toIso8601String() case final value?)
        'startedAt': value,
      if (instance.completedAt?.toIso8601String() case final value?)
        'completedAt': value,
      if (instance.error case final value?) 'error': value,
      if (instance.progress case final value?) 'progress': value,
      if (instance.options?.toJson() case final value?) 'options': value,
      if (instance.metadata case final value?) 'metadata': value,
    };

const _$RestoreStatusEnumMap = {
  RestoreStatus.pending: 'pending',
  RestoreStatus.validating: 'validating',
  RestoreStatus.running: 'running',
  RestoreStatus.completed: 'completed',
  RestoreStatus.failed: 'failed',
  RestoreStatus.cancelled: 'cancelled',
};
