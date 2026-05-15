import 'package:shared_preferences/shared_preferences.dart';

import '../models/meal_timer_config.dart';

class LocalSettingsService {
  static const _durationMinutesKey = 'durationMinutes';
  static const _showRemainingTimeKey = 'showRemainingTime';
  static const _soundEnabledKey = 'soundEnabled';
  static const _keepScreenAwakeKey = 'keepScreenAwake';
  static const _motorcycleIdKey = 'motorcycleId';
  static const _childNameKey = 'childName';
  static const _avatarModeKey = 'avatarMode';
  static const _customAvatarImagePathKey = 'customAvatarImagePath';
  static const _avatarScaleKey = 'avatarScale';
  static const _avatarOffsetXKey = 'avatarOffsetX';
  static const _avatarOffsetYKey = 'avatarOffsetY';
  static const _avatarRotationDegreesKey = 'avatarRotationDegrees';

  Future<MealTimerConfig> loadConfig() async {
    final preferences = await SharedPreferences.getInstance();
    final defaults = MealTimerConfig.defaults();

    return defaults.copyWith(
      duration: Duration(
        minutes:
            preferences.getInt(_durationMinutesKey) ??
            defaults.duration.inMinutes,
      ),
      showRemainingTime:
          preferences.getBool(_showRemainingTimeKey) ??
          defaults.showRemainingTime,
      soundEnabled:
          preferences.getBool(_soundEnabledKey) ?? defaults.soundEnabled,
      keepScreenAwake:
          preferences.getBool(_keepScreenAwakeKey) ?? defaults.keepScreenAwake,
      motorcycleId:
          preferences.getString(_motorcycleIdKey) ?? defaults.motorcycleId,
      childName: preferences.getString(_childNameKey) ?? defaults.childName,
      avatarMode: _avatarModeFromString(preferences.getString(_avatarModeKey)),
      customAvatarImagePath: preferences.getString(_customAvatarImagePathKey),
      avatarScale:
          preferences.getDouble(_avatarScaleKey) ?? defaults.avatarScale,
      avatarOffsetX:
          preferences.getDouble(_avatarOffsetXKey) ?? defaults.avatarOffsetX,
      avatarOffsetY:
          preferences.getDouble(_avatarOffsetYKey) ?? defaults.avatarOffsetY,
      avatarRotationDegrees:
          preferences.getDouble(_avatarRotationDegreesKey) ??
          defaults.avatarRotationDegrees,
    );
  }

  Future<void> saveConfig(MealTimerConfig config) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(_durationMinutesKey, config.duration.inMinutes);
    await preferences.setBool(_showRemainingTimeKey, config.showRemainingTime);
    await preferences.setBool(_soundEnabledKey, config.soundEnabled);
    await preferences.setBool(_keepScreenAwakeKey, config.keepScreenAwake);
    await preferences.setString(_motorcycleIdKey, config.motorcycleId);
    await preferences.setString(_childNameKey, config.childName);
    await preferences.setString(
      _avatarModeKey,
      _avatarModeToString(config.avatarMode),
    );

    final customAvatarImagePath = config.customAvatarImagePath?.trim();
    if (customAvatarImagePath == null || customAvatarImagePath.isEmpty) {
      await preferences.remove(_customAvatarImagePathKey);
    } else {
      await preferences.setString(
        _customAvatarImagePathKey,
        customAvatarImagePath,
      );
    }

    await preferences.setDouble(_avatarScaleKey, config.avatarScale);
    await preferences.setDouble(_avatarOffsetXKey, config.avatarOffsetX);
    await preferences.setDouble(_avatarOffsetYKey, config.avatarOffsetY);
    await preferences.setDouble(
      _avatarRotationDegreesKey,
      config.avatarRotationDegrees,
    );
  }

  AvatarImageMode _avatarModeFromString(String? value) {
    return switch (value) {
      'custom' => AvatarImageMode.custom,
      _ => AvatarImageMode.defaultImage,
    };
  }

  String _avatarModeToString(AvatarImageMode mode) {
    return switch (mode) {
      AvatarImageMode.defaultImage => 'defaultImage',
      AvatarImageMode.custom => 'custom',
    };
  }
}
