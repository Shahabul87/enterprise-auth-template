import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Provider for data retention manager
final dataRetentionManagerProvider = Provider<DataRetentionManager>((ref) {
  return DataRetentionManager();
});

/// Data Retention Policy Manager
///
/// Manages data lifecycle and retention policies in compliance with
/// GDPR, CCPA, and other data protection regulations.
class DataRetentionManager {
  static const String _policiesKey = 'data_retention_policies';
  static const String _scheduledDeletionsKey = 'scheduled_deletions';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  final Map<DataCategory, RetentionPolicy> _policies = {};
  final List<ScheduledDeletion> _scheduledDeletions = [];
  bool _isInitialized = false;

  /// Initialize data retention manager
  Future<void> initialize() async {
    if (_isInitialized) return;

    await _loadPolicies();
    await _loadScheduledDeletions();
    _setDefaultPolicies();
    _isInitialized = true;

    // Start periodic check for data cleanup
    _startRetentionCheck();
  }

  /// Load saved retention policies
  Future<void> _loadPolicies() async {
    try {
      final stored = await _storage.read(key: _policiesKey);
      if (stored != null) {
        final Map<String, dynamic> json = jsonDecode(stored);
        json.forEach((key, value) {
          final category = DataCategory.values.firstWhere(
            (c) => c.toString() == key,
            orElse: () => DataCategory.other,
          );
          _policies[category] = RetentionPolicy.fromJson(value);
        });
      }
    } catch (e) {
      debugPrint('Failed to load retention policies: $e');
    }
  }

  /// Load scheduled deletions
  Future<void> _loadScheduledDeletions() async {
    try {
      final stored = await _storage.read(key: _scheduledDeletionsKey);
      if (stored != null) {
        final List<dynamic> jsonList = jsonDecode(stored);
        _scheduledDeletions.clear();
        _scheduledDeletions.addAll(
          jsonList.map((json) => ScheduledDeletion.fromJson(json)).toList(),
        );
      }
    } catch (e) {
      debugPrint('Failed to load scheduled deletions: $e');
    }
  }

  /// Set default retention policies
  void _setDefaultPolicies() {
    // Default policies if not already configured
    _policies.putIfAbsent(
      DataCategory.authentication,
      () => const RetentionPolicy(
        category: DataCategory.authentication,
        retentionDays: 90,
        legalBasis: 'Security and fraud prevention',
        autoDelete: false,
        requiresReview: true,
      ),
    );

    _policies.putIfAbsent(
      DataCategory.sessionData,
      () => const RetentionPolicy(
        category: DataCategory.sessionData,
        retentionDays: 30,
        legalBasis: 'Session management',
        autoDelete: true,
        requiresReview: false,
      ),
    );

    _policies.putIfAbsent(
      DataCategory.auditLogs,
      () => const RetentionPolicy(
        category: DataCategory.auditLogs,
        retentionDays: 365,
        legalBasis: 'Legal compliance and security',
        autoDelete: false,
        requiresReview: true,
      ),
    );

    _policies.putIfAbsent(
      DataCategory.analytics,
      () => const RetentionPolicy(
        category: DataCategory.analytics,
        retentionDays: 180,
        legalBasis: 'Service improvement',
        autoDelete: true,
        requiresReview: false,
      ),
    );

    _policies.putIfAbsent(
      DataCategory.marketing,
      () => const RetentionPolicy(
        category: DataCategory.marketing,
        retentionDays: 90,
        legalBasis: 'User consent',
        autoDelete: true,
        requiresReview: false,
      ),
    );

    _policies.putIfAbsent(
      DataCategory.biometric,
      () => const RetentionPolicy(
        category: DataCategory.biometric,
        retentionDays: 30,
        legalBasis: 'Authentication security',
        autoDelete: true,
        requiresReview: true,
      ),
    );

    _policies.putIfAbsent(
      DataCategory.personalData,
      () => const RetentionPolicy(
        category: DataCategory.personalData,
        retentionDays: 0, // Keep until account deletion
        legalBasis: 'Contract fulfillment',
        autoDelete: false,
        requiresReview: true,
      ),
    );

    _policies.putIfAbsent(
      DataCategory.temporaryData,
      () => const RetentionPolicy(
        category: DataCategory.temporaryData,
        retentionDays: 7,
        legalBasis: 'Temporary processing',
        autoDelete: true,
        requiresReview: false,
      ),
    );
  }

  /// Save policies
  Future<void> _savePolicies() async {
    final json = _policies.map((k, v) => MapEntry(k.toString(), v.toJson()));
    await _storage.write(
      key: _policiesKey,
      value: jsonEncode(json),
    );
  }

  /// Save scheduled deletions
  Future<void> _saveScheduledDeletions() async {
    await _storage.write(
      key: _scheduledDeletionsKey,
      value: jsonEncode(_scheduledDeletions.map((d) => d.toJson()).toList()),
    );
  }

  /// Start periodic retention check
  void _startRetentionCheck() {
    // Check every 24 hours for data that needs deletion
    Future.delayed(const Duration(hours: 24), () {
      if (_isInitialized) {
        processScheduledDeletions();
        _startRetentionCheck(); // Reschedule
      }
    });
  }

  /// Get retention policy for a data category
  RetentionPolicy? getPolicy(DataCategory category) {
    return _policies[category];
  }

  /// Update retention policy
  Future<void> updatePolicy(RetentionPolicy policy) async {
    _policies[policy.category] = policy;
    await _savePolicies();

    // Log policy change for compliance
    debugPrint('Updated retention policy for ${policy.category}: ${policy.retentionDays} days');
  }

  /// Schedule data for deletion
  Future<void> scheduleDataDeletion({
    required String dataId,
    required DataCategory category,
    required DateTime scheduledDate,
    String? userId,
    String? reason,
  }) async {
    final deletion = ScheduledDeletion(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      dataId: dataId,
      category: category,
      scheduledDate: scheduledDate,
      createdAt: DateTime.now(),
      userId: userId,
      reason: reason ?? 'Retention policy expiry',
      status: DeletionStatus.scheduled,
    );

    _scheduledDeletions.add(deletion);
    await _saveScheduledDeletions();
  }

  /// Process scheduled deletions
  Future<void> processScheduledDeletions() async {
    final now = DateTime.now();
    final dueDeletions = _scheduledDeletions.where(
      (d) => d.scheduledDate.isBefore(now) && d.status == DeletionStatus.scheduled,
    ).toList();

    for (final deletion in dueDeletions) {
      try {
        // In production, this would call actual deletion APIs
        await _performDataDeletion(deletion);

        // Update status
        deletion.status = DeletionStatus.completed;
        deletion.completedAt = DateTime.now();
      } catch (e) {
        deletion.status = DeletionStatus.failed;
        deletion.error = e.toString();
        debugPrint('Failed to delete data: ${deletion.dataId}, Error: $e');
      }
    }

    await _saveScheduledDeletions();
  }

  /// Perform actual data deletion
  Future<void> _performDataDeletion(ScheduledDeletion deletion) async {
    // This would integrate with your backend to delete the actual data
    debugPrint('Deleting ${deletion.category} data: ${deletion.dataId}');

    // Category-specific deletion logic
    switch (deletion.category) {
      case DataCategory.sessionData:
        // Delete session data
        break;
      case DataCategory.analytics:
        // Delete analytics data
        break;
      case DataCategory.auditLogs:
        // Delete old audit logs
        break;
      case DataCategory.temporaryData:
        // Delete temporary data
        break;
      default:
        // Generic deletion
        break;
    }
  }

  /// Get data retention report for compliance
  Map<String, dynamic> generateRetentionReport() {
    return {
      'reportDate': DateTime.now().toIso8601String(),
      'policies': _policies.map((k, v) => MapEntry(k.toString(), v.toJson())),
      'scheduledDeletions': _scheduledDeletions.map((d) => d.toJson()).toList(),
      'statistics': {
        'totalPolicies': _policies.length,
        'pendingDeletions': _scheduledDeletions.where((d) => d.status == DeletionStatus.scheduled).length,
        'completedDeletions': _scheduledDeletions.where((d) => d.status == DeletionStatus.completed).length,
        'failedDeletions': _scheduledDeletions.where((d) => d.status == DeletionStatus.failed).length,
      },
    };
  }

  /// Check if data should be retained
  bool shouldRetainData(DataCategory category, DateTime dataCreatedDate) {
    final policy = _policies[category];
    if (policy == null) return true;

    if (policy.retentionDays == 0) {
      // Indefinite retention
      return true;
    }

    final retentionEndDate = dataCreatedDate.add(Duration(days: policy.retentionDays));
    return DateTime.now().isBefore(retentionEndDate);
  }

  /// Get remaining retention days
  int getRemainingRetentionDays(DataCategory category, DateTime dataCreatedDate) {
    final policy = _policies[category];
    if (policy == null || policy.retentionDays == 0) return -1; // Indefinite

    final retentionEndDate = dataCreatedDate.add(Duration(days: policy.retentionDays));
    final remaining = retentionEndDate.difference(DateTime.now()).inDays;
    return remaining > 0 ? remaining : 0;
  }

  /// Clear all retention data (for testing or reset)
  Future<void> clearAllData() async {
    _policies.clear();
    _scheduledDeletions.clear();
    await _storage.delete(key: _policiesKey);
    await _storage.delete(key: _scheduledDeletionsKey);
    _isInitialized = false;
  }
}

/// Data categories for retention policies
enum DataCategory {
  personalData,
  authentication,
  sessionData,
  auditLogs,
  analytics,
  marketing,
  biometric,
  temporaryData,
  backups,
  other,
}

/// Deletion status
enum DeletionStatus {
  scheduled,
  inProgress,
  completed,
  failed,
  cancelled,
}

/// Retention policy configuration
class RetentionPolicy {
  final DataCategory category;
  final int retentionDays; // 0 = indefinite
  final String legalBasis;
  final bool autoDelete;
  final bool requiresReview;
  final DateTime? lastReviewDate;
  final String? notes;

  const RetentionPolicy({
    required this.category,
    required this.retentionDays,
    required this.legalBasis,
    required this.autoDelete,
    required this.requiresReview,
    this.lastReviewDate,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'category': category.toString(),
    'retentionDays': retentionDays,
    'legalBasis': legalBasis,
    'autoDelete': autoDelete,
    'requiresReview': requiresReview,
    'lastReviewDate': lastReviewDate?.toIso8601String(),
    'notes': notes,
  };

  factory RetentionPolicy.fromJson(Map<String, dynamic> json) {
    return RetentionPolicy(
      category: DataCategory.values.firstWhere(
        (c) => c.toString() == json['category'],
        orElse: () => DataCategory.other,
      ),
      retentionDays: json['retentionDays'],
      legalBasis: json['legalBasis'],
      autoDelete: json['autoDelete'],
      requiresReview: json['requiresReview'],
      lastReviewDate: json['lastReviewDate'] != null
        ? DateTime.parse(json['lastReviewDate'])
        : null,
      notes: json['notes'],
    );
  }

  RetentionPolicy copyWith({
    int? retentionDays,
    String? legalBasis,
    bool? autoDelete,
    bool? requiresReview,
    DateTime? lastReviewDate,
    String? notes,
  }) {
    return RetentionPolicy(
      category: category,
      retentionDays: retentionDays ?? this.retentionDays,
      legalBasis: legalBasis ?? this.legalBasis,
      autoDelete: autoDelete ?? this.autoDelete,
      requiresReview: requiresReview ?? this.requiresReview,
      lastReviewDate: lastReviewDate ?? this.lastReviewDate,
      notes: notes ?? this.notes,
    );
  }
}

/// Scheduled deletion record
class ScheduledDeletion {
  final String id;
  final String dataId;
  final DataCategory category;
  final DateTime scheduledDate;
  final DateTime createdAt;
  final String? userId;
  final String reason;
  DeletionStatus status;
  DateTime? completedAt;
  String? error;

  ScheduledDeletion({
    required this.id,
    required this.dataId,
    required this.category,
    required this.scheduledDate,
    required this.createdAt,
    this.userId,
    required this.reason,
    required this.status,
    this.completedAt,
    this.error,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'dataId': dataId,
    'category': category.toString(),
    'scheduledDate': scheduledDate.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'userId': userId,
    'reason': reason,
    'status': status.toString(),
    'completedAt': completedAt?.toIso8601String(),
    'error': error,
  };

  factory ScheduledDeletion.fromJson(Map<String, dynamic> json) {
    return ScheduledDeletion(
      id: json['id'],
      dataId: json['dataId'],
      category: DataCategory.values.firstWhere(
        (c) => c.toString() == json['category'],
        orElse: () => DataCategory.other,
      ),
      scheduledDate: DateTime.parse(json['scheduledDate']),
      createdAt: DateTime.parse(json['createdAt']),
      userId: json['userId'],
      reason: json['reason'],
      status: DeletionStatus.values.firstWhere(
        (s) => s.toString() == json['status'],
        orElse: () => DeletionStatus.scheduled,
      ),
      completedAt: json['completedAt'] != null
        ? DateTime.parse(json['completedAt'])
        : null,
      error: json['error'],
    );
  }
}