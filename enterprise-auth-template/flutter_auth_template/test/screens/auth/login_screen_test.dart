import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:flutter_auth_template/screens/auth/login_screen.dart';
import 'package:flutter_auth_template/providers/auth_provider.dart';
import 'package:flutter_auth_template/data/models/auth_state.dart';
import 'package:flutter_auth_template/data/models/user.dart';
import 'package:flutter_auth_template/core/network/api_response.dart';

import 'login_screen_test.mocks.dart';

@GenerateMocks([AuthNotifier])
void main() {
  group('LoginScreen Widget Tests', () {
    late MockAuthNotifier mockAuthNotifier;

    setUp(() {
      mockAuthNotifier = MockAuthNotifier();
    });

    Widget createTestWidget() {
      return ProviderScope(
        overrides: [
          authStateProvider.overrideWith((ref) => mockAuthNotifier),
        ],
        child: MaterialApp(
          home: const LoginScreen(),
        ),
      );
    }

    testWidgets('displays login form with all required fields', (WidgetTester tester) async {
      // Arrange
      when(mockAuthNotifier.state).thenReturn(const AuthState.initial());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2)); // Email and password fields
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text('Don\'t have an account? '), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
    });

    testWidgets('shows validation errors for empty fields', (WidgetTester tester) async {
      // Arrange
      when(mockAuthNotifier.state).thenReturn(const AuthState.initial());

      // Act
      await tester.pumpWidget(createTestWidget());
      
      // Find and tap the login button without filling fields
      final loginButton = find.widgetWithText(ElevatedButton, 'Login');
      await tester.tap(loginButton);
      await tester.pump(); // Trigger validation

      // Assert
      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('shows email validation error for invalid email', (WidgetTester tester) async {
      // Arrange
      when(mockAuthNotifier.state).thenReturn(const AuthState.initial());

      // Act
      await tester.pumpWidget(createTestWidget());
      
      // Enter invalid email
      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'invalid-email');
      
      // Tap login to trigger validation
      final loginButton = find.widgetWithText(ElevatedButton, 'Login');
      await tester.tap(loginButton);
      await tester.pump();

      // Assert
      expect(find.text('Please enter a valid email address'), findsOneWidget);
    });

    testWidgets('calls login method when form is valid and submitted', (WidgetTester tester) async {
      // Arrange
      when(mockAuthNotifier.state).thenReturn(const AuthState.initial());
      when(mockAuthNotifier.login(any)).thenAnswer((_) async {});

      // Act
      await tester.pumpWidget(createTestWidget());
      
      // Enter valid credentials
      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).at(1);
      
      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'password123');
      
      // Submit form
      final loginButton = find.widgetWithText(ElevatedButton, 'Login');
      await tester.tap(loginButton);
      await tester.pump();

      // Assert
      verify(mockAuthNotifier.login(any)).called(1);
    });

    testWidgets('shows loading state during login', (WidgetTester tester) async {
      // Arrange
      when(mockAuthNotifier.state).thenReturn(const AuthState.loading());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error message when login fails', (WidgetTester tester) async {
      // Arrange
      const errorMessage = 'Invalid credentials';
      when(mockAuthNotifier.state).thenReturn(const AuthState.error(errorMessage));

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump(); // Allow error to be displayed

      // Assert
      expect(find.text(errorMessage), findsOneWidget);
    });

    testWidgets('calls Google OAuth when Google sign-in button is tapped', (WidgetTester tester) async {
      // Arrange
      when(mockAuthNotifier.state).thenReturn(const AuthState.initial());
      when(mockAuthNotifier.signInWithGoogle()).thenAnswer((_) async {});

      // Act
      await tester.pumpWidget(createTestWidget());
      
      final googleButton = find.text('Continue with Google');
      await tester.tap(googleButton);
      await tester.pump();

      // Assert
      verify(mockAuthNotifier.signInWithGoogle()).called(1);
    });

    testWidgets('toggles password visibility when visibility icon is tapped', (WidgetTester tester) async {
      // Arrange
      when(mockAuthNotifier.state).thenReturn(const AuthState.initial());

      // Act
      await tester.pumpWidget(createTestWidget());
      
      // Find password field and visibility toggle
      final passwordField = find.byType(TextFormField).at(1);
      final visibilityIcon = find.descendant(
        of: passwordField,
        matching: find.byIcon(Icons.visibility_off),
      );

      // Initially password should be obscured
      TextFormField passwordWidget = tester.widget(passwordField);
      expect(passwordWidget.obscureText, isTrue);

      // Tap visibility icon
      await tester.tap(visibilityIcon);
      await tester.pump();

      // Password should now be visible
      passwordWidget = tester.widget(passwordField);
      expect(passwordWidget.obscureText, isFalse);
    });

    testWidgets('navigates to registration when Sign Up is tapped', (WidgetTester tester) async {
      // Arrange
      when(mockAuthNotifier.state).thenReturn(const AuthState.initial());

      // Act
      await tester.pumpWidget(createTestWidget());
      
      final signUpButton = find.text('Sign Up');
      await tester.tap(signUpButton);
      await tester.pumpAndSettle();

      // Assert - This would normally test navigation
      // In a real app, you'd mock GoRouter or test navigation differently
    });

    testWidgets('shows forgot password link', (WidgetTester tester) async {
      // Arrange
      when(mockAuthNotifier.state).thenReturn(const AuthState.initial());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Forgot Password?'), findsOneWidget);
    });

    testWidgets('disables login button when loading', (WidgetTester tester) async {
      // Arrange
      when(mockAuthNotifier.state).thenReturn(const AuthState.loading());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      final loginButton = find.widgetWithText(ElevatedButton, 'Login');
      final button = tester.widget<ElevatedButton>(loginButton);
      expect(button.onPressed, isNull); // Button should be disabled
    });
  });
}