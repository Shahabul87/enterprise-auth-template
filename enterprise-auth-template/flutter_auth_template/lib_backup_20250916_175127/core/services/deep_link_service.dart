import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Deep Link Service Provider
final deepLinkServiceProvider = Provider<DeepLinkService>((ref) {
  return DeepLinkService();
});

class DeepLinkService {
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  // Stream controller for deep link events
  final _deepLinkController = StreamController<DeepLinkData>.broadcast();
  Stream<DeepLinkData> get deepLinkStream => _deepLinkController.stream;

  DeepLinkService() {
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();

    // Handle app launch from deep link
    try {
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        _handleDeepLink(initialLink);
      }
    } catch (e) {
      debugPrint('Failed to get initial link: $e');
    }

    // Handle deep links when app is already running
    _linkSubscription = _appLinks.uriLinkStream.listen(
      _handleDeepLink,
      onError: (error) {
        debugPrint('Deep link stream error: $error');
      },
    );
  }

  void _handleDeepLink(Uri uri) {
    debugPrint('Received deep link: $uri');

    // Parse the deep link and emit appropriate event
    final deepLinkData = _parseDeepLink(uri);
    if (deepLinkData != null) {
      _deepLinkController.add(deepLinkData);
      _navigateToDeepLink(deepLinkData);
    }
  }

  DeepLinkData? _parseDeepLink(Uri uri) {
    // Expected URL formats:
    // - Magic Link: https://yourapp.com/auth/magic-link?token=xxx&email=xxx
    // - Password Reset: https://yourapp.com/auth/reset-password?token=xxx
    // - Email Verification: https://yourapp.com/auth/verify-email?token=xxx
    // - OAuth Callback: https://yourapp.com/auth/callback?provider=google&code=xxx

    final path = uri.path;
    final queryParams = uri.queryParameters;

    // Magic Link Authentication
    if (path == '/auth/magic-link' || path.contains('magic-link')) {
      final token = queryParams['token'];
      final email = queryParams['email'];

      if (token != null) {
        return DeepLinkData(
          type: DeepLinkType.magicLink,
          token: token,
          email: email,
          queryParams: queryParams,
        );
      }
    }

    // Password Reset
    if (path == '/auth/reset-password' || path.contains('reset-password')) {
      final token = queryParams['token'];

      if (token != null) {
        return DeepLinkData(
          type: DeepLinkType.passwordReset,
          token: token,
          queryParams: queryParams,
        );
      }
    }

    // Email Verification
    if (path == '/auth/verify-email' || path.contains('verify-email')) {
      final token = queryParams['token'];

      if (token != null) {
        return DeepLinkData(
          type: DeepLinkType.emailVerification,
          token: token,
          queryParams: queryParams,
        );
      }
    }

    // OAuth Callback
    if (path == '/auth/callback' || path.contains('callback')) {
      final provider = queryParams['provider'];
      final code = queryParams['code'];
      final state = queryParams['state'];

      if (provider != null && code != null) {
        return DeepLinkData(
          type: DeepLinkType.oauthCallback,
          provider: provider,
          code: code,
          state: state,
          queryParams: queryParams,
        );
      }
    }

    // 2FA Verification Link
    if (path == '/auth/2fa-verify' || path.contains('2fa')) {
      final token = queryParams['token'];
      final session = queryParams['session'];

      if (token != null) {
        return DeepLinkData(
          type: DeepLinkType.twoFactorVerification,
          token: token,
          session: session,
          queryParams: queryParams,
        );
      }
    }

    return null;
  }

  void _navigateToDeepLink(DeepLinkData data) {
    // Get the current context from the navigator key
    final context = navigatorKey.currentContext;
    if (context == null) return;

    switch (data.type) {
      case DeepLinkType.magicLink:
        context.go('/auth/magic-link-verify', extra: data);
        break;
      case DeepLinkType.passwordReset:
        context.go('/auth/reset-password', extra: data);
        break;
      case DeepLinkType.emailVerification:
        context.go('/auth/verify-email', extra: data);
        break;
      case DeepLinkType.oauthCallback:
        context.go('/auth/oauth-callback', extra: data);
        break;
      case DeepLinkType.twoFactorVerification:
        context.go('/auth/2fa-verify', extra: data);
        break;
    }
  }

  void dispose() {
    _linkSubscription?.cancel();
    _deepLinkController.close();
  }
}

// Deep Link Data Model
class DeepLinkData {
  final DeepLinkType type;
  final String? token;
  final String? email;
  final String? provider;
  final String? code;
  final String? state;
  final String? session;
  final Map<String, String> queryParams;

  DeepLinkData({
    required this.type,
    this.token,
    this.email,
    this.provider,
    this.code,
    this.state,
    this.session,
    required this.queryParams,
  });
}

enum DeepLinkType {
  magicLink,
  passwordReset,
  emailVerification,
  oauthCallback,
  twoFactorVerification,
}

// Global navigator key for navigation from services
final navigatorKey = GlobalKey<NavigatorState>();

// Magic Link Handler Widget
class MagicLinkHandler extends ConsumerStatefulWidget {
  final DeepLinkData? deepLinkData;

  const MagicLinkHandler({super.key, this.deepLinkData});

  @override
  ConsumerState<MagicLinkHandler> createState() => _MagicLinkHandlerState();
}

class _MagicLinkHandlerState extends ConsumerState<MagicLinkHandler> {
  bool _isVerifying = false;
  String? _errorMessage;
  bool _verified = false;

  @override
  void initState() {
    super.initState();
    if (widget.deepLinkData != null) {
      _verifyMagicLink();
    }
  }

  Future<void> _verifyMagicLink() async {
    if (widget.deepLinkData?.token == null) {
      setState(() {
        _errorMessage = 'Invalid magic link';
      });
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      // TODO: Call your auth API to verify the magic link token
      // final authService = ref.read(authServiceProvider);
      // await authService.verifyMagicLink(widget.deepLinkData!.token!);

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _verified = true;
        _isVerifying = false;
      });

      // Navigate to dashboard after successful verification
      if (mounted) {
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            context.go('/dashboard');
          }
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isVerifying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: theme.brightness == Brightness.dark
                ? [const Color(0xFF1A1F36), const Color(0xFF0F1419)]
                : [const Color(0xFFF0F4FF), const Color(0xFFFFFFFF)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _verified
                          ? Colors.green.withValues(alpha: 0.1)
                          : _errorMessage != null
                          ? Colors.red.withValues(alpha: 0.1)
                          : theme.colorScheme.primary.withValues(alpha: 0.1),
                    ),
                    child: Icon(
                      _verified
                          ? Icons.check_circle_outline
                          : _errorMessage != null
                          ? Icons.error_outline
                          : Icons.link,
                      size: 50,
                      color: _verified
                          ? Colors.green
                          : _errorMessage != null
                          ? Colors.red
                          : theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Title
                  Text(
                    _verified
                        ? 'Magic Link Verified!'
                        : _errorMessage != null
                        ? 'Verification Failed'
                        : 'Verifying Magic Link',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    _verified
                        ? 'You have been successfully authenticated.\nRedirecting to dashboard...'
                        : _errorMessage != null
                        ? _errorMessage!
                        : 'Please wait while we verify your magic link...',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Loading or action
                  if (_isVerifying)
                    const CircularProgressIndicator()
                  else if (_errorMessage != null)
                    Column(
                      children: [
                        OutlinedButton.icon(
                          onPressed: _verifyMagicLink,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Try Again'),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => context.go('/auth/login'),
                          child: const Text('Back to Login'),
                        ),
                      ],
                    )
                  else if (_verified)
                    const CircularProgressIndicator(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
