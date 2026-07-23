import 'dart:async';

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
import 'package:jy_yamyam/services/timer_audio_service.dart';

void main() {
  testWidgets('timer BGM starts after preview and not on repeated ticks', (
    tester,
  ) async {
    final audioService = _FakeTimerAudioService();

    await _pumpTimer(tester, timerAudioService: audioService);

    expect(audioService.startOrResumeBgmCount, 0);

    await _finishCoursePreview(tester);

    expect(audioService.startOrResumeBgmCount, 1);

    await tester.pump(const Duration(milliseconds: 120));

    expect(audioService.startOrResumeBgmCount, 1);
  });

  testWidgets('sound disabled prevents timer BGM start', (tester) async {
    final audioService = _FakeTimerAudioService();

    await _pumpTimer(
      tester,
      timerAudioService: audioService,
      config: _timerConfig(soundEnabled: false),
    );
    await _finishCoursePreview(tester);

    expect(audioService.startOrResumeBgmCount, 0);
  });

  testWidgets('timer pause pauses BGM and resume resumes existing BGM', (
    tester,
  ) async {
    final audioService = _FakeTimerAudioService();

    await _pumpTimer(tester, timerAudioService: audioService);
    await _finishCoursePreview(tester);

    await tester.tap(find.text('일시정지'));
    await tester.pump();

    expect(audioService.pauseBgmCount, 1);

    await tester.pump(const Duration(milliseconds: 120));

    expect(audioService.pauseBgmCount, 1);

    await tester.tap(find.text('다시 출발'));
    await tester.pump();

    expect(audioService.startOrResumeBgmCount, 2);
  });

  testWidgets(
    'restored running session starts BGM and restored paused does not',
    (tester) async {
      var now = DateTime(2026, 1, 1, 8);
      final runningAudioService = _FakeTimerAudioService();
      final runningSession = ActiveMealTimerSession(
        sessionId: 'running-session',
        startedAt: now.subtract(const Duration(minutes: 1)),
        config: _timerConfig(),
        state: ActiveMealTimerSessionState.running,
      );

      await _pumpTimer(
        tester,
        now: () => now,
        restoredSession: runningSession,
        timerAudioService: runningAudioService,
      );
      await tester.pump();

      expect(runningAudioService.startOrResumeBgmCount, 1);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();

      final pausedAudioService = _FakeTimerAudioService();
      final pausedSession = ActiveMealTimerSession(
        sessionId: 'paused-session',
        startedAt: now.subtract(const Duration(minutes: 1)),
        config: _timerConfig(),
        state: ActiveMealTimerSessionState.paused,
        pausedAt: now,
      );

      await _pumpTimer(
        tester,
        now: () => now,
        restoredSession: pausedSession,
        timerAudioService: pausedAudioService,
      );
      await tester.pump();

      expect(pausedAudioService.startOrResumeBgmCount, 0);
    },
  );

  testWidgets('app lifecycle pauses and resumes timer BGM when still running', (
    tester,
  ) async {
    final audioService = _FakeTimerAudioService();

    await _pumpTimer(tester, timerAudioService: audioService);
    await _finishCoursePreview(tester);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();

    expect(audioService.pauseBgmCount, 1);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    expect(audioService.startOrResumeBgmCount, 2);
  });

  testWidgets('arrival stops timer BGM', (tester) async {
    final audioService = _FakeTimerAudioService();
    var now = DateTime(2026, 1, 1, 8);

    await _pumpTimer(tester, now: () => now, timerAudioService: audioService);
    await _finishCoursePreview(tester);

    now = now.add(const Duration(minutes: 6));
    await tester.pump(const Duration(milliseconds: 20));

    expect(audioService.stopBgmCount, 1);
  });

  testWidgets('confirmed exit waits for active session clear before leaving', (
    tester,
  ) async {
    final audioService = _FakeTimerAudioService();
    final store = _DelayedClearActiveSessionStore();

    await _pumpTimer(
      tester,
      activeSessionStore: store,
      timerAudioService: audioService,
    );
    await _finishCoursePreview(tester);

    expect(await store.load(), isNotNull);

    await tester.tap(find.byType(BackButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 320));
    await tester.tap(find.text('그만하기'));
    await tester.pump();

    expect(store.clearStarted, isTrue);
    expect(find.text('오늘의 냠냠코스'), findsOneWidget);
    expect(find.text('타이머 닫힘'), findsNothing);

    store.completeClear();
    await tester.pumpAndSettle();

    expect(find.text('타이머 닫힘'), findsOneWidget);
    expect(await store.load(), isNull);
  });

  testWidgets('course marker crossing plays one marker SFX', (tester) async {
    final audioService = _FakeTimerAudioService();
    var now = DateTime(2026, 1, 1, 8);

    await _pumpTimer(tester, now: () => now, timerAudioService: audioService);
    await _finishCoursePreview(tester);

    now = now.add(const Duration(seconds: 30));
    await tester.pump(const Duration(milliseconds: 20));
    await tester.pump();

    expect(audioService.playMarkerSfxCount, 1);

    await tester.pump(const Duration(milliseconds: 120));

    expect(audioService.playMarkerSfxCount, 1);
  });

  testWidgets(
    'course marker crossing does not play SFX when sound is disabled',
    (tester) async {
      final audioService = _FakeTimerAudioService();
      var now = DateTime(2026, 1, 1, 8);

      await _pumpTimer(
        tester,
        now: () => now,
        timerAudioService: audioService,
        config: _timerConfig(soundEnabled: false),
      );
      await _finishCoursePreview(tester);

      now = now.add(const Duration(seconds: 30));
      await tester.pump(const Duration(milliseconds: 20));
      await tester.pump();

      expect(audioService.playMarkerSfxCount, 0);
    },
  );

  testWidgets('timer sound toggle stops and restarts BGM while running', (
    tester,
  ) async {
    final audioService = _FakeTimerAudioService();
    final changedConfigs = <MealTimerConfig>[];

    await _pumpTimer(
      tester,
      timerAudioService: audioService,
      onConfigChanged: changedConfigs.add,
    );
    await _finishCoursePreview(tester);

    expect(audioService.startOrResumeBgmCount, 1);

    await tester.tap(find.byKey(const ValueKey('timerSoundToggleButton')));
    await tester.pump();

    expect(changedConfigs.last.soundEnabled, isFalse);
    expect(audioService.stopBgmCount, 1);

    await tester.tap(find.byKey(const ValueKey('timerSoundToggleButton')));
    await tester.pump();

    expect(changedConfigs.last.soundEnabled, isTrue);
    expect(audioService.startOrResumeBgmCount, 2);
  });

  testWidgets('timer sound toggle persists active session sound setting', (
    tester,
  ) async {
    final audioService = _FakeTimerAudioService();
    final store = _DelayedClearActiveSessionStore();

    await _pumpTimer(
      tester,
      activeSessionStore: store,
      timerAudioService: audioService,
    );
    await _finishCoursePreview(tester);

    await tester.tap(find.byKey(const ValueKey('timerSoundToggleButton')));
    await tester.pump();

    expect((await store.load())?.config.soundEnabled, isFalse);
  });
}

MealTimerConfig _timerConfig({bool soundEnabled = true}) {
  return MealTimerConfig.defaults().copyWith(
    duration: const Duration(minutes: 5),
    soundEnabled: soundEnabled,
  );
}

Future<void> _pumpTimer(
  WidgetTester tester, {
  MealTimerConfig? config,
  DateTime Function()? now,
  ActiveMealTimerSession? restoredSession,
  ActiveMealTimerSessionStore? activeSessionStore,
  ValueChanged<MealTimerConfig>? onConfigChanged,
  required TimerAudioService timerAudioService,
}) async {
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
      locale: const Locale('ko'),
      home: Navigator(
        onGenerateRoute: (_) => MaterialPageRoute(
          builder: (_) => const Scaffold(body: Center(child: Text('타이머 닫힘'))),
        ),
        onGenerateInitialRoutes: (navigator, initialRoute) {
          return [
            MaterialPageRoute<void>(
              builder: (_) =>
                  const Scaffold(body: Center(child: Text('타이머 닫힘'))),
            ),
            MaterialPageRoute<void>(
              builder: (_) => TimerScreen(
                config: config ?? _timerConfig(),
                restoredSession: restoredSession,
                mealProgressService: LocalMealProgressService(),
                activeSessionStore:
                    activeSessionStore ?? const ActiveMealTimerSessionStore(),
                timerAudioService: timerAudioService,
                now: now,
                onConfigChanged: onConfigChanged ?? (_) {},
              ),
            ),
          ];
        },
      ),
    ),
  );
  await tester.pump();
}

Future<void> _finishCoursePreview(WidgetTester tester) async {
  for (var i = 0; i < 8; i += 1) {
    await tester.pump(const Duration(milliseconds: 250));
  }
  await tester.pump();
}

class _FakeTimerAudioService implements TimerAudioService {
  var startOrResumeBgmCount = 0;
  var pauseBgmCount = 0;
  var stopBgmCount = 0;
  var playMarkerSfxCount = 0;
  var stopAllCount = 0;
  var disposeCount = 0;

  @override
  Future<void> startOrResumeBgm() async {
    startOrResumeBgmCount += 1;
  }

  @override
  Future<void> pauseBgm() async {
    pauseBgmCount += 1;
  }

  @override
  Future<void> stopBgm() async {
    stopBgmCount += 1;
  }

  @override
  Future<void> playMarkerSfx() async {
    playMarkerSfxCount += 1;
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

class _DelayedClearActiveSessionStore extends ActiveMealTimerSessionStore {
  ActiveMealTimerSession? _session;
  Completer<void>? _clearCompleter;

  bool get clearStarted => _clearCompleter != null;

  @override
  Future<void> save(ActiveMealTimerSession session) async {
    _session = session;
  }

  @override
  Future<ActiveMealTimerSession?> load() async {
    return _session;
  }

  @override
  Future<void> clear() async {
    _clearCompleter = Completer<void>();
    await _clearCompleter!.future;
    _session = null;
  }

  void completeClear() {
    _clearCompleter?.complete();
  }
}
