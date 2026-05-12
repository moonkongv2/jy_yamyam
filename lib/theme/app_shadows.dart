import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppShadows {
  static final soft = [
    BoxShadow(
      color: AppColors.brown700.withValues(alpha: 0.10),
      blurRadius: 18,
      offset: const Offset(0, 8),
    ),
  ];

  static final button = [
    BoxShadow(
      color: AppColors.blue.withValues(alpha: 0.18),
      blurRadius: 14,
      offset: const Offset(0, 7),
    ),
  ];
}
