import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Backgrounds & Surfaces
  static const Color background = Color(0xFF1A1A2E);
  static const Color surface = Color(0xFF16213E);
  static const Color surfaceDim = Color(0xFF11131e);
  static const Color surfaceBright = Color(0xFF373845);
  static const Color surfaceContainerLowest = Color(0xFF0c0d19);
  static const Color surfaceContainerLow = Color(0xFF191b27);
  static const Color surfaceContainer = Color(0xFF1d1f2b);
  static const Color surfaceContainerHigh = Color(0xFF282936);
  static const Color surfaceContainerHighest = Color(0xFF333441);
  static const Color surfaceElevated = Color(0xFF1E2A4A);
  static const Color cardBack = Color(0xFF0F3460);

  // Primary (coral/pink)
  static const Color primary = Color(0xFFffb2b7);
  static const Color onPrimary = Color(0xFF67001c);
  static const Color primaryContainer = Color(0xFFfc536d);
  static const Color onPrimaryContainer = Color(0xFF5b0017);
  static const Color inversePrimary = Color(0xFFb71d3f);
  static const Color primaryFixed = Color(0xFFffdadb);
  static const Color primaryFixedDim = Color(0xFFffb2b7);
  static const Color onPrimaryFixed = Color(0xFF40000e);
  static const Color onPrimaryFixedVariant = Color(0xFF91002b);

  // Secondary
  static const Color secondary = Color(0xFFffb2b9);
  static const Color onSecondary = Color(0xFF67001e);
  static const Color secondaryContainer = Color(0xFF8f1533);
  static const Color onSecondaryContainer = Color(0xFFff9da7);
  static const Color secondaryFixed = Color(0xFFffdadc);
  static const Color secondaryFixedDim = Color(0xFFffb2b9);
  static const Color onSecondaryFixed = Color(0xFF400010);
  static const Color onSecondaryFixedVariant = Color(0xFF8c1231);

  // Tertiary (gold)
  static const Color tertiary = Color(0xFFe9c400);
  static const Color onTertiary = Color(0xFF3a3000);
  static const Color tertiaryContainer = Color(0xFFc9a900);
  static const Color onTertiaryContainer = Color(0xFF4c3f00);
  static const Color tertiaryFixed = Color(0xFFffe16d);
  static const Color tertiaryFixedDim = Color(0xFFe9c400);
  static const Color onTertiaryFixed = Color(0xFF221b00);
  static const Color onTertiaryFixedVariant = Color(0xFF544600);

  // Text / On-colors
  static const Color onSurface = Color(0xFFe2e1f2);
  static const Color onSurfaceVariant = Color(0xFFe2bebf);
  static const Color inverseSurface = Color(0xFFe2e1f2);
  static const Color inverseOnSurface = Color(0xFF2e303c);

  // Status
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFffb4ab);
  static const Color onError = Color(0xFF690005);
  static const Color errorContainer = Color(0xFF93000a);
  static const Color onErrorContainer = Color(0xFFffdad6);
  static const Color warning = Color(0xFFFF9800);

  // Legacy convenience aliases (mapped to new palette)
  static const Color textPrimary = Color(0xFFe2e1f2);
  static const Color textSecondary = Color(0xFFe2bebf);
  static const Color textMuted = Color(0xFF666666);
  static const Color buttonText = Color(0xFFFFFFFF);

  // Gradients used for card backs
  static const Color cardBackGradient1 = Color(0xFFfc536d);
  static const Color cardBackGradient2 = Color(0xFFb71d3f);

  // Card front colors
  static const List<Color> cardColors = [
    Color(0xFFE8734A),
    Color(0xFF4A90D9),
    Color(0xFF5B8C5A),
    Color(0xFFD4A843),
    Color(0xFFB05E8A),
    Color(0xFF6BB8B8),
    Color(0xFFE8734A),
    Color(0xFF4A90D9),
    Color(0xFF9B59B6),
    Color(0xFFE67E22),
    Color(0xFF1ABC9C),
    Color(0xFFF1C40F),
    Color(0xFFE74C3C),
    Color(0xFF3498DB),
    Color(0xFF2ECC71),
    Color(0xFFF39C12),
    Color(0xFF9B59B6),
    Color(0xFF34495E),
    Color(0xFFE91E63),
    Color(0xFF00BCD4),
  ];

  // Light theme variants
  static const Color lightBackground = Color(0xFFF0F4FF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceContainerLow = Color(0xFFF5F5F5);
  static const Color lightSurfaceContainerHigh = Color(0xFFE8E8E8);
  static const Color lightSurfaceContainerHighest = Color(0xFFD0D0D0);
  static const Color lightTextPrimary = Color(0xFF1A1A2E);
  static const Color lightTextSecondary = Color(0xFF333333);
  static const Color lightOnSurface = Color(0xFF1A1A2E);
  static const Color lightOnSurfaceVariant = Color(0xFF555555);
  static const Color lightDivider = Color(0xFFD0D0D0);

  // Tailwind-compatible CSS gray scale
  static const Color outline = Color(0xFFa9898a);
  static const Color outlineVariant = Color(0xFF5a4042);
  static const Color divider = Color(0xFF333441);
  static const Color overlay = Color(0x80000000);

  static bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color surfaceOf(BuildContext context) =>
      _isDark(context) ? surface : lightSurface;

  static Color surfaceContainerLowOf(BuildContext context) =>
      _isDark(context) ? surfaceContainerLow : lightSurfaceContainerLow;

  static Color surfaceContainerHighOf(BuildContext context) =>
      _isDark(context) ? surfaceContainerHigh : lightSurfaceContainerHigh;

  static Color surfaceContainerHighestOf(BuildContext context) =>
      _isDark(context) ? surfaceContainerHighest : lightSurfaceContainerHighest;

  static Color textPrimaryOf(BuildContext context) =>
      _isDark(context) ? textPrimary : lightTextPrimary;

  static Color textSecondaryOf(BuildContext context) =>
      _isDark(context) ? textSecondary : lightTextSecondary;

  static Color onSurfaceOf(BuildContext context) =>
      _isDark(context) ? onSurface : lightOnSurface;

  static Color onSurfaceVariantOf(BuildContext context) =>
      _isDark(context) ? onSurfaceVariant : lightOnSurfaceVariant;

  static Color dividerOf(BuildContext context) =>
      _isDark(context) ? divider : lightDivider;
}
