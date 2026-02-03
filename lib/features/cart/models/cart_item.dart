import '../../catalog/models/product.dart';

/// نموذج تفاصيل التخصيص (اللون، المقاسات، الملاحظات)
class CartCustomization {
  final String? selectedColor; // اللون المختار (HEX مثل #RRGGBB)
  final String? colorName; // اسم اللون (اختياري)
  final Map<String, double>? measurements; // المقاسات {length, sleeve, width}
  final String? unit; // وحدة القياس (in أو cm)
  final String? notes; // ملاحظات إضافية

  const CartCustomization({
    this.selectedColor,
    this.colorName,
    this.measurements,
    this.unit,
    this.notes,
  });

  /// هل يوجد أي تخصيص؟
  bool get hasCustomization =>
      selectedColor != null ||
      (measurements != null && measurements!.isNotEmpty) ||
      (notes != null && notes!.isNotEmpty);

  /// نص مختصر للتخصيص
  String get summary {
    final parts = <String>[];
    if (selectedColor != null) {
      parts.add('اللون: ${colorName ?? selectedColor}');
    }
    if (measurements != null && measurements!.isNotEmpty) {
      final m = measurements!;
      if (m['length'] != null) parts.add('الطول: ${m['length']}');
      if (m['sleeve'] != null) parts.add('الكم: ${m['sleeve']}');
      if (m['width'] != null) parts.add('العرض: ${m['width']}');
    }
    return parts.join(' • ');
  }

  Map<String, dynamic> toJson() {
    return {
      'selectedColor': selectedColor,
      'colorName': colorName,
      'measurements': measurements,
      'unit': unit,
      'notes': notes,
    };
  }

  factory CartCustomization.fromJson(Map<String, dynamic> json) {
    Map<String, double>? measurements;
    if (json['measurements'] != null) {
      measurements = Map<String, double>.from(
        (json['measurements'] as Map).map(
          (k, v) => MapEntry(k.toString(), (v as num).toDouble()),
        ),
      );
    }
    return CartCustomization(
      selectedColor: json['selectedColor'],
      colorName: json['colorName'],
      measurements: measurements,
      unit: json['unit'],
      notes: json['notes'],
    );
  }

  CartCustomization copyWith({
    String? selectedColor,
    String? colorName,
    Map<String, double>? measurements,
    String? unit,
    String? notes,
  }) {
    return CartCustomization(
      selectedColor: selectedColor ?? this.selectedColor,
      colorName: colorName ?? this.colorName,
      measurements: measurements ?? this.measurements,
      unit: unit ?? this.unit,
      notes: notes ?? this.notes,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CartCustomization) return false;
    return selectedColor == other.selectedColor &&
        _mapEquals(measurements, other.measurements);
  }

  @override
  int get hashCode => Object.hash(selectedColor, measurements);

  static bool _mapEquals(Map<String, double>? a, Map<String, double>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (a[key] != b[key]) return false;
    }
    return true;
  }
}

class CartItem {
  final String? productId; // معرف المنتج
  final Product? product; // منتج (اختياري)
  final String? serviceName; // أو خدمة (اختياري)
  final String? imageUrl; // صورة المنتج
  final double price; // سعر الوحدة
  int qty; // الكمية
  final CartCustomization? customization; // تفاصيل التخصيص
  final DateTime? createdAt; // تاريخ الإضافة

  CartItem({
    this.productId,
    this.product,
    this.serviceName,
    this.imageUrl,
    required this.price,
    this.qty = 1,
    this.customization,
    DateTime? createdAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        assert(product != null || serviceName != null,
            'Either product or serviceName must be provided');

  CartItem copy() => CartItem(
        productId: productId,
        product: product,
        serviceName: serviceName,
        imageUrl: imageUrl,
        price: price,
        qty: qty,
        customization: customization,
        createdAt: createdAt,
      );

  CartItem copyWith({
    String? productId,
    Product? product,
    String? serviceName,
    String? imageUrl,
    double? price,
    int? qty,
    CartCustomization? customization,
    DateTime? createdAt,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      product: product ?? this.product,
      serviceName: serviceName ?? this.serviceName,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      qty: qty ?? this.qty,
      customization: customization ?? this.customization,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get title => product?.name ?? serviceName ?? 'خدمة';

  /// هل العنصر له نفس المنتج والتخصيص؟
  bool matches(String? id, CartCustomization? other) {
    if (productId != id) return false;
    if (customization == null && other == null) return true;
    if (customization == null || other == null) return false;
    return customization == other;
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'product': product?.toJson(),
      'serviceName': serviceName,
      'imageUrl': imageUrl,
      'price': price,
      'qty': qty,
      'customization': customization?.toJson(),
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['productId'],
      product:
          json['product'] != null ? Product.fromJson(json['product']) : null,
      serviceName: json['serviceName'],
      imageUrl: json['imageUrl'],
      price: (json['price'] as num).toDouble(),
      qty: json['qty'] ?? 1,
      customization: json['customization'] != null
          ? CartCustomization.fromJson(json['customization'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }
}
