import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_auth_template/widgets/common/custom_text_field.dart';

void main() {
  group('CustomTextField Widget Tests', () {
    testWidgets('renders text field with label and hint', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              controller: controller,
              label: 'Email',
              hintText: 'Enter your email',
            ),
          ),
        ),
      );

      // Assert text field is rendered with correct label and hint
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Enter your email'), findsOneWidget);
    });

    testWidgets('accepts text input', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              controller: controller,
              label: 'Name',
            ),
          ),
        ),
      );

      // Enter text
      await tester.enterText(find.byType(TextFormField), 'Test User');
      
      // Assert text is in controller
      expect(controller.text, 'Test User');
    });

    testWidgets('shows validation error', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              child: CustomTextField(
                controller: controller,
                label: 'Email',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email is required';
                  }
                  return null;
                },
              ),
            ),
          ),
        ),
      );

      // Trigger validation by submitting empty field
      final formState = tester.state<FormState>(find.byType(Form));
      formState.validate();
      await tester.pump();

      // Assert validation error is shown
      expect(find.text('Email is required'), findsOneWidget);
    });

    testWidgets('obscures text when isPassword is true', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              controller: controller,
              label: 'Password',
              isPassword: true,
            ),
          ),
        ),
      );

      // Assert text field is obscured
      final textField = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.obscureText, isTrue);
    });

    testWidgets('shows password visibility toggle when isPassword is true', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              controller: controller,
              label: 'Password',
              isPassword: true,
            ),
          ),
        ),
      );

      // Assert visibility toggle is shown
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);

      // Tap visibility toggle
      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();

      // Assert password is now visible and icon changed
      final textField = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.obscureText, isFalse);
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('shows prefix icon when provided', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              controller: controller,
              label: 'Email',
              prefixIcon: Icons.email,
            ),
          ),
        ),
      );

      // Assert prefix icon is shown
      expect(find.byIcon(Icons.email), findsOneWidget);
    });

    testWidgets('calls onChanged callback', (WidgetTester tester) async {
      final controller = TextEditingController();
      String? changedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              controller: controller,
              label: 'Name',
              onChanged: (value) => changedValue = value,
            ),
          ),
        ),
      );

      // Enter text
      await tester.enterText(find.byType(TextFormField), 'Test');
      
      // Assert callback was called
      expect(changedValue, 'Test');
    });

    testWidgets('calls onSubmitted callback', (WidgetTester tester) async {
      final controller = TextEditingController();
      String? submittedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              controller: controller,
              label: 'Name',
              onSubmitted: (value) => submittedValue = value,
            ),
          ),
        ),
      );

      // Enter text and submit
      await tester.enterText(find.byType(TextFormField), 'Test');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      
      // Assert callback was called
      expect(submittedValue, 'Test');
    });

    testWidgets('uses correct keyboard type', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              controller: controller,
              label: 'Email',
              keyboardType: TextInputType.emailAddress,
            ),
          ),
        ),
      );

      // Assert keyboard type is set
      final textField = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.keyboardType, TextInputType.emailAddress);
    });

    testWidgets('uses correct text input action', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              controller: controller,
              label: 'Name',
              textInputAction: TextInputAction.next,
            ),
          ),
        ),
      );

      // Assert text input action is set
      final textField = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.textInputAction, TextInputAction.next);
    });

    testWidgets('applies enabled state correctly', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              controller: controller,
              label: 'Disabled Field',
              enabled: false,
            ),
          ),
        ),
      );

      // Assert field is disabled
      final textField = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.enabled, isFalse);
    });

    testWidgets('supports multiline text', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              controller: controller,
              label: 'Description',
              maxLines: 3,
            ),
          ),
        ),
      );

      // Assert multiline support
      final textField = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.maxLines, 3);
    });

    testWidgets('supports character limit', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              controller: controller,
              label: 'Short Text',
              maxLength: 10,
            ),
          ),
        ),
      );

      // Assert max length is set
      final textField = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.maxLength, 10);
    });

    testWidgets('shows error state styling', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              child: CustomTextField(
                controller: controller,
                label: 'Email',
                validator: (value) => 'Invalid email',
              ),
            ),
          ),
        ),
      );

      // Trigger validation
      final formState = tester.state<FormState>(find.byType(Form));
      formState.validate();
      await tester.pump();

      // Assert error styling is applied
      expect(find.text('Invalid email'), findsOneWidget);
      
      final textField = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.decoration?.errorText, 'Invalid email');
    });
  });
}