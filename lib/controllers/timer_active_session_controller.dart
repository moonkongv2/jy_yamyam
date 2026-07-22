import 'package:flutter/foundation.dart';

import '../config/meal_timer_policy.dart';
import '../models/active_meal_timer_session.dart';
import '../models/meal_timer_config.dart';
import '../services/active_meal_timer_session_store.dart';
import 'meal_timer_controller.dart';

class TimerActiveSessionController {
  const TimerActiveSessionController({
    required MealTimerController timerController,
    required ActiveMealTimerSessionStore store,
    required String sessionId,
    required MealTimerConfig Function() config,
    required Set<int> Function() shownMotivationMilestones,
    required Duration? Function() lastMotivationVideoShownAt,
    required Duration Function() motivationScheduleStartedAt,
  }) : _timerController = timerController,
       _store = store,
       _sessionId = sessionId,
       _config = config,
       _shownMotivationMilestones = shownMotivationMilestones,
       _lastMotivationVideoShownAt = lastMotivationVideoShownAt,
       _motivationScheduleStartedAt = motivationScheduleStartedAt;

  final MealTimerController _timerController;
  final ActiveMealTimerSessionStore _store;
  final String _sessionId;
  final MealTimerConfig Function() _config;
  final Set<int> Function() _shownMotivationMilestones;
  final Duration? Function() _lastMotivationVideoShownAt;
  final Duration Function() _motivationScheduleStartedAt;

  ActiveMealTimerSession? snapshot() {
    final startedAt = _timerController.startedAt;
    if (startedAt == null ||
        _timerController.state == MealTimerState.completed) {
      return null;
    }

    return ActiveMealTimerSession(
      sessionId: _sessionId,
      startedAt: startedAt,
      config: _normalizeConfig(_config()),
      state: switch (_timerController.state) {
        MealTimerState.paused => ActiveMealTimerSessionState.paused,
        MealTimerState.arrived => ActiveMealTimerSessionState.arrived,
        _ => ActiveMealTimerSessionState.running,
      },
      totalPausedDuration: _timerController.totalPausedDuration,
      pausedAt: _timerController.pausedAt,
      shownMotivationMilestones: Set.unmodifiable(_shownMotivationMilestones()),
      lastMotivationVideoShownAt: _lastMotivationVideoShownAt(),
      motivationScheduleStartedAt: _motivationScheduleStartedAt(),
    );
  }

  Future<void> persist() async {
    final session = snapshot();
    if (session == null) {
      return;
    }

    try {
      await _store.save(session);
    } catch (error, stackTrace) {
      debugPrint('Unable to save active meal timer session: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> clear() async {
    try {
      await _store.clear();
    } catch (error, stackTrace) {
      debugPrint('Unable to clear active meal timer session: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}

MealTimerConfig _normalizeConfig(MealTimerConfig config) {
  final duration = MealTimerPolicy.normalizeDuration(config.duration);
  if (duration == config.duration) {
    return config;
  }

  return config.copyWith(duration: duration);
}
