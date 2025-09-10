import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/export_models.dart';
import '../../../data/services/export_api_service.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';

final exportApiServiceProvider = Provider((ref) =&gt; ExportApiService());

class ExportBackupPage extends ConsumerStatefulWidget {
  const ExportBackupPage({super.key});

  @override
  ConsumerState&lt;ExportBackupPage&gt; createState() =&gt; _ExportBackupPageState();
}

class _ExportBackupPageState extends ConsumerState&lt;ExportBackupPage&gt; 
    with TickerProviderStateMixin {
  late TabController _tabController;
  List&lt;ExportJob&gt; _exportJobs = [];
  List&lt;BackupJob&gt; _backupJobs = [];
  List&lt;RestorePoint&gt; _restorePoints = [];
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

  Future&lt;void&gt; _loadData() async {
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
          _exportJobs = results[0] as List&lt;ExportJob&gt;;
          _backupJobs = results[1] as List&lt;BackupJob&gt;;
          _restorePoints = results[2] as List&lt;RestorePoint&gt;;
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
        title: const Text(&apos;Export &amp; Backup&apos;),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: &apos;Exports&apos;),
            Tab(text: &apos;Backups&apos;),
            Tab(text: &apos;Restore Points&apos;),
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
        onPressed: () =&gt; _showActionMenu(context),
        label: const Text(&apos;Create&apos;),
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
            Text(&apos;No export jobs found&apos;),
            Text(&apos;Create a new export to get started&apos;),
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
                Text(&apos;Format: ${job.format.displayName}&apos;),
                Text(&apos;Created: ${_formatDateTime(job.createdAt)}&apos;),
                if (job.completedAt != null)
                  Text(&apos;Completed: ${_formatDateTime(job.completedAt!)}&apos;),
              ],
            ),
            trailing: PopupMenuButton&lt;String&gt;(
              onSelected: (action) =&gt; _handleExportAction(action, job),
              itemBuilder: (context) =&gt; [
                if (job.status == ExportStatus.completed) ...[
                  const PopupMenuItem(
                    value: &apos;download&apos;,
                    child: Row(
                      children: [
                        Icon(Icons.download),
                        SizedBox(width: 8),
                        Text(&apos;Download&apos;),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: &apos;share&apos;,
                    child: Row(
                      children: [
                        Icon(Icons.share),
                        SizedBox(width: 8),
                        Text(&apos;Share&apos;),
                      ],
                    ),
                  ),
                ],
                if (job.status == ExportStatus.pending || job.status == ExportStatus.running)
                  const PopupMenuItem(
                    value: &apos;cancel&apos;,
                    child: Row(
                      children: [
                        Icon(Icons.cancel),
                        SizedBox(width: 8),
                        Text(&apos;Cancel&apos;),
                      ],
                    ),
                  ),
                const PopupMenuItem(
                  value: &apos;delete&apos;,
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text(&apos;Delete&apos;, style: TextStyle(color: Colors.red)),
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
                  Text(&apos;Progress: ${job.progress.toStringAsFixed(1)}%&apos;),
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
                    child: _buildStatCard(&apos;Records&apos;, job.recordCount.toString()),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(&apos;Size&apos;, _formatFileSize(job.fileSize)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(&apos;Duration&apos;, _formatDuration(job.duration)),
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
                    &apos;Error:&apos;,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  Text(job.errorMessage ?? &apos;Unknown error&apos;),
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
            Text(&apos;No backup jobs found&apos;),
            Text(&apos;Create a backup schedule to get started&apos;),
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
                Text(&apos;Type: ${job.type.displayName}&apos;),
                Text(&apos;Schedule: ${job.schedule.displayName}&apos;),
                if (job.lastRunAt != null)
                  Text(&apos;Last run: ${_formatDateTime(job.lastRunAt!)}&apos;),
                if (job.nextRunAt != null)
                  Text(&apos;Next run: ${_formatDateTime(job.nextRunAt!)}&apos;),
              ],
            ),
            trailing: Switch(
              value: job.isEnabled,
              onChanged: (value) =&gt; _toggleBackupJob(job, value),
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
                  Text(&apos;Retention: ${job.retentionPolicy!.displayName}&apos;),
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
                  Text(&apos;Backup in progress...&apos;),
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
            Text(&apos;No restore points available&apos;),
            Text(&apos;Create backups to generate restore points&apos;),
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
            title: Text(&apos;${point.type.displayName} - ${_formatDateTime(point.createdAt)}&apos;),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(&apos;Size: ${_formatFileSize(point.size)}&apos;),
                if (point.description.isNotEmpty)
                  Text(&apos;Description: ${point.description}&apos;),
              ],
            ),
            trailing: PopupMenuButton&lt;String&gt;(
              onSelected: (action) =&gt; _handleRestorePointAction(action, point),
              itemBuilder: (context) =&gt; [
                const PopupMenuItem(
                  value: &apos;restore&apos;,
                  child: Row(
                    children: [
                      Icon(Icons.restore),
                      SizedBox(width: 8),
                      Text(&apos;Restore&apos;),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: &apos;download&apos;,
                  child: Row(
                    children: [
                      Icon(Icons.download),
                      SizedBox(width: 8),
                      Text(&apos;Download&apos;),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: &apos;delete&apos;,
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text(&apos;Delete&apos;, style: TextStyle(color: Colors.red)),
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
                  child: _buildStatCard(&apos;Tables&apos;, point.metadata[&apos;tables&apos;] ?? &apos;0&apos;),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(&apos;Records&apos;, point.metadata[&apos;records&apos;] ?? &apos;0&apos;),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(&apos;Version&apos;, point.metadata[&apos;version&apos;] ?? &apos;1.0&apos;),
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
      builder: (context) =&gt; Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.file_download),
            title: const Text(&apos;Create Export&apos;),
            onTap: () {
              Navigator.pop(context);
              _showCreateExportDialog();
            },
          ),
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text(&apos;Schedule Backup&apos;),
            onTap: () {
              Navigator.pop(context);
              _showCreateBackupDialog();
            },
          ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text(&apos;Create Restore Point&apos;),
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
      builder: (context) =&gt; _CreateExportDialog(
        onSubmit: (request) async {
          try {
            await ref.read(exportApiServiceProvider).createExportJob(request);
            _loadData();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text(&apos;Export job created&apos;)),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(&apos;Error: ${e.toString()}&apos;)),
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
      builder: (context) =&gt; _CreateBackupDialog(
        onSubmit: (request) async {
          try {
            await ref.read(exportApiServiceProvider).createBackupJob(request);
            _loadData();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text(&apos;Backup job created&apos;)),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(&apos;Error: ${e.toString()}&apos;)),
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
        &apos;Manual restore point - ${DateTime.now().toIso8601String()}&apos;,
      );
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(&apos;Restore point created&apos;)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(&apos;Error: ${e.toString()}&apos;)),
        );
      }
    }
  }

  void _handleExportAction(String action, ExportJob job) async {
    final service = ref.read(exportApiServiceProvider);
    
    try {
      switch (action) {
        case &apos;download&apos;:
          await service.downloadExport(job.id);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text(&apos;Download started&apos;)),
            );
          }
          break;
        case &apos;share&apos;:
          // Implement share functionality
          break;
        case &apos;cancel&apos;:
          await service.cancelExportJob(job.id);
          _loadData();
          break;
        case &apos;delete&apos;:
          final confirmed = await _showDeleteConfirmation(&apos;export job&apos;);
          if (confirmed) {
            await service.deleteExportJob(job.id);
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

  void _handleRestorePointAction(String action, RestorePoint point) async {
    final service = ref.read(exportApiServiceProvider);
    
    try {
      switch (action) {
        case &apos;restore&apos;:
          final confirmed = await _showRestoreConfirmation();
          if (confirmed) {
            await service.restoreFromPoint(point.id);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text(&apos;Restore initiated&apos;)),
              );
            }
          }
          break;
        case &apos;download&apos;:
          await service.downloadRestorePoint(point.id);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text(&apos;Download started&apos;)),
            );
          }
          break;
        case &apos;delete&apos;:
          final confirmed = await _showDeleteConfirmation(&apos;restore point&apos;);
          if (confirmed) {
            await service.deleteRestorePoint(point.id);
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

  void _toggleBackupJob(BackupJob job, bool enabled) async {
    try {
      await ref.read(exportApiServiceProvider).toggleBackupJob(job.id, enabled);
      _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(&apos;Error: ${e.toString()}&apos;)),
        );
      }
    }
  }

  Future&lt;bool&gt; _showDeleteConfirmation(String itemType) async {
    return await showDialog&lt;bool&gt;(
      context: context,
      builder: (context) =&gt; AlertDialog(
        title: Text(&apos;Delete ${itemType[0].toUpperCase()}${itemType.substring(1)}&apos;),
        content: Text(&apos;Are you sure you want to delete this $itemType?&apos;),
        actions: [
          TextButton(
            onPressed: () =&gt; Navigator.of(context).pop(false),
            child: const Text(&apos;Cancel&apos;),
          ),
          TextButton(
            onPressed: () =&gt; Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text(&apos;Delete&apos;),
          ),
        ],
      ),
    ) ?? false;
  }

  Future&lt;bool&gt; _showRestoreConfirmation() async {
    return await showDialog&lt;bool&gt;(
      context: context,
      builder: (context) =&gt; AlertDialog(
        title: const Text(&apos;Restore Database&apos;),
        content: const Text(
          &apos;This will restore your database to the selected point. All data created after this point will be lost. Are you sure?&apos;,
        ),
        actions: [
          TextButton(
            onPressed: () =&gt; Navigator.of(context).pop(false),
            child: const Text(&apos;Cancel&apos;),
          ),
          TextButton(
            onPressed: () =&gt; Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text(&apos;Restore&apos;),
          ),
        ],
      ),
    ) ?? false;
  }

  String _formatDateTime(DateTime dateTime) {
    return &apos;${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, &apos;0&apos;)}&apos;;
  }

  String _formatFileSize(int bytes) {
    if (bytes &lt; 1024) return &apos;${bytes}B&apos;;
    if (bytes &lt; 1024 * 1024) return &apos;${(bytes / 1024).toStringAsFixed(1)}KB&apos;;
    if (bytes &lt; 1024 * 1024 * 1024) return &apos;${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB&apos;;
    return &apos;${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB&apos;;
  }

  String _formatDuration(int seconds) {
    if (seconds &lt; 60) return &apos;${seconds}s&apos;;
    if (seconds &lt; 3600) return &apos;${(seconds / 60).toStringAsFixed(1)}m&apos;;
    return &apos;${(seconds / 3600).toStringAsFixed(1)}h&apos;;
  }
}

class _CreateExportDialog extends StatefulWidget {
  final Function(CreateExportRequest) onSubmit;

  const _CreateExportDialog({required this.onSubmit});

  @override
  State&lt;_CreateExportDialog&gt; createState() =&gt; _CreateExportDialogState();
}

class _CreateExportDialogState extends State&lt;_CreateExportDialog&gt; {
  ExportType _selectedType = ExportType.users;
  ExportFormat _selectedFormat = ExportFormat.csv;
  final Set&lt;String&gt; _selectedFilters = {};

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(&apos;Create Export&apos;),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField&lt;ExportType&gt;(
              decoration: const InputDecoration(
                labelText: &apos;Data Type&apos;,
                border: OutlineInputBorder(),
              ),
              value: _selectedType,
              items: ExportType.values.map(
                (type) =&gt; DropdownMenuItem(
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
            DropdownButtonFormField&lt;ExportFormat&gt;(
              decoration: const InputDecoration(
                labelText: &apos;Format&apos;,
                border: OutlineInputBorder(),
              ),
              value: _selectedFormat,
              items: ExportFormat.values.map(
                (format) =&gt; DropdownMenuItem(
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
          onPressed: () =&gt; Navigator.of(context).pop(),
          child: const Text(&apos;Cancel&apos;),
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
          child: const Text(&apos;Create&apos;),
        ),
      ],
    );
  }
}

class _CreateBackupDialog extends StatefulWidget {
  final Function(CreateBackupRequest) onSubmit;

  const _CreateBackupDialog({required this.onSubmit});

  @override
  State&lt;_CreateBackupDialog&gt; createState() =&gt; _CreateBackupDialogState();
}

class _CreateBackupDialogState extends State&lt;_CreateBackupDialog&gt; {
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
      title: const Text(&apos;Schedule Backup&apos;),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: &apos;Backup Name&apos;,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField&lt;BackupType&gt;(
              decoration: const InputDecoration(
                labelText: &apos;Backup Type&apos;,
                border: OutlineInputBorder(),
              ),
              value: _selectedType,
              items: BackupType.values.map(
                (type) =&gt; DropdownMenuItem(
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
            DropdownButtonFormField&lt;BackupSchedule&gt;(
              decoration: const InputDecoration(
                labelText: &apos;Schedule&apos;,
                border: OutlineInputBorder(),
              ),
              value: _selectedSchedule,
              items: BackupSchedule.values.map(
                (schedule) =&gt; DropdownMenuItem(
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
            DropdownButtonFormField&lt;RetentionPolicy&gt;(
              decoration: const InputDecoration(
                labelText: &apos;Retention Policy&apos;,
                border: OutlineInputBorder(),
              ),
              value: _selectedRetention,
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text(&apos;No retention policy&apos;),
                ),
                ...RetentionPolicy.values.map(
                  (policy) =&gt; DropdownMenuItem(
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
          onPressed: () =&gt; Navigator.of(context).pop(),
          child: const Text(&apos;Cancel&apos;),
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
          child: const Text(&apos;Create&apos;),
        ),
      ],
    );
  }
}