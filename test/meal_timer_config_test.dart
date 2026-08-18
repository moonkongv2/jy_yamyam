import 'package:flutter_test/flutter_test.dart';

import 'package:jy_yamyam/models/meal_timer_config.dart';

void main() {
  test('Default config uses default avatar image settings', () {
    final config = MealTimerConfig.defaults();

    expect(config.avatarMode, AvatarImageMode.defaultImage);
    expect(config.customAvatarImagePath, isNull);
    expect(config.customAvatarVehicleId, isNull);
    expect(config.vehicleId, 'motorcycle');
    expect(config.soundEnabled, isTrue);
    expect(config.motivationVideoEnabled, isTrue);
    expect(config.motivationVideoUseCustomInterval, isFalse);
    expect(config.motivationVideoInterval, const Duration(minutes: 3));
    expect(config.courseIngredientMode, CourseIngredientMode.manual);
    expect(config.avatarScale, 1.0);
    expect(config.avatarOffsetX, 0.0);
    expect(config.avatarOffsetY, 0.0);
    expect(config.avatarRotationDegrees, 0.0);
    expect(config.customAvatarsByVehicle, isEmpty);
    expect(config.courseIngredientIds, isEmpty);
    expect(config.selectedCourseIngredientIds, isEmpty);
  });

  test(
    'MealTimerConfig copyWith preserves and updates course ingredient ids',
    () {
      final config = MealTimerConfig.defaults().copyWith(
        courseIngredientIds: const ['carrot', 'egg'],
        selectedCourseIngredientIds: const ['carrot'],
      );
      final preservedConfig = config.copyWith(vehicleId: 'bus');
      final updatedConfig = config.copyWith(
        courseIngredientIds: const ['rice', 'tomato'],
        selectedCourseIngredientIds: const ['rice'],
      );

      expect(preservedConfig.courseIngredientIds, ['carrot', 'egg']);
      expect(preservedConfig.selectedCourseIngredientIds, ['carrot']);
      expect(updatedConfig.courseIngredientIds, ['rice', 'tomato']);
      expect(updatedConfig.selectedCourseIngredientIds, ['rice']);
    },
  );

  test('MealTimerConfig copyWith updates motivation video settings', () {
    final config = MealTimerConfig.defaults().copyWith(
      motivationVideoEnabled: false,
      motivationVideoUseCustomInterval: true,
      motivationVideoInterval: const Duration(minutes: 5),
    );
    final preservedConfig = config.copyWith(vehicleId: 'bus');
    final updatedConfig = config.copyWith(
      motivationVideoEnabled: true,
      motivationVideoUseCustomInterval: false,
      motivationVideoInterval: const Duration(minutes: 10),
    );

    expect(preservedConfig.motivationVideoEnabled, isFalse);
    expect(preservedConfig.motivationVideoUseCustomInterval, isTrue);
    expect(preservedConfig.motivationVideoInterval, const Duration(minutes: 5));
    expect(updatedConfig.motivationVideoEnabled, isTrue);
    expect(updatedConfig.motivationVideoUseCustomInterval, isFalse);
    expect(updatedConfig.motivationVideoInterval, const Duration(minutes: 10));
  });

  test('MealTimerConfig copyWith updates course ingredient mode', () {
    final config = MealTimerConfig.defaults().copyWith(
      courseIngredientMode: CourseIngredientMode.random,
    );
    final preservedConfig = config.copyWith(vehicleId: 'bus');
    final updatedConfig = config.copyWith(
      courseIngredientMode: CourseIngredientMode.off,
    );

    expect(preservedConfig.courseIngredientMode, CourseIngredientMode.random);
    expect(updatedConfig.courseIngredientMode, CourseIngredientMode.off);
  });
}
