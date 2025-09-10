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
  List&lt;Webhook&gt; _webhooks = [];
  List&lt;WebhookDelivery&gt; _deliveries = [];
  List&lt;WebhookTemplate&gt; _templates = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = &apos;&apos;;
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

  Future&lt;void&gt; _loadData() async {
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
          _webhooks = results[0] as List&lt;Webhook&gt;;
          _deliveries = results[1] as List&lt;WebhookDelivery&gt;;
          _templates = results[2] as List&lt;WebhookTemplate&gt;;
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
        title: const Text(&apos;Webhook Management&apos;),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: &apos;Webhooks&apos;),
            Tab(text: &apos;Deliveries&apos;),
            Tab(text: &apos;Templates&apos;),
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
      
      return matchesSearch &amp;&amp; matchesEvent &amp;&amp; matchesStatus;
    }).toList();

    return Column(
      children: [
        _buildWebhookFilters(),
        Expanded(
          child: filteredWebhooks.isEmpty
              ? const Center(child: Text(&apos;No webhooks found&apos;))
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
              hintText: &apos;Search webhooks...&apos;,
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
                child: DropdownButtonFormField&lt;WebhookEventType&gt;(
                  decoration: const InputDecoration(
                    labelText: &apos;Event Type&apos;,
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedEventFilter,
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text(&apos;All Events&apos;),
                    ),
                    ...WebhookEventType.values.map(
                      (type) =&gt; DropdownMenuItem(
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
                child: DropdownButtonFormField&lt;WebhookStatus&gt;(
                  decoration: const InputDecoration(
                    labelText: &apos;Status&apos;,
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedStatusFilter,
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text(&apos;All Status&apos;),
                    ),
                    ...WebhookStatus.values.map(
                      (status) =&gt; DropdownMenuItem(
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
              children: webhook.events.map((event) =&gt; Chip(
                label: Text(
                  event.displayName,
                  style: const TextStyle(fontSize: 10),
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              )).toList(),
            ),
          ],
        ),
        trailing: PopupMenuButton&lt;String&gt;(
          onSelected: (action) =&gt; _handleWebhookAction(action, webhook),
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
                  Icon(Icons.play_arrow),
                  SizedBox(width: 8),
                  Text(&apos;Test&apos;),
                ],
              ),
            ),
            PopupMenuItem(
              value: webhook.status == WebhookStatus.active ? &apos;disable&apos; : &apos;enable&apos;,
              child: Row(
                children: [
                  Icon(webhook.status == WebhookStatus.active 
                      ? Icons.pause 
                      : Icons.play_arrow),
                  const SizedBox(width: 8),
                  Text(webhook.status == WebhookStatus.active 
                      ? &apos;Disable&apos; 
                      : &apos;Enable&apos;),
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
                if (webhook.description.isNotEmpty) ...[
                  const Text(
                    &apos;Description:&apos;,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(webhook.description),
                  const SizedBox(height: 8),
                ],
                const Text(
                  &apos;Statistics:&apos;,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    _buildStatChip(&apos;Success&apos;, webhook.successCount.toString(), Colors.green),
                    const SizedBox(width: 8),
                    _buildStatChip(&apos;Failed&apos;, webhook.failureCount.toString(), Colors.red),
                    const SizedBox(width: 8),
                    _buildStatChip(&apos;Last Success&apos;, 
                        webhook.lastSuccessAt?.toString().split(&apos; &apos;)[0] ?? &apos;Never&apos;, 
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
            title: Text(&apos;${delivery.eventType.displayName} → ${delivery.webhookName}&apos;),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(&apos;Attempt ${delivery.attemptCount} of ${delivery.maxAttempts}&apos;),
                Text(&apos;${delivery.createdAt}&apos;),
                if (delivery.errorMessage != null)
                  Text(
                    &apos;Error: ${delivery.errorMessage}&apos;,
                    style: const TextStyle(color: Colors.red),
                  ),
              ],
            ),
            trailing: Text(&apos;${delivery.responseTime}ms&apos;),
            onTap: () =&gt; _showDeliveryDetails(delivery),
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
                  children: template.supportedEvents.map((event) =&gt; Chip(
                    label: Text(
                      event.displayName,
                      style: const TextStyle(fontSize: 10),
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  )).toList(),
                ),
              ],
            ),
            trailing: PopupMenuButton&lt;String&gt;(
              onSelected: (action) =&gt; _handleTemplateAction(action, template),
              itemBuilder: (context) =&gt; [
                const PopupMenuItem(
                  value: &apos;use&apos;,
                  child: Row(
                    children: [
                      Icon(Icons.rocket_launch),
                      SizedBox(width: 8),
                      Text(&apos;Use Template&apos;),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: &apos;view&apos;,
                  child: Row(
                    children: [
                      Icon(Icons.visibility),
                      SizedBox(width: 8),
                      Text(&apos;View Code&apos;),
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
        case &apos;edit&apos;:
          _showEditWebhookDialog(webhook);
          break;
        case &apos;test&apos;:
          await service.testWebhook(webhook.id);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text(&apos;Test webhook sent&apos;)),
            );
          }
          break;
        case &apos;enable&apos;:
        case &apos;disable&apos;:
          final newStatus = action == &apos;enable&apos; 
              ? WebhookStatus.active 
              : WebhookStatus.inactive;
          await service.updateWebhookStatus(webhook.id, newStatus);
          _loadData();
          break;
        case &apos;delete&apos;:
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
          SnackBar(content: Text(&apos;Error: ${e.toString()}&apos;)),
        );
      }
    }
  }

  void _handleTemplateAction(String action, WebhookTemplate template) {
    switch (action) {
      case &apos;use&apos;:
        _showCreateWebhookDialog(template: template);
        break;
      case &apos;view&apos;:
        _showTemplateCode(template);
        break;
    }
  }

  void _showCreateWebhookDialog({WebhookTemplate? template}) {
    showDialog(
      context: context,
      builder: (context) =&gt; _WebhookEditDialog(
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
      builder: (context) =&gt; _WebhookEditDialog(
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

  Future&lt;bool&gt; _showDeleteConfirmation(String webhookName) async {
    return await showDialog&lt;bool&gt;(
      context: context,
      builder: (context) =&gt; AlertDialog(
        title: const Text(&apos;Delete Webhook&apos;),
        content: Text(&apos;Are you sure you want to delete &quot;$webhookName&quot;?&apos;),
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

  void _showDeliveryDetails(WebhookDelivery delivery) {
    showDialog(
      context: context,
      builder: (context) =&gt; AlertDialog(
        title: Text(&apos;Delivery Details&apos;),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow(&apos;Event&apos;, delivery.eventType.displayName),
                _buildDetailRow(&apos;Webhook&apos;, delivery.webhookName),
                _buildDetailRow(&apos;Status&apos;, delivery.status.displayName),
                _buildDetailRow(&apos;Response Code&apos;, delivery.responseCode?.toString() ?? &apos;N/A&apos;),
                _buildDetailRow(&apos;Response Time&apos;, &apos;${delivery.responseTime}ms&apos;),
                _buildDetailRow(&apos;Attempt&apos;, &apos;${delivery.attemptCount}/${delivery.maxAttempts}&apos;),
                if (delivery.errorMessage != null)
                  _buildDetailRow(&apos;Error&apos;, delivery.errorMessage!),
                const SizedBox(height: 16),
                const Text(
                  &apos;Payload:&apos;,
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
                    style: const TextStyle(fontFamily: &apos;monospace&apos;, fontSize: 12),
                  ),
                ),
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

  void _showTemplateCode(WebhookTemplate template) {
    showDialog(
      context: context,
      builder: (context) =&gt; AlertDialog(
        title: Text(&apos;${template.name} Template&apos;),
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
                style: const TextStyle(fontFamily: &apos;monospace&apos;, fontSize: 12),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: template.payload));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text(&apos;Template copied to clipboard&apos;)),
              );
            },
            child: const Text(&apos;Copy&apos;),
          ),
          TextButton(
            onPressed: () =&gt; Navigator.of(context).pop(),
            child: const Text(&apos;Close&apos;),
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
  State&lt;_WebhookEditDialog&gt; createState() =&gt; _WebhookEditDialogState();
}

class _WebhookEditDialogState extends State&lt;_WebhookEditDialog&gt; {
  final _formKey = GlobalKey&lt;FormState&gt;();
  late TextEditingController _nameController;
  late TextEditingController _urlController;
  late TextEditingController _descriptionController;
  late TextEditingController _secretController;
  Set&lt;WebhookEventType&gt; _selectedEvents = {};

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.webhook?.name ?? widget.template?.name ?? &apos;&apos;,
    );
    _urlController = TextEditingController(
      text: widget.webhook?.url ?? &apos;&apos;,
    );
    _descriptionController = TextEditingController(
      text: widget.webhook?.description ?? widget.template?.description ?? &apos;&apos;,
    );
    _secretController = TextEditingController(
      text: widget.webhook?.secret ?? &apos;&apos;,
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
      title: Text(widget.webhook == null ? &apos;Create Webhook&apos; : &apos;Edit Webhook&apos;),
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
                    labelText: &apos;Name&apos;,
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return &apos;Name is required&apos;;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _urlController,
                  decoration: const InputDecoration(
                    labelText: &apos;URL&apos;,
                    border: OutlineInputBorder(),
                    hintText: &apos;https://example.com/webhook&apos;,
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return &apos;URL is required&apos;;
                    }
                    if (!Uri.tryParse(value!)?.hasAbsolutePath ?? true) {
                      return &apos;Invalid URL&apos;;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: &apos;Description&apos;,
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _secretController,
                  decoration: const InputDecoration(
                    labelText: &apos;Secret (optional)&apos;,
                    border: OutlineInputBorder(),
                    hintText: &apos;Used for signature verification&apos;,
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    &apos;Events:&apos;,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: WebhookEventType.values.map((event) =&gt; FilterChip(
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
          onPressed: () =&gt; Navigator.of(context).pop(),
          child: const Text(&apos;Cancel&apos;),
        ),
        ElevatedButton(
          onPressed: _selectedEvents.isEmpty ? null : _saveWebhook,
          child: Text(widget.webhook == null ? &apos;Create&apos; : &apos;Save&apos;),
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