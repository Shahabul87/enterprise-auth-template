import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_auth_template/presentation/providers/auth_provider.dart';
import 'package:flutter_auth_template/presentation/providers/two_factor_provider.dart';
import 'package:flutter_auth_template/presentation/providers/csrf_provider.dart';
import 'package:flutter_auth_template/infrastructure/services/auth/auth_service.dart';
import 'package:flutter_auth_template/infrastructure/services/auth/oauth_service.dart';
import 'package:flutter_auth_template/core/storage/secure_storage_service.dart';

/// Authentication Module - Groups all auth-related providers
class AuthModule {
  // Core Auth Providers
  static final authState = authStateProvider;
  static final currentUser = currentUserProvider;
  static final isAuthenticated = isAuthenticatedProvider;
  static final isLoading = isLoadingProvider;

  // Services
  static final authService = authServiceProvider;
  static final oauthService = oauthServiceProvider;
  static final secureStorage = secureStorageServiceProvider;

  // Security
  static final twoFactor = twoFactorProvider;
  static final csrf = csrfProvider;

  // Convenience methods
  static List<Override> getMockOverrides({
    required AuthService mockAuthService,
    required OAuthService mockOAuthService,
    required SecureStorageService mockSecureStorage,
  }) {
    return [
      authServiceProvider.overrideWithValue(mockAuthService),
      oauthServiceProvider.overrideWithValue(mockOAuthService),
      secureStorageServiceProvider.overrideWithValue(mockSecureStorage),
    ];
  }

  // Reset all auth state
  static void resetAll(WidgetRef ref) {
    ref.invalidate(authStateProvider);
    ref.invalidate(twoFactorProvider);
    ref.invalidate(csrfProvider);
  }
}