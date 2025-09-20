import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/profile_provider.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../widgets/app_bars/custom_app_bars.dart';
import '../../widgets/buttons/custom_buttons.dart';
import '../../widgets/dialog_components.dart';

class SecuritySettingsPage extends ConsumerStatefulWidget {
  const SecuritySettingsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<SecuritySettingsPage> createState() =>
      _SecuritySettingsPageState();
}

class _SecuritySettingsPageState extends ConsumerState<SecuritySettingsPage> {
  bool _biometricsEnabled = false;
  bool _twoFactorEnabled = false;
  bool _emailAlerts = true;
  bool _smsAlerts = false;
  bool _loginAlerts = true;

  @override
  void initState() {
    super.initState();
    _loadSecuritySettings();
  }

  void _loadSecuritySettings() {
    final profile = ref.read(currentUserProvider);
    if (profile != null) {
      setState(() {
        _twoFactorEnabled = profile.isTwoFactorEnabled;
        _emailAlerts = true; // Default value as settings field doesn't exist
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Security Settings', centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Security Status Card
            _buildSecurityStatusCard(context),

            const SizedBox(height: 24),

            // Authentication Section
            _buildSection(
              context,
              title: 'Authentication',
              icon: Icons.lock_outline,
              children: [
                _buildPasswordTile(context),
                _buildTwoFactorTile(context),
                _buildBiometricsTile(context),
                _buildPasskeysTile(context),
              ],
            ),

            const SizedBox(height: 24),

            // Security Alerts Section
            _buildSection(
              context,
              title: 'Security Alerts',
              icon: Icons.notifications_active_outlined,
              children: [
                SwitchListTile(
                  title: const Text('Email Alerts'),
                  subtitle: const Text(
                    'Get notified about security events via email',
                  ),
                  value: _emailAlerts,
                  onChanged: (value) {
                    setState(() => _emailAlerts = value);
                    _updateSecuritySettings();
                  },
                ),
                SwitchListTile(
                  title: const Text('SMS Alerts'),
                  subtitle: const Text(
                    'Get notified about security events via SMS',
                  ),
                  value: _smsAlerts,
                  onChanged: (value) {
                    setState(() => _smsAlerts = value);
                    _updateSecuritySettings();
                  },
                ),
                SwitchListTile(
                  title: const Text('Login Alerts'),
                  subtitle: const Text(
                    'Alert me when someone logs into my account',
                  ),
                  value: _loginAlerts,
                  onChanged: (value) {
                    setState(() => _loginAlerts = value);
                    _updateSecuritySettings();
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Login Security Section
            _buildSection(
              context,
              title: 'Login Security',
              icon: Icons.security,
              children: [
                ListTile(
                  leading: const Icon(Icons.devices),
                  title: const Text('Active Sessions'),
                  subtitle: const Text(
                    'Manage devices logged into your account',
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => context.push('/settings/sessions'),
                ),
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text('Login History'),
                  subtitle: const Text('View recent login activity'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showLoginHistory(context),
                ),
                ListTile(
                  leading: const Icon(Icons.vpn_key),
                  title: const Text('App Passwords'),
                  subtitle: const Text('Manage app-specific passwords'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showAppPasswords(context),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Privacy Section
            _buildSection(
              context,
              title: 'Privacy',
              icon: Icons.privacy_tip_outlined,
              children: [
                ListTile(
                  leading: const Icon(Icons.block),
                  title: const Text('Blocked Users'),
                  subtitle: const Text('Manage blocked accounts'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showBlockedUsers(context),
                ),
                ListTile(
                  leading: const Icon(Icons.visibility_off),
                  title: const Text('Privacy Settings'),
                  subtitle: const Text('Control who can see your information'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => context.push('/settings/privacy'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Advanced Security Section
            _buildSection(
              context,
              title: 'Advanced Security',
              icon: Icons.admin_panel_settings_outlined,
              children: [
                ListTile(
                  leading: const Icon(Icons.download),
                  title: const Text('Download Security Log'),
                  subtitle: const Text('Get a detailed log of security events'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _downloadSecurityLog(context),
                ),
                ListTile(
                  leading: const Icon(Icons.backup),
                  title: const Text('Backup Codes'),
                  subtitle: const Text('Generate emergency access codes'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showBackupCodes(context),
                ),
                ListTile(
                  leading: const Icon(Icons.warning_amber),
                  title: const Text('Security Checkup'),
                  subtitle: const Text('Review your security settings'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _runSecurityCheckup(context),
                ),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityStatusCard(BuildContext context) {
    final theme = Theme.of(context);
    final securityScore = _calculateSecurityScore();
    final scoreColor = _getScoreColor(securityScore);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Security Score', style: theme.textTheme.titleLarge),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: scoreColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: scoreColor),
                  ),
                  child: Text(
                    '$securityScore%',
                    style: TextStyle(
                      color: scoreColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: securityScore / 100,
              backgroundColor: theme.colorScheme.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
              minHeight: 8,
            ),
            const SizedBox(height: 16),
            Text(
              _getSecurityMessage(securityScore),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            if (securityScore < 100) ...[
              const SizedBox(height: 16),
              CustomButton(
                text: 'Improve Security',
                onPressed: () => _showSecurityRecommendations(context),
                type: ButtonType.primary,
                size: ButtonSize.small,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(child: Column(children: children)),
      ],
    );
  }

  Widget _buildPasswordTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.password),
      title: const Text('Password'),
      subtitle: const Text('Last changed 30 days ago'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => _showChangePasswordDialog(context),
    );
  }

  Widget _buildTwoFactorTile(BuildContext context) {
    final profile = ref.watch(currentUserProvider);

    return SwitchListTile(
      secondary: const Icon(Icons.security),
      title: const Text('Two-Factor Authentication'),
      subtitle: Text(
        _twoFactorEnabled
            ? 'Your account is protected with 2FA'
            : 'Add an extra layer of security',
      ),
      value: _twoFactorEnabled,
      onChanged: (value) => _toggleTwoFactor(context, value),
    );
  }

  Widget _buildBiometricsTile(BuildContext context) {
    return SwitchListTile(
      secondary: const Icon(Icons.fingerprint),
      title: const Text('Biometric Login'),
      subtitle: const Text('Use fingerprint or face to login'),
      value: _biometricsEnabled,
      onChanged: (value) => _toggleBiometrics(context, value),
    );
  }

  Widget _buildPasskeysTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.key),
      title: const Text('Passkeys'),
      subtitle: const Text('Passwordless sign-in'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => _showPasskeysDialog(context),
    );
  }

  int _calculateSecurityScore() {
    int score = 40; // Base score

    if (_twoFactorEnabled) score += 30;
    if (_biometricsEnabled) score += 10;
    if (_emailAlerts) score += 10;
    if (_loginAlerts) score += 10;

    return score.clamp(0, 100);
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  String _getSecurityMessage(int score) {
    if (score >= 80) {
      return 'Your account has strong security. Keep it up!';
    } else if (score >= 60) {
      return 'Your account security is good, but could be improved.';
    } else {
      return 'Your account is at risk. Enable additional security features.';
    }
  }

  void _showSecurityRecommendations(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return _SecurityRecommendationsSheet(
            scrollController: scrollController,
            twoFactorEnabled: _twoFactorEnabled,
            biometricsEnabled: _biometricsEnabled,
          );
        },
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    // Show change password dialog
    context.push('/settings/change-password');
  }

  void _toggleTwoFactor(BuildContext context, bool enable) async {
    if (enable) {
      final result = await ref.read(profileProvider.notifier).enable2FA();
      if (result != null) {
        setState(() => _twoFactorEnabled = true);
        // Show QR code and backup codes
        _show2FASetupDialog(context, result);
      }
    } else {
      // Show confirmation dialog to disable 2FA
      final confirmed = await DialogUtils.showConfirmationDialog(
        context: context,
        title: 'Disable Two-Factor Authentication',
        message:
            'Are you sure you want to disable 2FA? This will make your account less secure.',
        confirmText: 'Disable',
        confirmColor: Theme.of(context).colorScheme.error,
      );

      if (confirmed == true) {
        // Show dialog to enter 2FA code
        _showDisable2FADialog(context);
      }
    }
  }

  void _show2FASetupDialog(
    BuildContext context,
    Map<String, dynamic> setupData,
  ) {
    // Show 2FA setup with QR code and backup codes
  }

  void _showDisable2FADialog(BuildContext context) {
    // Show dialog to enter 2FA code for disabling
  }

  void _toggleBiometrics(BuildContext context, bool enable) {
    setState(() => _biometricsEnabled = enable);
    // Enable/disable biometric authentication
  }

  void _showPasskeysDialog(BuildContext context) {
    // Show passkeys management
  }

  void _showLoginHistory(BuildContext context) {
    context.push('/settings/login-history');
  }

  void _showAppPasswords(BuildContext context) {
    // Show app passwords management
  }

  void _showBlockedUsers(BuildContext context) {
    // Show blocked users list
  }

  void _downloadSecurityLog(BuildContext context) {
    // Download security log
  }

  void _showBackupCodes(BuildContext context) {
    // Show/generate backup codes
  }

  void _runSecurityCheckup(BuildContext context) {
    // Run security checkup
    context.push('/settings/security-checkup');
  }

  void _updateSecuritySettings() {
    // Update security settings
  }
}

class _SecurityRecommendationsSheet extends StatelessWidget {
  final ScrollController scrollController;
  final bool twoFactorEnabled;
  final bool biometricsEnabled;

  const _SecurityRecommendationsSheet({
    required this.scrollController,
    required this.twoFactorEnabled,
    required this.biometricsEnabled,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            'Security Recommendations',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              controller: scrollController,
              children: [
                if (!twoFactorEnabled)
                  _RecommendationCard(
                    icon: Icons.security,
                    title: 'Enable Two-Factor Authentication',
                    description:
                        'Add an extra layer of security to your account',
                    priority: 'High',
                    onTap: () {
                      Navigator.pop(context);
                      // Enable 2FA
                    },
                  ),
                if (!biometricsEnabled)
                  _RecommendationCard(
                    icon: Icons.fingerprint,
                    title: 'Enable Biometric Login',
                    description:
                        'Use your fingerprint or face for quick and secure access',
                    priority: 'Medium',
                    onTap: () {
                      Navigator.pop(context);
                      // Enable biometrics
                    },
                  ),
                _RecommendationCard(
                  icon: Icons.password,
                  title: 'Use a Strong Password',
                  description: 'Make sure your password is unique and complex',
                  priority: 'High',
                  onTap: () {
                    Navigator.pop(context);
                    // Change password
                  },
                ),
                _RecommendationCard(
                  icon: Icons.devices,
                  title: 'Review Active Sessions',
                  description: 'Check for any unauthorized devices',
                  priority: 'Low',
                  onTap: () {
                    Navigator.pop(context);
                    // View sessions
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String priority;
  final VoidCallback onTap;

  const _RecommendationCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.priority,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final priorityColor = _getPriorityColor(priority);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, size: 32, color: theme.colorScheme.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: priorityColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: priorityColor),
                          ),
                          child: Text(
                            priority,
                            style: TextStyle(
                              color: priorityColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
