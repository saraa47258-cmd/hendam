// lib/features/stores/models/category.dart

/// نموذج القسم - من traders/{traderId}/categories/{categoryId}
class TraderCategory {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final int? sortOrder;
  final bool isActive;
  final int productsCount; // عدد المنتجات في القسم

  const TraderCategory({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.sortOrder,
    this.isActive = true,
    this.productsCount = 0,
  });

  factory TraderCategory.fromMap(Map<String, dynamic> map, String id) {
    return TraderCategory(
      id: id,
      name: map['name'] ?? map['nameAr'] ?? '',
      description: map['description'] as String?,
      imageUrl: map['imageUrl'] ?? map['image'] as String?,
      sortOrder: map['sortOrder'] ?? map['sort'] as int?,
      isActive: map['isActive'] ?? true, // افتراضي true إذا لم يكن موجوداً
      productsCount: map['productsCount'] as int? ?? 0, // من Firebase
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'sortOrder': sortOrder,
      'isActive': isActive,
      'productsCount': productsCount,
    };
  }
}

