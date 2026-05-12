import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_motion.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';

class AppBouncyButton extends StatefulWidget {
  const AppBouncyButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.backgroundColor = AppColors.orangeDeep,
    this.foregroundColor = Colors.white,
    this.minHeight = 58,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final double minHeight;

  @override
  State<AppBouncyButton> createState() => _AppBouncyButtonState();
}

class _AppBouncyButtonState extends State<AppBouncyButton> {
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (_isPressed == value || widget.onPressed == null) {
      return;
    }
    setState(() => _isPressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null;
    final backgroundColor = isEnabled
        ? widget.backgroundColor
        : AppColors.brown300.withValues(alpha: 0.32);
    final foregroundColor = isEnabled
        ? widget.foregroundColor
        : AppColors.brown500.withValues(alpha: 0.56);

    return AnimatedScale(
      duration: AppMotion.fast,
      curve: AppMotion.playfulCurve,
      scale: _isPressed ? 0.96 : 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: AppRadius.button,
          boxShadow: isEnabled ? AppShadows.button : null,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: AppRadius.button,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onPressed,
            onTapDown: (_) => _setPressed(true),
            onTapCancel: () => _setPressed(false),
            onTapUp: (_) => _setPressed(false),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: widget.minHeight),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, color: foregroundColor, size: 24),
                      const SizedBox(width: AppSpacing.sm),
                    ],
                    Flexible(
                      child: Text(
                        widget.label,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: foregroundColor,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
