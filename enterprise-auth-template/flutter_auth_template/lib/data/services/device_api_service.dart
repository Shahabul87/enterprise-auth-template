import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/errors/app_exception.dart';
import '../models/device_models.dart';

final deviceApiServiceProvider = Provider&lt;DeviceApiService&gt;((ref) {
  return DeviceApiService(ref.read(apiClientProvider));
});

class DeviceApiService {
  final ApiClient _apiClient;

  DeviceApiService(this._apiClient);

  /// Get all devices for current user
  Future&lt;DeviceListResponse&gt; getUserDevices({
    int page = 1,
    int limit = 20,
    bool? isActive,
    bool? isTrusted,
    String? platform,
    String? deviceType,
  }) async {
    try {
      final queryParams = &lt;String, dynamic&gt;{
        &apos;page&apos;: page,
        &apos;limit&apos;: limit,
      };

      if (isActive != null) queryParams[&apos;is_active&apos;] = isActive;
      if (isTrusted != null) queryParams[&apos;is_trusted&apos;] = isTrusted;
      if (platform != null) queryParams[&apos;platform&apos;] = platform;
      if (deviceType != null) queryParams[&apos;device_type&apos;] = deviceType;

      final response = await _apiClient.get&lt;Map&lt;String, dynamic&gt;&gt;(
        &apos;${ApiConstants.profileBasePath}/devices&apos;,
        queryParameters: queryParams,
      );

      if (response.data![&apos;success&apos;] == true) {
        return DeviceListResponse.fromJson(response.data![&apos;data&apos;]);
      }

      throw ServerException(
        response.data![&apos;error&apos;]?[&apos;message&apos;] ?? &apos;Failed to get devices&apos;,
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get device by ID
  Future&lt;Device&gt; getDevice(String deviceId) async {
    try {
      final response = await _apiClient.get&lt;Map&lt;String, dynamic&gt;&gt;(
        &apos;${ApiConstants.profileBasePath}/devices/$deviceId&apos;,
      );

      if (response.data![&apos;success&apos;] == true) {
        return Device.fromJson(response.data![&apos;data&apos;]);
      }

      throw ServerException(
        response.data![&apos;error&apos;]?[&apos;message&apos;] ?? &apos;Failed to get device&apos;,
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Register new device
  Future&lt;Device&gt; registerDevice(DeviceRegistrationRequest request) async {
    try {
      final response = await _apiClient.post&lt;Map&lt;String, dynamic&gt;&gt;(
        &apos;${ApiConstants.profileBasePath}/devices&apos;,
        data: request.toJson(),
      );

      if (response.data![&apos;success&apos;] == true) {
        return Device.fromJson(response.data![&apos;data&apos;]);
      }

      throw ServerException(
        response.data![&apos;error&apos;]?[&apos;message&apos;] ?? &apos;Failed to register device&apos;,
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Update device
  Future&lt;Device&gt; updateDevice(
    String deviceId,
    DeviceUpdateRequest request,
  ) async {
    try {
      final response = await _apiClient.put&lt;Map&lt;String, dynamic&gt;&gt;(
        &apos;${ApiConstants.profileBasePath}/devices/$deviceId&apos;,
        data: request.toJson(),
      );

      if (response.data![&apos;success&apos;] == true) {
        return Device.fromJson(response.data![&apos;data&apos;]);
      }

      throw ServerException(
        response.data![&apos;error&apos;]?[&apos;message&apos;] ?? &apos;Failed to update device&apos;,
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Delete device
  Future&lt;void&gt; deleteDevice(String deviceId) async {
    try {
      final response = await _apiClient.delete&lt;Map&lt;String, dynamic&gt;&gt;(
        &apos;${ApiConstants.profileBasePath}/devices/$deviceId&apos;,
      );

      if (response.data![&apos;success&apos;] != true) {
        throw ServerException(
          response.data![&apos;error&apos;]?[&apos;message&apos;] ?? &apos;Failed to delete device&apos;,
          null,
          response.statusCode ?? 500,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Trust device
  Future&lt;Device&gt; trustDevice(String deviceId) async {
    try {
      final response = await _apiClient.post&lt;Map&lt;String, dynamic&gt;&gt;(
        &apos;${ApiConstants.profileBasePath}/devices/$deviceId/trust&apos;,
      );

      if (response.data![&apos;success&apos;] == true) {
        return Device.fromJson(response.data![&apos;data&apos;]);
      }

      throw ServerException(
        response.data![&apos;error&apos;]?[&apos;message&apos;] ?? &apos;Failed to trust device&apos;,
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Untrust device
  Future&lt;Device&gt; untrustDevice(String deviceId) async {
    try {
      final response = await _apiClient.post&lt;Map&lt;String, dynamic&gt;&gt;(
        &apos;${ApiConstants.profileBasePath}/devices/$deviceId/untrust&apos;,
      );

      if (response.data![&apos;success&apos;] == true) {
        return Device.fromJson(response.data![&apos;data&apos;]);
      }

      throw ServerException(
        response.data![&apos;error&apos;]?[&apos;message&apos;] ?? &apos;Failed to untrust device&apos;,
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Block device
  Future&lt;Device&gt; blockDevice(String deviceId) async {
    try {
      final response = await _apiClient.post&lt;Map&lt;String, dynamic&gt;&gt;(
        &apos;${ApiConstants.profileBasePath}/devices/$deviceId/block&apos;,
      );

      if (response.data![&apos;success&apos;] == true) {
        return Device.fromJson(response.data![&apos;data&apos;]);
      }

      throw ServerException(
        response.data![&apos;error&apos;]?[&apos;message&apos;] ?? &apos;Failed to block device&apos;,
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Unblock device
  Future&lt;Device&gt; unblockDevice(String deviceId) async {
    try {
      final response = await _apiClient.post&lt;Map&lt;String, dynamic&gt;&gt;(
        &apos;${ApiConstants.profileBasePath}/devices/$deviceId/unblock&apos;,
      );

      if (response.data![&apos;success&apos;] == true) {
        return Device.fromJson(response.data![&apos;data&apos;]);
      }

      throw ServerException(
        response.data![&apos;error&apos;]?[&apos;message&apos;] ?? &apos;Failed to unblock device&apos;,
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get device statistics
  Future&lt;DeviceStats&gt; getDeviceStats() async {
    try {
      final response = await _apiClient.get&lt;Map&lt;String, dynamic&gt;&gt;(
        &apos;${ApiConstants.profileBasePath}/devices/stats&apos;,
      );

      if (response.data![&apos;success&apos;] == true) {
        return DeviceStats.fromJson(response.data![&apos;data&apos;]);
      }

      throw ServerException(
        response.data![&apos;error&apos;]?[&apos;message&apos;] ?? &apos;Failed to get device stats&apos;,
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get device security alerts
  Future&lt;List&lt;DeviceSecurityAlert&gt;&gt; getDeviceSecurityAlerts({
    String? deviceId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = &lt;String, dynamic&gt;{
        &apos;page&apos;: page,
        &apos;limit&apos;: limit,
      };

      if (deviceId != null) queryParams[&apos;device_id&apos;] = deviceId;

      final response = await _apiClient.get&lt;Map&lt;String, dynamic&gt;&gt;(
        &apos;${ApiConstants.profileBasePath}/devices/security-alerts&apos;,
        queryParameters: queryParams,
      );

      if (response.data![&apos;success&apos;] == true) {
        final alertList = response.data![&apos;data&apos;] as List;
        return alertList
            .map((alert) =&gt; DeviceSecurityAlert.fromJson(alert))
            .toList();
      }

      throw ServerException(
        response.data![&apos;error&apos;]?[&apos;message&apos;] ?? &apos;Failed to get security alerts&apos;,
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Resolve security alert
  Future&lt;void&gt; resolveSecurityAlert(String alertId) async {
    try {
      final response = await _apiClient.post&lt;Map&lt;String, dynamic&gt;&gt;(
        &apos;${ApiConstants.profileBasePath}/devices/security-alerts/$alertId/resolve&apos;,
      );

      if (response.data![&apos;success&apos;] != true) {
        throw ServerException(
          response.data![&apos;error&apos;]?[&apos;message&apos;] ?? &apos;Failed to resolve alert&apos;,
          null,
          response.statusCode ?? 500,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get current device info
  Future&lt;Device&gt; getCurrentDevice() async {
    try {
      final response = await _apiClient.get&lt;Map&lt;String, dynamic&gt;&gt;(
        &apos;${ApiConstants.profileBasePath}/devices/current&apos;,
      );

      if (response.data![&apos;success&apos;] == true) {
        return Device.fromJson(response.data![&apos;data&apos;]);
      }

      throw ServerException(
        response.data![&apos;error&apos;]?[&apos;message&apos;] ?? &apos;Failed to get current device&apos;,
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Update current device
  Future&lt;Device&gt; updateCurrentDevice(DeviceUpdateRequest request) async {
    try {
      final response = await _apiClient.put&lt;Map&lt;String, dynamic&gt;&gt;(
        &apos;${ApiConstants.profileBasePath}/devices/current&apos;,
        data: request.toJson(),
      );

      if (response.data![&apos;success&apos;] == true) {
        return Device.fromJson(response.data![&apos;data&apos;]);
      }

      throw ServerException(
        response.data![&apos;error&apos;]?[&apos;message&apos;] ?? &apos;Failed to update current device&apos;,
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  AppException _handleDioException(DioException exception) {
    if (exception.response?.data != null) {
      final data = exception.response!.data;
      final message = data[&apos;error&apos;]?[&apos;message&apos;] ?? &apos;Unknown error occurred&apos;;
      return ServerException(message, null, exception.response?.statusCode ?? 500);
    }

    return NetworkException(
      exception.message ?? &apos;Network error occurred&apos;,
      exception.requestOptions.path,
    );
  }
}