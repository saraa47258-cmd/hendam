import 'package:flutter/material.dart';

/// Centralized semantic colors and Material 3 [ColorScheme] definitions.
///
/// Keep values aligned with the existing brand palette in `lib/app/theme.dart`.
class AppColors {
  AppColors._();

  // Brand (existing palette)
  static const Color brandPrimary = Color(0xFF475569); // slate-600
  static const Color brandOnPrimary = Color(0xFFFFFFFF);
  static const Color brandPrimaryContainerLight = Color(0xFFE2E8F0); // slate-200
  static const Color brandOnPrimaryContainerLight = Color(0xFF1E293B); // slate-800

  static const Color brandSecondary = Color(0xFF64748B); // slate-500
  static const Color brandOnSecondary = Color(0xFFFFFFFF);
  static const Color brandSecondaryContainerLight = Color(0xFFF1F5F9); // slate-100
  static const Color brandOnSecondaryContainerLight = Color(0xFF334155);

  // Surfaces (light)
  static const Color lightSurface = Color(0xFFFAFAF9);
  static const Color lightSurfaceBright = Color(0xFFFFFFFF);
  static const Color lightSurfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color lightSurfaceContainerLow = Color(0xFFF5F5F4);
  static const Color lightSurfaceContainer = Color(0xFFF0F0EF);
  static const Color lightSurfaceContainerHigh = Color(0xFFEBEBEA);
  static const Color lightSurfaceContainerHighest = Color(0xFFE5E5E4);

  static const Color lightOnSurface = Color(0xFF1C1917); // stone-900
  static const Color lightOnSurfaceVariant = Color(0xFF64748B); // slate-500
  static const Color lightOutline = Color(0xFFE5E7EB);
  static const Color lightOutlineVariant = Color(0xFFF3F4F6);

  // Dark palette (calm, slate-based)
  static const Color darkSurface = Color(0xFF0F172A);
  static const Color darkOnSurface = Color(0xFFF8FAFC);
  static const Color darkOnSurfaceVariant = Color(0xFF94A3B8);

  // Keep primary in dark mode slightly deeper to preserve contrast for white text.
  static const Color darkPrimary = Color(0xFF64748B); // slate-500
  static const Color darkOnPrimary = Color(0xFFFFFFFF);
  static const Color darkPrimaryContainer = Color(0xFF334155);
  static const Color darkOnPrimaryContainer = Color(0xFFE2E8F0);

  static const Color darkOutline = Color(0xFF334155);
  static const Color darkOutlineVariant = Color(0xFF1E293B);

  // Semantic accents used in UI (kept from existing design)
  static const Color success = Color(0xFF10B981);
  static const Color homeAccent = Color(0xFF0EA5E9);
  static const Color ordersAccent = success;
  static const Color cartAccent = Color(0xFFF59E0B);
  static const Color profileAccent = Color(0xFF8B5CF6);

  static const Color error = Color(0xFFB91C1C);
  static const Color onError = Color(0xFFFFFFFF);

  static const ColorScheme lightScheme = ColorScheme.light(
    primary: brandPrimary,
    onPrimary: brandOnPrimary,
    primaryContainer: brandPrimaryContainerLight,
    onPrimaryContainer: brandOnPrimaryContainerLight,
    secondary: brandSecondary,
    onSecondary: brandOnSecondary,
    secondaryContainer: brandSecondaryContainerLight,
    onSecondaryContainer: brandOnSecondaryContainerLight,
    tertiary: Color(0xFF94A3B8),
    onTertiary: Color(0xFFFFFFFF),
    error: error,
    onError: onError,
    surface: lightSurface,
    onSurface: lightOnSurface,
    onSurfaceVariant: lightOnSurfaceVariant,
    outline: lightOutline,
    outlineVariant: lightOutlineVariant,
    surfaceContainerLowest: lightSurfaceContainerLowest,
    surfaceContainerLow: lightSurfaceContainerLow,
    surfaceContainer: lightSurfaceContainer,
    surfaceContainerHigh: lightSurfaceContainerHigh,
    surfaceContainerHighest: lightSurfaceContainerHighest,
  );

  static const ColorScheme darkScheme = ColorScheme.dark(
    primary: darkPrimary,
    onPrimary: darkOnPrimary,
    primaryContainer: darkPrimaryContainer,
    onPrimaryContainer: darkOnPrimaryContainer,
    secondary: darkOnSurfaceVariant,
    onSecondary: darkSurface,
    secondaryContainer: darkOutlineVariant,
    onSecondaryContainer: darkOnPrimaryContainer,
    tertiary: darkOnSurfaceVariant,
    onTertiary: darkOnPrimary,
    error: error,
    onError: onError,
    surface: darkSurface,
    onSurface: darkOnSurface,
    onSurfaceVariant: darkOnSurfaceVariant,
    outline: darkOutline,
    outlineVariant: darkOutlineVariant,
    surfaceContainerLowest: Color(0xFF0B1220),
    surfaceContainerLow: Color(0xFF111C33),
    surfaceContainer: Color(0xFF15213B),
    surfaceContainerHigh: Color(0xFF1A2745),
    surfaceContainerHighest: Color(0xFF1F2E52),
  );
}
