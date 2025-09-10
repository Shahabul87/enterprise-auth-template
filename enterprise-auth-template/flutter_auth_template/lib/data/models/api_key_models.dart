import 'package:freezed_annotation/freezed_annotation.dart';

part &apos;api_key_models.freezed.dart&apos;;
part &apos;api_key_models.g.dart&apos;;

@freezed
class ApiKey with _$ApiKey {
  const factory ApiKey({
    required String id,
    required String name,
    required String description,
    required String keyPrefix,
    String? keyHash,
    required List&lt;String&gt; permissions,
    required List&lt;String&gt; scopes,
    required bool isActive,
    DateTime? expiresAt,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? lastUsedAt,
    required int usageCount,
    String? ipWhitelist,
    Map&lt;String, dynamic&gt;? metadata,
  }) = _ApiKey;

  factory ApiKey.fromJson(Map&lt;String, dynamic&gt; json) =&gt; _$ApiKeyFromJson(json);
}

@freezed
class ApiKeyCreateRequest with _$ApiKeyCreateRequest {
  const factory ApiKeyCreateRequest({
    required String name,
    required String description,
    required List&lt;String&gt; permissions,
    required List&lt;String&gt; scopes,
    DateTime? expiresAt,
    String? ipWhitelist,
    Map&lt;String, dynamic&gt;? metadata,
  }) = _ApiKeyCreateRequest;

  factory ApiKeyCreateRequest.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
      _$ApiKeyCreateRequestFromJson(json);
}

@freezed
class ApiKeyUpdateRequest with _$ApiKeyUpdateRequest {
  const factory ApiKeyUpdateRequest({
    String? name,
    String? description,
    List&lt;String&gt;? permissions,
    List&lt;String&gt;? scopes,
    bool? isActive,
    DateTime? expiresAt,
    String? ipWhitelist,
    Map&lt;String, dynamic&gt;? metadata,
  }) = _ApiKeyUpdateRequest;

  factory ApiKeyUpdateRequest.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
      _$ApiKeyUpdateRequestFromJson(json);
}

@freezed
class ApiKeyCreateResponse with _$ApiKeyCreateResponse {
  const factory ApiKeyCreateResponse({
    required ApiKey apiKey,
    required String plainTextKey,
    required String warning,
  }) = _ApiKeyCreateResponse;

  factory ApiKeyCreateResponse.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
      _$ApiKeyCreateResponseFromJson(json);
}

@freezed
class ApiKeyListResponse with _$ApiKeyListResponse {
  const factory ApiKeyListResponse({
    required List&lt;ApiKey&gt; apiKeys,
    required int total,
    required int page,
    required int limit,
    required bool hasNext,
    required bool hasPrevious,
  }) = _ApiKeyListResponse;

  factory ApiKeyListResponse.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
      _$ApiKeyListResponseFromJson(json);
}

@freezed
class ApiKeyUsageStats with _$ApiKeyUsageStats {
  const factory ApiKeyUsageStats({
    required String apiKeyId,
    required int totalRequests,
    required int successfulRequests,
    required int failedRequests,
    required Map&lt;String, int&gt; requestsByEndpoint,
    required Map&lt;String, int&gt; requestsByDay,
    required DateTime lastUsed,
    required double averageResponseTime,
  }) = _ApiKeyUsageStats;

  factory ApiKeyUsageStats.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
      _$ApiKeyUsageStatsFromJson(json);
}

@freezed
class ApiKeyPermission with _$ApiKeyPermission {
  const factory ApiKeyPermission({
    required String id,
    required String name,
    required String description,
    required String category,
    required bool isRequired,
    List&lt;String&gt;? subPermissions,
  }) = _ApiKeyPermission;

  factory ApiKeyPermission.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
      _$ApiKeyPermissionFromJson(json);
}

@freezed
class ApiKeyScope with _$ApiKeyScope {
  const factory ApiKeyScope({
    required String id,
    required String name,
    required String description,
    required List&lt;String&gt; endpoints,
    required bool isDefault,
  }) = _ApiKeyScope;

  factory ApiKeyScope.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
      _$ApiKeyScopeFromJson(json);
}

@freezed
class ApiKeyActivity with _$ApiKeyActivity {
  const factory ApiKeyActivity({
    required String id,
    required String apiKeyId,
    required String endpoint,
    required String method,
    required int statusCode,
    required String ipAddress,
    required String userAgent,
    required DateTime timestamp,
    required int responseTime,
    Map&lt;String, dynamic&gt;? requestData,
    Map&lt;String, dynamic&gt;? responseData,
  }) = _ApiKeyActivity;

  factory ApiKeyActivity.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
      _$ApiKeyActivityFromJson(json);
}

enum ApiKeyStatus {
  active,
  inactive,
  expired,
  revoked,
}

enum ApiKeyPermissionCategory {
  authentication,
  userManagement,
  dataAccess,
  administration,
  analytics,
  webhooks,
}

extension ApiKeyStatusExtension on ApiKeyStatus {
  String get displayName {
    switch (this) {
      case ApiKeyStatus.active:
        return &apos;Active&apos;;
      case ApiKeyStatus.inactive:
        return &apos;Inactive&apos;;
      case ApiKeyStatus.expired:
        return &apos;Expired&apos;;
      case ApiKeyStatus.revoked:
        return &apos;Revoked&apos;;
    }
  }

  String get colorName {
    switch (this) {
      case ApiKeyStatus.active:
        return &apos;green&apos;;
      case ApiKeyStatus.inactive:
        return &apos;orange&apos;;
      case ApiKeyStatus.expired:
        return &apos;red&apos;;
      case ApiKeyStatus.revoked:
        return &apos;red&apos;;
    }
  }
}

extension ApiKeyPermissionCategoryExtension on ApiKeyPermissionCategory {
  String get displayName {
    switch (this) {
      case ApiKeyPermissionCategory.authentication:
        return &apos;Authentication&apos;;
      case ApiKeyPermissionCategory.userManagement:
        return &apos;User Management&apos;;
      case ApiKeyPermissionCategory.dataAccess:
        return &apos;Data Access&apos;;
      case ApiKeyPermissionCategory.administration:
        return &apos;Administration&apos;;
      case ApiKeyPermissionCategory.analytics:
        return &apos;Analytics&apos;;
      case ApiKeyPermissionCategory.webhooks:
        return &apos;Webhooks&apos;;
    }
  }

  String get iconName {
    switch (this) {
      case ApiKeyPermissionCategory.authentication:
        return &apos;lock&apos;;
      case ApiKeyPermissionCategory.userManagement:
        return &apos;people&apos;;
      case ApiKeyPermissionCategory.dataAccess:
        return &apos;storage&apos;;
      case ApiKeyPermissionCategory.administration:
        return &apos;admin_panel_settings&apos;;
      case ApiKeyPermissionCategory.analytics:
        return &apos;analytics&apos;;
      case ApiKeyPermissionCategory.webhooks:
        return &apos;webhook&apos;;
    }
  }
}