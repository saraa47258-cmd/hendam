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

  /// تحويل من Firestore Map إلى Shop
  factory Shop.fromMap(Map<String, dynamic> data, String id, {int productsCount = 0, double? minProductPrice}) {
    final business = data['business'] as Map<String, dynamic>? ?? {};
    final deliveryOptions = business['deliveryOptions'] as List<dynamic>? ?? [];
    final hasDelivery = deliveryOptions.contains('delivery') || deliveryOptions.contains('pickup');
    
    final profile = data['profile'] as Map<String, dynamic>? ?? {};
    final avatar = profile['avatar'] as String?;
    final gallery = profile['gallery'] as List<dynamic>? ?? [];
    
    // استخدام الصورة من avatar أو أول صورة من gallery أو صورة افتراضية
    String imageUrl = avatar ?? '';
    if (imageUrl.isEmpty && gallery.isNotEmpty) {
      imageUrl = gallery.first.toString();
    }
    if (imageUrl.isEmpty) {
      imageUrl = 'assets/abaya/abaya1.jpeg'; // صورة افتراضية
    }

    // التقييم - افتراضي 0 إذا لم يكن موجوداً
    final rating = (data['rating'] is num) ? (data['rating'] as num).toDouble() : 0.0;
    
    // عدد المراجعات - افتراضي 0
    final reviews = (data['reviews'] is num) ? (data['reviews'] as int) : 0;

    // الموقع
    final location = data['location'] as String? ?? '';
    
    // نوع المحل - من business.type أو "عبايات" كافتراضي
    final businessType = business['type'] as String? ?? '';
    String category = 'عبايات';
    if (businessType.contains('store')) {
      category = 'عبايات';
    } else if (businessType.contains('tailor')) {
      category = 'تفصيل';
    }

    // السعر الأدنى - من minProductPrice أو 0
    final minPrice = minProductPrice ?? 0.0;

    // حالة الفتح - يمكن إضافة منطق للتحقق من أوقات العمل
    // حالياً نستخدم isActive كافتراضي
    final isActive = data['isActive'] as bool? ?? true;
    final isOpen = isActive; // يمكن تطوير هذا لاحقاً

    // استخراج اسم المحل (وليس اسم صاحب المحل)
    // الأولوية: business.shopName > shopName > name
    final shopName = business['shopName'] as String? ?? 
                     data['shopName'] as String? ?? 
                     data['name'] as String? ?? 
                     '';

    return Shop(
      id: id,
      name: shopName,
      city: location.isNotEmpty ? location : 'مسقط',
      imageUrl: imageUrl,
      category: category,
      rating: rating,
      reviews: reviews,
      servicesCount: productsCount,
      minPrice: minPrice,
      delivery: hasDelivery,
      isOpen: isOpen,
      isFavorite: false,
    );
  }
}
