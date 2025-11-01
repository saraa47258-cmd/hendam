import '../../catalog/models/product.dart';

class CartItem {
  final Product? product;     // منتج (اختياري)
  final String? serviceName;  // أو خدمة (اختياري)
  final double price;         // سعر الوحدة
  int qty;                    // الكمية

  CartItem({
    this.product,
    this.serviceName,
    required this.price,
    this.qty = 1,
  }) : assert(product != null || serviceName != null,
  'Either product or serviceName must be provided');

  CartItem copy() => CartItem(
    product: product,
    serviceName: serviceName,
    price: price,
    qty: qty,
  );

  CartItem copyWith({
    Product? product,
    String? serviceName,
    double? price,
    int? qty,
  }) {
    return CartItem(
      product: product ?? this.product,
      serviceName: serviceName ?? this.serviceName,
      price: price ?? this.price,
      qty: qty ?? this.qty,
    );
  }

  String get title => product?.name ?? serviceName ?? 'خدمة';

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'product': product?.toJson(),
      'serviceName': serviceName,
      'price': price,
      'qty': qty,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: json['product'] != null ? Product.fromJson(json['product']) : null,
      serviceName: json['serviceName'],
      price: json['price'].toDouble(),
      qty: json['qty'],
    );
  }
}
