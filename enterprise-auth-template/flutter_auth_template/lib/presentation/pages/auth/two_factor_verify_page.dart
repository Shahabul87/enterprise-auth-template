import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_auth_template/presentation/providers/auth_provider.dart';
import 'package:flutter_auth_template/core/errors/app_exception.dart';
import 'package:flutter_auth_template/domain/entities/auth_state.dart';

class TwoFactorVerifyPage extends HookConsumerWidget {
  final String? email;

  const TwoFactorVerifyPage({super.key, this.email});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authNotifier = ref.read(authStateProvider.notifier);

    // Controllers for OTP input
    final controllers = List.generate(6, (_) => useTextEditingController());
    final focusNodes = List.generate(6, (_) => useFocusNode());

    final isLoading = useState(false);
    final errorMessage = useState<String?>(null);
    final useBackupCode = useState(false);
    final backupCodeController = useTextEditingController();

    // Listen to auth state changes
    ref.listen<AuthState>(authStateProvider, (previous, next) {
      next.when(
        authenticated: (user, _, __) {
          // Navigate to dashboard on successful authentication
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context.go('/dashboard');
            }
          });
        },
        unauthenticated: () {},
        authenticating: () {
          isLoading.value = true;
        },
        error: (message) {
          isLoading.value = false;
          errorMessage.value = message;
        },
      );
    });

    Future<void> handleVerify() async {
      errorMessage.value = null;

      String code;
      if (useBackupCode.value) {
        code = backupCodeController.text.trim();
        if (code.isEmpty) {
          errorMessage.value = 'Please enter a backup code';
          return;
        }
      } else {
        code = controllers.map((c) => c.text).join();
        if (code.length != 6) {
          errorMessage.value = 'Please enter all 6 digits';
          return;
        }
      }

      isLoading.value = true;
      try {
        await authNotifier.verify2FA(code, isBackup: useBackupCode.value);
      } catch (e) {
        errorMessage.value = e is AppException
            ? e.message
            : 'Verification failed';
      } finally {
        isLoading.value = false;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Two-Factor Authentication'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Icon(Icons.security, size: 64, color: theme.colorScheme.primary),
              const SizedBox(height: 24),
              Text(
                'Enter Verification Code',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                useBackupCode.value
                    ? 'Enter one of your backup codes'
                    : 'Enter the 6-digit code from your authenticator app',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              if (email != null) ...[
                const SizedBox(height: 8),
                Text(
                  email!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 48),

              // Error Message
              if (errorMessage.value != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(12),
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
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          errorMessage.value!,
                          style: TextStyle(
                            color: theme.colorScheme.error,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Input Fields
              if (useBackupCode.value)
                // Backup Code Input
                TextFormField(
                  controller: backupCodeController,
                  decoration: const InputDecoration(
                    labelText: 'Backup Code',
                    hintText: 'Enter your backup code',
                    prefixIcon: Icon(Icons.key),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9-]')),
                  ],
                )
              else
                // OTP Input Fields
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: 45,
                      child: TextFormField(
                        controller: controllers[index],
                        focusNode: focusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        style: theme.textTheme.headlineSmall,
                        decoration: InputDecoration(
                          counterText: '',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) {
                          if (value.isNotEmpty && index < 5) {
                            focusNodes[index + 1].requestFocus();
                          } else if (value.isEmpty && index > 0) {
                            focusNodes[index - 1].requestFocus();
                          }

                          // Auto-submit when all fields are filled
                          if (index == 5 && value.isNotEmpty) {
                            final code = controllers.map((c) => c.text).join();
                            if (code.length == 6) {
                              handleVerify();
                            }
                          }
                        },
                      ),
                    );
                  }),
                ),

              const SizedBox(height: 32),

              // Verify Button
              ElevatedButton(
                onPressed: isLoading.value ? null : handleVerify,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: isLoading.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text('Verify'),
              ),

              const SizedBox(height: 24),

              // Toggle Backup Code
              TextButton.icon(
                onPressed: () {
                  useBackupCode.value = !useBackupCode.value;
                  errorMessage.value = null;
                  if (!useBackupCode.value) {
                    // Clear OTP fields when switching back
                    for (var controller in controllers) {
                      controller.clear();
                    }
                  } else {
                    backupCodeController.clear();
                  }
                },
                icon: Icon(
                  useBackupCode.value ? Icons.pin : Icons.key,
                  size: 20,
                ),
                label: Text(
                  useBackupCode.value
                      ? 'Use authenticator code instead'
                      : 'Use backup code instead',
                ),
              ),

              const SizedBox(height: 16),

              // Help Text
              Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.3,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.help_outline,
                            size: 20,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Having trouble?',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        useBackupCode.value
                            ? 'Backup codes are single-use codes that were provided when you set up 2FA. Each code can only be used once.'
                            : 'Open your authenticator app (Google Authenticator, Authy, etc.) and enter the 6-digit code shown for this account.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
