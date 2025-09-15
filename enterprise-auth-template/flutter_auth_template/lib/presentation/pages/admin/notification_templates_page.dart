import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/notification_models.dart';
import '../../../data/services/notification_api_service.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';

final notificationApiServiceProvider = Provider((ref) => NotificationApiService());

class NotificationTemplatesPage extends ConsumerStatefulWidget {
  const NotificationTemplatesPage({super.key});

  @override
  ConsumerState<NotificationTemplatesPage> createState() => _NotificationTemplatesPageState();
}

class _NotificationTemplatesPageState extends ConsumerState<NotificationTemplatesPage> 
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<NotificationTemplate> _templates = [];
  List<NotificationBatch> _batches = [];
  List<NotificationSubscription> _subscriptions = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  NotificationType? _selectedTypeFilter;

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

      final service = ref.read(notificationApiServiceProvider);
      final results = await Future.wait([
        service.getTemplates(),
        service.getBatches(),
        service.getSubscriptions(),
      ]);

      if (mounted) {
        setState(() {
          _templates = results[0] as List<NotificationTemplate>;
          _batches = results[1] as List<NotificationBatch>;
          _subscriptions = results[2] as List<NotificationSubscription>;
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
        title: const Text('Notification Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Templates'),
            Tab(text: 'Batches'),
            Tab(text: 'Subscriptions'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTemplatesTab(),
          _buildBatchesTab(),
          _buildSubscriptionsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateMenu(context),
        label: const Text('Create'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTemplatesTab() {
    final filteredTemplates = _templates.where((template) {
      final matchesSearch = _searchQuery.isEmpty ||
          template.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          template.description.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesType = _selectedTypeFilter == null ||
          template.type == _selectedTypeFilter;
      
      return matchesSearch && matchesType;
    }).toList();

    return Column(
      children: [
        _buildTemplateFilters(),
        Expanded(
          child: filteredTemplates.isEmpty
              ? const Center(child: Text('No templates found'))
              : ListView.builder(
                  itemCount: filteredTemplates.length,
                  itemBuilder: (context, index) {
                    final template = filteredTemplates[index];
                    return _buildTemplateCard(template);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTemplateFilters() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              hintText: 'Search templates...',
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
          DropdownButtonFormField<NotificationType>(
            decoration: const InputDecoration(
              labelText: 'Filter by Type',
              border: OutlineInputBorder(),
            ),
            value: _selectedTypeFilter,
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text('All Types'),
              ),
              ...NotificationType.values.map(
                (type) => DropdownMenuItem(
                  value: type,
                  child: Text(type.displayName),
                ),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _selectedTypeFilter = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(NotificationTemplate template) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: template.type.color,
          child: Icon(
            _getTypeIcon(template.type),
            color: Colors.white,
          ),
        ),
        title: Text(template.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(template.description),
            const SizedBox(height: 4),
            Chip(
              label: Text(
                template.type.displayName,
                style: const TextStyle(fontSize: 10),
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (action) => _handleTemplateAction(action, template),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'test',
              child: Row(
                children: [
                  Icon(Icons.send),
                  SizedBox(width: 8),
                  Text('Send Test'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'batch',
              child: Row(
                children: [
                  Icon(Icons.batch_prediction),
                  SizedBox(width: 8),
                  Text('Create Batch'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'clone',
              child: Row(
                children: [
                  Icon(Icons.copy),
                  SizedBox(width: 8),
                  Text('Clone'),
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
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Title Template:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(top: 4, bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(template.titleTemplate),
                ),
                const Text(
                  'Content Template:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(top: 4, bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(template.contentTemplate),
                ),
                if (template.variables?.isNotEmpty ?? false) ...[
                  const Text(
                    'Variables:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    children: template.variables!.keys.map((key) => Chip(
                      label: Text('{$key}', style: const TextStyle(fontSize: 10)),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    )).toList(),
                  ),
                ],
                if (template.channelSettings != null) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Channel Settings:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  _buildChannelSettings(template.channelSettings!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChannelSettings(NotificationChannelSettings settings) {
    final enabledChannels = <String>[];
    if (settings.inApp) enabledChannels.add('In-App');
    if (settings.email) enabledChannels.add('Email');
    if (settings.sms) enabledChannels.add('SMS');
    if (settings.push) enabledChannels.add('Push');
    if (settings.webhook) enabledChannels.add('Webhook');

    return Wrap(
      spacing: 4,
      children: enabledChannels.map((channel) => Chip(
        label: Text(channel, style: const TextStyle(fontSize: 10)),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        backgroundColor: Colors.green.withOpacity(0.2),
      )).toList(),
    );
  }

  Widget _buildBatchesTab() {
    return ListView.builder(
      itemCount: _batches.length,
      itemBuilder: (context, index) {
        final batch = _batches[index];
        return _buildBatchCard(batch);
      },
    );
  }

  Widget _buildBatchCard(NotificationBatch batch) {
    final progress = batch.totalCount > 0 
        ? (batch.successCount + batch.failureCount) / batch.totalCount 
        : 0.0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: batch.status.color,
              child: Icon(
                _getBatchStatusIcon(batch.status),
                color: Colors.white,
              ),
            ),
            title: Text(batch.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Recipients: ${batch.recipients.length}'),
                Text('Status: ${batch.status.displayName}'),
                Text('Created: ${_formatDateTime(batch.createdAt)}'),
                if (batch.scheduledAt != null)
                  Text('Scheduled: ${_formatDateTime(batch.scheduledAt!)}'),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (action) => _handleBatchAction(action, batch),
              itemBuilder: (context) => [
                if (batch.status == NotificationBatchStatus.scheduled ||
                    batch.status == NotificationBatchStatus.draft)
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
                  value: 'details',
                  child: Row(
                    children: [
                      Icon(Icons.visibility),
                      SizedBox(width: 8),
                      Text('View Details'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (batch.status == NotificationBatchStatus.processing) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  LinearProgressIndicator(value: progress),
                  const SizedBox(height: 8),
                  Text('Progress: ${(progress * 100).toStringAsFixed(1)}%'),
                ],
              ),
            ),
          ],
          if (batch.status == NotificationBatchStatus.completed ||
              batch.status == NotificationBatchStatus.failed) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard('Total', batch.totalCount.toString(), Colors.blue),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard('Success', batch.successCount.toString(), Colors.green),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard('Failed', batch.failureCount.toString(), Colors.red),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSubscriptionsTab() {
    return ListView.builder(
      itemCount: _subscriptions.length,
      itemBuilder: (context, index) {
        final subscription = _subscriptions[index];
        return _buildSubscriptionCard(subscription);
      },
    );
  }

  Widget _buildSubscriptionCard(NotificationSubscription subscription) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: subscription.isActive ? Colors.green : Colors.grey,
          child: Icon(
            _getChannelIcon(subscription.channel),
            color: Colors.white,
          ),
        ),
        title: Text(subscription.channel.displayName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subscription.endpoint),
            Text('Created: ${_formatDateTime(subscription.createdAt!)}'),
            if (subscription.lastUsedAt != null)
              Text('Last used: ${_formatDateTime(subscription.lastUsedAt!)}'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (action) => _handleSubscriptionAction(action, subscription),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'test',
              child: Row(
                children: [
                  Icon(Icons.send),
                  SizedBox(width: 8),
                  Text('Test'),
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
              fontSize: 18,
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

  void _showCreateMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.template_sharp),
            title: const Text('Create Template'),
            onTap: () {
              Navigator.pop(context);
              _showCreateTemplateDialog();
            },
          ),
          ListTile(
            leading: const Icon(Icons.batch_prediction),
            title: const Text('Create Batch'),
            onTap: () {
              Navigator.pop(context);
              _showCreateBatchDialog();
            },
          ),
          ListTile(
            leading: const Icon(Icons.subscriptions),
            title: const Text('Add Subscription'),
            onTap: () {
              Navigator.pop(context);
              _showCreateSubscriptionDialog();
            },
          ),
        ],
      ),
    );
  }

  void _showCreateTemplateDialog() {
    showDialog(
      context: context,
      builder: (context) => _TemplateEditDialog(
        onSaved: (template) async {
          try {
            await ref.read(notificationApiServiceProvider).createTemplate(template);
            _loadData();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Template created successfully')),
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

  void _showCreateBatchDialog() {
    if (_templates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No templates available. Create a template first.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => _BatchCreateDialog(
        templates: _templates,
        onSaved: (title, recipients, templateId, variables, scheduledAt) async {
          try {
            await ref.read(notificationApiServiceProvider).createBatch(
              title: title,
              recipients: recipients,
              templateId: templateId,
              variables: variables,
              scheduledAt: scheduledAt,
            );
            _loadData();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Batch created successfully')),
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

  void _showCreateSubscriptionDialog() {
    showDialog(
      context: context,
      builder: (context) => _SubscriptionCreateDialog(
        onSaved: (channel, endpoint, credentials) async {
          try {
            await ref.read(notificationApiServiceProvider).createSubscription(
              channel: channel,
              endpoint: endpoint,
              credentials: credentials,
            );
            _loadData();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Subscription created successfully')),
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

  void _handleTemplateAction(String action, NotificationTemplate template) async {
    final service = ref.read(notificationApiServiceProvider);
    
    try {
      switch (action) {
        case 'edit':
          _showEditTemplateDialog(template);
          break;
        case 'test':
          await service.sendTestNotification(
            title: template.titleTemplate,
            content: template.contentTemplate,
            type: template.type,
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Test notification sent')),
            );
          }
          break;
        case 'batch':
          // Open batch creation with this template selected
          _showCreateBatchDialog();
          break;
        case 'clone':
          final cloned = template.copyWith(
            id: '', // Will be assigned by server
            name: '${template.name} (Copy)',
            createdAt: null,
            updatedAt: null,
          );
          await service.createTemplate(cloned);
          _loadData();
          break;
        case 'delete':
          final confirmed = await _showDeleteConfirmation(template.name);
          if (confirmed) {
            await service.deleteTemplate(template.id);
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

  void _handleBatchAction(String action, NotificationBatch batch) async {
    final service = ref.read(notificationApiServiceProvider);
    
    try {
      switch (action) {
        case 'cancel':
          await service.cancelBatch(batch.id);
          _loadData();
          break;
        case 'details':
          _showBatchDetails(batch);
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

  void _handleSubscriptionAction(String action, NotificationSubscription subscription) async {
    final service = ref.read(notificationApiServiceProvider);
    
    try {
      switch (action) {
        case 'test':
          await service.sendTestNotification(
            title: 'Test Notification',
            content: 'This is a test notification for ${subscription.channel.displayName}',
            channels: [subscription.channel],
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Test notification sent')),
            );
          }
          break;
        case 'delete':
          final confirmed = await _showDeleteConfirmation('subscription');
          if (confirmed) {
            await service.deleteSubscription(subscription.id);
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

  void _showEditTemplateDialog(NotificationTemplate template) {
    showDialog(
      context: context,
      builder: (context) => _TemplateEditDialog(
        template: template,
        onSaved: (updatedTemplate) async {
          try {
            await ref.read(notificationApiServiceProvider)
                .updateTemplate(template.id, updatedTemplate);
            _loadData();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Template updated successfully')),
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

  void _showBatchDetails(NotificationBatch batch) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Batch Details: ${batch.title}'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('Status', batch.status.displayName),
                _buildDetailRow('Total Recipients', batch.totalCount.toString()),
                _buildDetailRow('Successful', batch.successCount.toString()),
                _buildDetailRow('Failed', batch.failureCount.toString()),
                _buildDetailRow('Created', _formatDateTime(batch.createdAt)),
                if (batch.scheduledAt != null)
                  _buildDetailRow('Scheduled', _formatDateTime(batch.scheduledAt!)),
                if (batch.completedAt != null)
                  _buildDetailRow('Completed', _formatDateTime(batch.completedAt!)),
                if (batch.errorMessage != null) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Error Message:',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                  Text(batch.errorMessage!, style: const TextStyle(color: Colors.red)),
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

  Future<bool> _showDeleteConfirmation(String itemName) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete "$itemName"?'),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
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

  IconData _getTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.info:
        return Icons.info;
      case NotificationType.warning:
        return Icons.warning;
      case NotificationType.error:
        return Icons.error;
      case NotificationType.success:
        return Icons.check_circle;
      case NotificationType.security:
        return Icons.security;
      case NotificationType.system:
        return Icons.settings;
      case NotificationType.marketing:
        return Icons.campaign;
      case NotificationType.reminder:
        return Icons.schedule;
      case NotificationType.announcement:
        return Icons.announcement;
    }
  }

  IconData _getBatchStatusIcon(NotificationBatchStatus status) {
    switch (status) {
      case NotificationBatchStatus.draft:
        return Icons.drafts;
      case NotificationBatchStatus.scheduled:
        return Icons.schedule;
      case NotificationBatchStatus.processing:
        return Icons.hourglass_empty;
      case NotificationBatchStatus.completed:
        return Icons.check_circle;
      case NotificationBatchStatus.failed:
        return Icons.error;
      case NotificationBatchStatus.cancelled:
        return Icons.cancel;
    }
  }

  IconData _getChannelIcon(NotificationChannel channel) {
    switch (channel) {
      case NotificationChannel.inApp:
        return Icons.notifications;
      case NotificationChannel.email:
        return Icons.email;
      case NotificationChannel.sms:
        return Icons.sms;
      case NotificationChannel.push:
        return Icons.mobile_friendly;
      case NotificationChannel.webhook:
        return Icons.webhook;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

// Template Edit Dialog
class _TemplateEditDialog extends StatefulWidget {
  final NotificationTemplate? template;
  final Function(NotificationTemplate) onSaved;

  const _TemplateEditDialog({
    this.template,
    required this.onSaved,
  });

  @override
  State<_TemplateEditDialog> createState() => _TemplateEditDialogState();
}

class _TemplateEditDialogState extends State<_TemplateEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _titleTemplateController;
  late TextEditingController _contentTemplateController;
  NotificationType _selectedType = NotificationType.info;
  NotificationPriority _selectedPriority = NotificationPriority.normal;
  NotificationChannelSettings _channelSettings = const NotificationChannelSettings();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.template?.name ?? '');
    _descriptionController = TextEditingController(text: widget.template?.description ?? '');
    _titleTemplateController = TextEditingController(text: widget.template?.titleTemplate ?? '');
    _contentTemplateController = TextEditingController(text: widget.template?.contentTemplate ?? '');
    
    if (widget.template != null) {
      _selectedType = widget.template!.type;
      _selectedPriority = widget.template!.defaultPriority ?? NotificationPriority.normal;
      _channelSettings = widget.template!.channelSettings ?? const NotificationChannelSettings();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _titleTemplateController.dispose();
    _contentTemplateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.template == null ? 'Create Template' : 'Edit Template'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value?.isEmpty ?? true ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<NotificationType>(
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedType,
                  items: NotificationType.values.map(
                    (type) => DropdownMenuItem(
                      value: type,
                      child: Text(type.displayName),
                    ),
                  ).toList(),
                  onChanged: (value) => setState(() => _selectedType = value!),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleTemplateController,
                  decoration: const InputDecoration(
                    labelText: 'Title Template',
                    border: OutlineInputBorder(),
                    hintText: 'Use {variable_name} for dynamic content',
                  ),
                  validator: (value) => value?.isEmpty ?? true ? 'Title template is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contentTemplateController,
                  decoration: const InputDecoration(
                    labelText: 'Content Template',
                    border: OutlineInputBorder(),
                    hintText: 'Use {variable_name} for dynamic content',
                  ),
                  maxLines: 3,
                  validator: (value) => value?.isEmpty ?? true ? 'Content template is required' : null,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveTemplate,
          child: Text(widget.template == null ? 'Create' : 'Save'),
        ),
      ],
    );
  }

  void _saveTemplate() {
    if (_formKey.currentState?.validate() ?? false) {
      final template = NotificationTemplate(
        id: widget.template?.id ?? '',
        name: _nameController.text,
        description: _descriptionController.text,
        type: _selectedType,
        titleTemplate: _titleTemplateController.text,
        contentTemplate: _contentTemplateController.text,
        defaultPriority: _selectedPriority,
        channelSettings: _channelSettings,
        isActive: true,
      );
      
      widget.onSaved(template);
      Navigator.of(context).pop();
    }
  }
}

// Batch Create Dialog
class _BatchCreateDialog extends StatefulWidget {
  final List<NotificationTemplate> templates;
  final Function(String, List<String>, String, Map<String, dynamic>, DateTime?) onSaved;

  const _BatchCreateDialog({
    required this.templates,
    required this.onSaved,
  });

  @override
  State<_BatchCreateDialog> createState() => _BatchCreateDialogState();
}

class _BatchCreateDialogState extends State<_BatchCreateDialog> {
  final _titleController = TextEditingController();
  final _recipientsController = TextEditingController();
  NotificationTemplate? _selectedTemplate;
  DateTime? _scheduledAt;

  @override
  void dispose() {
    _titleController.dispose();
    _recipientsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Notification Batch'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Batch Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<NotificationTemplate>(
              decoration: const InputDecoration(
                labelText: 'Template',
                border: OutlineInputBorder(),
              ),
              value: _selectedTemplate,
              items: widget.templates.map(
                (template) => DropdownMenuItem(
                  value: template,
                  child: Text(template.name),
                ),
              ).toList(),
              onChanged: (value) => setState(() => _selectedTemplate = value),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _recipientsController,
              decoration: const InputDecoration(
                labelText: 'Recipients (comma-separated)',
                border: OutlineInputBorder(),
                hintText: 'user1@example.com, user2@example.com',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Schedule for later'),
              subtitle: _scheduledAt != null 
                  ? Text('Scheduled: ${_scheduledAt!.toString().split('.')[0]}')
                  : const Text('Send immediately'),
              trailing: const Icon(Icons.schedule),
              onTap: _pickScheduleTime,
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
          onPressed: _selectedTemplate == null || 
                     _titleController.text.isEmpty ||
                     _recipientsController.text.isEmpty
              ? null
              : _createBatch,
          child: const Text('Create'),
        ),
      ],
    );
  }

  void _pickScheduleTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        setState(() {
          _scheduledAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
        });
      }
    }
  }

  void _createBatch() {
    final recipients = _recipientsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    widget.onSaved(
      _titleController.text,
      recipients,
      _selectedTemplate!.id,
      {}, // Variables would be collected from template
      _scheduledAt,
    );
    Navigator.of(context).pop();
  }
}

// Subscription Create Dialog
class _SubscriptionCreateDialog extends StatefulWidget {
  final Function(NotificationChannel, String, Map<String, dynamic>?) onSaved;

  const _SubscriptionCreateDialog({
    required this.onSaved,
  });

  @override
  State<_SubscriptionCreateDialog> createState() => _SubscriptionCreateDialogState();
}

class _SubscriptionCreateDialogState extends State<_SubscriptionCreateDialog> {
  final _endpointController = TextEditingController();
  NotificationChannel _selectedChannel = NotificationChannel.webhook;

  @override
  void dispose() {
    _endpointController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Subscription'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<NotificationChannel>(
            decoration: const InputDecoration(
              labelText: 'Channel',
              border: OutlineInputBorder(),
            ),
            value: _selectedChannel,
            items: NotificationChannel.values.map(
              (channel) => DropdownMenuItem(
                value: channel,
                child: Text(channel.displayName),
              ),
            ).toList(),
            onChanged: (value) => setState(() => _selectedChannel = value!),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _endpointController,
            decoration: InputDecoration(
              labelText: _getEndpointLabel(_selectedChannel),
              border: const OutlineInputBorder(),
              hintText: _getEndpointHint(_selectedChannel),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _endpointController.text.isEmpty ? null : _createSubscription,
          child: const Text('Add'),
        ),
      ],
    );
  }

  String _getEndpointLabel(NotificationChannel channel) {
    switch (channel) {
      case NotificationChannel.webhook:
        return 'Webhook URL';
      case NotificationChannel.email:
        return 'Email Address';
      case NotificationChannel.sms:
        return 'Phone Number';
      case NotificationChannel.push:
        return 'Device Token';
      case NotificationChannel.inApp:
        return 'User ID';
    }
  }

  String _getEndpointHint(NotificationChannel channel) {
    switch (channel) {
      case NotificationChannel.webhook:
        return 'https://example.com/webhook';
      case NotificationChannel.email:
        return 'user@example.com';
      case NotificationChannel.sms:
        return '+1234567890';
      case NotificationChannel.push:
        return 'Device registration token';
      case NotificationChannel.inApp:
        return 'user123';
    }
  }

  void _createSubscription() {
    widget.onSaved(_selectedChannel, _endpointController.text, null);
    Navigator.of(context).pop();
  }
}