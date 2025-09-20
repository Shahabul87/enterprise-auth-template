import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

/// Collection of loading indicators and spinners for the app
class LoadingIndicators {
  LoadingIndicators._();

  /// Full screen loading overlay
  static Widget fullScreenLoader({
    String? message,
    Color? backgroundColor,
    Color? indicatorColor,
  }) {
    return Container(
      color: backgroundColor ?? Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                indicatorColor ?? Colors.white,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Small circular loading indicator
  static Widget circular({
    double size = 24,
    double strokeWidth = 2,
    Color? color,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: color != null ? AlwaysStoppedAnimation<Color>(color) : null,
      ),
    );
  }

  /// iOS style activity indicator
  static Widget ios({double radius = 10, bool animating = true}) {
    return CupertinoActivityIndicator(radius: radius, animating: animating);
  }

  /// Linear progress indicator
  static Widget linear({
    double? value,
    Color? backgroundColor,
    Color? valueColor,
    double? minHeight,
  }) {
    return LinearProgressIndicator(
      value: value,
      backgroundColor: backgroundColor,
      valueColor: valueColor != null
          ? AlwaysStoppedAnimation<Color>(valueColor)
          : null,
      minHeight: minHeight,
    );
  }

  /// Custom pulsing dot loader
  static Widget pulsingDots({
    int count = 3,
    double size = 10,
    Color? color,
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    return PulsingDotLoader(
      count: count,
      size: size,
      color: color,
      duration: duration,
    );
  }

  /// Loading button with integrated spinner
  static Widget button({
    required bool isLoading,
    required Widget child,
    double indicatorSize = 16,
    Color? indicatorColor,
  }) {
    if (!isLoading) return child;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: indicatorSize,
          height: indicatorSize,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: indicatorColor != null
                ? AlwaysStoppedAnimation<Color>(indicatorColor)
                : null,
          ),
        ),
        const SizedBox(width: 8),
        child,
      ],
    );
  }

  /// Adaptive loader that switches between Material and Cupertino
  static Widget adaptive({double size = 24, Color? color}) {
    return Theme(
      data: ThemeData(
        cupertinoOverrideTheme: CupertinoThemeData(brightness: Brightness.dark),
      ),
      child: Builder(
        builder: (context) {
          final platform = Theme.of(context).platform;
          if (platform == TargetPlatform.iOS ||
              platform == TargetPlatform.macOS) {
            return ios(radius: size / 2);
          }
          return circular(size: size, color: color);
        },
      ),
    );
  }
}

/// Custom pulsing dot loader widget
class PulsingDotLoader extends StatefulWidget {
  final int count;
  final double size;
  final Color? color;
  final Duration duration;

  const PulsingDotLoader({
    Key? key,
    this.count = 3,
    this.size = 10,
    this.color,
    this.duration = const Duration(milliseconds: 1500),
  }) : super(key: key);

  @override
  State<PulsingDotLoader> createState() => _PulsingDotLoaderState();
}

class _PulsingDotLoaderState extends State<PulsingDotLoader>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _controllers = List.generate(
      widget.count,
      (index) => AnimationController(duration: widget.duration, vsync: this),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
    }).toList();

    for (int i = 0; i < widget.count; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dotColor = widget.color ?? theme.colorScheme.primary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.count, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: widget.size * 0.3),
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dotColor.withValues(
                  alpha: 0.3 + (_animations[index].value * 0.7),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

/// Loading overlay that can be shown over any widget
class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? loadingMessage;
  final Color? overlayColor;
  final Color? indicatorColor;

  const LoadingOverlay({
    Key? key,
    required this.child,
    required this.isLoading,
    this.loadingMessage,
    this.overlayColor,
    this.indicatorColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: LoadingIndicators.fullScreenLoader(
              message: loadingMessage,
              backgroundColor: overlayColor,
              indicatorColor: indicatorColor,
            ),
          ),
      ],
    );
  }
}

/// Skeleton loader for content placeholders
class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final Color? baseColor;
  final Color? highlightColor;

  const SkeletonLoader({
    Key? key,
    required this.width,
    required this.height,
    this.borderRadius,
    this.baseColor,
    this.highlightColor,
  }) : super(key: key);

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final baseColor =
        widget.baseColor ?? (isDark ? Colors.grey[800] : Colors.grey[300])!;
    final highlightColor =
        widget.highlightColor ??
        (isDark ? Colors.grey[700] : Colors.grey[100])!;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(4),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value, 0),
              colors: [baseColor, highlightColor, baseColor],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}
