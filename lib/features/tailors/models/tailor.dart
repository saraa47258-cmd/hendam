class Tailor {
  final String id;
  final String name;
  final String city;
  final double rating;
  final List<String> tags;
  final String? imageUrl;

  Tailor({
    required this.id,
    required this.name,
    required this.city,
    required this.rating,
    required this.tags,
    this.imageUrl,
  });
}
