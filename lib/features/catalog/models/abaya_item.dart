// lib/features/catalog/models/abaya_item.dart
import 'dart:ui' show Color;

class AbayaItem {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final List<String> gallery;
  final double price;

  /// ألوان متاحة للمنتج (اختياري)
  final List<Color> colors;

  /// هل المنتج جديد؟ (اختياري)
  final bool isNew;

  const AbayaItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.gallery = const [],
    required this.price,
    this.colors = const <Color>[],
    this.isNew = false,
  });

  /// لو راح تخزن في Firestore لاحقًا
  factory AbayaItem.fromMap(Map<String, dynamic> m, String id) {
    final rawPrice = m['price'];
    final price = rawPrice is int
        ? rawPrice.toDouble()
        : (rawPrice is double ? rawPrice : 0.0);

    // الألوان تُخزّن كقيم int للـ ARGB ثم نحولها إلى Color
    final List<dynamic> rawColors = (m['colors'] as List?) ?? const [];
    final colors = rawColors
        .map((e) => e is int ? Color(e) : null)
        .whereType<Color>()
        .toList();

    return AbayaItem(
      id: id,
      title: m['title'] ?? '',
      subtitle: m['subtitle'] ?? '',
      imageUrl: m['imageUrl'] ?? '',
      gallery: List<String>.from(m['gallery'] ?? const []),
      price: price,
      colors: colors,
      isNew: (m['isNew'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
    'title': title,
    'subtitle': subtitle,
    'imageUrl': imageUrl,
    'gallery': gallery,
    'price': price,
    // نحفظ اللون كقيمة int (ARGB)
    'colors': colors.map((c) => c.value).toList(),
    'isNew': isNew,
  };
}
