import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_auth_template/providers/auth_provider.dart';
import 'package:flutter_auth_template/data/models/auth_request.dart';
import 'package:url_launcher/url_launcher.dart';

enum RegistrationStep { info, credentials, complete }

class ModernRegisterScreen extends ConsumerStatefulWidget {
  const ModernRegisterScreen({super.key});

  @override
  ConsumerState<ModernRegisterScreen> createState() =>
      _ModernRegisterScreenState();
}

class _ModernRegisterScreenState extends ConsumerState<ModernRegisterScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  RegistrationStep _currentStep = RegistrationStep.info;
  bool _isLoading = false;

  // Form controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _organizationController = TextEditingController();

  // Form state
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _acceptTerms = false;
  bool _subscribeNewsletter = false;

  // Animation controllers
  late AnimationController _fadeAnimationController;
  late AnimationController _slideAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Password strength
  double _passwordStrength = 0.0;
  String _passwordStrengthText = '';
  Color _passwordStrengthColor = Colors.red;

  @override
  void initState() {
    super.initState();
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideAnimationController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimationController.forward();
    _slideAnimationController.forward();

    // Listen to password changes for strength calculation
    _passwordController.addListener(_calculatePasswordStrength);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _organizationController.dispose();
    _fadeAnimationController.dispose();
    _slideAnimationController.dispose();
    super.dispose();
  }

  void _calculatePasswordStrength() {
    final password = _passwordController.text;
    double strength = 0;

    if (password.length >= 8) strength += 0.25;
    if (password.length >= 12) strength += 0.25;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.125;
    if (RegExp(r'[a-z]').hasMatch(password)) strength += 0.125;
    if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.125;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength += 0.125;

    setState(() {
      _passwordStrength = strength;
      if (strength < 0.3) {
        _passwordStrengthText = 'Weak';
        _passwordStrengthColor = Colors.red;
      } else if (strength < 0.6) {
        _passwordStrengthText = 'Fair';
        _passwordStrengthColor = Colors.orange;
      } else if (strength < 0.8) {
        _passwordStrengthText = 'Good';
        _passwordStrengthColor = Colors.amber;
      } else {
        _passwordStrengthText = 'Strong';
        _passwordStrengthColor = Colors.green;
      }
    });
  }

  bool _validateCurrentStep() {
    if (!_formKey.currentState!.validate()) return false;

    if (_currentStep == RegistrationStep.credentials && !_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the terms and conditions'),
          backgroundColor: Colors.orange,
        ),
      );
      return false;
    }

    return true;
  }

  Future<void> _handleNextStep() async {
    if (!_validateCurrentStep()) return;

    if (_currentStep == RegistrationStep.info) {
      setState(() => _currentStep = RegistrationStep.credentials);
      _slideAnimationController.reset();
      _slideAnimationController.forward();
    } else if (_currentStep == RegistrationStep.credentials) {
      await _handleRegistration();
    }
  }

  Future<void> _handleRegistration() async {
    setState(() => _isLoading = true);

    try {
      final request = RegisterRequest(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
        fullName: _nameController.text.trim(),
        organization: _organizationController.text.trim().isNotEmpty
            ? _organizationController.text.trim()
            : null,
        agreeToTerms: _acceptTerms,
        subscribeNewsletter: _subscribeNewsletter,
      );

      await ref.read(authStateProvider.notifier).register(
        _emailController.text.trim(),
        _passwordController.text,
        _nameController.text.trim(),
      );

      setState(() {
        _currentStep = RegistrationStep.complete;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withOpacity(0.1),
              theme.colorScheme.secondary.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildHeader(theme),
                          const SizedBox(height: 32),
                          _buildProgressIndicator(theme),
                          const SizedBox(height: 32),
                          _buildStepContent(theme),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.secondary,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.person_add,
            color: Colors.white,
            size: 32,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _currentStep == RegistrationStep.complete
              ? 'Registration Complete!'
              : 'Create Account',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _currentStep == RegistrationStep.complete
              ? 'Check your email to verify your account'
              : 'Join thousands of users already using our platform',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProgressIndicator(ThemeData theme) {
    if (_currentStep == RegistrationStep.complete) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        _buildStepIndicator(
          theme,
          '1',
          'Personal Info',
          _currentStep.index >= 0,
        ),
        Expanded(
          child: Container(
            height: 2,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            color: _currentStep.index >= 1
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withOpacity(0.3),
          ),
        ),
        _buildStepIndicator(
          theme,
          '2',
          'Credentials',
          _currentStep.index >= 1,
        ),
      ],
    );
  }

  Widget _buildStepIndicator(
    ThemeData theme,
    String number,
    String label,
    bool isActive,
  ) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive
                ? theme.colorScheme.primary
                : theme.colorScheme.surface,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                color: isActive
                    ? Colors.white
                    : theme.colorScheme.onSurface.withOpacity(0.5),
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
            color: isActive
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildStepContent(ThemeData theme) {
    switch (_currentStep) {
      case RegistrationStep.info:
        return SlideTransition(
          position: _slideAnimation,
          child: _buildPersonalInfoStep(theme),
        );
      case RegistrationStep.credentials:
        return SlideTransition(
          position: _slideAnimation,
          child: _buildCredentialsStep(theme),
        );
      case RegistrationStep.complete:
        return _buildCompleteStep(theme);
    }
  }

  Widget _buildPersonalInfoStep(ThemeData theme) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Full Name',
              hintText: 'Enter your full name',
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.3),
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'Enter your email',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.3),
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                  .hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _organizationController,
            decoration: InputDecoration(
              labelText: 'Organization (Optional)',
              hintText: 'Enter your organization',
              prefixIcon: const Icon(Icons.business_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.3),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _handleNextStep,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => context.go('/login'),
            child: Text(
              'Already have an account? Sign in',
              style: TextStyle(color: theme.colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCredentialsStep(ThemeData theme) {
    return Form(
      key: _currentStep == RegistrationStep.credentials ? _formKey : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _passwordController,
            obscureText: !_showPassword,
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'Create a strong password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _showPassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () => setState(() => _showPassword = !_showPassword),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.3),
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              if (value.length < 8) {
                return 'Password must be at least 8 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          if (_passwordController.text.isNotEmpty) ...[
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: _passwordStrength,
                    backgroundColor: theme.colorScheme.outline.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _passwordStrengthColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _passwordStrengthText,
                  style: TextStyle(
                    color: _passwordStrengthColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Use 8+ characters with uppercase, lowercase, numbers & symbols',
              style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
          const SizedBox(height: 16),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: !_showConfirmPassword,
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              hintText: 'Re-enter your password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _showConfirmPassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: () =>
                    setState(() => _showConfirmPassword = !_showConfirmPassword),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.3),
                ),
              ),
            ),
            validator: (value) {
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          CheckboxListTile(
            value: _acceptTerms,
            onChanged: (value) => setState(() => _acceptTerms = value ?? false),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            title: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface,
                ),
                children: [
                  const TextSpan(text: 'I agree to the '),
                  TextSpan(
                    text: 'Terms of Service',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => launchUrl(
                            Uri.parse('https://example.com/terms'),
                          ),
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => launchUrl(
                            Uri.parse('https://example.com/privacy'),
                          ),
                  ),
                ],
              ),
            ),
          ),
          CheckboxListTile(
            value: _subscribeNewsletter,
            onChanged: (value) =>
                setState(() => _subscribeNewsletter = value ?? false),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Send me product updates and offers',
              style: TextStyle(fontSize: 14),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() => _currentStep = RegistrationStep.info);
                    _slideAnimationController.reset();
                    _slideAnimationController.forward();
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Back'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleNextStep,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompleteStep(ThemeData theme) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 60,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Verification Email Sent!',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'We\'ve sent a verification email to ${_emailController.text}. Please check your inbox and click the link to activate your account.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () => context.go('/login'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(200, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Go to Login',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            // TODO: Implement resend verification email
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Verification email resent!'),
                backgroundColor: Colors.green,
              ),
            );
          },
          child: Text(
            'Didn\'t receive email? Resend',
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}