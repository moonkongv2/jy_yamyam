import 'package:flutter/material.dart';

import '../catalogs/vehicle_catalog.dart';
import '../models/meal_timer_config.dart';
import '../models/vehicle.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import 'avatar/avatar_composite_preview.dart';

typedef VehicleAvatarConfigResolver =
    VehicleAvatarConfig? Function(String vehicleId);

class VehicleSelectionCard extends StatelessWidget {
  const VehicleSelectionCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.selectedVehicleId,
    required this.onVehicleSelected,
    this.avatarMode = AvatarImageMode.defaultImage,
    this.customAvatarImagePath,
    this.avatarScale = 1.0,
    this.avatarOffsetX = 0.0,
    this.avatarOffsetY = 0.0,
    this.avatarRotationDegrees = 0.0,
    this.avatarConfigForVehicle,
    this.avatarImageBuilder,
    this.footer,
  });

  final String title;
  final String? subtitle;
  final String selectedVehicleId;
  final ValueChanged<String> onVehicleSelected;
  final AvatarImageMode avatarMode;
  final String? customAvatarImagePath;
  final double avatarScale;
  final double avatarOffsetX;
  final double avatarOffsetY;
  final double avatarRotationDegrees;
  final VehicleAvatarConfigResolver? avatarConfigForVehicle;
  final Widget Function(BuildContext context, String imagePath)?
  avatarImageBuilder;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final selectedVehicle = VehicleCatalog.findById(selectedVehicleId);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceWarm,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.borderWarm),
        boxShadow: AppShadows.surface,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textStrong,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (subtitle != null)
                  Flexible(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.68),
                        borderRadius: AppRadius.pill,
                        border: Border.all(color: AppColors.borderSoft),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        child: Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            LayoutBuilder(
              builder: (context, constraints) {
                const spacing = AppSpacing.sm;
                final fourAcrossWidth =
                    (constraints.maxWidth - (spacing * 3)) / 4;
                final itemSize = fourAcrossWidth.clamp(72.0, 84.0).toDouble();

                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  clipBehavior: Clip.none,
                  children: [
                    for (final vehicle in VehicleCatalog.all)
                      _VehicleChoiceButton(
                        size: itemSize,
                        vehicle: vehicle,
                        isSelected: selectedVehicle.id == vehicle.id,
                        onTap: () => onVehicleSelected(vehicle.id),
                        avatarConfig: avatarConfigForVehicle?.call(vehicle.id),
                        avatarMode: avatarMode,
                        customAvatarImagePath: customAvatarImagePath,
                        avatarScale: avatarScale,
                        avatarOffsetX: avatarOffsetX,
                        avatarOffsetY: avatarOffsetY,
                        avatarRotationDegrees: avatarRotationDegrees,
                        avatarImageBuilder: avatarImageBuilder,
                      ),
                  ],
                );
              },
            ),
            if (footer != null) ...[
              const SizedBox(height: AppSpacing.md),
              const Divider(
                color: AppColors.borderSoft,
                height: 1,
                thickness: 1,
              ),
              const SizedBox(height: AppSpacing.sm),
              footer!,
            ],
          ],
        ),
      ),
    );
  }
}

class _VehicleChoiceButton extends StatelessWidget {
  const _VehicleChoiceButton({
    required this.size,
    required this.vehicle,
    required this.isSelected,
    required this.onTap,
    required this.avatarConfig,
    required this.avatarMode,
    required this.customAvatarImagePath,
    required this.avatarScale,
    required this.avatarOffsetX,
    required this.avatarOffsetY,
    required this.avatarRotationDegrees,
    this.avatarImageBuilder,
  });

  final double size;
  final VehicleDefinition vehicle;
  final bool isSelected;
  final VoidCallback onTap;
  final VehicleAvatarConfig? avatarConfig;
  final AvatarImageMode avatarMode;
  final String? customAvatarImagePath;
  final double avatarScale;
  final double avatarOffsetX;
  final double avatarOffsetY;
  final double avatarRotationDegrees;
  final Widget Function(BuildContext context, String imagePath)?
  avatarImageBuilder;

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected
        ? AppColors.primarySoft
        : AppColors.borderSoft;
    final backgroundColor = isSelected
        ? AppColors.surfaceYellow.withValues(alpha: 0.72)
        : AppColors.white.withValues(alpha: 0.72);
    final borderRadius = AppRadius.compactCard;
    final choiceAvatarMode = avatarConfig != null
        ? AvatarImageMode.custom
        : isSelected
        ? avatarMode
        : AvatarImageMode.defaultImage;
    final choiceAvatarImagePath =
        avatarConfig?.imagePath ?? (isSelected ? customAvatarImagePath : null);
    final choiceAvatarScale =
        avatarConfig?.scale ?? (isSelected ? avatarScale : 1.0);
    final choiceAvatarOffsetX =
        avatarConfig?.offsetX ?? (isSelected ? avatarOffsetX : 0.0);
    final choiceAvatarOffsetY =
        avatarConfig?.offsetY ?? (isSelected ? avatarOffsetY : 0.0);
    final choiceAvatarRotationDegrees =
        avatarConfig?.rotationDegrees ??
        (isSelected ? avatarRotationDegrees : 0.0);

    return SizedBox(
      width: size,
      height: size,
      child: Semantics(
        label: vehicle.labelForLanguage(
          Localizations.localeOf(context).languageCode,
        ),
        button: true,
        selected: isSelected,
        child: Material(
          key: ValueKey('vehicleChoice.${vehicle.id}'),
          color: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius,
            side: BorderSide(color: borderColor, width: 1.2),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Stack(
              children: [
                Center(
                  child: SizedBox(
                    width: size - 20,
                    height: size - 24,
                    child: _VehicleChoiceImage(
                      vehicle: vehicle,
                      size: size - 20,
                      avatarMode: choiceAvatarMode,
                      customAvatarImagePath: choiceAvatarImagePath,
                      avatarScale: choiceAvatarScale,
                      avatarOffsetX: choiceAvatarOffsetX,
                      avatarOffsetY: choiceAvatarOffsetY,
                      avatarRotationDegrees: choiceAvatarRotationDegrees,
                      avatarImageBuilder: avatarImageBuilder,
                    ),
                  ),
                ),
                if (isSelected)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: AppRadius.pill,
                        boxShadow: AppShadows.buttonSoft,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(3),
                        child: Icon(
                          Icons.check_rounded,
                          color: AppColors.white,
                          size: 13,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VehicleChoiceImage extends StatelessWidget {
  const _VehicleChoiceImage({
    required this.vehicle,
    required this.size,
    required this.avatarMode,
    required this.customAvatarImagePath,
    required this.avatarScale,
    required this.avatarOffsetX,
    required this.avatarOffsetY,
    required this.avatarRotationDegrees,
    this.avatarImageBuilder,
  });

  final VehicleDefinition vehicle;
  final double size;
  final AvatarImageMode avatarMode;
  final String? customAvatarImagePath;
  final double avatarScale;
  final double avatarOffsetX;
  final double avatarOffsetY;
  final double avatarRotationDegrees;
  final Widget Function(BuildContext context, String imagePath)?
  avatarImageBuilder;

  @override
  Widget build(BuildContext context) {
    if (avatarMode == AvatarImageMode.custom) {
      return AvatarCompositePreview(
        vehicle: vehicle,
        avatarMode: avatarMode,
        customAvatarImagePath: customAvatarImagePath,
        avatarScale: avatarScale,
        avatarOffsetX: avatarOffsetX,
        avatarOffsetY: avatarOffsetY,
        avatarRotationDegrees: avatarRotationDegrees,
        size: size,
        avatarImageBuilder: avatarImageBuilder,
      );
    }

    return Image.asset(
      vehicle.selectionImagePath,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Center(
          child: Text(
            vehicle.emoji,
            textScaler: TextScaler.noScaling,
            style: const TextStyle(fontSize: 40, height: 1),
          ),
        );
      },
    );
  }
}
