import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/notification_models.dart';
import '../../../data/services/notification_api_service.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';

final notificationApiServiceProvider = Provider((ref) =&gt; NotificationApiService());

class NotificationTemplatesPage extends ConsumerStatefulWidget {
  const NotificationTemplatesPage({super.key});

  @override
  ConsumerState&lt;NotificationTemplatesPage&gt; createState() =&gt; _NotificationTemplatesPageState();
}

class _NotificationTemplatesPageState extends ConsumerState&lt;NotificationTemplatesPage&gt; 
    with TickerProviderStateMixin {
  late TabController _tabController;
  List&lt;NotificationTemplate&gt; _templates = [];
  List&lt;NotificationBatch&gt; _batches = [];
  List&lt;NotificationSubscription&gt; _subscriptions = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = &apos;&apos;;
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

  Future&lt;void&gt; _loadData() async {
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
          _templates = results[0] as List&lt;NotificationTemplate&gt;;
          _batches = results[1] as List&lt;NotificationBatch&gt;;
          _subscriptions = results[2] as List&lt;NotificationSubscription&gt;;
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
        title: const Text(&apos;Notification Management&apos;),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: &apos;Templates&apos;),
            Tab(text: &apos;Batches&apos;),
            Tab(text: &apos;Subscriptions&apos;),
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
        onPressed: () =&gt; _showCreateMenu(context),
        label: const Text(&apos;Create&apos;),
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
      
      return matchesSearch &amp;&amp; matchesType;
    }).toList();

    return Column(
      children: [
        _buildTemplateFilters(),
        Expanded(
          child: filteredTemplates.isEmpty
              ? const Center(child: Text(&apos;No templates found&apos;))
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
              hintText: &apos;Search templates...&apos;,
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
          DropdownButtonFormField&lt;NotificationType&gt;(
            decoration: const InputDecoration(
              labelText: &apos;Filter by Type&apos;,
              border: OutlineInputBorder(),
            ),
            value: _selectedTypeFilter,
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text(&apos;All Types&apos;),
              ),
              ...NotificationType.values.map(
                (type) =&gt; DropdownMenuItem(
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
        trailing: PopupMenuButton&lt;String&gt;(
          onSelected: (action) =&gt; _handleTemplateAction(action, template),
          itemBuilder: (context) =&gt; [
            const PopupMenuItem(
              value: &apos;edit&apos;,
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text(&apos;Edit&apos;),
                ],
              ),
            ),
            const PopupMenuItem(
              value: &apos;test&apos;,
              child: Row(
                children: [
                  Icon(Icons.send),
                  SizedBox(width: 8),
                  Text(&apos;Send Test&apos;),
                ],
              ),
            ),
            const PopupMenuItem(
              value: &apos;batch&apos;,
              child: Row(
                children: [
                  Icon(Icons.batch_prediction),
                  SizedBox(width: 8),
                  Text(&apos;Create Batch&apos;),
                ],
              ),
            ),
            const PopupMenuItem(
              value: &apos;clone&apos;,
              child: Row(
                children: [
                  Icon(Icons.copy),
                  SizedBox(width: 8),
                  Text(&apos;Clone&apos;),
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
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  &apos;Title Template:&apos;,
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
                  &apos;Content Template:&apos;,
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
                    &apos;Variables:&apos;,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    children: template.variables!.keys.map((key) =&gt; Chip(
                      label: Text(&apos;{$key}&apos;, style: const TextStyle(fontSize: 10)),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    )).toList(),
                  ),
                ],
                if (template.channelSettings != null) ...[
                  const SizedBox(height: 8),
                  const Text(
                    &apos;Channel Settings:&apos;,
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
    final enabledChannels = &lt;String&gt;[];
    if (settings.inApp) enabledChannels.add(&apos;In-App&apos;);
    if (settings.email) enabledChannels.add(&apos;Email&apos;);
    if (settings.sms) enabledChannels.add(&apos;SMS&apos;);
    if (settings.push) enabledChannels.add(&apos;Push&apos;);
    if (settings.webhook) enabledChannels.add(&apos;Webhook&apos;);

    return Wrap(
      spacing: 4,
      children: enabledChannels.map((channel) =&gt; Chip(
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
    final progress = batch.totalCount &gt; 0 
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
                Text(&apos;Recipients: ${batch.recipients.length}&apos;),
                Text(&apos;Status: ${batch.status.displayName}&apos;),
                Text(&apos;Created: ${_formatDateTime(batch.createdAt)}&apos;),
                if (batch.scheduledAt != null)
                  Text(&apos;Scheduled: ${_formatDateTime(batch.scheduledAt!)}&apos;),
              ],
            ),
            trailing: PopupMenuButton&lt;String&gt;(
              onSelected: (action) =&gt; _handleBatchAction(action, batch),
              itemBuilder: (context) =&gt; [
                if (batch.status == NotificationBatchStatus.scheduled ||
                    batch.status == NotificationBatchStatus.draft)
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
                  value: &apos;details&apos;,
                  child: Row(
                    children: [
                      Icon(Icons.visibility),
                      SizedBox(width: 8),
                      Text(&apos;View Details&apos;),
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
                  Text(&apos;Progress: ${(progress * 100).toStringAsFixed(1)}%&apos;),
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
                    child: _buildStatCard(&apos;Total&apos;, batch.totalCount.toString(), Colors.blue),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard(&apos;Success&apos;, batch.successCount.toString(), Colors.green),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard(&apos;Failed&apos;, batch.failureCount.toString(), Colors.red),
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
            Text(&apos;Created: ${_formatDateTime(subscription.createdAt!)}&apos;),
            if (subscription.lastUsedAt != null)
              Text(&apos;Last used: ${_formatDateTime(subscription.lastUsedAt!)}&apos;),
          ],
        ),
        trailing: PopupMenuButton&lt;String&gt;(
          onSelected: (action) =&gt; _handleSubscriptionAction(action, subscription),
          itemBuilder: (context) =&gt; [
            const PopupMenuItem(
              value: &apos;test&apos;,
              child: Row(
                children: [
                  Icon(Icons.send),
                  SizedBox(width: 8),
                  Text(&apos;Test&apos;),
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
      builder: (context) =&gt; Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.template_sharp),
            title: const Text(&apos;Create Template&apos;),
            onTap: () {
              Navigator.pop(context);
              _showCreateTemplateDialog();
            },
          ),
          ListTile(
            leading: const Icon(Icons.batch_prediction),
            title: const Text(&apos;Create Batch&apos;),
            onTap: () {
              Navigator.pop(context);
              _showCreateBatchDialog();
            },
          ),
          ListTile(
            leading: const Icon(Icons.subscriptions),
            title: const Text(&apos;Add Subscription&apos;),
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
      builder: (context) =&gt; _TemplateEditDialog(
        onSaved: (template) async {
          try {
            await ref.read(notificationApiServiceProvider).createTemplate(template);
            _loadData();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text(&apos;Template created successfully&apos;)),
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

  void _showCreateBatchDialog() {
    if (_templates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(&apos;No templates available. Create a template first.&apos;)),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) =&gt; _BatchCreateDialog(
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
                const SnackBar(content: Text(&apos;Batch created successfully&apos;)),
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

  void _showCreateSubscriptionDialog() {
    showDialog(
      context: context,
      builder: (context) =&gt; _SubscriptionCreateDialog(
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
                const SnackBar(content: Text(&apos;Subscription created successfully&apos;)),
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

  void _handleTemplateAction(String action, NotificationTemplate template) async {
    final service = ref.read(notificationApiServiceProvider);
    
    try {
      switch (action) {
        case &apos;edit&apos;:
          _showEditTemplateDialog(template);
          break;
        case &apos;test&apos;:
          await service.sendTestNotification(
            title: template.titleTemplate,
            content: template.contentTemplate,
            type: template.type,
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text(&apos;Test notification sent&apos;)),
            );
          }
          break;
        case &apos;batch&apos;:
          // Open batch creation with this template selected
          _showCreateBatchDialog();
          break;
        case &apos;clone&apos;:
          final cloned = template.copyWith(
            id: &apos;&apos;, // Will be assigned by server
            name: &apos;${template.name} (Copy)&apos;,
            createdAt: null,
            updatedAt: null,
          );
          await service.createTemplate(cloned);
          _loadData();
          break;
        case &apos;delete&apos;:
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
          SnackBar(content: Text(&apos;Error: ${e.toString()}&apos;)),
        );
      }
    }
  }

  void _handleBatchAction(String action, NotificationBatch batch) async {
    final service = ref.read(notificationApiServiceProvider);
    
    try {
      switch (action) {
        case &apos;cancel&apos;:
          await service.cancelBatch(batch.id);
          _loadData();
          break;
        case &apos;details&apos;:
          _showBatchDetails(batch);
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

  void _handleSubscriptionAction(String action, NotificationSubscription subscription) async {
    final service = ref.read(notificationApiServiceProvider);
    
    try {
      switch (action) {
        case &apos;test&apos;:
          await service.sendTestNotification(
            title: &apos;Test Notification&apos;,
            content: &apos;This is a test notification for ${subscription.channel.displayName}&apos;,
            channels: [subscription.channel],
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text(&apos;Test notification sent&apos;)),
            );
          }
          break;
        case &apos;delete&apos;:
          final confirmed = await _showDeleteConfirmation(&apos;subscription&apos;);
          if (confirmed) {
            await service.deleteSubscription(subscription.id);
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

  void _showEditTemplateDialog(NotificationTemplate template) {
    showDialog(
      context: context,
      builder: (context) =&gt; _TemplateEditDialog(
        template: template,
        onSaved: (updatedTemplate) async {
          try {
            await ref.read(notificationApiServiceProvider)
                .updateTemplate(template.id, updatedTemplate);
            _loadData();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text(&apos;Template updated successfully&apos;)),
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

  void _showBatchDetails(NotificationBatch batch) {
    showDialog(
      context: context,
      builder: (context) =&gt; AlertDialog(
        title: Text(&apos;Batch Details: ${batch.title}&apos;),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow(&apos;Status&apos;, batch.status.displayName),
                _buildDetailRow(&apos;Total Recipients&apos;, batch.totalCount.toString()),
                _buildDetailRow(&apos;Successful&apos;, batch.successCount.toString()),
                _buildDetailRow(&apos;Failed&apos;, batch.failureCount.toString()),
                _buildDetailRow(&apos;Created&apos;, _formatDateTime(batch.createdAt)),
                if (batch.scheduledAt != null)
                  _buildDetailRow(&apos;Scheduled&apos;, _formatDateTime(batch.scheduledAt!)),
                if (batch.completedAt != null)
                  _buildDetailRow(&apos;Completed&apos;, _formatDateTime(batch.completedAt!)),
                if (batch.errorMessage != null) ...[
                  const SizedBox(height: 8),
                  const Text(
                    &apos;Error Message:&apos;,
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
            onPressed: () =&gt; Navigator.of(context).pop(),
            child: const Text(&apos;Close&apos;),
          ),
        ],
      ),
    );
  }

  Future&lt;bool&gt; _showDeleteConfirmation(String itemName) async {
    return await showDialog&lt;bool&gt;(
      context: context,
      builder: (context) =&gt; AlertDialog(
        title: const Text(&apos;Confirm Delete&apos;),
        content: Text(&apos;Are you sure you want to delete &quot;$itemName&quot;?&apos;),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
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
    return &apos;${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, &apos;0&apos;)}&apos;;
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
  State&lt;_TemplateEditDialog&gt; createState() =&gt; _TemplateEditDialogState();
}

class _TemplateEditDialogState extends State&lt;_TemplateEditDialog&gt; {
  final _formKey = GlobalKey&lt;FormState&gt;();
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
    _nameController = TextEditingController(text: widget.template?.name ?? &apos;&apos;);
    _descriptionController = TextEditingController(text: widget.template?.description ?? &apos;&apos;);
    _titleTemplateController = TextEditingController(text: widget.template?.titleTemplate ?? &apos;&apos;);
    _contentTemplateController = TextEditingController(text: widget.template?.contentTemplate ?? &apos;&apos;);
    
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
      title: Text(widget.template == null ? &apos;Create Template&apos; : &apos;Edit Template&apos;),
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
                    labelText: &apos;Name&apos;,
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =&gt; value?.isEmpty ?? true ? &apos;Name is required&apos; : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: &apos;Description&apos;,
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField&lt;NotificationType&gt;(
                  decoration: const InputDecoration(
                    labelText: &apos;Type&apos;,
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedType,
                  items: NotificationType.values.map(
                    (type) =&gt; DropdownMenuItem(
                      value: type,
                      child: Text(type.displayName),
                    ),
                  ).toList(),
                  onChanged: (value) =&gt; setState(() =&gt; _selectedType = value!),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleTemplateController,
                  decoration: const InputDecoration(
                    labelText: &apos;Title Template&apos;,
                    border: OutlineInputBorder(),
                    hintText: &apos;Use {variable_name} for dynamic content&apos;,
                  ),
                  validator: (value) =&gt; value?.isEmpty ?? true ? &apos;Title template is required&apos; : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contentTemplateController,
                  decoration: const InputDecoration(
                    labelText: &apos;Content Template&apos;,
                    border: OutlineInputBorder(),
                    hintText: &apos;Use {variable_name} for dynamic content&apos;,
                  ),
                  maxLines: 3,
                  validator: (value) =&gt; value?.isEmpty ?? true ? &apos;Content template is required&apos; : null,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () =&gt; Navigator.of(context).pop(),
          child: const Text(&apos;Cancel&apos;),
        ),
        ElevatedButton(
          onPressed: _saveTemplate,
          child: Text(widget.template == null ? &apos;Create&apos; : &apos;Save&apos;),
        ),
      ],
    );
  }

  void _saveTemplate() {
    if (_formKey.currentState?.validate() ?? false) {
      final template = NotificationTemplate(
        id: widget.template?.id ?? &apos;&apos;,
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
  final List&lt;NotificationTemplate&gt; templates;
  final Function(String, List&lt;String&gt;, String, Map&lt;String, dynamic&gt;, DateTime?) onSaved;

  const _BatchCreateDialog({
    required this.templates,
    required this.onSaved,
  });

  @override
  State&lt;_BatchCreateDialog&gt; createState() =&gt; _BatchCreateDialogState();
}

class _BatchCreateDialogState extends State&lt;_BatchCreateDialog&gt; {
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
      title: const Text(&apos;Create Notification Batch&apos;),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: &apos;Batch Title&apos;,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField&lt;NotificationTemplate&gt;(
              decoration: const InputDecoration(
                labelText: &apos;Template&apos;,
                border: OutlineInputBorder(),
              ),
              value: _selectedTemplate,
              items: widget.templates.map(
                (template) =&gt; DropdownMenuItem(
                  value: template,
                  child: Text(template.name),
                ),
              ).toList(),
              onChanged: (value) =&gt; setState(() =&gt; _selectedTemplate = value),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _recipientsController,
              decoration: const InputDecoration(
                labelText: &apos;Recipients (comma-separated)&apos;,
                border: OutlineInputBorder(),
                hintText: &apos;user1@example.com, user2@example.com&apos;,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text(&apos;Schedule for later&apos;),
              subtitle: _scheduledAt != null 
                  ? Text(&apos;Scheduled: ${_scheduledAt!.toString().split(&apos;.&apos;)[0]}&apos;)
                  : const Text(&apos;Send immediately&apos;),
              trailing: const Icon(Icons.schedule),
              onTap: _pickScheduleTime,
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
          onPressed: _selectedTemplate == null || 
                     _titleController.text.isEmpty ||
                     _recipientsController.text.isEmpty
              ? null
              : _createBatch,
          child: const Text(&apos;Create&apos;),
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
        .split(&apos;,&apos;)
        .map((e) =&gt; e.trim())
        .where((e) =&gt; e.isNotEmpty)
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
  final Function(NotificationChannel, String, Map&lt;String, dynamic&gt;?) onSaved;

  const _SubscriptionCreateDialog({
    required this.onSaved,
  });

  @override
  State&lt;_SubscriptionCreateDialog&gt; createState() =&gt; _SubscriptionCreateDialogState();
}

class _SubscriptionCreateDialogState extends State&lt;_SubscriptionCreateDialog&gt; {
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
      title: const Text(&apos;Add Subscription&apos;),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField&lt;NotificationChannel&gt;(
            decoration: const InputDecoration(
              labelText: &apos;Channel&apos;,
              border: OutlineInputBorder(),
            ),
            value: _selectedChannel,
            items: NotificationChannel.values.map(
              (channel) =&gt; DropdownMenuItem(
                value: channel,
                child: Text(channel.displayName),
              ),
            ).toList(),
            onChanged: (value) =&gt; setState(() =&gt; _selectedChannel = value!),
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
          onPressed: () =&gt; Navigator.of(context).pop(),
          child: const Text(&apos;Cancel&apos;),
        ),
        ElevatedButton(
          onPressed: _endpointController.text.isEmpty ? null : _createSubscription,
          child: const Text(&apos;Add&apos;),
        ),
      ],
    );
  }

  String _getEndpointLabel(NotificationChannel channel) {
    switch (channel) {
      case NotificationChannel.webhook:
        return &apos;Webhook URL&apos;;
      case NotificationChannel.email:
        return &apos;Email Address&apos;;
      case NotificationChannel.sms:
        return &apos;Phone Number&apos;;
      case NotificationChannel.push:
        return &apos;Device Token&apos;;
      case NotificationChannel.inApp:
        return &apos;User ID&apos;;
    }
  }

  String _getEndpointHint(NotificationChannel channel) {
    switch (channel) {
      case NotificationChannel.webhook:
        return &apos;https://example.com/webhook&apos;;
      case NotificationChannel.email:
        return &apos;user@example.com&apos;;
      case NotificationChannel.sms:
        return &apos;+1234567890&apos;;
      case NotificationChannel.push:
        return &apos;Device registration token&apos;;
      case NotificationChannel.inApp:
        return &apos;user123&apos;;
    }
  }

  void _createSubscription() {
    widget.onSaved(_selectedChannel, _endpointController.text, null);
    Navigator.of(context).pop();
  }
}