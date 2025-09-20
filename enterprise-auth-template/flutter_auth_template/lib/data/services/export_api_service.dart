import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_auth_template/core/constants/api_constants.dart';
import 'package:flutter_auth_template/core/network/api_client.dart';
import 'package:flutter_auth_template/core/errors/app_exception.dart';
import 'package:flutter_auth_template/data/models/export_models.dart';

final exportApiServiceProvider = Provider<ExportApiService>((ref) {
  return ExportApiService(ref.read(apiClientProvider));
});

class ExportApiService {
  final ApiClient _apiClient;

  ExportApiService(this._apiClient);

  /// Create export job
  Future<ExportJob> createExportJob(ExportRequest request) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '${ApiConstants.adminBasePath}/exports',
        data: request.toJson(),
      );

      if (response.data!['success'] == true) {
        return ExportJob.fromJson(response.data!['data']);
      }

      throw ServerException(
        response.data!['error']?['message'] ?? 'Failed to create export job',
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get export jobs
  Future<ExportJobList> getExportJobs({
    int page = 1,
    int limit = 20,
    ExportStatus? status,
    ExportType? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (status != null) queryParams['status'] = status.name;
      if (type != null) queryParams['type'] = type.name;
      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String();
      }

      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.adminBasePath}/exports',
        queryParameters: queryParams,
      );

      if (response.data!['success'] == true) {
        return ExportJobList.fromJson(response.data!['data']);
      }

      throw ServerException(
        response.data!['error']?['message'] ?? 'Failed to get export jobs',
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get export job by ID
  Future<ExportJob> getExportJob(String jobId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.adminBasePath}/exports/$jobId',
      );

      if (response.data!['success'] == true) {
        return ExportJob.fromJson(response.data!['data']);
      }

      throw ServerException(
        response.data!['error']?['message'] ?? 'Failed to get export job',
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Cancel export job
  Future<ExportJob> cancelExportJob(String jobId) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '${ApiConstants.adminBasePath}/exports/$jobId/cancel',
      );

      if (response.data!['success'] == true) {
        return ExportJob.fromJson(response.data!['data']);
      }

      throw ServerException(
        response.data!['error']?['message'] ?? 'Failed to cancel export job',
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Download export file
  Future<String> downloadExportFile(String jobId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.adminBasePath}/exports/$jobId/download',
      );

      if (response.data!['success'] == true) {
        return response.data!['data']['download_url'];
      }

      throw ServerException(
        response.data!['error']?['message'] ?? 'Failed to get download URL',
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Delete export job
  Future<void> deleteExportJob(String jobId) async {
    try {
      final response = await _apiClient.delete<Map<String, dynamic>>(
        '${ApiConstants.adminBasePath}/exports/$jobId',
      );

      if (response.data!['success'] != true) {
        throw ServerException(
          response.data!['error']?['message'] ?? 'Failed to delete export job',
          null,
          response.statusCode ?? 500,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get export statistics
  Future<ExportStats> getExportStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String();
      }

      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.adminBasePath}/exports/stats',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.data!['success'] == true) {
        return ExportStats.fromJson(response.data!['data']);
      }

      throw ServerException(
        response.data!['error']?['message'] ?? 'Failed to get export statistics',
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  // Backup Methods

  /// Create backup job
  Future<BackupJob> createBackupJob(BackupRequest request) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '${ApiConstants.adminBasePath}/backups',
        data: request.toJson(),
      );

      if (response.data!['success'] == true) {
        return BackupJob.fromJson(response.data!['data']);
      }

      throw ServerException(
        response.data!['error']?['message'] ?? 'Failed to create backup job',
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get backup jobs
  Future<List<BackupJob>> getBackupJobs({
    int page = 1,
    int limit = 20,
    BackupStatus? status,
    BackupType? type,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (status != null) queryParams['status'] = status.name;
      if (type != null) queryParams['type'] = type.name;

      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.adminBasePath}/backups',
        queryParameters: queryParams,
      );

      if (response.data!['success'] == true) {
        final backupList = response.data!['data'] as List;
        return backupList
            .map((backup) => BackupJob.fromJson(backup))
            .toList();
      }

      throw ServerException(
        response.data!['error']?['message'] ?? 'Failed to get backup jobs',
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get backup job by ID
  Future<BackupJob> getBackupJob(String jobId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.adminBasePath}/backups/$jobId',
      );

      if (response.data!['success'] == true) {
        return BackupJob.fromJson(response.data!['data']);
      }

      throw ServerException(
        response.data!['error']?['message'] ?? 'Failed to get backup job',
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Download backup file
  Future<String> downloadBackupFile(String jobId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.adminBasePath}/backups/$jobId/download',
      );

      if (response.data!['success'] == true) {
        return response.data!['data']['download_url'];
      }

      throw ServerException(
        response.data!['error']?['message'] ?? 'Failed to get backup download URL',
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Delete backup
  Future<void> deleteBackup(String jobId) async {
    try {
      final response = await _apiClient.delete<Map<String, dynamic>>(
        '${ApiConstants.adminBasePath}/backups/$jobId',
      );

      if (response.data!['success'] != true) {
        throw ServerException(
          response.data!['error']?['message'] ?? 'Failed to delete backup',
          null,
          response.statusCode ?? 500,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Create restore job
  Future<RestoreJob> createRestoreJob(RestoreRequest request) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '${ApiConstants.adminBasePath}/restores',
        data: request.toJson(),
      );

      if (response.data!['success'] == true) {
        return RestoreJob.fromJson(response.data!['data']);
      }

      throw ServerException(
        response.data!['error']?['message'] ?? 'Failed to create restore job',
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get restore jobs
  Future<List<RestoreJob>> getRestoreJobs({
    int page = 1,
    int limit = 20,
    RestoreStatus? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (status != null) queryParams['status'] = status.name;

      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.adminBasePath}/restores',
        queryParameters: queryParams,
      );

      if (response.data!['success'] == true) {
        final restoreList = response.data!['data'] as List;
        return restoreList
            .map((restore) => RestoreJob.fromJson(restore))
            .toList();
      }

      throw ServerException(
        response.data!['error']?['message'] ?? 'Failed to get restore jobs',
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get restore job by ID
  Future<RestoreJob> getRestoreJob(String jobId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.adminBasePath}/restores/$jobId',
      );

      if (response.data!['success'] == true) {
        return RestoreJob.fromJson(response.data!['data']);
      }

      throw ServerException(
        response.data!['error']?['message'] ?? 'Failed to get restore job',
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Cancel restore job
  Future<RestoreJob> cancelRestoreJob(String jobId) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '${ApiConstants.adminBasePath}/restores/$jobId/cancel',
      );

      if (response.data!['success'] == true) {
        return RestoreJob.fromJson(response.data!['data']);
      }

      throw ServerException(
        response.data!['error']?['message'] ?? 'Failed to cancel restore job',
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Validate backup file
  Future<Map<String, dynamic>> validateBackupFile(String jobId) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '${ApiConstants.adminBasePath}/backups/$jobId/validate',
      );

      if (response.data!['success'] == true) {
        return response.data!['data'];
      }

      throw ServerException(
        response.data!['error']?['message'] ?? 'Failed to validate backup file',
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get export templates
  Future<List<Map<String, dynamic>>> getExportTemplates() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.adminBasePath}/exports/templates',
      );

      if (response.data!['success'] == true) {
        return (response.data!['data'] as List).cast<Map<String, dynamic>>();
      }

      throw ServerException(
        response.data!['error']?['message'] ?? 'Failed to get export templates',
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  AppException _handleDioException(DioException exception) {
    if (exception.response?.data != null) {
      final data = exception.response!.data;
      final message = data['error']?['message'] ?? 'Unknown error occurred';
      return ServerException(message, null, exception.response?.statusCode ?? 500);
    }

    return NetworkException(
      exception.message ?? 'Network error occurred',
      exception.requestOptions.path,
    );
  }
}