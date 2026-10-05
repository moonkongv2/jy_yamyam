import 'package:flutter/material.dart';

import '../catalogs/vehicle_catalog.dart';
import '../l10n/app_texts.dart';
import '../models/meal_progress_snapshot.dart';
import '../models/reward_item.dart';
import '../services/local_meal_progress_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../widgets/reward_sticker_image.dart';
import '../widgets/sticker_fountain_animation.dart';

class StickerCollectionScreen extends StatelessWidget {
  const StickerCollectionScreen({super.key, required this.mealProgressService});

  final LocalMealProgressService mealProgressService;

  @override
  Widget build(BuildContext context) {
    final texts = AppTexts.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(texts.rewards.collectionTitle)),
      body: SafeArea(
        child: FutureBuilder<MealProgressSnapshot>(
          future: mealProgressService.loadSnapshot(),
          builder: (context, snapshot) {
            final inventory = snapshot.data?.inventory ?? const [];

            return LayoutBuilder(
              builder: (context, constraints) {
                final horizontalPadding = (constraints.maxWidth / 4)
                    .clamp(0.0, AppSpacing.xl)
                    .toDouble();
                final availableWidth =
                    constraints.maxWidth - horizontalPadding * 2;
                if (availableWidth <= 0) return const SizedBox.shrink();
                final textScale =
                    (MediaQuery.textScalerOf(context).scale(16) / 16).clamp(
                      1.0,
                      double.infinity,
                    );
                final columns =
                    ((availableWidth + AppSpacing.md) /
                            (132 * textScale + AppSpacing.md))
                        .floor()
                        .clamp(1, 4);
                final distributedWidth =
                    (availableWidth - (columns - 1) * AppSpacing.md) / columns;
                // Round down so floating-point error cannot push a card to a new row.
                final cardWidth = columns == 1
                    ? availableWidth
                    : distributedWidth.floorToDouble();
                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    AppSpacing.md,
                    horizontalPadding,
                    AppSpacing.xxl,
                  ),
                  child: Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.md,
                    children: VehicleCatalog.all.map((vehicle) {
                      final sticker =
                          RewardCatalog.findVehicleStickerByVehicleId(
                            vehicle.id,
                          )!;
                      final item = _inventoryItemFor(inventory, sticker.id);

                      return SizedBox(
                        width: cardWidth,
                        child: _StickerCard(
                          sticker: sticker,
                          count: item?.count ?? 0,
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  RewardInventoryItem? _inventoryItemFor(
    List<RewardInventoryItem> inventory,
    String rewardId,
  ) {
    for (final item in inventory) {
      if (item.rewardId == rewardId) {
        return item;
      }
    }
    return null;
  }
}

class _StickerCard extends StatelessWidget {
  const _StickerCard({required this.sticker, required this.count});

  final RewardDefinition sticker;
  final int count;

  bool get _isCollected => count > 0;

  Widget _buildStickerStack(String semanticLabel, double availableWidth) {
    // Include rotated corners and shadows in the stack's layout bounds.
    final scale = (availableWidth / (count > 1 ? 141 : 85))
        .clamp(0.0, 1.0)
        .toDouble();
    final stickerImage = RewardStickerImage(
      reward: sticker,
      semanticLabel: semanticLabel,
      size: 85 * scale,
      locked: !_isCollected,
    );

    if (count <= 1) {
      return stickerImage;
    }

    return SizedBox(
      width: 141 * scale,
      height: 131 * scale,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          if (count >= 5)
            Positioned(
              left: 18 * scale,
              top: 26 * scale,
              child: Transform.rotate(
                angle: -0.25,
                child: Opacity(opacity: 0.6, child: stickerImage),
              ),
            ),
          if (count >= 2)
            Positioned(
              left: 40 * scale,
              top: 16 * scale,
              child: Transform.rotate(
                angle: 0.18,
                child: Opacity(opacity: 0.8, child: stickerImage),
              ),
            ),
          Positioned(left: 30 * scale, top: 22 * scale, child: stickerImage),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final texts = AppTexts.of(context);
    final stickerName = sticker.labelForLanguage(
      Localizations.localeOf(context).languageCode,
    );

    return GestureDetector(
      onTapUp: _isCollected
          ? (details) {
              showStickerFountain(
                context: context,
                reward: sticker,
                count: count,
                position: details.globalPosition,
              );
            }
          : null,
      child: Card(
        color: _isCollected ? AppColors.white : AppColors.cream,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final padding = (constraints.maxWidth / 4)
                .clamp(0.0, AppSpacing.lg)
                .toDouble();
            final contentWidth = constraints.maxWidth - padding * 2;
            return Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStickerStack(
                    _isCollected
                        ? stickerName
                        : texts.rewards.uncollectedSemanticLabel,
                    contentWidth,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    _isCollected ? stickerName : texts.rewards.lockedSticker,
                    textAlign: TextAlign.center,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: _isCollected
                          ? AppColors.textStrong
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: _isCollected
                          ? AppColors.surfaceYellow
                          : AppColors.borderSoft,
                      borderRadius: AppRadius.pill,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: (contentWidth / 4)
                            .clamp(0.0, AppSpacing.md)
                            .toDouble(),
                        vertical: AppSpacing.xs,
                      ),
                      child: Text(
                        _isCollected
                            ? texts.rewards.stickerCount(count)
                            : texts.rewards.lockedStatus,
                        textAlign: TextAlign.center,
                        style: textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
