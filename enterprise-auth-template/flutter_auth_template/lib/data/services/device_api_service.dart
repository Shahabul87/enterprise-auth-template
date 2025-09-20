import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_auth_template/core/constants/api_constants.dart';
import 'package:flutter_auth_template/core/network/api_client.dart';
import 'package:flutter_auth_template/core/errors/app_exception.dart';
import 'package:flutter_auth_template/data/models/device_models.dart';

final deviceApiServiceProvider = Provider<DeviceApiService>((ref) {
  return DeviceApiService(ref.read(apiClientProvider));
});

class DeviceApiService {
  final ApiClient _apiClient;

  DeviceApiService(this._apiClient);

  /// Get all devices for current user
  Future<DeviceListResponse> getUserDevices({
    int page = 1,
    int limit = 20,
    bool? isActive,
    bool? isTrusted,
    String? platform,
    String? deviceType,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (isActive != null) queryParams['is_active'] = isActive;
      if (isTrusted != null) queryParams['is_trusted'] = isTrusted;
      if (platform != null) queryParams['platform'] = platform;
      if (deviceType != null) queryParams['device_type'] = deviceType;

      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.profileBasePath}/devices',
        queryParameters: queryParams,
      );

      if (response.data!['success'] == true) {
        return DeviceListResponse.fromJson(response.data!['data']);
      }

      throw ServerException(
        response.data!['error']?['message'] ?? 'Failed to get devices',
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get device by ID
  Future<Device> getDevice(String deviceId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.profileBasePath}/devices/$deviceId',
      );

      if (response.data!['success'] == true) {
        return Device.fromJson(response.data!['data']);
      }

      throw ServerException(
        response.data!['error']?['message'] ?? 'Failed to get device',
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Register new device
  Future<Device> registerDevice(DeviceRegistrationRequest request) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '${ApiConstants.profileBasePath}/devices',
        data: request.toJson(),
      );

      if (response.data!['success'] == true) {
        return Device.fromJson(response.data!['data']);
      }

      throw ServerException(
        response.data!['error']?['message'] ?? 'Failed to register device',
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Update device
  Future<Device> updateDevice(
    String deviceId,
    DeviceUpdateRequest request,
  ) async {
    try {
      final response = await _apiClient.put<Map<String, dynamic>>(
        '${ApiConstants.profileBasePath}/devices/$deviceId',
        data: request.toJson(),
      );

      if (response.data!['success'] == true) {
        return Device.fromJson(response.data!['data']);
      }

      throw ServerException(
        response.data!['error']?['message'] ?? 'Failed to update device',
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Delete device
  Future<void> deleteDevice(String deviceId) async {
    try {
      final response = await _apiClient.delete<Map<String, dynamic>>(
        '${ApiConstants.profileBasePath}/devices/$deviceId',
      );

      if (response.data!['success'] != true) {
        throw ServerException(
          response.data!['error']?['message'] ?? 'Failed to delete device',
          null,
          response.statusCode ?? 500,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Trust device
  Future<Device> trustDevice(String deviceId) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '${ApiConstants.profileBasePath}/devices/$deviceId/trust',
      );

      if (response.data!['success'] == true) {
        return Device.fromJson(response.data!['data']);
      }

      throw ServerException(
        response.data!['error']?['message'] ?? 'Failed to trust device',
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Untrust device
  Future<Device> untrustDevice(String deviceId) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '${ApiConstants.profileBasePath}/devices/$deviceId/untrust',
      );

      if (response.data!['success'] == true) {
        return Device.fromJson(response.data!['data']);
      }

      throw ServerException(
        response.data!['error']?['message'] ?? 'Failed to untrust device',
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Block device
  Future<Device> blockDevice(String deviceId) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '${ApiConstants.profileBasePath}/devices/$deviceId/block',
      );

      if (response.data!['success'] == true) {
        return Device.fromJson(response.data!['data']);
      }

      throw ServerException(
        response.data!['error']?['message'] ?? 'Failed to block device',
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Unblock device
  Future<Device> unblockDevice(String deviceId) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '${ApiConstants.profileBasePath}/devices/$deviceId/unblock',
      );

      if (response.data!['success'] == true) {
        return Device.fromJson(response.data!['data']);
      }

      throw ServerException(
        response.data!['error']?['message'] ?? 'Failed to unblock device',
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get device statistics
  Future<DeviceStats> getDeviceStats() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.profileBasePath}/devices/stats',
      );

      if (response.data!['success'] == true) {
        return DeviceStats.fromJson(response.data!['data']);
      }

      throw ServerException(
        response.data!['error']?['message'] ?? 'Failed to get device stats',
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get device security alerts
  Future<List<DeviceSecurityAlert>> getDeviceSecurityAlerts({
    String? deviceId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (deviceId != null) queryParams['device_id'] = deviceId;

      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.profileBasePath}/devices/security-alerts',
        queryParameters: queryParams,
      );

      if (response.data!['success'] == true) {
        final alertList = response.data!['data'] as List;
        return alertList
            .map((alert) => DeviceSecurityAlert.fromJson(alert))
            .toList();
      }

      throw ServerException(
        response.data!['error']?['message'] ?? 'Failed to get security alerts',
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Resolve security alert
  Future<void> resolveSecurityAlert(String alertId) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '${ApiConstants.profileBasePath}/devices/security-alerts/$alertId/resolve',
      );

      if (response.data!['success'] != true) {
        throw ServerException(
          response.data!['error']?['message'] ?? 'Failed to resolve alert',
          null,
          response.statusCode ?? 500,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get current device info
  Future<Device> getCurrentDevice() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.profileBasePath}/devices/current',
      );

      if (response.data!['success'] == true) {
        return Device.fromJson(response.data!['data']);
      }

      throw ServerException(
        response.data!['error']?['message'] ?? 'Failed to get current device',
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Update current device
  Future<Device> updateCurrentDevice(DeviceUpdateRequest request) async {
    try {
      final response = await _apiClient.put<Map<String, dynamic>>(
        '${ApiConstants.profileBasePath}/devices/current',
        data: request.toJson(),
      );

      if (response.data!['success'] == true) {
        return Device.fromJson(response.data!['data']);
      }

      throw ServerException(
        response.data!['error']?['message'] ?? 'Failed to update current device',
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
      final message = data['error']?['message'] ?? 'Unknown error occurred';
      return ServerException(message, null, exception.response?.statusCode ?? 500);
    }

    return NetworkException(
      exception.message ?? 'Network error occurred',
      exception.requestOptions.path,
    );
  }
}