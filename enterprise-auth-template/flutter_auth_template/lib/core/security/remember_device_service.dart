import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_auth_template/core/storage/secure_storage_service.dart';
import 'package:flutter_auth_template/core/security/device_fingerprint_service.dart';
import 'dart:convert';

// Remember Device Service Provider
final rememberDeviceServiceProvider = Provider<RememberDeviceService>((ref) {
  final secureStorage = ref.watch(secureStorageServiceProvider);
  final deviceFingerprint = ref.watch(deviceFingerprintServiceProvider);
  return RememberDeviceService(secureStorage, deviceFingerprint);
});

/// Service for managing "Remember Me" functionality on trusted devices
class RememberDeviceService {
  final SecureStorageService _secureStorage;
  final DeviceFingerprintService _deviceFingerprint;

  // Storage keys
  static const String _rememberedDeviceKey = 'remembered_device_info';
  static const String _rememberDurationKey = 'remember_device_duration';
  static const String _lastRememberedLoginKey = 'last_remembered_login';
  static const String _skipBiometricKey = 'skip_biometric_on_trusted';
  static const String _skipMFAKey = 'skip_mfa_on_trusted';

  // Configuration
  static const int defaultRememberDurationDays = 30;
  static const int maxRememberDurationDays = 90;
  static const int warningBeforeExpiryDays = 3;

  RememberDeviceService(this._secureStorage, this._deviceFingerprint);

  /// Check if current device is remembered
  Future<RememberedDeviceStatus> isDeviceRemembered(String userId) async {
    try {
      // First check if device is trusted
      final isTrusted = await _deviceFingerprint.isDeviceTrusted(userId);
      if (!isTrusted) {
        return RememberedDeviceStatus(
          isRemembered: false,
          reason: 'Device is not trusted',
        );
      }

      // Check if remember device is enabled
      final rememberedInfoStr = await _secureStorage.read(
        key: '$_rememberedDeviceKey:$userId',
      );

      if (rememberedInfoStr == null) {
        return RememberedDeviceStatus(
          isRemembered: false,
          reason: 'Device not remembered',
        );
      }

      final rememberedInfo = json.decode(rememberedInfoStr);
      final rememberedUntil = DateTime.parse(rememberedInfo['rememberedUntil']);
      final deviceFingerprint = rememberedInfo['deviceFingerprint'];

      // Verify device fingerprint matches
      final currentFingerprint = await _deviceFingerprint.getStoredFingerprint();
      if (currentFingerprint != deviceFingerprint) {
        return RememberedDeviceStatus(
          isRemembered: false,
          reason: 'Device fingerprint mismatch',
        );
      }

      // Check if remember period has expired
      final now = DateTime.now();
      if (now.isAfter(rememberedUntil)) {
        // Clean up expired remember data
        await forgetDevice(userId);
        return RememberedDeviceStatus(
          isRemembered: false,
          reason: 'Remember period expired',
          expiredAt: rememberedUntil,
        );
      }

      // Calculate days remaining
      final daysRemaining = rememberedUntil.difference(now).inDays;
      final needsReAuth = daysRemaining <= warningBeforeExpiryDays;

      return RememberedDeviceStatus(
        isRemembered: true,
        rememberedUntil: rememberedUntil,
        daysRemaining: daysRemaining,
        needsReAuthentication: needsReAuth,
        skipBiometric: rememberedInfo['skipBiometric'] ?? false,
        skipMFA: rememberedInfo['skipMFA'] ?? false,
      );
    } catch (e) {
      debugPrint('Error checking remembered device: $e');
      return RememberedDeviceStatus(
        isRemembered: false,
        reason: 'Error checking device status',
      );
    }
  }

  /// Remember current device for specified duration
  Future<bool> rememberDevice({
    required String userId,
    int? durationDays,
    bool skipBiometric = false,
    bool skipMFA = false,
  }) async {
    try {
      // Ensure device is trusted first
      final isTrusted = await _deviceFingerprint.isDeviceTrusted(userId);
      if (!isTrusted) {
        // Trust the device first
        final trustResult = await _deviceFingerprint.trustDevice(
          userId: userId,
          customName: 'Remembered Device',
        );
        final success = trustResult.when(
          success: (data, _) => true,
          error: (_, __, ___, ____) => false,
          loading: () => false,
        );
        if (!success) {
          return false;
        }
      }

      // Get current device fingerprint
      final fingerprint = await _deviceFingerprint.getStoredFingerprint();
      if (fingerprint == null) {
        return false;
      }

      // Calculate remember until date
      final duration = durationDays ?? defaultRememberDurationDays;
      final clampedDuration = duration.clamp(1, maxRememberDurationDays);
      final rememberedUntil = DateTime.now().add(
        Duration(days: clampedDuration),
      );

      // Store remember information
      final rememberedInfo = {
        'userId': userId,
        'deviceFingerprint': fingerprint,
        'rememberedAt': DateTime.now().toIso8601String(),
        'rememberedUntil': rememberedUntil.toIso8601String(),
        'skipBiometric': skipBiometric,
        'skipMFA': skipMFA,
        'durationDays': clampedDuration,
      };

      await _secureStorage.write(
        key: '$_rememberedDeviceKey:$userId',
        value: json.encode(rememberedInfo),
      );

      // Record last remembered login
      await _secureStorage.write(
        key: '$_lastRememberedLoginKey:$userId',
        value: DateTime.now().toIso8601String(),
      );

      return true;
    } catch (e) {
      debugPrint('Error remembering device: $e');
      return false;
    }
  }

  /// Forget current device
  Future<void> forgetDevice(String userId) async {
    try {
      await _secureStorage.delete(key: '$_rememberedDeviceKey:$userId');
      await _secureStorage.delete(key: '$_lastRememberedLoginKey:$userId');
      await _secureStorage.delete(key: '$_rememberDurationKey:$userId');
    } catch (e) {
      debugPrint('Error forgetting device: $e');
    }
  }

  /// Extend remember duration
  Future<bool> extendRememberDuration({
    required String userId,
    int additionalDays = 30,
  }) async {
    try {
      final status = await isDeviceRemembered(userId);
      if (!status.isRemembered) {
        return false;
      }

      // Get current remember info
      final rememberedInfoStr = await _secureStorage.read(
        key: '$_rememberedDeviceKey:$userId',
      );
      if (rememberedInfoStr == null) {
        return false;
      }

      final rememberedInfo = json.decode(rememberedInfoStr);
      final currentUntil = DateTime.parse(rememberedInfo['rememberedUntil']);
      
      // Calculate new expiry
      final newUntil = currentUntil.add(Duration(days: additionalDays));
      final maxAllowedUntil = DateTime.now().add(
        Duration(days: maxRememberDurationDays),
      );
      
      // Clamp to max duration
      final finalUntil = newUntil.isAfter(maxAllowedUntil) 
        ? maxAllowedUntil 
        : newUntil;

      // Update remember info
      rememberedInfo['rememberedUntil'] = finalUntil.toIso8601String();
      rememberedInfo['extendedAt'] = DateTime.now().toIso8601String();

      await _secureStorage.write(
        key: '$_rememberedDeviceKey:$userId',
        value: json.encode(rememberedInfo),
      );

      return true;
    } catch (e) {
      debugPrint('Error extending remember duration: $e');
      return false;
    }
  }

  /// Check if biometric should be skipped
  Future<bool> shouldSkipBiometric(String userId) async {
    final status = await isDeviceRemembered(userId);
    return status.isRemembered && (status.skipBiometric ?? false);
  }

  /// Check if MFA should be skipped
  Future<bool> shouldSkipMFA(String userId) async {
    final status = await isDeviceRemembered(userId);
    return status.isRemembered && (status.skipMFA ?? false);
  }

  /// Get last remembered login time
  Future<DateTime?> getLastRememberedLogin(String userId) async {
    try {
      final lastLoginStr = await _secureStorage.read(
        key: '$_lastRememberedLoginKey:$userId',
      );
      if (lastLoginStr != null) {
        return DateTime.parse(lastLoginStr);
      }
    } catch (e) {
      debugPrint('Error getting last remembered login: $e');
    }
    return null;
  }

  /// Clear all remembered devices for user
  Future<void> clearAllRememberedDevices(String userId) async {
    try {
      // Clear remember data
      await forgetDevice(userId);
      
      // Also clear trusted devices
      await _deviceFingerprint.clearTrustedDevices(userId);
    } catch (e) {
      debugPrint('Error clearing remembered devices: $e');
    }
  }

  /// Get remember preferences
  Future<RememberPreferences> getRememberPreferences(String userId) async {
    try {
      final rememberedInfoStr = await _secureStorage.read(
        key: '$_rememberedDeviceKey:$userId',
      );
      
      if (rememberedInfoStr != null) {
        final info = json.decode(rememberedInfoStr);
        return RememberPreferences(
          isEnabled: true,
          durationDays: info['durationDays'] ?? defaultRememberDurationDays,
          skipBiometric: info['skipBiometric'] ?? false,
          skipMFA: info['skipMFA'] ?? false,
        );
      }
    } catch (e) {
      debugPrint('Error getting remember preferences: $e');
    }
    
    return RememberPreferences(
      isEnabled: false,
      durationDays: defaultRememberDurationDays,
      skipBiometric: false,
      skipMFA: false,
    );
  }

  /// Update remember preferences
  Future<bool> updateRememberPreferences({
    required String userId,
    required RememberPreferences preferences,
  }) async {
    try {
      if (!preferences.isEnabled) {
        await forgetDevice(userId);
        return true;
      }

      return await rememberDevice(
        userId: userId,
        durationDays: preferences.durationDays,
        skipBiometric: preferences.skipBiometric,
        skipMFA: preferences.skipMFA,
      );
    } catch (e) {
      debugPrint('Error updating remember preferences: $e');
      return false;
    }
  }
}

/// Status of remembered device
class RememberedDeviceStatus {
  final bool isRemembered;
  final String? reason;
  final DateTime? rememberedUntil;
  final DateTime? expiredAt;
  final int? daysRemaining;
  final bool? needsReAuthentication;
  final bool? skipBiometric;
  final bool? skipMFA;

  const RememberedDeviceStatus({
    required this.isRemembered,
    this.reason,
    this.rememberedUntil,
    this.expiredAt,
    this.daysRemaining,
    this.needsReAuthentication,
    this.skipBiometric,
    this.skipMFA,
  });

  bool get isExpiringSoon => 
    daysRemaining != null && daysRemaining! <= RememberDeviceService.warningBeforeExpiryDays;
}

/// Remember device preferences
class RememberPreferences {
  final bool isEnabled;
  final int durationDays;
  final bool skipBiometric;
  final bool skipMFA;

  const RememberPreferences({
    required this.isEnabled,
    required this.durationDays,
    required this.skipBiometric,
    required this.skipMFA,
  });

  RememberPreferences copyWith({
    bool? isEnabled,
    int? durationDays,
    bool? skipBiometric,
    bool? skipMFA,
  }) {
    return RememberPreferences(
      isEnabled: isEnabled ?? this.isEnabled,
      durationDays: durationDays ?? this.durationDays,
      skipBiometric: skipBiometric ?? this.skipBiometric,
      skipMFA: skipMFA ?? this.skipMFA,
    );
  }
}