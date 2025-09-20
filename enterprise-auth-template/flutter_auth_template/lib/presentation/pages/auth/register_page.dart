import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_auth_template/domain/entities/auth_state.dart';
import 'package:flutter_auth_template/presentation/providers/auth_provider.dart';
import 'package:flutter_auth_template/presentation/widgets/auth/enhanced_registration_form.dart';

class RegisterPage extends ConsumerWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to auth state changes for navigation
    ref.listen<AuthState>(authStateProvider, (previous, next) {
      next.when(
        authenticated: (user, _, __) {
          // Navigate to dashboard on successful registration
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
        child: EnhancedRegistrationForm(
          onSuccess: () {
            // Navigation is handled by the auth state listener
          },
          onLogin: () {
            context.go('/login');
          },
        ),
      ),
    );
  }
}
