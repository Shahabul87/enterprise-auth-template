import 'package:flutter/material.dart';

/// Enhanced loading overlay with authentication-specific states
class AuthLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final String? loadingMessage;
  final Widget child;
  final Color? backgroundColor;

  const AuthLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.loadingMessage,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: backgroundColor ?? Colors.black54,
            child: Center(
              child: Card(
                margin: const EdgeInsets.all(32),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        loadingMessage ?? 'Please wait...',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Specific loading states for different authentication methods
class AuthLoadingStates {
  static const String emailLogin = 'Signing in with email...';
  static const String googleOAuth = 'Signing in with Google...';
  static const String appleOAuth = 'Signing in with Apple...';
  static const String biometric = 'Authenticating with biometrics...';
  static const String magicLink = 'Sending magic link...';
  static const String webauthn = 'Authenticating with passkey...';
  static const String twoFactor = 'Verifying two-factor code...';
  static const String registration = 'Creating your account...';
  static const String passwordReset = 'Sending password reset email...';
  static const String logout = 'Signing out...';
  static const String refreshing = 'Refreshing session...';
}