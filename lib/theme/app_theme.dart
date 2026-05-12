import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';

abstract final class AppTheme {
  static ThemeData light() {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.blue,
      onPrimary: AppColors.brown900,
      primaryContainer: AppColors.skyBlue,
      onPrimaryContainer: AppColors.brown900,
      secondary: AppColors.skyBlue,
      onSecondary: AppColors.brown900,
      secondaryContainer: AppColors.mint,
      onSecondaryContainer: AppColors.brown900,
      tertiary: Color(0xFF66B7E8),
      onTertiary: Colors.white,
      tertiaryContainer: AppColors.sky,
      onTertiaryContainer: AppColors.brown900,
      error: Color(0xFFBA1A1A),
      onError: Colors.white,
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF410002),
      surface: Colors.white,
      onSurface: AppColors.brown900,
      surfaceContainerHighest: AppColors.creamDark,
      onSurfaceVariant: AppColors.brown500,
      outline: AppColors.brown300,
      outlineVariant: Color(0xFFEAD8C7),
      shadow: AppColors.brown700,
      scrim: Colors.black,
      inverseSurface: AppColors.brown900,
      onInverseSurface: AppColors.cream,
      inversePrimary: AppColors.skyBlue,
    );

    final baseTheme = ThemeData(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.cream,
      useMaterial3: true,
    );
    final textTheme = _textTheme(baseTheme.textTheme);

    return baseTheme.copyWith(
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.cream,
        foregroundColor: AppColors.brown900,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: AppColors.brown900,
          fontWeight: FontWeight.w900,
        ),
        iconTheme: const IconThemeData(color: AppColors.brown700),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shadowColor: AppColors.brown700.withValues(alpha: 0.12),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(58),
          backgroundColor: AppColors.blue,
          foregroundColor: AppColors.brown900,
          disabledBackgroundColor: AppColors.brown300.withValues(alpha: 0.32),
          disabledForegroundColor: AppColors.brown500.withValues(alpha: 0.56),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          foregroundColor: AppColors.brown700,
          side: const BorderSide(color: AppColors.brown300, width: 1.4),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.blue,
          textStyle: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.button,
          borderSide: const BorderSide(color: AppColors.brown300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.button,
          borderSide: const BorderSide(color: Color(0xFFEAD8C7)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.button,
          borderSide: const BorderSide(color: AppColors.blue, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.brown500),
      ),
      chipTheme: baseTheme.chipTheme.copyWith(
        backgroundColor: Colors.white,
        selectedColor: AppColors.skyBlue,
        disabledColor: AppColors.creamDark,
        labelStyle: textTheme.titleMedium?.copyWith(
          color: AppColors.brown900,
          fontWeight: FontWeight.w900,
        ),
        secondaryLabelStyle: textTheme.titleMedium?.copyWith(
          color: AppColors.brown900,
          fontWeight: FontWeight.w900,
        ),
        side: const BorderSide(color: Color(0xFFEAD8C7)),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? AppColors.blue
              : AppColors.brown300;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? AppColors.skyBlue
              : AppColors.creamDark;
        }),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFEAD8C7),
        thickness: 1,
        space: 1,
      ),
    );
  }

  static TextTheme _textTheme(TextTheme base) {
    const textColor = AppColors.brown900;
    const bodyColor = AppColors.brown700;

    return base
        .copyWith(
          displayLarge: base.displayLarge?.copyWith(
            fontWeight: FontWeight.w900,
          ),
          displayMedium: base.displayMedium?.copyWith(
            fontWeight: FontWeight.w900,
          ),
          headlineLarge: base.headlineLarge?.copyWith(
            fontWeight: FontWeight.w900,
          ),
          headlineMedium: base.headlineMedium?.copyWith(
            fontWeight: FontWeight.w900,
          ),
          titleLarge: base.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          titleMedium: base.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          titleSmall: base.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          bodyLarge: base.bodyLarge?.copyWith(height: 1.35),
          bodyMedium: base.bodyMedium?.copyWith(height: 1.35),
          labelLarge: base.labelLarge?.copyWith(fontWeight: FontWeight.w900),
        )
        .apply(displayColor: textColor, bodyColor: bodyColor);
  }
}
