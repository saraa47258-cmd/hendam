import '../../cart/models/cart_item.dart';

class Order {
  final String id;
  final String status;
  final DateTime createdAt;
  final double totalOmr;
  final List<CartItem> items;

  Order({
    required this.id,
    required this.status,
    required this.createdAt,
    required this.totalOmr,
    required this.items,
  });

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'totalOmr': totalOmr,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      totalOmr: json['totalOmr'].toDouble(),
      items: (json['items'] as List)
          .map((item) => CartItem.fromJson(item))
          .toList(),
    );
  }
}
