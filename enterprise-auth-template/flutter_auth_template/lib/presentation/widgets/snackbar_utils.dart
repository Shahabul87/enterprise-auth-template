import 'package:flutter/material.dart';

/// Utility class for showing consistent snackbars throughout the app
class SnackBarUtils {
  SnackBarUtils._();

  /// Show a success snackbar
  static void showSuccess({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
    bool showIcon = true,
    IconData? icon,
  }) {
    _showSnackBar(
      context: context,
      message: message,
      type: SnackBarType.success,
      duration: duration,
      action: action,
      showIcon: showIcon,
      icon: icon ?? Icons.check_circle_outline,
    );
  }

  /// Show an error snackbar
  static void showError({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
    bool showIcon = true,
    IconData? icon,
  }) {
    _showSnackBar(
      context: context,
      message: message,
      type: SnackBarType.error,
      duration: duration,
      action: action,
      showIcon: showIcon,
      icon: icon ?? Icons.error_outline,
    );
  }

  /// Show an info snackbar
  static void showInfo({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
    bool showIcon = true,
    IconData? icon,
  }) {
    _showSnackBar(
      context: context,
      message: message,
      type: SnackBarType.info,
      duration: duration,
      action: action,
      showIcon: showIcon,
      icon: icon ?? Icons.info_outline,
    );
  }

  /// Show a warning snackbar
  static void showWarning({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
    bool showIcon = true,
    IconData? icon,
  }) {
    _showSnackBar(
      context: context,
      message: message,
      type: SnackBarType.warning,
      duration: duration,
      action: action,
      showIcon: showIcon,
      icon: icon ?? Icons.warning_amber_outlined,
    );
  }

  /// Show a custom snackbar
  static void showCustom({
    required BuildContext context,
    required String message,
    Color? backgroundColor,
    Color? textColor,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
    Widget? leading,
    Widget? trailing,
    EdgeInsetsGeometry? margin,
    ShapeBorder? shape,
    double? elevation,
    SnackBarBehavior? behavior,
  }) {
    final theme = Theme.of(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (leading != null) ...[leading, const SizedBox(width: 12)],
            Expanded(
              child: Text(message, style: TextStyle(color: textColor)),
            ),
            if (trailing != null) ...[const SizedBox(width: 12), trailing],
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        action: action,
        margin: margin,
        shape:
            shape ??
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: behavior ?? SnackBarBehavior.floating,
        elevation: elevation ?? 4,
      ),
    );
  }

  /// Show a loading snackbar with indefinite duration
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showLoading({
    required BuildContext context,
    required String message,
    Color? backgroundColor,
    Color? progressColor,
  }) {
    final theme = Theme.of(context);

    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  progressColor ?? Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: backgroundColor ?? theme.colorScheme.primary,
        duration: const Duration(days: 1), // Indefinite
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  /// Show a confirmation snackbar with action buttons
  static void showConfirmation({
    required BuildContext context,
    required String message,
    required String confirmLabel,
    required VoidCallback onConfirm,
    String cancelLabel = 'Cancel',
    VoidCallback? onCancel,
    Duration duration = const Duration(seconds: 5),
  }) {
    final theme = Theme.of(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        action: SnackBarAction(
          label: confirmLabel,
          onPressed: onConfirm,
          textColor: theme.colorScheme.secondary,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  /// Internal method to show snackbar
  static void _showSnackBar({
    required BuildContext context,
    required String message,
    required SnackBarType type,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
    bool showIcon = true,
    IconData? icon,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final config = _getSnackBarConfig(type, colorScheme);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (showIcon) ...[
              Icon(icon ?? config.icon, color: config.iconColor, size: 20),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(message, style: TextStyle(color: config.textColor)),
            ),
          ],
        ),
        backgroundColor: config.backgroundColor,
        duration: duration,
        action: action,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
        elevation: 4,
      ),
    );
  }

  /// Get configuration for different snackbar types
  static SnackBarConfig _getSnackBarConfig(
    SnackBarType type,
    ColorScheme colorScheme,
  ) {
    switch (type) {
      case SnackBarType.success:
        return SnackBarConfig(
          backgroundColor: Colors.green.shade600,
          textColor: Colors.white,
          iconColor: Colors.white,
          icon: Icons.check_circle_outline,
        );
      case SnackBarType.error:
        return SnackBarConfig(
          backgroundColor: colorScheme.error,
          textColor: colorScheme.onError,
          iconColor: colorScheme.onError,
          icon: Icons.error_outline,
        );
      case SnackBarType.warning:
        return SnackBarConfig(
          backgroundColor: Colors.orange.shade700,
          textColor: Colors.white,
          iconColor: Colors.white,
          icon: Icons.warning_amber_outlined,
        );
      case SnackBarType.info:
        return SnackBarConfig(
          backgroundColor: Colors.blue.shade600,
          textColor: Colors.white,
          iconColor: Colors.white,
          icon: Icons.info_outline,
        );
    }
  }

  /// Clear all snackbars
  static void clear(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
  }

  /// Hide current snackbar
  static void hide(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }
}

/// Enum for different snackbar types
enum SnackBarType { success, error, warning, info }

/// Configuration for snackbar appearance
class SnackBarConfig {
  final Color backgroundColor;
  final Color textColor;
  final Color iconColor;
  final IconData icon;

  const SnackBarConfig({
    required this.backgroundColor,
    required this.textColor,
    required this.iconColor,
    required this.icon,
  });
}

/// Extension on BuildContext for easier snackbar access
extension SnackBarExtension on BuildContext {
  void showSuccessSnackBar(String message, {Duration? duration}) {
    SnackBarUtils.showSuccess(
      context: this,
      message: message,
      duration: duration ?? const Duration(seconds: 3),
    );
  }

  void showErrorSnackBar(String message, {Duration? duration}) {
    SnackBarUtils.showError(
      context: this,
      message: message,
      duration: duration ?? const Duration(seconds: 4),
    );
  }

  void showInfoSnackBar(String message, {Duration? duration}) {
    SnackBarUtils.showInfo(
      context: this,
      message: message,
      duration: duration ?? const Duration(seconds: 3),
    );
  }

  void showWarningSnackBar(String message, {Duration? duration}) {
    SnackBarUtils.showWarning(
      context: this,
      message: message,
      duration: duration ?? const Duration(seconds: 3),
    );
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showLoadingSnackBar(
    String message,
  ) {
    return SnackBarUtils.showLoading(context: this, message: message);
  }

  void clearSnackBars() {
    SnackBarUtils.clear(this);
  }

  void hideCurrentSnackBar() {
    SnackBarUtils.hide(this);
  }
}
