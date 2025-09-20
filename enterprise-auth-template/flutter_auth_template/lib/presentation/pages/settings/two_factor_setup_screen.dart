import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_auth_template/presentation/providers/two_factor_provider.dart';
import 'package:flutter_auth_template/presentation/widgets/loading_indicators.dart';
import 'package:flutter_auth_template/presentation/widgets/buttons/custom_buttons.dart';
import 'package:flutter_auth_template/presentation/widgets/forms/custom_form_field.dart';
import 'package:flutter_auth_template/core/theme/app_colors.dart';
import 'package:flutter_auth_template/core/theme/app_text_styles.dart';

class TwoFactorSetupScreen extends ConsumerStatefulWidget {
  const TwoFactorSetupScreen({super.key});

  @override
  ConsumerState<TwoFactorSetupScreen> createState() =>
      _TwoFactorSetupScreenState();
}

class _TwoFactorSetupScreenState extends ConsumerState<TwoFactorSetupScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  int _currentStep = 0;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    // Initialize setup when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(twoFactorProvider.notifier).beginSetup();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeSetup() async {
    final code = _codeController.text.trim();
    final password = _passwordController.text.trim();

    if (code.isEmpty) {
      _showError('Please enter the verification code');
      return;
    }

    final success = await ref
        .read(twoFactorProvider.notifier)
        .completeSetup(code, password: password.isEmpty ? null : password);

    if (success) {
      _nextStep(); // Go to backup codes step
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _finishSetup() {
    Navigator.of(context).pop(true); // Return success
  }

  @override
  Widget build(BuildContext context) {
    final twoFactorState = ref.watch(twoFactorProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Two-Factor Authentication'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _previousStep,
              )
            : null,
      ),
      body: LoadingOverlay(
        isLoading: twoFactorState.isLoading,
        child: Column(
          children: [
            // Progress indicator
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: List.generate(3, (index) {
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
                      height: 4,
                      decoration: BoxDecoration(
                        color: index <= _currentStep
                            ? AppColors.primary
                            : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildInstructionsStep(),
                  _buildQRCodeStep(),
                  _buildVerificationStep(),
                  _buildBackupCodesStep(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionsStep() {
    final supportedApps = ref
        .read(twoFactorProvider.notifier)
        .getSupportedApps();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.security, size: 64, color: AppColors.primary),
          const SizedBox(height: 24),

          Text('Secure Your Account', style: AppTextStyles.headlineMedium),
          const SizedBox(height: 16),

          Text(
            'Two-factor authentication adds an extra layer of security to your account. You\'ll need an authenticator app to generate verification codes.',
            style: AppTextStyles.bodyLarge,
          ),
          const SizedBox(height: 24),

          Text(
            'Recommended Authenticator Apps:',
            style: AppTextStyles.titleMedium,
          ),
          const SizedBox(height: 16),

          Expanded(
            child: ListView.builder(
              itemCount: supportedApps.length,
              itemBuilder: (context, index) {
                final app = supportedApps[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.phone_android),
                    title: Text(app.name),
                    subtitle: Text(app.description),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: () {
                      // TODO: Open app store link
                    },
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),
          CustomButton(
            text: 'I have an authenticator app',
            onPressed: _nextStep,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildQRCodeStep() {
    final setupResponse = ref.watch(
      twoFactorProvider.select((state) => state.setupResponse),
    );

    if (setupResponse == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Scan QR Code', style: AppTextStyles.headlineMedium),
          const SizedBox(height: 16),

          Text(
            'Open your authenticator app and scan this QR code:',
            style: AppTextStyles.bodyLarge,
          ),
          const SizedBox(height: 24),

          // QR Code
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: QrImageView(
                data: setupResponse.qrCode,
                size: 200,
                backgroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'Can\'t scan the code? Enter this key manually:',
            style: AppTextStyles.titleSmall,
          ),
          const SizedBox(height: 8),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    setupResponse.secret,
                    style: AppTextStyles.labelMedium.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () => _copyToClipboard(setupResponse.secret),
                  tooltip: 'Copy to clipboard',
                ),
              ],
            ),
          ),

          const Spacer(),

          CustomButton(
            text: 'I\'ve added the account',
            onPressed: _nextStep,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationStep() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Verify Setup', style: AppTextStyles.headlineMedium),
          const SizedBox(height: 16),

          Text(
            'Enter the 6-digit code from your authenticator app to complete setup:',
            style: AppTextStyles.bodyLarge,
          ),
          const SizedBox(height: 24),

          CustomFormField(
            controller: _codeController,
            label: 'Verification Code',
            hint: '123456',
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            maxLength: 6,
          ),
          const SizedBox(height: 16),

          CustomFormField(
            controller: _passwordController,
            label: 'Current Password (Optional)',
            hint: 'Enter your current password',
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'The code changes every 30 seconds. Make sure to enter the current code.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          CustomButton(
            text: 'Verify and Enable',
            onPressed: _completeSetup,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildBackupCodesStep() {
    final backupCodes = ref.watch(backupCodesProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.success, size: 32),
              const SizedBox(width: 12),
              Text(
                'Setup Complete!',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Text('Save Your Backup Codes', style: AppTextStyles.titleLarge),
          const SizedBox(height: 8),

          Text(
            'Store these backup codes in a safe place. You can use them to access your account if you lose your authenticator app.',
            style: AppTextStyles.bodyLarge,
          ),
          const SizedBox(height: 24),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outline),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Backup Codes', style: AppTextStyles.titleMedium),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () => _copyToClipboard(backupCodes.join('\n')),
                      tooltip: 'Copy all codes',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...backupCodes.map(
                  (code) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      ref
                          .read(twoFactorProvider.notifier)
                          .formatBackupCode(code),
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.warning.withOpacity(0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning_amber, color: AppColors.warning, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Important: Each backup code can only be used once. Store them securely and don\'t share them with anyone.',
                    style: AppTextStyles.bodySmall,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          CustomButton(
            text: 'I\'ve saved my backup codes',
            onPressed: _finishSetup,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }
}
