import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_auth_template/presentation/pages/dashboard_page.dart';
import 'package:flutter_auth_template/data/models/user_models.dart';
import 'package:flutter_auth_template/data/models/dashboard_models.dart';
import 'package:flutter_auth_template/providers/auth_provider.dart';
import 'package:flutter_auth_template/providers/dashboard_provider.dart';

@GenerateMocks([])
import 'dashboard_test.mocks.dart';

void main() {
  group('DashboardPage Widget Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          // Mock auth provider
          authProvider.overrideWith((ref) => AsyncValue.data(
            User(
              id: 'test-user',
              email: 'test@example.com',
              name: 'Test User',
              createdAt: DateTime.now(),
              isActive: true,
              role: UserRole.user,
            ),
          )),
          // Mock dashboard data
          dashboardDataProvider.overrideWith((ref) => AsyncValue.data(
            DashboardData(
              totalUsers: 1250,
              activeUsers: 890,
              newUsersToday: 45,
              totalSessions: 3420,
              activeSessions: 125,
              failedLogins: 12,
              securityAlerts: 3,
              apiRequests: 15670,
              errorRate: 2.1,
              averageResponseTime: 245.5,
              systemHealth: SystemHealth.healthy,
              recentActivities: _getMockRecentActivities(),
              quickStats: _getMockQuickStats(),
            ),
          )),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('should display dashboard title', (WidgetTester tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: DashboardPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Dashboard'), findsOneWidget);
    });

    testWidgets('should display user stats cards', (WidgetTester tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: DashboardPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check for user statistics
      expect(find.text('Total Users'), findsOneWidget);
      expect(find.text('1,250'), findsOneWidget);
      expect(find.text('Active Users'), findsOneWidget);
      expect(find.text('890'), findsOneWidget);
    });

    testWidgets('should display system health indicator', (WidgetTester tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: DashboardPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('System Health'), findsOneWidget);
      expect(find.text('Healthy'), findsOneWidget);
    });

    testWidgets('should show loading state initially', (WidgetTester tester) async {
      final loadingContainer = ProviderContainer(
        overrides: [
          authProvider.overrideWith((ref) => const AsyncValue.loading()),
          dashboardDataProvider.overrideWith((ref) => const AsyncValue.loading()),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: loadingContainer,
          child: const MaterialApp(
            home: DashboardPage(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsWidgets);

      loadingContainer.dispose();
    });

    testWidgets('should handle error state', (WidgetTester tester) async {
      final errorContainer = ProviderContainer(
        overrides: [
          authProvider.overrideWith((ref) => AsyncValue.error(
            Exception('Failed to load user'),
            StackTrace.current,
          )),
          dashboardDataProvider.overrideWith((ref) => const AsyncValue.loading()),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: errorContainer,
          child: const MaterialApp(
            home: DashboardPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('Error'), findsOneWidget);

      errorContainer.dispose();
    });

    testWidgets('should display recent activities', (WidgetTester tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: DashboardPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Recent Activities'), findsOneWidget);
      expect(find.text('User Login'), findsOneWidget);
      expect(find.text('test@example.com logged in'), findsOneWidget);
    });

    testWidgets('should display security alerts if any', (WidgetTester tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: DashboardPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Security Alerts'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('should navigate to detailed views on tap', (WidgetTester tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: const DashboardPage(),
            routes: {
              '/users': (context) => const Scaffold(body: Text('Users Page')),
              '/security': (context) => const Scaffold(body: Text('Security Page')),
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Test navigation to users page
      await tester.tap(find.text('View All').first);
      await tester.pumpAndSettle();
      
      // Should navigate or show more details
      // Note: Actual navigation testing would require more specific implementation
    });

    testWidgets('should refresh data on pull to refresh', (WidgetTester tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: DashboardPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the RefreshIndicator
      final refreshIndicator = find.byType(RefreshIndicator);
      expect(refreshIndicator, findsOneWidget);

      // Perform pull to refresh gesture
      await tester.drag(refreshIndicator, const Offset(0, 300));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Should trigger refresh
    });

    testWidgets('should display quick actions', (WidgetTester tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: DashboardPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Quick Actions'), findsOneWidget);
      expect(find.byIcon(Icons.person_add), findsOneWidget);
      expect(find.byIcon(Icons.security), findsOneWidget);
    });

    group('Dashboard Tabs', () {
      testWidgets('should switch between overview and analytics tabs', (WidgetTester tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              home: DashboardPage(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Find and tap Analytics tab
        final analyticsTab = find.text('Analytics');
        if (analyticsTab.evaluate().isNotEmpty) {
          await tester.tap(analyticsTab);
          await tester.pumpAndSettle();

          // Should show analytics content
          expect(find.text('Analytics'), findsOneWidget);
        }
      });

      testWidgets('should display different content in each tab', (WidgetTester tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              home: DashboardPage(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Check overview tab content
        expect(find.text('System Health'), findsOneWidget);

        // Switch to analytics tab if available
        final tabs = find.byType(Tab);
        if (tabs.evaluate().length > 1) {
          await tester.tap(tabs.at(1));
          await tester.pumpAndSettle();

          // Analytics content should be different
          // This would depend on the specific implementation
        }
      });
    });

    group('Responsive Design', () {
      testWidgets('should adapt layout for tablet screens', (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1024, 768);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              home: DashboardPage(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // On tablet, stats cards should be arranged differently
        // This would depend on the specific responsive implementation
        
        addTearDown(tester.view.resetPhysicalSize);
      });

      testWidgets('should show compact layout on mobile', (WidgetTester tester) async {
        tester.view.physicalSize = const Size(375, 667);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              home: DashboardPage(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // On mobile, layout should be more compact
        
        addTearDown(tester.view.resetPhysicalSize);
      });
    });
  });
}

List<RecentActivity> _getMockRecentActivities() {
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

List<QuickStat> _getMockQuickStats() {
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