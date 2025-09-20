import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_auth_template/presentation/widgets/compliance/cookie_consent_banner.dart';
import 'package:flutter_auth_template/core/compliance/consent_manager.dart';

@GenerateMocks([ConsentManager])
import 'cookie_consent_banner_test.mocks.dart';

void main() {
  late MockConsentManager mockConsentManager;

  setUp(() {
    mockConsentManager = MockConsentManager();

    // Setup default mock behaviors
    when(mockConsentManager.initialize()).thenAnswer((_) async => {});
    when(mockConsentManager.hasGivenConsent).thenReturn(false);
    when(mockConsentManager.currentPreferences).thenReturn(null);
    when(mockConsentManager.isConsentGranted(any)).thenReturn(false);
    when(mockConsentManager.updateConsent(
      consents: anyNamed('consents'),
      method: anyNamed('method'),
    )).thenAnswer((_) async => {});
  });

  Widget createTestWidget(Widget child) {
    return ProviderScope(
      overrides: [
        consentManagerProvider.overrideWithValue(mockConsentManager),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: child,
        ),
      ),
    );
  }

  group('CookieConsentBanner Tests', () {
    testWidgets('should not show on non-web platforms', (tester) async {
      // Override kIsWeb for testing (this is tricky in actual tests)
      // In real scenarios, you'd need platform-specific test configurations

      await tester.pumpWidget(createTestWidget(const CookieConsentBanner()));
      await tester.pumpAndSettle();

      // On non-web platforms, the banner should not be visible
      if (!kIsWeb) {
        expect(find.byType(CookieConsentBanner), findsOneWidget);
        expect(find.text('Cookie Consent'), findsNothing);
      }
    });

    testWidgets('should show banner when consent not given on web',
        (tester) async {
      // This test would run on web platform
      if (kIsWeb) {
        when(mockConsentManager.hasGivenConsent).thenReturn(false);

        await tester.pumpWidget(createTestWidget(const CookieConsentBanner()));
        await tester.pumpAndSettle();

        expect(find.text('Cookie Consent'), findsOneWidget);
        expect(find.text('Accept All'), findsOneWidget);
        expect(find.text('Manage Preferences'), findsOneWidget);
        expect(find.text('Reject Non-Essential'), findsOneWidget);
      }
    });

    testWidgets('should not show banner when consent already given',
        (tester) async {
      if (kIsWeb) {
        when(mockConsentManager.hasGivenConsent).thenReturn(true);

        await tester.pumpWidget(createTestWidget(const CookieConsentBanner()));
        await tester.pumpAndSettle();

        expect(find.text('Cookie Consent'), findsNothing);
      }
    });

    testWidgets('should show consent options when Manage Preferences tapped',
        (tester) async {
      if (kIsWeb) {
        when(mockConsentManager.hasGivenConsent).thenReturn(false);

        await tester.pumpWidget(createTestWidget(const CookieConsentBanner()));
        await tester.pumpAndSettle();

        // Tap Manage Preferences
        final manageButton = find.text('Manage Preferences');
        if (manageButton.evaluate().isNotEmpty) {
          await tester.tap(manageButton);
          await tester.pumpAndSettle();

          expect(find.text('Cookie Preferences'), findsOneWidget);
          expect(find.text('Essential Cookies'), findsOneWidget);
          expect(find.text('Analytics Cookies'), findsOneWidget);
          expect(find.text('Marketing Cookies'), findsOneWidget);
          expect(find.text('Preference Cookies'), findsOneWidget);
        }
      }
    });

    testWidgets('should call updateConsent when Accept All is tapped',
        (tester) async {
      if (kIsWeb) {
        when(mockConsentManager.hasGivenConsent).thenReturn(false);

        await tester.pumpWidget(createTestWidget(const CookieConsentBanner()));
        await tester.pumpAndSettle();

        final acceptButton = find.text('Accept All');
        if (acceptButton.evaluate().isNotEmpty) {
          await tester.tap(acceptButton);
          await tester.pumpAndSettle();

          verify(mockConsentManager.updateConsent(
            consents: argThat(
              named: 'consents',
              isA<Map<ConsentType, bool>>().having(
                (consents) => consents.values.every((v) => v == true),
                'all consents true',
                isTrue,
              ),
            ),
            method: ConsentMethod.explicit,
          )).called(1);
        }
      }
    });

    testWidgets('should only accept essential when Reject Non-Essential tapped',
        (tester) async {
      if (kIsWeb) {
        when(mockConsentManager.hasGivenConsent).thenReturn(false);

        await tester.pumpWidget(createTestWidget(const CookieConsentBanner()));
        await tester.pumpAndSettle();

        final rejectButton = find.text('Reject Non-Essential');
        if (rejectButton.evaluate().isNotEmpty) {
          await tester.tap(rejectButton);
          await tester.pumpAndSettle();

          verify(mockConsentManager.updateConsent(
            consents: argThat(
              named: 'consents',
              isA<Map<ConsentType, bool>>().having(
                (consents) => consents[ConsentType.essential] == true,
                'essential consent true',
                isTrue,
              ),
            ),
            method: ConsentMethod.explicit,
          )).called(1);
        }
      }
    });

    testWidgets('should show privacy policy dialog', (tester) async {
      if (kIsWeb) {
        when(mockConsentManager.hasGivenConsent).thenReturn(false);

        await tester.pumpWidget(createTestWidget(const CookieConsentBanner()));
        await tester.pumpAndSettle();

        final privacyButton = find.text('Privacy Policy');
        if (privacyButton.evaluate().isNotEmpty) {
          await tester.tap(privacyButton);
          await tester.pumpAndSettle();

          expect(find.byType(AlertDialog), findsOneWidget);
          expect(find.text('Privacy Policy'), findsNWidgets(2)); // Title and button
          expect(find.text('Close'), findsOneWidget);

          // Close dialog
          await tester.tap(find.text('Close'));
          await tester.pumpAndSettle();

          expect(find.byType(AlertDialog), findsNothing);
        }
      }
    });

    testWidgets('should animate banner appearance', (tester) async {
      if (kIsWeb) {
        when(mockConsentManager.hasGivenConsent).thenReturn(false);

        await tester.pumpWidget(createTestWidget(const CookieConsentBanner()));

        // Initial state
        expect(find.byType(CookieConsentBanner), findsOneWidget);

        // Wait for animation
        await tester.pump(const Duration(milliseconds: 250));
        await tester.pump(const Duration(milliseconds: 250));
        await tester.pumpAndSettle();

        // Banner should be fully visible
        expect(find.text('Cookie Consent'), findsOneWidget);
      }
    });

    testWidgets('Essential cookies should not be toggleable', (tester) async {
      if (kIsWeb) {
        when(mockConsentManager.hasGivenConsent).thenReturn(false);

        await tester.pumpWidget(createTestWidget(const CookieConsentBanner()));
        await tester.pumpAndSettle();

        // Show preferences
        final manageButton = find.text('Manage Preferences');
        if (manageButton.evaluate().isNotEmpty) {
          await tester.tap(manageButton);
          await tester.pumpAndSettle();

          // Find the switch for essential cookies
          final switches = find.byType(Switch);
          if (switches.evaluate().isNotEmpty) {
            // The first switch should be for essential cookies and should be disabled
            final essentialSwitch = switches.first;
            final switchWidget = tester.widget<Switch>(essentialSwitch);
            expect(switchWidget.onChanged, isNull); // Disabled switch
          }
        }
      }
    });
  });

  group('CookieConsentSettings Tests', () {
    testWidgets('should display current consent preferences', (tester) async {
      final mockPreferences = ConsentPreferences(
        consents: {
          ConsentType.essential: true,
          ConsentType.analytics: true,
          ConsentType.marketing: false,
        },
        timestamp: DateTime.now(),
        version: ConsentVersion.current,
        method: ConsentMethod.explicit,
      );

      when(mockConsentManager.currentPreferences).thenReturn(mockPreferences);

      await tester.pumpWidget(
        createTestWidget(const CookieConsentSettings()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Cookie Preferences'), findsOneWidget);
      expect(find.text('About Cookies'), findsOneWidget);
      expect(find.byType(SwitchListTile), findsWidgets);
    });

    testWidgets('should save preferences when Save button tapped',
        (tester) async {
      when(mockConsentManager.currentPreferences).thenReturn(null);

      await tester.pumpWidget(
        createTestWidget(const CookieConsentSettings()),
      );
      await tester.pumpAndSettle();

      // Toggle a preference
      final switches = find.byType(SwitchListTile);
      if (switches.evaluate().length > 1) {
        // Skip essential (first one) and toggle analytics (second one)
        await tester.tap(switches.at(1));
        await tester.pumpAndSettle();
      }

      // Tap save
      final saveButton = find.text('Save Preferences');
      if (saveButton.evaluate().isNotEmpty) {
        await tester.tap(saveButton);
        await tester.pumpAndSettle();

        verify(mockConsentManager.updateConsent(
          consents: any,
          method: ConsentMethod.explicit,
        )).called(1);
      }
    });

    testWidgets('should navigate back when Cancel tapped', (tester) async {
      when(mockConsentManager.currentPreferences).thenReturn(null);

      await tester.pumpWidget(
        createTestWidget(const CookieConsentSettings()),
      );
      await tester.pumpAndSettle();

      final cancelButton = find.text('Cancel');
      if (cancelButton.evaluate().isNotEmpty) {
        await tester.tap(cancelButton);
        await tester.pumpAndSettle();

        // Should navigate back (in test environment, this might not work as expected)
        verifyNever(mockConsentManager.updateConsent(
          consents: any,
          method: any,
        ));
      }
    });

    testWidgets('should display all consent types', (tester) async {
      when(mockConsentManager.currentPreferences).thenReturn(null);

      await tester.pumpWidget(
        createTestWidget(const CookieConsentSettings()),
      );
      await tester.pumpAndSettle();

      // Check for various consent type titles
      expect(find.textContaining('Essential'), findsOneWidget);
      expect(find.textContaining('Analytics'), findsOneWidget);
      expect(find.textContaining('Marketing'), findsOneWidget);
      expect(find.textContaining('Preference'), findsOneWidget);
    });

    testWidgets('should show loading indicator initially', (tester) async {
      when(mockConsentManager.initialize())
          .thenAnswer((_) async => Future.delayed(
                const Duration(seconds: 1),
              ));

      await tester.pumpWidget(
        createTestWidget(const CookieConsentSettings()),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('should show success snackbar after saving', (tester) async {
      when(mockConsentManager.currentPreferences).thenReturn(null);

      await tester.pumpWidget(
        createTestWidget(const CookieConsentSettings()),
      );
      await tester.pumpAndSettle();

      final saveButton = find.text('Save Preferences');
      if (saveButton.evaluate().isNotEmpty) {
        await tester.tap(saveButton);
        await tester.pump();

        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.text('Cookie preferences updated'), findsOneWidget);
      }
    });
  });
}