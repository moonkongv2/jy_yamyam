import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jy_yamyam/constants/legal_support_links.dart';
import 'package:jy_yamyam/controllers/vehicle_pack_purchase_controller.dart';
import 'package:jy_yamyam/models/meal_timer_config.dart';
import 'package:jy_yamyam/models/purchase_entitlement.dart';
import 'package:jy_yamyam/screens/settings_screen.dart';
import 'package:jy_yamyam/screens/user_guide_screen.dart';
import 'package:jy_yamyam/services/app_version_service.dart';
import 'package:jy_yamyam/services/external_link_launcher.dart';
import 'package:jy_yamyam/services/local_purchase_entitlement_store.dart';
import 'package:jy_yamyam/widgets/purchases/guardian_gate_sheet.dart';
import 'package:jy_yamyam/widgets/purchases/purchase_entitlement_scope.dart';
import 'package:jy_yamyam/widgets/purchases/vehicle_pack_purchase_sheet.dart';

import 'fakes/fake_iap_purchase_client.dart';
import 'helpers/guardian_gate_test_helpers.dart';

void main() {
  testWidgets('Settings shows help and about sections near the bottom', (
    tester,
  ) async {
    final harness = _SettingsLegalSupportHarness();
    addTearDown(harness.dispose);

    await _pumpSettings(tester, harness);
    await _scrollToHelpSupportSection(tester);

    expect(find.text('도움말 및 지원'), findsOneWidget);
    expect(find.text('사용 가이드'), findsOneWidget);
    expect(find.text('구매 복원'), findsOneWidget);
    expect(find.text('고객지원'), findsOneWidget);

    await _scrollToAboutSection(tester);

    expect(find.text('정보'), findsOneWidget);
    expect(find.text('개인정보처리방침'), findsOneWidget);
    expect(find.text('앱 버전'), findsOneWidget);
    expect(find.text('1.2.3+45'), findsOneWidget);
  });

  testWidgets('User Guide opens internally without guardian gate', (
    tester,
  ) async {
    final harness = _SettingsLegalSupportHarness();
    addTearDown(harness.dispose);

    await _pumpSettings(tester, harness);
    await _scrollToTile(tester, const ValueKey('userGuideSettingsTile'));

    await tester.tap(find.byKey(const ValueKey('userGuideSettingsTile')));
    await tester.pumpAndSettle();

    expect(find.byType(GuardianGateSheet), findsNothing);
    expect(find.byType(UserGuideScreen), findsOneWidget);
    expect(find.byKey(const ValueKey('userGuideListView')), findsOneWidget);
    expect(harness.linkLauncher.openedUris, isEmpty);
  });

  testWidgets('Restore Purchase opens guardian gate before restore UI', (
    tester,
  ) async {
    final harness = _SettingsLegalSupportHarness();
    addTearDown(harness.dispose);

    await _pumpSettings(tester, harness);
    await _scrollToTile(tester, const ValueKey('settingsRestorePurchaseTile'));

    await tester.tap(find.byKey(const ValueKey('settingsRestorePurchaseTile')));
    await tester.pumpAndSettle();

    expect(find.byType(GuardianGateSheet), findsOneWidget);
    expect(find.byType(VehiclePackPurchaseSheet), findsNothing);
    expect(harness.purchaseClient.restorePurchasesCallCount, 0);

    await enterCurrentGuardianGateAnswer(tester);
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('guardianGateContinueButton')));
    await tester.pumpAndSettle();

    expect(find.byType(GuardianGateSheet), findsNothing);
    expect(find.byType(VehiclePackPurchaseSheet), findsOneWidget);
    expect(harness.purchaseClient.restorePurchasesCallCount, 0);
  });

  testWidgets('Contact Support opens external URL after guardian gate', (
    tester,
  ) async {
    final harness = _SettingsLegalSupportHarness();
    addTearDown(harness.dispose);

    await _pumpSettings(tester, harness);
    await _scrollToTile(tester, const ValueKey('settingsContactSupportTile'));

    await tester.tap(find.byKey(const ValueKey('settingsContactSupportTile')));
    await tester.pumpAndSettle();

    expect(find.byType(GuardianGateSheet), findsOneWidget);
    expect(harness.linkLauncher.openedUris, isEmpty);

    await enterCurrentGuardianGateAnswer(tester);
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('guardianGateContinueButton')));
    await tester.pumpAndSettle();

    expect(harness.linkLauncher.openedUris, [LegalSupportLinks.supportUri]);
  });

  testWidgets('Privacy Policy opens external URL after guardian gate', (
    tester,
  ) async {
    final harness = _SettingsLegalSupportHarness();
    addTearDown(harness.dispose);

    await _pumpSettings(tester, harness);
    await _scrollToTile(tester, const ValueKey('settingsPrivacyPolicyTile'));

    await tester.tap(find.byKey(const ValueKey('settingsPrivacyPolicyTile')));
    await tester.pumpAndSettle();

    expect(find.byType(GuardianGateSheet), findsOneWidget);
    expect(harness.linkLauncher.openedUris, isEmpty);

    await enterCurrentGuardianGateAnswer(tester);
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('guardianGateContinueButton')));
    await tester.pumpAndSettle();

    expect(harness.linkLauncher.openedUris, [
      LegalSupportLinks.privacyPolicyUri,
    ]);
  });

  testWidgets('App Version is plain text and not an action', (tester) async {
    final harness = _SettingsLegalSupportHarness();
    addTearDown(harness.dispose);

    await _pumpSettings(tester, harness);
    await _scrollToTile(tester, const ValueKey('settingsAppVersionRow'));

    expect(find.text('앱 버전'), findsOneWidget);
    expect(find.text('1.2.3+45'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('settingsAppVersionRow')));
    await tester.pumpAndSettle();

    expect(find.byType(GuardianGateSheet), findsNothing);
    expect(harness.linkLauncher.openedUris, isEmpty);
  });
}

Future<void> _pumpSettings(
  WidgetTester tester,
  _SettingsLegalSupportHarness harness,
) async {
  SharedPreferences.setMockInitialValues({});
  harness.purchaseController.startListening();
  await tester.pumpWidget(
    PurchaseEntitlementScope(
      entitlement: const PurchaseEntitlement.locked(),
      purchaseController: harness.purchaseController,
      child: MaterialApp(
        locale: const Locale('ko'),
        supportedLocales: const [Locale('ko'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        home: SettingsScreen(
          config: MealTimerConfig.defaults(),
          onConfigChanged: (_) {},
          externalLinkLauncher: harness.linkLauncher,
          appVersionService: harness.appVersionService,
        ),
      ),
    ),
  );
  await tester.pump();
}

Future<void> _scrollToHelpSupportSection(WidgetTester tester) {
  return _scrollToTile(tester, const ValueKey('settingsHelpSupportSection'));
}

Future<void> _scrollToAboutSection(WidgetTester tester) {
  return _scrollToTile(tester, const ValueKey('settingsAboutSection'));
}

Future<void> _scrollToTile(WidgetTester tester, Key key) async {
  await tester.scrollUntilVisible(
    find.byKey(key),
    300,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

class _SettingsLegalSupportHarness {
  _SettingsLegalSupportHarness() {
    purchaseClient = FakeIapPurchaseClient(
      productDetailsResponse: ProductDetailsResponse(
        productDetails: [fakeProductDetails()],
        notFoundIDs: const [],
      ),
    );
    purchaseController = VehiclePackPurchaseController(
      purchaseClient: purchaseClient,
      entitlementStore: const LocalPurchaseEntitlementStore(),
      initialEntitlement: const PurchaseEntitlement.locked(),
    );
  }

  final linkLauncher = _FakeExternalLinkLauncher();
  final appVersionService = const _FakeAppVersionService('1.2.3+45');
  late final FakeIapPurchaseClient purchaseClient;
  late final VehiclePackPurchaseController purchaseController;

  Future<void> dispose() async {
    purchaseController.dispose();
    await purchaseClient.dispose();
  }
}

class _FakeExternalLinkLauncher implements ExternalLinkLauncher {
  final openedUris = <Uri>[];

  @override
  Future<bool> open(Uri uri) async {
    openedUris.add(uri);
    return true;
  }
}

class _FakeAppVersionService implements AppVersionService {
  const _FakeAppVersionService(this.versionLabel);

  final String versionLabel;

  @override
  Future<String> loadVersionLabel() async => versionLabel;
}
