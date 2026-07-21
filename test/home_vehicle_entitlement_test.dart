import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jy_yamyam/controllers/vehicle_pack_purchase_controller.dart';
import 'package:jy_yamyam/models/active_meal_timer_session.dart';
import 'package:jy_yamyam/models/meal_timer_config.dart';
import 'package:jy_yamyam/models/purchase_entitlement.dart';
import 'package:jy_yamyam/screens/home_screen.dart';
import 'package:jy_yamyam/screens/timer_screen.dart';
import 'package:jy_yamyam/services/active_meal_timer_session_store.dart';
import 'package:jy_yamyam/services/local_meal_progress_service.dart';
import 'package:jy_yamyam/services/local_purchase_entitlement_store.dart';
import 'package:jy_yamyam/widgets/app/app_bouncy_button.dart';
import 'package:jy_yamyam/widgets/purchases/guardian_gate_sheet.dart';
import 'package:jy_yamyam/widgets/purchases/purchase_entitlement_scope.dart';
import 'package:jy_yamyam/widgets/purchases/vehicle_pack_intro_sheet.dart';
import 'package:jy_yamyam/widgets/purchases/vehicle_pack_purchase_sheet.dart';

import 'fakes/fake_iap_purchase_client.dart';
import 'helpers/guardian_gate_test_helpers.dart';

void main() {
  testWidgets(
    'Home starts timer with free fallback for locked premium vehicle',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      MealTimerConfig? changedConfig;
      final savedConfig = MealTimerConfig.defaults().copyWith(
        childName: '지율',
        vehicleId: 'bus',
        courseIngredientMode: CourseIngredientMode.off,
      );

      await _pumpHome(
        tester,
        config: savedConfig,
        entitlement: const PurchaseEntitlement.locked(),
        onConfigChanged: (config) => changedConfig = config,
      );

      _tapNormalCourse(tester);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 400));

      final timerScreen = tester.widget<TimerScreen>(find.byType(TimerScreen));
      expect(timerScreen.config.vehicleId, 'motorcycle');
      expect(savedConfig.vehicleId, 'bus');
      expect(changedConfig, isNull);
      await _disposeCurrentTree(tester);
    },
  );

  testWidgets(
    'Home keeps premium vehicle for timer when vehicle pack is unlocked',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final savedConfig = MealTimerConfig.defaults().copyWith(
        childName: '지율',
        vehicleId: 'bus',
        courseIngredientMode: CourseIngredientMode.off,
      );

      await _pumpHome(
        tester,
        config: savedConfig,
        entitlement: const PurchaseEntitlement(vehiclePackUnlocked: true),
      );

      _tapNormalCourse(tester);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 400));

      final timerScreen = tester.widget<TimerScreen>(find.byType(TimerScreen));
      expect(timerScreen.config.vehicleId, 'bus');
      await _disposeCurrentTree(tester);
    },
  );

  testWidgets('Home normalizes below-minimum duration before starting timer', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final savedConfig = MealTimerConfig.defaults().copyWith(
      childName: '지율',
      duration: const Duration(minutes: 1),
      courseIngredientMode: CourseIngredientMode.off,
    );

    await _pumpHome(
      tester,
      config: savedConfig,
      entitlement: const PurchaseEntitlement(vehiclePackUnlocked: true),
    );

    _tapNormalCourse(tester);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 400));

    final timerScreen = tester.widget<TimerScreen>(find.byType(TimerScreen));
    expect(timerScreen.config.duration, const Duration(minutes: 5));
    await _disposeCurrentTree(tester);
  });

  testWidgets('Home custom duration slider starts at policy minimum', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await _pumpHome(
      tester,
      config: MealTimerConfig.defaults().copyWith(
        childName: '지율',
        duration: const Duration(minutes: 1),
      ),
      entitlement: const PurchaseEntitlement(vehiclePackUnlocked: true),
    );

    final customDurationButton = find.byIcon(Icons.tune_rounded);
    for (var i = 0; i < 4 && customDurationButton.evaluate().isEmpty; i += 1) {
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pump();
    }

    expect(customDurationButton, findsOneWidget);
    await tester.tap(customDurationButton);
    await tester.pumpAndSettle();

    final slider = tester.widget<Slider>(find.byType(Slider));
    expect(slider.min, 5);
    expect(slider.max, 60);
    expect(slider.value, 5);

    await _disposeCurrentTree(tester);
  });

  testWidgets('Home resumes active session with free fallback', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final startedAt = DateTime.utc(2026, 7, 1, 10);
    const store = ActiveMealTimerSessionStore();
    addTearDown(store.clear);
    await store.save(
      ActiveMealTimerSession(
        sessionId: 'active-session',
        startedAt: startedAt,
        config: MealTimerConfig.defaults().copyWith(
          childName: '지율',
          duration: const Duration(minutes: 4),
          vehicleId: 'bus',
        ),
        state: ActiveMealTimerSessionState.running,
      ),
    );

    await _pumpHome(
      tester,
      config: MealTimerConfig.defaults().copyWith(childName: '지율'),
      entitlement: const PurchaseEntitlement.locked(),
      now: () => startedAt.add(const Duration(minutes: 1)),
    );
    await tester.pump();

    await tester.tap(find.text('이어가기'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 400));

    final timerScreen = tester.widget<TimerScreen>(find.byType(TimerScreen));
    expect(timerScreen.restoredSession?.config.vehicleId, 'motorcycle');
    expect(
      timerScreen.restoredSession?.config.duration,
      const Duration(minutes: 5),
    );
    await _disposeCurrentTree(tester);
  });

  testWidgets('Home shows locked vehicles and blocks locked selection', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    MealTimerConfig? changedConfig;

    await _pumpHome(
      tester,
      config: MealTimerConfig.defaults().copyWith(childName: '지율'),
      entitlement: const PurchaseEntitlement.locked(),
      onConfigChanged: (config) => changedConfig = config,
    );

    expect(
      find.byKey(const ValueKey('vehicleChoiceLockBadge.bus')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('vehicleChoiceLockBadge.fire_truck')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('vehicleChoiceLockBadge.motorcycle')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('vehicleChoiceLockBadge.supercar')),
      findsNothing,
    );

    final busChoice = find.byKey(const ValueKey('vehicleChoice.bus'));
    await tester.ensureVisible(busChoice);
    await tester.pump();
    await tester.tap(busChoice);
    await tester.pump();
    expect(changedConfig, isNull);

    final supercarChoice = find.byKey(const ValueKey('vehicleChoice.supercar'));
    await tester.ensureVisible(supercarChoice);
    await tester.pump();
    await tester.tap(supercarChoice);
    await tester.pump();
    expect(changedConfig?.vehicleId, 'supercar');
  });

  testWidgets(
    'Home does not show vehicle locks when vehicle pack is unlocked',
    (tester) async {
      SharedPreferences.setMockInitialValues({});

      await _pumpHome(
        tester,
        config: MealTimerConfig.defaults().copyWith(childName: '지율'),
        entitlement: const PurchaseEntitlement(vehiclePackUnlocked: true),
      );

      expect(
        find.byKey(const ValueKey('vehicleChoiceLockBadge.bus')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('vehicleChoiceLockBadge.fire_truck')),
        findsNothing,
      );
    },
  );

  testWidgets('Home locked vehicle opens guardian gate and purchase sheet', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    MealTimerConfig? changedConfig;
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
    controller.startListening();
    addTearDown(controller.dispose);

    await _pumpHome(
      tester,
      config: MealTimerConfig.defaults().copyWith(childName: '지율'),
      entitlement: const PurchaseEntitlement.locked(),
      purchaseController: controller,
      onConfigChanged: (config) => changedConfig = config,
    );

    final busChoice = find.byKey(const ValueKey('vehicleChoice.bus'));
    await tester.ensureVisible(busChoice);
    await tester.pump();
    await tester.tap(busChoice);
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

    await enterCurrentGuardianGateAnswer(tester);
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('guardianGateContinueButton')));
    await tester.pumpAndSettle();

    expect(find.byType(GuardianGateSheet), findsNothing);
    expect(find.byType(VehiclePackPurchaseSheet), findsOneWidget);
    expect(find.byKey(const ValueKey('vehiclePackBuyButton')), findsOneWidget);

    client.emitPurchases([
      fakePurchaseDetails(status: PurchaseStatus.purchased),
    ]);
    await tester.pumpAndSettle();

    expect(changedConfig?.vehicleId, 'bus');
  });
}

Future<void> _pumpHome(
  WidgetTester tester, {
  required MealTimerConfig config,
  required PurchaseEntitlement entitlement,
  ValueChanged<MealTimerConfig>? onConfigChanged,
  DateTime Function()? now,
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
        home: HomeScreen(
          config: config,
          mealProgressService: LocalMealProgressService(),
          onConfigChanged: onConfigChanged ?? (_) {},
          now: now,
        ),
      ),
    ),
  );
  await tester.pump();
}

void _tapNormalCourse(WidgetTester tester) {
  final normalCourseButton = tester.widget<AppBouncyButton>(
    find.ancestor(
      of: find.textContaining('보통 코스'),
      matching: find.byType(AppBouncyButton),
    ),
  );
  normalCourseButton.onPressed!();
}

Future<void> _disposeCurrentTree(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 5));
}
