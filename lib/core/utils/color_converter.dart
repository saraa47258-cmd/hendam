// lib/core/utils/color_converter.dart
import 'dart:ui' show Color;

/// أداة مساعدة لتحويل الألوان من Firebase إلى Color objects
class ColorConverter {
  /// قاموس للألوان الشائعة
  static const Map<String, int> _colorMap = {
    'أسود': 0xFF000000,
    'أبيض': 0xFFFFFFFF,
    'رمادي': 0xFF808080,
    'بني': 0xFF8B4513,
    'أحمر': 0xFFFF0000,
    'أزرق': 0xFF0000FF,
    'أخضر': 0xFF008000,
    'أصفر': 0xFFFFFF00,
    'وردي': 0xFFFFC0CB,
    'بني فاتح': 0xFFA0522D,
    'بيج': 0xFFF5F5DC,
    'كحلي': 0xFF2F4F4F,
    'زيتي': 0xFF556B2F,
    'بنفسجي': 0xFF800080,
    'برتقالي': 0xFFFFA500,
    'سماوي': 0xFF00FFFF,
    'بني غامق': 0xFF654321,
    'رمادي فاتح': 0xFFD3D3D3,
    'رمادي غامق': 0xFFA9A9A9,
    'كحلي غامق': 0xFF191970,
  };

  /// تحويل لون من Firebase (String أو int) إلى Color
  static Color? fromFirebase(dynamic value) {
    if (value == null) return null;

    // إذا كان int (ARGB value)
    if (value is int) {
      return Color(value);
    }

    // إذا كان String
    if (value is String) {
      final normalized = value.trim();

      // محاولة التحويل من hex string (#RRGGBB أو RRGGBB)
      if (normalized.startsWith('#') || 
          (normalized.length == 6 && _isHexString(normalized))) {
        try {
          final hex = normalized.replaceFirst('#', '');
          return Color(int.parse(hex, radix: 16) | 0xFF000000);
        } catch (_) {
          // إذا فشل التحويل، جرب البحث في القاموس
        }
      }

      // البحث في قاموس الألوان النصية
      final colorValue = _colorMap[normalized] ?? _colorMap[normalized.toLowerCase()];
      if (colorValue != null) {
        return Color(colorValue);
      }

      // محاولة أخرى للتحويل من hex بدون #
      try {
        return Color(int.parse(normalized, radix: 16) | 0xFF000000);
      } catch (_) {
        return null;
      }
    }

    return null;
  }

  /// تحقق من أن النص هو hex string
  static bool _isHexString(String s) {
    return RegExp(r'^[0-9A-Fa-f]+$').hasMatch(s);
  }

  /// تحويل Color إلى hex string للاستخدام في Firebase
  static String toHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }
}


