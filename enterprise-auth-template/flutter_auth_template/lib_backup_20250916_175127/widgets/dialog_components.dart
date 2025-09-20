import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

/// Custom dialog utility class
class DialogUtils {
  DialogUtils._();

  /// Show confirmation dialog
  static Future<bool?> showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color? confirmColor,
    IconData? icon,
    bool barrierDismissible = true,
  }) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return ConfirmationDialog(
          title: title,
          message: message,
          confirmText: confirmText,
          cancelText: cancelText,
          confirmColor: confirmColor,
          icon: icon,
        );
      },
    );
  }

  /// Show information dialog
  static Future<void> showInfoDialog({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'OK',
    IconData? icon,
    Color? iconColor,
  }) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return InfoDialog(
          title: title,
          message: message,
          buttonText: buttonText,
          icon: icon,
          iconColor: iconColor,
        );
      },
    );
  }

  /// Show error dialog
  static Future<void> showErrorDialog({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'OK',
    VoidCallback? onDismiss,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return ErrorDialog(
          title: title,
          message: message,
          buttonText: buttonText,
        );
      },
    );
    onDismiss?.call();
  }

  /// Show loading dialog
  static void showLoadingDialog({
    required BuildContext context,
    String? message,
    bool barrierDismissible = false,
  }) {
    showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return LoadingDialog(message: message);
      },
    );
  }

  /// Show custom dialog
  static Future<T?> showCustomDialog<T>({
    required BuildContext context,
    required Widget child,
    bool barrierDismissible = true,
    Color? barrierColor,
    EdgeInsets? insetPadding,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor ?? Colors.black54,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding:
              insetPadding ??
              const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
          child: child,
        );
      },
    );
  }

  /// Show adaptive dialog (Material/Cupertino)
  static Future<T?> showAdaptiveDialog<T>({
    required BuildContext context,
    required String title,
    required String content,
    required List<DialogAction> actions,
  }) {
    final platform = Theme.of(context).platform;

    if (platform == TargetPlatform.iOS || platform == TargetPlatform.macOS) {
      return showCupertinoDialog<T>(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text(title),
          content: Text(content),
          actions: actions
              .map(
                (action) => CupertinoDialogAction(
                  onPressed: () {
                    Navigator.of(context).pop(action.value);
                    action.onPressed?.call();
                  },
                  isDefaultAction: action.isDefault,
                  isDestructiveAction: action.isDestructive,
                  child: Text(action.text),
                ),
              )
              .toList(),
        ),
      );
    }

    return showDialog<T>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: actions
            .map(
              (action) => TextButton(
                onPressed: () {
                  Navigator.of(context).pop(action.value);
                  action.onPressed?.call();
                },
                child: Text(
                  action.text,
                  style: TextStyle(
                    color: action.isDestructive
                        ? Theme.of(context).colorScheme.error
                        : null,
                    fontWeight: action.isDefault ? FontWeight.bold : null,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

/// Confirmation dialog widget
class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final Color? confirmColor;
  final IconData? icon;

  const ConfirmationDialog({
    Key? key,
    required this.title,
    required this.message,
    required this.confirmText,
    required this.cancelText,
    this.confirmColor,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: colorScheme.primary),
            const SizedBox(width: 12),
          ],
          Expanded(child: Text(title)),
        ],
      ),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelText),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: confirmColor != null
              ? ElevatedButton.styleFrom(backgroundColor: confirmColor)
              : null,
          child: Text(confirmText),
        ),
      ],
    );
  }
}

/// Information dialog widget
class InfoDialog extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;
  final IconData? icon;
  final Color? iconColor;

  const InfoDialog({
    Key? key,
    required this.title,
    required this.message,
    required this.buttonText,
    this.icon,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Column(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 48, color: iconColor ?? colorScheme.primary),
            const SizedBox(height: 16),
          ],
          Text(title, textAlign: TextAlign.center),
        ],
      ),
      content: Text(message, textAlign: TextAlign.center),
      actions: [
        Center(
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(buttonText),
          ),
        ),
      ],
    );
  }
}

/// Error dialog widget
class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;

  const ErrorDialog({
    Key? key,
    required this.title,
    required this.message,
    required this.buttonText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: colorScheme.errorContainer,
      title: Row(
        children: [
          Icon(Icons.error_outline, color: colorScheme.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(color: colorScheme.onErrorContainer),
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: TextStyle(color: colorScheme.onErrorContainer),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.error,
            foregroundColor: colorScheme.onError,
          ),
          child: Text(buttonText),
        ),
      ],
    );
  }
}

/// Loading dialog widget
class LoadingDialog extends StatelessWidget {
  final String? message;

  const LoadingDialog({Key? key, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Dialog action model
class DialogAction {
  final String text;
  final VoidCallback? onPressed;
  final bool isDefault;
  final bool isDestructive;
  final dynamic value;

  const DialogAction({
    required this.text,
    this.onPressed,
    this.isDefault = false,
    this.isDestructive = false,
    this.value,
  });
}

/// Full screen dialog
class FullScreenDialog extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final VoidCallback? onClose;

  const FullScreenDialog({
    Key? key,
    required this.title,
    required this.body,
    this.actions,
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            onClose?.call();
            Navigator.of(context).pop();
          },
        ),
        actions: actions,
      ),
      body: body,
    );
  }

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget body,
    List<Widget>? actions,
    VoidCallback? onClose,
  }) {
    return Navigator.of(context).push<T>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => FullScreenDialog(
          title: title,
          body: body,
          actions: actions,
          onClose: onClose,
        ),
      ),
    );
  }
}

/// Input dialog
class InputDialog extends StatefulWidget {
  final String title;
  final String? initialValue;
  final String? hintText;
  final String? labelText;
  final String confirmText;
  final String cancelText;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final int? maxLines;
  final int? maxLength;

  const InputDialog({
    Key? key,
    required this.title,
    this.initialValue,
    this.hintText,
    this.labelText,
    this.confirmText = 'OK',
    this.cancelText = 'Cancel',
    this.validator,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.maxLength,
  }) : super(key: key);

  static Future<String?> show({
    required BuildContext context,
    required String title,
    String? initialValue,
    String? hintText,
    String? labelText,
    String confirmText = 'OK',
    String cancelText = 'Cancel',
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int? maxLines = 1,
    int? maxLength,
  }) {
    return showDialog<String>(
      context: context,
      builder: (context) => InputDialog(
        title: title,
        initialValue: initialValue,
        hintText: hintText,
        labelText: labelText,
        confirmText: confirmText,
        cancelText: cancelText,
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
        maxLength: maxLength,
      ),
    );
  }

  @override
  State<InputDialog> createState() => _InputDialogState();
}

class _InputDialogState extends State<InputDialog> {
  late TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: widget.hintText,
            labelText: widget.labelText,
          ),
          validator: widget.validator,
          keyboardType: widget.keyboardType,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          autofocus: true,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(widget.cancelText),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.of(context).pop(_controller.text);
            }
          },
          child: Text(widget.confirmText),
        ),
      ],
    );
  }
}
