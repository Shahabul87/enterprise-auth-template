import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/webhook_models.dart';
import '../../../data/services/webhook_api_service.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';

final webhookApiServiceProvider = Provider((ref) => WebhookApiService());

class WebhookManagementPage extends ConsumerStatefulWidget {
  const WebhookManagementPage({super.key});

  @override
  ConsumerState<WebhookManagementPage> createState() => _WebhookManagementPageState();
}

class _WebhookManagementPageState extends ConsumerState<WebhookManagementPage> 
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<Webhook> _webhooks = [];
  List<WebhookDelivery> _deliveries = [];
  List<WebhookTemplate> _templates = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  WebhookEventType? _selectedEventFilter;
  WebhookStatus? _selectedStatusFilter;

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

      final service = ref.read(webhookApiServiceProvider);
      final results = await Future.wait([
        service.getWebhooks(),
        service.getDeliveries(),
        service.getTemplates(),
      ]);

      if (mounted) {
        setState(() {
          _webhooks = results[0] as List<Webhook>;
          _deliveries = results[1] as List<WebhookDelivery>;
          _templates = results[2] as List<WebhookTemplate>;
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
        title: const Text('Webhook Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Webhooks'),
            Tab(text: 'Deliveries'),
            Tab(text: 'Templates'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildWebhooksTab(),
          _buildDeliveriesTab(),
          _buildTemplatesTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateWebhookDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildWebhooksTab() {
    final filteredWebhooks = _webhooks.where((webhook) {
      final matchesSearch = _searchQuery.isEmpty ||
          webhook.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          webhook.url.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesEvent = _selectedEventFilter == null ||
          webhook.events.contains(_selectedEventFilter!);
      
      final matchesStatus = _selectedStatusFilter == null ||
          webhook.status == _selectedStatusFilter!;
      
      return matchesSearch && matchesEvent && matchesStatus;
    }).toList();

    return Column(
      children: [
        _buildWebhookFilters(),
        Expanded(
          child: filteredWebhooks.isEmpty
              ? const Center(child: Text('No webhooks found'))
              : ListView.builder(
                  itemCount: filteredWebhooks.length,
                  itemBuilder: (context, index) {
                    final webhook = filteredWebhooks[index];
                    return _buildWebhookCard(webhook);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildWebhookFilters() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              hintText: 'Search webhooks...',
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
                child: DropdownButtonFormField<WebhookEventType>(
                  decoration: const InputDecoration(
                    labelText: 'Event Type',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedEventFilter,
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Events'),
                    ),
                    ...WebhookEventType.values.map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(type.displayName),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedEventFilter = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<WebhookStatus>(
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedStatusFilter,
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Status'),
                    ),
                    ...WebhookStatus.values.map(
                      (status) => DropdownMenuItem(
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
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWebhookCard(Webhook webhook) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: webhook.status.color,
          child: Icon(
            webhook.status.icon,
            color: Colors.white,
          ),
        ),
        title: Text(webhook.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(webhook.url),
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              children: webhook.events.map((event) => Chip(
                label: Text(
                  event.displayName,
                  style: const TextStyle(fontSize: 10),
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              )).toList(),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (action) => _handleWebhookAction(action, webhook),
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
                  Icon(Icons.play_arrow),
                  SizedBox(width: 8),
                  Text('Test'),
                ],
              ),
            ),
            PopupMenuItem(
              value: webhook.status == WebhookStatus.active ? 'disable' : 'enable',
              child: Row(
                children: [
                  Icon(webhook.status == WebhookStatus.active 
                      ? Icons.pause 
                      : Icons.play_arrow),
                  const SizedBox(width: 8),
                  Text(webhook.status == WebhookStatus.active 
                      ? 'Disable' 
                      : 'Enable'),
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
                if (webhook.description.isNotEmpty) ...[
                  const Text(
                    'Description:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(webhook.description),
                  const SizedBox(height: 8),
                ],
                const Text(
                  'Statistics:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    _buildStatChip('Success', webhook.successCount.toString(), Colors.green),
                    const SizedBox(width: 8),
                    _buildStatChip('Failed', webhook.failureCount.toString(), Colors.red),
                    const SizedBox(width: 8),
                    _buildStatChip('Last Success', 
                        webhook.lastSuccessAt?.toString().split(' ')[0] ?? 'Never', 
                        Colors.blue),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Chip(
      label: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 10)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      backgroundColor: color.withOpacity(0.1),
    );
  }

  Widget _buildDeliveriesTab() {
    return ListView.builder(
      itemCount: _deliveries.length,
      itemBuilder: (context, index) {
        final delivery = _deliveries[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: delivery.status.color,
              child: Icon(
                delivery.status.icon,
                color: Colors.white,
              ),
            ),
            title: Text('${delivery.eventType.displayName} → ${delivery.webhookName}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Attempt ${delivery.attemptCount} of ${delivery.maxAttempts}'),
                Text('${delivery.createdAt}'),
                if (delivery.errorMessage != null)
                  Text(
                    'Error: ${delivery.errorMessage}',
                    style: const TextStyle(color: Colors.red),
                  ),
              ],
            ),
            trailing: Text('${delivery.responseTime}ms'),
            onTap: () => _showDeliveryDetails(delivery),
          ),
        );
      },
    );
  }

  Widget _buildTemplatesTab() {
    return ListView.builder(
      itemCount: _templates.length,
      itemBuilder: (context, index) {
        final template = _templates[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              child: Text(template.name.substring(0, 2).toUpperCase()),
            ),
            title: Text(template.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(template.description),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  children: template.supportedEvents.map((event) => Chip(
                    label: Text(
                      event.displayName,
                      style: const TextStyle(fontSize: 10),
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  )).toList(),
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (action) => _handleTemplateAction(action, template),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'use',
                  child: Row(
                    children: [
                      Icon(Icons.rocket_launch),
                      SizedBox(width: 8),
                      Text('Use Template'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      Icon(Icons.visibility),
                      SizedBox(width: 8),
                      Text('View Code'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleWebhookAction(String action, Webhook webhook) async {
    final service = ref.read(webhookApiServiceProvider);
    
    try {
      switch (action) {
        case 'edit':
          _showEditWebhookDialog(webhook);
          break;
        case 'test':
          await service.testWebhook(webhook.id);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Test webhook sent')),
            );
          }
          break;
        case 'enable':
        case 'disable':
          final newStatus = action == 'enable' 
              ? WebhookStatus.active 
              : WebhookStatus.inactive;
          await service.updateWebhookStatus(webhook.id, newStatus);
          _loadData();
          break;
        case 'delete':
          final confirmed = await _showDeleteConfirmation(webhook.name);
          if (confirmed) {
            await service.deleteWebhook(webhook.id);
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

  void _handleTemplateAction(String action, WebhookTemplate template) {
    switch (action) {
      case 'use':
        _showCreateWebhookDialog(template: template);
        break;
      case 'view':
        _showTemplateCode(template);
        break;
    }
  }

  void _showCreateWebhookDialog({WebhookTemplate? template}) {
    showDialog(
      context: context,
      builder: (context) => _WebhookEditDialog(
        onSaved: (webhook) {
          ref.read(webhookApiServiceProvider).createWebhook(webhook).then((_) {
            _loadData();
          });
        },
        template: template,
      ),
    );
  }

  void _showEditWebhookDialog(Webhook webhook) {
    showDialog(
      context: context,
      builder: (context) => _WebhookEditDialog(
        webhook: webhook,
        onSaved: (updatedWebhook) {
          ref.read(webhookApiServiceProvider)
              .updateWebhook(webhook.id, updatedWebhook).then((_) {
            _loadData();
          });
        },
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(String webhookName) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Webhook'),
        content: Text('Are you sure you want to delete "$webhookName"?'),
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

  void _showDeliveryDetails(WebhookDelivery delivery) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delivery Details'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('Event', delivery.eventType.displayName),
                _buildDetailRow('Webhook', delivery.webhookName),
                _buildDetailRow('Status', delivery.status.displayName),
                _buildDetailRow('Response Code', delivery.responseCode?.toString() ?? 'N/A'),
                _buildDetailRow('Response Time', '${delivery.responseTime}ms'),
                _buildDetailRow('Attempt', '${delivery.attemptCount}/${delivery.maxAttempts}'),
                if (delivery.errorMessage != null)
                  _buildDetailRow('Error', delivery.errorMessage!),
                const SizedBox(height: 16),
                const Text(
                  'Payload:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    delivery.payload,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                ),
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

  void _showTemplateCode(WebhookTemplate template) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${template.name} Template'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                template.payload,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: template.payload));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Template copied to clipboard')),
              );
            },
            child: const Text('Copy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _WebhookEditDialog extends StatefulWidget {
  final Webhook? webhook;
  final WebhookTemplate? template;
  final Function(CreateWebhookRequest) onSaved;

  const _WebhookEditDialog({
    this.webhook,
    this.template,
    required this.onSaved,
  });

  @override
  State<_WebhookEditDialog> createState() => _WebhookEditDialogState();
}

class _WebhookEditDialogState extends State<_WebhookEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _urlController;
  late TextEditingController _descriptionController;
  late TextEditingController _secretController;
  Set<WebhookEventType> _selectedEvents = {};

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.webhook?.name ?? widget.template?.name ?? '',
    );
    _urlController = TextEditingController(
      text: widget.webhook?.url ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.webhook?.description ?? widget.template?.description ?? '',
    );
    _secretController = TextEditingController(
      text: widget.webhook?.secret ?? '',
    );
    _selectedEvents = widget.webhook?.events.toSet() ?? 
        widget.template?.supportedEvents.toSet() ?? {};
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    _descriptionController.dispose();
    _secretController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.webhook == null ? 'Create Webhook' : 'Edit Webhook'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _urlController,
                  decoration: const InputDecoration(
                    labelText: 'URL',
                    border: OutlineInputBorder(),
                    hintText: 'https://example.com/webhook',
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'URL is required';
                    }
                    if (!Uri.tryParse(value!)?.hasAbsolutePath ?? true) {
                      return 'Invalid URL';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _secretController,
                  decoration: const InputDecoration(
                    labelText: 'Secret (optional)',
                    border: OutlineInputBorder(),
                    hintText: 'Used for signature verification',
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Events:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: WebhookEventType.values.map((event) => FilterChip(
                    label: Text(event.displayName),
                    selected: _selectedEvents.contains(event),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedEvents.add(event);
                        } else {
                          _selectedEvents.remove(event);
                        }
                      });
                    },
                  )).toList(),
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
          onPressed: _selectedEvents.isEmpty ? null : _saveWebhook,
          child: Text(widget.webhook == null ? 'Create' : 'Save'),
        ),
      ],
    );
  }

  void _saveWebhook() {
    if (_formKey.currentState?.validate() ?? false) {
      final request = CreateWebhookRequest(
        name: _nameController.text,
        url: _urlController.text,
        description: _descriptionController.text,
        events: _selectedEvents.toList(),
        secret: _secretController.text.isEmpty ? null : _secretController.text,
        isActive: true,
      );
      widget.onSaved(request);
      Navigator.of(context).pop();
    }
  }
}