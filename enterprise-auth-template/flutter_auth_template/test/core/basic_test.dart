import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Basic Tests', () {
    test('should verify basic Dart functionality', () {
      // Arrange
      const expected = 'Hello World';

      // Act
      final result = 'Hello World';

      // Assert
      expect(result, equals(expected));
    });

    test('should work with lists', () {
      // Arrange
      final list = <String>[];

      // Act
      list.add('item1');
      list.add('item2');

      // Assert
      expect(list.length, equals(2));
      expect(list.first, equals('item1'));
      expect(list.last, equals('item2'));
    });

    test('should work with maps', () {
      // Arrange
      final map = <String, int>{};

      // Act
      map['key1'] = 1;
      map['key2'] = 2;

      // Assert
      expect(map.length, equals(2));
      expect(map['key1'], equals(1));
      expect(map['key2'], equals(2));
    });

    test('should work with async functions', () async {
      // Arrange
      Future<String> getData() async {
        await Future.delayed(const Duration(milliseconds: 10));
        return 'async data';
      }

      // Act
      final result = await getData();

      // Assert
      expect(result, equals('async data'));
    });
  });
}