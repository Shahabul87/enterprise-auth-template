import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_auth_template/core/constants/api_constants.dart';
import 'package:flutter_auth_template/core/errors/app_exception.dart';
import 'package:flutter_auth_template/core/network/api_response.dart';
import 'package:flutter_auth_template/core/storage/secure_storage_service.dart';
import 'package:flutter_auth_template/data/models/auth_response.dart';
import 'package:flutter_auth_template/domain/entities/user.dart';
import 'api/api_client.dart';

// WebAuthn Service Provider
final webAuthnServiceProvider = Provider<WebAuthnService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final secureStorage = ref.watch(secureStorageServiceProvider);
  return WebAuthnService(apiClient, secureStorage);
});

/// WebAuthn service for handling passkey authentication
class WebAuthnService {
  final ApiClient _apiClient;
  final SecureStorageService _secureStorage;

  WebAuthnService(this._apiClient, this._secureStorage);

  /// Start WebAuthn registration process
  Future<ApiResponse<WebAuthnRegistrationOptions>> startRegistration() async {
    try {
      final response = await _apiClient.post(ApiConstants.webauthnRegisterStartPath);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['success'] == true) {
          final options = WebAuthnRegistrationOptions.fromJson(data['data']);
          return ApiResponse.success(data: options);
        }
      }

      return ApiResponse.error(
        message: 'Failed to start WebAuthn registration',
      );
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error(
        message: 'WebAuthn registration start failed: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Complete WebAuthn registration
  Future<ApiResponse<String>> completeRegistration({
    required String credentialId,
    required String response,
    required String clientDataJSON,
    required String attestationObject,
    String? deviceName,
  }) async {
    try {
      final requestData = {
        'credential_id': credentialId,
        'response': response,
        'client_data_json': clientDataJSON,
        'attestation_object': attestationObject,
        if (deviceName != null) 'device_name': deviceName,
      };

      final apiResponse = await _apiClient.post(
        ApiConstants.webauthnRegisterCompletePath,
        data: requestData,
      );

      if (apiResponse.statusCode == 200) {
        final data = apiResponse.data;
        if (data is Map<String, dynamic> && data['success'] == true) {
          final message = data['data']?['message'] as String? ?? 'WebAuthn registration completed';
          return ApiResponse.success(data: message);
        }
      }

      return ApiResponse.error(
        message: 'Failed to complete WebAuthn registration',
      );
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error(
        message: 'WebAuthn registration completion failed: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Start WebAuthn authentication process
  Future<ApiResponse<WebAuthnAuthenticationOptions>> startAuthentication({
    String? email,
  }) async {
    try {
      final requestData = <String, dynamic>{};
      if (email != null) {
        requestData['email'] = email;
      }

      final response = await _apiClient.post(
        ApiConstants.webauthnAuthStartPath,
        data: requestData,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['success'] == true) {
          final options = WebAuthnAuthenticationOptions.fromJson(data['data']);
          return ApiResponse.success(data: options);
        }
      }

      return ApiResponse.error(
        message: 'Failed to start WebAuthn authentication',
      );
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error(
        message: 'WebAuthn authentication start failed: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Complete WebAuthn authentication
  Future<ApiResponse<User>> completeAuthentication({
    required String credentialId,
    required String response,
    required String clientDataJSON,
    required String authenticatorData,
    required String signature,
    required String userHandle,
  }) async {
    try {
      final requestData = {
        'credential_id': credentialId,
        'response': response,
        'client_data_json': clientDataJSON,
        'authenticator_data': authenticatorData,
        'signature': signature,
        'user_handle': userHandle,
      };

      final apiResponse = await _apiClient.post(
        ApiConstants.webauthnAuthCompletePath,
        data: requestData,
      );

      return _handleAuthResponse(apiResponse);
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error(
        message: 'WebAuthn authentication completion failed: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Get user's registered WebAuthn credentials
  Future<ApiResponse<List<WebAuthnCredential>>> getUserCredentials() async {
    try {
      final response = await _apiClient.get(ApiConstants.webauthnCredentialsPath);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['success'] == true) {
          final credentialsData = data['data'] as List?;
          if (credentialsData != null) {
            final credentials = credentialsData
                .cast<Map<String, dynamic>>()
                .map((credData) => WebAuthnCredential.fromJson(credData))
                .toList();
            return ApiResponse.success(data: credentials);
          }
        }
      }

      return ApiResponse.error(
        message: 'Failed to get WebAuthn credentials',
      );
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error(
        message: 'Get WebAuthn credentials failed: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Delete a WebAuthn credential
  Future<ApiResponse<String>> deleteCredential(String credentialId) async {
    try {
      final response = await _apiClient.delete(
        ApiConstants.webauthnCredentialsPath.replaceAll('{id}', credentialId),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['success'] == true) {
          final message = data['data']?['message'] as String? ?? 'Credential deleted';
          return ApiResponse.success(data: message);
        }
      }

      return ApiResponse.error(
        message: 'Failed to delete WebAuthn credential',
      );
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error(
        message: 'Delete WebAuthn credential failed: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Update WebAuthn credential name
  Future<ApiResponse<String>> updateCredentialName({
    required String credentialId,
    required String name,
  }) async {
    try {
      final response = await _apiClient.patch(
        ApiConstants.webauthnCredentialsPath.replaceAll('{id}', credentialId),
        data: {'name': name},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['success'] == true) {
          final message = data['data']?['message'] as String? ?? 'Credential updated';
          return ApiResponse.success(data: message);
        }
      }

      return ApiResponse.error(
        message: 'Failed to update WebAuthn credential',
      );
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error(
        message: 'Update WebAuthn credential failed: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Check if WebAuthn is supported on this platform
  bool isWebAuthnSupported() {
    // WebAuthn is primarily supported on web platforms
    // For mobile, we would need platform-specific implementations
    if (kIsWeb) {
      return true;
    }

    // For mobile platforms, WebAuthn support would require native implementations
    // This is a placeholder for future native WebAuthn support
    return false;
  }

  /// Handle authentication response and store tokens
  ApiResponse<User> _handleAuthResponse(Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        final success = responseData['success'] as bool? ?? false;

        if (success) {
          final data = responseData['data'] as Map<String, dynamic>?;
          if (data != null) {
            try {
              // Extract user and tokens
              final user = User.fromJson(data['user'] as Map<String, dynamic>);
              final accessToken = data['access_token'] as String?;
              final refreshToken = data['refresh_token'] as String?;

              // Store tokens asynchronously
              if (accessToken != null) {
                _secureStorage.storeAccessToken(accessToken);
              }
              if (refreshToken != null) {
                _secureStorage.storeRefreshToken(refreshToken);
              }

              return ApiResponse.success(data: user);
            } catch (e) {
              return ApiResponse.error(
                message: 'Invalid response format',
                originalError: e,
              );
            }
          }
        }

        final error = responseData['error'] as Map<String, dynamic>?;
        final message = error?['message'] as String? ?? 'Request failed';
        return ApiResponse.error(message: message);
      }
    }

    return ApiResponse.error(
      message: 'Request failed with status: ${response.statusCode}',
    );
  }

  /// Handle Dio errors
  ApiResponse<T> _handleDioError<T>(DioException e) {
    if (e.error is AppException) {
      final appError = e.error as AppException;
      return ApiResponse.error(
        message: appError.message,
        code: appError.toString(),
        originalError: e,
      );
    }
    return ApiResponse.error(
      message: e.message ?? 'Request failed',
      originalError: e,
    );
  }
}

/// WebAuthn registration options
class WebAuthnRegistrationOptions {
  final String challenge;
  final Map<String, dynamic> rp;
  final Map<String, dynamic> user;
  final List<Map<String, dynamic>> pubKeyCredParams;
  final int timeout;
  final List<Map<String, dynamic>>? excludeCredentials;
  final Map<String, dynamic>? authenticatorSelection;
  final String? attestation;

  WebAuthnRegistrationOptions({
    required this.challenge,
    required this.rp,
    required this.user,
    required this.pubKeyCredParams,
    required this.timeout,
    this.excludeCredentials,
    this.authenticatorSelection,
    this.attestation,
  });

  factory WebAuthnRegistrationOptions.fromJson(Map<String, dynamic> json) {
    return WebAuthnRegistrationOptions(
      challenge: json['challenge'] as String,
      rp: json['rp'] as Map<String, dynamic>,
      user: json['user'] as Map<String, dynamic>,
      pubKeyCredParams: (json['pubKeyCredParams'] as List)
          .cast<Map<String, dynamic>>(),
      timeout: json['timeout'] as int,
      excludeCredentials: json['excludeCredentials'] != null
          ? (json['excludeCredentials'] as List).cast<Map<String, dynamic>>()
          : null,
      authenticatorSelection: json['authenticatorSelection'] as Map<String, dynamic>?,
      attestation: json['attestation'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'challenge': challenge,
      'rp': rp,
      'user': user,
      'pubKeyCredParams': pubKeyCredParams,
      'timeout': timeout,
      if (excludeCredentials != null) 'excludeCredentials': excludeCredentials,
      if (authenticatorSelection != null) 'authenticatorSelection': authenticatorSelection,
      if (attestation != null) 'attestation': attestation,
    };
  }
}

/// WebAuthn authentication options
class WebAuthnAuthenticationOptions {
  final String challenge;
  final int timeout;
  final String? rpId;
  final List<Map<String, dynamic>>? allowCredentials;
  final String? userVerification;

  WebAuthnAuthenticationOptions({
    required this.challenge,
    required this.timeout,
    this.rpId,
    this.allowCredentials,
    this.userVerification,
  });

  factory WebAuthnAuthenticationOptions.fromJson(Map<String, dynamic> json) {
    return WebAuthnAuthenticationOptions(
      challenge: json['challenge'] as String,
      timeout: json['timeout'] as int,
      rpId: json['rpId'] as String?,
      allowCredentials: json['allowCredentials'] != null
          ? (json['allowCredentials'] as List).cast<Map<String, dynamic>>()
          : null,
      userVerification: json['userVerification'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'challenge': challenge,
      'timeout': timeout,
      if (rpId != null) 'rpId': rpId,
      if (allowCredentials != null) 'allowCredentials': allowCredentials,
      if (userVerification != null) 'userVerification': userVerification,
    };
  }
}

/// WebAuthn credential
class WebAuthnCredential {
  final String id;
  final String name;
  final String createdAt;
  final String? lastUsed;
  final bool isActive;

  WebAuthnCredential({
    required this.id,
    required this.name,
    required this.createdAt,
    this.lastUsed,
    required this.isActive,
  });

  factory WebAuthnCredential.fromJson(Map<String, dynamic> json) {
    return WebAuthnCredential(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: json['created_at'] as String,
      lastUsed: json['last_used'] as String?,
      isActive: json['is_active'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt,
      if (lastUsed != null) 'last_used': lastUsed,
      'is_active': isActive,
    };
  }
}