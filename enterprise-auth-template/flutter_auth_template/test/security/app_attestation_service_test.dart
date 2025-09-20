import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_auth_template/core/security/app_attestation_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('App Attestation Service Tests', () {
    late AppAttestationService attestationService;
    late List<MethodCall> methodCallLog;

    setUp(() {
      attestationService = AppAttestationService();
      methodCallLog = [];

      // Mock the method channel
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('app_attestation'),
        (MethodCall methodCall) async {
          methodCallLog.add(methodCall);

          switch (methodCall.method) {
            case 'initSafetyNet':
              return null;
            case 'isDeviceCheckSupported':
              return true;
            case 'verifySafetyNet':
              return {
                'basicIntegrity': true,
                'ctsProfileMatch': true,
                'evaluationType': 'BASIC',
              };
            case 'generateDeviceToken':
              return 'mock_device_token_123';
            case 'verifyDeviceToken':
              return {
                'isValid': true,
                'riskScore': 0.1,
              };
            case 'isSafetyNetAvailable':
              return true;
            default:
              return null;
          }
        },
      );
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('app_attestation'), null);
    });

    test('should initialize attestation service', () async {
      await attestationService.initialize();

      // Verify initialization methods were called
      expect(methodCallLog.any((call) =>
        call.method == 'initSafetyNet' ||
        call.method == 'isDeviceCheckSupported'
      ), isTrue);
    });

    test('should verify attestation successfully', () async {
      final result = await attestationService.verifyAttestation(
        userId: 'test_user_123',
        challenge: 'test_challenge',
      );

      expect(result.isValid, isTrue);
      expect(result.platform, isNotEmpty);
      expect(result.message, contains('passed'));
    });

    test('should check if attestation is supported', () async {
      final isSupported = await attestationService.isAttestationSupported();

      expect(isSupported, isA<bool>());

      // Verify the appropriate method was called
      if (methodCallLog.isNotEmpty) {
        expect(methodCallLog.last.method,
          anyOf('isSafetyNetAvailable', 'isDeviceCheckSupported'));
      }
    });

    test('should get attestation requirements', () {
      final requirements = attestationService.getRequirements();

      expect(requirements, isNotNull);
      expect(requirements.platform, isNotEmpty);
      expect(requirements.method, isNotEmpty);
      expect(requirements.minimumOSVersion, isNotEmpty);
      expect(requirements.requiresInternet, isTrue);
    });

    test('should handle attestation failure gracefully', () async {
      // Mock a failure response
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('app_attestation'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'verifySafetyNet') {
            throw PlatformException(
              code: 'ATTESTATION_FAILED',
              message: 'Device attestation failed',
            );
          }
          return null;
        },
      );

      final result = await attestationService.verifyAttestation(
        userId: 'test_user',
        challenge: 'test',
      );

      expect(result.isValid, isFalse);
      expect(result.error, isNotNull);
      expect(result.message, contains('failed'));
    });

    test('should validate attestation result on server', () async {
      final attestationResult = AttestationResult(
        isValid: true,
        platform: 'test',
        message: 'Test attestation',
        riskLevel: 'low',
      );

      final serverResult = await attestationService.validateOnServer(
        result: attestationResult,
        userId: 'test_user',
      );

      serverResult.when(
        success: (data, message) => expect(data, isTrue),
        error: (message, code, originalError, details) => fail('Should not fail'),
        loading: () => fail('Should not be loading'),
      );
    });

    test('should handle invalid attestation on server validation', () async {
      final attestationResult = AttestationResult(
        isValid: false,
        platform: 'test',
        message: 'Invalid attestation',
        riskLevel: 'high',
      );

      final serverResult = await attestationService.validateOnServer(
        result: attestationResult,
        userId: 'test_user',
      );

      serverResult.when(
        success: (data, message) => fail('Should not succeed'),
        error: (message, code, originalError, details) => expect(message, isNotNull),
        loading: () => fail('Should not be loading'),
      );
    });

    test('should correctly serialize AttestationResult to JSON', () {
      final result = AttestationResult(
        isValid: true,
        platform: 'android',
        message: 'Success',
        riskLevel: 'low',
        basicIntegrity: true,
        ctsProfileMatch: true,
        evaluationType: 'BASIC',
      );

      final json = result.toJson();

      expect(json['isValid'], isTrue);
      expect(json['platform'], equals('android'));
      expect(json['message'], equals('Success'));
      expect(json['riskLevel'], equals('low'));
      expect(json['basicIntegrity'], isTrue);
      expect(json['ctsProfileMatch'], isTrue);
      expect(json['evaluationType'], equals('BASIC'));
    });

    test('should handle unsupported platform', () async {
      // Test will return neutral result for unsupported platforms
      final result = await attestationService.verifyAttestation(
        userId: 'test_user',
        challenge: 'test',
      );

      // Even unsupported platforms should return a result
      expect(result, isNotNull);
      expect(result.platform, isNotEmpty);
    });
  });
}