// lib/features/auth/services/profile_photo_service.dart
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hindam/core/services/firebase_service.dart';

/// رفع صورة الملف الشخصي إلى Firebase Storage وتحديث الرابط
class ProfilePhotoService {
  final _storage = FirebaseService.storage;

  static const String _usersPath = 'users';
  static const String _profileFileName = 'profile.jpg';

  /// رفع ملف الصورة وإرجاع رابط التحميل
  /// [userId] معرف المستخدم
  /// [file] ملف الصورة من المعرض أو الكاميرا
  /// يرمي [Exception] عند فشل الرفع
  Future<String> uploadProfilePhoto({
    required String userId,
    required File file,
  }) async {
    final ref =
        _storage.ref().child(_usersPath).child(userId).child(_profileFileName);

    final metadata = SettableMetadata(
      contentType: 'image/jpeg',
      cacheControl: 'max-age=86400',
    );

    final uploadTask = ref.putFile(file, metadata);

    final snapshot = await uploadTask;
    if (snapshot.state != TaskState.success) {
      throw Exception('فشل رفع الصورة');
    }

    final downloadUrl = await ref.getDownloadURL();
    return downloadUrl;
  }

  /// حذف صورة الملف الشخصي من التخزين (اختياري)
  Future<void> deleteProfilePhoto(String userId) async {
    final ref =
        _storage.ref().child(_usersPath).child(userId).child(_profileFileName);
    try {
      await ref.delete();
    } catch (_) {
      // تجاهل إذا الملف غير موجود
    }
  }
}
