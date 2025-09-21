import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_auth_template/presentation/widgets/security/session_timeout_warning.dart' as widgets;
import 'package:flutter_auth_template/presentation/providers/auth_provider.dart';
import 'package:flutter_auth_template/core/security/session_timeout_manager.dart';
import 'package:flutter_auth_template/domain/entities/auth_state.dart';

/// Wrapper widget that provides security features to the entire app
class SecureAppWrapper extends HookConsumerWidget {
  final Widget child;
  final bool enableSessionTimer;
  final bool enableTimeoutWarning;
  final bool enableAutoLogout;

  const SecureAppWrapper({
    super.key,
    required this.child,
    this.enableSessionTimer = true,
    this.enableTimeoutWarning = true,
    this.enableAutoLogout = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final sessionManager = ref.watch(sessionTimeoutManagerProvider);

    final showAutoLogout = useState(false);
    final showTimeoutWarning = useState(false);

    // Initialize session management for authenticated users
    useEffect(() {
      if (authState is Authenticated && enableTimeoutWarning) {
        sessionManager.initializeSession(
          onWarning: () {
            if (enableTimeoutWarning) {
              showTimeoutWarning.value = true;
            }
          },
          onTimeout: () {
            if (enableAutoLogout) {
              showAutoLogout.value = true;
              showTimeoutWarning.value = false;
            }
          },
        );
      } else {
        sessionManager.clearSession();
      }

      return () {
        sessionManager.clearSession();
      };
    }, [authState]);

    // Track user activity
    useEffect(() {
      // Note: User activity is tracked through gesture detectors
      // in the widget tree below
      return null;
    }, [authState]);

    return Stack(
      children: [
        // Main app content
        GestureDetector(
          onTap: () {
            // Update activity on any tap
            if (authState is Authenticated) {
              sessionManager.updateActivity();
            }
          },
          onPanUpdate: (_) {
            // Update activity on any pan gesture
            if (authState is Authenticated) {
              sessionManager.updateActivity();
            }
          },
          child: child,
        ),

        // Session timer widget (floating)
        if (authState is Authenticated && enableSessionTimer)
          const widgets.SessionTimerWidget(),

        // Session timeout warning dialog
        if (showTimeoutWarning.value)
          widgets.SessionTimeoutWarning(
            onExtendSession: () {
              showTimeoutWarning.value = false;
              sessionManager.updateActivity();
            },
            onLogout: () {
              showTimeoutWarning.value = false;
              showAutoLogout.value = false;
            },
          ),

        // Auto-logout countdown
        if (showAutoLogout.value)
          widgets.AutoLogoutCountdown(
            countdownSeconds: 10,
            onCancel: () {
              showAutoLogout.value = false;
              sessionManager.updateActivity();
            },
          ),
      ],
    );
  }
}

/// Activity detector widget that wraps individual screens
class ActivityDetector extends HookConsumerWidget {
  final Widget child;
  final Duration inactivityDuration;
  final VoidCallback? onInactivity;

  const ActivityDetector({
    super.key,
    required this.child,
    this.inactivityDuration = const Duration(minutes: 5),
    this.onInactivity,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionManager = ref.watch(sessionTimeoutManagerProvider);
    final lastActivity = useState(DateTime.now());

    useEffect(() {
      final timer = Timer.periodic(const Duration(seconds: 1), (t) {
        final elapsed = DateTime.now().difference(lastActivity.value);
        if (elapsed >= inactivityDuration) {
          onInactivity?.call();
          t.cancel();
        }
      });

      return () => timer.cancel();
    }, []);

    void updateActivity() {
      lastActivity.value = DateTime.now();
      sessionManager.updateActivity();
    }

    return GestureDetector(
      onTap: updateActivity,
      onPanUpdate: (_) => updateActivity(),
      onScaleUpdate: (_) => updateActivity(),
      child: MouseRegion(
        onHover: (_) => updateActivity(),
        child: child,
      ),
    );
  }
}

/// Security overlay for sensitive screens
class SecurityOverlay extends StatelessWidget {
  final Widget child;
  final bool blurWhenInactive;
  final Duration inactivityDuration;

  const SecurityOverlay({
    super.key,
    required this.child,
    this.blurWhenInactive = true,
    this.inactivityDuration = const Duration(seconds: 30),
  });

  @override
  Widget build(BuildContext context) {
    return ActivityDetector(
      inactivityDuration: inactivityDuration,
      onInactivity: () {
        // You can add custom behavior here
      },
      child: child,
    );
  }
}