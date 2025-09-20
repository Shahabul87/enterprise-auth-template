import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_auth_template/core/services/offline_service.dart';
import 'package:flutter_auth_template/presentation/providers/offline_provider.dart';

class OfflineBanner extends ConsumerWidget {
  final Widget child;
  final bool showPendingCount;

  const OfflineBanner({
    super.key,
    required this.child,
    this.showPendingCount = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityStatus = ref.watch(offlineStatusProvider);
    final pendingCount = ref.watch(pendingActionsCountProvider);

    return connectivityStatus.when(
      data: (status) => Column(
        children: [
          if (status != ConnectivityStatus.online)
            _buildOfflineBanner(context, ref, status, pendingCount),
          Expanded(child: child),
        ],
      ),
      loading: () => child,
      error: (_, __) => child,
    );
  }

  Widget _buildOfflineBanner(
    BuildContext context,
    WidgetRef ref,
    ConnectivityStatus status,
    int pendingCount,
  ) {
    final theme = Theme.of(context);
    final isOffline = status == ConnectivityStatus.offline;
    
    return Container(
      width: double.infinity,
      color: isOffline ? Colors.red.shade700 : Colors.orange.shade700,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SafeArea(
        top: true,
        bottom: false,
        child: Row(
          children: [
            Icon(
              isOffline ? Icons.cloud_off : Icons.signal_wifi_statusbar_connected_no_internet_4,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isOffline ? 'You\'re offline' : 'Limited connectivity',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (showPendingCount && pendingCount > 0)
                    Text(
                      '$pendingCount action${pendingCount > 1 ? 's' : ''} pending sync',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                ],
              ),
            ),
            if (pendingCount > 0) ...[
              const SizedBox(width: 8),
              _buildSyncButton(context, ref, isOffline),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSyncButton(BuildContext context, WidgetRef ref, bool isOffline) {
    return TextButton.icon(
      onPressed: isOffline ? null : () => _showSyncDialog(context, ref),
      icon: const Icon(Icons.sync, color: Colors.white, size: 16),
      label: const Text(
        'Sync',
        style: TextStyle(color: Colors.white, fontSize: 12),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  void _showSyncDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => _SyncDialog(),
    );
  }
}

class _SyncDialog extends ConsumerStatefulWidget {
  @override
  ConsumerState<_SyncDialog> createState() => _SyncDialogState();
}

class _SyncDialogState extends ConsumerState<_SyncDialog> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final pendingCount = ref.watch(pendingActionsCountProvider);
    final pendingActionsNotifier = ref.read(pendingActionsCountProvider.notifier);

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.sync, color: Colors.blue),
          SizedBox(width: 8),
          Text('Sync Pending Actions'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('You have $pendingCount pending action${pendingCount > 1 ? 's' : ''} waiting to be synced.'),
          const SizedBox(height: 16),
          const Text('What would you like to do?'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _isLoading ? null : () => _clearPendingActions(pendingActionsNotifier),
          child: const Text('Clear All'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : () => _syncNow(pendingActionsNotifier),
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Sync Now'),
        ),
      ],
    );
  }

  Future<void> _syncNow(PendingActionsNotifier notifier) async {
    setState(() => _isLoading = true);
    
    try {
      await notifier.syncNow();
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Actions synced successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _clearPendingActions(PendingActionsNotifier notifier) async {
    setState(() => _isLoading = true);
    
    try {
      await notifier.clearAll();
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pending actions cleared'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Clear failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

class OfflineIndicator extends ConsumerWidget {
  final double? size;
  final Color? color;

  const OfflineIndicator({
    super.key,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityStatus = ref.watch(offlineStatusProvider);
    
    return connectivityStatus.when(
      data: (status) {
        if (status == ConnectivityStatus.online) {
          return const SizedBox.shrink();
        }
        
        return Icon(
          status == ConnectivityStatus.offline 
              ? Icons.cloud_off 
              : Icons.signal_wifi_statusbar_connected_no_internet_4,
          size: size,
          color: color ?? (status == ConnectivityStatus.offline ? Colors.red : Colors.orange),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class OfflineStatusCard extends ConsumerWidget {
  const OfflineStatusCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final connectivityStatus = ref.watch(offlineStatusProvider);
    final pendingCount = ref.watch(pendingActionsCountProvider);

    return connectivityStatus.when(
      data: (status) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getStatusIcon(status),
                    color: _getStatusColor(status),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Connection Status',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                _getStatusText(status),
                style: theme.textTheme.bodyLarge,
              ),
              if (pendingCount > 0) ...[
                const SizedBox(height: 8),
                Text(
                  '$pendingCount pending action${pendingCount > 1 ? 's' : ''} waiting to sync',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.orange,
                  ),
                ),
              ],
              if (status == ConnectivityStatus.online && pendingCount > 0) ...[
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => ref.read(pendingActionsCountProvider.notifier).syncNow(),
                  icon: const Icon(Icons.sync),
                  label: const Text('Sync Now'),
                ),
              ],
            ],
          ),
        ),
      ),
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Checking connection status...'),
            ],
          ),
        ),
      ),
      error: (_, __) => const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.error, color: Colors.red),
              SizedBox(width: 8),
              Text('Unable to determine connection status'),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getStatusIcon(ConnectivityStatus status) {
    switch (status) {
      case ConnectivityStatus.online:
        return Icons.cloud_done;
      case ConnectivityStatus.offline:
        return Icons.cloud_off;
      case ConnectivityStatus.limited:
        return Icons.signal_wifi_statusbar_connected_no_internet_4;
    }
  }

  Color _getStatusColor(ConnectivityStatus status) {
    switch (status) {
      case ConnectivityStatus.online:
        return Colors.green;
      case ConnectivityStatus.offline:
        return Colors.red;
      case ConnectivityStatus.limited:
        return Colors.orange;
    }
  }

  String _getStatusText(ConnectivityStatus status) {
    switch (status) {
      case ConnectivityStatus.online:
        return 'Connected to the internet';
      case ConnectivityStatus.offline:
        return 'No internet connection';
      case ConnectivityStatus.limited:
        return 'Limited or unstable connection';
    }
  }
}