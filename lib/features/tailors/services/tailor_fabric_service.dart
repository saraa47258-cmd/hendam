// lib/features/tailors/services/tailor_fabric_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hindam/core/services/firebase_service.dart';
import '../models/tailor_fabric.dart';

/// خدمة إدارة أقمشة وألوان الخياطين
class TailorFabricService {
  static const String _fabricsCollection = 'tailor_fabrics';
  static const String _colorsCollection = 'fabric_colors';

  /// جلب جميع أقمشة خياط معين
  static Stream<List<TailorFabric>> getTailorFabrics(String tailorId) {
    return FirebaseService.firestore
        .collection(_fabricsCollection)
        .where('tailorId', isEqualTo: tailorId)
        .where('isAvailable', isEqualTo: true)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TailorFabric.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  /// جلب قماش واحد بالتفصيل
  static Future<TailorFabric?> getFabricById(String fabricId) async {
    try {
      final doc = await FirebaseService.firestore
          .collection(_fabricsCollection)
          .doc(fabricId)
          .get();

      if (doc.exists) {
        return TailorFabric.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('خطأ في جلب القماش: $e');
      return null;
    }
  }

  /// جلب ألوان قماش معين
  static Stream<List<FabricColor>> getFabricColors(String fabricId) {
    return FirebaseService.firestore
        .collection(_colorsCollection)
        .where('fabricId', isEqualTo: fabricId)
        .where('isAvailable', isEqualTo: true)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FabricColor.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  /// جلب جميع ألوان خياط معين (من جميع أقمشته)
  static Stream<List<FabricColor>> getTailorColors(String tailorId) {
    return FirebaseService.firestore
        .collection(_fabricsCollection)
        .where('tailorId', isEqualTo: tailorId)
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .asyncMap((fabricsSnapshot) async {
      final List<FabricColor> allColors = [];

      for (final fabricDoc in fabricsSnapshot.docs) {
        final colorsSnapshot = await FirebaseService.firestore
            .collection(_colorsCollection)
            .where('fabricId', isEqualTo: fabricDoc.id)
            .where('isAvailable', isEqualTo: true)
            .get();

        allColors.addAll(colorsSnapshot.docs
            .map((doc) => FabricColor.fromFirestore(doc.data(), doc.id)));
      }

      return allColors;
    });
  }

  /// إضافة قماش جديد للخياط
  static Future<String?> addFabric(TailorFabric fabric) async {
    try {
      final docRef = await FirebaseService.firestore
          .collection(_fabricsCollection)
          .add(fabric.toFirestore());
      return docRef.id;
    } catch (e) {
      print('خطأ في إضافة القماش: $e');
      return null;
    }
  }

  /// إضافة لون جديد لقماش
  static Future<String?> addFabricColor(FabricColor color) async {
    try {
      final docRef = await FirebaseService.firestore
          .collection(_colorsCollection)
          .add(color.toFirestore());
      return docRef.id;
    } catch (e) {
      print('خطأ في إضافة اللون: $e');
      return null;
    }
  }

  /// تحديث قماش موجود
  static Future<bool> updateFabric(TailorFabric fabric) async {
    try {
      await FirebaseService.firestore
          .collection(_fabricsCollection)
          .doc(fabric.id)
          .update(fabric.toFirestore());
      return true;
    } catch (e) {
      print('خطأ في تحديث القماش: $e');
      return false;
    }
  }

  /// تحديث لون موجود
  static Future<bool> updateFabricColor(FabricColor color) async {
    try {
      await FirebaseService.firestore
          .collection(_colorsCollection)
          .doc(color.id)
          .update(color.toFirestore());
      return true;
    } catch (e) {
      print('خطأ في تحديث اللون: $e');
      return false;
    }
  }

  /// حذف قماش (تعطيله)
  static Future<bool> deleteFabric(String fabricId) async {
    try {
      await FirebaseService.firestore
          .collection(_fabricsCollection)
          .doc(fabricId)
          .update({'isAvailable': false, 'updatedAt': Timestamp.now()});
      return true;
    } catch (e) {
      print('خطأ في حذف القماش: $e');
      return false;
    }
  }

  /// حذف لون (تعطيله)
  static Future<bool> deleteFabricColor(String colorId) async {
    try {
      await FirebaseService.firestore
          .collection(_colorsCollection)
          .doc(colorId)
          .update({'isAvailable': false});
      return true;
    } catch (e) {
      print('خطأ في حذف اللون: $e');
      return false;
    }
  }

  /// البحث في أقمشة الخياط
  static Stream<List<TailorFabric>> searchTailorFabrics(
    String tailorId,
    String searchQuery,
  ) {
    return FirebaseService.firestore
        .collection(_fabricsCollection)
        .where('tailorId', isEqualTo: tailorId)
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TailorFabric.fromFirestore(doc.data(), doc.id))
            .where((fabric) =>
                fabric.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                fabric.description
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase()) ||
                fabric.fabricType
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase()))
            .toList());
  }

  /// جلب أقمشة حسب النوع
  static Stream<List<TailorFabric>> getFabricsByType(
    String tailorId,
    String fabricType,
  ) {
    return FirebaseService.firestore
        .collection(_fabricsCollection)
        .where('tailorId', isEqualTo: tailorId)
        .where('fabricType', isEqualTo: fabricType)
        .where('isAvailable', isEqualTo: true)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TailorFabric.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  /// جلب أقمشة حسب الموسم
  static Stream<List<TailorFabric>> getFabricsBySeason(
    String tailorId,
    String season,
  ) {
    return FirebaseService.firestore
        .collection(_fabricsCollection)
        .where('tailorId', isEqualTo: tailorId)
        .where('season', isEqualTo: season)
        .where('isAvailable', isEqualTo: true)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TailorFabric.fromFirestore(doc.data(), doc.id))
            .toList());
  }
}



