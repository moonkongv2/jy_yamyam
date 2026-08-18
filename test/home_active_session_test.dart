import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jy_yamyam/l10n/app_texts.dart';
import 'package:jy_yamyam/models/active_meal_timer_session.dart';
import 'package:jy_yamyam/models/meal_progress_snapshot.dart';
import 'package:jy_yamyam/models/meal_timer_config.dart';
import 'package:jy_yamyam/screens/home_screen.dart';
import 'package:jy_yamyam/screens/timer_screen.dart';
import 'package:jy_yamyam/services/active_meal_timer_session_store.dart';
import 'package:jy_yamyam/services/local_meal_progress_service.dart';
import 'package:jy_yamyam/widgets/road_view.dart';

import 'helpers/app_test_harness.dart';

void main() {
  testWidgets('Home screen shows meal timer actions', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await startApp(tester, const Locale('ko'));

    expect(find.byKey(const ValueKey('homeLogo')), findsOneWidget);
    expect(find.text('기본 얼굴 사용 중'), findsOneWidget);
    expect(find.text('만들기'), findsOneWidget);
    expect(find.text('다른 코스'), findsOneWidget);
    expect(find.text('15분 코스'), findsOneWidget);
    expect(find.textContaining('25분 보통 코스'), findsOneWidget);
    expect(find.text('35분 코스'), findsOneWidget);
    expect(find.textContaining('직접 설정'), findsOneWidget);
  });

  testWidgets('Home screen opens a saved active timer session', (tester) async {
    SharedPreferences.setMockInitialValues({});
    addTearDown(() async {
      await const ActiveMealTimerSessionStore().clear();
    });
    final startedAt = DateTime(2026, 6, 10, 8);
    final now = startedAt.add(const Duration(minutes: 10));
    final session = ActiveMealTimerSession(
      sessionId: 'active-session',
      startedAt: startedAt,
      config: MealTimerConfig.defaults().copyWith(
        childName: '지율',
        duration: const Duration(minutes: 35),
        vehicleId: 'bus',
      ),
      state: ActiveMealTimerSessionState.running,
    );
    await const ActiveMealTimerSessionStore().save(session);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: HomeScreen(
          motivationMediaAvailable: true,
          config: MealTimerConfig.defaults().copyWith(childName: '지율'),
          mealProgressService: LocalMealProgressService(),
          onConfigChanged: (_) {},
          now: () => now,
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const ValueKey('activeTimerResumeCard')), findsOneWidget);
    expect(find.text('진행 중인 식사 타이머'), findsOneWidget);

    await tester.tap(find.text('이어가기'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final timerScreen = tester.widget<TimerScreen>(find.byType(TimerScreen));
    expect(timerScreen.restoredSession?.sessionId, 'active-session');
    expect(timerScreen.config.duration, const Duration(minutes: 35));
  });

  testWidgets('Home screen can cancel a saved active timer session', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    addTearDown(() async {
      await const ActiveMealTimerSessionStore().clear();
    });
    final now = DateTime(2026, 6, 10, 8, 10);
    await const ActiveMealTimerSessionStore().save(
      ActiveMealTimerSession(
        sessionId: 'active-session',
        startedAt: DateTime(2026, 6, 10, 8),
        config: MealTimerConfig.defaults().copyWith(childName: '지율'),
        state: ActiveMealTimerSessionState.running,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: HomeScreen(
          motivationMediaAvailable: true,
          config: MealTimerConfig.defaults().copyWith(childName: '지율'),
          mealProgressService: LocalMealProgressService(),
          onConfigChanged: (_) {},
          now: () => now,
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const ValueKey('activeTimerResumeCard')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('activeTimerCancelButton')));
    await tester.pump();

    expect(find.text('진행 중인 타이머를 취소할까요?'), findsOneWidget);

    await tester.tap(find.byType(FilledButton).last);
    await tester.pump();

    expect(await const ActiveMealTimerSessionStore().load(), isNull);
    await tester.pump();
    expect(find.byKey(const ValueKey('activeTimerResumeCard')), findsNothing);
  });

  testWidgets('Home active timer remaining time updates every second', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    addTearDown(() async {
      await const ActiveMealTimerSessionStore().clear();
    });
    var now = DateTime(2026, 6, 10, 8);
    await const ActiveMealTimerSessionStore().save(
      ActiveMealTimerSession(
        sessionId: 'active-session',
        startedAt: now.subtract(Duration(minutes: 24, seconds: 50)),
        config: MealTimerConfig.defaults().copyWith(
          childName: '지율',
          duration: const Duration(minutes: 25),
        ),
        state: ActiveMealTimerSessionState.running,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: HomeScreen(
          motivationMediaAvailable: true,
          config: MealTimerConfig.defaults().copyWith(childName: '지율'),
          mealProgressService: LocalMealProgressService(),
          onConfigChanged: (_) {},
          now: () => now,
        ),
      ),
    );
    await tester.pump();

    final activeTimerCard = find.byKey(const ValueKey('activeTimerResumeCard'));
    String remainingText() {
      return tester
          .widget<Text>(
            find.descendant(
              of: activeTimerCard,
              matching: find.textContaining('남은 시간'),
            ),
          )
          .data!;
    }

    final initialRemainingText = remainingText();
    expect(initialRemainingText, startsWith('남은 시간 00:'));

    now = now.add(const Duration(seconds: 2));
    await tester.pump(const Duration(seconds: 2));

    expect(remainingText(), isNot(initialRemainingText));
  });

  testWidgets('Home active timer remaining time stays fixed when paused', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    addTearDown(() async {
      await const ActiveMealTimerSessionStore().clear();
    });
    var now = DateTime(2026, 6, 10, 8, 20);
    final pausedAt = DateTime(2026, 6, 10, 8, 10);
    await const ActiveMealTimerSessionStore().save(
      ActiveMealTimerSession(
        sessionId: 'paused-session',
        startedAt: DateTime(2026, 6, 10, 8),
        pausedAt: pausedAt,
        config: MealTimerConfig.defaults().copyWith(
          childName: '지율',
          duration: const Duration(minutes: 25),
        ),
        state: ActiveMealTimerSessionState.paused,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: HomeScreen(
          motivationMediaAvailable: true,
          config: MealTimerConfig.defaults().copyWith(childName: '지율'),
          mealProgressService: LocalMealProgressService(),
          onConfigChanged: (_) {},
          now: () => now,
        ),
      ),
    );
    await tester.pump();

    final activeTimerCard = find.byKey(const ValueKey('activeTimerResumeCard'));
    String remainingText() {
      return tester
          .widget<Text>(
            find.descendant(
              of: activeTimerCard,
              matching: find.textContaining('남은 시간'),
            ),
          )
          .data!;
    }

    expect(remainingText(), '남은 시간 15:00');

    now = now.add(const Duration(minutes: 10));
    await tester.pump(const Duration(seconds: 2));

    expect(remainingText(), '남은 시간 15:00');
  });

  testWidgets('Home active timer ticks without reloading progress snapshot', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    addTearDown(() async {
      await const ActiveMealTimerSessionStore().clear();
    });
    var now = DateTime(2026, 6, 10, 8);
    await const ActiveMealTimerSessionStore().save(
      ActiveMealTimerSession(
        sessionId: 'active-session',
        startedAt: now.subtract(const Duration(minutes: 10)),
        config: MealTimerConfig.defaults().copyWith(
          childName: '지율',
          duration: const Duration(minutes: 25),
        ),
        state: ActiveMealTimerSessionState.running,
      ),
    );
    final mealProgressService = _CountingMealProgressService();

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: HomeScreen(
          motivationMediaAvailable: true,
          config: MealTimerConfig.defaults().copyWith(childName: '지율'),
          mealProgressService: mealProgressService,
          onConfigChanged: (_) {},
          now: () => now,
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const ValueKey('activeTimerResumeCard')), findsOneWidget);
    expect(mealProgressService.loadSnapshotCallCount, 1);

    now = now.add(const Duration(seconds: 2));
    await tester.pump(const Duration(seconds: 2));

    expect(find.byKey(const ValueKey('activeTimerResumeCard')), findsOneWidget);
    expect(mealProgressService.loadSnapshotCallCount, 1);
  });

  testWidgets('Home screen shows finished copy for arrived active sessions', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    addTearDown(() async {
      await const ActiveMealTimerSessionStore().clear();
    });
    final now = DateTime(2026, 6, 10, 8);
    await const ActiveMealTimerSessionStore().save(
      ActiveMealTimerSession(
        sessionId: 'active-session',
        startedAt: now.subtract(const Duration(minutes: 30)),
        config: MealTimerConfig.defaults().copyWith(
          childName: '지율',
          duration: const Duration(minutes: 25),
        ),
        state: ActiveMealTimerSessionState.running,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: HomeScreen(
          motivationMediaAvailable: true,
          config: MealTimerConfig.defaults().copyWith(childName: '지율'),
          mealProgressService: LocalMealProgressService(),
          onConfigChanged: (_) {},
          now: () => now,
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const ValueKey('activeTimerResumeCard')), findsOneWidget);
    expect(find.text('식사 시간이 끝났어요'), findsOneWidget);
    expect(find.textContaining('남은 시간'), findsNothing);
  });

  testWidgets('Home screen clears stale active timer sessions', (tester) async {
    SharedPreferences.setMockInitialValues({});
    addTearDown(() async {
      await const ActiveMealTimerSessionStore().clear();
    });
    final now = DateTime(2026, 6, 10, 8);
    await const ActiveMealTimerSessionStore().save(
      ActiveMealTimerSession(
        sessionId: 'stale-session',
        startedAt: now.subtract(const Duration(hours: 25)),
        config: MealTimerConfig.defaults().copyWith(childName: '지율'),
        state: ActiveMealTimerSessionState.running,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: HomeScreen(
          motivationMediaAvailable: true,
          config: MealTimerConfig.defaults().copyWith(childName: '지율'),
          mealProgressService: LocalMealProgressService(),
          onConfigChanged: (_) {},
          now: () => now,
        ),
      ),
    );
    await tester.pump();

    expect(await const ActiveMealTimerSessionStore().load(), isNull);
    expect(find.byKey(const ValueKey('activeTimerResumeCard')), findsNothing);
  });

  testWidgets('Home screen resumes finished active sessions at the finish', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    addTearDown(() async {
      await const ActiveMealTimerSessionStore().clear();
    });
    final now = DateTime(2026, 6, 10, 8);
    await const ActiveMealTimerSessionStore().save(
      ActiveMealTimerSession(
        sessionId: 'finished-session',
        startedAt: now.subtract(const Duration(minutes: 30)),
        config: MealTimerConfig.defaults().copyWith(
          childName: '지율',
          duration: const Duration(minutes: 25),
        ),
        state: ActiveMealTimerSessionState.running,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: HomeScreen(
          motivationMediaAvailable: true,
          config: MealTimerConfig.defaults().copyWith(childName: '지율'),
          mealProgressService: LocalMealProgressService(),
          onConfigChanged: (_) {},
          now: () => now,
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('이어가기'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(tester.widget<RoadView>(find.byType(RoadView)).progress, 1);
  });

  testWidgets('Starting a new timer with an active session asks first', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    addTearDown(() async {
      await const ActiveMealTimerSessionStore().clear();
    });
    final now = DateTime(2026, 6, 10, 8, 10);
    await const ActiveMealTimerSessionStore().save(
      ActiveMealTimerSession(
        sessionId: 'active-session',
        startedAt: DateTime(2026, 6, 10, 8),
        config: MealTimerConfig.defaults().copyWith(
          childName: '지율',
          duration: const Duration(minutes: 35),
        ),
        state: ActiveMealTimerSessionState.running,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: HomeScreen(
          motivationMediaAvailable: true,
          config: MealTimerConfig.defaults().copyWith(
            childName: '지율',
            courseIngredientMode: CourseIngredientMode.off,
          ),
          mealProgressService: LocalMealProgressService(),
          onConfigChanged: (_) {},
          now: () => now,
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.textContaining('25분 보통 코스'));
    await tester.pump();

    expect(find.text('진행 중인 타이머가 있어요'), findsOneWidget);
    expect(
      tester.widget<AlertDialog>(find.byType(AlertDialog)).actions,
      hasLength(2),
    );
    expect(find.byType(TimerScreen), findsNothing);

    await tester.tap(find.text('새로 시작'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final timerScreen = tester.widget<TimerScreen>(find.byType(TimerScreen));
    expect(timerScreen.restoredSession, isNull);
    expect(timerScreen.config.duration, const Duration(minutes: 25));
  });
}

class _CountingMealProgressService extends LocalMealProgressService {
  var loadSnapshotCallCount = 0;

  @override
  Future<MealProgressSnapshot> loadSnapshot() {
    loadSnapshotCallCount += 1;
    return super.loadSnapshot();
  }
}
