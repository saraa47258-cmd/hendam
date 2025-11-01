// lib/features/tailors/utils/fabric_migration_helper.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hindam/core/services/firebase_service.dart';

/// أداة مساعدة لإضافة حقل tailorId للأقمشة الموجودة
class FabricMigrationHelper {
  static const String _fabricsCollection = 'fabrics';

  /// إضافة tailorId لقماش واحد
  static Future<bool> addTailorIdToFabric(
      String fabricId, String tailorId) async {
    try {
      await FirebaseService.firestore
          .collection(_fabricsCollection)
          .doc(fabricId)
          .update({
        'tailorId': tailorId,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      print('تم إضافة tailorId للقماش: $fabricId');
      return true;
    } catch (e) {
      print('خطأ في إضافة tailorId للقماش $fabricId: $e');
      return false;
    }
  }

  /// إضافة tailorId لجميع الأقمشة الموجودة
  static Future<Map<String, dynamic>> addTailorIdToAllFabrics(
      String tailorId) async {
    try {
      final snapshot =
          await FirebaseService.firestore.collection(_fabricsCollection).get();

      int successCount = 0;
      int errorCount = 0;
      List<String> errorFabricIds = [];

      for (final doc in snapshot.docs) {
        final fabricData = doc.data();

        // تخطي الأقمشة التي لديها tailorId بالفعل
        if (fabricData['tailorId'] != null) {
          continue;
        }

        final success = await addTailorIdToFabric(doc.id, tailorId);
        if (success) {
          successCount++;
        } else {
          errorCount++;
          errorFabricIds.add(doc.id);
        }
      }

      return {
        'success': true,
        'totalFabrics': snapshot.docs.length,
        'successCount': successCount,
        'errorCount': errorCount,
        'errorFabricIds': errorFabricIds,
      };
    } catch (e) {
      print('خطأ في إضافة tailorId لجميع الأقمشة: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// جلب الأقمشة التي لا تحتوي على tailorId
  static Future<List<Map<String, dynamic>>> getFabricsWithoutTailorId() async {
    try {
      final snapshot =
          await FirebaseService.firestore.collection(_fabricsCollection).get();

      return snapshot.docs
          .where((doc) => doc.data()['tailorId'] == null)
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();
    } catch (e) {
      print('خطأ في جلب الأقمشة بدون tailorId: $e');
      return [];
    }
  }

  /// جلب الأقمشة التي تحتوي على tailorId محدد
  static Future<List<Map<String, dynamic>>> getFabricsByTailorId(
      String tailorId) async {
    try {
      final snapshot = await FirebaseService.firestore
          .collection(_fabricsCollection)
          .where('tailorId', isEqualTo: tailorId)
          .get();

      return snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();
    } catch (e) {
      print('خطأ في جلب أقمشة الخياط $tailorId: $e');
      return [];
    }
  }

  /// إحصائيات الأقمشة
  static Future<Map<String, dynamic>> getFabricStatistics() async {
    try {
      final snapshot =
          await FirebaseService.firestore.collection(_fabricsCollection).get();

      int totalFabrics = snapshot.docs.length;
      int fabricsWithTailorId = 0;
      int fabricsWithoutTailorId = 0;
      Map<String, int> tailorCounts = {};

      for (final doc in snapshot.docs) {
        final tailorId = doc.data()['tailorId'];
        if (tailorId != null) {
          fabricsWithTailorId++;
          tailorCounts[tailorId] = (tailorCounts[tailorId] ?? 0) + 1;
        } else {
          fabricsWithoutTailorId++;
        }
      }

      return {
        'totalFabrics': totalFabrics,
        'fabricsWithTailorId': fabricsWithTailorId,
        'fabricsWithoutTailorId': fabricsWithoutTailorId,
        'tailorCounts': tailorCounts,
        'uniqueTailors': tailorCounts.keys.length,
      };
    } catch (e) {
      print('خطأ في جلب إحصائيات الأقمشة: $e');
      return {
        'error': e.toString(),
      };
    }
  }

  /// حذف tailorId من قماش (للمرحلة الانتقالية)
  static Future<bool> removeTailorIdFromFabric(String fabricId) async {
    try {
      await FirebaseService.firestore
          .collection(_fabricsCollection)
          .doc(fabricId)
          .update({
        'tailorId': FieldValue.delete(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      print('تم حذف tailorId من القماش: $fabricId');
      return true;
    } catch (e) {
      print('خطأ في حذف tailorId من القماش $fabricId: $e');
      return false;
    }
  }
}



