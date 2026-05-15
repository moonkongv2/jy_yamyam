import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/meal_timer_config.dart';
import '../../models/vehicle.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_shadows.dart';

class AvatarCompositePreview extends StatelessWidget {
  const AvatarCompositePreview({
    super.key,
    required this.vehicle,
    required this.avatarMode,
    required this.customAvatarImagePath,
    required this.avatarScale,
    required this.avatarOffsetX,
    required this.avatarOffsetY,
    required this.avatarRotationDegrees,
    required this.size,
    this.isFacingLeft = false,
    this.avatarImageBuilder,
  });

  final VehicleDefinition vehicle;
  final AvatarImageMode avatarMode;
  final String? customAvatarImagePath;
  final double avatarScale;
  final double avatarOffsetX;
  final double avatarOffsetY;
  final double avatarRotationDegrees;
  final double size;
  final bool isFacingLeft;
  final Widget Function(BuildContext context, String imagePath)?
  avatarImageBuilder;

  @override
  Widget build(BuildContext context) {
    final avatarSlot = vehicle.avatarSlot;
    final avatarPath = customAvatarImagePath;
    final shouldShowAvatar =
        avatarMode == AvatarImageMode.custom &&
        avatarSlot != null &&
        avatarPath != null &&
        avatarPath.trim().isNotEmpty &&
        File(avatarPath).existsSync();

    return SizedBox(
      width: size,
      height: size,
      child: Transform.flip(
        flipX: isFacingLeft,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: Image.asset(
                vehicle.assetPath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Text(
                      vehicle.emoji,
                      textScaler: TextScaler.noScaling,
                      semanticsLabel: vehicle.labelKo,
                      style: TextStyle(fontSize: size * 0.48, height: 1),
                    ),
                  );
                },
              ),
            ),
            if (shouldShowAvatar)
              _AvatarOverlay(
                imagePath: avatarPath,
                size: size,
                slot: avatarSlot,
                avatarScale: avatarScale,
                avatarOffsetX: avatarOffsetX,
                avatarOffsetY: avatarOffsetY,
                avatarRotationDegrees: avatarRotationDegrees,
                avatarImageBuilder: avatarImageBuilder,
              ),
          ],
        ),
      ),
    );
  }
}

class _AvatarOverlay extends StatelessWidget {
  const _AvatarOverlay({
    required this.imagePath,
    required this.size,
    required this.slot,
    required this.avatarScale,
    required this.avatarOffsetX,
    required this.avatarOffsetY,
    required this.avatarRotationDegrees,
    this.avatarImageBuilder,
  });

  final String imagePath;
  final double size;
  final VehicleAvatarSlot slot;
  final double avatarScale;
  final double avatarOffsetX;
  final double avatarOffsetY;
  final double avatarRotationDegrees;
  final Widget Function(BuildContext context, String imagePath)?
  avatarImageBuilder;

  @override
  Widget build(BuildContext context) {
    final avatarSize = size * slot.sizeRatio * avatarScale;
    final centerX = size * slot.centerX + avatarOffsetX * size;
    final centerY = size * slot.centerY + avatarOffsetY * size;
    final rotation =
        (slot.rotationDegrees + avatarRotationDegrees) * math.pi / 180;

    return Positioned(
      left: centerX - (avatarSize / 2),
      top: centerY - (avatarSize / 2),
      width: avatarSize,
      height: avatarSize,
      child: Transform.rotate(
        angle: rotation,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.surfaceWarm,
            border: Border.all(color: AppColors.white, width: 3),
            boxShadow: AppShadows.buttonSoft,
          ),
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: ClipOval(
              child:
                  avatarImageBuilder?.call(context, imagePath) ??
                  Image.file(
                    File(imagePath),
                    key: const ValueKey('avatarCompositeOverlayImage'),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const SizedBox.shrink();
                    },
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
