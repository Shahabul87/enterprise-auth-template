import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_auth_template/core/security/encryption_key_manager.dart';

// Secure Storage Service Provider
final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  final keyManager = ref.watch(encryptionKeyManagerProvider);
  return SecureStorageService(keyManager);
});

/// Service for securely storing sensitive data
class SecureStorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  final EncryptionKeyManager _keyManager;

  // Keys for common storage items
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _deviceIdKey = 'device_id';
  static const String _fcmTokenKey = 'fcm_token';
  static const String _lastLoginKey = 'last_login';
  static const String _twoFactorSecretKey = 'two_factor_secret';
  static const String _encryptedPrefix = 'enc_';

  SecureStorageService(this._keyManager);

  /// Initialize the service and key manager
  Future<void> initialize() async {
    await _keyManager.initialize();
  }

  /// Store access token with encryption and key rotation support
  Future<void> storeAccessToken(String token) async {
    // Encrypt the token with current key
    final encrypted = await _keyManager.encrypt(token);

    // Store encrypted data with metadata
    await _storage.write(
      key: '$_encryptedPrefix$_accessTokenKey',
      value: jsonEncode(encrypted.toJson()),
    );
  }

  /// Get access token with decryption support for rotated keys
  Future<String?> getAccessToken() async {
    // Try to read encrypted token first
    final encryptedJson = await _storage.read(key: '$_encryptedPrefix$_accessTokenKey');
    if (encryptedJson != null) {
      try {
        final encrypted = EncryptedData.fromJson(jsonDecode(encryptedJson));
        return await _keyManager.decrypt(encrypted);
      } catch (e) {
        // If decryption fails, try legacy unencrypted token
        print('Failed to decrypt token, trying legacy: $e');
      }
    }

    // Fallback to legacy unencrypted token
    final legacyToken = await _storage.read(key: _accessTokenKey);
    if (legacyToken != null) {
      // Migrate to encrypted storage
      await storeAccessToken(legacyToken);
      // Remove legacy token
      await _storage.delete(key: _accessTokenKey);
      return legacyToken;
    }

    return null;
  }

  /// Get token (alias for getAccessToken, used by WebSocket service)
  Future<String?> getToken() async {
    return await getAccessToken();
  }

  /// Remove access token
  Future<void> removeAccessToken() async {
    await _storage.delete(key: '$_encryptedPrefix$_accessTokenKey');
    // Also remove legacy token if exists
    await _storage.delete(key: _accessTokenKey);
  }

  /// Store refresh token with encryption and key rotation support
  Future<void> storeRefreshToken(String token) async {
    // Encrypt the refresh token with current key
    final encrypted = await _keyManager.encrypt(token);

    // Store encrypted data with metadata
    await _storage.write(
      key: '$_encryptedPrefix$_refreshTokenKey',
      value: jsonEncode(encrypted.toJson()),
    );
  }

  /// Get refresh token with decryption support for rotated keys
  Future<String?> getRefreshToken() async {
    // Try to read encrypted token first
    final encryptedJson = await _storage.read(key: '$_encryptedPrefix$_refreshTokenKey');
    if (encryptedJson != null) {
      try {
        final encrypted = EncryptedData.fromJson(jsonDecode(encryptedJson));
        return await _keyManager.decrypt(encrypted);
      } catch (e) {
        // If decryption fails, try legacy unencrypted token
        print('Failed to decrypt refresh token, trying legacy: $e');
      }
    }

    // Fallback to legacy unencrypted token
    final legacyToken = await _storage.read(key: _refreshTokenKey);
    if (legacyToken != null) {
      // Migrate to encrypted storage
      await storeRefreshToken(legacyToken);
      // Remove legacy token
      await _storage.delete(key: _refreshTokenKey);
      return legacyToken;
    }

    return null;
  }

  /// Remove refresh token
  Future<void> removeRefreshToken() async {
    await _storage.delete(key: '$_encryptedPrefix$_refreshTokenKey');
    // Also remove legacy token if exists
    await _storage.delete(key: _refreshTokenKey);
  }

  /// Delete refresh token (alias for removeRefreshToken)
  Future<void> deleteRefreshToken() async {
    await removeRefreshToken();
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

  /// Store biometric enabled preference (alias)
  Future<void> storeBiometricEnabled(bool enabled) async {
    await setBiometricEnabled(enabled);
  }

  /// Check if biometric is enabled (alias)
  Future<bool> isBiometricEnabled() async {
    return await getBiometricEnabled();
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

  /// Store two-factor secret with encryption
  Future<void> storeTwoFactorSecret(String secret) async {
    // Encrypt the 2FA secret with current key
    final encrypted = await _keyManager.encrypt(secret);

    // Store encrypted data with metadata
    await _storage.write(
      key: '$_encryptedPrefix$_twoFactorSecretKey',
      value: jsonEncode(encrypted.toJson()),
    );
  }

  /// Get two-factor secret with decryption
  Future<String?> getTwoFactorSecret() async {
    // Try to read encrypted secret first
    final encryptedJson = await _storage.read(key: '$_encryptedPrefix$_twoFactorSecretKey');
    if (encryptedJson != null) {
      try {
        final encrypted = EncryptedData.fromJson(jsonDecode(encryptedJson));
        return await _keyManager.decrypt(encrypted);
      } catch (e) {
        // If decryption fails, try legacy unencrypted secret
        print('Failed to decrypt 2FA secret, trying legacy: $e');
      }
    }

    // Fallback to legacy unencrypted secret
    final legacySecret = await _storage.read(key: _twoFactorSecretKey);
    if (legacySecret != null) {
      // Migrate to encrypted storage
      await storeTwoFactorSecret(legacySecret);
      // Remove legacy secret
      await _storage.delete(key: _twoFactorSecretKey);
      return legacySecret;
    }

    return null;
  }

  /// Remove two-factor secret
  Future<void> removeTwoFactorSecret() async {
    await _storage.delete(key: '$_encryptedPrefix$_twoFactorSecretKey');
    // Also remove legacy secret if exists
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

  /// Check if key rotation is needed
  Future<bool> isKeyRotationNeeded() async {
    return await _keyManager.isRotationNeeded();
  }

  /// Perform key rotation for all stored tokens
  Future<void> rotateEncryptionKeys() async {
    // Get current tokens before rotation
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();
    final twoFactorSecret = await getTwoFactorSecret();

    // Rotate the key
    await _keyManager.rotateKey();

    // Re-encrypt tokens with new key
    if (accessToken != null) {
      await storeAccessToken(accessToken);
    }
    if (refreshToken != null) {
      await storeRefreshToken(refreshToken);
    }
    if (twoFactorSecret != null) {
      await storeTwoFactorSecret(twoFactorSecret);
    }
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
