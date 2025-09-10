import 'package:freezed_annotation/freezed_annotation.dart';

part &apos;device_models.freezed.dart&apos;;
part &apos;device_models.g.dart&apos;;

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
    Map&lt;String, dynamic&gt;? metadata,
  }) = _Device;

  factory Device.fromJson(Map&lt;String, dynamic&gt; json) =&gt; _$DeviceFromJson(json);
}

@freezed
class DeviceRegistrationRequest with _$DeviceRegistrationRequest {
  const factory DeviceRegistrationRequest({
    required String deviceName,
    required String deviceType,
    required String platform,
    required String userAgent,
    String? deviceFingerprint,
    Map&lt;String, dynamic&gt;? metadata,
  }) = _DeviceRegistrationRequest;

  factory DeviceRegistrationRequest.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
      _$DeviceRegistrationRequestFromJson(json);
}

@freezed
class DeviceUpdateRequest with _$DeviceUpdateRequest {
  const factory DeviceUpdateRequest({
    String? deviceName,
    bool? isTrusted,
    Map&lt;String, dynamic&gt;? metadata,
  }) = _DeviceUpdateRequest;

  factory DeviceUpdateRequest.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
      _$DeviceUpdateRequestFromJson(json);
}

@freezed
class DeviceListResponse with _$DeviceListResponse {
  const factory DeviceListResponse({
    required List&lt;Device&gt; devices,
    required int total,
    required int page,
    required int limit,
    required bool hasNext,
    required bool hasPrevious,
  }) = _DeviceListResponse;

  factory DeviceListResponse.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
      _$DeviceListResponseFromJson(json);
}

@freezed
class DeviceStats with _$DeviceStats {
  const factory DeviceStats({
    required int totalDevices,
    required int activeDevices,
    required int trustedDevices,
    required int unknownDevices,
    required Map&lt;String, int&gt; devicesByPlatform,
    required Map&lt;String, int&gt; devicesByType,
    required List&lt;DeviceLocationStat&gt; topLocations,
  }) = _DeviceStats;

  factory DeviceStats.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
      _$DeviceStatsFromJson(json);
}

@freezed
class DeviceLocationStat with _$DeviceLocationStat {
  const factory DeviceLocationStat({
    required String location,
    required int count,
    required double percentage,
  }) = _DeviceLocationStat;

  factory DeviceLocationStat.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
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
    Map&lt;String, dynamic&gt;? metadata,
  }) = _DeviceSecurityAlert;

  factory DeviceSecurityAlert.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
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
        return &apos;Mobile&apos;;
      case DeviceType.desktop:
        return &apos;Desktop&apos;;
      case DeviceType.tablet:
        return &apos;Tablet&apos;;
      case DeviceType.browser:
        return &apos;Browser&apos;;
      case DeviceType.api:
        return &apos;API Client&apos;;
      case DeviceType.unknown:
        return &apos;Unknown&apos;;
    }
  }

  String get iconName {
    switch (this) {
      case DeviceType.mobile:
        return &apos;phone&apos;;
      case DeviceType.desktop:
        return &apos;computer&apos;;
      case DeviceType.tablet:
        return &apos;tablet&apos;;
      case DeviceType.browser:
        return &apos;web&apos;;
      case DeviceType.api:
        return &apos;code&apos;;
      case DeviceType.unknown:
        return &apos;device_unknown&apos;;
    }
  }
}

extension DevicePlatformExtension on DevicePlatform {
  String get displayName {
    switch (this) {
      case DevicePlatform.android:
        return &apos;Android&apos;;
      case DevicePlatform.ios:
        return &apos;iOS&apos;;
      case DevicePlatform.windows:
        return &apos;Windows&apos;;
      case DevicePlatform.macos:
        return &apos;macOS&apos;;
      case DevicePlatform.linux:
        return &apos;Linux&apos;;
      case DevicePlatform.web:
        return &apos;Web&apos;;
      case DevicePlatform.unknown:
        return &apos;Unknown&apos;;
    }
  }

  String get iconName {
    switch (this) {
      case DevicePlatform.android:
        return &apos;android&apos;;
      case DevicePlatform.ios:
        return &apos;apple&apos;;
      case DevicePlatform.windows:
        return &apos;windows&apos;;
      case DevicePlatform.macos:
        return &apos;apple&apos;;
      case DevicePlatform.linux:
        return &apos;linux&apos;;
      case DevicePlatform.web:
        return &apos;web&apos;;
      case DevicePlatform.unknown:
        return &apos;device_unknown&apos;;
    }
  }
}