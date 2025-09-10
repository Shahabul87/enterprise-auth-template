import 'dart:convert';
import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import '../errors/app_exception.dart';

final tokenManagerProvider = Provider<TokenManager>((ref) {
  return TokenManager();
});

class TokenManager {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_PKCS1Padding,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
      synchronizable: false,
    ),
    lOptions: LinuxOptions(),
    wOptions: WindowsOptions(),
    mOptions: MacOsOptions(),
  );

  // Token storage keys
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpiryKey = 'token_expiry';
  static const String _userDataKey = 'user_data';

  /// Store authentication tokens securely
  Future<void> storeTokens({
    required String accessToken,
    String? refreshToken,
    DateTime? expiryTime,
  }) async {
    try {
      await _storage.write(key: _accessTokenKey, value: accessToken);

      if (refreshToken != null) {
        await _storage.write(key: _refreshTokenKey, value: refreshToken);
      }

      if (expiryTime != null) {
        await _storage.write(
          key: _tokenExpiryKey,
          value: expiryTime.millisecondsSinceEpoch.toString(),
        );
      } else {
        // Default expiry time if not provided
        final defaultExpiry = DateTime.now().add(
          const Duration(minutes: ApiConstants.accessTokenExpiryMinutes),
        );
        await _storage.write(
          key: _tokenExpiryKey,
          value: defaultExpiry.millisecondsSinceEpoch.toString(),
        );
      }

      developer.log('Tokens stored successfully', name: 'TokenManager');
    } catch (e) {
      developer.log(
        'Failed to store tokens: $e',
        name: 'TokenManager',
        level: 1000,
      );
      throw const SecureStorageException();
    }
  }

  /// Get valid access token, refresh if necessary
  Future<String?> getValidAccessToken() async {
    try {
      final accessToken = await _storage.read(key: _accessTokenKey);

      if (accessToken == null) {
        developer.log('No access token found', name: 'TokenManager');
        return null;
      }

      // Check if token is expired
      if (await _isTokenExpired()) {
        developer.log(
          'Access token expired, attempting refresh',
          name: 'TokenManager',
        );
        return await refreshAccessToken();
      }

      return accessToken;
    } catch (e) {
      developer.log(
        'Failed to get access token: $e',
        name: 'TokenManager',
        level: 1000,
      );
      return null;
    }
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } catch (e) {
      developer.log(
        'Failed to get refresh token: $e',
        name: 'TokenManager',
        level: 1000,
      );
      return null;
    }
  }

  /// Refresh access token using refresh token
  Future<String?> refreshAccessToken() async {
    try {
      final refreshToken = await getRefreshToken();

      if (refreshToken == null) {
        developer.log('No refresh token available', name: 'TokenManager');
        await clearTokens();
        throw const TokenExpiredException();
      }

      // Import required dependencies for API call
      final Dio dio = Dio();

      // Call the refresh endpoint
      final response = await dio.post(
        '${ApiConstants.apiUrl}${ApiConstants.refreshPath}',
        options: Options(
          headers: {
            ApiConstants.authorizationHeader:
                '${ApiConstants.bearerPrefix}$refreshToken',
            ApiConstants.contentTypeHeader:
                ApiConstants.applicationJsonContentType,
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data as Map<String, dynamic>;

        if (responseData['success'] == true && responseData['data'] != null) {
          final data = responseData['data'] as Map<String, dynamic>;
          final newAccessToken = data['access_token'] as String?;
          final newRefreshToken = data['refresh_token'] as String?;

          if (newAccessToken != null) {
            // Store the new tokens
            await storeTokens(
              accessToken: newAccessToken,
              refreshToken:
                  newRefreshToken ??
                  refreshToken, // Use new refresh token if provided
            );

            developer.log('Token refresh successful', name: 'TokenManager');
            return newAccessToken;
          }
        }
      }

      // If we reach here, refresh failed
      developer.log(
        'Token refresh failed: Invalid response',
        name: 'TokenManager',
      );
      await clearTokens();
      throw const TokenExpiredException();
    } catch (e) {
      developer.log(
        'Token refresh failed: $e',
        name: 'TokenManager',
        level: 1000,
      );
      await clearTokens();
      if (e is AppException) {
        rethrow;
      }
      throw const TokenExpiredException();
    }
  }

  /// Check if the current access token is expired
  Future<bool> _isTokenExpired() async {
    try {
      final expiryString = await _storage.read(key: _tokenExpiryKey);

      if (expiryString == null) {
        return true; // Assume expired if no expiry time stored
      }

      final expiryTime = DateTime.fromMillisecondsSinceEpoch(
        int.parse(expiryString),
      );

      // Add a 5-minute buffer before actual expiry
      final bufferTime = DateTime.now().add(const Duration(minutes: 5));

      return bufferTime.isAfter(expiryTime);
    } catch (e) {
      developer.log(
        'Error checking token expiry: $e',
        name: 'TokenManager',
        level: 1000,
      );
      return true; // Assume expired on error
    }
  }

  /// Store user data
  Future<void> storeUserData(Map<String, dynamic> userData) async {
    try {
      final userDataJson = jsonEncode(userData);
      await _storage.write(key: _userDataKey, value: userDataJson);
      developer.log('User data stored successfully', name: 'TokenManager');
    } catch (e) {
      developer.log(
        'Failed to store user data: $e',
        name: 'TokenManager',
        level: 1000,
      );
      throw const SecureStorageException();
    }
  }

  /// Get stored user data
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final userDataJson = await _storage.read(key: _userDataKey);

      if (userDataJson == null) {
        return null;
      }

      return jsonDecode(userDataJson) as Map<String, dynamic>;
    } catch (e) {
      developer.log(
        'Failed to get user data: $e',
        name: 'TokenManager',
        level: 1000,
      );
      return null;
    }
  }

  /// Clear all stored tokens and user data
  Future<void> clearTokens() async {
    try {
      await Future.wait([
        _storage.delete(key: _accessTokenKey),
        _storage.delete(key: _refreshTokenKey),
        _storage.delete(key: _tokenExpiryKey),
        _storage.delete(key: _userDataKey),
      ]);

      developer.log('All tokens and user data cleared', name: 'TokenManager');
    } catch (e) {
      developer.log(
        'Failed to clear tokens: $e',
        name: 'TokenManager',
        level: 1000,
      );
      throw const SecureStorageException();
    }
  }

  /// Check if user is authenticated (has valid tokens)
  Future<bool> isAuthenticated() async {
    final accessToken = await getValidAccessToken();
    return accessToken != null;
  }

  /// Get token expiry time
  Future<DateTime?> getTokenExpiryTime() async {
    try {
      final expiryString = await _storage.read(key: _tokenExpiryKey);

      if (expiryString == null) {
        return null;
      }

      return DateTime.fromMillisecondsSinceEpoch(int.parse(expiryString));
    } catch (e) {
      developer.log(
        'Failed to get token expiry time: $e',
        name: 'TokenManager',
        level: 1000,
      );
      return null;
    }
  }

  /// Clear all secure storage (for debugging or complete reset)
  Future<void> clearAllStorage() async {
    try {
      await _storage.deleteAll();

      // Also clear shared preferences if needed
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      developer.log('All storage cleared', name: 'TokenManager');
    } catch (e) {
      developer.log(
        'Failed to clear all storage: $e',
        name: 'TokenManager',
        level: 1000,
      );
      throw const SecureStorageException();
    }
  }

  /// Check if secure storage is available
  Future<bool> isSecureStorageAvailable() async {
    try {
      // Try to write and read a test value
      const testKey = 'test_key';
      const testValue = 'test_value';

      await _storage.write(key: testKey, value: testValue);
      final readValue = await _storage.read(key: testKey);
      await _storage.delete(key: testKey);

      return readValue == testValue;
    } catch (e) {
      developer.log(
        'Secure storage not available: $e',
        name: 'TokenManager',
        level: 1000,
      );
      return false;
    }
  }
}
