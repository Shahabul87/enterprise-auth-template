import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/analytics_models.dart';
import '../../../data/services/analytics_api_service.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';

final analyticsApiServiceProvider = Provider((ref) => AnalyticsApiService());

class AdvancedSecuritySettingsPage extends ConsumerStatefulWidget {
  const AdvancedSecuritySettingsPage({super.key});

  @override
  ConsumerState<AdvancedSecuritySettingsPage> createState() => _AdvancedSecuritySettingsPageState();
}

class _AdvancedSecuritySettingsPageState extends ConsumerState<AdvancedSecuritySettingsPage> 
    with TickerProviderStateMixin {
  late TabController _tabController;
  SecurityConfiguration? _securityConfig;
  List<IpBlockRule> _ipBlockRules = [];
  List<RateLimitRule> _rateLimitRules = [];
  List<SecurityEvent> _securityEvents = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final service = ref.read(analyticsApiServiceProvider);
      final results = await Future.wait([
        service.getSecurityConfiguration(),
        service.getIpBlockRules(),
        service.getRateLimitRules(),
        service.getSecurityEvents(),
      ]);

      if (mounted) {
        setState(() {
          _securityConfig = results[0] as SecurityConfiguration;
          _ipBlockRules = results[1] as List<IpBlockRule>;
          _rateLimitRules = results[2] as List<RateLimitRule>;
          _securityEvents = results[3] as List<SecurityEvent>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: LoadingWidget()),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: ErrorDisplayWidget(
          error: _error!,
          onRetry: _loadData,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Security Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveConfiguration,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'General Security'),
            Tab(text: 'IP Access Control'),
            Tab(text: 'Rate Limiting'),
            Tab(text: 'Security Events'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGeneralSecurityTab(),
          _buildIpAccessControlTab(),
          _buildRateLimitingTab(),
          _buildSecurityEventsTab(),
        ],
      ),
    );
  }

  Widget _buildGeneralSecurityTab() {
    if (_securityConfig == null) {
      return const Center(child: Text('No security configuration found'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Authentication Security'),
          _buildSecurityCard([
            _buildSwitchTile(
              'Require Two-Factor Authentication',
              'Force all users to enable 2FA',
              _securityConfig!.requireTwoFactor,
              (value) => setState(() => _securityConfig = _securityConfig!.copyWith(requireTwoFactor: value)),
            ),
            _buildSwitchTile(
              'Account Lockout',
              'Lock accounts after failed attempts',
              _securityConfig!.accountLockoutEnabled,
              (value) => setState(() => _securityConfig = _securityConfig!.copyWith(accountLockoutEnabled: value)),
            ),
            _buildSliderTile(
              'Max Failed Attempts',
              'Number of attempts before lockout',
              _securityConfig!.maxFailedAttempts.toDouble(),
              1, 10,
              (value) => setState(() => _securityConfig = _securityConfig!.copyWith(maxFailedAttempts: value.round())),
            ),
            _buildSliderTile(
              'Lockout Duration (minutes)',
              'How long accounts remain locked',
              _securityConfig!.lockoutDurationMinutes.toDouble(),
              5, 1440,
              (value) => setState(() => _securityConfig = _securityConfig!.copyWith(lockoutDurationMinutes: value.round())),
            ),
          ]),

          const SizedBox(height: 24),
          _buildSectionHeader('Session Security'),
          _buildSecurityCard([
            _buildSliderTile(
              'Session Timeout (hours)',
              'Inactive session timeout',
              _securityConfig!.sessionTimeoutHours.toDouble(),
              1, 24,
              (value) => setState(() => _securityConfig = _securityConfig!.copyWith(sessionTimeoutHours: value.round())),
            ),
            _buildSwitchTile(
              'Concurrent Session Limit',
              'Limit simultaneous user sessions',
              _securityConfig!.concurrentSessionLimitEnabled,
              (value) => setState(() => _securityConfig = _securityConfig!.copyWith(concurrentSessionLimitEnabled: value)),
            ),
            if (_securityConfig!.concurrentSessionLimitEnabled)
              _buildSliderTile(
                'Max Concurrent Sessions',
                'Maximum sessions per user',
                _securityConfig!.maxConcurrentSessions.toDouble(),
                1, 10,
                (value) => setState(() => _securityConfig = _securityConfig!.copyWith(maxConcurrentSessions: value.round())),
              ),
            _buildSwitchTile(
              'Detect Suspicious Locations',
              'Alert on logins from new locations',
              _securityConfig!.detectSuspiciousLocations,
              (value) => setState(() => _securityConfig = _securityConfig!.copyWith(detectSuspiciousLocations: value)),
            ),
          ]),

          const SizedBox(height: 24),
          _buildSectionHeader('Password Security'),
          _buildSecurityCard([
            _buildSliderTile(
              'Minimum Password Length',
              'Required password length',
              _securityConfig!.passwordMinLength.toDouble(),
              8, 32,
              (value) => setState(() => _securityConfig = _securityConfig!.copyWith(passwordMinLength: value.round())),
            ),
            _buildSwitchTile(
              'Require Special Characters',
              'Password must contain symbols',
              _securityConfig!.passwordRequireSpecial,
              (value) => setState(() => _securityConfig = _securityConfig!.copyWith(passwordRequireSpecial: value)),
            ),
            _buildSwitchTile(
              'Require Numbers',
              'Password must contain numbers',
              _securityConfig!.passwordRequireNumbers,
              (value) => setState(() => _securityConfig = _securityConfig!.copyWith(passwordRequireNumbers: value)),
            ),
            _buildSwitchTile(
              'Require Mixed Case',
              'Password must have upper and lower case',
              _securityConfig!.passwordRequireMixedCase,
              (value) => setState(() => _securityConfig = _securityConfig!.copyWith(passwordRequireMixedCase: value)),
            ),
            _buildSliderTile(
              'Password Expiry (days)',
              'Force password changes (0 = never)',
              _securityConfig!.passwordExpiryDays.toDouble(),
              0, 365,
              (value) => setState(() => _securityConfig = _securityConfig!.copyWith(passwordExpiryDays: value.round())),
            ),
          ]),

          const SizedBox(height: 24),
          _buildSectionHeader('API Security'),
          _buildSecurityCard([
            _buildSwitchTile(
              'API Key Required',
              'Require API keys for all requests',
              _securityConfig!.apiKeyRequired,
              (value) => setState(() => _securityConfig = _securityConfig!.copyWith(apiKeyRequired: value)),
            ),
            _buildSwitchTile(
              'CORS Restrictions',
              'Enable Cross-Origin restrictions',
              _securityConfig!.corsEnabled,
              (value) => setState(() => _securityConfig = _securityConfig!.copyWith(corsEnabled: value)),
            ),
            _buildSwitchTile(
              'Request Signing',
              'Require request signature verification',
              _securityConfig!.requireRequestSigning,
              (value) => setState(() => _securityConfig = _securityConfig!.copyWith(requireRequestSigning: value)),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildIpAccessControlTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'IP Access Rules (${_ipBlockRules.length})',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Rule'),
                onPressed: _showAddIpRuleDialog,
              ),
            ],
          ),
        ),
        Expanded(
          child: _ipBlockRules.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.security, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No IP access rules configured'),
                      Text('Add rules to control access by IP address'),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _ipBlockRules.length,
                  itemBuilder: (context, index) {
                    final rule = _ipBlockRules[index];
                    return _buildIpRuleCard(rule);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildIpRuleCard(IpBlockRule rule) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: rule.type == IpRuleType.allow ? Colors.green : Colors.red,
          child: Icon(
            rule.type == IpRuleType.allow ? Icons.check : Icons.block,
            color: Colors.white,
          ),
        ),
        title: Text(rule.ipAddress),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${rule.type.displayName}'),
            if (rule.description.isNotEmpty) Text(rule.description),
            Text('Created: ${_formatDateTime(rule.createdAt)}'),
            if (rule.expiresAt != null)
              Text('Expires: ${_formatDateTime(rule.expiresAt!)}'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (action) => _handleIpRuleAction(action, rule),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRateLimitingTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Rate Limit Rules (${_rateLimitRules.length})',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Rule'),
                onPressed: _showAddRateLimitDialog,
              ),
            ],
          ),
        ),
        Expanded(
          child: _rateLimitRules.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.speed, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No rate limit rules configured'),
                      Text('Add rules to prevent abuse and ensure fair usage'),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _rateLimitRules.length,
                  itemBuilder: (context, index) {
                    final rule = _rateLimitRules[index];
                    return _buildRateLimitCard(rule);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildRateLimitCard(RateLimitRule rule) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: rule.isActive ? Colors.green : Colors.grey,
          child: Icon(
            rule.isActive ? Icons.speed : Icons.pause,
            color: Colors.white,
          ),
        ),
        title: Text(rule.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${rule.requestLimit} requests per ${rule.windowDuration} seconds'),
            Text('Endpoint: ${rule.endpoint}'),
            if (rule.description.isNotEmpty) Text(rule.description),
            Text('Created: ${_formatDateTime(rule.createdAt)}'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (action) => _handleRateLimitAction(action, rule),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: rule.isActive ? 'disable' : 'enable',
              child: Row(
                children: [
                  Icon(rule.isActive ? Icons.pause : Icons.play_arrow),
                  const SizedBox(width: 8),
                  Text(rule.isActive ? 'Disable' : 'Enable'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityEventsTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Recent Security Events (${_securityEvents.length})',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: _showEventFilters,
              ),
            ],
          ),
        ),
        Expanded(
          child: _securityEvents.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_note, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No security events recorded'),
                      Text('Events will appear here as they occur'),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _securityEvents.length,
                  itemBuilder: (context, index) {
                    final event = _securityEvents[index];
                    return _buildSecurityEventCard(event);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSecurityEventCard(SecurityEvent event) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: event.severity.color,
          child: Icon(
            _getEventIcon(event.type),
            color: Colors.white,
          ),
        ),
        title: Text(event.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(event.description),
            Text('IP: ${event.ipAddress}'),
            if (event.userEmail.isNotEmpty) Text('User: ${event.userEmail}'),
            Text(_formatDateTime(event.timestamp)),
          ],
        ),
        trailing: event.severity == SecurityEventSeverity.high
            ? const Icon(Icons.priority_high, color: Colors.red)
            : null,
        onTap: () => _showEventDetails(event),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSecurityCard(List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildSliderTile(
    String title,
    String subtitle,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      children: [
        ListTile(
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: Text(value.round().toString()),
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: (max - min).round(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  void _showAddIpRuleDialog() {
    showDialog(
      context: context,
      builder: (context) => _IpRuleDialog(
        onSave: (rule) async {
          try {
            await ref.read(analyticsApiServiceProvider).createIpBlockRule(rule);
            _loadData();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('IP rule created successfully')),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${e.toString()}')),
              );
            }
          }
        },
      ),
    );
  }

  void _showAddRateLimitDialog() {
    showDialog(
      context: context,
      builder: (context) => _RateLimitDialog(
        onSave: (rule) async {
          try {
            await ref.read(analyticsApiServiceProvider).createRateLimitRule(rule);
            _loadData();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Rate limit rule created successfully')),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${e.toString()}')),
              );
            }
          }
        },
      ),
    );
  }

  void _showEventFilters() {
    // Implementation for event filtering
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Security Events'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Filter options will be implemented here'),
            const SizedBox(height: 16),
            const Text('Available filters:'),
            const Text('• Event type'),
            const Text('• Severity level'),
            const Text('• Date range'),
            const Text('• IP address'),
            const Text('• User email'),
          ],
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

  void _handleIpRuleAction(String action, IpBlockRule rule) async {
    final service = ref.read(analyticsApiServiceProvider);
    
    try {
      switch (action) {
        case 'edit':
          _showEditIpRuleDialog(rule);
          break;
        case 'delete':
          final confirmed = await _showDeleteConfirmation('IP rule');
          if (confirmed) {
            await service.deleteIpBlockRule(rule.id);
            _loadData();
          }
          break;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  void _handleRateLimitAction(String action, RateLimitRule rule) async {
    final service = ref.read(analyticsApiServiceProvider);
    
    try {
      switch (action) {
        case 'enable':
        case 'disable':
          final newRule = rule.copyWith(isActive: action == 'enable');
          await service.updateRateLimitRule(rule.id, newRule);
          _loadData();
          break;
        case 'edit':
          _showEditRateLimitDialog(rule);
          break;
        case 'delete':
          final confirmed = await _showDeleteConfirmation('rate limit rule');
          if (confirmed) {
            await service.deleteRateLimitRule(rule.id);
            _loadData();
          }
          break;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  void _showEditIpRuleDialog(IpBlockRule rule) {
    showDialog(
      context: context,
      builder: (context) => _IpRuleDialog(
        rule: rule,
        onSave: (updatedRule) async {
          try {
            await ref.read(analyticsApiServiceProvider).updateIpBlockRule(rule.id, updatedRule);
            _loadData();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('IP rule updated successfully')),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${e.toString()}')),
              );
            }
          }
        },
      ),
    );
  }

  void _showEditRateLimitDialog(RateLimitRule rule) {
    showDialog(
      context: context,
      builder: (context) => _RateLimitDialog(
        rule: rule,
        onSave: (updatedRule) async {
          try {
            await ref.read(analyticsApiServiceProvider).updateRateLimitRule(rule.id, updatedRule);
            _loadData();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Rate limit rule updated successfully')),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${e.toString()}')),
              );
            }
          }
        },
      ),
    );
  }

  void _showEventDetails(SecurityEvent event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Security Event: ${event.title}'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('Type', event.type.displayName),
                _buildDetailRow('Severity', event.severity.displayName),
                _buildDetailRow('Description', event.description),
                _buildDetailRow('IP Address', event.ipAddress),
                if (event.userEmail.isNotEmpty)
                  _buildDetailRow('User Email', event.userEmail),
                _buildDetailRow('Timestamp', _formatDateTime(event.timestamp)),
                if (event.metadata.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Additional Details:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...event.metadata.entries.map((entry) => 
                      Text('${entry.key}: ${entry.value}')),
                ],
              ],
            ),
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

  Future<bool> _showDeleteConfirmation(String itemType) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${itemType[0].toUpperCase()}${itemType.substring(1)}'),
        content: Text('Are you sure you want to delete this $itemType?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    ) ?? false;
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _saveConfiguration() async {
    if (_securityConfig == null) return;

    try {
      await ref.read(analyticsApiServiceProvider).updateSecurityConfiguration(_securityConfig!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Security configuration saved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving configuration: ${e.toString()}')),
        );
      }
    }
  }

  IconData _getEventIcon(SecurityEventType type) {
    switch (type) {
      case SecurityEventType.loginAttempt:
        return Icons.login;
      case SecurityEventType.passwordChange:
        return Icons.lock;
      case SecurityEventType.accountLocked:
        return Icons.lock_person;
      case SecurityEventType.suspiciousActivity:
        return Icons.warning;
      case SecurityEventType.apiKeyUsage:
        return Icons.vpn_key;
      case SecurityEventType.ipBlocked:
        return Icons.block;
      case SecurityEventType.rateLimitExceeded:
        return Icons.speed;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

// IP Rule Dialog
class _IpRuleDialog extends StatefulWidget {
  final IpBlockRule? rule;
  final Function(CreateIpBlockRuleRequest) onSave;

  const _IpRuleDialog({
    this.rule,
    required this.onSave,
  });

  @override
  State<_IpRuleDialog> createState() => _IpRuleDialogState();
}

class _IpRuleDialogState extends State<_IpRuleDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _ipController;
  late TextEditingController _descriptionController;
  IpRuleType _selectedType = IpRuleType.block;
  DateTime? _expiresAt;

  @override
  void initState() {
    super.initState();
    _ipController = TextEditingController(text: widget.rule?.ipAddress ?? '');
    _descriptionController = TextEditingController(text: widget.rule?.description ?? '');
    _selectedType = widget.rule?.type ?? IpRuleType.block;
    _expiresAt = widget.rule?.expiresAt;
  }

  @override
  void dispose() {
    _ipController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.rule == null ? 'Add IP Rule' : 'Edit IP Rule'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _ipController,
                decoration: const InputDecoration(
                  labelText: 'IP Address or CIDR',
                  border: OutlineInputBorder(),
                  hintText: '192.168.1.0/24 or 10.0.0.1',
                ),
                validator: (value) => value?.isEmpty ?? true ? 'IP address is required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<IpRuleType>(
                decoration: const InputDecoration(
                  labelText: 'Rule Type',
                  border: OutlineInputBorder(),
                ),
                value: _selectedType,
                items: IpRuleType.values.map(
                  (type) => DropdownMenuItem(
                    value: type,
                    child: Row(
                      children: [
                        Icon(
                          type == IpRuleType.allow ? Icons.check : Icons.block,
                          color: type == IpRuleType.allow ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(type.displayName),
                      ],
                    ),
                  ),
                ).toList(),
                onChanged: (value) => setState(() => _selectedType = value!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Expiration Date'),
                subtitle: _expiresAt != null 
                    ? Text('Expires: ${_formatDateTime(_expiresAt!)}')
                    : const Text('Never expires'),
                trailing: const Icon(Icons.date_range),
                onTap: _selectExpirationDate,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveRule,
          child: Text(widget.rule == null ? 'Create' : 'Save'),
        ),
      ],
    );
  }

  void _selectExpirationDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _expiresAt ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _expiresAt = date;
      });
    }
  }

  void _saveRule() {
    if (_formKey.currentState?.validate() ?? false) {
      final request = CreateIpBlockRuleRequest(
        ipAddress: _ipController.text,
        type: _selectedType,
        description: _descriptionController.text,
        expiresAt: _expiresAt,
      );
      widget.onSave(request);
      Navigator.of(context).pop();
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}

// Rate Limit Dialog
class _RateLimitDialog extends StatefulWidget {
  final RateLimitRule? rule;
  final Function(CreateRateLimitRuleRequest) onSave;

  const _RateLimitDialog({
    this.rule,
    required this.onSave,
  });

  @override
  State<_RateLimitDialog> createState() => _RateLimitDialogState();
}

class _RateLimitDialogState extends State<_RateLimitDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _endpointController;
  late TextEditingController _descriptionController;
  int _requestLimit = 100;
  int _windowDuration = 60;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.rule?.name ?? '');
    _endpointController = TextEditingController(text: widget.rule?.endpoint ?? '');
    _descriptionController = TextEditingController(text: widget.rule?.description ?? '');
    _requestLimit = widget.rule?.requestLimit ?? 100;
    _windowDuration = widget.rule?.windowDuration ?? 60;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _endpointController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.rule == null ? 'Add Rate Limit Rule' : 'Edit Rate Limit Rule'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Rule Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value?.isEmpty ?? true ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _endpointController,
                  decoration: const InputDecoration(
                    labelText: 'API Endpoint',
                    border: OutlineInputBorder(),
                    hintText: '/api/auth/login or * for all',
                  ),
                  validator: (value) => value?.isEmpty ?? true ? 'Endpoint is required' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Request Limit: $_requestLimit'),
                          Slider(
                            value: _requestLimit.toDouble(),
                            min: 1,
                            max: 1000,
                            divisions: 100,
                            onChanged: (value) => setState(() => _requestLimit = value.round()),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Window Duration: ${_windowDuration}s'),
                          Slider(
                            value: _windowDuration.toDouble(),
                            min: 1,
                            max: 3600,
                            divisions: 100,
                            onChanged: (value) => setState(() => _windowDuration = value.round()),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveRule,
          child: Text(widget.rule == null ? 'Create' : 'Save'),
        ),
      ],
    );
  }

  void _saveRule() {
    if (_formKey.currentState?.validate() ?? false) {
      final request = CreateRateLimitRuleRequest(
        name: _nameController.text,
        endpoint: _endpointController.text,
        requestLimit: _requestLimit,
        windowDuration: _windowDuration,
        description: _descriptionController.text,
      );
      widget.onSave(request);
      Navigator.of(context).pop();
    }
  }
}