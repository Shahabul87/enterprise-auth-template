import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_auth_template/presentation/providers/auth_provider.dart';
import 'package:flutter_auth_template/infrastructure/services/auth/auth_service.dart';
import 'package:flutter_auth_template/infrastructure/services/auth/oauth_service.dart';
import 'package:flutter_auth_template/core/storage/secure_storage_service.dart';
import 'package:flutter_auth_template/domain/entities/auth_state.dart';
import 'package:flutter_auth_template/domain/entities/user.dart';
import 'package:flutter_auth_template/data/models/auth_request.dart';
import 'package:flutter_auth_template/core/network/api_response.dart';
import 'package:flutter_auth_template/core/security/account_lockout_service.dart';
import 'package:flutter_auth_template/core/security/device_fingerprint_service.dart';

import 'auth_flow_test.mocks.dart';

@GenerateMocks([
  AuthService,
  OAuthService,
  SecureStorageService,
  AccountLockoutService,
  DeviceFingerprintService,
])
void main() {
  late AuthNotifier authNotifier;
  late MockAuthService mockAuthService;
  late MockOAuthService mockOAuthService;
  late MockSecureStorageService mockSecureStorage;
  late MockAccountLockoutService mockAccountLockout;
  late MockDeviceFingerprintService mockDeviceFingerprint;

  setUp(() {
    mockAuthService = MockAuthService();
    mockOAuthService = MockOAuthService();
    mockSecureStorage = MockSecureStorageService();
    mockAccountLockout = MockAccountLockoutService();
    mockDeviceFingerprint = MockDeviceFingerprintService();

    authNotifier = AuthNotifier(
      mockAuthService,
      mockOAuthService,
      mockSecureStorage,
      mockAccountLockout,
      mockDeviceFingerprint,
    );
  });

  group('Authentication Flow Integration Tests', () {
    group('Login Flow', () {
      test('should successfully login with valid credentials', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        final user = User(
          id: '123',
          email: email,
          name: 'Test User',
          isEmailVerified: true,
          isTwoFactorEnabled: false,
          roles: [],
          permissions: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(mockAuthService.login(any)).thenAnswer(
          (_) async => ApiResponse.success(data: user),
        );
        when(mockAuthService.isAuthenticated()).thenAnswer((_) async => true);
        when(mockAuthService.getCurrentUser()).thenAnswer(
          (_) async => const ApiResponse.success(data: user),
        );

        // Act
        await authNotifier.login(email, password);

        // Assert
        expect(authNotifier.state, isA<Authenticated>());
        final state = authNotifier.state as Authenticated;
        expect(state.user.email, email);
        verify(mockAuthService.login(any)).called(1);
      });

      test('should handle login failure with invalid credentials', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'wrongpassword';

        when(mockAuthService.login(any)).thenAnswer(
          (_) async => const ApiResponse.error(
            message: 'Invalid credentials',
            code: 'INVALID_CREDENTIALS',
          ),
        );

        // Act
        await authNotifier.login(email, password);

        // Assert
        expect(authNotifier.state, isA<AuthError>());
        final state = authNotifier.state as AuthError;
        expect(state.message, 'Invalid credentials');
      });
    });

    group('Biometric Authentication Flow', () {
      test('should authenticate with biometric using refresh token', () async {
        // Arrange
        const refreshToken = 'refresh_token_123';
        const user = User(
          id: '123',
          email: 'test@example.com',
          name: 'Test User',
          isEmailVerified: true,
          isTwoFactorEnabled: false,
          roles: [],
          permissions: [],
        );

        when(mockSecureStorage.getRefreshToken())
            .thenAnswer((_) async => refreshToken);
        when(mockAuthService.refreshToken(refreshToken)).thenAnswer(
          (_) async => const ApiResponse.success(data: user),
        );

        // Act
        await authNotifier.refreshToken();

        // Assert
        expect(authNotifier.state, isA<Authenticated>());
        final state = authNotifier.state as Authenticated;
        expect(state.user, user);
        verify(mockAuthService.refreshToken(refreshToken)).called(1);
      });

      test('should handle biometric auth failure when no refresh token', () async {
        // Arrange
        when(mockSecureStorage.getRefreshToken())
            .thenAnswer((_) async => null);

        // Act & Assert
        await expectLater(
          authNotifier.refreshToken(),
          throwsException,
        );
        expect(authNotifier.state, isA<Unauthenticated>());
      });

      test('should handle biometric auth failure with invalid refresh token', () async {
        // Arrange
        const refreshToken = 'invalid_refresh_token';

        when(mockSecureStorage.getRefreshToken())
            .thenAnswer((_) async => refreshToken);
        when(mockAuthService.refreshToken(refreshToken)).thenAnswer(
          (_) async => const ApiResponse.error(
            message: 'Invalid refresh token',
            code: 'INVALID_TOKEN',
          ),
        );

        // Act & Assert
        await expectLater(
          authNotifier.refreshToken(),
          throwsException,
        );
        expect(authNotifier.state, isA<Unauthenticated>());
      });
    });

    group('OAuth Authentication Flow', () {
      test('should handle Google Sign-In flow', () async {
        // Arrange
        const user = User(
          id: '123',
          email: 'test@example.com',
          name: 'Test User',
          isEmailVerified: true,
          isTwoFactorEnabled: false,
          roles: [],
          permissions: [],
        );
        const googleResult = GoogleSignInResult(
          user: GoogleSignInAccount(
            email: 'test@example.com',
            displayName: 'Test User',
          ),
          accessToken: 'google_access_token',
        );

        when(mockOAuthService.signInWithGoogle()).thenAnswer(
          (_) async => const ApiResponse.success(data: googleResult),
        );
        when(mockAuthService.oauthLogin(any)).thenAnswer(
          (_) async => const ApiResponse.success(data: user),
        );

        // Act
        await authNotifier.signInWithGoogle();

        // Assert
        expect(authNotifier.state, isA<Authenticated>());
        final state = authNotifier.state as Authenticated;
        expect(state.user.email, 'test@example.com');
        verify(mockOAuthService.signInWithGoogle()).called(1);
        verify(mockAuthService.oauthLogin(any)).called(1);
      });

      test('should handle Google Sign-In cancellation', () async {
        // Arrange
        when(mockOAuthService.signInWithGoogle()).thenAnswer(
          (_) async => const ApiResponse.error(
            message: 'User cancelled sign in',
            code: 'USER_CANCELLED',
          ),
        );

        // Act & Assert
        await expectLater(
          authNotifier.signInWithGoogle(),
          throwsException,
        );
        expect(authNotifier.state, isA<AuthError>());
      });
    });

    group('Logout Flow', () {
      test('should successfully logout and clear session', () async {
        // Arrange
        when(mockOAuthService.isGoogleSignedIn())
            .thenAnswer((_) async => false);
        when(mockAuthService.logout()).thenAnswer(
          (_) async => const ApiResponse.success(data: 'Logged out'),
        );

        // Act
        await authNotifier.logout();

        // Assert
        expect(authNotifier.state, isA<Unauthenticated>());
        verify(mockAuthService.logout()).called(1);
      });

      test('should sign out from OAuth providers during logout', () async {
        // Arrange
        when(mockOAuthService.isGoogleSignedIn())
            .thenAnswer((_) async => true);
        when(mockOAuthService.signOutFromGoogle())
            .thenAnswer((_) async => {});
        when(mockAuthService.logout()).thenAnswer(
          (_) async => const ApiResponse.success(data: 'Logged out'),
        );

        // Act
        await authNotifier.logout();

        // Assert
        expect(authNotifier.state, isA<Unauthenticated>());
        verify(mockOAuthService.signOutFromGoogle()).called(1);
        verify(mockAuthService.logout()).called(1);
      });
    });

    group('Session Restoration', () {
      test('should restore session on app start if authenticated', () async {
        // Arrange
        const user = User(
          id: '123',
          email: 'test@example.com',
          name: 'Test User',
          isEmailVerified: true,
          isTwoFactorEnabled: false,
          roles: [],
          permissions: [],
        );

        when(mockAuthService.isAuthenticated()).thenAnswer((_) async => true);
        when(mockAuthService.getCurrentUser()).thenAnswer(
          (_) async => const ApiResponse.success(data: user),
        );

        // Act
        authNotifier = AuthNotifier(
          mockAuthService,
          mockOAuthService,
          mockSecureStorage,
        );

        // Wait for initialization
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(authNotifier.state, isA<Authenticated>());
        verify(mockAuthService.isAuthenticated()).called(1);
        verify(mockAuthService.getCurrentUser()).called(1);
      });

      test('should remain unauthenticated if no valid session', () async {
        // Arrange
        when(mockAuthService.isAuthenticated()).thenAnswer((_) async => false);

        // Act
        authNotifier = AuthNotifier(
          mockAuthService,
          mockOAuthService,
          mockSecureStorage,
        );

        // Wait for initialization
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(authNotifier.state, isA<Unauthenticated>());
        verify(mockAuthService.isAuthenticated()).called(1);
        verifyNever(mockAuthService.getCurrentUser());
      });
    });
  });
}