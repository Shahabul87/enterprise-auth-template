import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/errors/app_exception.dart';
import '../models/auth_request.dart';
import '../models/auth_response.dart';
import '../../domain/entities/user.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.read(apiClientProvider));
});

class AuthService {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  /// Register a new user with email and password
  Future<AuthResponseData> register(RegisterRequest request) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.registerPath,
        data: request.toJson(),
      );

      final authResponse = AuthResponse.fromJson(response.data!);

      if (!authResponse.success || authResponse.data == null) {
        throw _handleAuthError(authResponse.error);
      }

      return authResponse.data!;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Login with email and password
  Future<AuthResponseData> login(LoginRequest request) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.loginPath,
        data: request.toJson(),
      );

      final authResponse = AuthResponse.fromJson(response.data!);

      if (!authResponse.success || authResponse.data == null) {
        throw _handleAuthError(authResponse.error);
      }

      return authResponse.data!;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Refresh access token
  Future<AuthResponseData> refreshToken() async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.refreshPath,
      );

      final authResponse = AuthResponse.fromJson(response.data!);

      if (!authResponse.success || authResponse.data == null) {
        throw const TokenExpiredException();
      }

      return authResponse.data!;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const TokenExpiredException();
      }
      throw _handleDioException(e);
    }
  }

  /// Logout current user
  Future<void> logout() async {
    try {
      await _apiClient.post(ApiConstants.logoutPath);
    } on DioException catch (e) {
      // Ignore logout errors, clear local state anyway
      throw _handleDioException(e);
    }
  }

  /// Send forgot password email
  Future<void> forgotPassword(ForgotPasswordRequest request) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.forgotPasswordPath,
        data: request.toJson(),
      );

      final authResponse = AuthResponse.fromJson(response.data!);

      if (!authResponse.success) {
        throw _handleAuthError(authResponse.error);
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Reset password with token
  Future<void> resetPassword(ResetPasswordRequest request) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.resetPasswordPath,
        data: request.toJson(),
      );

      final authResponse = AuthResponse.fromJson(response.data!);

      if (!authResponse.success) {
        throw _handleAuthError(authResponse.error);
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Verify email with token
  Future<void> verifyEmail(String token) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.verifyEmailPath.replaceAll('{token}', token),
      );

      final authResponse = AuthResponse.fromJson(response.data!);

      if (!authResponse.success) {
        throw _handleAuthError(authResponse.error);
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Resend email verification
  Future<void> resendEmailVerification() async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.resendVerificationPath,
      );

      final authResponse = AuthResponse.fromJson(response.data!);

      if (!authResponse.success) {
        throw _handleAuthError(authResponse.error);
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get current user permissions
  Future<List<String>> getUserPermissions() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.permissionsPath,
      );

      final authResponse = AuthResponse.fromJson(response.data!);

      if (!authResponse.success || authResponse.data == null) {
        throw _handleAuthError(authResponse.error);
      }

      // Extract permissions from response
      final permissions =
          (response.data!['data']['permissions'] as List<dynamic>)
              .cast<String>();
      return permissions;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get current user profile
  Future<User> getCurrentUser() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.userMePath,
      );

      final authResponse = AuthResponse.fromJson(response.data!);

      if (!authResponse.success || authResponse.data == null) {
        throw _handleAuthError(authResponse.error);
      }

      return authResponse.data!.user;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Update current user profile
  Future<User> updateCurrentUser(Map<String, dynamic> userData) async {
    try {
      final response = await _apiClient.put<Map<String, dynamic>>(
        ApiConstants.userMePath,
        data: userData,
      );

      final authResponse = AuthResponse.fromJson(response.data!);

      if (!authResponse.success || authResponse.data == null) {
        throw _handleAuthError(authResponse.error);
      }

      return authResponse.data!.user;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// OAuth2 Methods

  /// Get supported OAuth providers
  Future<List<String>> getOAuthProviders() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.oauthProvidersPath,
      );

      final providers = (response.data!['providers'] as List<dynamic>)
          .cast<String>();
      return providers;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get OAuth authorization URL
  Future<String> getOAuthAuthorizationUrl(String provider) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.oauthInitPath.replaceAll('{provider}', provider),
      );

      return response.data!['authorization_url'] as String;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Complete OAuth login with authorization code
  Future<AuthResponseData> completeOAuthLogin(OAuthLoginRequest request) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.oauthCallbackPath.replaceAll(
          '{provider}',
          request.provider,
        ),
        data: request.toJson(),
      );

      final authResponse = AuthResponse.fromJson(response.data!);

      if (!authResponse.success || authResponse.data == null) {
        throw _handleAuthError(authResponse.error);
      }

      return authResponse.data!;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Magic Links Methods

  /// Request magic link
  Future<void> requestMagicLink(MagicLinkRequest request) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.magicLinkRequestPath,
        data: request.toJson(),
      );

      final authResponse = AuthResponse.fromJson(response.data!);

      if (!authResponse.success) {
        throw _handleAuthError(authResponse.error);
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Verify magic link token
  Future<AuthResponseData> verifyMagicLink(String token) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.magicLinkVerifyPath.replaceAll('{token}', token),
      );

      final authResponse = AuthResponse.fromJson(response.data!);

      if (!authResponse.success || authResponse.data == null) {
        throw _handleAuthError(authResponse.error);
      }

      return authResponse.data!;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// WebAuthn Methods

  /// Begin WebAuthn registration
  Future<WebAuthnRegistrationResponse> beginWebAuthnRegistration({
    String? email,
  }) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.webauthnRegisterBeginPath,
        data: email != null ? {'email': email} : null,
      );

      return WebAuthnRegistrationResponse.fromJson(response.data!);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Complete WebAuthn registration
  Future<void> completeWebAuthnRegistration(
    Map<String, dynamic> credential,
  ) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.webauthnRegisterCompletePath,
        data: credential,
      );

      final authResponse = AuthResponse.fromJson(response.data!);

      if (!authResponse.success) {
        throw _handleAuthError(authResponse.error);
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Begin WebAuthn authentication
  Future<WebAuthnAuthenticationResponse> beginWebAuthnAuthentication({
    String? email,
  }) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.webauthnAuthenticateBeginPath,
        data: email != null ? {'email': email} : null,
      );

      return WebAuthnAuthenticationResponse.fromJson(response.data!);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Complete WebAuthn authentication
  Future<AuthResponseData> completeWebAuthnAuthentication(
    Map<String, dynamic> credential,
  ) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.webauthnAuthenticateCompletePath,
        data: credential,
      );

      final authResponse = AuthResponse.fromJson(response.data!);

      if (!authResponse.success || authResponse.data == null) {
        throw _handleAuthError(authResponse.error);
      }

      return authResponse.data!;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Two-Factor Authentication Methods

  /// Get 2FA status
  Future<Map<String, dynamic>> getTwoFactorStatus() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.twoFactorStatusPath,
      );

      return response.data!;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Setup 2FA (get QR code and secret)
  Future<TwoFactorSetupResponse> setupTwoFactor() async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.twoFactorSetupPath,
      );

      return TwoFactorSetupResponse.fromJson(response.data!);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Enable 2FA with verification code
  Future<List<String>> enableTwoFactor(VerifyTwoFactorRequest request) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.twoFactorEnablePath,
        data: request.toJson(),
      );

      final backupCodes = (response.data!['backup_codes'] as List<dynamic>)
          .cast<String>();
      return backupCodes;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Verify 2FA code
  Future<AuthResponseData> verifyTwoFactor(
    VerifyTwoFactorRequest request,
  ) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.twoFactorVerifyPath,
        data: request.toJson(),
      );

      final authResponse = AuthResponse.fromJson(response.data!);

      if (!authResponse.success || authResponse.data == null) {
        throw _handleAuthError(authResponse.error);
      }

      return authResponse.data!;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Disable 2FA
  Future<void> disableTwoFactor() async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.twoFactorDisablePath,
      );

      final authResponse = AuthResponse.fromJson(response.data!);

      if (!authResponse.success) {
        throw _handleAuthError(authResponse.error);
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Regenerate 2FA backup codes
  Future<List<String>> regenerateBackupCodes() async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.twoFactorBackupCodesPath,
      );

      final backupCodes = (response.data!['backup_codes'] as List<dynamic>)
          .cast<String>();
      return backupCodes;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Private helper methods

  AppException _handleAuthError(AuthResponseError? error) {
    if (error == null) {
      return const UnknownException('Authentication failed', null);
    }

    switch (error.code) {
      case ApiErrors.invalidCredentials:
        return const InvalidCredentialsException();
      case ApiErrors.emailNotVerified:
        return const EmailNotVerifiedException();
      case ApiErrors.twoFactorRequired:
        return const TwoFactorRequiredException();
      case ApiErrors.accountLocked:
        return const AccountLockedException();
      case ApiErrors.emailAlreadyExists:
        return const EmailAlreadyExistsException();
      case ApiErrors.tokenExpired:
        return const TokenExpiredException();
      case ApiErrors.invalidToken:
        return const InvalidTokenException();
      default:
        return UnknownException(error.message, null);
    }
  }

  AppException _handleDioException(DioException exception) {
    // The error interceptor should have already handled this,
    // but provide fallback handling
    if (exception.error is AppException) {
      return exception.error as AppException;
    }

    return NetworkException(
      exception.message ?? 'Network error occurred',
      exception.requestOptions.path,
    );
  }
}
