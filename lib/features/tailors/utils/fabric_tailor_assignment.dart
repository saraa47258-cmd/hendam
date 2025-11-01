// lib/features/tailors/utils/fabric_tailor_assignment.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hindam/core/services/firebase_service.dart';

/// أداة مساعدة لربط الأقمشة بالخياطين
class FabricTailorAssignment {
  static const String _fabricsCollection = 'fabrics';

  /// إضافة tailorId لقماش واحد
  static Future<bool> assignFabricToTailor(
      String fabricId, String tailorId) async {
    try {
      await FirebaseService.firestore
          .collection(_fabricsCollection)
          .doc(fabricId)
          .update({
        'tailorId': tailorId,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      print('✅ تم ربط القماش $fabricId بالخياط $tailorId');
      return true;
    } catch (e) {
      print('❌ خطأ في ربط القماش $fabricId بالخياط $tailorId: $e');
      return false;
    }
  }

  /// إضافة tailorId لجميع الأقمشة الموجودة (للمرحلة الانتقالية)
  static Future<Map<String, dynamic>> assignAllFabricsToTailor(
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

        final success = await assignFabricToTailor(doc.id, tailorId);
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
      print('❌ خطأ في ربط جميع الأقمشة بالخياط: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// جلب الأقمشة التي لا تحتوي على tailorId
  static Future<List<Map<String, dynamic>>> getUnassignedFabrics() async {
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
      print('❌ خطأ في جلب الأقمشة غير المربوطة: $e');
      return [];
    }
  }

  /// جلب الأقمشة المربوطة بخياط محدد
  static Future<List<Map<String, dynamic>>> getTailorAssignedFabrics(
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
      print('❌ خطأ في جلب أقمشة الخياط $tailorId: $e');
      return [];
    }
  }

  /// إحصائيات ربط الأقمشة
  static Future<Map<String, dynamic>> getAssignmentStatistics() async {
    try {
      final snapshot =
          await FirebaseService.firestore.collection(_fabricsCollection).get();

      int totalFabrics = snapshot.docs.length;
      int assignedFabrics = 0;
      int unassignedFabrics = 0;
      Map<String, int> tailorCounts = {};

      for (final doc in snapshot.docs) {
        final tailorId = doc.data()['tailorId'];
        if (tailorId != null) {
          assignedFabrics++;
          tailorCounts[tailorId] = (tailorCounts[tailorId] ?? 0) + 1;
        } else {
          unassignedFabrics++;
        }
      }

      return {
        'totalFabrics': totalFabrics,
        'assignedFabrics': assignedFabrics,
        'unassignedFabrics': unassignedFabrics,
        'tailorCounts': tailorCounts,
        'uniqueTailors': tailorCounts.keys.length,
      };
    } catch (e) {
      print('❌ خطأ في جلب إحصائيات الربط: $e');
      return {
        'error': e.toString(),
      };
    }
  }

  /// إزالة tailorId من قماش (إلغاء الربط)
  static Future<bool> unassignFabricFromTailor(String fabricId) async {
    try {
      await FirebaseService.firestore
          .collection(_fabricsCollection)
          .doc(fabricId)
          .update({
        'tailorId': FieldValue.delete(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      print('✅ تم إلغاء ربط القماش $fabricId');
      return true;
    } catch (e) {
      print('❌ خطأ في إلغاء ربط القماش $fabricId: $e');
      return false;
    }
  }

  /// نقل قماش من خياط إلى آخر
  static Future<bool> transferFabricToAnotherTailor(
      String fabricId, String newTailorId) async {
    try {
      await FirebaseService.firestore
          .collection(_fabricsCollection)
          .doc(fabricId)
          .update({
        'tailorId': newTailorId,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      print('✅ تم نقل القماش $fabricId إلى الخياط $newTailorId');
      return true;
    } catch (e) {
      print('❌ خطأ في نقل القماش $fabricId: $e');
      return false;
    }
  }

  /// جلب تفاصيل قماش مع معلومات الخياط
  static Future<Map<String, dynamic>?> getFabricWithTailorInfo(
      String fabricId) async {
    try {
      final fabricDoc = await FirebaseService.firestore
          .collection(_fabricsCollection)
          .doc(fabricId)
          .get();

      if (!fabricDoc.exists) {
        return null;
      }

      final fabricData = fabricDoc.data()!;
      final tailorId = fabricData['tailorId'];

      if (tailorId == null) {
        return {
          'id': fabricDoc.id,
          ...fabricData,
          'tailorInfo': null,
        };
      }

      // جلب معلومات الخياط
      final tailorDoc = await FirebaseService.firestore
          .collection('tailors')
          .doc(tailorId)
          .get();

      return {
        'id': fabricDoc.id,
        ...fabricData,
        'tailorInfo': tailorDoc.exists ? tailorDoc.data() : null,
      };
    } catch (e) {
      print('❌ خطأ في جلب تفاصيل القماش مع معلومات الخياط: $e');
      return null;
    }
  }
}



