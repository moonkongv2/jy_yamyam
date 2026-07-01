import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jy_yamyam/models/active_meal_timer_session.dart';
import 'package:jy_yamyam/models/meal_timer_config.dart';
import 'package:jy_yamyam/models/purchase_entitlement.dart';
import 'package:jy_yamyam/screens/home_screen.dart';
import 'package:jy_yamyam/screens/timer_screen.dart';
import 'package:jy_yamyam/services/active_meal_timer_session_store.dart';
import 'package:jy_yamyam/services/local_meal_progress_service.dart';
import 'package:jy_yamyam/widgets/app/app_bouncy_button.dart';
import 'package:jy_yamyam/widgets/purchases/purchase_entitlement_scope.dart';

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
    await _disposeCurrentTree(tester);
  });
}

Future<void> _pumpHome(
  WidgetTester tester, {
  required MealTimerConfig config,
  required PurchaseEntitlement entitlement,
  ValueChanged<MealTimerConfig>? onConfigChanged,
  DateTime Function()? now,
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
