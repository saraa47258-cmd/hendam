// lib/features/shops/services/trader_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/shop.dart';

class TraderService {
  final _firestore = FirebaseFirestore.instance;

  /// جلب جميع التجار من collection traders
  Stream<List<Shop>> getTradersStream() {
    return _firestore
        .collection('traders')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final shops = <Shop>[];
      
      for (final doc in snapshot.docs) {
        try {
          final data = doc.data();
          
          // جلب عدد المنتجات والسعر الأدنى من subcollection products
          int productsCount = 0;
          double? minPrice;
          
          try {
            final productsSnapshot = await _firestore
                .collection('traders')
                .doc(doc.id)
                .collection('products')
                .get();
            
            productsCount = productsSnapshot.docs.length;
            
            // حساب السعر الأدنى
            for (final productDoc in productsSnapshot.docs) {
              final productData = productDoc.data();
              final price = (productData['price'] is num) 
                  ? (productData['price'] as num).toDouble() 
                  : 0.0;
              if (minPrice == null || price < minPrice) {
                minPrice = price;
              }
            }
          } catch (e) {
            // تجاهل أخطاء جلب المنتجات
          }
          
          final shop = Shop.fromMap(
            data, 
            doc.id,
            productsCount: productsCount,
            minProductPrice: minPrice,
          );
          
          // تجاهل المحلات بدون اسم
          if (shop.name.isNotEmpty) {
            shops.add(shop);
          }
        } catch (e) {
          print('خطأ في تحويل بيانات التاجر ${doc.id}: $e');
        }
      }
      
      return shops;
    });
  }

  /// جلب التجار مرة واحدة (بدون stream)
  Future<List<Shop>> getTraders() async {
    try {
      final snapshot = await _firestore
          .collection('traders')
          .where('isActive', isEqualTo: true)
          .get();
      
      final shops = <Shop>[];
      
      for (final doc in snapshot.docs) {
        try {
          final data = doc.data();
          
          // جلب عدد المنتجات والسعر الأدنى
          int productsCount = 0;
          double? minPrice;
          
          try {
            final productsSnapshot = await _firestore
                .collection('traders')
                .doc(doc.id)
                .collection('products')
                .get();
            
            productsCount = productsSnapshot.docs.length;
            
            for (final productDoc in productsSnapshot.docs) {
              final productData = productDoc.data();
              final price = (productData['price'] is num) 
                  ? (productData['price'] as num).toDouble() 
                  : 0.0;
              if (minPrice == null || price < minPrice) {
                minPrice = price;
              }
            }
          } catch (e) {
            // تجاهل أخطاء جلب المنتجات
          }
          
          final shop = Shop.fromMap(
            data, 
            doc.id,
            productsCount: productsCount,
            minProductPrice: minPrice,
          );
          
          if (shop.name.isNotEmpty) {
            shops.add(shop);
          }
        } catch (e) {
          print('خطأ في تحويل بيانات التاجر ${doc.id}: $e');
        }
      }
      
      return shops;
    } catch (e) {
      print('خطأ في جلب التجار: $e');
      return [];
    }
  }
}

