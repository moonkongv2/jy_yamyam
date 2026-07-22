import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jy_yamyam/controllers/meal_timer_controller.dart';
import 'package:jy_yamyam/controllers/timer_active_session_controller.dart';
import 'package:jy_yamyam/models/active_meal_timer_session.dart';
import 'package:jy_yamyam/models/meal_timer_config.dart';
import 'package:jy_yamyam/services/active_meal_timer_session_store.dart';

void main() {
  TimerActiveSessionController buildActiveSessionController({
    required MealTimerController timerController,
    ActiveMealTimerSessionStore store = const ActiveMealTimerSessionStore(),
    MealTimerConfig Function()? config,
    Set<int> Function()? shownMotivationMilestones,
    Duration? Function()? lastMotivationVideoShownAt,
    Duration Function()? motivationScheduleStartedAt,
  }) {
    return TimerActiveSessionController(
      timerController: timerController,
      store: store,
      sessionId: 'session-1',
      config: config ?? () => timerController.config,
      shownMotivationMilestones: shownMotivationMilestones ?? () => const {},
      lastMotivationVideoShownAt: lastMotivationVideoShownAt ?? () => null,
      motivationScheduleStartedAt:
          motivationScheduleStartedAt ?? () => Duration.zero,
    );
  }

  test('TimerActiveSessionController maps running sessions', () {
    final startedAt = DateTime.utc(2026, 6, 15, 10);
    final controller = MealTimerController(
      config: MealTimerConfig.defaults(),
      now: () => startedAt,
    )..start();
    final activeSessionController = buildActiveSessionController(
      timerController: controller,
    );

    final session = activeSessionController.snapshot();

    expect(session, isNotNull);
    expect(session!.sessionId, 'session-1');
    expect(session.startedAt, startedAt);
    expect(session.state, ActiveMealTimerSessionState.running);
    expect(session.pausedAt, isNull);

    controller.dispose();
  });

  test('TimerActiveSessionController normalizes snapshot config duration', () {
    final startedAt = DateTime.utc(2026, 6, 15, 10);
    final controller = MealTimerController(
      config: MealTimerConfig.defaults(),
      now: () => startedAt,
    )..start();
    final activeSessionController = buildActiveSessionController(
      timerController: controller,
      config: () => MealTimerConfig.defaults().copyWith(
        duration: const Duration(minutes: 1),
      ),
    );

    final session = activeSessionController.snapshot();

    expect(session, isNotNull);
    expect(session!.duration, const Duration(minutes: 5));

    controller.dispose();
  });

  test('TimerActiveSessionController maps paused sessions', () {
    var now = DateTime.utc(2026, 6, 15, 10);
    final controller = MealTimerController(
      config: MealTimerConfig.defaults(),
      now: () => now,
    )..start();
    now = DateTime.utc(2026, 6, 15, 10, 3);
    controller.pause();
    final activeSessionController = buildActiveSessionController(
      timerController: controller,
    );

    final session = activeSessionController.snapshot();

    expect(session, isNotNull);
    expect(session!.state, ActiveMealTimerSessionState.paused);
    expect(session.pausedAt, now);
    expect(session.totalPausedDuration, Duration.zero);

    controller.dispose();
  });

  test('TimerActiveSessionController maps arrived sessions', () {
    final startedAt = DateTime.utc(2026, 6, 15, 10);
    final controller = MealTimerController.fromSession(
      session: ActiveMealTimerSession(
        sessionId: 'session-1',
        startedAt: startedAt,
        config: MealTimerConfig.defaults(),
        state: ActiveMealTimerSessionState.arrived,
      ),
      now: () => startedAt.add(const Duration(minutes: 20)),
    );
    final activeSessionController = buildActiveSessionController(
      timerController: controller,
    );

    final session = activeSessionController.snapshot();

    expect(session, isNotNull);
    expect(session!.state, ActiveMealTimerSessionState.arrived);
    expect(session.pausedAt, isNull);

    controller.dispose();
  });

  test('TimerActiveSessionController skips idle and completed sessions', () {
    final now = DateTime.utc(2026, 6, 15, 10);
    final idleController = MealTimerController(
      config: MealTimerConfig.defaults(),
      now: () => now,
    );
    final idleActiveSessionController = buildActiveSessionController(
      timerController: idleController,
    );

    expect(idleActiveSessionController.snapshot(), isNull);

    final completedController = MealTimerController(
      config: MealTimerConfig.defaults(),
      now: () => now,
    )..start();
    completedController.complete();
    final completedActiveSessionController = buildActiveSessionController(
      timerController: completedController,
    );

    expect(completedActiveSessionController.snapshot(), isNull);

    idleController.dispose();
    completedController.dispose();
  });

  test(
    'TimerActiveSessionController includes motivation persistence fields',
    () {
      final now = DateTime.utc(2026, 6, 15, 10);
      final controller = MealTimerController(
        config: MealTimerConfig.defaults(),
        now: () => now,
      )..start();
      final activeSessionController = buildActiveSessionController(
        timerController: controller,
        shownMotivationMilestones: () => {10, 30},
        lastMotivationVideoShownAt: () => const Duration(minutes: 5),
        motivationScheduleStartedAt: () => const Duration(minutes: 2),
      );

      final session = activeSessionController.snapshot();

      expect(session, isNotNull);
      expect(session!.shownMotivationMilestones, {10, 30});
      expect(session.lastMotivationVideoShownAt, const Duration(minutes: 5));
      expect(session.motivationScheduleStartedAt, const Duration(minutes: 2));

      controller.dispose();
    },
  );

  test('TimerActiveSessionController persists and clears snapshots', () async {
    SharedPreferences.setMockInitialValues({});
    final store = ActiveMealTimerSessionStore();
    final now = DateTime.utc(2026, 6, 15, 10);
    final controller = MealTimerController(
      config: MealTimerConfig.defaults().copyWith(vehicleId: 'bus'),
      now: () => now,
    )..start();
    final activeSessionController = buildActiveSessionController(
      timerController: controller,
      store: store,
    );

    await activeSessionController.persist();

    final savedSession = await store.load();
    expect(savedSession, isNotNull);
    expect(savedSession!.sessionId, 'session-1');
    expect(savedSession.config.vehicleId, 'bus');

    await activeSessionController.clear();

    expect(await store.load(), isNull);

    controller.dispose();
  });
}
