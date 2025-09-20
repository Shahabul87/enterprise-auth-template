import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../../core/security/oauth_service.dart';
import '../../../core/errors/app_exception.dart';

class EnhancedRegistrationForm extends HookConsumerWidget {
  final VoidCallback? onSuccess;
  final VoidCallback? onLogin;

  const EnhancedRegistrationForm({super.key, this.onSuccess, this.onLogin});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authStateProvider);
    final authNotifier = ref.read(authStateProvider.notifier);
    final oauthService = ref.read(oauthServiceProvider);

    // Form controllers
    final firstNameController = useTextEditingController();
    final lastNameController = useTextEditingController();
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();
    final formKey = useMemoized(() => GlobalKey<FormState>());

    // State
    final obscurePassword = useState(true);
    final obscureConfirmPassword = useState(true);
    final acceptTerms = useState(false);
    final isLoading = useState(false);
    final errorMessage = useState<String?>(null);
    final currentStep = useState(0);

    // Password strength
    final passwordStrength = useState<PasswordStrength>(PasswordStrength.weak);

    // Handle auth state changes
    useEffect(() {
      authState.when(
        authenticated: (user, _, __) {
          isLoading.value = false;
          onSuccess?.call();
        },
        error: (message) {
          isLoading.value = false;
          errorMessage.value = message;
        },
        authenticating: () {
          isLoading.value = true;
          errorMessage.value = null;
        },
        unauthenticated: () {
          isLoading.value = false;
        },
      );
      return null;
    }, [authState]);

    // Handle registration
    Future<void> handleRegistration() async {
      if (!(formKey.currentState?.validate() ?? false)) return;
      if (!acceptTerms.value) {
        errorMessage.value =
            'Please accept the Terms of Service and Privacy Policy';
        return;
      }

      errorMessage.value = null;

      try {
        final fullName =
            '${firstNameController.text.trim()} ${lastNameController.text.trim()}';

        await authNotifier.register(
          emailController.text.trim(),
          passwordController.text,
          fullName,
        );
      } catch (e) {
        errorMessage.value = e is AppException
            ? e.message
            : 'Registration failed';
      }
    }

    // Handle Google Sign-Up
    Future<void> handleGoogleSignUp() async {
      try {
        errorMessage.value = null;
        isLoading.value = true;

        final account = await oauthService.signInWithGoogle();
        if (account == null) {
          isLoading.value = false;
          return; // User canceled
        }

        final token = await oauthService.getGoogleAuthToken(account);
        if (token == null) {
          throw const UnknownException(
            'Failed to get Google authentication token',
            null,
          );
        }

        // TODO: Complete OAuth registration with backend
        // await authNotifier.registerWithOAuth('google', token);
        throw UnimplementedError('OAuth registration not yet implemented');
      } catch (e) {
        isLoading.value = false;
        errorMessage.value = e is AppException
            ? e.message
            : 'Google Sign-Up failed';
      }
    }

    // Check password strength
    void checkPasswordStrength(String password) {
      passwordStrength.value = _calculatePasswordStrength(password);
    }

    // Navigate to next step
    void nextStep() {
      if (currentStep.value < 1) {
        if (currentStep.value == 0) {
          // Validate first step
          if (firstNameController.text.trim().isEmpty ||
              lastNameController.text.trim().isEmpty ||
              emailController.text.trim().isEmpty ||
              !_isValidEmail(emailController.text.trim())) {
            errorMessage.value =
                'Please fill in all fields with valid information';
            return;
          }
        }
        currentStep.value++;
        errorMessage.value = null;
      }
    }

    // Navigate to previous step
    void previousStep() {
      if (currentStep.value > 0) {
        currentStep.value--;
        errorMessage.value = null;
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Column(
            children: [
              Icon(
                Icons.person_add,
                size: 64,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Create Account',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Join our secure authentication platform',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Step Indicator
          Row(
            children: [
              _buildStepIndicator(0, currentStep.value, 'Personal Info'),
              Expanded(
                child: Container(
                  height: 2,
                  color: currentStep.value > 0
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline,
                ),
              ),
              _buildStepIndicator(1, currentStep.value, 'Security'),
            ],
          ),

          const SizedBox(height: 32),

          // Error Message
          if (errorMessage.value != null)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
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

          // Registration Form
          Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Step 0: Personal Information
                if (currentStep.value == 0) ...[
                  Text(
                    'Personal Information',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // First Name
                  TextFormField(
                    controller: firstNameController,
                    autofillHints: const [AutofillHints.givenName],
                    decoration: const InputDecoration(
                      labelText: 'First Name',
                      hintText: 'Enter your first name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your first name';
                      }
                      if (value.trim().length < 2) {
                        return 'First name must be at least 2 characters';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Last Name
                  TextFormField(
                    controller: lastNameController,
                    autofillHints: const [AutofillHints.familyName],
                    decoration: const InputDecoration(
                      labelText: 'Last Name',
                      hintText: 'Enter your last name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your last name';
                      }
                      if (value.trim().length < 2) {
                        return 'Last name must be at least 2 characters';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Email
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      hintText: 'Enter your email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!_isValidEmail(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 32),

                  // OAuth Registration Options
                  Text(
                    'Or sign up with',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  OutlinedButton.icon(
                    onPressed: isLoading.value ? null : handleGoogleSignUp,
                    icon: const Icon(Icons.g_mobiledata, size: 24),
                    label: const Text('Continue with Google'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Next Button
                  ElevatedButton(
                    onPressed: isLoading.value ? null : nextStep,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Next'),
                  ),
                ],

                // Step 1: Security Settings
                if (currentStep.value == 1) ...[
                  Text(
                    'Security Settings',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Password
                  TextFormField(
                    controller: passwordController,
                    obscureText: obscurePassword.value,
                    autofillHints: const [AutofillHints.newPassword],
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Create a strong password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword.value
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () =>
                            obscurePassword.value = !obscurePassword.value,
                      ),
                    ),
                    onChanged: checkPasswordStrength,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.length < 8) {
                        return 'Password must be at least 8 characters';
                      }
                      if (passwordStrength.value == PasswordStrength.weak) {
                        return 'Password is too weak';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 8),

                  // Password Strength Indicator
                  _buildPasswordStrengthIndicator(
                    passwordStrength.value,
                    theme,
                  ),

                  const SizedBox(height: 16),

                  // Confirm Password
                  TextFormField(
                    controller: confirmPasswordController,
                    obscureText: obscureConfirmPassword.value,
                    autofillHints: const [AutofillHints.newPassword],
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      hintText: 'Re-enter your password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureConfirmPassword.value
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () => obscureConfirmPassword.value =
                            !obscureConfirmPassword.value,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  // Terms and Privacy
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: acceptTerms.value,
                        onChanged: (value) =>
                            acceptTerms.value = value ?? false,
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => acceptTerms.value = !acceptTerms.value,
                          child: RichText(
                            text: TextSpan(
                              style: theme.textTheme.bodyMedium,
                              children: [
                                const TextSpan(text: 'I agree to the '),
                                TextSpan(
                                  text: 'Terms of Service',
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                                const TextSpan(text: ' and '),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isLoading.value ? null : previousStep,
                          child: const Text('Back'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: isLoading.value
                              ? null
                              : handleRegistration,
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
                              : const Text('Create Account'),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 48),

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: theme.textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: onLogin ?? () => context.push('/login'),
                      child: const Text('Sign In'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int stepIndex, int currentStep, String label) {
    final isActive = stepIndex <= currentStep;
    final isCompleted = stepIndex < currentStep;

    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? Colors.blue : Colors.grey.shade300,
            border: Border.all(
              color: isActive ? Colors.blue : Colors.grey.shade300,
              width: 2,
            ),
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : Text(
                    (stepIndex + 1).toString(),
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? Colors.blue : Colors.grey.shade600,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordStrengthIndicator(
    PasswordStrength strength,
    ThemeData theme,
  ) {
    Color getStrengthColor() {
      switch (strength) {
        case PasswordStrength.weak:
          return Colors.red;
        case PasswordStrength.medium:
          return Colors.orange;
        case PasswordStrength.strong:
          return Colors.green;
      }
    }

    String getStrengthText() {
      switch (strength) {
        case PasswordStrength.weak:
          return 'Weak';
        case PasswordStrength.medium:
          return 'Medium';
        case PasswordStrength.strong:
          return 'Strong';
      }
    }

    double getStrengthValue() {
      switch (strength) {
        case PasswordStrength.weak:
          return 0.33;
        case PasswordStrength.medium:
          return 0.66;
        case PasswordStrength.strong:
          return 1.0;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: getStrengthValue(),
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(getStrengthColor()),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              getStrengthText(),
              style: TextStyle(
                color: getStrengthColor(),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
        if (strength != PasswordStrength.strong) ...[
          const SizedBox(height: 4),
          Text(
            'Use uppercase, lowercase, numbers, and special characters',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
          ),
        ],
      ],
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  PasswordStrength _calculatePasswordStrength(String password) {
    if (password.length < 8) return PasswordStrength.weak;

    int score = 0;

    // Check for lowercase
    if (RegExp(r'[a-z]').hasMatch(password)) score++;

    // Check for uppercase
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;

    // Check for numbers
    if (RegExp(r'[0-9]').hasMatch(password)) score++;

    // Check for special characters
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score++;

    // Check length
    if (password.length >= 12) score++;

    if (score >= 4) return PasswordStrength.strong;
    if (score >= 2) return PasswordStrength.medium;
    return PasswordStrength.weak;
  }
}

enum PasswordStrength { weak, medium, strong }
