import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Accessibility manager for enhanced app accessibility
class AccessibilityManager {
  static final AccessibilityManager _instance = AccessibilityManager._internal();
  factory AccessibilityManager() => _instance;
  AccessibilityManager._internal();

  // Accessibility preferences
  bool _isScreenReaderEnabled = false;
  bool _isHighContrastEnabled = false;
  bool _isReducedMotionEnabled = false;
  bool _isLargeFontsEnabled = false;
  double _textScaleFactor = 1.0;

  // Preference keys
  static const String _keyHighContrast = 'accessibility_high_contrast';
  static const String _keyReducedMotion = 'accessibility_reduced_motion';
  static const String _keyLargeFonts = 'accessibility_large_fonts';
  static const String _keyTextScale = 'accessibility_text_scale';

  /// Initialize accessibility settings
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();

    _isHighContrastEnabled = prefs.getBool(_keyHighContrast) ?? false;
    _isReducedMotionEnabled = prefs.getBool(_keyReducedMotion) ?? false;
    _isLargeFontsEnabled = prefs.getBool(_keyLargeFonts) ?? false;
    _textScaleFactor = prefs.getDouble(_keyTextScale) ?? 1.0;

    // Check system accessibility settings
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkSystemAccessibility();
    });
  }

  void _checkSystemAccessibility() {
    final window = WidgetsBinding.instance.platformDispatcher;
    _isScreenReaderEnabled = window.accessibilityFeatures.accessibleNavigation;
  }

  // Getters
  bool get isScreenReaderEnabled => _isScreenReaderEnabled;
  bool get isHighContrastEnabled => _isHighContrastEnabled;
  bool get isReducedMotionEnabled => _isReducedMotionEnabled;
  bool get isLargeFontsEnabled => _isLargeFontsEnabled;
  double get textScaleFactor => _textScaleFactor;

  // Setters with persistence
  Future<void> setHighContrast(bool enabled) async {
    _isHighContrastEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHighContrast, enabled);
  }

  Future<void> setReducedMotion(bool enabled) async {
    _isReducedMotionEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyReducedMotion, enabled);
  }

  Future<void> setLargeFonts(bool enabled) async {
    _isLargeFontsEnabled = enabled;
    _textScaleFactor = enabled ? 1.3 : 1.0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLargeFonts, enabled);
    await prefs.setDouble(_keyTextScale, _textScaleFactor);
  }

  Future<void> setTextScale(double scale) async {
    _textScaleFactor = scale.clamp(0.8, 2.0);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyTextScale, _textScaleFactor);
  }

  /// Get animation duration based on reduced motion preference
  Duration getAnimationDuration(Duration normalDuration) {
    if (_isReducedMotionEnabled) {
      return Duration.zero;
    }
    return normalDuration;
  }

  /// Get animation curve based on reduced motion preference
  Curve getAnimationCurve(Curve normalCurve) {
    if (_isReducedMotionEnabled) {
      return Curves.linear;
    }
    return normalCurve;
  }

  /// Announce message for screen readers
  static void announce(String message, {TextDirection textDirection = TextDirection.ltr}) {
    SemanticsService.announce(message, textDirection);
  }

  /// Get accessible color for high contrast mode
  Color getAccessibleColor(Color normalColor, Color highContrastColor) {
    if (_isHighContrastEnabled) {
      return highContrastColor;
    }
    return normalColor;
  }

  /// Generate semantic label for complex widgets
  static String generateSemanticLabel({
    String? label,
    String? hint,
    String? value,
    bool? isButton,
    bool? isChecked,
    bool? isSelected,
  }) {
    final parts = <String>[];

    if (label != null) parts.add(label);
    if (value != null) parts.add(value);
    if (isButton == true) parts.add('button');
    if (isChecked == true) parts.add('checked');
    if (isSelected == true) parts.add('selected');
    if (hint != null) parts.add(hint);

    return parts.join(', ');
  }
}

/// Accessibility-aware button widget
class AccessibleButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final String semanticLabel;
  final String? tooltip;
  final bool excludeFromSemantics;

  const AccessibleButton({
    super.key,
    required this.onPressed,
    required this.child,
    required this.semanticLabel,
    this.tooltip,
    this.excludeFromSemantics = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget button = ElevatedButton(
      onPressed: onPressed,
      child: child,
    );

    if (tooltip != null) {
      button = Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return Semantics(
      button: true,
      label: semanticLabel,
      excludeSemantics: excludeFromSemantics,
      child: button,
    );
  }
}

/// Accessibility-aware form field widget
class AccessibleFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final String? hint;
  final String? errorText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? semanticLabel;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;

  const AccessibleFormField({
    super.key,
    this.controller,
    required this.label,
    this.hint,
    this.errorText,
    this.keyboardType,
    this.obscureText = false,
    this.semanticLabel,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel ?? label,
      hint: hint,
      textField: true,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          errorText: errorText,
        ),
        keyboardType: keyboardType,
        obscureText: obscureText,
        onChanged: (value) {
          if (onChanged != null) {
            onChanged!(value);
            // Announce changes for screen readers
            if (errorText != null) {
              AccessibilityManager.announce(errorText!);
            }
          }
        },
        validator: validator,
      ),
    );
  }
}

/// Accessibility-aware image widget
class AccessibleImage extends StatelessWidget {
  final ImageProvider image;
  final String semanticLabel;
  final double? width;
  final double? height;
  final BoxFit? fit;

  const AccessibleImage({
    super.key,
    required this.image,
    required this.semanticLabel,
    this.width,
    this.height,
    this.fit,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      image: true,
      child: Image(
        image: image,
        width: width,
        height: height,
        fit: fit,
        semanticLabel: semanticLabel,
      ),
    );
  }
}

/// Widget to provide skip navigation for screen readers
class SkipToContent extends StatelessWidget {
  final VoidCallback onSkip;
  final String label;

  const SkipToContent({
    super.key,
    required this.onSkip,
    this.label = 'Skip to main content',
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onSkip,
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Text(
            label,
            style: const TextStyle(
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ),
    );
  }
}

/// Focus management utilities
class FocusManagement {
  /// Request focus for accessibility
  static void requestFocus(BuildContext context, FocusNode node) {
    FocusScope.of(context).requestFocus(node);
    // Announce focus change
    AccessibilityManager.announce('Focus moved');
  }

  /// Create focus trap for modals
  static Widget createFocusTrap({
    required Widget child,
    required bool isActive,
  }) {
    if (!isActive) return child;

    return FocusTraversalGroup(
      policy: OrderedTraversalPolicy(),
      child: child,
    );
  }

  /// Navigate focus programmatically
  static void navigateFocus(BuildContext context, {bool forward = true}) {
    if (forward) {
      FocusScope.of(context).nextFocus();
    } else {
      FocusScope.of(context).previousFocus();
    }
  }
}

/// Mixin for adding accessibility features to widgets
mixin AccessibilityMixin<T extends StatefulWidget> on State<T> {
  late AccessibilityManager _accessibilityManager;

  @override
  void initState() {
    super.initState();
    _accessibilityManager = AccessibilityManager();
  }

  /// Get appropriate animation duration
  Duration getAnimationDuration(Duration normal) {
    return _accessibilityManager.getAnimationDuration(normal);
  }

  /// Get appropriate animation curve
  Curve getAnimationCurve(Curve normal) {
    return _accessibilityManager.getAnimationCurve(normal);
  }

  /// Get accessible color
  Color getAccessibleColor(Color normal, Color highContrast) {
    return _accessibilityManager.getAccessibleColor(normal, highContrast);
  }

  /// Check if animations should be disabled
  bool get shouldDisableAnimations => _accessibilityManager.isReducedMotionEnabled;

  /// Get text scale factor
  double get textScaleFactor => _accessibilityManager.textScaleFactor;
}