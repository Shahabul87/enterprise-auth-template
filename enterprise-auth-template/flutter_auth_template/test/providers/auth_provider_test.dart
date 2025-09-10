import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_auth_template/providers/auth_provider.dart';
import 'package:flutter_auth_template/services/auth_service.dart';
import 'package:flutter_auth_template/services/oauth_service.dart';
import 'package:flutter_auth_template/core/storage/secure_storage_service.dart';
import 'package:flutter_auth_template/data/models/auth_state.dart';
import 'package:flutter_auth_template/data/models/auth_request.dart';
import 'package:flutter_auth_template/data/models/user.dart';
import 'package:flutter_auth_template/core/network/api_response.dart';

import 'auth_provider_test.mocks.dart';

@GenerateMocks([AuthService, OAuthService, SecureStorageService])
void main() {
  group('AuthNotifier Tests', () {
    late MockAuthService mockAuthService;
    late MockOAuthService mockOAuthService;
    late MockSecureStorageService mockSecureStorage;
    late AuthNotifier authNotifier;
    late ProviderContainer container;

    setUp(() {
      mockAuthService = MockAuthService();
      mockOAuthService = MockOAuthService();
      mockSecureStorage = MockSecureStorageService();
      
      container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
          oauthServiceProvider.overrideWithValue(mockOAuthService),
          secureStorageProvider.overrideWithValue(mockSecureStorage),
        ],
      );
      
      authNotifier = container.read(authStateProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    group('login', () {
      test('should update state to loading then authenticated on successful login', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        const request = LoginRequest(email: email, password: password);
        
        final mockUser = User(
          id: '123',
          email: email,
          name: 'Test User',
          isEmailVerified: true,
          isTwoFactorEnabled: false,
          roles: const [],
          permissions: const [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final successResponse = ApiResponse.success(mockUser);
        when(mockAuthService.login(request)).thenAnswer((_) async => successResponse);

        // Act
        final future = authNotifier.login(request);
        
        // Assert initial loading state
        expect(authNotifier.state, isA<AuthStateLoading>());
        
        await future;
        
        // Assert final authenticated state
        expect(authNotifier.state, isA<AuthStateAuthenticated>());
        final authenticatedState = authNotifier.state as AuthStateAuthenticated;
        expect(authenticatedState.user.email, email);
      });

      test('should update state to error on failed login', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'wrongpassword';
        const request = LoginRequest(email: email, password: password);
        const errorMessage = 'Invalid credentials';
        
        final errorResponse = ApiResponse<User>.error(errorMessage, 'AUTH_ERROR');
        when(mockAuthService.login(request)).thenAnswer((_) async => errorResponse);

        // Act
        await authNotifier.login(request);
        
        // Assert error state
        expect(authNotifier.state, isA<AuthStateError>());
        final errorState = authNotifier.state as AuthStateError;
        expect(errorState.message, errorMessage);
      });

      test('should handle login exception', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        const request = LoginRequest(email: email, password: password);
        
        when(mockAuthService.login(request)).thenThrow(Exception('Network error'));

        // Act
        await authNotifier.login(request);
        
        // Assert error state
        expect(authNotifier.state, isA<AuthStateError>());
        final errorState = authNotifier.state as AuthStateError;
        expect(errorState.message, contains('Network error'));
      });
    });

    group('register', () {
      test('should update state to loading then authenticated on successful registration', () async {
        // Arrange
        const email = 'newuser@example.com';
        const password = 'password123';
        const name = 'New User';
        const request = RegisterRequest(
          email: email,
          password: password,
          name: name,
        );
        
        final mockUser = User(
          id: '124',
          email: email,
          name: name,
          isEmailVerified: false,
          isTwoFactorEnabled: false,
          roles: const [],
          permissions: const [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final successResponse = ApiResponse.success(mockUser);
        when(mockAuthService.register(request)).thenAnswer((_) async => successResponse);

        // Act
        final future = authNotifier.register(request);
        
        // Assert initial loading state
        expect(authNotifier.state, isA<AuthStateLoading>());
        
        await future;
        
        // Assert final authenticated state
        expect(authNotifier.state, isA<AuthStateAuthenticated>());
        final authenticatedState = authNotifier.state as AuthStateAuthenticated;
        expect(authenticatedState.user.email, email);
        expect(authenticatedState.user.name, name);
      });

      test('should update state to error on failed registration', () async {
        // Arrange
        const email = 'existing@example.com';
        const password = 'password123';
        const name = 'Test User';
        const request = RegisterRequest(
          email: email,
          password: password,
          name: name,
        );
        const errorMessage = 'Email already exists';
        
        final errorResponse = ApiResponse<User>.error(errorMessage, 'VALIDATION_ERROR');
        when(mockAuthService.register(request)).thenAnswer((_) async => errorResponse);

        // Act
        await authNotifier.register(request);
        
        // Assert error state
        expect(authNotifier.state, isA<AuthStateError>());
        final errorState = authNotifier.state as AuthStateError;
        expect(errorState.message, errorMessage);
      });
    });

    group('logout', () {
      test('should update state to unauthenticated on successful logout', () async {
        // Arrange
        final mockUser = User(
          id: '123',
          email: 'test@example.com',
          name: 'Test User',
          isEmailVerified: true,
          isTwoFactorEnabled: false,
          roles: const [],
          permissions: const [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        // Set initial authenticated state
        authNotifier.state = AuthState.authenticated(mockUser);
        
        final successResponse = ApiResponse<void>.success(null);
        when(mockAuthService.logout()).thenAnswer((_) async => successResponse);

        // Act
        await authNotifier.logout();
        
        // Assert unauthenticated state
        expect(authNotifier.state, isA<AuthStateUnauthenticated>());
      });

      test('should still logout locally even if API call fails', () async {
        // Arrange
        final mockUser = User(
          id: '123',
          email: 'test@example.com',
          name: 'Test User',
          isEmailVerified: true,
          isTwoFactorEnabled: false,
          roles: const [],
          permissions: const [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        // Set initial authenticated state
        authNotifier.state = AuthState.authenticated(mockUser);
        
        when(mockAuthService.logout()).thenThrow(Exception('Network error'));

        // Act
        await authNotifier.logout();
        
        // Assert still logs out locally
        expect(authNotifier.state, isA<AuthStateUnauthenticated>());
      });
    });

    group('Google OAuth', () {
      test('should handle successful Google sign-in', () async {
        // Arrange
        final mockUser = User(
          id: '123',
          email: 'test@gmail.com',
          name: 'Test User',
          isEmailVerified: true,
          isTwoFactorEnabled: false,
          roles: const [],
          permissions: const [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final mockGoogleResult = GoogleSignInResult(
          user: mockUser,
          isNewUser: false,
        );

        final successResponse = ApiResponse.success(mockGoogleResult);
        when(mockOAuthService.signInWithGoogle()).thenAnswer((_) async => successResponse);

        // Act
        final future = authNotifier.signInWithGoogle();
        
        // Assert loading state
        expect(authNotifier.state, isA<AuthStateLoading>());
        
        await future;
        
        // Assert authenticated state
        expect(authNotifier.state, isA<AuthStateAuthenticated>());
        final authenticatedState = authNotifier.state as AuthStateAuthenticated;
        expect(authenticatedState.user.email, 'test@gmail.com');
      });

      test('should handle Google sign-in cancellation', () async {
        // Arrange
        final errorResponse = ApiResponse<GoogleSignInResult>.error('Sign-in cancelled', 'CANCELLED');
        when(mockOAuthService.signInWithGoogle()).thenAnswer((_) async => errorResponse);

        // Act
        await authNotifier.signInWithGoogle();
        
        // Assert returns to initial state (not error for cancellation)
        expect(authNotifier.state, isA<AuthStateInitial>());
      });

      test('should handle Google sign-in error', () async {
        // Arrange
        const errorMessage = 'Google sign-in failed';
        final errorResponse = ApiResponse<GoogleSignInResult>.error(errorMessage, 'GOOGLE_ERROR');
        when(mockOAuthService.signInWithGoogle()).thenAnswer((_) async => errorResponse);

        // Act
        await authNotifier.signInWithGoogle();
        
        // Assert error state
        expect(authNotifier.state, isA<AuthStateError>());
        final errorState = authNotifier.state as AuthStateError;
        expect(errorState.message, errorMessage);
      });
    });

    group('2FA operations', () {
      test('should handle successful 2FA setup', () async {
        // Arrange
        final mockSetupResponse = TwoFactorSetupResponse(
          secret: 'JBSWY3DPEHPK3PXP',
          qrCode: 'otpauth://totp/Example:user@example.com?secret=JBSWY3DPEHPK3PXP&issuer=Example',
          backupCodes: ['12345678', '87654321'],
        );

        final successResponse = ApiResponse.success(mockSetupResponse);
        when(mockAuthService.setup2FA()).thenAnswer((_) async => successResponse);

        // Act
        final result = await authNotifier.setup2FA();
        
        // Assert
        expect(result, isNotNull);
        expect(result?.secret, 'JBSWY3DPEHPK3PXP');
        expect(result?.backupCodes, hasLength(2));
      });

      test('should handle successful 2FA verification', () async {
        // Arrange
        const code = '123456';
        const token = 'temp-token';
        
        final mockUser = User(
          id: '123',
          email: 'test@example.com',
          name: 'Test User',
          isEmailVerified: true,
          isTwoFactorEnabled: true,
          roles: const [],
          permissions: const [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final successResponse = ApiResponse.success(mockUser);
        when(mockAuthService.verify2FA(code, token: token, isBackup: false))
            .thenAnswer((_) async => successResponse);

        // Act
        await authNotifier.verify2FA(code, token: token, isBackup: false);
        
        // Assert authenticated state
        expect(authNotifier.state, isA<AuthStateAuthenticated>());
        final authenticatedState = authNotifier.state as AuthStateAuthenticated;
        expect(authenticatedState.user.isTwoFactorEnabled, isTrue);
      });

      test('should handle failed 2FA verification', () async {
        // Arrange
        const code = '000000';
        const errorMessage = 'Invalid 2FA code';
        
        final errorResponse = ApiResponse<User>.error(errorMessage, '2FA_ERROR');
        when(mockAuthService.verify2FA(code, token: null, isBackup: false))
            .thenAnswer((_) async => errorResponse);

        // Act
        await authNotifier.verify2FA(code, token: null, isBackup: false);
        
        // Assert error state
        expect(authNotifier.state, isA<AuthStateError>());
        final errorState = authNotifier.state as AuthStateError;
        expect(errorState.message, errorMessage);
      });
    });

    group('checkAuthState', () {
      test('should restore authenticated state from stored token', () async {
        // Arrange
        const accessToken = 'stored-access-token';
        when(mockSecureStorage.getAccessToken()).thenAnswer((_) async => accessToken);
        
        final mockUser = User(
          id: '123',
          email: 'test@example.com',
          name: 'Test User',
          isEmailVerified: true,
          isTwoFactorEnabled: false,
          roles: const [],
          permissions: const [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final successResponse = ApiResponse.success(mockUser);
        when(mockAuthService.getCurrentUser()).thenAnswer((_) async => successResponse);

        // Act
        await authNotifier.checkAuthState();
        
        // Assert authenticated state
        expect(authNotifier.state, isA<AuthStateAuthenticated>());
        final authenticatedState = authNotifier.state as AuthStateAuthenticated;
        expect(authenticatedState.user.id, '123');
      });

      test('should set unauthenticated state when no token stored', () async {
        // Arrange
        when(mockSecureStorage.getAccessToken()).thenAnswer((_) async => null);

        // Act
        await authNotifier.checkAuthState();
        
        // Assert unauthenticated state
        expect(authNotifier.state, isA<AuthStateUnauthenticated>());
      });

      test('should handle invalid stored token', () async {
        // Arrange
        const accessToken = 'invalid-token';
        when(mockSecureStorage.getAccessToken()).thenAnswer((_) async => accessToken);
        
        final errorResponse = ApiResponse<User>.error('Invalid token', 'AUTH_ERROR');
        when(mockAuthService.getCurrentUser()).thenAnswer((_) async => errorResponse);

        // Act
        await authNotifier.checkAuthState();
        
        // Assert unauthenticated state
        expect(authNotifier.state, isA<AuthStateUnauthenticated>());
      });
    });
  });

  group('Provider Tests', () {
    test('isLoadingProvider should return true when state is loading', () {
      final container = ProviderContainer();
      
      // Set loading state
      container.read(authStateProvider.notifier).state = const AuthState.loading();
      
      final isLoading = container.read(isLoadingProvider);
      expect(isLoading, isTrue);
      
      container.dispose();
    });

    test('isAuthenticatedProvider should return true when user is authenticated', () {
      final container = ProviderContainer();
      
      final mockUser = User(
        id: '123',
        email: 'test@example.com',
        name: 'Test User',
        isEmailVerified: true,
        isTwoFactorEnabled: false,
        roles: const [],
        permissions: const [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Set authenticated state
      container.read(authStateProvider.notifier).state = AuthState.authenticated(mockUser);
      
      final isAuthenticated = container.read(isAuthenticatedProvider);
      expect(isAuthenticated, isTrue);
      
      container.dispose();
    });

    test('currentUserProvider should return user when authenticated', () {
      final container = ProviderContainer();
      
      final mockUser = User(
        id: '123',
        email: 'test@example.com',
        name: 'Test User',
        isEmailVerified: true,
        isTwoFactorEnabled: false,
        roles: const [],
        permissions: const [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Set authenticated state
      container.read(authStateProvider.notifier).state = AuthState.authenticated(mockUser);
      
      final currentUser = container.read(currentUserProvider);
      expect(currentUser?.id, '123');
      expect(currentUser?.email, 'test@example.com');
      
      container.dispose();
    });

    test('currentUserProvider should return null when not authenticated', () {
      final container = ProviderContainer();
      
      // Set unauthenticated state
      container.read(authStateProvider.notifier).state = const AuthState.unauthenticated();
      
      final currentUser = container.read(currentUserProvider);
      expect(currentUser, isNull);
      
      container.dispose();
    });
  });
}