import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jy_yamyam/catalogs/meal_ingredient_catalog.dart';
import 'package:jy_yamyam/l10n/app_texts.dart';
import 'package:jy_yamyam/models/active_meal_timer_session.dart';
import 'package:jy_yamyam/models/meal_completion_status.dart';
import 'package:jy_yamyam/models/meal_session_result.dart';
import 'package:jy_yamyam/models/meal_timer_config.dart';
import 'package:jy_yamyam/models/reward_goal.dart';
import 'package:jy_yamyam/models/reward_item.dart';
import 'package:jy_yamyam/screens/home_screen.dart';
import 'package:jy_yamyam/screens/meal_history_screen.dart';
import 'package:jy_yamyam/screens/reward_goal_screen.dart';
import 'package:jy_yamyam/screens/result_screen.dart';
import 'package:jy_yamyam/screens/sticker_collection_screen.dart';
import 'package:jy_yamyam/screens/timer_screen.dart';
import 'package:jy_yamyam/services/active_meal_timer_session_store.dart';
import 'package:jy_yamyam/services/local_meal_progress_service.dart';
import 'package:jy_yamyam/services/motivation_audio_service.dart';
import 'package:jy_yamyam/services/orientation_service.dart';
import 'package:jy_yamyam/services/screen_awake_service.dart';
import 'package:jy_yamyam/services/timer_audio_service.dart';
import 'package:jy_yamyam/theme/app_theme.dart';
import 'package:jy_yamyam/widgets/goal_star_pulse.dart';
import 'package:jy_yamyam/widgets/road_painter.dart';
import 'package:jy_yamyam/widgets/road_view.dart';
import 'package:jy_yamyam/widgets/reward_sticker_image.dart';
import 'package:jy_yamyam/widgets/result_sticker_album_sheet.dart';
import 'package:jy_yamyam/widgets/timer_control_bar.dart';
import 'package:jy_yamyam/widgets/vehicle_widget.dart';

import 'helpers/meal_result_fixture.dart';
import 'helpers/test_image_fixture.dart';

void main() {
  test('Arrival dialog copy uses the selected vehicle label', () {
    final timerTexts = AppTexts.ko.timer;

    expect(timerTexts.arrivalDialogMessage('경찰차'), '경찰차가 지나갔어. 식사를 마무리했어?');
    expect(timerTexts.arrivalDialogMessage('포크레인'), '포크레인이 지나갔어. 식사를 마무리했어?');
  });

  test('Timer arrival dialog copy uses the configured vehicle', () {
    expect(
      timerArrivalDialogMessage(
        texts: AppTexts.ko.timer,
        vehicleId: 'excavator',
        languageCode: 'ko',
      ),
      '포크레인이 지나갔어. 식사를 마무리했어?',
    );
    expect(
      timerArrivalDialogMessage(
        texts: AppTexts.en.timer,
        vehicleId: 'police_car',
        languageCode: 'en',
      ),
      'Time is up. Did you finish your meal?',
    );
  });

  testWidgets('Timer screen does not apply avatar saved for another vehicle', (
    tester,
  ) async {
    final avatarFile = createTemporaryAvatarImage();

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: TimerScreen(
          motivationMediaAvailable: true,
          config: MealTimerConfig.defaults().copyWith(
            vehicleId: 'excavator',
            avatarMode: AvatarImageMode.custom,
            customAvatarImagePath: avatarFile.path,
            customAvatarVehicleId: 'police_car',
          ),
          mealProgressService: LocalMealProgressService(),
          onConfigChanged: (_) {},
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(RoadView), findsOneWidget);
    expect(
      tester.widget<RoadView>(find.byType(RoadView)).avatar.mode,
      AvatarImageMode.defaultImage,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('Timer screen applies avatar config for selected vehicle', (
    tester,
  ) async {
    final avatarFile = createTemporaryAvatarImage();

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: TimerScreen(
          motivationMediaAvailable: true,
          config: MealTimerConfig.defaults().copyWith(
            vehicleId: 'fire_truck',
            avatarMode: AvatarImageMode.custom,
            customAvatarsByVehicle: {
              'fire_truck': VehicleAvatarConfig(
                imagePath: avatarFile.path,
                scale: 1.4,
                offsetX: 0.11,
                offsetY: -0.07,
                rotationDegrees: 9.0,
              ),
            },
          ),
          mealProgressService: LocalMealProgressService(),
          onConfigChanged: (_) {},
        ),
      ),
    );
    await tester.pump();

    final roadView = tester.widget<RoadView>(find.byType(RoadView));
    expect(roadView.avatar.mode, AvatarImageMode.custom);
    expect(roadView.avatar.imagePath, avatarFile.path);
    expect(roadView.avatar.scale, 1.4);
    expect(roadView.avatar.offsetX, 0.11);
    expect(roadView.avatar.offsetY, -0.07);
    expect(roadView.avatar.rotationDegrees, 9.0);
  });

  testWidgets('TimerScreen passes course ingredient ids to road ingredients', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: TimerScreen(
          motivationMediaAvailable: true,
          config: MealTimerConfig.defaults().copyWith(
            courseIngredientIds: const ['carrot', 'egg'],
          ),
          mealProgressService: LocalMealProgressService(),
          onConfigChanged: (_) {},
        ),
      ),
    );
    await tester.pump();

    final roadView = tester.widget<RoadView>(find.byType(RoadView));
    expect(
      roadView.ingredients,
      hasLength(
        MealIngredientCatalog.courseSlotCountForDuration(
          MealTimerConfig.defaults().duration,
        ),
      ),
    );
    expect(roadView.ingredients.map((ingredient) => ingredient.id).toSet(), {
      'carrot',
      'egg',
    });
    expect(tester.takeException(), isNull);
  });

  testWidgets('TimerScreen hides road ingredients when course mode is off', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: TimerScreen(
          motivationMediaAvailable: true,
          config: MealTimerConfig.defaults().copyWith(
            courseIngredientMode: CourseIngredientMode.off,
            courseIngredientIds: const [],
          ),
          mealProgressService: LocalMealProgressService(),
          onConfigChanged: (_) {},
        ),
      ),
    );
    await tester.pump();

    final roadView = tester.widget<RoadView>(find.byType(RoadView));
    expect(roadView.ingredients, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('TimerScreen passes configured duration to the road course', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: TimerScreen(
          motivationMediaAvailable: true,
          config: MealTimerConfig.defaults().copyWith(
            duration: const Duration(minutes: 60),
          ),
          mealProgressService: LocalMealProgressService(),
          onConfigChanged: (_) {},
        ),
      ),
    );
    await tester.pump();

    final roadView = tester.widget<RoadView>(find.byType(RoadView));
    expect(roadView.courseDuration, const Duration(minutes: 60));
    expect(tester.takeException(), isNull);
  });

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
    await _finishCoursePreview(tester);

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
    await _finishCoursePreview(tester);

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
    await _finishCoursePreview(tester);
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
    await _finishCoursePreview(tester);

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

  testWidgets('Meal done before arrival does not immediately push result', (
    tester,
  ) async {
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
    await _finishCoursePreview(tester);

    tester.widget<TimerControlBar>(find.byType(TimerControlBar)).onComplete!();
    await tester.pump();
    await tester.tap(find.byType(FilledButton).last);
    await tester.pump();

    expect(find.byType(TimerScreen), findsOneWidget);
    expect(find.byType(ResultScreen), findsNothing);
    expect(
      tester.widget<TimerControlBar>(find.byType(TimerControlBar)).onComplete,
      isNull,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('Fast finish drive animates display progress to finish', (
    tester,
  ) async {
    var now = DateTime(2026);
    final timerAudioService = _FakeTimerAudioService();

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: TimerScreen(
          motivationMediaAvailable: true,
          config: MealTimerConfig.defaults().copyWith(
            duration: const Duration(seconds: 100),
          ),
          mealProgressService: LocalMealProgressService(),
          now: () => now,
          timerAudioService: timerAudioService,
          onConfigChanged: (_) {},
        ),
      ),
    );
    await tester.pump();
    await _finishCoursePreview(tester);
    now = now.add(const Duration(seconds: 150));
    await tester.pump(const Duration(milliseconds: 250));

    tester.widget<TimerControlBar>(find.byType(TimerControlBar)).onComplete!();
    await tester.pump();
    await tester.tap(find.byType(FilledButton).last);
    await tester.pump();

    final driveDuration = finishDriveDurationForProgress(0.5);
    await tester.pump(driveDuration - const Duration(milliseconds: 1));

    expect(find.byType(ResultScreen), findsNothing);
    expect(
      tester.widget<RoadView>(find.byType(RoadView)).progress,
      greaterThan(0.99),
    );

    await tester.pump(const Duration(milliseconds: 3));
    await tester.pump();

    expect(find.byType(ResultScreen), findsNothing);
    expect(tester.widget<RoadView>(find.byType(RoadView)).progress, 1);

    await tester.pump(const Duration(milliseconds: 999));

    expect(find.byType(ResultScreen), findsNothing);

    await tester.pump(const Duration(milliseconds: 2));
    await tester.pump();

    expect(find.byType(ResultScreen), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('Fast finish drive plays short SFX for medium finish duration', (
    tester,
  ) async {
    var now = DateTime(2026);
    final timerAudioService = _FakeTimerAudioService();

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: TimerScreen(
          motivationMediaAvailable: true,
          config: MealTimerConfig.defaults().copyWith(
            duration: const Duration(minutes: 5),
          ),
          mealProgressService: LocalMealProgressService(),
          now: () => now,
          timerAudioService: timerAudioService,
          onConfigChanged: (_) {},
        ),
      ),
    );
    await tester.pump();
    await _finishCoursePreview(tester);
    now = now.add(const Duration(minutes: 2, seconds: 30));
    await tester.pump(const Duration(milliseconds: 250));

    tester.widget<TimerControlBar>(find.byType(TimerControlBar)).onComplete!();
    await tester.pump();
    await tester.tap(find.byType(FilledButton).last);
    await tester.pump();
    await tester.pump();

    expect(timerAudioService.playFinishDriveShortSfxCount, 1);
    expect(timerAudioService.playFinishDriveLongSfxCount, 0);
    expect(timerAudioService.playFinishArrivalSfxCount, 0);

    final driveDuration = finishDriveDurationForProgress(0.5);
    await tester.pump(driveDuration + const Duration(milliseconds: 2));
    await tester.pump();

    expect(timerAudioService.stopFinishDriveSfxCount, 1);
    expect(timerAudioService.playFinishArrivalSfxCount, 1);
    expect(find.byType(ResultScreen), findsNothing);

    await tester.pump(const Duration(milliseconds: 1001));
    await tester.pump();

    expect(find.byType(ResultScreen), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('Fast finish drive chooses long SFX and skips near-finish SFX', (
    tester,
  ) async {
    final longAudioService = _FakeTimerAudioService();
    await _pumpCompletedBeforeArrivalTimer(
      tester,
      elapsed: Duration.zero,
      timerAudioService: longAudioService,
    );

    expect(longAudioService.playFinishDriveShortSfxCount, 0);
    expect(longAudioService.playFinishDriveLongSfxCount, 1);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();

    final nearFinishAudioService = _FakeTimerAudioService();
    await _pumpCompletedBeforeArrivalTimer(
      tester,
      elapsed: const Duration(minutes: 4, seconds: 30),
      timerAudioService: nearFinishAudioService,
    );

    expect(nearFinishAudioService.playFinishDriveShortSfxCount, 0);
    expect(nearFinishAudioService.playFinishDriveLongSfxCount, 0);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('Fast finish drive sound disabled skips finish SFX', (
    tester,
  ) async {
    final timerAudioService = _FakeTimerAudioService();
    await _pumpCompletedBeforeArrivalTimer(
      tester,
      elapsed: Duration.zero,
      timerAudioService: timerAudioService,
      soundEnabled: false,
    );

    final driveDuration = finishDriveDurationForProgress(0);
    await tester.pump(driveDuration + const Duration(milliseconds: 2));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1001));
    await tester.pump();

    expect(timerAudioService.playFinishDriveShortSfxCount, 0);
    expect(timerAudioService.playFinishDriveLongSfxCount, 0);
    expect(timerAudioService.playFinishArrivalSfxCount, 0);
    expect(find.byType(ResultScreen), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('Controls are disabled during fast finish drive', (tester) async {
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
    await _finishCoursePreview(tester);

    tester.widget<TimerControlBar>(find.byType(TimerControlBar)).onComplete!();
    await tester.pump();
    await tester.tap(find.byType(FilledButton).last);
    await tester.pump();

    final controls = tester.widget<TimerControlBar>(
      find.byType(TimerControlBar),
    );
    expect(controls.onPauseResume, isNull);
    expect(controls.onComplete, isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('Completing after arrival opens result without fast finish', (
    tester,
  ) async {
    var now = DateTime(2026);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: TimerScreen(
          motivationMediaAvailable: true,
          config: MealTimerConfig.defaults().copyWith(
            duration: const Duration(minutes: 5),
          ),
          mealProgressService: LocalMealProgressService(),
          now: () => now,
          onConfigChanged: (_) {},
        ),
      ),
    );
    await tester.pump();
    await _finishCoursePreview(tester);
    now = now.add(const Duration(minutes: 6));
    await tester.pump(const Duration(milliseconds: 250));

    tester.widget<TimerControlBar>(find.byType(TimerControlBar)).onComplete!();
    await tester.pump();
    await tester.tap(find.byType(FilledButton).last);
    await tester.pump();
    await tester.pump();

    expect(find.byType(ResultScreen), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('Timer records directly selected ingredients on completion', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    var now = DateTime(2026);
    final service = LocalMealProgressService();

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: TimerScreen(
          motivationMediaAvailable: true,
          config: MealTimerConfig.defaults().copyWith(
            duration: const Duration(minutes: 5),
            courseIngredientMode: CourseIngredientMode.manual,
            courseIngredientIds: const ['carrot', 'egg'],
            selectedCourseIngredientIds: const ['carrot', 'egg'],
          ),
          mealProgressService: service,
          now: () => now,
          onConfigChanged: (_) {},
        ),
      ),
    );
    await tester.pump();
    await _finishCoursePreview(tester);
    now = now.add(const Duration(minutes: 6));
    await tester.pump(const Duration(milliseconds: 250));

    tester.widget<TimerControlBar>(find.byType(TimerControlBar)).onComplete!();
    await tester.pump();
    await tester.tap(find.byType(FilledButton).last);
    await tester.pump();
    await tester.pump();

    final snapshot = await service.loadSnapshot();
    expect(snapshot.history.single.selectedIngredientIds, ['carrot', 'egg']);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('Timer awards sticker for the configured vehicle on completion', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    var now = DateTime(2026);
    final service = LocalMealProgressService();

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: TimerScreen(
          motivationMediaAvailable: true,
          config: MealTimerConfig.defaults().copyWith(
            duration: const Duration(minutes: 5),
            vehicleId: 'bus',
          ),
          mealProgressService: service,
          now: () => now,
          onConfigChanged: (_) {},
        ),
      ),
    );
    await tester.pump();
    await _finishCoursePreview(tester);
    now = now.add(const Duration(minutes: 6));
    await tester.pump(const Duration(milliseconds: 250));

    tester.widget<TimerControlBar>(find.byType(TimerControlBar)).onComplete!();
    await tester.pump();
    await tester.tap(find.byType(FilledButton).last);
    await tester.pump();
    await tester.pump();

    final snapshot = await service.loadSnapshot();
    expect(snapshot.history.single.rewardIds, ['sticker_vehicle_bus']);
    expect(snapshot.inventory.single.rewardId, 'sticker_vehicle_bus');

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('Timer hands orientation control to result screen', (
    tester,
  ) async {
    var now = DateTime(2026);
    final orientationService = _FakeOrientationService();

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: TimerScreen(
          motivationMediaAvailable: true,
          config: MealTimerConfig.defaults().copyWith(
            duration: const Duration(minutes: 5),
          ),
          mealProgressService: LocalMealProgressService(),
          now: () => now,
          onConfigChanged: (_) {},
          orientationService: orientationService,
        ),
      ),
    );
    await tester.pump();
    await _finishCoursePreview(tester);
    now = now.add(const Duration(minutes: 6));
    await tester.pump(const Duration(milliseconds: 250));

    tester.widget<TimerControlBar>(find.byType(TimerControlBar)).onComplete!();
    await tester.pump();
    await tester.tap(find.byType(FilledButton).last);
    await tester.pump();
    await tester.pump();

    expect(find.byType(ResultScreen), findsOneWidget);
    expect(orientationService.calls, [
      'allowMealFlowOrientations',
      'allowMealFlowOrientations',
    ]);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();

    expect(orientationService.calls, [
      'allowMealFlowOrientations',
      'allowMealFlowOrientations',
      'lockPortrait',
    ]);
  });

  testWidgets('Timer screen plays motivation voice after video starts', (
    tester,
  ) async {
    final motivationAudioService = _FakeMotivationAudioService();
    var now = DateTime(2026);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: TimerScreen(
          motivationMediaAvailable: true,
          config: MealTimerConfig.defaults().copyWith(
            duration: const Duration(minutes: 5),
            soundEnabled: true,
          ),
          mealProgressService: LocalMealProgressService(),
          motivationAudioService: motivationAudioService,
          now: () => now,
          onConfigChanged: (_) {},
        ),
      ),
    );
    await tester.pump();
    await _finishCoursePreview(tester);
    now = now.add(const Duration(seconds: 30));
    await tester.pump(const Duration(milliseconds: 250));

    expect(
      find.byKey(const ValueKey('motivationVideoBubble_10')),
      findsOneWidget,
    );
    expect(motivationAudioService.playedAssets, isEmpty);

    await tester.pump(motivationVoiceStartDelay);

    expect(motivationAudioService.playedAssets, hasLength(1));
    expect(
      motivationAudioService.playedAssets.single,
      startsWith('assets/audio/motivation/ko_'),
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets(
    'Timer screen uses three-minute motivation cadence for long timer',
    (tester) async {
      var now = DateTime(2026);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          supportedLocales: AppTexts.supportedLocales,
          locale: const Locale('ko'),
          home: TimerScreen(
            motivationMediaAvailable: true,
            config: MealTimerConfig.defaults().copyWith(
              duration: const Duration(minutes: 60),
              soundEnabled: false,
            ),
            mealProgressService: LocalMealProgressService(),
            now: () => now,
            onConfigChanged: (_) {},
          ),
        ),
      );
      await tester.pump();
      await _finishCoursePreview(tester);

      now = now.add(const Duration(minutes: 2, seconds: 59));
      await tester.pump(const Duration(milliseconds: 250));

      expect(
        find.byKey(const ValueKey('motivationVideoBubble_3')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('motivationVideoBubble_10')),
        findsNothing,
      );

      now = now.add(const Duration(seconds: 1));
      await tester.pump(const Duration(milliseconds: 250));

      expect(
        find.byKey(const ValueKey('motivationVideoBubble_3')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('motivationVideoBubble_10')),
        findsNothing,
      );

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    },
  );

  testWidgets(
    'Timer screen custom motivation interval ignores percent milestones',
    (tester) async {
      var now = DateTime(2026);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          supportedLocales: AppTexts.supportedLocales,
          locale: const Locale('ko'),
          home: TimerScreen(
            motivationMediaAvailable: true,
            config: MealTimerConfig.defaults().copyWith(
              duration: const Duration(minutes: 15),
              soundEnabled: false,
              motivationVideoUseCustomInterval: true,
              motivationVideoInterval: const Duration(minutes: 5),
            ),
            mealProgressService: LocalMealProgressService(),
            now: () => now,
            onConfigChanged: (_) {},
          ),
        ),
      );
      await tester.pump();
      await _finishCoursePreview(tester);

      now = now.add(const Duration(minutes: 2));
      await tester.pump(const Duration(milliseconds: 250));

      expect(
        find.byKey(const ValueKey('motivationVideoBubble_10')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('motivationVideoBubble_5')),
        findsNothing,
      );

      now = now.add(const Duration(minutes: 3));
      await tester.pump(const Duration(milliseconds: 250));

      expect(
        find.byKey(const ValueKey('motivationVideoBubble_5')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('motivationVideoBubble_10')),
        findsNothing,
      );

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    },
  );

  testWidgets('Timer screen closes active motivation video when disabled', (
    tester,
  ) async {
    MealTimerConfig? changedConfig;
    var now = DateTime(2026);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: TimerScreen(
          motivationMediaAvailable: true,
          config: MealTimerConfig.defaults().copyWith(
            duration: const Duration(minutes: 60),
            soundEnabled: false,
          ),
          mealProgressService: LocalMealProgressService(),
          now: () => now,
          onConfigChanged: (config) => changedConfig = config,
        ),
      ),
    );
    await tester.pump();
    await _finishCoursePreview(tester);

    now = now.add(const Duration(minutes: 3));
    await tester.pump(const Duration(milliseconds: 250));

    expect(
      find.byKey(const ValueKey('motivationVideoBubble_3')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('motivationSettingsButton')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(
      find.byKey(const ValueKey('timerMotivationVideoHelpButton')),
      findsOneWidget,
    );
    expect(find.textContaining('보상'), findsOneWidget);

    tester
        .widget<SwitchListTile>(
          find.byKey(const ValueKey('motivationVideoEnabledSwitch')),
        )
        .onChanged!(false);
    await tester.pump();
    await tester.tap(
      find.byKey(const ValueKey('motivationSettingsApplyButton')),
    );
    await tester.pump();

    expect(find.byKey(const ValueKey('motivationVideoBubble_3')), findsNothing);
    expect(changedConfig?.motivationVideoEnabled, isFalse);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets(
    'Timer motivation settings dismiss keeps pending changes unapplied',
    (tester) async {
      MealTimerConfig? changedConfig;
      var now = DateTime(2026);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          supportedLocales: AppTexts.supportedLocales,
          locale: const Locale('ko'),
          home: TimerScreen(
            motivationMediaAvailable: true,
            config: MealTimerConfig.defaults().copyWith(
              duration: const Duration(minutes: 60),
              soundEnabled: false,
            ),
            mealProgressService: LocalMealProgressService(),
            now: () => now,
            onConfigChanged: (config) => changedConfig = config,
          ),
        ),
      );
      await tester.pump();
      await _finishCoursePreview(tester);

      now = now.add(const Duration(minutes: 3));
      await tester.pump(const Duration(milliseconds: 250));

      expect(
        find.byKey(const ValueKey('motivationVideoBubble_3')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const ValueKey('motivationSettingsButton')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      tester
          .widget<SwitchListTile>(
            find.byKey(const ValueKey('motivationVideoEnabledSwitch')),
          )
          .onChanged!(false);
      await tester.pump();
      tester
          .widget<TextButton>(
            find.byKey(const ValueKey('motivationSettingsCancelButton')),
          )
          .onPressed!();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(changedConfig, isNull);
      expect(
        find.byKey(const ValueKey('motivationVideoEnabledSwitch')),
        findsNothing,
      );

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    },
  );

  testWidgets(
    'Timer screen restarts custom motivation interval from change time',
    (tester) async {
      var now = DateTime(2026);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          supportedLocales: AppTexts.supportedLocales,
          locale: const Locale('ko'),
          home: TimerScreen(
            motivationMediaAvailable: true,
            config: MealTimerConfig.defaults().copyWith(
              duration: const Duration(minutes: 60),
              soundEnabled: false,
            ),
            mealProgressService: LocalMealProgressService(),
            now: () => now,
            onConfigChanged: (_) {},
          ),
        ),
      );
      await tester.pump();
      await _finishCoursePreview(tester);

      now = now.add(const Duration(minutes: 2));
      await tester.pump(const Duration(milliseconds: 250));
      await tester.tap(find.byKey(const ValueKey('motivationSettingsButton')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      tester
          .widget<SwitchListTile>(
            find.byKey(const ValueKey('motivationVideoCustomIntervalSwitch')),
          )
          .onChanged!(true);
      await tester.pump();
      await tester.tap(
        find.byKey(const ValueKey('motivationSettingsApplyButton')),
      );
      await tester.pump();

      now = now.add(const Duration(minutes: 2, seconds: 59));
      await tester.pump(const Duration(milliseconds: 250));

      expect(
        find.byKey(const ValueKey('motivationVideoBubble_3')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('motivationVideoBubble_5')),
        findsNothing,
      );

      now = now.add(const Duration(seconds: 1));
      await tester.pump(const Duration(milliseconds: 250));

      expect(
        find.byKey(const ValueKey('motivationVideoBubble_5')),
        findsOneWidget,
      );

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    },
  );

  testWidgets('Timer screen skips motivation videos when disabled', (
    tester,
  ) async {
    var now = DateTime(2026);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: TimerScreen(
          motivationMediaAvailable: true,
          config: MealTimerConfig.defaults().copyWith(
            duration: const Duration(minutes: 60),
            soundEnabled: false,
            motivationVideoEnabled: false,
          ),
          mealProgressService: LocalMealProgressService(),
          now: () => now,
          onConfigChanged: (_) {},
        ),
      ),
    );
    await tester.pump();
    await _finishCoursePreview(tester);

    now = now.add(const Duration(minutes: 3));
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.byKey(const ValueKey('motivationVideoBubble_3')), findsNothing);
    expect(
      find.byKey(const ValueKey('motivationVideoBubble_10')),
      findsNothing,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('Timer screen keeps vehicle fixed when paused', (tester) async {
    tester.view.physicalSize = const Size(852, 393);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    var now = DateTime(2026);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: TimerScreen(
          motivationMediaAvailable: true,
          config: MealTimerConfig.defaults().copyWith(
            duration: const Duration(minutes: 60),
          ),
          mealProgressService: LocalMealProgressService(),
          now: () => now,
          onConfigChanged: (_) {},
        ),
      ),
    );
    await tester.pump();
    await _finishCoursePreview(tester);
    now = now.add(const Duration(minutes: 20));
    await tester.pump(const Duration(milliseconds: 250));

    Offset vehicleCenterInRoad() {
      final roadRect = tester.getRect(find.byType(RoadView));
      final vehicleCenter = tester.getCenter(find.byType(VehicleWidget));
      return vehicleCenter - roadRect.topLeft;
    }

    final centerBeforePause = vehicleCenterInRoad();
    await tester.tap(find.byIcon(Icons.pause_rounded));
    await tester.pump();
    final centerAfterPause = vehicleCenterInRoad();

    now = now.add(const Duration(minutes: 10));
    await tester.pump(const Duration(seconds: 1));
    final centerAfterPausedTime = vehicleCenterInRoad();

    expect(centerAfterPause.dx, closeTo(centerBeforePause.dx, 0.1));
    expect(centerAfterPause.dy, closeTo(centerBeforePause.dy, 0.1));
    expect(centerAfterPausedTime.dx, closeTo(centerBeforePause.dx, 0.1));
    expect(centerAfterPausedTime.dy, closeTo(centerBeforePause.dy, 0.1));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('Timer screen gives the route primary space in landscape', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: TimerScreen(
          motivationMediaAvailable: true,
          config: MealTimerConfig.defaults().copyWith(
            duration: const Duration(minutes: 5),
          ),
          mealProgressService: LocalMealProgressService(),
          onConfigChanged: (_) {},
        ),
      ),
    );
    await tester.pump();

    final roadSize = tester.getSize(find.byType(RoadView));
    expect(roadSize, const Size(1200, 520));
    expect(roadSize.width, greaterThan(760));
    expect(roadSize.height, greaterThan(460));
    expect(roadSize.height, lessThanOrEqualTo(560));
    final roadRect = tester.getRect(find.byType(RoadView));
    expect(
      roadRect.contains(tester.getCenter(find.byIcon(Icons.home_rounded))),
      isTrue,
    );
    expect(
      roadRect.contains(tester.getCenter(find.byType(GoalStarPulse))),
      isTrue,
    );
    expect(
      roadRect.contains(tester.getCenter(find.byType(VehicleWidget))),
      isTrue,
    );
    expect(
      find.descendant(
        of: find.byType(RoadView),
        matching: find.byType(VehicleWidget),
      ),
      findsNothing,
    );
    expect(find.byType(VehicleWidget), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const ValueKey('remainingTimeBadge'))).width,
      360,
    );
    expect(
      tester.getSize(find.byKey(const ValueKey('remainingTimeBadge'))).height,
      lessThanOrEqualTo(
        tester
            .getSize(find.byKey(const ValueKey('timerProgressMessageCard')))
            .height,
      ),
    );
    final roadBounds = createRoadBounds(const Size(1200, 520));
    final expectedRoadRight =
        roadRect.left + (roadRect.width * roadBounds.right / 1200);
    final expectedRoadLeft =
        roadRect.left + (roadRect.width * roadBounds.left / 1200);
    expect(
      tester.getRect(find.byKey(const ValueKey('remainingTimeBadge'))).right,
      closeTo(expectedRoadRight, 1),
    );
    expect(
      tester
          .getRect(find.byKey(const ValueKey('timerProgressMessageCard')))
          .left,
      greaterThanOrEqualTo(expectedRoadLeft),
    );
    expect(
      tester
          .getSize(find.byKey(const ValueKey('timerProgressIndicator')))
          .width,
      greaterThan(250),
    );
    expect(
      tester
          .getRect(find.byKey(const ValueKey('timerProgressMessageCard')))
          .right,
      lessThanOrEqualTo(
        tester.getRect(find.byKey(const ValueKey('remainingTimeBadge'))).left,
      ),
    );
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.text('오늘의 냠냠코스'), findsNothing);
    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    expect(
      tester.widget<TimerControlBar>(find.byType(TimerControlBar)).isVertical,
      isFalse,
    );

    tester.view.physicalSize = const Size(900, 500);
    await tester.pump();

    expect(tester.getSize(find.byType(RoadView)), roadSize);
  });

  testWidgets('Landscape finish drive message has room for Japanese copy', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    var now = DateTime(2026);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ja'),
        home: TimerScreen(
          motivationMediaAvailable: true,
          config: MealTimerConfig.defaults().copyWith(
            duration: const Duration(seconds: 100),
          ),
          mealProgressService: LocalMealProgressService(),
          now: () => now,
          onConfigChanged: (_) {},
        ),
      ),
    );
    await tester.pump();
    await _finishCoursePreview(tester);

    now = now.add(const Duration(seconds: 50));
    await tester.pump(const Duration(milliseconds: 250));
    tester.widget<TimerControlBar>(find.byType(TimerControlBar)).onComplete!();
    await tester.pump();
    await tester.tap(find.byType(FilledButton).last);
    await tester.pump();

    expect(find.text('仕上げに向かっています！'), findsOneWidget);
    expect(
      tester
          .getSize(find.byKey(const ValueKey('timerProgressMessageText')))
          .width,
      greaterThan(220),
    );
    expect(
      tester
          .getSize(find.byKey(const ValueKey('timerProgressIndicator')))
          .width,
      greaterThan(180),
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('Timer screen keeps long landscape course viewport fixed', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: TimerScreen(
          motivationMediaAvailable: true,
          config: MealTimerConfig.defaults().copyWith(
            duration: const Duration(minutes: 60),
          ),
          mealProgressService: LocalMealProgressService(),
          onConfigChanged: (_) {},
        ),
      ),
    );
    await tester.pump();
    await _finishCoursePreview(tester);

    expect(tester.getSize(find.byType(RoadView)), const Size(1200, 520));
    expect(
      tester.widget<RoadView>(find.byType(RoadView)).courseDuration,
      const Duration(minutes: 60),
    );
    expect(
      tester
          .widget<RoadVehicleLayer>(find.byType(RoadVehicleLayer))
          .courseDuration,
      const Duration(minutes: 60),
    );

    expect(
      tester
          .getRect(find.byType(RoadView))
          .contains(tester.getCenter(find.byType(VehicleWidget))),
      isTrue,
    );
  });

  testWidgets(
    'Timer screen places controls inside compact landscape course action slot',
    (tester) async {
      tester.view.physicalSize = const Size(852, 393);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          supportedLocales: AppTexts.supportedLocales,
          locale: const Locale('en'),
          home: TimerScreen(
            motivationMediaAvailable: true,
            config: MealTimerConfig.defaults(),
            mealProgressService: LocalMealProgressService(),
            onConfigChanged: (_) {},
          ),
        ),
      );
      await tester.pump();

      final roadRect = tester.getRect(find.byType(RoadView));
      final controlsRect = tester.getRect(
        find.byKey(const ValueKey('compactLandscapeControls')),
      );
      final settingsRect = tester.getRect(
        find.byKey(const ValueKey('motivationSettingsButton')),
      );
      final pauseRect = tester.getRect(find.byIcon(Icons.pause_rounded));
      final roadBounds = createRoadBounds(const Size(1200, 520));
      final expectedRoadRight =
          roadRect.left + (roadRect.width * roadBounds.right / 1200);

      expect(find.byType(SingleChildScrollView), findsNothing);
      expect(find.byType(TimerControlBar), findsNothing);
      expect(find.byIcon(Icons.video_settings_rounded), findsOneWidget);
      expect(find.byIcon(Icons.route_rounded), findsOneWidget);
      expect(roadRect.width, greaterThan(760));
      expect(roadRect.height, greaterThan(320));
      expect(controlsRect.left, greaterThanOrEqualTo(expectedRoadRight));
      expect(controlsRect.right, lessThanOrEqualTo(roadRect.right));
      expect(controlsRect.width, lessThanOrEqualTo(72));
      expect(controlsRect.height, lessThanOrEqualTo(350));
      expect(controlsRect.contains(settingsRect.center), isTrue);
      expect(controlsRect.contains(pauseRect.center), isTrue);
      expect(settingsRect.bottom, lessThanOrEqualTo(pauseRect.top));
      expect(
        controlsRect.right,
        lessThanOrEqualTo(tester.view.physicalSize.width),
      );
      expect(
        controlsRect.bottom,
        lessThanOrEqualTo(tester.view.physicalSize.height),
      );
    },
  );

  testWidgets('Timer motivation settings sheet scrolls in compact landscape', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(852, 393);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('en'),
        home: TimerScreen(
          motivationMediaAvailable: true,
          config: MealTimerConfig.defaults().copyWith(
            motivationVideoUseCustomInterval: true,
          ),
          mealProgressService: LocalMealProgressService(),
          onConfigChanged: (_) {},
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('motivationSettingsButton')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(tester.takeException(), isNull);
    expect(
      find.byKey(const ValueKey('motivationVideoIntervalSegmentedButton')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('motivationSettingsApplyButton')),
      findsOneWidget,
    );
  });

  testWidgets('Timer screen allows landscape only while mounted', (
    tester,
  ) async {
    final orientationService = _FakeOrientationService();

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        home: TimerScreen(
          motivationMediaAvailable: true,
          config: MealTimerConfig.defaults(),
          mealProgressService: LocalMealProgressService(),
          onConfigChanged: (_) {},
          orientationService: orientationService,
        ),
      ),
    );
    await tester.pump();

    expect(orientationService.calls, ['allowMealFlowOrientations']);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();

    expect(orientationService.calls, [
      'allowMealFlowOrientations',
      'lockPortrait',
    ]);
  });

  testWidgets('Timer screen keeps screen awake only when setting is enabled', (
    tester,
  ) async {
    final screenAwakeService = _FakeScreenAwakeService();

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        home: TimerScreen(
          motivationMediaAvailable: true,
          config: MealTimerConfig.defaults().copyWith(keepScreenAwake: true),
          mealProgressService: LocalMealProgressService(),
          onConfigChanged: (_) {},
          screenAwakeService: screenAwakeService,
        ),
      ),
    );
    await tester.pump();

    expect(screenAwakeService.enabledValues, [true]);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();

    expect(screenAwakeService.enabledValues, [true, false]);
  });

  testWidgets(
    'Timer screen leaves wakelock untouched when setting is disabled',
    (tester) async {
      final screenAwakeService = _FakeScreenAwakeService();

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          supportedLocales: AppTexts.supportedLocales,
          home: TimerScreen(
            motivationMediaAvailable: true,
            config: MealTimerConfig.defaults().copyWith(keepScreenAwake: false),
            mealProgressService: LocalMealProgressService(),
            onConfigChanged: (_) {},
            screenAwakeService: screenAwakeService,
          ),
        ),
      );
      await tester.pump();

      expect(screenAwakeService.enabledValues, isEmpty);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();

      expect(screenAwakeService.enabledValues, isEmpty);
    },
  );

  testWidgets('Timer screen asks before leaving with the back button', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(600, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    final navigatorKey = GlobalKey<NavigatorState>();

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        navigatorKey: navigatorKey,
        locale: const Locale('ko'),
        home: const Scaffold(body: Center(child: Text('타이머 열기'))),
      ),
    );
    navigatorKey.currentState!.push(
      MaterialPageRoute(
        builder: (_) => TimerScreen(
          motivationMediaAvailable: true,
          config: MealTimerConfig.defaults(),
          mealProgressService: LocalMealProgressService(),
          onConfigChanged: (_) {},
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('오늘의 냠냠코스'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 320));

    expect(find.text('코스를 그만할까요?'), findsOneWidget);
    expect(find.text('지금 나가면 진행 중인 냠냠코스가 저장되지 않아요.'), findsOneWidget);

    await tester.tap(find.text('계속하기'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 320));

    expect(find.text('코스를 그만할까요?'), findsNothing);
    expect(find.text('오늘의 냠냠코스'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 320));
    await tester.tap(find.text('그만하기'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('타이머 열기'), findsOneWidget);
    expect(find.text('오늘의 냠냠코스'), findsNothing);
  });

  testWidgets('English locale shows English timer progress copy', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(600, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('en'),
        home: TimerScreen(
          motivationMediaAvailable: true,
          config: MealTimerConfig.defaults(),
          mealProgressService: LocalMealProgressService(),
          onConfigChanged: (_) {},
        ),
      ),
    );
    await tester.pump();
    await _finishCoursePreview(tester);

    expect(find.text("Today's Yamyam Ride"), findsOneWidget);
    expect(find.text('Pause'), findsOneWidget);
    expect(find.text('출발했어요!'), findsNothing);
  });

  testWidgets('Paused timer shows paused status copy', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('en'),
        home: TimerScreen(
          motivationMediaAvailable: true,
          config: MealTimerConfig.defaults(),
          mealProgressService: LocalMealProgressService(),
          onConfigChanged: (_) {},
        ),
      ),
    );
    await tester.pump();
    await _finishCoursePreview(tester);

    await tester.ensureVisible(find.text('Pause'));
    await tester.pump();
    await tester.tap(find.text('Pause'));
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  test('Fast meal awards the selected vehicle sticker', () async {
    SharedPreferences.setMockInitialValues({});

    final service = LocalMealProgressService();
    final recordedSession = await service.recordMealResult(
      MealSessionResult(
        startedAt: DateTime(2026, 5, 4, 12),
        endedAt: DateTime(2026, 5, 4, 12, 10),
        targetDuration: const Duration(minutes: 20),
        actualDuration: const Duration(minutes: 13),
        completedBeforeArrival: true,
      ),
      vehicleId: 'motorcycle',
    );

    expect(recordedSession.awardedRewards, hasLength(1));
    expect(
      recordedSession.awardedRewards.single.id,
      'sticker_vehicle_motorcycle',
    );
    expect(recordedSession.entry.rewardIds, ['sticker_vehicle_motorcycle']);
  });

  test('Completed overtime meal awards the selected vehicle sticker', () async {
    SharedPreferences.setMockInitialValues({});

    final service = LocalMealProgressService();
    final recordedSession = await service.recordMealResult(
      MealSessionResult(
        startedAt: DateTime(2026, 5, 4, 12),
        endedAt: DateTime(2026, 5, 4, 12, 25),
        targetDuration: const Duration(minutes: 20),
        actualDuration: const Duration(minutes: 25),
        completedBeforeArrival: false,
      ),
      vehicleId: 'fire_truck',
    );

    expect(recordedSession.awardedRewards, hasLength(1));
    expect(
      recordedSession.awardedRewards.single.id,
      'sticker_vehicle_fire_truck',
    );
  });

  test('Incomplete meal does not award stickers', () async {
    SharedPreferences.setMockInitialValues({});

    final service = LocalMealProgressService();
    final recordedSession = await service.recordMealResult(
      MealSessionResult(
        startedAt: DateTime(2026, 5, 4, 12),
        endedAt: DateTime(2026, 5, 4, 12, 25),
        targetDuration: const Duration(minutes: 20),
        actualDuration: const Duration(minutes: 25),
        completedBeforeArrival: false,
        mealCompleted: false,
      ),
      vehicleId: 'shark',
    );

    expect(recordedSession.awardedRewards, isEmpty);
    expect(recordedSession.entry.mealCompleted, isFalse);
    expect(
      recordedSession.entry.completionStatus,
      MealCompletionStatus.notCompleted,
    );
    expect(recordedSession.entry.rewardIds, isEmpty);
    expect((await service.loadSnapshot()).inventory, isEmpty);
  });

  test('Unknown vehicle does not award stickers', () async {
    SharedPreferences.setMockInitialValues({});

    final service = LocalMealProgressService();
    final recordedSession = await service.recordMealResult(
      mealResult(),
      vehicleId: 'missing_vehicle',
    );

    expect(recordedSession.awardedRewards, isEmpty);
    expect(recordedSession.entry.rewardIds, isEmpty);
  });

  test('Arrival-completed meal records at-arrival status', () async {
    SharedPreferences.setMockInitialValues({});

    final service = LocalMealProgressService();
    final recordedSession = await service.recordMealResult(
      mealResult(
        actualDuration: const Duration(minutes: 20),
        completedBeforeArrival: false,
        completionStatus: MealCompletionStatus.completedAtArrival,
      ),
      vehicleId: 'motorcycle',
    );
    final snapshot = await service.loadSnapshot();

    expect(
      recordedSession.entry.completionStatus,
      MealCompletionStatus.completedAtArrival,
    );
    expect(
      snapshot.history.single.completionStatus,
      MealCompletionStatus.completedAtArrival,
    );
  });

  test('Meal history stores directly selected ingredient ids', () async {
    SharedPreferences.setMockInitialValues({});

    final service = LocalMealProgressService();
    final recordedSession = await service.recordMealResult(
      mealResult(selectedIngredientIds: const ['carrot', 'egg']),
      vehicleId: 'motorcycle',
    );
    final snapshot = await service.loadSnapshot();

    expect(recordedSession.entry.selectedIngredientIds, ['carrot', 'egg']);
    expect(snapshot.history.single.selectedIngredientIds, ['carrot', 'egg']);
  });

  test('Deleting meal history removes only the saved record', () async {
    SharedPreferences.setMockInitialValues({});

    final service = LocalMealProgressService();
    await service.createRewardGoal(
      requiredStickerCount: 2,
      rewardText: '아이스크림',
    );
    final recordedSession = await service.recordMealResult(
      mealResult(),
      vehicleId: 'motorcycle',
    );
    final beforeDelete = await service.loadSnapshot();

    expect(beforeDelete.history, hasLength(1));
    expect(beforeDelete.inventory, isNotEmpty);
    expect(beforeDelete.activeRewardGoals.single.filledCount, 1);

    final deleted = await service.deleteMealHistoryEntry(
      recordedSession.entry.id,
    );
    final afterDelete = await service.loadSnapshot();

    expect(deleted, isTrue);
    expect(afterDelete.history, isEmpty);
    expect(afterDelete.inventory, hasLength(beforeDelete.inventory.length));
    expect(
      afterDelete.inventory.single.rewardId,
      beforeDelete.inventory.single.rewardId,
    );
    expect(
      afterDelete.inventory.single.count,
      beforeDelete.inventory.single.count,
    );
    expect(afterDelete.activeRewardGoals.single.filledCount, 1);
    expect(
      afterDelete.activeRewardGoals.single.filledSlots.single.mealSessionId,
      recordedSession.entry.id,
    );
  });

  test(
    'Deleting missing meal history entry leaves records unchanged',
    () async {
      SharedPreferences.setMockInitialValues({});

      final service = LocalMealProgressService();
      await service.recordMealResult(mealResult(), vehicleId: 'motorcycle');

      final deleted = await service.deleteMealHistoryEntry('missing-meal');
      final snapshot = await service.loadSnapshot();

      expect(deleted, isFalse);
      expect(snapshot.history, hasLength(1));
    },
  );

  test('Completed meal fills exactly one active reward goal slot', () async {
    SharedPreferences.setMockInitialValues({});

    final service = LocalMealProgressService();
    await service.createRewardGoal(
      requiredStickerCount: 5,
      rewardText: '아이스크림',
    );

    final recordedSession = await service.recordMealResult(
      mealResult(),
      vehicleId: 'motorcycle',
    );
    final snapshot = await service.loadSnapshot();

    expect(recordedSession.updatedRewardGoal?.filledCount, 1);
    expect(recordedSession.rewardGoalJustReady, isFalse);
    expect(snapshot.activeRewardGoals.single.filledCount, 1);
  });

  test('Completed meal fills all active reward goals', () async {
    SharedPreferences.setMockInitialValues({});

    final service = LocalMealProgressService();
    await service.createRewardGoal(
      requiredStickerCount: 5,
      rewardText: '아이스크림',
    );
    await service.createRewardGoal(requiredStickerCount: 7, rewardText: '딸기');

    final recordedSession = await service.recordMealResult(
      mealResult(),
      vehicleId: 'motorcycle',
    );
    final snapshot = await service.loadSnapshot();

    expect(recordedSession.updatedRewardGoals, hasLength(2));
    expect(snapshot.activeRewardGoals, hasLength(2));
    expect(snapshot.activeRewardGoals.map((goal) => goal.filledCount), [1, 1]);
  });

  test('Only two active reward goals can be created', () async {
    SharedPreferences.setMockInitialValues({});

    final service = LocalMealProgressService();
    await service.createRewardGoal(
      requiredStickerCount: 5,
      rewardText: '아이스크림',
    );
    await service.createRewardGoal(requiredStickerCount: 7, rewardText: '딸기');

    expect(
      () =>
          service.createRewardGoal(requiredStickerCount: 10, rewardText: '젤리'),
      throwsStateError,
    );
  });

  test(
    'Legacy single reward goal storage loads into list storage shape',
    () async {
      final legacyGoal = RewardGoal(
        id: 'legacy-active',
        rewardText: '아이스크림',
        requiredStickerCount: 5,
        filledSlots: const [],
        createdAt: DateTime(2026, 5, 4, 12),
        status: RewardGoalStatus.active,
      );
      final legacyUsedGoal = RewardGoal(
        id: 'legacy-used',
        rewardText: '딸기',
        requiredStickerCount: 1,
        filledSlots: [
          RewardGoalSlot(
            rewardId: 'sticker_vehicle_motorcycle',
            filledAt: DateTime(2026, 5, 4, 12),
            mealSessionId: 'meal-1',
          ),
        ],
        createdAt: DateTime(2026, 5, 4, 12),
        status: RewardGoalStatus.redeemed,
        redeemedAt: DateTime(2026, 5, 5, 12),
      );
      SharedPreferences.setMockInitialValues({
        'activeRewardGoal': jsonEncode(legacyGoal.toJson()),
        'redeemedRewardGoals': [jsonEncode(legacyUsedGoal.toJson())],
      });

      final snapshot = await LocalMealProgressService().loadSnapshot();

      expect(snapshot.activeRewardGoals, hasLength(1));
      expect(snapshot.activeRewardGoals.first.rewardText, '아이스크림');
      expect(snapshot.usedRewardGoals, hasLength(1));
      expect(snapshot.usedRewardGoals.first.status, RewardGoalStatus.used);
    },
  );

  test('Legacy meal history loads with completion status fallback', () async {
    SharedPreferences.setMockInitialValues({
      'mealHistory': [
        jsonEncode({
          'id': 'legacy-meal',
          'startedAt': DateTime(2026, 5, 4, 12).toIso8601String(),
          'endedAt': DateTime(2026, 5, 4, 12, 25).toIso8601String(),
          'targetMs': const Duration(minutes: 20).inMilliseconds,
          'actualMs': const Duration(minutes: 25).inMilliseconds,
          'completedBeforeArrival': false,
          'rewardIds': <String>[],
        }),
      ],
    });

    final snapshot = await LocalMealProgressService().loadSnapshot();

    expect(snapshot.history.single.mealCompleted, isTrue);
    expect(
      snapshot.history.single.completionStatus,
      MealCompletionStatus.completedAfterArrival,
    );
    expect(snapshot.history.single.selectedIngredientIds, isEmpty);
  });

  test(
    'Malformed meal history items are skipped during snapshot load',
    () async {
      final firstMeal = jsonEncode({
        'id': 'meal-1',
        'startedAt': DateTime(2026, 5, 4, 12).toIso8601String(),
        'endedAt': DateTime(2026, 5, 4, 12, 20).toIso8601String(),
        'targetMs': const Duration(minutes: 20).inMilliseconds,
        'actualMs': const Duration(minutes: 20).inMilliseconds,
        'completedBeforeArrival': true,
        'mealCompleted': true,
        'completionStatus': MealCompletionStatus.completedBeforeArrival.name,
        'rewardIds': <String>['sticker_vehicle_motorcycle'],
        'selectedIngredientIds': <String>['egg'],
      });
      final secondMeal = jsonEncode({
        'id': 'meal-2',
        'startedAt': DateTime(2026, 5, 5, 12).toIso8601String(),
        'endedAt': DateTime(2026, 5, 5, 12, 25).toIso8601String(),
        'targetMs': const Duration(minutes: 20).inMilliseconds,
        'actualMs': const Duration(minutes: 25).inMilliseconds,
        'completedBeforeArrival': false,
        'mealCompleted': true,
        'completionStatus': MealCompletionStatus.completedAfterArrival.name,
        'rewardIds': <String>['sticker_vehicle_fire_truck'],
        'selectedIngredientIds': <String>['tofu'],
      });
      final rawHistory = [
        firstMeal,
        '{malformed',
        jsonEncode(<String>['not-a-map']),
        jsonEncode({'id': 'bad-meal', 'startedAt': 'not-a-date'}),
        secondMeal,
      ];
      SharedPreferences.setMockInitialValues({'mealHistory': rawHistory});

      final snapshot = await LocalMealProgressService().loadSnapshot();
      final preferences = await SharedPreferences.getInstance();

      expect(snapshot.history.map((entry) => entry.id), ['meal-1', 'meal-2']);
      expect(snapshot.history.first.rewardIds, ['sticker_vehicle_motorcycle']);
      expect(snapshot.history.last.selectedIngredientIds, ['tofu']);
      expect(preferences.getStringList('mealHistory'), rawHistory);
    },
  );

  test(
    'Malformed reward inventory items are skipped during snapshot load',
    () async {
      final firstReward = jsonEncode({
        'rewardId': 'sticker_vehicle_motorcycle',
        'acquiredAt': DateTime(2026, 5, 4, 12).toIso8601String(),
        'count': 1,
      });
      final secondReward = jsonEncode({
        'rewardId': 'sticker_vehicle_fire_truck',
        'acquiredAt': DateTime(2026, 5, 5, 12).toIso8601String(),
        'count': 2,
      });
      final rawInventory = [
        firstReward,
        '{malformed',
        jsonEncode('not-a-map'),
        jsonEncode({
          'rewardId': 'bad-reward',
          'acquiredAt': 'not-a-date',
          'count': 'many',
        }),
        secondReward,
      ];
      SharedPreferences.setMockInitialValues({'rewardInventory': rawInventory});

      final snapshot = await LocalMealProgressService().loadSnapshot();
      final preferences = await SharedPreferences.getInstance();

      expect(snapshot.inventory.map((item) => item.rewardId), [
        'sticker_vehicle_motorcycle',
        'sticker_vehicle_fire_truck',
      ]);
      expect(snapshot.inventory.map((item) => item.count), [1, 2]);
      expect(preferences.getStringList('rewardInventory'), rawInventory);
    },
  );

  test('Fast meal fills only one reward goal slot', () async {
    SharedPreferences.setMockInitialValues({});

    final service = LocalMealProgressService();
    await service.createRewardGoal(
      requiredStickerCount: 5,
      rewardText: '아이스크림',
    );

    final recordedSession = await service.recordMealResult(
      mealResult(
        targetDuration: const Duration(minutes: 20),
        actualDuration: const Duration(minutes: 13),
      ),
      vehicleId: 'motorcycle',
    );
    final snapshot = await service.loadSnapshot();

    expect(recordedSession.awardedRewards, hasLength(1));
    expect(snapshot.activeRewardGoals.single.filledCount, 1);
  });

  test('Incomplete meal does not fill a reward goal slot', () async {
    SharedPreferences.setMockInitialValues({});

    final service = LocalMealProgressService();
    await service.createRewardGoal(
      requiredStickerCount: 5,
      rewardText: '아이스크림',
    );

    final recordedSession = await service.recordMealResult(
      mealResult(mealCompleted: false),
      vehicleId: 'motorcycle',
    );
    final snapshot = await service.loadSnapshot();

    expect(recordedSession.updatedRewardGoal, isNull);
    expect(snapshot.activeRewardGoals.single.filledCount, 0);
  });

  test('Reward goal becomes earned when required count is reached', () async {
    SharedPreferences.setMockInitialValues({});

    final service = LocalMealProgressService();
    await service.createRewardGoal(
      requiredStickerCount: 2,
      rewardText: '아이스크림',
    );

    await service.recordMealResult(
      mealResult(endedAt: DateTime(2026, 5, 4, 12)),
      vehicleId: 'motorcycle',
    );
    final recordedSession = await service.recordMealResult(
      mealResult(endedAt: DateTime(2026, 5, 4, 13)),
      vehicleId: 'motorcycle',
    );
    final snapshot = await service.loadSnapshot();

    expect(recordedSession.rewardGoalJustReady, isTrue);
    expect(snapshot.activeRewardGoals, isEmpty);
    expect(snapshot.earnedRewardGoals.single.status, RewardGoalStatus.earned);
    expect(snapshot.earnedRewardGoals.single.earnedAt, isNotNull);
  });

  test('Using an earned goal moves it to used history', () async {
    SharedPreferences.setMockInitialValues({});

    final service = LocalMealProgressService();
    await service.createRewardGoal(
      requiredStickerCount: 1,
      rewardText: '아이스크림',
    );
    await service.recordMealResult(mealResult(), vehicleId: 'motorcycle');

    final usedGoal = await service.useEarnedRewardGoal();
    final snapshot = await service.loadSnapshot();

    expect(usedGoal?.status, RewardGoalStatus.used);
    expect(usedGoal?.usedAt, isNotNull);
    expect(snapshot.activeRewardGoals, isEmpty);
    expect(snapshot.earnedRewardGoals, isEmpty);
    expect(snapshot.usedRewardGoals, hasLength(1));
    expect(snapshot.usedRewardGoals.first.rewardText, '아이스크림');
  });

  test('Active reward goal can be updated', () async {
    SharedPreferences.setMockInitialValues({});

    final service = LocalMealProgressService();
    await service.createRewardGoal(
      requiredStickerCount: 5,
      rewardText: '아이스크림',
    );

    final updatedGoal = await service.updateActiveRewardGoal(
      requiredStickerCount: 7,
      rewardText: '딸기',
    );
    final snapshot = await service.loadSnapshot();

    expect(updatedGoal?.rewardText, '딸기');
    expect(updatedGoal?.requiredStickerCount, 7);
    expect(snapshot.activeRewardGoals.single.rewardText, '딸기');
    expect(snapshot.activeRewardGoals.single.requiredStickerCount, 7);
  });

  test(
    'Reducing required count to filled count makes reward goal earned',
    () async {
      SharedPreferences.setMockInitialValues({});

      final service = LocalMealProgressService();
      await service.createRewardGoal(
        requiredStickerCount: 5,
        rewardText: '아이스크림',
      );
      await service.recordMealResult(mealResult(), vehicleId: 'motorcycle');
      await service.recordMealResult(
        mealResult(endedAt: DateTime(2026, 5, 4, 13)),
        vehicleId: 'motorcycle',
      );

      final updatedGoal = await service.updateActiveRewardGoal(
        requiredStickerCount: 2,
        rewardText: '아이스크림',
      );

      final snapshot = await service.loadSnapshot();

      expect(updatedGoal?.status, RewardGoalStatus.earned);
      expect(updatedGoal?.earnedAt, isNotNull);
      expect(snapshot.activeRewardGoals, isEmpty);
      expect(snapshot.earnedRewardGoals, hasLength(1));
    },
  );

  test('Active reward goal can be canceled', () async {
    SharedPreferences.setMockInitialValues({});

    final service = LocalMealProgressService();
    await service.createRewardGoal(
      requiredStickerCount: 5,
      rewardText: '아이스크림',
    );

    final canceledGoal = await service.cancelActiveRewardGoal();
    final snapshot = await service.loadSnapshot();

    expect(canceledGoal?.rewardText, '아이스크림');
    expect(snapshot.activeRewardGoals, isEmpty);
    expect(snapshot.usedRewardGoals, isEmpty);
  });

  test('Existing sticker inventory counts still increase', () async {
    SharedPreferences.setMockInitialValues({});

    final service = LocalMealProgressService();
    await service.createRewardGoal(
      requiredStickerCount: 5,
      rewardText: '아이스크림',
    );

    final recordedSession = await service.recordMealResult(
      mealResult(),
      vehicleId: 'motorcycle',
    );
    final snapshot = await service.loadSnapshot();
    final inventoryCount = snapshot.inventory.fold<int>(
      0,
      (total, item) => total + item.count,
    );

    expect(inventoryCount, recordedSession.awardedRewards.length);
    expect(snapshot.activeRewardGoals.single.filledCount, 1);
  });

  test(
    'Completing meals with the same vehicle increments inventory count',
    () async {
      SharedPreferences.setMockInitialValues({});

      final service = LocalMealProgressService();
      await service.recordMealResult(
        mealResult(endedAt: DateTime(2026, 5, 4, 12, 20)),
        vehicleId: 'bus',
      );
      await service.recordMealResult(
        mealResult(endedAt: DateTime(2026, 5, 4, 13, 20)),
        vehicleId: 'bus',
      );

      final snapshot = await service.loadSnapshot();

      expect(snapshot.inventory, hasLength(1));
      expect(snapshot.inventory.single.rewardId, 'sticker_vehicle_bus');
      expect(snapshot.inventory.single.count, 2);
    },
  );

  test(
    'Completing meals with different vehicles creates separate inventory items',
    () async {
      SharedPreferences.setMockInitialValues({});

      final service = LocalMealProgressService();
      await service.recordMealResult(
        mealResult(endedAt: DateTime(2026, 5, 4, 12, 20)),
        vehicleId: 'motorcycle',
      );
      await service.recordMealResult(
        mealResult(endedAt: DateTime(2026, 5, 4, 13, 20)),
        vehicleId: 'fire_truck',
      );

      final snapshot = await service.loadSnapshot();

      expect(snapshot.inventory, hasLength(2));
      expect(snapshot.inventory.map((item) => item.rewardId), [
        'sticker_vehicle_motorcycle',
        'sticker_vehicle_fire_truck',
      ]);
      expect(snapshot.inventory.map((item) => item.count), [1, 1]);
    },
  );

  testWidgets('Home screen shows reward goal CTA', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('en'),
        home: HomeScreen(
          motivationMediaAvailable: true,
          config: MealTimerConfig.defaults().copyWith(childName: 'Jiyul'),
          mealProgressService: LocalMealProgressService(),
          onConfigChanged: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();

    expect(find.text('Create Reward Goal'), findsOneWidget);
  });

  testWidgets(
    'Home reward summary refreshes after returning from reward goal',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final service = LocalMealProgressService();

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          supportedLocales: AppTexts.supportedLocales,
          locale: const Locale('en'),
          home: HomeScreen(
            motivationMediaAvailable: true,
            config: MealTimerConfig.defaults().copyWith(childName: 'Jiyul'),
            mealProgressService: service,
            onConfigChanged: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView), const Offset(0, -700));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create Reward Goal'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'ice cream');
      await tester.pump();
      await tester.tap(find.text('Save Goal'));
      await tester.pumpAndSettle();

      expect(find.byType(RewardGoalScreen), findsOneWidget);
      expect(find.text('ice cream'), findsOneWidget);

      Navigator.of(tester.element(find.byType(RewardGoalScreen))).pop();
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('ice cream · 0/5'), findsOneWidget);
      expect(find.text('Create Reward Goal'), findsNothing);
    },
  );

  testWidgets('Result sticker album uses bounded three-column landscape grid', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(852, 393);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await _pumpOpenResultStickerAlbumSheet(tester);

    expect(find.text('차량 스티커 보관함'), findsOneWidget);
    expect(find.text('오토바이 스티커'), findsOneWidget);

    final firstCard = tester.getRect(find.byType(Card).at(0));
    final secondCard = tester.getRect(find.byType(Card).at(1));
    final thirdCard = tester.getRect(find.byType(Card).at(2));
    final stickerSizes = tester
        .widgetList<RewardStickerImage>(find.byType(RewardStickerImage))
        .map((widget) => widget.size);

    expect((firstCard.top - secondCard.top).abs(), lessThan(0.1));
    expect((firstCard.top - thirdCard.top).abs(), lessThan(0.1));
    expect(firstCard.left, greaterThan(70));
    expect(thirdCard.right, lessThan(780));
    expect(firstCard.width, lessThan(240));
    expect(stickerSizes.every((size) => size <= 96), isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Result sticker album keeps two-column portrait grid', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await _pumpOpenResultStickerAlbumSheet(tester);

    expect(find.text('차량 스티커 보관함'), findsOneWidget);
    expect(find.text('오토바이 스티커'), findsOneWidget);

    final firstCard = tester.getRect(find.byType(Card).at(0));
    final secondCard = tester.getRect(find.byType(Card).at(1));
    final thirdCard = tester.getRect(find.byType(Card).at(2));
    final firstSticker = tester.widget<RewardStickerImage>(
      find.byType(RewardStickerImage).first,
    );

    expect((firstCard.top - secondCard.top).abs(), lessThan(0.1));
    expect(thirdCard.top, greaterThan(firstCard.bottom));
    expect(firstCard.width, lessThan(180));
    expect(firstSticker.size, 85);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Sticker collection shows motorcycle and supercar first', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'rewardInventory': [
        jsonEncode({
          'rewardId': 'sticker_vehicle_motorcycle',
          'acquiredAt': DateTime(2026, 5, 4, 12).toIso8601String(),
          'count': 1,
        }),
        jsonEncode({
          'rewardId': 'sticker_vehicle_supercar',
          'acquiredAt': DateTime(2026, 5, 4, 13).toIso8601String(),
          'count': 1,
        }),
      ],
    });

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: StickerCollectionScreen(
          mealProgressService: LocalMealProgressService(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      tester.getTopLeft(find.text('오토바이 스티커')).dy,
      tester.getTopLeft(find.text('슈퍼카 스티커')).dy,
    );
  });

  testWidgets('Home meal records summary opens meal history screen', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final service = LocalMealProgressService();
    await service.recordMealResult(
      mealResult(
        targetDuration: const Duration(minutes: 20),
        actualDuration: const Duration(minutes: 25),
      ),
      vehicleId: 'motorcycle',
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('en'),
        home: HomeScreen(
          motivationMediaAvailable: true,
          config: MealTimerConfig.defaults().copyWith(childName: 'Jiyul'),
          mealProgressService: service,
          onConfigChanged: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();

    expect(find.text("Jiyul's meal records"), findsOneWidget);
    expect(find.text('Recent meal 20:00 · complete'), findsNothing);

    await tester.tap(find.text("Jiyul's meal records"));
    await tester.pumpAndSettle();

    expect(find.byType(MealHistoryScreen), findsOneWidget);
    expect(find.text('Meal Records'), findsOneWidget);
  });

  testWidgets('Home meal records summary shows incomplete status', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final service = LocalMealProgressService();
    await service.recordMealResult(
      mealResult(
        targetDuration: const Duration(minutes: 20),
        actualDuration: const Duration(minutes: 25),
        mealCompleted: false,
        completionStatus: MealCompletionStatus.notCompleted,
      ),
      vehicleId: 'motorcycle',
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: HomeScreen(
          motivationMediaAvailable: true,
          config: MealTimerConfig.defaults().copyWith(childName: '강우'),
          mealProgressService: service,
          onConfigChanged: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();

    expect(find.text('강우의 냠냠 기록'), findsOneWidget);
    expect(
      find.text('최근 식사 20:00 · 미완료 · 차량 스티커 없음 · 초과 +05:00'),
      findsNothing,
    );
    expect(find.textContaining('최근 식사'), findsNothing);
  });

  testWidgets('Reward goal creation form saves a goal', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final service = LocalMealProgressService();

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('en'),
        home: RewardGoalScreen(mealProgressService: service),
      ),
    );
    await tester.pump();

    await tester.tap(find.widgetWithText(ChoiceChip, '7'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'ice cream');
    await tester.pump();
    await tester.tap(find.text('Save Goal'));
    await tester.pumpAndSettle();

    final snapshot = await service.loadSnapshot();
    expect(snapshot.activeRewardGoals.single.rewardText, 'ice cream');
    expect(snapshot.activeRewardGoals.single.requiredStickerCount, 7);
  });

  testWidgets('Earned reward use flow asks for confirmation', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final service = LocalMealProgressService();
    await service.createRewardGoal(
      requiredStickerCount: 1,
      rewardText: 'ice cream',
    );
    await service.recordMealResult(mealResult(), vehicleId: 'motorcycle');

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('en'),
        home: RewardGoalScreen(mealProgressService: service),
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Give Reward'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Give Reward'));
    await tester.pumpAndSettle();
    expect(find.text('Give this reward?'), findsOneWidget);

    await tester.tap(find.text('Keep Goal'));
    await tester.pumpAndSettle();
    expect((await service.loadSnapshot()).earnedRewardGoals, hasLength(1));

    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Give Reward'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Give Reward'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Give Reward').last);
    await tester.pumpAndSettle();

    final snapshot = await service.loadSnapshot();
    expect(snapshot.earnedRewardGoals, isEmpty);
    expect(snapshot.usedRewardGoals, hasLength(1));
  });

  testWidgets('Meal history screen shows empty state', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: MealHistoryScreen(
          mealProgressService: LocalMealProgressService(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('식사 기록'), findsOneWidget);
    expect(find.text('아직 식사 기록이 없어요'), findsOneWidget);
    expect(find.text('타이머를 완료하면 기록이 여기에 쌓여요.'), findsOneWidget);
  });

  testWidgets('Meal history screen lists saved meal records', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final service = LocalMealProgressService();
    await service.recordMealResult(
      mealResult(
        startedAt: DateTime(2026, 5, 4, 12),
        targetDuration: const Duration(minutes: 20),
        actualDuration: const Duration(minutes: 25),
        completedBeforeArrival: false,
      ),
      vehicleId: 'motorcycle',
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: MealHistoryScreen(mealProgressService: service),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('12:25'), findsOneWidget);
    expect(find.text('목표'), findsOneWidget);
    expect(find.text('20:00'), findsNWidgets(2));
    expect(find.text('실제'), findsOneWidget);
    expect(find.text('25:00'), findsNothing);
    expect(find.text('초과 +05:00'), findsNothing);
    expect(find.text('완료'), findsOneWidget);
    expect(find.text('받은 차량 스티커'), findsOneWidget);
    expect(find.text('고른 식재료'), findsNothing);
  });

  testWidgets('Meal history reward sticker renders without a frame', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final service = LocalMealProgressService();
    await service.recordMealResult(
      mealResult(
        startedAt: DateTime(2026, 5, 4, 12),
        targetDuration: const Duration(minutes: 20),
        actualDuration: const Duration(minutes: 18),
      ),
      vehicleId: 'motorcycle',
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: MealHistoryScreen(mealProgressService: service),
      ),
    );
    await tester.pumpAndSettle();

    final stickerFinder = find.byWidgetPredicate(
      (widget) =>
          widget is RewardStickerImage && widget.size == 56 && !widget.framed,
    );

    expect(stickerFinder, findsOneWidget);
  });

  testWidgets('Meal history screen deletes a record after confirmation', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final service = LocalMealProgressService();
    final recordedSession = await service.recordMealResult(
      mealResult(
        startedAt: DateTime(2026, 5, 4, 12),
        targetDuration: const Duration(minutes: 20),
        actualDuration: const Duration(minutes: 25),
      ),
      vehicleId: 'motorcycle',
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: MealHistoryScreen(mealProgressService: service),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('12:25'), findsOneWidget);

    await tester.tap(
      find.byKey(
        ValueKey('deleteMealHistoryEntry-${recordedSession.entry.id}'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('이 식사 기록을 삭제할까요?'), findsOneWidget);
    expect(find.text('기록만 삭제되고 받은 차량 스티커는 유지돼요.'), findsOneWidget);

    await tester.tap(find.text('삭제'));
    await tester.pumpAndSettle();

    expect(find.text('식사 기록을 삭제했어요.'), findsOneWidget);
    expect(find.textContaining('12:25'), findsNothing);
    expect(find.text('아직 식사 기록이 없어요'), findsOneWidget);
    expect((await service.loadSnapshot()).history, isEmpty);
  });

  testWidgets('Meal history delete dialog can be canceled', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final service = LocalMealProgressService();
    final recordedSession = await service.recordMealResult(
      mealResult(
        startedAt: DateTime(2026, 5, 4, 12),
        targetDuration: const Duration(minutes: 20),
        actualDuration: const Duration(minutes: 25),
      ),
      vehicleId: 'motorcycle',
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: MealHistoryScreen(mealProgressService: service),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(
        ValueKey('deleteMealHistoryEntry-${recordedSession.entry.id}'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('취소'));
    await tester.pumpAndSettle();

    expect(find.textContaining('12:25'), findsOneWidget);
    expect((await service.loadSnapshot()).history, hasLength(1));
  });

  testWidgets('Meal history screen shows directly selected ingredients', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final service = LocalMealProgressService();
    await service.recordMealResult(
      mealResult(
        startedAt: DateTime(2026, 5, 4, 12),
        targetDuration: const Duration(minutes: 20),
        actualDuration: const Duration(minutes: 20),
        selectedIngredientIds: const ['carrot', 'egg'],
      ),
      vehicleId: 'motorcycle',
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: MealHistoryScreen(mealProgressService: service),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('mealHistoryHelpCard')), findsOneWidget);
    expect(find.text('식사 기록 안내'), findsOneWidget);
    expect(find.text('고른 식재료'), findsOneWidget);
    expect(find.text('당근'), findsOneWidget);
    expect(find.text('달걀'), findsOneWidget);
  });

  testWidgets('Meal history screen shows incomplete meal records', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final service = LocalMealProgressService();
    await service.recordMealResult(
      mealResult(
        startedAt: DateTime(2026, 5, 4, 12),
        targetDuration: const Duration(minutes: 20),
        actualDuration: const Duration(minutes: 25),
        mealCompleted: false,
        completionStatus: MealCompletionStatus.notCompleted,
      ),
      vehicleId: 'motorcycle',
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        locale: const Locale('ko'),
        home: MealHistoryScreen(mealProgressService: service),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('미완료'), findsOneWidget);
    expect(find.text('차량 스티커 없음'), findsOneWidget);
    expect(find.text('초과 +05:00'), findsNothing);
  });
}

Future<void> _pumpOpenResultStickerAlbumSheet(WidgetTester tester) async {
  final inventory = [
    RewardInventoryItem(
      rewardId: RewardCatalog.vehicleStickerIdForVehicle('motorcycle'),
      acquiredAt: DateTime(2026),
      count: 2,
    ),
  ];

  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: AppTexts.supportedLocales,
      locale: const Locale('ko'),
      theme: AppTheme.light(),
      home: Builder(
        builder: (context) {
          return TextButton(
            onPressed: () {
              showResultStickerAlbumSheet(context, inventory: inventory);
            },
            child: const Text('openAlbum'),
          );
        },
      ),
    ),
  );
  await tester.tap(find.text('openAlbum'));
  await tester.pumpAndSettle();
}

Future<void> _finishCoursePreview(WidgetTester tester) async {
  await tester.pump();
  for (var i = 0; i < 30; i += 1) {
    await tester.pump(const Duration(milliseconds: 250));
  }
  await tester.pump();
}

Future<void> _pumpCompletedBeforeArrivalTimer(
  WidgetTester tester, {
  required Duration elapsed,
  required _FakeTimerAudioService timerAudioService,
  bool soundEnabled = true,
}) async {
  var now = DateTime(2026);

  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: AppTexts.supportedLocales,
      locale: const Locale('ko'),
      home: TimerScreen(
        motivationMediaAvailable: true,
        config: MealTimerConfig.defaults().copyWith(
          duration: const Duration(minutes: 5),
          soundEnabled: soundEnabled,
        ),
        mealProgressService: LocalMealProgressService(),
        now: () => now,
        timerAudioService: timerAudioService,
        onConfigChanged: (_) {},
      ),
    ),
  );
  await tester.pump();
  await _finishCoursePreview(tester);
  now = now.add(elapsed);
  await tester.pump(const Duration(milliseconds: 250));

  tester.widget<TimerControlBar>(find.byType(TimerControlBar)).onComplete!();
  await tester.pump();
  await tester.tap(find.byType(FilledButton).last);
  await tester.pump();
  await tester.pump();
}

class _FakeScreenAwakeService implements ScreenAwakeService {
  final List<bool> enabledValues = [];

  @override
  Future<void> setEnabled(bool enabled) async {
    enabledValues.add(enabled);
  }
}

class _FakeOrientationService implements OrientationService {
  final List<String> calls = [];

  @override
  Future<void> lockPortrait() async {
    calls.add('lockPortrait');
  }

  @override
  Future<void> allowMealFlowOrientations() async {
    calls.add('allowMealFlowOrientations');
  }
}

class _FakeMotivationAudioService implements MotivationAudioService {
  final List<String> playedAssets = [];
  var stopCount = 0;
  var disposeCount = 0;

  @override
  Future<void> playAsset(String assetPath) async {
    playedAssets.add(assetPath);
  }

  @override
  Future<void> stop() async {
    stopCount += 1;
  }

  @override
  Future<void> dispose() async {
    disposeCount += 1;
  }
}

class _FakeTimerAudioService implements TimerAudioService {
  var playFinishDriveShortSfxCount = 0;
  var playFinishDriveLongSfxCount = 0;
  var stopFinishDriveSfxCount = 0;
  var playFinishArrivalSfxCount = 0;
  var stopAllCount = 0;
  var disposeCount = 0;

  @override
  Future<void> startOrResumeBgm() async {}

  @override
  Future<void> pauseBgm() async {}

  @override
  Future<void> stopBgm() async {}

  @override
  Future<void> playMarkerSfx() async {}

  @override
  Future<void> playCourseLoading() async {}

  @override
  Future<void> stopCourseLoading() async {}

  @override
  Future<void> playReadyStartBeep() async {}

  @override
  Future<void> stopReadyStartBeep() async {}

  @override
  Future<void> playFinishDriveShortSfx() async {
    playFinishDriveShortSfxCount += 1;
  }

  @override
  Future<void> playFinishDriveLongSfx() async {
    playFinishDriveLongSfxCount += 1;
  }

  @override
  Future<void> stopFinishDriveSfx() async {
    stopFinishDriveSfxCount += 1;
  }

  @override
  Future<void> playFinishArrivalSfx() async {
    playFinishArrivalSfxCount += 1;
  }

  @override
  Future<void> stopAll() async {
    stopAllCount += 1;
  }

  @override
  Future<void> dispose() async {
    disposeCount += 1;
  }
}
