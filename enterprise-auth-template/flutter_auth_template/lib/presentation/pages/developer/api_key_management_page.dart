import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_auth_template/data/models/api_key_models.dart';
import 'package:flutter_auth_template/data/services/api_key_service.dart';
import 'package:flutter_auth_template/presentation/widgets/loading_indicators.dart';
import 'package:flutter_auth_template/presentation/widgets/empty_state.dart';
import 'package:flutter_auth_template/presentation/widgets/dialog_components.dart';

class ApiKeyManagementPage extends ConsumerStatefulWidget {
  const ApiKeyManagementPage({super.key});

  @override
  ConsumerState<ApiKeyManagementPage> createState() => _ApiKeyManagementPageState();
}

class _ApiKeyManagementPageState extends ConsumerState<ApiKeyManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';
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
        title: const Text('API Key Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'API Keys', icon: Icon(Icons.key)),
            Tab(text: 'Usage', icon: Icon(Icons.analytics)),
            Tab(text: 'Documentation', icon: Icon(Icons.description)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildApiKeysTab(),
          _buildUsageTab(),
          _buildDocumentationTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateApiKeyDialog,
        child: const Icon(Icons.add),
        tooltip: 'Create API Key',
      ),
    );
  }

  Widget _buildApiKeysTab() {
    return Column(
      children: [
        _buildSearchAndFilters(),
        Expanded(
          child: _buildApiKeysList(),
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
              hintText: 'Search API keys...',
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
                          _searchQuery = '';
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
                label: const Text('Active Only'),
                selected: _showActiveOnly,
                onSelected: (selected) {
                  setState(() {
                    _showActiveOnly = selected;
                  });
                },
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _refreshApiKeys,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildApiKeysList() {
    return FutureBuilder<ApiKeyListResponse>(
      future: _loadApiKeys(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingIndicator();
        }

        if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error.toString());
        }

        final apiKeyList = snapshot.data!;
        if (apiKeyList.apiKeys.isEmpty) {
          return const EmptyState(
            icon: Icons.key,
            title: 'No API Keys Found',
            description: 'Create your first API key to get started with the API.',
          );
        }

        return RefreshIndicator(
          onRefresh: _refreshApiKeys,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: apiKeyList.apiKeys.length,
            itemBuilder: (context, index) {
              final apiKey = apiKeyList.apiKeys[index];
              return _buildApiKeyCard(apiKey);
            },
          ),
        );
      },
    );
  }

  Widget _buildApiKeyCard(ApiKey apiKey) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: _buildApiKeyIcon(apiKey),
        title: Text(
          apiKey.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(apiKey.description),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildStatusChip(apiKey),
                const SizedBox(width: 8),
                Text(
                  'Created: ${_formatDateTime(apiKey.createdAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleApiKeyAction(value, apiKey),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: ListTile(
                leading: Icon(Icons.visibility),
                title: Text('View Details'),
              ),
            ),
            const PopupMenuItem(
              value: 'copy',
              child: ListTile(
                leading: Icon(Icons.copy),
                title: Text('Copy Key Prefix'),
              ),
            ),
            PopupMenuItem(
              value: apiKey.isActive ? 'deactivate' : 'activate',
              child: ListTile(
                leading: Icon(apiKey.isActive ? Icons.pause : Icons.play_arrow),
                title: Text(apiKey.isActive ? 'Deactivate' : 'Activate'),
              ),
            ),
            const PopupMenuItem(
              value: 'rotate',
              child: ListTile(
                leading: Icon(Icons.refresh),
                title: Text('Rotate Key'),
              ),
            ),
            const PopupMenuItem(
              value: 'usage',
              child: ListTile(
                leading: Icon(Icons.analytics),
                title: Text('View Usage'),
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text('Edit'),
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Delete', style: TextStyle(color: Colors.red)),
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
                _buildDetailRow('Key Prefix', apiKey.keyPrefix),
                _buildDetailRow('Permissions', apiKey.permissions.join(', ')),
                _buildDetailRow('Scopes', apiKey.scopes.join(', ')),
                _buildDetailRow('Usage Count', apiKey.usageCount.toString()),
                _buildDetailRow('Last Used', _formatDateTime(apiKey.lastUsedAt)),
                _buildDetailRow('Expires', apiKey.expiresAt != null ? _formatDateTime(apiKey.expiresAt) : 'Never'),
                if (apiKey.ipWhitelist != null)
                  _buildDetailRow('IP Whitelist', apiKey.ipWhitelist!),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApiKeyIcon(ApiKey apiKey) {
    IconData iconData;
    Color iconColor;

    if (!apiKey.isActive) {
      iconData = Icons.key_off;
      iconColor = Colors.grey;
    } else if (apiKey.expiresAt != null && apiKey.expiresAt!.isBefore(DateTime.now())) {
      iconData = Icons.key;
      iconColor = Colors.red;
    } else {
      iconData = Icons.key;
      iconColor = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(iconData, color: iconColor),
    );
  }

  Widget _buildStatusChip(ApiKey apiKey) {
    Color color;
    String label;

    if (!apiKey.isActive) {
      color = Colors.grey;
      label = 'Inactive';
    } else if (apiKey.expiresAt != null && apiKey.expiresAt!.isBefore(DateTime.now())) {
      color = Colors.red;
      label = 'Expired';
    } else {
      color = Colors.green;
      label = 'Active';
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

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value ?? 'N/A'),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageTab() {
    return FutureBuilder<ApiKeyListResponse>(
      future: _loadApiKeys(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingIndicator();
        }

        if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error.toString());
        }

        final apiKeys = snapshot.data!.apiKeys;
        if (apiKeys.isEmpty) {
          return const EmptyState(
            icon: Icons.analytics,
            title: 'No Usage Data',
            description: 'Create API keys to view usage statistics.',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: apiKeys.length,
          itemBuilder: (context, index) {
            final apiKey = apiKeys[index];
            return _buildUsageCard(apiKey);
          },
        );
      },
    );
  }

  Widget _buildUsageCard(ApiKey apiKey) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    apiKey.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => _showDetailedUsage(apiKey),
                  child: const Text('View Details'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildUsageMetric('Total Requests', apiKey.usageCount.toString()),
                ),
                Expanded(
                  child: _buildUsageMetric('Last Used', _formatDateTime(apiKey.lastUsedAt)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: apiKey.usageCount / 10000, // Assuming 10k limit
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                apiKey.usageCount > 8000 ? Colors.red : Colors.blue,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${apiKey.usageCount} / 10,000 requests',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDocSection(
            'Getting Started',
            'Learn how to authenticate and make your first API request.',
            Icons.play_arrow,
          ),
          _buildDocSection(
            'Authentication',
            'Understand how to use API keys for secure access.',
            Icons.security,
          ),
          _buildDocSection(
            'Rate Limits',
            'Information about API rate limits and best practices.',
            Icons.speed,
          ),
          _buildDocSection(
            'Error Codes',
            'Common error codes and their meanings.',
            Icons.error,
          ),
          _buildDocSection(
            'Examples',
            'Code examples in different programming languages.',
            Icons.code,
          ),
          const SizedBox(height: 24),
          _buildQuickStart(),
        ],
      ),
    );
  }

  Widget _buildDocSection(String title, String description, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Theme.of(context).primaryColor),
        ),
        title: Text(title),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          // Navigate to detailed documentation
          _showDocumentationDetail(title);
        },
      ),
    );
  }

  Widget _buildQuickStart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Start Example',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: const Text(
                '''curl -H "Authorization: Bearer YOUR_API_KEY" \\
     -H "Content-Type: application/json" \\
     https://api.example.com/v1/users''',
                style: TextStyle(fontFamily: 'monospace'),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _copyToClipboard('curl -H "Authorization: Bearer YOUR_API_KEY" -H "Content-Type: application/json" https://api.example.com/v1/users'),
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy Example'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
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
            'Failed to load API keys',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _refreshApiKeys,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Future<ApiKeyListResponse> _loadApiKeys() async {
    final apiKeyService = ref.read(apiKeyServiceProvider);
    return await apiKeyService.getApiKeys(
      isActive: _showActiveOnly ? true : null,
      search: _searchQuery.isNotEmpty ? _searchQuery : null,
    );
  }

  Future<void> _refreshApiKeys() async {
    setState(() {});
  }

  void _handleApiKeyAction(String action, ApiKey apiKey) async {
    final apiKeyService = ref.read(apiKeyServiceProvider);

    try {
      switch (action) {
        case 'view':
          _showApiKeyDetails(apiKey);
          break;
        case 'copy':
          _copyToClipboard(apiKey.keyPrefix);
          _showSnackBar('API key prefix copied to clipboard');
          break;
        case 'activate':
          await apiKeyService.activateApiKey(apiKey.id);
          _refreshApiKeys();
          _showSnackBar('API key activated successfully');
          break;
        case 'deactivate':
          await apiKeyService.deactivateApiKey(apiKey.id);
          _refreshApiKeys();
          _showSnackBar('API key deactivated successfully');
          break;
        case 'rotate':
          final confirmed = await _showConfirmDialog(
            'Rotate API Key',
            'This will generate a new key. The old key will stop working immediately. Continue?',
          );
          if (confirmed) {
            final newKey = await apiKeyService.rotateApiKey(apiKey.id);
            _showNewApiKeyDialog(newKey);
            _refreshApiKeys();
          }
          break;
        case 'usage':
          _showDetailedUsage(apiKey);
          break;
        case 'edit':
          _showEditApiKeyDialog(apiKey);
          break;
        case 'delete':
          final confirmed = await _showConfirmDialog(
            'Delete API Key',
            'This action cannot be undone. Are you sure you want to delete this API key?',
          );
          if (confirmed) {
            await apiKeyService.deleteApiKey(apiKey.id);
            _refreshApiKeys();
            _showSnackBar('API key deleted successfully');
          }
          break;
      }
    } catch (e) {
      _showSnackBar('Failed to perform action: ${e.toString()}');
    }
  }

  void _showCreateApiKeyDialog() {
    showDialog(
      context: context,
      builder: (context) => _CreateApiKeyDialog(
        onCreated: (apiKey) {
          _refreshApiKeys();
          _showNewApiKeyDialog(apiKey);
        },
      ),
    );
  }

  void _showEditApiKeyDialog(ApiKey apiKey) {
    showDialog(
      context: context,
      builder: (context) => _EditApiKeyDialog(
        apiKey: apiKey,
        onUpdated: () {
          _refreshApiKeys();
          _showSnackBar('API key updated successfully');
        },
      ),
    );
  }

  void _showNewApiKeyDialog(ApiKeyCreateResponse response) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('API Key Created'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your new API key has been created. Please save it now as it will not be shown again.'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: SelectableText(
                response.plainTextKey,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              response.warning,
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: () {
              _copyToClipboard(response.plainTextKey);
              _showSnackBar('API key copied to clipboard');
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copy Key'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showApiKeyDetails(ApiKey apiKey) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(apiKey.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Description', apiKey.description),
              _buildDetailRow('Key Prefix', apiKey.keyPrefix),
              _buildDetailRow('Status', apiKey.isActive ? 'Active' : 'Inactive'),
              _buildDetailRow('Permissions', apiKey.permissions.join(', ')),
              _buildDetailRow('Scopes', apiKey.scopes.join(', ')),
              _buildDetailRow('Usage Count', apiKey.usageCount.toString()),
              _buildDetailRow('Created', _formatDateTime(apiKey.createdAt)),
              _buildDetailRow('Last Used', _formatDateTime(apiKey.lastUsedAt)),
              _buildDetailRow('Expires', apiKey.expiresAt != null ? _formatDateTime(apiKey.expiresAt) : 'Never'),
              if (apiKey.ipWhitelist != null)
                _buildDetailRow('IP Whitelist', apiKey.ipWhitelist!),
            ],
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

  void _showDetailedUsage(ApiKey apiKey) {
    // TODO: Implement detailed usage view with charts
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${apiKey.name} Usage'),
        content: const Text('Detailed usage analytics coming soon...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDocumentationDetail(String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text('$title documentation coming soon...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<bool> _showConfirmDialog(String title, String message) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Confirm'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Never';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class _CreateApiKeyDialog extends ConsumerStatefulWidget {
  final Function(ApiKeyCreateResponse) onCreated;

  const _CreateApiKeyDialog({required this.onCreated});

  @override
  ConsumerState<_CreateApiKeyDialog> createState() => _CreateApiKeyDialogState();
}

class _CreateApiKeyDialogState extends ConsumerState<_CreateApiKeyDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _ipWhitelistController = TextEditingController();
  
  DateTime? _expiresAt;
  List<String> _selectedPermissions = [];
  List<String> _selectedScopes = [];
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create API Key'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: 'Enter API key name',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Describe what this API key will be used for',
                  ),
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Description is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ipWhitelistController,
                  decoration: const InputDecoration(
                    labelText: 'IP Whitelist (Optional)',
                    hintText: 'Comma-separated IP addresses',
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Expires At'),
                  subtitle: Text(_expiresAt != null ? _expiresAt.toString() : 'Never'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: _selectExpirationDate,
                        child: const Text('Set'),
                      ),
                      if (_expiresAt != null)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => setState(() => _expiresAt = null),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Permissions and scopes will be configured after creation.'),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _createApiKey,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create'),
        ),
      ],
    );
  }

  Future<void> _selectExpirationDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 90)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _expiresAt = date);
    }
  }

  Future<void> _createApiKey() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final apiKeyService = ref.read(apiKeyServiceProvider);
      final request = ApiKeyCreateRequest(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        permissions: _selectedPermissions,
        scopes: _selectedScopes.isNotEmpty ? _selectedScopes : ['read'],
        expiresAt: _expiresAt,
        ipWhitelist: _ipWhitelistController.text.trim().isNotEmpty
            ? _ipWhitelistController.text.trim()
            : null,
      );

      final response = await apiKeyService.createApiKey(request);
      widget.onCreated(response);
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create API key: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}

class _EditApiKeyDialog extends ConsumerStatefulWidget {
  final ApiKey apiKey;
  final VoidCallback onUpdated;

  const _EditApiKeyDialog({required this.apiKey, required this.onUpdated});

  @override
  ConsumerState<_EditApiKeyDialog> createState() => _EditApiKeyDialogState();
}

class _EditApiKeyDialogState extends ConsumerState<_EditApiKeyDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(text: widget.apiKey.name);
  late final _descriptionController = TextEditingController(text: widget.apiKey.description);
  late final _ipWhitelistController = TextEditingController(text: widget.apiKey.ipWhitelist);
  
  late DateTime? _expiresAt = widget.apiKey.expiresAt;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit API Key'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Description is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ipWhitelistController,
                decoration: const InputDecoration(
                  labelText: 'IP Whitelist (Optional)',
                  hintText: 'Comma-separated IP addresses',
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _updateApiKey,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Update'),
        ),
      ],
    );
  }

  Future<void> _updateApiKey() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final apiKeyService = ref.read(apiKeyServiceProvider);
      final request = ApiKeyUpdateRequest(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        ipWhitelist: _ipWhitelistController.text.trim().isNotEmpty
            ? _ipWhitelistController.text.trim()
            : null,
      );

      await apiKeyService.updateApiKey(widget.apiKey.id, request);
      widget.onUpdated();
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update API key: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}