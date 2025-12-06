// lib/features/shops/services/abaya_traders_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hindam/core/services/firebase_service.dart';
import '../models/shop.dart';

/// خدمة جلب تجار العبايات من Firestore
class AbayaTradersService {
  final FirebaseFirestore _firestore = FirebaseService.firestore;

  /// Stream لجلب جميع تجار العبايات النشطين
  Stream<List<Shop>> getAbayaTraders() {
    try {
      return _firestore
          .collection('abaya_traders')
          .where('isActive', isEqualTo: true)
          .snapshots()
          .asyncMap((snapshot) async {
        final List<Shop> traders = [];

        for (var doc in snapshot.docs) {
          try {
            final data = doc.data();
            
            // جلب عدد المنتجات والسعر الأدنى
            final productsSnapshot = await _firestore
                .collection('abaya_traders')
                .doc(doc.id)
                .collection('products')
                .where('isAvailable', isEqualTo: true)
                .get();

            int productsCount = productsSnapshot.docs.length;
            
            // حساب السعر الأدنى
            double? minPrice;
            for (var productDoc in productsSnapshot.docs) {
              final productData = productDoc.data();
              final price = productData['price'];
              if (price != null) {
                final productPrice = (price is int) ? price.toDouble() : (price is double ? price : 0.0);
                if (minPrice == null || productPrice < minPrice) {
                  minPrice = productPrice;
                }
              }
            }

            final shop = Shop.fromMap(
              data,
              doc.id,
              productsCount: productsCount,
              minProductPrice: minPrice,
            );
            
            traders.add(shop);
          } catch (e) {
            print('خطأ في تحويل تاجر: ${doc.id} - $e');
          }
        }

        return traders;
      });
    } catch (e) {
      print('خطأ في جلب تجار العبايات: $e');
      return Stream.value([]);
    }
  }

  /// جلب تاجر واحد فقط
  Future<Shop?> getTraderById(String traderId) async {
    try {
      final doc = await _firestore
          .collection('abaya_traders')
          .doc(traderId)
          .get();

      if (!doc.exists) return null;

      // جلب عدد المنتجات والسعر الأدنى
      final productsSnapshot = await _firestore
          .collection('abaya_traders')
          .doc(traderId)
          .collection('products')
          .where('isAvailable', isEqualTo: true)
          .get();

      int productsCount = productsSnapshot.docs.length;
      
      double? minPrice;
      for (var productDoc in productsSnapshot.docs) {
        final productData = productDoc.data();
        final price = productData['price'];
        if (price != null) {
          final productPrice = (price is int) ? price.toDouble() : (price is double ? price : 0.0);
          if (minPrice == null || productPrice < minPrice) {
            minPrice = productPrice;
          }
        }
      }

      return Shop.fromMap(
        doc.data()!,
        doc.id,
        productsCount: productsCount,
        minProductPrice: minPrice,
      );
    } catch (e) {
      print('خطأ في جلب التاجر: $traderId - $e');
      return null;
    }
  }
}


