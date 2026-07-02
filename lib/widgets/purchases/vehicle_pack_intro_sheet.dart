import 'package:flutter/material.dart';

import '../../l10n/app_texts.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';

Future<bool> showVehiclePackIntroSheet(BuildContext context) async {
  final shouldContinue = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.surfaceWarm,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => const VehiclePackIntroSheet(),
  );

  return shouldContinue == true;
}

class VehiclePackIntroSheet extends StatelessWidget {
  const VehiclePackIntroSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final texts = AppTexts.of(context).purchases;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DecoratedBox(
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceYellow,
                    shape: BoxShape.circle,
                  ),
                  child: const SizedBox(
                    width: 64,
                    height: 64,
                    child: Icon(
                      Icons.lock_open_rounded,
                      color: AppColors.brown700,
                      size: 34,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        texts.vehiclePackIntroTitle,
                        style: textTheme.titleLarge?.copyWith(
                          color: AppColors.textStrong,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        texts.vehiclePackIntroBody,
                        style: textTheme.bodyLarge?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.72),
                borderRadius: AppRadius.card,
                border: Border.all(color: AppColors.borderSoft),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.family_restroom_rounded,
                      color: AppColors.brown700,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        texts.vehiclePackIntroGuardianNote,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton.icon(
              key: const ValueKey('vehiclePackIntroContinueButton'),
              onPressed: () => Navigator.of(context).pop(true),
              icon: const Icon(Icons.family_restroom_rounded),
              label: Text(texts.vehiclePackIntroContinueButton),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton(
              key: const ValueKey('vehiclePackIntroCloseButton'),
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(texts.vehiclePackIntroCloseButton),
            ),
          ],
        ),
      ),
    );
  }
}
