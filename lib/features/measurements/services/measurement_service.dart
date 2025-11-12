// lib/features/measurements/services/measurement_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hindam/core/services/firebase_service.dart';
import '../../auth/services/auth_service.dart';
import '../models/measurement_profile.dart';

/// خدمة إدارة ملفات المقاسات
class MeasurementService {
  static const _collectionName = 'measurement_profiles';

  final FirebaseFirestore _firestore = FirebaseService.firestore;
  final AuthService _authService = AuthService();

  String? get _uid => _authService.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> _userCollection(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection(_collectionName);
  }

  /// جلب جميع ملفات المقاسات للمستخدم
  Stream<List<MeasurementProfile>> streamProfiles() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();

    return _userCollection(uid)
        .orderBy('isDefault', descending: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map(MeasurementProfile.fromDoc).toList());
  }

  /// جلب الملف الافتراضي
  Future<MeasurementProfile?> getDefaultProfile() async {
    final uid = _uid;
    if (uid == null) return null;

    try {
      final snapshot = await _userCollection(uid)
          .where('isDefault', isEqualTo: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return MeasurementProfile.fromDoc(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      print('❌ خطأ في جلب الملف الافتراضي: $e');
      return null;
    }
  }

  /// حفظ ملف مقاسات جديد
  Future<void> saveProfile(MeasurementProfile profile) async {
    final uid = _uid;
    if (uid == null) throw StateError('User not authenticated');

    final collection = _userCollection(uid);
    final docRef = collection.doc();
    final data = profile.copyWith(id: docRef.id, userId: uid);

    if (profile.isDefault) {
      await _unsetDefault(uid);
    }

    await docRef.set(data.toMap());
    print('✅ تم حفظ ملف المقاسات: ${profile.name}');
  }

  /// تحديث ملف مقاسات
  Future<void> updateProfile(MeasurementProfile profile) async {
    final uid = _uid;
    if (uid == null) throw StateError('User not authenticated');

    final docRef = _userCollection(uid).doc(profile.id);
    
    if (profile.isDefault) {
      await _unsetDefault(uid, exceptId: profile.id);
    }

    await docRef.update({
      ...profile.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    print('✅ تم تحديث ملف المقاسات: ${profile.name}');
  }

  /// حذف ملف مقاسات
  Future<void> deleteProfile(String profileId) async {
    final uid = _uid;
    if (uid == null) throw StateError('User not authenticated');

    await _userCollection(uid).doc(profileId).delete();
    print('✅ تم حذف ملف المقاسات');
  }

  /// تعيين ملف كافتراضي
  Future<void> setDefault(String profileId) async {
    final uid = _uid;
    if (uid == null) throw StateError('User not authenticated');

    await _unsetDefault(uid, exceptId: profileId);
    await _userCollection(uid).doc(profileId).update({
      'isDefault': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    print('✅ تم تعيين الملف كافتراضي');
  }

  Future<void> _unsetDefault(String userId, {String? exceptId}) async {
    final docs = await _userCollection(userId)
        .where('isDefault', isEqualTo: true)
        .get();
    
    for (final doc in docs.docs) {
      if (doc.id == exceptId) continue;
      await doc.reference.update({
        'isDefault': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// جلب المقاسات من آخر طلب
  Future<Map<String, double>?> getLastOrderMeasurements() async {
    final uid = _uid;
    if (uid == null) return null;

    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('customerId', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        return Map<String, double>.from(data['measurements'] ?? {});
      }
      return null;
    } catch (e) {
      print('❌ خطأ في جلب مقاسات الطلب الأخير: $e');
      return null;
    }
  }
}




