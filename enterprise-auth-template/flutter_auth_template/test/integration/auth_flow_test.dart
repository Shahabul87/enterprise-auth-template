import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_auth_template/main.dart';
import 'package:flutter_auth_template/data/services/auth_api_service.dart';
import 'package:flutter_auth_template/data/models/auth_models.dart';
import 'package:flutter_auth_template/data/models/user_models.dart';
import 'package:flutter_auth_template/providers/auth_provider.dart';

@GenerateMocks([AuthApiService])
import 'auth_flow_test.mocks.dart';

void main() {
  group('Authentication Flow Integration Tests', () {
    late MockAuthApiService mockAuthService;
    late ProviderContainer container;

    setUp(() {
      mockAuthService = MockAuthApiService();
      
      container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('Login Flow', () {
      testWidgets('should complete successful login flow', (WidgetTester tester) async {
        // Mock successful login response
        when(mockAuthService.login(any)).thenAnswer((_) async => LoginResponse(
          accessToken: 'test-access-token',
          refreshToken: 'test-refresh-token',
          user: User(
            id: 'test-user-id',
            email: 'test@example.com',
            name: 'Test User',
            createdAt: DateTime.now(),
            isActive: true,
            role: UserRole.user,
          ),
          expiresIn: 3600,
        ));

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MyApp(),
          ),
        );

        await tester.pumpAndSettle();

        // Should show login page initially
        expect(find.text('Login'), findsOneWidget);
        expect(find.byType(TextField), findsNWidgets(2)); // Email and password fields

        // Enter login credentials
        await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
        await tester.enterText(find.byKey(const Key('password_field')), 'password123');

        // Tap login button
        await tester.tap(find.byKey(const Key('login_button')));
        await tester.pumpAndSettle();

        // Should navigate to dashboard
        expect(find.text('Dashboard'), findsOneWidget);
        expect(find.text('Welcome, Test User'), findsOneWidget);

        // Verify login was called with correct parameters
        verify(mockAuthService.login(any)).called(1);
      });

      testWidgets('should handle login errors gracefully', (WidgetTester tester) async {
        // Mock login error
        when(mockAuthService.login(any)).thenThrow(
          Exception('Invalid credentials'),
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MyApp(),
          ),
        );

        await tester.pumpAndSettle();

        // Enter invalid credentials
        await tester.enterText(find.byKey(const Key('email_field')), 'wrong@example.com');
        await tester.enterText(find.byKey(const Key('password_field')), 'wrongpassword');

        await tester.tap(find.byKey(const Key('login_button')));
        await tester.pump(); // Don't settle immediately to catch loading state

        // Should show loading indicator
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        await tester.pumpAndSettle();

        // Should show error message and stay on login page
        expect(find.textContaining('Invalid credentials'), findsOneWidget);
        expect(find.text('Login'), findsOneWidget);
      });

      testWidgets('should validate form inputs', (WidgetTester tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MyApp(),
          ),
        );

        await tester.pumpAndSettle();

        // Try to login with empty fields
        await tester.tap(find.byKey(const Key('login_button')));
        await tester.pumpAndSettle();

        // Should show validation errors
        expect(find.textContaining('required'), findsWidgets);

        // Enter invalid email
        await tester.enterText(find.byKey(const Key('email_field')), 'invalid-email');
        await tester.tap(find.byKey(const Key('login_button')));
        await tester.pumpAndSettle();

        expect(find.textContaining('valid email'), findsOneWidget);

        // Enter valid email but short password
        await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
        await tester.enterText(find.byKey(const Key('password_field')), '123');
        await tester.tap(find.byKey(const Key('login_button')));
        await tester.pumpAndSettle();

        expect(find.textContaining('password'), findsOneWidget);
      });
    });

    group('Registration Flow', () {
      testWidgets('should complete successful registration flow', (WidgetTester tester) async {
        // Mock successful registration
        when(mockAuthService.register(any)).thenAnswer((_) async => LoginResponse(
          accessToken: 'test-access-token',
          refreshToken: 'test-refresh-token',
          user: User(
            id: 'new-user-id',
            email: 'new@example.com',
            name: 'New User',
            createdAt: DateTime.now(),
            isActive: true,
            role: UserRole.user,
          ),
          expiresIn: 3600,
        ));

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MyApp(),
          ),
        );

        await tester.pumpAndSettle();

        // Navigate to registration page
        await tester.tap(find.text('Sign Up'));
        await tester.pumpAndSettle();

        expect(find.text('Register'), findsOneWidget);

        // Fill registration form
        await tester.enterText(find.byKey(const Key('name_field')), 'New User');
        await tester.enterText(find.byKey(const Key('email_field')), 'new@example.com');
        await tester.enterText(find.byKey(const Key('password_field')), 'password123');
        await tester.enterText(find.byKey(const Key('confirm_password_field')), 'password123');

        // Accept terms
        await tester.tap(find.byKey(const Key('terms_checkbox')));

        // Submit registration
        await tester.tap(find.byKey(const Key('register_button')));
        await tester.pumpAndSettle();

        // Should navigate to dashboard
        expect(find.text('Dashboard'), findsOneWidget);
        expect(find.text('Welcome, New User'), findsOneWidget);

        verify(mockAuthService.register(any)).called(1);
      });

      testWidgets('should validate password confirmation', (WidgetTester tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MyApp(),
          ),
        );

        await tester.pumpAndSettle();

        await tester.tap(find.text('Sign Up'));
        await tester.pumpAndSettle();

        // Fill form with mismatched passwords
        await tester.enterText(find.byKey(const Key('name_field')), 'New User');
        await tester.enterText(find.byKey(const Key('email_field')), 'new@example.com');
        await tester.enterText(find.byKey(const Key('password_field')), 'password123');
        await tester.enterText(find.byKey(const Key('confirm_password_field')), 'different123');

        await tester.tap(find.byKey(const Key('register_button')));
        await tester.pumpAndSettle();

        expect(find.textContaining('Passwords do not match'), findsOneWidget);
      });
    });

    group('Logout Flow', () {
      testWidgets('should complete logout flow', (WidgetTester tester) async {
        // Setup authenticated state
        when(mockAuthService.login(any)).thenAnswer((_) async => LoginResponse(
          accessToken: 'test-access-token',
          refreshToken: 'test-refresh-token',
          user: User(
            id: 'test-user-id',
            email: 'test@example.com',
            name: 'Test User',
            createdAt: DateTime.now(),
            isActive: true,
            role: UserRole.user,
          ),
          expiresIn: 3600,
        ));

        when(mockAuthService.logout()).thenAnswer((_) async => {});

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MyApp(),
          ),
        );

        await tester.pumpAndSettle();

        // Login first
        await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
        await tester.enterText(find.byKey(const Key('password_field')), 'password123');
        await tester.tap(find.byKey(const Key('login_button')));
        await tester.pumpAndSettle();

        // Should be on dashboard
        expect(find.text('Dashboard'), findsOneWidget);

        // Open user menu and logout
        await tester.tap(find.byIcon(Icons.account_circle));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Logout'));
        await tester.pumpAndSettle();

        // Should return to login page
        expect(find.text('Login'), findsOneWidget);
        expect(find.byType(TextField), findsNWidgets(2));

        verify(mockAuthService.logout()).called(1);
      });
    });

    group('Session Management', () {
      testWidgets('should handle token refresh', (WidgetTester tester) async {
        // Mock initial login
        when(mockAuthService.login(any)).thenAnswer((_) async => LoginResponse(
          accessToken: 'initial-token',
          refreshToken: 'refresh-token',
          user: User(
            id: 'test-user-id',
            email: 'test@example.com',
            name: 'Test User',
            createdAt: DateTime.now(),
            isActive: true,
            role: UserRole.user,
          ),
          expiresIn: 3600,
        ));

        // Mock token refresh
        when(mockAuthService.refreshToken()).thenAnswer((_) async => LoginResponse(
          accessToken: 'new-access-token',
          refreshToken: 'new-refresh-token',
          user: User(
            id: 'test-user-id',
            email: 'test@example.com',
            name: 'Test User',
            createdAt: DateTime.now(),
            isActive: true,
            role: UserRole.user,
          ),
          expiresIn: 3600,
        ));

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MyApp(),
          ),
        );

        await tester.pumpAndSettle();

        // Login
        await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
        await tester.enterText(find.byKey(const Key('password_field')), 'password123');
        await tester.tap(find.byKey(const Key('login_button')));
        await tester.pumpAndSettle();

        // Simulate token expiration and API call
        // This would typically be triggered by an API call getting 401 response
        container.read(authProvider.notifier).refreshTokens();
        await tester.pumpAndSettle();

        // Should still be authenticated
        expect(find.text('Dashboard'), findsOneWidget);

        verify(mockAuthService.refreshToken()).called(1);
      });

      testWidgets('should handle expired refresh token', (WidgetTester tester) async {
        // Mock login
        when(mockAuthService.login(any)).thenAnswer((_) async => LoginResponse(
          accessToken: 'access-token',
          refreshToken: 'refresh-token',
          user: User(
            id: 'test-user-id',
            email: 'test@example.com',
            name: 'Test User',
            createdAt: DateTime.now(),
            isActive: true,
            role: UserRole.user,
          ),
          expiresIn: 3600,
        ));

        // Mock refresh token failure
        when(mockAuthService.refreshToken()).thenThrow(Exception('Refresh token expired'));

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MyApp(),
          ),
        );

        await tester.pumpAndSettle();

        // Login
        await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
        await tester.enterText(find.byKey(const Key('password_field')), 'password123');
        await tester.tap(find.byKey(const Key('login_button')));
        await tester.pumpAndSettle();

        // Simulate refresh token failure
        container.read(authProvider.notifier).refreshTokens();
        await tester.pumpAndSettle();

        // Should redirect to login
        expect(find.text('Login'), findsOneWidget);
      });
    });

    group('Forgot Password Flow', () {
      testWidgets('should send password reset email', (WidgetTester tester) async {
        when(mockAuthService.requestPasswordReset(any)).thenAnswer((_) async => {});

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MyApp(),
          ),
        );

        await tester.pumpAndSettle();

        // Go to forgot password page
        await tester.tap(find.text('Forgot Password?'));
        await tester.pumpAndSettle();

        expect(find.text('Reset Password'), findsOneWidget);

        // Enter email
        await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
        await tester.tap(find.byKey(const Key('reset_button')));
        await tester.pumpAndSettle();

        // Should show success message
        expect(find.textContaining('reset link sent'), findsOneWidget);

        verify(mockAuthService.requestPasswordReset(any)).called(1);
      });
    });

    group('Two-Factor Authentication', () {
      testWidgets('should handle 2FA setup flow', (WidgetTester tester) async {
        // Mock login requiring 2FA
        when(mockAuthService.login(any)).thenAnswer((_) async => LoginResponse(
          accessToken: 'temp-token',
          refreshToken: 'temp-refresh',
          user: User(
            id: 'test-user-id',
            email: 'test@example.com',
            name: 'Test User',
            createdAt: DateTime.now(),
            isActive: true,
            role: UserRole.user,
          ),
          expiresIn: 3600,
          requiresTwoFactor: true,
        ));

        when(mockAuthService.verifyTwoFactor(any, any)).thenAnswer((_) async => LoginResponse(
          accessToken: 'final-token',
          refreshToken: 'final-refresh',
          user: User(
            id: 'test-user-id',
            email: 'test@example.com',
            name: 'Test User',
            createdAt: DateTime.now(),
            isActive: true,
            role: UserRole.user,
          ),
          expiresIn: 3600,
          requiresTwoFactor: false,
        ));

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MyApp(),
          ),
        );

        await tester.pumpAndSettle();

        // Login
        await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
        await tester.enterText(find.byKey(const Key('password_field')), 'password123');
        await tester.tap(find.byKey(const Key('login_button')));
        await tester.pumpAndSettle();

        // Should show 2FA verification page
        expect(find.text('Two-Factor Authentication'), findsOneWidget);

        // Enter 2FA code
        await tester.enterText(find.byKey(const Key('2fa_code_field')), '123456');
        await tester.tap(find.byKey(const Key('verify_2fa_button')));
        await tester.pumpAndSettle();

        // Should complete login
        expect(find.text('Dashboard'), findsOneWidget);

        verify(mockAuthService.verifyTwoFactor(any, '123456')).called(1);
      });
    });
  });
}