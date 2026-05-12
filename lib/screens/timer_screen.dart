import 'package:flutter/material.dart';

import '../catalogs/vehicle_catalog.dart';
import '../controllers/meal_timer_controller.dart';
import '../l10n/app_texts.dart';
import '../models/meal_session_result.dart';
import '../models/meal_timer_config.dart';
import '../services/local_meal_progress_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import '../utils/duration_format.dart';
import '../widgets/road_view.dart';
import '../widgets/timer_control_bar.dart';
import 'result_screen.dart';

const _motivationVideoByMilestone = {
  10: 'assets/videos/motivation_10.mp4',
  20: 'assets/videos/motivation_10.mp4',
  30: 'assets/videos/motivation_10.mp4',
  40: 'assets/videos/motivation_10.mp4',
  50: 'assets/videos/motivation_10.mp4',
  60: 'assets/videos/motivation_10.mp4',
  70: 'assets/videos/motivation_10.mp4',
  80: 'assets/videos/motivation_10.mp4',
  90: 'assets/videos/motivation_10.mp4',
  // 20: 'assets/videos/motivation_20.mp4',
  // 30: 'assets/videos/motivation_30.mp4',
  // 40: 'assets/videos/motivation_40.mp4',
  // 50: 'assets/videos/motivation_50.mp4',
  // 60: 'assets/videos/motivation_60.mp4',
  // 70: 'assets/videos/motivation_70.mp4',
  // 80: 'assets/videos/motivation_80.mp4',
  // 90: 'assets/videos/motivation_90.mp4',
};

class TimerScreen extends StatefulWidget {
  const TimerScreen({
    super.key,
    required this.config,
    required this.mealProgressService,
    required this.onConfigChanged,
  });

  final MealTimerConfig config;
  final LocalMealProgressService mealProgressService;
  final ValueChanged<MealTimerConfig> onConfigChanged;

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  late final MealTimerController _controller;
  final Set<int> _shownMotivationMilestones = {};
  bool _arrivalPromptShown = false;
  int? _activeMotivationMilestone;
  String? _activeMotivationVideoPath;

  @override
  void initState() {
    super.initState();
    _controller = MealTimerController(config: widget.config);
    _controller.addListener(_handleTimerChanged);
    _controller.start();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTimerChanged() {
    _maybeShowMotivationVideo();

    if (_arrivalPromptShown ||
        _controller.state != MealTimerState.arrived ||
        !mounted) {
      return;
    }

    _arrivalPromptShown = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 900));
      if (!mounted) {
        return;
      }
      _confirmComplete(showFailureOnDecline: true);
    });
  }

  void _maybeShowMotivationVideo() {
    if (!mounted || _controller.progress >= 1) {
      return;
    }

    final milestone = (_controller.progress * 10).floor() * 10;
    if (milestone < 10 || milestone > 90) {
      return;
    }

    if (!_shownMotivationMilestones.add(milestone)) {
      return;
    }

    if (_activeMotivationMilestone != null) {
      return;
    }

    final videoPath = _motivationVideoByMilestone[milestone];
    if (videoPath == null) {
      return;
    }

    setState(() {
      _activeMotivationMilestone = milestone;
      _activeMotivationVideoPath = videoPath;
    });
  }

  void _handleMotivationVideoFinished() {
    if (!mounted || _activeMotivationMilestone == null) {
      return;
    }

    setState(() {
      _activeMotivationMilestone = null;
      _activeMotivationVideoPath = null;
    });
  }

  Future<void> _confirmComplete({bool showFailureOnDecline = false}) async {
    final texts = AppTexts.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: !showFailureOnDecline,
      builder: (context) {
        return AlertDialog(
          title: Text(texts.timer.completeDialogTitle),
          content: Text(
            showFailureOnDecline
                ? texts.timer.arrivalDialogMessage
                : texts.timer.completeDialogMessage,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(texts.common.notYet),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(texts.common.complete),
            ),
          ],
        );
      },
    );

    if (!mounted) {
      return;
    }

    if (confirmed != true) {
      if (showFailureOnDecline) {
        final result = _controller.complete(mealCompleted: false);
        _openResult(result);
      }
      return;
    }

    final result = _controller.complete();
    _openResult(result);
  }

  void _openResult(MealSessionResult result) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          result: result,
          config: widget.config,
          mealProgressService: widget.mealProgressService,
          onConfigChanged: widget.onConfigChanged,
        ),
      ),
    );
  }

  String _progressMessage(double progress) {
    if (progress < 0.25) {
      return '출발했어요!';
    }
    if (progress < 0.5) {
      return '잘 가고 있어요!';
    }
    if (progress < 0.8) {
      return '벌써 많이 왔어요!';
    }
    if (progress < 1.0) {
      return '거의 도착했어요!';
    }
    return '도착했어요!';
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppTexts.of(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final vehicle = VehicleCatalog.findById(widget.config.motorcycleId);
        final progress = _controller.progress.clamp(0.0, 1.0).toDouble();

        return Scaffold(
          backgroundColor: AppColors.cream,
          appBar: AppBar(
            title: Text(texts.timer.courseTitle),
            backgroundColor: AppColors.cream,
            foregroundColor: AppColors.brown900,
            elevation: 0,
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.sm,
                AppSpacing.xl,
                AppSpacing.xl,
              ),
              child: Column(
                children: [
                  _ProgressMessageCard(
                    message: _progressMessage(progress),
                    progress: progress,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Expanded(
                    child: RoadView(
                      progress: progress,
                      vehicle: vehicle,
                      motivationVideoAssetPath: _activeMotivationVideoPath,
                      motivationVideoMilestone: _activeMotivationMilestone,
                      onMotivationVideoFinished: _handleMotivationVideoFinished,
                    ),
                  ),
                  if (widget.config.showRemainingTime) ...[
                    const SizedBox(height: AppSpacing.lg),
                    _RemainingTimeCard(remaining: _controller.remaining),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  TimerControlBar(
                    isPaused: _controller.isPaused,
                    onPauseResume: () {
                      if (_controller.isPaused) {
                        _controller.resume();
                      } else {
                        _controller.pause();
                      }
                    },
                    onComplete: _confirmComplete,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProgressMessageCard extends StatelessWidget {
  const _ProgressMessageCard({required this.message, required this.progress});

  final String message;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.panel,
        border: Border.all(color: AppColors.creamDark),
        boxShadow: AppShadows.soft,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.yellow, AppColors.orange],
                ),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const SizedBox(
                width: 46,
                height: 46,
                child: Center(
                  child: Text(
                    '🏁',
                    textScaler: TextScaler.noScaling,
                    style: TextStyle(fontSize: 24, height: 1),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: textTheme.titleLarge?.copyWith(
                      color: AppColors.brown900,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 9,
                      backgroundColor: AppColors.creamDark,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.orangeDeep,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RemainingTimeCard extends StatelessWidget {
  const _RemainingTimeCard({required this.remaining});

  final Duration remaining;

  @override
  Widget build(BuildContext context) {
    final texts = AppTexts.of(context);
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.panel,
        border: Border.all(color: AppColors.creamDark),
        boxShadow: AppShadows.soft,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.lg,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.mint,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Padding(
                padding: EdgeInsets.all(AppSpacing.sm),
                child: Icon(Icons.timer_rounded, color: AppColors.brown700),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Flexible(
              child: Text(
                texts.timer.remainingTime(formatDuration(remaining)),
                textAlign: TextAlign.center,
                style: textTheme.headlineSmall?.copyWith(
                  color: AppColors.brown900,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
