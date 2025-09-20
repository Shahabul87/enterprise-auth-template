import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/session_provider.dart';
import '../../providers/biometric_provider.dart';
import '../../providers/magic_link_provider.dart';
import '../../providers/webauthn_provider.dart';

/// Comprehensive error handler for authentication flows
class AuthErrorHandler extends ConsumerWidget {
  final Widget child;

  const AuthErrorHandler({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to all error states
    ref.listen<String?>(authErrorProvider, (previous, next) {
      if (next != null && next.isNotEmpty) {
        _showErrorSnackBar(context, next, ref);
      }
    });

    ref.listen<String?>(biometricErrorProvider, (previous, next) {
      if (next != null && next.isNotEmpty) {
        _showBiometricErrorSnackBar(context, next, ref);
      }
    });

    ref.listen<String?>(magicLinkErrorProvider, (previous, next) {
      if (next != null && next.isNotEmpty) {
        _showMagicLinkErrorSnackBar(context, next, ref);
      }
    });

    ref.listen<String?>(webAuthnErrorProvider, (previous, next) {
      if (next != null && next.isNotEmpty) {
        _showWebAuthnErrorSnackBar(context, next, ref);
      }
    });

    // Listen to success states
    ref.listen<String?>(magicLinkSuccessProvider, (previous, next) {
      if (next != null && next.isNotEmpty) {
        _showSuccessSnackBar(context, next);
      }
    });

    ref.listen<String?>(webAuthnSuccessProvider, (previous, next) {
      if (next != null && next.isNotEmpty) {
        _showSuccessSnackBar(context, next);
      }
    });

    return child;
  }

  void _showErrorSnackBar(BuildContext context, String message, WidgetRef ref) {
    if (!context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();

    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.onError,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _formatErrorMessage(message),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onError,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Theme.of(context).colorScheme.onError,
          onPressed: () {
            messenger.hideCurrentSnackBar();
            // Clear the error from the provider
            final notifier = ref.read(sessionNotifierProvider.notifier);
            notifier.clearError();
          },
        ),
        duration: const Duration(seconds: 6),
      ),
    );
  }

  void _showBiometricErrorSnackBar(BuildContext context, String message, WidgetRef ref) {
    if (!context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();

    Widget? actionWidget;
    VoidCallback? onActionPressed;

    // Handle specific biometric error codes
    if (message.contains('BIOMETRIC_NOT_ENROLLED')) {
      actionWidget = SnackBarAction(
        label: 'Set Up',
        onPressed: () {
          // Open device settings or show setup dialog
          _showBiometricSetupDialog(context, ref);
        },
      );
    } else if (message.contains('BIOMETRIC_NOT_AVAILABLE')) {
      actionWidget = SnackBarAction(
        label: 'Learn More',
        onPressed: () => _showBiometricHelpDialog(context),
      );
    }

    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.fingerprint, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(_formatBiometricError(message))),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        action: actionWidget ??
            SnackBarAction(
              label: 'Dismiss',
              onPressed: () {
                ref.read(biometricSettingsProvider.notifier).clearError();
              },
            ),
        duration: const Duration(seconds: 8),
      ),
    );
  }

  void _showMagicLinkErrorSnackBar(BuildContext context, String message, WidgetRef ref) {
    if (!context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();

    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.link, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(_formatErrorMessage(message))),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Retry',
          onPressed: () {
            ref.read(magicLinkProvider.notifier).clearMessages();
          },
        ),
        duration: const Duration(seconds: 6),
      ),
    );
  }

  void _showWebAuthnErrorSnackBar(BuildContext context, String message, WidgetRef ref) {
    if (!context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();

    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.security, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(_formatErrorMessage(message))),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Dismiss',
          onPressed: () {
            ref.read(webAuthnProvider.notifier).clearMessages();
          },
        ),
        duration: const Duration(seconds: 6),
      ),
    );
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();

    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  String _formatErrorMessage(String message) {
    // Remove common error prefixes
    return message
        .replaceFirst('Exception: ', '')
        .replaceFirst('Error: ', '')
        .replaceFirst('DioError: ', '')
        .trim();
  }

  String _formatBiometricError(String message) {
    // Convert technical biometric error messages to user-friendly ones
    if (message.contains('BIOMETRIC_NOT_AVAILABLE')) {
      return 'Biometric authentication is not available on this device';
    } else if (message.contains('BIOMETRIC_NOT_ENROLLED')) {
      return 'No biometric authentication is set up. Please set up fingerprint or face recognition in your device settings.';
    } else if (message.contains('BIOMETRIC_LOCKED_OUT')) {
      return 'Biometric authentication is temporarily locked. Please try again later or use your device password.';
    } else if (message.contains('USER_CANCELLED')) {
      return 'Biometric authentication was cancelled';
    } else if (message.contains('USER_FALLBACK')) {
      return 'Biometric authentication fallback selected';
    }

    return _formatErrorMessage(message);
  }

  void _showBiometricSetupDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Up Biometric Authentication'),
        content: const Text(
          'To use biometric authentication, please set up fingerprint or face recognition in your device settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // In a real app, you would open device settings
              // For now, just try to enable biometric auth again
              ref.read(biometricSettingsProvider.notifier).promptSetup();
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  void _showBiometricHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Biometric Authentication Help'),
        content: const Text(
          'Your device does not support biometric authentication, or it may be disabled. '
          'Check your device settings to ensure fingerprint or face recognition is available and enabled.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

/// Error dialog for critical authentication errors
class AuthErrorDialog {
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onRetry,
    VoidCallback? onCancel,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(width: 12),
              Text(title),
            ],
          ),
          content: Text(message),
          actions: <Widget>[
            if (onCancel != null)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onCancel();
                },
                child: const Text('Cancel'),
              ),
            if (onRetry != null)
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onRetry();
                },
                child: const Text('Retry'),
              ),
            if (onRetry == null && onCancel == null)
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
          ],
        );
      },
    );
  }
}