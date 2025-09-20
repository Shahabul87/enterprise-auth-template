import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_auth_template/domain/repositories/auth_repository.dart';
import 'package:flutter_auth_template/domain/entities/user.dart';
import 'package:flutter_auth_template/data/models/auth_request.dart';
import 'package:flutter_auth_template/data/models/auth_response.dart';
import 'package:flutter_auth_template/data/services/auth_service.dart';
import 'package:flutter_auth_template/core/security/token_manager.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.read(authServiceProvider),
    ref.read(tokenManagerProvider),
  );
});

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;
  final TokenManager _tokenManager;

  AuthRepositoryImpl(this._authService, this._tokenManager);

  @override
  Future<AuthResponseData> login(LoginRequest request) async {
    final result = await _authService.login(request);

    // Store tokens and user data
    await _tokenManager.storeTokens(
      accessToken: result.accessToken,
      refreshToken: result.refreshToken,
    );

    await _tokenManager.storeUserData(result.user.toJson());

    return result;
  }

  @override
  Future<AuthResponseData> register(RegisterRequest request) async {
    final result = await _authService.register(request);

    // Store tokens and user data
    await _tokenManager.storeTokens(
      accessToken: result.accessToken,
      refreshToken: result.refreshToken,
    );

    await _tokenManager.storeUserData(result.user.toJson());

    return result;
  }

  @override
  Future<AuthResponseData> refreshToken() async {
    final result = await _authService.refreshToken();

    // Update stored tokens
    await _tokenManager.storeTokens(
      accessToken: result.accessToken,
      refreshToken: result.refreshToken,
    );

    return result;
  }

  @override
  Future<void> logout() async {
    try {
      await _authService.logout();
    } finally {
      // Always clear local data, even if logout API call fails
      await _tokenManager.clearTokens();
    }
  }

  @override
  Future<void> forgotPassword(ForgotPasswordRequest request) async {
    return await _authService.forgotPassword(request);
  }

  @override
  Future<void> resetPassword(ResetPasswordRequest request) async {
    return await _authService.resetPassword(request);
  }

  @override
  Future<void> verifyEmail(String token) async {
    return await _authService.verifyEmail(token);
  }

  @override
  Future<void> resendEmailVerification() async {
    return await _authService.resendEmailVerification();
  }

  @override
  Future<User> getCurrentUser() async {
    final user = await _authService.getCurrentUser();

    // Update stored user data
    await _tokenManager.storeUserData(user.toJson());

    return user;
  }

  @override
  Future<User> updateCurrentUser(Map<String, dynamic> userData) async {
    final user = await _authService.updateCurrentUser(userData);

    // Update stored user data
    await _tokenManager.storeUserData(user.toJson());

    return user;
  }

  @override
  Future<List<String>> getUserPermissions() async {
    return await _authService.getUserPermissions();
  }

  @override
  Future<List<String>> getOAuthProviders() async {
    return await _authService.getOAuthProviders();
  }

  @override
  Future<String> getOAuthAuthorizationUrl(String provider) async {
    return await _authService.getOAuthAuthorizationUrl(provider);
  }

  @override
  Future<AuthResponseData> completeOAuthLogin(OAuthLoginRequest request) async {
    final result = await _authService.completeOAuthLogin(request);

    // Store tokens and user data
    await _tokenManager.storeTokens(
      accessToken: result.accessToken,
      refreshToken: result.refreshToken,
    );

    await _tokenManager.storeUserData(result.user.toJson());

    return result;
  }

  @override
  Future<void> requestMagicLink(MagicLinkRequest request) async {
    return await _authService.requestMagicLink(request);
  }

  @override
  Future<AuthResponseData> verifyMagicLink(String token) async {
    final result = await _authService.verifyMagicLink(token);

    // Store tokens and user data
    await _tokenManager.storeTokens(
      accessToken: result.accessToken,
      refreshToken: result.refreshToken,
    );

    await _tokenManager.storeUserData(result.user.toJson());

    return result;
  }

  @override
  Future<WebAuthnRegistrationResponse> beginWebAuthnRegistration({
    String? email,
  }) async {
    return await _authService.beginWebAuthnRegistration(email: email);
  }

  @override
  Future<void> completeWebAuthnRegistration(
    Map<String, dynamic> credential,
  ) async {
    return await _authService.completeWebAuthnRegistration(credential);
  }

  @override
  Future<WebAuthnAuthenticationResponse> beginWebAuthnAuthentication({
    String? email,
  }) async {
    return await _authService.beginWebAuthnAuthentication(email: email);
  }

  @override
  Future<AuthResponseData> completeWebAuthnAuthentication(
    Map<String, dynamic> credential,
  ) async {
    final result = await _authService.completeWebAuthnAuthentication(
      credential,
    );

    // Store tokens and user data
    await _tokenManager.storeTokens(
      accessToken: result.accessToken,
      refreshToken: result.refreshToken,
    );

    await _tokenManager.storeUserData(result.user.toJson());

    return result;
  }

  @override
  Future<Map<String, dynamic>> getTwoFactorStatus() async {
    return await _authService.getTwoFactorStatus();
  }

  @override
  Future<TwoFactorSetupResponse> setupTwoFactor() async {
    return await _authService.setupTwoFactor();
  }

  @override
  Future<List<String>> enableTwoFactor(VerifyTwoFactorRequest request) async {
    return await _authService.enableTwoFactor(request);
  }

  @override
  Future<AuthResponseData> verifyTwoFactor(
    VerifyTwoFactorRequest request,
  ) async {
    final result = await _authService.verifyTwoFactor(request);

    // Store tokens and user data (2FA verification completes login)
    await _tokenManager.storeTokens(
      accessToken: result.accessToken,
      refreshToken: result.refreshToken,
    );

    await _tokenManager.storeUserData(result.user.toJson());

    return result;
  }

  @override
  Future<void> disableTwoFactor() async {
    return await _authService.disableTwoFactor();
  }

  @override
  Future<List<String>> regenerateBackupCodes() async {
    return await _authService.regenerateBackupCodes();
  }

  // Local State Management Methods

  @override
  Future<bool> isAuthenticated() async {
    return await _tokenManager.isAuthenticated();
  }

  @override
  Future<String?> getStoredAccessToken() async {
    return await _tokenManager.getValidAccessToken();
  }

  @override
  Future<User?> getStoredUser() async {
    final userData = await _tokenManager.getUserData();
    if (userData == null) return null;

    try {
      return User.fromJson(userData);
    } catch (e) {
      // If user data is corrupted, clear it
      await _tokenManager.clearTokens();
      return null;
    }
  }

  @override
  Future<void> clearAuthData() async {
    await _tokenManager.clearTokens();
  }
}
