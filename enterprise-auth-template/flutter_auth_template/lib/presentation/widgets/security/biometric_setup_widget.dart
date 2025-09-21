import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_auth_template/infrastructure/services/auth/biometric_service.dart';
import 'package:flutter_auth_template/core/storage/secure_storage_service.dart';

/// Widget for setting up biometric authentication
class BiometricSetupWidget extends HookConsumerWidget {
  final VoidCallback? onSetupComplete;
  final VoidCallback? onSkip;

  const BiometricSetupWidget({
    super.key,
    this.onSetupComplete,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final biometricService = ref.watch(biometricServiceProvider);
    final secureStorage = ref.watch(secureStorageServiceProvider);

    final isLoading = useState(false);
    final isEnabled = useState(false);
    final availableBiometrics = useState<List<BiometricType>>([]);
    final errorMessage = useState<String?>(null);
    final setupStep = useState(0); // 0: intro, 1: setup, 2: test, 3: complete

    // Check current biometric status
    useEffect(() {
      Future<void> checkStatus() async {
        isLoading.value = true;
        try {
          // Check if biometrics are already enabled
          isEnabled.value = await secureStorage.isBiometricEnabled();

          // Check available biometrics
          final response = await biometricService.checkBiometricAvailability();
          response.when(
            success: (availability, _) {
              if (availability.isAvailable) {
                availableBiometrics.value = availability.availableBiometrics ?? [];
              } else {
                errorMessage.value = availability.reason;
              }
            },
            error: (message, _, __, ___) {
              errorMessage.value = message;
            },
            loading: () {},
          );
        } catch (e) {
          errorMessage.value = 'Failed to check biometric status';
        } finally {
          isLoading.value = false;
        }
      }

      checkStatus();
      return null;
    }, []);

    Future<void> enableBiometric() async {
      isLoading.value = true;
      errorMessage.value = null;

      try {
        // Authenticate first
        final authResponse = await biometricService.authenticateWithBiometrics(
          reason: 'Please authenticate to enable biometric login',
        );

        authResponse.when(
          success: (authenticated, _) async {
            if (authenticated) {
              // Store biometric preference
              await secureStorage.setBiometricEnabled(true);
              isEnabled.value = true;
              setupStep.value = 2; // Move to test step
            } else {
              errorMessage.value = 'Authentication failed';
            }
          },
          error: (message, _, __, ___) {
            errorMessage.value = message;
          },
          loading: () {},
        );
      } catch (e) {
        errorMessage.value = 'Failed to enable biometric authentication';
      } finally {
        isLoading.value = false;
      }
    }

    Future<void> testBiometric() async {
      isLoading.value = true;
      errorMessage.value = null;

      try {
        final authResponse = await biometricService.authenticateWithBiometrics(
          reason: 'Test your biometric authentication',
        );

        authResponse.when(
          success: (authenticated, _) {
            if (authenticated) {
              setupStep.value = 3; // Move to complete step
            } else {
              errorMessage.value = 'Test failed. Please try again.';
            }
          },
          error: (message, _, __, ___) {
            errorMessage.value = 'Test failed: $message';
          },
          loading: () {},
        );
      } catch (e) {
        errorMessage.value = 'Test failed';
      } finally {
        isLoading.value = false;
      }
    }

    Future<void> disableBiometric() async {
      isLoading.value = true;
      try {
        await secureStorage.setBiometricEnabled(false);
        isEnabled.value = false;
        setupStep.value = 0;
      } finally {
        isLoading.value = false;
      }
    }

    Widget buildBiometricIcon(BiometricType type) {
      switch (type) {
        case BiometricType.face:
          return const Icon(Icons.face, size: 32);
        case BiometricType.fingerprint:
          return const Icon(Icons.fingerprint, size: 32);
        case BiometricType.iris:
          return const Icon(Icons.remove_red_eye, size: 32);
        case BiometricType.strong:
        case BiometricType.weak:
          return const Icon(Icons.security, size: 32);
      }
    }

    String getBiometricName(BiometricType type) {
      switch (type) {
        case BiometricType.face:
          return 'Face ID';
        case BiometricType.fingerprint:
          return 'Fingerprint';
        case BiometricType.iris:
          return 'Iris Scan';
        case BiometricType.strong:
          return 'Biometric';
        case BiometricType.weak:
          return 'PIN/Pattern';
      }
    }

    Widget buildStepContent() {
      switch (setupStep.value) {
        case 0: // Introduction
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.fingerprint,
                  size: 64,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Set Up Biometric Login',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Use your fingerprint or face to quickly and securely access your account',
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              if (availableBiometrics.value.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  'Available methods:',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha((179).round()),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  children: availableBiometrics.value.map((type) {
                    return Chip(
                      avatar: buildBiometricIcon(type),
                      label: Text(getBiometricName(type)),
                      backgroundColor: theme.colorScheme.secondaryContainer,
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 32),
              Row(
                children: [
                  if (onSkip != null)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onSkip,
                        child: const Text('Skip'),
                      ),
                    ),
                  if (onSkip != null) const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isLoading.value
                          ? null
                          : () => setupStep.value = 1,
                      child: const Text('Continue'),
                    ),
                  ),
                ],
              ),
            ],
          );

        case 1: // Setup
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 600),
                tween: Tween(begin: 0, end: 1),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.settings_suggest,
                        size: 64,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Text(
                'Enable Biometric Authentication',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'You\'ll be prompted to authenticate using your biometric',
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              if (errorMessage.value != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
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
              ],
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isLoading.value
                          ? null
                          : () => setupStep.value = 0,
                      child: const Text('Back'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isLoading.value ? null : enableBiometric,
                      child: isLoading.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Enable'),
                    ),
                  ),
                ],
              ),
            ],
          );

        case 2: // Test
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.withAlpha((51).round()),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 64,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Biometric Enabled!',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Let\'s test your biometric authentication',
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              if (errorMessage.value != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    errorMessage.value!,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
              ],
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: isLoading.value ? null : testBiometric,
                icon: const Icon(Icons.fingerprint),
                label: const Text('Test Biometric'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          );

        case 3: // Complete
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 800),
                tween: Tween(begin: 0, end: 1),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.green.withAlpha((51).round()),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.done_all,
                        size: 64,
                        color: Colors.green,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Text(
                'All Set!',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'You can now use biometric authentication to log in',
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: onSetupComplete ?? () => Navigator.pop(context),
                child: const Text('Done'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          );

        default:
          return const SizedBox.shrink();
      }
    }

    return Container(
      padding: const EdgeInsets.all(24),
      child: buildStepContent(),
    );
  }
}

/// Quick biometric toggle for settings
class BiometricToggle extends HookConsumerWidget {
  const BiometricToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final biometricService = ref.watch(biometricServiceProvider);
    final secureStorage = ref.watch(secureStorageServiceProvider);

    final isEnabled = useState(false);
    final isLoading = useState(false);
    final isAvailable = useState(false);

    useEffect(() {
      Future<void> checkStatus() async {
        isEnabled.value = await secureStorage.isBiometricEnabled();

        final response = await biometricService.checkBiometricAvailability();
        response.when(
          success: (availability, _) {
            isAvailable.value = availability.isAvailable;
          },
          error: (_, __, ___, ____) {
            isAvailable.value = false;
          },
          loading: () {},
        );
      }

      checkStatus();
      return null;
    }, []);

    Future<void> toggleBiometric(bool value) async {
      isLoading.value = true;

      try {
        if (value) {
          // Authenticate before enabling
          final authResponse = await biometricService.authenticateWithBiometrics(
            reason: 'Authenticate to enable biometric login',
          );

          authResponse.when(
            success: (authenticated, _) async {
              if (authenticated) {
                await secureStorage.setBiometricEnabled(true);
                isEnabled.value = true;
              }
            },
            error: (_, __, ___, ____) {},
            loading: () {},
          );
        } else {
          // Disable without authentication
          await secureStorage.setBiometricEnabled(false);
          isEnabled.value = false;
        }
      } finally {
        isLoading.value = false;
      }
    }

    return ListTile(
      leading: Icon(
        Icons.fingerprint,
        color: isEnabled.value ? theme.colorScheme.primary : null,
      ),
      title: const Text('Biometric Authentication'),
      subtitle: Text(
        isAvailable.value
            ? isEnabled.value
                ? 'Use biometric to log in'
                : 'Enable quick login with biometric'
            : 'Not available on this device',
      ),
      trailing: isAvailable.value
          ? Switch(
              value: isEnabled.value,
              onChanged: isLoading.value ? null : toggleBiometric,
            )
          : null,
    );
  }
}