/// نموذج لتصميم التطريز
class EmbroideryDesign {
  final String id;
  final String imageUrl;
  final String name;
  final double price;
  final DateTime uploadedAt;

  EmbroideryDesign({
    required this.id,
    required this.imageUrl,
    required this.name,
    required this.price,
    required this.uploadedAt,
  });

  factory EmbroideryDesign.fromMap(Map<String, dynamic> map, String id) {
    return EmbroideryDesign(
      id: id,
      imageUrl: map['imageUrl'] as String? ?? '',
      name: map['name'] as String? ?? 'تطريز ${id.substring(0, 8)}',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      uploadedAt: map['uploadedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['uploadedAt'] as int)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'imageUrl': imageUrl,
      'name': name,
      'price': price,
      'uploadedAt': uploadedAt.millisecondsSinceEpoch,
    };
  }

  EmbroideryDesign copyWith({
    String? id,
    String? imageUrl,
    String? name,
    double? price,
    DateTime? uploadedAt,
  }) {
    return EmbroideryDesign(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      name: name ?? this.name,
      price: price ?? this.price,
      uploadedAt: uploadedAt ?? this.uploadedAt,
    );
  }
}

