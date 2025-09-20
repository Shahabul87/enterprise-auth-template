import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_auth_template/core/security/anti_tampering_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Anti-Tampering Service Tests', () {
    late AntiTamperingService antiTamperingService;
    late List<MethodCall> methodCallLog;

    setUp(() {
      antiTamperingService = AntiTamperingService();
      methodCallLog = [];

      // Mock the method channel
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('anti_tampering'),
        (MethodCall methodCall) async {
          methodCallLog.add(methodCall);

          switch (methodCall.method) {
            case 'verifySignature':
              return true; // Valid signature
            case 'getPackageHash':
              return 'abc123def456';
            case 'isDebuggerConnected':
              return false; // No debugger
            case 'isRunningInEmulator':
              return false; // Real device
            case 'checkHooks':
              return false; // No hooks
            case 'verifyInstallerPackage':
              return 'com.android.vending'; // Play Store
            case 'getAppSignature':
              return 'ABCD1234';
            case 'detectTampering':
              return {
                'isIntact': true,
                'issues': <String>[],
              };
            default:
              return null;
          }
        },
      );
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('anti_tampering'), null);
    });

    test('should initialize anti-tampering service', () async {
      await antiTamperingService.initialize();

      // Service should be ready after initialization
      expect(methodCallLog.isNotEmpty, isTrue);
    });

    test('should verify app integrity successfully', () async {
      final result = await antiTamperingService.verifyIntegrity();

      expect(result.isIntact, isTrue);
      expect(result.issues, isEmpty);
      expect(result.checks, isNotEmpty);
      expect(result.riskLevel, isNotEmpty);
    });

    test('should detect when app signature is invalid', () async {
      // Mock invalid signature
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('anti_tampering'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'verifySignature') {
            return false; // Invalid signature
          }
          if (methodCall.method == 'detectTampering') {
            return {
              'isIntact': false,
              'issues': ['Invalid app signature'],
            };
          }
          return null;
        },
      );

      final result = await antiTamperingService.verifyIntegrity();

      expect(result.isIntact, isFalse);
      expect(result.issues, isNotEmpty);
      expect(result.issues, contains('Invalid app signature'));
    });

    test('should check if debugger is connected', () async {
      // Initialize service which internally checks for debugger
      await antiTamperingService.initialize();

      // Verify debugger check was performed
      expect(methodCallLog.any((call) => call.method == 'isDebuggerConnected'), isTrue);
    });

    test('should detect when running in emulator', () async {
      // Mock emulator detection
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('anti_tampering'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'isRunningInEmulator') {
            return true; // Is emulator
          }
          return null;
        },
      );

      final isEmulator = await antiTamperingService.isRunningInEmulator();

      expect(isEmulator, isTrue);
    });

    test('should check if app is from official store', () async {
      final isOfficial = await antiTamperingService.isFromOfficialStore();

      expect(isOfficial, isTrue);
      expect(methodCallLog.any((call) => call.method == 'verifyInstallerPackage'), isTrue);
    });

    test('should detect when app is not from official store', () async {
      // Mock sideloaded app
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('anti_tampering'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'verifyInstallerPackage') {
            return 'unknown'; // Sideloaded
          }
          return null;
        },
      );

      final isOfficial = await antiTamperingService.isFromOfficialStore();

      expect(isOfficial, isFalse);
    });

    test('should detect hooks during integrity check', () async {
      // Mock hook detection
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('anti_tampering'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'checkHooks') {
            return true; // Hooks detected
          }
          if (methodCall.method == 'detectTampering') {
            return {
              'isIntact': false,
              'issues': ['Hooks detected'],
            };
          }
          return null;
        },
      );

      final result = await antiTamperingService.verifyIntegrity();

      expect(result.isIntact, isFalse);
      expect(result.issues.any((issue) => issue.contains('Hooks')), isTrue);
    });

    test('should verify app signature during integrity check', () async {
      await antiTamperingService.verifyIntegrity();

      // Verify signature check was performed
      expect(methodCallLog.any((call) => call.method == 'getAppSignature' || call.method == 'verifySignature'), isTrue);
    });

    test('should handle errors gracefully', () async {
      // Mock channel error
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('anti_tampering'),
        (MethodCall methodCall) async {
          throw PlatformException(
            code: 'ERROR',
            message: 'Anti-tampering check failed',
          );
        },
      );

      // Should not throw, but return safe defaults
      final result = await antiTamperingService.verifyIntegrity();

      // When error occurs, should assume tampered for safety
      expect(result.isIntact, isFalse);
      expect(result.issues, isNotEmpty);
    });

    test('should detect multiple tampering issues', () async {
      // Mock multiple issues
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('anti_tampering'),
        (MethodCall methodCall) async {
          switch (methodCall.method) {
            case 'verifySignature':
              return false;
            case 'isDebuggerConnected':
              return true;
            case 'checkHooks':
              return true;
            case 'detectTampering':
              return {
                'isIntact': false,
                'issues': [
                  'Invalid signature',
                  'Debugger detected',
                  'Hooks detected',
                ],
              };
            default:
              return null;
          }
        },
      );

      final result = await antiTamperingService.verifyIntegrity();

      expect(result.isIntact, isFalse);
      expect(result.issues.length, greaterThanOrEqualTo(3));
    });

    test('should correctly serialize TamperDetectionResult to JSON', () {
      final result = TamperDetectionResult(
        isIntact: false,
        checks: {
          'signature': false,
          'debugger': true,
          'emulator': false,
          'store': true,
          'hooks': true,
        },
        issues: ['Issue 1', 'Issue 2'],
        riskLevel: 'high',
        timestamp: DateTime.parse('2024-01-01T12:00:00'),
      );

      final json = result.toJson();

      expect(json['isIntact'], isFalse);
      expect(json['issues'], equals(['Issue 1', 'Issue 2']));
      expect(json['checks'], isNotNull);
      expect(json['checks']['signature'], isFalse);
      expect(json['checks']['debugger'], isTrue);
      expect(json['riskLevel'], equals('high'));
      expect(json['timestamp'], equals('2024-01-01T12:00:00.000'));
    });

    test('should perform comprehensive integrity check', () async {
      // This tests the full integrity check flow
      await antiTamperingService.initialize();
      final result = await antiTamperingService.verifyIntegrity();

      expect(result, isNotNull);
      expect(result.timestamp, isNotNull);

      // Verify all checks were performed
      final relevantCalls = methodCallLog.where((call) =>
        call.method == 'verifySignature' ||
        call.method == 'isDebuggerConnected' ||
        call.method == 'checkHooks' ||
        call.method == 'detectTampering'
      );

      expect(relevantCalls.isNotEmpty, isTrue);
    });
  });
}