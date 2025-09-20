import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/entities/auth_state.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/auth/enhanced_login_form.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to auth state changes for navigation
    ref.listen<AuthState>(authStateProvider, (previous, next) {
      next.when(
        authenticated: (user, _, __) {
          // Navigate to dashboard on successful authentication
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context.go('/dashboard');
            }
          });
        },
        unauthenticated: () {},
        authenticating: () {},
        error: (message) {
          // Error is handled in the form widget
        },
      );
    });

    return Scaffold(
      body: SafeArea(
        child: EnhancedLoginForm(
          onSuccess: () {
            // Navigation is handled by the auth state listener
          },
          onForgotPassword: () {
            context.push('/auth/forgot-password');
          },
          onRegister: () {
            context.go('/register');
          },
        ),
      ),
    );
  }
}
