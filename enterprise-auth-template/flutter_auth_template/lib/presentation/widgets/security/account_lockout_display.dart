import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:async';
import 'package:flutter_auth_template/core/security/account_lockout_service.dart';

/// Widget to display account lockout status with countdown timer
class AccountLockoutDisplay extends HookConsumerWidget {
  final String? email;
  final VoidCallback? onUnlockComplete;

  const AccountLockoutDisplay({
    super.key,
    this.email,
    this.onUnlockComplete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final lockoutService = ref.watch(accountLockoutServiceProvider);

    final isLocked = useState(false);
    final remainingMinutes = useState(0);
    final remainingSeconds = useState(0);
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 600),
    );

    // Check lockout status
    useEffect(() {
      Timer? timer;

      void checkLockout() async {
        final locked = await lockoutService.isAccountLocked();
        isLocked.value = locked;

        if (locked) {
          animationController.forward();
          final minutes = await lockoutService.getRemainingLockoutMinutes();
          remainingMinutes.value = minutes;
          remainingSeconds.value = 0;

          // Start countdown timer
          timer = Timer.periodic(const Duration(seconds: 1), (t) async {
            if (remainingSeconds.value > 0) {
              remainingSeconds.value--;
            } else if (remainingMinutes.value > 0) {
              remainingMinutes.value--;
              remainingSeconds.value = 59;
            } else {
              // Lockout period ended
              t.cancel();
              isLocked.value = false;
              animationController.reverse();
              onUnlockComplete?.call();
            }
          });
        }
      }

      checkLockout();

      return () {
        timer?.cancel();
        animationController.dispose();
      };
    }, []);

    if (!isLocked.value) {
      return const SizedBox.shrink();
    }

    return FadeTransition(
      opacity: animationController,
      child: SlideTransition(
        position: animationController.drive(
          Tween<Offset>(
            begin: const Offset(0, -0.1),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOut)),
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.error.withAlpha((0.1 * 255).round()),
                theme.colorScheme.errorContainer,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.error.withAlpha((0.3 * 255).round()),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.error.withAlpha((0.2 * 255).round()),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Lock icon with animation
              TweenAnimationBuilder<double>(
                duration: const Duration(seconds: 2),
                tween: Tween(begin: 0, end: 1),
                builder: (context, value, child) {
                  return Transform.rotate(
                    angle: value * 0.1,
                    child: Icon(
                      Icons.lock_clock,
                      size: 48,
                      color: theme.colorScheme.error,
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              // Title
              Text(
                'Account Temporarily Locked',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              // Description
              Text(
                'Too many failed login attempts detected.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                ),
                textAlign: TextAlign.center,
              ),
              if (email != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Account: $email',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onErrorContainer.withAlpha((179).round()),
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 16),
              // Countdown timer
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.error.withAlpha((0.2 * 255).round()),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Time remaining:',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha((179).round()),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _TimeUnit(
                          value: remainingMinutes.value,
                          label: 'MIN',
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            ':',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        _TimeUnit(
                          value: remainingSeconds.value,
                          label: 'SEC',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Additional info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withAlpha((128).round()),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'For security reasons, please wait for the timer to complete before attempting to login again.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Time unit display widget
class _TimeUnit extends StatelessWidget {
  final int value;
  final String label;

  const _TimeUnit({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.colorScheme.error.withAlpha((0.3 * 255).round()),
            ),
          ),
          child: Text(
            value.toString().padLeft(2, '0'),
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.error,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withAlpha((128).round()),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// Simple lockout badge for inline display
class AccountLockoutBadge extends StatelessWidget {
  final int failedAttempts;
  final int maxAttempts;

  const AccountLockoutBadge({
    super.key,
    required this.failedAttempts,
    required this.maxAttempts,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final remaining = maxAttempts - failedAttempts;
    final percentage = remaining / maxAttempts;

    if (failedAttempts == 0) {
      return const SizedBox.shrink();
    }

    Color getColor() {
      if (percentage > 0.5) return Colors.green;
      if (percentage > 0.25) return Colors.orange;
      return theme.colorScheme.error;
    }

    IconData getIcon() {
      if (percentage > 0.5) return Icons.check_circle_outline;
      if (percentage > 0.25) return Icons.warning_amber_rounded;
      return Icons.error_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: getColor().withAlpha((0.1 * 255).round()),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: getColor().withAlpha((0.3 * 255).round()),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            getIcon(),
            size: 14,
            color: getColor(),
          ),
          const SizedBox(width: 4),
          Text(
            remaining > 0
                ? '$remaining attempts left'
                : 'Account locked',
            style: theme.textTheme.labelSmall?.copyWith(
              color: getColor(),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}