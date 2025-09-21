import 'package:flutter/material.dart';
import 'dart:async';

/// Widget to display rate limiting status with visual feedback
class RateLimitIndicator extends StatefulWidget {
  final int retryAfterSeconds;
  final String message;
  final VoidCallback? onRetryComplete;

  const RateLimitIndicator({
    super.key,
    required this.retryAfterSeconds,
    this.message = 'Too many attempts. Please try again in:',
    this.onRetryComplete,
  });

  @override
  State<RateLimitIndicator> createState() => _RateLimitIndicatorState();
}

class _RateLimitIndicatorState extends State<RateLimitIndicator>
    with SingleTickerProviderStateMixin {
  late Timer _countdownTimer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.retryAfterSeconds;

    // Setup pulse animation
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    _pulseController.repeat(reverse: true);

    // Start countdown
    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
        widget.onRetryComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    if (minutes > 0) {
      return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
    }
    return '$seconds seconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.error.withAlpha((0.3 * 255).round()),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.error.withAlpha((0.1 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Animated warning icon
          ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withAlpha((0.1 * 255).round()),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.timer_off,
                color: theme.colorScheme.error,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Message and countdown
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(_remainingSeconds),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_remainingSeconds > 0) ...[
                  const SizedBox(height: 8),
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: 1 -
                          (_remainingSeconds / widget.retryAfterSeconds),
                      backgroundColor:
                          theme.colorScheme.error.withAlpha((0.2 * 255).round()),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.error,
                      ),
                      minHeight: 6,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple rate limit badge for inline display
class RateLimitBadge extends StatelessWidget {
  final int attemptsRemaining;
  final int maxAttempts;

  const RateLimitBadge({
    super.key,
    required this.attemptsRemaining,
    required this.maxAttempts,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentage = attemptsRemaining / maxAttempts;

    Color getColor() {
      if (percentage > 0.5) return Colors.green;
      if (percentage > 0.25) return Colors.orange;
      return theme.colorScheme.error;
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
            Icons.info_outline,
            size: 14,
            color: getColor(),
          ),
          const SizedBox(width: 4),
          Text(
            '$attemptsRemaining/$maxAttempts attempts',
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