import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../../core/errors/app_exception.dart';
import '../../../domain/entities/auth_state.dart';

class MagicLinkVerificationPage extends HookConsumerWidget {
  final String? token;
  final String? email;

  const MagicLinkVerificationPage({super.key, this.token, this.email});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authNotifier = ref.read(authStateProvider.notifier);

    final isLoading = useState(false);
    final errorMessage = useState<String?>(null);
    final verificationStatus = useState<VerificationStatus>(
      VerificationStatus.pending,
    );

    // Auto-verify if token is provided
    useEffect(() {
      if (token != null &&
          verificationStatus.value == VerificationStatus.pending) {
        Future.microtask(() async {
          isLoading.value = true;
          try {
            await authNotifier.verifyMagicLink(token!);
            verificationStatus.value = VerificationStatus.success;
          } catch (e) {
            errorMessage.value = e is AppException
                ? e.message
                : 'Verification failed';
            verificationStatus.value = VerificationStatus.failed;
          } finally {
            isLoading.value = false;
          }
        });
      }
      return null;
    }, [token]);

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
        authenticating: () {},
        error: (message) {
          errorMessage.value = message;
          verificationStatus.value = VerificationStatus.failed;
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Magic Link Verification'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: _buildContent(
              context,
              theme,
              verificationStatus.value,
              isLoading.value,
              errorMessage.value,
              email,
              authNotifier,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ThemeData theme,
    VerificationStatus status,
    bool isLoading,
    String? errorMessage,
    String? email,
    AuthNotifier authNotifier,
  ) {
    if (isLoading) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(strokeWidth: 3),
          const SizedBox(height: 24),
          Text('Verifying Magic Link...', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 16),
          Text(
            'Please wait while we verify your magic link',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    switch (status) {
      case VerificationStatus.pending:
        return _buildPendingView(context, theme, email);
      case VerificationStatus.success:
        return _buildSuccessView(context, theme);
      case VerificationStatus.failed:
        return _buildFailureView(context, theme, errorMessage, authNotifier);
    }
  }

  Widget _buildPendingView(
    BuildContext context,
    ThemeData theme,
    String? email,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.email_outlined, size: 80, color: theme.colorScheme.primary),
        const SizedBox(height: 24),
        Text(
          'Check Your Email',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (email != null) ...[
          Text(
            'We sent a magic link to:',
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            email,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
        ],
        Text(
          'Click the link in your email to sign in automatically.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48),
        OutlinedButton.icon(
          onPressed: () => context.go('/login'),
          icon: const Icon(Icons.arrow_back),
          label: const Text('Back to Login'),
        ),
      ],
    );
  }

  Widget _buildSuccessView(BuildContext context, ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.check_circle_outline,
          size: 80,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 24),
        Text(
          'Verification Successful!',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Your magic link has been verified successfully.',
          style: theme.textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Redirecting to your dashboard...',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 32),
        const CircularProgressIndicator(),
      ],
    );
  }

  Widget _buildFailureView(
    BuildContext context,
    ThemeData theme,
    String? errorMessage,
    AuthNotifier authNotifier,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, size: 80, color: theme.colorScheme.error),
        const SizedBox(height: 24),
        Text(
          'Verification Failed',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.error,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          errorMessage ?? 'The magic link is invalid or has expired.',
          style: theme.textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48),
        ElevatedButton.icon(
          onPressed: () async {
            // Request a new magic link
            try {
              await authNotifier.requestMagicLink(
                '',
              ); // Email should be provided
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('New magic link sent to your email'),
                  backgroundColor: Colors.green,
                ),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(e.toString()),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          icon: const Icon(Icons.refresh),
          label: const Text('Request New Link'),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => context.go('/login'),
          child: const Text('Back to Login'),
        ),
      ],
    );
  }
}

enum VerificationStatus { pending, success, failed }
