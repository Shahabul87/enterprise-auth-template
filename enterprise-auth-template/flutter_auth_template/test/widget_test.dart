import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_auth_template/app/app.dart';

void main() {
  testWidgets('App should load without errors', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: FlutterAuthApp()));

    // Wait for async operations
    await tester.pumpAndSettle();

    // Verify that the app loads without throwing exceptions
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}