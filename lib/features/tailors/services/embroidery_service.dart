import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/embroidery_design.dart';

/// خدمة لإدارة تصاميم التطريز
class EmbroideryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// جلب جميع تصاميم التطريز المتاحة لخياط معين
  Future<List<EmbroideryDesign>> getEmbroideryDesigns(String tailorId) async {
    try {
      // أولاً: جلب البيانات من Firestore إذا كانت متوفرة
      final designsSnapshot = await _firestore
          .collection('tailors')
          .doc(tailorId)
          .collection('embroideryDesigns')
          .orderBy('uploadedAt', descending: true)
          .get();

      if (designsSnapshot.docs.isNotEmpty) {
        return designsSnapshot.docs
            .map((doc) => EmbroideryDesign.fromMap(doc.data(), doc.id))
            .toList();
      }

      // إذا لم تكن متوفرة في Firestore، جلب الصور من Storage
      return await _getDesignsFromStorage(tailorId);
    } catch (e) {
      print('❌ خطأ في جلب تصاميم التطريز: $e');
      return [];
    }
  }

  /// جلب تصاميم التطريز من Firebase Storage مباشرة
  Future<List<EmbroideryDesign>> _getDesignsFromStorage(String tailorId) async {
    try {
      final storageRef = _storage.ref('tailors/$tailorId/embroidery_images');
      final listResult = await storageRef.listAll();

      final designs = <EmbroideryDesign>[];

      for (var item in listResult.items) {
        try {
          final url = await item.getDownloadURL();
          final metadata = await item.getMetadata();
          
          // استخراج ID من اسم الملف (بدون الامتداد)
          final fileName = item.name;
          final id = fileName.split('.').first;

          designs.add(EmbroideryDesign(
            id: id,
            imageUrl: url,
            name: 'تطريز ${designs.length + 1}',
            price: 0.0, // سعر افتراضي
            uploadedAt: metadata.timeCreated ?? DateTime.now(),
          ));
        } catch (e) {
          print('❌ خطأ في جلب صورة التطريز: $e');
        }
      }

      return designs;
    } catch (e) {
      print('❌ خطأ في جلب الصور من Storage: $e');
      return [];
    }
  }

  /// Stream لمتابعة تحديثات تصاميم التطريز
  Stream<List<EmbroideryDesign>> streamEmbroideryDesigns(String tailorId) {
    return _firestore
        .collection('tailors')
        .doc(tailorId)
        .collection('embroideryDesigns')
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs
            .map((doc) => EmbroideryDesign.fromMap(doc.data(), doc.id))
            .toList();
      }
      // إذا لم يكن هناك بيانات في Firestore، جلب من Storage
      return await _getDesignsFromStorage(tailorId);
    });
  }

  /// حفظ تصميم تطريز جديد في Firestore
  Future<void> saveEmbroideryDesign(
    String tailorId,
    EmbroideryDesign design,
  ) async {
    try {
      await _firestore
          .collection('tailors')
          .doc(tailorId)
          .collection('embroideryDesigns')
          .doc(design.id)
          .set(design.toMap());
      
      print('✅ تم حفظ تصميم التطريز بنجاح');
    } catch (e) {
      print('❌ خطأ في حفظ تصميم التطريز: $e');
      rethrow;
    }
  }

  /// حذف تصميم تطريز
  Future<void> deleteEmbroideryDesign(String tailorId, String designId) async {
    try {
      await _firestore
          .collection('tailors')
          .doc(tailorId)
          .collection('embroideryDesigns')
          .doc(designId)
          .delete();
      
      print('✅ تم حذف تصميم التطريز بنجاح');
    } catch (e) {
      print('❌ خطأ في حذف تصميم التطريز: $e');
      rethrow;
    }
  }

  /// تحديث معلومات تصميم تطريز
  Future<void> updateEmbroideryDesign(
    String tailorId,
    String designId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _firestore
          .collection('tailors')
          .doc(tailorId)
          .collection('embroideryDesigns')
          .doc(designId)
          .update(updates);
      
      print('✅ تم تحديث تصميم التطريز بنجاح');
    } catch (e) {
      print('❌ خطأ في تحديث تصميم التطريز: $e');
      rethrow;
    }
  }
}

