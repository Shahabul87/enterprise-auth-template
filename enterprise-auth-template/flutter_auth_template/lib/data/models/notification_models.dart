import 'package:flutter/material.dart';
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
    Map<String, dynamic>? metadata,
    List<NotificationAction>? actions,
    String? imageUrl,
    String? deepLink,
    @Default(false) bool isRead,
    @Default(false) bool isPersistent,
  }) = _NotificationMessage;

  factory NotificationMessage.fromJson(Map<String, dynamic> json) =>
      _$NotificationMessageFromJson(json);
}

@freezed
class NotificationAction with _$NotificationAction {
  const factory NotificationAction({
    required String id,
    required String label,
    required NotificationActionType type,
    String? url,
    Map<String, dynamic>? payload,
  }) = _NotificationAction;

  factory NotificationAction.fromJson(Map<String, dynamic> json) =>
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
    String? subject,
    String? content,
    List<String>? variables,
    NotificationPriority? defaultPriority,
    List<NotificationAction>? defaultActions,
    Map<String, String>? variableMap,
    NotificationChannelSettings? channelSettings,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _NotificationTemplate;

  factory NotificationTemplate.fromJson(Map<String, dynamic> json) =>
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
    Map<String, dynamic>? emailSettings,
    Map<String, dynamic>? smsSettings,
    Map<String, dynamic>? pushSettings,
  }) = _NotificationChannelSettings;

  factory NotificationChannelSettings.fromJson(Map<String, dynamic> json) =>
      _$NotificationChannelSettingsFromJson(json);
}

@freezed
class NotificationPreferences with _$NotificationPreferences {
  const factory NotificationPreferences({
    String? userId,
    @Default(true) bool globalEnabled,
    @Default(true) bool email,
    @Default(true) bool push,
    @Default(false) bool sms,
    @Default(true) bool inApp,
    Map<String, bool>? categories,
    Map<NotificationType, NotificationChannelSettings>? typeSettings,
    Map<NotificationPriority, bool>? prioritySettings,
    List<String>? mutedCategories,
    @Default(true) bool soundEnabled,
    @Default(true) bool vibrationEnabled,
    @Default('08:00') String quietHoursStart,
    @Default('22:00') String quietHoursEnd,
    DateTime? updatedAt,
  }) = _NotificationPreferences;

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) =>
      _$NotificationPreferencesFromJson(json);
}

@freezed
class NotificationBatch with _$NotificationBatch {
  const factory NotificationBatch({
    required String id,
    required String title,
    required List<String> recipients,
    required NotificationTemplate template,
    required Map<String, dynamic> variables,
    required NotificationBatchStatus status,
    required DateTime createdAt,
    DateTime? scheduledAt,
    DateTime? completedAt,
    @Default(0) int totalCount,
    @Default(0) int successCount,
    @Default(0) int failureCount,
    @Default(0) int recipientCount,
    List<NotificationDeliveryResult>? results,
    String? errorMessage,
  }) = _NotificationBatch;

  factory NotificationBatch.fromJson(Map<String, dynamic> json) =>
      _$NotificationBatchFromJson(json);
}

@freezed
class NotificationDeliveryResult with _$NotificationDeliveryResult {
  const factory NotificationDeliveryResult({
    required String recipientId,
    required List<NotificationChannelResult> channelResults,
    required NotificationDeliveryStatus overallStatus,
    DateTime? deliveredAt,
    String? errorMessage,
  }) = _NotificationDeliveryResult;

  factory NotificationDeliveryResult.fromJson(Map<String, dynamic> json) =>
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
    Map<String, dynamic>? metadata,
  }) = _NotificationChannelResult;

  factory NotificationChannelResult.fromJson(Map<String, dynamic> json) =>
      _$NotificationChannelResultFromJson(json);
}

@freezed
class NotificationSubscription with _$NotificationSubscription {
  const factory NotificationSubscription({
    required String id,
    required String userId,
    required NotificationChannel channel,
    required String endpoint,
    Map<String, dynamic>? credentials,
    @Default(true) bool isActive,
    DateTime? createdAt,
    DateTime? lastUsedAt,
  }) = _NotificationSubscription;

  factory NotificationSubscription.fromJson(Map<String, dynamic> json) =>
      _$NotificationSubscriptionFromJson(json);
}

@freezed
class NotificationAnalytics with _$NotificationAnalytics {
  const factory NotificationAnalytics({
    required NotificationDeliveryStats deliveryStats,
    required List<NotificationTypeMetric> typeMetrics,
    required List<NotificationChannelMetric> channelMetrics,
    required NotificationEngagementMetrics engagement,
    @Default(0) int totalSent,
    @Default(0.0) double deliveryRate,
  }) = _NotificationAnalytics;

  factory NotificationAnalytics.fromJson(Map<String, dynamic> json) =>
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

  factory NotificationDeliveryStats.fromJson(Map<String, dynamic> json) =>
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

  factory NotificationTypeMetric.fromJson(Map<String, dynamic> json) =>
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

  factory NotificationChannelMetric.fromJson(Map<String, dynamic> json) =>
      _$NotificationChannelMetricFromJson(json);
}

@freezed
class NotificationEngagementMetrics with _$NotificationEngagementMetrics {
  const factory NotificationEngagementMetrics({
    required double averageReadTime,
    required double clickThroughRate,
    required int totalClicks,
    required int totalDismissals,
    Map<String, int>? actionCounts,
  }) = _NotificationEngagementMetrics;

  factory NotificationEngagementMetrics.fromJson(Map<String, dynamic> json) =>
      _$NotificationEngagementMetricsFromJson(json);
}

@freezed
class CreateNotificationRequest with _$CreateNotificationRequest {
  const factory CreateNotificationRequest({
    required String title,
    required String content,
    required NotificationType type,
    NotificationPriority? priority,
    List<String>? recipients,
    List<NotificationAction>? actions,
    String? imageUrl,
    String? deepLink,
    Map<String, dynamic>? metadata,
    DateTime? expiresAt,
    DateTime? scheduledAt,
    @Default(false) bool isPersistent,
  }) = _CreateNotificationRequest;

  factory CreateNotificationRequest.fromJson(Map<String, dynamic> json) =>
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
        return 'Information';
      case NotificationType.warning:
        return 'Warning';
      case NotificationType.error:
        return 'Error';
      case NotificationType.success:
        return 'Success';
      case NotificationType.security:
        return 'Security';
      case NotificationType.system:
        return 'System';
      case NotificationType.marketing:
        return 'Marketing';
      case NotificationType.reminder:
        return 'Reminder';
      case NotificationType.announcement:
        return 'Announcement';
    }
  }

  String get icon {
    switch (this) {
      case NotificationType.info:
        return 'info';
      case NotificationType.warning:
        return 'warning';
      case NotificationType.error:
        return 'error';
      case NotificationType.success:
        return 'check_circle';
      case NotificationType.security:
        return 'security';
      case NotificationType.system:
        return 'settings';
      case NotificationType.marketing:
        return 'campaign';
      case NotificationType.reminder:
        return 'schedule';
      case NotificationType.announcement:
        return 'announcement';
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
        return 'Low';
      case NotificationPriority.normal:
        return 'Normal';
      case NotificationPriority.high:
        return 'High';
      case NotificationPriority.urgent:
        return 'Urgent';
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
        return 'In-App';
      case NotificationChannel.email:
        return 'Email';
      case NotificationChannel.sms:
        return 'SMS';
      case NotificationChannel.push:
        return 'Push';
      case NotificationChannel.webhook:
        return 'Webhook';
    }
  }

  String get icon {
    switch (this) {
      case NotificationChannel.inApp:
        return 'notifications';
      case NotificationChannel.email:
        return 'email';
      case NotificationChannel.sms:
        return 'sms';
      case NotificationChannel.push:
        return 'mobile_friendly';
      case NotificationChannel.webhook:
        return 'webhook';
    }
  }
}

extension NotificationBatchStatusExtension on NotificationBatchStatus {
  String get displayName {
    switch (this) {
      case NotificationBatchStatus.draft:
        return 'Draft';
      case NotificationBatchStatus.scheduled:
        return 'Scheduled';
      case NotificationBatchStatus.processing:
        return 'Processing';
      case NotificationBatchStatus.completed:
        return 'Completed';
      case NotificationBatchStatus.failed:
        return 'Failed';
      case NotificationBatchStatus.cancelled:
        return 'Cancelled';
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
        return 'Pending';
      case NotificationDeliveryStatus.sent:
        return 'Sent';
      case NotificationDeliveryStatus.delivered:
        return 'Delivered';
      case NotificationDeliveryStatus.failed:
        return 'Failed';
      case NotificationDeliveryStatus.read:
        return 'Read';
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