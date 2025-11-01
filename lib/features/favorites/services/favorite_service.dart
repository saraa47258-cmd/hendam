// lib/features/favorites/services/favorite_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hindam/core/services/firebase_service.dart';
import 'package:hindam/features/auth/services/auth_service.dart';

/// خدمة إدارة المفضلة
class FavoriteService {
  final FirebaseFirestore _firestore = FirebaseService.firestore;
  final AuthService _authService = AuthService();

  static const String _favoritesCollection = 'favorites';

  /// إضافة منتج للمفضلة
  Future<bool> addToFavorites({
    required String productId,
    required String productType, // 'fabric', 'product', 'abaya', etc.
    Map<String, dynamic>? productData,
  }) async {
    try {
      if (_authService.currentUser == null) return false;

      final userId = _authService.currentUser!.uid;
      final favoriteId = '$userId-$productId-$productType';

      await _firestore.collection(_favoritesCollection).doc(favoriteId).set({
        'userId': userId,
        'productId': productId,
        'productType': productType,
        'productData': productData,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('خطأ في إضافة المفضلة: $e');
      return false;
    }
  }

  /// إزالة منتج من المفضلة
  Future<bool> removeFromFavorites({
    required String productId,
    required String productType,
  }) async {
    try {
      if (_authService.currentUser == null) return false;

      final userId = _authService.currentUser!.uid;
      final favoriteId = '$userId-$productId-$productType';

      await _firestore
          .collection(_favoritesCollection)
          .doc(favoriteId)
          .delete();

      return true;
    } catch (e) {
      print('خطأ في إزالة المفضلة: $e');
      return false;
    }
  }

  /// التحقق من حالة المفضلة
  Future<bool> isFavorite({
    required String productId,
    required String productType,
  }) async {
    try {
      if (_authService.currentUser == null) return false;

      final userId = _authService.currentUser!.uid;
      final favoriteId = '$userId-$productId-$productType';

      final doc = await _firestore
          .collection(_favoritesCollection)
          .doc(favoriteId)
          .get();

      return doc.exists;
    } catch (e) {
      print('خطأ في التحقق من المفضلة: $e');
      return false;
    }
  }

  /// جلب جميع المفضلات للمستخدم الحالي
  Stream<List<Map<String, dynamic>>> getUserFavorites() {
    if (_authService.currentUser == null) {
      return Stream.value([]);
    }

    final userId = _authService.currentUser!.uid;

    return _firestore
        .collection(_favoritesCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return {
                'id': doc.id,
                ...doc.data(),
              };
            }).toList());
  }

  /// جلب عدد المفضلات للمستخدم
  Future<int> getFavoritesCount() async {
    try {
      if (_authService.currentUser == null) return 0;

      final userId = _authService.currentUser!.uid;

      final snapshot = await _firestore
          .collection(_favoritesCollection)
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      print('خطأ في جلب عدد المفضلات: $e');
      return 0;
    }
  }

  /// تحديث بيانات المنتج في المفضلة
  Future<bool> updateFavoriteData({
    required String productId,
    required String productType,
    required Map<String, dynamic> productData,
  }) async {
    try {
      if (_authService.currentUser == null) return false;

      final userId = _authService.currentUser!.uid;
      final favoriteId = '$userId-$productId-$productType';

      await _firestore.collection(_favoritesCollection).doc(favoriteId).update({
        'productData': productData,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('خطأ في تحديث بيانات المفضلة: $e');
      return false;
    }
  }

  /// حذف جميع المفضلات للمستخدم
  Future<bool> clearAllFavorites() async {
    try {
      if (_authService.currentUser == null) return false;

      final userId = _authService.currentUser!.uid;

      final snapshot = await _firestore
          .collection(_favoritesCollection)
          .where('userId', isEqualTo: userId)
          .get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      return true;
    } catch (e) {
      print('خطأ في حذف المفضلات: $e');
      return false;
    }
  }
}
