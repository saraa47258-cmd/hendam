// lib/features/tailors/services/fabric_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hindam/core/services/firebase_service.dart';

/// خدمة جلب الأقمشة من مجموعة fabrics الموجودة في Firebase
class FabricService {
  static const String _fabricsCollection = 'fabrics';

  /// جلب جميع الأقمشة المتاحة
  static Stream<List<Map<String, dynamic>>> getAllFabrics() {
    return FirebaseService.firestore
        .collection(_fabricsCollection)
        .where('isAvailable', isEqualTo: true)
        .orderBy('lastUpdated', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data(),
                })
            .toList());
  }

  /// جلب الأقمشة الخاصة بخياط محدد
  /// يعرض فقط الأقمشة التي تحتوي على tailorId مطابق للخياط المحدد
  static Stream<List<Map<String, dynamic>>> getTailorFabrics(String tailorId) {
    try {
      // استخدام where query مباشرة في Firestore لفلترة حسب tailorId
      return FirebaseService.firestore
          .collection(_fabricsCollection)
          .where('tailorId', isEqualTo: tailorId)
          .where('isAvailable', isEqualTo: true)
          .orderBy('lastUpdated', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data(),
                })
            .toList();
      });
    } catch (e) {
      // في حالة عدم وجود index في Firestore، نستخدم فلترة يدوية
      print('⚠️ تحذير: استخدام فلترة يدوية لـ getTailorFabrics: $e');
      return FirebaseService.firestore
          .collection(_fabricsCollection)
          .where('isAvailable', isEqualTo: true)
          .orderBy('lastUpdated', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data(),
                })
            .where((fabric) {
          // عرض فقط الأقمشة التي تحتوي على tailorId مطابق
          // لا نعرض الأقمشة بدون tailorId
          return fabric['tailorId'] != null && 
                 fabric['tailorId'] == tailorId;
        }).toList();
      });
    }
  }

  /// جلب قماش واحد بالتفصيل
  static Future<Map<String, dynamic>?> getFabricById(String fabricId) async {
    try {
      final doc = await FirebaseService.firestore
          .collection(_fabricsCollection)
          .doc(fabricId)
          .get();

      if (doc.exists) {
        return {
          'id': doc.id,
          ...doc.data()!,
        };
      }
      return null;
    } catch (e) {
      print('خطأ في جلب القماش: $e');
      return null;
    }
  }

  /// البحث في الأقمشة
  static Stream<List<Map<String, dynamic>>> searchFabrics(String searchQuery) {
    return FirebaseService.firestore
        .collection(_fabricsCollection)
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data(),
                })
            .where((fabric) =>
                (fabric['name'] ?? '')
                    .toString()
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase()) ||
                (fabric['description'] ?? '')
                    .toString()
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase()) ||
                (fabric['type'] ?? '')
                    .toString()
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase()))
            .toList());
  }

  /// البحث في أقمشة خياط محدد
  static Stream<List<Map<String, dynamic>>> searchTailorFabrics(
      String tailorId, String searchQuery) {
    return FirebaseService.firestore
        .collection(_fabricsCollection)
        .where('tailorId', isEqualTo: tailorId)
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data(),
                })
            .where((fabric) =>
                (fabric['name'] ?? '')
                    .toString()
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase()) ||
                (fabric['description'] ?? '')
                    .toString()
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase()) ||
                (fabric['type'] ?? '')
                    .toString()
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase()))
            .toList());
  }

  /// جلب الأقمشة حسب النوع لخياط محدد
  static Stream<List<Map<String, dynamic>>> getTailorFabricsByType(
      String tailorId, String fabricType) {
    return FirebaseService.firestore
        .collection(_fabricsCollection)
        .where('tailorId', isEqualTo: tailorId)
        .where('type', isEqualTo: fabricType)
        .where('isAvailable', isEqualTo: true)
        .orderBy('lastUpdated', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data(),
                })
            .toList());
  }

  /// جلب الأقمشة حسب الموسم لخياط محدد
  static Stream<List<Map<String, dynamic>>> getTailorFabricsBySeason(
      String tailorId, String season) {
    return FirebaseService.firestore
        .collection(_fabricsCollection)
        .where('tailorId', isEqualTo: tailorId)
        .where('season', isEqualTo: season)
        .where('isAvailable', isEqualTo: true)
        .orderBy('lastUpdated', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data(),
                })
            .toList());
  }

  /// جلب الأقمشة حسب الجودة لخياط محدد
  static Stream<List<Map<String, dynamic>>> getTailorFabricsByQuality(
      String tailorId, String quality) {
    return FirebaseService.firestore
        .collection(_fabricsCollection)
        .where('tailorId', isEqualTo: tailorId)
        .where('quality', isEqualTo: quality)
        .where('isAvailable', isEqualTo: true)
        .orderBy('lastUpdated', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data(),
                })
            .toList());
  }

  /// جلب الأقمشة حسب الموسم
  static Stream<List<Map<String, dynamic>>> getFabricsBySeason(String season) {
    return FirebaseService.firestore
        .collection(_fabricsCollection)
        .where('season', isEqualTo: season)
        .where('isAvailable', isEqualTo: true)
        .orderBy('lastUpdated', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data(),
                })
            .toList());
  }

  /// جلب الأقمشة حسب الجودة
  static Stream<List<Map<String, dynamic>>> getFabricsByQuality(
      String quality) {
    return FirebaseService.firestore
        .collection(_fabricsCollection)
        .where('quality', isEqualTo: quality)
        .where('isAvailable', isEqualTo: true)
        .orderBy('lastUpdated', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data(),
                })
            .toList());
  }

  /// تحديث كمية القماش
  static Future<bool> updateFabricQuantity(
      String fabricId, int newQuantity) async {
    try {
      await FirebaseService.firestore
          .collection(_fabricsCollection)
          .doc(fabricId)
          .update({
        'quantity': newQuantity,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('خطأ في تحديث كمية القماش: $e');
      return false;
    }
  }

  /// تحديث حالة توفر القماش
  static Future<bool> updateFabricAvailability(
      String fabricId, bool isAvailable) async {
    try {
      await FirebaseService.firestore
          .collection(_fabricsCollection)
          .doc(fabricId)
          .update({
        'isAvailable': isAvailable,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('خطأ في تحديث حالة القماش: $e');
      return false;
    }
  }

  /// إضافة قماش جديد
  static Future<String?> addFabric(Map<String, dynamic> fabricData) async {
    try {
      final docRef =
          await FirebaseService.firestore.collection(_fabricsCollection).add({
        ...fabricData,
        'isAvailable': true,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      print('خطأ في إضافة القماش: $e');
      return null;
    }
  }

  /// إضافة قماش جديد لخياط محدد
  static Future<String?> addTailorFabric(
      String tailorId, Map<String, dynamic> fabricData) async {
    try {
      final docRef =
          await FirebaseService.firestore.collection(_fabricsCollection).add({
        ...fabricData,
        'tailorId': tailorId,
        'isAvailable': true,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      print('خطأ في إضافة قماش الخياط: $e');
      return null;
    }
  }

  /// إضافة قماش جديد (مع tailorId تلقائياً إذا لم يكن موجوداً)
  static Future<String?> addFabricWithTailorId(
      String tailorId, Map<String, dynamic> fabricData) async {
    try {
      final docRef =
          await FirebaseService.firestore.collection(_fabricsCollection).add({
        ...fabricData,
        'tailorId': tailorId, // إضافة tailorId تلقائياً
        'isAvailable': true,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      print('تم إضافة قماش جديد مع tailorId: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('خطأ في إضافة القماش مع tailorId: $e');
      return null;
    }
  }

  /// تحديث قماش خياط محدد
  static Future<bool> updateTailorFabric(
      String tailorId, String fabricId, Map<String, dynamic> fabricData) async {
    try {
      await FirebaseService.firestore
          .collection(_fabricsCollection)
          .doc(fabricId)
          .update({
        ...fabricData,
        'tailorId': tailorId,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('خطأ في تحديث قماش الخياط: $e');
      return false;
    }
  }

  /// إضافة حقل tailorId للأقمشة الموجودة (للمرحلة الانتقالية)
  static Future<bool> addTailorIdToExistingFabrics(
      String fabricId, String tailorId) async {
    try {
      await FirebaseService.firestore
          .collection(_fabricsCollection)
          .doc(fabricId)
          .update({
        'tailorId': tailorId,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('خطأ في إضافة tailorId للقماش: $e');
      return false;
    }
  }

  /// تحديث قماش موجود
  static Future<bool> updateFabric(
      String fabricId, Map<String, dynamic> fabricData) async {
    try {
      await FirebaseService.firestore
          .collection(_fabricsCollection)
          .doc(fabricId)
          .update({
        ...fabricData,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('خطأ في تحديث القماش: $e');
      return false;
    }
  }

  /// حذف قماش (تعطيله)
  static Future<bool> deleteFabric(String fabricId) async {
    try {
      await FirebaseService.firestore
          .collection(_fabricsCollection)
          .doc(fabricId)
          .update({
        'isAvailable': false,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('خطأ في حذف القماش: $e');
      return false;
    }
  }

  /// جلب أنواع الأقمشة المتاحة
  static Future<List<String>> getAvailableFabricTypes() async {
    try {
      final snapshot = await FirebaseService.firestore
          .collection(_fabricsCollection)
          .where('isAvailable', isEqualTo: true)
          .get();

      final types = <String>{};
      for (final doc in snapshot.docs) {
        final type = doc.data()['type']?.toString();
        if (type != null && type.isNotEmpty) {
          types.add(type);
        }
      }

      return types.toList()..sort();
    } catch (e) {
      print('خطأ في جلب أنواع الأقمشة: $e');
      return [];
    }
  }

  /// جلب مواسم الأقمشة المتاحة
  static Future<List<String>> getAvailableSeasons() async {
    try {
      final snapshot = await FirebaseService.firestore
          .collection(_fabricsCollection)
          .where('isAvailable', isEqualTo: true)
          .get();

      final seasons = <String>{};
      for (final doc in snapshot.docs) {
        final season = doc.data()['season']?.toString();
        if (season != null && season.isNotEmpty) {
          seasons.add(season);
        }
      }

      return seasons.toList()..sort();
    } catch (e) {
      print('خطأ في جلب مواسم الأقمشة: $e');
      return [];
    }
  }

  /// جلب جودات الأقمشة المتاحة
  static Future<List<String>> getAvailableQualities() async {
    try {
      final snapshot = await FirebaseService.firestore
          .collection(_fabricsCollection)
          .where('isAvailable', isEqualTo: true)
          .get();

      final qualities = <String>{};
      for (final doc in snapshot.docs) {
        final quality = doc.data()['quality']?.toString();
        if (quality != null && quality.isNotEmpty) {
          qualities.add(quality);
        }
      }

      return qualities.toList()..sort();
    } catch (e) {
      print('خطأ في جلب جودات الأقمشة: $e');
      return [];
    }
  }
}
