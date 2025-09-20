#!/usr/bin/env dart
// Script to fix common compilation errors in Flutter tests

import 'dart:io';
import 'dart:convert';

void main() async {
  print('Starting test compilation error fixes...');

  // Common fixes for User and AuthState constructors
  await fixUserConstructors();
  await fixAuthStateConstructors();
  await fixMockitoIssues();
  await fixDeprecatedAPIs();

  print('Fixes applied. Running flutter analyze to check...');
  final result = await Process.run('flutter', ['analyze', 'test/']);
  print(result.stdout);
}

Future<void> fixUserConstructors() async {
  print('Fixing User constructor calls...');

  final testFiles = await findTestFiles();

  for (final file in testFiles) {
    var content = await File(file).readAsString();
    var modified = false;

    // Fix User constructor missing required fields
    // Pattern: User(id: ..., email: ..., name: ...)
    final userPattern = RegExp(
      r'User\s*\(\s*id:\s*[^,]+,\s*email:\s*[^,]+,\s*name:\s*[^,)]+\)',
      multiLine: true,
    );

    content = content.replaceAllMapped(userPattern, (match) {
      modified = true;
      final original = match.group(0)!;
      // Extract existing parameters
      final idMatch = RegExp(r'id:\s*([^,]+)').firstMatch(original);
      final emailMatch = RegExp(r'email:\s*([^,]+)').firstMatch(original);
      final nameMatch = RegExp(r'name:\s*([^,)]+)').firstMatch(original);

      final id = idMatch?.group(1) ?? "'test-id'";
      final email = emailMatch?.group(1) ?? "'test@example.com'";
      final name = nameMatch?.group(1) ?? "'Test User'";

      return '''User(
        id: $id,
        email: $email,
        name: $name,
        isEmailVerified: false,
        isTwoFactorEnabled: false,
        roles: ['user'],
        permissions: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      )''';
    });

    // Fix const User calls
    content = content.replaceAll('const User(', 'User(');

    if (modified) {
      await File(file).writeAsString(content);
      print('Fixed: $file');
    }
  }
}

Future<void> fixAuthStateConstructors() async {
  print('Fixing AuthState constructor calls...');

  final testFiles = await findTestFiles();

  for (final file in testFiles) {
    var content = await File(file).readAsString();
    var modified = false;

    // Fix AuthState.authenticated missing accessToken
    final authPattern = RegExp(
      r'AuthState\.authenticated\s*\(\s*user:\s*[^,)]+\s*\)',
      multiLine: true,
    );

    content = content.replaceAllMapped(authPattern, (match) {
      modified = true;
      final original = match.group(0)!;
      final userMatch = RegExp(r'user:\s*([^,)]+)').firstMatch(original);
      final user = userMatch?.group(1) ?? 'testUser';

      return 'AuthState.authenticated(user: $user, accessToken: "test-token")';
    });

    if (modified) {
      await File(file).writeAsString(content);
      print('Fixed: $file');
    }
  }
}

Future<void> fixMockitoIssues() async {
  print('Fixing Mockito issues...');

  final testFiles = await findTestFiles();

  for (final file in testFiles) {
    var content = await File(file).readAsString();
    var modified = false;

    // Fix deprecated parent property
    content = content.replaceAll('.parent', '');
    modified = content.contains('.parent');

    // Fix deprecated value property on Color
    content = content.replaceAll('.value', '.toARGB32');

    if (modified) {
      await File(file).writeAsString(content);
      print('Fixed: $file');
    }
  }
}

Future<void> fixDeprecatedAPIs() async {
  print('Fixing deprecated APIs...');

  final testFiles = await findTestFiles();

  for (final file in testFiles) {
    var content = await File(file).readAsString();
    var modified = false;

    // Fix GoRouter configuration access
    content = content.replaceAll('.configuration', '.config');

    // Fix FlutterExceptionHandler type
    content = content.replaceAll(
      'FlutterExceptionHandler?',
      'void Function(Object, StackTrace?)?'
    );

    if (content.contains('.config') || content.contains('void Function(Object, StackTrace?)')) {
      modified = true;
      await File(file).writeAsString(content);
      print('Fixed: $file');
    }
  }
}

Future<List<String>> findTestFiles() async {
  final result = await Process.run(
    'find',
    ['test', '-name', '*.dart', '-type', 'f'],
  );

  return LineSplitter.split(result.stdout)
      .where((line) => line.isNotEmpty)
      .where((line) => !line.endsWith('.mocks.dart'))
      .toList();
}