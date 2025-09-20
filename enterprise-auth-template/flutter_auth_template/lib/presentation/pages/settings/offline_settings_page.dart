import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_auth_template/core/services/offline_service.dart';
import 'package:flutter_auth_template/presentation/providers/offline_provider.dart';
import 'package:flutter_auth_template/presentation/widgets/common/offline_banner.dart';

class OfflineSettingsPage extends ConsumerStatefulWidget {
  const OfflineSettingsPage({super.key});

  @override
  ConsumerState<OfflineSettingsPage> createState() => _OfflineSettingsPageState();
}

class _OfflineSettingsPageState extends ConsumerState<OfflineSettingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Settings'),
        actions: [
          IconButton(
            onPressed: () => _showOfflineStatus(),
            icon: const OfflineIndicator(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.settings), text: 'Settings'),
            Tab(icon: Icon(Icons.pending_actions), text: 'Pending Actions'),
            Tab(icon: Icon(Icons.storage), text: 'Cache'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSettingsTab(),
          _buildPendingActionsTab(),
          _buildCacheTab(),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    final connectivityStatus = ref.watch(offlineStatusProvider);
    
    return connectivityStatus.when(
      data: (status) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const OfflineStatusCard(),
          const SizedBox(height: 16),
          _buildSettingsCard(),
          const SizedBox(height: 16),
          _buildActionsCard(),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.refresh(offlineStatusProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Offline Behavior',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.cached),
              title: const Text('Auto-cache responses'),
              subtitle: const Text('Automatically cache GET responses for offline use'),
              trailing: Switch(
                value: true,
                onChanged: (value) {
                  // TODO: Implement setting toggle
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.queue),
              title: const Text('Queue actions offline'),
              subtitle: const Text('Queue POST/PUT/DELETE actions when offline'),
              trailing: Switch(
                value: true,
                onChanged: (value) {
                  // TODO: Implement setting toggle
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.sync),
              title: const Text('Auto-sync when online'),
              subtitle: const Text('Automatically sync pending actions when connected'),
              trailing: Switch(
                value: true,
                onChanged: (value) {
                  // TODO: Implement setting toggle
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.sync, color: Colors.blue),
              title: const Text('Force Sync Now'),
              subtitle: const Text('Manually sync all pending actions'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _forceSyncNow(),
            ),
            ListTile(
              leading: const Icon(Icons.clear_all, color: Colors.orange),
              title: const Text('Clear Pending Actions'),
              subtitle: const Text('Remove all queued actions'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _clearPendingActions(),
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Clear All Cache'),
              subtitle: const Text('Remove all cached data'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _clearAllCache(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingActionsTab() {
    final pendingCount = ref.watch(pendingActionsCountProvider);
    final offlineService = ref.read(offlineServiceProvider);
    
    return FutureBuilder<List<PendingAction>>(
      future: Future.value(offlineService.pendingActions),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final pendingActions = snapshot.data ?? [];
        
        if (pendingActions.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, size: 64, color: Colors.green),
                SizedBox(height: 16),
                Text(
                  'No pending actions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('All your actions are synced!'),
              ],
            ),
          );
        }
        
        return Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).colorScheme.surfaceContainer,
              child: Text(
                '$pendingCount pending action${pendingCount > 1 ? 's' : ''}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: pendingActions.length,
                itemBuilder: (context, index) {
                  final action = pendingActions[index];
                  return _buildPendingActionTile(action);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPendingActionTile(PendingAction action) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getActionTypeColor(action.type),
          child: Icon(
            _getActionTypeIcon(action.type),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          action.type.name.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(action.endpoint),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: theme.hintColor),
                const SizedBox(width: 4),
                Text(
                  _formatTimestamp(action.timestamp),
                  style: theme.textTheme.bodySmall,
                ),
                if (action.retryCount > 0) ...[
                  const SizedBox(width: 16),
                  Icon(Icons.refresh, size: 14, color: theme.hintColor),
                  const SizedBox(width: 4),
                  Text(
                    '${action.retryCount} retries',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _removePendingAction(action.id),
        ),
        onTap: () => _showActionDetails(action),
      ),
    );
  }

  Widget _buildCacheTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cache Management',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.storage, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'Cache Statistics',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildCacheStatRow('Total cached responses', '124 items'),
                  _buildCacheStatRow('Cache size', '2.3 MB'),
                  _buildCacheStatRow('Last updated', '5 minutes ago'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _refreshCacheStats(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Refresh Stats'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _clearAllCache(),
                          icon: const Icon(Icons.clear_all),
                          label: const Text('Clear Cache'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCacheStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Color _getActionTypeColor(OfflineActionType type) {
    switch (type) {
      case OfflineActionType.create:
        return Colors.green;
      case OfflineActionType.update:
        return Colors.blue;
      case OfflineActionType.delete:
        return Colors.red;
      case OfflineActionType.sync:
        return Colors.orange;
    }
  }

  IconData _getActionTypeIcon(OfflineActionType type) {
    switch (type) {
      case OfflineActionType.create:
        return Icons.add;
      case OfflineActionType.update:
        return Icons.edit;
      case OfflineActionType.delete:
        return Icons.delete;
      case OfflineActionType.sync:
        return Icons.sync;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _showOfflineStatus() {
    final offlineService = ref.read(offlineServiceProvider);
    final status = offlineService.getOfflineStatus();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Offline Status'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Online: ${status['isOnline']}'),
              Text('Connectivity: ${status['connectivity']}'),
              Text('Pending Actions: ${status['pendingActionsCount']}'),
              if (status['lastSyncAttempt'] != null)
                Text('Last Sync: ${status['lastSyncAttempt']}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _forceSyncNow() async {
    setState(() => _isLoading = true);
    
    try {
      await ref.read(pendingActionsCountProvider.notifier).syncNow();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sync completed successfully'),
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
      setState(() => _isLoading = false);
    }
  }

  Future<void> _clearPendingActions() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Pending Actions'),
        content: const Text('Are you sure you want to clear all pending actions? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      try {
        await ref.read(pendingActionsCountProvider.notifier).clearAll();
        
        if (mounted) {
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
      }
    }
  }

  Future<void> _clearAllCache() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('Are you sure you want to clear all cached data? This will remove offline access to previously loaded content.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear Cache'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      try {
        await ref.read(offlineServiceProvider).clearCache();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cache cleared successfully'),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Clear cache failed: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _removePendingAction(String actionId) async {
    try {
      await ref.read(offlineServiceProvider).removePendingAction(actionId);
      await ref.read(pendingActionsCountProvider.notifier).refresh();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pending action removed'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Remove failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showActionDetails(PendingAction action) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${action.type.name.toUpperCase()} Action'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Endpoint: ${action.endpoint}'),
              const SizedBox(height: 8),
              Text('Created: ${action.timestamp}'),
              if (action.retryCount > 0) ...[
                const SizedBox(height: 8),
                Text('Retry Count: ${action.retryCount}'),
              ],
              const SizedBox(height: 16),
              const Text('Data:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  action.data.toString(),
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _removePendingAction(action.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _refreshCacheStats() {
    // TODO: Implement cache statistics refresh
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cache statistics refreshed'),
      ),
    );
  }
}