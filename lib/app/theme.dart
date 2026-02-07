import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ═══════════════════════════════════════════════════════════════════════════
// هندام — نظام ألوان هادئ وعصري (Apple / Google style)
// Calm, modern, global palette. No bright or aggressive colors.
// ═══════════════════════════════════════════════════════════════════════════

class AppTheme {
  AppTheme._();

  // ─── Light mode: ألوان فاتحة هادئة ─────────────────────────────────────

  /// Primary: soft navy / muted blue-gray (أزرق رمادي ناعم)
  static const Color _lightPrimary = Color(0xFF475569); // slate-600
  static const Color _lightOnPrimary = Color(0xFFFFFFFF);
  static const Color _lightPrimaryContainer = Color(0xFFE2E8F0); // slate-200
  static const Color _lightOnPrimaryContainer = Color(0xFF1E293B); // slate-800

  /// Secondary: very light blue-gray for surfaces (سطوح وبطاقات)
  static const Color _lightSecondary = Color(0xFF64748B); // slate-500
  static const Color _lightOnSecondary = Color(0xFFFFFFFF);
  static const Color _lightSecondaryContainer = Color(0xFFF1F5F9); // slate-100
  static const Color _lightOnSecondaryContainer = Color(0xFF334155);

  /// Background & surface: off-white / very light warm gray
  static const Color _lightSurface = Color(0xFFFAFAF9); // warm off-white
  static const Color _lightSurfaceBright = Color(0xFFFFFFFF);
  static const Color _lightSurfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color _lightSurfaceContainerLow = Color(0xFFF5F5F4);
  static const Color _lightSurfaceContainer = Color(0xFFF0F0EF);
  static const Color _lightSurfaceContainerHigh = Color(0xFFEBEBEA);
  static const Color _lightSurfaceContainerHighest = Color(0xFFE5E5E4);

  /// Text: dark gray (primary), medium gray (secondary). High contrast.
  static const Color _lightOnSurface =
      Color(0xFF1C1917); // stone-900, not black
  static const Color _lightOnSurfaceVariant = Color(0xFF64748B); // slate-500
  static const Color _lightOutline = Color(0xFFE5E7EB);
  static const Color _lightOutlineVariant = Color(0xFFF3F4F6);

  /// Error (minimal, calm red)
  static const Color _lightError = Color(0xFFB91C1C);
  static const Color _lightOnError = Color(0xFFFFFFFF);

  /// Tertiary / accent: minimal use only
  static const Color _lightTertiary = Color(0xFF94A3B8); // slate-400
  static const Color _lightOnTertiary = Color(0xFFFFFFFF);

  // ─── Dark mode (optional, same calm logic) ──────────────────────────────

  static const Color _darkPrimary = Color(0xFF94A3B8);
  static const Color _darkOnPrimary = Color(0xFF1E293B);
  static const Color _darkPrimaryContainer = Color(0xFF334155);
  static const Color _darkOnPrimaryContainer = Color(0xFFE2E8F0);
  static const Color _darkSurface = Color(0xFF0F172A);
  static const Color _darkOnSurface = Color(0xFFF8FAFC);
  static const Color _darkOnSurfaceVariant = Color(0xFF94A3B8);
  static const Color _darkOutline = Color(0xFF334155);
  static const Color _darkOutlineVariant = Color(0xFF1E293B);

  // ─── Public theme getters ─────────────────────────────────────────────

  static ThemeData get light => _createLightTheme();
  static ThemeData get dark => _createDarkTheme();

  static ThemeData _createLightTheme() {
    const colorScheme = ColorScheme.light(
      primary: _lightPrimary,
      onPrimary: _lightOnPrimary,
      primaryContainer: _lightPrimaryContainer,
      onPrimaryContainer: _lightOnPrimaryContainer,
      secondary: _lightSecondary,
      onSecondary: _lightOnSecondary,
      secondaryContainer: _lightSecondaryContainer,
      onSecondaryContainer: _lightOnSecondaryContainer,
      tertiary: _lightTertiary,
      onTertiary: _lightOnTertiary,
      error: _lightError,
      onError: _lightOnError,
      surface: _lightSurface,
      onSurface: _lightOnSurface,
      onSurfaceVariant: _lightOnSurfaceVariant,
      outline: _lightOutline,
      outlineVariant: _lightOutlineVariant,
      surfaceContainerLowest: _lightSurfaceContainerLowest,
      surfaceContainerLow: _lightSurfaceContainerLow,
      surfaceContainer: _lightSurfaceContainer,
      surfaceContainerHigh: _lightSurfaceContainerHigh,
      surfaceContainerHighest: _lightSurfaceContainerHighest,
    );

    final textTheme =
        _buildTextTheme(colorScheme.onSurface, colorScheme.onSurfaceVariant);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: _lightSurface,
      splashFactory: InkRipple.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: _lightSurface,
        foregroundColor: _lightOnSurface,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: _lightOnSurface,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(
          color: _lightOnSurface,
          size: 24,
        ),
        actionsIconTheme: const IconThemeData(
          color: _lightOnSurface,
          size: 24,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: _lightSurfaceBright,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: _lightOutline.withOpacity(0.5)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _lightSurfaceContainerLow,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _lightOutline.withOpacity(0.6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _lightPrimary, width: 2.0),
        ),
        floatingLabelStyle: const TextStyle(color: _lightPrimary),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _lightPrimary,
          foregroundColor: _lightOnPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
          textStyle:
              textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _lightPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          side: const BorderSide(color: _lightOutline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle:
              textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 56,
        elevation: 0,
        backgroundColor: _lightSurfaceContainerLow,
        indicatorColor: _lightPrimaryContainer,
        surfaceTintColor: Colors.transparent,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 22,
            color: selected ? _lightPrimary : _lightOnSurfaceVariant,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? _lightPrimary : _lightOnSurfaceVariant,
          );
        }),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _lightSurfaceContainerLow,
        selectedColor: _lightPrimaryContainer,
        labelStyle: textTheme.bodyMedium,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: BorderSide(color: _lightOutline.withOpacity(0.5)),
      ),
      dividerTheme: const DividerThemeData(
        color: _lightOutlineVariant,
        thickness: 1,
        space: 0,
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  static ThemeData _createDarkTheme() {
    const colorScheme = ColorScheme.dark(
      primary: _darkPrimary,
      onPrimary: _darkOnPrimary,
      primaryContainer: _darkPrimaryContainer,
      onPrimaryContainer: _darkOnPrimaryContainer,
      secondary: _darkOnSurfaceVariant,
      onSecondary: _darkSurface,
      secondaryContainer: _darkOutlineVariant,
      onSecondaryContainer: _darkOnPrimaryContainer,
      tertiary: _darkOnSurfaceVariant,
      onTertiary: _darkOnPrimary,
      error: _lightError,
      onError: _lightOnError,
      surface: _darkSurface,
      onSurface: _darkOnSurface,
      onSurfaceVariant: _darkOnSurfaceVariant,
      outline: _darkOutline,
      outlineVariant: _darkOutlineVariant,
    );

    final textTheme =
        _buildTextTheme(colorScheme.onSurface, colorScheme.onSurfaceVariant);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: _darkSurface,
      splashFactory: InkRipple.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: _darkSurface,
        foregroundColor: _darkOnSurface,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: _darkOnSurface,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(
          color: _darkOnSurface,
          size: 24,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: _darkOutlineVariant,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: _darkOutline.withOpacity(0.5)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _darkPrimary,
          foregroundColor: _darkOnPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
          textStyle:
              textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _darkPrimary,
          side: const BorderSide(color: _darkOutline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 56,
        elevation: 0,
        backgroundColor: _darkSurface,
        indicatorColor: _darkPrimaryContainer,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 22,
            color: selected ? _darkPrimary : _darkOnSurfaceVariant,
          );
        }),
      ),
      dividerTheme: const DividerThemeData(
        color: _darkOutline,
        thickness: 1,
        space: 0,
      ),
    );
  }

  static TextTheme _buildTextTheme(Color onSurface, Color onSurfaceVariant) {
    final base = GoogleFonts.cairoTextTheme().apply(
      bodyColor: onSurface,
      displayColor: onSurface,
    );
    return base.copyWith(
      headlineLarge: base.headlineLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: onSurface,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: onSurface,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        height: 1.5,
        color: onSurface,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        height: 1.5,
        color: onSurface,
      ),
      bodySmall: base.bodySmall?.copyWith(
        color: onSurfaceVariant,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      labelMedium: base.labelMedium?.copyWith(
        color: onSurfaceVariant,
      ),
      labelSmall: base.labelSmall?.copyWith(
        color: onSurfaceVariant,
      ),
    );
  }
}
