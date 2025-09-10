import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_auth_template/data/models/user_models.dart';
import 'package:flutter_auth_template/data/models/auth_models.dart';
import 'package:flutter_auth_template/data/models/dashboard_models.dart';
import 'package:flutter_auth_template/data/models/device_models.dart';
import 'package:flutter_auth_template/data/models/api_key_models.dart';
import 'package:flutter_auth_template/data/models/webhook_models.dart';
import 'package:flutter_auth_template/data/models/analytics_models.dart';
import 'package:flutter_auth_template/providers/auth_provider.dart';
import 'package:flutter_auth_template/providers/dashboard_provider.dart';
import 'package:flutter_auth_template/providers/device_provider.dart';
import 'package:flutter_auth_template/providers/api_key_provider.dart';
import 'package:flutter_auth_template/providers/webhook_provider.dart';
import 'package:flutter_auth_template/providers/analytics_provider.dart';

/// Mock providers for testing
class MockProviders {
  MockProviders._();

  /// Creates mock auth provider with authenticated user
  static Override mockAuthenticatedUser({
    String? id,
    String? email,
    String? name,
    UserRole? role,
  }) {
    final user = User(
      id: id ?? 'test-user-id',
      email: email ?? 'test@example.com',
      name: name ?? 'Test User',
      role: role ?? UserRole.user,
      createdAt: DateTime.now(),
      isActive: true,
    );

    return authProvider.overrideWith((ref) => AsyncValue.data(user));
  }

  /// Creates mock auth provider with unauthenticated state
  static Override mockUnauthenticatedUser() {
    return authProvider.overrideWith((ref) => const AsyncValue.data(null));
  }

  /// Creates mock auth provider with loading state
  static Override mockAuthLoading() {
    return authProvider.overrideWith((ref) => const AsyncValue.loading());
  }

  /// Creates mock auth provider with error state
  static Override mockAuthError(String error) {
    return authProvider.overrideWith(
      (ref) => AsyncValue.error(Exception(error), StackTrace.current),
    );
  }

  /// Creates mock dashboard provider with sample data
  static Override mockDashboardData({
    int? totalUsers,
    int? activeUsers,
    int? newUsersToday,
    SystemHealth? systemHealth,
  }) {
    final dashboardData = DashboardData(
      totalUsers: totalUsers ?? 1250,
      activeUsers: activeUsers ?? 890,
      newUsersToday: newUsersToday ?? 45,
      totalSessions: 3420,
      activeSessions: 125,
      failedLogins: 12,
      securityAlerts: 3,
      apiRequests: 15670,
      errorRate: 2.1,
      averageResponseTime: 245.5,
      systemHealth: systemHealth ?? SystemHealth.healthy,
      recentActivities: _createMockRecentActivities(),
      quickStats: _createMockQuickStats(),
    );

    return dashboardDataProvider.overrideWith((ref) => AsyncValue.data(dashboardData));
  }

  /// Creates mock device provider with sample devices
  static Override mockDeviceList({
    List<Device>? devices,
  }) {
    final deviceList = devices ?? _createMockDevices();
    return deviceListProvider.overrideWith((ref) => AsyncValue.data(deviceList));
  }

  /// Creates mock API key provider with sample keys
  static Override mockApiKeyList({
    List<ApiKey>? apiKeys,
  }) {
    final keyList = apiKeys ?? _createMockApiKeys();
    return apiKeyListProvider.overrideWith((ref) => AsyncValue.data(keyList));
  }

  /// Creates mock webhook provider with sample webhooks
  static Override mockWebhookList({
    List<Webhook>? webhooks,
  }) {
    final webhookList = webhooks ?? _createMockWebhooks();
    return webhookListProvider.overrideWith((ref) => AsyncValue.data(webhookList));
  }

  /// Creates mock analytics provider with sample data
  static Override mockAnalyticsData({
    UserAnalytics? userAnalytics,
    AuthenticationAnalytics? authAnalytics,
    SecurityAnalytics? securityAnalytics,
    ApiAnalytics? apiAnalytics,
  }) {
    final analyticsData = AnalyticsData(
      userAnalytics: userAnalytics ?? _createMockUserAnalytics(),
      authenticationAnalytics: authAnalytics ?? _createMockAuthAnalytics(),
      securityAnalytics: securityAnalytics ?? _createMockSecurityAnalytics(),
      apiAnalytics: apiAnalytics ?? _createMockApiAnalytics(),
      generatedAt: DateTime.now(),
    );

    return analyticsDataProvider.overrideWith((ref) => AsyncValue.data(analyticsData));
  }

  /// Creates a comprehensive set of mock overrides for testing
  static List<Override> createComprehensiveMocks({
    User? user,
    DashboardData? dashboardData,
    List<Device>? devices,
    List<ApiKey>? apiKeys,
    List<Webhook>? webhooks,
    AnalyticsData? analyticsData,
  }) {
    return [
      if (user != null)
        authProvider.overrideWith((ref) => AsyncValue.data(user))
      else
        mockAuthenticatedUser(),
      
      dashboardData != null
          ? dashboardDataProvider.overrideWith((ref) => AsyncValue.data(dashboardData))
          : mockDashboardData(),
      
      devices != null
          ? deviceListProvider.overrideWith((ref) => AsyncValue.data(devices))
          : mockDeviceList(),
      
      apiKeys != null
          ? apiKeyListProvider.overrideWith((ref) => AsyncValue.data(apiKeys))
          : mockApiKeyList(),
      
      webhooks != null
          ? webhookListProvider.overrideWith((ref) => AsyncValue.data(webhooks))
          : mockWebhookList(),
      
      analyticsData != null
          ? analyticsDataProvider.overrideWith((ref) => AsyncValue.data(analyticsData))
          : mockAnalyticsData(),
    ];
  }

  /// Creates mock provider for error states
  static List<Override> createErrorStateMocks() {
    return [
      authProvider.overrideWith(
        (ref) => AsyncValue.error(Exception('Auth error'), StackTrace.current),
      ),
      dashboardDataProvider.overrideWith(
        (ref) => AsyncValue.error(Exception('Dashboard error'), StackTrace.current),
      ),
      deviceListProvider.overrideWith(
        (ref) => AsyncValue.error(Exception('Device error'), StackTrace.current),
      ),
      apiKeyListProvider.overrideWith(
        (ref) => AsyncValue.error(Exception('API key error'), StackTrace.current),
      ),
    ];
  }

  /// Creates mock provider for loading states
  static List<Override> createLoadingStateMocks() {
    return [
      authProvider.overrideWith((ref) => const AsyncValue.loading()),
      dashboardDataProvider.overrideWith((ref) => const AsyncValue.loading()),
      deviceListProvider.overrideWith((ref) => const AsyncValue.loading()),
      apiKeyListProvider.overrideWith((ref) => const AsyncValue.loading()),
      webhookListProvider.overrideWith((ref) => const AsyncValue.loading()),
      analyticsDataProvider.overrideWith((ref) => const AsyncValue.loading()),
    ];
  }

  /// Creates mock provider with empty states
  static List<Override> createEmptyStateMocks() {
    return [
      authProvider.overrideWith((ref) => const AsyncValue.data(null)),
      dashboardDataProvider.overrideWith((ref) => AsyncValue.data(_createEmptyDashboardData())),
      deviceListProvider.overrideWith((ref) => const AsyncValue.data([])),
      apiKeyListProvider.overrideWith((ref) => const AsyncValue.data([])),
      webhookListProvider.overrideWith((ref) => const AsyncValue.data([])),
    ];
  }
}

// Helper functions to create mock data

List<RecentActivity> _createMockRecentActivities() {
  return [
    RecentActivity(
      id: '1',
      type: ActivityType.userLogin,
      description: 'test@example.com logged in',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      severity: ActivitySeverity.info,
    ),
    RecentActivity(
      id: '2',
      type: ActivityType.securityAlert,
      description: 'Multiple failed login attempts detected',
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      severity: ActivitySeverity.warning,
    ),
    RecentActivity(
      id: '3',
      type: ActivityType.systemUpdate,
      description: 'System maintenance completed',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      severity: ActivitySeverity.info,
    ),
  ];
}

List<QuickStat> _createMockQuickStats() {
  return [
    QuickStat(
      label: 'Response Time',
      value: '245ms',
      trend: StatTrend.up,
      changePercentage: 5.2,
    ),
    QuickStat(
      label: 'Error Rate',
      value: '2.1%',
      trend: StatTrend.down,
      changePercentage: -0.5,
    ),
    QuickStat(
      label: 'Active Sessions',
      value: '125',
      trend: StatTrend.stable,
      changePercentage: 0.0,
    ),
  ];
}

List<Device> _createMockDevices() {
  return [
    Device(
      id: 'device-1',
      userId: 'user-1',
      deviceName: 'iPhone 13 Pro',
      deviceType: DeviceType.mobile,
      platform: DevicePlatform.ios,
      lastSeenAt: DateTime.now().subtract(const Duration(minutes: 5)),
      isActive: true,
      location: 'San Francisco, CA',
      ipAddress: '192.168.1.100',
      userAgent: 'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X)',
      isTrusted: true,
      securityAlerts: [],
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    Device(
      id: 'device-2',
      userId: 'user-1',
      deviceName: 'MacBook Pro',
      deviceType: DeviceType.desktop,
      platform: DevicePlatform.macos,
      lastSeenAt: DateTime.now().subtract(const Duration(hours: 2)),
      isActive: false,
      location: 'San Francisco, CA',
      ipAddress: '192.168.1.101',
      userAgent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)',
      isTrusted: true,
      securityAlerts: [],
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
  ];
}

List<ApiKey> _createMockApiKeys() {
  return [
    ApiKey(
      id: 'key-1',
      name: 'Production API',
      keyPrefix: 'pk_live_',
      permissions: [ApiKeyPermission.read, ApiKeyPermission.write],
      scopes: ['users', 'analytics'],
      isActive: true,
      lastUsedAt: DateTime.now().subtract(const Duration(minutes: 30)),
      expiresAt: DateTime.now().add(const Duration(days: 365)),
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      rateLimit: ApiKeyRateLimit(
        requestsPerMinute: 1000,
        requestsPerHour: 10000,
        requestsPerDay: 100000,
      ),
      usage: ApiKeyUsage(
        totalRequests: 45678,
        requestsToday: 234,
        lastRequestAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
    ),
    ApiKey(
      id: 'key-2',
      name: 'Development API',
      keyPrefix: 'pk_test_',
      permissions: [ApiKeyPermission.read],
      scopes: ['users'],
      isActive: true,
      lastUsedAt: DateTime.now().subtract(const Duration(hours: 3)),
      expiresAt: DateTime.now().add(const Duration(days: 30)),
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      rateLimit: ApiKeyRateLimit(
        requestsPerMinute: 100,
        requestsPerHour: 1000,
        requestsPerDay: 10000,
      ),
      usage: ApiKeyUsage(
        totalRequests: 1234,
        requestsToday: 45,
        lastRequestAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
    ),
  ];
}

List<Webhook> _createMockWebhooks() {
  return [
    Webhook(
      id: 'webhook-1',
      name: 'User Registration Webhook',
      url: 'https://api.example.com/webhooks/user-registered',
      events: [WebhookEvent.userRegistered, WebhookEvent.userUpdated],
      isActive: true,
      secret: 'whsec_test123',
      retryConfig: WebhookRetryConfig(
        maxRetries: 3,
        retryDelay: const Duration(minutes: 1),
        backoffMultiplier: 2.0,
      ),
      headers: {'Authorization': 'Bearer token123'},
      timeout: const Duration(seconds: 30),
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      lastTriggeredAt: DateTime.now().subtract(const Duration(hours: 2)),
      deliveryStats: WebhookDeliveryStats(
        totalDeliveries: 156,
        successfulDeliveries: 152,
        failedDeliveries: 4,
        lastSuccessAt: DateTime.now().subtract(const Duration(hours: 2)),
        lastFailureAt: DateTime.now().subtract(const Duration(days: 3)),
        averageResponseTime: 245.6,
      ),
    ),
  ];
}

UserAnalytics _createMockUserAnalytics() {
  return UserAnalytics(
    totalUsers: 1250,
    activeUsers: 890,
    newUsersToday: 45,
    newUsersThisWeek: 312,
    newUsersThisMonth: 1204,
    userGrowthRate: 15.6,
    userRetentionRate: 78.4,
    averageSessionDuration: const Duration(minutes: 23, seconds: 45),
    usersByRole: {
      UserRole.user: 1180,
      UserRole.admin: 45,
      UserRole.moderator: 25,
    },
    userRegistrationTrend: List.generate(30, (index) => 
      DataPoint(
        date: DateTime.now().subtract(Duration(days: 29 - index)),
        value: 20 + (index % 7) * 5 + (index ~/ 7) * 2,
      ),
    ),
  );
}

AuthenticationAnalytics _createMockAuthAnalytics() {
  return AuthenticationAnalytics(
    totalLogins: 5670,
    successfulLogins: 5542,
    failedLogins: 128,
    loginSuccessRate: 97.7,
    averageLoginTime: const Duration(milliseconds: 1234),
    uniqueLoginUsers: 856,
    twoFactorUsage: 234,
    passwordResets: 23,
    loginsByMethod: {
      'email_password': 4890,
      'google_oauth': 567,
      'github_oauth': 213,
    },
    loginTrend: List.generate(24, (index) =>
      DataPoint(
        date: DateTime.now().subtract(Duration(hours: 23 - index)),
        value: 180 + (index % 4) * 20,
      ),
    ),
  );
}

SecurityAnalytics _createMockSecurityAnalytics() {
  return SecurityAnalytics(
    securityAlerts: 12,
    blockedIps: 5,
    suspiciousActivities: 8,
    malwareDetections: 0,
    vulnerabilitiesFound: 2,
    securityScore: 94.5,
    lastSecurityScan: DateTime.now().subtract(const Duration(hours: 6)),
    alertsByType: {
      'failed_login_attempts': 7,
      'suspicious_ip': 3,
      'unusual_activity': 2,
    },
    securityTrend: List.generate(7, (index) =>
      DataPoint(
        date: DateTime.now().subtract(Duration(days: 6 - index)),
        value: 8 + (index % 3) * 2,
      ),
    ),
  );
}

ApiAnalytics _createMockApiAnalytics() {
  return ApiAnalytics(
    totalRequests: 156789,
    successfulRequests: 153456,
    failedRequests: 3333,
    averageResponseTime: const Duration(milliseconds: 245),
    requestsPerSecond: 12.7,
    errorRate: 2.1,
    topEndpoints: [
      EndpointStats(
        endpoint: '/api/users',
        requests: 45678,
        averageResponseTime: const Duration(milliseconds: 180),
        errorRate: 1.2,
      ),
      EndpointStats(
        endpoint: '/api/auth/login',
        requests: 23456,
        averageResponseTime: const Duration(milliseconds: 320),
        errorRate: 3.1,
      ),
    ],
    statusCodeDistribution: {
      200: 153456,
      400: 1234,
      401: 567,
      404: 890,
      500: 642,
    },
    requestTrend: List.generate(48, (index) =>
      DataPoint(
        date: DateTime.now().subtract(Duration(minutes: 47 - index)),
        value: 120 + (index % 6) * 15,
      ),
    ),
  );
}

DashboardData _createEmptyDashboardData() {
  return DashboardData(
    totalUsers: 0,
    activeUsers: 0,
    newUsersToday: 0,
    totalSessions: 0,
    activeSessions: 0,
    failedLogins: 0,
    securityAlerts: 0,
    apiRequests: 0,
    errorRate: 0.0,
    averageResponseTime: 0.0,
    systemHealth: SystemHealth.healthy,
    recentActivities: [],
    quickStats: [],
  );
}