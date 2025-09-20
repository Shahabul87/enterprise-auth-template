import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_auth_template/core/compliance/consent_manager.dart';
import 'package:flutter_auth_template/core/compliance/data_retention_manager.dart';

// Provider for data export manager
final dataExportManagerProvider = Provider<DataExportManager>((ref) {
  final consentManager = ref.watch(consentManagerProvider);
  final retentionManager = ref.watch(dataRetentionManagerProvider);

  return DataExportManager(
    consentManager: consentManager,
    retentionManager: retentionManager,
  );
});

/// Data Export Manager for GDPR Right to be Forgotten
///
/// Handles data export and deletion requests in compliance with GDPR Article 17 (Right to erasure)
/// and Article 20 (Right to data portability).
class DataExportManager {
  final ConsentManager consentManager;
  final DataRetentionManager retentionManager;

  DataExportManager({
    required this.consentManager,
    required this.retentionManager,
  });

  /// Export all user data for GDPR data portability
  Future<DataExportResult> exportUserData({
    required String userId,
    required DataExportFormat format,
    bool includeActivityLogs = true,
    bool includePreferences = true,
    bool includeAnalytics = false,
  }) async {
    try {
      final exportData = <String, dynamic>{};

      // 1. Personal Information
      exportData['personalInformation'] = await _getPersonalInformation(userId);

      // 2. Account Settings
      exportData['accountSettings'] = await _getAccountSettings(userId);

      // 3. Consent History
      exportData['consentHistory'] = consentManager.exportConsentData();

      // 4. Activity Logs (if requested)
      if (includeActivityLogs) {
        exportData['activityLogs'] = await _getActivityLogs(userId);
      }

      // 5. Preferences (if requested)
      if (includePreferences) {
        exportData['preferences'] = await _getUserPreferences(userId);
      }

      // 6. Analytics Data (if requested and consented)
      if (includeAnalytics && consentManager.isConsentGranted(ConsentType.analytics)) {
        exportData['analyticsData'] = await _getAnalyticsData(userId);
      }

      // 7. Data Retention Information
      exportData['dataRetentionInfo'] = retentionManager.generateRetentionReport();

      // Add metadata
      exportData['exportMetadata'] = {
        'exportDate': DateTime.now().toIso8601String(),
        'userId': userId,
        'format': format.toString(),
        'gdprCompliant': true,
        'dataCategories': exportData.keys.toList(),
      };

      // Format the data based on requested format
      final formattedData = await _formatExportData(exportData, format);

      // Save to file
      final file = await _saveExportToFile(formattedData, userId, format);

      return DataExportResult(
        success: true,
        filePath: file.path,
        format: format,
        exportDate: DateTime.now(),
        dataCategoriesIncluded: exportData.keys.toList(),
      );
    } catch (e) {
      debugPrint('Failed to export user data: $e');
      return DataExportResult(
        success: false,
        error: e.toString(),
        exportDate: DateTime.now(),
      );
    }
  }

  /// Delete all user data (Right to be Forgotten)
  Future<DataDeletionResult> deleteAllUserData({
    required String userId,
    required String confirmationPassword,
    bool exportBeforeDelete = true,
  }) async {
    try {
      DataExportResult? exportResult;

      // 1. Export data before deletion (if requested)
      if (exportBeforeDelete) {
        exportResult = await exportUserData(
          userId: userId,
          format: DataExportFormat.json,
          includeActivityLogs: true,
          includePreferences: true,
          includeAnalytics: true,
        );

        if (!exportResult.success) {
          return DataDeletionResult(
            success: false,
            error: 'Failed to export data before deletion',
            timestamp: DateTime.now(),
          );
        }
      }

      // 2. Verify user authorization (would validate password with backend)
      final isAuthorized = await _verifyUserAuthorization(userId, confirmationPassword);
      if (!isAuthorized) {
        return DataDeletionResult(
          success: false,
          error: 'Unauthorized: Invalid credentials',
          timestamp: DateTime.now(),
        );
      }

      // 3. Delete data categories
      final deletionTasks = <String, bool>{};

      // Delete personal information
      deletionTasks['personalInfo'] = await _deletePersonalInformation(userId);

      // Delete activity logs
      deletionTasks['activityLogs'] = await _deleteActivityLogs(userId);

      // Delete preferences
      deletionTasks['preferences'] = await _deleteUserPreferences(userId);

      // Delete analytics data
      deletionTasks['analytics'] = await _deleteAnalyticsData(userId);

      // Delete consent records
      await consentManager.clearAllConsentData();
      deletionTasks['consent'] = true;

      // Delete cached data
      deletionTasks['cache'] = await _deleteCachedData(userId);

      // Schedule deletion of retained data per policies
      await _scheduleRetainedDataDeletion(userId);

      // 4. Log the deletion for compliance
      await _logDataDeletion(userId, deletionTasks, exportResult?.filePath);

      return DataDeletionResult(
        success: true,
        deletedCategories: deletionTasks,
        exportFilePath: exportResult?.filePath,
        timestamp: DateTime.now(),
        retainedDataInfo: _getRetainedDataInfo(),
      );
    } catch (e) {
      debugPrint('Failed to delete user data: $e');
      return DataDeletionResult(
        success: false,
        error: e.toString(),
        timestamp: DateTime.now(),
      );
    }
  }

  /// Get personal information for export
  Future<Map<String, dynamic>> _getPersonalInformation(String userId) async {
    // This would fetch from your backend/local storage
    return {
      'userId': userId,
      'email': 'user@example.com', // Fetch actual data
      'name': 'User Name',
      'phone': '+1234567890',
      'createdAt': '2024-01-01T00:00:00Z',
      // Add other personal fields
    };
  }

  /// Get account settings for export
  Future<Map<String, dynamic>> _getAccountSettings(String userId) async {
    return {
      'twoFactorEnabled': false,
      'biometricEnabled': true,
      'notificationsEnabled': true,
      'language': 'en',
      'theme': 'system',
      // Add other settings
    };
  }

  /// Get activity logs for export
  Future<List<Map<String, dynamic>>> _getActivityLogs(String userId) async {
    // This would fetch from your backend
    return [
      {
        'timestamp': '2024-01-01T10:00:00Z',
        'action': 'login',
        'ip': '192.168.1.1',
        'device': 'iPhone',
      },
      // Add more logs
    ];
  }

  /// Get user preferences for export
  Future<Map<String, dynamic>> _getUserPreferences(String userId) async {
    return {
      'notifications': {
        'email': true,
        'push': true,
        'sms': false,
      },
      'privacy': {
        'profileVisibility': 'private',
        'showOnlineStatus': false,
      },
      // Add more preferences
    };
  }

  /// Get analytics data for export
  Future<Map<String, dynamic>> _getAnalyticsData(String userId) async {
    return {
      'lastActive': '2024-01-20T15:30:00Z',
      'totalSessions': 42,
      'averageSessionDuration': '5m 30s',
      // Add more analytics
    };
  }

  /// Format export data based on requested format
  Future<String> _formatExportData(
    Map<String, dynamic> data,
    DataExportFormat format,
  ) async {
    switch (format) {
      case DataExportFormat.json:
        return const JsonEncoder.withIndent('  ').convert(data);

      case DataExportFormat.csv:
        return _convertToCSV(data);

      case DataExportFormat.html:
        return _convertToHTML(data);

      case DataExportFormat.pdf:
        // Would use a PDF generation library
        return _convertToHTML(data); // Fallback to HTML for now
    }
  }

  /// Convert data to CSV format
  String _convertToCSV(Map<String, dynamic> data) {
    final buffer = StringBuffer();
    buffer.writeln('Category,Field,Value');

    void addRows(String category, dynamic value, [String prefix = '']) {
      if (value is Map) {
        value.forEach((k, v) {
          addRows(category, v, prefix.isEmpty ? k : '$prefix.$k');
        });
      } else if (value is List) {
        for (var i = 0; i < value.length; i++) {
          addRows(category, value[i], '$prefix[$i]');
        }
      } else {
        buffer.writeln('$category,"$prefix","$value"');
      }
    }

    data.forEach((category, value) {
      if (category != 'exportMetadata') {
        addRows(category, value);
      }
    });

    return buffer.toString();
  }

  /// Convert data to HTML format
  String _convertToHTML(Map<String, dynamic> data) {
    final buffer = StringBuffer();
    buffer.writeln('''
<!DOCTYPE html>
<html>
<head>
  <title>Data Export</title>
  <style>
    body { font-family: Arial, sans-serif; margin: 20px; }
    h1 { color: #333; }
    h2 { color: #666; border-bottom: 1px solid #ddd; padding-bottom: 5px; }
    pre { background: #f5f5f5; padding: 10px; border-radius: 5px; }
    .metadata { background: #e8f4ff; padding: 10px; border-radius: 5px; margin-bottom: 20px; }
  </style>
</head>
<body>
  <h1>GDPR Data Export</h1>
''');

    // Add metadata
    if (data['exportMetadata'] != null) {
      buffer.writeln('<div class="metadata">');
      buffer.writeln('<h2>Export Information</h2>');
      buffer.writeln('<pre>${const JsonEncoder.withIndent('  ').convert(data['exportMetadata'])}</pre>');
      buffer.writeln('</div>');
    }

    // Add each data category
    data.forEach((category, value) {
      if (category != 'exportMetadata') {
        buffer.writeln('<h2>${_formatCategoryName(category)}</h2>');
        buffer.writeln('<pre>${const JsonEncoder.withIndent('  ').convert(value)}</pre>');
      }
    });

    buffer.writeln('</body></html>');
    return buffer.toString();
  }

  /// Format category name for display
  String _formatCategoryName(String category) {
    return category
        .replaceAll(RegExp(r'([A-Z])'), ' \$1')
        .trim()
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  /// Save export to file
  Future<File> _saveExportToFile(
    String data,
    String userId,
    DataExportFormat format,
  ) async {
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = format.toString().split('.').last;
    final fileName = 'gdpr_export_${userId}_$timestamp.$extension';
    final file = File('${directory.path}/$fileName');

    await file.writeAsString(data);
    return file;
  }

  /// Verify user authorization for deletion
  Future<bool> _verifyUserAuthorization(String userId, String password) async {
    // This would verify with your backend
    // For now, return true for demo
    return true;
  }

  /// Delete personal information
  Future<bool> _deletePersonalInformation(String userId) async {
    // This would call your backend API to delete personal info
    debugPrint('Deleting personal information for user: $userId');
    return true;
  }

  /// Delete activity logs
  Future<bool> _deleteActivityLogs(String userId) async {
    debugPrint('Deleting activity logs for user: $userId');
    return true;
  }

  /// Delete user preferences
  Future<bool> _deleteUserPreferences(String userId) async {
    debugPrint('Deleting user preferences for user: $userId');
    return true;
  }

  /// Delete analytics data
  Future<bool> _deleteAnalyticsData(String userId) async {
    debugPrint('Deleting analytics data for user: $userId');
    return true;
  }

  /// Delete cached data
  Future<bool> _deleteCachedData(String userId) async {
    debugPrint('Deleting cached data for user: $userId');
    return true;
  }

  /// Schedule deletion of retained data
  Future<void> _scheduleRetainedDataDeletion(String userId) async {
    // Schedule deletion based on retention policies
    for (final category in DataCategory.values) {
      final policy = retentionManager.getPolicy(category);
      if (policy != null && policy.retentionDays > 0) {
        await retentionManager.scheduleDataDeletion(
          dataId: 'user_$userId',
          category: category,
          scheduledDate: DateTime.now().add(Duration(days: policy.retentionDays)),
          userId: userId,
          reason: 'User requested account deletion - GDPR Article 17',
        );
      }
    }
  }

  /// Log data deletion for compliance
  Future<void> _logDataDeletion(
    String userId,
    Map<String, bool> deletionTasks,
    String? exportPath,
  ) async {
    final log = {
      'timestamp': DateTime.now().toIso8601String(),
      'userId': userId,
      'requestType': 'GDPR Article 17 - Right to be Forgotten',
      'deletionTasks': deletionTasks,
      'exportCreated': exportPath != null,
      'exportPath': exportPath,
      'retentionNote': 'Some data may be retained for legal compliance',
    };

    debugPrint('Data deletion log: ${jsonEncode(log)}');
    // In production, this would be sent to audit log
  }

  /// Get information about retained data
  Map<String, dynamic> _getRetainedDataInfo() {
    return {
      'legalRetention': {
        'auditLogs': '365 days for security compliance',
        'financialRecords': '7 years for tax compliance',
        'legalHolds': 'Varies based on legal requirements',
      },
      'technicalRetention': {
        'backups': '30 days for disaster recovery',
        'caches': 'Up to 7 days for performance',
      },
    };
  }

  /// Share exported data
  Future<void> shareExportedData(String filePath) async {
    await Share.shareXFiles([XFile(filePath)], text: 'Your GDPR data export');
  }
}

/// Data export formats
enum DataExportFormat {
  json,
  csv,
  html,
  pdf,
}

/// Data export result
class DataExportResult {
  final bool success;
  final String? filePath;
  final DataExportFormat? format;
  final DateTime exportDate;
  final List<String>? dataCategoriesIncluded;
  final String? error;

  const DataExportResult({
    required this.success,
    this.filePath,
    this.format,
    required this.exportDate,
    this.dataCategoriesIncluded,
    this.error,
  });
}

/// Data deletion result
class DataDeletionResult {
  final bool success;
  final Map<String, bool>? deletedCategories;
  final String? exportFilePath;
  final DateTime timestamp;
  final Map<String, dynamic>? retainedDataInfo;
  final String? error;

  const DataDeletionResult({
    required this.success,
    this.deletedCategories,
    this.exportFilePath,
    required this.timestamp,
    this.retainedDataInfo,
    this.error,
  });
}