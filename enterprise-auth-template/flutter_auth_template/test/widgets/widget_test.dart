import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Widget Tests', () {
    testWidgets('should create and test a simple widget', (tester) async {
      // Arrange
      const widget = MaterialApp(
        home: Scaffold(
          body: Text('Hello World'),
        ),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert
      expect(find.text('Hello World'), findsOneWidget);
    });

    testWidgets('should test button tap', (tester) async {
      // Arrange
      int counter = 0;
      final widget = MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                children: [
                  Text('Counter: $counter'),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        counter++;
                      });
                    },
                    child: const Text('Increment'),
                  ),
                ],
              );
            },
          ),
        ),
      );

      // Act
      await tester.pumpWidget(widget);
      expect(find.text('Counter: 0'), findsOneWidget);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Assert
      expect(find.text('Counter: 1'), findsOneWidget);
    });
  });
}