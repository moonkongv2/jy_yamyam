import 'package:flutter_test/flutter_test.dart';

import 'package:jy_yamyam/controllers/meal_timer_controller.dart';
import 'package:jy_yamyam/controllers/motivation_cue_controller.dart';
import 'package:jy_yamyam/controllers/timer_active_session_controller.dart';
import 'package:jy_yamyam/models/active_meal_timer_session.dart';
import 'package:jy_yamyam/models/meal_timer_config.dart';
import 'package:jy_yamyam/services/active_meal_timer_session_store.dart';

void main() {
  test('MotivationCueController activates at a valid milestone', () {
    final controller = MotivationCueController();

    final cue = controller.maybeActivateCue(
      config: MealTimerConfig.defaults().copyWith(
        duration: const Duration(seconds: 100),
      ),
      elapsed: const Duration(seconds: 11),
      progress: 0.11,
      videoPathForVehicle: _videoPathForVehicle,
    );

    expect(cue, isNotNull);
    expect(cue!.milestone, 10);
    expect(cue.videoPath, 'video-10.mp4');
    expect(controller.activeMilestone, 10);
    expect(controller.activeVideoPath, 'video-10.mp4');
    expect(controller.shownMilestones, {10});
    expect(controller.lastShownAt, const Duration(seconds: 11));
  });

  test('MotivationCueController ignores invalid or disabled milestones', () {
    final controller = MotivationCueController();

    expect(
      controller.maybeActivateCue(
        config: MealTimerConfig.defaults(),
        elapsed: const Duration(seconds: 15),
        progress: 0.05,
        videoPathForVehicle: _videoPathForVehicle,
      ),
      isNull,
    );
    expect(
      controller.maybeActivateCue(
        config: MealTimerConfig.defaults().copyWith(
          motivationVideoEnabled: false,
        ),
        elapsed: const Duration(seconds: 30),
        progress: 0.2,
        videoPathForVehicle: _videoPathForVehicle,
      ),
      isNull,
    );
  });

  test('MotivationCueController respects the minimum interval', () {
    final controller = MotivationCueController();
    final config = MealTimerConfig.defaults().copyWith(
      duration: const Duration(seconds: 100),
    );

    expect(
      controller.maybeActivateCue(
        config: config,
        elapsed: const Duration(seconds: 11),
        progress: 0.11,
        videoPathForVehicle: _videoPathForVehicle,
      ),
      isNotNull,
    );
    controller.completeActiveCue();

    expect(
      controller.maybeActivateCue(
        config: config,
        elapsed: const Duration(seconds: 15),
        progress: 0.2,
        videoPathForVehicle: _videoPathForVehicle,
      ),
      isNull,
    );

    final nextCue = controller.maybeActivateCue(
      config: config,
      elapsed: const Duration(seconds: 21),
      progress: 0.21,
      videoPathForVehicle: _videoPathForVehicle,
    );

    expect(nextCue, isNotNull);
    expect(nextCue!.milestone, 20);
  });

  test('MotivationCueController clears the active cue when finished', () {
    final controller = MotivationCueController();

    controller.maybeActivateCue(
      config: MealTimerConfig.defaults().copyWith(
        duration: const Duration(seconds: 100),
      ),
      elapsed: const Duration(seconds: 11),
      progress: 0.11,
      videoPathForVehicle: _videoPathForVehicle,
    );
    controller.completeActiveCue();

    expect(controller.activeMilestone, isNull);
    expect(controller.activeVideoPath, isNull);
    expect(controller.hasActiveCue, isFalse);
  });

  test('MotivationCueController resets state when video settings change', () {
    final controller = MotivationCueController();
    final config = MealTimerConfig.defaults().copyWith(
      duration: const Duration(seconds: 100),
    );

    controller.maybeActivateCue(
      config: config,
      elapsed: const Duration(seconds: 11),
      progress: 0.11,
      videoPathForVehicle: _videoPathForVehicle,
    );
    controller.updateSettings(
      config: config.copyWith(motivationVideoEnabled: false),
      elapsed: const Duration(seconds: 50),
      progress: 0.55,
    );

    expect(controller.hasActiveCue, isFalse);
    expect(controller.scheduleStartedAt, const Duration(seconds: 50));
    expect(controller.lastShownAt, const Duration(seconds: 50));
    expect(controller.shownMilestones, {10, 20, 30, 40, 50});

    controller.updateSettings(
      config: config.copyWith(motivationVideoUseCustomInterval: true),
      elapsed: const Duration(seconds: 60),
      progress: 0.6,
    );

    expect(controller.shownMilestones, isEmpty);
    expect(controller.scheduleStartedAt, const Duration(seconds: 60));
  });

  test('MotivationCueController restored state can be snapshotted', () {
    final cueController = MotivationCueController(
      shownMilestones: const {10, 20},
      lastShownAt: const Duration(minutes: 6),
      scheduleStartedAt: const Duration(minutes: 1),
    );
    final now = DateTime.utc(2026, 6, 15, 10);
    final timerController = MealTimerController(
      config: MealTimerConfig.defaults(),
      now: () => now,
    )..start();
    final activeSessionController = TimerActiveSessionController(
      timerController: timerController,
      store: const ActiveMealTimerSessionStore(),
      sessionId: 'session-1',
      config: () => timerController.config,
      shownMotivationMilestones: () => cueController.shownMilestones,
      lastMotivationVideoShownAt: () => cueController.lastShownAt,
      motivationScheduleStartedAt: () => cueController.scheduleStartedAt,
    );

    final session = activeSessionController.snapshot();

    expect(session, isNotNull);
    expect(session!.state, ActiveMealTimerSessionState.running);
    expect(session.shownMotivationMilestones, {10, 20});
    expect(session.lastMotivationVideoShownAt, const Duration(minutes: 6));
    expect(session.motivationScheduleStartedAt, const Duration(minutes: 1));

    timerController.dispose();
  });
}

String? _videoPathForVehicle({
  required String vehicleId,
  required int milestone,
  int Function(int max)? nextInt,
  bool allowTimedMilestone = false,
}) {
  return 'video-$milestone.mp4';
}
