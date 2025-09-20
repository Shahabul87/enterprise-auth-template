import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_auth_template/data/models/export_models.dart';
import 'package:flutter_auth_template/data/models/admin_models.dart';
import 'package:flutter_auth_template/data/services/export_api_service.dart';
import 'package:flutter_auth_template/presentation/widgets/common/loading_widget.dart';
import 'package:flutter_auth_template/presentation/widgets/common/error_widget.dart';

final exportApiServiceProvider = Provider((ref) => ExportApiService());

class ExportBackupPage extends ConsumerStatefulWidget {
  const ExportBackupPage({super.key});

  @override
  ConsumerState<ExportBackupPage> createState() => _ExportBackupPageState();
}

class _ExportBackupPageState extends ConsumerState<ExportBackupPage> 
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<ExportJob> _exportJobs = [];
  List<BackupJob> _backupJobs = [];
  List<RestorePoint> _restorePoints = [];
  bool _isLoading = true;
  String? _error;

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

      final service = ref.read(exportApiServiceProvider);
      final results = await Future.wait([
        service.getExportJobs(),
        service.getBackupJobs(),
        service.getRestorePoints(),
      ]);

      if (mounted) {
        setState(() {
          _exportJobs = results[0] as List<ExportJob>;
          _backupJobs = results[1] as List<BackupJob>;
          _restorePoints = results[2] as List<RestorePoint>;
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
        title: const Text('Export & Backup'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Exports'),
            Tab(text: 'Backups'),
            Tab(text: 'Restore Points'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildExportsTab(),
          _buildBackupsTab(),
          _buildRestorePointsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showActionMenu(context),
        label: const Text('Create'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildExportsTab() {
    if (_exportJobs.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.file_download, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No export jobs found'),
            Text('Create a new export to get started'),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _exportJobs.length,
      itemBuilder: (context, index) {
        final job = _exportJobs[index];
        return _buildExportJobCard(job);
      },
    );
  }

  Widget _buildExportJobCard(ExportJob job) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: job.status.color,
              child: Icon(
                job.status.icon,
                color: Colors.white,
              ),
            ),
            title: Text(job.type.displayName),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Format: ${job.format.displayName}'),
                Text('Created: ${_formatDateTime(job.createdAt)}'),
                if (job.completedAt != null)
                  Text('Completed: ${_formatDateTime(job.completedAt!)}'),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (action) => _handleExportAction(action, job),
              itemBuilder: (context) => [
                if (job.status == ExportStatus.completed) ...[
                  const PopupMenuItem(
                    value: 'download',
                    child: Row(
                      children: [
                        Icon(Icons.download),
                        SizedBox(width: 8),
                        Text('Download'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'share',
                    child: Row(
                      children: [
                        Icon(Icons.share),
                        SizedBox(width: 8),
                        Text('Share'),
                      ],
                    ),
                  ),
                ],
                if (job.status == ExportStatus.pending || job.status == ExportStatus.running)
                  const PopupMenuItem(
                    value: 'cancel',
                    child: Row(
                      children: [
                        Icon(Icons.cancel),
                        SizedBox(width: 8),
                        Text('Cancel'),
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
          if (job.status == ExportStatus.running) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  LinearProgressIndicator(value: job.progress / 100),
                  const SizedBox(height: 8),
                  Text('Progress: ${job.progress.toStringAsFixed(1)}%'),
                ],
              ),
            ),
          ],
          if (job.status == ExportStatus.completed) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard('Records', job.recordCount.toString()),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard('Size', _formatFileSize(job.fileSize)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard('Duration', _formatDuration(job.duration)),
                  ),
                ],
              ),
            ),
          ],
          if (job.status == ExportStatus.failed) ...[
            const Divider(),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.red.withOpacity(0.1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Error:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  Text(job.errorMessage ?? 'Unknown error'),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBackupsTab() {
    if (_backupJobs.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.backup, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No backup jobs found'),
            Text('Create a backup schedule to get started'),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _backupJobs.length,
      itemBuilder: (context, index) {
        final job = _backupJobs[index];
        return _buildBackupJobCard(job);
      },
    );
  }

  Widget _buildBackupJobCard(BackupJob job) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: job.status.color,
              child: Icon(
                job.type.icon,
                color: Colors.white,
              ),
            ),
            title: Text(job.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Type: ${job.type.displayName}'),
                Text('Schedule: ${job.schedule.displayName}'),
                if (job.lastRunAt != null)
                  Text('Last run: ${_formatDateTime(job.lastRunAt!)}'),
                if (job.nextRunAt != null)
                  Text('Next run: ${_formatDateTime(job.nextRunAt!)}'),
              ],
            ),
            trailing: Switch(
              value: job.isEnabled,
              onChanged: (value) => _toggleBackupJob(job, value),
            ),
          ),
          if (job.retentionPolicy != null) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.schedule, size: 16),
                  const SizedBox(width: 8),
                  Text('Retention: ${job.retentionPolicy!.displayName}'),
                ],
              ),
            ),
          ],
          if (job.status == BackupStatus.running) ...[
            const Divider(),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 16),
                  Text('Backup in progress...'),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRestorePointsTab() {
    if (_restorePoints.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restore, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No restore points available'),
            Text('Create backups to generate restore points'),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _restorePoints.length,
      itemBuilder: (context, index) {
        final point = _restorePoints[index];
        return _buildRestorePointCard(point);
      },
    );
  }

  Widget _buildRestorePointCard(RestorePoint point) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: point.type.color,
              child: Icon(
                point.type.icon,
                color: Colors.white,
              ),
            ),
            title: Text('${point.type.displayName} - ${_formatDateTime(point.createdAt)}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Size: ${_formatFileSize(point.size)}'),
                if (point.description.isNotEmpty)
                  Text('Description: ${point.description}'),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (action) => _handleRestorePointAction(action, point),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'restore',
                  child: Row(
                    children: [
                      Icon(Icons.restore),
                      SizedBox(width: 8),
                      Text('Restore'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'download',
                  child: Row(
                    children: [
                      Icon(Icons.download),
                      SizedBox(width: 8),
                      Text('Download'),
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
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard('Tables', point.metadata['tables'] ?? '0'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard('Records', point.metadata['records'] ?? '0'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard('Version', point.metadata['version'] ?? '1.0'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
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

  void _showActionMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.file_download),
            title: const Text('Create Export'),
            onTap: () {
              Navigator.pop(context);
              _showCreateExportDialog();
            },
          ),
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Schedule Backup'),
            onTap: () {
              Navigator.pop(context);
              _showCreateBackupDialog();
            },
          ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Create Restore Point'),
            onTap: () {
              Navigator.pop(context);
              _createRestorePoint();
            },
          ),
        ],
      ),
    );
  }

  void _showCreateExportDialog() {
    showDialog(
      context: context,
      builder: (context) => _CreateExportDialog(
        onSubmit: (request) async {
          try {
            await ref.read(exportApiServiceProvider).createExportJob(request);
            _loadData();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Export job created')),
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

  void _showCreateBackupDialog() {
    showDialog(
      context: context,
      builder: (context) => _CreateBackupDialog(
        onSubmit: (request) async {
          try {
            await ref.read(exportApiServiceProvider).createBackupJob(request);
            _loadData();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Backup job created')),
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

  void _createRestorePoint() async {
    try {
      await ref.read(exportApiServiceProvider).createRestorePoint(
        'Manual restore point - ${DateTime.now().toIso8601String()}',
      );
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Restore point created')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  void _handleExportAction(String action, ExportJob job) async {
    final service = ref.read(exportApiServiceProvider);
    
    try {
      switch (action) {
        case 'download':
          await service.downloadExport(job.id);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Download started')),
            );
          }
          break;
        case 'share':
          // Implement share functionality
          break;
        case 'cancel':
          await service.cancelExportJob(job.id);
          _loadData();
          break;
        case 'delete':
          final confirmed = await _showDeleteConfirmation('export job');
          if (confirmed) {
            await service.deleteExportJob(job.id);
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

  void _handleRestorePointAction(String action, RestorePoint point) async {
    final service = ref.read(exportApiServiceProvider);
    
    try {
      switch (action) {
        case 'restore':
          final confirmed = await _showRestoreConfirmation();
          if (confirmed) {
            await service.restoreFromPoint(point.id);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Restore initiated')),
              );
            }
          }
          break;
        case 'download':
          await service.downloadRestorePoint(point.id);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Download started')),
            );
          }
          break;
        case 'delete':
          final confirmed = await _showDeleteConfirmation('restore point');
          if (confirmed) {
            await service.deleteRestorePoint(point.id);
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

  void _toggleBackupJob(BackupJob job, bool enabled) async {
    try {
      await ref.read(exportApiServiceProvider).toggleBackupJob(job.id, enabled);
      _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
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

  Future<bool> _showRestoreConfirmation() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Database'),
        content: const Text(
          'This will restore your database to the selected point. All data created after this point will be lost. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Restore'),
          ),
        ],
      ),
    ) ?? false;
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) return '${seconds}s';
    if (seconds < 3600) return '${(seconds / 60).toStringAsFixed(1)}m';
    return '${(seconds / 3600).toStringAsFixed(1)}h';
  }
}

class _CreateExportDialog extends StatefulWidget {
  final Function(CreateExportRequest) onSubmit;

  const _CreateExportDialog({required this.onSubmit});

  @override
  State<_CreateExportDialog> createState() => _CreateExportDialogState();
}

class _CreateExportDialogState extends State<_CreateExportDialog> {
  ExportType _selectedType = ExportType.users;
  ExportFormat _selectedFormat = ExportFormat.csv;
  final Set<String> _selectedFilters = {};

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Export'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<ExportType>(
              decoration: const InputDecoration(
                labelText: 'Data Type',
                border: OutlineInputBorder(),
              ),
              value: _selectedType,
              items: ExportType.values.map(
                (type) => DropdownMenuItem(
                  value: type,
                  child: Text(type.displayName),
                ),
              ).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedType = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ExportFormat>(
              decoration: const InputDecoration(
                labelText: 'Format',
                border: OutlineInputBorder(),
              ),
              value: _selectedFormat,
              items: ExportFormat.values.map(
                (format) => DropdownMenuItem(
                  value: format,
                  child: Text(format.displayName),
                ),
              ).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedFormat = value;
                  });
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final request = CreateExportRequest(
              type: _selectedType,
              format: _selectedFormat,
              filters: _selectedFilters.toList(),
            );
            widget.onSubmit(request);
            Navigator.of(context).pop();
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}

class _CreateBackupDialog extends StatefulWidget {
  final Function(CreateBackupRequest) onSubmit;

  const _CreateBackupDialog({required this.onSubmit});

  @override
  State<_CreateBackupDialog> createState() => _CreateBackupDialogState();
}

class _CreateBackupDialogState extends State<_CreateBackupDialog> {
  final _nameController = TextEditingController();
  BackupType _selectedType = BackupType.full;
  BackupSchedule _selectedSchedule = BackupSchedule.manual;
  RetentionPolicy? _selectedRetention;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Schedule Backup'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Backup Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<BackupType>(
              decoration: const InputDecoration(
                labelText: 'Backup Type',
                border: OutlineInputBorder(),
              ),
              value: _selectedType,
              items: BackupType.values.map(
                (type) => DropdownMenuItem(
                  value: type,
                  child: Text(type.displayName),
                ),
              ).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedType = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<BackupSchedule>(
              decoration: const InputDecoration(
                labelText: 'Schedule',
                border: OutlineInputBorder(),
              ),
              value: _selectedSchedule,
              items: BackupSchedule.values.map(
                (schedule) => DropdownMenuItem(
                  value: schedule,
                  child: Text(schedule.displayName),
                ),
              ).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedSchedule = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<RetentionPolicy>(
              decoration: const InputDecoration(
                labelText: 'Retention Policy',
                border: OutlineInputBorder(),
              ),
              value: _selectedRetention,
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('No retention policy'),
                ),
                ...RetentionPolicy.values.map(
                  (policy) => DropdownMenuItem(
                    value: policy,
                    child: Text(policy.displayName),
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedRetention = value;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final request = CreateBackupRequest(
              name: _nameController.text,
              type: _selectedType,
              schedule: _selectedSchedule,
              retentionPolicy: _selectedRetention,
            );
            widget.onSubmit(request);
            Navigator.of(context).pop();
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}