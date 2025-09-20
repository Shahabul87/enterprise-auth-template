import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_auth_template/core/security/password_strength_analyzer.dart';

void main() {
  group('PasswordStrengthAnalyzer Tests', () {
    test('should identify very weak passwords', () {
      final testCases = [
        '',
        'abc',
        '123',
      ];

      for (final password in testCases) {
        final strength = PasswordStrengthAnalyzer.analyze(password);
        expect(
          strength.level,
          PasswordStrengthLevel.veryWeak,
          reason: 'Password "$password" should be very weak',
        );
        expect(strength.score, lessThanOrEqualTo(0.2));
      }
    });

    test('should identify weak passwords', () {
      final testCases = [
        'pass',
        '12345',
        'hello1',
      ];

      for (final password in testCases) {
        final strength = PasswordStrengthAnalyzer.analyze(password);
        expect(
          strength.level,
          isIn([PasswordStrengthLevel.veryWeak, PasswordStrengthLevel.weak, PasswordStrengthLevel.fair]),
          reason: 'Password "$password" should be weak to fair',
        );
        expect(strength.score, lessThan(0.6));
      }
    });

    test('should identify fair passwords', () {
      final testCases = [
        'Password1',
        'Test@123',
        'Hello123!',
      ];

      for (final password in testCases) {
        final strength = PasswordStrengthAnalyzer.analyze(password);
        expect(
          strength.level,
          isIn([PasswordStrengthLevel.fair, PasswordStrengthLevel.good, PasswordStrengthLevel.strong]),
          reason: 'Password "$password" should be fair to strong',
        );
      }
    });

    test('should identify strong passwords', () {
      final testCases = [
        'MyP@ssw0rd!2024',
        'C0mpl3x&Secure#',
        'Str0ng!Pass@Word',
        'T3st!ng_P@ssw0rd',
      ];

      for (final password in testCases) {
        final strength = PasswordStrengthAnalyzer.analyze(password);
        expect(
          strength.level,
          isIn([PasswordStrengthLevel.good, PasswordStrengthLevel.strong, PasswordStrengthLevel.veryStrong]),
          reason: 'Password "$password" should be good to very strong',
        );
        expect(strength.score, greaterThan(0.6));
      }
    });

    test('should identify very strong passwords', () {
      final testCases = [
        'MyV3ry!Str0ng@P@ssw0rd#2024',
        'C0mpl3x&S3cur3!P@ssw0rd\$123',
        'Un1qu3_P@ssw0rd!W1th#M@ny*Ch@rs',
      ];

      for (final password in testCases) {
        final strength = PasswordStrengthAnalyzer.analyze(password);
        expect(
          strength.level,
          isIn([PasswordStrengthLevel.strong, PasswordStrengthLevel.veryStrong]),
          reason: 'Password "$password" should be strong to very strong',
        );
        expect(strength.score, greaterThan(0.8));
      }
    });

    test('should detect common passwords', () {
      final commonPasswords = [
        'password',
        'password123',
        'qwerty',
        'admin',
        'letmein',
      ];

      for (final password in commonPasswords) {
        final strength = PasswordStrengthAnalyzer.analyze(password);
        expect(strength.score, lessThan(0.5),
            reason: 'Common password "$password" should have low score');
        expect(
          strength.feedback.any((f) =>
            f.toLowerCase().contains('common') ||
            f.toLowerCase().contains('weak') ||
            f.toLowerCase().contains('pattern')),
          isTrue,
          reason: 'Should identify "$password" as common/weak',
        );
      }
    });

    test('should detect keyboard patterns', () {
      final patterns = [
        'qwerty123',
        'asdfgh',
        '123456789',
        'zxcvbn',
      ];

      for (final password in patterns) {
        final strength = PasswordStrengthAnalyzer.analyze(password);
        expect(strength.score, lessThan(0.5));
      }
    });

    test('should detect sequential characters', () {
      final sequences = [
        'abc123',
        '123abc',
        'xyz789',
      ];

      for (final password in sequences) {
        final strength = PasswordStrengthAnalyzer.analyze(password);
        expect(strength.score, lessThan(0.6),
            reason: 'Sequential password "$password" should have lower score');
      }
    });

    test('should detect repeated patterns', () {
      final repeated = [
        'abcabc',
        '123123',
        'testtest',
      ];

      for (final password in repeated) {
        final strength = PasswordStrengthAnalyzer.analyze(password);
        expect(strength.score, lessThan(0.5));
      }
    });

    test('should provide appropriate feedback', () {
      // Short password
      var strength = PasswordStrengthAnalyzer.analyze('Pass1');
      expect(strength.feedback.any((f) => f.contains('short')), isTrue);
      expect(strength.suggestions.any((s) => s.contains('8 characters')), isTrue);

      // Missing uppercase
      strength = PasswordStrengthAnalyzer.analyze('password123!');
      expect(strength.feedback.any((f) => f.contains('uppercase')), isTrue);

      // Missing special characters
      strength = PasswordStrengthAnalyzer.analyze('Password123');
      expect(strength.feedback.any((f) => f.contains('special')), isTrue);

      // Good password
      strength = PasswordStrengthAnalyzer.analyze('G00dP@ssw0rd!');
      expect(strength.feedback.isNotEmpty, isTrue);
    });

    test('should calculate entropy correctly', () {
      // Only lowercase (26 chars)
      var strength = PasswordStrengthAnalyzer.analyze('abcdefgh');
      expect(strength.entropy, isNotNull);
      expect(strength.entropy!, greaterThan(0));

      // Mixed case (52 chars)
      strength = PasswordStrengthAnalyzer.analyze('AbCdEfGh');
      expect(strength.entropy!, greaterThan(37)); // 8 * log2(52)

      // All character types
      strength = PasswordStrengthAnalyzer.analyze('AbC!23De');
      expect(strength.entropy!, greaterThan(50)); // Higher entropy with more character types
    });

    test('should estimate crack time', () {
      // Weak password
      var strength = PasswordStrengthAnalyzer.analyze('pass');
      expect(strength.estimatedCrackTime, isNotNull);
      expect(strength.estimatedCrackTime, contains('Instant'));

      // Strong password
      strength = PasswordStrengthAnalyzer.analyze('MyStr0ng!P@ssw0rd#2024');
      expect(strength.estimatedCrackTime, isNotNull);
      expect(
        strength.estimatedCrackTime!.contains('years') ||
        strength.estimatedCrackTime!.contains('Forever'),
        isTrue,
      );
    });

    test('should handle edge cases', () {
      // Empty password
      var strength = PasswordStrengthAnalyzer.analyze('');
      expect(strength.level, PasswordStrengthLevel.veryWeak);
      expect(strength.score, equals(0));
      expect(strength.feedback.any((f) => f.contains('required')), isTrue);

      // Very long password
      strength = PasswordStrengthAnalyzer.analyze('a' * 100);
      expect(strength.score, greaterThan(0));

      // Special Unicode characters
      strength = PasswordStrengthAnalyzer.analyze('P@ss✓wörd♥123');
      expect(strength.score, greaterThan(0));
      expect(strength.entropy, isNotNull);
    });
  });
}