import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData get light => _build(Brightness.light, AppPalette.light);

  static ThemeData get dark => _build(Brightness.dark, AppPalette.dark);

  static ThemeData _build(Brightness brightness, AppPalette colors) {
    final isDark = brightness == Brightness.dark;
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppPalette.light.primary,
        brightness: brightness,
        // Material widgets (date picker, cursors, text buttons) draw their
        // accents in `primary`; on dark surfaces that needs the lime.
        primary: colors.primaryText,
        onPrimary: isDark ? AppColors.ink : AppColors.textOnPrimary,
        secondary: AppColors.accent,
        surface: colors.surface,
        onSurface: colors.textPrimary,
        onSurfaceVariant: colors.textSecondary,
        error: colors.danger,
      ),
      scaffoldBackgroundColor: colors.background,
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: colors.textPrimary,
        displayColor: colors.textPrimary,
      ),
      dividerTheme: DividerThemeData(
        color: colors.divider,
        thickness: 1,
        space: 1,
      ),
      dialogTheme: DialogThemeData(backgroundColor: colors.surface),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surface,
        modalBackgroundColor: colors.surface,
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: colors.surface,
        headerForegroundColor: colors.textPrimary,
      ),
      // Light mode keeps Material's default dark snackbar.
      snackBarTheme: isDark
          ? SnackBarThemeData(
              backgroundColor: colors.surfaceMuted,
              contentTextStyle: TextStyle(color: colors.textPrimary),
            )
          : null,
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.primaryText,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: colors.primaryText,
      ),
      splashFactory: InkSparkle.splashFactory,
    );
  }
}
