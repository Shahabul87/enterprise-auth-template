// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'webhook_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WebhookImpl _$$WebhookImplFromJson(Map<String, dynamic> json) =>
    _$WebhookImpl(
      id: json['id'] as String?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      url: json['url'] as String?,
      secret: json['secret'] as String?,
      events: (json['events'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      isActive: json['isActive'] as bool?,
      httpMethod: json['httpMethod'] as String?,
      headers: (json['headers'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      timeoutSeconds: (json['timeoutSeconds'] as num?)?.toInt(),
      maxRetries: (json['maxRetries'] as num?)?.toInt(),
      verifyTls: json['verifyTls'] as bool?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      lastTriggeredAt: json['lastTriggeredAt'] == null
          ? null
          : DateTime.parse(json['lastTriggeredAt'] as String),
      status: $enumDecodeNullable(_$WebhookStatusEnumMap, json['status']),
      successCount: (json['successCount'] as num?)?.toInt(),
      failureCount: (json['failureCount'] as num?)?.toInt(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$WebhookImplToJson(_$WebhookImpl instance) =>
    <String, dynamic>{
      if (instance.id case final value?) 'id': value,
      if (instance.name case final value?) 'name': value,
      if (instance.description case final value?) 'description': value,
      if (instance.url case final value?) 'url': value,
      if (instance.secret case final value?) 'secret': value,
      if (instance.events case final value?) 'events': value,
      if (instance.isActive case final value?) 'isActive': value,
      if (instance.httpMethod case final value?) 'httpMethod': value,
      if (instance.headers case final value?) 'headers': value,
      if (instance.timeoutSeconds case final value?) 'timeoutSeconds': value,
      if (instance.maxRetries case final value?) 'maxRetries': value,
      if (instance.verifyTls case final value?) 'verifyTls': value,
      if (instance.createdAt?.toIso8601String() case final value?)
        'createdAt': value,
      if (instance.updatedAt?.toIso8601String() case final value?)
        'updatedAt': value,
      if (instance.lastTriggeredAt?.toIso8601String() case final value?)
        'lastTriggeredAt': value,
      if (_$WebhookStatusEnumMap[instance.status] case final value?)
        'status': value,
      if (instance.successCount case final value?) 'successCount': value,
      if (instance.failureCount case final value?) 'failureCount': value,
      if (instance.metadata case final value?) 'metadata': value,
    };

const _$WebhookStatusEnumMap = {
  WebhookStatus.active: 'active',
  WebhookStatus.inactive: 'inactive',
  WebhookStatus.error: 'error',
  WebhookStatus.disabled: 'disabled',
};

_$WebhookCreateRequestImpl _$$WebhookCreateRequestImplFromJson(
  Map<String, dynamic> json,
) => _$WebhookCreateRequestImpl(
  name: json['name'] as String,
  description: json['description'] as String,
  url: json['url'] as String,
  secret: json['secret'] as String,
  events: (json['events'] as List<dynamic>).map((e) => e as String).toList(),
  httpMethod: json['httpMethod'] as String? ?? 'POST',
  headers:
      (json['headers'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const {},
  timeoutSeconds: (json['timeoutSeconds'] as num?)?.toInt() ?? 30,
  maxRetries: (json['maxRetries'] as num?)?.toInt() ?? 3,
  verifyTls: json['verifyTls'] as bool? ?? true,
  isActive: json['isActive'] as bool? ?? true,
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$$WebhookCreateRequestImplToJson(
  _$WebhookCreateRequestImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
  'url': instance.url,
  'secret': instance.secret,
  'events': instance.events,
  'httpMethod': instance.httpMethod,
  'headers': instance.headers,
  'timeoutSeconds': instance.timeoutSeconds,
  'maxRetries': instance.maxRetries,
  'verifyTls': instance.verifyTls,
  'isActive': instance.isActive,
  if (instance.metadata case final value?) 'metadata': value,
};

_$WebhookUpdateRequestImpl _$$WebhookUpdateRequestImplFromJson(
  Map<String, dynamic> json,
) => _$WebhookUpdateRequestImpl(
  name: json['name'] as String?,
  description: json['description'] as String?,
  url: json['url'] as String?,
  secret: json['secret'] as String?,
  events: (json['events'] as List<dynamic>?)?.map((e) => e as String).toList(),
  httpMethod: json['httpMethod'] as String?,
  headers: (json['headers'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
  timeoutSeconds: (json['timeoutSeconds'] as num?)?.toInt(),
  maxRetries: (json['maxRetries'] as num?)?.toInt(),
  verifyTls: json['verifyTls'] as bool?,
  isActive: json['isActive'] as bool?,
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$$WebhookUpdateRequestImplToJson(
  _$WebhookUpdateRequestImpl instance,
) => <String, dynamic>{
  if (instance.name case final value?) 'name': value,
  if (instance.description case final value?) 'description': value,
  if (instance.url case final value?) 'url': value,
  if (instance.secret case final value?) 'secret': value,
  if (instance.events case final value?) 'events': value,
  if (instance.httpMethod case final value?) 'httpMethod': value,
  if (instance.headers case final value?) 'headers': value,
  if (instance.timeoutSeconds case final value?) 'timeoutSeconds': value,
  if (instance.maxRetries case final value?) 'maxRetries': value,
  if (instance.verifyTls case final value?) 'verifyTls': value,
  if (instance.isActive case final value?) 'isActive': value,
  if (instance.metadata case final value?) 'metadata': value,
};

_$WebhookListResponseImpl _$$WebhookListResponseImplFromJson(
  Map<String, dynamic> json,
) => _$WebhookListResponseImpl(
  webhooks: (json['webhooks'] as List<dynamic>)
      .map((e) => Webhook.fromJson(e as Map<String, dynamic>))
      .toList(),
  total: (json['total'] as num).toInt(),
  page: (json['page'] as num).toInt(),
  limit: (json['limit'] as num).toInt(),
  hasNext: json['hasNext'] as bool,
  hasPrevious: json['hasPrevious'] as bool,
);

Map<String, dynamic> _$$WebhookListResponseImplToJson(
  _$WebhookListResponseImpl instance,
) => <String, dynamic>{
  'webhooks': instance.webhooks.map((e) => e.toJson()).toList(),
  'total': instance.total,
  'page': instance.page,
  'limit': instance.limit,
  'hasNext': instance.hasNext,
  'hasPrevious': instance.hasPrevious,
};

_$WebhookDeliveryImpl _$$WebhookDeliveryImplFromJson(
  Map<String, dynamic> json,
) => _$WebhookDeliveryImpl(
  id: json['id'] as String?,
  webhookId: json['webhookId'] as String?,
  event: json['event'] as String?,
  payload: json['payload'] as Map<String, dynamic>?,
  statusCode: (json['statusCode'] as num?)?.toInt(),
  response: json['response'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  deliveredAt: json['deliveredAt'] == null
      ? null
      : DateTime.parse(json['deliveredAt'] as String),
  success: json['success'] as bool?,
  attempt: (json['attempt'] as num?)?.toInt(),
  error: json['error'] as String?,
  responseTime: (json['responseTime'] as num?)?.toInt(),
  requestHeaders: (json['requestHeaders'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
  responseHeaders: (json['responseHeaders'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
);

Map<String, dynamic> _$$WebhookDeliveryImplToJson(
  _$WebhookDeliveryImpl instance,
) => <String, dynamic>{
  if (instance.id case final value?) 'id': value,
  if (instance.webhookId case final value?) 'webhookId': value,
  if (instance.event case final value?) 'event': value,
  if (instance.payload case final value?) 'payload': value,
  if (instance.statusCode case final value?) 'statusCode': value,
  if (instance.response case final value?) 'response': value,
  if (instance.createdAt?.toIso8601String() case final value?)
    'createdAt': value,
  if (instance.deliveredAt?.toIso8601String() case final value?)
    'deliveredAt': value,
  if (instance.success case final value?) 'success': value,
  if (instance.attempt case final value?) 'attempt': value,
  if (instance.error case final value?) 'error': value,
  if (instance.responseTime case final value?) 'responseTime': value,
  if (instance.requestHeaders case final value?) 'requestHeaders': value,
  if (instance.responseHeaders case final value?) 'responseHeaders': value,
};

_$WebhookEventImpl _$$WebhookEventImplFromJson(Map<String, dynamic> json) =>
    _$WebhookEventImpl(
      id: json['id'] as String?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      category: json['category'] as String?,
      samplePayload: json['samplePayload'] as Map<String, dynamic>?,
      isEnabled: json['isEnabled'] as bool?,
    );

Map<String, dynamic> _$$WebhookEventImplToJson(_$WebhookEventImpl instance) =>
    <String, dynamic>{
      if (instance.id case final value?) 'id': value,
      if (instance.name case final value?) 'name': value,
      if (instance.description case final value?) 'description': value,
      if (instance.category case final value?) 'category': value,
      if (instance.samplePayload case final value?) 'samplePayload': value,
      if (instance.isEnabled case final value?) 'isEnabled': value,
    };

_$WebhookStatsImpl _$$WebhookStatsImplFromJson(Map<String, dynamic> json) =>
    _$WebhookStatsImpl(
      webhookId: json['webhookId'] as String?,
      totalDeliveries: (json['totalDeliveries'] as num?)?.toInt(),
      successfulDeliveries: (json['successfulDeliveries'] as num?)?.toInt(),
      failedDeliveries: (json['failedDeliveries'] as num?)?.toInt(),
      successRate: (json['successRate'] as num?)?.toDouble(),
      averageResponseTime: (json['averageResponseTime'] as num?)?.toDouble(),
      lastDelivery: json['lastDelivery'] == null
          ? null
          : DateTime.parse(json['lastDelivery'] as String),
      deliveriesByDay: (json['deliveriesByDay'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ),
      deliveriesByEvent: (json['deliveriesByEvent'] as Map<String, dynamic>?)
          ?.map((k, e) => MapEntry(k, (e as num).toInt())),
      recentDeliveries: (json['recentDeliveries'] as List<dynamic>?)
          ?.map((e) => WebhookDelivery.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$WebhookStatsImplToJson(
  _$WebhookStatsImpl instance,
) => <String, dynamic>{
  if (instance.webhookId case final value?) 'webhookId': value,
  if (instance.totalDeliveries case final value?) 'totalDeliveries': value,
  if (instance.successfulDeliveries case final value?)
    'successfulDeliveries': value,
  if (instance.failedDeliveries case final value?) 'failedDeliveries': value,
  if (instance.successRate case final value?) 'successRate': value,
  if (instance.averageResponseTime case final value?)
    'averageResponseTime': value,
  if (instance.lastDelivery?.toIso8601String() case final value?)
    'lastDelivery': value,
  if (instance.deliveriesByDay case final value?) 'deliveriesByDay': value,
  if (instance.deliveriesByEvent case final value?) 'deliveriesByEvent': value,
  if (instance.recentDeliveries?.map((e) => e.toJson()).toList()
      case final value?)
    'recentDeliveries': value,
};

_$WebhookTestRequestImpl _$$WebhookTestRequestImplFromJson(
  Map<String, dynamic> json,
) => _$WebhookTestRequestImpl(
  event: json['event'] as String,
  customPayload: json['customPayload'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$$WebhookTestRequestImplToJson(
  _$WebhookTestRequestImpl instance,
) => <String, dynamic>{
  'event': instance.event,
  if (instance.customPayload case final value?) 'customPayload': value,
};

_$WebhookTestResponseImpl _$$WebhookTestResponseImplFromJson(
  Map<String, dynamic> json,
) => _$WebhookTestResponseImpl(
  success: json['success'] as bool?,
  statusCode: (json['statusCode'] as num?)?.toInt(),
  response: json['response'] as String?,
  responseTime: (json['responseTime'] as num?)?.toInt(),
  error: json['error'] as String?,
  requestHeaders: (json['requestHeaders'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
  responseHeaders: (json['responseHeaders'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
);

Map<String, dynamic> _$$WebhookTestResponseImplToJson(
  _$WebhookTestResponseImpl instance,
) => <String, dynamic>{
  if (instance.success case final value?) 'success': value,
  if (instance.statusCode case final value?) 'statusCode': value,
  if (instance.response case final value?) 'response': value,
  if (instance.responseTime case final value?) 'responseTime': value,
  if (instance.error case final value?) 'error': value,
  if (instance.requestHeaders case final value?) 'requestHeaders': value,
  if (instance.responseHeaders case final value?) 'responseHeaders': value,
};

_$WebhookTemplateImpl _$$WebhookTemplateImplFromJson(
  Map<String, dynamic> json,
) => _$WebhookTemplateImpl(
  id: json['id'] as String?,
  name: json['name'] as String?,
  description: json['description'] as String?,
  category: json['category'] as String?,
  url: json['url'] as String?,
  events: (json['events'] as List<dynamic>?)?.map((e) => e as String).toList(),
  headers: (json['headers'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
  config: json['config'] as Map<String, dynamic>?,
  documentation: json['documentation'] as String?,
);

Map<String, dynamic> _$$WebhookTemplateImplToJson(
  _$WebhookTemplateImpl instance,
) => <String, dynamic>{
  if (instance.id case final value?) 'id': value,
  if (instance.name case final value?) 'name': value,
  if (instance.description case final value?) 'description': value,
  if (instance.category case final value?) 'category': value,
  if (instance.url case final value?) 'url': value,
  if (instance.events case final value?) 'events': value,
  if (instance.headers case final value?) 'headers': value,
  if (instance.config case final value?) 'config': value,
  if (instance.documentation case final value?) 'documentation': value,
};
