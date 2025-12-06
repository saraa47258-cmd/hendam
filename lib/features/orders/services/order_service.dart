// lib/features/orders/services/order_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hindam/core/services/firebase_service.dart';
import '../models/order_model.dart';

/// خدمة إدارة الطلبات
class OrderService {
  static const String _ordersCollection = 'orders';

  /// إرسال طلب جديد
  static Future<String?> submitOrder(OrderModel order) async {
    try {
      // التأكد من إرسال جميع التفاصيل
      final orderData = order.toFirestore();

      print('📦 إرسال الطلب مع التفاصيل التالية:');
      print('   👤 العميل: ${order.customerName} (${order.customerPhone})');
      print('   👔 الخياط: ${order.tailorName}');
      print('   🧵 القماش: ${order.fabricName}');
      print('   🎨 اللون: ${order.fabricColorHex}');
      print('   📏 المقاسات:');
      order.measurements.forEach((key, value) {
        print('      • $key: ${value.toStringAsFixed(1)} سم');
      });
      print('   💰 السعر: ر.ع ${order.totalPrice.toStringAsFixed(3)}');
      print(
          '   📝 الملاحظات: ${order.notes.isEmpty ? "لا يوجد" : order.notes}');

      final docRef = await FirebaseService.firestore
          .collection(_ordersCollection)
          .add(orderData);

      print('✅ تم إرسال الطلب بنجاح: ${docRef.id}');
      print('   📊 الحالة: ${order.status}');
      print('   📅 التاريخ: ${order.createdAt}');

      return docRef.id;
    } catch (e, stackTrace) {
      print('❌ خطأ في إرسال الطلب: $e');
      print('📍 Stack trace: $stackTrace');
      return null;
    }
  }

  /// جلب طلبات العميل
  static Stream<List<OrderModel>> getCustomerOrders(String customerId) {
    return FirebaseService.firestore
        .collection(_ordersCollection)
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList());
  }

  /// جلب طلبات الخياط
  static Stream<List<OrderModel>> getTailorOrders(String tailorId) {
    return FirebaseService.firestore
        .collection(_ordersCollection)
        .where('tailorId', isEqualTo: tailorId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList());
  }

  /// جلب طلبات الخياط حسب الحالة
  static Stream<List<OrderModel>> getTailorOrdersByStatus(
      String tailorId, OrderStatus status) {
    return FirebaseService.firestore
        .collection(_ordersCollection)
        .where('tailorId', isEqualTo: tailorId)
        .where('status', isEqualTo: status.toString().split('.').last)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList());
  }

  /// جلب طلب واحد بالتفصيل (لمرة واحدة)
  static Future<OrderModel?> getOrderById(String orderId) async {
    try {
      final doc = await FirebaseService.firestore
          .collection(_ordersCollection)
          .doc(orderId)
          .get();

      if (doc.exists) {
        return OrderModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('❌ خطأ في جلب الطلب: $e');
      return null;
    }
  }

  /// جلب طلب واحد بالتفصيل مع التحديثات الفورية
  static Stream<OrderModel?> getOrderByIdStream(String orderId) {
    return FirebaseService.firestore
        .collection(_ordersCollection)
        .doc(orderId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        print('🔄 Order updated: $orderId - ${doc.data()?['status']}');
        return OrderModel.fromFirestore(doc);
      }
      return null;
    });
  }

  /// تحديث حالة الطلب
  static Future<bool> updateOrderStatus(String orderId, OrderStatus newStatus,
      {String? rejectionReason}) async {
    try {
      final updateData = {
        'status': newStatus.toString().split('.').last,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (newStatus == OrderStatus.completed) {
        updateData['completedAt'] = FieldValue.serverTimestamp();
      }

      if (newStatus == OrderStatus.rejected && rejectionReason != null) {
        updateData['rejectionReason'] = rejectionReason;
      }

      await FirebaseService.firestore
          .collection(_ordersCollection)
          .doc(orderId)
          .update(updateData);

      print('✅ تم تحديث حالة الطلب: $orderId -> ${newStatus.labelAr}');
      return true;
    } catch (e) {
      print('❌ خطأ في تحديث حالة الطلب: $e');
      return false;
    }
  }

  /// إلغاء الطلب
  static Future<bool> cancelOrder(String orderId, String reason) async {
    try {
      await FirebaseService.firestore
          .collection(_ordersCollection)
          .doc(orderId)
          .update({
        'status': OrderStatus.cancelled.toString().split('.').last,
        'rejectionReason': reason,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ تم إلغاء الطلب: $orderId');
      return true;
    } catch (e) {
      print('❌ خطأ في إلغاء الطلب: $e');
      return false;
    }
  }

  /// جلب إحصائيات الطلبات للخياط
  static Future<Map<String, dynamic>> getTailorOrderStatistics(
      String tailorId) async {
    try {
      final snapshot = await FirebaseService.firestore
          .collection(_ordersCollection)
          .where('tailorId', isEqualTo: tailorId)
          .get();

      int totalOrders = snapshot.docs.length;
      int pendingOrders = 0;
      int acceptedOrders = 0;
      int inProgressOrders = 0;
      int completedOrders = 0;
      int rejectedOrders = 0;
      int cancelledOrders = 0;
      double totalRevenue = 0.0;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final status = data['status'] as String?;
        final price = (data['totalPrice'] as num?)?.toDouble() ?? 0.0;

        switch (status) {
          case 'pending':
            pendingOrders++;
            break;
          case 'accepted':
            acceptedOrders++;
            break;
          case 'inProgress':
            inProgressOrders++;
            break;
          case 'completed':
            completedOrders++;
            totalRevenue += price;
            break;
          case 'rejected':
            rejectedOrders++;
            break;
          case 'cancelled':
            cancelledOrders++;
            break;
        }
      }

      return {
        'totalOrders': totalOrders,
        'pendingOrders': pendingOrders,
        'acceptedOrders': acceptedOrders,
        'inProgressOrders': inProgressOrders,
        'completedOrders': completedOrders,
        'rejectedOrders': rejectedOrders,
        'cancelledOrders': cancelledOrders,
        'totalRevenue': totalRevenue,
      };
    } catch (e) {
      print('❌ خطأ في جلب إحصائيات الطلبات: $e');
      return {
        'error': e.toString(),
      };
    }
  }

  /// جلب إحصائيات الطلبات للعميل
  static Future<Map<String, dynamic>> getCustomerOrderStatistics(
      String customerId) async {
    try {
      final snapshot = await FirebaseService.firestore
          .collection(_ordersCollection)
          .where('customerId', isEqualTo: customerId)
          .get();

      int totalOrders = snapshot.docs.length;
      int pendingOrders = 0;
      int acceptedOrders = 0;
      int inProgressOrders = 0;
      int completedOrders = 0;
      int rejectedOrders = 0;
      int cancelledOrders = 0;
      double totalSpent = 0.0;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final status = data['status'] as String?;
        final price = (data['totalPrice'] as num?)?.toDouble() ?? 0.0;

        switch (status) {
          case 'pending':
            pendingOrders++;
            break;
          case 'accepted':
            acceptedOrders++;
            break;
          case 'inProgress':
            inProgressOrders++;
            break;
          case 'completed':
            completedOrders++;
            totalSpent += price;
            break;
          case 'rejected':
            rejectedOrders++;
            break;
          case 'cancelled':
            cancelledOrders++;
            break;
        }
      }

      return {
        'totalOrders': totalOrders,
        'pendingOrders': pendingOrders,
        'acceptedOrders': acceptedOrders,
        'inProgressOrders': inProgressOrders,
        'completedOrders': completedOrders,
        'rejectedOrders': rejectedOrders,
        'cancelledOrders': cancelledOrders,
        'totalSpent': totalSpent,
      };
    } catch (e) {
      print('❌ خطأ في جلب إحصائيات الطلبات: $e');
      return {
        'error': e.toString(),
      };
    }
  }

  /// البحث في الطلبات
  static Stream<List<OrderModel>> searchOrders(String query) {
    return FirebaseService.firestore
        .collection(_ordersCollection)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromFirestore(doc))
            .where((order) =>
                order.customerName
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                order.tailorName.toLowerCase().contains(query.toLowerCase()) ||
                order.fabricName.toLowerCase().contains(query.toLowerCase()) ||
                order.id.toLowerCase().contains(query.toLowerCase()))
            .toList());
  }

  /// جلب الطلبات الجديدة (في آخر 24 ساعة)
  static Stream<List<OrderModel>> getRecentOrders(String tailorId) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));

    return FirebaseService.firestore
        .collection(_ordersCollection)
        .where('tailorId', isEqualTo: tailorId)
        .where('createdAt', isGreaterThan: Timestamp.fromDate(yesterday))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList());
  }

  /// حذف الطلب (للمدير فقط)
  static Future<bool> deleteOrder(String orderId) async {
    try {
      await FirebaseService.firestore
          .collection(_ordersCollection)
          .doc(orderId)
          .delete();

      print('✅ تم حذف الطلب: $orderId');
      return true;
    } catch (e) {
      print('❌ خطأ في حذف الطلب: $e');
      return false;
    }
  }

  /// إرسال طلب عباية من متجر
  static Future<String?> submitAbayaOrder({
    required String customerId,
    required String customerName,
    required String customerPhone,
    required String traderId,
    required String traderName,
    required String productId,
    required String productName,
    required String productImageUrl,
    required double productPrice,
    required Map<String, double> measurements, // {length, sleeve, width}
    String notes = '',
    String? selectedColor,
  }) async {
    try {
      final orderData = {
        // نوع الطلب
        'orderType': 'abaya',
        
        // معلومات العميل
        'customerId': customerId,
        'customerName': customerName,
        'customerPhone': customerPhone,

        // معلومات المتجر/التاجر
        'traderId': traderId,
        'traderName': traderName,

        // معلومات المنتج
        'productId': productId,
        'productName': productName,
        'productImageUrl': productImageUrl,
        'productPrice': productPrice,
        'selectedColor': selectedColor,

        // المقاسات
        'measurements': measurements,

        // ملاحظات
        'notes': notes,

        // السعر الإجمالي
        'totalPrice': productPrice,

        // حالة الطلب
        'status': 'pending',

        // التواريخ
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      print('📦 إرسال طلب عباية:');
      print('   👤 العميل: $customerName ($customerPhone)');
      print('   🏪 المتجر: $traderName');
      print('   👗 المنتج: $productName');
      print('   📏 المقاسات: $measurements');
      print('   💰 السعر: $productPrice ر.ع');

      final docRef = await FirebaseService.firestore
          .collection(_ordersCollection)
          .add(orderData);

      print('✅ تم إرسال الطلب بنجاح: ${docRef.id}');

      // إرسال إشعار للمتجر (اختياري - يمكن إضافته لاحقاً)
      try {
        await FirebaseService.firestore
            .collection('abaya_traders')
            .doc(traderId)
            .collection('orders')
            .doc(docRef.id)
            .set({
          'orderId': docRef.id,
          'customerName': customerName,
          'productName': productName,
          'totalPrice': productPrice,
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        print('⚠️ لم يتم إرسال إشعار للمتجر: $e');
      }

      return docRef.id;
    } catch (e, stackTrace) {
      print('❌ خطأ في إرسال طلب العباية: $e');
      print('📍 Stack trace: $stackTrace');
      return null;
    }
  }
}
