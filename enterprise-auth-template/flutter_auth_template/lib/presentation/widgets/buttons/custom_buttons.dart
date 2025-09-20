import 'package:flutter/material.dart';

/// Custom button widget with various styles and configurations
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  final ButtonType type;
  final ButtonSize size;
  final Widget? icon;
  final bool isLoading;
  final bool isFullWidth;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Color? color;
  final Color? textColor;
  final double? elevation;
  final Widget? child;

  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.style,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.padding,
    this.borderRadius,
    this.color,
    this.textColor,
    this.elevation,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final buttonStyle = style ?? _getButtonStyle(context);
    final buttonChild = _buildButtonChild(context);

    Widget button;

    switch (type) {
      case ButtonType.primary:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: buttonChild,
        );
        break;
      case ButtonType.secondary:
        button = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: buttonChild,
        );
        break;
      case ButtonType.text:
        button = TextButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: buttonChild,
        );
        break;
      case ButtonType.icon:
        if (icon == null) {
          throw ArgumentError('Icon is required for ButtonType.icon');
        }
        button = IconButton(
          onPressed: isLoading ? null : onPressed,
          icon: icon!,
          padding: padding ?? _getPadding(),
        );
        break;
      case ButtonType.elevated:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle.copyWith(
            elevation: MaterialStateProperty.all(elevation ?? 4),
          ),
          child: buttonChild,
        );
        break;
      case ButtonType.tonal:
        button = FilledButton.tonal(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: buttonChild,
        );
        break;
    }

    if (isFullWidth) {
      button = SizedBox(width: double.infinity, child: button);
    }

    return button;
  }

  ButtonStyle _getButtonStyle(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color? backgroundColor;
    Color? foregroundColor;
    BorderSide? side;

    switch (type) {
      case ButtonType.primary:
        backgroundColor = color ?? colorScheme.primary;
        foregroundColor = textColor ?? colorScheme.onPrimary;
        break;
      case ButtonType.secondary:
        backgroundColor = Colors.transparent;
        foregroundColor = textColor ?? colorScheme.primary;
        side = BorderSide(color: color ?? colorScheme.outline);
        break;
      case ButtonType.text:
        backgroundColor = Colors.transparent;
        foregroundColor = textColor ?? colorScheme.primary;
        break;
      case ButtonType.elevated:
        backgroundColor = color ?? colorScheme.primaryContainer;
        foregroundColor = textColor ?? colorScheme.onPrimaryContainer;
        break;
      case ButtonType.tonal:
        backgroundColor = color ?? colorScheme.secondaryContainer;
        foregroundColor = textColor ?? colorScheme.onSecondaryContainer;
        break;
      default:
        backgroundColor = color;
        foregroundColor = textColor;
    }

    return ButtonStyle(
      backgroundColor: MaterialStateProperty.all(backgroundColor),
      foregroundColor: MaterialStateProperty.all(foregroundColor),
      padding: MaterialStateProperty.all(padding ?? _getPadding()),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(8),
          side: side ?? BorderSide.none,
        ),
      ),
      elevation: MaterialStateProperty.all(elevation ?? 0),
    );
  }

  EdgeInsetsGeometry _getPadding() {
    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 10);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 14);
    }
  }

  double _getFontSize() {
    switch (size) {
      case ButtonSize.small:
        return 13;
      case ButtonSize.medium:
        return 15;
      case ButtonSize.large:
        return 17;
    }
  }

  Widget _buildButtonChild(BuildContext context) {
    if (child != null) return child!;

    final fontSize = _getFontSize();
    final textWidget = Text(text, style: TextStyle(fontSize: fontSize));

    if (isLoading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: fontSize,
            height: fontSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                textColor ?? Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          textWidget,
        ],
      );
    }

    if (icon != null && type != ButtonType.icon) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [icon!, const SizedBox(width: 8), textWidget],
      );
    }

    return textWidget;
  }
}

/// Button types enum
enum ButtonType { primary, secondary, text, icon, elevated, tonal }

/// Button sizes enum
enum ButtonSize { small, medium, large }

/// Gradient button widget
class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Gradient gradient;
  final double? width;
  final double height;
  final BorderRadius? borderRadius;
  final Widget? icon;
  final bool isLoading;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;

  const GradientButton({
    Key? key,
    required this.text,
    this.onPressed,
    required this.gradient,
    this.width,
    this.height = 50,
    this.borderRadius,
    this.icon,
    this.isLoading = false,
    this.textStyle,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        boxShadow: onPressed != null
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
          child: Container(
            padding:
                padding ??
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            alignment: Alignment.center,
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[icon!, const SizedBox(width: 8)],
                      Text(
                        text,
                        style:
                            textStyle ??
                            const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// Social login button
class SocialLoginButton extends StatelessWidget {
  final SocialPlatform platform;
  final VoidCallback? onPressed;
  final String? text;
  final bool isLoading;
  final ButtonSize size;
  final bool showIcon;

  const SocialLoginButton({
    Key? key,
    required this.platform,
    this.onPressed,
    this.text,
    this.isLoading = false,
    this.size = ButtonSize.medium,
    this.showIcon = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final config = _getSocialConfig();

    return CustomButton(
      text: text ?? config.defaultText,
      onPressed: onPressed,
      type: ButtonType.secondary,
      size: size,
      icon: showIcon ? config.icon : null,
      isLoading: isLoading,
      isFullWidth: true,
      color: config.backgroundColor,
      textColor: config.textColor,
    );
  }

  SocialButtonConfig _getSocialConfig() {
    switch (platform) {
      case SocialPlatform.google:
        return SocialButtonConfig(
          icon: const Icon(Icons.g_mobiledata, size: 24),
          defaultText: 'Continue with Google',
          backgroundColor: Colors.white,
          textColor: Colors.black87,
        );
      case SocialPlatform.apple:
        return SocialButtonConfig(
          icon: const Icon(Icons.apple, size: 24),
          defaultText: 'Continue with Apple',
          backgroundColor: Colors.black,
          textColor: Colors.white,
        );
      case SocialPlatform.facebook:
        return SocialButtonConfig(
          icon: const Icon(Icons.facebook, size: 24),
          defaultText: 'Continue with Facebook',
          backgroundColor: const Color(0xFF1877F2),
          textColor: Colors.white,
        );
      case SocialPlatform.github:
        return SocialButtonConfig(
          icon: const Icon(Icons.code, size: 24),
          defaultText: 'Continue with GitHub',
          backgroundColor: const Color(0xFF24292E),
          textColor: Colors.white,
        );
      case SocialPlatform.twitter:
        return SocialButtonConfig(
          icon: const Icon(Icons.flutter_dash, size: 24),
          defaultText: 'Continue with Twitter',
          backgroundColor: const Color(0xFF1DA1F2),
          textColor: Colors.white,
        );
    }
  }
}

/// Social platform enum
enum SocialPlatform { google, apple, facebook, github, twitter }

/// Social button configuration
class SocialButtonConfig {
  final Widget icon;
  final String defaultText;
  final Color backgroundColor;
  final Color textColor;

  const SocialButtonConfig({
    required this.icon,
    required this.defaultText,
    required this.backgroundColor,
    required this.textColor,
  });
}

/// Floating action button with multiple options
class ExpandableFAB extends StatefulWidget {
  final List<FABAction> actions;
  final IconData icon;
  final IconData? closeIcon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Duration animationDuration;

  const ExpandableFAB({
    Key? key,
    required this.actions,
    this.icon = Icons.add,
    this.closeIcon,
    this.backgroundColor,
    this.foregroundColor,
    this.animationDuration = const Duration(milliseconds: 300),
  }) : super(key: key);

  @override
  State<ExpandableFAB> createState() => _ExpandableFABState();
}

class _ExpandableFABState extends State<ExpandableFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ...widget.actions.map((action) {
          final index = widget.actions.indexOf(action);
          return AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, (1 - _animation.value) * 60 * (index + 1)),
                child: Opacity(
                  opacity: _animation.value,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (action.label != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Text(
                              action.label!,
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                        FloatingActionButton.small(
                          onPressed: () {
                            action.onPressed();
                            _toggle();
                          },
                          backgroundColor:
                              action.backgroundColor ??
                              colorScheme.secondaryContainer,
                          foregroundColor:
                              action.foregroundColor ??
                              colorScheme.onSecondaryContainer,
                          heroTag: 'fab_action_$index',
                          child: Icon(action.icon),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }),
        FloatingActionButton(
          onPressed: _toggle,
          backgroundColor: widget.backgroundColor ?? colorScheme.primary,
          foregroundColor: widget.foregroundColor ?? colorScheme.onPrimary,
          child: AnimatedRotation(
            duration: widget.animationDuration,
            turns: _isExpanded ? 0.125 : 0,
            child: Icon(
              _isExpanded ? (widget.closeIcon ?? Icons.close) : widget.icon,
            ),
          ),
        ),
      ],
    );
  }
}

/// FAB action model
class FABAction {
  final IconData icon;
  final VoidCallback onPressed;
  final String? label;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const FABAction({
    required this.icon,
    required this.onPressed,
    this.label,
    this.backgroundColor,
    this.foregroundColor,
  });
}
