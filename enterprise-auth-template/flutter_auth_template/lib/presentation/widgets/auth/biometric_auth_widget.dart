import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_auth_template/app/theme.dart';

class BiometricAuthWidget extends ConsumerStatefulWidget {
  final VoidCallback? onSuccess;
  final VoidCallback? onSkip;
  final bool isSetup;
  final String? email;

  const BiometricAuthWidget({
    super.key,
    this.onSuccess,
    this.onSkip,
    this.isSetup = false,
    this.email,
  });

  @override
  ConsumerState<BiometricAuthWidget> createState() =>
      _BiometricAuthWidgetState();
}

class _BiometricAuthWidgetState extends ConsumerState<BiometricAuthWidget>
    with TickerProviderStateMixin {
  final LocalAuthentication _localAuth = LocalAuthentication();

  bool _isChecking = true;
  bool _canCheckBiometrics = false;
  bool _isAuthenticating = false;
  List<BiometricType> _availableBiometrics = [];
  String? _errorMessage;

  // Animations
  late AnimationController _iconAnimationController;
  late AnimationController _pulseAnimationController;
  late Animation<double> _iconRotation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkBiometrics();
  }

  void _initializeAnimations() {
    // Icon rotation animation
    _iconAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _iconRotation = Tween<double>(begin: 0.0, end: 2 * 3.14159).animate(
      CurvedAnimation(
        parent: _iconAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Pulse animation
    _pulseAnimationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _pulseAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _iconAnimationController.dispose();
    _pulseAnimationController.dispose();
    super.dispose();
  }

  Future<void> _checkBiometrics() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();

      if (canCheck && isSupported) {
        final availableBiometrics = await _localAuth.getAvailableBiometrics();
        setState(() {
          _canCheckBiometrics = true;
          _availableBiometrics = availableBiometrics;
          _isChecking = false;
        });
      } else {
        setState(() {
          _canCheckBiometrics = false;
          _isChecking = false;
          _errorMessage =
              'Biometric authentication is not available on this device';
        });
      }
    } catch (e) {
      setState(() {
        _canCheckBiometrics = false;
        _isChecking = false;
        _errorMessage = 'Failed to check biometric availability';
      });
    }
  }

  Future<void> _authenticate() async {
    if (!_canCheckBiometrics) return;

    setState(() {
      _isAuthenticating = true;
      _errorMessage = null;
    });

    _iconAnimationController.repeat();
    HapticFeedback.lightImpact();

    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: widget.isSetup
            ? 'Authenticate to enable biometric login'
            : 'Authenticate to sign in',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        HapticFeedback.mediumImpact();

        if (widget.isSetup) {
          // Save biometric setup
          await _saveBiometricSetup();
        }

        widget.onSuccess?.call();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.isSetup
                    ? 'Biometric authentication enabled successfully!'
                    : 'Authentication successful!',
              ),
              backgroundColor: AppTheme.successColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Authentication cancelled';
        });
      }
    } on PlatformException catch (e) {
      setState(() {
        switch (e.code) {
          case 'NotEnrolled':
            _errorMessage =
                'No biometric data enrolled. Please set up biometrics in device settings';
            break;
          case 'LockedOut':
          case 'PermanentlyLockedOut':
            _errorMessage =
                'Too many attempts. Biometric authentication is locked';
            break;
          default:
            _errorMessage = 'Authentication error: ${e.message}';
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Authentication failed: ${e.toString()}';
      });
    } finally {
      _iconAnimationController.stop();
      _iconAnimationController.reset();

      if (mounted) {
        setState(() {
          _isAuthenticating = false;
        });
      }
    }
  }

  Future<void> _saveBiometricSetup() async {
    // TODO: Save biometric setup to secure storage
    // This would typically involve storing a flag that biometric is enabled
    // and potentially storing encrypted credentials for future use
  }

  IconData _getBiometricIcon() {
    if (_availableBiometrics.contains(BiometricType.face)) {
      return Icons.face;
    } else if (_availableBiometrics.contains(BiometricType.fingerprint)) {
      return Icons.fingerprint;
    } else if (_availableBiometrics.contains(BiometricType.iris)) {
      return Icons.remove_red_eye;
    }
    return Icons.security;
  }

  String _getBiometricName() {
    if (_availableBiometrics.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (_availableBiometrics.contains(BiometricType.fingerprint)) {
      return 'Fingerprint';
    } else if (_availableBiometrics.contains(BiometricType.iris)) {
      return 'Iris Scan';
    }
    return 'Biometric';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    if (_isChecking) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppTheme.primaryColor),
            const SizedBox(height: 16),
            Text(
              'Checking biometric availability...',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(
          alpha: isDarkMode ? 0.95 : 1,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withValues(alpha: 0.2)
                : AppTheme.primaryColor.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon with animation
          ScaleTransition(
            scale: _pulseAnimation,
            child: AnimatedBuilder(
              animation: _iconRotation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _isAuthenticating ? _iconRotation.value : 0,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.primaryColor.withValues(alpha: 0.1),
                          AppTheme.primaryVariant.withValues(alpha: 0.1),
                        ],
                      ),
                      border: Border.all(
                        color: AppTheme.primaryColor.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      _canCheckBiometrics
                          ? _getBiometricIcon()
                          : Icons.error_outline,
                      size: 60,
                      color: _canCheckBiometrics
                          ? AppTheme.primaryColor
                          : AppTheme.errorColor,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Text(
            widget.isSetup
                ? 'Enable Biometric Login'
                : 'Biometric Authentication',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Description
          Text(
            _canCheckBiometrics
                ? widget.isSetup
                      ? 'Use ${_getBiometricName()} for quick and secure login'
                      : 'Authenticate using ${_getBiometricName()}'
                : 'Biometric authentication unavailable',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),

          // Error message
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.errorColor.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: AppTheme.errorColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: AppTheme.errorColor,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 32),

          // Action buttons
          if (_canCheckBiometrics) ...[
            // Authenticate button
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.primaryVariant],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: _isAuthenticating ? null : _authenticate,
                icon: Icon(_getBiometricIcon(), color: Colors.white),
                label: Text(
                  _isAuthenticating
                      ? 'Authenticating...'
                      : widget.isSetup
                      ? 'Enable ${_getBiometricName()}'
                      : 'Authenticate with ${_getBiometricName()}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            if (widget.onSkip != null) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: widget.onSkip,
                child: Text(
                  widget.isSetup ? 'Skip for now' : 'Use password instead',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ] else ...[
            // Biometrics not available - show alternative
            OutlinedButton.icon(
              onPressed: widget.onSkip,
              icon: const Icon(Icons.arrow_forward),
              label: Text(
                widget.isSetup ? 'Continue without biometrics' : 'Use password',
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],

          // Information section
          if (widget.isSetup && _canCheckBiometrics) ...[
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Benefits of biometric login',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildBenefitItem(
                    icon: Icons.speed,
                    text: 'Faster login without typing passwords',
                    theme: theme,
                  ),
                  const SizedBox(height: 8),
                  _buildBenefitItem(
                    icon: Icons.security,
                    text: 'Enhanced security with unique biometric data',
                    theme: theme,
                  ),
                  const SizedBox(height: 8),
                  _buildBenefitItem(
                    icon: Icons.lock,
                    text: 'Your biometric data never leaves your device',
                    theme: theme,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBenefitItem({
    required IconData icon,
    required String text,
    required ThemeData theme,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.primary.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
      ],
    );
  }
}
