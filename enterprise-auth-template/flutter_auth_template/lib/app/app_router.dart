import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_auth_template/presentation/providers/auth_provider.dart';
import 'package:flutter_auth_template/presentation/pages/splash_screen.dart';
import 'package:flutter_auth_template/presentation/pages/auth/modern_login_screen.dart';
import 'package:flutter_auth_template/presentation/pages/auth/modern_register_screen.dart';
import 'package:flutter_auth_template/presentation/pages/auth/two_factor_setup_screen.dart';
import 'package:flutter_auth_template/presentation/pages/auth/two_factor_verify_screen.dart';
import 'package:flutter_auth_template/presentation/pages/dashboard/dashboard_screen.dart';
import 'package:flutter_auth_template/presentation/pages/home/modern_home_screen.dart';
import 'package:flutter_auth_template/presentation/pages/home/public_home_screen.dart';
import 'package:flutter_auth_template/presentation/pages/auth/forgot_password_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // Watch the auth state - this will cause router to rebuild when auth changes
  final authState = ref.watch(authStateProvider);

  // Get authentication status
  final isAuthenticated = authState.when(
    authenticated: (_, __, ___) => true,
    error: (_) => false,
    authenticating: () => false,
    unauthenticated: () => false,
  );

  debugPrint('Router rebuild - isAuthenticated: $isAuthenticated');

  return GoRouter(
    initialLocation: '/home',
    debugLogDiagnostics: true, // Enable debug logging
    redirect: (BuildContext context, GoRouterState state) {
      final isGoingToLogin = state.matchedLocation == '/auth/login';
      final isGoingToRegister = state.matchedLocation == '/auth/register';
      final isGoingToHome = state.matchedLocation == '/home';
      final isGoingToDashboard = state.matchedLocation == '/dashboard';
      final isGoingToSplash = state.matchedLocation == '/splash';
      final isGoingToForgotPassword = state.matchedLocation == '/auth/forgot-password';
      final isGoingTo2FA = state.matchedLocation.startsWith('/auth/2fa');

      debugPrint('Router redirect - auth: $isAuthenticated, path: ${state.matchedLocation}');

      // Handle authentication redirects
      if (isAuthenticated) {
        // Authenticated users should not see login/register pages
        if (isGoingToLogin || isGoingToRegister) {
          debugPrint('Authenticated user on auth page - redirecting to dashboard');
          return '/dashboard';
        }
        // Authenticated users on home should go to dashboard
        if (isGoingToHome) {
          debugPrint('Authenticated user on home - redirecting to dashboard');
          return '/dashboard';
        }
      } else {
        // Unauthenticated users cannot access protected pages
        if (isGoingToDashboard) {
          debugPrint('Unauthenticated user on dashboard - redirecting to home');
          return '/home';
        }
      }

      return null; // No redirect needed
    },
    routes: [
      // Public Home Screen
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const PublicHomeScreen(),
      ),

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
        builder: (context, state) => const ModernLoginScreen(),
      ),
      GoRoute(
        path: '/auth/register',
        name: 'register',
        builder: (context, state) => const ModernRegisterScreen(),
      ),
      GoRoute(
        path: '/auth/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
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
        redirect: (context, state) => '/home',
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
        builder: (context, state) => const ModernLoginScreen(),
      ),
      GoRoute(
        path: '/auth/register',
        name: 'register',
        builder: (context, state) => const ModernRegisterScreen(),
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