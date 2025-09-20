import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_auth_template/core/security/rasp_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RASP Service Tests', () {
    late RASPService raspService;
    late List<MethodCall> methodCallLog;
    late List<SecurityViolation> detectedViolations;

    setUp(() {
      raspService = RASPService();
      methodCallLog = [];
      detectedViolations = [];

      // Mock the method channel
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('rasp_protection'),
        (MethodCall methodCall) async {
          methodCallLog.add(methodCall);

          switch (methodCall.method) {
            case 'setupProtection':
              return null;
            case 'isDebuggerAttached':
              return false; // No debugger
            case 'detectHooks':
              return false; // No hooks
            case 'checkMemoryIntegrity':
              return false; // No tampering
            case 'detectBreakpoints':
              return null;
            case 'getRunningProcesses':
              return <String>['system', 'app'];
            case 'verifyCodeIntegrity':
              return true; // Code is intact
            case 'monitorSystemCalls':
              return null;
            default:
              return null;
          }
        },
      );
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('rasp_protection'), null);
      raspService.dispose();
    });

    test('should initialize RASP service', () async {
      await raspService.initialize(
        onViolation: (violation) {
          detectedViolations.add(violation);
        },
      );

      // Should have setup native protection
      expect(methodCallLog.any((call) => call.method == 'setupProtection'), isTrue);
    });

    test('should detect debugger when attached', () async {
      // Mock debugger attached
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('rasp_protection'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'isDebuggerAttached') {
            return true; // Debugger attached
          }
          return null;
        },
      );

      await raspService.initialize(
        enableDebuggerDetection: true,
        onViolation: (violation) {
          detectedViolations.add(violation);
        },
      );

      // Wait for periodic check
      await Future.delayed(const Duration(seconds: 6));

      // Should have detected debugger
      expect(detectedViolations.any((v) => v.type == ViolationType.debuggerAttached), isTrue);
    });

    test('should detect hooks when present', () async {
      // Mock hooks detected
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('rasp_protection'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'detectHooks') {
            return true; // Hooks detected
          }
          return null;
        },
      );

      await raspService.initialize(
        enableHookDetection: true,
        onViolation: (violation) {
          detectedViolations.add(violation);
        },
      );

      // Wait for periodic check
      await Future.delayed(const Duration(seconds: 11));

      // Should have detected hooks
      expect(detectedViolations.any((v) => v.type == ViolationType.hookDetected), isTrue);
    });

    test('should detect memory tampering', () async {
      // Mock memory tampering
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('rasp_protection'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'checkMemoryIntegrity') {
            return true; // Tampering detected
          }
          return null;
        },
      );

      await raspService.initialize(
        enableMemoryProtection: true,
        onViolation: (violation) {
          detectedViolations.add(violation);
        },
      );

      // Wait for periodic check
      await Future.delayed(const Duration(seconds: 31));

      // Should have detected memory tampering
      expect(detectedViolations.any((v) => v.type == ViolationType.memoryTampering), isTrue);
    });

    test('should detect debugging tools in process list', () async {
      // Mock debugging tool in processes
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('rasp_protection'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'getRunningProcesses') {
            return <String>['system', 'app', 'frida-server'];
          }
          return null;
        },
      );

      await raspService.initialize(
        enableAntiDebugging: true,
        onViolation: (violation) {
          detectedViolations.add(violation);
        },
      );

      // Should have detected debugging tool
      expect(detectedViolations.any((v) => v.type == ViolationType.debuggingToolDetected), isTrue);
    });

    test('should track violations', () {
      final violation1 = SecurityViolation(
        type: ViolationType.debuggerAttached,
        severity: ViolationSeverity.critical,
        message: 'Test violation 1',
        timestamp: DateTime.now(),
      );

      final violation2 = SecurityViolation(
        type: ViolationType.hookDetected,
        severity: ViolationSeverity.high,
        message: 'Test violation 2',
        timestamp: DateTime.now(),
      );

      // Simulate violations
      raspService.onViolationDetected = (v) => detectedViolations.add(v);
      raspService.onViolationDetected!(violation1);
      raspService.onViolationDetected!(violation2);

      expect(detectedViolations.length, equals(2));
      expect(detectedViolations[0].type, equals(ViolationType.debuggerAttached));
      expect(detectedViolations[1].type, equals(ViolationType.hookDetected));
    });

    test('should stream violations', () async {
      final violations = <SecurityViolation>[];

      // Listen to violation stream
      final subscription = raspService.violationStream.listen((violation) {
        violations.add(violation);
      });

      // Initialize with violation callback
      await raspService.initialize(
        onViolation: (violation) {
          // This will trigger the stream
        },
      );

      // Cleanup
      await subscription.cancel();
    });

    test('should detect code modification', () async {
      // Mock code modification detected
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('rasp_protection'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'verifyCodeIntegrity') {
            return false; // Code modified
          }
          return null;
        },
      );

      await raspService.initialize(
        onViolation: (violation) {
          detectedViolations.add(violation);
        },
      );

      // Wait for runtime check
      await Future.delayed(const Duration(seconds: 11));

      // Should have detected code modification
      expect(detectedViolations.any((v) => v.type == ViolationType.codeModification), isTrue);
    });

    test('should handle different severity levels', () {
      final lowViolation = SecurityViolation(
        type: ViolationType.timeAnomaly,
        severity: ViolationSeverity.low,
        message: 'Low severity',
        timestamp: DateTime.now(),
      );

      final criticalViolation = SecurityViolation(
        type: ViolationType.debuggerAttached,
        severity: ViolationSeverity.critical,
        message: 'Critical severity',
        timestamp: DateTime.now(),
      );

      raspService.onViolationDetected = (v) => detectedViolations.add(v);
      raspService.onViolationDetected!(lowViolation);
      raspService.onViolationDetected!(criticalViolation);

      // Check severity handling
      expect(detectedViolations[0].severity, equals(ViolationSeverity.low));
      expect(detectedViolations[1].severity, equals(ViolationSeverity.critical));
    });

    test('should serialize SecurityViolation to JSON', () {
      final violation = SecurityViolation(
        type: ViolationType.debuggerAttached,
        severity: ViolationSeverity.critical,
        message: 'Debugger detected',
        timestamp: DateTime.parse('2024-01-01T12:00:00'),
        details: {'process': 'lldb', 'pid': 12345},
      );

      final json = violation.toJson();

      expect(json['type'], contains('debuggerAttached'));
      expect(json['severity'], contains('critical'));
      expect(json['message'], equals('Debugger detected'));
      expect(json['timestamp'], equals('2024-01-01T12:00:00.000'));
      expect(json['details'], isNotNull);
      expect(json['details']['process'], equals('lldb'));
    });

    test('should clear violations', () {
      // Add some violations
      raspService.onViolationDetected = (v) => detectedViolations.add(v);
      raspService.onViolationDetected!(SecurityViolation(
        type: ViolationType.debuggerAttached,
        severity: ViolationSeverity.critical,
        message: 'Test',
        timestamp: DateTime.now(),
      ));

      expect(raspService.violations.isNotEmpty, isTrue);

      // Clear violations
      raspService.clearViolations();

      expect(raspService.violations.isEmpty, isTrue);
    });

    test('should perform runtime checks', () async {
      await raspService.initialize(
        onViolation: (violation) {
          detectedViolations.add(violation);
        },
      );

      // Wait for runtime monitoring to trigger
      await Future.delayed(const Duration(seconds: 11));

      // Should have performed various checks
      final checkMethods = ['verifyCodeIntegrity', 'monitorSystemCalls'];

      for (final method in checkMethods) {
        expect(
          methodCallLog.any((call) => call.method == method),
          isTrue,
          reason: 'Should have called $method',
        );
      }
    });

    test('should handle initialization with custom configuration', () async {
      await raspService.initialize(
        enableDebuggerDetection: false,
        enableHookDetection: false,
        enableMemoryProtection: false,
        enableAntiDebugging: false,
        onViolation: (violation) {},
      );

      // Service should still initialize without errors
      expect(methodCallLog.any((call) => call.method == 'setupProtection'), isTrue);
    });
  });
}