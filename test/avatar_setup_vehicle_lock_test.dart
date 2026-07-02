import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'package:jy_yamyam/controllers/vehicle_pack_purchase_controller.dart';
import 'package:jy_yamyam/models/meal_timer_config.dart';
import 'package:jy_yamyam/models/purchase_entitlement.dart';
import 'package:jy_yamyam/screens/avatar_setup_screen.dart';
import 'package:jy_yamyam/services/local_purchase_entitlement_store.dart';
import 'package:jy_yamyam/widgets/purchases/guardian_gate_sheet.dart';
import 'package:jy_yamyam/widgets/purchases/purchase_entitlement_scope.dart';
import 'package:jy_yamyam/widgets/purchases/vehicle_pack_intro_sheet.dart';
import 'package:jy_yamyam/widgets/purchases/vehicle_pack_purchase_sheet.dart';

import 'fakes/fake_iap_purchase_client.dart';

void main() {
  testWidgets('Avatar setup default mode blocks locked vehicle selection', (
    tester,
  ) async {
    MealTimerConfig? changedConfig;

    await _pumpAvatarSetup(
      tester,
      entitlement: const PurchaseEntitlement.locked(),
      onConfigChanged: (config) => changedConfig = config,
    );
    await _scrollVehicleChoiceIntoView(tester, 'bus');

    expect(
      find.byKey(const ValueKey('vehicleChoiceLockBadge.bus')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('vehicleChoiceLockBadge.motorcycle')),
      findsNothing,
    );

    await _tapVehicleChoice(tester, 'bus');
    expect(changedConfig, isNull);

    await _tapVehicleChoice(tester, 'supercar');
    expect(changedConfig?.vehicleId, 'supercar');
  });

  testWidgets('Avatar setup custom mode blocks locked vehicle selection', (
    tester,
  ) async {
    MealTimerConfig? changedConfig;

    await _pumpAvatarSetup(
      tester,
      entitlement: const PurchaseEntitlement.locked(),
      onConfigChanged: (config) => changedConfig = config,
    );

    await tester.tap(find.text('직접 만든 라이더 사용'));
    await tester.pump();

    await _tapVehicleChoice(tester, 'bus');
    expect(changedConfig, isNull);

    await _tapVehicleChoice(tester, 'supercar');
    expect(changedConfig?.vehicleId, 'supercar');
  });

  testWidgets(
    'Avatar setup does not show locks when vehicle pack is unlocked',
    (tester) async {
      await _pumpAvatarSetup(
        tester,
        entitlement: const PurchaseEntitlement(vehiclePackUnlocked: true),
      );
      await _scrollVehicleChoiceIntoView(tester, 'bus');

      expect(
        find.byKey(const ValueKey('vehicleChoiceLockBadge.bus')),
        findsNothing,
      );
    },
  );

  testWidgets(
    'Avatar setup locked vehicle opens guardian gate and purchase sheet',
    (tester) async {
      final productDetails = fakeProductDetails();
      final client = FakeIapPurchaseClient(
        productDetailsResponse: ProductDetailsResponse(
          productDetails: [productDetails],
          notFoundIDs: const [],
        ),
      );
      addTearDown(client.dispose);
      final controller = VehiclePackPurchaseController(
        purchaseClient: client,
        entitlementStore: const LocalPurchaseEntitlementStore(),
      );
      addTearDown(controller.dispose);

      await _pumpAvatarSetup(
        tester,
        entitlement: const PurchaseEntitlement.locked(),
        purchaseController: controller,
      );

      await _tapVehicleChoice(tester, 'bus');
      await tester.pumpAndSettle();

      expect(find.byType(VehiclePackIntroSheet), findsOneWidget);
      expect(find.byType(GuardianGateSheet), findsNothing);
      expect(find.byType(VehiclePackPurchaseSheet), findsNothing);

      await tester.tap(
        find.byKey(const ValueKey('vehiclePackIntroContinueButton')),
      );
      await tester.pumpAndSettle();

      expect(find.byType(VehiclePackIntroSheet), findsNothing);
      expect(find.byType(GuardianGateSheet), findsOneWidget);

      await tester.enterText(
        find.byKey(const ValueKey('guardianGateAnswerField')),
        '13',
      );
      await tester.pump();
      await tester.tap(
        find.byKey(const ValueKey('guardianGateContinueButton')),
      );
      await tester.pumpAndSettle();

      expect(find.byType(GuardianGateSheet), findsNothing);
      expect(find.byType(VehiclePackPurchaseSheet), findsOneWidget);
      expect(
        find.byKey(const ValueKey('vehiclePackBuyButton')),
        findsOneWidget,
      );
    },
  );
}

Future<void> _pumpAvatarSetup(
  WidgetTester tester, {
  required PurchaseEntitlement entitlement,
  ValueChanged<MealTimerConfig>? onConfigChanged,
  VehiclePackPurchaseController? purchaseController,
}) async {
  await tester.pumpWidget(
    PurchaseEntitlementScope(
      entitlement: entitlement,
      purchaseController: purchaseController,
      child: MaterialApp(
        locale: const Locale('ko'),
        supportedLocales: const [Locale('ko'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        home: AvatarSetupScreen(
          config: MealTimerConfig.defaults(),
          onConfigChanged: onConfigChanged ?? (_) {},
        ),
      ),
    ),
  );
  await tester.pump();
  await _dismissAvatarGuideIfVisible(tester);
}

Future<void> _dismissAvatarGuideIfVisible(WidgetTester tester) async {
  await tester.pumpAndSettle();
  final guideTitle = find.text('우리 아이 라이더 만들기 안내');
  if (guideTitle.evaluate().isEmpty) {
    return;
  }
  Navigator.of(tester.element(guideTitle)).pop();
  await tester.pumpAndSettle();
}

Future<void> _tapVehicleChoice(WidgetTester tester, String vehicleId) async {
  final choice = await _scrollVehicleChoiceIntoView(tester, vehicleId);
  await tester.tap(choice);
  await tester.pump();
}

Future<Finder> _scrollVehicleChoiceIntoView(
  WidgetTester tester,
  String vehicleId,
) async {
  final choice = find.byKey(ValueKey('vehicleChoice.$vehicleId'));
  for (var index = 0; index < 6; index += 1) {
    if (choice.evaluate().isNotEmpty) {
      await tester.ensureVisible(choice);
      await tester.pumpAndSettle();
      return choice;
    }
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
  }
  fail('Vehicle choice $vehicleId was not found.');
}
