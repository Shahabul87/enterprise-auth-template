import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/analytics_models.dart';
import '../../../data/services/analytics_api_service.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/charts/line_chart_widget.dart';
import '../../widgets/charts/pie_chart_widget.dart';

final analyticsApiServiceProvider = Provider((ref) =&gt; AnalyticsApiService());

class SessionMonitoringPage extends ConsumerStatefulWidget {
  const SessionMonitoringPage({super.key});

  @override
  ConsumerState&lt;SessionMonitoringPage&gt; createState() =&gt; _SessionMonitoringPageState();
}

class _SessionMonitoringPageState extends ConsumerState&lt;SessionMonitoringPage&gt; 
    with TickerProviderStateMixin {
  late TabController _tabController;
  List&lt;UserSessionDetails&gt; _activeSessions = [];
  List&lt;SessionSecurityAlert&gt; _securityAlerts = [];
  SessionAnalytics? _sessionAnalytics;
  bool _isLoading = true;
  String? _error;
  String _searchQuery = &apos;&apos;;
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

  Future&lt;void&gt; _loadData() async {
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
          _activeSessions = results[0] as List&lt;UserSessionDetails&gt;;
          _securityAlerts = results[1] as List&lt;SessionSecurityAlert&gt;;
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
        title: const Text(&apos;Session Monitoring&apos;),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: &apos;Active Sessions&apos;),
            Tab(text: &apos;Security Alerts&apos;),
            Tab(text: &apos;Analytics&apos;),
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
      
      return matchesSearch &amp;&amp; matchesStatus &amp;&amp; matchesDate;
    }).toList();

    return Column(
      children: [
        _buildSessionFilters(),
        _buildSessionsStats(),
        Expanded(
          child: filteredSessions.isEmpty
              ? const Center(child: Text(&apos;No active sessions found&apos;))
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
              hintText: &apos;Search by user, IP, or device...&apos;,
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
                child: DropdownButtonFormField&lt;SessionStatus&gt;(
                  decoration: const InputDecoration(
                    labelText: &apos;Status&apos;,
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedStatusFilter,
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text(&apos;All Status&apos;),
                    ),
                    ...SessionStatus.values.map(
                      (status) =&gt; DropdownMenuItem(
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
                      ? &apos;Filter by Date&apos; 
                      : &apos;Since ${_formatDate(_selectedDateFilter!)}&apos;),
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
    final activeCount = _activeSessions.where((s) =&gt; s.status == SessionStatus.active).length;
    final suspiciousCount = _activeSessions.where((s) =&gt; s.isSuspicious).length;
    final mobileCount = _activeSessions.where((s) =&gt; s.deviceType == DeviceType.mobile).length;
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(&apos;Active&apos;, activeCount.toString(), Colors.green),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(&apos;Suspicious&apos;, suspiciousCount.toString(), Colors.red),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(&apos;Mobile&apos;, mobileCount.toString(), Colors.blue),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(&apos;Total&apos;, _activeSessions.length.toString(), Colors.grey),
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
            Text(&apos;${session.ipAddress} • ${session.location}&apos;),
            Text(&apos;${session.deviceInfo}&apos;),
            Text(&apos;Last active: ${_formatTimestamp(session.lastActivity)}&apos;),
          ],
        ),
        trailing: PopupMenuButton&lt;String&gt;(
          onSelected: (action) =&gt; _handleSessionAction(action, session),
          itemBuilder: (context) =&gt; [
            const PopupMenuItem(
              value: &apos;details&apos;,
              child: Row(
                children: [
                  Icon(Icons.info),
                  SizedBox(width: 8),
                  Text(&apos;Details&apos;),
                ],
              ),
            ),
            if (session.status == SessionStatus.active)
              const PopupMenuItem(
                value: &apos;terminate&apos;,
                child: Row(
                  children: [
                    Icon(Icons.exit_to_app, color: Colors.red),
                    SizedBox(width: 8),
                    Text(&apos;Terminate&apos;, style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            if (session.isSuspicious)
              const PopupMenuItem(
                value: &apos;block&apos;,
                child: Row(
                  children: [
                    Icon(Icons.block, color: Colors.red),
                    SizedBox(width: 8),
                    Text(&apos;Block IP&apos;, style: TextStyle(color: Colors.red)),
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
                      child: _buildDetailItem(&apos;Session ID&apos;, session.sessionId),
                    ),
                    Expanded(
                      child: _buildDetailItem(&apos;Duration&apos;, _formatDuration(session.duration)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailItem(&apos;User Agent&apos;, session.userAgent),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailItem(&apos;Created&apos;, _formatTimestamp(session.createdAt)),
                    ),
                    Expanded(
                      child: _buildDetailItem(&apos;Requests&apos;, session.requestCount.toString()),
                    ),
                  ],
                ),
                if (session.securityFlags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text(
                    &apos;Security Flags:&apos;,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    children: session.securityFlags.map((flag) =&gt; Chip(
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
            Text(&apos;No security alerts&apos;),
            Text(&apos;All sessions appear normal&apos;),
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
            Text(&apos;User: ${alert.userEmail}&apos;),
            Text(&apos;IP: ${alert.ipAddress}&apos;),
            Text(&apos;${_formatTimestamp(alert.timestamp)}&apos;),
          ],
        ),
        trailing: PopupMenuButton&lt;String&gt;(
          onSelected: (action) =&gt; _handleAlertAction(action, alert),
          itemBuilder: (context) =&gt; [
            const PopupMenuItem(
              value: &apos;investigate&apos;,
              child: Row(
                children: [
                  Icon(Icons.search),
                  SizedBox(width: 8),
                  Text(&apos;Investigate&apos;),
                ],
              ),
            ),
            const PopupMenuItem(
              value: &apos;dismiss&apos;,
              child: Row(
                children: [
                  Icon(Icons.check),
                  SizedBox(width: 8),
                  Text(&apos;Dismiss&apos;),
                ],
              ),
            ),
            const PopupMenuItem(
              value: &apos;block&apos;,
              child: Row(
                children: [
                  Icon(Icons.block, color: Colors.red),
                  SizedBox(width: 8),
                  Text(&apos;Block IP&apos;, style: TextStyle(color: Colors.red)),
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
      return const Center(child: Text(&apos;No analytics data available&apos;));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            &apos;Session Overview&apos;,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildAnalyticsKPIs(),
          const SizedBox(height: 24),
          const Text(
            &apos;Session Trends&apos;,
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
              title: &apos;Daily Active Sessions&apos;,
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
                      &apos;Device Types&apos;,
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
                      &apos;Geographic Distribution&apos;,
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
          &apos;Total Sessions&apos;,
          _sessionAnalytics!.totalSessions.toString(),
          Icons.people,
          Colors.blue,
        ),
        _buildKPICard(
          &apos;Avg Duration&apos;,
          &apos;${_sessionAnalytics!.averageDuration.toStringAsFixed(1)}m&apos;,
          Icons.access_time,
          Colors.green,
        ),
        _buildKPICard(
          &apos;Suspicious&apos;,
          _sessionAnalytics!.suspiciousActivities.toString(),
          Icons.warning,
          Colors.red,
        ),
        _buildKPICard(
          &apos;Unique IPs&apos;,
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
        case &apos;details&apos;:
          _showSessionDetails(session);
          break;
        case &apos;terminate&apos;:
          final confirmed = await _showConfirmationDialog(
            &apos;Terminate Session&apos;,
            &apos;Are you sure you want to terminate this session?&apos;,
          );
          if (confirmed) {
            await service.terminateSession(session.sessionId);
            _loadData();
          }
          break;
        case &apos;block&apos;:
          final confirmed = await _showConfirmationDialog(
            &apos;Block IP Address&apos;,
            &apos;Are you sure you want to block IP ${session.ipAddress}?&apos;,
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
          SnackBar(content: Text(&apos;Error: ${e.toString()}&apos;)),
        );
      }
    }
  }

  void _handleAlertAction(String action, SessionSecurityAlert alert) async {
    final service = ref.read(analyticsApiServiceProvider);
    
    try {
      switch (action) {
        case &apos;investigate&apos;:
          _showAlertDetails(alert);
          break;
        case &apos;dismiss&apos;:
          await service.dismissSecurityAlert(alert.id);
          _loadData();
          break;
        case &apos;block&apos;:
          final confirmed = await _showConfirmationDialog(
            &apos;Block IP Address&apos;,
            &apos;Are you sure you want to block IP ${alert.ipAddress}?&apos;,
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
          SnackBar(content: Text(&apos;Error: ${e.toString()}&apos;)),
        );
      }
    }
  }

  void _showSessionDetails(UserSessionDetails session) {
    showDialog(
      context: context,
      builder: (context) =&gt; AlertDialog(
        title: const Text(&apos;Session Details&apos;),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow(&apos;User&apos;, session.userEmail),
                _buildDetailRow(&apos;Session ID&apos;, session.sessionId),
                _buildDetailRow(&apos;IP Address&apos;, session.ipAddress),
                _buildDetailRow(&apos;Location&apos;, session.location),
                _buildDetailRow(&apos;Device&apos;, session.deviceInfo),
                _buildDetailRow(&apos;User Agent&apos;, session.userAgent),
                _buildDetailRow(&apos;Status&apos;, session.status.displayName),
                _buildDetailRow(&apos;Created&apos;, _formatTimestamp(session.createdAt)),
                _buildDetailRow(&apos;Last Activity&apos;, _formatTimestamp(session.lastActivity)),
                _buildDetailRow(&apos;Duration&apos;, _formatDuration(session.duration)),
                _buildDetailRow(&apos;Requests&apos;, session.requestCount.toString()),
                if (session.securityFlags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text(
                    &apos;Security Flags:&apos;,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...session.securityFlags.map((flag) =&gt; Text(&apos;• $flag&apos;)),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () =&gt; Navigator.of(context).pop(),
            child: const Text(&apos;Close&apos;),
          ),
        ],
      ),
    );
  }

  void _showAlertDetails(SessionSecurityAlert alert) {
    showDialog(
      context: context,
      builder: (context) =&gt; AlertDialog(
        title: Text(&apos;Security Alert: ${alert.title}&apos;),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow(&apos;Type&apos;, alert.type.displayName),
                _buildDetailRow(&apos;Severity&apos;, alert.severity.displayName),
                _buildDetailRow(&apos;Description&apos;, alert.description),
                _buildDetailRow(&apos;User&apos;, alert.userEmail),
                _buildDetailRow(&apos;IP Address&apos;, alert.ipAddress),
                _buildDetailRow(&apos;Timestamp&apos;, _formatTimestamp(alert.timestamp)),
                if (alert.metadata.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text(
                    &apos;Additional Details:&apos;,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...alert.metadata.entries.map((entry) =&gt; 
                      Text(&apos;${entry.key}: ${entry.value}&apos;)),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () =&gt; Navigator.of(context).pop(),
            child: const Text(&apos;Close&apos;),
          ),
        ],
      ),
    );
  }

  Future&lt;bool&gt; _showConfirmationDialog(String title, String content) async {
    return await showDialog&lt;bool&gt;(
      context: context,
      builder: (context) =&gt; AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () =&gt; Navigator.of(context).pop(false),
            child: const Text(&apos;Cancel&apos;),
          ),
          TextButton(
            onPressed: () =&gt; Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text(&apos;Confirm&apos;),
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
              &apos;$label:&apos;,
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

    if (difference.inMinutes &lt; 1) {
      return &apos;Just now&apos;;
    } else if (difference.inHours &lt; 1) {
      return &apos;${difference.inMinutes}m ago&apos;;
    } else if (difference.inDays &lt; 1) {
      return &apos;${difference.inHours}h ago&apos;;
    } else {
      return &apos;${timestamp.day}/${timestamp.month}/${timestamp.year}&apos;;
    }
  }

  String _formatDate(DateTime date) {
    return &apos;${date.day}/${date.month}/${date.year}&apos;;
  }

  String _formatDuration(int minutes) {
    if (minutes &lt; 60) {
      return &apos;${minutes}m&apos;;
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return remainingMinutes == 0 ? &apos;${hours}h&apos; : &apos;${hours}h ${remainingMinutes}m&apos;;
    }
  }
}