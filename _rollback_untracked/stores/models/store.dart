// lib/features/stores/models/store.dart

/// نموذج المتجر - متوافق مع collection traders في Firebase
class Store {
  final String id;
  final String name;
  final String category;
  final String address;
  final String location;
  final String email;
  final String? phone;
  final String? imageUrl;
  final bool isActive;
  final bool isVerified;
  final DateTime? createdAt;
  final int productsCount; // عدد المنتجات

  const Store({
    required this.id,
    required this.name,
    required this.category,
    required this.address,
    required this.location,
    required this.email,
    this.phone,
    this.imageUrl,
    required this.isActive,
    required this.isVerified,
    this.createdAt,
    this.productsCount = 0,
  });

  factory Store.fromMap(Map<String, dynamic> map, String id, {int productsCount = 0}) {
    // استخراج رقم الهاتف من contact إذا كان موجوداً
    String? phone;
    if (map['contact'] != null && map['contact'] is Map) {
      phone = map['contact']['phone'];
    }

    return Store(
      id: id,
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      address: map['address'] ?? '',
      location: map['location'] ?? '',
      email: map['email'] ?? '',
      phone: phone,
      imageUrl: map['storeImageUrl'] ?? map['imageUrl'] ?? map['image'] ?? map['logo'],
      isActive: map['isActive'] ?? false,
      isVerified: map['isVerified'] ?? false,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as dynamic).toDate()
          : null,
      productsCount: productsCount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'address': address,
      'location': location,
      'email': email,
      'contact': {
        'phone': phone,
        'email': email,
      },
      'imageUrl': imageUrl,
      'isActive': isActive,
      'isVerified': isVerified,
    };
  }

  /// هل المتجر مفتوح (نستخدم isActive كمؤشر)
  bool get isOpen => isActive;
}
