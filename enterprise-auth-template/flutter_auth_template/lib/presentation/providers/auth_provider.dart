import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/auth_state.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/models/auth_request.dart';
import '../../data/models/auth_response.dart';
import '../../core/errors/app_exception.dart';

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider));
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository)
    : super(const AuthState.unauthenticated()) {
    _initializeAuthState();
  }

  /// Initialize authentication state on app start
  Future<void> _initializeAuthState() async {
    try {
      state = const AuthState.authenticating();

      final isAuthenticated = await _authRepository.isAuthenticated();

      if (isAuthenticated) {
        final user = await _authRepository.getStoredUser();
        final accessToken = await _authRepository.getStoredAccessToken();

        if (user != null && accessToken != null) {
          state = AuthState.authenticated(user: user, accessToken: accessToken);
          developer.log(
            'User authenticated from storage',
            name: 'AuthProvider',
          );
        } else {
          await _authRepository.clearAuthData();
          state = const AuthState.unauthenticated();
        }
      } else {
        state = const AuthState.unauthenticated();
      }
    } catch (e) {
      developer.log(
        'Auth initialization failed: $e',
        name: 'AuthProvider',
        level: 1000,
      );
      await _authRepository.clearAuthData();
      state = const AuthState.unauthenticated();
    }
  }

  /// Login with email and password
  Future<void> login(String email, String password) async {
    try {
      state = const AuthState.authenticating();

      final request = LoginRequest(email: email, password: password);
      final result = await _authRepository.login(request);

      state = AuthState.authenticated(
        user: result.user,
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );

      developer.log('Login successful for: $email', name: 'AuthProvider');
    } on TwoFactorRequiredException catch (e) {
      // Two-factor authentication required
      state = AuthState.error(e.message);
      developer.log('2FA required for: $email', name: 'AuthProvider');
      rethrow; // Let UI handle 2FA flow
    } catch (e) {
      final errorMessage = e is AppException ? e.message : 'Login failed';
      state = AuthState.error(errorMessage);
      developer.log('Login failed: $e', name: 'AuthProvider', level: 1000);
      rethrow;
    }
  }

  /// Register new user
  Future<void> register(String email, String password, String name) async {
    try {
      state = const AuthState.authenticating();

      final request = RegisterRequest(
        email: email,
        password: password,
        name: name,
      );
      final result = await _authRepository.register(request);

      state = AuthState.authenticated(
        user: result.user,
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );

      developer.log(
        'Registration successful for: $email',
        name: 'AuthProvider',
      );
    } catch (e) {
      final errorMessage = e is AppException
          ? e.message
          : 'Registration failed';
      state = AuthState.error(errorMessage);
      developer.log(
        'Registration failed: $e',
        name: 'AuthProvider',
        level: 1000,
      );
      rethrow;
    }
  }

  /// Logout current user
  Future<void> logout() async {
    try {
      state = const AuthState.authenticating();

      await _authRepository.logout();
      state = const AuthState.unauthenticated();

      developer.log('Logout successful', name: 'AuthProvider');
    } catch (e) {
      // Even if logout API fails, clear local state
      state = const AuthState.unauthenticated();
      developer.log('Logout completed (with error): $e', name: 'AuthProvider');
    }
  }

  /// Request password reset (alias for forgotPassword)
  Future<void> requestPasswordReset(String email) async {
    return forgotPassword(email);
  }

  /// Forgot password
  Future<void> forgotPassword(String email) async {
    try {
      final request = ForgotPasswordRequest(email: email);
      await _authRepository.forgotPassword(request);
      developer.log(
        'Password reset email sent to: $email',
        name: 'AuthProvider',
      );
    } catch (e) {
      developer.log(
        'Forgot password failed: $e',
        name: 'AuthProvider',
        level: 1000,
      );
      rethrow;
    }
  }

  /// Reset password
  Future<void> resetPassword(String token, String password) async {
    try {
      final request = ResetPasswordRequest(token: token, password: password);
      await _authRepository.resetPassword(request);
      developer.log('Password reset successful', name: 'AuthProvider');
    } catch (e) {
      developer.log(
        'Password reset failed: $e',
        name: 'AuthProvider',
        level: 1000,
      );
      rethrow;
    }
  }

  /// Verify email
  Future<void> verifyEmail(String token) async {
    try {
      await _authRepository.verifyEmail(token);

      // Refresh user data to get updated verification status
      if (state is Authenticated) {
        await refreshUser();
      }

      developer.log('Email verification successful', name: 'AuthProvider');
    } catch (e) {
      developer.log(
        'Email verification failed: $e',
        name: 'AuthProvider',
        level: 1000,
      );
      rethrow;
    }
  }

  /// Resend email verification
  Future<void> resendEmailVerification() async {
    try {
      await _authRepository.resendEmailVerification();
      developer.log('Email verification resent', name: 'AuthProvider');
    } catch (e) {
      developer.log(
        'Resend email verification failed: $e',
        name: 'AuthProvider',
        level: 1000,
      );
      rethrow;
    }
  }

  /// OAuth2 Authentication

  /// Get OAuth authorization URL
  Future<String> getOAuthUrl(String provider) async {
    try {
      return await _authRepository.getOAuthAuthorizationUrl(provider);
    } catch (e) {
      developer.log(
        'Get OAuth URL failed: $e',
        name: 'AuthProvider',
        level: 1000,
      );
      rethrow;
    }
  }

  /// Complete OAuth login
  Future<void> completeOAuthLogin(
    String provider,
    String code, {
    String? state,
  }) async {
    try {
      this.state = const AuthState.authenticating();

      final request = OAuthLoginRequest(
        provider: provider,
        code: code,
        state: state,
      );
      final result = await _authRepository.completeOAuthLogin(request);

      this.state = AuthState.authenticated(
        user: result.user,
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );

      developer.log(
        'OAuth login successful with: $provider',
        name: 'AuthProvider',
      );
    } catch (e) {
      final errorMessage = e is AppException ? e.message : 'OAuth login failed';
      this.state = AuthState.error(errorMessage);
      developer.log(
        'OAuth login failed: $e',
        name: 'AuthProvider',
        level: 1000,
      );
      rethrow;
    }
  }

  /// Magic Links Authentication

  /// Request magic link
  Future<void> requestMagicLink(String email) async {
    try {
      final request = MagicLinkRequest(email: email);
      await _authRepository.requestMagicLink(request);
      developer.log('Magic link sent to: $email', name: 'AuthProvider');
    } catch (e) {
      developer.log(
        'Magic link request failed: $e',
        name: 'AuthProvider',
        level: 1000,
      );
      rethrow;
    }
  }

  /// Verify magic link
  Future<void> verifyMagicLink(String token) async {
    try {
      state = const AuthState.authenticating();

      final result = await _authRepository.verifyMagicLink(token);

      state = AuthState.authenticated(
        user: result.user,
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );

      developer.log('Magic link verification successful', name: 'AuthProvider');
    } catch (e) {
      final errorMessage = e is AppException
          ? e.message
          : 'Magic link verification failed';
      state = AuthState.error(errorMessage);
      developer.log(
        'Magic link verification failed: $e',
        name: 'AuthProvider',
        level: 1000,
      );
      rethrow;
    }
  }

  /// WebAuthn Authentication

  /// Begin WebAuthn registration
  Future<WebAuthnRegistrationResponse> beginWebAuthnRegistration({
    String? email,
  }) async {
    try {
      return await _authRepository.beginWebAuthnRegistration(email: email);
    } catch (e) {
      developer.log(
        'WebAuthn registration begin failed: $e',
        name: 'AuthProvider',
        level: 1000,
      );
      rethrow;
    }
  }

  /// Complete WebAuthn registration
  Future<void> completeWebAuthnRegistration(
    Map<String, dynamic> credential,
  ) async {
    try {
      await _authRepository.completeWebAuthnRegistration(credential);
      developer.log('WebAuthn registration completed', name: 'AuthProvider');
    } catch (e) {
      developer.log(
        'WebAuthn registration failed: $e',
        name: 'AuthProvider',
        level: 1000,
      );
      rethrow;
    }
  }

  /// Begin WebAuthn authentication
  Future<WebAuthnAuthenticationResponse> beginWebAuthnAuthentication({
    String? email,
  }) async {
    try {
      return await _authRepository.beginWebAuthnAuthentication(email: email);
    } catch (e) {
      developer.log(
        'WebAuthn auth begin failed: $e',
        name: 'AuthProvider',
        level: 1000,
      );
      rethrow;
    }
  }

  /// Complete WebAuthn authentication
  Future<void> completeWebAuthnAuthentication(
    Map<String, dynamic> credential,
  ) async {
    try {
      state = const AuthState.authenticating();

      final result = await _authRepository.completeWebAuthnAuthentication(
        credential,
      );

      state = AuthState.authenticated(
        user: result.user,
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );

      developer.log('WebAuthn authentication successful', name: 'AuthProvider');
    } catch (e) {
      final errorMessage = e is AppException
          ? e.message
          : 'WebAuthn authentication failed';
      state = AuthState.error(errorMessage);
      developer.log(
        'WebAuthn authentication failed: $e',
        name: 'AuthProvider',
        level: 1000,
      );
      rethrow;
    }
  }

  /// Two-Factor Authentication

  /// Get 2FA status
  Future<Map<String, dynamic>> getTwoFactorStatus() async {
    try {
      return await _authRepository.getTwoFactorStatus();
    } catch (e) {
      developer.log(
        'Get 2FA status failed: $e',
        name: 'AuthProvider',
        level: 1000,
      );
      rethrow;
    }
  }

  /// Setup 2FA
  Future<TwoFactorSetupResponse> setupTwoFactor() async {
    try {
      return await _authRepository.setupTwoFactor();
    } catch (e) {
      developer.log('2FA setup failed: $e', name: 'AuthProvider', level: 1000);
      rethrow;
    }
  }

  /// Enable 2FA
  Future<List<String>> enableTwoFactor(String code) async {
    try {
      final request = VerifyTwoFactorRequest(code: code);
      final backupCodes = await _authRepository.enableTwoFactor(request);

      // Refresh user data to update 2FA status
      await refreshUser();

      developer.log('2FA enabled successfully', name: 'AuthProvider');
      return backupCodes;
    } catch (e) {
      developer.log('2FA enable failed: $e', name: 'AuthProvider', level: 1000);
      rethrow;
    }
  }

  /// Verify 2FA code (for login)
  Future<void> verifyTwoFactor(String code) async {
    try {
      state = const AuthState.authenticating();

      final request = VerifyTwoFactorRequest(code: code);
      final result = await _authRepository.verifyTwoFactor(request);

      state = AuthState.authenticated(
        user: result.user,
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );

      developer.log('2FA verification successful', name: 'AuthProvider');
    } catch (e) {
      final errorMessage = e is AppException
          ? e.message
          : '2FA verification failed';
      state = AuthState.error(errorMessage);
      developer.log(
        '2FA verification failed: $e',
        name: 'AuthProvider',
        level: 1000,
      );
      rethrow;
    }
  }

  /// Verify 2FA code (alias for verifyTwoFactor with backup code support)
  Future<void> verify2FA(String code, {bool isBackupCode = false}) async {
    // For now, treating backup codes the same as regular codes
    // In a real implementation, you might want to handle them differently
    return verifyTwoFactor(code);
  }

  /// Disable 2FA
  Future<void> disableTwoFactor() async {
    try {
      await _authRepository.disableTwoFactor();

      // Refresh user data to update 2FA status
      await refreshUser();

      developer.log('2FA disabled successfully', name: 'AuthProvider');
    } catch (e) {
      developer.log(
        '2FA disable failed: $e',
        name: 'AuthProvider',
        level: 1000,
      );
      rethrow;
    }
  }

  /// Regenerate backup codes
  Future<List<String>> regenerateBackupCodes() async {
    try {
      final backupCodes = await _authRepository.regenerateBackupCodes();
      developer.log('Backup codes regenerated', name: 'AuthProvider');
      return backupCodes;
    } catch (e) {
      developer.log(
        'Backup codes regeneration failed: $e',
        name: 'AuthProvider',
        level: 1000,
      );
      rethrow;
    }
  }

  /// Utility Methods

  /// Refresh current user data
  Future<void> refreshUser() async {
    try {
      if (state is Authenticated) {
        final currentState = state as Authenticated;
        final user = await _authRepository.getCurrentUser();

        state = currentState.copyWith(user: user);
        developer.log('User data refreshed', name: 'AuthProvider');
      }
    } catch (e) {
      developer.log(
        'User refresh failed: $e',
        name: 'AuthProvider',
        level: 1000,
      );
      // Don't rethrow, as this is often called internally
    }
  }

  /// Update user profile
  Future<void> updateUserProfile(Map<String, dynamic> userData) async {
    try {
      if (state is Authenticated) {
        final currentState = state as Authenticated;
        final updatedUser = await _authRepository.updateCurrentUser(userData);

        state = currentState.copyWith(user: updatedUser);
        developer.log('User profile updated', name: 'AuthProvider');
      }
    } catch (e) {
      developer.log(
        'User profile update failed: $e',
        name: 'AuthProvider',
        level: 1000,
      );
      rethrow;
    }
  }

  /// Clear error state
  void clearError() {
    if (state is AuthError) {
      state = const AuthState.unauthenticated();
    }
  }
}
