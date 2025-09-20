import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_auth_template/core/storage/secure_storage_service.dart';
import 'package:flutter_auth_template/core/network/api_response.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

// Device Fingerprinting Service Provider
final deviceFingerprintServiceProvider = Provider<DeviceFingerprintService>((ref) {
  final secureStorage = ref.watch(secureStorageServiceProvider);
  return DeviceFingerprintService(secureStorage);
});

/// Service for device fingerprinting and trusted device management
class DeviceFingerprintService {
  final SecureStorageService _secureStorage;
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  // Storage keys
  static const String _deviceIdKey = 'device_fingerprint_id';
  static const String _trustedDevicesKey = 'trusted_devices';
  static const String _lastVerifiedKey = 'last_device_verification';
  static const String _deviceNameKey = 'device_custom_name';

  // Configuration
  static const int maxTrustedDevices = 5;
  static const int deviceVerificationDays = 30;

  DeviceFingerprintService(this._secureStorage);

  /// Generate a unique device fingerprint
  Future<DeviceFingerprint> generateFingerprint() async {
    try {
      String deviceId = '';
      String deviceName = '';
      String deviceModel = '';
      String osVersion = '';
      String platform = '';
      Map<String, dynamic> additionalInfo = {};

      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        deviceId = androidInfo.id;
        deviceName = androidInfo.device;
        deviceModel = androidInfo.model;
        osVersion = androidInfo.version.release;
        platform = 'Android';
        additionalInfo = {
          'manufacturer': androidInfo.manufacturer,
          'brand': androidInfo.brand,
          'sdkInt': androidInfo.version.sdkInt,
          'fingerprint': androidInfo.fingerprint,
          'hardware': androidInfo.hardware,
        };
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? '';
        deviceName = iosInfo.name;
        deviceModel = iosInfo.model;
        osVersion = iosInfo.systemVersion;
        platform = 'iOS';
        additionalInfo = {
          'systemName': iosInfo.systemName,
          'utsname': {
            'machine': iosInfo.utsname.machine,
            'sysname': iosInfo.utsname.sysname,
            'version': iosInfo.utsname.version,
          },
          'isPhysicalDevice': iosInfo.isPhysicalDevice,
        };
      } else if (kIsWeb) {
        final webInfo = await _deviceInfo.webBrowserInfo;
        // For web, create a unique ID based on browser info
        final browserString = '${webInfo.userAgent}_${webInfo.vendor}_${webInfo.platform}';
        deviceId = _generateHashedId(browserString);
        deviceName = webInfo.browserName.name;
        deviceModel = 'Web Browser';
        osVersion = webInfo.platform ?? 'Unknown';
        platform = 'Web';
        additionalInfo = {
          'browserName': webInfo.browserName.name,
          'appName': webInfo.appName,
          'vendor': webInfo.vendor,
          'userAgent': webInfo.userAgent,
          'language': webInfo.language,
        };
      }

      // Generate a stable fingerprint hash
      final fingerprintHash = _generateFingerprintHash(
        deviceId: deviceId,
        deviceModel: deviceModel,
        platform: platform,
      );

      // Store device ID locally
      await _secureStorage.write(key: _deviceIdKey, value: fingerprintHash);

      return DeviceFingerprint(
        fingerprintId: fingerprintHash,
        deviceId: deviceId,
        deviceName: deviceName,
        deviceModel: deviceModel,
        osVersion: osVersion,
        platform: platform,
        additionalInfo: additionalInfo,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Error generating device fingerprint: $e');
      throw DeviceFingerprintException('Failed to generate device fingerprint', e);
    }
  }

  /// Generate a hashed ID for consistent fingerprinting
  String _generateHashedId(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Generate a stable fingerprint hash from device characteristics
  String _generateFingerprintHash({
    required String deviceId,
    required String deviceModel,
    required String platform,
  }) {
    final combinedData = '$deviceId|$deviceModel|$platform';
    return _generateHashedId(combinedData);
  }

  /// Get stored device fingerprint
  Future<String?> getStoredFingerprint() async {
    try {
      return await _secureStorage.read(key: _deviceIdKey);
    } catch (e) {
      debugPrint('Error reading stored fingerprint: $e');
      return null;
    }
  }

  /// Verify if current device matches stored fingerprint
  Future<bool> verifyDevice() async {
    try {
      final storedFingerprint = await getStoredFingerprint();
      if (storedFingerprint == null) return false;

      final currentFingerprint = await generateFingerprint();
      return currentFingerprint.fingerprintId == storedFingerprint;
    } catch (e) {
      debugPrint('Error verifying device: $e');
      return false;
    }
  }

  /// Check if device is trusted
  Future<bool> isDeviceTrusted(String userId) async {
    try {
      final trustedDevicesJson = await _secureStorage.read(
        key: '$_trustedDevicesKey:$userId',
      );
      
      if (trustedDevicesJson == null) return false;

      final List<dynamic> trustedDevices = json.decode(trustedDevicesJson);
      final currentFingerprint = await getStoredFingerprint();
      
      if (currentFingerprint == null) return false;

      return trustedDevices.any((device) => 
        device['fingerprintId'] == currentFingerprint &&
        _isDeviceStillValid(device['trustedAt'])
      );
    } catch (e) {
      debugPrint('Error checking trusted device: $e');
      return false;
    }
  }

  /// Check if device trust is still valid
  bool _isDeviceStillValid(String trustedAtString) {
    try {
      final trustedAt = DateTime.parse(trustedAtString);
      final daysSinceTrust = DateTime.now().difference(trustedAt).inDays;
      return daysSinceTrust <= deviceVerificationDays;
    } catch (e) {
      return false;
    }
  }

  /// Add current device to trusted devices
  Future<ApiResponse<bool>> trustDevice({
    required String userId,
    String? customName,
  }) async {
    try {
      final fingerprint = await generateFingerprint();
      
      // Get existing trusted devices
      final trustedDevicesJson = await _secureStorage.read(
        key: '$_trustedDevicesKey:$userId',
      );
      
      List<Map<String, dynamic>> trustedDevices = [];
      if (trustedDevicesJson != null) {
        final decoded = json.decode(trustedDevicesJson);
        trustedDevices = List<Map<String, dynamic>>.from(decoded);
      }

      // Remove expired devices
      trustedDevices.removeWhere((device) => 
        !_isDeviceStillValid(device['trustedAt'])
      );

      // Check if device already trusted
      final existingIndex = trustedDevices.indexWhere(
        (device) => device['fingerprintId'] == fingerprint.fingerprintId
      );

      if (existingIndex >= 0) {
        // Update existing device
        trustedDevices[existingIndex] = fingerprint.toTrustedDeviceJson(customName);
      } else {
        // Add new device
        if (trustedDevices.length >= maxTrustedDevices) {
          // Remove oldest device
          trustedDevices.sort((a, b) => 
            DateTime.parse(a['trustedAt']).compareTo(
              DateTime.parse(b['trustedAt'])
            )
          );
          trustedDevices.removeAt(0);
        }
        trustedDevices.add(fingerprint.toTrustedDeviceJson(customName));
      }

      // Save updated list
      await _secureStorage.write(
        key: '$_trustedDevicesKey:$userId',
        value: json.encode(trustedDevices),
      );

      // Store custom name if provided
      if (customName != null) {
        await _secureStorage.write(
          key: _deviceNameKey,
          value: customName,
        );
      }

      return const ApiResponse.success(data: true);
    } catch (e) {
      return ApiResponse.error(
        message: 'Failed to trust device: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Remove a device from trusted devices
  Future<ApiResponse<bool>> removeTrustedDevice({
    required String userId,
    required String fingerprintId,
  }) async {
    try {
      final trustedDevicesJson = await _secureStorage.read(
        key: '$_trustedDevicesKey:$userId',
      );
      
      if (trustedDevicesJson == null) {
        return const ApiResponse.success(data: true);
      }

      List<Map<String, dynamic>> trustedDevices = 
        List<Map<String, dynamic>>.from(json.decode(trustedDevicesJson));
      
      trustedDevices.removeWhere(
        (device) => device['fingerprintId'] == fingerprintId
      );

      await _secureStorage.write(
        key: '$_trustedDevicesKey:$userId',
        value: json.encode(trustedDevices),
      );

      return const ApiResponse.success(data: true);
    } catch (e) {
      return ApiResponse.error(
        message: 'Failed to remove trusted device: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Get list of trusted devices for a user
  Future<List<TrustedDevice>> getTrustedDevices(String userId) async {
    try {
      final trustedDevicesJson = await _secureStorage.read(
        key: '$_trustedDevicesKey:$userId',
      );
      
      if (trustedDevicesJson == null) return [];

      final List<dynamic> devices = json.decode(trustedDevicesJson);
      
      // Filter out expired devices and convert to TrustedDevice objects
      return devices
        .where((device) => _isDeviceStillValid(device['trustedAt']))
        .map((device) => TrustedDevice.fromJson(device))
        .toList();
    } catch (e) {
      debugPrint('Error getting trusted devices: $e');
      return [];
    }
  }

  /// Clear all trusted devices for a user
  Future<void> clearTrustedDevices(String userId) async {
    try {
      await _secureStorage.delete(key: '$_trustedDevicesKey:$userId');
    } catch (e) {
      debugPrint('Error clearing trusted devices: $e');
    }
  }

  /// Record device verification
  Future<void> recordDeviceVerification() async {
    try {
      await _secureStorage.write(
        key: _lastVerifiedKey,
        value: DateTime.now().toIso8601String(),
      );
    } catch (e) {
      debugPrint('Error recording device verification: $e');
    }
  }

  /// Get device custom name
  Future<String?> getDeviceCustomName() async {
    try {
      return await _secureStorage.read(key: _deviceNameKey);
    } catch (e) {
      return null;
    }
  }

  /// Check if device verification is needed
  Future<bool> needsDeviceVerification() async {
    try {
      final lastVerifiedStr = await _secureStorage.read(key: _lastVerifiedKey);
      if (lastVerifiedStr == null) return true;

      final lastVerified = DateTime.parse(lastVerifiedStr);
      final daysSinceVerification = DateTime.now().difference(lastVerified).inDays;
      
      return daysSinceVerification > deviceVerificationDays;
    } catch (e) {
      return true;
    }
  }
}

/// Device fingerprint data model
class DeviceFingerprint {
  final String fingerprintId;
  final String deviceId;
  final String deviceName;
  final String deviceModel;
  final String osVersion;
  final String platform;
  final Map<String, dynamic> additionalInfo;
  final DateTime createdAt;

  const DeviceFingerprint({
    required this.fingerprintId,
    required this.deviceId,
    required this.deviceName,
    required this.deviceModel,
    required this.osVersion,
    required this.platform,
    required this.additionalInfo,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'fingerprintId': fingerprintId,
    'deviceId': deviceId,
    'deviceName': deviceName,
    'deviceModel': deviceModel,
    'osVersion': osVersion,
    'platform': platform,
    'additionalInfo': additionalInfo,
    'createdAt': createdAt.toIso8601String(),
  };

  Map<String, dynamic> toTrustedDeviceJson(String? customName) => {
    'fingerprintId': fingerprintId,
    'deviceName': customName ?? deviceName,
    'deviceModel': deviceModel,
    'platform': platform,
    'osVersion': osVersion,
    'trustedAt': DateTime.now().toIso8601String(),
    'lastUsed': DateTime.now().toIso8601String(),
  };
}

/// Trusted device model
class TrustedDevice {
  final String fingerprintId;
  final String deviceName;
  final String deviceModel;
  final String platform;
  final String osVersion;
  final DateTime trustedAt;
  final DateTime lastUsed;

  const TrustedDevice({
    required this.fingerprintId,
    required this.deviceName,
    required this.deviceModel,
    required this.platform,
    required this.osVersion,
    required this.trustedAt,
    required this.lastUsed,
  });

  factory TrustedDevice.fromJson(Map<String, dynamic> json) => TrustedDevice(
    fingerprintId: json['fingerprintId'],
    deviceName: json['deviceName'],
    deviceModel: json['deviceModel'],
    platform: json['platform'],
    osVersion: json['osVersion'],
    trustedAt: DateTime.parse(json['trustedAt']),
    lastUsed: DateTime.parse(json['lastUsed']),
  );

  bool get isCurrentDevice => true; // Implement logic to check if this is current device

  int get daysUntilExpiry {
    final daysSinceTrust = DateTime.now().difference(trustedAt).inDays;
    return DeviceFingerprintService.deviceVerificationDays - daysSinceTrust;
  }
}

/// Device fingerprint exception
class DeviceFingerprintException implements Exception {
  final String message;
  final dynamic originalError;

  const DeviceFingerprintException(this.message, this.originalError);

  @override
  String toString() => 'DeviceFingerprintException: $message';
}