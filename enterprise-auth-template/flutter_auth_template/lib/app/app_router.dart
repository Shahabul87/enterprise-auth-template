import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../screens/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/two_factor_setup_screen.dart';
import '../screens/auth/two_factor_verify_screen.dart';
import '../screens/dashboard_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final isAuthenticated = ref.watch(isAuthenticatedProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (BuildContext context, GoRouterState state) {
      final isGoingToLogin = state.matchedLocation == '/auth/login';
      final isGoingToRegister = state.matchedLocation == '/auth/register';
      final isGoingToSplash = state.matchedLocation == '/splash';

      // If we're going to splash, let it through
      if (isGoingToSplash) {
        return null;
      }

      // If not authenticated and not going to auth screens, go to login
      if (!isAuthenticated && !isGoingToLogin && !isGoingToRegister) {
        return '/auth/login';
      }

      // If authenticated and going to auth screens, go to dashboard
      if (isAuthenticated && (isGoingToLogin || isGoingToRegister)) {
        return '/dashboard';
      }

      return null; // No redirect needed
    },
    routes: [
      // Splash Screen
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Authentication Routes
      GoRoute(
        path: '/auth/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/auth/2fa-setup',
        name: '2fa-setup',
        builder: (context, state) => const TwoFactorSetupScreen(),
      ),
      GoRoute(
        path: '/auth/2fa-verify',
        name: '2fa-verify',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'];
          final token = state.uri.queryParameters['token'];
          return TwoFactorVerifyScreen(email: email, token: token);
        },
      ),

      // Dashboard (Protected)
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),

      // Default redirect
      GoRoute(
        path: '/',
        redirect: (context, state) => '/splash',
      ),
    ],

    // Error handling
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'The page you are looking for does not exist.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});

// Alternative router without auth redirection for testing
final simpleRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/auth/login',
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/auth/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/',
        redirect: (context, state) => '/auth/login',
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64),
            const SizedBox(height: 16),
            const Text('Page not found'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});