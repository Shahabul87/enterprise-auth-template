import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_auth_template/core/compliance/data_retention_manager.dart';

@GenerateMocks([FlutterSecureStorage])
import 'data_retention_manager_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DataRetentionManager retentionManager;
  late MockFlutterSecureStorage mockStorage;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    retentionManager = DataRetentionManager();

    // Mock storage operations
    when(mockStorage.read(key: anyNamed('key')))
        .thenAnswer((_) async => null);
    when(mockStorage.write(
      key: anyNamed('key'),
      value: anyNamed('value'),
    )).thenAnswer((_) async => {});
    when(mockStorage.delete(key: anyNamed('key')))
        .thenAnswer((_) async => {});
  });

  group('DataRetentionManager Tests', () {
    test('should initialize with default policies', () async {
      await retentionManager.initialize();

      final authPolicy = retentionManager.getPolicy(DataCategory.authentication);
      expect(authPolicy, isNotNull);
      expect(authPolicy!.retentionDays, equals(90));
      expect(authPolicy.legalBasis, equals('Security and fraud prevention'));

      final sessionPolicy = retentionManager.getPolicy(DataCategory.sessionData);
      expect(sessionPolicy, isNotNull);
      expect(sessionPolicy!.retentionDays, equals(30));
      expect(sessionPolicy.autoDelete, isTrue);
    });

    test('should update retention policy', () async {
      await retentionManager.initialize();

      final newPolicy = RetentionPolicy(
        category: DataCategory.analytics,
        retentionDays: 365,
        legalBasis: 'Extended analytics',
        autoDelete: false,
        requiresReview: true,
      );

      await retentionManager.updatePolicy(newPolicy);

      final updatedPolicy = retentionManager.getPolicy(DataCategory.analytics);
      expect(updatedPolicy, isNotNull);
      expect(updatedPolicy!.retentionDays, equals(365));
      expect(updatedPolicy.legalBasis, equals('Extended analytics'));
    });

    test('should schedule data deletion', () async {
      await retentionManager.initialize();

      final scheduledDate = DateTime.now().add(const Duration(days: 30));

      await retentionManager.scheduleDataDeletion(
        dataId: 'user-data-123',
        category: DataCategory.personalData,
        scheduledDate: scheduledDate,
        userId: 'test-user',
        reason: 'User requested deletion',
      );

      // Verify deletion was scheduled (would need to access internal state)
      expect(retentionManager.generateRetentionReport(), isNotNull);
    });

    test('should check if data should be retained', () async {
      await retentionManager.initialize();

      final dataCreatedDate = DateTime.now().subtract(const Duration(days: 10));

      // Data within retention period
      final shouldRetain = retentionManager.shouldRetainData(
        DataCategory.sessionData,
        dataCreatedDate,
      );
      expect(shouldRetain, isTrue);

      // Data beyond retention period
      final oldDataDate = DateTime.now().subtract(const Duration(days: 100));
      final shouldNotRetain = retentionManager.shouldRetainData(
        DataCategory.sessionData,
        oldDataDate,
      );
      expect(shouldNotRetain, isFalse);
    });

    test('should calculate remaining retention days', () async {
      await retentionManager.initialize();

      final dataCreatedDate = DateTime.now().subtract(const Duration(days: 10));

      final remainingDays = retentionManager.getRemainingRetentionDays(
        DataCategory.sessionData,
        dataCreatedDate,
      );

      expect(remainingDays, greaterThan(0));
      expect(remainingDays, lessThanOrEqualTo(20)); // 30 - 10 days
    });

    test('should generate retention report', () async {
      await retentionManager.initialize();

      final report = retentionManager.generateRetentionReport();

      expect(report, isNotNull);
      expect(report.containsKey('reportDate'), isTrue);
      expect(report.containsKey('policies'), isTrue);
      expect(report.containsKey('scheduledDeletions'), isTrue);
      expect(report.containsKey('statistics'), isTrue);

      final statistics = report['statistics'] as Map<String, dynamic>;
      expect(statistics.containsKey('totalPolicies'), isTrue);
      expect(statistics['totalPolicies'], greaterThan(0));
    });

    test('should handle indefinite retention', () async {
      await retentionManager.initialize();

      final policy = RetentionPolicy(
        category: DataCategory.personalData,
        retentionDays: 0, // Indefinite
        legalBasis: 'Contract fulfillment',
        autoDelete: false,
        requiresReview: true,
      );

      await retentionManager.updatePolicy(policy);

      final shouldRetain = retentionManager.shouldRetainData(
        DataCategory.personalData,
        DateTime.now().subtract(const Duration(days: 10000)),
      );

      expect(shouldRetain, isTrue);

      final remainingDays = retentionManager.getRemainingRetentionDays(
        DataCategory.personalData,
        DateTime.now(),
      );

      expect(remainingDays, equals(-1)); // Indefinite
    });

    test('should clear all retention data', () async {
      await retentionManager.initialize();

      await retentionManager.scheduleDataDeletion(
        dataId: 'test-data',
        category: DataCategory.temporaryData,
        scheduledDate: DateTime.now().add(const Duration(days: 1)),
      );

      await retentionManager.clearAllData();

      // After clearing, should need re-initialization
      final policy = retentionManager.getPolicy(DataCategory.authentication);
      expect(policy, isNull);
    });

    test('should handle different data categories', () async {
      await retentionManager.initialize();

      for (final category in DataCategory.values) {
        if (category != DataCategory.other) {
          final policy = retentionManager.getPolicy(category);
          expect(policy, isNotNull,
              reason: 'Policy should exist for $category');
        }
      }
    });

    test('should process scheduled deletions', () async {
      await retentionManager.initialize();

      // Schedule a deletion for immediate processing
      await retentionManager.scheduleDataDeletion(
        dataId: 'test-data-immediate',
        category: DataCategory.temporaryData,
        scheduledDate: DateTime.now().subtract(const Duration(hours: 1)),
        userId: 'test-user',
      );

      // Process deletions
      await retentionManager.processScheduledDeletions();

      // Verify deletion was processed
      final report = retentionManager.generateRetentionReport();
      final statistics = report['statistics'] as Map<String, dynamic>;

      // At least one deletion should be processed or failed
      final completed = statistics['completedDeletions'] as int;
      final failed = statistics['failedDeletions'] as int;
      expect(completed + failed, greaterThan(0));
    });
  });

  group('RetentionPolicy Tests', () {
    test('should serialize and deserialize correctly', () {
      final policy = RetentionPolicy(
        category: DataCategory.auditLogs,
        retentionDays: 365,
        legalBasis: 'Legal compliance',
        autoDelete: false,
        requiresReview: true,
        lastReviewDate: DateTime.now(),
        notes: 'Required for compliance audit',
      );

      final json = policy.toJson();
      final restored = RetentionPolicy.fromJson(json);

      expect(restored.category, equals(policy.category));
      expect(restored.retentionDays, equals(policy.retentionDays));
      expect(restored.legalBasis, equals(policy.legalBasis));
      expect(restored.autoDelete, equals(policy.autoDelete));
      expect(restored.requiresReview, equals(policy.requiresReview));
      expect(restored.notes, equals(policy.notes));
    });

    test('should handle copyWith correctly', () {
      const original = RetentionPolicy(
        category: DataCategory.analytics,
        retentionDays: 180,
        legalBasis: 'Service improvement',
        autoDelete: true,
        requiresReview: false,
      );

      final modified = original.copyWith(
        retentionDays: 365,
        autoDelete: false,
        notes: 'Extended for annual review',
      );

      expect(modified.category, equals(original.category));
      expect(modified.retentionDays, equals(365));
      expect(modified.autoDelete, isFalse);
      expect(modified.notes, equals('Extended for annual review'));
      expect(modified.legalBasis, equals(original.legalBasis));
    });
  });

  group('ScheduledDeletion Tests', () {
    test('should serialize and deserialize correctly', () {
      final deletion = ScheduledDeletion(
        id: 'del-123',
        dataId: 'data-456',
        category: DataCategory.sessionData,
        scheduledDate: DateTime.now().add(const Duration(days: 30)),
        createdAt: DateTime.now(),
        userId: 'user-789',
        reason: 'Retention policy expiry',
        status: DeletionStatus.scheduled,
      );

      final json = deletion.toJson();
      final restored = ScheduledDeletion.fromJson(json);

      expect(restored.id, equals(deletion.id));
      expect(restored.dataId, equals(deletion.dataId));
      expect(restored.category, equals(deletion.category));
      expect(restored.userId, equals(deletion.userId));
      expect(restored.reason, equals(deletion.reason));
      expect(restored.status, equals(deletion.status));
    });

    test('should handle different deletion statuses', () {
      for (final status in DeletionStatus.values) {
        final deletion = ScheduledDeletion(
          id: 'test-id',
          dataId: 'test-data',
          category: DataCategory.temporaryData,
          scheduledDate: DateTime.now(),
          createdAt: DateTime.now(),
          reason: 'Test',
          status: status,
        );

        expect(deletion.status, equals(status));
      }
    });
  });
}