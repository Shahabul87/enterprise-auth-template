import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_auth_template/data/models/device_models.dart';
import 'package:flutter_auth_template/data/services/device_api_service.dart';
import 'package:flutter_auth_template/core/errors/app_exception.dart';
import 'package:flutter_auth_template/presentation/widgets/buttons/custom_buttons.dart';
import 'package:flutter_auth_template/presentation/widgets/dialog_components.dart';
import 'package:flutter_auth_template/presentation/widgets/loading_indicators.dart';
import 'package:flutter_auth_template/presentation/widgets/empty_state.dart';

class DeviceManagementPage extends ConsumerStatefulWidget {
  const DeviceManagementPage({super.key});

  @override
  ConsumerState<DeviceManagementPage> createState() => _DeviceManagementPageState();
}

class _DeviceManagementPageState extends ConsumerState<DeviceManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showTrustedOnly = false;
  bool _showActiveOnly = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Devices', icon: Icon(Icons.devices)),
            Tab(text: 'Security', icon: Icon(Icons.security)),
            Tab(text: 'Statistics', icon: Icon(Icons.analytics)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDevicesTab(),
          _buildSecurityTab(),
          _buildStatisticsTab(),
        ],
      ),
    );
  }

  Widget _buildDevicesTab() {
    return Column(
      children: [
        _buildSearchAndFilters(),
        Expanded(
          child: _buildDeviceList(),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search devices...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              FilterChip(
                label: const Text('Trusted Only'),
                selected: _showTrustedOnly,
                onSelected: (selected) {
                  setState(() {
                    _showTrustedOnly = selected;
                  });
                },
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('Active Only'),
                selected: _showActiveOnly,
                onSelected: (selected) {
                  setState(() {
                    _showActiveOnly = selected;
                  });
                },
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _refreshDevices,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceList() {
    return FutureBuilder<DeviceListResponse>(
      future: _loadDevices(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingIndicator();
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).errorColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to load devices',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  snapshot.error.toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _refreshDevices,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final deviceList = snapshot.data!;
        if (deviceList.devices.isEmpty) {
          return const EmptyState(
            icon: Icons.devices_other,
            title: 'No Devices Found',
            description: 'No devices match your search criteria.',
          );
        }

        return RefreshIndicator(
          onRefresh: _refreshDevices,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: deviceList.devices.length,
            itemBuilder: (context, index) {
              final device = deviceList.devices[index];
              return _buildDeviceCard(device);
            },
          ),
        );
      },
    );
  }

  Widget _buildDeviceCard(Device device) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: _buildDeviceIcon(device),
        title: Text(
          device.deviceName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${device.platform} • ${device.browser ?? 'Unknown'}'),
            Text(
              'Last seen: ${_formatDateTime(device.lastSeenAt)}',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusChip(device),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              onSelected: (value) => _handleDeviceAction(value, device),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: ListTile(
                    leading: Icon(Icons.visibility),
                    title: Text('View Details'),
                  ),
                ),
                if (!device.isTrusted)
                  const PopupMenuItem(
                    value: 'trust',
                    child: ListTile(
                      leading: Icon(Icons.verified_user),
                      title: Text('Trust Device'),
                    ),
                  )
                else
                  const PopupMenuItem(
                    value: 'untrust',
                    child: ListTile(
                      leading: Icon(Icons.verified_user_outlined),
                      title: Text('Untrust Device'),
                    ),
                  ),
                PopupMenuItem(
                  value: device.isActive ? 'block' : 'unblock',
                  child: ListTile(
                    leading: Icon(device.isActive ? Icons.block : Icons.check_circle),
                    title: Text(device.isActive ? 'Block Device' : 'Unblock Device'),
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text('Delete Device', style: TextStyle(color: Colors.red)),
                  ),
                ),
              ],
            ),
          ],
        ),
        isThreeLine: true,
        onTap: () => _showDeviceDetails(device),
      ),
    );
  }

  Widget _buildDeviceIcon(Device device) {
    IconData iconData;
    switch (device.deviceType.toLowerCase()) {
      case 'mobile':
        iconData = Icons.smartphone;
        break;
      case 'desktop':
        iconData = Icons.computer;
        break;
      case 'tablet':
        iconData = Icons.tablet;
        break;
      case 'browser':
        iconData = Icons.web;
        break;
      default:
        iconData = Icons.devices_other;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: device.isTrusted ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        iconData,
        color: device.isTrusted ? Colors.green : Colors.orange,
      ),
    );
  }

  Widget _buildStatusChip(Device device) {
    Color color;
    String label;

    if (!device.isActive) {
      color = Colors.red;
      label = 'Blocked';
    } else if (device.isTrusted) {
      color = Colors.green;
      label = 'Trusted';
    } else {
      color = Colors.orange;
      label = 'Unverified';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSecurityTab() {
    return FutureBuilder<List<DeviceSecurityAlert>>(
      future: _loadSecurityAlerts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingIndicator();
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Failed to load security alerts'));
        }

        final alerts = snapshot.data!;
        if (alerts.isEmpty) {
          return const EmptyState(
            icon: Icons.security,
            title: 'No Security Alerts',
            description: 'No security alerts found for your devices.',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: alerts.length,
          itemBuilder: (context, index) {
            final alert = alerts[index];
            return _buildSecurityAlertCard(alert);
          },
        );
      },
    );
  }

  Widget _buildSecurityAlertCard(DeviceSecurityAlert alert) {
    Color severityColor;
    IconData severityIcon;

    switch (alert.severity.toLowerCase()) {
      case 'high':
        severityColor = Colors.red;
        severityIcon = Icons.warning;
        break;
      case 'medium':
        severityColor = Colors.orange;
        severityIcon = Icons.info;
        break;
      default:
        severityColor = Colors.blue;
        severityIcon = Icons.info_outline;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: severityColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(severityIcon, color: severityColor),
        ),
        title: Text(
          alert.alertType,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(alert.message),
            const SizedBox(height: 4),
            Text(
              _formatDateTime(alert.createdAt),
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
        trailing: alert.isResolved
            ? const Icon(Icons.check_circle, color: Colors.green)
            : TextButton(
                onPressed: () => _resolveSecurityAlert(alert.id),
                child: const Text('Resolve'),
              ),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildStatisticsTab() {
    return FutureBuilder<DeviceStats>(
      future: _loadDeviceStats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingIndicator();
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Failed to load statistics'));
        }

        final stats = snapshot.data!;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatsGrid(stats),
              const SizedBox(height: 24),
              _buildPlatformChart(stats),
              const SizedBox(height: 24),
              _buildLocationStats(stats),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsGrid(DeviceStats stats) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard('Total Devices', stats.totalDevices.toString(), Icons.devices),
        _buildStatCard('Active Devices', stats.activeDevices.toString(), Icons.check_circle),
        _buildStatCard('Trusted Devices', stats.trustedDevices.toString(), Icons.verified_user),
        _buildStatCard('Unknown Devices', stats.unknownDevices.toString(), Icons.help_outline),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlatformChart(DeviceStats stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Devices by Platform',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...stats.devicesByPlatform.entries.map((entry) => _buildPlatformRow(entry.key, entry.value, stats.totalDevices)),
          ],
        ),
      ),
    );
  }

  Widget _buildPlatformRow(String platform, int count, int total) {
    final percentage = (count / total * 100).round();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(platform),
          ),
          Expanded(
            flex: 3,
            child: LinearProgressIndicator(
              value: count / total,
              backgroundColor: Colors.grey[300],
            ),
          ),
          Expanded(
            child: Text(
              '$count ($percentage%)',
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationStats(DeviceStats stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Locations',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...stats.topLocations.map((location) => ListTile(
                  leading: const Icon(Icons.location_on),
                  title: Text(location.location),
                  trailing: Text('${location.count} devices'),
                )),
          ],
        ),
      ),
    );
  }

  Future<DeviceListResponse> _loadDevices() async {
    final deviceService = ref.read(deviceApiServiceProvider);
    return await deviceService.getUserDevices(
      isActive: _showActiveOnly ? true : null,
      isTrusted: _showTrustedOnly ? true : null,
    );
  }

  Future<List<DeviceSecurityAlert>> _loadSecurityAlerts() async {
    final deviceService = ref.read(deviceApiServiceProvider);
    return await deviceService.getDeviceSecurityAlerts();
  }

  Future<DeviceStats> _loadDeviceStats() async {
    final deviceService = ref.read(deviceApiServiceProvider);
    return await deviceService.getDeviceStats();
  }

  Future<void> _refreshDevices() async {
    setState(() {});
  }

  void _handleDeviceAction(String action, Device device) async {
    final deviceService = ref.read(deviceApiServiceProvider);

    try {
      switch (action) {
        case 'view':
          _showDeviceDetails(device);
          break;
        case 'trust':
          await deviceService.trustDevice(device.id);
          _refreshDevices();
          _showSnackBar('Device trusted successfully');
          break;
        case 'untrust':
          await deviceService.untrustDevice(device.id);
          _refreshDevices();
          _showSnackBar('Device untrusted successfully');
          break;
        case 'block':
          await deviceService.blockDevice(device.id);
          _refreshDevices();
          _showSnackBar('Device blocked successfully');
          break;
        case 'unblock':
          await deviceService.unblockDevice(device.id);
          _refreshDevices();
          _showSnackBar('Device unblocked successfully');
          break;
        case 'delete':
          final confirmed = await _showConfirmDialog(
            'Delete Device',
            'Are you sure you want to delete this device?',
          );
          if (confirmed) {
            await deviceService.deleteDevice(device.id);
            _refreshDevices();
            _showSnackBar('Device deleted successfully');
          }
          break;
      }
    } catch (e) {
      _showSnackBar('Failed to perform action: ${e.toString()}');
    }
  }

  void _showDeviceDetails(Device device) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(device.deviceName),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Device Type', device.deviceType),
              _buildDetailRow('Platform', device.platform),
              _buildDetailRow('Browser', device.browser ?? 'Unknown'),
              _buildDetailRow('OS', device.os ?? 'Unknown'),
              _buildDetailRow('IP Address', device.ipAddress),
              _buildDetailRow('Location', device.location ?? 'Unknown'),
              _buildDetailRow('Status', device.isActive ? 'Active' : 'Blocked'),
              _buildDetailRow('Trusted', device.isTrusted ? 'Yes' : 'No'),
              _buildDetailRow('Created', _formatDateTime(device.createdAt)),
              _buildDetailRow('Last Seen', _formatDateTime(device.lastSeenAt)),
            ],
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

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value ?? 'N/A')),
        ],
      ),
    );
  }

  Future<void> _resolveSecurityAlert(String alertId) async {
    try {
      final deviceService = ref.read(deviceApiServiceProvider);
      await deviceService.resolveSecurityAlert(alertId);
      setState(() {});
      _showSnackBar('Security alert resolved');
    } catch (e) {
      _showSnackBar('Failed to resolve alert: ${e.toString()}');
    }
  }

  Future<bool> _showConfirmDialog(String title, String message) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Confirm'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Never';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}