enum AvatarImageMode { defaultImage, custom }

const Object _customAvatarImagePathUnset = Object();

class MealTimerConfig {
  const MealTimerConfig({
    required this.duration,
    required this.showRemainingTime,
    required this.soundEnabled,
    required this.keepScreenAwake,
    required this.courseId,
    required this.motorcycleId,
    required this.childName,
    required this.avatarMode,
    required this.customAvatarImagePath,
    required this.avatarScale,
    required this.avatarOffsetX,
    required this.avatarOffsetY,
    required this.avatarRotationDegrees,
  });

  factory MealTimerConfig.defaults() {
    return const MealTimerConfig(
      duration: Duration(minutes: 25),
      showRemainingTime: true,
      soundEnabled: false,
      keepScreenAwake: false,
      courseId: 'park',
      motorcycleId: 'motorcycle',
      childName: '',
      avatarMode: AvatarImageMode.defaultImage,
      customAvatarImagePath: null,
      avatarScale: 1.0,
      avatarOffsetX: 0.0,
      avatarOffsetY: 0.0,
      avatarRotationDegrees: 0.0,
    );
  }

  final Duration duration;
  final bool showRemainingTime;
  final bool soundEnabled;
  final bool keepScreenAwake;
  final String courseId;
  final String motorcycleId;
  final String childName;
  final AvatarImageMode avatarMode;
  final String? customAvatarImagePath;
  final double avatarScale;
  final double avatarOffsetX;
  final double avatarOffsetY;
  final double avatarRotationDegrees;

  MealTimerConfig copyWith({
    Duration? duration,
    bool? showRemainingTime,
    bool? soundEnabled,
    bool? keepScreenAwake,
    String? courseId,
    String? motorcycleId,
    String? childName,
    AvatarImageMode? avatarMode,
    Object? customAvatarImagePath = _customAvatarImagePathUnset,
    double? avatarScale,
    double? avatarOffsetX,
    double? avatarOffsetY,
    double? avatarRotationDegrees,
  }) {
    return MealTimerConfig(
      duration: duration ?? this.duration,
      showRemainingTime: showRemainingTime ?? this.showRemainingTime,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      keepScreenAwake: keepScreenAwake ?? this.keepScreenAwake,
      courseId: courseId ?? this.courseId,
      motorcycleId: motorcycleId ?? this.motorcycleId,
      childName: childName ?? this.childName,
      avatarMode: avatarMode ?? this.avatarMode,
      customAvatarImagePath:
          customAvatarImagePath == _customAvatarImagePathUnset
          ? this.customAvatarImagePath
          : customAvatarImagePath as String?,
      avatarScale: avatarScale ?? this.avatarScale,
      avatarOffsetX: avatarOffsetX ?? this.avatarOffsetX,
      avatarOffsetY: avatarOffsetY ?? this.avatarOffsetY,
      avatarRotationDegrees:
          avatarRotationDegrees ?? this.avatarRotationDegrees,
    );
  }
}
