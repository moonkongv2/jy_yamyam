import 'package:flutter_test/flutter_test.dart';

import 'package:jy_yamyam/config/meal_timer_policy.dart';

void main() {
  group('MealTimerPolicy', () {
    test('uses a 5 minute minimum when short timers are not enabled', () {
      final range = MealTimerPolicy.rangeFor(
        isReleaseMode: false,
        allowShortTimer: false,
      );

      expect(range.minMinutes, 5);
    });

    test('keeps the maximum at 60 minutes', () {
      expect(MealTimerPolicy.maxMinutes, 60);
      expect(MealTimerPolicy.range.maxMinutes, 60);
    });

    test('normalizes minutes in the default range', () {
      const range = TimerDurationRange(minMinutes: 5, maxMinutes: 60);

      expect(range.normalizeMinutes(1), 5);
      expect(range.normalizeMinutes(4), 5);
      expect(range.normalizeMinutes(5), 5);
      expect(range.normalizeMinutes(60), 60);
      expect(range.normalizeMinutes(61), 60);
    });

    test('allows short timers only outside release mode', () {
      final debugRange = MealTimerPolicy.rangeFor(
        isReleaseMode: false,
        allowShortTimer: true,
      );
      final releaseRange = MealTimerPolicy.rangeFor(
        isReleaseMode: true,
        allowShortTimer: true,
      );

      expect(debugRange.minMinutes, 1);
      expect(releaseRange.minMinutes, 5);
    });
  });
}
