import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_auth_template/presentation/providers/auth_provider.dart';
import 'package:flutter_auth_template/presentation/widgets/security/rate_limit_indicator.dart';
import 'package:flutter_auth_template/presentation/widgets/security/account_lockout_display.dart';
import 'package:flutter_auth_template/core/security/rate_limiter.dart';
import 'package:flutter_auth_template/core/security/account_lockout_service.dart';
import 'package:flutter_auth_template/domain/entities/auth_state.dart';

/// Enhanced login form with integrated security components
class SecureLoginForm extends HookConsumerWidget {
  final VoidCallback? onSuccess;

  const SecureLoginForm({
    super.key,
    this.onSuccess,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authStateProvider);
    final authNotifier = ref.read(authStateProvider.notifier);
    final rateLimiter = ref.watch(rateLimiterProvider);
    final lockoutService = ref.watch(accountLockoutServiceProvider);

    // Form controllers
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final formKey = useMemoized(() => GlobalKey<FormState>());

    // State
    final obscurePassword = useState(true);
    final isLoading = useState(false);
    final errorMessage = useState<String?>(null);
    final rateLimitInfo = useState<RateLimitResult?>(null);
    final isAccountLocked = useState(false);
    final attemptsRemaining = useState(5);

    // Check account lockout status
    useEffect(() {
      void checkLockout() async {
        if (emailController.text.isNotEmpty) {
          final locked = await lockoutService.isAccountLocked();
          isAccountLocked.value = locked;

          if (!locked) {
            final status = await lockoutService.getAccountStatus(emailController.text);
            attemptsRemaining.value = status.attemptsRemaining;
          }
        }
      }

      emailController.addListener(checkLockout);
      return () => emailController.removeListener(checkLockout);
    }, [emailController.text]);

    // Handle auth state changes
    useEffect(() {
      if (authState is Authenticated) {
        isLoading.value = false;
        errorMessage.value = null;
        rateLimitInfo.value = null;
        onSuccess?.call();
      } else if (authState is AuthError) {
        isLoading.value = false;
        final error = authState as AuthError;
        errorMessage.value = error.message;

        // Check if it's a rate limit error
        if (error.message.contains('Too many')) {
          checkRateLimit();
        }
      } else if (authState is Authenticating) {
        isLoading.value = true;
        errorMessage.value = null;
      }
      return null;
    }, [authState]);

    Future<void> checkRateLimit() async {
      final result = await rateLimiter.checkLimit(
        endpoint: '/api/auth/login',
        clientId: emailController.text.isEmpty ? 'unknown' : emailController.text,
      );

      if (!result.allowed) {
        rateLimitInfo.value = result;
      }
    }

    Future<void> handleLogin() async {
      if (!(formKey.currentState?.validate() ?? false)) return;

      // Check if account is locked
      if (isAccountLocked.value) {
        errorMessage.value = 'Account is locked. Please wait for the lockout period to end.';
        return;
      }

      errorMessage.value = null;
      rateLimitInfo.value = null;

      try {
        await authNotifier.login(
          emailController.text.trim(),
          passwordController.text,
        );
      } catch (e) {
        // Error is handled by auth state
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
                Icons.security,
                size: 64,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Secure Login',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in with enhanced security',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha((179).round()),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Account Lockout Display
          AccountLockoutDisplay(
            email: emailController.text,
            onUnlockComplete: () {
              isAccountLocked.value = false;
              attemptsRemaining.value = 5;
            },
          ),

          // Rate Limit Indicator
          if (rateLimitInfo.value != null && !rateLimitInfo.value!.allowed)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: RateLimitIndicator(
                retryAfterSeconds: rateLimitInfo.value!.retryAfterSeconds ?? 60,
                message: rateLimitInfo.value!.reason ?? 'Too many attempts. Please try again in:',
                onRetryComplete: () {
                  rateLimitInfo.value = null;
                },
              ),
            ),

          // Error Message
          if (errorMessage.value != null &&
              rateLimitInfo.value == null &&
              !isAccountLocked.value)
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

          // Attempts Remaining Badge
          if (!isAccountLocked.value && attemptsRemaining.value < 5)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AccountLockoutBadge(
                    failedAttempts: 5 - attemptsRemaining.value,
                    maxAttempts: 5,
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
                  enabled: !isLoading.value &&
                           !isAccountLocked.value &&
                           (rateLimitInfo.value?.allowed ?? true),
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    final emailRegex = RegExp(
                      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                    );
                    if (!emailRegex.hasMatch(value.trim())) {
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
                  enabled: !isLoading.value &&
                           !isAccountLocked.value &&
                           (rateLimitInfo.value?.allowed ?? true),
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
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Login Button
                ElevatedButton(
                  onPressed: (isLoading.value ||
                             isAccountLocked.value ||
                             !(rateLimitInfo.value?.allowed ?? true))
                      ? null
                      : handleLogin,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    disabledBackgroundColor:
                        theme.colorScheme.surfaceContainerHighest,
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
                      : Text(
                          isAccountLocked.value
                              ? 'Account Locked'
                              : (rateLimitInfo.value?.allowed ?? true)
                                  ? 'Sign In'
                                  : 'Too Many Attempts',
                        ),
                ),

                const SizedBox(height: 16),

                // Links
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => context.push('/auth/forgot-password'),
                      child: const Text('Forgot Password?'),
                    ),
                    TextButton(
                      onPressed: () => context.push('/register'),
                      child: const Text('Create Account'),
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