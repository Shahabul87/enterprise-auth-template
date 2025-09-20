import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../../core/security/biometric_service.dart';
import '../../../core/security/oauth_service.dart';
import '../../../core/errors/app_exception.dart';

class EnhancedLoginForm extends HookConsumerWidget {
  final VoidCallback? onSuccess;
  final VoidCallback? onForgotPassword;
  final VoidCallback? onRegister;

  const EnhancedLoginForm({
    super.key,
    this.onSuccess,
    this.onForgotPassword,
    this.onRegister,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authStateProvider);
    final authNotifier = ref.read(authStateProvider.notifier);
    final biometricService = ref.read(biometricServiceProvider);
    final oauthService = ref.read(oauthServiceProvider);

    // Form controllers
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final formKey = useMemoized(() => GlobalKey<FormState>());

    // State
    final obscurePassword = useState(true);
    final rememberMe = useState(false);
    final isLoading = useState(false);
    final errorMessage = useState<String?>(null);
    final biometricCapability = useState<BiometricCapability?>(null);

    // Initialize biometric capability
    useEffect(() {
      biometricService.getBiometricCapability().then((capability) {
        biometricCapability.value = capability;
      });
      return null;
    }, []);

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

    // Handle email/password login
    Future<void> handleEmailLogin() async {
      if (!(formKey.currentState?.validate() ?? false)) return;

      errorMessage.value = null;

      try {
        await authNotifier.login(
          emailController.text.trim(),
          passwordController.text,
        );
      } on TwoFactorRequiredException {
        // Navigate to 2FA verification screen
        if (context.mounted) {
          context.push('/auth/2fa-verify');
        }
      } catch (e) {
        errorMessage.value = e is AppException ? e.message : 'Login failed';
      }
    }

    // Handle biometric login
    Future<void> handleBiometricLogin() async {
      try {
        errorMessage.value = null;

        final authenticated = await biometricService.authenticateForLogin();

        if (authenticated) {
          // For biometric login, we need an email to identify the user
          // In a real app, you might store the last logged-in email
          final email = emailController.text.trim();
          if (email.isEmpty) {
            errorMessage.value = 'Please enter your email for biometric login';
            return;
          }

          // TODO: Implement biometric login with backend
          // This would typically involve using WebAuthn or a stored token
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Biometric login not fully implemented yet'),
            ),
          );
        }
      } catch (e) {
        String message = 'Biometric authentication failed';
        if (e is BiometricException) {
          message = e.message;
        }
        errorMessage.value = message;
      }
    }

    // Handle Google Sign-In
    Future<void> handleGoogleSignIn() async {
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

        // Complete OAuth login with backend
        await authNotifier.completeOAuthLogin('google', token);
      } catch (e) {
        isLoading.value = false;
        errorMessage.value = e is AppException
            ? e.message
            : 'Google Sign-In failed';
      }
    }

    // Handle Magic Link request
    Future<void> handleMagicLinkRequest() async {
      if (emailController.text.trim().isEmpty) {
        errorMessage.value = 'Please enter your email address';
        return;
      }

      try {
        errorMessage.value = null;
        isLoading.value = true;

        await authNotifier.requestMagicLink(emailController.text.trim());

        isLoading.value = false;
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Magic link sent to your email'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        isLoading.value = false;
        errorMessage.value = e is AppException
            ? e.message
            : 'Failed to send magic link';
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
              Icon(Icons.security, size: 64, color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                'Welcome Back',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to your account',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
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

          // Login Form
          Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Email Field
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Password Field
                TextFormField(
                  controller: passwordController,
                  obscureText: obscurePassword.value,
                  autofillHints: const [AutofillHints.password],
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Remember Me & Forgot Password
                Row(
                  children: [
                    Checkbox(
                      value: rememberMe.value,
                      onChanged: (value) => rememberMe.value = value ?? false,
                    ),
                    Text('Remember me', style: theme.textTheme.bodyMedium),
                    const Spacer(),
                    TextButton(
                      onPressed:
                          onForgotPassword ??
                          () {
                            context.push('/auth/forgot-password');
                          },
                      child: const Text('Forgot Password?'),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Login Button
                ElevatedButton(
                  onPressed: isLoading.value ? null : handleEmailLogin,
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
                      : const Text('Sign In'),
                ),

                const SizedBox(height: 16),

                // Biometric Login Button
                if (biometricCapability.value?.canAuthenticate == true)
                  OutlinedButton.icon(
                    onPressed: isLoading.value ? null : handleBiometricLogin,
                    icon: const Icon(Icons.fingerprint),
                    label: const Text('Use Biometric'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),

                const SizedBox(height: 32),

                // Divider
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),

                const SizedBox(height: 32),

                // OAuth Buttons
                OutlinedButton.icon(
                  onPressed: isLoading.value ? null : handleGoogleSignIn,
                  icon: const Icon(Icons.g_mobiledata, size: 24),
                  label: const Text('Continue with Google'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),

                const SizedBox(height: 12),

                // Magic Link Button
                OutlinedButton.icon(
                  onPressed: isLoading.value ? null : handleMagicLinkRequest,
                  icon: const Icon(Icons.link),
                  label: const Text('Send Magic Link'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),

                const SizedBox(height: 48),

                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: theme.textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: onRegister ?? () => context.push('/register'),
                      child: const Text('Sign Up'),
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
}
