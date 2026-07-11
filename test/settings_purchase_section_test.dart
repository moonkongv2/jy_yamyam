import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jy_yamyam/controllers/vehicle_pack_purchase_controller.dart';
import 'package:jy_yamyam/models/meal_timer_config.dart';
import 'package:jy_yamyam/models/purchase_entitlement.dart';
import 'package:jy_yamyam/screens/settings_screen.dart';
import 'package:jy_yamyam/services/local_purchase_entitlement_store.dart';
import 'package:jy_yamyam/widgets/purchases/guardian_gate_sheet.dart';
import 'package:jy_yamyam/widgets/purchases/purchase_entitlement_scope.dart';
import 'package:jy_yamyam/widgets/purchases/vehicle_pack_purchase_sheet.dart';

import 'fakes/fake_iap_purchase_client.dart';
import 'helpers/guardian_gate_test_helpers.dart';

void main() {
  testWidgets('Settings shows locked vehicle pack section', (tester) async {
    final harness = _SettingsPurchaseHarness(
      entitlement: const PurchaseEntitlement.locked(),
    );
    addTearDown(harness.dispose);

    await _pumpSettings(tester, harness);
    await _scrollToVehiclePackCard(tester);

    expect(
      find.byKey(const ValueKey('settingsVehiclePackCard')),
      findsOneWidget,
    );
    expect(find.text('차량팩'), findsOneWidget);
    expect(find.textContaining('오토바이와 슈퍼카는 무료로 사용할 수 있어요.'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('settingsVehiclePackUnlockButton')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('settingsVehiclePackRestoreButton')),
      findsOneWidget,
    );
  });

  testWidgets('Settings purchase CTA requires guardian gate', (tester) async {
    final harness = _SettingsPurchaseHarness(
      entitlement: const PurchaseEntitlement.locked(),
    );
    addTearDown(harness.dispose);

    await _pumpSettings(tester, harness);
    await _scrollToVehiclePackCard(tester);

    await tester.tap(
      find.byKey(const ValueKey('settingsVehiclePackUnlockButton')),
    );
    await tester.pumpAndSettle();

    expect(find.byType(GuardianGateSheet), findsOneWidget);
    expect(find.byType(VehiclePackPurchaseSheet), findsNothing);

    await enterCurrentGuardianGateAnswer(tester);
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('guardianGateContinueButton')));
    await tester.pumpAndSettle();

    expect(find.byType(GuardianGateSheet), findsNothing);
    expect(find.byType(VehiclePackPurchaseSheet), findsOneWidget);
    expect(find.byKey(const ValueKey('vehiclePackBuyButton')), findsOneWidget);
  });

  testWidgets('Settings restore CTA requires gate and starts restore', (
    tester,
  ) async {
    final harness = _SettingsPurchaseHarness(
      entitlement: const PurchaseEntitlement.locked(),
    );
    addTearDown(harness.dispose);

    await _pumpSettings(tester, harness);
    await _scrollToVehiclePackCard(tester);

    await tester.tap(
      find.byKey(const ValueKey('settingsVehiclePackRestoreButton')),
    );
    await tester.pumpAndSettle();

    expect(find.byType(GuardianGateSheet), findsOneWidget);
    expect(harness.client.restorePurchasesCallCount, 0);

    await enterCurrentGuardianGateAnswer(tester);
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('guardianGateContinueButton')));
    await tester.pumpAndSettle();

    expect(find.byType(VehiclePackPurchaseSheet), findsOneWidget);
    expect(harness.client.restorePurchasesCallCount, 1);
  });

  testWidgets('Settings unlocked vehicle pack section hides purchase CTA', (
    tester,
  ) async {
    final harness = _SettingsPurchaseHarness(
      entitlement: const PurchaseEntitlement(vehiclePackUnlocked: true),
    );
    addTearDown(harness.dispose);

    await _pumpSettings(tester, harness);

    await _scrollToVehiclePackCard(tester);

    expect(
      find.byKey(const ValueKey('settingsUnlockedVehiclePackCard')),
      findsWidgets,
    );
    expect(
      find.text('차량팩 열림. 모든 차량을 사용할 수 있어요.'),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('settingsVehiclePackUnlockButton')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('settingsVehiclePackRestoreButton')),
      findsNothing,
    );
  });
}

Future<void> _scrollToVehiclePackCard(WidgetTester tester) async {
  await tester.drag(find.byType(ListView), const Offset(0, -900));
  await tester.pumpAndSettle();
}

Future<void> _pumpSettings(
  WidgetTester tester,
  _SettingsPurchaseHarness harness,
) async {
  SharedPreferences.setMockInitialValues({});
  harness.controller.startListening();
  await tester.pumpWidget(
    PurchaseEntitlementScope(
      entitlement: harness.entitlement,
      purchaseController: harness.controller,
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
        ),
      ),
    ),
  );
  await tester.pump();
}

class _SettingsPurchaseHarness {
  _SettingsPurchaseHarness({required this.entitlement}) {
    productDetails = fakeProductDetails();
    client = FakeIapPurchaseClient(
      productDetailsResponse: ProductDetailsResponse(
        productDetails: [productDetails],
        notFoundIDs: const [],
      ),
    );
    controller = VehiclePackPurchaseController(
      purchaseClient: client,
      entitlementStore: const LocalPurchaseEntitlementStore(),
      initialEntitlement: entitlement,
    );
  }

  final PurchaseEntitlement entitlement;
  late final ProductDetails productDetails;
  late final FakeIapPurchaseClient client;
  late final VehiclePackPurchaseController controller;

  Future<void> dispose() async {
    controller.dispose();
    await client.dispose();
  }
}
