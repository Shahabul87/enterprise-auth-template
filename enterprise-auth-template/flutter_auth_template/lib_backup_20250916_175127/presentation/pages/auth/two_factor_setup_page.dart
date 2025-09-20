import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../providers/auth_provider.dart';
import '../../../core/security/two_factor_service.dart';
import '../../../core/errors/app_exception.dart';
import '../../../data/models/auth_response.dart';

class TwoFactorSetupPage extends HookConsumerWidget {
  const TwoFactorSetupPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authNotifier = ref.read(authStateProvider.notifier);
    final twoFactorService = ref.read(twoFactorServiceProvider);

    // State
    final currentStep = useState(TwoFactorSetupStep.instructions);
    final isLoading = useState(false);
    final errorMessage = useState<String?>(null);
    final setupResponse = useState<TwoFactorSetupResponse?>(null);
    final backupCodes = useState<List<String>>([]);
    final verificationCodeController = useTextEditingController();

    // Setup 2FA
    Future<void> setupTwoFactor() async {
      try {
        isLoading.value = true;
        errorMessage.value = null;

        final response = await authNotifier.setupTwoFactor();
        setupResponse.value = response;
        currentStep.value = TwoFactorSetupStep.scanQrCode;
      } catch (e) {
        errorMessage.value = e is AppException
            ? e.message
            : 'Failed to setup 2FA';
      } finally {
        isLoading.value = false;
      }
    }

    // Enable 2FA with verification code
    Future<void> enableTwoFactor() async {
      if (verificationCodeController.text.trim().length != 6) {
        errorMessage.value = 'Please enter a valid 6-digit code';
        return;
      }

      try {
        isLoading.value = true;
        errorMessage.value = null;

        final codes = await authNotifier.enableTwoFactor(
          verificationCodeController.text.trim(),
        );

        backupCodes.value = codes;
        currentStep.value = TwoFactorSetupStep.backupCodes;
      } catch (e) {
        errorMessage.value = e is AppException
            ? e.message
            : 'Invalid verification code';
      } finally {
        isLoading.value = false;
      }
    }

    // Copy backup codes to clipboard
    Future<void> copyBackupCodes() async {
      final codesText = backupCodes.value
          .map((code) => twoFactorService.formatBackupCode(code))
          .join('\n');

      await Clipboard.setData(ClipboardData(text: codesText));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Backup codes copied to clipboard'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }

    // Complete setup
    void completeSetup() {
      context.go('/dashboard');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Two-Factor Authentication'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Progress Indicator
            LinearProgressIndicator(
              value: _getProgress(currentStep.value),
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
            ),

            const SizedBox(height: 32),

            // Error Message
            if (errorMessage.value != null)
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.colorScheme.error),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: theme.colorScheme.error,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        errorMessage.value!,
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ),
                  ],
                ),
              ),

            // Step Content
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildStepContent(
                context,
                theme,
                currentStep.value,
                setupResponse.value,
                backupCodes.value,
                verificationCodeController,
                twoFactorService,
                isLoading.value,
                setupTwoFactor,
                enableTwoFactor,
                copyBackupCodes,
                completeSetup,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent(
    BuildContext context,
    ThemeData theme,
    TwoFactorSetupStep step,
    TwoFactorSetupResponse? setupResponse,
    List<String> backupCodes,
    TextEditingController verificationController,
    TwoFactorService twoFactorService,
    bool isLoading,
    VoidCallback onSetup,
    VoidCallback onEnable,
    VoidCallback onCopyBackupCodes,
    VoidCallback onComplete,
  ) {
    switch (step) {
      case TwoFactorSetupStep.instructions:
        return _buildInstructionsStep(
          context,
          theme,
          twoFactorService,
          isLoading,
          onSetup,
        );
      case TwoFactorSetupStep.scanQrCode:
        return _buildScanQrCodeStep(
          context,
          theme,
          setupResponse,
          verificationController,
          isLoading,
          onEnable,
        );
      case TwoFactorSetupStep.backupCodes:
        return _buildBackupCodesStep(
          context,
          theme,
          backupCodes,
          twoFactorService,
          onCopyBackupCodes,
          onComplete,
        );
    }
  }

  Widget _buildInstructionsStep(
    BuildContext context,
    ThemeData theme,
    TwoFactorService twoFactorService,
    bool isLoading,
    VoidCallback onSetup,
  ) {
    final authenticatorApps = twoFactorService.getSupportedAuthenticatorApps();

    return Column(
      key: const ValueKey('instructions'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Icon(Icons.security, size: 64, color: theme.colorScheme.primary),
        const SizedBox(height: 16),
        Text(
          'Enable Two-Factor Authentication',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Add an extra layer of security to your account',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 32),

        // Instructions
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How it works:',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  twoFactorService.getSetupInstructions('Enterprise Auth'),
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Supported Apps
        Text(
          'Recommended Authenticator Apps',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...authenticatorApps.map(
          (app) => Card(
            child: ListTile(
              leading: const Icon(Icons.smartphone),
              title: Text(app.name),
              subtitle: Text(app.description),
              trailing: TextButton(
                onPressed: () {
                  // TODO: Launch app store links
                },
                child: const Text('Get App'),
              ),
            ),
          ),
        ),

        const SizedBox(height: 32),

        // Continue Button
        ElevatedButton(
          onPressed: isLoading ? null : onSetup,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Continue Setup'),
        ),
      ],
    );
  }

  Widget _buildScanQrCodeStep(
    BuildContext context,
    ThemeData theme,
    TwoFactorSetupResponse? setupResponse,
    TextEditingController verificationController,
    bool isLoading,
    VoidCallback onEnable,
  ) {
    if (setupResponse == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      key: const ValueKey('scan_qr'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Text(
          'Scan QR Code',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Open your authenticator app and scan this QR code',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 32),

        // QR Code
        Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: QrImageView(
              data: setupResponse.qrCode,
              version: QrVersions.auto,
              size: 200,
              backgroundColor: Colors.white,
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Manual Entry Option
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Can\'t scan? Enter this code manually:',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          setupResponse.secret,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(text: setupResponse.secret),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Secret copied to clipboard'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 32),

        // Verification Code Input
        TextFormField(
          controller: verificationController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Verification Code',
            hintText: 'Enter 6-digit code from your app',
            prefixIcon: Icon(Icons.security),
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
        ),

        const SizedBox(height: 24),

        // Enable Button
        ElevatedButton(
          onPressed: isLoading ? null : onEnable,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Enable 2FA'),
        ),
      ],
    );
  }

  Widget _buildBackupCodesStep(
    BuildContext context,
    ThemeData theme,
    List<String> backupCodes,
    TwoFactorService twoFactorService,
    VoidCallback onCopyBackupCodes,
    VoidCallback onComplete,
  ) {
    return Column(
      key: const ValueKey('backup_codes'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Icon(Icons.check_circle, size: 64, color: Colors.green),
        const SizedBox(height: 16),
        Text(
          '2FA Enabled Successfully!',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Save these backup codes in a secure location',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 32),

        // Warning Card
        Card(
          color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.warning, color: theme.colorScheme.error),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Store these codes securely! You\'ll need them if you lose access to your authenticator app.',
                    style: TextStyle(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Backup Codes
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Text(
                      'Backup Codes',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: onCopyBackupCodes,
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('Copy All'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: backupCodes
                      .map(
                        (code) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            twoFactorService.formatBackupCode(code),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 32),

        // Complete Button
        ElevatedButton(
          onPressed: onComplete,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.green,
          ),
          child: const Text('Complete Setup'),
        ),
      ],
    );
  }

  double _getProgress(TwoFactorSetupStep step) {
    switch (step) {
      case TwoFactorSetupStep.instructions:
        return 0.33;
      case TwoFactorSetupStep.scanQrCode:
        return 0.66;
      case TwoFactorSetupStep.backupCodes:
        return 1.0;
    }
  }
}

enum TwoFactorSetupStep { instructions, scanQrCode, backupCodes }
