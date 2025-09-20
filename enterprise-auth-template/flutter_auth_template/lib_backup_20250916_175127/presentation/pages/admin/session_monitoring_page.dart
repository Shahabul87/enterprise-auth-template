import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/analytics_models.dart';
import '../../../data/services/analytics_api_service.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/charts/line_chart_widget.dart';
import '../../widgets/charts/pie_chart_widget.dart';

final analyticsApiServiceProvider = Provider((ref) => AnalyticsApiService());

class SessionMonitoringPage extends ConsumerStatefulWidget {
  const SessionMonitoringPage({super.key});

  @override
  ConsumerState<SessionMonitoringPage> createState() => _SessionMonitoringPageState();
}

class _SessionMonitoringPageState extends ConsumerState<SessionMonitoringPage> 
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<UserSessionDetails> _activeSessions = [];
  List<SessionSecurityAlert> _securityAlerts = [];
  SessionAnalytics? _sessionAnalytics;
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  SessionStatus? _selectedStatusFilter;
  DateTime? _selectedDateFilter;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        service.getUserSessions(),
        service.getSessionSecurityAlerts(),
        service.getSessionAnalytics(),
      ]);

      if (mounted) {
        setState(() {
          _activeSessions = results[0] as List<UserSessionDetails>;
          _securityAlerts = results[1] as List<SessionSecurityAlert>;
          _sessionAnalytics = results[2] as SessionAnalytics;
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
        title: const Text('Session Monitoring'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active Sessions'),
            Tab(text: 'Security Alerts'),
            Tab(text: 'Analytics'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildActiveSessionsTab(),
          _buildSecurityAlertsTab(),
          _buildAnalyticsTab(),
        ],
      ),
    );
  }

  Widget _buildActiveSessionsTab() {
    final filteredSessions = _activeSessions.where((session) {
      final matchesSearch = _searchQuery.isEmpty ||
          session.userEmail.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          session.ipAddress.contains(_searchQuery) ||
          session.deviceInfo.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesStatus = _selectedStatusFilter == null ||
          session.status == _selectedStatusFilter;
      
      final matchesDate = _selectedDateFilter == null ||
          session.lastActivity.isAfter(_selectedDateFilter!) ||
          session.createdAt.isAfter(_selectedDateFilter!);
      
      return matchesSearch && matchesStatus && matchesDate;
    }).toList();

    return Column(
      children: [
        _buildSessionFilters(),
        _buildSessionsStats(),
        Expanded(
          child: filteredSessions.isEmpty
              ? const Center(child: Text('No active sessions found'))
              : ListView.builder(
                  itemCount: filteredSessions.length,
                  itemBuilder: (context, index) {
                    final session = filteredSessions[index];
                    return _buildSessionCard(session);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSessionFilters() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              hintText: 'Search by user, IP, or device...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<SessionStatus>(
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedStatusFilter,
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Status'),
                    ),
                    ...SessionStatus.values.map(
                      (status) => DropdownMenuItem(
                        value: status,
                        child: Text(status.displayName),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedStatusFilter = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.date_range),
                  label: Text(_selectedDateFilter == null 
                      ? 'Filter by Date' 
                      : 'Since ${_formatDate(_selectedDateFilter!)}'),
                  onPressed: _selectDateFilter,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSessionsStats() {
    final activeCount = _activeSessions.where((s) => s.status == SessionStatus.active).length;
    final suspiciousCount = _activeSessions.where((s) => s.isSuspicious).length;
    final mobileCount = _activeSessions.where((s) => s.deviceType == DeviceType.mobile).length;
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard('Active', activeCount.toString(), Colors.green),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard('Suspicious', suspiciousCount.toString(), Colors.red),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard('Mobile', mobileCount.toString(), Colors.blue),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard('Total', _activeSessions.length.toString(), Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(UserSessionDetails session) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ExpansionTile(
        leading: Stack(
          children: [
            CircleAvatar(
              backgroundColor: session.status.color,
              child: Icon(
                _getDeviceIcon(session.deviceType),
                color: Colors.white,
              ),
            ),
            if (session.isSuspicious)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning,
                    size: 8,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
        title: Text(session.userEmail),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${session.ipAddress} • ${session.location}'),
            Text('${session.deviceInfo}'),
            Text('Last active: ${_formatTimestamp(session.lastActivity)}'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (action) => _handleSessionAction(action, session),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'details',
              child: Row(
                children: [
                  Icon(Icons.info),
                  SizedBox(width: 8),
                  Text('Details'),
                ],
              ),
            ),
            if (session.status == SessionStatus.active)
              const PopupMenuItem(
                value: 'terminate',
                child: Row(
                  children: [
                    Icon(Icons.exit_to_app, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Terminate', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            if (session.isSuspicious)
              const PopupMenuItem(
                value: 'block',
                child: Row(
                  children: [
                    Icon(Icons.block, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Block IP', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailItem('Session ID', session.sessionId),
                    ),
                    Expanded(
                      child: _buildDetailItem('Duration', _formatDuration(session.duration)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailItem('User Agent', session.userAgent),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailItem('Created', _formatTimestamp(session.createdAt)),
                    ),
                    Expanded(
                      child: _buildDetailItem('Requests', session.requestCount.toString()),
                    ),
                  ],
                ),
                if (session.securityFlags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Security Flags:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    children: session.securityFlags.map((flag) => Chip(
                      label: Text(flag, style: const TextStyle(fontSize: 10)),
                      backgroundColor: Colors.red.withOpacity(0.2),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    )).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildSecurityAlertsTab() {
    if (_securityAlerts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.security, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No security alerts'),
            Text('All sessions appear normal'),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _securityAlerts.length,
      itemBuilder: (context, index) {
        final alert = _securityAlerts[index];
        return _buildSecurityAlertCard(alert);
      },
    );
  }

  Widget _buildSecurityAlertCard(SessionSecurityAlert alert) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: alert.severity.color,
          child: Icon(
            _getAlertIcon(alert.type),
            color: Colors.white,
          ),
        ),
        title: Text(alert.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(alert.description),
            const SizedBox(height: 4),
            Text('User: ${alert.userEmail}'),
            Text('IP: ${alert.ipAddress}'),
            Text('${_formatTimestamp(alert.timestamp)}'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (action) => _handleAlertAction(action, alert),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'investigate',
              child: Row(
                children: [
                  Icon(Icons.search),
                  SizedBox(width: 8),
                  Text('Investigate'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'dismiss',
              child: Row(
                children: [
                  Icon(Icons.check),
                  SizedBox(width: 8),
                  Text('Dismiss'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'block',
              child: Row(
                children: [
                  Icon(Icons.block, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Block IP', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    if (_sessionAnalytics == null) {
      return const Center(child: Text('No analytics data available'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Session Overview',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildAnalyticsKPIs(),
          const SizedBox(height: 24),
          const Text(
            'Session Trends',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: LineChartWidget(
              data: _sessionAnalytics!.sessionTrend.asMap().entries.map((entry) {
                return ChartDataPoint(
                  x: entry.key.toDouble(),
                  y: entry.value.toDouble(),
                );
              }).toList(),
              title: 'Daily Active Sessions',
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Device Types',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 200,
                      child: PieChartWidget(
                        data: _sessionAnalytics!.deviceTypeDistribution.entries.map((entry) {
                          return PieChartData(
                            label: entry.key,
                            value: entry.value.toDouble(),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Geographic Distribution',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 200,
                      child: PieChartWidget(
                        data: _sessionAnalytics!.geographicDistribution.entries.map((entry) {
                          return PieChartData(
                            label: entry.key,
                            value: entry.value.toDouble(),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsKPIs() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildKPICard(
          'Total Sessions',
          _sessionAnalytics!.totalSessions.toString(),
          Icons.people,
          Colors.blue,
        ),
        _buildKPICard(
          'Avg Duration',
          '${_sessionAnalytics!.averageDuration.toStringAsFixed(1)}m',
          Icons.access_time,
          Colors.green,
        ),
        _buildKPICard(
          'Suspicious',
          _sessionAnalytics!.suspiciousActivities.toString(),
          Icons.warning,
          Colors.red,
        ),
        _buildKPICard(
          'Unique IPs',
          _sessionAnalytics!.uniqueIpAddresses.toString(),
          Icons.public,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildKPICard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _selectDateFilter() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateFilter ?? DateTime.now().subtract(const Duration(days: 7)),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _selectedDateFilter = date;
      });
    }
  }

  void _handleSessionAction(String action, UserSessionDetails session) async {
    final service = ref.read(analyticsApiServiceProvider);
    
    try {
      switch (action) {
        case 'details':
          _showSessionDetails(session);
          break;
        case 'terminate':
          final confirmed = await _showConfirmationDialog(
            'Terminate Session',
            'Are you sure you want to terminate this session?',
          );
          if (confirmed) {
            await service.terminateSession(session.sessionId);
            _loadData();
          }
          break;
        case 'block':
          final confirmed = await _showConfirmationDialog(
            'Block IP Address',
            'Are you sure you want to block IP ${session.ipAddress}?',
          );
          if (confirmed) {
            await service.blockIpAddress(session.ipAddress);
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

  void _handleAlertAction(String action, SessionSecurityAlert alert) async {
    final service = ref.read(analyticsApiServiceProvider);
    
    try {
      switch (action) {
        case 'investigate':
          _showAlertDetails(alert);
          break;
        case 'dismiss':
          await service.dismissSecurityAlert(alert.id);
          _loadData();
          break;
        case 'block':
          final confirmed = await _showConfirmationDialog(
            'Block IP Address',
            'Are you sure you want to block IP ${alert.ipAddress}?',
          );
          if (confirmed) {
            await service.blockIpAddress(alert.ipAddress);
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

  void _showSessionDetails(UserSessionDetails session) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Session Details'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('User', session.userEmail),
                _buildDetailRow('Session ID', session.sessionId),
                _buildDetailRow('IP Address', session.ipAddress),
                _buildDetailRow('Location', session.location),
                _buildDetailRow('Device', session.deviceInfo),
                _buildDetailRow('User Agent', session.userAgent),
                _buildDetailRow('Status', session.status.displayName),
                _buildDetailRow('Created', _formatTimestamp(session.createdAt)),
                _buildDetailRow('Last Activity', _formatTimestamp(session.lastActivity)),
                _buildDetailRow('Duration', _formatDuration(session.duration)),
                _buildDetailRow('Requests', session.requestCount.toString()),
                if (session.securityFlags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Security Flags:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...session.securityFlags.map((flag) => Text('• $flag')),
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

  void _showAlertDetails(SessionSecurityAlert alert) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Security Alert: ${alert.title}'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('Type', alert.type.displayName),
                _buildDetailRow('Severity', alert.severity.displayName),
                _buildDetailRow('Description', alert.description),
                _buildDetailRow('User', alert.userEmail),
                _buildDetailRow('IP Address', alert.ipAddress),
                _buildDetailRow('Timestamp', _formatTimestamp(alert.timestamp)),
                if (alert.metadata.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Additional Details:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...alert.metadata.entries.map((entry) => 
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

  Future<bool> _showConfirmationDialog(String title, String content) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Confirm'),
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
            width: 120,
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

  IconData _getDeviceIcon(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.desktop:
        return Icons.computer;
      case DeviceType.mobile:
        return Icons.phone_android;
      case DeviceType.tablet:
        return Icons.tablet;
      case DeviceType.unknown:
        return Icons.device_unknown;
    }
  }

  IconData _getAlertIcon(SecurityAlertType type) {
    switch (type) {
      case SecurityAlertType.suspiciousLocation:
        return Icons.location_on;
      case SecurityAlertType.multipleFailedAttempts:
        return Icons.lock;
      case SecurityAlertType.unusualActivity:
        return Icons.warning;
      case SecurityAlertType.concurrentSessions:
        return Icons.people;
      case SecurityAlertType.unknownDevice:
        return Icons.device_unknown;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '${minutes}m';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return remainingMinutes == 0 ? '${hours}h' : '${hours}h ${remainingMinutes}m';
    }
  }
}