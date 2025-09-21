import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_auth_template/presentation/widgets/auth/secure_login_form.dart';
import 'package:flutter_auth_template/presentation/widgets/security/secure_app_wrapper.dart';

/// Login page with integrated security features
class SecureLoginPage extends ConsumerWidget {
  const SecureLoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: SecureLoginForm(
          onSuccess: () {
            // Navigate to dashboard after successful login
            context.go('/dashboard');
          },
        ),
      ),
    );
  }
}

/// Example of how to wrap the entire app with security features
class SecureApp extends ConsumerWidget {
  final Widget child;

  const SecureApp({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SecureAppWrapper(
      enableSessionTimer: true,
      enableTimeoutWarning: true,
      enableAutoLogout: true,
      child: child,
    );
  }
}

/// Example usage in main app
class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp.router(
        title: 'Secure Flutter App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        routerConfig: GoRouter(
          routes: [
            GoRoute(
              path: '/login',
              builder: (context, state) => const SecureApp(
                child: SecureLoginPage(),
              ),
            ),
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => const SecureApp(
                child: DashboardPage(),
              ),
            ),
          ],
          initialLocation: '/login',
        ),
      ),
    );
  }
}

/// Example dashboard page
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SecurityOverlay(
      blurWhenInactive: false,
      inactivityDuration: Duration(minutes: 2),
      child: Scaffold(
        body: Center(
          child: Text('Secure Dashboard'),
        ),
      ),
    );
  }
}