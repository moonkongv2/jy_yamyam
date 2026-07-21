import 'package:flutter/foundation.dart';

class TimerDurationRange {
  const TimerDurationRange({
    required this.minMinutes,
    required this.maxMinutes,
  });

  final int minMinutes;
  final int maxMinutes;

  int normalizeMinutes(int minutes) {
    return minutes.clamp(minMinutes, maxMinutes).toInt();
  }

  Duration normalizeDuration(Duration duration) {
    return Duration(minutes: normalizeMinutes(duration.inMinutes));
  }
}

abstract final class MealTimerPolicy {
  static const int productionMinMinutes = 5;
  static const int shortTestMinMinutes = 1;
  static const int maxMinutes = 60;

  static const bool _allowShortTimer = bool.fromEnvironment(
    'ALLOW_SHORT_TIMER',
    defaultValue: false,
  );

  static int get minMinutes => range.minMinutes;

  static TimerDurationRange get range {
    return rangeFor(
      isReleaseMode: kReleaseMode,
      allowShortTimer: _allowShortTimer,
    );
  }

  static TimerDurationRange rangeFor({
    required bool isReleaseMode,
    required bool allowShortTimer,
  }) {
    if (isReleaseMode) {
      return const TimerDurationRange(
        minMinutes: productionMinMinutes,
        maxMinutes: maxMinutes,
      );
    }

    return TimerDurationRange(
      minMinutes: allowShortTimer ? shortTestMinMinutes : productionMinMinutes,
      maxMinutes: maxMinutes,
    );
  }

  static int normalizeMinutes(int minutes) {
    return range.normalizeMinutes(minutes);
  }

  static Duration normalizeDuration(Duration duration) {
    return range.normalizeDuration(duration);
  }
}
