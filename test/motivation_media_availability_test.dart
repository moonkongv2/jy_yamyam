import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jy_yamyam/config/app_feature_flags.dart';
import 'package:jy_yamyam/l10n/app_texts.dart';
import 'package:jy_yamyam/models/active_meal_timer_session.dart';
import 'package:jy_yamyam/models/meal_timer_config.dart';
import 'package:jy_yamyam/screens/settings_screen.dart';
import 'package:jy_yamyam/screens/timer_screen.dart';
import 'package:jy_yamyam/screens/user_guide_screen.dart';
import 'package:jy_yamyam/services/local_meal_progress_service.dart';
import 'package:jy_yamyam/services/motivation_audio_service.dart';

void main() {
  test('motivation media availability defaults to false', () {
    expect(AppFeatureFlags.motivationMediaAvailable, isFalse);
  });

  testWidgets('Settings hides motivation section when unavailable', (
    tester,
  ) async {
    MealTimerConfig? changedConfig;
    final config = MealTimerConfig.defaults().copyWith(
      motivationVideoEnabled: true,
      motivationVideoUseCustomInterval: true,
    );

    await tester.pumpWidget(
      _localizedApp(
        home: SettingsScreen(
          config: config,
          motivationMediaAvailable: false,
          onConfigChanged: (value) => changedConfig = value,
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('motivationVideoHelpButton')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('motivationVideoEnabledSwitch')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('motivationVideoCustomIntervalSwitch')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('motivationVideoIntervalSegmentedButton')),
      findsNothing,
    );

    await tester.scrollUntilVisible(
      find.text('남은 시간 보여주기'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    final remainingSwitch = tester.widget<SwitchListTile>(
      find.widgetWithText(SwitchListTile, '남은 시간 보여주기'),
    );
    remainingSwitch.onChanged!(false);
    await tester.pump();

    expect(changedConfig?.motivationVideoEnabled, isTrue);
  });

  testWidgets('Settings shows motivation section when explicitly available', (
    tester,
  ) async {
    await tester.pumpWidget(
      _localizedApp(
        home: SettingsScreen(
          config: MealTimerConfig.defaults().copyWith(
            motivationVideoUseCustomInterval: true,
          ),
          motivationMediaAvailable: true,
          onConfigChanged: (_) {},
        ),
      ),
    );

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('motivationVideoHelpButton')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('motivationVideoHelpButton')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('motivationVideoEnabledSwitch')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('motivationVideoCustomIntervalSwitch')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('motivationVideoIntervalSegmentedButton')),
      findsOneWidget,
    );
  });

  testWidgets('User guide hides motivation section when unavailable', (
    tester,
  ) async {
    await tester.pumpWidget(
      _localizedApp(
        locale: const Locale('en'),
        home: const UserGuideScreen(motivationMediaAvailable: false),
      ),
    );

    expect(find.text('Motivation videos'), findsNothing);
    expect(
      find.text('Review ingredients, motivation videos, and sticker rules.'),
      findsOneWidget,
    );
  });

  testWidgets('User guide shows motivation section when explicitly available', (
    tester,
  ) async {
    await tester.pumpWidget(
      _localizedApp(
        locale: const Locale('en'),
        home: const UserGuideScreen(motivationMediaAvailable: true),
      ),
    );

    await tester.scrollUntilVisible(
      find.text('Motivation videos'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Motivation videos'), findsOneWidget);
  });

  testWidgets('Timer portrait hides motivation settings when unavailable', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(600, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await _pumpTimer(tester, motivationMediaAvailable: false);

    expect(
      find.byKey(const ValueKey('motivationSettingsButton')),
      findsNothing,
    );
    expect(find.byIcon(Icons.video_settings_rounded), findsNothing);
  });

  testWidgets('Timer landscape hides motivation settings when unavailable', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await _pumpTimer(tester, motivationMediaAvailable: false);

    expect(
      find.byKey(const ValueKey('motivationSettingsButton')),
      findsNothing,
    );
    expect(find.byIcon(Icons.video_settings_rounded), findsNothing);
  });

  testWidgets(
    'Timer compact landscape hides motivation settings when unavailable',
    (tester) async {
      tester.view.physicalSize = const Size(852, 393);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await _pumpTimer(tester, motivationMediaAvailable: false);

      expect(
        find.byKey(const ValueKey('compactLandscapeControls')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('motivationSettingsButton')),
        findsNothing,
      );
      expect(find.byIcon(Icons.video_settings_rounded), findsNothing);
    },
  );

  testWidgets('Timer does not activate cues or audio when unavailable', (
    tester,
  ) async {
    final audioService = _FakeMotivationAudioService();
    var now = DateTime(2026);

    await _pumpTimer(
      tester,
      now: () => now,
      motivationMediaAvailable: false,
      motivationAudioService: audioService,
      config: MealTimerConfig.defaults().copyWith(
        duration: const Duration(seconds: 100),
        soundEnabled: true,
        motivationVideoEnabled: true,
      ),
    );
    await _finishCoursePreview(tester);

    now = now.add(const Duration(seconds: 15));
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pump(motivationVoiceStartDelay);

    expect(
      find.byKey(const ValueKey('motivationVideoBubble_10')),
      findsNothing,
    );
    expect(audioService.playedAssets, isEmpty);
  });

  testWidgets('Restored enabled session remains blocked when unavailable', (
    tester,
  ) async {
    var now = DateTime(2026, 1, 1, 8);
    final session = ActiveMealTimerSession(
      sessionId: 'session-1',
      startedAt: now,
      config: MealTimerConfig.defaults().copyWith(
        duration: const Duration(seconds: 100),
        soundEnabled: true,
        motivationVideoEnabled: true,
      ),
      state: ActiveMealTimerSessionState.running,
      shownMotivationMilestones: const {10},
      lastMotivationVideoShownAt: const Duration(seconds: 15),
      motivationScheduleStartedAt: Duration.zero,
    );
    now = now.add(const Duration(seconds: 25));

    await _pumpTimer(
      tester,
      now: () => now,
      restoredSession: session,
      motivationMediaAvailable: false,
      config: session.config,
    );
    await tester.pump(const Duration(milliseconds: 250));

    expect(
      find.byKey(const ValueKey('motivationVideoBubble_20')),
      findsNothing,
    );
  });

  testWidgets('Timer motivation remains available when explicitly enabled', (
    tester,
  ) async {
    var now = DateTime(2026);

    await _pumpTimer(
      tester,
      now: () => now,
      motivationMediaAvailable: true,
      config: MealTimerConfig.defaults().copyWith(
        duration: const Duration(seconds: 100),
        soundEnabled: false,
      ),
    );
    await _finishCoursePreview(tester);

    now = now.add(const Duration(seconds: 10));
    await tester.pump(const Duration(milliseconds: 250));

    expect(
      find.byKey(const ValueKey('motivationVideoBubble_10')),
      findsOneWidget,
    );
  });
}

Widget _localizedApp({
  required Widget home,
  Locale locale = const Locale('ko'),
}) {
  return MaterialApp(
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    supportedLocales: AppTexts.supportedLocales,
    locale: locale,
    home: home,
  );
}

Future<void> _pumpTimer(
  WidgetTester tester, {
  required bool motivationMediaAvailable,
  MealTimerConfig? config,
  DateTime Function()? now,
  MotivationAudioService? motivationAudioService,
  ActiveMealTimerSession? restoredSession,
}) async {
  await tester.pumpWidget(
    _localizedApp(
      home: TimerScreen(
        config: config ?? MealTimerConfig.defaults(),
        restoredSession: restoredSession,
        mealProgressService: LocalMealProgressService(),
        motivationMediaAvailable: motivationMediaAvailable,
        motivationAudioService: motivationAudioService,
        now: now,
        onConfigChanged: (_) {},
      ),
    ),
  );
  await tester.pump();
}

Future<void> _finishCoursePreview(WidgetTester tester) async {
  await tester.pump();
  for (var i = 0; i < 30; i += 1) {
    await tester.pump(const Duration(milliseconds: 250));
  }
  await tester.pump();
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
