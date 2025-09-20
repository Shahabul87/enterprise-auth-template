import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:flutter_auth_template/app/app.dart';
import 'package:flutter_auth_template/data/services/auth_service.dart';
import 'package:flutter_auth_template/infrastructure/services/auth/oauth_service.dart';
import 'package:flutter_auth_template/core/storage/secure_storage_service.dart';
import 'package:google_sign_in/google_sign_in.dart' as google;
import 'package:flutter_auth_template/data/models/auth_request.dart';
import 'package:flutter_auth_template/data/models/auth_response.dart';
import 'package:flutter_auth_template/domain/entities/user.dart';
import 'package:flutter_auth_template/core/network/api_response.dart';
import 'package:flutter_auth_template/core/errors/app_exception.dart';

import 'auth_flow_test.mocks.dart';

@GenerateMocks([AuthService, OAuthService, SecureStorageService])
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Flow Integration Tests', () {
    late MockAuthService mockAuthService;
    late MockOAuthService mockOAuthService;
    late MockSecureStorageService mockSecureStorage;

    setUp(() {
      mockAuthService = MockAuthService();
      mockOAuthService = MockOAuthService();
      mockSecureStorage = MockSecureStorageService();
    });

    Widget createApp() {
      return ProviderScope(
        overrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
          oauthServiceProvider.overrideWithValue(mockOAuthService),
          secureStorageServiceProvider.overrideWithValue(mockSecureStorage),
        ],
        child: const FlutterAuthApp(),
      );
    }

    testWidgets('Complete login flow - from splash to dashboard', (WidgetTester tester) async {
      // Arrange - Mock no stored token (unauthenticated)
      when(mockSecureStorage.getAccessToken()).thenAnswer((_) async => null);

      // Act - Start app
      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();

      // Assert - Should navigate to login screen
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Sign in to your account'), findsOneWidget);

      // Arrange - Mock successful login
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
      
      const loginRequest = LoginRequest(
        email: 'test@example.com',
        password: 'password123',
      );

      final loginResponse = AuthResponseData(
        user: mockUser,
        accessToken: 'test_access_token',
        refreshToken: 'test_refresh_token',
      );
      when(mockAuthService.login(loginRequest)).thenAnswer((_) async => loginResponse);

      // Act - Fill login form and submit
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      
      final loginButton = find.widgetWithText(ElevatedButton, 'Login');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Assert - Should navigate to dashboard
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Welcome back!'), findsOneWidget);
      expect(find.text('Test User'), findsOneWidget);
      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('Complete registration flow', (WidgetTester tester) async {
      // Arrange - Mock no stored token
      when(mockSecureStorage.getAccessToken()).thenAnswer((_) async => null);

      // Act - Start app and navigate to registration
      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();

      // Navigate to register screen
      final signUpButton = find.text('Sign Up');
      await tester.tap(signUpButton);
      await tester.pumpAndSettle();

      // Assert - Should be on registration screen
      expect(find.text('Create Account'), findsOneWidget);

      // Arrange - Mock successful registration
      final mockUser = User(
        id: '124',
        email: 'newuser@example.com',
        name: 'New User',
        isEmailVerified: false,
        isTwoFactorEnabled: false,
        roles: const [],
        permissions: const [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      const registerRequest = RegisterRequest(
        email: 'newuser@example.com',
        password: 'SecurePass123!',
        fullName: 'New User',
        confirmPassword: 'SecurePass123!',
        agreeToTerms: true,
      );

      final registerResponse = AuthResponseData(
        user: mockUser,
        accessToken: 'test_access_token',
        refreshToken: 'test_refresh_token',
      );
      when(mockAuthService.register(registerRequest)).thenAnswer((_) async => registerResponse);

      // Act - Fill registration form
      await tester.enterText(find.byType(TextFormField).at(0), 'New User');
      await tester.enterText(find.byType(TextFormField).at(1), 'newuser@example.com');
      await tester.enterText(find.byType(TextFormField).at(2), 'SecurePass123!');
      await tester.enterText(find.byType(TextFormField).at(3), 'SecurePass123!');
      
      // Accept terms
      final checkbox = find.byType(Checkbox);
      await tester.tap(checkbox);
      await tester.pump();
      
      // Submit form
      final registerButton = find.widgetWithText(ElevatedButton, 'Create Account').first;
      await tester.tap(registerButton);
      await tester.pumpAndSettle();

      // Assert - Should navigate to dashboard
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('New User'), findsOneWidget);
    });

    testWidgets('Login with 2FA flow', (WidgetTester tester) async {
      // Arrange - Mock no stored token
      when(mockSecureStorage.getAccessToken()).thenAnswer((_) async => null);

      // Start app
      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();

      // Arrange - Mock login that requires 2FA
      const loginRequest = LoginRequest(
        email: 'test@example.com',
        password: 'password123',
      );

      // Mock login response that requires 2FA (throw exception for 2FA requirement)
      when(mockAuthService.login(loginRequest))
          .thenThrow(const TwoFactorRequiredException('Two-factor authentication required'));

      // Act - Login with credentials
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      
      final loginButton = find.widgetWithText(ElevatedButton, 'Login');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Assert - Should navigate to 2FA verification screen
      expect(find.text('Verification Required'), findsOneWidget);
      expect(find.text('Enter the 6-digit code from your authenticator app'), findsOneWidget);

      // Arrange - Mock successful 2FA verification
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

      final verify2FAResponse = AuthResponseData(
        user: mockUser,
        accessToken: 'test_access_token',
        refreshToken: 'test_refresh_token',
      );
      when(mockAuthService.verifyTwoFactorCode('123456'))
          .thenAnswer((_) async => verify2FAResponse);

      // Act - Enter 2FA code
      await tester.enterText(find.byType(TextFormField), '123456');
      
      final verifyButton = find.widgetWithText(ElevatedButton, 'Verify & Continue');
      await tester.tap(verifyButton);
      await tester.pumpAndSettle();

      // Assert - Should navigate to dashboard
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Test User'), findsOneWidget);
    });

    testWidgets('Google OAuth login flow', (WidgetTester tester) async {
      // Arrange - Mock no stored token
      when(mockSecureStorage.getAccessToken()).thenAnswer((_) async => null);

      // Start app
      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();

      // Should be on login screen
      expect(find.text('Welcome Back'), findsOneWidget);

      // Arrange - Mock successful Google sign-in
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

      // Mock Google Sign-In result - we'll just test the flow without actual account

      when(mockOAuthService.signInWithGoogle()).thenAnswer((_) async => null);

      // Act - Tap Google sign-in button
      final googleButton = find.text('Continue with Google');
      await tester.tap(googleButton);
      await tester.pumpAndSettle();

      // Assert - Should navigate to dashboard
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Test User'), findsOneWidget);
      expect(find.text('test@gmail.com'), findsOneWidget);
    });

    testWidgets('Logout flow', (WidgetTester tester) async {
      // Arrange - Mock authenticated user
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

      when(mockSecureStorage.getAccessToken()).thenAnswer((_) async => 'valid-token');
      
      when(mockAuthService.getCurrentUser()).thenAnswer((_) async => mockUser);

      // Start app (should go to dashboard)
      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();

      // Should be on dashboard
      expect(find.text('Dashboard'), findsOneWidget);

      // Arrange - Mock logout
      when(mockAuthService.logout()).thenAnswer((_) async => null);

      // Act - Open menu and logout
      final menuButton = find.byType(PopupMenuButton<String>);
      await tester.tap(menuButton);
      await tester.pumpAndSettle();

      final logoutOption = find.text('Logout');
      await tester.tap(logoutOption);
      await tester.pumpAndSettle();

      // Should show confirmation dialog
      expect(find.text('Are you sure you want to logout?'), findsOneWidget);

      // Confirm logout
      final confirmButton = find.text('Logout').last;
      await tester.tap(confirmButton);
      await tester.pumpAndSettle();

      // Assert - Should navigate back to login screen
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Sign in to your account'), findsOneWidget);
    });

    testWidgets('Error handling - invalid login credentials', (WidgetTester tester) async {
      // Arrange - Mock no stored token
      when(mockSecureStorage.getAccessToken()).thenAnswer((_) async => null);

      // Start app
      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();

      // Arrange - Mock failed login
      const loginRequest = LoginRequest(
        email: 'test@example.com',
        password: 'wrongpassword',
      );

      // Mock failed login - throw exception
      when(mockAuthService.login(loginRequest))
          .thenThrow(const InvalidCredentialsException('Invalid email or password'));

      // Act - Try to login with wrong credentials
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'wrongpassword');
      
      final loginButton = find.widgetWithText(ElevatedButton, 'Login');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Assert - Should show error message and stay on login screen
      expect(find.text('Invalid email or password'), findsOneWidget);
      expect(find.text('Welcome Back'), findsOneWidget); // Still on login screen
    });
  });
}