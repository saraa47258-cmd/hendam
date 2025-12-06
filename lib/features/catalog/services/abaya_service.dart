// lib/features/catalog/services/abaya_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hindam/core/services/firebase_service.dart';
import '../models/abaya_item.dart';

/// خدمة جلب منتجات العبايات من Firestore
class AbayaService {
  final FirebaseFirestore _firestore = FirebaseService.firestore;

  /// Stream لجلب جميع منتجات العبايات
  /// يبحث في collection منتجات تحت abaya_traders أو في collection عام
  Stream<List<AbayaItem>> getAbayaProducts({String? traderId}) {
    try {
      // إذا كان هناك traderId محدد، نجلب من subcollection الخاص به
      if (traderId != null && traderId.isNotEmpty) {
        return _firestore
            .collection('abaya_traders')
            .doc(traderId)
            .collection('products')
            .where('isAvailable', isEqualTo: true)
            .snapshots()
            .map((snapshot) {
          return snapshot.docs.map((doc) {
            try {
              return AbayaItem.fromMap(doc.data(), doc.id);
            } catch (e) {
              print('خطأ في تحويل منتج: ${doc.id} - $e');
              return null;
            }
          }).whereType<AbayaItem>().toList();
        });
      }

      // جلب من collection عام للمنتجات (إذا كان موجوداً)
      // أو جمع المنتجات من جميع التجار
      return _firestore
          .collectionGroup('products')
          .where('type', isEqualTo: 'abaya')
          .where('isActive', isEqualTo: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          try {
            return AbayaItem.fromMap(doc.data(), doc.id);
          } catch (e) {
            print('خطأ في تحويل منتج: ${doc.id} - $e');
            return null;
          }
        }).whereType<AbayaItem>().toList();
      });
    } catch (e) {
      print('خطأ في جلب منتجات العبايات: $e');
      // إرجاع stream فارغ في حالة الخطأ
      return Stream.value([]);
    }
  }

  /// جلب منتجات العبايات من جميع التجار النشطين
  Stream<List<AbayaItem>> getAllAbayaProducts() {
    try {
      // جلب جميع التجار النشطين أولاً
      return _firestore
          .collection('abaya_traders')
          .where('isActive', isEqualTo: true)
          .snapshots()
          .asyncMap((tradersSnapshot) async {
        final allProducts = <AbayaItem>[];

        // جلب منتجات كل تاجر
        for (var traderDoc in tradersSnapshot.docs) {
          try {
            final productsSnapshot = await _firestore
                .collection('abaya_traders')
                .doc(traderDoc.id)
                .collection('products')
                .where('isAvailable', isEqualTo: true)
                .get();

            for (var productDoc in productsSnapshot.docs) {
              try {
                final product = AbayaItem.fromMap(
                  productDoc.data(),
                  productDoc.id,
                );
                allProducts.add(product);
              } catch (e) {
                print('خطأ في تحويل منتج: ${productDoc.id} - $e');
              }
            }
          } catch (e) {
            print('خطأ في جلب منتجات التاجر: ${traderDoc.id} - $e');
          }
        }

        return allProducts;
      });
    } catch (e) {
      print('خطأ في جلب جميع منتجات العبايات: $e');
      return Stream.value([]);
    }
  }

  /// جلب منتجات العبايات (طريقة مبسطة - تبحث في collection مباشر)
  Stream<List<AbayaItem>> getAbayaProductsSimple() {
    try {
      // محاولة جلب من collection مباشر أولاً (إذا كان موجوداً)
      return _firestore
          .collection('products')
          .where('type', isEqualTo: 'abaya')
          .where('isAvailable', isEqualTo: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          try {
            return AbayaItem.fromMap(doc.data(), doc.id);
          } catch (e) {
            print('خطأ في تحويل منتج: ${doc.id} - $e');
            return null;
          }
        }).whereType<AbayaItem>().toList();
      });
    } catch (e) {
      print('خطأ في جلب منتجات العبايات: $e');
      // محاولة الطريقة البديلة - من subcollections
      return getAllAbayaProducts();
    }
  }

  /// جلب منتج واحد من Firestore
  /// يبحث في collection المنتجات العامة وفي subcollections التجار
  Future<AbayaItem?> getProductById(String productId) async {
    try {
      // محاولة 1: البحث في collection المنتجات العام
      try {
        final doc = await _firestore.collection('products').doc(productId).get();
        if (doc.exists) {
          final data = doc.data();
          if (data != null && data['type'] == 'abaya') {
            return AbayaItem.fromMap(data, doc.id);
          }
        }
      } catch (e) {
        print('خطأ في جلب المنتج من collection العام: $e');
      }

      // محاولة 2: البحث في subcollections التجار
      try {
        final tradersSnapshot = await _firestore
            .collection('abaya_traders')
            .where('isActive', isEqualTo: true)
            .get();

        for (var traderDoc in tradersSnapshot.docs) {
          try {
            final productDoc = await _firestore
                .collection('abaya_traders')
                .doc(traderDoc.id)
                .collection('products')
                .doc(productId)
                .get();

            if (productDoc.exists) {
              final data = productDoc.data();
              if (data != null) {
                return AbayaItem.fromMap(data, productDoc.id);
              }
            }
          } catch (e) {
            print('خطأ في جلب المنتج من تاجر ${traderDoc.id}: $e');
          }
        }
      } catch (e) {
        print('خطأ في البحث في subcollections: $e');
      }

      return null;
    } catch (e) {
      print('خطأ في جلب المنتج: $e');
      return null;
    }
  }

  /// Stream لجلب منتج واحد (للتحديثات المباشرة)
  Stream<AbayaItem?> getProductByIdStream(String productId) {
    try {
      // محاولة البحث في collection المنتجات العام
      return _firestore
          .collection('products')
          .doc(productId)
          .snapshots()
          .map((doc) {
        if (doc.exists) {
          final data = doc.data();
          if (data != null && data['type'] == 'abaya') {
            return AbayaItem.fromMap(data, doc.id);
          }
        }
        return null;
      });
    } catch (e) {
      print('خطأ في جلب stream المنتج: $e');
      return Stream.value(null);
    }
  }

  /// الحصول على معرف التاجر (traderId) من المنتج
  /// يُرجع null إذا كان المنتج في collection عام
  Future<String?> getTraderIdByProductId(String productId) async {
    try {
      // البحث في subcollections التجار
      final tradersSnapshot = await _firestore
          .collection('abaya_traders')
          .where('isActive', isEqualTo: true)
          .get();

      for (var traderDoc in tradersSnapshot.docs) {
        try {
          final productDoc = await _firestore
              .collection('abaya_traders')
              .doc(traderDoc.id)
              .collection('products')
              .doc(productId)
              .get();

          if (productDoc.exists) {
            return traderDoc.id;
          }
        } catch (e) {
          print('خطأ في البحث عن المنتج في تاجر ${traderDoc.id}: $e');
        }
      }

      // إذا لم يُعثر على المنتج في subcollections، قد يكون في collection عام
      return null;
    } catch (e) {
      print('خطأ في جلب traderId: $e');
      return null;
    }
  }

  /// الحصول على اسم التاجر من معرفه
  Future<String?> getTraderName(String traderId) async {
    try {
      final doc = await _firestore
          .collection('abaya_traders')
          .doc(traderId)
          .get();

      if (doc.exists) {
        final data = doc.data();
        return data?['name'] as String?;
      }
      return null;
    } catch (e) {
      print('خطأ في جلب اسم التاجر: $e');
      return null;
    }
  }
}

