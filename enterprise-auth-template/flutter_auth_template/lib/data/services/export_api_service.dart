import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/errors/app_exception.dart';
import '../models/export_models.dart';

final exportApiServiceProvider = Provider&lt;ExportApiService&gt;((ref) {
  return ExportApiService(ref.read(apiClientProvider));
});

class ExportApiService {
  final ApiClient _apiClient;

  ExportApiService(this._apiClient);

  /// Create export job
  Future&lt;ExportJob&gt; createExportJob(ExportRequest request) async {
    try {
      final response = await _apiClient.post&lt;Map&lt;String, dynamic&gt;&gt;(
        &apos;${ApiConstants.adminBasePath}/exports&apos;,
        data: request.toJson(),
      );

      if (response.data![&apos;success&apos;] == true) {
        return ExportJob.fromJson(response.data![&apos;data&apos;]);
      }

      throw ServerException(
        response.data![&apos;error&apos;]?[&apos;message&apos;] ?? &apos;Failed to create export job&apos;,
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get export jobs
  Future&lt;ExportJobList&gt; getExportJobs({
    int page = 1,
    int limit = 20,
    ExportStatus? status,
    ExportType? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = &lt;String, dynamic&gt;{
        &apos;page&apos;: page,
        &apos;limit&apos;: limit,
      };

      if (status != null) queryParams[&apos;status&apos;] = status.name;
      if (type != null) queryParams[&apos;type&apos;] = type.name;
      if (startDate != null) {
        queryParams[&apos;start_date&apos;] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams[&apos;end_date&apos;] = endDate.toIso8601String();
      }

      final response = await _apiClient.get&lt;Map&lt;String, dynamic&gt;&gt;(
        &apos;${ApiConstants.adminBasePath}/exports&apos;,
        queryParameters: queryParams,
      );

      if (response.data![&apos;success&apos;] == true) {
        return ExportJobList.fromJson(response.data![&apos;data&apos;]);
      }

      throw ServerException(
        response.data![&apos;error&apos;]?[&apos;message&apos;] ?? &apos;Failed to get export jobs&apos;,
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get export job by ID
  Future&lt;ExportJob&gt; getExportJob(String jobId) async {
    try {
      final response = await _apiClient.get&lt;Map&lt;String, dynamic&gt;&gt;(
        &apos;${ApiConstants.adminBasePath}/exports/$jobId&apos;,
      );

      if (response.data![&apos;success&apos;] == true) {
        return ExportJob.fromJson(response.data![&apos;data&apos;]);
      }

      throw ServerException(
        response.data![&apos;error&apos;]?[&apos;message&apos;] ?? &apos;Failed to get export job&apos;,
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Cancel export job
  Future&lt;ExportJob&gt; cancelExportJob(String jobId) async {
    try {
      final response = await _apiClient.post&lt;Map&lt;String, dynamic&gt;&gt;(
        &apos;${ApiConstants.adminBasePath}/exports/$jobId/cancel&apos;,
      );

      if (response.data![&apos;success&apos;] == true) {
        return ExportJob.fromJson(response.data![&apos;data&apos;]);
      }

      throw ServerException(
        response.data![&apos;error&apos;]?[&apos;message&apos;] ?? &apos;Failed to cancel export job&apos;,
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Download export file
  Future&lt;String&gt; downloadExportFile(String jobId) async {
    try {
      final response = await _apiClient.get&lt;Map&lt;String, dynamic&gt;&gt;(
        &apos;${ApiConstants.adminBasePath}/exports/$jobId/download&apos;,
      );

      if (response.data![&apos;success&apos;] == true) {
        return response.data![&apos;data&apos;][&apos;download_url&apos;];
      }

      throw ServerException(
        response.data![&apos;error&apos;]?[&apos;message&apos;] ?? &apos;Failed to get download URL&apos;,
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Delete export job
  Future&lt;void&gt; deleteExportJob(String jobId) async {
    try {
      final response = await _apiClient.delete&lt;Map&lt;String, dynamic&gt;&gt;(
        &apos;${ApiConstants.adminBasePath}/exports/$jobId&apos;,
      );

      if (response.data![&apos;success&apos;] != true) {
        throw ServerException(
          response.data![&apos;error&apos;]?[&apos;message&apos;] ?? &apos;Failed to delete export job&apos;,
          null,
          response.statusCode ?? 500,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get export statistics
  Future&lt;ExportStats&gt; getExportStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = &lt;String, dynamic&gt;{};

      if (startDate != null) {
        queryParams[&apos;start_date&apos;] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams[&apos;end_date&apos;] = endDate.toIso8601String();
      }

      final response = await _apiClient.get&lt;Map&lt;String, dynamic&gt;&gt;(
        &apos;${ApiConstants.adminBasePath}/exports/stats&apos;,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.data![&apos;success&apos;] == true) {
        return ExportStats.fromJson(response.data![&apos;data&apos;]);
      }

      throw ServerException(
        response.data![&apos;error&apos;]?[&apos;message&apos;] ?? &apos;Failed to get export statistics&apos;,
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  // Backup Methods

  /// Create backup job
  Future&lt;BackupJob&gt; createBackupJob(BackupRequest request) async {
    try {
      final response = await _apiClient.post&lt;Map&lt;String, dynamic&gt;&gt;(
        &apos;${ApiConstants.adminBasePath}/backups&apos;,
        data: request.toJson(),
      );

      if (response.data![&apos;success&apos;] == true) {
        return BackupJob.fromJson(response.data![&apos;data&apos;]);
      }

      throw ServerException(
        response.data![&apos;error&apos;]?[&apos;message&apos;] ?? &apos;Failed to create backup job&apos;,
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get backup jobs
  Future&lt;List&lt;BackupJob&gt;&gt; getBackupJobs({
    int page = 1,
    int limit = 20,
    BackupStatus? status,
    BackupType? type,
  }) async {
    try {
      final queryParams = &lt;String, dynamic&gt;{
        &apos;page&apos;: page,
        &apos;limit&apos;: limit,
      };

      if (status != null) queryParams[&apos;status&apos;] = status.name;
      if (type != null) queryParams[&apos;type&apos;] = type.name;

      final response = await _apiClient.get&lt;Map&lt;String, dynamic&gt;&gt;(
        &apos;${ApiConstants.adminBasePath}/backups&apos;,
        queryParameters: queryParams,
      );

      if (response.data![&apos;success&apos;] == true) {
        final backupList = response.data![&apos;data&apos;] as List;
        return backupList
            .map((backup) =&gt; BackupJob.fromJson(backup))
            .toList();
      }

      throw ServerException(
        response.data![&apos;error&apos;]?[&apos;message&apos;] ?? &apos;Failed to get backup jobs&apos;,
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get backup job by ID
  Future&lt;BackupJob&gt; getBackupJob(String jobId) async {
    try {
      final response = await _apiClient.get&lt;Map&lt;String, dynamic&gt;&gt;(
        &apos;${ApiConstants.adminBasePath}/backups/$jobId&apos;,
      );

      if (response.data![&apos;success&apos;] == true) {
        return BackupJob.fromJson(response.data![&apos;data&apos;]);
      }

      throw ServerException(
        response.data![&apos;error&apos;]?[&apos;message&apos;] ?? &apos;Failed to get backup job&apos;,
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Download backup file
  Future&lt;String&gt; downloadBackupFile(String jobId) async {
    try {
      final response = await _apiClient.get&lt;Map&lt;String, dynamic&gt;&gt;(
        &apos;${ApiConstants.adminBasePath}/backups/$jobId/download&apos;,
      );

      if (response.data![&apos;success&apos;] == true) {
        return response.data![&apos;data&apos;][&apos;download_url&apos;];
      }

      throw ServerException(
        response.data![&apos;error&apos;]?[&apos;message&apos;] ?? &apos;Failed to get backup download URL&apos;,
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Delete backup
  Future&lt;void&gt; deleteBackup(String jobId) async {
    try {
      final response = await _apiClient.delete&lt;Map&lt;String, dynamic&gt;&gt;(
        &apos;${ApiConstants.adminBasePath}/backups/$jobId&apos;,
      );

      if (response.data![&apos;success&apos;] != true) {
        throw ServerException(
          response.data![&apos;error&apos;]?[&apos;message&apos;] ?? &apos;Failed to delete backup&apos;,
          null,
          response.statusCode ?? 500,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Create restore job
  Future&lt;RestoreJob&gt; createRestoreJob(RestoreRequest request) async {
    try {
      final response = await _apiClient.post&lt;Map&lt;String, dynamic&gt;&gt;(
        &apos;${ApiConstants.adminBasePath}/restores&apos;,
        data: request.toJson(),
      );

      if (response.data![&apos;success&apos;] == true) {
        return RestoreJob.fromJson(response.data![&apos;data&apos;]);
      }

      throw ServerException(
        response.data![&apos;error&apos;]?[&apos;message&apos;] ?? &apos;Failed to create restore job&apos;,
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get restore jobs
  Future&lt;List&lt;RestoreJob&gt;&gt; getRestoreJobs({
    int page = 1,
    int limit = 20,
    RestoreStatus? status,
  }) async {
    try {
      final queryParams = &lt;String, dynamic&gt;{
        &apos;page&apos;: page,
        &apos;limit&apos;: limit,
      };

      if (status != null) queryParams[&apos;status&apos;] = status.name;

      final response = await _apiClient.get&lt;Map&lt;String, dynamic&gt;&gt;(
        &apos;${ApiConstants.adminBasePath}/restores&apos;,
        queryParameters: queryParams,
      );

      if (response.data![&apos;success&apos;] == true) {
        final restoreList = response.data![&apos;data&apos;] as List;
        return restoreList
            .map((restore) =&gt; RestoreJob.fromJson(restore))
            .toList();
      }

      throw ServerException(
        response.data![&apos;error&apos;]?[&apos;message&apos;] ?? &apos;Failed to get restore jobs&apos;,
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get restore job by ID
  Future&lt;RestoreJob&gt; getRestoreJob(String jobId) async {
    try {
      final response = await _apiClient.get&lt;Map&lt;String, dynamic&gt;&gt;(
        &apos;${ApiConstants.adminBasePath}/restores/$jobId&apos;,
      );

      if (response.data![&apos;success&apos;] == true) {
        return RestoreJob.fromJson(response.data![&apos;data&apos;]);
      }

      throw ServerException(
        response.data![&apos;error&apos;]?[&apos;message&apos;] ?? &apos;Failed to get restore job&apos;,
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Cancel restore job
  Future&lt;RestoreJob&gt; cancelRestoreJob(String jobId) async {
    try {
      final response = await _apiClient.post&lt;Map&lt;String, dynamic&gt;&gt;(
        &apos;${ApiConstants.adminBasePath}/restores/$jobId/cancel&apos;,
      );

      if (response.data![&apos;success&apos;] == true) {
        return RestoreJob.fromJson(response.data![&apos;data&apos;]);
      }

      throw ServerException(
        response.data![&apos;error&apos;]?[&apos;message&apos;] ?? &apos;Failed to cancel restore job&apos;,
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Validate backup file
  Future&lt;Map&lt;String, dynamic&gt;&gt; validateBackupFile(String jobId) async {
    try {
      final response = await _apiClient.post&lt;Map&lt;String, dynamic&gt;&gt;(
        &apos;${ApiConstants.adminBasePath}/backups/$jobId/validate&apos;,
      );

      if (response.data![&apos;success&apos;] == true) {
        return response.data![&apos;data&apos;];
      }

      throw ServerException(
        response.data![&apos;error&apos;]?[&apos;message&apos;] ?? &apos;Failed to validate backup file&apos;,
        null,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get export templates
  Future&lt;List&lt;Map&lt;String, dynamic&gt;&gt;&gt; getExportTemplates() async {
    try {
      final response = await _apiClient.get&lt;Map&lt;String, dynamic&gt;&gt;(
        &apos;${ApiConstants.adminBasePath}/exports/templates&apos;,
      );

      if (response.data![&apos;success&apos;] == true) {
        return (response.data![&apos;data&apos;] as List).cast&lt;Map&lt;String, dynamic&gt;&gt;();
      }

      throw ServerException(
        response.data![&apos;error&apos;]?[&apos;message&apos;] ?? &apos;Failed to get export templates&apos;,
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
      final message = data[&apos;error&apos;]?[&apos;message&apos;] ?? &apos;Unknown error occurred&apos;;
      return ServerException(message, null, exception.response?.statusCode ?? 500);
    }

    return NetworkException(
      exception.message ?? &apos;Network error occurred&apos;,
      exception.requestOptions.path,
    );
  }
}