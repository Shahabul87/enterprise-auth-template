import 'package:freezed_annotation/freezed_annotation.dart';

part 'webhook_models.freezed.dart';
part 'webhook_models.g.dart';

@freezed
class Webhook with _$Webhook {
  const factory Webhook({
    required String id,
    required String name,
    required String description,
    required String url,
    required String secret,
    required List<String> events,
    required bool isActive,
    required String httpMethod,
    required Map<String, String> headers,
    required int timeoutSeconds,
    required int maxRetries,
    required bool verifyTls,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? lastTriggeredAt,
    WebhookStatus? status,
    int? successCount,
    int? failureCount,
    Map<String, dynamic>? metadata,
  }) = _Webhook;

  factory Webhook.fromJson(Map<String, dynamic> json) => _$WebhookFromJson(json);
}

@freezed
class WebhookCreateRequest with _$WebhookCreateRequest {
  const factory WebhookCreateRequest({
    required String name,
    required String description,
    required String url,
    required String secret,
    required List<String> events,
    @Default('POST') String httpMethod,
    @Default({}) Map<String, String> headers,
    @Default(30) int timeoutSeconds,
    @Default(3) int maxRetries,
    @Default(true) bool verifyTls,
    @Default(true) bool isActive,
    Map<String, dynamic>? metadata,
  }) = _WebhookCreateRequest;

  factory WebhookCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$WebhookCreateRequestFromJson(json);
}

@freezed
class WebhookUpdateRequest with _$WebhookUpdateRequest {
  const factory WebhookUpdateRequest({
    String? name,
    String? description,
    String? url,
    String? secret,
    List<String>? events,
    String? httpMethod,
    Map<String, String>? headers,
    int? timeoutSeconds,
    int? maxRetries,
    bool? verifyTls,
    bool? isActive,
    Map<String, dynamic>? metadata,
  }) = _WebhookUpdateRequest;

  factory WebhookUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$WebhookUpdateRequestFromJson(json);
}

@freezed
class WebhookListResponse with _$WebhookListResponse {
  const factory WebhookListResponse({
    required List<Webhook> webhooks,
    required int total,
    required int page,
    required int limit,
    required bool hasNext,
    required bool hasPrevious,
  }) = _WebhookListResponse;

  factory WebhookListResponse.fromJson(Map<String, dynamic> json) =>
      _$WebhookListResponseFromJson(json);
}

@freezed
class WebhookDelivery with _$WebhookDelivery {
  const factory WebhookDelivery({
    required String id,
    required String webhookId,
    required String event,
    required Map<String, dynamic> payload,
    required int statusCode,
    required String response,
    required DateTime createdAt,
    required DateTime deliveredAt,
    required bool success,
    required int attempt,
    String? error,
    int? responseTime,
    Map<String, String>? requestHeaders,
    Map<String, String>? responseHeaders,
  }) = _WebhookDelivery;

  factory WebhookDelivery.fromJson(Map<String, dynamic> json) =>
      _$WebhookDeliveryFromJson(json);
}

@freezed
class WebhookEvent with _$WebhookEvent {
  const factory WebhookEvent({
    required String id,
    required String name,
    required String description,
    required String category,
    required Map<String, dynamic> samplePayload,
    required bool isEnabled,
  }) = _WebhookEvent;

  factory WebhookEvent.fromJson(Map<String, dynamic> json) =>
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
    required Map<String, int> deliveriesByDay,
    required Map<String, int> deliveriesByEvent,
    required List<WebhookDelivery> recentDeliveries,
  }) = _WebhookStats;

  factory WebhookStats.fromJson(Map<String, dynamic> json) =>
      _$WebhookStatsFromJson(json);
}

@freezed
class WebhookTestRequest with _$WebhookTestRequest {
  const factory WebhookTestRequest({
    required String event,
    Map<String, dynamic>? customPayload,
  }) = _WebhookTestRequest;

  factory WebhookTestRequest.fromJson(Map<String, dynamic> json) =>
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
    Map<String, String>? requestHeaders,
    Map<String, String>? responseHeaders,
  }) = _WebhookTestResponse;

  factory WebhookTestResponse.fromJson(Map<String, dynamic> json) =>
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
    required List<String> events,
    required Map<String, String> headers,
    required Map<String, dynamic> config,
    String? documentation,
  }) = _WebhookTemplate;

  factory WebhookTemplate.fromJson(Map<String, dynamic> json) =>
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
        return 'Active';
      case WebhookStatus.inactive:
        return 'Inactive';
      case WebhookStatus.error:
        return 'Error';
      case WebhookStatus.disabled:
        return 'Disabled';
    }
  }

  String get colorName {
    switch (this) {
      case WebhookStatus.active:
        return 'green';
      case WebhookStatus.inactive:
        return 'orange';
      case WebhookStatus.error:
        return 'red';
      case WebhookStatus.disabled:
        return 'gray';
    }
  }
}

extension WebhookEventTypeExtension on WebhookEventType {
  String get displayName {
    switch (this) {
      case WebhookEventType.userCreated:
        return 'User Created';
      case WebhookEventType.userUpdated:
        return 'User Updated';
      case WebhookEventType.userDeleted:
        return 'User Deleted';
      case WebhookEventType.userLogin:
        return 'User Login';
      case WebhookEventType.userLogout:
        return 'User Logout';
      case WebhookEventType.roleAssigned:
        return 'Role Assigned';
      case WebhookEventType.roleRemoved:
        return 'Role Removed';
      case WebhookEventType.passwordChanged:
        return 'Password Changed';
      case WebhookEventType.emailVerified:
        return 'Email Verified';
      case WebhookEventType.twoFactorEnabled:
        return 'Two Factor Enabled';
      case WebhookEventType.deviceRegistered:
        return 'Device Registered';
      case WebhookEventType.sessionExpired:
        return 'Session Expired';
      case WebhookEventType.securityAlert:
        return 'Security Alert';
      case WebhookEventType.auditLogCreated:
        return 'Audit Log Created';
      case WebhookEventType.organizationCreated:
        return 'Organization Created';
      case WebhookEventType.organizationUpdated:
        return 'Organization Updated';
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
        return 'Authentication';
      case WebhookCategory.userManagement:
        return 'User Management';
      case WebhookCategory.security:
        return 'Security';
      case WebhookCategory.audit:
        return 'Audit';
      case WebhookCategory.organization:
        return 'Organization';
      case WebhookCategory.system:
        return 'System';
    }
  }

  String get iconName {
    switch (this) {
      case WebhookCategory.authentication:
        return 'lock';
      case WebhookCategory.userManagement:
        return 'people';
      case WebhookCategory.security:
        return 'security';
      case WebhookCategory.audit:
        return 'history';
      case WebhookCategory.organization:
        return 'business';
      case WebhookCategory.system:
        return 'settings';
    }
  }
}