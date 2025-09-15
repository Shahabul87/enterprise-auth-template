// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_key_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ApiKeyImpl _$$ApiKeyImplFromJson(Map<String, dynamic> json) => _$ApiKeyImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  keyPrefix: json['keyPrefix'] as String,
  keyHash: json['keyHash'] as String?,
  permissions: (json['permissions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  scopes: (json['scopes'] as List<dynamic>).map((e) => e as String).toList(),
  isActive: json['isActive'] as bool,
  expiresAt: json['expiresAt'] == null
      ? null
      : DateTime.parse(json['expiresAt'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  lastUsedAt: json['lastUsedAt'] == null
      ? null
      : DateTime.parse(json['lastUsedAt'] as String),
  usageCount: (json['usageCount'] as num).toInt(),
  ipWhitelist: json['ipWhitelist'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$$ApiKeyImplToJson(_$ApiKeyImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'keyPrefix': instance.keyPrefix,
      if (instance.keyHash case final value?) 'keyHash': value,
      'permissions': instance.permissions,
      'scopes': instance.scopes,
      'isActive': instance.isActive,
      if (instance.expiresAt?.toIso8601String() case final value?)
        'expiresAt': value,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      if (instance.lastUsedAt?.toIso8601String() case final value?)
        'lastUsedAt': value,
      'usageCount': instance.usageCount,
      if (instance.ipWhitelist case final value?) 'ipWhitelist': value,
      if (instance.metadata case final value?) 'metadata': value,
    };

_$ApiKeyCreateRequestImpl _$$ApiKeyCreateRequestImplFromJson(
  Map<String, dynamic> json,
) => _$ApiKeyCreateRequestImpl(
  name: json['name'] as String,
  description: json['description'] as String,
  permissions: (json['permissions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  scopes: (json['scopes'] as List<dynamic>).map((e) => e as String).toList(),
  expiresAt: json['expiresAt'] == null
      ? null
      : DateTime.parse(json['expiresAt'] as String),
  ipWhitelist: json['ipWhitelist'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$$ApiKeyCreateRequestImplToJson(
  _$ApiKeyCreateRequestImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
  'permissions': instance.permissions,
  'scopes': instance.scopes,
  if (instance.expiresAt?.toIso8601String() case final value?)
    'expiresAt': value,
  if (instance.ipWhitelist case final value?) 'ipWhitelist': value,
  if (instance.metadata case final value?) 'metadata': value,
};

_$ApiKeyUpdateRequestImpl _$$ApiKeyUpdateRequestImplFromJson(
  Map<String, dynamic> json,
) => _$ApiKeyUpdateRequestImpl(
  name: json['name'] as String?,
  description: json['description'] as String?,
  permissions: (json['permissions'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  scopes: (json['scopes'] as List<dynamic>?)?.map((e) => e as String).toList(),
  isActive: json['isActive'] as bool?,
  expiresAt: json['expiresAt'] == null
      ? null
      : DateTime.parse(json['expiresAt'] as String),
  ipWhitelist: json['ipWhitelist'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$$ApiKeyUpdateRequestImplToJson(
  _$ApiKeyUpdateRequestImpl instance,
) => <String, dynamic>{
  if (instance.name case final value?) 'name': value,
  if (instance.description case final value?) 'description': value,
  if (instance.permissions case final value?) 'permissions': value,
  if (instance.scopes case final value?) 'scopes': value,
  if (instance.isActive case final value?) 'isActive': value,
  if (instance.expiresAt?.toIso8601String() case final value?)
    'expiresAt': value,
  if (instance.ipWhitelist case final value?) 'ipWhitelist': value,
  if (instance.metadata case final value?) 'metadata': value,
};

_$ApiKeyCreateResponseImpl _$$ApiKeyCreateResponseImplFromJson(
  Map<String, dynamic> json,
) => _$ApiKeyCreateResponseImpl(
  apiKey: ApiKey.fromJson(json['apiKey'] as Map<String, dynamic>),
  plainTextKey: json['plainTextKey'] as String,
  warning: json['warning'] as String,
);

Map<String, dynamic> _$$ApiKeyCreateResponseImplToJson(
  _$ApiKeyCreateResponseImpl instance,
) => <String, dynamic>{
  'apiKey': instance.apiKey.toJson(),
  'plainTextKey': instance.plainTextKey,
  'warning': instance.warning,
};

_$ApiKeyListResponseImpl _$$ApiKeyListResponseImplFromJson(
  Map<String, dynamic> json,
) => _$ApiKeyListResponseImpl(
  apiKeys: (json['apiKeys'] as List<dynamic>)
      .map((e) => ApiKey.fromJson(e as Map<String, dynamic>))
      .toList(),
  total: (json['total'] as num).toInt(),
  page: (json['page'] as num).toInt(),
  limit: (json['limit'] as num).toInt(),
  hasNext: json['hasNext'] as bool,
  hasPrevious: json['hasPrevious'] as bool,
);

Map<String, dynamic> _$$ApiKeyListResponseImplToJson(
  _$ApiKeyListResponseImpl instance,
) => <String, dynamic>{
  'apiKeys': instance.apiKeys.map((e) => e.toJson()).toList(),
  'total': instance.total,
  'page': instance.page,
  'limit': instance.limit,
  'hasNext': instance.hasNext,
  'hasPrevious': instance.hasPrevious,
};

_$ApiKeyUsageStatsImpl _$$ApiKeyUsageStatsImplFromJson(
  Map<String, dynamic> json,
) => _$ApiKeyUsageStatsImpl(
  apiKeyId: json['apiKeyId'] as String,
  totalRequests: (json['totalRequests'] as num).toInt(),
  successfulRequests: (json['successfulRequests'] as num).toInt(),
  failedRequests: (json['failedRequests'] as num).toInt(),
  requestsByEndpoint: Map<String, int>.from(json['requestsByEndpoint'] as Map),
  requestsByDay: Map<String, int>.from(json['requestsByDay'] as Map),
  lastUsed: DateTime.parse(json['lastUsed'] as String),
  averageResponseTime: (json['averageResponseTime'] as num).toDouble(),
);

Map<String, dynamic> _$$ApiKeyUsageStatsImplToJson(
  _$ApiKeyUsageStatsImpl instance,
) => <String, dynamic>{
  'apiKeyId': instance.apiKeyId,
  'totalRequests': instance.totalRequests,
  'successfulRequests': instance.successfulRequests,
  'failedRequests': instance.failedRequests,
  'requestsByEndpoint': instance.requestsByEndpoint,
  'requestsByDay': instance.requestsByDay,
  'lastUsed': instance.lastUsed.toIso8601String(),
  'averageResponseTime': instance.averageResponseTime,
};

_$ApiKeyPermissionImpl _$$ApiKeyPermissionImplFromJson(
  Map<String, dynamic> json,
) => _$ApiKeyPermissionImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  category: json['category'] as String,
  isRequired: json['isRequired'] as bool,
  subPermissions: (json['subPermissions'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$$ApiKeyPermissionImplToJson(
  _$ApiKeyPermissionImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'category': instance.category,
  'isRequired': instance.isRequired,
  if (instance.subPermissions case final value?) 'subPermissions': value,
};

_$ApiKeyScopeImpl _$$ApiKeyScopeImplFromJson(Map<String, dynamic> json) =>
    _$ApiKeyScopeImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      endpoints: (json['endpoints'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      isDefault: json['isDefault'] as bool,
    );

Map<String, dynamic> _$$ApiKeyScopeImplToJson(_$ApiKeyScopeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'endpoints': instance.endpoints,
      'isDefault': instance.isDefault,
    };

_$ApiKeyActivityImpl _$$ApiKeyActivityImplFromJson(Map<String, dynamic> json) =>
    _$ApiKeyActivityImpl(
      id: json['id'] as String,
      apiKeyId: json['apiKeyId'] as String,
      endpoint: json['endpoint'] as String,
      method: json['method'] as String,
      statusCode: (json['statusCode'] as num).toInt(),
      ipAddress: json['ipAddress'] as String,
      userAgent: json['userAgent'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      responseTime: (json['responseTime'] as num).toInt(),
      requestData: json['requestData'] as Map<String, dynamic>?,
      responseData: json['responseData'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$ApiKeyActivityImplToJson(
  _$ApiKeyActivityImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'apiKeyId': instance.apiKeyId,
  'endpoint': instance.endpoint,
  'method': instance.method,
  'statusCode': instance.statusCode,
  'ipAddress': instance.ipAddress,
  'userAgent': instance.userAgent,
  'timestamp': instance.timestamp.toIso8601String(),
  'responseTime': instance.responseTime,
  if (instance.requestData case final value?) 'requestData': value,
  if (instance.responseData case final value?) 'responseData': value,
};
