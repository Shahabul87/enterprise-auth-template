import 'package:freezed_annotation/freezed_annotation.dart';

part 'device_models.freezed.dart';
part 'device_models.g.dart';

@freezed
class Device with _$Device {
  const factory Device({
    required String id,
    required String userId,
    required String deviceName,
    required String deviceType,
    required String platform,
    required String userAgent,
    required String ipAddress,
    String? location,
    String? browser,
    String? browserVersion,
    String? os,
    String? osVersion,
    required bool isActive,
    required bool isTrusted,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? lastSeenAt,
    String? deviceFingerprint,
    Map<String, dynamic>? metadata,
  }) = _Device;

  factory Device.fromJson(Map<String, dynamic> json) => _$DeviceFromJson(json);
}

@freezed
class DeviceRegistrationRequest with _$DeviceRegistrationRequest {
  const factory DeviceRegistrationRequest({
    required String deviceName,
    required String deviceType,
    required String platform,
    required String userAgent,
    String? deviceFingerprint,
    Map<String, dynamic>? metadata,
  }) = _DeviceRegistrationRequest;

  factory DeviceRegistrationRequest.fromJson(Map<String, dynamic> json) =>
      _$DeviceRegistrationRequestFromJson(json);
}

@freezed
class DeviceUpdateRequest with _$DeviceUpdateRequest {
  const factory DeviceUpdateRequest({
    String? deviceName,
    bool? isTrusted,
    Map<String, dynamic>? metadata,
  }) = _DeviceUpdateRequest;

  factory DeviceUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$DeviceUpdateRequestFromJson(json);
}

@freezed
class DeviceListResponse with _$DeviceListResponse {
  const factory DeviceListResponse({
    required List<Device> devices,
    required int total,
    required int page,
    required int limit,
    required bool hasNext,
    required bool hasPrevious,
  }) = _DeviceListResponse;

  factory DeviceListResponse.fromJson(Map<String, dynamic> json) =>
      _$DeviceListResponseFromJson(json);
}

@freezed
class DeviceStats with _$DeviceStats {
  const factory DeviceStats({
    required int totalDevices,
    required int activeDevices,
    required int trustedDevices,
    required int unknownDevices,
    required Map<String, int> devicesByPlatform,
    required Map<String, int> devicesByType,
    required List<DeviceLocationStat> topLocations,
  }) = _DeviceStats;

  factory DeviceStats.fromJson(Map<String, dynamic> json) =>
      _$DeviceStatsFromJson(json);
}

@freezed
class DeviceLocationStat with _$DeviceLocationStat {
  const factory DeviceLocationStat({
    required String location,
    required int count,
    required double percentage,
  }) = _DeviceLocationStat;

  factory DeviceLocationStat.fromJson(Map<String, dynamic> json) =>
      _$DeviceLocationStatFromJson(json);
}

@freezed
class DeviceSecurityAlert with _$DeviceSecurityAlert {
  const factory DeviceSecurityAlert({
    required String id,
    required String deviceId,
    required String alertType,
    required String severity,
    required String message,
    required DateTime createdAt,
    required bool isResolved,
    DateTime? resolvedAt,
    Map<String, dynamic>? metadata,
  }) = _DeviceSecurityAlert;

  factory DeviceSecurityAlert.fromJson(Map<String, dynamic> json) =>
      _$DeviceSecurityAlertFromJson(json);
}

enum DeviceType {
  mobile,
  desktop,
  tablet,
  browser,
  api,
  unknown,
}

enum DevicePlatform {
  android,
  ios,
  windows,
  macos,
  linux,
  web,
  unknown,
}

enum DeviceStatus {
  active,
  inactive,
  blocked,
  unknown,
}

extension DeviceTypeExtension on DeviceType {
  String get displayName {
    switch (this) {
      case DeviceType.mobile:
        return 'Mobile';
      case DeviceType.desktop:
        return 'Desktop';
      case DeviceType.tablet:
        return 'Tablet';
      case DeviceType.browser:
        return 'Browser';
      case DeviceType.api:
        return 'API Client';
      case DeviceType.unknown:
        return 'Unknown';
    }
  }

  String get iconName {
    switch (this) {
      case DeviceType.mobile:
        return 'phone';
      case DeviceType.desktop:
        return 'computer';
      case DeviceType.tablet:
        return 'tablet';
      case DeviceType.browser:
        return 'web';
      case DeviceType.api:
        return 'code';
      case DeviceType.unknown:
        return 'device_unknown';
    }
  }
}

extension DevicePlatformExtension on DevicePlatform {
  String get displayName {
    switch (this) {
      case DevicePlatform.android:
        return 'Android';
      case DevicePlatform.ios:
        return 'iOS';
      case DevicePlatform.windows:
        return 'Windows';
      case DevicePlatform.macos:
        return 'macOS';
      case DevicePlatform.linux:
        return 'Linux';
      case DevicePlatform.web:
        return 'Web';
      case DevicePlatform.unknown:
        return 'Unknown';
    }
  }

  String get iconName {
    switch (this) {
      case DevicePlatform.android:
        return 'android';
      case DevicePlatform.ios:
        return 'apple';
      case DevicePlatform.windows:
        return 'windows';
      case DevicePlatform.macos:
        return 'apple';
      case DevicePlatform.linux:
        return 'linux';
      case DevicePlatform.web:
        return 'web';
      case DevicePlatform.unknown:
        return 'device_unknown';
    }
  }
}