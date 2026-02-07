// lib/features/orders/models/order_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

/// نموذج بيانات مستلم الهدية
class GiftRecipientDetails {
  final String recipientName;
  final String? recipientPhone;
  final String? city;
  final String? address;
  final String? giftMessage;
  final String? deliveryNotes;
  final bool hidePrice;

  GiftRecipientDetails({
    required this.recipientName,
    this.recipientPhone,
    this.city,
    this.address,
    this.giftMessage,
    this.deliveryNotes,
    this.hidePrice = false,
  });

  factory GiftRecipientDetails.fromMap(Map<String, dynamic> map) {
    return GiftRecipientDetails(
      recipientName: map['recipientName'] ?? '',
      recipientPhone: map['recipientPhone'],
      city: map['city'],
      address: map['address'],
      giftMessage: map['giftMessage'],
      deliveryNotes: map['deliveryNotes'],
      hidePrice: map['hidePrice'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'recipientName': recipientName,
      'recipientPhone': recipientPhone,
      'city': city,
      'address': address,
      'giftMessage': giftMessage,
      'deliveryNotes': deliveryNotes,
      'hidePrice': hidePrice,
    };
  }
}

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

  // تفاصيل الخيوط
  final List<String>? threadColorIds;
  final List<String>? threadColorNames;
  final int? threadCount;

  // معلومات الهدية
  final bool isGift;
  final GiftRecipientDetails? giftRecipientDetails;

  // معلومات منتجات المتاجر (merchant products)
  final String? orderType; // 'tailoring', 'abaya', 'merchant_product'
  final String? productId;
  final String? productName;
  final String? productSubtitle;
  final String? productImageUrl;
  final String? selectedColor;
  final String? traderId;
  final String? traderName;

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
    this.threadColorIds,
    this.threadColorNames,
    this.threadCount,
    this.isGift = false,
    this.giftRecipientDetails,
    this.orderType,
    this.productId,
    this.productName,
    this.productSubtitle,
    this.productImageUrl,
    this.selectedColor,
    this.traderId,
    this.traderName,
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
      embroideryDesignPrice:
          (data['embroideryDesignPrice'] as num?)?.toDouble(),
      threadColorIds: (data['threadColorIds'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      threadColorNames: (data['threadColorNames'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      threadCount: (data['threadCount'] as num?)?.toInt(),
      isGift: data['isGift'] ?? false,
      giftRecipientDetails: data['giftRecipientDetails'] != null
          ? GiftRecipientDetails.fromMap(
              Map<String, dynamic>.from(data['giftRecipientDetails']))
          : null,
      // معلومات منتجات المتاجر
      orderType: data['orderType'],
      productId: data['productId'],
      productName: data['productName'],
      productSubtitle: data['productSubtitle'],
      productImageUrl: data['productImageUrl'],
      selectedColor: data['selectedColor'],
      traderId: data['traderId'],
      traderName: data['traderName'],
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

      // تفاصيل الخيوط
      'threadColorIds': threadColorIds,
      'threadColorNames': threadColorNames,
      'threadCount': threadCount,

      // معلومات الهدية
      'isGift': isGift,
      'giftRecipientDetails': giftRecipientDetails?.toMap(),

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
    List<String>? threadColorIds,
    List<String>? threadColorNames,
    int? threadCount,
    bool? isGift,
    GiftRecipientDetails? giftRecipientDetails,
    String? orderType,
    String? productId,
    String? productName,
    String? productSubtitle,
    String? productImageUrl,
    String? selectedColor,
    String? traderId,
    String? traderName,
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
      embroideryDesignImageUrl:
          embroideryDesignImageUrl ?? this.embroideryDesignImageUrl,
      embroideryDesignPrice:
          embroideryDesignPrice ?? this.embroideryDesignPrice,
      threadColorIds: threadColorIds ?? this.threadColorIds,
      threadColorNames: threadColorNames ?? this.threadColorNames,
      threadCount: threadCount ?? this.threadCount,
      isGift: isGift ?? this.isGift,
      giftRecipientDetails: giftRecipientDetails ?? this.giftRecipientDetails,
      orderType: orderType ?? this.orderType,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productSubtitle: productSubtitle ?? this.productSubtitle,
      productImageUrl: productImageUrl ?? this.productImageUrl,
      selectedColor: selectedColor ?? this.selectedColor,
      traderId: traderId ?? this.traderId,
      traderName: traderName ?? this.traderName,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }

  /// الحصول على صورة الطلب الصحيحة (منتج أو قماش)
  String get displayImageUrl {
    if (orderType == 'merchant_product' ||
        orderType == 'abaya' ||
        orderType == 'cart_order') {
      return productImageUrl ?? '';
    }
    return fabricImageUrl;
  }

  /// الحصول على اسم الطلب الصحيح
  String get displayName {
    if (orderType == 'merchant_product' ||
        orderType == 'abaya' ||
        orderType == 'cart_order') {
      return productName ?? '';
    }
    return fabricName;
  }

  /// الحصول على اسم المتجر/الخياط
  String get displaySellerName {
    if (orderType == 'merchant_product' ||
        orderType == 'abaya' ||
        orderType == 'cart_order') {
      return traderName ?? tailorName;
    }
    return tailorName;
  }

  /// هل هذا طلب منتج من متجر؟
  bool get isMerchantProduct =>
      orderType == 'merchant_product' ||
      orderType == 'abaya' ||
      orderType == 'cart_order';
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
