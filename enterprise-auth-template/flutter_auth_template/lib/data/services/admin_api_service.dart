import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/api/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/admin_models.dart';
import '../../core/errors/app_exception.dart';

// Admin API Service Provider
final adminApiServiceProvider = Provider<AdminApiService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AdminApiService(apiClient);
});

/// API service for admin backend integration
class AdminApiService {
  final ApiClient _apiClient;

  AdminApiService(this._apiClient);

  /// Get admin dashboard data
  Future<AdminDashboardData> getDashboardData() async {
    try {
      final response = await _apiClient.get(ApiConstants.adminDashboardPath);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return AdminDashboardData.fromJson(data['data']);
        }
      }

      throw const ServerException('Failed to get dashboard data', null, 500);
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(
        'Error getting dashboard data: ${e.toString()}',
        null,
      );
    }
  }

  /// Get system statistics
  Future<SystemStats> getSystemStats() async {
    try {
      final response = await _apiClient.get(ApiConstants.adminStatsPath);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return SystemStats.fromJson(data['data']);
        }
      }

      throw const ServerException('Failed to get system stats', null, 500);
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(
        'Error getting system stats: ${e.toString()}',
        null,
      );
    }
  }

  /// List all users with filtering and pagination
  Future<List<UserManagementResponse>> getUsers({
    int skip = 0,
    int limit = 100,
    String? search,
    String? roleId,
    bool? isActive,
    String? organizationId,
  }) async {
    try {
      final queryParams = <String, dynamic>{'skip': skip, 'limit': limit};

      if (search != null) queryParams['search'] = search;
      if (roleId != null) queryParams['role_id'] = roleId;
      if (isActive != null) queryParams['is_active'] = isActive;
      if (organizationId != null)
        queryParams['organization_id'] = organizationId;

      final response = await _apiClient.get(
        ApiConstants.adminUsersPath,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final userList = data['data'] as List;
          return userList
              .map((user) => UserManagementResponse.fromJson(user))
              .toList();
        }
      }

      throw const ServerException('Failed to get users', null, 500);
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException('Error getting users: ${e.toString()}', null);
    }
  }

  /// Get user details
  Future<UserManagementResponse> getUserDetails(String userId) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.adminUsersPath}/$userId',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return UserManagementResponse.fromJson(data['data']);
        }
      }

      throw const ServerException('Failed to get user details', null, 500);
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(
        'Error getting user details: ${e.toString()}',
        null,
      );
    }
  }

  /// Update user
  Future<UserManagementResponse> updateUser(
    String userId,
    UserManagementRequest request,
  ) async {
    try {
      final response = await _apiClient.put(
        '${ApiConstants.adminUsersPath}/$userId',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return UserManagementResponse.fromJson(data['data']);
        }
      }

      throw const ServerException('Failed to update user', null, 500);
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException('Error updating user: ${e.toString()}', null);
    }
  }

  /// Suspend user
  Future<Map<String, dynamic>> suspendUser(
    String userId,
    String reason, {
    int? durationHours,
  }) async {
    try {
      final queryParams = <String, dynamic>{'reason': reason};
      if (durationHours != null) {
        queryParams['duration_hours'] = durationHours;
      }

      final response = await _apiClient.post(
        '${ApiConstants.adminUsersPath}/$userId/suspend',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return data['data'];
        }
      }

      throw const ServerException('Failed to suspend user', null, 500);
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException('Error suspending user: ${e.toString()}', null);
    }
  }

  /// Unsuspend user
  Future<Map<String, dynamic>> unsuspendUser(String userId) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.adminUsersPath}/$userId/unsuspend',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return data['data'];
        }
      }

      throw const ServerException('Failed to unsuspend user', null, 500);
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException('Error unsuspending user: ${e.toString()}', null);
    }
  }

  /// Delete user
  Future<String> deleteUser(String userId, {bool hardDelete = false}) async {
    try {
      final response = await _apiClient.delete(
        '${ApiConstants.adminUsersPath}/$userId',
        queryParameters: {'hard_delete': hardDelete},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return data['message'];
        }
      }

      throw const ServerException('Failed to delete user', null, 500);
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException('Error deleting user: ${e.toString()}', null);
    }
  }

  /// Perform bulk user operation
  Future<BulkOperationResult> bulkUserOperation(
    BulkUserOperation operation,
  ) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.adminUsersPath}/bulk-operation',
        data: operation.toJson(),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return BulkOperationResult.fromJson(data['data']);
        }
      }

      throw const ServerException(
        'Failed to perform bulk operation',
        null,
        500,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(
        'Error performing bulk operation: ${e.toString()}',
        null,
      );
    }
  }

  /// Get active sessions
  Future<List<SessionData>> getActiveSessions({String? userId}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (userId != null) queryParams['user_id'] = userId;

      final response = await _apiClient.get(
        ApiConstants.adminActiveSessionsPath,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final sessionList = data['data'] as List;
          return sessionList
              .map((session) => SessionData.fromJson(session))
              .toList();
        }
      }

      throw const ServerException('Failed to get active sessions', null, 500);
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(
        'Error getting active sessions: ${e.toString()}',
        null,
      );
    }
  }

  /// Terminate session
  Future<String> terminateSession(String sessionId) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.adminSessionsPath}/$sessionId/terminate',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return data['message'];
        }
      }

      throw const ServerException('Failed to terminate session', null, 500);
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(
        'Error terminating session: ${e.toString()}',
        null,
      );
    }
  }

  /// Terminate all user sessions
  Future<Map<String, dynamic>> terminateAllUserSessions(String userId) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.adminSessionsPath}/terminate-all',
        queryParameters: {'user_id': userId},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return data['data'];
        }
      }

      throw const ServerException(
        'Failed to terminate all user sessions',
        null,
        500,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(
        'Error terminating all user sessions: ${e.toString()}',
        null,
      );
    }
  }

  /// Get audit logs
  Future<List<AuditLogEntry>> getAuditLogs({
    int skip = 0,
    int limit = 100,
    String? userId,
    String? action,
    String? resourceType,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{'skip': skip, 'limit': limit};

      if (userId != null) queryParams['user_id'] = userId;
      if (action != null) queryParams['action'] = action;
      if (resourceType != null) queryParams['resource_type'] = resourceType;
      if (startDate != null)
        queryParams['start_date'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();

      final response = await _apiClient.get(
        ApiConstants.adminAuditLogsPath,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final auditList = data['data'] as List;
          return auditList
              .map((audit) => AuditLogEntry.fromJson(audit))
              .toList();
        }
      }

      throw const ServerException('Failed to get audit logs', null, 500);
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException('Error getting audit logs: ${e.toString()}', null);
    }
  }

  /// Get user activity report
  Future<UserActivityReport> getUserActivityReport({
    String? userId,
    int days = 30,
  }) async {
    try {
      final queryParams = <String, dynamic>{'days': days};
      if (userId != null) queryParams['user_id'] = userId;

      final response = await _apiClient.get(
        ApiConstants.adminActivityReportPath,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return UserActivityReport.fromJson(data['data']);
        }
      }

      throw const ServerException('Failed to get activity report', null, 500);
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(
        'Error getting activity report: ${e.toString()}',
        null,
      );
    }
  }

  /// Get security report
  Future<SecurityReport> getSecurityReport({int days = 30}) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.adminSecurityReportPath,
        queryParameters: {'days': days},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return SecurityReport.fromJson(data['data']);
        }
      }

      throw const ServerException('Failed to get security report', null, 500);
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(
        'Error getting security report: ${e.toString()}',
        null,
      );
    }
  }

  /// Check system health
  Future<SystemHealthCheck> checkSystemHealth() async {
    try {
      final response = await _apiClient.get(ApiConstants.adminSystemHealthPath);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return SystemHealthCheck.fromJson(data['data']);
        }
      }

      throw const ServerException('Failed to check system health', null, 500);
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(
        'Error checking system health: ${e.toString()}',
        null,
      );
    }
  }

  /// Get system configuration
  Future<Map<String, dynamic>> getSystemConfig() async {
    try {
      final response = await _apiClient.get(ApiConstants.adminSystemConfigPath);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return data['data'];
        }
      }

      throw const ServerException('Failed to get system config', null, 500);
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(
        'Error getting system config: ${e.toString()}',
        null,
      );
    }
  }

  /// Update system configuration
  Future<Map<String, dynamic>> updateSystemConfig(
    SystemConfigUpdate config,
  ) async {
    try {
      final response = await _apiClient.put(
        ApiConstants.adminSystemConfigPath,
        data: config.toJson(),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return data['data'];
        }
      }

      throw const ServerException('Failed to update system config', null, 500);
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(
        'Error updating system config: ${e.toString()}',
        null,
      );
    }
  }

  /// Toggle maintenance mode
  Future<Map<String, dynamic>> toggleMaintenanceMode(
    bool enable, {
    String? message,
  }) async {
    try {
      final queryParams = <String, dynamic>{'enable': enable};
      if (message != null) queryParams['message'] = message;

      final response = await _apiClient.post(
        ApiConstants.adminMaintenancePath,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return data['data'];
        }
      }

      throw const ServerException(
        'Failed to toggle maintenance mode',
        null,
        500,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(
        'Error toggling maintenance mode: ${e.toString()}',
        null,
      );
    }
  }

  /// Clear cache
  Future<String> clearCache({String? cacheType}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (cacheType != null) queryParams['cache_type'] = cacheType;

      final response = await _apiClient.post(
        ApiConstants.adminCacheClearPath,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return data['message'];
        }
      }

      throw const ServerException('Failed to clear cache', null, 500);
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException('Error clearing cache: ${e.toString()}', null);
    }
  }

  /// Export users
  Future<Map<String, dynamic>> exportUsers({String format = 'csv'}) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.adminExportUsersPath,
        queryParameters: {'format': format},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return data['data'];
        }
      }

      throw const ServerException('Failed to export users', null, 500);
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException('Error exporting users: ${e.toString()}', null);
    }
  }

  /// Export audit logs
  Future<Map<String, dynamic>> exportAuditLogs({
    String format = 'csv',
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{'format': format};
      if (startDate != null)
        queryParams['start_date'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();

      final response = await _apiClient.get(
        ApiConstants.adminExportAuditLogsPath,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return data['data'];
        }
      }

      throw const ServerException('Failed to export audit logs', null, 500);
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(
        'Error exporting audit logs: ${e.toString()}',
        null,
      );
    }
  }
}
