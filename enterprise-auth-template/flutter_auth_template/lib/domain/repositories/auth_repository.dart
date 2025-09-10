import '../entities/user.dart';
import '../../data/models/auth_request.dart';
import '../../data/models/auth_response.dart';

abstract class AuthRepository {
  // Basic Authentication
  Future<AuthResponseData> login(LoginRequest request);
  Future<AuthResponseData> register(RegisterRequest request);
  Future<AuthResponseData> refreshToken();
  Future<void> logout();

  // Password Management
  Future<void> forgotPassword(ForgotPasswordRequest request);
  Future<void> resetPassword(ResetPasswordRequest request);

  // Email Verification
  Future<void> verifyEmail(String token);
  Future<void> resendEmailVerification();

  // User Management
  Future<User> getCurrentUser();
  Future<User> updateCurrentUser(Map<String, dynamic> userData);
  Future<List<String>> getUserPermissions();

  // OAuth2
  Future<List<String>> getOAuthProviders();
  Future<String> getOAuthAuthorizationUrl(String provider);
  Future<AuthResponseData> completeOAuthLogin(OAuthLoginRequest request);

  // Magic Links
  Future<void> requestMagicLink(MagicLinkRequest request);
  Future<AuthResponseData> verifyMagicLink(String token);

  // WebAuthn
  Future<WebAuthnRegistrationResponse> beginWebAuthnRegistration({
    String? email,
  });
  Future<void> completeWebAuthnRegistration(Map<String, dynamic> credential);
  Future<WebAuthnAuthenticationResponse> beginWebAuthnAuthentication({
    String? email,
  });
  Future<AuthResponseData> completeWebAuthnAuthentication(
    Map<String, dynamic> credential,
  );

  // Two-Factor Authentication
  Future<Map<String, dynamic>> getTwoFactorStatus();
  Future<TwoFactorSetupResponse> setupTwoFactor();
  Future<List<String>> enableTwoFactor(VerifyTwoFactorRequest request);
  Future<AuthResponseData> verifyTwoFactor(VerifyTwoFactorRequest request);
  Future<void> disableTwoFactor();
  Future<List<String>> regenerateBackupCodes();

  // Local State Management
  Future<bool> isAuthenticated();
  Future<String?> getStoredAccessToken();
  Future<User?> getStoredUser();
  Future<void> clearAuthData();
}
