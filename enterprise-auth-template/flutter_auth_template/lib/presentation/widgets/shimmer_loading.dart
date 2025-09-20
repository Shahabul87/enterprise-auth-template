import 'package:flutter/material.dart';

/// Shimmer loading effect widget for content placeholders
class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final bool isLoading;
  final Duration duration;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerLoading({
    Key? key,
    required this.child,
    required this.isLoading,
    this.duration = const Duration(milliseconds: 1500),
    this.baseColor,
    this.highlightColor,
  }) : super(key: key);

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this)
      ..repeat();

    _animation = Tween<double>(
      begin: -2.0,
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
    if (!widget.isLoading) {
      return widget.child;
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final baseColor =
        widget.baseColor ??
        (isDark ? Colors.grey.shade800 : Colors.grey.shade300);
    final highlightColor =
        widget.highlightColor ??
        (isDark ? Colors.grey.shade700 : Colors.grey.shade100);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                baseColor,
                baseColor,
                highlightColor,
                baseColor,
                baseColor,
              ],
              stops: [
                0.0,
                (_animation.value - 1) / 2,
                _animation.value / 2,
                (_animation.value + 1) / 2,
                1.0,
              ],
              transform: const GradientRotation(0.5),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
    );
  }
}

/// Pre-built shimmer components for common use cases
class ShimmerComponents {
  ShimmerComponents._();

  /// List item shimmer placeholder
  static Widget listItem({
    double height = 80,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
    bool showAvatar = true,
  }) {
    return Container(
      height: height,
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showAvatar) ...[
            const ShimmerBox(width: 48, height: 48, shape: BoxShape.circle),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const ShimmerBox(height: 16, width: double.infinity),
                const SizedBox(height: 8),
                ShimmerBox(
                  height: 14,
                  width: double.infinity,
                  widthFactor: 0.7,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Card shimmer placeholder
  static Widget card({
    double height = 200,
    double? width,
    EdgeInsetsGeometry margin = const EdgeInsets.all(16),
  }) {
    return Container(
      height: height,
      width: width,
      margin: margin,
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerBox(
              height: height * 0.6,
              width: double.infinity,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerBox(height: 16, width: double.infinity),
                  const SizedBox(height: 8),
                  ShimmerBox(
                    height: 14,
                    width: double.infinity,
                    widthFactor: 0.6,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Grid item shimmer placeholder
  static Widget gridItem({double aspectRatio = 1.0}) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Card(
        child: Column(
          children: [
            Expanded(
              child: ShimmerBox(
                width: double.infinity,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  const ShimmerBox(height: 14, width: double.infinity),
                  const SizedBox(height: 4),
                  ShimmerBox(
                    height: 12,
                    width: double.infinity,
                    widthFactor: 0.5,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Text lines shimmer placeholder
  static Widget textLines({
    int lines = 3,
    double lineHeight = 14,
    double spacing = 8,
    List<double>? widthFactors,
  }) {
    final factors =
        widthFactors ?? List.generate(lines, (i) => i == lines - 1 ? 0.5 : 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(lines, (index) {
        return Padding(
          padding: EdgeInsets.only(bottom: index < lines - 1 ? spacing : 0),
          child: ShimmerBox(
            height: lineHeight,
            width: double.infinity,
            widthFactor: factors[index],
          ),
        );
      }),
    );
  }

  /// User profile shimmer placeholder
  static Widget userProfile() {
    return Column(
      children: [
        const ShimmerBox(width: 100, height: 100, shape: BoxShape.circle),
        const SizedBox(height: 16),
        const ShimmerBox(height: 20, width: 150),
        const SizedBox(height: 8),
        const ShimmerBox(height: 16, width: 200),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(3, (index) {
            return Column(
              children: [
                const ShimmerBox(height: 24, width: 40),
                const SizedBox(height: 4),
                const ShimmerBox(height: 14, width: 60),
              ],
            );
          }),
        ),
      ],
    );
  }
}

/// Basic shimmer box widget
class ShimmerBox extends StatelessWidget {
  final double? width;
  final double? height;
  final double widthFactor;
  final BoxShape shape;
  final BorderRadius? borderRadius;

  const ShimmerBox({
    Key? key,
    this.width,
    this.height,
    this.widthFactor = 1.0,
    this.shape = BoxShape.rectangle,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;

    Widget container = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: baseColor,
        shape: shape,
        borderRadius: shape == BoxShape.rectangle
            ? (borderRadius ?? BorderRadius.circular(4))
            : null,
      ),
    );

    if (width == double.infinity && widthFactor < 1.0) {
      container = FractionallySizedBox(
        widthFactor: widthFactor,
        alignment: Alignment.centerLeft,
        child: container,
      );
    }

    return ShimmerLoading(isLoading: true, child: container);
  }
}

/// List view with shimmer loading
class ShimmerListView extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final bool isLoading;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;

  const ShimmerListView({
    Key? key,
    required this.itemCount,
    required this.itemBuilder,
    required this.isLoading,
    this.physics,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: physics,
      padding: padding,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return ShimmerLoading(
          isLoading: isLoading,
          child: itemBuilder(context, index),
        );
      },
    );
  }
}

/// Grid view with shimmer loading
class ShimmerGridView extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final bool isLoading;
  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double childAspectRatio;
  final EdgeInsetsGeometry? padding;

  const ShimmerGridView({
    Key? key,
    required this.itemCount,
    required this.itemBuilder,
    required this.isLoading,
    required this.crossAxisCount,
    this.crossAxisSpacing = 10,
    this.mainAxisSpacing = 10,
    this.childAspectRatio = 1.0,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: padding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return ShimmerLoading(
          isLoading: isLoading,
          child: itemBuilder(context, index),
        );
      },
    );
  }
}
