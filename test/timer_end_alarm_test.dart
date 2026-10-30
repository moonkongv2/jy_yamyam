import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jy_yamyam/models/active_meal_timer_session.dart';
import 'package:jy_yamyam/models/meal_completion_status.dart';
import 'package:jy_yamyam/models/meal_progress_snapshot.dart';
import 'package:jy_yamyam/models/meal_session_result.dart';
import 'package:jy_yamyam/models/meal_timer_config.dart';
import 'package:jy_yamyam/screens/timer_screen.dart';
import 'package:jy_yamyam/services/local_meal_progress_service.dart';
import 'package:jy_yamyam/services/motivation_audio_service.dart';
import 'package:jy_yamyam/services/timer_audio_service.dart';
import 'package:jy_yamyam/widgets/timer_control_bar.dart';

class _AlarmAudio extends NoOpTimerAudioService {
  final calls = <String>[];
  Completer<void>? stopGate;

  @override
  Future<void> startOrResumeBgm() async => calls.add('bgm');

  @override
  Future<void> stopBgm() async => calls.add('stopBgm');

  @override
  Future<void> startTimerEndAlarm() async => calls.add('startAlarm');

  @override
  Future<void> stopTimerEndAlarm() async {
    calls.add('stopAlarm');
    await stopGate?.future;
  }

  @override
  Future<void> stopAll() async => calls.add('stopAll');

  int get starts => calls.where((c) => c == 'startAlarm').length;
  int get stops => calls.where((c) => c == 'stopAlarm').length;
}

class _MotivationAudio extends NoOpMotivationAudioService {
  int plays = 0;
  int stops = 0;
  Completer<void>? playGate;

  @override
  Future<void> playAsset(String path) async {
    plays++;
    await playGate?.future;
  }

  @override
  Future<void> stop() async => stops++;
}

class _Progress extends LocalMealProgressService {
  final gate = Completer<void>();
  final results = <MealSessionResult>[];
  bool fail = false;

  @override
  Future<RecordedMealSession> recordMealResult(
    MealSessionResult result, {
    required String vehicleId,
  }) async {
    results.add(result);
    await gate.future;
    if (fail) throw StateError('Test completion failure');
    return super.recordMealResult(result, vehicleId: vehicleId);
  }
}

class _Harness {
  final startedAt = DateTime(2026, 10, 30, 8);
  late DateTime now = startedAt.add(const Duration(minutes: 4, seconds: 59));
  final audio = _AlarmAudio();
  final motivation = _MotivationAudio();
  final progress = _Progress();
  var restoredState = ActiveMealTimerSessionState.running;
  MealTimerConfig config = MealTimerConfig.defaults().copyWith(
    duration: const Duration(minutes: 5),
    motivationVideoEnabled: false,
  );

  Future<void> mount(WidgetTester tester) async {
    tester.view.physicalSize = const Size(600, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ko'),
        supportedLocales: const [Locale('ko')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: TimerScreen(
          config: config,
          restoredSession: ActiveMealTimerSession(
            sessionId: 'end-alarm-test',
            config: config,
            startedAt: startedAt,
            state: restoredState,
            pausedAt: restoredState == ActiveMealTimerSessionState.paused
                ? now
                : null,
          ),
          mealProgressService: progress,
          timerAudioService: audio,
          motivationAudioService: motivation,
          motivationMediaAvailable: true,
          now: () => now,
          onConfigChanged: (value) => config = value,
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> expire(WidgetTester tester) async {
    now = startedAt.add(const Duration(minutes: 5, seconds: 1));
    await tester.pump(const Duration(milliseconds: 20));
    await tester.pump();
  }

  Future<void> showExpiry(WidgetTester tester) async {
    await expire(tester);
    await tester.pump(const Duration(milliseconds: 900));
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 300));
  }

  Future<void> answer(WidgetTester tester, bool? confirmed) async {
    if (confirmed == null) {
      Navigator.of(tester.element(find.byType(AlertDialog))).pop();
    } else {
      final button = find.descendant(
        of: find.byType(AlertDialog),
        matching: confirmed
            ? find.byType(FilledButton)
            : find.byType(TextButton),
      );
      await tester.tap(button);
    }
    await tester.pump();
  }

  void openManual(WidgetTester tester) {
    tester.widget<TimerControlBar>(find.byType(TimerControlBar)).onComplete!();
  }

  Future<void> close(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    if (audio.stopGate case final gate? when !gate.isCompleted) gate.complete();
    if (motivation.playGate case final gate? when !gate.isCompleted) {
      gate.complete();
    }
    if (!progress.gate.isCompleted) progress.gate.complete();
    for (var i = 0; i < 5; i++) {
      await tester.pump();
    }
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
  }
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('Expiry rings before 900ms modal and never restarts on ticks', (
    tester,
  ) async {
    final h = _Harness();
    await h.mount(tester);
    await h.expire(tester);
    expect(h.audio.calls, containsAllInOrder(['stopBgm', 'startAlarm']));
    expect(find.byType(AlertDialog), findsNothing);
    await tester.pump(const Duration(milliseconds: 899));
    expect(find.byType(AlertDialog), findsNothing);
    await tester.pump(const Duration(milliseconds: 1));
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.pump(const Duration(seconds: 30));
    expect(h.audio.starts, 1);
    expect(h.audio.stops, 0);
    await h.close(tester);
    expect(h.audio.calls.last, 'stopAll');
  });

  for (final response in <bool?>[true, false, null]) {
    testWidgets(
      'Automatic response $response silences then records existing status',
      (tester) async {
        final h = _Harness();
        await h.mount(tester);
        await h.showExpiry(tester);
        await h.answer(tester, response);
        expect(h.audio.stops, 1);
        expect(h.progress.results, hasLength(1));
        expect(
          h.progress.results.single.completionStatus,
          response == true
              ? MealCompletionStatus.completedAtArrival
              : MealCompletionStatus.notCompleted,
        );
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        await tester.pump();
        expect(h.audio.starts, 1);
        await h.close(tester);
      },
    );
  }

  testWidgets('Delayed stop preserves response time before storing result', (
    tester,
  ) async {
    final h = _Harness();
    h.audio.stopGate = Completer<void>();
    await h.mount(tester);
    await h.showExpiry(tester);
    final respondedAt = h.now;
    await h.answer(tester, true);
    expect(h.audio.stops, 1);
    expect(h.progress.results, isEmpty);
    h.now = h.now.add(const Duration(minutes: 2));
    await tester.pump(const Duration(seconds: 1));
    h.audio.stopGate!.complete();
    await tester.pump();
    expect(h.progress.results.single.endedAt, respondedAt);
    expect(
      h.progress.results.single.actualDuration,
      const Duration(minutes: 5, seconds: 1),
    );
    await h.close(tester);
  });

  for (final response in <bool?>[true, false, null]) {
    testWidgets(
      'Manual dialog expiring then $response preserves semantics and deferred prompt',
      (tester) async {
        final h = _Harness();
        await h.mount(tester);
        h.openManual(tester);
        await tester.pump();
        await h.expire(tester);
        await tester.pump(const Duration(seconds: 2));
        expect(find.byType(AlertDialog), findsOneWidget);
        expect(h.audio.starts, 1);
        await h.answer(tester, response);
        if (response == true) {
          expect(
            h.progress.results.single.completionStatus,
            MealCompletionStatus.completedAfterArrival,
          );
          expect(h.audio.stops, 1);
        } else {
          expect(h.progress.results, isEmpty);
          expect(h.audio.stops, response == false ? 1 : 0);
          await tester.pump(const Duration(milliseconds: 300));
          await tester.pump();
          expect(find.byType(AlertDialog), findsNothing);
          await tester.pump(const Duration(milliseconds: 900));
          expect(find.byType(AlertDialog), findsOneWidget);
          expect(h.audio.starts, 1);
          await tester.pump(const Duration(milliseconds: 300));
          await h.answer(tester, false);
          expect(
            h.progress.results.single.completionStatus,
            MealCompletionStatus.notCompleted,
          );
        }
        await h.close(tester);
      },
    );
  }

  testWidgets('Background expiry defers sound and modal until resume', (
    tester,
  ) async {
    final h = _Harness();
    await h.mount(tester);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await h.expire(tester);
    await tester.pump(const Duration(seconds: 2));
    expect(h.audio.starts, 0);
    expect(find.byType(AlertDialog), findsNothing);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(h.audio.starts, 1);
    await tester.pump(const Duration(milliseconds: 900));
    expect(find.byType(AlertDialog), findsOneWidget);
    for (final state in [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
      AppLifecycleState.detached,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(state);
      await tester.pump();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(find.byType(AlertDialog), findsOneWidget);
    }
    expect(h.audio.starts, 5);
    expect(h.audio.stops, 4);
    await h.close(tester);
  });

  testWidgets('Backgrounding in 900ms delay cancels stale modal reservation', (
    tester,
  ) async {
    final h = _Harness();
    await h.mount(tester);
    await h.expire(tester);
    await tester.pump(const Duration(milliseconds: 450));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump(const Duration(seconds: 2));
    expect(find.byType(AlertDialog), findsNothing);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(h.audio.starts, 2);
    await h.close(tester);
  });

  testWidgets('Initially inactive timer waits for resume', (tester) async {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    final h = _Harness();
    await h.mount(tester);
    await h.expire(tester);
    await tester.pump(const Duration(seconds: 1));
    expect(h.audio.starts, 0);
    expect(find.byType(AlertDialog), findsNothing);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(h.audio.starts, 1);
    await h.close(tester);
  });

  testWidgets('Restored expired session shows prompt without old alarm', (
    tester,
  ) async {
    final h = _Harness();
    h.now = h.startedAt.add(const Duration(minutes: 6));
    await h.mount(tester);
    await tester.pump(const Duration(milliseconds: 20));
    await tester.pump(const Duration(milliseconds: 900));
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(h.audio.starts, 0);
    await h.answer(tester, false);
    expect(
      h.progress.results.single.completionStatus,
      MealCompletionStatus.notCompleted,
    );
    await h.close(tester);
  });

  testWidgets('Sound toggle and parent config synchronize unconfirmed alarm', (
    tester,
  ) async {
    final h = _Harness();
    h.config = h.config.copyWith(soundEnabled: false);
    await h.mount(tester);
    await h.expire(tester);
    expect(h.audio.starts, 0);
    await tester.tap(find.byKey(const ValueKey('timerSoundToggleButton')));
    await tester.pump();
    expect(h.audio.starts, 1);
    h.config = h.config.copyWith(soundEnabled: false);
    await h.mount(tester);
    expect(h.audio.stops, 1);
    h.config = h.config.copyWith(soundEnabled: true);
    await h.mount(tester);
    expect(h.audio.starts, 2);
    await h.close(tester);
  });

  testWidgets(
    'Save failure retries without another alarm or duplicate sticker',
    (tester) async {
      final h = _Harness();
      h.progress.fail = true;
      await h.mount(tester);
      await h.showExpiry(tester);
      await h.answer(tester, true);
      h.progress.gate.complete();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(SnackBar), findsOneWidget);
      h.progress.fail = false;
      tester.widget<SnackBar>(find.byType(SnackBar)).action!.onPressed();
      for (var i = 0; i < 5; i++) {
        await tester.pump();
      }
      expect(h.audio.starts, 1);
      expect(h.progress.results, hasLength(2));
      final snapshot = await h.progress.loadSnapshot();
      expect(snapshot.history, hasLength(1));
      expect(snapshot.inventory.single.count, 1);
      await h.close(tester);
    },
  );

  testWidgets('Pending voice finishing after response cannot start alarm', (
    tester,
  ) async {
    final h = _Harness();
    h.config = h.config.copyWith(motivationVideoEnabled: true);
    h.now = h.startedAt.add(const Duration(seconds: 30));
    h.motivation.playGate = Completer<void>();
    await h.mount(tester);
    await tester.pump(const Duration(milliseconds: 20));
    await tester.pump(motivationVoiceStartDelay);
    expect(h.motivation.plays, 1);
    await h.showExpiry(tester);
    expect(h.audio.starts, 0);
    await h.answer(tester, true);
    h.motivation.playGate!.complete();
    await tester.pump();
    expect(h.motivation.stops, greaterThan(0));
    expect(h.audio.starts, 0);
    await h.close(tester);
  });
  testWidgets('Manual cancel before expiry leaves future alarm enabled', (
    tester,
  ) async {
    final h = _Harness();
    await h.mount(tester);
    h.openManual(tester);
    await tester.pump();
    await h.answer(tester, false);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();
    expect(h.progress.results, isEmpty);
    expect(h.audio.starts, 0);
    await h.showExpiry(tester);
    expect(h.audio.starts, 1);
    await h.close(tester);
  });

  testWidgets('Early completion remains silent with original result timing', (
    tester,
  ) async {
    final h = _Harness();
    await h.mount(tester);
    h.openManual(tester);
    await tester.pump();
    await h.answer(tester, true);
    expect(h.audio.starts, 0);
    expect(
      h.progress.results.single.completionStatus,
      MealCompletionStatus.completedBeforeArrival,
    );
    expect(
      h.progress.results.single.actualDuration,
      const Duration(minutes: 4, seconds: 59),
    );
    await h.close(tester);
  });

  testWidgets('Paused restored timer rings only after resume and new expiry', (
    tester,
  ) async {
    final h = _Harness();
    h.restoredState = ActiveMealTimerSessionState.paused;
    await h.mount(tester);
    await h.expire(tester);
    expect(h.audio.starts, 0);
    tester
        .widget<TimerControlBar>(find.byType(TimerControlBar))
        .onPauseResume!();
    await tester.pump();
    expect(h.audio.starts, 0);
    h.now = h.now.add(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 20));
    expect(h.audio.starts, 1);
    await h.close(tester);
  });

  for (final leave in [false, true]) {
    testWidgets(
      'Exit response $leave cancels stale expiry prompt and controls alarm',
      (tester) async {
        final h = _Harness();
        await h.mount(tester);
        await h.expire(tester);
        await tester.binding.handlePopRoute();
        await tester.pump();
        expect(find.text('코스를 그만할까요?'), findsOneWidget);
        expect(h.audio.stops, 1);
        await tester.pump(const Duration(seconds: 2));
        expect(find.byType(AlertDialog), findsOneWidget);
        await h.answer(tester, leave);
        await tester.pump(const Duration(milliseconds: 300));
        if (leave) {
          tester.binding.handleAppLifecycleStateChanged(
            AppLifecycleState.paused,
          );
          tester.binding.handleAppLifecycleStateChanged(
            AppLifecycleState.resumed,
          );
          await tester.pump(const Duration(seconds: 2));
          expect(h.audio.starts, 1);
          expect(find.byType(AlertDialog), findsNothing);
        } else {
          expect(h.audio.starts, 2);
          await tester.pump(const Duration(milliseconds: 900));
          expect(find.byType(AlertDialog), findsOneWidget);
          expect(find.text('식사를 완료했어?'), findsOneWidget);
        }
        expect(h.progress.results, isEmpty);
        await h.close(tester);
      },
    );
  }

  for (final action in ['background', 'mute', 'dispose']) {
    testWidgets('Late voice after $action does not resurrect alarm', (
      tester,
    ) async {
      final h = _Harness();
      h.config = h.config.copyWith(motivationVideoEnabled: true);
      h.now = h.startedAt.add(const Duration(seconds: 30));
      h.motivation.playGate = Completer<void>();
      await h.mount(tester);
      await tester.pump(const Duration(milliseconds: 20));
      await tester.pump(motivationVoiceStartDelay);
      expect(h.motivation.plays, 1);
      await h.expire(tester);
      expect(h.audio.starts, 0);
      if (action == 'dispose') {
        await h.close(tester);
      } else {
        if (action == 'background') {
          tester.binding.handleAppLifecycleStateChanged(
            AppLifecycleState.paused,
          );
        } else {
          h.config = h.config.copyWith(soundEnabled: false);
          await h.mount(tester);
        }
        h.motivation.playGate!.complete();
        await tester.pump();
        expect(h.audio.starts, 0);
        if (action == 'background') {
          tester.binding.handleAppLifecycleStateChanged(
            AppLifecycleState.resumed,
          );
          await tester.pump();
        } else {
          h.config = h.config.copyWith(soundEnabled: true);
          await h.mount(tester);
        }
        expect(h.audio.starts, 1);
        await h.close(tester);
      }
      expect(h.audio.calls.last, 'stopAll');
    });
  }
}
