import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:flutter_auth_template/app/app.dart';
import 'package:flutter_auth_template/services/auth_service.dart';
import 'package:flutter_auth_template/services/oauth_service.dart';
import 'package:flutter_auth_template/core/storage/secure_storage_service.dart';
import 'package:flutter_auth_template/data/models/auth_request.dart';
import 'package:flutter_auth_template/domain/entities/user.dart';
import 'package:flutter_auth_template/core/network/api_response.dart';
import 'package:flutter_auth_template/providers/auth_provider.dart';
import 'package:flutter_auth_template/data/models/auth_response.dart';

// Generate mocks
@GenerateMocks([AuthService, OAuthService, SecureStorageService])
import 'auth_flow_test_fixed.mocks.dart';

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

      final loginRequest = LoginRequest(
        email: 'test@example.com',
        password: 'password123',
      );

      final loginResponse = ApiResponse<User>.success(data: mockUser);
      when(mockAuthService.login(any)).thenAnswer((_) async => loginResponse);

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
      final createAccountButton = find.text('Create Account');
      await tester.tap(createAccountButton);
      await tester.pumpAndSettle();

      // Assert - Should be on registration screen
      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Sign up to get started'), findsOneWidget);

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

      final registerRequest = RegisterRequest(
        email: 'newuser@example.com',
        password: 'SecurePassword123!',
        fullName: 'New User',
        confirmPassword: 'SecurePassword123!',
        agreeToTerms: true,
      );

      final registerResponse = ApiResponse<User>.success(data: mockUser);
      when(mockAuthService.register(any)).thenAnswer((_) async => registerResponse);

      // Act - Fill registration form
      await tester.enterText(find.byType(TextFormField).at(0), 'New User');
      await tester.enterText(find.byType(TextFormField).at(1), 'newuser@example.com');
      await tester.enterText(find.byType(TextFormField).at(2), 'SecurePassword123!');
      await tester.enterText(find.byType(TextFormField).at(3), 'SecurePassword123!');

      // Check terms and conditions
      final termsCheckbox = find.byType(Checkbox);
      await tester.tap(termsCheckbox);

      // Submit registration
      final signUpButton = find.widgetWithText(ElevatedButton, 'Sign Up');
      await tester.tap(signUpButton);
      await tester.pumpAndSettle();

      // Assert - Should navigate to dashboard or email verification
      expect(find.text('Dashboard'), findsOneWidget);
    });

    testWidgets('Forgot password flow', (WidgetTester tester) async {
      // Arrange
      when(mockSecureStorage.getAccessToken()).thenAnswer((_) async => null);

      // Act - Start app
      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();

      // Navigate to forgot password
      final forgotPasswordLink = find.text('Forgot Password?');
      await tester.tap(forgotPasswordLink);
      await tester.pumpAndSettle();

      // Assert - Should be on forgot password screen
      expect(find.text('Reset Password'), findsOneWidget);
      expect(find.text('Enter your email to reset password'), findsOneWidget);

      // Arrange - Mock forgot password response
      final forgotResponse = ApiResponse<String>.success(
        data: 'Reset email sent',
        message: 'Check your email for reset instructions',
      );
      when(mockAuthService.forgotPassword(any)).thenAnswer((_) async => forgotResponse);

      // Act - Enter email and submit
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');

      final submitButton = find.widgetWithText(ElevatedButton, 'Send Reset Email');
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Assert - Should show success message
      expect(find.text('Check your email for reset instructions'), findsOneWidget);
    });

    testWidgets('OAuth login with Google', (WidgetTester tester) async {
      // Arrange
      when(mockSecureStorage.getAccessToken()).thenAnswer((_) async => null);

      // Act - Start app
      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();

      // Assert - Should see OAuth buttons
      expect(find.text('Sign in with Google'), findsOneWidget);

      // Arrange - Mock Google sign-in
      final mockUser = User(
        id: '125',
        email: 'google@example.com',
        name: 'Google User',
        isEmailVerified: true,
        isTwoFactorEnabled: false,
        roles: const [],
        permissions: const [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final googleSignInData = GoogleSignInData(
        accessToken: 'google_access_token',
        idToken: 'google_id_token',
        email: 'google@example.com',
        name: 'Google User',
        photoUrl: 'https://example.com/photo.jpg',
      );

      final googleResponse = ApiResponse<GoogleSignInData>.success(data: googleSignInData);
      when(mockOAuthService.signInWithGoogle()).thenAnswer((_) async => googleResponse);

      final oauthResponse = ApiResponse<User>.success(data: mockUser);
      when(mockAuthService.oauthLogin(any)).thenAnswer((_) async => oauthResponse);

      // Act - Tap Google sign-in button
      final googleButton = find.text('Sign in with Google');
      await tester.tap(googleButton);
      await tester.pumpAndSettle();

      // Assert - Should navigate to dashboard
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Google User'), findsOneWidget);
    });

    testWidgets('Two-factor authentication flow', (WidgetTester tester) async {
      // Arrange - Mock user requires 2FA
      when(mockSecureStorage.getAccessToken()).thenAnswer((_) async => null);

      // Start app
      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();

      // Mock initial login requiring 2FA
      final loginResponse = ApiResponse<User>.success(
        data: null,
        message: 'Two-factor authentication required',
      );
      when(mockAuthService.login(any)).thenAnswer((_) async => loginResponse);

      // Login
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');

      final loginButton = find.widgetWithText(ElevatedButton, 'Login');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Should show 2FA screen
      expect(find.text('Two-Factor Authentication'), findsOneWidget);
      expect(find.text('Enter your verification code'), findsOneWidget);

      // Mock 2FA verification
      final mockUser = User(
        id: '126',
        email: 'test@example.com',
        name: 'Test User',
        isEmailVerified: true,
        isTwoFactorEnabled: true,
        roles: const [],
        permissions: const [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final twoFactorResponse = ApiResponse<User>.success(data: mockUser);
      when(mockAuthService.verify2FA(any)).thenAnswer((_) async => twoFactorResponse);

      // Enter 2FA code
      await tester.enterText(find.byType(TextFormField).first, '123456');

      final verifyButton = find.widgetWithText(ElevatedButton, 'Verify');
      await tester.tap(verifyButton);
      await tester.pumpAndSettle();

      // Should navigate to dashboard
      expect(find.text('Dashboard'), findsOneWidget);
    });
  });
}

/// Mock data classes for testing
class GoogleSignInData {
  final String accessToken;
  final String idToken;
  final String email;
  final String name;
  final String? photoUrl;

  GoogleSignInData({
    required this.accessToken,
    required this.idToken,
    required this.email,
    required this.name,
    this.photoUrl,
  });
}