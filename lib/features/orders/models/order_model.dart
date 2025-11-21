// lib/features/orders/models/order_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

/// نموذج بيانات الطلب
class OrderModel {
  final String id;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String tailorId;
  final String tailorName;
  final String fabricId;
  final String fabricName;
  final String fabricType;
  final String fabricImageUrl;
  final String fabricColor;
  final String fabricColorHex;
  final Map<String, double> measurements; // المقاسات
  final String notes;
  
  // معلومات التطريز
  final String? embroideryDesignId;
  final String? embroideryDesignName;
  final String? embroideryDesignImageUrl;
  final double? embroideryDesignPrice;
  
  final double totalPrice;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;
  final String? rejectionReason;

  OrderModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.tailorId,
    required this.tailorName,
    required this.fabricId,
    required this.fabricName,
    required this.fabricType,
    required this.fabricImageUrl,
    required this.fabricColor,
    required this.fabricColorHex,
    required this.measurements,
    required this.notes,
    this.embroideryDesignId,
    this.embroideryDesignName,
    this.embroideryDesignImageUrl,
    this.embroideryDesignPrice,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.completedAt,
    this.rejectionReason,
  });

  /// تحويل من Firestore Document إلى OrderModel
  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id: doc.id,
      customerId: data['customerId'] ?? '',
      customerName: data['customerName'] ?? '',
      customerPhone: data['customerPhone'] ?? '',
      tailorId: data['tailorId'] ?? '',
      tailorName: data['tailorName'] ?? '',
      fabricId: data['fabricId'] ?? '',
      fabricName: data['fabricName'] ?? '',
      fabricType: data['fabricType'] ?? '',
      fabricImageUrl: data['fabricImageUrl'] ?? '',
      fabricColor: data['fabricColor'] ?? '',
      fabricColorHex: data['fabricColorHex'] ?? '',
      measurements: Map<String, double>.from(data['measurements'] ?? {}),
      notes: data['notes'] ?? '',
      embroideryDesignId: data['embroideryDesignId'],
      embroideryDesignName: data['embroideryDesignName'],
      embroideryDesignImageUrl: data['embroideryDesignImageUrl'],
      embroideryDesignPrice: (data['embroideryDesignPrice'] as num?)?.toDouble(),
      totalPrice: (data['totalPrice'] as num?)?.toDouble() ?? 0.0,
      status: OrderStatus.values.firstWhere(
        (e) => e.toString() == 'OrderStatus.${data['status']}',
        orElse: () => OrderStatus.pending,
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      rejectionReason: data['rejectionReason'],
    );
  }

  /// تحويل من OrderModel إلى Map للـ Firestore
  Map<String, dynamic> toFirestore() {
    return {
      // معلومات العميل
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,

      // معلومات الخياط
      'tailorId': tailorId,
      'tailorName': tailorName,

      // معلومات القماش
      'fabricId': fabricId,
      'fabricName': fabricName,
      'fabricType': fabricType,
      'fabricImageUrl': fabricImageUrl,

      // لون القماش
      'fabricColor': fabricColor,
      'fabricColorHex': fabricColorHex,

      // المقاسات التفصيلية
      'measurements': measurements,

      // ملاحظات إضافية
      'notes': notes,

      // معلومات التطريز
      'embroideryDesignId': embroideryDesignId,
      'embroideryDesignName': embroideryDesignName,
      'embroideryDesignImageUrl': embroideryDesignImageUrl,
      'embroideryDesignPrice': embroideryDesignPrice,

      // السعر الإجمالي
      'totalPrice': totalPrice,

      // حالة الطلب
      'status': status.toString().split('.').last,

      // التواريخ
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,

      // سبب الرفض (إن وجد)
      'rejectionReason': rejectionReason,
    };
  }

  /// تحويل من OrderModel إلى Map (للتوافق مع الكود القديم)
  Map<String, dynamic> toMap() {
    return toFirestore();
  }

  /// نسخ الطلب مع تحديث بعض الحقول
  OrderModel copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? tailorId,
    String? tailorName,
    String? fabricId,
    String? fabricName,
    String? fabricType,
    String? fabricImageUrl,
    String? fabricColor,
    String? fabricColorHex,
    Map<String, double>? measurements,
    String? notes,
    String? embroideryDesignId,
    String? embroideryDesignName,
    String? embroideryDesignImageUrl,
    double? embroideryDesignPrice,
    double? totalPrice,
    OrderStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
    String? rejectionReason,
  }) {
    return OrderModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      tailorId: tailorId ?? this.tailorId,
      tailorName: tailorName ?? this.tailorName,
      fabricId: fabricId ?? this.fabricId,
      fabricName: fabricName ?? this.fabricName,
      fabricType: fabricType ?? this.fabricType,
      fabricImageUrl: fabricImageUrl ?? this.fabricImageUrl,
      fabricColor: fabricColor ?? this.fabricColor,
      fabricColorHex: fabricColorHex ?? this.fabricColorHex,
      measurements: measurements ?? this.measurements,
      notes: notes ?? this.notes,
      embroideryDesignId: embroideryDesignId ?? this.embroideryDesignId,
      embroideryDesignName: embroideryDesignName ?? this.embroideryDesignName,
      embroideryDesignImageUrl: embroideryDesignImageUrl ?? this.embroideryDesignImageUrl,
      embroideryDesignPrice: embroideryDesignPrice ?? this.embroideryDesignPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }
}

/// حالات الطلب
enum OrderStatus {
  pending, // في الانتظار
  accepted, // مقبول
  inProgress, // قيد التنفيذ
  completed, // مكتمل
  rejected, // مرفوض
  cancelled, // ملغي
}

/// امتداد لحالات الطلب
extension OrderStatusExtension on OrderStatus {
  String get labelAr {
    switch (this) {
      case OrderStatus.pending:
        return 'في الانتظار';
      case OrderStatus.accepted:
        return 'مقبول';
      case OrderStatus.inProgress:
        return 'قيد التنفيذ';
      case OrderStatus.completed:
        return 'مكتمل';
      case OrderStatus.rejected:
        return 'مرفوض';
      case OrderStatus.cancelled:
        return 'ملغي';
    }
  }

  String get labelEn {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.accepted:
        return 'Accepted';
      case OrderStatus.inProgress:
        return 'In Progress';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.rejected:
        return 'Rejected';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}
