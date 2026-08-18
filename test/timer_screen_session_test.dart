import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jy_yamyam/l10n/app_texts.dart';
import 'package:jy_yamyam/models/active_meal_timer_session.dart';
import 'package:jy_yamyam/models/meal_timer_config.dart';
import 'package:jy_yamyam/screens/timer_screen.dart';
import 'package:jy_yamyam/services/active_meal_timer_session_store.dart';
import 'package:jy_yamyam/services/local_meal_progress_service.dart';
import 'package:jy_yamyam/widgets/road_view.dart';
import 'package:jy_yamyam/widgets/timer_control_bar.dart';

import 'helpers/timer_screen_test_harness.dart';

void main() {
  testWidgets('TimerScreen saves an active session when started', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final startedAt = DateTime(2026, 6, 10, 8);
    final store = ActiveMealTimerSessionStore();

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: TimerScreen(
          motivationMediaAvailable: true,
          config: MealTimerConfig.defaults().copyWith(
            duration: const Duration(minutes: 35),
            childName: '지율',
            vehicleId: 'bus',
          ),
          mealProgressService: LocalMealProgressService(),
          now: () => startedAt,
          onConfigChanged: (_) {},
        ),
      ),
    );
    await tester.pump();

    expect(await store.load(), isNull);
    await finishCoursePreview(tester);

    final session = await store.load();
    expect(session, isNotNull);
    expect(session!.startedAt, startedAt);
    expect(session.duration, const Duration(minutes: 35));
    expect(session.config.childName, '지율');
    expect(session.config.vehicleId, 'bus');
    expect(session.state, ActiveMealTimerSessionState.running);
    expect(session.totalPausedDuration, Duration.zero);
    expect(session.pausedAt, isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('TimerScreen updates active session when paused and resumed', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    var now = DateTime(2026, 6, 10, 8);
    final store = ActiveMealTimerSessionStore();

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: TimerScreen(
          motivationMediaAvailable: true,
          config: MealTimerConfig.defaults().copyWith(
            duration: const Duration(minutes: 35),
          ),
          mealProgressService: LocalMealProgressService(),
          now: () => now,
          onConfigChanged: (_) {},
        ),
      ),
    );
    await tester.pump();
    await finishCoursePreview(tester);

    now = now.add(const Duration(minutes: 5));
    await tester.pump(const Duration(milliseconds: 250));
    tester
        .widget<TimerControlBar>(find.byType(TimerControlBar))
        .onPauseResume!();
    await tester.pump();

    final pausedSession = await store.load();
    expect(pausedSession, isNotNull);
    expect(pausedSession!.state, ActiveMealTimerSessionState.paused);
    expect(pausedSession.pausedAt, now);
    expect(pausedSession.totalPausedDuration, Duration.zero);

    now = now.add(const Duration(minutes: 3));
    tester
        .widget<TimerControlBar>(find.byType(TimerControlBar))
        .onPauseResume!();
    await tester.pump();

    final resumedSession = await store.load();
    expect(resumedSession, isNotNull);
    expect(resumedSession!.state, ActiveMealTimerSessionState.running);
    expect(resumedSession.pausedAt, isNull);
    expect(resumedSession.totalPausedDuration, const Duration(minutes: 3));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('TimerScreen clears active session after completion', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final store = ActiveMealTimerSessionStore();

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: TimerScreen(
          motivationMediaAvailable: true,
          config: MealTimerConfig.defaults().copyWith(
            duration: const Duration(minutes: 10),
          ),
          mealProgressService: LocalMealProgressService(),
          onConfigChanged: (_) {},
        ),
      ),
    );
    await tester.pump();
    await finishCoursePreview(tester);
    expect(await store.load(), isNotNull);

    tester.widget<TimerControlBar>(find.byType(TimerControlBar)).onComplete!();
    await tester.pump();
    await tester.tap(find.byType(FilledButton).last);
    await tester.pump();

    expect(await store.load(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('TimerScreen restores progress from an active session', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    addTearDown(() async {
      await const ActiveMealTimerSessionStore().clear();
    });
    final startedAt = DateTime(2026, 6, 10, 8);
    final now = startedAt.add(const Duration(minutes: 20));
    final session = ActiveMealTimerSession(
      sessionId: 'active-session',
      startedAt: startedAt,
      config: MealTimerConfig.defaults().copyWith(
        duration: const Duration(minutes: 60),
        vehicleId: 'bus',
      ),
      state: ActiveMealTimerSessionState.running,
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: TimerScreen(
          motivationMediaAvailable: true,
          config: MealTimerConfig.defaults(),
          restoredSession: session,
          mealProgressService: LocalMealProgressService(),
          now: () => now,
          onConfigChanged: (_) {},
        ),
      ),
    );
    await tester.pump();

    final roadView = tester.widget<RoadView>(find.byType(RoadView));
    expect(roadView.courseDuration, const Duration(minutes: 60));
    expect(roadView.vehicle.id, 'bus');
    expect(roadView.progress, closeTo(1 / 3, 0.01));
    expect(
      tester.widget<TimerScreen>(find.byType(TimerScreen)).restoredSession,
      session,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('TimerScreen shows course overview for long running timers', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(600, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    SharedPreferences.setMockInitialValues({});
    final startedAt = DateTime(2026, 6, 10, 8);
    final now = startedAt.add(const Duration(minutes: 10));
    final session = ActiveMealTimerSession(
      sessionId: 'course-overview-session',
      startedAt: startedAt,
      config: MealTimerConfig.defaults().copyWith(
        duration: const Duration(minutes: 30),
      ),
      state: ActiveMealTimerSessionState.running,
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: TimerScreen(
          motivationMediaAvailable: true,
          config: MealTimerConfig.defaults(),
          restoredSession: session,
          mealProgressService: LocalMealProgressService(),
          now: () => now,
          onConfigChanged: (_) {},
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const ValueKey('courseOverviewButton')), findsOneWidget);

    final button = tester.widget<IconButton>(
      find.byKey(const ValueKey('courseOverviewButton')),
    );
    expect(button.onPressed, isNotNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('TimerScreen hides course overview for five minute timers', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(600, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    SharedPreferences.setMockInitialValues({});
    final startedAt = DateTime(2026, 6, 10, 8);
    final now = startedAt.add(const Duration(minutes: 1));
    final session = ActiveMealTimerSession(
      sessionId: 'short-course-session',
      startedAt: startedAt,
      config: MealTimerConfig.defaults().copyWith(
        duration: const Duration(minutes: 5),
      ),
      state: ActiveMealTimerSessionState.running,
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: TimerScreen(
          motivationMediaAvailable: true,
          config: MealTimerConfig.defaults(),
          restoredSession: session,
          mealProgressService: LocalMealProgressService(),
          now: () => now,
          onConfigChanged: (_) {},
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const ValueKey('courseOverviewButton')), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('TimerScreen course overview moves camera but not vehicle', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(600, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    SharedPreferences.setMockInitialValues({});
    final startedAt = DateTime(2026, 6, 10, 8);
    final now = startedAt.add(const Duration(minutes: 10));
    final session = ActiveMealTimerSession(
      sessionId: 'course-overview-camera-session',
      startedAt: startedAt,
      config: MealTimerConfig.defaults().copyWith(
        duration: const Duration(minutes: 30),
      ),
      state: ActiveMealTimerSessionState.running,
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: TimerScreen(
          motivationMediaAvailable: true,
          config: MealTimerConfig.defaults(),
          restoredSession: session,
          mealProgressService: LocalMealProgressService(),
          now: () => now,
          onConfigChanged: (_) {},
        ),
      ),
    );
    await tester.pump();

    var roadView = tester.widget<RoadView>(find.byType(RoadView));
    expect(roadView.cameraProgress, closeTo(1 / 3, 0.01));
    expect(roadView.vehicleProgress, closeTo(1 / 3, 0.01));

    tester
        .widget<IconButton>(find.byKey(const ValueKey('courseOverviewButton')))
        .onPressed!();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));

    roadView = tester.widget<RoadView>(find.byType(RoadView));
    expect(roadView.cameraProgress, greaterThan(roadView.vehicleProgress));
    expect(roadView.vehicleProgress, closeTo(1 / 3, 0.01));

    tester
        .widget<TimerControlBar>(find.byType(TimerControlBar))
        .onPauseResume!();
    await tester.pump();

    roadView = tester.widget<RoadView>(find.byType(RoadView));
    expect(roadView.cameraProgress, closeTo(roadView.vehicleProgress, 0.01));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('TimerScreen resumes ticking from a restored paused session', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    addTearDown(() async {
      await const ActiveMealTimerSessionStore().clear();
    });
    var now = DateTime(2026, 6, 10, 8, 30);
    final session = ActiveMealTimerSession(
      sessionId: 'paused-session',
      startedAt: DateTime(2026, 6, 10, 8),
      config: MealTimerConfig.defaults().copyWith(
        duration: const Duration(minutes: 30),
      ),
      state: ActiveMealTimerSessionState.paused,
      pausedAt: DateTime(2026, 6, 10, 8, 10),
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: TimerScreen(
          motivationMediaAvailable: true,
          config: MealTimerConfig.defaults(),
          restoredSession: session,
          mealProgressService: LocalMealProgressService(),
          now: () => now,
          onConfigChanged: (_) {},
        ),
      ),
    );
    await tester.pump();

    expect(
      tester.widget<RoadView>(find.byType(RoadView)).progress,
      closeTo(1 / 3, 0.01),
    );

    tester
        .widget<TimerControlBar>(find.byType(TimerControlBar))
        .onPauseResume!();
    await tester.pump();

    now = now.add(const Duration(minutes: 2));
    await tester.pump(const Duration(milliseconds: 40));

    expect(
      tester.widget<RoadView>(find.byType(RoadView)).progress,
      closeTo(0.4, 0.01),
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('TimerScreen refreshes elapsed time when app resumes', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    addTearDown(() async {
      await const ActiveMealTimerSessionStore().clear();
    });
    var now = DateTime(2026, 6, 10, 8);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: TimerScreen(
          motivationMediaAvailable: true,
          config: MealTimerConfig.defaults().copyWith(
            duration: const Duration(minutes: 25),
          ),
          mealProgressService: LocalMealProgressService(),
          now: () => now,
          onConfigChanged: (_) {},
        ),
      ),
    );
    await tester.pump();
    await finishCoursePreview(tester);

    expect(tester.widget<RoadView>(find.byType(RoadView)).progress, 0);

    now = now.add(const Duration(minutes: 10));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    expect(
      tester.widget<RoadView>(find.byType(RoadView)).progress,
      closeTo(0.4, 0.01),
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
