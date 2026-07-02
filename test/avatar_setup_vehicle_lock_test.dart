import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jy_yamyam/models/meal_timer_config.dart';
import 'package:jy_yamyam/models/purchase_entitlement.dart';
import 'package:jy_yamyam/screens/avatar_setup_screen.dart';
import 'package:jy_yamyam/widgets/purchases/purchase_entitlement_scope.dart';

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
}

Future<void> _pumpAvatarSetup(
  WidgetTester tester, {
  required PurchaseEntitlement entitlement,
  ValueChanged<MealTimerConfig>? onConfigChanged,
}) async {
  await tester.pumpWidget(
    PurchaseEntitlementScope(
      entitlement: entitlement,
      purchaseController: null,
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
