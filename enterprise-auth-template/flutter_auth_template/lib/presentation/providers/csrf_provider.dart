import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_auth_template/core/security/csrf_protection.dart';
import 'package:flutter_auth_template/core/storage/secure_storage_service.dart';

/// CSRF Protection Service Provider
final csrfServiceProvider = Provider<CSRFProtectionService>((ref) {
  final storage = ref.watch(secureStorageServiceProvider);
  return CSRFProtectionService(storage);
});

/// CSRF Interceptor Provider
final csrfInterceptorProvider = Provider<CSRFInterceptor>((ref) {
  final csrfService = ref.watch(csrfServiceProvider);
  return CSRFInterceptor(csrfService);
});

/// CSRF Token Manager Provider
final csrfTokenManagerProvider = Provider<CSRFTokenManager>((ref) {
  final csrfService = ref.watch(csrfServiceProvider);
  return CSRFTokenManager(csrfService);
});

/// CSRF Configuration Provider
final csrfConfigProvider = Provider<CSRFConfig>((ref) {
  return const CSRFConfig(
    enabled: true,
    tokenExpiry: Duration(hours: 24),
    tokenLength: 32,
    excludedPaths: [
      '/auth/login',
      '/auth/register',
      '/auth/refresh',
      '/health',
    ],
    excludedDomains: [],
    doubleSubmitCookie: true,
    synchronizerToken: true,
  );
});

/// Current CSRF Token Provider
final currentCSRFTokenProvider = FutureProvider<String?>((ref) async {
  final csrfService = ref.watch(csrfServiceProvider);
  return await csrfService.getCurrentToken();
});

/// Generate New CSRF Token Provider
final generateCSRFTokenProvider = FutureProvider<String>((ref) async {
  final csrfService = ref.watch(csrfServiceProvider);
  return await csrfService.generateToken();
});

/// CSRF Token State Provider
class CSRFTokenState {
  final String? token;
  final DateTime? expiry;
  final bool isValid;
  final bool needsRefresh;

  const CSRFTokenState({
    this.token,
    this.expiry,
    this.isValid = false,
    this.needsRefresh = false,
  });
}

/// CSRF Token State Notifier
class CSRFTokenNotifier extends StateNotifier<CSRFTokenState> {
  final CSRFProtectionService _csrfService;

  CSRFTokenNotifier(this._csrfService) : super(const CSRFTokenState()) {
    _loadToken();
  }

  /// Load current token
  Future<void> _loadToken() async {
    final token = await _csrfService.getCurrentToken();
    final expiry = await _csrfService.getTokenExpiry();
    final needsRefresh = await _csrfService.needsRefresh();

    state = CSRFTokenState(
      token: token,
      expiry: expiry,
      isValid:
          token != null && expiry != null && DateTime.now().isBefore(expiry),
      needsRefresh: needsRefresh,
    );
  }

  /// Generate new token
  Future<void> generateToken() async {
    final token = await _csrfService.generateToken();
    final expiry = await _csrfService.getTokenExpiry();

    state = CSRFTokenState(
      token: token,
      expiry: expiry,
      isValid: true,
      needsRefresh: false,
    );
  }

  /// Refresh token
  Future<void> refreshToken() async {
    final token = await _csrfService.refreshToken();
    final expiry = await _csrfService.getTokenExpiry();

    state = CSRFTokenState(
      token: token,
      expiry: expiry,
      isValid: true,
      needsRefresh: false,
    );
  }

  /// Clear token
  Future<void> clearToken() async {
    await _csrfService.clearToken();
    state = const CSRFTokenState();
  }

  /// Validate token
  Future<bool> validateToken(String token) async {
    return await _csrfService.validateToken(token);
  }
}

/// CSRF Token State Provider
final csrfTokenStateProvider =
    StateNotifierProvider<CSRFTokenNotifier, CSRFTokenState>((ref) {
      final csrfService = ref.watch(csrfServiceProvider);
      return CSRFTokenNotifier(csrfService);
    });
