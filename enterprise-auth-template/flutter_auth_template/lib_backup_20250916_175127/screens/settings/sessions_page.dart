import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../widgets/app_bars/custom_app_bars.dart';
import '../../widgets/dialog_components.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/shimmer_loading.dart';

class SessionsPage extends ConsumerStatefulWidget {
  const SessionsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<SessionsPage> createState() => _SessionsPageState();
}

class _SessionsPageState extends ConsumerState<SessionsPage> {
  List<SessionInfo> _sessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() => _isLoading = true);

    // Simulate loading sessions
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _sessions = [
        SessionInfo(
          id: 'session_current',
          device: 'iPhone 14 Pro',
          deviceType: DeviceType.mobile,
          location: 'San Francisco, CA',
          ipAddress: '192.168.1.1',
          browser: 'Safari',
          os: 'iOS 17.0',
          lastActive: DateTime.now(),
          isCurrent: true,
        ),
        SessionInfo(
          id: 'session_2',
          device: 'MacBook Pro',
          deviceType: DeviceType.desktop,
          location: 'San Francisco, CA',
          ipAddress: '192.168.1.2',
          browser: 'Chrome',
          os: 'macOS Sonoma',
          lastActive: DateTime.now().subtract(const Duration(hours: 2)),
          isCurrent: false,
        ),
        SessionInfo(
          id: 'session_3',
          device: 'iPad Air',
          deviceType: DeviceType.tablet,
          location: 'New York, NY',
          ipAddress: '10.0.0.1',
          browser: 'Safari',
          os: 'iPadOS 17.0',
          lastActive: DateTime.now().subtract(const Duration(days: 1)),
          isCurrent: false,
        ),
        SessionInfo(
          id: 'session_4',
          device: 'Windows PC',
          deviceType: DeviceType.desktop,
          location: 'Los Angeles, CA',
          ipAddress: '172.16.0.1',
          browser: 'Edge',
          os: 'Windows 11',
          lastActive: DateTime.now().subtract(const Duration(days: 3)),
          isCurrent: false,
        ),
      ];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Active Sessions',
        centerTitle: true,
        actions: [
          if (_sessions.length > 1)
            TextButton(
              onPressed: () => _terminateAllSessions(context),
              child: Text(
                'End All',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _sessions.isEmpty
          ? _buildEmptyState()
          : _buildSessionsList(context),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ShimmerLoading(
            isLoading: true,
            child: Card(
              child: Container(
                height: 120,
                padding: const EdgeInsets.all(16),
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: EmptyStates.noItems(
        itemType: 'active sessions',
        onAdd: () => _loadSessions(),
      ),
    );
  }

  Widget _buildSessionsList(BuildContext context) {
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: _loadSessions,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Security Info Card
          Card(
            color: theme.colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'These devices are currently logged into your account. If you see an unfamiliar device, end its session immediately.',
                      style: TextStyle(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Current Session
          Text(
            'Current Session',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildSessionCard(context, _sessions.firstWhere((s) => s.isCurrent)),

          if (_sessions.where((s) => !s.isCurrent).isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Other Sessions',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ..._sessions
                .where((s) => !s.isCurrent)
                .map((session) => _buildSessionCard(context, session)),
          ],
        ],
      ),
    );
  }

  Widget _buildSessionCard(BuildContext context, SessionInfo session) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, yyyy h:mm a');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showSessionDetails(context, session),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Device Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getDeviceIcon(session.deviceType),
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Device Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              session.device,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (session.isCurrent) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Current',
                                  style: TextStyle(
                                    color: theme.colorScheme.onPrimary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${session.browser} • ${session.os}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Action Button
                  if (!session.isCurrent)
                    IconButton(
                      icon: Icon(Icons.close, color: theme.colorScheme.error),
                      onPressed: () => _terminateSession(context, session),
                    ),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),

              // Session Details
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      context,
                      icon: Icons.location_on_outlined,
                      label: 'Location',
                      value: session.location,
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      context,
                      icon: Icons.router_outlined,
                      label: 'IP Address',
                      value: session.ipAddress,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildDetailItem(
                context,
                icon: Icons.access_time,
                label: 'Last Active',
                value: _getLastActiveText(session.lastActive),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              Text(value, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getDeviceIcon(DeviceType type) {
    switch (type) {
      case DeviceType.mobile:
        return Icons.phone_iphone;
      case DeviceType.tablet:
        return Icons.tablet_mac;
      case DeviceType.desktop:
        return Icons.computer;
      default:
        return Icons.devices;
    }
  }

  String _getLastActiveText(DateTime lastActive) {
    final now = DateTime.now();
    final difference = now.difference(lastActive);

    if (difference.inMinutes < 1) {
      return 'Active now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM d, yyyy').format(lastActive);
    }
  }

  void _showSessionDetails(BuildContext context, SessionInfo session) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _SessionDetailsSheet(
        session: session,
        onTerminate: () {
          Navigator.pop(context);
          _terminateSession(context, session);
        },
      ),
    );
  }

  void _terminateSession(BuildContext context, SessionInfo session) async {
    final confirmed = await DialogUtils.showConfirmationDialog(
      context: context,
      title: 'End Session',
      message:
          'Are you sure you want to end this session? The device will be logged out.',
      confirmText: 'End Session',
      confirmColor: Theme.of(context).colorScheme.error,
    );

    if (confirmed == true) {
      setState(() {
        _sessions.removeWhere((s) => s.id == session.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session ended successfully')),
      );
    }
  }

  void _terminateAllSessions(BuildContext context) async {
    final confirmed = await DialogUtils.showConfirmationDialog(
      context: context,
      title: 'End All Other Sessions',
      message:
          'This will log you out of all devices except the current one. Continue?',
      confirmText: 'End All',
      confirmColor: Theme.of(context).colorScheme.error,
    );

    if (confirmed == true) {
      setState(() {
        _sessions.removeWhere((s) => !s.isCurrent);
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('All other sessions ended')));
    }
  }
}

class _SessionDetailsSheet extends StatelessWidget {
  final SessionInfo session;
  final VoidCallback onTerminate;

  const _SessionDetailsSheet({
    required this.session,
    required this.onTerminate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMMM d, yyyy h:mm a');

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getDeviceIcon(session.deviceType),
                size: 32,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(session.device, style: theme.textTheme.titleLarge),
                    if (session.isCurrent)
                      Text(
                        'Current Session',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          _buildDetailRow('Browser', session.browser),
          _buildDetailRow('Operating System', session.os),
          _buildDetailRow('Location', session.location),
          _buildDetailRow('IP Address', session.ipAddress),
          _buildDetailRow('Last Active', dateFormat.format(session.lastActive)),
          _buildDetailRow('Session ID', session.id, isMonospace: true),

          if (!session.isCurrent) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onTerminate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: theme.colorScheme.onError,
                ),
                child: const Text('End This Session'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isMonospace = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: isMonospace ? 'monospace' : null,
                fontSize: isMonospace ? 12 : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getDeviceIcon(DeviceType type) {
    switch (type) {
      case DeviceType.mobile:
        return Icons.phone_iphone;
      case DeviceType.tablet:
        return Icons.tablet_mac;
      case DeviceType.desktop:
        return Icons.computer;
      default:
        return Icons.devices;
    }
  }
}

// Models
enum DeviceType { mobile, tablet, desktop, unknown }

class SessionInfo {
  final String id;
  final String device;
  final DeviceType deviceType;
  final String location;
  final String ipAddress;
  final String browser;
  final String os;
  final DateTime lastActive;
  final bool isCurrent;

  const SessionInfo({
    required this.id,
    required this.device,
    required this.deviceType,
    required this.location,
    required this.ipAddress,
    required this.browser,
    required this.os,
    required this.lastActive,
    required this.isCurrent,
  });
}
