import 'package:flutter/material.dart';
import 'package:flutter_auth_template/core/security/password_strength_analyzer.dart';

/// A visual password strength meter widget
class PasswordStrengthMeter extends StatefulWidget {
  final String password;
  final bool showDetails;
  final bool showSuggestions;
  final bool showCrackTime;
  final ValueChanged<PasswordStrength>? onStrengthChanged;
  final double height;
  final BorderRadius? borderRadius;

  const PasswordStrengthMeter({
    Key? key,
    required this.password,
    this.showDetails = true,
    this.showSuggestions = true,
    this.showCrackTime = true,
    this.onStrengthChanged,
    this.height = 8.0,
    this.borderRadius,
  }) : super(key: key);

  @override
  State<PasswordStrengthMeter> createState() => _PasswordStrengthMeterState();
}

class _PasswordStrengthMeterState extends State<PasswordStrengthMeter>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  PasswordStrength? _strength;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _analyzePassword();
  }

  @override
  void didUpdateWidget(PasswordStrengthMeter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.password != widget.password) {
      _analyzePassword();
    }
  }

  void _analyzePassword() {
    final strength = PasswordStrengthAnalyzer.analyze(widget.password);
    setState(() {
      _strength = strength;
    });
    widget.onStrengthChanged?.call(strength);
    _animationController.forward(from: 0);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.password.isEmpty || _strength == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Strength bar
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress bar
                Stack(
                  children: [
                    // Background
                    Container(
                      height: widget.height,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceVariant,
                        borderRadius: widget.borderRadius ??
                            BorderRadius.circular(widget.height / 2),
                      ),
                    ),
                    // Filled portion
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: widget.height,
                      width: MediaQuery.of(context).size.width *
                          _strength!.score *
                          _animation.value,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _strength!.color.withOpacity(0.8),
                            _strength!.color,
                          ],
                        ),
                        borderRadius: widget.borderRadius ??
                            BorderRadius.circular(widget.height / 2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Strength label with icon
                Row(
                  children: [
                    Icon(
                      _strength!.icon,
                      size: 16,
                      color: _strength!.color,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _strength!.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _strength!.color,
                      ),
                    ),
                    if (widget.showCrackTime && _strength!.estimatedCrackTime != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        '• Time to crack: ${_strength!.estimatedCrackTime}',
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            );
          },
        ),

        // Details section
        if (widget.showDetails) ...[
          const SizedBox(height: 12),
          _buildDetailsSection(theme),
        ],

        // Suggestions section
        if (widget.showSuggestions && _strength!.suggestions.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildSuggestionsSection(theme),
        ],
      ],
    );
  }

  Widget _buildDetailsSection(ThemeData theme) {
    if (_strength == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _strength!.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _strength!.color.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Password requirements checklist
          _buildRequirementCheck('At least 8 characters', widget.password.length >= 8),
          const SizedBox(height: 4),
          _buildRequirementCheck(
            'Contains lowercase letters',
            widget.password.contains(RegExp(r'[a-z]')),
          ),
          const SizedBox(height: 4),
          _buildRequirementCheck(
            'Contains uppercase letters',
            widget.password.contains(RegExp(r'[A-Z]')),
          ),
          const SizedBox(height: 4),
          _buildRequirementCheck(
            'Contains numbers',
            widget.password.contains(RegExp(r'[0-9]')),
          ),
          const SizedBox(height: 4),
          _buildRequirementCheck(
            'Contains special characters',
            widget.password.contains(RegExp(r'[^a-zA-Z0-9]')),
          ),

          if (_strength!.entropy != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.security,
                  size: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  'Entropy: ${_strength!.entropy!.toStringAsFixed(1)} bits',
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRequirementCheck(String requirement, bool met) {
    return Row(
      children: [
        Icon(
          met ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 14,
          color: met ? Colors.green : Colors.grey,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            requirement,
            style: TextStyle(
              fontSize: 12,
              color: met ? Colors.green[700] : Colors.grey[600],
              decoration: met ? TextDecoration.none : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestionsSection(ThemeData theme) {
    if (_strength == null || _strength!.suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.blue.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 16,
                color: Colors.blue[700],
              ),
              const SizedBox(width: 6),
              Text(
                'Suggestions',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._strength!.suggestions.map((suggestion) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '•',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue[600],
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    suggestion,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[600],
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

/// Simplified password strength indicator
class PasswordStrengthIndicator extends StatelessWidget {
  final String password;
  final double height;
  final bool showLabel;

  const PasswordStrengthIndicator({
    Key? key,
    required this.password,
    this.height = 4.0,
    this.showLabel = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) {
      return const SizedBox.shrink();
    }

    final strength = PasswordStrengthAnalyzer.analyze(password);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Segmented bar
        Row(
          children: List.generate(5, (index) {
            final isActive = index < (strength.score * 5).ceil();
            return Expanded(
              child: Container(
                height: height,
                margin: EdgeInsets.only(right: index < 4 ? 2 : 0),
                decoration: BoxDecoration(
                  color: isActive
                      ? strength.color
                      : theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(height / 2),
                ),
              ),
            );
          }),
        ),

        if (showLabel) ...[
          const SizedBox(height: 4),
          Text(
            strength.label,
            style: TextStyle(
              fontSize: 11,
              color: strength.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}