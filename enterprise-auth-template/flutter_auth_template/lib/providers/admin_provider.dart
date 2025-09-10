import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/admin_models.dart';
import '../data/services/admin_api_service.dart';
import '../core/errors/app_exception.dart';

// Admin State
class AdminState {
  final AdminDashboardData? dashboardData;
  final SystemStats? systemStats;
  final List<UserManagementResponse> users;
  final UserManagementResponse? selectedUser;
  final List<SessionData> activeSessions;
  final List<AuditLogEntry> auditLogs;
  final UserActivityReport? activityReport;
  final SecurityReport? securityReport;
  final SystemHealthCheck? systemHealth;
  final Map<String, dynamic>? systemConfig;
  final bool isLoading;
  final String? error;
  final bool isDashboardLoading;
  final bool isUsersLoading;
  final bool isSessionsLoading;
  final bool isAuditLoading;

  const AdminState({
    this.dashboardData,
    this.systemStats,
    this.users = const [],
    this.selectedUser,
    this.activeSessions = const [],
    this.auditLogs = const [],
    this.activityReport,
    this.securityReport,
    this.systemHealth,
    this.systemConfig,
    this.isLoading = false,
    this.error,
    this.isDashboardLoading = false,
    this.isUsersLoading = false,
    this.isSessionsLoading = false,
    this.isAuditLoading = false,
  });

  AdminState copyWith({
    AdminDashboardData? dashboardData,
    SystemStats? systemStats,
    List<UserManagementResponse>? users,
    UserManagementResponse? selectedUser,
    List<SessionData>? activeSessions,
    List<AuditLogEntry>? auditLogs,
    UserActivityReport? activityReport,
    SecurityReport? securityReport,
    SystemHealthCheck? systemHealth,
    Map<String, dynamic>? systemConfig,
    bool? isLoading,
    String? error,
    bool? isDashboardLoading,
    bool? isUsersLoading,
    bool? isSessionsLoading,
    bool? isAuditLoading,
  }) {
    return AdminState(
      dashboardData: dashboardData ?? this.dashboardData,
      systemStats: systemStats ?? this.systemStats,
      users: users ?? this.users,
      selectedUser: selectedUser ?? this.selectedUser,
      activeSessions: activeSessions ?? this.activeSessions,
      auditLogs: auditLogs ?? this.auditLogs,
      activityReport: activityReport ?? this.activityReport,
      securityReport: securityReport ?? this.securityReport,
      systemHealth: systemHealth ?? this.systemHealth,
      systemConfig: systemConfig ?? this.systemConfig,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isDashboardLoading: isDashboardLoading ?? this.isDashboardLoading,
      isUsersLoading: isUsersLoading ?? this.isUsersLoading,
      isSessionsLoading: isSessionsLoading ?? this.isSessionsLoading,
      isAuditLoading: isAuditLoading ?? this.isAuditLoading,
    );
  }
}

// Admin Provider
class AdminNotifier extends StateNotifier<AdminState> {
  final AdminApiService _apiService;

  AdminNotifier(this._apiService) : super(const AdminState());

  /// Load dashboard data
  Future<void> loadDashboardData() async {
    state = state.copyWith(isDashboardLoading: true, error: null);

    try {
      final dashboardData = await _apiService.getDashboardData();
      state = state.copyWith(
        dashboardData: dashboardData,
        isDashboardLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isDashboardLoading: false,
        error: e is AppException ? e.message : e.toString(),
      );
    }
  }

  /// Load system statistics
  Future<void> loadSystemStats() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final stats = await _apiService.getSystemStats();
      state = state.copyWith(systemStats: stats, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e is AppException ? e.message : e.toString(),
      );
    }
  }

  /// Load users with filtering
  Future<void> loadUsers({
    int skip = 0,
    int limit = 100,
    String? search,
    String? roleId,
    bool? isActive,
    String? organizationId,
    bool append = false,
  }) async {
    if (!append) {
      state = state.copyWith(isUsersLoading: true, error: null);
    }

    try {
      final users = await _apiService.getUsers(
        skip: skip,
        limit: limit,
        search: search,
        roleId: roleId,
        isActive: isActive,
        organizationId: organizationId,
      );

      state = state.copyWith(
        users: append ? [...state.users, ...users] : users,
        isUsersLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isUsersLoading: false,
        error: e is AppException ? e.message : e.toString(),
      );
    }
  }

  /// Load user details
  Future<void> loadUserDetails(String userId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = await _apiService.getUserDetails(userId);
      state = state.copyWith(selectedUser: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e is AppException ? e.message : e.toString(),
      );
    }
  }

  /// Update user
  Future<bool> updateUser(String userId, UserManagementRequest request) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedUser = await _apiService.updateUser(userId, request);

      // Update user in the list if present
      final userIndex = state.users.indexWhere((user) => user.id == userId);
      if (userIndex != -1) {
        final updatedUsers = [...state.users];
        updatedUsers[userIndex] = updatedUser;
        state = state.copyWith(users: updatedUsers);
      }

      // Update selected user if it's the same one
      if (state.selectedUser?.id == userId) {
        state = state.copyWith(selectedUser: updatedUser);
      }

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e is AppException ? e.message : e.toString(),
      );
      return false;
    }
  }

  /// Suspend user
  Future<bool> suspendUser(
    String userId,
    String reason, {
    int? durationHours,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _apiService.suspendUser(
        userId,
        reason,
        durationHours: durationHours,
      );

      // Refresh user data
      await loadUserDetails(userId);
      await loadUsers();

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e is AppException ? e.message : e.toString(),
      );
      return false;
    }
  }

  /// Unsuspend user
  Future<bool> unsuspendUser(String userId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _apiService.unsuspendUser(userId);

      // Refresh user data
      await loadUserDetails(userId);
      await loadUsers();

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e is AppException ? e.message : e.toString(),
      );
      return false;
    }
  }

  /// Delete user
  Future<bool> deleteUser(String userId, {bool hardDelete = false}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _apiService.deleteUser(userId, hardDelete: hardDelete);

      // Remove user from list
      final updatedUsers = state.users
          .where((user) => user.id != userId)
          .toList();
      state = state.copyWith(
        users: updatedUsers,
        selectedUser: state.selectedUser?.id == userId
            ? null
            : state.selectedUser,
        isLoading: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e is AppException ? e.message : e.toString(),
      );
      return false;
    }
  }

  /// Perform bulk user operation
  Future<BulkOperationResult?> bulkUserOperation(
    BulkUserOperation operation,
  ) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _apiService.bulkUserOperation(operation);

      // Refresh user list
      await loadUsers();

      state = state.copyWith(isLoading: false);
      return result;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e is AppException ? e.message : e.toString(),
      );
      return null;
    }
  }

  /// Load active sessions
  Future<void> loadActiveSessions({String? userId}) async {
    state = state.copyWith(isSessionsLoading: true, error: null);

    try {
      final sessions = await _apiService.getActiveSessions(userId: userId);
      state = state.copyWith(
        activeSessions: sessions,
        isSessionsLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isSessionsLoading: false,
        error: e is AppException ? e.message : e.toString(),
      );
    }
  }

  /// Terminate session
  Future<bool> terminateSession(String sessionId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _apiService.terminateSession(sessionId);

      // Remove session from list
      final updatedSessions = state.activeSessions
          .where((session) => session.id != sessionId)
          .toList();

      state = state.copyWith(activeSessions: updatedSessions, isLoading: false);

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e is AppException ? e.message : e.toString(),
      );
      return false;
    }
  }

  /// Terminate all user sessions
  Future<bool> terminateAllUserSessions(String userId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _apiService.terminateAllUserSessions(userId);

      // Remove all sessions for this user
      final updatedSessions = state.activeSessions
          .where((session) => session.userId != userId)
          .toList();

      state = state.copyWith(activeSessions: updatedSessions, isLoading: false);

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e is AppException ? e.message : e.toString(),
      );
      return false;
    }
  }

  /// Load audit logs
  Future<void> loadAuditLogs({
    int skip = 0,
    int limit = 100,
    String? userId,
    String? action,
    String? resourceType,
    DateTime? startDate,
    DateTime? endDate,
    bool append = false,
  }) async {
    if (!append) {
      state = state.copyWith(isAuditLoading: true, error: null);
    }

    try {
      final logs = await _apiService.getAuditLogs(
        skip: skip,
        limit: limit,
        userId: userId,
        action: action,
        resourceType: resourceType,
        startDate: startDate,
        endDate: endDate,
      );

      state = state.copyWith(
        auditLogs: append ? [...state.auditLogs, ...logs] : logs,
        isAuditLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isAuditLoading: false,
        error: e is AppException ? e.message : e.toString(),
      );
    }
  }

  /// Load activity report
  Future<void> loadActivityReport({String? userId, int days = 30}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final report = await _apiService.getUserActivityReport(
        userId: userId,
        days: days,
      );
      state = state.copyWith(activityReport: report, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e is AppException ? e.message : e.toString(),
      );
    }
  }

  /// Load security report
  Future<void> loadSecurityReport({int days = 30}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final report = await _apiService.getSecurityReport(days: days);
      state = state.copyWith(securityReport: report, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e is AppException ? e.message : e.toString(),
      );
    }
  }

  /// Check system health
  Future<void> checkSystemHealth() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final health = await _apiService.checkSystemHealth();
      state = state.copyWith(systemHealth: health, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e is AppException ? e.message : e.toString(),
      );
    }
  }

  /// Load system configuration
  Future<void> loadSystemConfig() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final config = await _apiService.getSystemConfig();
      state = state.copyWith(systemConfig: config, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e is AppException ? e.message : e.toString(),
      );
    }
  }

  /// Update system configuration
  Future<bool> updateSystemConfig(SystemConfigUpdate configUpdate) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedConfig = await _apiService.updateSystemConfig(configUpdate);
      state = state.copyWith(systemConfig: updatedConfig, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e is AppException ? e.message : e.toString(),
      );
      return false;
    }
  }

  /// Toggle maintenance mode
  Future<bool> toggleMaintenanceMode(bool enable, {String? message}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _apiService.toggleMaintenanceMode(enable, message: message);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e is AppException ? e.message : e.toString(),
      );
      return false;
    }
  }

  /// Clear cache
  Future<bool> clearCache({String? cacheType}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _apiService.clearCache(cacheType: cacheType);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e is AppException ? e.message : e.toString(),
      );
      return false;
    }
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Clear selected user
  void clearSelectedUser() {
    state = state.copyWith(selectedUser: null);
  }

  /// Refresh all data
  Future<void> refreshAll() async {
    await Future.wait([
      loadDashboardData(),
      loadSystemStats(),
      checkSystemHealth(),
    ]);
  }
}

// Provider instances
final adminProvider = StateNotifierProvider<AdminNotifier, AdminState>((ref) {
  final apiService = ref.watch(adminApiServiceProvider);
  return AdminNotifier(apiService);
});

// Computed providers
final isDashboardLoadingProvider = Provider<bool>((ref) {
  return ref.watch(adminProvider.select((state) => state.isDashboardLoading));
});

final isUsersLoadingProvider = Provider<bool>((ref) {
  return ref.watch(adminProvider.select((state) => state.isUsersLoading));
});

final isSessionsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(adminProvider.select((state) => state.isSessionsLoading));
});

final isAuditLoadingProvider = Provider<bool>((ref) {
  return ref.watch(adminProvider.select((state) => state.isAuditLoading));
});

final adminUsersProvider = Provider<List<UserManagementResponse>>((ref) {
  return ref.watch(adminProvider.select((state) => state.users));
});

final adminActiveSessionsProvider = Provider<List<SessionData>>((ref) {
  return ref.watch(adminProvider.select((state) => state.activeSessions));
});

final adminAuditLogsProvider = Provider<List<AuditLogEntry>>((ref) {
  return ref.watch(adminProvider.select((state) => state.auditLogs));
});

final adminErrorProvider = Provider<String?>((ref) {
  return ref.watch(adminProvider.select((state) => state.error));
});
