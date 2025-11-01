class Product {
  final String id, name, image;
  final double priceOmr;
  
  Product({required this.id, required this.name, required this.priceOmr, this.image = ''});

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'priceOmr': priceOmr,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      image: json['image'] ?? '',
      priceOmr: json['priceOmr'].toDouble(),
    );
  }
}
