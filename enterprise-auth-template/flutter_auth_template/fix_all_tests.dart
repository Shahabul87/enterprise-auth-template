#!/usr/bin/env dart
/// Script to fix all test issues in the Flutter auth template
/// Addresses:
/// 1. Mock Dependencies: Missing or incorrect mocks
/// 2. Model/Entity Mismatches: User model properties and AuthState fields
/// 3. API Changes: Service method signatures
/// 4. Testing Framework Issues: Mockito setup and Riverpod API

import 'dart:io';

void main() async {
  print('🔧 Flutter Test Fixer Script');
  print('=' * 50);

  // Step 1: Fix User model issues - Add missing properties
  await fixUserModel();

  // Step 2: Fix AuthState issues
  await fixAuthState();

  // Step 3: Fix test imports
  await fixTestImports();

  // Step 4: Fix mock annotations
  await fixMockAnnotations();

  // Step 5: Regenerate freezed and mocks
  await regenerateCode();

  // Step 6: Fix API method signatures
  await fixApiSignatures();

  print('✅ All fixes completed!');
  print('Run: flutter test to verify');
}

Future<void> fixUserModel() async {
  print('\n📝 Fixing User model...');

  final userFile = File('lib/domain/entities/user.dart');
  if (!await userFile.exists()) {
    print('❌ User model not found');
    return;
  }

  var content = await userFile.readAsString();

  // Check if properties are missing
  if (!content.contains('bool? isActive')) {
    print('  → Adding isActive property');
    content = content.replaceFirst(
      'required bool isEmailVerified,',
      '''required bool isEmailVerified,

    /// Whether the user account is active.
    /// Inactive accounts cannot login.
    @Default(true) bool? isActive,'''
    );
  }

  if (!content.contains('String? role,')) {
    print('  → Adding role property for backward compatibility');
    content = content.replaceFirst(
      'required List<String> roles,',
      '''required List<String> roles,

    /// Single role for backward compatibility.
    /// @deprecated Use roles list instead
    String? role,'''
    );
  }

  await userFile.writeAsString(content);
  print('  ✓ User model fixed');
}

Future<void> fixAuthState() async {
  print('\n📝 Fixing AuthState...');

  final authStateFile = File('lib/domain/entities/auth_state.dart');
  if (!await authStateFile.exists()) {
    print('❌ AuthState not found');
    return;
  }

  var content = await authStateFile.readAsString();

  // Ensure all required methods are present
  if (!content.contains('AuthState.loading()')) {
    print('  → Adding loading state');
    content = content.replaceFirst(
      'const factory AuthState.authenticating() = Authenticating;',
      '''const factory AuthState.authenticating() = Authenticating;

  /// Alias for authenticating state for compatibility
  const factory AuthState.loading() = Authenticating;'''
    );
  }

  await authStateFile.writeAsString(content);
  print('  ✓ AuthState fixed');
}

Future<void> fixTestImports() async {
  print('\n📝 Fixing test imports...');

  final testDir = Directory('test');
  if (!await testDir.exists()) {
    print('❌ Test directory not found');
    return;
  }

  await for (final file in testDir.list(recursive: true)) {
    if (file is File && file.path.endsWith('.dart') && !file.path.endsWith('.mocks.dart')) {
      var content = await file.readAsString();
      var modified = false;

      // Fix auth service imports
      if (content.contains("import 'package:flutter_auth_template/data/services/auth_service.dart';")) {
        content = content.replaceAll(
          "import 'package:flutter_auth_template/data/services/auth_service.dart';",
          "import 'package:flutter_auth_template/infrastructure/services/auth/auth_service.dart';"
        );
        modified = true;
      }

      // Fix OAuth service imports
      if (content.contains("import 'package:flutter_auth_template/core/security/oauth_service.dart';")) {
        content = content.replaceAll(
          "import 'package:flutter_auth_template/core/security/oauth_service.dart';",
          "import 'package:flutter_auth_template/infrastructure/services/auth/oauth_service.dart';"
        );
        modified = true;
      }

      // Fix provider imports
      if (content.contains("secureStorageProvider.overrideWithValue")) {
        content = content.replaceAll(
          "secureStorageProvider.overrideWithValue",
          "secureStorageServiceProvider.overrideWithValue"
        );
        modified = true;
      }

      if (modified) {
        await file.writeAsString(content);
        print('  ✓ Fixed imports in ${file.path}');
      }
    }
  }
}

Future<void> fixMockAnnotations() async {
  print('\n📝 Fixing mock annotations...');

  final testDir = Directory('test');
  if (!await testDir.exists()) {
    print('❌ Test directory not found');
    return;
  }

  await for (final file in testDir.list(recursive: true)) {
    if (file is File && file.path.endsWith('.dart') && !file.path.endsWith('.mocks.dart')) {
      var content = await file.readAsString();
      var modified = false;

      // Remove FlutterSecureStorage from mocks (not mockable directly)
      if (content.contains('@GenerateMocks([') && content.contains('FlutterSecureStorage')) {
        content = content.replaceAllMapped(
          RegExp(r'@GenerateMocks\(\[(.*?)\]\)'),
          (match) {
            var classes = match.group(1)!;
            classes = classes.replaceAll(', FlutterSecureStorage', '');
            classes = classes.replaceAll('FlutterSecureStorage, ', '');
            classes = classes.replaceAll('FlutterSecureStorage', '');
            return '@GenerateMocks([$classes])';
          }
        );
        modified = true;
      }

      // Fix duplicate mock names
      if (content.contains('MockAuthNotifier') && content.contains('@GenerateMocks')) {
        if (content.contains('class MockAuthNotifier')) {
          content = content.replaceAll(
            '@GenerateMocks([AuthNotifier',
            '@GenerateMocks([' // Remove AuthNotifier from GenerateMocks
          );
          modified = true;
        }
      }

      if (modified) {
        await file.writeAsString(content);
        print('  ✓ Fixed mock annotations in ${file.path}');
      }
    }
  }
}

Future<void> fixApiSignatures() async {
  print('\n📝 Fixing API signatures in tests...');

  final testDir = Directory('test');
  if (!await testDir.exists()) {
    print('❌ Test directory not found');
    return;
  }

  await for (final file in testDir.list(recursive: true)) {
    if (file is File && file.path.endsWith('_test.dart')) {
      var content = await file.readAsString();
      var modified = false;

      // Fix login method calls
      if (content.contains('authNotifier.login(request)')) {
        content = content.replaceAllMapped(
          RegExp(r'authNotifier\.login\(request\)'),
          (match) => 'authNotifier.login(email, password)'
        );
        modified = true;
      }

      // Fix register method calls
      if (content.contains('authNotifier.register(request)')) {
        content = content.replaceAllMapped(
          RegExp(r'authNotifier\.register\(request\)'),
          (match) => 'authNotifier.register(email, password, name)'
        );
        modified = true;
      }

      // Fix AuthState.authenticated constructor
      if (content.contains('AuthState.authenticated(mockUser)')) {
        content = content.replaceAll(
          'AuthState.authenticated(mockUser)',
          "AuthState.authenticated(user: mockUser, accessToken: 'test-token')"
        );
        modified = true;
      }

      // Fix ApiResponse.error constructor
      if (content.contains('ApiResponse<User>.error(')) {
        content = content.replaceAll(
          RegExp(r'ApiResponse<User>\.error\(([^,]+), ([^)]+)\)'),
          r"ApiResponse<User>.error(message: $1, code: $2)"
        );
        modified = true;
      }

      if (modified) {
        await file.writeAsString(content);
        print('  ✓ Fixed API signatures in ${file.path}');
      }
    }
  }
}

Future<void> regenerateCode() async {
  print('\n🔄 Regenerating code...');

  // Generate freezed files
  print('  → Generating freezed files...');
  final freezedResult = await Process.run(
    'flutter',
    ['pub', 'run', 'build_runner', 'build', '--delete-conflicting-outputs'],
    runInShell: true,
  );

  if (freezedResult.exitCode != 0) {
    print('  ⚠️ Warning: Some code generation issues occurred');
    print(freezedResult.stderr);
  } else {
    print('  ✓ Code generation complete');
  }
}

// Helper to process files in batches
Stream<File> findTestFiles(String pattern) async* {
  final testDir = Directory('test');
  if (await testDir.exists()) {
    await for (final entity in testDir.list(recursive: true)) {
      if (entity is File && entity.path.contains(pattern)) {
        yield entity;
      }
    }
  }
}