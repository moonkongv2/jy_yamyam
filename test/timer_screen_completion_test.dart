import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jy_yamyam/l10n/app_texts.dart';
import 'package:jy_yamyam/models/meal_timer_config.dart';
import 'package:jy_yamyam/screens/result_screen.dart';
import 'package:jy_yamyam/screens/timer_screen.dart';
import 'package:jy_yamyam/services/local_meal_progress_service.dart';
import 'package:jy_yamyam/services/orientation_service.dart';
import 'package:jy_yamyam/services/timer_audio_service.dart';
import 'package:jy_yamyam/widgets/road_view.dart';
import 'package:jy_yamyam/widgets/timer_control_bar.dart';

import 'helpers/timer_screen_test_harness.dart';

void main() {
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
    await finishCoursePreview(tester);

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
    await finishCoursePreview(tester);
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
    await finishCoursePreview(tester);
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
    await finishCoursePreview(tester);

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
    await finishCoursePreview(tester);
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
    await finishCoursePreview(tester);
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
    await finishCoursePreview(tester);
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
    await finishCoursePreview(tester);
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
  await finishCoursePreview(tester);
  now = now.add(elapsed);
  await tester.pump(const Duration(milliseconds: 250));

  tester.widget<TimerControlBar>(find.byType(TimerControlBar)).onComplete!();
  await tester.pump();
  await tester.tap(find.byType(FilledButton).last);
  await tester.pump();
  await tester.pump();
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
