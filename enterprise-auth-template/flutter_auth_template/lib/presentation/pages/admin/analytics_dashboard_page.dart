import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/analytics_models.dart';
import '../../../data/services/analytics_api_service.dart';
import '../../widgets/loading_indicators.dart';
import '../../widgets/charts/line_chart_widget.dart';
import '../../widgets/charts/pie_chart_widget.dart';
import '../../widgets/charts/bar_chart_widget.dart';

class AnalyticsDashboardPage extends ConsumerStatefulWidget {
  const AnalyticsDashboardPage({super.key});

  @override
  ConsumerState&lt;AnalyticsDashboardPage&gt; createState() =&gt; _AnalyticsDashboardPageState();
}

class _AnalyticsDashboardPageState extends ConsumerState&lt;AnalyticsDashboardPage&gt;
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
        title: const Text(&apos;Analytics Dashboard&apos;),
        actions: [
          _buildTimeRangeSelector(),
          IconButton(
            icon: Icon(_isRealTimeEnabled ? Icons.pause : Icons.play_arrow),
            onPressed: _toggleRealTime,
            tooltip: _isRealTimeEnabled ? &apos;Pause Real-time&apos; : &apos;Enable Real-time&apos;,
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
            Tab(text: &apos;Overview&apos;, icon: Icon(Icons.dashboard)),
            Tab(text: &apos;Users&apos;, icon: Icon(Icons.people)),
            Tab(text: &apos;Authentication&apos;, icon: Icon(Icons.login)),
            Tab(text: &apos;Security&apos;, icon: Icon(Icons.security)),
            Tab(text: &apos;API Usage&apos;, icon: Icon(Icons.api)),
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
        tooltip: &apos;Custom Query&apos;,
      ),
    );
  }

  Widget _buildTimeRangeSelector() {
    return PopupMenuButton&lt;AnalyticsTimeRangeType&gt;(
      icon: const Icon(Icons.date_range),
      onSelected: (range) {
        setState(() {
          _selectedTimeRange = range;
          if (range == AnalyticsTimeRangeType.custom) {
            _showCustomDatePicker();
          }
        });
      },
      itemBuilder: (context) =&gt; AnalyticsTimeRangeType.values.map((range) {
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
    return FutureBuilder&lt;AnalyticsDashboard&gt;(
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
          &apos;Total Users&apos;,
          dashboard.userAnalytics.totalUsers.toString(),
          Icons.people,
          dashboard.userAnalytics.userGrowthRate &gt;= 0 ? Colors.green : Colors.red,
          &apos;${dashboard.userAnalytics.userGrowthRate.toStringAsFixed(1)}%&apos;,
        ),
        _buildKPICard(
          &apos;Active Users&apos;,
          dashboard.userAnalytics.activeUsers.toString(),
          Icons.person,
          Colors.blue,
          &apos;${(dashboard.userAnalytics.activeUsers / dashboard.userAnalytics.totalUsers * 100).toStringAsFixed(1)}%&apos;,
        ),
        _buildKPICard(
          &apos;Login Success Rate&apos;,
          &apos;${dashboard.authenticationAnalytics.loginSuccessRate.toStringAsFixed(1)}%&apos;,
          Icons.login,
          dashboard.authenticationAnalytics.loginSuccessRate &gt;= 95 ? Colors.green : Colors.orange,
          &apos;${dashboard.authenticationAnalytics.totalLogins} logins&apos;,
        ),
        _buildKPICard(
          &apos;Security Incidents&apos;,
          dashboard.securityAnalytics.securityIncidents.toString(),
          Icons.security,
          dashboard.securityAnalytics.securityIncidents == 0 ? Colors.green : Colors.red,
          &apos;${dashboard.securityAnalytics.blockedAttempts} blocked&apos;,
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
                  &apos;System Health&apos;,
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
                Expanded(child: _buildMetricIndicator(&apos;CPU&apos;, performance.cpuUsage, &apos;%&apos;)),
                Expanded(child: _buildMetricIndicator(&apos;Memory&apos;, performance.memoryUsage, &apos;%&apos;)),
                Expanded(child: _buildMetricIndicator(&apos;Disk&apos;, performance.diskUsage, &apos;%&apos;)),
                Expanded(child: _buildMetricIndicator(&apos;Response&apos;, performance.averageResponseTime, &apos;ms&apos;)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricIndicator(String label, double value, String unit) {
    Color color;
    if (unit == &apos;%&apos;) {
      color = value &gt; 80 ? Colors.red : value &gt; 60 ? Colors.orange : Colors.green;
    } else {
      color = value &gt; 1000 ? Colors.red : value &gt; 500 ? Colors.orange : Colors.green;
    }

    return Column(
      children: [
        CircularProgressIndicator(
          value: unit == &apos;%&apos; ? value / 100 : (value / 2000).clamp(0.0, 1.0),
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation&lt;Color&gt;(color),
        ),
        const SizedBox(height: 8),
        Text(
          &apos;${value.toStringAsFixed(unit == &apos;%&apos; ? 1 : 0)}$unit&apos;,
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
              &apos;Quick Insights&apos;,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildInsightTile(
              Icons.trending_up,
              &apos;User Growth&apos;,
              &apos;${dashboard.userAnalytics.newUsersToday} new users today&apos;,
              Colors.green,
            ),
            _buildInsightTile(
              Icons.warning,
              &apos;Security Alerts&apos;,
              &apos;${dashboard.securityAnalytics.securityIncidents} incidents this week&apos;,
              dashboard.securityAnalytics.securityIncidents &gt; 0 ? Colors.red : Colors.green,
            ),
            _buildInsightTile(
              Icons.api,
              &apos;API Performance&apos;,
              &apos;${dashboard.apiUsageAnalytics.averageResponseTime.toStringAsFixed(0)}ms avg response time&apos;,
              dashboard.apiUsageAnalytics.averageResponseTime &lt; 200 ? Colors.green : Colors.orange,
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
    return FutureBuilder&lt;UserAnalytics&gt;(
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
        _buildStatCard(&apos;Total Users&apos;, analytics.totalUsers.toString(), Icons.people),
        _buildStatCard(&apos;Active Users&apos;, analytics.activeUsers.toString(), Icons.person),
        _buildStatCard(&apos;New Today&apos;, analytics.newUsersToday.toString(), Icons.person_add),
        _buildStatCard(&apos;New This Week&apos;, analytics.newUsersThisWeek.toString(), Icons.trending_up),
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
              &apos;User Growth Trend&apos;,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChartWidget(
                data: analytics.userGrowthChart
                    .map((data) =&gt; ChartDataPoint(
                          x: data.date.millisecondsSinceEpoch.toDouble(),
                          y: data.newUsers.toDouble(),
                        ))
                    .toList(),
                title: &apos;New Users&apos;,
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
              &apos;User Distribution by Role&apos;,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChartWidget(
                data: analytics.usersByRole.entries
                    .map((entry) =&gt; PieChartData(
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
              &apos;User Activity&apos;,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChartWidget(
                data: analytics.userActivityChart
                    .map((data) =&gt; BarChartData(
                          label: &apos;${data.timestamp.hour}:00&apos;,
                          value: data.activeUsers.toDouble(),
                        ))
                    .toList(),
                title: &apos;Active Users&apos;,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthenticationTab() {
    return FutureBuilder&lt;AuthenticationAnalytics&gt;(
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
        _buildStatCard(&apos;Total Logins&apos;, analytics.totalLogins.toString(), Icons.login),
        _buildStatCard(&apos;Success Rate&apos;, &apos;${analytics.loginSuccessRate.toStringAsFixed(1)}%&apos;, Icons.check_circle),
        _buildStatCard(&apos;Successful&apos;, analytics.successfulLogins.toString(), Icons.verified),
        _buildStatCard(&apos;Failed&apos;, analytics.failedLogins.toString(), Icons.error),
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
              &apos;Login Trends&apos;,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChartWidget(
                data: analytics.loginTrends
                    .map((data) =&gt; ChartDataPoint(
                          x: data.date.millisecondsSinceEpoch.toDouble(),
                          y: data.successful.toDouble(),
                        ))
                    .toList(),
                title: &apos;Successful Logins&apos;,
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
              &apos;Authentication Methods&apos;,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChartWidget(
                data: analytics.authMethodUsage
                    .map((method) =&gt; PieChartData(
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
    return FutureBuilder&lt;SecurityAnalytics&gt;(
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
        _buildStatCard(&apos;Incidents&apos;, analytics.securityIncidents.toString(), Icons.warning),
        _buildStatCard(&apos;Blocked&apos;, analytics.blockedAttempts.toString(), Icons.block),
        _buildStatCard(&apos;Suspicious&apos;, analytics.suspiciousActivities.toString(), Icons.flag),
        _buildStatCard(&apos;Active Devices&apos;, analytics.activeDevices.toString(), Icons.devices),
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
              &apos;Security Trends&apos;,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChartWidget(
                data: analytics.securityTrends
                    .map((data) =&gt; ChartDataPoint(
                          x: data.date.millisecondsSinceEpoch.toDouble(),
                          y: data.incidents.toDouble(),
                        ))
                    .toList(),
                title: &apos;Security Incidents&apos;,
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
              &apos;Recent Security Incidents&apos;,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...analytics.recentIncidents.take(5).map((incident) =&gt; _buildIncidentTile(incident)),
          ],
        ),
      ),
    );
  }

  Widget _buildIncidentTile(SecurityIncident incident) {
    Color severityColor;
    switch (incident.severity.toLowerCase()) {
      case &apos;high&apos;:
        severityColor = Colors.red;
        break;
      case &apos;medium&apos;:
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
    return FutureBuilder&lt;ApiUsageAnalytics&gt;(
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
        _buildStatCard(&apos;Total Requests&apos;, analytics.totalRequests.toString(), Icons.api),
        _buildStatCard(&apos;Success Rate&apos;, &apos;${((analytics.successfulRequests / analytics.totalRequests) * 100).toStringAsFixed(1)}%&apos;, Icons.check_circle),
        _buildStatCard(&apos;Avg Response&apos;, &apos;${analytics.averageResponseTime.toStringAsFixed(0)}ms&apos;, Icons.timer),
        _buildStatCard(&apos;Active Keys&apos;, analytics.activeApiKeys.toString(), Icons.key),
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
              &apos;API Usage Trends&apos;,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChartWidget(
                data: analytics.usageTrends
                    .map((data) =&gt; ChartDataPoint(
                          x: data.timestamp.millisecondsSinceEpoch.toDouble(),
                          y: data.requests.toDouble(),
                        ))
                    .toList(),
                title: &apos;API Requests&apos;,
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
              &apos;Top API Endpoints&apos;,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...analytics.topEndpoints.take(5).map((endpoint) =&gt; _buildEndpointTile(endpoint)),
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
      title: Text(&apos;${endpoint.method} ${endpoint.endpoint}&apos;),
      subtitle: Text(
        &apos;${endpoint.requestCount} requests • ${endpoint.averageResponseTime.toStringAsFixed(0)}ms avg&apos;,
      ),
      trailing: Text(
        &apos;${endpoint.errorRate.toStringAsFixed(1)}% error&apos;,
        style: TextStyle(
          color: endpoint.errorRate &gt; 5 ? Colors.red : Colors.green,
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
            &apos;Failed to load analytics&apos;,
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
            child: const Text(&apos;Retry&apos;),
          ),
        ],
      ),
    );
  }

  // Data loading methods
  Future&lt;AnalyticsDashboard&gt; _loadDashboardData() async {
    final analyticsService = ref.read(analyticsApiServiceProvider);
    return await analyticsService.getDashboardAnalytics(
      startDate: _getStartDate(),
      endDate: _getEndDate(),
    );
  }

  Future&lt;UserAnalytics&gt; _loadUserAnalytics() async {
    final analyticsService = ref.read(analyticsApiServiceProvider);
    return await analyticsService.getUserAnalytics(
      startDate: _getStartDate(),
      endDate: _getEndDate(),
    );
  }

  Future&lt;AuthenticationAnalytics&gt; _loadAuthenticationAnalytics() async {
    final analyticsService = ref.read(analyticsApiServiceProvider);
    return await analyticsService.getAuthenticationAnalytics(
      startDate: _getStartDate(),
      endDate: _getEndDate(),
    );
  }

  Future&lt;SecurityAnalytics&gt; _loadSecurityAnalytics() async {
    final analyticsService = ref.read(analyticsApiServiceProvider);
    return await analyticsService.getSecurityAnalytics(
      startDate: _getStartDate(),
      endDate: _getEndDate(),
    );
  }

  Future&lt;ApiUsageAnalytics&gt; _loadApiUsageAnalytics() async {
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

  Future&lt;void&gt; _refreshData() async {
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
      builder: (context) =&gt; AlertDialog(
        title: const Text(&apos;Custom Query&apos;),
        content: const Text(&apos;Custom query builder coming soon...&apos;),
        actions: [
          TextButton(
            onPressed: () =&gt; Navigator.of(context).pop(),
            child: const Text(&apos;Close&apos;),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return &apos;${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, &apos;0&apos;)}&apos;;
  }
}