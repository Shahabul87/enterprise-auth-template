import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_models.freezed.dart';
part 'notification_models.g.dart';

@freezed
class NotificationMessage with _$NotificationMessage {
  const factory NotificationMessage({
    required String id,
    required String title,
    required String content,
    required NotificationType type,
    required NotificationPriority priority,
    required DateTime createdAt,
    DateTime? readAt,
    DateTime? expiresAt,
    Map&lt;String, dynamic&gt;? metadata,
    List&lt;NotificationAction&gt;? actions,
    String? imageUrl,
    String? deepLink,
    @Default(false) bool isRead,
    @Default(false) bool isPersistent,
  }) = _NotificationMessage;

  factory NotificationMessage.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
      _$NotificationMessageFromJson(json);
}

@freezed
class NotificationAction with _$NotificationAction {
  const factory NotificationAction({
    required String id,
    required String label,
    required NotificationActionType type,
    String? url,
    Map&lt;String, dynamic&gt;? payload,
  }) = _NotificationAction;

  factory NotificationAction.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
      _$NotificationActionFromJson(json);
}

@freezed
class NotificationTemplate with _$NotificationTemplate {
  const factory NotificationTemplate({
    required String id,
    required String name,
    required String description,
    required NotificationType type,
    required String titleTemplate,
    required String contentTemplate,
    NotificationPriority? defaultPriority,
    List&lt;NotificationAction&gt;? defaultActions,
    Map&lt;String, String&gt;? variables,
    NotificationChannelSettings? channelSettings,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _NotificationTemplate;

  factory NotificationTemplate.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
      _$NotificationTemplateFromJson(json);
}

@freezed
class NotificationChannelSettings with _$NotificationChannelSettings {
  const factory NotificationChannelSettings({
    @Default(true) bool inApp,
    @Default(false) bool email,
    @Default(false) bool sms,
    @Default(false) bool push,
    @Default(false) bool webhook,
    String? webhookUrl,
    Map&lt;String, dynamic&gt;? emailSettings,
    Map&lt;String, dynamic&gt;? smsSettings,
    Map&lt;String, dynamic&gt;? pushSettings,
  }) = _NotificationChannelSettings;

  factory NotificationChannelSettings.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
      _$NotificationChannelSettingsFromJson(json);
}

@freezed
class NotificationPreferences with _$NotificationPreferences {
  const factory NotificationPreferences({
    required String userId,
    @Default(true) bool globalEnabled,
    Map&lt;NotificationType, NotificationChannelSettings&gt;? typeSettings,
    Map&lt;NotificationPriority, bool&gt;? prioritySettings,
    List&lt;String&gt;? mutedCategories,
    @Default(true) bool soundEnabled,
    @Default(true) bool vibrationEnabled,
    @Default(&apos;08:00&apos;) String quietHoursStart,
    @Default(&apos;22:00&apos;) String quietHoursEnd,
    DateTime? updatedAt,
  }) = _NotificationPreferences;

  factory NotificationPreferences.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
      _$NotificationPreferencesFromJson(json);
}

@freezed
class NotificationBatch with _$NotificationBatch {
  const factory NotificationBatch({
    required String id,
    required String title,
    required List&lt;String&gt; recipients,
    required NotificationTemplate template,
    required Map&lt;String, dynamic&gt; variables,
    required NotificationBatchStatus status,
    required DateTime createdAt,
    DateTime? scheduledAt,
    DateTime? completedAt,
    @Default(0) int totalCount,
    @Default(0) int successCount,
    @Default(0) int failureCount,
    List&lt;NotificationDeliveryResult&gt;? results,
    String? errorMessage,
  }) = _NotificationBatch;

  factory NotificationBatch.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
      _$NotificationBatchFromJson(json);
}

@freezed
class NotificationDeliveryResult with _$NotificationDeliveryResult {
  const factory NotificationDeliveryResult({
    required String recipientId,
    required List&lt;NotificationChannelResult&gt; channelResults,
    required NotificationDeliveryStatus overallStatus,
    DateTime? deliveredAt,
    String? errorMessage,
  }) = _NotificationDeliveryResult;

  factory NotificationDeliveryResult.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
      _$NotificationDeliveryResultFromJson(json);
}

@freezed
class NotificationChannelResult with _$NotificationChannelResult {
  const factory NotificationChannelResult({
    required NotificationChannel channel,
    required NotificationDeliveryStatus status,
    DateTime? attemptedAt,
    DateTime? deliveredAt,
    String? errorMessage,
    Map&lt;String, dynamic&gt;? metadata,
  }) = _NotificationChannelResult;

  factory NotificationChannelResult.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
      _$NotificationChannelResultFromJson(json);
}

@freezed
class NotificationSubscription with _$NotificationSubscription {
  const factory NotificationSubscription({
    required String id,
    required String userId,
    required NotificationChannel channel,
    required String endpoint,
    Map&lt;String, dynamic&gt;? credentials,
    @Default(true) bool isActive,
    DateTime? createdAt,
    DateTime? lastUsedAt,
  }) = _NotificationSubscription;

  factory NotificationSubscription.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
      _$NotificationSubscriptionFromJson(json);
}

@freezed
class NotificationAnalytics with _$NotificationAnalytics {
  const factory NotificationAnalytics({
    required NotificationDeliveryStats deliveryStats,
    required List&lt;NotificationTypeMetric&gt; typeMetrics,
    required List&lt;NotificationChannelMetric&gt; channelMetrics,
    required NotificationEngagementMetrics engagement,
  }) = _NotificationAnalytics;

  factory NotificationAnalytics.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
      _$NotificationAnalyticsFromJson(json);
}

@freezed
class NotificationDeliveryStats with _$NotificationDeliveryStats {
  const factory NotificationDeliveryStats({
    required int totalSent,
    required int totalDelivered,
    required int totalFailed,
    required int totalRead,
    required double deliveryRate,
    required double readRate,
    required double averageDeliveryTime,
  }) = _NotificationDeliveryStats;

  factory NotificationDeliveryStats.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
      _$NotificationDeliveryStatsFromJson(json);
}

@freezed
class NotificationTypeMetric with _$NotificationTypeMetric {
  const factory NotificationTypeMetric({
    required NotificationType type,
    required int count,
    required double deliveryRate,
    required double readRate,
    required double averageEngagementTime,
  }) = _NotificationTypeMetric;

  factory NotificationTypeMetric.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
      _$NotificationTypeMetricFromJson(json);
}

@freezed
class NotificationChannelMetric with _$NotificationChannelMetric {
  const factory NotificationChannelMetric({
    required NotificationChannel channel,
    required int sent,
    required int delivered,
    required int failed,
    required double deliveryRate,
    required double averageDeliveryTime,
  }) = _NotificationChannelMetric;

  factory NotificationChannelMetric.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
      _$NotificationChannelMetricFromJson(json);
}

@freezed
class NotificationEngagementMetrics with _$NotificationEngagementMetrics {
  const factory NotificationEngagementMetrics({
    required double averageReadTime,
    required double clickThroughRate,
    required int totalClicks,
    required int totalDismissals,
    Map&lt;String, int&gt;? actionCounts,
  }) = _NotificationEngagementMetrics;

  factory NotificationEngagementMetrics.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
      _$NotificationEngagementMetricsFromJson(json);
}

@freezed
class CreateNotificationRequest with _$CreateNotificationRequest {
  const factory CreateNotificationRequest({
    required String title,
    required String content,
    required NotificationType type,
    NotificationPriority? priority,
    List&lt;String&gt;? recipients,
    List&lt;NotificationAction&gt;? actions,
    String? imageUrl,
    String? deepLink,
    Map&lt;String, dynamic&gt;? metadata,
    DateTime? expiresAt,
    DateTime? scheduledAt,
    @Default(false) bool isPersistent,
  }) = _CreateNotificationRequest;

  factory CreateNotificationRequest.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
      _$CreateNotificationRequestFromJson(json);
}

enum NotificationType {
  info,
  warning,
  error,
  success,
  security,
  system,
  marketing,
  reminder,
  announcement,
}

enum NotificationPriority {
  low,
  normal,
  high,
  urgent,
}

enum NotificationActionType {
  button,
  link,
  dismiss,
  snooze,
}

enum NotificationChannel {
  inApp,
  email,
  sms,
  push,
  webhook,
}

enum NotificationBatchStatus {
  draft,
  scheduled,
  processing,
  completed,
  failed,
  cancelled,
}

enum NotificationDeliveryStatus {
  pending,
  sent,
  delivered,
  failed,
  read,
}

extension NotificationTypeExtension on NotificationType {
  String get displayName {
    switch (this) {
      case NotificationType.info:
        return &apos;Information&apos;;
      case NotificationType.warning:
        return &apos;Warning&apos;;
      case NotificationType.error:
        return &apos;Error&apos;;
      case NotificationType.success:
        return &apos;Success&apos;;
      case NotificationType.security:
        return &apos;Security&apos;;
      case NotificationType.system:
        return &apos;System&apos;;
      case NotificationType.marketing:
        return &apos;Marketing&apos;;
      case NotificationType.reminder:
        return &apos;Reminder&apos;;
      case NotificationType.announcement:
        return &apos;Announcement&apos;;
    }
  }

  String get icon {
    switch (this) {
      case NotificationType.info:
        return &apos;info&apos;;
      case NotificationType.warning:
        return &apos;warning&apos;;
      case NotificationType.error:
        return &apos;error&apos;;
      case NotificationType.success:
        return &apos;check_circle&apos;;
      case NotificationType.security:
        return &apos;security&apos;;
      case NotificationType.system:
        return &apos;settings&apos;;
      case NotificationType.marketing:
        return &apos;campaign&apos;;
      case NotificationType.reminder:
        return &apos;schedule&apos;;
      case NotificationType.announcement:
        return &apos;announcement&apos;;
    }
  }

  Color get color {
    switch (this) {
      case NotificationType.info:
        return const Color(0xFF2196F3);
      case NotificationType.warning:
        return const Color(0xFFFF9800);
      case NotificationType.error:
        return const Color(0xFFF44336);
      case NotificationType.success:
        return const Color(0xFF4CAF50);
      case NotificationType.security:
        return const Color(0xFF9C27B0);
      case NotificationType.system:
        return const Color(0xFF607D8B);
      case NotificationType.marketing:
        return const Color(0xFFE91E63);
      case NotificationType.reminder:
        return const Color(0xFF00BCD4);
      case NotificationType.announcement:
        return const Color(0xFF3F51B5);
    }
  }
}

extension NotificationPriorityExtension on NotificationPriority {
  String get displayName {
    switch (this) {
      case NotificationPriority.low:
        return &apos;Low&apos;;
      case NotificationPriority.normal:
        return &apos;Normal&apos;;
      case NotificationPriority.high:
        return &apos;High&apos;;
      case NotificationPriority.urgent:
        return &apos;Urgent&apos;;
    }
  }

  Color get color {
    switch (this) {
      case NotificationPriority.low:
        return const Color(0xFF9E9E9E);
      case NotificationPriority.normal:
        return const Color(0xFF2196F3);
      case NotificationPriority.high:
        return const Color(0xFFFF9800);
      case NotificationPriority.urgent:
        return const Color(0xFFF44336);
    }
  }
}

extension NotificationChannelExtension on NotificationChannel {
  String get displayName {
    switch (this) {
      case NotificationChannel.inApp:
        return &apos;In-App&apos;;
      case NotificationChannel.email:
        return &apos;Email&apos;;
      case NotificationChannel.sms:
        return &apos;SMS&apos;;
      case NotificationChannel.push:
        return &apos;Push&apos;;
      case NotificationChannel.webhook:
        return &apos;Webhook&apos;;
    }
  }

  String get icon {
    switch (this) {
      case NotificationChannel.inApp:
        return &apos;notifications&apos;;
      case NotificationChannel.email:
        return &apos;email&apos;;
      case NotificationChannel.sms:
        return &apos;sms&apos;;
      case NotificationChannel.push:
        return &apos;mobile_friendly&apos;;
      case NotificationChannel.webhook:
        return &apos;webhook&apos;;
    }
  }
}

extension NotificationBatchStatusExtension on NotificationBatchStatus {
  String get displayName {
    switch (this) {
      case NotificationBatchStatus.draft:
        return &apos;Draft&apos;;
      case NotificationBatchStatus.scheduled:
        return &apos;Scheduled&apos;;
      case NotificationBatchStatus.processing:
        return &apos;Processing&apos;;
      case NotificationBatchStatus.completed:
        return &apos;Completed&apos;;
      case NotificationBatchStatus.failed:
        return &apos;Failed&apos;;
      case NotificationBatchStatus.cancelled:
        return &apos;Cancelled&apos;;
    }
  }

  Color get color {
    switch (this) {
      case NotificationBatchStatus.draft:
        return const Color(0xFF9E9E9E);
      case NotificationBatchStatus.scheduled:
        return const Color(0xFF2196F3);
      case NotificationBatchStatus.processing:
        return const Color(0xFFFF9800);
      case NotificationBatchStatus.completed:
        return const Color(0xFF4CAF50);
      case NotificationBatchStatus.failed:
        return const Color(0xFFF44336);
      case NotificationBatchStatus.cancelled:
        return const Color(0xFF607D8B);
    }
  }
}

extension NotificationDeliveryStatusExtension on NotificationDeliveryStatus {
  String get displayName {
    switch (this) {
      case NotificationDeliveryStatus.pending:
        return &apos;Pending&apos;;
      case NotificationDeliveryStatus.sent:
        return &apos;Sent&apos;;
      case NotificationDeliveryStatus.delivered:
        return &apos;Delivered&apos;;
      case NotificationDeliveryStatus.failed:
        return &apos;Failed&apos;;
      case NotificationDeliveryStatus.read:
        return &apos;Read&apos;;
    }
  }

  Color get color {
    switch (this) {
      case NotificationDeliveryStatus.pending:
        return const Color(0xFF9E9E9E);
      case NotificationDeliveryStatus.sent:
        return const Color(0xFF2196F3);
      case NotificationDeliveryStatus.delivered:
        return const Color(0xFF4CAF50);
      case NotificationDeliveryStatus.failed:
        return const Color(0xFFF44336);
      case NotificationDeliveryStatus.read:
        return const Color(0xFF00BCD4);
    }
  }
}