// lib/features/catalog/models/abaya_item.dart
import 'dart:ui' show Color;
import '../../../core/utils/color_converter.dart';

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

    // الألوان تُخزّن كقيم int أو strings في Firebase
    final List<dynamic> rawColors = (m['colors'] as List?) ?? const [];
    final colors = rawColors
        .map((e) => ColorConverter.fromFirebase(e))
        .whereType<Color>()
        .toList();

    // معالجة الصور - يمكن أن تكون في imageUrl أو imageUrls
    String imageUrl = m['imageUrl'] as String? ?? '';
    if (imageUrl.isEmpty) {
      final imageUrls = m['imageUrls'] as List<dynamic>? ?? [];
      if (imageUrls.isNotEmpty) {
        imageUrl = imageUrls.first.toString();
      }
    }

    // معالجة العنوان - يمكن أن يكون في name أو title
    String title = m['title'] as String? ?? '';
    if (title.isEmpty) {
      title = m['name'] as String? ?? '';
    }

    // معالجة الوصف - يمكن أن يكون في subtitle أو description
    String subtitle = m['subtitle'] as String? ?? '';
    if (subtitle.isEmpty) {
      subtitle = m['description'] as String? ?? '';
    }

    // معالجة gallery
    List<String> gallery = [];
    if (m['gallery'] != null) {
      gallery = List<String>.from(m['gallery'] ?? const []);
    } else if (m['imageUrls'] != null) {
      gallery = (m['imageUrls'] as List<dynamic>).map((e) => e.toString()).toList();
    }

    return AbayaItem(
      id: id,
      title: title,
      subtitle: subtitle,
      imageUrl: imageUrl,
      gallery: gallery,
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
