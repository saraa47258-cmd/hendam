// lib/features/tailors/services/fabric_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hindam/core/services/firebase_service.dart';

/// خدمة جلب الأقمشة من Firestore.
/// الأقمشة مخزنة كمجموعة فرعية تحت كل تاجر: tailors/{tailorId}/fabrics
class FabricService {
  static const String _tailorsCollection = 'tailors';
  static const String _fabricsSubcollection = 'fabrics';
  static const String _fabricsCollection = 'fabrics';

  /// مرجع مجموعة الأقمشة لتاجر معين: tailors/{tailorId}/fabrics
  static CollectionReference<Map<String, dynamic>> _tailorFabricsRef(
      String tailorId) {
    return FirebaseService.firestore
        .collection(_tailorsCollection)
        .doc(tailorId)
        .collection(_fabricsSubcollection);
  }

  /// جلب جميع الأقمشة المتاحة (من مجموعة عامة إن وُجدت - للتوافق مع الشاشات الأخرى)
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

  /// جلب الأقمشة الخاصة بتاجر/خياط محدد من المجموعة الفرعية tailors/{tailorId}/fabrics
  static Stream<List<Map<String, dynamic>>> getTailorFabrics(String tailorId) {
    final ref = _tailorFabricsRef(tailorId);
    try {
      return ref
          .where('isAvailable', isEqualTo: true)
          .orderBy('lastUpdated', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => {
                    'id': doc.id,
                    ...doc.data(),
                  })
              .toList());
    } catch (e) {
      try {
        return ref
            .where('isAvailable', isEqualTo: true)
            .orderBy('updatedAt', descending: true)
            .snapshots()
            .map((snapshot) => snapshot.docs
                .map((doc) => {
                      'id': doc.id,
                      ...doc.data(),
                    })
                .toList());
      } catch (_) {
        return ref
            .where('isAvailable', isEqualTo: true)
            .snapshots()
            .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => {
                    'id': doc.id,
                    ...doc.data(),
                  })
              .toList();
          list.sort((a, b) {
            final aTime = a['lastUpdated'] ?? a['updatedAt'];
            final bTime = b['lastUpdated'] ?? b['updatedAt'];
            if (aTime == null || bTime == null) return 0;
            return (bTime as Comparable).compareTo(aTime as Comparable);
          });
          return list;
        });
      }
    }
  }

  /// جلب قماش واحد بالتفصيل (من مجموعة التاجر الفرعية)
  static Future<Map<String, dynamic>?> getTailorFabricById(
      String tailorId, String fabricId) async {
    try {
      const opts = GetOptions(source: Source.serverAndCache);
      final doc = await _tailorFabricsRef(tailorId).doc(fabricId).get(opts);
      if (doc.exists && doc.data() != null) {
        return {'id': doc.id, ...doc.data()!};
      }
      return null;
    } catch (e) {
      print('خطأ في جلب قماش التاجر: $e');
      return null;
    }
  }

  /// جلب قماش واحد بالتفصيل (من المجموعة العامة - للتوافق مع الشاشات القديمة)
  static Future<Map<String, dynamic>?> getFabricById(String fabricId) async {
    try {
      const opts = GetOptions(source: Source.serverAndCache);
      final doc = await FirebaseService.firestore
          .collection(_fabricsCollection)
          .doc(fabricId)
          .get(opts);
      if (doc.exists) {
        return {'id': doc.id, ...doc.data()!};
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

  /// البحث في أقمشة خياط محدد (من tailors/{tailorId}/fabrics)
  static Stream<List<Map<String, dynamic>>> searchTailorFabrics(
      String tailorId, String searchQuery) {
    final ref = _tailorFabricsRef(tailorId);
    final lower = searchQuery.toLowerCase();
    return ref.where('isAvailable', isEqualTo: true).snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .where((fabric) =>
                (fabric['name'] ?? '')
                    .toString()
                    .toLowerCase()
                    .contains(lower) ||
                (fabric['description'] ?? '')
                    .toString()
                    .toLowerCase()
                    .contains(lower) ||
                (fabric['type'] ?? '').toString().toLowerCase().contains(lower))
            .toList());
  }

  /// جلب الأقمشة حسب النوع لخياط محدد (من tailors/{tailorId}/fabrics)
  static Stream<List<Map<String, dynamic>>> getTailorFabricsByType(
      String tailorId, String fabricType) {
    final ref = _tailorFabricsRef(tailorId);
    return ref
        .where('type', isEqualTo: fabricType)
        .where('isAvailable', isEqualTo: true)
        .orderBy('lastUpdated', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
  }

  /// جلب الأقمشة حسب الموسم لخياط محدد
  static Stream<List<Map<String, dynamic>>> getTailorFabricsBySeason(
      String tailorId, String season) {
    final ref = _tailorFabricsRef(tailorId);
    return ref
        .where('season', isEqualTo: season)
        .where('isAvailable', isEqualTo: true)
        .orderBy('lastUpdated', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
  }

  /// جلب الأقمشة حسب الجودة لخياط محدد
  static Stream<List<Map<String, dynamic>>> getTailorFabricsByQuality(
      String tailorId, String quality) {
    final ref = _tailorFabricsRef(tailorId);
    return ref
        .where('quality', isEqualTo: quality)
        .where('isAvailable', isEqualTo: true)
        .orderBy('lastUpdated', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
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

  /// تحديث كمية القماش (لتاجر معين)
  static Future<bool> updateFabricQuantity(
      String tailorId, String fabricId, int newQuantity) async {
    try {
      await _tailorFabricsRef(tailorId).doc(fabricId).update({
        'quantity': newQuantity,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('خطأ في تحديث كمية القماش: $e');
      return false;
    }
  }

  /// تحديث حالة توفر القماش (لتاجر معين)
  static Future<bool> updateFabricAvailability(
      String tailorId, String fabricId, bool isAvailable) async {
    try {
      await _tailorFabricsRef(tailorId).doc(fabricId).update({
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

  /// إضافة قماش جديد لخياط محدد (في tailors/{tailorId}/fabrics)
  static Future<String?> addTailorFabric(
      String tailorId, Map<String, dynamic> fabricData) async {
    try {
      final docRef = await _tailorFabricsRef(tailorId).add({
        ...fabricData,
        'isAvailable': true,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      print('خطأ في إضافة قماش الخياط: $e');
      return null;
    }
  }

  /// إضافة قماش جديد (في مجموعة التاجر الفرعية)
  static Future<String?> addFabricWithTailorId(
      String tailorId, Map<String, dynamic> fabricData) async {
    return addTailorFabric(tailorId, fabricData);
  }

  /// تحديث قماش خياط محدد (في tailors/{tailorId}/fabrics)
  static Future<bool> updateTailorFabric(
      String tailorId, String fabricId, Map<String, dynamic> fabricData) async {
    try {
      await _tailorFabricsRef(tailorId).doc(fabricId).update({
        ...fabricData,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('خطأ في تحديث قماش الخياط: $e');
      return false;
    }
  }

  /// إضافة حقل tailorId للأقمشة الموجودة (للمرحلة الانتقالية - مجموعة عامة)
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

  /// حذف/تعطيل قماش لتاجر معين (في tailors/{tailorId}/fabrics)
  static Future<bool> deleteTailorFabric(
      String tailorId, String fabricId) async {
    try {
      await _tailorFabricsRef(tailorId).doc(fabricId).update({
        'isAvailable': false,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('خطأ في حذف قماش التاجر: $e');
      return false;
    }
  }

  /// حذف قماش (تعطيله) - من المجموعة العامة (للتوافق مع الشاشات القديمة)
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
