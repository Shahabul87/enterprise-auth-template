import 'package:flutter/material.dart';
import 'dart:math';

/// Password strength analyzer for evaluating password security
class PasswordStrengthAnalyzer {
  // Password criteria weights
  static const double lengthWeight = 0.25;
  static const double complexityWeight = 0.25;
  static const double uniquenessWeight = 0.25;
  static const double patternsWeight = 0.25;

  // Common weak passwords to check against
  static const List<String> commonPasswords = [
    'password', '123456', '123456789', 'qwerty', 'abc123',
    'password1', 'password123', '111111', '1234567',
    'sunshine', 'iloveyou', 'princess', 'admin', 'welcome',
    'monkey', 'dragon', 'master', 'letmein', 'qwertyuiop',
  ];

  // Keyboard patterns to detect
  static const List<String> keyboardPatterns = [
    'qwerty', 'qwertz', 'azerty', 'qweasd', 'qazwsx',
    'zxcvbn', 'asdfgh', 'zaqwsx', 'qazxsw', 'edcrfv',
    '1234567890', '0987654321', 'abcdefgh', 'zyxwvu',
  ];

  /// Analyze password and return strength result
  static PasswordStrength analyze(String password) {
    if (password.isEmpty) {
      return PasswordStrength(
        score: 0,
        level: PasswordStrengthLevel.veryWeak,
        feedback: ['Password is required'],
        suggestions: ['Enter a password'],
      );
    }

    double score = 0;
    List<String> feedback = [];
    List<String> suggestions = [];

    // 1. Length analysis (25%)
    final lengthScore = _analyzeLengthScore(password);
    score += lengthScore * lengthWeight;
    if (lengthScore < 1.0) {
      if (password.length < 8) {
        feedback.add('Password is too short');
        suggestions.add('Use at least 8 characters');
      } else if (password.length < 12) {
        suggestions.add('Consider using 12+ characters for better security');
      }
    }

    // 2. Complexity analysis (25%)
    final complexityScore = _analyzeComplexityScore(password);
    score += complexityScore * complexityWeight;
    final complexity = _getComplexityFeedback(password);
    if (complexity.isNotEmpty) {
      feedback.addAll(complexity['feedback']!);
      suggestions.addAll(complexity['suggestions']!);
    }

    // 3. Uniqueness analysis (25%)
    final uniquenessScore = _analyzeUniquenessScore(password);
    score += uniquenessScore * uniquenessWeight;
    if (uniquenessScore < 0.5) {
      feedback.add('Password contains common patterns');
      suggestions.add('Avoid common words and patterns');
    }

    // 4. Pattern analysis (25%)
    final patternScore = _analyzePatternScore(password);
    score += patternScore * patternsWeight;
    if (patternScore < 0.5) {
      feedback.add('Password has predictable patterns');
      suggestions.add('Mix up character positions');
    }

    // Calculate entropy
    final entropy = _calculateEntropy(password);

    // Determine strength level
    final level = _getStrengthLevel(score);

    // Add level-specific feedback
    if (level == PasswordStrengthLevel.veryWeak) {
      if (feedback.isEmpty) feedback.add('Password is very weak');
      if (suggestions.isEmpty) suggestions.add('Create a stronger password');
    } else if (level == PasswordStrengthLevel.weak) {
      if (feedback.isEmpty) feedback.add('Password could be stronger');
    } else if (level == PasswordStrengthLevel.good) {
      if (feedback.isEmpty) feedback.add('Good password');
    } else if (level == PasswordStrengthLevel.strong) {
      if (feedback.isEmpty) feedback.add('Strong password');
    } else if (level == PasswordStrengthLevel.veryStrong) {
      if (feedback.isEmpty) feedback.add('Excellent password!');
    }

    return PasswordStrength(
      score: score,
      level: level,
      feedback: feedback,
      suggestions: suggestions,
      entropy: entropy,
      estimatedCrackTime: _estimateCrackTime(entropy),
    );
  }

  /// Analyze password length score
  static double _analyzeLengthScore(String password) {
    final length = password.length;
    if (length < 6) return 0.0;
    if (length < 8) return 0.25;
    if (length < 10) return 0.5;
    if (length < 12) return 0.75;
    if (length < 16) return 0.9;
    return 1.0;
  }

  /// Analyze password complexity score
  static double _analyzeComplexityScore(String password) {
    double score = 0;
    int characterTypes = 0;

    if (password.contains(RegExp(r'[a-z]'))) {
      characterTypes++;
      score += 0.2;
    }
    if (password.contains(RegExp(r'[A-Z]'))) {
      characterTypes++;
      score += 0.2;
    }
    if (password.contains(RegExp(r'[0-9]'))) {
      characterTypes++;
      score += 0.2;
    }
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      characterTypes++;
      score += 0.3;
    }
    if (password.contains(RegExp(r'[^a-zA-Z0-9!@#$%^&*(),.?":{}|<>]'))) {
      // Other special characters
      score += 0.1;
    }

    // Bonus for mixing character types
    if (characterTypes >= 3) score = min(1.0, score + 0.2);
    if (characterTypes >= 4) score = 1.0;

    return score;
  }

  /// Get complexity feedback
  static Map<String, List<String>> _getComplexityFeedback(String password) {
    List<String> feedback = [];
    List<String> suggestions = [];

    if (!password.contains(RegExp(r'[a-z]'))) {
      feedback.add('Missing lowercase letters');
      suggestions.add('Add lowercase letters (a-z)');
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      feedback.add('Missing uppercase letters');
      suggestions.add('Add uppercase letters (A-Z)');
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      feedback.add('Missing numbers');
      suggestions.add('Add numbers (0-9)');
    }
    if (!password.contains(RegExp(r'[^a-zA-Z0-9]'))) {
      feedback.add('Missing special characters');
      suggestions.add('Add special characters (!@#\$%^&*)');
    }

    return {'feedback': feedback, 'suggestions': suggestions};
  }

  /// Analyze uniqueness score
  static double _analyzeUniquenessScore(String password) {
    final lowerPassword = password.toLowerCase();

    // Check against common passwords
    for (final common in commonPasswords) {
      if (lowerPassword == common) return 0.0;
      if (lowerPassword.contains(common)) return 0.25;
    }

    // Check for dictionary words (simplified)
    if (RegExp(r'^[a-z]+$').hasMatch(lowerPassword) && password.length < 10) {
      return 0.3;
    }

    // Check for personal information patterns
    if (_containsDatePattern(password)) return 0.4;
    if (_containsPhonePattern(password)) return 0.4;

    return 1.0;
  }

  /// Analyze pattern score
  static double _analyzePatternScore(String password) {
    double score = 1.0;
    final lower = password.toLowerCase();

    // Check for keyboard patterns
    for (final pattern in keyboardPatterns) {
      if (lower.contains(pattern)) {
        score -= 0.5;
        break;
      }
    }

    // Check for repeated characters
    if (RegExp(r'(.)\1{2,}').hasMatch(password)) {
      score -= 0.3;
    }

    // Check for sequential characters
    if (_hasSequentialCharacters(password)) {
      score -= 0.3;
    }

    // Check for repeated patterns
    if (_hasRepeatedPatterns(password)) {
      score -= 0.2;
    }

    return max(0.0, score);
  }

  /// Check if password contains date patterns
  static bool _containsDatePattern(String password) {
    // Check for year patterns (1900-2099)
    if (RegExp(r'(19|20)\d{2}').hasMatch(password)) return true;
    // Check for date patterns (MM/DD, DD/MM)
    if (RegExp(r'\d{2}[/\-.]\d{2}').hasMatch(password)) return true;
    return false;
  }

  /// Check if password contains phone patterns
  static bool _containsPhonePattern(String password) {
    // Check for phone number patterns
    if (RegExp(r'\d{3}[\-.]?\d{3}[\-.]?\d{4}').hasMatch(password)) return true;
    if (RegExp(r'\d{10,11}').hasMatch(password)) return true;
    return false;
  }

  /// Check for sequential characters
  static bool _hasSequentialCharacters(String password) {
    for (int i = 0; i < password.length - 2; i++) {
      final char1 = password.codeUnitAt(i);
      final char2 = password.codeUnitAt(i + 1);
      final char3 = password.codeUnitAt(i + 2);

      // Check ascending or descending sequences
      if ((char2 == char1 + 1 && char3 == char2 + 1) ||
          (char2 == char1 - 1 && char3 == char2 - 1)) {
        return true;
      }
    }
    return false;
  }

  /// Check for repeated patterns
  static bool _hasRepeatedPatterns(String password) {
    if (password.length < 6) return false;

    // Check for patterns like "abcabc" or "123123"
    final halfLength = password.length ~/ 2;
    for (int len = 2; len <= halfLength; len++) {
      final pattern = password.substring(0, len);
      final repeated = pattern * (password.length ~/ len);
      if (repeated == password.substring(0, repeated.length)) {
        return true;
      }
    }
    return false;
  }

  /// Calculate password entropy
  static double _calculateEntropy(String password) {
    int poolSize = 0;

    if (password.contains(RegExp(r'[a-z]'))) poolSize += 26;
    if (password.contains(RegExp(r'[A-Z]'))) poolSize += 26;
    if (password.contains(RegExp(r'[0-9]'))) poolSize += 10;
    if (password.contains(RegExp(r'[^a-zA-Z0-9]'))) poolSize += 32;

    if (poolSize == 0) return 0;

    // Entropy = length * log2(poolSize)
    return password.length * (log(poolSize) / log(2));
  }

  /// Get strength level from score
  static PasswordStrengthLevel _getStrengthLevel(double score) {
    if (score < 0.15) return PasswordStrengthLevel.veryWeak;
    if (score < 0.3) return PasswordStrengthLevel.weak;
    if (score < 0.45) return PasswordStrengthLevel.fair;
    if (score < 0.65) return PasswordStrengthLevel.good;
    if (score < 0.85) return PasswordStrengthLevel.strong;
    return PasswordStrengthLevel.veryStrong;
  }

  /// Estimate crack time based on entropy
  static String _estimateCrackTime(double entropy) {
    // Assuming 1 billion guesses per second
    final guessesPerSecond = 1e9;
    final possibleCombinations = pow(2, entropy);
    final seconds = possibleCombinations / guessesPerSecond / 2; // Average case

    if (seconds < 1) return 'Instant';
    if (seconds < 60) return '${seconds.toStringAsFixed(0)} seconds';
    if (seconds < 3600) return '${(seconds / 60).toStringAsFixed(0)} minutes';
    if (seconds < 86400) return '${(seconds / 3600).toStringAsFixed(0)} hours';
    if (seconds < 2592000) return '${(seconds / 86400).toStringAsFixed(0)} days';
    if (seconds < 31536000) return '${(seconds / 2592000).toStringAsFixed(0)} months';
    if (seconds < 3153600000) return '${(seconds / 31536000).toStringAsFixed(0)} years';

    // For very large numbers
    final years = seconds / 31536000;
    if (years < 1e6) return '${years.toStringAsExponential(1)} years';
    if (years < 1e9) return '${(years / 1e6).toStringAsFixed(0)} million years';
    if (years < 1e12) return '${(years / 1e9).toStringAsFixed(0)} billion years';
    return 'Forever';
  }
}

/// Password strength result
class PasswordStrength {
  final double score; // 0.0 to 1.0
  final PasswordStrengthLevel level;
  final List<String> feedback;
  final List<String> suggestions;
  final double? entropy;
  final String? estimatedCrackTime;

  const PasswordStrength({
    required this.score,
    required this.level,
    required this.feedback,
    required this.suggestions,
    this.entropy,
    this.estimatedCrackTime,
  });

  Color get color {
    switch (level) {
      case PasswordStrengthLevel.veryWeak:
        return Colors.red[900]!;
      case PasswordStrengthLevel.weak:
        return Colors.red;
      case PasswordStrengthLevel.fair:
        return Colors.orange;
      case PasswordStrengthLevel.good:
        return Colors.amber;
      case PasswordStrengthLevel.strong:
        return Colors.lightGreen;
      case PasswordStrengthLevel.veryStrong:
        return Colors.green;
    }
  }

  String get label {
    switch (level) {
      case PasswordStrengthLevel.veryWeak:
        return 'Very Weak';
      case PasswordStrengthLevel.weak:
        return 'Weak';
      case PasswordStrengthLevel.fair:
        return 'Fair';
      case PasswordStrengthLevel.good:
        return 'Good';
      case PasswordStrengthLevel.strong:
        return 'Strong';
      case PasswordStrengthLevel.veryStrong:
        return 'Very Strong';
    }
  }

  IconData get icon {
    switch (level) {
      case PasswordStrengthLevel.veryWeak:
      case PasswordStrengthLevel.weak:
        return Icons.error_outline;
      case PasswordStrengthLevel.fair:
        return Icons.warning_amber;
      case PasswordStrengthLevel.good:
        return Icons.check_circle_outline;
      case PasswordStrengthLevel.strong:
      case PasswordStrengthLevel.veryStrong:
        return Icons.verified_user;
    }
  }
}

/// Password strength levels
enum PasswordStrengthLevel {
  veryWeak,
  weak,
  fair,
  good,
  strong,
  veryStrong,
}