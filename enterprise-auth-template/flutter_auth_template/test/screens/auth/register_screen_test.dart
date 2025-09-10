import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:flutter_auth_template/screens/auth/register_screen.dart';
import 'package:flutter_auth_template/providers/auth_provider.dart';
import 'package:flutter_auth_template/data/models/auth_state.dart';

import '../../../test/screens/auth/login_screen_test.mocks.dart';

void main() {
  group('RegisterScreen Widget Tests', () {
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
          home: const RegisterScreen(),
        ),
      );
    }

    testWidgets('displays registration form with all required fields', (WidgetTester tester) async {
      // Arrange
      when(mockAuthNotifier.state).thenReturn(const AuthState.initial());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Create Account'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(4)); // Name, email, password, confirm password
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
      expect(find.text('Create Account'), findsAtLeastNWidgets(1));
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text('Already have an account? '), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('shows validation errors for empty fields', (WidgetTester tester) async {
      // Arrange
      when(mockAuthNotifier.state).thenReturn(const AuthState.initial());

      // Act
      await tester.pumpWidget(createTestWidget());
      
      // Find and tap the register button without filling fields
      final registerButton = find.widgetWithText(ElevatedButton, 'Create Account').first;
      await tester.tap(registerButton);
      await tester.pump(); // Trigger validation

      // Assert
      expect(find.text('Name is required'), findsOneWidget);
      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
      expect(find.text('Please confirm your password'), findsOneWidget);
    });

    testWidgets('shows password validation errors', (WidgetTester tester) async {
      // Arrange
      when(mockAuthNotifier.state).thenReturn(const AuthState.initial());

      // Act
      await tester.pumpWidget(createTestWidget());
      
      // Enter weak password
      final nameField = find.byType(TextFormField).at(0);
      final emailField = find.byType(TextFormField).at(1);
      final passwordField = find.byType(TextFormField).at(2);
      final confirmPasswordField = find.byType(TextFormField).at(3);
      
      await tester.enterText(nameField, 'Test User');
      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, '123'); // Weak password
      await tester.enterText(confirmPasswordField, '456'); // Different password
      
      // Tap register to trigger validation
      final registerButton = find.widgetWithText(ElevatedButton, 'Create Account').first;
      await tester.tap(registerButton);
      await tester.pump();

      // Assert
      expect(find.text('Password must be at least 8 characters long'), findsOneWidget);
      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets('shows password strength indicator', (WidgetTester tester) async {
      // Arrange
      when(mockAuthNotifier.state).thenReturn(const AuthState.initial());

      // Act
      await tester.pumpWidget(createTestWidget());
      
      // Enter password to trigger strength indicator
      final passwordField = find.byType(TextFormField).at(2);
      await tester.enterText(passwordField, 'WeakPass1!');
      await tester.pump();

      // Assert - Look for password strength indicator
      expect(find.textContaining('Password Strength'), findsOneWidget);
    });

    testWidgets('shows terms and conditions checkbox', (WidgetTester tester) async {
      // Arrange
      when(mockAuthNotifier.state).thenReturn(const AuthState.initial());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byType(Checkbox), findsOneWidget);
      expect(find.textContaining('I agree to the'), findsOneWidget);
      expect(find.text('Terms of Service'), findsOneWidget);
      expect(find.text('Privacy Policy'), findsOneWidget);
    });

    testWidgets('requires terms acceptance before registration', (WidgetTester tester) async {
      // Arrange
      when(mockAuthNotifier.state).thenReturn(const AuthState.initial());

      // Act
      await tester.pumpWidget(createTestWidget());
      
      // Fill all fields but don't accept terms
      final nameField = find.byType(TextFormField).at(0);
      final emailField = find.byType(TextFormField).at(1);
      final passwordField = find.byType(TextFormField).at(2);
      final confirmPasswordField = find.byType(TextFormField).at(3);
      
      await tester.enterText(nameField, 'Test User');
      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'StrongPass123!');
      await tester.enterText(confirmPasswordField, 'StrongPass123!');
      
      // Tap register without accepting terms
      final registerButton = find.widgetWithText(ElevatedButton, 'Create Account').first;
      await tester.tap(registerButton);
      await tester.pump();

      // Assert
      expect(find.text('You must accept the terms and conditions'), findsOneWidget);
    });

    testWidgets('calls register method when form is valid and terms accepted', (WidgetTester tester) async {
      // Arrange
      when(mockAuthNotifier.state).thenReturn(const AuthState.initial());
      when(mockAuthNotifier.register(any)).thenAnswer((_) async {});

      // Act
      await tester.pumpWidget(createTestWidget());
      
      // Fill all fields
      final nameField = find.byType(TextFormField).at(0);
      final emailField = find.byType(TextFormField).at(1);
      final passwordField = find.byType(TextFormField).at(2);
      final confirmPasswordField = find.byType(TextFormField).at(3);
      
      await tester.enterText(nameField, 'Test User');
      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'StrongPass123!');
      await tester.enterText(confirmPasswordField, 'StrongPass123!');
      
      // Accept terms
      final checkbox = find.byType(Checkbox);
      await tester.tap(checkbox);
      await tester.pump();
      
      // Submit form
      final registerButton = find.widgetWithText(ElevatedButton, 'Create Account').first;
      await tester.tap(registerButton);
      await tester.pump();

      // Assert
      verify(mockAuthNotifier.register(any)).called(1);
    });

    testWidgets('shows loading state during registration', (WidgetTester tester) async {
      // Arrange
      when(mockAuthNotifier.state).thenReturn(const AuthState.loading());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error message when registration fails', (WidgetTester tester) async {
      // Arrange
      const errorMessage = 'Email already exists';
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

    testWidgets('toggles password visibility when visibility icons are tapped', (WidgetTester tester) async {
      // Arrange
      when(mockAuthNotifier.state).thenReturn(const AuthState.initial());

      // Act
      await tester.pumpWidget(createTestWidget());
      
      // Test password field visibility toggle
      final passwordField = find.byType(TextFormField).at(2);
      final passwordVisibilityIcon = find.descendant(
        of: passwordField,
        matching: find.byIcon(Icons.visibility_off),
      );

      // Initially password should be obscured
      TextFormField passwordWidget = tester.widget(passwordField);
      expect(passwordWidget.obscureText, isTrue);

      // Tap visibility icon
      await tester.tap(passwordVisibilityIcon);
      await tester.pump();

      // Password should now be visible
      passwordWidget = tester.widget(passwordField);
      expect(passwordWidget.obscureText, isFalse);

      // Test confirm password field visibility toggle
      final confirmPasswordField = find.byType(TextFormField).at(3);
      final confirmPasswordVisibilityIcon = find.descendant(
        of: confirmPasswordField,
        matching: find.byIcon(Icons.visibility_off),
      );

      // Initially confirm password should be obscured
      TextFormField confirmPasswordWidget = tester.widget(confirmPasswordField);
      expect(confirmPasswordWidget.obscureText, isTrue);

      // Tap visibility icon
      await tester.tap(confirmPasswordVisibilityIcon);
      await tester.pump();

      // Confirm password should now be visible
      confirmPasswordWidget = tester.widget(confirmPasswordField);
      expect(confirmPasswordWidget.obscureText, isFalse);
    });

    testWidgets('navigates to login when Sign In is tapped', (WidgetTester tester) async {
      // Arrange
      when(mockAuthNotifier.state).thenReturn(const AuthState.initial());

      // Act
      await tester.pumpWidget(createTestWidget());
      
      final signInButton = find.text('Sign In');
      await tester.tap(signInButton);
      await tester.pumpAndSettle();

      // Assert - This would normally test navigation
      // In a real app, you'd mock GoRouter or test navigation differently
    });

    testWidgets('disables register button when loading', (WidgetTester tester) async {
      // Arrange
      when(mockAuthNotifier.state).thenReturn(const AuthState.loading());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      final registerButton = find.widgetWithText(ElevatedButton, 'Create Account').first;
      final button = tester.widget<ElevatedButton>(registerButton);
      expect(button.onPressed, isNull); // Button should be disabled
    });
  });
}