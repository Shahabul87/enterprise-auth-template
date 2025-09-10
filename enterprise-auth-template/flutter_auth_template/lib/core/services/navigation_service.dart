import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final navigationServiceProvider = Provider<NavigationService>((ref) {
  return NavigationService();
});

/// Service for handling navigation from anywhere in the app
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// Get the current context
  BuildContext? get currentContext => navigatorKey.currentContext;

  /// Navigate to login and clear the navigation stack
  void navigateToLogin() {
    final context = currentContext;
    if (context != null && context.mounted) {
      context.go('/login');
    }
  }

  /// Navigate to dashboard
  void navigateToDashboard() {
    final context = currentContext;
    if (context != null && context.mounted) {
      context.go('/dashboard');
    }
  }

  /// Navigate to a specific route
  void navigateTo(String route) {
    final context = currentContext;
    if (context != null && context.mounted) {
      context.go(route);
    }
  }

  /// Push a route onto the navigation stack
  void pushRoute(String route) {
    final context = currentContext;
    if (context != null && context.mounted) {
      context.push(route);
    }
  }

  /// Pop the current route
  void pop() {
    final context = currentContext;
    if (context != null && context.mounted && context.canPop()) {
      context.pop();
    }
  }

  /// Check if we can pop the current route
  bool canPop() {
    final context = currentContext;
    if (context != null && context.mounted) {
      return context.canPop();
    }
    return false;
  }

  /// Show a snackbar with a message
  void showSnackBar(String message, {bool isError = false}) {
    final context = currentContext;
    if (context != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : null,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Show an error snackbar
  void showErrorSnackBar(String message) {
    showSnackBar(message, isError: true);
  }
}
