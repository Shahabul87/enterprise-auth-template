import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_auth_template/core/security/device_fingerprint_service.dart';
import 'package:flutter_auth_template/presentation/providers/auth_provider.dart';
import 'package:intl/intl.dart';

/// Widget for managing trusted devices
class TrustedDevicesManager extends ConsumerStatefulWidget {
  const TrustedDevicesManager({Key? key}) : super(key: key);

  @override
  ConsumerState<TrustedDevicesManager> createState() => _TrustedDevicesManagerState();
}

class _TrustedDevicesManagerState extends ConsumerState<TrustedDevicesManager> {
  List<TrustedDevice> _trustedDevices = [];
  bool _isLoading = true;
  String? _currentFingerprint;

  @override
  void initState() {
    super.initState();
    _loadTrustedDevices();
  }

  Future<void> _loadTrustedDevices() async {
    setState(() => _isLoading = true);

    try {
      final deviceService = ref.read(deviceFingerprintServiceProvider);
      final currentUser = ref.read(currentUserProvider);
      
      if (currentUser != null) {
        // Get current device fingerprint
        _currentFingerprint = await deviceService.getStoredFingerprint();
        
        // Load trusted devices
        final devices = await deviceService.getTrustedDevices(currentUser.id);
        
        setState(() {
          _trustedDevices = devices;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load trusted devices: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removeTrustedDevice(String fingerprintId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Trusted Device'),
        content: const Text(
          'Are you sure you want to remove this device? '
          'You will need to verify it again next time you log in from this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final deviceService = ref.read(deviceFingerprintServiceProvider);
        final currentUser = ref.read(currentUserProvider);
        
        if (currentUser != null) {
          final result = await deviceService.removeTrustedDevice(
            userId: currentUser.id,
            fingerprintId: fingerprintId,
          );

          if (result.isSuccess) {
            await _loadTrustedDevices();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Device removed successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } else {
            throw Exception(result.errorMessage);
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to remove device: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _clearAllDevices() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Trusted Devices'),
        content: const Text(
          'Are you sure you want to remove all trusted devices? '
          'You will need to verify each device again on next login.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final deviceService = ref.read(deviceFingerprintServiceProvider);
        final currentUser = ref.read(currentUserProvider);
        
        if (currentUser != null) {
          await deviceService.clearTrustedDevices(currentUser.id);
          await _loadTrustedDevices();
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('All trusted devices cleared'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to clear devices: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, y HH:mm').format(date);
  }

  Widget _buildDeviceIcon(String platform) {
    IconData icon;
    switch (platform.toLowerCase()) {
      case 'android':
        icon = Icons.android;
        break;
      case 'ios':
        icon = Icons.phone_iphone;
        break;
      case 'web':
        icon = Icons.web;
        break;
      default:
        icon = Icons.devices;
    }
    return Icon(icon, size: 32);
  }

  Widget _buildDeviceTile(TrustedDevice device) {
    final isCurrentDevice = device.fingerprintId == _currentFingerprint;
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isCurrentDevice ? 4 : 1,
      color: isCurrentDevice ? theme.colorScheme.primaryContainer : null,
      child: ListTile(
        leading: _buildDeviceIcon(device.platform),
        title: Row(
          children: [
            Expanded(
              child: Text(
                device.deviceName,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            if (isCurrentDevice)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Current',
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('${device.deviceModel} - ${device.platform} ${device.osVersion}'),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  'Added: ${_formatDate(device.trustedAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(
                  Icons.update,
                  size: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  'Last used: ${_formatDate(device.lastUsed)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(
                  Icons.timer,
                  size: 14,
                  color: device.daysUntilExpiry < 7 ? Colors.orange : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  'Expires in ${device.daysUntilExpiry} days',
                  style: TextStyle(
                    fontSize: 12,
                    color: device.daysUntilExpiry < 7 ? Colors.orange : theme.colorScheme.onSurfaceVariant,
                    fontWeight: device.daysUntilExpiry < 7 ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: !isCurrentDevice
            ? IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                color: Colors.red,
                onPressed: () => _removeTrustedDevice(device.fingerprintId),
                tooltip: 'Remove device',
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trusted Devices'),
        actions: [
          if (_trustedDevices.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _clearAllDevices,
              tooltip: 'Clear all devices',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTrustedDevices,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _trustedDevices.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.devices_other,
                        size: 64,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No trusted devices',
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Devices you log in from will appear here',
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadTrustedDevices,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Card(
                        color: theme.colorScheme.secondaryContainer,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: theme.colorScheme.onSecondaryContainer,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Device Trust',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: theme.colorScheme.onSecondaryContainer,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Trusted devices can log in without additional verification. '
                                      'Devices expire after 30 days of inactivity.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: theme.colorScheme.onSecondaryContainer,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Trusted Devices (${_trustedDevices.length})',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      ..._trustedDevices.map(_buildDeviceTile),
                    ],
                  ),
                ),
    );
  }
}