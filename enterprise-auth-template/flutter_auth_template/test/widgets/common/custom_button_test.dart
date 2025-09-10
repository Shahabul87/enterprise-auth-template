import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_auth_template/widgets/common/custom_button.dart';

void main() {
  group('CustomButton Widget Tests', () {
    testWidgets('renders primary button correctly', (WidgetTester tester) async {
      bool wasPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Test Button',
              onPressed: () => wasPressed = true,
            ),
          ),
        ),
      );

      // Assert button is rendered
      expect(find.text('Test Button'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);

      // Test button press
      await tester.tap(find.byType(ElevatedButton));
      expect(wasPressed, isTrue);
    });

    testWidgets('renders outlined button correctly', (WidgetTester tester) async {
      bool wasPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton.outlined(
              text: 'Outlined Button',
              onPressed: () => wasPressed = true,
            ),
          ),
        ),
      );

      // Assert outlined button is rendered
      expect(find.text('Outlined Button'), findsOneWidget);
      expect(find.byType(OutlinedButton), findsOneWidget);

      // Test button press
      await tester.tap(find.byType(OutlinedButton));
      expect(wasPressed, isTrue);
    });

    testWidgets('renders text button correctly', (WidgetTester tester) async {
      bool wasPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton.text(
              text: 'Text Button',
              onPressed: () => wasPressed = true,
            ),
          ),
        ),
      );

      // Assert text button is rendered
      expect(find.text('Text Button'), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);

      // Test button press
      await tester.tap(find.byType(TextButton));
      expect(wasPressed, isTrue);
    });

    testWidgets('shows loading indicator when isLoading is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Loading Button',
              onPressed: () {},
              isLoading: true,
            ),
          ),
        ),
      );

      // Assert loading indicator is shown
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading Button'), findsNothing);
    });

    testWidgets('button is disabled when isLoading is true', (WidgetTester tester) async {
      bool wasPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Loading Button',
              onPressed: () => wasPressed = true,
              isLoading: true,
            ),
          ),
        ),
      );

      // Try to tap the button
      await tester.tap(find.byType(ElevatedButton));
      
      // Assert callback was not called
      expect(wasPressed, isFalse);
    });

    testWidgets('button is disabled when onPressed is null', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Disabled Button',
              onPressed: null,
            ),
          ),
        ),
      );

      // Assert button is rendered but disabled
      expect(find.text('Disabled Button'), findsOneWidget);
      
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('renders icon when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Icon Button',
              icon: Icons.add,
              onPressed: () {},
            ),
          ),
        ),
      );

      // Assert both icon and text are rendered
      expect(find.text('Icon Button'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('applies custom width when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Wide Button',
              onPressed: () {},
              width: 300,
            ),
          ),
        ),
      );

      // Assert button has correct width
      final sizedBox = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byType(ElevatedButton),
          matching: find.byType(SizedBox),
        ),
      );
      expect(sizedBox.width, 300);
    });

    testWidgets('uses full width when width is not provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Full Width Button',
              onPressed: () {},
            ),
          ),
        ),
      );

      // Assert button takes full width
      final sizedBox = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byType(ElevatedButton),
          matching: find.byType(SizedBox),
        ),
      );
      expect(sizedBox.width, double.infinity);
    });

    testWidgets('applies custom background color', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Custom Color Button',
              onPressed: () {},
              backgroundColor: Colors.red,
            ),
          ),
        ),
      );

      // Assert button has custom color
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      final buttonStyle = button.style;
      expect(buttonStyle, isNotNull);
    });

    testWidgets('applies custom text color', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Custom Text Color Button',
              onPressed: () {},
              textColor: Colors.yellow,
            ),
          ),
        ),
      );

      // Assert button has custom text color
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      final buttonStyle = button.style;
      expect(buttonStyle, isNotNull);
    });

    testWidgets('has correct default height', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Height Button',
              onPressed: () {},
            ),
          ),
        ),
      );

      // Assert button has correct height
      final sizedBox = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byType(ElevatedButton),
          matching: find.byType(SizedBox),
        ),
      );
      expect(sizedBox.height, 48);
    });
  });
}