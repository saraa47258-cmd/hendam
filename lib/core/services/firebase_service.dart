// lib/core/services/firebase_service.dart
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:hindam/core/error/error_handler.dart';

class FirebaseService {
  static FirebaseFirestore? _firestore;
  static FirebaseAuth? _auth;
  static FirebaseStorage? _storage;
  static FirebaseAnalytics? _analytics;
  static bool _analyticsInitialized = false;

  // تهيئة Firebase الأساسية فقط (سريعة)
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp();
      _firestore = FirebaseFirestore.instance;
      _auth = FirebaseAuth.instance;
      _storage = FirebaseStorage.instance;

      // إعدادات Firestore محسّنة للأداء
      _firestore!.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );

      // تأخير تهيئة Analytics لتحسين وقت البدء
      // Analytics تسبب بطء كبير في بداية التطبيق
      _initializeAnalyticsDeferred();
    } catch (e) {
      ErrorHandler.handleError(e, null, context: 'تهيئة Firebase');
    }
  }

  // تهيئة Analytics بشكل مؤجل (لا تحجب الـ main thread)
  static void _initializeAnalyticsDeferred() {
    // تأجيل تهيئة Analytics لمدة 3 ثواني بعد بدء التطبيق
    Future.delayed(const Duration(seconds: 3), () async {
      try {
        // في وضع Debug، نتجنب Analytics لتحسين الأداء
        if (kDebugMode) {
          debugPrint('⏭️ تم تخطي Analytics في وضع Debug لتحسين الأداء');
          return;
        }
        _analytics = FirebaseAnalytics.instance;
        _analyticsInitialized = true;
        debugPrint('✅ تم تهيئة Analytics بنجاح');
      } catch (e) {
        debugPrint('⚠️ فشل تهيئة Analytics: $e');
      }
    });
  }

  // Getters
  static FirebaseFirestore get firestore {
    if (_firestore == null) {
      throw Exception('Firebase لم يتم تهيئته بعد');
    }
    return _firestore!;
  }

  static FirebaseAuth get auth {
    if (_auth == null) {
      throw Exception('Firebase لم يتم تهيئته بعد');
    }
    return _auth!;
  }

  static FirebaseStorage get storage {
    if (_storage == null) {
      throw Exception('Firebase لم يتم تهيئته بعد');
    }
    return _storage!;
  }

  static FirebaseAnalytics? get analytics {
    // إرجاع null إذا لم يتم تهيئة Analytics بعد (بدلاً من إلقاء استثناء)
    return _analytics;
  }

  // التحقق من جاهزية Analytics
  static bool get isAnalyticsReady =>
      _analyticsInitialized && _analytics != null;

  // تسجيل الأحداث (مع معالجة آمنة للأخطاء)
  static Future<void> logEvent(
      String eventName, Map<String, Object> parameters) async {
    // تخطي في وضع Debug لتحسين الأداء
    if (kDebugMode) return;

    try {
      if (_analytics != null && _analyticsInitialized) {
        await _analytics!.logEvent(name: eventName, parameters: parameters);
      }
    } catch (e) {
      // تجاهل أخطاء Analytics تماماً
      debugPrint('تحذير: فشل تسجيل الحدث في Analytics: $e');
    }
  }

  // تسجيل الدخول
  static Future<UserCredential?> signInWithEmail(
      String email, String password) async {
    try {
      return await auth.signInWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      ErrorHandler.handleError(e, null, context: 'تسجيل الدخول');
      return null;
    }
  }

  // إنشاء حساب جديد
  static Future<UserCredential?> createUserWithEmail(
      String email, String password) async {
    try {
      return await auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      ErrorHandler.handleError(e, null, context: 'إنشاء حساب جديد');
      return null;
    }
  }

  // تسجيل الخروج
  static Future<void> signOut() async {
    try {
      await auth.signOut();
    } catch (e) {
      ErrorHandler.handleError(e, null, context: 'تسجيل الخروج');
    }
  }

  // الحصول على المستخدم الحالي
  static User? get currentUser => auth.currentUser;

  // التحقق من حالة تسجيل الدخول
  static bool get isSignedIn => currentUser != null;

  // Stream للمستخدم الحالي
  static Stream<User?> get authStateChanges => auth.authStateChanges();

  // تحديث البيانات يدوياً مع التحقق من الشبكة
  static Future<void> refreshData() async {
    try {
      // التحقق من تفعيل الشبكة
      await _firestore?.enableNetwork();
      debugPrint('تم تحديث الاتصال بـ Firebase');
    } catch (e) {
      debugPrint('فشل تحديث الاتصال: $e');
    }
  }

  // الحصول على استعلام محسّن للخياطين
  static Query<Map<String, dynamic>> getTailorsQuery({int? limit}) {
    try {
      // جلب المحلات النشطة مع الترتيب حسب createdAt
      // ملاحظة: إذا أردت استخدام where + orderBy، تحتاج index في Firestore
      var query = firestore
          .collection('tailors')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      return query;
    } catch (e) {
      // في حالة الخطأ (مثلاً لا يوجد index)، نستخدم query بدون where
      debugPrint('تحذير: خطأ في getTailorsQuery: $e');
      debugPrint('محاولة استخدام query بسيط بدون where...');

      try {
        // محاولة بدون where
        var query = firestore
            .collection('tailors')
            .orderBy('createdAt', descending: true);

        if (limit != null) {
          query = query.limit(limit);
        }

        return query;
      } catch (e2) {
        // إذا فشل الترتيب أيضاً، نرجع query بسيط جداً
        debugPrint('تحذير: خطأ في الترتيب أيضاً: $e2');
        debugPrint('استخدام query بسيط بدون ترتيب...');

        Query<Map<String, dynamic>> query = firestore.collection('tailors');

        if (limit != null) {
          query = query.limit(limit);
        }

        return query;
      }
    }
  }
}
