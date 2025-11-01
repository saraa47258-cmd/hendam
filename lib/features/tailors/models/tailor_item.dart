class TailorItem {
  final String name;
  final double rating;
  final double distanceKm;
  final bool isOpen;
  final List<String> tags; // مثل: ['تطريز', 'تسليم سريع']
  final String? imageUrl;  // إن وُجدت صورة للمتجر

  const TailorItem({
    required this.name,
    required this.rating,
    required this.distanceKm,
    required this.isOpen,
    this.tags = const [],
    this.imageUrl,
  });
}
