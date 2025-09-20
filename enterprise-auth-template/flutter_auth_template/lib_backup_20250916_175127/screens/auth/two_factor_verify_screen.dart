import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/loading_overlay.dart';

class TwoFactorVerifyScreen extends ConsumerStatefulWidget {
  final String? email;
  final String? token;

  const TwoFactorVerifyScreen({
    super.key,
    this.email,
    this.token,
  });

  @override
  ConsumerState<TwoFactorVerifyScreen> createState() => _TwoFactorVerifyScreenState();
}

class _TwoFactorVerifyScreenState extends ConsumerState<TwoFactorVerifyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  bool _isLoading = false;
  bool _useBackupCode = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _handleVerify() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(authStateProvider.notifier).verify2FA(
            _codeController.text.trim(),
            token: widget.token,
            isBackup: _useBackupCode,
          );

      if (mounted) {
        context.go('/dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        
        // Clear the code field on error
        _codeController.clear();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isAuthLoading = ref.watch(isLoadingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Two-Factor Authentication'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/auth/login'),
        ),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading || isAuthLoading,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 48),
                  
                  // Icon
                  Icon(
                    Icons.security,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  
                  Text(
                    'Verification Required',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  
                  Text(
                    _useBackupCode 
                        ? 'Enter one of your backup codes'
                        : 'Enter the 6-digit code from your authenticator app',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  if (widget.email != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'for ${widget.email}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  
                  const SizedBox(height: 48),

                  // Code Input
                  CustomTextField(
                    controller: _codeController,
                    label: _useBackupCode ? 'Backup Code' : 'Verification Code',
                    hintText: _useBackupCode ? 'Enter backup code' : 'Enter 6-digit code',
                    keyboardType: _useBackupCode 
                        ? TextInputType.text 
                        : TextInputType.number,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _handleVerify(),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '${_useBackupCode ? 'Backup code' : 'Verification code'} is required';
                      }
                      
                      if (!_useBackupCode) {
                        if (value.trim().length != 6) {
                          return 'Verification code must be 6 digits';
                        }
                        if (!RegExp(r'^[0-9]+$').hasMatch(value.trim())) {
                          return 'Verification code must contain only numbers';
                        }
                      } else {
                        if (value.trim().length < 8) {
                          return 'Backup code is too short';
                        }
                      }
                      
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // Verify Button
                  CustomButton(
                    text: 'Verify & Continue',
                    onPressed: _handleVerify,
                    isLoading: _isLoading || isAuthLoading,
                  ),
                  const SizedBox(height: 24),

                  // Toggle between auth code and backup code
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _useBackupCode 
                            ? 'Have your authenticator app? '
                            : 'Lost your authenticator app? ',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _useBackupCode = !_useBackupCode;
                            _codeController.clear();
                          });
                        },
                        child: Text(
                          _useBackupCode 
                              ? 'Use Authenticator Code'
                              : 'Use Backup Code',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Help text
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 20,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Need Help?',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _useBackupCode
                              ? 'Backup codes are one-time use codes that you saved when setting up 2FA. Each code can only be used once.'
                              : 'Open your authenticator app (Google Authenticator, Authy, etc.) and enter the 6-digit code shown for this account.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Back to login
                  TextButton(
                    onPressed: () => context.go('/auth/login'),
                    child: const Text('Back to Login'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}