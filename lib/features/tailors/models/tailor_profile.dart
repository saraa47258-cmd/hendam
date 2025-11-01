class TailorProfile {
  final String id;
  final String name;
  final String city;
  final double rating;
  final bool hasShop;          // 👈 خياط مستقل؟ false
  final double serviceRadiusKm; // 👈 نطاق الخدمة للمستقل
  final bool pickup;           // استلام من العميل
  final bool dropoff;          // توصيل للعميل
  final List<String> categories; // ids من ServiceCategory التي يخدمها
  final String image;

  const TailorProfile({
    required this.id,
    required this.name,
    required this.city,
    this.rating = 4.5,
    this.hasShop = true,
    this.serviceRadiusKm = 0,
    this.pickup = false,
    this.dropoff = false,
    this.categories = const [],
    this.image = '',
  });
}
