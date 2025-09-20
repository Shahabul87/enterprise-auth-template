import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_auth_template/core/compliance/consent_manager.dart';

/// Cookie Consent Banner Widget
///
/// Shows cookie consent banner for web version to comply with GDPR/ePrivacy.
/// Only displays on web platform and when consent hasn't been given.
class CookieConsentBanner extends ConsumerStatefulWidget {
  const CookieConsentBanner({super.key});

  @override
  ConsumerState<CookieConsentBanner> createState() => _CookieConsentBannerState();
}

class _CookieConsentBannerState extends ConsumerState<CookieConsentBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  bool _showBanner = false;
  bool _showDetails = false;

  // Consent selections
  final Map<ConsentType, bool> _consentSelections = {
    ConsentType.essential: true, // Always true, cannot be disabled
    ConsentType.analytics: false,
    ConsentType.marketing: false,
    ConsentType.preferences: false,
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _checkConsentStatus();
  }

  Future<void> _checkConsentStatus() async {
    // Only show on web platform
    if (!kIsWeb) {
      return;
    }

    final consentManager = ref.read(consentManagerProvider);
    await consentManager.initialize();

    if (!consentManager.hasGivenConsent) {
      setState(() {
        _showBanner = true;
      });
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _acceptAll() async {
    final consentManager = ref.read(consentManagerProvider);

    // Accept all consent types
    final allConsents = Map<ConsentType, bool>.fromEntries(
      ConsentType.values.map((type) => MapEntry(type, true)),
    );

    await consentManager.updateConsent(
      consents: allConsents,
      method: ConsentMethod.explicit,
    );

    _hideBanner();
  }

  Future<void> _acceptSelected() async {
    final consentManager = ref.read(consentManagerProvider);

    // Include all consent types with user selections
    final fullConsents = Map<ConsentType, bool>.fromEntries(
      ConsentType.values.map((type) {
        if (_consentSelections.containsKey(type)) {
          return MapEntry(type, _consentSelections[type]!);
        }
        return MapEntry(type, false);
      }),
    );

    await consentManager.updateConsent(
      consents: fullConsents,
      method: ConsentMethod.explicit,
    );

    _hideBanner();
  }

  Future<void> _rejectNonEssential() async {
    final consentManager = ref.read(consentManagerProvider);

    // Only accept essential cookies
    final minimalConsents = Map<ConsentType, bool>.fromEntries(
      ConsentType.values.map((type) => MapEntry(
        type,
        type == ConsentType.essential,
      )),
    );

    await consentManager.updateConsent(
      consents: minimalConsents,
      method: ConsentMethod.explicit,
    );

    _hideBanner();
  }

  void _hideBanner() {
    _animationController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _showBanner = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_showBanner || !kIsWeb) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * 200),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[900] : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(theme),
                        const SizedBox(height: 12),
                        _buildDescription(theme),
                        if (_showDetails) ...[
                          const SizedBox(height: 16),
                          _buildConsentOptions(theme),
                        ],
                        const SizedBox(height: 20),
                        _buildActions(theme),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        Icon(
          Icons.cookie,
          color: theme.primaryColor,
          size: 24,
        ),
        const SizedBox(width: 12),
        Text(
          'Cookie Consent',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(ThemeData theme) {
    return Text(
      'We use cookies to enhance your experience, analyze site traffic, and for '
      'marketing purposes. By clicking "Accept All", you consent to our use of cookies.',
      style: theme.textTheme.bodyMedium,
    );
  }

  Widget _buildConsentOptions(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cookie Preferences',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildConsentOption(
            theme,
            ConsentType.essential,
            'Essential Cookies',
            'Required for the website to function properly',
            true, // Always enabled
            enabled: false, // Cannot be toggled
          ),
          _buildConsentOption(
            theme,
            ConsentType.analytics,
            'Analytics Cookies',
            'Help us understand how visitors interact with our website',
            _consentSelections[ConsentType.analytics]!,
          ),
          _buildConsentOption(
            theme,
            ConsentType.marketing,
            'Marketing Cookies',
            'Used to track visitors across websites for marketing',
            _consentSelections[ConsentType.marketing]!,
          ),
          _buildConsentOption(
            theme,
            ConsentType.preferences,
            'Preference Cookies',
            'Remember your settings and preferences',
            _consentSelections[ConsentType.preferences]!,
          ),
        ],
      ),
    );
  }

  Widget _buildConsentOption(
    ThemeData theme,
    ConsentType type,
    String title,
    String description,
    bool value, {
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: enabled
                ? (newValue) {
                    setState(() {
                      _consentSelections[type] = newValue;
                    });
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildActions(ThemeData theme) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        if (!_showDetails) ...[
          OutlinedButton(
            onPressed: () {
              setState(() {
                _showDetails = true;
              });
            },
            child: const Text('Manage Preferences'),
          ),
          OutlinedButton(
            onPressed: _rejectNonEssential,
            child: const Text('Reject Non-Essential'),
          ),
          ElevatedButton(
            onPressed: _acceptAll,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
            ),
            child: const Text('Accept All'),
          ),
        ] else ...[
          TextButton(
            onPressed: () {
              setState(() {
                _showDetails = false;
              });
            },
            child: const Text('Hide Details'),
          ),
          OutlinedButton(
            onPressed: _rejectNonEssential,
            child: const Text('Essential Only'),
          ),
          ElevatedButton(
            onPressed: _acceptSelected,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
            ),
            child: const Text('Save Preferences'),
          ),
        ],
        TextButton(
          onPressed: () => _showPrivacyPolicy(context),
          child: const Text('Privacy Policy'),
        ),
      ],
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'This is where your privacy policy would be displayed. '
            'It should include information about:\n\n'
            '• What data you collect\n'
            '• How you use the data\n'
            '• How long you retain data\n'
            '• User rights under GDPR\n'
            '• Contact information for data protection officer\n\n'
            'For production, integrate with your actual privacy policy.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

/// Cookie Consent Settings Page
///
/// Allows users to manage their cookie consent preferences after initial consent
class CookieConsentSettings extends ConsumerStatefulWidget {
  const CookieConsentSettings({super.key});

  @override
  ConsumerState<CookieConsentSettings> createState() => _CookieConsentSettingsState();
}

class _CookieConsentSettingsState extends ConsumerState<CookieConsentSettings> {
  Map<ConsentType, bool> _consentSelections = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentConsents();
  }

  Future<void> _loadCurrentConsents() async {
    final consentManager = ref.read(consentManagerProvider);
    await consentManager.initialize();

    final currentPrefs = consentManager.currentPreferences;
    if (currentPrefs != null) {
      setState(() {
        _consentSelections = Map.from(currentPrefs.consents);
        _isLoading = false;
      });
    } else {
      setState(() {
        // Default selections
        _consentSelections = Map.fromEntries(
          ConsentType.values.map((type) => MapEntry(
            type,
            type == ConsentType.essential,
          )),
        );
        _isLoading = false;
      });
    }
  }

  Future<void> _savePreferences() async {
    final consentManager = ref.read(consentManagerProvider);

    await consentManager.updateConsent(
      consents: _consentSelections,
      method: ConsentMethod.explicit,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cookie preferences updated'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cookie Preferences'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: theme.primaryColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'About Cookies',
                                style: theme.textTheme.titleLarge,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Cookies are small text files that are placed on your device '
                            'to help us provide a better experience. You can manage your '
                            'cookie preferences below.',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...ConsentType.values.map((type) => _buildConsentTile(type)),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _savePreferences,
                        child: const Text('Save Preferences'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildConsentTile(ConsentType type) {
    final isEssential = type == ConsentType.essential;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: SwitchListTile(
        title: Text(_getConsentTitle(type)),
        subtitle: Text(ConsentManager.getConsentText(type)),
        value: _consentSelections[type] ?? false,
        onChanged: isEssential
            ? null // Essential cookies cannot be disabled
            : (value) {
                setState(() {
                  _consentSelections[type] = value;
                });
              },
        secondary: Icon(_getConsentIcon(type)),
      ),
    );
  }

  String _getConsentTitle(ConsentType type) {
    switch (type) {
      case ConsentType.essential:
        return 'Essential Cookies (Required)';
      case ConsentType.analytics:
        return 'Analytics Cookies';
      case ConsentType.marketing:
        return 'Marketing Cookies';
      case ConsentType.preferences:
        return 'Preference Cookies';
      case ConsentType.thirdParty:
        return 'Third-Party Services';
      case ConsentType.dataSharing:
        return 'Data Sharing';
      case ConsentType.biometric:
        return 'Biometric Data';
      case ConsentType.location:
        return 'Location Services';
      case ConsentType.pushNotifications:
        return 'Push Notifications';
    }
  }

  IconData _getConsentIcon(ConsentType type) {
    switch (type) {
      case ConsentType.essential:
        return Icons.security;
      case ConsentType.analytics:
        return Icons.analytics;
      case ConsentType.marketing:
        return Icons.campaign;
      case ConsentType.preferences:
        return Icons.settings;
      case ConsentType.thirdParty:
        return Icons.group;
      case ConsentType.dataSharing:
        return Icons.share;
      case ConsentType.biometric:
        return Icons.fingerprint;
      case ConsentType.location:
        return Icons.location_on;
      case ConsentType.pushNotifications:
        return Icons.notifications;
    }
  }
}