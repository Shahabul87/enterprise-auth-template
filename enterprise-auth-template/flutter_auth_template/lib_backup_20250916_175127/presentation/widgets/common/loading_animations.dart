import 'package:flutter/material.dart';
import 'dart:math' as math;

class LoadingAnimations {
  LoadingAnimations._();

  /// Shimmer loading effect for content placeholders
  static Widget shimmer({
    required Widget child,
    Duration duration = const Duration(milliseconds: 1500),
    Color? baseColor,
    Color? highlightColor,
  }) {
    return _ShimmerWidget(
      duration: duration,
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: child,
    );
  }

  /// Pulsing dot loader
  static Widget pulsingDots({
    int dotCount = 3,
    double dotSize = 8.0,
    Color? color,
    Duration duration = const Duration(milliseconds: 1200),
  }) {
    return _PulsingDotsWidget(
      dotCount: dotCount,
      dotSize: dotSize,
      color: color,
      duration: duration,
    );
  }

  /// Wave loading animation
  static Widget wave({
    double height = 40.0,
    double width = 100.0,
    Color? color,
    Duration duration = const Duration(milliseconds: 1000),
  }) {
    return _WaveWidget(
      height: height,
      width: width,
      color: color,
      duration: duration,
    );
  }

  /// Skeleton loading for cards
  static Widget skeletonCard({
    double? width,
    double height = 200.0,
    BorderRadius? borderRadius,
    bool showAvatar = true,
    int textLines = 3,
  }) {
    return _SkeletonCard(
      width: width,
      height: height,
      borderRadius: borderRadius,
      showAvatar: showAvatar,
      textLines: textLines,
    );
  }

  /// Skeleton loading for list items
  static Widget skeletonListItem({
    bool showLeading = true,
    bool showTrailing = false,
    int subtitleLines = 1,
  }) {
    return _SkeletonListItem(
      showLeading: showLeading,
      showTrailing: showTrailing,
      subtitleLines: subtitleLines,
    );
  }

  /// Rotating spinner with custom icons
  static Widget iconSpinner({
    required IconData icon,
    double size = 24.0,
    Color? color,
    Duration duration = const Duration(milliseconds: 1000),
  }) {
    return _IconSpinnerWidget(
      icon: icon,
      size: size,
      color: color,
      duration: duration,
    );
  }

  /// Bouncing balls animation
  static Widget bouncingBalls({
    int ballCount = 3,
    double ballSize = 12.0,
    Color? color,
    Duration duration = const Duration(milliseconds: 1200),
  }) {
    return _BouncingBallsWidget(
      ballCount: ballCount,
      ballSize: ballSize,
      color: color,
      duration: duration,
    );
  }

  /// Typing indicator animation
  static Widget typingIndicator({
    Color? color,
    double dotSize = 6.0,
    Duration duration = const Duration(milliseconds: 1400),
  }) {
    return _TypingIndicatorWidget(
      color: color,
      dotSize: dotSize,
      duration: duration,
    );
  }

  /// Progress bar with animation
  static Widget progressBar({
    required double progress,
    double height = 4.0,
    Color? backgroundColor,
    Color? progressColor,
    Duration animationDuration = const Duration(milliseconds: 300),
  }) {
    return _AnimatedProgressBar(
      progress: progress,
      height: height,
      backgroundColor: backgroundColor,
      progressColor: progressColor,
      animationDuration: animationDuration,
    );
  }

  /// Loading overlay that can be shown over content
  static Widget overlay({
    required bool isLoading,
    required Widget child,
    Widget? loadingWidget,
    Color? overlayColor,
    String? loadingText,
  }) {
    return _LoadingOverlay(
      isLoading: isLoading,
      loadingWidget: loadingWidget,
      overlayColor: overlayColor,
      loadingText: loadingText,
      child: child,
    );
  }
}

class _ShimmerWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Color? baseColor;
  final Color? highlightColor;

  const _ShimmerWidget({
    required this.child,
    required this.duration,
    this.baseColor,
    this.highlightColor,
  });

  @override
  State<_ShimmerWidget> createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<_ShimmerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.baseColor ?? Colors.grey[300]!;
    final highlightColor = widget.highlightColor ?? Colors.grey[100]!;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [baseColor, highlightColor, baseColor],
              stops: [
                0.0,
                _animation.value.clamp(0.0, 1.0),
                1.0,
              ],
              transform: GradientRotation(_animation.value),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

class _PulsingDotsWidget extends StatefulWidget {
  final int dotCount;
  final double dotSize;
  final Color? color;
  final Duration duration;

  const _PulsingDotsWidget({
    required this.dotCount,
    required this.dotSize,
    this.color,
    required this.duration,
  });

  @override
  State<_PulsingDotsWidget> createState() => _PulsingDotsWidgetState();
}

class _PulsingDotsWidgetState extends State<_PulsingDotsWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.dotCount, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final delay = index / widget.dotCount;
            final animationValue = (_controller.value + delay) % 1.0;
            final scale = 0.5 + (0.5 * (1.0 - (animationValue - 0.5).abs() * 2));

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: widget.dotSize,
                  height: widget.dotSize,
                  decoration: BoxDecoration(
                    color: widget.color ?? Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class _WaveWidget extends StatefulWidget {
  final double height;
  final double width;
  final Color? color;
  final Duration duration;

  const _WaveWidget({
    required this.height,
    required this.width,
    this.color,
    required this.duration,
  });

  @override
  State<_WaveWidget> createState() => _WaveWidgetState();
}

class _WaveWidgetState extends State<_WaveWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _WavePainter(
              animationValue: _controller.value,
              color: widget.color ?? Theme.of(context).primaryColor,
            ),
            size: Size(widget.width, widget.height),
          );
        },
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final double animationValue;
  final Color color;

  _WavePainter({required this.animationValue, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final waveHeight = size.height * 0.2;
    final waveWidth = size.width;

    path.moveTo(0, size.height / 2);

    for (double x = 0; x <= waveWidth; x += 1) {
      final y = size.height / 2 +
          waveHeight *
              math.sin((x / waveWidth * 2 * math.pi) + (animationValue * 2 * math.pi));
      path.lineTo(x, y);
    }

    path.lineTo(waveWidth, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _SkeletonCard extends StatelessWidget {
  final double? width;
  final double height;
  final BorderRadius? borderRadius;
  final bool showAvatar;
  final int textLines;

  const _SkeletonCard({
    this.width,
    required this.height,
    this.borderRadius,
    required this.showAvatar,
    required this.textLines,
  });

  @override
  Widget build(BuildContext context) {
    return LoadingAnimations.shimmer(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showAvatar)
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: 100,
                            height: 12,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              ...List.generate(
                textLines,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    width: index == textLines - 1
                        ? MediaQuery.of(context).size.width * 0.6
                        : double.infinity,
                    height: 14,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SkeletonListItem extends StatelessWidget {
  final bool showLeading;
  final bool showTrailing;
  final int subtitleLines;

  const _SkeletonListItem({
    required this.showLeading,
    required this.showTrailing,
    required this.subtitleLines,
  });

  @override
  Widget build(BuildContext context) {
    return LoadingAnimations.shimmer(
      child: ListTile(
        leading: showLeading
            ? Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.grey,
                  shape: BoxShape.circle,
                ),
              )
            : null,
        title: Container(
          width: double.infinity,
          height: 16,
          color: Colors.grey[300],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(
            subtitleLines,
            (index) => Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Container(
                width: index == subtitleLines - 1
                    ? MediaQuery.of(context).size.width * 0.5
                    : double.infinity,
                height: 12,
                color: Colors.grey[300],
              ),
            ),
          ),
        ),
        trailing: showTrailing
            ? Container(
                width: 20,
                height: 20,
                color: Colors.grey[300],
              )
            : null,
      ),
    );
  }
}

class _IconSpinnerWidget extends StatefulWidget {
  final IconData icon;
  final double size;
  final Color? color;
  final Duration duration;

  const _IconSpinnerWidget({
    required this.icon,
    required this.size,
    this.color,
    required this.duration,
  });

  @override
  State<_IconSpinnerWidget> createState() => _IconSpinnerWidgetState();
}

class _IconSpinnerWidgetState extends State<_IconSpinnerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * math.pi,
          child: Icon(
            widget.icon,
            size: widget.size,
            color: widget.color ?? Theme.of(context).primaryColor,
          ),
        );
      },
    );
  }
}

class _BouncingBallsWidget extends StatefulWidget {
  final int ballCount;
  final double ballSize;
  final Color? color;
  final Duration duration;

  const _BouncingBallsWidget({
    required this.ballCount,
    required this.ballSize,
    this.color,
    required this.duration,
  });

  @override
  State<_BouncingBallsWidget> createState() => _BouncingBallsWidgetState();
}

class _BouncingBallsWidgetState extends State<_BouncingBallsWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.ballSize * 2,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(widget.ballCount, (index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final delay = index / widget.ballCount;
              final animationValue = (_controller.value + delay) % 1.0;
              final bounce = math.sin(animationValue * math.pi).abs();

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                child: Transform.translate(
                  offset: Offset(0, -bounce * widget.ballSize),
                  child: Container(
                    width: widget.ballSize,
                    height: widget.ballSize,
                    decoration: BoxDecoration(
                      color: widget.color ?? Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

class _TypingIndicatorWidget extends StatefulWidget {
  final Color? color;
  final double dotSize;
  final Duration duration;

  const _TypingIndicatorWidget({
    this.color,
    required this.dotSize,
    required this.duration,
  });

  @override
  State<_TypingIndicatorWidget> createState() => _TypingIndicatorWidgetState();
}

class _TypingIndicatorWidgetState extends State<_TypingIndicatorWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final delay = index * 0.2;
            final animationValue = (_controller.value + delay) % 1.0;
            final opacity = animationValue < 0.5
                ? (animationValue * 2)
                : (2 - animationValue * 2);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: Opacity(
                opacity: opacity.clamp(0.3, 1.0),
                child: Container(
                  width: widget.dotSize,
                  height: widget.dotSize,
                  decoration: BoxDecoration(
                    color: widget.color ?? Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class _AnimatedProgressBar extends StatelessWidget {
  final double progress;
  final double height;
  final Color? backgroundColor;
  final Color? progressColor;
  final Duration animationDuration;

  const _AnimatedProgressBar({
    required this.progress,
    required this.height,
    this.backgroundColor,
    this.progressColor,
    required this.animationDuration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey[300],
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: AnimatedContainer(
        duration: animationDuration,
        width: double.infinity,
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: progress.clamp(0.0, 1.0),
          child: Container(
            decoration: BoxDecoration(
              color: progressColor ?? Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(height / 2),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final Widget? loadingWidget;
  final Color? overlayColor;
  final String? loadingText;

  const _LoadingOverlay({
    required this.isLoading,
    required this.child,
    this.loadingWidget,
    this.overlayColor,
    this.loadingText,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: overlayColor ?? Colors.black.withOpacity(0.3),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  loadingWidget ??
                      LoadingAnimations.pulsingDots(
                        color: Colors.white,
                        dotSize: 12,
                      ),
                  if (loadingText != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      loadingText!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// Extension for easy loading state management
extension LoadingStateExtension on Widget {
  Widget withLoadingOverlay({
    required bool isLoading,
    Widget? loadingWidget,
    Color? overlayColor,
    String? loadingText,
  }) {
    return LoadingAnimations.overlay(
      isLoading: isLoading,
      loadingWidget: loadingWidget,
      overlayColor: overlayColor,
      loadingText: loadingText,
      child: this,
    );
  }
}

