import 'dart:ui' show Color;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import '../models/embroidery_design.dart';

/// خدمة لإدارة تصاميم التطريز
class EmbroideryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// حد الصفحة للطلبات
  static const int _designsLimit = 50;

  /// جلب جميع تصاميم التطريز المتاحة لخياط معين
  /// [useCacheFirst] عند true يقرأ من الكاش أولاً إن وُجد (أسرع)
  Future<List<EmbroideryDesign>> getEmbroideryDesigns(
    String tailorId, {
    bool useCacheFirst = false,
    int limit = _designsLimit,
    DocumentSnapshot? startAfterDocument,
  }) async {
    final stopwatch = Stopwatch()..start();
    final fullPath1 = 'tailors/$tailorId/displayed_embroidery';

    try {
      final options = useCacheFirst
          ? const GetOptions(source: Source.cache)
          : const GetOptions(source: Source.serverAndCache);

      // 1) محاولة من مجموعة displayed_embroidery (المسار الرئيسي)
      Query<Map<String, dynamic>> query = _firestore
          .collection('tailors')
          .doc(tailorId)
          .collection('displayed_embroidery')
          .limit(limit);

      if (startAfterDocument != null) {
        query = query.startAfterDocument(startAfterDocument);
      }

      QuerySnapshot<Map<String, dynamic>> displayedSnapshot;
      try {
        displayedSnapshot = await query.get(options);
      } catch (e) {
        debugPrint(
            '📂 [Embroidery] Firestore path: $fullPath1 | query failed: $e');
        stopwatch.stop();
        rethrow;
      }

      final count = displayedSnapshot.docs.length;
      debugPrint(
          '📂 [Embroidery] Firestore path: $fullPath1 | documents: $count | time: ${stopwatch.elapsedMilliseconds}ms');

      if (displayedSnapshot.docs.isNotEmpty) {
        // جلب تفاصيل التصاميم من embroidery_images دفعة واحدة (whereIn حد 10 لكل استعلام)
        final ids = displayedSnapshot.docs.map((d) => d.id).toList();
        final Map<String, Map<String, dynamic>> idToData = {};
        const int chunkSize = 10;
        for (int i = 0; i < ids.length; i += chunkSize) {
          final chunk = ids.skip(i).take(chunkSize).toList();
          final snapshot = await _firestore
              .collection('embroidery_images')
              .where(FieldPath.documentId, whereIn: chunk)
              .get(options);
          for (final doc in snapshot.docs) {
            if (doc.data().isNotEmpty) {
              idToData[doc.id] = doc.data();
            }
          }
        }
        final List<EmbroideryDesign> designs = [];
        for (final doc in displayedSnapshot.docs) {
          final data = idToData[doc.id];
          if (data != null) {
            designs.add(EmbroideryDesign.fromMap(data, doc.id));
          }
        }
        stopwatch.stop();
        debugPrint(
            '📂 [Embroidery] Total designs loaded: ${designs.length} | time: ${stopwatch.elapsedMilliseconds}ms');
        if (designs.isNotEmpty) {
          return designs;
        }
      }

      // 2) محاولة من مجموعة embroideryDesigns (المسار القديم)
      final fullPath2 = 'tailors/$tailorId/embroideryDesigns';
      debugPrint('📂 [Embroidery] $fullPath1 empty, trying $fullPath2');

      final embroideryDesignsSnapshot = await _firestore
          .collection('tailors')
          .doc(tailorId)
          .collection('embroideryDesigns')
          .orderBy('uploadedAt', descending: true)
          .limit(limit)
          .get(options);

      if (embroideryDesignsSnapshot.docs.isNotEmpty) {
        final list = embroideryDesignsSnapshot.docs
            .map((doc) => EmbroideryDesign.fromMap(doc.data(), doc.id))
            .toList();
        return list;
      }

      // 3) محاولة من مجموعة embroidery_images (إذا كانت البيانات هناك)
      final fullPath3 = 'tailors/$tailorId/embroidery_images';
      debugPrint('📂 [Embroidery] $fullPath2 empty, trying $fullPath3');

      final imagesSnapshot = await _firestore
          .collection('tailors')
          .doc(tailorId)
          .collection('embroidery_images')
          .limit(limit)
          .get(options);

      final count2 = imagesSnapshot.docs.length;
      debugPrint(
          '📂 [Embroidery] Firestore path: $fullPath3 | documents: $count2');

      if (imagesSnapshot.docs.isNotEmpty) {
        final docs = imagesSnapshot.docs;

        // تحضير قائمة ملفات التخزين كـ fallback عند غياب الروابط
        List<Reference> storageItems = const [];
        final needStorageLookup = docs.any((doc) {
          final d = doc.data();
          final url = d['imageUrl'] ??
              d['image_url'] ??
              d['url'] ??
              d['downloadUrl'] ??
              d['image'];
          return (url == null || (url is String && url.isEmpty));
        });
        if (needStorageLookup) {
          try {
            final listResult = await _storage
                .ref('tailors/$tailorId/embroidery_images')
                .listAll();
            storageItems = listResult.items;
          } catch (_) {
            // ignore - fallback will just keep empty url
          }
        }

        final designs = <EmbroideryDesign>[];
        for (final doc in docs) {
          final d = doc.data();
          final rawUploaded = d['uploadedAt'];
          final uploadedMs = rawUploaded is Timestamp
              ? rawUploaded.millisecondsSinceEpoch
              : (rawUploaded as int?) ?? DateTime.now().millisecondsSinceEpoch;

          String imageUrl = (d['imageUrl'] ??
                  d['image_url'] ??
                  d['url'] ??
                  d['downloadUrl'] ??
                  d['image']) as String? ??
              '';

          // إذا لم يوجد رابط، حاول استخراجه من Storage
          if (imageUrl.isEmpty) {
            final storagePath = (d['storagePath'] ??
                    d['path'] ??
                    d['fullPath'] ??
                    d['filePath']) as String? ??
                '';
            if (storagePath.isNotEmpty) {
              try {
                imageUrl = await _storage.ref(storagePath).getDownloadURL();
              } catch (_) {}
            } else if (storageItems.isNotEmpty) {
              // محاولة مطابقة الـ doc.id مع اسم الملف
              final match = storageItems.firstWhere(
                (r) => r.name.split('.').first == doc.id,
                orElse: () => storageItems.first,
              );
              try {
                imageUrl = await match.getDownloadURL();
              } catch (_) {}
            }
          }

          designs.add(EmbroideryDesign.fromMap({
            'imageUrl': imageUrl,
            'name': d['name'] ?? 'تطريز ${doc.id}',
            'price': (d['price'] as num?)?.toDouble() ?? 0.0,
            'uploadedAt': uploadedMs,
          }, doc.id));
        }
        return designs;
      }

      // 3) Fallback: جلب من Storage
      debugPrint('📂 [Embroidery] Firestore empty, falling back to Storage');
      return await _getDesignsFromStorage(tailorId);
    } catch (e, st) {
      stopwatch.stop();
      debugPrint('❌ [Embroidery] Error path: $fullPath1 | $e');
      debugPrint('❌ [Embroidery] Stack: $st');
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

  /// جلب ألوان خيوط التطريز المتاحة من Firebase
  Future<List<ThreadColor>> getThreadColors(String tailorId) async {
    try {
      // أولاً: جلب ألوان الخياط المحددة
      final colorsSnapshot = await _firestore
          .collection('tailors')
          .doc(tailorId)
          .collection('threadColors')
          .orderBy('order', descending: false)
          .get();

      if (colorsSnapshot.docs.isNotEmpty) {
        return colorsSnapshot.docs
            .map((doc) => ThreadColor.fromMap(doc.data(), doc.id))
            .toList();
      }

      // إذا لم تكن موجودة، جلب الألوان العامة
      final globalSnapshot =
          await _firestore.collection('settings').doc('threadColors').get();
      if (globalSnapshot.exists) {
        final data = globalSnapshot.data();
        final colorsList = data?['colors'] as List<dynamic>? ?? [];
        return colorsList.asMap().entries.map((entry) {
          final colorData = entry.value as Map<String, dynamic>;
          return ThreadColor(
            id: 'color_${entry.key}',
            name: colorData['name'] ?? 'لون ${entry.key + 1}',
            hexCode: colorData['hex'] ?? '#000000',
            order: entry.key,
          );
        }).toList();
      }

      // ألوان افتراضية
      return _defaultThreadColors;
    } catch (e) {
      print('❌ خطأ في جلب ألوان الخيوط: $e');
      return _defaultThreadColors;
    }
  }

  /// Stream لمتابعة تحديثات ألوان الخيوط
  Stream<List<ThreadColor>> streamThreadColors(String tailorId) {
    return _firestore
        .collection('tailors')
        .doc(tailorId)
        .collection('threadColors')
        .orderBy('order', descending: false)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs
            .map((doc) => ThreadColor.fromMap(doc.data(), doc.id))
            .toList();
      }
      return _defaultThreadColors;
    });
  }

  /// الألوان الافتراضية
  static final List<ThreadColor> _defaultThreadColors = [
    const ThreadColor(id: 'navy', name: 'كحلي', hexCode: '#1a237e', order: 0),
    const ThreadColor(
        id: 'teal', name: 'أخضر زيتي', hexCode: '#00695c', order: 1),
    const ThreadColor(
        id: 'burgundy', name: 'خمري', hexCode: '#880e4f', order: 2),
    const ThreadColor(id: 'gold', name: 'ذهبي', hexCode: '#c9a227', order: 3),
    const ThreadColor(id: 'silver', name: 'فضي', hexCode: '#9e9e9e', order: 4),
    const ThreadColor(id: 'white', name: 'أبيض', hexCode: '#ffffff', order: 5),
    const ThreadColor(id: 'black', name: 'أسود', hexCode: '#212121', order: 6),
    const ThreadColor(id: 'brown', name: 'بني', hexCode: '#5d4037', order: 7),
  ];
}

/// نموذج لون خيط التطريز
class ThreadColor {
  final String id;
  final String name;
  final String hexCode;
  final int order;
  const ThreadColor({
    required this.id,
    required this.name,
    required this.hexCode,
    required this.order,
  });

  factory ThreadColor.fromMap(Map<String, dynamic> data, String id) {
    return ThreadColor(
      id: id,
      name: data['name'] ?? '',
      hexCode: data['hex'] ?? data['hexCode'] ?? '#000000',
      order: data['order'] ?? 0,
    );
  }

  Color get color {
    final hex = hexCode.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
}
