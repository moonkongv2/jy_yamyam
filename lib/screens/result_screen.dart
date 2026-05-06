import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../models/meal_progress_snapshot.dart';
import '../models/meal_session_result.dart';
import '../models/meal_timer_config.dart';
import '../models/reward_item.dart';
import '../services/local_meal_progress_service.dart';
import '../widgets/reward_sticker_image.dart';
import 'home_screen.dart';
import 'timer_screen.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({
    super.key,
    required this.result,
    required this.config,
    required this.mealProgressService,
    required this.onConfigChanged,
  });

  final MealSessionResult result;
  final MealTimerConfig config;
  final LocalMealProgressService mealProgressService;
  final ValueChanged<MealTimerConfig> onConfigChanged;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  static const _successVideoPath = 'assets/images/result_success.mp4';
  static const _failureVideoPath = 'assets/images/result_failure.mp4';
  static const _successImagePath = 'assets/images/result_success.png';
  static const _failureImagePath = 'assets/images/result_failure.png';

  late final VideoPlayerController _introController;
  late final Future<RecordedMealSession> _recordedSession = widget
      .mealProgressService
      .recordMealResult(widget.result);
  bool _introFinished = false;
  bool _introFallback = false;

  @override
  void initState() {
    super.initState();
    _introController = VideoPlayerController.asset(_introVideoPath);
    _introController.addListener(_handleIntroChanged);
    _initializeIntroVideo();
  }

  String get _introVideoPath =>
      widget.result.mealCompleted ? _successVideoPath : _failureVideoPath;

  String get _introFallbackImagePath =>
      widget.result.mealCompleted ? _successImagePath : _failureImagePath;

  void _handleIntroChanged() {
    final value = _introController.value;
    if (_introFinished ||
        !value.isInitialized ||
        value.duration == Duration.zero) {
      return;
    }

    if (value.position >= value.duration) {
      setState(() => _introFinished = true);
    }
  }

  Future<void> _initializeIntroVideo() async {
    try {
      await _introController.initialize();
      await _introController.setLooping(false);
      await _introController.play();
      if (mounted) {
        setState(() {});
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _introFallback = true;
          _introFinished = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _introController.removeListener(_handleIntroChanged);
    _introController.dispose();
    super.dispose();
  }

  void _restart(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => TimerScreen(
          config: widget.config,
          mealProgressService: widget.mealProgressService,
          onConfigChanged: widget.onConfigChanged,
        ),
      ),
    );
  }

  void _goHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => HomeScreen(
          config: widget.config,
          mealProgressService: widget.mealProgressService,
          onConfigChanged: widget.onConfigChanged,
        ),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final mealCompleted = widget.result.mealCompleted;

    if (!_introFinished) {
      return _ResultIntroScreen(
        controller: _introController,
        fallbackImageAssetPath: _introFallbackImagePath,
        showFallback: _introFallback || !_introController.value.isInitialized,
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Spacer(),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                Text(
                                  mealCompleted ? '식사 완주 성공!' : '아쉽지만 실패했어',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(fontWeight: FontWeight.w900),
                                ),
                                if (mealCompleted) ...[
                                  const SizedBox(height: 18),
                                  FutureBuilder<RecordedMealSession>(
                                    future: _recordedSession,
                                    builder: (context, snapshot) {
                                      return _RewardResultBox(
                                        rewards: snapshot.data?.awardedRewards,
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 18),
                                ] else
                                  const SizedBox(height: 16),
                                Text(
                                  mealCompleted
                                      ? '오늘의 냠냠코스를 끝까지 잘 마쳤어.'
                                      : '타이머가 끝났지만 아직 식사가 완료되지 않았어.',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(height: 1.4),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  mealCompleted
                                      ? '오늘도 멋진 라이더였어!'
                                      : '다음 냠냠코스에서 다시 도전해보자.',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Spacer(),
                        FilledButton.icon(
                          onPressed: () => _restart(context),
                          icon: const Icon(Icons.two_wheeler_rounded),
                          label: const Text('다시 출발'),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () => _goHome(context),
                          icon: const Icon(Icons.home_rounded),
                          label: const Text('홈으로'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ResultIntroScreen extends StatelessWidget {
  const _ResultIntroScreen({
    required this.controller,
    required this.fallbackImageAssetPath,
    required this.showFallback,
  });

  final VideoPlayerController controller;
  final String fallbackImageAssetPath;
  final bool showFallback;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: showFallback
            ? Image.asset(
                fallbackImageAssetPath,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              )
            : FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: controller.value.size.width,
                  height: controller.value.size.height,
                  child: VideoPlayer(controller),
                ),
              ),
      ),
    );
  }
}

class _RewardResultBox extends StatelessWidget {
  const _RewardResultBox({required this.rewards});

  final List<RewardDefinition>? rewards;

  @override
  Widget build(BuildContext context) {
    final rewards = this.rewards;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1B8),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: rewards == null
            ? Text(
                '보상 정리 중...',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              )
            : rewards.isEmpty
            ? Text(
                '오늘의 기록을 저장했어',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              )
            : Wrap(
                alignment: WrapAlignment.center,
                runAlignment: WrapAlignment.center,
                spacing: 14,
                runSpacing: 14,
                children: [
                  for (final reward in rewards) _RewardBadge(reward: reward),
                ],
              ),
      ),
    );
  }
}

class _RewardBadge extends StatelessWidget {
  const _RewardBadge({required this.reward});

  final RewardDefinition reward;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 116,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RewardStickerImage(reward: reward, size: 64),
          const SizedBox(height: 8),
          Text(
            reward.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: const Color(0xFF5B4636),
            ),
          ),
        ],
      ),
    );
  }
}
