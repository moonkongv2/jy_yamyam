import 'package:flutter/material.dart';

import '../l10n/app_texts.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';

class TimerControlBar extends StatelessWidget {
  const TimerControlBar({
    super.key,
    required this.isPaused,
    required this.onPauseResume,
    required this.onComplete,
  });

  final bool isPaused;
  final VoidCallback onPauseResume;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final texts = AppTexts.of(context);

    return Row(
      children: [
        Flexible(
          flex: 9,
          child: OutlinedButton.icon(
            onPressed: onPauseResume,
            icon: Icon(isPaused ? Icons.play_arrow_rounded : Icons.pause),
            label: Text(
              isPaused ? texts.common.restartRide : texts.timer.pauseButton,
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(64),
              backgroundColor: AppColors.white,
              foregroundColor: AppColors.brown700,
              side: const BorderSide(color: AppColors.creamDark, width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
              textStyle: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Flexible(
          flex: 11,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: AppRadius.button,
              boxShadow: AppShadows.button,
            ),
            child: FilledButton.icon(
              onPressed: onComplete,
              icon: const Icon(Icons.check_circle_rounded),
              label: Text(texts.timer.completeMealButton),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(64),
                backgroundColor: AppColors.orangeDeep,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
                textStyle: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
