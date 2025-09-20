import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_auth_template/presentation/providers/profile_provider.dart';
import 'package:flutter_auth_template/presentation/providers/auth_provider.dart';
import 'package:flutter_auth_template/presentation/widgets/app_bars/custom_app_bars.dart';
import 'package:flutter_auth_template/core/responsive/responsive.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = ref.watch(currentUserProvider);

    return ResponsiveBuilder(
      builder: (context, constraints, deviceType) {
        return Scaffold(
          appBar: CustomAppBar(
            title: 'Settings',
            centerTitle: deviceType == DeviceType.mobile,
          ),
          body: _buildBody(context, deviceType),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, DeviceType deviceType) {
    if (deviceType == DeviceType.desktop) {
      return _buildDesktopLayout(context);
    }
    return _buildMobileLayout(context);
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Settings categories sidebar
        SizedBox(
          width: 280,
          child: _buildCategoriesList(context, isDesktop: true),
        ),
        const VerticalDivider(width: 1),
        // Settings content
        Expanded(child: _buildSettingsContent(context)),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Column(children: [_buildSettingsContent(context)]),
    );
  }

  Widget _buildCategoriesList(BuildContext context, {bool isDesktop = false}) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _CategoryTile(
          icon: Icons.person_outline,
          title: 'Account',
          subtitle: 'Profile, email, phone',
          onTap: () => context.push('/settings/account'),
        ),
        _CategoryTile(
          icon: Icons.notifications_outlined,
          title: 'Notifications',
          subtitle: 'Push, email, SMS preferences',
          onTap: () => context.push('/settings/notifications'),
        ),
        _CategoryTile(
          icon: Icons.palette_outlined,
          title: 'Appearance',
          subtitle: 'Theme, font size, display',
          onTap: () => context.push('/settings/appearance'),
        ),
        _CategoryTile(
          icon: Icons.lock_outline,
          title: 'Security',
          subtitle: 'Password, 2FA, sessions',
          onTap: () => context.push('/settings/security'),
        ),
        _CategoryTile(
          icon: Icons.privacy_tip_outlined,
          title: 'Privacy',
          subtitle: 'Data sharing, visibility',
          onTap: () => context.push('/settings/privacy'),
        ),
        _CategoryTile(
          icon: Icons.language,
          title: 'Language & Region',
          subtitle: 'Language, timezone, format',
          onTap: () => context.push('/settings/language'),
        ),
        _CategoryTile(
          icon: Icons.accessibility_new,
          title: 'Accessibility',
          subtitle: 'Screen reader, contrast',
          onTap: () => context.push('/settings/accessibility'),
        ),
        _CategoryTile(
          icon: Icons.storage,
          title: 'Data & Storage',
          subtitle: 'Cache, downloads, backup',
          onTap: () => context.push('/settings/storage'),
        ),
        _CategoryTile(
          icon: Icons.help_outline,
          title: 'Help & Support',
          subtitle: 'FAQs, contact, feedback',
          onTap: () => context.push('/settings/help'),
        ),
        _CategoryTile(
          icon: Icons.info_outline,
          title: 'About',
          subtitle: 'Version, licenses, terms',
          onTap: () => context.push('/settings/about'),
        ),
      ],
    );
  }

  Widget _buildSettingsContent(BuildContext context) {
    final theme = Theme.of(context);
    final profile = ref.watch(currentUserProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Quick Settings Section
        _SettingsSection(
          title: 'Quick Settings',
          children: [
            SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: const Text('Use dark theme'),
              value: theme.brightness == Brightness.dark,
              onChanged: (value) {
                // Toggle theme
              },
              secondary: const Icon(Icons.dark_mode),
            ),
            SwitchListTile(
              title: const Text('Notifications'),
              subtitle: const Text('Receive push notifications'),
              value: true, // Default value as settings field doesn't exist
              onChanged: (value) {
                // Toggle notifications
              },
              secondary: const Icon(Icons.notifications),
            ),
            SwitchListTile(
              title: const Text('Email Updates'),
              subtitle: const Text('Receive email updates'),
              value: true, // Default value as settings field doesn't exist
              onChanged: (value) {
                // Toggle email updates
              },
              secondary: const Icon(Icons.email),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Account Section
        _SettingsSection(
          title: 'Account',
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              subtitle: Text(profile?.email ?? 'Not logged in'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => context.push('/profile'),
            ),
            ListTile(
              leading: const Icon(Icons.security),
              title: const Text('Security'),
              subtitle: const Text('Password, 2FA, biometrics'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => context.push('/settings/security'),
            ),
            ListTile(
              leading: const Icon(Icons.devices),
              title: const Text('Sessions'),
              subtitle: const Text('Manage active sessions'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => context.push('/settings/sessions'),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Preferences Section
        _SettingsSection(
          title: 'Preferences',
          children: [
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Language'),
              subtitle: Text(profile?.locale ?? 'English'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showLanguageDialog(context),
            ),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Timezone'),
              subtitle: Text(profile?.timezone ?? 'UTC'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showTimezoneDialog(context),
            ),
            ListTile(
              leading: const Icon(Icons.format_paint),
              title: const Text('Theme'),
              subtitle: const Text('System'), // Default theme value
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showThemeDialog(context),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Data & Privacy Section
        _SettingsSection(
          title: 'Data & Privacy',
          children: [
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Download My Data'),
              subtitle: const Text('Get a copy of your data'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _requestDataDownload(context),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Clear Cache'),
              subtitle: const Text('Free up storage space'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _clearCache(context),
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever),
              title: const Text('Delete Account'),
              subtitle: const Text('Permanently delete your account'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showDeleteAccountDialog(context),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Support Section
        _SettingsSection(
          title: 'Support',
          children: [
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Help Center'),
              subtitle: const Text('Get help and support'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => context.push('/help'),
            ),
            ListTile(
              leading: const Icon(Icons.feedback),
              title: const Text('Send Feedback'),
              subtitle: const Text('Report issues or suggestions'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showFeedbackDialog(context),
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Terms & Privacy'),
              subtitle: const Text('Legal documents'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => context.push('/legal'),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Sign Out Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ElevatedButton.icon(
            onPressed: () => _signOut(context),
            icon: const Icon(Icons.logout),
            label: const Text('Sign Out'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Version Info
        Center(
          child: Text(
            'Version 1.0.0 (Build 100)',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ),

        const SizedBox(height: 32),
      ],
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile(
              title: const Text('English'),
              value: 'en',
              groupValue: 'en',
              onChanged: (value) {
                Navigator.pop(context);
              },
            ),
            RadioListTile(
              title: const Text('Spanish'),
              value: 'es',
              groupValue: 'en',
              onChanged: (value) {
                Navigator.pop(context);
              },
            ),
            RadioListTile(
              title: const Text('French'),
              value: 'fr',
              groupValue: 'en',
              onChanged: (value) {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showTimezoneDialog(BuildContext context) {
    // Show timezone picker
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile(
              title: const Text('System'),
              value: 'system',
              groupValue: 'system',
              onChanged: (value) {
                Navigator.pop(context);
              },
            ),
            RadioListTile(
              title: const Text('Light'),
              value: 'light',
              groupValue: 'system',
              onChanged: (value) {
                Navigator.pop(context);
              },
            ),
            RadioListTile(
              title: const Text('Dark'),
              value: 'dark',
              groupValue: 'system',
              onChanged: (value) {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _requestDataDownload(BuildContext context) {
    // Request data download
  }

  void _clearCache(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('Are you sure you want to clear the cache?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Clear cache
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Delete account
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    // Show feedback dialog
  }

  void _signOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authStateProvider.notifier).logout();
              context.go('/login');
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(title, style: theme.textTheme.titleMedium),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Card(child: Column(children: children)),
      ],
    );
  }
}
