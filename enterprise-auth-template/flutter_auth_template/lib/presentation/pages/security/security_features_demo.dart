import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_auth_template/presentation/widgets/security/biometric_setup_widget.dart';
import 'package:flutter_auth_template/presentation/widgets/security/security_questions_widget.dart';
import 'package:flutter_auth_template/presentation/widgets/security/login_anomaly_alert.dart';
import 'package:flutter_auth_template/presentation/widgets/security/rate_limit_indicator.dart';
import 'package:flutter_auth_template/presentation/widgets/security/account_lockout_display.dart';
import 'package:flutter_auth_template/presentation/widgets/security/session_timeout_warning.dart';
import 'package:flutter_auth_template/presentation/widgets/security/secure_app_wrapper.dart';

/// Demo page showcasing all security features
class SecurityFeaturesDemo extends ConsumerStatefulWidget {
  const SecurityFeaturesDemo({super.key});

  @override
  ConsumerState<SecurityFeaturesDemo> createState() => _SecurityFeaturesDemoState();
}

class _SecurityFeaturesDemoState extends ConsumerState<SecurityFeaturesDemo> {
  int _selectedIndex = 0;

  // Demo data for anomaly detection
  final _demoAnomaly = const LoginAnomaly(
    id: 'demo-1',
    type: AnomalyType.newDevice,
    detectedAt: DateTime.now(),
    location: 'San Francisco, CA',
    deviceInfo: 'iPhone 15 Pro',
    ipAddress: '192.168.1.1',
    riskScore: 0.7,
    metadata: {
      'browser': 'Safari',
      'os': 'iOS 17.2',
    },
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final features = [
      _SecurityFeature(
        title: 'Biometric Authentication',
        description: 'Set up fingerprint or face recognition',
        icon: Icons.fingerprint,
        color: Colors.blue,
        widget: const BiometricSetupWidget(),
      ),
      _SecurityFeature(
        title: 'Security Questions',
        description: 'Configure recovery questions',
        icon: Icons.quiz,
        color: Colors.green,
        widget: const SecurityQuestionsSetup(),
      ),
      _SecurityFeature(
        title: 'Login Anomaly Detection',
        description: 'Suspicious login alerts',
        icon: Icons.warning,
        color: Colors.orange,
        widget: _buildAnomalyDemo(),
      ),
      _SecurityFeature(
        title: 'Rate Limiting',
        description: 'API rate limit protection',
        icon: Icons.speed,
        color: Colors.purple,
        widget: _buildRateLimitDemo(),
      ),
      _SecurityFeature(
        title: 'Account Lockout',
        description: 'Failed attempt protection',
        icon: Icons.lock_clock,
        color: Colors.red,
        widget: _buildAccountLockoutDemo(),
      ),
      _SecurityFeature(
        title: 'Session Management',
        description: 'Timeout and activity tracking',
        icon: Icons.timer,
        color: Colors.teal,
        widget: _buildSessionDemo(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Features'),
        centerTitle: true,
      ),
      body: Row(
        children: [
          // Navigation rail for larger screens
          if (MediaQuery.of(context).size.width > 600)
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              labelType: NavigationRailLabelType.all,
              destinations: features.map((feature) {
                return NavigationRailDestination(
                  icon: Icon(feature.icon),
                  selectedIcon: Icon(feature.icon, color: feature.color),
                  label: Text(feature.title),
                );
              }).toList(),
            ),
          const VerticalDivider(thickness: 1, width: 1),
          // Content area
          Expanded(
            child: Column(
              children: [
                // Feature header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        features[_selectedIndex].color.withAlpha((26).round()),
                        features[_selectedIndex].color.withAlpha((13).round()),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border(
                      bottom: BorderSide(
                        color: features[_selectedIndex].color.withAlpha((51).round()),
                        width: 2,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: features[_selectedIndex].color.withAlpha((26).round()),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              features[_selectedIndex].icon,
                              size: 32,
                              color: features[_selectedIndex].color,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  features[_selectedIndex].title,
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  features[_selectedIndex].description,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.onSurface.withAlpha((179).round()),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Feature content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: features[_selectedIndex].widget,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // Bottom navigation for mobile
      bottomNavigationBar: MediaQuery.of(context).size.width <= 600
          ? NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              destinations: features.map((feature) {
                return NavigationDestination(
                  icon: Icon(feature.icon),
                  label: feature.title,
                );
              }).toList(),
            )
          : null,
    );
  }

  Widget _buildAnomalyDemo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Anomaly Detection Examples',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        // Notification example
        SuspiciousLoginNotification(
          anomaly: _demoAnomaly,
          onReview: () {
            showDialog(
              context: context,
              builder: (context) => LoginAnomalyAlert(
                anomaly: _demoAnomaly,
                onApprove: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Login approved'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                onDeny: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Login blocked'),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
                onRequireVerification: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Additional verification required'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                },
              ),
            );
          },
          onDismiss: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Marked as trusted'),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        // Different anomaly types
        ...AnomalyType.values.map((type) {
          final anomaly = LoginAnomaly(
            id: 'demo-${type.index}',
            type: type,
            detectedAt: DateTime.now().subtract(Duration(hours: type.index)),
            location: 'Various Location',
            deviceInfo: 'Demo Device',
            ipAddress: '10.0.0.${type.index}',
            riskScore: (type.index + 1) / AnomalyType.values.length,
          );

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: ListTile(
                leading: Icon(
                  anomaly.typeIcon,
                  color: anomaly.getRiskColor(context),
                ),
                title: Text(anomaly.typeDescription),
                subtitle: Text('Risk: ${anomaly.riskLevel}'),
                trailing: TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => LoginAnomalyAlert(
                        anomaly: anomaly,
                      ),
                    );
                  },
                  child: const Text('View'),
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildRateLimitDemo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rate Limiting Examples',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        // Full indicator
        const RateLimitIndicator(
          retryAfterSeconds: 300,
          message: 'Too many login attempts. Please wait:',
        ),
        const SizedBox(height: 24),
        // Badges with different states
        const Text(
          'Attempt Indicators',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            const RateLimitBadge(attemptsRemaining: 5, maxAttempts: 5),
            const RateLimitBadge(attemptsRemaining: 3, maxAttempts: 5),
            const RateLimitBadge(attemptsRemaining: 1, maxAttempts: 5),
            const RateLimitBadge(attemptsRemaining: 0, maxAttempts: 5),
          ],
        ),
      ],
    );
  }

  Widget _buildAccountLockoutDemo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Account Lockout Examples',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        // Lockout display
        AccountLockoutDisplay(
          email: 'demo@example.com',
          onUnlockComplete: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Account unlocked'),
                backgroundColor: Colors.green,
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        // Badges
        const Text(
          'Failed Attempt Badges',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        const Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            AccountLockoutBadge(failedAttempts: 0, maxAttempts: 5),
            AccountLockoutBadge(failedAttempts: 2, maxAttempts: 5),
            AccountLockoutBadge(failedAttempts: 4, maxAttempts: 5),
            AccountLockoutBadge(failedAttempts: 5, maxAttempts: 5),
          ],
        ),
      ],
    );
  }

  Widget _buildSessionDemo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Session Management',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        // Session timer
        const Text(
          'The session timer widget appears as a floating indicator.',
          style: TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => SessionTimeoutWarning(
                onExtendSession: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Session extended'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                onLogout: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Logged out'),
                    ),
                  );
                },
              ),
            );
          },
          icon: const Icon(Icons.timer),
          label: const Text('Show Timeout Warning'),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AutoLogoutCountdown(
                countdownSeconds: 5,
                onCancel: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Auto-logout cancelled'),
                    ),
                  );
                },
              ),
            );
          },
          icon: const Icon(Icons.logout),
          label: const Text('Show Auto-Logout'),
        ),
        const SizedBox(height: 24),
        const Text(
          'Security Questions Verification',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => Dialog(
                child: SizedBox(
                  width: 400,
                  child: SecurityQuestionsVerification(
                    onSuccess: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Verification successful'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    onForgot: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Recovery options sent'),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
          icon: const Icon(Icons.quiz),
          label: const Text('Test Security Question'),
        ),
      ],
    );
  }
}

class _SecurityFeature {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final Widget widget;

  const _SecurityFeature({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.widget,
  });
}