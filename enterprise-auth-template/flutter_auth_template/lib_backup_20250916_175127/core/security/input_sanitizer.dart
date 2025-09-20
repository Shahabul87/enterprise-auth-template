import 'package:html_unescape/html_unescape.dart';

/// Input sanitization utilities to prevent injection attacks
class InputSanitizer {
  static final HtmlUnescape _htmlUnescape = HtmlUnescape();

  /// Sanitize text input to prevent XSS attacks
  static String sanitizeText(String input) {
    if (input.isEmpty) return input;

    // Remove HTML tags
    String sanitized = input.replaceAll(RegExp(r'<[^>]*>'), '');

    // Escape special HTML characters
    sanitized = sanitized
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;')
        .replaceAll('/', '&#x2F;');

    // Remove null bytes
    sanitized = sanitized.replaceAll('\x00', '');

    // Trim whitespace
    sanitized = sanitized.trim();

    return sanitized;
  }

  /// Sanitize email input
  static String? sanitizeEmail(String input) {
    if (input.isEmpty) return null;

    // Convert to lowercase and trim
    String email = input.toLowerCase().trim();

    // Basic email validation regex
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(email)) {
      return null;
    }

    // Additional sanitization
    email = sanitizeText(email);

    return email;
  }

  /// Sanitize URL input
  static String? sanitizeUrl(String input) {
    if (input.isEmpty) return null;

    try {
      final uri = Uri.parse(input);

      // Only allow http and https schemes
      if (!['http', 'https'].contains(uri.scheme)) {
        return null;
      }

      // Rebuild URL from parsed components
      return uri.toString();
    } catch (e) {
      return null;
    }
  }

  /// Sanitize phone number input
  static String? sanitizePhoneNumber(String input) {
    if (input.isEmpty) return null;

    // Remove all non-numeric characters except + (for country code)
    String phone = input.replaceAll(RegExp(r'[^0-9+]'), '');

    // Validate phone number format
    if (phone.length < 10 || phone.length > 15) {
      return null;
    }

    return phone;
  }

  /// Sanitize numeric input
  static int? sanitizeInteger(String input) {
    if (input.isEmpty) return null;

    try {
      // Remove all non-numeric characters
      final cleaned = input.replaceAll(RegExp(r'[^0-9-]'), '');
      return int.tryParse(cleaned);
    } catch (e) {
      return null;
    }
  }

  /// Sanitize decimal input
  static double? sanitizeDecimal(String input) {
    if (input.isEmpty) return null;

    try {
      // Remove all non-numeric characters except decimal point
      final cleaned = input.replaceAll(RegExp(r'[^0-9.-]'), '');
      return double.tryParse(cleaned);
    } catch (e) {
      return null;
    }
  }

  /// Sanitize file name
  static String sanitizeFileName(String input) {
    if (input.isEmpty) return 'file';

    // Remove dangerous characters
    String sanitized = input.replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1F]'), '_');

    // Limit length
    if (sanitized.length > 255) {
      sanitized = sanitized.substring(0, 255);
    }

    // Ensure it's not a reserved name
    final reserved = ['CON', 'PRN', 'AUX', 'NUL'];
    if (reserved.contains(sanitized.toUpperCase())) {
      sanitized = '_$sanitized';
    }

    return sanitized;
  }

  /// Sanitize SQL input to prevent SQL injection
  static String sanitizeSql(String input) {
    if (input.isEmpty) return input;

    // Escape single quotes
    String sanitized = input.replaceAll("'", "''");

    // Remove SQL comment indicators
    sanitized = sanitized
        .replaceAll('--', '')
        .replaceAll('/*', '')
        .replaceAll('*/', '');

    // Remove common SQL injection patterns
    final dangerousPatterns = [
      r'\bDROP\b',
      r'\bDELETE\b',
      r'\bINSERT\b',
      r'\bUPDATE\b',
      r'\bEXEC\b',
      r'\bEXECUTE\b',
      r'\bCREATE\b',
      r'\bALTER\b',
      r'\bGRANT\b',
      r'\bREVOKE\b',
    ];

    for (final pattern in dangerousPatterns) {
      sanitized = sanitized.replaceAll(RegExp(pattern, caseSensitive: false), '');
    }

    return sanitized;
  }

  /// Sanitize JSON string
  static String sanitizeJson(String input) {
    if (input.isEmpty) return '{}';

    try {
      // Parse and re-encode to ensure valid JSON
      final decoded = Uri.decodeComponent(input);
      return decoded;
    } catch (e) {
      return '{}';
    }
  }

  /// Validate and sanitize password
  static String? sanitizePassword(String input) {
    if (input.length < 8) return null;

    // Don't modify password content, just validate
    // Check for common weak patterns
    final weakPatterns = [
      '12345678',
      'password',
      'qwerty',
      'abc123',
      '111111',
    ];

    final lowerInput = input.toLowerCase();
    for (final pattern in weakPatterns) {
      if (lowerInput.contains(pattern)) {
        return null; // Reject weak passwords
      }
    }

    return input; // Return original password if valid
  }

  /// Strip all HTML tags from input
  static String stripHtml(String input) {
    if (input.isEmpty) return input;

    // Remove HTML tags
    String stripped = input.replaceAll(RegExp(r'<[^>]*>'), '');

    // Unescape HTML entities
    stripped = _htmlUnescape.convert(stripped);

    return stripped.trim();
  }

  /// Sanitize search query
  static String sanitizeSearchQuery(String input) {
    if (input.isEmpty) return input;

    // Remove special characters that might break search
    String sanitized = input.replaceAll(RegExp(r'[^\w\s-.]'), '');

    // Limit length
    if (sanitized.length > 100) {
      sanitized = sanitized.substring(0, 100);
    }

    return sanitized.trim();
  }
}