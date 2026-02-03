// lib/features/stores/services/stores_service.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hindam/core/services/firebase_service.dart';
import '../models/store.dart';
import '../models/category.dart';
import '../../catalog/models/abaya_item.dart';

/// خدمة المتاجر - جلب البيانات من Firebase collection: traders
class StoresService {
  final FirebaseFirestore _firestore = FirebaseService.firestore;

  /// جلب جميع المتاجر كـ Stream مع عدد المنتجات
  Stream<List<Store>> getStores() {
    return _firestore
        .collection('traders')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final stores = <Store>[];
      
      for (final doc in snapshot.docs) {
        try {
          // جلب عدد المنتجات من subcollection
          int productsCount = 0;
          try {
            final productsSnapshot = await _firestore
                .collection('traders')
                .doc(doc.id)
                .collection('products')
                .get();
            productsCount = productsSnapshot.docs.length;
          } catch (e) {
            // تجاهل الخطأ إذا لم يكن هناك products collection
            print('خطأ في جلب عدد المنتجات للتاجر ${doc.id}: $e');
          }
          
          // إنشاء Store مع عدد المنتجات
          final store = Store.fromMap(doc.data(), doc.id, productsCount: productsCount);
          stores.add(store);
        } catch (e) {
          print('خطأ في تحويل بيانات المتجر ${doc.id}: $e');
        }
      }
      
      return stores;
    });
  }

  /// جلب متجر محدد بواسطة ID
  Future<Store?> getStoreById(String id) async {
    final doc = await _firestore.collection('traders').doc(id).get();
    if (doc.exists) {
      // جلب عدد المنتجات
      int productsCount = 0;
      try {
        final productsSnapshot = await _firestore
            .collection('traders')
            .doc(id)
            .collection('products')
            .get();
        productsCount = productsSnapshot.docs.length;
      } catch (e) {
        print('خطأ في جلب عدد المنتجات: $e');
      }
      return Store.fromMap(doc.data()!, doc.id, productsCount: productsCount);
    }
    return null;
  }

  /// جلب المتاجر حسب الفئة
  Stream<List<Store>> getStoresByCategory(String category) {
    return _firestore
        .collection('traders')
        .where('category', isEqualTo: category)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final stores = <Store>[];
      
      for (final doc in snapshot.docs) {
        try {
          // جلب عدد المنتجات
          int productsCount = 0;
          try {
            final productsSnapshot = await _firestore
                .collection('traders')
                .doc(doc.id)
                .collection('products')
                .get();
            productsCount = productsSnapshot.docs.length;
          } catch (e) {
            print('خطأ في جلب عدد المنتجات: $e');
          }
          
          stores.add(Store.fromMap(doc.data(), doc.id, productsCount: productsCount));
        } catch (e) {
          print('خطأ في تحويل بيانات المتجر: $e');
        }
      }
      
      return stores;
    });
  }

  /// البحث في المتاجر
  Future<List<Store>> searchStores(String query) async {
    final snapshot = await _firestore
        .collection('traders')
        .where('isActive', isEqualTo: true)
        .get();
    
    final stores = <Store>[];
    
    for (final doc in snapshot.docs) {
      try {
        final storeData = doc.data();
        final storeName = (storeData['name'] ?? '').toString().toLowerCase();
        final storeCategory = (storeData['category'] ?? '').toString().toLowerCase();
        final storeLocation = (storeData['location'] ?? '').toString().toLowerCase();
        
        if (storeName.contains(query.toLowerCase()) ||
            storeCategory.contains(query.toLowerCase()) ||
            storeLocation.contains(query.toLowerCase())) {
          // جلب عدد المنتجات
          int productsCount = 0;
          try {
            final productsSnapshot = await _firestore
                .collection('traders')
                .doc(doc.id)
                .collection('products')
                .get();
            productsCount = productsSnapshot.docs.length;
          } catch (e) {
            print('خطأ في جلب عدد المنتجات: $e');
          }
          
          stores.add(Store.fromMap(storeData, doc.id, productsCount: productsCount));
        }
      } catch (e) {
        print('خطأ في تحويل بيانات المتجر: $e');
      }
    }
    
    return stores;
  }

  /// جلب الأقسام من traders/{traderId}/categories
  Stream<List<TraderCategory>> getTraderCategories(String traderId) {
    try {
      return _firestore
          .collection('traders')
          .doc(traderId)
          .collection('categories')
          .snapshots()
          .map((snapshot) {
        final categories = <TraderCategory>[];
        
        for (final doc in snapshot.docs) {
          try {
            final data = doc.data();
            final isActive = data['isActive'] ?? true;
            if (isActive == false) continue;
            
            final category = TraderCategory.fromMap(data, doc.id);
            categories.add(category);
          } catch (e) {
            print('خطأ في تحويل القسم: ${doc.id} - $e');
          }
        }
        
        // ترتيب حسب sortOrder إذا كان موجوداً
        categories.sort((a, b) {
          final aOrder = a.sortOrder ?? 999;
          final bOrder = b.sortOrder ?? 999;
          return aOrder.compareTo(bOrder);
        });
        
        return categories;
      });
    } catch (e) {
      print('خطأ في جلب أقسام التاجر: $e');
      return Stream.value([]);
    }
  }

  /// جلب المنتجات حسب القسم من traders/{traderId}/products
  /// المنتجات لها categoryId يربطها بالقسم
  Stream<List<AbayaItem>> getTraderProductsByCategory({
    required String traderId,
    required String categoryId,
  }) {
    try {
      print('🔍 جلب منتجات القسم: $categoryId للتاجر: $traderId');
      
      final controller = StreamController<List<AbayaItem>>();
      bool isInitialLoad = true;
      
      // جلب البيانات الأولية مباشرة من traders/{traderId}/products
      _firestore
          .collection('traders')
          .doc(traderId)
          .collection('products')
          .where('categoryId', isEqualTo: categoryId)
          .where('isActive', isEqualTo: true)
          .get()
          .then((snapshot) {
        print('✅ تم جلب ${snapshot.docs.length} منتج من القسم $categoryId (جلب مباشر)');
        
        final products = snapshot.docs.map((doc) {
          try {
            final data = doc.data();
            final isActive = data['isActive'] ?? true;
            if (isActive == false) {
              print('⏭️ تخطي منتج غير نشط: ${doc.id}');
              return null;
            }
            final product = AbayaItem.fromMap(data, doc.id);
            print('✅ منتج: ${product.title} (${product.id}), categoryId: ${product.categoryId}, الصورة: ${product.imageUrl}');
            return product;
          } catch (e) {
            print('❌ خطأ في تحويل منتج من القسم: ${doc.id} - $e');
            return null;
          }
        }).whereType<AbayaItem>().toList();
        
        print('📊 عدد المنتجات بعد الفلترة: ${products.length}');
        controller.add(products);
        isInitialLoad = false;
      }).catchError((e) {
        print('❌ خطأ في جلب منتجات القسم: $e');
        controller.add([]);
      });
      
      // الاستماع للتحديثات
      final subscription = _firestore
          .collection('traders')
          .doc(traderId)
          .collection('products')
          .where('categoryId', isEqualTo: categoryId)
          .where('isActive', isEqualTo: true)
          .snapshots()
          .listen(
        (snapshot) {
          if (isInitialLoad) {
            isInitialLoad = false;
            return; // نتخطى التحديث الأول لأننا جلبنا البيانات مباشرة
          }
          
          print('🔄 تحديث منتجات القسم $categoryId: ${snapshot.docs.length} منتج');
          
          final products = snapshot.docs.map((doc) {
            try {
              final data = doc.data();
              final isActive = data['isActive'] ?? true;
              if (isActive == false) return null;
              return AbayaItem.fromMap(data, doc.id);
            } catch (e) {
              print('❌ خطأ في تحويل منتج: ${doc.id} - $e');
              return null;
            }
          }).whereType<AbayaItem>().toList();
          
          controller.add(products);
        },
        onError: (e) {
          print('❌ خطأ في stream منتجات القسم: $e');
          controller.add([]);
        },
      );
      
      controller.onCancel = () {
        subscription.cancel();
      };
      
      return controller.stream;
    } catch (e) {
      print('❌ خطأ في جلب منتجات القسم: $e');
      return Stream.value([]);
    }
  }

  /// جلب جميع منتجات التاجر من traders/{traderId}/products
  /// المنتجات لها categoryId يربطها بالأقسام
  Stream<List<AbayaItem>> getTraderProductsFromCategories(String traderId) {
    try {
      print('🔍 بدء جلب جميع المنتجات للتاجر: $traderId');
      
      final controller = StreamController<List<AbayaItem>>();
      bool isInitialLoad = true;
      
      // جلب البيانات الأولية مباشرة من traders/{traderId}/products
      _firestore
          .collection('traders')
          .doc(traderId)
          .collection('products')
          .where('isActive', isEqualTo: true)
          .get()
          .then((snapshot) {
        print('✅ تم جلب ${snapshot.docs.length} منتج من traders/$traderId/products (جلب مباشر)');
        
        final products = snapshot.docs.map((doc) {
          try {
            final data = doc.data();
            final isActive = data['isActive'] ?? true;
            if (isActive == false) {
              print('⏭️ تخطي منتج غير نشط: ${doc.id}');
              return null;
            }
            final product = AbayaItem.fromMap(data, doc.id);
            print('✅ منتج: ${product.title} (${product.id}), categoryId: ${product.categoryId}, الصورة: ${product.imageUrl}');
            return product;
          } catch (e) {
            print('❌ خطأ في تحويل منتج: ${doc.id} - $e');
            return null;
          }
        }).whereType<AbayaItem>().toList();
        
        print('📊 عدد المنتجات بعد الفلترة: ${products.length}');
        if (products.isNotEmpty) {
          print('📦 أول منتج: ${products.first.title}, categoryId: ${products.first.categoryId}');
        }
        controller.add(products);
        isInitialLoad = false;
      }).catchError((e) {
        print('❌ خطأ في جلب المنتجات: $e');
        controller.add([]);
      });
      
      // الاستماع للتحديثات
      final subscription = _firestore
          .collection('traders')
          .doc(traderId)
          .collection('products')
          .where('isActive', isEqualTo: true)
          .snapshots()
          .listen(
        (snapshot) {
          if (isInitialLoad) {
            isInitialLoad = false;
            return; // نتخطى التحديث الأول لأننا جلبنا البيانات مباشرة
          }
          
          print('🔄 تحديث المنتجات: ${snapshot.docs.length} منتج');
          
          final products = snapshot.docs.map((doc) {
            try {
              final data = doc.data();
              final isActive = data['isActive'] ?? true;
              if (isActive == false) return null;
              return AbayaItem.fromMap(data, doc.id);
            } catch (e) {
              print('❌ خطأ في تحويل منتج: ${doc.id} - $e');
              return null;
            }
          }).whereType<AbayaItem>().toList();
          
          controller.add(products);
        },
        onError: (e) {
          print('❌ خطأ في stream المنتجات: $e');
          controller.add([]);
        },
      );
      
      controller.onCancel = () {
        subscription.cancel();
      };
      
      return controller.stream;
    } catch (e) {
      print('❌ خطأ في جلب منتجات التاجر: $e');
      return Stream.value([]);
    }
  }

  /// جلب عدد المنتجات في قسم محدد
  /// يبحث في traders/{traderId}/products حيث categoryId == categoryId
  Future<int> getCategoryProductsCount({
    required String traderId,
    required String categoryId,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('traders')
          .doc(traderId)
          .collection('products')
          .where('categoryId', isEqualTo: categoryId)
          .where('isActive', isEqualTo: true)
          .get();
      print('📊 عدد المنتجات في القسم $categoryId: ${snapshot.docs.length}');
      return snapshot.docs.length;
    } catch (e) {
      print('❌ خطأ في جلب عدد منتجات القسم: $e');
      return 0;
    }
  }

  /// جلب منتجات التاجر من traders/{traderId}/products (fallback)
  Stream<List<AbayaItem>> getTraderProducts(String traderId) {
    try {
      print('🔍 جلب منتجات التاجر (fallback): $traderId');
      final controller = StreamController<List<AbayaItem>>();
      bool isInitialLoad = true;
      
      // جلب البيانات الأولية مباشرة
      _firestore
          .collection('traders')
          .doc(traderId)
          .collection('products')
          .where('isActive', isEqualTo: true)
          .get()
          .then((snapshot) {
        print('✅ تم جلب ${snapshot.docs.length} منتج من traders/$traderId/products (جلب مباشر)');
        
        final products = snapshot.docs.map((doc) {
          try {
            final data = doc.data();
            final isActive = data['isActive'] ?? true;
            if (isActive == false) {
              print('⏭️ تخطي منتج غير نشط: ${doc.id}');
              return null;
            }
            final product = AbayaItem.fromMap(data, doc.id);
            print('✅ منتج: ${product.title} (${product.id}), categoryId: ${product.categoryId}');
            return product;
          } catch (e) {
            print('❌ خطأ في تحويل منتج: ${doc.id} - $e');
            return null;
          }
        }).whereType<AbayaItem>().toList();
        
        print('📊 عدد المنتجات بعد الفلترة: ${products.length}');
        controller.add(products);
        isInitialLoad = false;
      }).catchError((e) {
        print('❌ خطأ في جلب المنتجات: $e');
        controller.add([]);
      });

      // الاشتراك في stream traders للتحديثات
      final tradersSubscription = _firestore
          .collection('traders')
          .doc(traderId)
          .collection('products')
          .where('isActive', isEqualTo: true)
          .snapshots()
          .listen(
        (snapshot) {
          if (isInitialLoad) {
            isInitialLoad = false;
            return; // نتخطى التحديث الأول لأننا جلبنا البيانات مباشرة
          }
          
          print('🔄 تحديث المنتجات: ${snapshot.docs.length} منتج');
          
          final products = snapshot.docs.map((doc) {
            try {
              final data = doc.data();
              final isActive = data['isActive'] ?? true;
              if (isActive == false) return null;
              return AbayaItem.fromMap(data, doc.id);
            } catch (e) {
              print('❌ خطأ في تحويل منتج: ${doc.id} - $e');
              return null;
            }
          }).whereType<AbayaItem>().toList();
          
          controller.add(products);
        },
        onError: (e) {
          print('❌ خطأ في stream traders: $e');
          controller.add([]);
        },
      );

      controller.onCancel = () {
        tradersSubscription.cancel();
      };

      return controller.stream;
    } catch (e) {
      print('خطأ في جلب منتجات التاجر: $e');
      return Stream.value([]);
    }
  }

  /// جلب منتج واحد من traders/{traderId}/categories/{categoryId}/products
  /// يبحث في جميع الأقسام للمتاجر
  Future<AbayaItem?> getProductById(String productId) async {
    try {
      // محاولة 1: البحث في traders/{traderId}/categories/{categoryId}/products
      try {
        final tradersSnapshot = await _firestore
            .collection('traders')
            .where('isActive', isEqualTo: true)
            .get();

        for (var traderDoc in tradersSnapshot.docs) {
          try {
            // البحث في جميع أقسام التاجر
            final categoriesSnapshot = await _firestore
                .collection('traders')
                .doc(traderDoc.id)
                .collection('categories')
                .get();

            for (var categoryDoc in categoriesSnapshot.docs) {
              try {
                final productDoc = await _firestore
                    .collection('traders')
                    .doc(traderDoc.id)
                    .collection('categories')
                    .doc(categoryDoc.id)
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
                print('خطأ في جلب المنتج من القسم ${categoryDoc.id}: $e');
              }
            }

            // البحث في traders/{traderId}/products (fallback)
            try {
              final productDoc = await _firestore
                  .collection('traders')
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
              print('خطأ في جلب المنتج من traders/${traderDoc.id}/products: $e');
            }
          } catch (e) {
            print('خطأ في البحث في تاجر ${traderDoc.id}: $e');
          }
        }
      } catch (e) {
        print('خطأ في البحث في traders: $e');
      }

      // محاولة 2: البحث في collection المنتجات العام
      try {
        final doc = await _firestore.collection('products').doc(productId).get();
        if (doc.exists) {
          final data = doc.data();
          if (data != null && (data['type'] == 'store_product' || data['type'] == 'abaya')) {
            return AbayaItem.fromMap(data, doc.id);
          }
        }
      } catch (e) {
        print('خطأ في جلب المنتج من collection العام: $e');
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
      // البحث في collection المنتجات العام فقط للتحديثات المباشرة
      return _firestore
          .collection('products')
          .doc(productId)
          .snapshots()
          .map((doc) {
        if (doc.exists) {
          final data = doc.data();
          if (data != null && (data['type'] == 'store_product' || data['type'] == 'abaya')) {
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
}
