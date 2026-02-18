// lib/features/auth/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hindam/features/auth/models/user_model.dart';
import 'package:hindam/core/services/firebase_service.dart';
import 'package:hindam/core/error/error_handler.dart';

/// خدمة المصادقة والتعامل مع المستخدمين
class AuthService {
  final FirebaseAuth _auth = FirebaseService.auth;
  final FirebaseFirestore _firestore = FirebaseService.firestore;

  // Collection للمستخدمين
  static const String _usersCollection = 'users';

  /// الحصول على المستخدم الحالي
  User? get currentUser => _auth.currentUser;

  /// Stream لحالة المستخدم
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// التحقق من تسجيل الدخول
  bool get isSignedIn => currentUser != null;

  /// تسجيل حساب جديد
  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String name,
    String? phoneNumber,
    UserRole role = UserRole.customer,
  }) async {
    try {
      // إنشاء حساب في Firebase Auth
      final UserCredential credential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw Exception('auth_error_account_creation');
      }

      // لا نحتاج لتحديث displayName - نحفظ الاسم في Firestore فقط

      // إنشاء بيانات المستخدم
      final userModel = UserModel(
        uid: credential.user!.uid,
        email: email,
        name: name,
        phoneNumber: phoneNumber,
        createdAt: DateTime.now(),
        role: role,
      );

      // حفظ بيانات المستخدم في Firestore
      await _firestore
          .collection(_usersCollection)
          .doc(credential.user!.uid)
          .set(userModel.toMap());

      // لا نحتاج لتسجيل الأحداث في Analytics حالياً
      // await FirebaseService.logEvent('sign_up', {
      //   'method': 'email',
      //   'user_role': role.name,
      // });

      return userModel;
    } on FirebaseAuthException catch (e) {
      ErrorHandler.handleError(e, null, context: 'تسجيل حساب جديد');
      throw _handleAuthException(e);
    } catch (e) {
      ErrorHandler.handleError(e, null, context: 'تسجيل حساب جديد');
      rethrow;
    }
  }

  /// تسجيل الدخول
  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // تسجيل الدخول في Firebase Auth
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw Exception('auth_error_sign_in');
      }

      // جلب بيانات المستخدم من Firestore
      final userDoc = await _firestore
          .collection(_usersCollection)
          .doc(credential.user!.uid)
          .get();

      if (!userDoc.exists) {
        // إذا لم توجد بيانات المستخدم، نقوم بإنشائها
        final userModel = UserModel(
          uid: credential.user!.uid,
          email: credential.user!.email ?? email,
          name: credential.user!.displayName ?? '', // default name set by presentation layer
          createdAt: DateTime.now(),
        );

        await _firestore
            .collection(_usersCollection)
            .doc(credential.user!.uid)
            .set(userModel.toMap());

        return userModel;
      }

      // لا نحتاج لتسجيل الأحداث في Analytics حالياً
      // await FirebaseService.logEvent('login', {
      //   'method': 'email',
      // });

      return UserModel.fromFirestore(userDoc);
    } on FirebaseAuthException catch (e) {
      ErrorHandler.handleError(e, null, context: 'تسجيل الدخول');
      throw _handleAuthException(e);
    } catch (e) {
      ErrorHandler.handleError(e, null, context: 'تسجيل الدخول');
      rethrow;
    }
  }

  /// تسجيل الخروج
  Future<void> signOut() async {
    try {
      await _auth.signOut();

      // لا نحتاج لتسجيل الأحداث في Analytics حالياً
      // await FirebaseService.logEvent('logout', {});
    } catch (e) {
      ErrorHandler.handleError(e, null, context: 'تسجيل الخروج');
      rethrow;
    }
  }

  /// الحصول على بيانات المستخدم الحالي
  Future<UserModel?> getCurrentUserData() async {
    try {
      if (!isSignedIn) return null;

      final userDoc = await _firestore
          .collection(_usersCollection)
          .doc(currentUser!.uid)
          .get();

      if (!userDoc.exists) return null;

      return UserModel.fromFirestore(userDoc);
    } catch (e) {
      ErrorHandler.handleError(e, null, context: 'جلب بيانات المستخدم');
      return null;
    }
  }

  /// تحديث بيانات المستخدم
  Future<void> updateUserData(UserModel user) async {
    try {
      // إضافة تاريخ التحديث إذا لم يكن موجوداً
      final userData = user.toMap();
      if (!userData.containsKey('updatedAt') || userData['updatedAt'] == null) {
        userData['updatedAt'] = Timestamp.fromDate(DateTime.now());
      }

      await _firestore
          .collection(_usersCollection)
          .doc(user.uid)
          .update(userData);
    } catch (e) {
      ErrorHandler.handleError(e, null, context: 'تحديث بيانات المستخدم');
      rethrow;
    }
  }

  /// إعادة تعيين كلمة المرور
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);

      // لا نحتاج لتسجيل الأحداث في Analytics حالياً
      // await FirebaseService.logEvent('password_reset', {});
    } on FirebaseAuthException catch (e) {
      ErrorHandler.handleError(e, null, context: 'إعادة تعيين كلمة المرور');
      throw _handleAuthException(e);
    } catch (e) {
      ErrorHandler.handleError(e, null, context: 'إعادة تعيين كلمة المرور');
      rethrow;
    }
  }

  /// حذف الحساب
  Future<void> deleteAccount() async {
    try {
      if (!isSignedIn) throw Exception('auth_error_not_signed_in');

      // حذف بيانات المستخدم من Firestore
      await _firestore
          .collection(_usersCollection)
          .doc(currentUser!.uid)
          .delete();

      // حذف الحساب من Firebase Auth
      await currentUser!.delete();

      // لا نحتاج لتسجيل الأحداث في Analytics حالياً
      // await FirebaseService.logEvent('account_deleted', {});
    } catch (e) {
      ErrorHandler.handleError(e, null, context: 'حذف الحساب');
      rethrow;
    }
  }

  /// معالجة أخطاء Firebase Auth - returns error codes for l10n
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'auth_error_weak_password';
      case 'email-already-in-use':
        return 'auth_error_email_in_use';
      case 'invalid-email':
        return 'auth_error_invalid_email';
      case 'user-disabled':
        return 'auth_error_user_disabled';
      case 'user-not-found':
        return 'auth_error_user_not_found';
      case 'wrong-password':
        return 'auth_error_wrong_password';
      case 'too-many-requests':
        return 'auth_error_too_many_requests';
      case 'operation-not-allowed':
        return 'auth_error_operation_not_allowed';
      case 'network-request-failed':
        return 'auth_error_network_failed';
      default:
        return 'auth_error_unexpected';
    }
  }
}
