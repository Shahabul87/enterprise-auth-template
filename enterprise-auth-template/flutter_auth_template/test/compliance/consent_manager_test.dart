import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_auth_template/core/compliance/consent_manager.dart';

@GenerateMocks([FlutterSecureStorage])
import 'consent_manager_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ConsentManager consentManager;
  late MockFlutterSecureStorage mockStorage;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    consentManager = ConsentManager();

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

  group('ConsentManager Tests', () {
    test('should initialize successfully', () async {
      await consentManager.initialize();
      expect(consentManager.hasGivenConsent, isFalse);
    });

    test('should update consent preferences', () async {
      await consentManager.initialize();

      final consents = {
        ConsentType.essential: true,
        ConsentType.analytics: true,
        ConsentType.marketing: false,
        ConsentType.preferences: true,
        ConsentType.thirdParty: false,
        ConsentType.dataSharing: false,
        ConsentType.biometric: true,
        ConsentType.location: false,
        ConsentType.pushNotifications: true,
      };

      await consentManager.updateConsent(
        consents: consents,
        userId: 'test-user-123',
        method: ConsentMethod.explicit,
      );

      expect(consentManager.hasGivenConsent, isTrue);
      expect(consentManager.isConsentGranted(ConsentType.analytics), isTrue);
      expect(consentManager.isConsentGranted(ConsentType.marketing), isFalse);
    });

    test('should track consent history', () async {
      await consentManager.initialize();

      // First consent
      await consentManager.updateConsent(
        consents: {
          ConsentType.essential: true,
          ConsentType.analytics: true,
          ConsentType.marketing: true,
        },
        userId: 'test-user',
        method: ConsentMethod.explicit,
      );

      // Update consent
      await consentManager.updateConsent(
        consents: {
          ConsentType.essential: true,
          ConsentType.analytics: false,
          ConsentType.marketing: false,
        },
        userId: 'test-user',
        method: ConsentMethod.withdrawal,
      );

      final history = consentManager.getConsentHistory(userId: 'test-user');
      expect(history.length, greaterThanOrEqualTo(1));
      expect(history.first.method, equals(ConsentMethod.withdrawal));
    });

    test('should withdraw all consents except essential', () async {
      await consentManager.initialize();

      await consentManager.updateConsent(
        consents: {
          for (var type in ConsentType.values) type: true,
        },
        userId: 'test-user',
      );

      await consentManager.withdrawAllConsents(userId: 'test-user');

      expect(consentManager.isConsentGranted(ConsentType.essential), isTrue);
      expect(consentManager.isConsentGranted(ConsentType.analytics), isFalse);
      expect(consentManager.isConsentGranted(ConsentType.marketing), isFalse);
    });

    test('should export consent data for GDPR compliance', () async {
      await consentManager.initialize();

      await consentManager.updateConsent(
        consents: {
          ConsentType.essential: true,
          ConsentType.analytics: true,
        },
        userId: 'test-user',
      );

      final exportData = consentManager.exportConsentData();

      expect(exportData, isNotNull);
      expect(exportData.containsKey('currentPreferences'), isTrue);
      expect(exportData.containsKey('consentHistory'), isTrue);
      expect(exportData.containsKey('exportDate'), isTrue);
    });

    test('should clear all consent data', () async {
      await consentManager.initialize();

      await consentManager.updateConsent(
        consents: {
          ConsentType.essential: true,
          ConsentType.analytics: true,
        },
        userId: 'test-user',
      );

      await consentManager.clearAllConsentData();

      expect(consentManager.hasGivenConsent, isFalse);
      expect(consentManager.getConsentHistory().isEmpty, isTrue);
    });

    test('should check if re-consent is needed', () async {
      await consentManager.initialize();

      // Without any consent, re-consent should be needed
      expect(
        consentManager.needsReconsent(ConsentVersion.current),
        isTrue,
      );

      await consentManager.updateConsent(
        consents: {ConsentType.essential: true},
        userId: 'test-user',
      );

      // With current version consent, re-consent should not be needed
      expect(
        consentManager.needsReconsent(ConsentVersion.v1_0),
        isFalse,
      );
    });

    test('should get correct consent text for each type', () {
      expect(
        ConsentManager.getConsentText(ConsentType.essential),
        contains('Essential cookies'),
      );
      expect(
        ConsentManager.getConsentText(ConsentType.analytics),
        contains('Analytics cookies'),
      );
      expect(
        ConsentManager.getConsentText(ConsentType.marketing),
        contains('Marketing cookies'),
      );
    });

    test('should get correct legal basis for consent types', () {
      expect(
        ConsentManager.getLegalBasis(ConsentType.essential),
        equals(LegalBasis.legitimateInterest),
      );
      expect(
        ConsentManager.getLegalBasis(ConsentType.analytics),
        equals(LegalBasis.consent),
      );
      expect(
        ConsentManager.getLegalBasis(ConsentType.marketing),
        equals(LegalBasis.consent),
      );
    });

    test('should handle parental consent method', () async {
      await consentManager.initialize();

      await consentManager.updateConsent(
        consents: {ConsentType.essential: true},
        userId: 'minor-user',
        method: ConsentMethod.parentalConsent,
      );

      final history = consentManager.getConsentHistory(userId: 'minor-user');
      expect(history.first.method, equals(ConsentMethod.parentalConsent));
    });
  });

  group('ConsentPreferences Tests', () {
    test('should serialize and deserialize correctly', () {
      final preferences = ConsentPreferences(
        userId: 'test-user',
        consents: {
          ConsentType.essential: true,
          ConsentType.analytics: false,
        },
        timestamp: DateTime.now(),
        version: ConsentVersion.current,
        ipAddress: '192.168.1.1',
        method: ConsentMethod.explicit,
      );

      final json = preferences.toJson();
      final restored = ConsentPreferences.fromJson(json);

      expect(restored.userId, equals(preferences.userId));
      expect(restored.consents.length, equals(preferences.consents.length));
      expect(restored.version, equals(preferences.version));
      expect(restored.method, equals(preferences.method));
    });
  });

  group('ConsentRecord Tests', () {
    test('should serialize and deserialize correctly', () {
      final record = ConsentRecord(
        timestamp: DateTime.now(),
        userId: 'test-user',
        previousConsents: {ConsentType.analytics: false},
        newConsents: {ConsentType.analytics: true},
        changeReason: 'User updated preferences',
        method: ConsentMethod.explicit,
      );

      final json = record.toJson();
      final restored = ConsentRecord.fromJson(json);

      expect(restored.userId, equals(record.userId));
      expect(restored.changeReason, equals(record.changeReason));
      expect(restored.method, equals(record.method));
      expect(
        restored.newConsents[ConsentType.analytics],
        equals(true),
      );
    });
  });
}