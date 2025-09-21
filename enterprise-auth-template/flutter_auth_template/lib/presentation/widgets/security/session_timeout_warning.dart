import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_auth_template/core/security/session_timeout_manager.dart';
import 'package:flutter_auth_template/presentation/providers/auth_provider.dart';

/// Widget to display session timeout warning with countdown
class SessionTimeoutWarning extends HookConsumerWidget {
  final VoidCallback? onExtendSession;
  final VoidCallback? onLogout;

  const SessionTimeoutWarning({
    super.key,
    this.onExtendSession,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final sessionManager = ref.watch(sessionTimeoutManagerProvider);
    final authNotifier = ref.read(authStateProvider.notifier);

    final showWarning = useState(false);
    final remainingSeconds = useState(60);
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 300),
    );

    // Timer for countdown
    useEffect(() {
      Timer? countdownTimer;

      // Initialize session manager with callbacks
      sessionManager.initializeSession(
        onWarning: () {
          showWarning.value = true;
          remainingSeconds.value = 60;
          animationController.forward();

          // Start countdown
          countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
            if (remainingSeconds.value > 0) {
              remainingSeconds.value--;
            } else {
              timer.cancel();
              showWarning.value = false;
              animationController.reverse();
            }
          });
        },
        onTimeout: () async {
          showWarning.value = false;
          animationController.reverse();
          onLogout?.call();
          await authNotifier.logout();
        },
      );

      return () {
        countdownTimer?.cancel();
        animationController.dispose();
      };
    }, []);

    void handleExtendSession() {
      sessionManager.updateActivity();
      showWarning.value = false;
      animationController.reverse();
      onExtendSession?.call();
    }

    void handleLogout() async {
      showWarning.value = false;
      animationController.reverse();
      onLogout?.call();
      await authNotifier.logout();
    }

    if (!showWarning.value) {
      return const SizedBox.shrink();
    }

    return ScaleTransition(
      scale: animationController.drive(
        Tween<double>(begin: 0.8, end: 1.0).chain(
          CurveTween(curve: Curves.elasticOut),
        ),
      ),
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 16,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Warning icon with pulse animation
              TweenAnimationBuilder<double>(
                duration: const Duration(seconds: 1),
                tween: Tween(begin: 0.8, end: 1.2),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.withAlpha((0.1 * 255).round()),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.timer,
                        size: 48,
                        color: Colors.orange,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              // Title
              Text(
                'Session Timeout Warning',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              // Message
              Text(
                'Your session will expire due to inactivity.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              // Countdown display
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.access_time,
                      color: theme.colorScheme.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Time remaining: ',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                    Text(
                      '${remainingSeconds.value}s',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: remainingSeconds.value / 60,
                  backgroundColor: theme.colorScheme.error.withAlpha((0.2 * 255).round()),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    remainingSeconds.value > 30
                        ? Colors.orange
                        : theme.colorScheme.error,
                  ),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 24),
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Logout button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: handleLogout,
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                        side: BorderSide(color: theme.colorScheme.error),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Extend session button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: handleExtendSession,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Stay Logged In'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Floating session timer widget
class SessionTimerWidget extends HookConsumerWidget {
  const SessionTimerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final sessionManager = ref.watch(sessionTimeoutManagerProvider);

    final timeRemaining = useState<Duration?>(null);
    final isExpanded = useState(false);

    // Update timer every second
    useEffect(() {
      Timer? timer;

      void updateTimer() {
        final lastActivity = sessionManager.getLastActivityTime();
        if (lastActivity != null) {
          final elapsed = DateTime.now().difference(lastActivity);
          final remaining = Duration(
                  minutes: SessionTimeoutManager.sessionTimeoutMinutes) -
              elapsed;

          if (remaining.isNegative) {
            timeRemaining.value = Duration.zero;
          } else {
            timeRemaining.value = remaining;
          }
        }
      }

      updateTimer();
      timer = Timer.periodic(const Duration(seconds: 1), (_) => updateTimer());

      return () => timer?.cancel();
    }, []);

    if (timeRemaining.value == null) {
      return const SizedBox.shrink();
    }

    final minutes = timeRemaining.value!.inMinutes;
    final seconds = timeRemaining.value!.inSeconds % 60;
    final isWarning = minutes < 5;
    final isCritical = minutes < 1;

    Color getColor() {
      if (isCritical) return theme.colorScheme.error;
      if (isWarning) return Colors.orange;
      return theme.colorScheme.primary;
    }

    return Positioned(
      bottom: 80,
      right: 16,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: isExpanded.value ? 200 : 56,
        height: 56,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: getColor().withAlpha((0.3 * 255).round()),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: getColor().withAlpha((0.2 * 255).round()),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: () {
              isExpanded.value = !isExpanded.value;
              // Reset activity on interaction
              sessionManager.updateActivity();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isCritical
                        ? Icons.timer_off
                        : isWarning
                            ? Icons.timer
                            : Icons.access_time,
                    color: getColor(),
                  ),
                  if (isExpanded.value) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Session Timer',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurface.withAlpha((179).round()),
                            ),
                          ),
                          Text(
                            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: getColor(),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Auto-logout countdown overlay
class AutoLogoutCountdown extends HookConsumerWidget {
  final int countdownSeconds;
  final VoidCallback? onCancel;

  const AutoLogoutCountdown({
    super.key,
    this.countdownSeconds = 10,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authNotifier = ref.read(authStateProvider.notifier);

    final remainingSeconds = useState(countdownSeconds);
    final animationController = useAnimationController(
      duration: Duration(seconds: countdownSeconds),
    );

    useEffect(() {
      animationController.forward();

      final timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (remainingSeconds.value > 1) {
          remainingSeconds.value--;
        } else {
          t.cancel();
          authNotifier.logout();
        }
      });

      return () {
        timer.cancel();
        animationController.dispose();
      };
    }, []);

    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Circular countdown
              SizedBox(
                width: 100,
                height: 100,
                child: Stack(
                  children: [
                    // Background circle
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.colorScheme.outline.withAlpha((51).round()),
                          width: 8,
                        ),
                      ),
                    ),
                    // Animated progress circle
                    AnimatedBuilder(
                      animation: animationController,
                      builder: (context, child) {
                        return CustomPaint(
                          size: const Size(100, 100),
                          painter: _CircularCountdownPainter(
                            progress: 1 - animationController.value,
                            color: theme.colorScheme.error,
                          ),
                        );
                      },
                    ),
                    // Center text
                    Center(
                      child: Text(
                        '${remainingSeconds.value}',
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Logging out...',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your session has expired',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha((179).round()),
                ),
              ),
              if (onCancel != null) ...[
                const SizedBox(height: 20),
                TextButton(
                  onPressed: onCancel,
                  child: const Text('Cancel'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom painter for circular countdown
class _CircularCountdownPainter extends CustomPainter {
  final double progress;
  final Color color;

  _CircularCountdownPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * 3.14159 * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_CircularCountdownPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}