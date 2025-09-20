import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth_template/core/security/security_manager.dart';
import 'package:flutter_auth_template/core/security/app_attestation_service.dart';
import 'package:flutter_auth_template/core/security/anti_tampering_service.dart';
import 'package:flutter_auth_template/core/security/rasp_service.dart';
import 'package:flutter_auth_template/core/security/security_event_logger.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Generate mocks
@GenerateMocks([
  AppAttestationService,
  AntiTamperingService,
  RASPService,
  SecurityEventLogger,
])
import 'security_manager_test.mocks.dart';

void main() {
  late MockAppAttestationService mockAttestation;
  late MockAntiTamperingService mockAntiTampering;
  late MockRASPService mockRasp;
  late MockSecurityEventLogger mockEventLogger;
  late SecurityManager securityManager;

  setUp(() {
    mockAttestation = MockAppAttestationService();
    mockAntiTampering = MockAntiTamperingService();
    mockRasp = MockRASPService();
    mockEventLogger = MockSecurityEventLogger();

    securityManager = SecurityManager(
      attestation: mockAttestation,
      antiTampering: mockAntiTampering,
      rasp: mockRasp,
      eventLogger: mockEventLogger,
    );

    // Setup default mock behaviors
    when(mockAttestation.initialize()).thenAnswer((_) async => {});
    when(mockAntiTampering.initialize()).thenAnswer((_) async => {});
    when(mockRasp.initialize(
      enableDebuggerDetection: anyNamed('enableDebuggerDetection'),
      enableHookDetection: anyNamed('enableHookDetection'),
      enableMemoryProtection: anyNamed('enableMemoryProtection'),
      onViolation: anyNamed('onViolation'),
    )).thenAnswer((_) async => {});

    when(mockEventLogger.logEvent(
      type: anyNamed('type'),
      severity: anyNamed('severity'),
      description: anyNamed('description'),
      metadata: anyNamed('metadata'),
    )).thenAnswer((_) async => {});
  });

  group('Security Manager Tests', () {
    test('should initialize with production configuration', () async {
      // Setup mocks for security check
      when(mockAttestation.verifyAttestation(
        userId: anyNamed('userId'),
        challenge: anyNamed('challenge'),
      )).thenAnswer((_) async => AttestationResult(
        isValid: true,
        platform: 'android',
        message: 'Attestation passed',
        riskLevel: 'low',
      ));

      when(mockAntiTampering.verifyIntegrity()).thenAnswer((_) async =>
        TamperDetectionResult(
          isIntact: true,
          checks: {'signature': true, 'resources': true},
          issues: [],
          riskLevel: 'low',
          timestamp: DateTime.now(),
        ),
      );

      when(mockAntiTampering.isRunningInEmulator()).thenAnswer((_) async => false);
      when(mockAntiTampering.isFromOfficialStore()).thenAnswer((_) async => true);

      await securityManager.initialize(
        config: SecurityConfiguration.production(),
      );

      // Verify all services were initialized
      verify(mockAttestation.initialize()).called(1);
      verify(mockAntiTampering.initialize()).called(1);
      verify(mockRasp.initialize(
        enableDebuggerDetection: true,
        enableHookDetection: true,
        enableMemoryProtection: true,
        onViolation: anyNamed('onViolation'),
      )).called(1);
    });

    test('should initialize with development configuration', () async {
      // Setup mocks for security check
      when(mockAntiTampering.verifyIntegrity()).thenAnswer((_) async =>
        TamperDetectionResult(
          isIntact: true,
          checks: {},
          issues: [],
          riskLevel: 'low',
          timestamp: DateTime.now(),
        ),
      );

      await securityManager.initialize(
        config: SecurityConfiguration.development(),
      );

      // Verify attestation is not initialized in dev mode
      verifyNever(mockAttestation.initialize());

      // Verify RASP is initialized with development settings
      verify(mockRasp.initialize(
        enableDebuggerDetection: false,
        enableHookDetection: false,
        enableMemoryProtection: true,
        onViolation: anyNamed('onViolation'),
      )).called(1);
    });

    test('should perform comprehensive security check', () async {
      // Setup all mocks
      when(mockAttestation.verifyAttestation(
        userId: anyNamed('userId'),
        challenge: anyNamed('challenge'),
      )).thenAnswer((_) async => AttestationResult(
        isValid: true,
        platform: 'ios',
        message: 'Device check passed',
        riskLevel: 'low',
      ));

      when(mockAntiTampering.verifyIntegrity()).thenAnswer((_) async =>
        TamperDetectionResult(
          isIntact: true,
          checks: {'all': true},
          issues: [],
          riskLevel: 'low',
          timestamp: DateTime.now(),
        ),
      );

      when(mockAntiTampering.isRunningInEmulator()).thenAnswer((_) async => false);
      when(mockAntiTampering.isFromOfficialStore()).thenAnswer((_) async => true);

      await securityManager.initialize(config: SecurityConfiguration.production());
      final result = await securityManager.performSecurityCheck();

      expect(result.status, equals(SecurityStatus.secure));
      expect(result.score, greaterThanOrEqualTo(90));
      expect(result.issues, isEmpty);
      expect(result.checks['attestation'], isTrue);
      expect(result.checks['integrity'], isTrue);
      expect(result.checks['no_emulator'], isTrue);
      expect(result.checks['official_store'], isTrue);
    });

    test('should detect rooted device', () async {
      // Mock rooted device
      when(mockAttestation.verifyAttestation(
        userId: anyNamed('userId'),
        challenge: anyNamed('challenge'),
      )).thenAnswer((_) async => AttestationResult(
        isValid: false,
        platform: 'android',
        message: 'Device is rooted',
        riskLevel: 'high',
      ));

      when(mockAntiTampering.verifyIntegrity()).thenAnswer((_) async =>
        TamperDetectionResult(
          isIntact: true,
          checks: {},
          issues: [],
          riskLevel: 'low',
          timestamp: DateTime.now(),
        ),
      );

      when(mockAntiTampering.isRunningInEmulator()).thenAnswer((_) async => false);
      when(mockAntiTampering.isFromOfficialStore()).thenAnswer((_) async => true);

      await securityManager.initialize(config: SecurityConfiguration.production());
      final result = await securityManager.performSecurityCheck();

      expect(result.status, equals(SecurityStatus.risk));
      expect(result.score, lessThan(90));
      expect(result.issues, contains('Device is rooted'));
      expect(result.checks['attestation'], isFalse);
    });

    test('should detect tampered app', () async {
      // Mock tampered app
      when(mockAttestation.verifyAttestation(
        userId: anyNamed('userId'),
        challenge: anyNamed('challenge'),
      )).thenAnswer((_) async => AttestationResult(
        isValid: true,
        platform: 'android',
        message: 'Attestation passed',
        riskLevel: 'low',
      ));

      when(mockAntiTampering.verifyIntegrity()).thenAnswer((_) async =>
        TamperDetectionResult(
          isIntact: false,
          checks: {'signature': false},
          issues: ['Invalid app signature', 'Modified resources'],
          riskLevel: 'critical',
          timestamp: DateTime.now(),
        ),
      );

      when(mockAntiTampering.isRunningInEmulator()).thenAnswer((_) async => false);
      when(mockAntiTampering.isFromOfficialStore()).thenAnswer((_) async => true);

      await securityManager.initialize(config: SecurityConfiguration.production());
      final result = await securityManager.performSecurityCheck();

      expect(result.status, equals(SecurityStatus.risk));
      expect(result.issues, contains('Invalid app signature'));
      expect(result.issues, contains('Modified resources'));
      expect(result.checks['integrity'], isFalse);
    });

    test('should detect emulator', () async {
      // Mock emulator detection
      when(mockAttestation.verifyAttestation(
        userId: anyNamed('userId'),
        challenge: anyNamed('challenge'),
      )).thenAnswer((_) async => AttestationResult(
        isValid: true,
        platform: 'android',
        message: 'Attestation passed',
        riskLevel: 'low',
      ));

      when(mockAntiTampering.verifyIntegrity()).thenAnswer((_) async =>
        TamperDetectionResult(
          isIntact: true,
          checks: {},
          issues: [],
          riskLevel: 'low',
          timestamp: DateTime.now(),
        ),
      );

      when(mockAntiTampering.isRunningInEmulator()).thenAnswer((_) async => true);
      when(mockAntiTampering.isFromOfficialStore()).thenAnswer((_) async => true);

      await securityManager.initialize(config: SecurityConfiguration.production());
      final result = await securityManager.performSecurityCheck();

      expect(result.issues, contains('App is running in emulator'));
      expect(result.checks['no_emulator'], isFalse);
    });

    test('should detect unofficial store installation', () async {
      // Mock sideloaded app
      when(mockAttestation.verifyAttestation(
        userId: anyNamed('userId'),
        challenge: anyNamed('challenge'),
      )).thenAnswer((_) async => AttestationResult(
        isValid: true,
        platform: 'android',
        message: 'Attestation passed',
        riskLevel: 'low',
      ));

      when(mockAntiTampering.verifyIntegrity()).thenAnswer((_) async =>
        TamperDetectionResult(
          isIntact: true,
          checks: {},
          issues: [],
          riskLevel: 'low',
          timestamp: DateTime.now(),
        ),
      );

      when(mockAntiTampering.isRunningInEmulator()).thenAnswer((_) async => false);
      when(mockAntiTampering.isFromOfficialStore()).thenAnswer((_) async => false);

      await securityManager.initialize(config: SecurityConfiguration.production());
      final result = await securityManager.performSecurityCheck();

      expect(result.issues, contains('App not installed from official store'));
      expect(result.checks['official_store'], isFalse);
    });

    test('should handle RASP violations', () async {
      SecurityViolation? capturedViolation;

      // Initialize with callback capture
      when(mockRasp.initialize(
        enableDebuggerDetection: anyNamed('enableDebuggerDetection'),
        enableHookDetection: anyNamed('enableHookDetection'),
        enableMemoryProtection: anyNamed('enableMemoryProtection'),
        onViolation: anyNamed('onViolation'),
      )).thenAnswer((invocation) async {
        final callback = invocation.namedArguments[Symbol('onViolation')] as Function(SecurityViolation);

        // Simulate a violation
        final violation = SecurityViolation(
          type: ViolationType.debuggerAttached,
          severity: ViolationSeverity.critical,
          message: 'Debugger detected',
          timestamp: DateTime.now(),
        );
        callback(violation);
        capturedViolation = violation;
      });

      when(mockAntiTampering.verifyIntegrity()).thenAnswer((_) async =>
        TamperDetectionResult(
          isIntact: true,
          checks: {},
          issues: [],
          riskLevel: 'low',
          timestamp: DateTime.now(),
        ),
      );

      await securityManager.initialize(config: SecurityConfiguration.production());

      // Verify violation was logged
      verify(mockEventLogger.logEvent(
        type: SecurityEventType.suspiciousActivity,
        severity: SecurityEventSeverity.critical,
        description: 'Debugger detected',
        metadata: anyNamed('metadata'),
      )).called(1);

      expect(securityManager.status, equals(SecurityStatus.critical));
    });

    test('should get security score', () async {
      when(mockAttestation.verifyAttestation(
        userId: anyNamed('userId'),
        challenge: anyNamed('challenge'),
      )).thenAnswer((_) async => AttestationResult(
        isValid: true,
        platform: 'ios',
        message: 'Success',
        riskLevel: 'low',
      ));

      when(mockAntiTampering.verifyIntegrity()).thenAnswer((_) async =>
        TamperDetectionResult(
          isIntact: true,
          checks: {},
          issues: [],
          riskLevel: 'low',
          timestamp: DateTime.now(),
        ),
      );

      when(mockAntiTampering.isRunningInEmulator()).thenAnswer((_) async => false);
      when(mockAntiTampering.isFromOfficialStore()).thenAnswer((_) async => true);

      await securityManager.initialize(config: SecurityConfiguration.production());
      final score = await securityManager.getSecurityScore();

      expect(score, greaterThanOrEqualTo(0));
      expect(score, lessThanOrEqualTo(100));
    });

    test('should check if app is secure', () async {
      when(mockAttestation.verifyAttestation(
        userId: anyNamed('userId'),
        challenge: anyNamed('challenge'),
      )).thenAnswer((_) async => AttestationResult(
        isValid: true,
        platform: 'android',
        message: 'Success',
        riskLevel: 'low',
      ));

      when(mockAntiTampering.verifyIntegrity()).thenAnswer((_) async =>
        TamperDetectionResult(
          isIntact: true,
          checks: {},
          issues: [],
          riskLevel: 'low',
          timestamp: DateTime.now(),
        ),
      );

      when(mockAntiTampering.isRunningInEmulator()).thenAnswer((_) async => false);
      when(mockAntiTampering.isFromOfficialStore()).thenAnswer((_) async => true);

      await securityManager.initialize(config: SecurityConfiguration.production());
      await securityManager.performSecurityCheck();

      expect(securityManager.isSecure, isTrue);
      expect(securityManager.status, equals(SecurityStatus.secure));
    });

    test('should use testing configuration', () async {
      await securityManager.initialize(
        config: SecurityConfiguration.testing(),
      );

      // Verify no security services are initialized in testing mode
      verifyNever(mockAttestation.initialize());
      verifyNever(mockAntiTampering.initialize());
      verifyNever(mockRasp.initialize(
        enableDebuggerDetection: anyNamed('enableDebuggerDetection'),
        enableHookDetection: anyNamed('enableHookDetection'),
        enableMemoryProtection: anyNamed('enableMemoryProtection'),
        onViolation: anyNamed('onViolation'),
      ));
    });
  });

  group('Security Status Indicator Tests', () {
    testWidgets('should display security status', (WidgetTester tester) async {
      final container = ProviderContainer(
        overrides: [
          securityManagerProvider.overrideWithValue(securityManager),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: SecurityStatusIndicator(),
            ),
          ),
        ),
      );

      // Should show unknown status initially
      expect(find.text('Unknown'), findsOneWidget);
      expect(find.byIcon(Icons.help_outline), findsOneWidget);
    });
  });
}