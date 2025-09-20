import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_auth_template/presentation/providers/admin_provider.dart';
import 'package:flutter_auth_template/presentation/providers/auth_provider.dart';
import 'package:flutter_auth_template/presentation/widgets/loading_indicators.dart';
import 'package:flutter_auth_template/presentation/widgets/admin/dashboard_overview_cards.dart';
import 'package:flutter_auth_template/presentation/widgets/admin/recent_activity_widget.dart';
import 'package:flutter_auth_template/presentation/widgets/admin/system_health_widget.dart';
import 'package:flutter_auth_template/presentation/widgets/admin/user_stats_chart.dart';
import 'package:flutter_auth_template/presentation/widgets/admin/security_alerts_widget.dart';
import 'package:flutter_auth_template/core/theme/app_colors.dart';
import 'package:flutter_auth_template/core/theme/app_text_styles.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Load initial data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final adminNotifier = ref.read(adminProvider.notifier);
    await Future.wait([
      adminNotifier.loadDashboardData(),
      adminNotifier.loadSystemStats(),
      adminNotifier.checkSystemHealth(),
      adminNotifier.loadSecurityReport(),
    ]);
  }

  Future<void> _refreshData() async {
    final adminNotifier = ref.read(adminProvider.notifier);
    await adminNotifier.refreshAll();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);
    final authState = ref.watch(authStateProvider);
    final currentUser = authState.maybeWhen(
      authenticated: (user, _, __) => user,
      orElse: () => null,
    );

    // Listen to errors
    ref.listen(adminErrorProvider, (previous, next) {
      if (next != null) {
        _showError(next);
        ref.read(adminProvider.notifier).clearError();
      }
    });

    // Check admin permissions
    if (currentUser == null || !currentUser.roles.contains('admin')) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Access Denied'),
          backgroundColor: AppColors.surface,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.security, size: 64, color: AppColors.error),
              SizedBox(height: 16),
              Text('Access Denied', style: AppTextStyles.headlineMedium),
              SizedBox(height: 8),
              Text(
                'You need administrator privileges to access this area.',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Refresh Data',
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'users',
                child: ListTile(
                  leading: Icon(Icons.people),
                  title: Text('Manage Users'),
                  dense: true,
                ),
              ),
              const PopupMenuItem(
                value: 'sessions',
                child: ListTile(
                  leading: Icon(Icons.devices),
                  title: Text('Active Sessions'),
                  dense: true,
                ),
              ),
              const PopupMenuItem(
                value: 'audit',
                child: ListTile(
                  leading: Icon(Icons.history),
                  title: Text('Audit Logs'),
                  dense: true,
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('System Settings'),
                  dense: true,
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
            Tab(text: 'Users', icon: Icon(Icons.people)),
            Tab(text: 'Security', icon: Icon(Icons.security)),
            Tab(text: 'System', icon: Icon(Icons.settings)),
          ],
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.onSurfaceVariant,
        ),
      ),
      body: LoadingOverlay(
        isLoading: adminState.isDashboardLoading,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(adminState),
            _buildUsersTab(adminState),
            _buildSecurityTab(adminState),
            _buildSystemTab(adminState),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(AdminState adminState) {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dashboard overview cards
            if (adminState.dashboardData != null)
              DashboardOverviewCards(dashboardData: adminState.dashboardData!),

            const SizedBox(height: 24),

            // System health status
            if (adminState.systemHealth != null)
              SystemHealthWidget(
                healthData: adminState.systemHealth!,
                onRefresh: () {
                  ref.read(adminProvider.notifier).checkSystemHealth();
                },
              ),

            const SizedBox(height: 24),

            // User statistics chart
            if (adminState.dashboardData != null)
              UserStatsChart(dashboardData: adminState.dashboardData!),

            const SizedBox(height: 24),

            // Recent activity
            if (adminState.dashboardData != null)
              RecentActivityWidget(
                auditLogs: adminState.dashboardData!.recentAuditLogs,
                onViewAll: () => _handleMenuAction('audit'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersTab(AdminState adminState) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(adminProvider.notifier).loadUsers();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User management summary
            if (adminState.dashboardData != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('User Management', style: AppTextStyles.titleLarge),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildUserStatItem(
                            'Total Users',
                            adminState.dashboardData!.totalUsers.toString(),
                            Icons.people,
                            AppColors.primary,
                          ),
                          _buildUserStatItem(
                            'Active Users',
                            adminState.dashboardData!.activeUsers.toString(),
                            Icons.verified_user,
                            AppColors.success,
                          ),
                          _buildUserStatItem(
                            'Suspended',
                            adminState.dashboardData!.suspendedUsers.toString(),
                            Icons.person_remove,
                            AppColors.warning,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Quick actions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Quick Actions', style: AppTextStyles.titleMedium),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _navigateToUserManagement(),
                          icon: const Icon(Icons.person_add),
                          label: const Text('Add User'),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _navigateToUserList(),
                          icon: const Icon(Icons.list),
                          label: const Text('View All Users'),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _showBulkActionDialog(),
                          icon: const Icon(Icons.select_all),
                          label: const Text('Bulk Actions'),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _exportUsers(),
                          icon: const Icon(Icons.download),
                          label: const Text('Export Users'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityTab(AdminState adminState) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(adminProvider.notifier).loadSecurityReport();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Security overview
            if (adminState.securityReport != null)
              SecurityAlertsWidget(
                securityReport: adminState.securityReport!,
                onViewDetails: (alertType) => _handleSecurityAlert(alertType),
              ),

            const SizedBox(height: 16),

            // Two-factor authentication stats
            if (adminState.securityReport != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Two-Factor Authentication',
                        style: AppTextStyles.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(
                            Icons.security,
                            size: 48,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${(adminState.securityReport!.twoFaAdoptionRate * 100).toStringAsFixed(1)}%',
                                  style: AppTextStyles.headlineMedium.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                                Text(
                                  'Adoption Rate',
                                  style: AppTextStyles.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Security actions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Security Actions', style: AppTextStyles.titleMedium),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _viewActiveSessions(),
                          icon: const Icon(Icons.devices),
                          label: const Text('Active Sessions'),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _viewAuditLogs(),
                          icon: const Icon(Icons.history),
                          label: const Text('Audit Logs'),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _viewSecurityEvents(),
                          icon: const Icon(Icons.warning),
                          label: const Text('Security Events'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemTab(AdminState adminState) {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([
          ref.read(adminProvider.notifier).checkSystemHealth(),
          ref.read(adminProvider.notifier).loadSystemStats(),
        ]);
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // System health detailed view
            if (adminState.systemHealth != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _getHealthIcon(adminState.systemHealth!.status),
                            color: _getHealthColor(
                              adminState.systemHealth!.status,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'System Status: ${adminState.systemHealth!.status.toUpperCase()}',
                            style: AppTextStyles.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Version: ${adminState.systemHealth!.version}',
                        style: AppTextStyles.bodyMedium,
                      ),
                      Text(
                        'Uptime: ${adminState.systemHealth!.uptime}',
                        style: AppTextStyles.bodyMedium,
                      ),
                      Text(
                        'Last Check: ${adminState.systemHealth!.lastCheck}',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // System actions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('System Actions', style: AppTextStyles.titleMedium),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _clearCache(),
                          icon: const Icon(Icons.cached),
                          label: const Text('Clear Cache'),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _showMaintenanceDialog(),
                          icon: const Icon(Icons.build),
                          label: const Text('Maintenance Mode'),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _viewSystemConfig(),
                          icon: const Icon(Icons.settings),
                          label: const Text('System Config'),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _exportAuditLogs(),
                          icon: const Icon(Icons.download),
                          label: const Text('Export Logs'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, size: 32, color: color),
        const SizedBox(height: 8),
        Text(value, style: AppTextStyles.headlineSmall.copyWith(color: color)),
        Text(
          label,
          style: AppTextStyles.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  IconData _getHealthIcon(String status) {
    switch (status.toLowerCase()) {
      case 'healthy':
        return Icons.check_circle;
      case 'degraded':
        return Icons.warning;
      case 'unhealthy':
        return Icons.error;
      default:
        return Icons.help;
    }
  }

  Color _getHealthColor(String status) {
    switch (status.toLowerCase()) {
      case 'healthy':
        return AppColors.success;
      case 'degraded':
        return AppColors.warning;
      case 'unhealthy':
        return AppColors.error;
      default:
        return AppColors.onSurfaceVariant;
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'users':
        _navigateToUserManagement();
        break;
      case 'sessions':
        _viewActiveSessions();
        break;
      case 'audit':
        _viewAuditLogs();
        break;
      case 'settings':
        _viewSystemConfig();
        break;
    }
  }

  void _navigateToUserManagement() {
    Navigator.of(context).pushNamed('/admin/users');
  }

  void _navigateToUserList() {
    Navigator.of(context).pushNamed('/admin/users/list');
  }

  void _viewActiveSessions() {
    Navigator.of(context).pushNamed('/admin/sessions');
  }

  void _viewAuditLogs() {
    Navigator.of(context).pushNamed('/admin/audit');
  }

  void _viewSystemConfig() {
    Navigator.of(context).pushNamed('/admin/system-config');
  }

  void _viewSecurityEvents() {
    Navigator.of(context).pushNamed('/admin/security-events');
  }

  void _showBulkActionDialog() {
    // TODO: Show bulk action dialog
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Bulk actions coming soon')));
  }

  void _showMaintenanceDialog() {
    // TODO: Show maintenance mode dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Maintenance mode controls coming soon')),
    );
  }

  Future<void> _clearCache() async {
    final success = await ref.read(adminProvider.notifier).clearCache();
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cache cleared successfully')),
      );
    }
  }

  void _exportUsers() {
    // TODO: Implement user export
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('User export coming soon')));
  }

  void _exportAuditLogs() {
    // TODO: Implement audit log export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Audit log export coming soon')),
    );
  }

  void _handleSecurityAlert(String alertType) {
    // TODO: Handle security alert details
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Security alert: $alertType')));
  }
}
