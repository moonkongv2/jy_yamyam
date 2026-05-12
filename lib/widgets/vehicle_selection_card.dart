import 'package:flutter/material.dart';

import '../catalogs/vehicle_catalog.dart';
import '../models/vehicle.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';

class VehicleSelectionCard extends StatelessWidget {
  const VehicleSelectionCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.selectedVehicleId,
    required this.onVehicleSelected,
  });

  final String title;
  final String? subtitle;
  final String selectedVehicleId;
  final ValueChanged<String> onVehicleSelected;

  @override
  Widget build(BuildContext context) {
    final selectedVehicle = VehicleCatalog.findById(selectedVehicleId);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.creamDark),
        boxShadow: AppShadows.soft,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.brown900,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.brown500,
                      fontWeight: FontWeight.w700,
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
                final itemWidth = fourAcrossWidth.clamp(72.0, 84.0).toDouble();

                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: [
                    for (final vehicle in VehicleCatalog.all)
                      _VehicleChoiceButton(
                        width: itemWidth,
                        vehicle: vehicle,
                        isSelected: selectedVehicle.id == vehicle.id,
                        onTap: () => onVehicleSelected(vehicle.id),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _VehicleChoiceButton extends StatelessWidget {
  const _VehicleChoiceButton({
    required this.width,
    required this.vehicle,
    required this.isSelected,
    required this.onTap,
  });

  final double width;
  final VehicleDefinition vehicle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected ? AppColors.skyBlue : AppColors.creamDark;
    final backgroundColor = isSelected
        ? AppColors.skyBlue.withValues(alpha: 0.52)
        : AppColors.cream.withValues(alpha: 0.52);
    final borderRadius = BorderRadius.circular(AppRadius.lg);

    return SizedBox(
      width: width,
      height: 80,
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
                    width: 58,
                    height: 58,
                    child: Image.asset(
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
                    ),
                  ),
                ),
                if (isSelected)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.brown900,
                        borderRadius: BorderRadius.circular(999),
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
