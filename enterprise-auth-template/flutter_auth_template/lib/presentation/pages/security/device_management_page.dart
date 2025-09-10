import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/device_models.dart';
import '../../../data/services/device_api_service.dart';
import '../../../core/errors/app_exception.dart';
import '../../widgets/buttons/custom_buttons.dart';
import '../../widgets/dialog_components.dart';
import '../../widgets/loading_indicators.dart';
import '../../widgets/empty_state.dart';

class DeviceManagementPage extends ConsumerStatefulWidget {
  const DeviceManagementPage({super.key});

  @override
  ConsumerState&lt;DeviceManagementPage&gt; createState() =&gt; _DeviceManagementPageState();
}

class _DeviceManagementPageState extends ConsumerState&lt;DeviceManagementPage&gt;
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = &apos;&apos;;
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
        title: const Text(&apos;Device Management&apos;),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: &apos;Devices&apos;, icon: Icon(Icons.devices)),
            Tab(text: &apos;Security&apos;, icon: Icon(Icons.security)),
            Tab(text: &apos;Statistics&apos;, icon: Icon(Icons.analytics)),
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
              hintText: &apos;Search devices...&apos;,
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
                          _searchQuery = &apos;&apos;;
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
                label: const Text(&apos;Trusted Only&apos;),
                selected: _showTrustedOnly,
                onSelected: (selected) {
                  setState(() {
                    _showTrustedOnly = selected;
                  });
                },
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text(&apos;Active Only&apos;),
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
                label: const Text(&apos;Refresh&apos;),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceList() {
    return FutureBuilder&lt;DeviceListResponse&gt;(
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
                  &apos;Failed to load devices&apos;,
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
                  child: const Text(&apos;Retry&apos;),
                ),
              ],
            ),
          );
        }

        final deviceList = snapshot.data!;
        if (deviceList.devices.isEmpty) {
          return const EmptyState(
            icon: Icons.devices_other,
            title: &apos;No Devices Found&apos;,
            description: &apos;No devices match your search criteria.&apos;,
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
            Text(&apos;${device.platform} • ${device.browser ?? &apos;Unknown&apos;}&apos;),
            Text(
              &apos;Last seen: ${_formatDateTime(device.lastSeenAt)}&apos;,
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
            PopupMenuButton&lt;String&gt;(
              onSelected: (value) =&gt; _handleDeviceAction(value, device),
              itemBuilder: (context) =&gt; [
                const PopupMenuItem(
                  value: &apos;view&apos;,
                  child: ListTile(
                    leading: Icon(Icons.visibility),
                    title: Text(&apos;View Details&apos;),
                  ),
                ),
                if (!device.isTrusted)
                  const PopupMenuItem(
                    value: &apos;trust&apos;,
                    child: ListTile(
                      leading: Icon(Icons.verified_user),
                      title: Text(&apos;Trust Device&apos;),
                    ),
                  )
                else
                  const PopupMenuItem(
                    value: &apos;untrust&apos;,
                    child: ListTile(
                      leading: Icon(Icons.verified_user_outlined),
                      title: Text(&apos;Untrust Device&apos;),
                    ),
                  ),
                PopupMenuItem(
                  value: device.isActive ? &apos;block&apos; : &apos;unblock&apos;,
                  child: ListTile(
                    leading: Icon(device.isActive ? Icons.block : Icons.check_circle),
                    title: Text(device.isActive ? &apos;Block Device&apos; : &apos;Unblock Device&apos;),
                  ),
                ),
                const PopupMenuItem(
                  value: &apos;delete&apos;,
                  child: ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text(&apos;Delete Device&apos;, style: TextStyle(color: Colors.red)),
                  ),
                ),
              ],
            ),
          ],
        ),
        isThreeLine: true,
        onTap: () =&gt; _showDeviceDetails(device),
      ),
    );
  }

  Widget _buildDeviceIcon(Device device) {
    IconData iconData;
    switch (device.deviceType.toLowerCase()) {
      case &apos;mobile&apos;:
        iconData = Icons.smartphone;
        break;
      case &apos;desktop&apos;:
        iconData = Icons.computer;
        break;
      case &apos;tablet&apos;:
        iconData = Icons.tablet;
        break;
      case &apos;browser&apos;:
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
      label = &apos;Blocked&apos;;
    } else if (device.isTrusted) {
      color = Colors.green;
      label = &apos;Trusted&apos;;
    } else {
      color = Colors.orange;
      label = &apos;Unverified&apos;;
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
    return FutureBuilder&lt;List&lt;DeviceSecurityAlert&gt;&gt;(
      future: _loadSecurityAlerts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingIndicator();
        }

        if (snapshot.hasError) {
          return const Center(child: Text(&apos;Failed to load security alerts&apos;));
        }

        final alerts = snapshot.data!;
        if (alerts.isEmpty) {
          return const EmptyState(
            icon: Icons.security,
            title: &apos;No Security Alerts&apos;,
            description: &apos;No security alerts found for your devices.&apos;,
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
      case &apos;high&apos;:
        severityColor = Colors.red;
        severityIcon = Icons.warning;
        break;
      case &apos;medium&apos;:
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
                onPressed: () =&gt; _resolveSecurityAlert(alert.id),
                child: const Text(&apos;Resolve&apos;),
              ),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildStatisticsTab() {
    return FutureBuilder&lt;DeviceStats&gt;(
      future: _loadDeviceStats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingIndicator();
        }

        if (snapshot.hasError) {
          return const Center(child: Text(&apos;Failed to load statistics&apos;));
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
        _buildStatCard(&apos;Total Devices&apos;, stats.totalDevices.toString(), Icons.devices),
        _buildStatCard(&apos;Active Devices&apos;, stats.activeDevices.toString(), Icons.check_circle),
        _buildStatCard(&apos;Trusted Devices&apos;, stats.trustedDevices.toString(), Icons.verified_user),
        _buildStatCard(&apos;Unknown Devices&apos;, stats.unknownDevices.toString(), Icons.help_outline),
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
              &apos;Devices by Platform&apos;,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...stats.devicesByPlatform.entries.map((entry) =&gt; _buildPlatformRow(entry.key, entry.value, stats.totalDevices)),
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
              &apos;$count ($percentage%)&apos;,
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
              &apos;Top Locations&apos;,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...stats.topLocations.map((location) =&gt; ListTile(
                  leading: const Icon(Icons.location_on),
                  title: Text(location.location),
                  trailing: Text(&apos;${location.count} devices&apos;),
                )),
          ],
        ),
      ),
    );
  }

  Future&lt;DeviceListResponse&gt; _loadDevices() async {
    final deviceService = ref.read(deviceApiServiceProvider);
    return await deviceService.getUserDevices(
      isActive: _showActiveOnly ? true : null,
      isTrusted: _showTrustedOnly ? true : null,
    );
  }

  Future&lt;List&lt;DeviceSecurityAlert&gt;&gt; _loadSecurityAlerts() async {
    final deviceService = ref.read(deviceApiServiceProvider);
    return await deviceService.getDeviceSecurityAlerts();
  }

  Future&lt;DeviceStats&gt; _loadDeviceStats() async {
    final deviceService = ref.read(deviceApiServiceProvider);
    return await deviceService.getDeviceStats();
  }

  Future&lt;void&gt; _refreshDevices() async {
    setState(() {});
  }

  void _handleDeviceAction(String action, Device device) async {
    final deviceService = ref.read(deviceApiServiceProvider);

    try {
      switch (action) {
        case &apos;view&apos;:
          _showDeviceDetails(device);
          break;
        case &apos;trust&apos;:
          await deviceService.trustDevice(device.id);
          _refreshDevices();
          _showSnackBar(&apos;Device trusted successfully&apos;);
          break;
        case &apos;untrust&apos;:
          await deviceService.untrustDevice(device.id);
          _refreshDevices();
          _showSnackBar(&apos;Device untrusted successfully&apos;);
          break;
        case &apos;block&apos;:
          await deviceService.blockDevice(device.id);
          _refreshDevices();
          _showSnackBar(&apos;Device blocked successfully&apos;);
          break;
        case &apos;unblock&apos;:
          await deviceService.unblockDevice(device.id);
          _refreshDevices();
          _showSnackBar(&apos;Device unblocked successfully&apos;);
          break;
        case &apos;delete&apos;:
          final confirmed = await _showConfirmDialog(
            &apos;Delete Device&apos;,
            &apos;Are you sure you want to delete this device?&apos;,
          );
          if (confirmed) {
            await deviceService.deleteDevice(device.id);
            _refreshDevices();
            _showSnackBar(&apos;Device deleted successfully&apos;);
          }
          break;
      }
    } catch (e) {
      _showSnackBar(&apos;Failed to perform action: ${e.toString()}&apos;);
    }
  }

  void _showDeviceDetails(Device device) {
    showDialog(
      context: context,
      builder: (context) =&gt; AlertDialog(
        title: Text(device.deviceName),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow(&apos;Device Type&apos;, device.deviceType),
              _buildDetailRow(&apos;Platform&apos;, device.platform),
              _buildDetailRow(&apos;Browser&apos;, device.browser ?? &apos;Unknown&apos;),
              _buildDetailRow(&apos;OS&apos;, device.os ?? &apos;Unknown&apos;),
              _buildDetailRow(&apos;IP Address&apos;, device.ipAddress),
              _buildDetailRow(&apos;Location&apos;, device.location ?? &apos;Unknown&apos;),
              _buildDetailRow(&apos;Status&apos;, device.isActive ? &apos;Active&apos; : &apos;Blocked&apos;),
              _buildDetailRow(&apos;Trusted&apos;, device.isTrusted ? &apos;Yes&apos; : &apos;No&apos;),
              _buildDetailRow(&apos;Created&apos;, _formatDateTime(device.createdAt)),
              _buildDetailRow(&apos;Last Seen&apos;, _formatDateTime(device.lastSeenAt)),
            ],
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
          Expanded(child: Text(value ?? &apos;N/A&apos;)),
        ],
      ),
    );
  }

  Future&lt;void&gt; _resolveSecurityAlert(String alertId) async {
    try {
      final deviceService = ref.read(deviceApiServiceProvider);
      await deviceService.resolveSecurityAlert(alertId);
      setState(() {});
      _showSnackBar(&apos;Security alert resolved&apos;);
    } catch (e) {
      _showSnackBar(&apos;Failed to resolve alert: ${e.toString()}&apos;);
    }
  }

  Future&lt;bool&gt; _showConfirmDialog(String title, String message) async {
    return await showDialog&lt;bool&gt;(
          context: context,
          builder: (context) =&gt; AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () =&gt; Navigator.of(context).pop(false),
                child: const Text(&apos;Cancel&apos;),
              ),
              ElevatedButton(
                onPressed: () =&gt; Navigator.of(context).pop(true),
                child: const Text(&apos;Confirm&apos;),
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
    if (dateTime == null) return &apos;Never&apos;;
    return &apos;${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, &apos;0&apos;)}&apos;;
  }
}