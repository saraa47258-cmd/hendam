import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- ثيم الصفاء الاحترافي (Serenity Theme) ---
class AppTheme {
  // --- 1. لوحة الألوان الأساسية ---
  // لون أزرق هادئ وعميق يبعث على الثقة والاحترافية.
  static const Color _primarySeed = Color(0xFF0A5B8A);
  // لون ثانوي (Accent) دافئ للموازنة وإبراز العناصر الهامة.
  static const Color _secondarySeed = Color(0xFFE57373); // مرجاني ناعم

  // --- 2. تعريف الثيمات (فاتح ومظلم) ---
  static ThemeData get light => _createTheme(
    brightness: Brightness.light,
    primarySeed: _primarySeed,
    secondarySeed: _secondarySeed,
    background: const Color(0xFFF5F8FA), // أبيض مائل للرمادي الفاتح جداً
    surface: const Color(0xFFFFFFFF),     // أبيض نقي للبطاقات
    onSurface: const Color(0xFF1B2A33),   // أسود ناعم للنصوص
  );

  static ThemeData get dark => _createTheme(
    brightness: Brightness.dark,
    primarySeed: _primarySeed,
    secondarySeed: _secondarySeed,
    background: const Color(0xFF121A20), // أزرق داكن جداً للخلفية
    surface: const Color(0xFF1A242A),    // لون أفتح قليلاً للبطاقات
    onSurface: const Color(0xFFEBF1F5),   // أبيض مائل للزرقة للنصوص
  );

  // --- 3. الدالة المحورية لبناء الثيم ---
  static ThemeData _createTheme({
    required Brightness brightness,
    required Color primarySeed,
    required Color secondarySeed,
    required Color background,
    required Color surface,
    required Color onSurface,
  }) {
    // إنشاء لوحة الألوان الرئيسية من اللون الأساسي
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primarySeed,
      brightness: brightness,
      background: background,
      surface: surface,
      onSurface: onSurface,
      // دمج اللون الثانوي في اللوحة
      secondary: secondarySeed,
      onSecondary: Colors.white,
    );

    // --- 4. تحسين الخطوط (Typography) ---
    // استخدام خط IBM Plex Sans Arabic لمظهر احترافي ووضوح عالٍ
    final textTheme = GoogleFonts.ibmPlexSansArabicTextTheme().apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    );

    final refinedTextTheme = textTheme.copyWith(
      headlineSmall: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
      titleLarge: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      titleMedium: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      bodyLarge: textTheme.bodyLarge?.copyWith(height: 1.5), // زيادة ارتفاع السطر لسهولة القراءة
      bodyMedium: textTheme.bodyMedium?.copyWith(height: 1.5),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: refinedTextTheme,
      scaffoldBackgroundColor: colorScheme.surface,
      splashFactory: InkSparkle.splashFactory, // تأثير ضغطة أنيق

      // --- 5. تخصيص عناصر الواجهة (Components) ---

      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        scrolledUnderElevation: 2.0,
        shadowColor: colorScheme.shadow.withOpacity(0.1),
        titleTextStyle: refinedTextTheme.titleLarge,
        iconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.7)),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainer,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.primary, width: 2.0),
        ),
        floatingLabelStyle: TextStyle(color: colorScheme.primary),
      ),

      // --- 6. تصميم احترافي للأزرار ---
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: const StadiumBorder(), // حواف دائرية بالكامل
          textStyle: refinedTextTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          side: BorderSide(color: colorScheme.outline, width: 1.5),
          shape: const StadiumBorder(),
        ),
      ),

      // --- 7. شريط تنقل سفلي فاخر ---
      navigationBarTheme: NavigationBarThemeData(
        height: 75,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        indicatorShape: const CircleBorder(), // مؤشر دائري أنيق
        indicatorColor: colorScheme.primary.withOpacity(0.1),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide, // إخفاء النصوص للتركيز على الأيقونات
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 28,
            color: selected ? colorScheme.primary : colorScheme.onSurfaceVariant,
          );
        }),
      ),

      chipTheme: ChipThemeData(
        shape: const StadiumBorder(),
        side: BorderSide.none,
        selectedColor: colorScheme.primary,
        checkmarkColor: colorScheme.onPrimary,
        labelStyle: refinedTextTheme.labelLarge,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        backgroundColor: colorScheme.surfaceContainerHigh,
      ),

      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant.withOpacity(0.5),
        thickness: 1,
        space: 0,
      ),
    );
  }
}
