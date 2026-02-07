// lib/features/shops/services/traders_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hindam/core/services/firebase_service.dart';
import '../models/shop.dart';

/// خدمة جلب التجار من Firestore (مجموعة traders)
class TradersService {
  final FirebaseFirestore _firestore = FirebaseService.firestore;

  /// Stream لجلب جميع التجار النشطين
  Stream<List<Shop>> getTraders() {
    try {
      return _firestore
          .collection('traders')
          .where('isActive', isEqualTo: true)
          .snapshots()
          .asyncMap((snapshot) async {
        final List<Shop> traders = [];

        for (var doc in snapshot.docs) {
          try {
            final data = doc.data();

            // جلب عدد المنتجات
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
              for (var productDoc in productsSnapshot.docs) {
                final productData = productDoc.data();
                final price = productData['price'];
                if (price != null) {
                  final productPrice = (price is int)
                      ? price.toDouble()
                      : (price is double ? price : 0.0);
                  if (minPrice == null || productPrice < minPrice) {
                    minPrice = productPrice;
                  }
                }
              }
            } catch (_) {}

            final shop = _mapToShop(data, doc.id, productsCount, minPrice);
            if (shop != null) {
              traders.add(shop);
            }
          } catch (e) {
            print('خطأ في تحويل تاجر: ${doc.id} - $e');
          }
        }

        return traders;
      });
    } catch (e) {
      print('خطأ في جلب التجار: $e');
      return Stream.value([]);
    }
  }

  /// جلب التجار مرة واحدة (Future)
  Future<List<Shop>> getTradersOnce() async {
    try {
      final snapshot = await _firestore
          .collection('traders')
          .where('isActive', isEqualTo: true)
          .get();

      final List<Shop> traders = [];

      for (var doc in snapshot.docs) {
        try {
          final data = doc.data();

          // جلب عدد المنتجات
          int productsCount = 0;
          double? minPrice;

          try {
            final productsSnapshot = await _firestore
                .collection('traders')
                .doc(doc.id)
                .collection('products')
                .get();

            productsCount = productsSnapshot.docs.length;

            for (var productDoc in productsSnapshot.docs) {
              final productData = productDoc.data();
              final price = productData['price'];
              if (price != null) {
                final productPrice = (price is int)
                    ? price.toDouble()
                    : (price is double ? price : 0.0);
                if (minPrice == null || productPrice < minPrice) {
                  minPrice = productPrice;
                }
              }
            }
          } catch (_) {}

          final shop = _mapToShop(data, doc.id, productsCount, minPrice);
          if (shop != null) {
            traders.add(shop);
          }
        } catch (e) {
          print('خطأ في تحويل تاجر: ${doc.id} - $e');
        }
      }

      return traders;
    } catch (e) {
      print('خطأ في جلب التجار: $e');
      return [];
    }
  }

  /// تحويل بيانات Firestore إلى Shop
  Shop? _mapToShop(Map<String, dynamic> data, String id, int productsCount,
      double? minPrice) {
    try {
      // الاسم
      final name = data['name'] as String? ?? '';
      if (name.isEmpty) return null;

      // الموقع
      final location = data['location'] as String? ?? 'مسقط';

      // الصورة - من profile.avatar أو صورة افتراضية
      String imageUrl = 'assets/shops/3.jpg';
      final profile = data['profile'] as Map<String, dynamic>?;
      if (profile != null) {
        final avatar = profile['avatar'] as String?;
        if (avatar != null && avatar.isNotEmpty) {
          imageUrl = avatar;
        } else {
          final gallery = profile['gallery'] as List<dynamic>?;
          if (gallery != null && gallery.isNotEmpty) {
            imageUrl = gallery.first.toString();
          }
        }
      }

      // التقييم
      final rating = (data['rating'] is num)
          ? (data['rating'] as num).toDouble()
          : 4.5; // تقييم افتراضي

      // عدد المراجعات
      final reviews =
          (data['reviews'] is num) ? (data['reviews'] as num).toInt() : 0;

      // حالة الفتح
      final isActive = data['isActive'] as bool? ?? true;

      // التوصيل - من business.deliveryOptions أو افتراضي
      bool hasDelivery = true;
      final business = data['business'] as Map<String, dynamic>?;
      if (business != null) {
        final deliveryOptions = business['deliveryOptions'] as List<dynamic>?;
        hasDelivery = deliveryOptions?.contains('delivery') ?? true;
      }

      // الفئة
      String category = 'مستلزمات رجالية';
      if (business != null) {
        final type = business['type'] as String?;
        if (type != null) {
          if (type.contains('fabric')) {
            category = 'أقمشة رجالية';
          } else if (type.contains('tailor')) {
            category = 'تفصيل دشداشة';
          }
        }
      }

      return Shop(
        id: id,
        name: name,
        city: location,
        imageUrl: imageUrl,
        category: category,
        rating: rating,
        reviews: reviews,
        servicesCount: productsCount > 0
            ? productsCount
            : 10, // افتراضي إذا لم يكن هناك منتجات
        minPrice: minPrice ?? 5.0,
        delivery: hasDelivery,
        isOpen: isActive,
        isFavorite: false,
      );
    } catch (e) {
      print('خطأ في تحويل البيانات: $e');
      return null;
    }
  }

  /// جلب تاجر واحد
  Future<Shop?> getTraderById(String traderId) async {
    try {
      final doc = await _firestore.collection('traders').doc(traderId).get();

      if (!doc.exists) return null;

      int productsCount = 0;
      double? minPrice;

      try {
        final productsSnapshot = await _firestore
            .collection('traders')
            .doc(traderId)
            .collection('products')
            .get();

        productsCount = productsSnapshot.docs.length;

        for (var productDoc in productsSnapshot.docs) {
          final productData = productDoc.data();
          final price = productData['price'];
          if (price != null) {
            final productPrice = (price is int)
                ? price.toDouble()
                : (price is double ? price : 0.0);
            if (minPrice == null || productPrice < minPrice) {
              minPrice = productPrice;
            }
          }
        }
      } catch (_) {}

      return _mapToShop(doc.data()!, doc.id, productsCount, minPrice);
    } catch (e) {
      print('خطأ في جلب التاجر: $traderId - $e');
      return null;
    }
  }
}
