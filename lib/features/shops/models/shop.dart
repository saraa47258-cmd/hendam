class Shop {
  final String id;
  final String name;
  final String city;
  final String imageUrl;   // اختياري
  final String category;   // مثال: 'men'
  final double rating;     // 0..5
  final int reviews;       // عدد المراجعات
  final int servicesCount; // عدد الخدمات المتاحة
  final double minPrice;   // ابتداءً من
  final bool delivery;     // توصيل
  final bool isOpen;       // مفتوح الآن
  final bool isFavorite;   // مفضلة (شكليًا)

  Shop({
    required this.id,
    required this.name,
    required this.city,
    required this.imageUrl,
    required this.category,
    required this.rating,
    required this.reviews,
    required this.servicesCount,
    required this.minPrice,
    required this.delivery,
    required this.isOpen,
    this.isFavorite = false,
  });
}
