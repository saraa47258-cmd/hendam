
class Tailor {
  final String id, name, city, image;
  final double rating;
  final List<String> tags;
  Tailor({
    required this.id,
    required this.name,
    required this.city,
    required this.rating,
    this.image = '',
    this.tags = const [],
  });
}
