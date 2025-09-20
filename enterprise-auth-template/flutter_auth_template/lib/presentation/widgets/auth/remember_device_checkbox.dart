import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_auth_template/core/security/remember_device_service.dart';
import 'package:flutter_auth_template/presentation/providers/auth_provider.dart';

/// A checkbox widget for "Remember this device" functionality
class RememberDeviceCheckbox extends ConsumerStatefulWidget {
  final ValueChanged<bool>? onChanged;
  final bool initialValue;
  final bool showAdvancedOptions;
  
  const RememberDeviceCheckbox({
    Key? key,
    this.onChanged,
    this.initialValue = false,
    this.showAdvancedOptions = false,
  }) : super(key: key);

  @override
  ConsumerState<RememberDeviceCheckbox> createState() => _RememberDeviceCheckboxState();
}

class _RememberDeviceCheckboxState extends ConsumerState<RememberDeviceCheckbox> {
  late bool _isChecked;
  bool _showOptions = false;
  int _durationDays = RememberDeviceService.defaultRememberDurationDays;
  bool _skipBiometric = false;
  bool _skipMFA = false;

  @override
  void initState() {
    super.initState();
    _isChecked = widget.initialValue;
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser != null) {
      final rememberService = ref.read(rememberDeviceServiceProvider);
      final prefs = await rememberService.getRememberPreferences(currentUser.id);
      
      if (mounted) {
        setState(() {
          _durationDays = prefs.durationDays;
          _skipBiometric = prefs.skipBiometric;
          _skipMFA = prefs.skipMFA;
          if (prefs.isEnabled) {
            _isChecked = true;
          }
        });
      }
    }
  }

  void _handleCheckboxChange(bool? value) {
    setState(() {
      _isChecked = value ?? false;
      if (_isChecked && widget.showAdvancedOptions) {
        _showOptions = true;
      }
    });
    widget.onChanged?.call(_isChecked);
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remember This Device'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'When enabled, this device will be remembered for the specified duration. '
                'You won\'t need to enter your credentials each time you open the app.',
              ),
              SizedBox(height: 16),
              Text(
                'Security Features:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Device fingerprinting for verification'),
              Text('• Automatic logout after expiry'),
              Text('• Optional biometric/MFA skip'),
              Text('• Revocable from security settings'),
              SizedBox(height: 16),
              Text(
                'Note: Only use this feature on personal devices you trust.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Checkbox(
              value: _isChecked,
              onChanged: _handleCheckboxChange,
              activeColor: theme.colorScheme.primary,
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => _handleCheckboxChange(!_isChecked),
                child: Text(
                  'Remember this device',
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.info_outline,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              onPressed: _showInfoDialog,
              tooltip: 'Learn more',
            ),
          ],
        ),
        
        if (_isChecked && widget.showAdvancedOptions) ...[          
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: _showOptions ? null : 0,
            child: _showOptions
                ? Padding(
                    padding: const EdgeInsets.only(left: 48, right: 16, bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Duration selector
                        Row(
                          children: [
                            Text(
                              'Remember for:',
                              style: theme.textTheme.bodyMedium,
                            ),
                            const SizedBox(width: 12),
                            DropdownButton<int>(
                              value: _durationDays,
                              isDense: true,
                              items: [
                                const DropdownMenuItem(
                                  value: 7,
                                  child: Text('1 week'),
                                ),
                                const DropdownMenuItem(
                                  value: 30,
                                  child: Text('30 days'),
                                ),
                                const DropdownMenuItem(
                                  value: 60,
                                  child: Text('60 days'),
                                ),
                                const DropdownMenuItem(
                                  value: 90,
                                  child: Text('90 days'),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _durationDays = value ?? RememberDeviceService.defaultRememberDurationDays;
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        
                        // Skip biometric option
                        CheckboxListTile(
                          value: _skipBiometric,
                          onChanged: (value) {
                            setState(() {
                              _skipBiometric = value ?? false;
                            });
                          },
                          title: const Text('Skip biometric authentication'),
                          subtitle: const Text(
                            'Don\'t require fingerprint/face on this device',
                            style: TextStyle(fontSize: 12),
                          ),
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                        
                        // Skip MFA option
                        CheckboxListTile(
                          value: _skipMFA,
                          onChanged: (value) {
                            setState(() {
                              _skipMFA = value ?? false;
                            });
                          },
                          title: const Text('Skip 2FA verification'),
                          subtitle: const Text(
                            'Don\'t require 2FA code on this device',
                            style: TextStyle(fontSize: 12),
                          ),
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                        
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.warningContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.warning_amber,
                                size: 16,
                                color: theme.colorScheme.onWarningContainer,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Only enable on your personal devices',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: theme.colorScheme.onWarningContainer,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ],
    );
  }

  RememberPreferences getPreferences() {
    return RememberPreferences(
      isEnabled: _isChecked,
      durationDays: _durationDays,
      skipBiometric: _skipBiometric,
      skipMFA: _skipMFA,
    );
  }
}

// Extension for color scheme
extension on ColorScheme {
  Color get warningContainer => Colors.orange.shade100;
  Color get onWarningContainer => Colors.orange.shade900;
}