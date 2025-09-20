import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_auth_template/presentation/widgets/auth/enhanced_login_form.dart';
import 'package:flutter_auth_template/presentation/providers/auth_provider.dart';
import 'package:flutter_auth_template/infrastructure/services/auth/biometric_service.dart';
import 'package:flutter_auth_template/infrastructure/services/auth/oauth_service.dart';
import 'package:flutter_auth_template/core/storage/secure_storage_service.dart';
import 'package:flutter_auth_template/domain/entities/auth_state.dart';
import 'package:flutter_auth_template/core/network/api_response.dart';
import 'package:local_auth/local_auth.dart';

import 'enhanced_login_form_test.mocks.dart';

@GenerateMocks([
  AuthNotifier,
  BiometricService,
  OAuthService,
  SecureStorageService,
])
void main() {
  late MockAuthNotifier mockAuthNotifier;
  late MockBiometricService mockBiometricService;
  late MockOAuthService mockOAuthService;
  late MockSecureStorageService mockSecureStorage;

  setUp(() {
    mockAuthNotifier = MockAuthNotifier();
    mockBiometricService = MockBiometricService();
    mockOAuthService = MockOAuthService();
    mockSecureStorage = MockSecureStorageService();

    // Set up default stubs
    when(mockAuthNotifier.state).thenReturn(const AuthState.unauthenticated());
  });

  Widget createWidgetUnderTest({
    VoidCallback? onSuccess,
    VoidCallback? onForgotPassword,
    VoidCallback? onRegister,
  }) {
    return ProviderScope(
      overrides: [
        authStateProvider.overrideWith((ref) => mockAuthNotifier),
        biometricServiceProvider.overrideWithValue(mockBiometricService),
        oauthServiceProvider.overrideWithValue(mockOAuthService),
        secureStorageServiceProvider.overrideWithValue(mockSecureStorage),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: EnhancedLoginForm(
            onSuccess: onSuccess,
            onForgotPassword: onForgotPassword,
            onRegister: onRegister,
          ),
        ),
      ),
    );
  }

  group('EnhancedLoginForm', () {
    testWidgets('should display email and password fields', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('should display login button', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('should show error for invalid email', (tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      await tester.enterText(find.byType(TextFormField).first, 'invalid-email');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Assert
      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('should show error for empty password', (tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Assert
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('should call login with valid credentials', (tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Assert
      verify(mockAuthNotifier.login('test@example.com', 'password123')).called(1);
    });

    testWidgets('should display biometric button when available', (tester) async {
      // Arrange
      when(mockBiometricService.isBiometricAuthEnabled())
          .thenAnswer((_) async => true);
      when(mockBiometricService.checkBiometricAvailability())
          .thenAnswer((_) async => const ApiResponse.success(
                data: BiometricAvailability(
                  isAvailable: true,
                  availableBiometrics: [BiometricType.fingerprint],
                ),
              ));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(); // Wait for async operations

      // Assert
      expect(find.byIcon(Icons.fingerprint), findsOneWidget);
    });

    testWidgets('should display OAuth buttons', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Or continue with'), findsOneWidget);
      // Social buttons should be visible
      expect(find.byType(OutlinedButton), findsWidgets);
    });

    testWidgets('should navigate to forgot password when link is tapped',
        (tester) async {
      // Arrange
      bool forgotPasswordCalled = false;
      await tester.pumpWidget(createWidgetUnderTest(
        onForgotPassword: () => forgotPasswordCalled = true,
      ));

      // Act
      await tester.tap(find.text('Forgot password?'));
      await tester.pump();

      // Assert
      expect(forgotPasswordCalled, true);
    });

    testWidgets('should navigate to register when link is tapped',
        (tester) async {
      // Arrange
      bool registerCalled = false;
      await tester.pumpWidget(createWidgetUnderTest(
        onRegister: () => registerCalled = true,
      ));

      // Act
      await tester.tap(find.text("Don't have an account? Sign up"));
      await tester.pump();

      // Assert
      expect(registerCalled, true);
    });

    testWidgets('should show loading indicator during login', (tester) async {
      // Arrange
      when(mockAuthNotifier.login(any, any)).thenAnswer((_) async {
        await Future.delayed(const Duration(seconds: 1));
      });

      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should toggle password visibility', (tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Initially should show visibility icon (password is obscured)
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off_outlined), findsNothing);

      // Act - tap the visibility toggle
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();

      // Assert - should show visibility_off icon (password is visible)
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
      expect(find.byIcon(Icons.visibility_outlined), findsNothing);
    });
  });
}