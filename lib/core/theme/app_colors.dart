import 'package:flutter/material.dart';

/// Colours that look the same in light and dark mode.
///
/// Anything that must change with the theme lives in [AppPalette]; read it
/// with `context.colors`.
abstract final class AppColors {
  // Brand
  static const Color accent = Color(0xFFD4F25C);

  /// Near-black green, for dark tiles that stay dark in both themes.
  static const Color ink = Color(0xFF17221C);

  // Text on brand fills
  static const Color textOnPrimary = Colors.white;
  static const Color textOnPrimaryMuted = Color(0xFFB5C2BA);

  // Categories. Checked with the dataviz palette validator (all pairs, on
  // white): no hard fails; charts must keep gaps + a labelled legend.
  static const Color food = Color(0xFFE07A3F);
  static const Color bills = Color(0xFF0F8F78);
  static const Color transport = Color(0xFF3867D6);
  static const Color shopping = Color(0xFFCC5FB8);
  static const Color health = Color(0xFFC9304F);
  static const Color leisure = Color(0xFFCDB42A);
  static const Color other = Color(0xFF7C8580);

  // Actions
  static const Color edit = Color(0xFF2C3B57);
  static const Color errorBanner = Color(0xFF34191A);

  // Status
  static const Color offlineBanner = Color(0xFF2A2C29);
  static const Color warning = Color(0xFFE8B84A);
}

/// Theme-dependent colours. Use `context.colors` to get the active one.
class AppPalette {
  const AppPalette({
    required this.primary,
    required this.primaryText,
    required this.primaryMuted,
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.border,
    required this.divider,
    required this.textPrimary,
    required this.textSecondary,
    required this.danger,
    required this.dangerSurface,
    required this.dangerBorder,
    required this.success,
    required this.successSurface,
    required this.errorTint,
    required this.skeleton,
    required this.skeletonOnPrimary,
    required this.illustrationBackground,
    required this.tintGreen,
    required this.tintLime,
    required this.olive,
    required this.tintPurple,
    required this.purple,
    required this.tintBlue,
    required this.blue,
  });

  /// Brand fill: buttons, the summary card, selected chips.
  final Color primary;

  /// Brand colour for text and icons drawn on [surface] / [background].
  final Color primaryText;

  /// Light tint of [primary], e.g. non-highlighted bars.
  final Color primaryMuted;

  // Surfaces
  final Color background;
  final Color surface;

  /// Muted panel colour (info strips, previews).
  final Color surfaceMuted;
  final Color border;
  final Color divider;

  // Text
  final Color textPrimary;
  final Color textSecondary;

  // Danger / status
  final Color danger;
  final Color dangerSurface;
  final Color dangerBorder;
  final Color success;
  final Color successSurface;

  /// Soft red behind error icons.
  final Color errorTint;

  // Loading placeholders
  final Color skeleton;
  final Color skeletonOnPrimary;

  /// Soft green circle behind empty-state illustrations.
  final Color illustrationBackground;

  // Settings icon tiles: tinted backgrounds and their icon colours.
  final Color tintGreen;
  final Color tintLime;
  final Color olive;
  final Color tintPurple;
  final Color purple;
  final Color tintBlue;
  final Color blue;

  static const light = AppPalette(
    primary: Color(0xFF1E3B2F),
    primaryText: Color(0xFF1E3B2F),
    primaryMuted: Color(0xFFD1E3D8),
    background: Color(0xFFF3F1EA),
    surface: Colors.white,
    surfaceMuted: Color(0xFFEDEAE2),
    border: Color(0xFFE8E5DC),
    divider: Color(0xFFEFEDE6),
    textPrimary: Color(0xFF17221C),
    textSecondary: Color(0xFF6E736F),
    danger: Color(0xFFC7413D),
    dangerSurface: Color(0xFFFDF1F0),
    dangerBorder: Color(0xFFF1C4C0),
    success: Color(0xFF1F7A4D),
    successSurface: Color(0xFFE2F1E7),
    errorTint: Color(0xFFFCE4E4),
    skeleton: Color(0xFFEAE6DE),
    skeletonOnPrimary: Color(0xFF2F5644),
    illustrationBackground: Color(0xFFE6F0D8),
    tintGreen: Color(0xFFDDEEE3),
    tintLime: Color(0xFFEFF6CF),
    olive: Color(0xFF5E6B1E),
    tintPurple: Color(0xFFF1E2F6),
    purple: Color(0xFF8E4FB0),
    tintBlue: Color(0xFFE1E9FB),
    blue: Color(0xFF3867D6),
  );

  static const dark = AppPalette(
    primary: Color(0xFF24493A),
    primaryText: AppColors.accent,
    primaryMuted: Color(0xFF2C3F35),
    background: Color(0xFF111613),
    surface: Color(0xFF1A201C),
    surfaceMuted: Color(0xFF232A25),
    border: Color(0xFF2A322D),
    divider: Color(0xFF252C27),
    textPrimary: Color(0xFFEDEFEA),
    textSecondary: Color(0xFF9AA39D),
    danger: Color(0xFFEF6B66),
    dangerSurface: Color(0xFF331C1B),
    dangerBorder: Color(0xFF5C2A28),
    success: Color(0xFF5CC98C),
    successSurface: Color(0xFF1C3326),
    errorTint: Color(0xFF3A1E1F),
    skeleton: Color(0xFF252C27),
    skeletonOnPrimary: Color(0xFF33604B),
    illustrationBackground: Color(0xFF1F2E22),
    tintGreen: Color(0xFF1E3328),
    tintLime: Color(0xFF2C3318),
    olive: Color(0xFFC6DB6A),
    tintPurple: Color(0xFF33223B),
    purple: Color(0xFFC08BDD),
    tintBlue: Color(0xFF1D2A45),
    blue: Color(0xFF7FA2F0),
  );
}

extension AppPaletteContext on BuildContext {
  /// The palette for the current theme brightness.
  AppPalette get colors => Theme.of(this).brightness == Brightness.dark
      ? AppPalette.dark
      : AppPalette.light;
}
