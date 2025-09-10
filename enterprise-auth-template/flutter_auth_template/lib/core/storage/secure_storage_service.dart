import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Secure Storage Service Provider
final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

/// Service for securely storing sensitive data
class SecureStorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Keys for common storage items
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _deviceIdKey = 'device_id';
  static const String _fcmTokenKey = 'fcm_token';
  static const String _lastLoginKey = 'last_login';
  static const String _twoFactorSecretKey = 'two_factor_secret';

  /// Store access token
  Future<void> storeAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  /// Remove access token
  Future<void> removeAccessToken() async {
    await _storage.delete(key: _accessTokenKey);
  }

  /// Store refresh token
  Future<void> storeRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /// Remove refresh token
  Future<void> removeRefreshToken() async {
    await _storage.delete(key: _refreshTokenKey);
  }

  /// Store user data as JSON
  Future<void> storeUserData(Map<String, dynamic> userData) async {
    final jsonString = jsonEncode(userData);
    await _storage.write(key: _userDataKey, value: jsonString);
  }

  /// Get user data
  Future<Map<String, dynamic>?> getUserData() async {
    final jsonString = await _storage.read(key: _userDataKey);
    if (jsonString != null) {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    }
    return null;
  }

  /// Remove user data
  Future<void> removeUserData() async {
    await _storage.delete(key: _userDataKey);
  }

  /// Store biometric enabled preference
  Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(key: _biometricEnabledKey, value: enabled.toString());
  }

  /// Get biometric enabled preference
  Future<bool> getBiometricEnabled() async {
    final value = await _storage.read(key: _biometricEnabledKey);
    return value == 'true';
  }

  /// Store device ID
  Future<void> storeDeviceId(String deviceId) async {
    await _storage.write(key: _deviceIdKey, value: deviceId);
  }

  /// Get device ID
  Future<String?> getDeviceId() async {
    return await _storage.read(key: _deviceIdKey);
  }

  /// Store FCM token
  Future<void> storeFcmToken(String token) async {
    await _storage.write(key: _fcmTokenKey, value: token);
  }

  /// Get FCM token
  Future<String?> getFcmToken() async {
    return await _storage.read(key: _fcmTokenKey);
  }

  /// Store last login timestamp
  Future<void> storeLastLogin(DateTime timestamp) async {
    await _storage.write(
      key: _lastLoginKey,
      value: timestamp.toIso8601String(),
    );
  }

  /// Get last login timestamp
  Future<DateTime?> getLastLogin() async {
    final value = await _storage.read(key: _lastLoginKey);
    if (value != null) {
      return DateTime.parse(value);
    }
    return null;
  }

  /// Store two-factor secret
  Future<void> storeTwoFactorSecret(String secret) async {
    await _storage.write(key: _twoFactorSecretKey, value: secret);
  }

  /// Get two-factor secret
  Future<String?> getTwoFactorSecret() async {
    return await _storage.read(key: _twoFactorSecretKey);
  }

  /// Remove two-factor secret
  Future<void> removeTwoFactorSecret() async {
    await _storage.delete(key: _twoFactorSecretKey);
  }

  /// Store custom key-value pair
  Future<void> store(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  /// Get custom key value
  Future<String?> get(String key) async {
    return await _storage.read(key: key);
  }

  /// Remove custom key
  Future<void> remove(String key) async {
    await _storage.delete(key: key);
  }

  /// Write key-value pair (alias for store, used by CSRF)
  Future<void> write({required String key, required String value}) async {
    await _storage.write(key: key, value: value);
  }

  /// Read value by key (alias for get, used by CSRF)
  Future<String?> read({required String key}) async {
    return await _storage.read(key: key);
  }

  /// Delete key (alias for remove, used by CSRF)
  Future<void> delete({required String key}) async {
    await _storage.delete(key: key);
  }

  /// Clear all stored data (logout)
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  /// Check if key exists
  Future<bool> containsKey(String key) async {
    return await _storage.containsKey(key: key);
  }

  /// Get all keys
  Future<Map<String, String>> getAllItems() async {
    return await _storage.readAll();
  }

  /// Store encrypted JSON data
  Future<void> storeJsonData(String key, Map<String, dynamic> data) async {
    final jsonString = jsonEncode(data);
    await _storage.write(key: key, value: jsonString);
  }

  /// Get encrypted JSON data
  Future<Map<String, dynamic>?> getJsonData(String key) async {
    final jsonString = await _storage.read(key: key);
    if (jsonString != null) {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    }
    return null;
  }

  /// Save user profile
  Future<void> saveUserProfile(dynamic profile) async {
    if (profile != null) {
      final profileJson = profile.toJson();
      await storeJsonData('user_profile', profileJson);
    }
  }

  /// Get user profile
  Future<dynamic> getUserProfile() async {
    final profileJson = await getJsonData('user_profile');
    if (profileJson != null) {
      // Import UserProfile dynamically to avoid circular dependency
      // The actual UserProfile conversion should be done in the provider
      return profileJson;
    }
    return null;
  }
}
