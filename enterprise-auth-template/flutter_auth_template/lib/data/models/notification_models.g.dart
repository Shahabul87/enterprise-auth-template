// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NotificationMessageImpl _$$NotificationMessageImplFromJson(
  Map<String, dynamic> json,
) => _$NotificationMessageImpl(
  id: json['id'] as String,
  title: json['title'] as String,
  content: json['content'] as String,
  type: $enumDecode(_$NotificationTypeEnumMap, json['type']),
  priority: $enumDecode(_$NotificationPriorityEnumMap, json['priority']),
  createdAt: DateTime.parse(json['createdAt'] as String),
  readAt: json['readAt'] == null
      ? null
      : DateTime.parse(json['readAt'] as String),
  expiresAt: json['expiresAt'] == null
      ? null
      : DateTime.parse(json['expiresAt'] as String),
  metadata: json['metadata'] as Map<String, dynamic>?,
  actions: (json['actions'] as List<dynamic>?)
      ?.map((e) => NotificationAction.fromJson(e as Map<String, dynamic>))
      .toList(),
  imageUrl: json['imageUrl'] as String?,
  deepLink: json['deepLink'] as String?,
  isRead: json['isRead'] as bool? ?? false,
  isPersistent: json['isPersistent'] as bool? ?? false,
);

Map<String, dynamic> _$$NotificationMessageImplToJson(
  _$NotificationMessageImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'content': instance.content,
  'type': _$NotificationTypeEnumMap[instance.type]!,
  'priority': _$NotificationPriorityEnumMap[instance.priority]!,
  'createdAt': instance.createdAt.toIso8601String(),
  if (instance.readAt?.toIso8601String() case final value?) 'readAt': value,
  if (instance.expiresAt?.toIso8601String() case final value?)
    'expiresAt': value,
  if (instance.metadata case final value?) 'metadata': value,
  if (instance.actions?.map((e) => e.toJson()).toList() case final value?)
    'actions': value,
  if (instance.imageUrl case final value?) 'imageUrl': value,
  if (instance.deepLink case final value?) 'deepLink': value,
  'isRead': instance.isRead,
  'isPersistent': instance.isPersistent,
};

const _$NotificationTypeEnumMap = {
  NotificationType.info: 'info',
  NotificationType.warning: 'warning',
  NotificationType.error: 'error',
  NotificationType.success: 'success',
  NotificationType.security: 'security',
  NotificationType.system: 'system',
  NotificationType.marketing: 'marketing',
  NotificationType.reminder: 'reminder',
  NotificationType.announcement: 'announcement',
};

const _$NotificationPriorityEnumMap = {
  NotificationPriority.low: 'low',
  NotificationPriority.normal: 'normal',
  NotificationPriority.high: 'high',
  NotificationPriority.urgent: 'urgent',
};

_$NotificationActionImpl _$$NotificationActionImplFromJson(
  Map<String, dynamic> json,
) => _$NotificationActionImpl(
  id: json['id'] as String,
  label: json['label'] as String,
  type: $enumDecode(_$NotificationActionTypeEnumMap, json['type']),
  url: json['url'] as String?,
  payload: json['payload'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$$NotificationActionImplToJson(
  _$NotificationActionImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'label': instance.label,
  'type': _$NotificationActionTypeEnumMap[instance.type]!,
  if (instance.url case final value?) 'url': value,
  if (instance.payload case final value?) 'payload': value,
};

const _$NotificationActionTypeEnumMap = {
  NotificationActionType.button: 'button',
  NotificationActionType.link: 'link',
  NotificationActionType.dismiss: 'dismiss',
  NotificationActionType.snooze: 'snooze',
};

_$NotificationTemplateImpl _$$NotificationTemplateImplFromJson(
  Map<String, dynamic> json,
) => _$NotificationTemplateImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  type: $enumDecode(_$NotificationTypeEnumMap, json['type']),
  titleTemplate: json['titleTemplate'] as String,
  contentTemplate: json['contentTemplate'] as String,
  defaultPriority: $enumDecodeNullable(
    _$NotificationPriorityEnumMap,
    json['defaultPriority'],
  ),
  defaultActions: (json['defaultActions'] as List<dynamic>?)
      ?.map((e) => NotificationAction.fromJson(e as Map<String, dynamic>))
      .toList(),
  variables: (json['variables'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
  channelSettings: json['channelSettings'] == null
      ? null
      : NotificationChannelSettings.fromJson(
          json['channelSettings'] as Map<String, dynamic>,
        ),
  isActive: json['isActive'] as bool?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$NotificationTemplateImplToJson(
  _$NotificationTemplateImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'type': _$NotificationTypeEnumMap[instance.type]!,
  'titleTemplate': instance.titleTemplate,
  'contentTemplate': instance.contentTemplate,
  if (_$NotificationPriorityEnumMap[instance.defaultPriority] case final value?)
    'defaultPriority': value,
  if (instance.defaultActions?.map((e) => e.toJson()).toList()
      case final value?)
    'defaultActions': value,
  if (instance.variables case final value?) 'variables': value,
  if (instance.channelSettings?.toJson() case final value?)
    'channelSettings': value,
  if (instance.isActive case final value?) 'isActive': value,
  if (instance.createdAt?.toIso8601String() case final value?)
    'createdAt': value,
  if (instance.updatedAt?.toIso8601String() case final value?)
    'updatedAt': value,
};

_$NotificationChannelSettingsImpl _$$NotificationChannelSettingsImplFromJson(
  Map<String, dynamic> json,
) => _$NotificationChannelSettingsImpl(
  inApp: json['inApp'] as bool? ?? true,
  email: json['email'] as bool? ?? false,
  sms: json['sms'] as bool? ?? false,
  push: json['push'] as bool? ?? false,
  webhook: json['webhook'] as bool? ?? false,
  webhookUrl: json['webhookUrl'] as String?,
  emailSettings: json['emailSettings'] as Map<String, dynamic>?,
  smsSettings: json['smsSettings'] as Map<String, dynamic>?,
  pushSettings: json['pushSettings'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$$NotificationChannelSettingsImplToJson(
  _$NotificationChannelSettingsImpl instance,
) => <String, dynamic>{
  'inApp': instance.inApp,
  'email': instance.email,
  'sms': instance.sms,
  'push': instance.push,
  'webhook': instance.webhook,
  if (instance.webhookUrl case final value?) 'webhookUrl': value,
  if (instance.emailSettings case final value?) 'emailSettings': value,
  if (instance.smsSettings case final value?) 'smsSettings': value,
  if (instance.pushSettings case final value?) 'pushSettings': value,
};

_$NotificationPreferencesImpl _$$NotificationPreferencesImplFromJson(
  Map<String, dynamic> json,
) => _$NotificationPreferencesImpl(
  userId: json['userId'] as String,
  globalEnabled: json['globalEnabled'] as bool? ?? true,
  typeSettings: (json['typeSettings'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(
      $enumDecode(_$NotificationTypeEnumMap, k),
      NotificationChannelSettings.fromJson(e as Map<String, dynamic>),
    ),
  ),
  prioritySettings: (json['prioritySettings'] as Map<String, dynamic>?)?.map(
    (k, e) =>
        MapEntry($enumDecode(_$NotificationPriorityEnumMap, k), e as bool),
  ),
  mutedCategories: (json['mutedCategories'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  soundEnabled: json['soundEnabled'] as bool? ?? true,
  vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
  quietHoursStart: json['quietHoursStart'] as String? ?? '08:00',
  quietHoursEnd: json['quietHoursEnd'] as String? ?? '22:00',
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$NotificationPreferencesImplToJson(
  _$NotificationPreferencesImpl instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'globalEnabled': instance.globalEnabled,
  if (instance.typeSettings?.map(
        (k, e) => MapEntry(_$NotificationTypeEnumMap[k]!, e.toJson()),
      )
      case final value?)
    'typeSettings': value,
  if (instance.prioritySettings?.map(
        (k, e) => MapEntry(_$NotificationPriorityEnumMap[k]!, e),
      )
      case final value?)
    'prioritySettings': value,
  if (instance.mutedCategories case final value?) 'mutedCategories': value,
  'soundEnabled': instance.soundEnabled,
  'vibrationEnabled': instance.vibrationEnabled,
  'quietHoursStart': instance.quietHoursStart,
  'quietHoursEnd': instance.quietHoursEnd,
  if (instance.updatedAt?.toIso8601String() case final value?)
    'updatedAt': value,
};

_$NotificationBatchImpl _$$NotificationBatchImplFromJson(
  Map<String, dynamic> json,
) => _$NotificationBatchImpl(
  id: json['id'] as String,
  title: json['title'] as String,
  recipients: (json['recipients'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  template: NotificationTemplate.fromJson(
    json['template'] as Map<String, dynamic>,
  ),
  variables: json['variables'] as Map<String, dynamic>,
  status: $enumDecode(_$NotificationBatchStatusEnumMap, json['status']),
  createdAt: DateTime.parse(json['createdAt'] as String),
  scheduledAt: json['scheduledAt'] == null
      ? null
      : DateTime.parse(json['scheduledAt'] as String),
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
  totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
  successCount: (json['successCount'] as num?)?.toInt() ?? 0,
  failureCount: (json['failureCount'] as num?)?.toInt() ?? 0,
  results: (json['results'] as List<dynamic>?)
      ?.map(
        (e) => NotificationDeliveryResult.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
  errorMessage: json['errorMessage'] as String?,
);

Map<String, dynamic> _$$NotificationBatchImplToJson(
  _$NotificationBatchImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'recipients': instance.recipients,
  'template': instance.template.toJson(),
  'variables': instance.variables,
  'status': _$NotificationBatchStatusEnumMap[instance.status]!,
  'createdAt': instance.createdAt.toIso8601String(),
  if (instance.scheduledAt?.toIso8601String() case final value?)
    'scheduledAt': value,
  if (instance.completedAt?.toIso8601String() case final value?)
    'completedAt': value,
  'totalCount': instance.totalCount,
  'successCount': instance.successCount,
  'failureCount': instance.failureCount,
  if (instance.results?.map((e) => e.toJson()).toList() case final value?)
    'results': value,
  if (instance.errorMessage case final value?) 'errorMessage': value,
};

const _$NotificationBatchStatusEnumMap = {
  NotificationBatchStatus.draft: 'draft',
  NotificationBatchStatus.scheduled: 'scheduled',
  NotificationBatchStatus.processing: 'processing',
  NotificationBatchStatus.completed: 'completed',
  NotificationBatchStatus.failed: 'failed',
  NotificationBatchStatus.cancelled: 'cancelled',
};

_$NotificationDeliveryResultImpl _$$NotificationDeliveryResultImplFromJson(
  Map<String, dynamic> json,
) => _$NotificationDeliveryResultImpl(
  recipientId: json['recipientId'] as String,
  channelResults: (json['channelResults'] as List<dynamic>)
      .map((e) => NotificationChannelResult.fromJson(e as Map<String, dynamic>))
      .toList(),
  overallStatus: $enumDecode(
    _$NotificationDeliveryStatusEnumMap,
    json['overallStatus'],
  ),
  deliveredAt: json['deliveredAt'] == null
      ? null
      : DateTime.parse(json['deliveredAt'] as String),
  errorMessage: json['errorMessage'] as String?,
);

Map<String, dynamic> _$$NotificationDeliveryResultImplToJson(
  _$NotificationDeliveryResultImpl instance,
) => <String, dynamic>{
  'recipientId': instance.recipientId,
  'channelResults': instance.channelResults.map((e) => e.toJson()).toList(),
  'overallStatus': _$NotificationDeliveryStatusEnumMap[instance.overallStatus]!,
  if (instance.deliveredAt?.toIso8601String() case final value?)
    'deliveredAt': value,
  if (instance.errorMessage case final value?) 'errorMessage': value,
};

const _$NotificationDeliveryStatusEnumMap = {
  NotificationDeliveryStatus.pending: 'pending',
  NotificationDeliveryStatus.sent: 'sent',
  NotificationDeliveryStatus.delivered: 'delivered',
  NotificationDeliveryStatus.failed: 'failed',
  NotificationDeliveryStatus.read: 'read',
};

_$NotificationChannelResultImpl _$$NotificationChannelResultImplFromJson(
  Map<String, dynamic> json,
) => _$NotificationChannelResultImpl(
  channel: $enumDecode(_$NotificationChannelEnumMap, json['channel']),
  status: $enumDecode(_$NotificationDeliveryStatusEnumMap, json['status']),
  attemptedAt: json['attemptedAt'] == null
      ? null
      : DateTime.parse(json['attemptedAt'] as String),
  deliveredAt: json['deliveredAt'] == null
      ? null
      : DateTime.parse(json['deliveredAt'] as String),
  errorMessage: json['errorMessage'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$$NotificationChannelResultImplToJson(
  _$NotificationChannelResultImpl instance,
) => <String, dynamic>{
  'channel': _$NotificationChannelEnumMap[instance.channel]!,
  'status': _$NotificationDeliveryStatusEnumMap[instance.status]!,
  if (instance.attemptedAt?.toIso8601String() case final value?)
    'attemptedAt': value,
  if (instance.deliveredAt?.toIso8601String() case final value?)
    'deliveredAt': value,
  if (instance.errorMessage case final value?) 'errorMessage': value,
  if (instance.metadata case final value?) 'metadata': value,
};

const _$NotificationChannelEnumMap = {
  NotificationChannel.inApp: 'inApp',
  NotificationChannel.email: 'email',
  NotificationChannel.sms: 'sms',
  NotificationChannel.push: 'push',
  NotificationChannel.webhook: 'webhook',
};

_$NotificationSubscriptionImpl _$$NotificationSubscriptionImplFromJson(
  Map<String, dynamic> json,
) => _$NotificationSubscriptionImpl(
  id: json['id'] as String,
  userId: json['userId'] as String,
  channel: $enumDecode(_$NotificationChannelEnumMap, json['channel']),
  endpoint: json['endpoint'] as String,
  credentials: json['credentials'] as Map<String, dynamic>?,
  isActive: json['isActive'] as bool? ?? true,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  lastUsedAt: json['lastUsedAt'] == null
      ? null
      : DateTime.parse(json['lastUsedAt'] as String),
);

Map<String, dynamic> _$$NotificationSubscriptionImplToJson(
  _$NotificationSubscriptionImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'channel': _$NotificationChannelEnumMap[instance.channel]!,
  'endpoint': instance.endpoint,
  if (instance.credentials case final value?) 'credentials': value,
  'isActive': instance.isActive,
  if (instance.createdAt?.toIso8601String() case final value?)
    'createdAt': value,
  if (instance.lastUsedAt?.toIso8601String() case final value?)
    'lastUsedAt': value,
};

_$NotificationAnalyticsImpl _$$NotificationAnalyticsImplFromJson(
  Map<String, dynamic> json,
) => _$NotificationAnalyticsImpl(
  deliveryStats: NotificationDeliveryStats.fromJson(
    json['deliveryStats'] as Map<String, dynamic>,
  ),
  typeMetrics: (json['typeMetrics'] as List<dynamic>)
      .map((e) => NotificationTypeMetric.fromJson(e as Map<String, dynamic>))
      .toList(),
  channelMetrics: (json['channelMetrics'] as List<dynamic>)
      .map((e) => NotificationChannelMetric.fromJson(e as Map<String, dynamic>))
      .toList(),
  engagement: NotificationEngagementMetrics.fromJson(
    json['engagement'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$$NotificationAnalyticsImplToJson(
  _$NotificationAnalyticsImpl instance,
) => <String, dynamic>{
  'deliveryStats': instance.deliveryStats.toJson(),
  'typeMetrics': instance.typeMetrics.map((e) => e.toJson()).toList(),
  'channelMetrics': instance.channelMetrics.map((e) => e.toJson()).toList(),
  'engagement': instance.engagement.toJson(),
};

_$NotificationDeliveryStatsImpl _$$NotificationDeliveryStatsImplFromJson(
  Map<String, dynamic> json,
) => _$NotificationDeliveryStatsImpl(
  totalSent: (json['totalSent'] as num).toInt(),
  totalDelivered: (json['totalDelivered'] as num).toInt(),
  totalFailed: (json['totalFailed'] as num).toInt(),
  totalRead: (json['totalRead'] as num).toInt(),
  deliveryRate: (json['deliveryRate'] as num).toDouble(),
  readRate: (json['readRate'] as num).toDouble(),
  averageDeliveryTime: (json['averageDeliveryTime'] as num).toDouble(),
);

Map<String, dynamic> _$$NotificationDeliveryStatsImplToJson(
  _$NotificationDeliveryStatsImpl instance,
) => <String, dynamic>{
  'totalSent': instance.totalSent,
  'totalDelivered': instance.totalDelivered,
  'totalFailed': instance.totalFailed,
  'totalRead': instance.totalRead,
  'deliveryRate': instance.deliveryRate,
  'readRate': instance.readRate,
  'averageDeliveryTime': instance.averageDeliveryTime,
};

_$NotificationTypeMetricImpl _$$NotificationTypeMetricImplFromJson(
  Map<String, dynamic> json,
) => _$NotificationTypeMetricImpl(
  type: $enumDecode(_$NotificationTypeEnumMap, json['type']),
  count: (json['count'] as num).toInt(),
  deliveryRate: (json['deliveryRate'] as num).toDouble(),
  readRate: (json['readRate'] as num).toDouble(),
  averageEngagementTime: (json['averageEngagementTime'] as num).toDouble(),
);

Map<String, dynamic> _$$NotificationTypeMetricImplToJson(
  _$NotificationTypeMetricImpl instance,
) => <String, dynamic>{
  'type': _$NotificationTypeEnumMap[instance.type]!,
  'count': instance.count,
  'deliveryRate': instance.deliveryRate,
  'readRate': instance.readRate,
  'averageEngagementTime': instance.averageEngagementTime,
};

_$NotificationChannelMetricImpl _$$NotificationChannelMetricImplFromJson(
  Map<String, dynamic> json,
) => _$NotificationChannelMetricImpl(
  channel: $enumDecode(_$NotificationChannelEnumMap, json['channel']),
  sent: (json['sent'] as num).toInt(),
  delivered: (json['delivered'] as num).toInt(),
  failed: (json['failed'] as num).toInt(),
  deliveryRate: (json['deliveryRate'] as num).toDouble(),
  averageDeliveryTime: (json['averageDeliveryTime'] as num).toDouble(),
);

Map<String, dynamic> _$$NotificationChannelMetricImplToJson(
  _$NotificationChannelMetricImpl instance,
) => <String, dynamic>{
  'channel': _$NotificationChannelEnumMap[instance.channel]!,
  'sent': instance.sent,
  'delivered': instance.delivered,
  'failed': instance.failed,
  'deliveryRate': instance.deliveryRate,
  'averageDeliveryTime': instance.averageDeliveryTime,
};

_$NotificationEngagementMetricsImpl
_$$NotificationEngagementMetricsImplFromJson(Map<String, dynamic> json) =>
    _$NotificationEngagementMetricsImpl(
      averageReadTime: (json['averageReadTime'] as num).toDouble(),
      clickThroughRate: (json['clickThroughRate'] as num).toDouble(),
      totalClicks: (json['totalClicks'] as num).toInt(),
      totalDismissals: (json['totalDismissals'] as num).toInt(),
      actionCounts: (json['actionCounts'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ),
    );

Map<String, dynamic> _$$NotificationEngagementMetricsImplToJson(
  _$NotificationEngagementMetricsImpl instance,
) => <String, dynamic>{
  'averageReadTime': instance.averageReadTime,
  'clickThroughRate': instance.clickThroughRate,
  'totalClicks': instance.totalClicks,
  'totalDismissals': instance.totalDismissals,
  if (instance.actionCounts case final value?) 'actionCounts': value,
};

_$CreateNotificationRequestImpl _$$CreateNotificationRequestImplFromJson(
  Map<String, dynamic> json,
) => _$CreateNotificationRequestImpl(
  title: json['title'] as String,
  content: json['content'] as String,
  type: $enumDecode(_$NotificationTypeEnumMap, json['type']),
  priority: $enumDecodeNullable(
    _$NotificationPriorityEnumMap,
    json['priority'],
  ),
  recipients: (json['recipients'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  actions: (json['actions'] as List<dynamic>?)
      ?.map((e) => NotificationAction.fromJson(e as Map<String, dynamic>))
      .toList(),
  imageUrl: json['imageUrl'] as String?,
  deepLink: json['deepLink'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
  expiresAt: json['expiresAt'] == null
      ? null
      : DateTime.parse(json['expiresAt'] as String),
  scheduledAt: json['scheduledAt'] == null
      ? null
      : DateTime.parse(json['scheduledAt'] as String),
  isPersistent: json['isPersistent'] as bool? ?? false,
);

Map<String, dynamic> _$$CreateNotificationRequestImplToJson(
  _$CreateNotificationRequestImpl instance,
) => <String, dynamic>{
  'title': instance.title,
  'content': instance.content,
  'type': _$NotificationTypeEnumMap[instance.type]!,
  if (_$NotificationPriorityEnumMap[instance.priority] case final value?)
    'priority': value,
  if (instance.recipients case final value?) 'recipients': value,
  if (instance.actions?.map((e) => e.toJson()).toList() case final value?)
    'actions': value,
  if (instance.imageUrl case final value?) 'imageUrl': value,
  if (instance.deepLink case final value?) 'deepLink': value,
  if (instance.metadata case final value?) 'metadata': value,
  if (instance.expiresAt?.toIso8601String() case final value?)
    'expiresAt': value,
  if (instance.scheduledAt?.toIso8601String() case final value?)
    'scheduledAt': value,
  'isPersistent': instance.isPersistent,
};
