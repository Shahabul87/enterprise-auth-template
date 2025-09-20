import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import '../storage/secure_storage_service.dart';

/// CSRF Protection Service
///
/// Implements Cross-Site Request Forgery protection for the Flutter application.
/// This service generates, validates, and manages CSRF tokens to prevent
/// unauthorized requests from malicious websites.
class CSRFProtectionService {
  final SecureStorageService _storage;
  static const String _csrfTokenKey = 'csrf_token';
  static const String _csrfSecretKey = 'csrf_secret';
  static const int _tokenLength = 32;
  static const Duration _tokenExpiry = Duration(hours: 24);

  // Singleton instance
  static CSRFProtectionService? _instance;

  CSRFProtectionService._internal(this._storage);

  factory CSRFProtectionService(SecureStorageService storage) {
    _instance ??= CSRFProtectionService._internal(storage);
    return _instance!;
  }

  /// Generate a new CSRF token
  Future<String> generateToken() async {
    try {
      // Generate random bytes for token
      final random = Random.secure();
      final tokenBytes = List<int>.generate(
        _tokenLength,
        (i) => random.nextInt(256),
      );
      final token = base64Url.encode(tokenBytes);

      // Generate secret for double-submit cookie pattern
      final secretBytes = List<int>.generate(
        _tokenLength,
        (i) => random.nextInt(256),
      );
      final secret = base64Url.encode(secretBytes);

      // Create token data with expiry
      final tokenData = {
        'token': token,
        'secret': secret,
        'expiry': DateTime.now().add(_tokenExpiry).toIso8601String(),
        'created': DateTime.now().toIso8601String(),
      };

      // Store token data securely
      await _storage.write(key: _csrfTokenKey, value: jsonEncode(tokenData));
      await _storage.write(key: _csrfSecretKey, value: secret);

      // Return signed token
      return _signToken(token, secret);
    } catch (e) {
      debugPrint('Error generating CSRF token: $e');
      throw CSRFException('Failed to generate CSRF token');
    }
  }

  /// Get current CSRF token
  Future<String?> getCurrentToken() async {
    try {
      final tokenDataStr = await _storage.read(key: _csrfTokenKey);
      if (tokenDataStr == null) return null;

      final tokenData = jsonDecode(tokenDataStr) as Map<String, dynamic>;
      final expiry = DateTime.parse(tokenData['expiry'] as String);

      // Check if token is expired
      if (DateTime.now().isAfter(expiry)) {
        await clearToken();
        return null;
      }

      final token = tokenData['token'] as String;
      final secret = tokenData['secret'] as String;

      return _signToken(token, secret);
    } catch (e) {
      debugPrint('Error getting CSRF token: $e');
      return null;
    }
  }

  /// Validate CSRF token
  Future<bool> validateToken(String token) async {
    try {
      if (token.isEmpty) return false;

      final tokenDataStr = await _storage.read(key: _csrfTokenKey);
      if (tokenDataStr == null) return false;

      final tokenData = jsonDecode(tokenDataStr) as Map<String, dynamic>;
      final expiry = DateTime.parse(tokenData['expiry'] as String);

      // Check if token is expired
      if (DateTime.now().isAfter(expiry)) {
        await clearToken();
        return false;
      }

      final storedToken = tokenData['token'] as String;
      final secret = tokenData['secret'] as String;
      final expectedToken = _signToken(storedToken, secret);

      // Constant-time comparison to prevent timing attacks
      return _constantTimeCompare(token, expectedToken);
    } catch (e) {
      debugPrint('Error validating CSRF token: $e');
      return false;
    }
  }

  /// Refresh CSRF token
  Future<String> refreshToken() async {
    await clearToken();
    return generateToken();
  }

  /// Clear CSRF token
  Future<void> clearToken() async {
    await _storage.delete(key: _csrfTokenKey);
    await _storage.delete(key: _csrfSecretKey);
  }

  /// Get CSRF header name
  String get headerName => 'X-CSRF-Token';

  /// Get CSRF cookie name (for web)
  String get cookieName => 'csrf_token';

  /// Sign token with secret
  String _signToken(String token, String secret) {
    final hmac = Hmac(sha256, utf8.encode(secret));
    final digest = hmac.convert(utf8.encode(token));
    return '$token.$digest';
  }

  /// Constant-time string comparison
  bool _constantTimeCompare(String a, String b) {
    if (a.length != b.length) return false;

    int result = 0;
    for (int i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }

    return result == 0;
  }

  /// Generate token for form field
  Future<String> getFormToken() async {
    String? token = await getCurrentToken();
    if (token == null) {
      token = await generateToken();
    }
    return token;
  }

  /// Validate request with CSRF token
  Future<bool> validateRequest({
    required String? headerToken,
    String? formToken,
    String? cookieToken,
  }) async {
    // Priority: Header > Form > Cookie
    final tokenToValidate = headerToken ?? formToken ?? cookieToken;

    if (tokenToValidate == null) {
      debugPrint('No CSRF token provided in request');
      return false;
    }

    return validateToken(tokenToValidate);
  }

  /// Get token expiry time
  Future<DateTime?> getTokenExpiry() async {
    try {
      final tokenDataStr = await _storage.read(key: _csrfTokenKey);
      if (tokenDataStr == null) return null;

      final tokenData = jsonDecode(tokenDataStr) as Map<String, dynamic>;
      return DateTime.parse(tokenData['expiry'] as String);
    } catch (e) {
      debugPrint('Error getting token expiry: $e');
      return null;
    }
  }

  /// Check if token needs refresh
  Future<bool> needsRefresh() async {
    final expiry = await getTokenExpiry();
    if (expiry == null) return true;

    // Refresh if less than 1 hour remaining
    final timeRemaining = expiry.difference(DateTime.now());
    return timeRemaining.inHours < 1;
  }

  /// Create anti-CSRF meta tag content (for web)
  Future<String> getMetaTagContent() async {
    final token = await getFormToken();
    return base64.encode(utf8.encode(token));
  }
}

/// CSRF Protection Interceptor for HTTP requests
class CSRFInterceptor {
  final CSRFProtectionService _csrfService;

  CSRFInterceptor(this._csrfService);

  /// Add CSRF token to request headers
  Future<Map<String, String>> addCSRFHeaders(
    Map<String, String> headers,
  ) async {
    // Skip CSRF for safe methods
    final token = await _csrfService.getCurrentToken();
    if (token != null) {
      headers[_csrfService.headerName] = token;
    }
    return headers;
  }

  /// Check if method requires CSRF protection
  bool requiresCSRF(String method) {
    // Safe methods don't require CSRF protection
    final safeMethods = ['GET', 'HEAD', 'OPTIONS'];
    return !safeMethods.contains(method.toUpperCase());
  }

  /// Intercept request to add CSRF protection
  Future<Map<String, dynamic>> interceptRequest({
    required String method,
    required Map<String, String> headers,
    Map<String, dynamic>? body,
  }) async {
    if (!requiresCSRF(method)) {
      return {'headers': headers, 'body': body};
    }

    // Ensure token exists
    String? token = await _csrfService.getCurrentToken();
    if (token == null) {
      token = await _csrfService.generateToken();
    }

    // Check if token needs refresh
    if (await _csrfService.needsRefresh()) {
      token = await _csrfService.refreshToken();
    }

    // Add token to headers
    headers[_csrfService.headerName] = token;

    return {'headers': headers, 'body': body};
  }
}

/// CSRF Protection Widget for Forms
class CSRFFormField extends StatefulWidget {
  final Widget child;
  final Function(String token)? onTokenGenerated;

  const CSRFFormField({super.key, required this.child, this.onTokenGenerated});

  @override
  State<CSRFFormField> createState() => _CSRFFormFieldState();
}

class _CSRFFormFieldState extends State<CSRFFormField> {
  String? _csrfToken;

  @override
  void initState() {
    super.initState();
    _generateToken();
  }

  Future<void> _generateToken() async {
    final storage = SecureStorageService();
    final csrfService = CSRFProtectionService(storage);
    final token = await csrfService.getFormToken();

    if (mounted) {
      setState(() {
        _csrfToken = token;
      });

      widget.onTokenGenerated?.call(token);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_csrfToken == null) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // Hidden field with CSRF token
        SizedBox(
          height: 0,
          width: 0,
          child: TextFormField(
            initialValue: _csrfToken,
            enabled: false,
            decoration: const InputDecoration(
              isCollapsed: true,
              border: InputBorder.none,
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
}

/// CSRF Exception
class CSRFException implements Exception {
  final String message;
  final String? code;

  CSRFException(this.message, {this.code});

  @override
  String toString() =>
      'CSRFException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// CSRF Configuration
class CSRFConfig {
  final bool enabled;
  final Duration tokenExpiry;
  final int tokenLength;
  final List<String> excludedPaths;
  final List<String> excludedDomains;
  final bool doubleSubmitCookie;
  final bool synchronizerToken;

  const CSRFConfig({
    this.enabled = true,
    this.tokenExpiry = const Duration(hours: 24),
    this.tokenLength = 32,
    this.excludedPaths = const [],
    this.excludedDomains = const [],
    this.doubleSubmitCookie = true,
    this.synchronizerToken = true,
  });

  /// Check if path is excluded from CSRF protection
  bool isPathExcluded(String path) {
    return excludedPaths.any((excluded) => path.startsWith(excluded));
  }

  /// Check if domain is excluded from CSRF protection
  bool isDomainExcluded(String domain) {
    return excludedDomains.contains(domain);
  }
}

/// CSRF Token Manager for managing multiple tokens
class CSRFTokenManager {
  final Map<String, String> _tokens = {};
  final CSRFProtectionService _service;

  CSRFTokenManager(this._service);

  /// Get token for specific form/action
  Future<String> getTokenForAction(String action) async {
    if (_tokens.containsKey(action)) {
      return _tokens[action]!;
    }

    final token = await _service.generateToken();
    _tokens[action] = token;
    return token;
  }

  /// Validate token for specific action
  Future<bool> validateTokenForAction(String action, String token) async {
    final expectedToken = _tokens[action];
    if (expectedToken == null) return false;

    return await _service.validateToken(token) && token == expectedToken;
  }

  /// Clear token for action
  void clearTokenForAction(String action) {
    _tokens.remove(action);
  }

  /// Clear all tokens
  void clearAll() {
    _tokens.clear();
  }
}
