import '../models/meal_timer_config.dart';
import '../utils/motivation_video_schedule.dart' as motivation_schedule;

const _defaultMinimumVideoInterval = Duration(seconds: 10);

typedef MotivationVideoAssetSelector =
    String? Function({
      required String vehicleId,
      required int milestone,
      int Function(int max)? nextInt,
      required bool allowTimedMilestone,
    });

class MotivationCue {
  const MotivationCue({required this.milestone, required this.videoPath});

  final int milestone;
  final String videoPath;
}

class MotivationCueController {
  MotivationCueController({
    Set<int> shownMilestones = const {},
    Duration? lastShownAt,
    Duration scheduleStartedAt = Duration.zero,
  }) : _shownMilestones = {...shownMilestones},
       _lastShownAt = lastShownAt,
       _scheduleStartedAt = scheduleStartedAt;

  final Set<int> _shownMilestones;
  int? _activeMilestone;
  String? _activeVideoPath;
  Duration? _lastShownAt;
  Duration _scheduleStartedAt;

  Set<int> get shownMilestones => Set.unmodifiable(_shownMilestones);
  int? get activeMilestone => _activeMilestone;
  String? get activeVideoPath => _activeVideoPath;
  Duration? get lastShownAt => _lastShownAt;
  Duration get scheduleStartedAt => _scheduleStartedAt;
  bool get hasActiveCue => _activeMilestone != null;

  MotivationCue? maybeActivateCue({
    required MealTimerConfig config,
    required Duration elapsed,
    required double progress,
    required MotivationVideoAssetSelector videoPathForVehicle,
    int Function(int max)? nextInt,
    Duration minimumInterval = _defaultMinimumVideoInterval,
  }) {
    if (_activeMilestone != null) {
      return null;
    }

    final schedule = motivation_schedule.MotivationVideoSchedule.fromConfig(
      config,
    );
    final usesTimedSchedule = schedule.usesTimedSchedule(config.duration);
    final milestone = schedule.nextMilestoneForTimer(
      duration: config.duration,
      elapsed: elapsed,
      progress: progress,
      shownMilestones: _shownMilestones,
      scheduleStartedAt: _scheduleStartedAt,
    );
    if (milestone == null) {
      return null;
    }
    if (!_canShowAt(
      elapsed: elapsed,
      lastShownAt: _lastShownAt,
      minimumInterval: minimumInterval,
    )) {
      return null;
    }

    final videoPath = videoPathForVehicle(
      vehicleId: config.vehicleId,
      milestone: milestone,
      nextInt: nextInt,
      allowTimedMilestone: usesTimedSchedule,
    );
    if (videoPath == null) {
      return null;
    }

    _shownMilestones.add(milestone);
    _lastShownAt = elapsed;
    _activeMilestone = milestone;
    _activeVideoPath = videoPath;
    return MotivationCue(milestone: milestone, videoPath: videoPath);
  }

  void completeActiveCue() {
    _activeMilestone = null;
    _activeVideoPath = null;
  }

  void updateSettings({
    required MealTimerConfig config,
    required Duration elapsed,
    required double progress,
  }) {
    final schedule = motivation_schedule.MotivationVideoSchedule.fromConfig(
      config,
    );
    _scheduleStartedAt = elapsed;
    _lastShownAt = elapsed;
    _shownMilestones
      ..clear()
      ..addAll(_shownMilestonesForCurrentSchedule(schedule, config, progress));
    if (!config.motivationVideoEnabled) {
      completeActiveCue();
    }
  }

  Iterable<int> _shownMilestonesForCurrentSchedule(
    motivation_schedule.MotivationVideoSchedule schedule,
    MealTimerConfig config,
    double progress,
  ) {
    if (schedule.usesTimedSchedule(config.duration)) {
      return const [];
    }

    final reachedPercent = (progress * 100).floor();
    return [
      for (var milestone = 10; milestone <= 90; milestone += 10)
        if (reachedPercent >= milestone) milestone,
    ];
  }

  bool _canShowAt({
    required Duration elapsed,
    required Duration? lastShownAt,
    required Duration minimumInterval,
  }) {
    if (lastShownAt == null) {
      return elapsed >= minimumInterval;
    }

    return elapsed - lastShownAt >= minimumInterval;
  }
}
