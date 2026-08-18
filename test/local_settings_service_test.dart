import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jy_yamyam/models/meal_timer_config.dart';
import 'package:jy_yamyam/services/local_settings_service.dart';

void main() {
  test('Local settings saves and loads avatar settings', () async {
    SharedPreferences.setMockInitialValues({});

    final service = LocalSettingsService();
    await service.saveConfig(
      MealTimerConfig.defaults().copyWith(
        childName: '지율',
        vehicleId: 'police_car',
        avatarMode: AvatarImageMode.custom,
        customAvatarImagePath: '/local/avatar.png',
        customAvatarVehicleId: 'police_car',
        avatarScale: 1.25,
        avatarOffsetX: 8.0,
        avatarOffsetY: -6.0,
        avatarRotationDegrees: 12.0,
        courseIngredientIds: const ['carrot', 'egg'],
      ),
    );

    final loadedConfig = await service.loadConfig();
    final preferences = await SharedPreferences.getInstance();
    expect(loadedConfig.childName, '지율');
    expect(loadedConfig.vehicleId, 'police_car');
    expect(preferences.getString('vehicleId'), 'police_car');
    expect(loadedConfig.avatarMode, AvatarImageMode.custom);
    expect(loadedConfig.customAvatarImagePath, '/local/avatar.png');
    expect(loadedConfig.customAvatarVehicleId, 'police_car');
    expect(loadedConfig.avatarScale, 1.25);
    expect(loadedConfig.avatarOffsetX, 8.0);
    expect(loadedConfig.avatarOffsetY, -6.0);
    expect(loadedConfig.avatarRotationDegrees, 12.0);
    expect(loadedConfig.courseIngredientIds, isEmpty);
    expect(preferences.getStringList('courseIngredientIds'), isNull);
    final policeCarAvatar = loadedConfig.customAvatarConfigForVehicle(
      'police_car',
    );
    expect(policeCarAvatar?.imagePath, '/local/avatar.png');
    expect(policeCarAvatar?.scale, 1.25);
    expect(policeCarAvatar?.offsetX, 8.0);
    expect(policeCarAvatar?.offsetY, -6.0);
    expect(policeCarAvatar?.rotationDegrees, 12.0);
  });

  test('Local settings saves and loads motivation video settings', () async {
    SharedPreferences.setMockInitialValues({});

    final service = LocalSettingsService();
    await service.saveConfig(
      MealTimerConfig.defaults().copyWith(
        motivationVideoEnabled: false,
        motivationVideoUseCustomInterval: true,
        motivationVideoInterval: const Duration(minutes: 5),
      ),
    );

    final loadedConfig = await service.loadConfig();
    final preferences = await SharedPreferences.getInstance();
    expect(loadedConfig.motivationVideoEnabled, isFalse);
    expect(loadedConfig.motivationVideoUseCustomInterval, isTrue);
    expect(loadedConfig.motivationVideoInterval, const Duration(minutes: 5));
    expect(preferences.getBool('motivationVideoEnabled'), isFalse);
    expect(preferences.getBool('motivationVideoUseCustomInterval'), isTrue);
    expect(preferences.getInt('motivationVideoIntervalMinutes'), 5);
  });

  test(
    'Local settings normalizes stored meal durations below minimum',
    () async {
      SharedPreferences.setMockInitialValues({'durationMinutes': 4});

      final loadedConfig = await LocalSettingsService().loadConfig();

      expect(loadedConfig.duration, const Duration(minutes: 5));
    },
  );

  test(
    'Local settings normalizes stored meal durations above maximum',
    () async {
      SharedPreferences.setMockInitialValues({'durationMinutes': 61});

      final loadedConfig = await LocalSettingsService().loadConfig();

      expect(loadedConfig.duration, const Duration(minutes: 60));
    },
  );

  test('Local settings saves normalized meal durations', () async {
    SharedPreferences.setMockInitialValues({});

    final service = LocalSettingsService();
    await service.saveConfig(
      MealTimerConfig.defaults().copyWith(duration: const Duration(minutes: 1)),
    );

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getInt('durationMinutes'), 5);
  });

  test('Local settings saves and loads course ingredient mode', () async {
    SharedPreferences.setMockInitialValues({});

    final service = LocalSettingsService();
    await service.saveConfig(
      MealTimerConfig.defaults().copyWith(
        courseIngredientMode: CourseIngredientMode.random,
      ),
    );

    final loadedConfig = await service.loadConfig();
    final preferences = await SharedPreferences.getInstance();
    expect(loadedConfig.courseIngredientMode, CourseIngredientMode.random);
    expect(preferences.getString('courseIngredientMode'), 'random');
  });

  test('Local settings defaults first-run onboarding to unseen', () async {
    SharedPreferences.setMockInitialValues({});

    final service = LocalSettingsService();

    expect(await service.loadHasSeenFirstRunOnboarding(), isFalse);
  });

  test('Local settings saves and loads first-run onboarding state', () async {
    SharedPreferences.setMockInitialValues({});

    final service = LocalSettingsService();
    await service.saveHasSeenFirstRunOnboarding(true);

    final preferences = await SharedPreferences.getInstance();
    expect(await service.loadHasSeenFirstRunOnboarding(), isTrue);
    expect(preferences.getBool('hasSeenFirstRunOnboarding'), isTrue);
  });

  test(
    'Local settings falls back for invalid course ingredient mode',
    () async {
      SharedPreferences.setMockInitialValues({
        'courseIngredientMode': 'unknown',
      });

      final loadedConfig = await LocalSettingsService().loadConfig();

      expect(loadedConfig.courseIngredientMode, CourseIngredientMode.manual);
    },
  );

  test(
    'Local settings falls back for invalid motivation video interval',
    () async {
      SharedPreferences.setMockInitialValues({
        'motivationVideoEnabled': false,
        'motivationVideoUseCustomInterval': true,
        'motivationVideoIntervalMinutes': 0,
      });

      final loadedConfig = await LocalSettingsService().loadConfig();

      expect(loadedConfig.motivationVideoEnabled, isFalse);
      expect(loadedConfig.motivationVideoUseCustomInterval, isTrue);
      expect(loadedConfig.motivationVideoInterval, const Duration(minutes: 3));
    },
  );

  test('Local settings saves and loads vehicle avatar maps', () async {
    SharedPreferences.setMockInitialValues({});

    final service = LocalSettingsService();
    await service.saveConfig(
      MealTimerConfig.defaults().copyWith(
        avatarMode: AvatarImageMode.custom,
        vehicleId: 'bus',
        customAvatarsByVehicle: const {
          'bus': VehicleAvatarConfig(
            imagePath: '/local/bus.png',
            scale: 1.1,
            offsetX: 0.05,
            offsetY: -0.02,
            rotationDegrees: 3.0,
          ),
          'train': VehicleAvatarConfig(
            imagePath: '/local/train.png',
            scale: 1.2,
            offsetX: -0.04,
            offsetY: 0.03,
            rotationDegrees: -5.0,
          ),
        },
      ),
    );

    final loadedConfig = await service.loadConfig();
    expect(
      loadedConfig.customAvatarsByVehicle.keys,
      containsAll(['bus', 'train']),
    );
    expect(
      loadedConfig.customAvatarConfigForVehicle('bus')?.imagePath,
      '/local/bus.png',
    );
    expect(
      loadedConfig.customAvatarConfigForVehicle('train')?.rotationDegrees,
      -5.0,
    );
    expect(loadedConfig.customAvatarImagePath, '/local/bus.png');
    expect(loadedConfig.customAvatarVehicleId, 'bus');
  });

  test('Custom avatar image path can be cleared to null', () async {
    SharedPreferences.setMockInitialValues({});

    final service = LocalSettingsService();
    await service.saveConfig(
      MealTimerConfig.defaults().copyWith(
        avatarMode: AvatarImageMode.custom,
        customAvatarImagePath: '/local/avatar.png',
      ),
    );
    await service.saveConfig(
      MealTimerConfig.defaults().copyWith(customAvatarImagePath: null),
    );

    final loadedConfig = await service.loadConfig();
    final preferences = await SharedPreferences.getInstance();
    expect(loadedConfig.customAvatarImagePath, isNull);
    expect(preferences.getString('customAvatarImagePath'), isNull);
  });

  test(
    'Existing child name and vehicle settings load without avatar keys',
    () async {
      SharedPreferences.setMockInitialValues({
        'vehicleId': 'bus',
        'childName': '민준',
      });

      final config = await LocalSettingsService().loadConfig();

      expect(config.childName, '민준');
      expect(config.vehicleId, 'bus');
      expect(config.avatarMode, AvatarImageMode.defaultImage);
      expect(config.customAvatarImagePath, isNull);
      expect(config.customAvatarVehicleId, isNull);
    },
  );

  test(
    'Existing custom avatar settings infer vehicle id when missing',
    () async {
      SharedPreferences.setMockInitialValues({
        'vehicleId': 'police_car',
        'avatarMode': 'custom',
        'customAvatarImagePath': '/local/avatar.png',
      });

      final config = await LocalSettingsService().loadConfig();

      expect(config.avatarMode, AvatarImageMode.custom);
      expect(config.customAvatarImagePath, '/local/avatar.png');
      expect(config.customAvatarVehicleId, 'police_car');
      expect(
        config.customAvatarConfigForVehicle('police_car')?.imagePath,
        '/local/avatar.png',
      );
    },
  );

  test(
    'Malformed vehicle avatar map falls back to legacy avatar keys',
    () async {
      SharedPreferences.setMockInitialValues({
        'vehicleId': 'fire_truck',
        'avatarMode': 'custom',
        'customAvatarImagePath': '/local/fire-truck.png',
        'customAvatarVehicleId': 'fire_truck',
        'customAvatarsByVehicle': '{not-json',
      });

      final config = await LocalSettingsService().loadConfig();

      expect(config.customAvatarsByVehicle.keys, contains('fire_truck'));
      expect(
        config.customAvatarConfigForVehicle('fire_truck')?.imagePath,
        '/local/fire-truck.png',
      );
    },
  );
}
