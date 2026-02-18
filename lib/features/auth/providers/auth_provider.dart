// lib/features/auth/providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import 'package:hindam/features/auth/models/user_model.dart';
import 'package:hindam/features/auth/services/auth_service.dart';
import 'package:hindam/l10n/app_localizations.dart';

/// مزود حالة المصادقة
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  /// تهيئة المزود
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // انتظار قليل للتأكد من تهيئة Firebase
      await Future.delayed(const Duration(milliseconds: 500));

      if (_authService.isSignedIn) {
        _currentUser = await _authService.getCurrentUserData();
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('خطأ في تهيئة AuthProvider: $e');
      // في حالة الخطأ، نعيد تعيين المستخدم إلى null
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// تسجيل حساب جديد
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    String? phoneNumber,
    UserRole role = UserRole.customer,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _authService.signUp(
        email: email,
        password: password,
        name: name,
        phoneNumber: phoneNumber,
        role: role,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// تسجيل الدخول
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _authService.signIn(
        email: email,
        password: password,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// تسجيل الخروج
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();
      _currentUser = null;
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('خطأ في تسجيل الخروج: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// تحديث بيانات المستخدم
  Future<bool> updateUser(UserModel user) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.updateUserData(user);
      _currentUser = user;
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// إعادة تعيين كلمة المرور
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.resetPassword(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// حذف الحساب
  Future<bool> deleteAccount() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.deleteAccount();
      _currentUser = null;
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// مسح الخطأ
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// ترجمة رسائل الخطأ باستخدام l10n
  static String localizeError(String? errorCode, AppLocalizations l10n) {
    if (errorCode == null) return l10n.errorOccurred;
    // Strip 'Exception: ' prefix if present
    final code = errorCode.replaceFirst('Exception: ', '');
    switch (code) {
      case 'auth_error_weak_password':
        return l10n.authErrorWeakPassword;
      case 'auth_error_email_in_use':
        return l10n.authErrorEmailInUse;
      case 'auth_error_invalid_email':
        return l10n.authErrorInvalidEmail;
      case 'auth_error_user_disabled':
        return l10n.authErrorUserDisabled;
      case 'auth_error_user_not_found':
        return l10n.authErrorUserNotFound;
      case 'auth_error_wrong_password':
        return l10n.authErrorWrongPassword;
      case 'auth_error_too_many_requests':
        return l10n.authErrorTooManyRequests;
      case 'auth_error_operation_not_allowed':
        return l10n.authErrorOperationNotAllowed;
      case 'auth_error_network_failed':
        return l10n.authErrorNetworkFailed;
      case 'auth_error_unexpected':
        return l10n.authErrorUnexpected;
      case 'auth_error_account_creation':
        return l10n.authErrorAccountCreation;
      case 'auth_error_sign_in':
        return l10n.authErrorSignIn;
      case 'auth_error_not_signed_in':
        return l10n.authErrorNotSignedIn;
      default:
        return errorCode;
    }
  }
}
