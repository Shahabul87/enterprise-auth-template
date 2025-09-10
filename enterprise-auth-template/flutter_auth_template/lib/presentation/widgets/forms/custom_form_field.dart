import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/theme.dart';

class CustomFormField extends StatefulWidget {
  final TextEditingController? controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final void Function()? onTap;
  final bool readOnly;
  final bool enabled;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool showCounter;
  final FocusNode? focusNode;
  final List<String>? autofillHints;
  final bool autovalidateMode;
  final EdgeInsetsGeometry? contentPadding;

  const CustomFormField({
    super.key,
    this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.onTap,
    this.readOnly = false,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.showCounter = false,
    this.focusNode,
    this.autofillHints,
    this.autovalidateMode = false,
    this.contentPadding,
  });

  @override
  State<CustomFormField> createState() => _CustomFormFieldState();
}

class _CustomFormFieldState extends State<CustomFormField>
    with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  late AnimationController _animationController;
  late Animation<double> _focusAnimation;
  bool _isFocused = false;
  bool _hasError = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChanged);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _focusAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _focusNode.removeListener(_onFocusChanged);
    _animationController.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
    if (_isFocused) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _focusAnimation,
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.label.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: theme.textTheme.labelMedium!.copyWith(
                    color: _hasError
                        ? AppTheme.errorColor
                        : _isFocused
                        ? AppTheme.primaryColor
                        : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    fontWeight: _isFocused ? FontWeight.w600 : FontWeight.w500,
                  ),
                  child: Text(widget.label),
                ),
              ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  if (_isFocused)
                    BoxShadow(
                      color:
                          (_hasError
                                  ? AppTheme.errorColor
                                  : AppTheme.primaryColor)
                              .withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: TextFormField(
                controller: widget.controller,
                focusNode: _focusNode,
                obscureText: widget.obscureText,
                keyboardType: widget.keyboardType,
                textInputAction: widget.textInputAction,
                inputFormatters: widget.inputFormatters,
                onChanged: widget.onChanged,
                onFieldSubmitted: widget.onFieldSubmitted,
                onTap: widget.onTap,
                readOnly: widget.readOnly,
                enabled: widget.enabled,
                maxLines: widget.obscureText ? 1 : widget.maxLines,
                minLines: widget.minLines,
                maxLength: widget.maxLength,
                autofillHints: widget.autofillHints,
                autovalidateMode: widget.autovalidateMode
                    ? AutovalidateMode.onUserInteraction
                    : AutovalidateMode.disabled,
                style: theme.textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                  prefixIcon: widget.prefixIcon != null
                      ? AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.all(12),
                          child: Icon(
                            widget.prefixIcon,
                            size: 20,
                            color: _hasError
                                ? AppTheme.errorColor
                                : _isFocused
                                ? AppTheme.primaryColor
                                : theme.colorScheme.onSurface.withValues(
                                    alpha: 0.5,
                                  ),
                          ),
                        )
                      : null,
                  suffixIcon: widget.suffixIcon,
                  counterText: widget.showCounter ? null : '',
                  contentPadding:
                      widget.contentPadding ??
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  filled: true,
                  fillColor: widget.enabled
                      ? theme.colorScheme.surface
                      : theme.colorScheme.onSurface.withValues(alpha: 0.03),
                  errorText: _errorText,
                  errorStyle: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.errorColor,
                    fontWeight: FontWeight.w500,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.primaryColor,
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.errorColor,
                      width: 1,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.errorColor,
                      width: 2,
                    ),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.05,
                      ),
                      width: 1,
                    ),
                  ),
                ),
                validator: (value) {
                  final error = widget.validator?.call(value);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      _hasError = error != null;
                      _errorText = error;
                    });
                  });
                  return error;
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

// Email Form Field with built-in validation
class EmailFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final String? hint;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final TextInputAction? textInputAction;
  final bool enabled;

  const EmailFormField({
    super.key,
    this.controller,
    this.label = 'Email Address',
    this.hint = 'Enter your email',
    this.onChanged,
    this.onFieldSubmitted,
    this.textInputAction = TextInputAction.next,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return CustomFormField(
      controller: controller,
      label: label,
      hint: hint,
      prefixIcon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      enabled: enabled,
      autofillHints: const [AutofillHints.email],
      inputFormatters: [
        FilteringTextInputFormatter.deny(RegExp(r'\s')), // No spaces
        LengthLimitingTextInputFormatter(100),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        }
        final emailRegex = RegExp(
          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
        );
        if (!emailRegex.hasMatch(value)) {
          return 'Please enter a valid email address';
        }
        return null;
      },
    );
  }
}

// Password Form Field with strength indicator
class PasswordFormField extends StatefulWidget {
  final TextEditingController? controller;
  final String label;
  final String? hint;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final TextInputAction? textInputAction;
  final bool showStrengthIndicator;
  final bool enabled;
  final String? Function(String?)? customValidator;

  const PasswordFormField({
    super.key,
    this.controller,
    this.label = 'Password',
    this.hint = 'Enter your password',
    this.onChanged,
    this.onFieldSubmitted,
    this.textInputAction = TextInputAction.done,
    this.showStrengthIndicator = false,
    this.enabled = true,
    this.customValidator,
  });

  @override
  State<PasswordFormField> createState() => _PasswordFormFieldState();
}

class _PasswordFormFieldState extends State<PasswordFormField> {
  bool _obscureText = true;
  double _strength = 0.0;
  String _strengthText = '';
  Color _strengthColor = Colors.grey;

  void _calculateStrength(String password) {
    if (!widget.showStrengthIndicator) return;

    double strength = 0;
    String strengthText = '';
    Color strengthColor = Colors.grey;

    if (password.isEmpty) {
      setState(() {
        _strength = 0;
        _strengthText = '';
        _strengthColor = Colors.grey;
      });
      return;
    }

    // Length check
    if (password.length >= 8) strength += 0.25;
    if (password.length >= 12) strength += 0.25;

    // Contains lowercase
    if (password.contains(RegExp(r'[a-z]'))) strength += 0.125;

    // Contains uppercase
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.125;

    // Contains numbers
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.125;

    // Contains special characters
    if (password.contains(RegExp(r'[!@#\$&*~%^()]'))) strength += 0.125;

    if (strength <= 0.25) {
      strengthText = 'Weak';
      strengthColor = AppTheme.errorColor;
    } else if (strength <= 0.5) {
      strengthText = 'Fair';
      strengthColor = AppTheme.warningColor;
    } else if (strength <= 0.75) {
      strengthText = 'Good';
      strengthColor = Colors.orange;
    } else {
      strengthText = 'Strong';
      strengthColor = AppTheme.successColor;
    }

    setState(() {
      _strength = strength;
      _strengthText = strengthText;
      _strengthColor = strengthColor;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomFormField(
          controller: widget.controller,
          label: widget.label,
          hint: widget.hint,
          prefixIcon: Icons.lock_outline,
          obscureText: _obscureText,
          textInputAction: widget.textInputAction,
          enabled: widget.enabled,
          autofillHints: const [AutofillHints.password],
          suffixIcon: IconButton(
            icon: Icon(
              _obscureText
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            onPressed: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
          ),
          onChanged: (value) {
            _calculateStrength(value);
            widget.onChanged?.call(value);
          },
          onFieldSubmitted: widget.onFieldSubmitted,
          validator:
              widget.customValidator ??
              (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                if (value.length < 8) {
                  return 'Password must be at least 8 characters';
                }
                if (widget.showStrengthIndicator && _strength < 0.5) {
                  return 'Password is too weak';
                }
                return null;
              },
        ),
        if (widget.showStrengthIndicator && _strength > 0) ...[
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Password Strength:', style: theme.textTheme.bodySmall),
                  Text(
                    _strengthText,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _strengthColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _strength,
                  backgroundColor: theme.colorScheme.onSurface.withValues(
                    alpha: 0.1,
                  ),
                  valueColor: AlwaysStoppedAnimation<Color>(_strengthColor),
                  minHeight: 4,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
