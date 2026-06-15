import 'package:flutter/material.dart';

import '../models/reward_item.dart';
import '../theme/app_colors.dart';

class RewardStickerImage extends StatelessWidget {
  const RewardStickerImage({
    super.key,
    required this.reward,
    this.semanticLabel,
    this.size = 88,
    this.locked = false,
  });

  final RewardDefinition reward;
  final String? semanticLabel;
  final double size;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final padding = (size * 0.14).clamp(3.0, 10.0).toDouble();
    final imageSize = (size - padding * 2).clamp(0.0, size).toDouble();
    final image = Image.asset(
      reward.imageAssetPath,
      width: imageSize,
      height: imageSize,
      fit: BoxFit.contain,
      semanticLabel: semanticLabel ?? reward.id,
      errorBuilder: (_, _, _) =>
          _FallbackStickerIcon(reward: reward, size: imageSize, locked: locked),
    );
    final sticker = _StickerFrame(size: size, padding: padding, child: image);

    if (!locked) {
      return sticker;
    }

    return Opacity(
      opacity: 0.48,
      child: ColorFiltered(
        colorFilter: const ColorFilter.mode(
          AppColors.textSecondary,
          BlendMode.srcIn,
        ),
        child: sticker,
      ),
    );
  }
}

class _StickerFrame extends StatelessWidget {
  const _StickerFrame({
    required this.size,
    required this.padding,
    required this.child,
  });

  final double size;
  final double padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final radius = (size * 0.22).clamp(6.0, 18.0).toDouble();
    final shadow = size < 36
        ? const <BoxShadow>[]
        : [
            BoxShadow(
              color: AppColors.brown700.withValues(alpha: 0.08),
              blurRadius: (size * 0.10).clamp(3.0, 8.0).toDouble(),
              offset: Offset(0, (size * 0.04).clamp(1.0, 3.0).toDouble()),
            ),
          ];

    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: AppColors.borderSoft),
          boxShadow: shadow,
        ),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _FallbackStickerIcon extends StatelessWidget {
  const _FallbackStickerIcon({
    required this.reward,
    required this.size,
    required this.locked,
  });

  final RewardDefinition reward;
  final double size;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Center(
        child: Text(
          locked ? '?' : reward.emoji,
          style: TextStyle(
            fontSize: size * 0.56,
            color: locked ? AppColors.textMuted : null,
          ),
        ),
      ),
    );
  }
}
