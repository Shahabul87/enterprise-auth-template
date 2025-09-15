import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_key_models.freezed.dart';
part 'api_key_models.g.dart';

@freezed
class ApiKey with _$ApiKey {
  const factory ApiKey({
    required String id,
    required String name,
    required String description,
    required String keyPrefix,
    String? keyHash,
    required List<String> permissions,
    required List<String> scopes,
    required bool isActive,
    DateTime? expiresAt,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? lastUsedAt,
    required int usageCount,
    String? ipWhitelist,
    Map<String, dynamic>? metadata,
  }) = _ApiKey;

  factory ApiKey.fromJson(Map<String, dynamic> json) => _$ApiKeyFromJson(json);
}

@freezed
class ApiKeyCreateRequest with _$ApiKeyCreateRequest {
  const factory ApiKeyCreateRequest({
    required String name,
    required String description,
    required List<String> permissions,
    required List<String> scopes,
    DateTime? expiresAt,
    String? ipWhitelist,
    Map<String, dynamic>? metadata,
  }) = _ApiKeyCreateRequest;

  factory ApiKeyCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$ApiKeyCreateRequestFromJson(json);
}

@freezed
class ApiKeyUpdateRequest with _$ApiKeyUpdateRequest {
  const factory ApiKeyUpdateRequest({
    String? name,
    String? description,
    List<String>? permissions,
    List<String>? scopes,
    bool? isActive,
    DateTime? expiresAt,
    String? ipWhitelist,
    Map<String, dynamic>? metadata,
  }) = _ApiKeyUpdateRequest;

  factory ApiKeyUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$ApiKeyUpdateRequestFromJson(json);
}

@freezed
class ApiKeyCreateResponse with _$ApiKeyCreateResponse {
  const factory ApiKeyCreateResponse({
    required ApiKey apiKey,
    required String plainTextKey,
    required String warning,
  }) = _ApiKeyCreateResponse;

  factory ApiKeyCreateResponse.fromJson(Map<String, dynamic> json) =>
      _$ApiKeyCreateResponseFromJson(json);
}

@freezed
class ApiKeyListResponse with _$ApiKeyListResponse {
  const factory ApiKeyListResponse({
    required List<ApiKey> apiKeys,
    required int total,
    required int page,
    required int limit,
    required bool hasNext,
    required bool hasPrevious,
  }) = _ApiKeyListResponse;

  factory ApiKeyListResponse.fromJson(Map<String, dynamic> json) =>
      _$ApiKeyListResponseFromJson(json);
}

@freezed
class ApiKeyUsageStats with _$ApiKeyUsageStats {
  const factory ApiKeyUsageStats({
    required String apiKeyId,
    required int totalRequests,
    required int successfulRequests,
    required int failedRequests,
    required Map<String, int> requestsByEndpoint,
    required Map<String, int> requestsByDay,
    required DateTime lastUsed,
    required double averageResponseTime,
  }) = _ApiKeyUsageStats;

  factory ApiKeyUsageStats.fromJson(Map<String, dynamic> json) =>
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
    List<String>? subPermissions,
  }) = _ApiKeyPermission;

  factory ApiKeyPermission.fromJson(Map<String, dynamic> json) =>
      _$ApiKeyPermissionFromJson(json);
}

@freezed
class ApiKeyScope with _$ApiKeyScope {
  const factory ApiKeyScope({
    required String id,
    required String name,
    required String description,
    required List<String> endpoints,
    required bool isDefault,
  }) = _ApiKeyScope;

  factory ApiKeyScope.fromJson(Map<String, dynamic> json) =>
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
    Map<String, dynamic>? requestData,
    Map<String, dynamic>? responseData,
  }) = _ApiKeyActivity;

  factory ApiKeyActivity.fromJson(Map<String, dynamic> json) =>
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
        return 'Active';
      case ApiKeyStatus.inactive:
        return 'Inactive';
      case ApiKeyStatus.expired:
        return 'Expired';
      case ApiKeyStatus.revoked:
        return 'Revoked';
    }
  }

  String get colorName {
    switch (this) {
      case ApiKeyStatus.active:
        return 'green';
      case ApiKeyStatus.inactive:
        return 'orange';
      case ApiKeyStatus.expired:
        return 'red';
      case ApiKeyStatus.revoked:
        return 'red';
    }
  }
}

extension ApiKeyPermissionCategoryExtension on ApiKeyPermissionCategory {
  String get displayName {
    switch (this) {
      case ApiKeyPermissionCategory.authentication:
        return 'Authentication';
      case ApiKeyPermissionCategory.userManagement:
        return 'User Management';
      case ApiKeyPermissionCategory.dataAccess:
        return 'Data Access';
      case ApiKeyPermissionCategory.administration:
        return 'Administration';
      case ApiKeyPermissionCategory.analytics:
        return 'Analytics';
      case ApiKeyPermissionCategory.webhooks:
        return 'Webhooks';
    }
  }

  String get iconName {
    switch (this) {
      case ApiKeyPermissionCategory.authentication:
        return 'lock';
      case ApiKeyPermissionCategory.userManagement:
        return 'people';
      case ApiKeyPermissionCategory.dataAccess:
        return 'storage';
      case ApiKeyPermissionCategory.administration:
        return 'admin_panel_settings';
      case ApiKeyPermissionCategory.analytics:
        return 'analytics';
      case ApiKeyPermissionCategory.webhooks:
        return 'webhook';
    }
  }
}