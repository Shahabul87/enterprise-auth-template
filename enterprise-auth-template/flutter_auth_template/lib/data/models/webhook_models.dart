import 'package:freezed_annotation/freezed_annotation.dart';

part &apos;webhook_models.freezed.dart&apos;;
part &apos;webhook_models.g.dart&apos;;

@freezed
class Webhook with _$Webhook {
  const factory Webhook({
    required String id,
    required String name,
    required String description,
    required String url,
    required String secret,
    required List&lt;String&gt; events,
    required bool isActive,
    required String httpMethod,
    required Map&lt;String, String&gt; headers,
    required int timeoutSeconds,
    required int maxRetries,
    required bool verifyTls,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? lastTriggeredAt,
    WebhookStatus? status,
    int? successCount,
    int? failureCount,
    Map&lt;String, dynamic&gt;? metadata,
  }) = _Webhook;

  factory Webhook.fromJson(Map&lt;String, dynamic&gt; json) =&gt; _$WebhookFromJson(json);
}

@freezed
class WebhookCreateRequest with _$WebhookCreateRequest {
  const factory WebhookCreateRequest({
    required String name,
    required String description,
    required String url,
    required String secret,
    required List&lt;String&gt; events,
    @Default(&apos;POST&apos;) String httpMethod,
    @Default({}) Map&lt;String, String&gt; headers,
    @Default(30) int timeoutSeconds,
    @Default(3) int maxRetries,
    @Default(true) bool verifyTls,
    @Default(true) bool isActive,
    Map&lt;String, dynamic&gt;? metadata,
  }) = _WebhookCreateRequest;

  factory WebhookCreateRequest.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
      _$WebhookCreateRequestFromJson(json);
}

@freezed
class WebhookUpdateRequest with _$WebhookUpdateRequest {
  const factory WebhookUpdateRequest({
    String? name,
    String? description,
    String? url,
    String? secret,
    List&lt;String&gt;? events,
    String? httpMethod,
    Map&lt;String, String&gt;? headers,
    int? timeoutSeconds,
    int? maxRetries,
    bool? verifyTls,
    bool? isActive,
    Map&lt;String, dynamic&gt;? metadata,
  }) = _WebhookUpdateRequest;

  factory WebhookUpdateRequest.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
      _$WebhookUpdateRequestFromJson(json);
}

@freezed
class WebhookListResponse with _$WebhookListResponse {
  const factory WebhookListResponse({
    required List&lt;Webhook&gt; webhooks,
    required int total,
    required int page,
    required int limit,
    required bool hasNext,
    required bool hasPrevious,
  }) = _WebhookListResponse;

  factory WebhookListResponse.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
      _$WebhookListResponseFromJson(json);
}

@freezed
class WebhookDelivery with _$WebhookDelivery {
  const factory WebhookDelivery({
    required String id,
    required String webhookId,
    required String event,
    required Map&lt;String, dynamic&gt; payload,
    required int statusCode,
    required String response,
    required DateTime createdAt,
    required DateTime deliveredAt,
    required bool success,
    required int attempt,
    String? error,
    int? responseTime,
    Map&lt;String, String&gt;? requestHeaders,
    Map&lt;String, String&gt;? responseHeaders,
  }) = _WebhookDelivery;

  factory WebhookDelivery.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
      _$WebhookDeliveryFromJson(json);
}

@freezed
class WebhookEvent with _$WebhookEvent {
  const factory WebhookEvent({
    required String id,
    required String name,
    required String description,
    required String category,
    required Map&lt;String, dynamic&gt; samplePayload,
    required bool isEnabled,
  }) = _WebhookEvent;

  factory WebhookEvent.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
      _$WebhookEventFromJson(json);
}

@freezed
class WebhookStats with _$WebhookStats {
  const factory WebhookStats({
    required String webhookId,
    required int totalDeliveries,
    required int successfulDeliveries,
    required int failedDeliveries,
    required double successRate,
    required double averageResponseTime,
    required DateTime lastDelivery,
    required Map&lt;String, int&gt; deliveriesByDay,
    required Map&lt;String, int&gt; deliveriesByEvent,
    required List&lt;WebhookDelivery&gt; recentDeliveries,
  }) = _WebhookStats;

  factory WebhookStats.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
      _$WebhookStatsFromJson(json);
}

@freezed
class WebhookTestRequest with _$WebhookTestRequest {
  const factory WebhookTestRequest({
    required String event,
    Map&lt;String, dynamic&gt;? customPayload,
  }) = _WebhookTestRequest;

  factory WebhookTestRequest.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
      _$WebhookTestRequestFromJson(json);
}

@freezed
class WebhookTestResponse with _$WebhookTestResponse {
  const factory WebhookTestResponse({
    required bool success,
    required int statusCode,
    required String response,
    required int responseTime,
    String? error,
    Map&lt;String, String&gt;? requestHeaders,
    Map&lt;String, String&gt;? responseHeaders,
  }) = _WebhookTestResponse;

  factory WebhookTestResponse.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
      _$WebhookTestResponseFromJson(json);
}

@freezed
class WebhookTemplate with _$WebhookTemplate {
  const factory WebhookTemplate({
    required String id,
    required String name,
    required String description,
    required String category,
    required String url,
    required List&lt;String&gt; events,
    required Map&lt;String, String&gt; headers,
    required Map&lt;String, dynamic&gt; config,
    String? documentation,
  }) = _WebhookTemplate;

  factory WebhookTemplate.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
      _$WebhookTemplateFromJson(json);
}

enum WebhookStatus {
  active,
  inactive,
  error,
  disabled,
}

enum WebhookEventType {
  userCreated,
  userUpdated,
  userDeleted,
  userLogin,
  userLogout,
  roleAssigned,
  roleRemoved,
  passwordChanged,
  emailVerified,
  twoFactorEnabled,
  deviceRegistered,
  sessionExpired,
  securityAlert,
  auditLogCreated,
  organizationCreated,
  organizationUpdated,
}

enum WebhookCategory {
  authentication,
  userManagement,
  security,
  audit,
  organization,
  system,
}

extension WebhookStatusExtension on WebhookStatus {
  String get displayName {
    switch (this) {
      case WebhookStatus.active:
        return &apos;Active&apos;;
      case WebhookStatus.inactive:
        return &apos;Inactive&apos;;
      case WebhookStatus.error:
        return &apos;Error&apos;;
      case WebhookStatus.disabled:
        return &apos;Disabled&apos;;
    }
  }

  String get colorName {
    switch (this) {
      case WebhookStatus.active:
        return &apos;green&apos;;
      case WebhookStatus.inactive:
        return &apos;orange&apos;;
      case WebhookStatus.error:
        return &apos;red&apos;;
      case WebhookStatus.disabled:
        return &apos;gray&apos;;
    }
  }
}

extension WebhookEventTypeExtension on WebhookEventType {
  String get displayName {
    switch (this) {
      case WebhookEventType.userCreated:
        return &apos;User Created&apos;;
      case WebhookEventType.userUpdated:
        return &apos;User Updated&apos;;
      case WebhookEventType.userDeleted:
        return &apos;User Deleted&apos;;
      case WebhookEventType.userLogin:
        return &apos;User Login&apos;;
      case WebhookEventType.userLogout:
        return &apos;User Logout&apos;;
      case WebhookEventType.roleAssigned:
        return &apos;Role Assigned&apos;;
      case WebhookEventType.roleRemoved:
        return &apos;Role Removed&apos;;
      case WebhookEventType.passwordChanged:
        return &apos;Password Changed&apos;;
      case WebhookEventType.emailVerified:
        return &apos;Email Verified&apos;;
      case WebhookEventType.twoFactorEnabled:
        return &apos;Two Factor Enabled&apos;;
      case WebhookEventType.deviceRegistered:
        return &apos;Device Registered&apos;;
      case WebhookEventType.sessionExpired:
        return &apos;Session Expired&apos;;
      case WebhookEventType.securityAlert:
        return &apos;Security Alert&apos;;
      case WebhookEventType.auditLogCreated:
        return &apos;Audit Log Created&apos;;
      case WebhookEventType.organizationCreated:
        return &apos;Organization Created&apos;;
      case WebhookEventType.organizationUpdated:
        return &apos;Organization Updated&apos;;
    }
  }

  String get eventName {
    return name;
  }

  WebhookCategory get category {
    switch (this) {
      case WebhookEventType.userCreated:
      case WebhookEventType.userUpdated:
      case WebhookEventType.userDeleted:
      case WebhookEventType.roleAssigned:
      case WebhookEventType.roleRemoved:
        return WebhookCategory.userManagement;
      case WebhookEventType.userLogin:
      case WebhookEventType.userLogout:
      case WebhookEventType.passwordChanged:
      case WebhookEventType.emailVerified:
      case WebhookEventType.twoFactorEnabled:
        return WebhookCategory.authentication;
      case WebhookEventType.deviceRegistered:
      case WebhookEventType.sessionExpired:
      case WebhookEventType.securityAlert:
        return WebhookCategory.security;
      case WebhookEventType.auditLogCreated:
        return WebhookCategory.audit;
      case WebhookEventType.organizationCreated:
      case WebhookEventType.organizationUpdated:
        return WebhookCategory.organization;
    }
  }
}

extension WebhookCategoryExtension on WebhookCategory {
  String get displayName {
    switch (this) {
      case WebhookCategory.authentication:
        return &apos;Authentication&apos;;
      case WebhookCategory.userManagement:
        return &apos;User Management&apos;;
      case WebhookCategory.security:
        return &apos;Security&apos;;
      case WebhookCategory.audit:
        return &apos;Audit&apos;;
      case WebhookCategory.organization:
        return &apos;Organization&apos;;
      case WebhookCategory.system:
        return &apos;System&apos;;
    }
  }

  String get iconName {
    switch (this) {
      case WebhookCategory.authentication:
        return &apos;lock&apos;;
      case WebhookCategory.userManagement:
        return &apos;people&apos;;
      case WebhookCategory.security:
        return &apos;security&apos;;
      case WebhookCategory.audit:
        return &apos;history&apos;;
      case WebhookCategory.organization:
        return &apos;business&apos;;
      case WebhookCategory.system:
        return &apos;settings&apos;;
    }
  }
}