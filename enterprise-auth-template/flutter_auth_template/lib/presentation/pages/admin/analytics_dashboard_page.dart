import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_auth_template/data/models/analytics_models.dart';
import 'package:flutter_auth_template/data/services/analytics_api_service.dart';
import 'package:flutter_auth_template/presentation/widgets/loading_indicators.dart';
import 'package:flutter_auth_template/presentation/widgets/charts/line_chart_widget.dart';
import 'package:flutter_auth_template/presentation/widgets/charts/pie_chart_widget.dart';
import 'package:flutter_auth_template/presentation/widgets/charts/bar_chart_widget.dart';

class AnalyticsDashboardPage extends ConsumerStatefulWidget {
  const AnalyticsDashboardPage({super.key});

  @override
  ConsumerState<AnalyticsDashboardPage> createState() => _AnalyticsDashboardPageState();
}

class _AnalyticsDashboardPageState extends ConsumerState<AnalyticsDashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  AnalyticsTimeRangeType _selectedTimeRange = AnalyticsTimeRangeType.last7Days;
  DateTime? _customStartDate;
  DateTime? _customEndDate;
  bool _isRealTimeEnabled = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
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
        title: const Text('Analytics Dashboard'),
        actions: [
          _buildTimeRangeSelector(),
          IconButton(
            icon: Icon(_isRealTimeEnabled ? Icons.pause : Icons.play_arrow),
            onPressed: _toggleRealTime,
            tooltip: _isRealTimeEnabled ? 'Pause Real-time' : 'Enable Real-time',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
            Tab(text: 'Users', icon: Icon(Icons.people)),
            Tab(text: 'Authentication', icon: Icon(Icons.login)),
            Tab(text: 'Security', icon: Icon(Icons.security)),
            Tab(text: 'API Usage', icon: Icon(Icons.api)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildUsersTab(),
          _buildAuthenticationTab(),
          _buildSecurityTab(),
          _buildApiUsageTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCustomQueryDialog,
        child: const Icon(Icons.analytics),
        tooltip: 'Custom Query',
      ),
    );
  }

  Widget _buildTimeRangeSelector() {
    return PopupMenuButton<AnalyticsTimeRangeType>(
      icon: const Icon(Icons.date_range),
      onSelected: (range) {
        setState(() {
          _selectedTimeRange = range;
          if (range == AnalyticsTimeRangeType.custom) {
            _showCustomDatePicker();
          }
        });
      },
      itemBuilder: (context) => AnalyticsTimeRangeType.values.map((range) {
        return PopupMenuItem(
          value: range,
          child: Row(
            children: [
              Icon(
                _selectedTimeRange == range ? Icons.check : null,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(range.displayName),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOverviewTab() {
    return FutureBuilder<AnalyticsDashboard>(
      future: _loadDashboardData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingIndicator();
        }

        if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error.toString());
        }

        final dashboard = snapshot.data!;
        return RefreshIndicator(
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildKPICards(dashboard),
                const SizedBox(height: 24),
                _buildSystemHealthCard(dashboard.systemPerformance),
                const SizedBox(height: 24),
                _buildQuickInsights(dashboard),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildKPICards(AnalyticsDashboard dashboard) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildKPICard(
          'Total Users',
          dashboard.userAnalytics.totalUsers.toString(),
          Icons.people,
          dashboard.userAnalytics.userGrowthRate >= 0 ? Colors.green : Colors.red,
          '${dashboard.userAnalytics.userGrowthRate.toStringAsFixed(1)}%',
        ),
        _buildKPICard(
          'Active Users',
          dashboard.userAnalytics.activeUsers.toString(),
          Icons.person,
          Colors.blue,
          '${(dashboard.userAnalytics.activeUsers / dashboard.userAnalytics.totalUsers * 100).toStringAsFixed(1)}%',
        ),
        _buildKPICard(
          'Login Success Rate',
          '${dashboard.authenticationAnalytics.loginSuccessRate.toStringAsFixed(1)}%',
          Icons.login,
          dashboard.authenticationAnalytics.loginSuccessRate >= 95 ? Colors.green : Colors.orange,
          '${dashboard.authenticationAnalytics.totalLogins} logins',
        ),
        _buildKPICard(
          'Security Incidents',
          dashboard.securityAnalytics.securityIncidents.toString(),
          Icons.security,
          dashboard.securityAnalytics.securityIncidents == 0 ? Colors.green : Colors.red,
          '${dashboard.securityAnalytics.blockedAttempts} blocked',
        ),
      ],
    );
  }

  Widget _buildKPICard(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    subtitle,
                    style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemHealthCard(SystemPerformance performance) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'System Health',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getHealthStatusColor(performance.healthStatus).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _getHealthStatusColor(performance.healthStatus)),
                  ),
                  child: Text(
                    performance.healthStatus.displayName,
                    style: TextStyle(
                      color: _getHealthStatusColor(performance.healthStatus),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildMetricIndicator('CPU', performance.cpuUsage, '%')),
                Expanded(child: _buildMetricIndicator('Memory', performance.memoryUsage, '%')),
                Expanded(child: _buildMetricIndicator('Disk', performance.diskUsage, '%')),
                Expanded(child: _buildMetricIndicator('Response', performance.averageResponseTime, 'ms')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricIndicator(String label, double value, String unit) {
    Color color;
    if (unit == '%') {
      color = value > 80 ? Colors.red : value > 60 ? Colors.orange : Colors.green;
    } else {
      color = value > 1000 ? Colors.red : value > 500 ? Colors.orange : Colors.green;
    }

    return Column(
      children: [
        CircularProgressIndicator(
          value: unit == '%' ? value / 100 : (value / 2000).clamp(0.0, 1.0),
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
        const SizedBox(height: 8),
        Text(
          '${value.toStringAsFixed(unit == '%' ? 1 : 0)}$unit',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildQuickInsights(AnalyticsDashboard dashboard) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Insights',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildInsightTile(
              Icons.trending_up,
              'User Growth',
              '${dashboard.userAnalytics.newUsersToday} new users today',
              Colors.green,
            ),
            _buildInsightTile(
              Icons.warning,
              'Security Alerts',
              '${dashboard.securityAnalytics.securityIncidents} incidents this week',
              dashboard.securityAnalytics.securityIncidents > 0 ? Colors.red : Colors.green,
            ),
            _buildInsightTile(
              Icons.api,
              'API Performance',
              '${dashboard.apiUsageAnalytics.averageResponseTime.toStringAsFixed(0)}ms avg response time',
              dashboard.apiUsageAnalytics.averageResponseTime < 200 ? Colors.green : Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightTile(IconData icon, String title, String subtitle, Color color) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }

  Widget _buildUsersTab() {
    return FutureBuilder<UserAnalytics>(
      future: _loadUserAnalytics(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingIndicator();
        }

        if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error.toString());
        }

        final analytics = snapshot.data!;
        return RefreshIndicator(
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUserStatsGrid(analytics),
                const SizedBox(height: 24),
                _buildUserGrowthChart(analytics),
                const SizedBox(height: 24),
                _buildUserRoleDistribution(analytics),
                const SizedBox(height: 24),
                _buildUserActivityChart(analytics),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserStatsGrid(UserAnalytics analytics) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard('Total Users', analytics.totalUsers.toString(), Icons.people),
        _buildStatCard('Active Users', analytics.activeUsers.toString(), Icons.person),
        _buildStatCard('New Today', analytics.newUsersToday.toString(), Icons.person_add),
        _buildStatCard('New This Week', analytics.newUsersThisWeek.toString(), Icons.trending_up),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserGrowthChart(UserAnalytics analytics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Growth Trend',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChartWidget(
                data: analytics.userGrowthChart
                    .map((data) => ChartDataPoint(
                          x: data.date.millisecondsSinceEpoch.toDouble(),
                          y: data.newUsers.toDouble(),
                        ))
                    .toList(),
                title: 'New Users',
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserRoleDistribution(UserAnalytics analytics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Distribution by Role',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChartWidget(
                data: analytics.usersByRole.entries
                    .map((entry) => PieChartData(
                          label: entry.key,
                          value: entry.value.toDouble(),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserActivityChart(UserAnalytics analytics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Activity',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChartWidget(
                data: analytics.userActivityChart
                    .map((data) => BarChartData(
                          label: '${data.timestamp.hour}:00',
                          value: data.activeUsers.toDouble(),
                        ))
                    .toList(),
                title: 'Active Users',
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthenticationTab() {
    return FutureBuilder<AuthenticationAnalytics>(
      future: _loadAuthenticationAnalytics(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingIndicator();
        }

        if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error.toString());
        }

        final analytics = snapshot.data!;
        return RefreshIndicator(
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAuthStatsGrid(analytics),
                const SizedBox(height: 24),
                _buildLoginTrendChart(analytics),
                const SizedBox(height: 24),
                _buildAuthMethodChart(analytics),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAuthStatsGrid(AuthenticationAnalytics analytics) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard('Total Logins', analytics.totalLogins.toString(), Icons.login),
        _buildStatCard('Success Rate', '${analytics.loginSuccessRate.toStringAsFixed(1)}%', Icons.check_circle),
        _buildStatCard('Successful', analytics.successfulLogins.toString(), Icons.verified),
        _buildStatCard('Failed', analytics.failedLogins.toString(), Icons.error),
      ],
    );
  }

  Widget _buildLoginTrendChart(AuthenticationAnalytics analytics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Login Trends',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChartWidget(
                data: analytics.loginTrends
                    .map((data) => ChartDataPoint(
                          x: data.date.millisecondsSinceEpoch.toDouble(),
                          y: data.successful.toDouble(),
                        ))
                    .toList(),
                title: 'Successful Logins',
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthMethodChart(AuthenticationAnalytics analytics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Authentication Methods',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChartWidget(
                data: analytics.authMethodUsage
                    .map((method) => PieChartData(
                          label: method.displayName,
                          value: method.count.toDouble(),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityTab() {
    return FutureBuilder<SecurityAnalytics>(
      future: _loadSecurityAnalytics(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingIndicator();
        }

        if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error.toString());
        }

        final analytics = snapshot.data!;
        return RefreshIndicator(
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSecurityStatsGrid(analytics),
                const SizedBox(height: 24),
                _buildSecurityTrendChart(analytics),
                const SizedBox(height: 24),
                _buildRecentIncidents(analytics),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSecurityStatsGrid(SecurityAnalytics analytics) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard('Incidents', analytics.securityIncidents.toString(), Icons.warning),
        _buildStatCard('Blocked', analytics.blockedAttempts.toString(), Icons.block),
        _buildStatCard('Suspicious', analytics.suspiciousActivities.toString(), Icons.flag),
        _buildStatCard('Active Devices', analytics.activeDevices.toString(), Icons.devices),
      ],
    );
  }

  Widget _buildSecurityTrendChart(SecurityAnalytics analytics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Security Trends',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChartWidget(
                data: analytics.securityTrends
                    .map((data) => ChartDataPoint(
                          x: data.date.millisecondsSinceEpoch.toDouble(),
                          y: data.incidents.toDouble(),
                        ))
                    .toList(),
                title: 'Security Incidents',
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentIncidents(SecurityAnalytics analytics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Security Incidents',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...analytics.recentIncidents.take(5).map((incident) => _buildIncidentTile(incident)),
          ],
        ),
      ),
    );
  }

  Widget _buildIncidentTile(SecurityIncident incident) {
    Color severityColor;
    switch (incident.severity.toLowerCase()) {
      case 'high':
        severityColor = Colors.red;
        break;
      case 'medium':
        severityColor = Colors.orange;
        break;
      default:
        severityColor = Colors.blue;
    }

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: severityColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.warning, color: severityColor),
      ),
      title: Text(incident.type),
      subtitle: Text(incident.description),
      trailing: Text(
        _formatDateTime(incident.timestamp),
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }

  Widget _buildApiUsageTab() {
    return FutureBuilder<ApiUsageAnalytics>(
      future: _loadApiUsageAnalytics(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingIndicator();
        }

        if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error.toString());
        }

        final analytics = snapshot.data!;
        return RefreshIndicator(
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildApiStatsGrid(analytics),
                const SizedBox(height: 24),
                _buildApiUsageChart(analytics),
                const SizedBox(height: 24),
                _buildTopEndpoints(analytics),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildApiStatsGrid(ApiUsageAnalytics analytics) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard('Total Requests', analytics.totalRequests.toString(), Icons.api),
        _buildStatCard('Success Rate', '${((analytics.successfulRequests / analytics.totalRequests) * 100).toStringAsFixed(1)}%', Icons.check_circle),
        _buildStatCard('Avg Response', '${analytics.averageResponseTime.toStringAsFixed(0)}ms', Icons.timer),
        _buildStatCard('Active Keys', analytics.activeApiKeys.toString(), Icons.key),
      ],
    );
  }

  Widget _buildApiUsageChart(ApiUsageAnalytics analytics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'API Usage Trends',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChartWidget(
                data: analytics.usageTrends
                    .map((data) => ChartDataPoint(
                          x: data.timestamp.millisecondsSinceEpoch.toDouble(),
                          y: data.requests.toDouble(),
                        ))
                    .toList(),
                title: 'API Requests',
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopEndpoints(ApiUsageAnalytics analytics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top API Endpoints',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...analytics.topEndpoints.take(5).map((endpoint) => _buildEndpointTile(endpoint)),
          ],
        ),
      ),
    );
  }

  Widget _buildEndpointTile(EndpointPerformance endpoint) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.api, color: Theme.of(context).primaryColor),
      ),
      title: Text('${endpoint.method} ${endpoint.endpoint}'),
      subtitle: Text(
        '${endpoint.requestCount} requests • ${endpoint.averageResponseTime.toStringAsFixed(0)}ms avg',
      ),
      trailing: Text(
        '${endpoint.errorRate.toStringAsFixed(1)}% error',
        style: TextStyle(
          color: endpoint.errorRate > 5 ? Colors.red : Colors.green,
          fontWeight: FontWeight.bold,
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
            'Failed to load analytics',
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
            onPressed: _refreshData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // Data loading methods
  Future<AnalyticsDashboard> _loadDashboardData() async {
    final analyticsService = ref.read(analyticsApiServiceProvider);
    return await analyticsService.getDashboardAnalytics(
      startDate: _getStartDate(),
      endDate: _getEndDate(),
    );
  }

  Future<UserAnalytics> _loadUserAnalytics() async {
    final analyticsService = ref.read(analyticsApiServiceProvider);
    return await analyticsService.getUserAnalytics(
      startDate: _getStartDate(),
      endDate: _getEndDate(),
    );
  }

  Future<AuthenticationAnalytics> _loadAuthenticationAnalytics() async {
    final analyticsService = ref.read(analyticsApiServiceProvider);
    return await analyticsService.getAuthenticationAnalytics(
      startDate: _getStartDate(),
      endDate: _getEndDate(),
    );
  }

  Future<SecurityAnalytics> _loadSecurityAnalytics() async {
    final analyticsService = ref.read(analyticsApiServiceProvider);
    return await analyticsService.getSecurityAnalytics(
      startDate: _getStartDate(),
      endDate: _getEndDate(),
    );
  }

  Future<ApiUsageAnalytics> _loadApiUsageAnalytics() async {
    final analyticsService = ref.read(analyticsApiServiceProvider);
    return await analyticsService.getApiUsageAnalytics(
      startDate: _getStartDate(),
      endDate: _getEndDate(),
    );
  }

  DateTime? _getStartDate() {
    if (_selectedTimeRange == AnalyticsTimeRangeType.custom) {
      return _customStartDate;
    }
    
    final now = DateTime.now();
    switch (_selectedTimeRange) {
      case AnalyticsTimeRangeType.last24Hours:
        return now.subtract(const Duration(days: 1));
      case AnalyticsTimeRangeType.last7Days:
        return now.subtract(const Duration(days: 7));
      case AnalyticsTimeRangeType.last30Days:
        return now.subtract(const Duration(days: 30));
      case AnalyticsTimeRangeType.last90Days:
        return now.subtract(const Duration(days: 90));
      default:
        return null;
    }
  }

  DateTime? _getEndDate() {
    if (_selectedTimeRange == AnalyticsTimeRangeType.custom) {
      return _customEndDate;
    }
    return null;
  }

  Color _getHealthStatusColor(SystemHealthStatus status) {
    switch (status) {
      case SystemHealthStatus.healthy:
        return Colors.green;
      case SystemHealthStatus.warning:
        return Colors.orange;
      case SystemHealthStatus.critical:
        return Colors.red;
      case SystemHealthStatus.unknown:
        return Colors.grey;
    }
  }

  void _toggleRealTime() {
    setState(() {
      _isRealTimeEnabled = !_isRealTimeEnabled;
    });
    // TODO: Implement real-time updates using WebSocket
  }

  Future<void> _refreshData() async {
    setState(() {});
  }

  void _showCustomDatePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: _customStartDate ?? DateTime.now().subtract(const Duration(days: 7)),
        end: _customEndDate ?? DateTime.now(),
      ),
    );

    if (picked != null) {
      setState(() {
        _customStartDate = picked.start;
        _customEndDate = picked.end;
      });
    }
  }

  void _showCustomQueryDialog() {
    // TODO: Implement custom query builder
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Custom Query'),
        content: const Text('Custom query builder coming soon...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}