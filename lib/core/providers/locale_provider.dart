import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// مزود اللغة للتحكم في لغة التطبيق
class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'app_locale';
  static const String _useDeviceLocaleKey = 'use_device_locale';

  Locale? _locale;
  bool _useDeviceLocale = true;
  bool _isInitialized = false;

  /// اللغة الحالية
  Locale? get locale => _locale;

  /// هل يستخدم لغة الجهاز؟
  bool get useDeviceLocale => _useDeviceLocale;

  /// هل تم التهيئة؟
  bool get isInitialized => _isInitialized;

  /// اللغات المدعومة
  static const List<Locale> supportedLocales = [
    Locale('ar'),
    Locale('en'),
  ];

  /// تهيئة المزود
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      _useDeviceLocale = prefs.getBool(_useDeviceLocaleKey) ?? true;

      if (_useDeviceLocale) {
        // استخدام لغة الجهاز
        _locale = _getDeviceLocale();
      } else {
        // استخدام اللغة المحفوظة
        final savedLocale = prefs.getString(_localeKey);
        if (savedLocale != null) {
          _locale = Locale(savedLocale);
        } else {
          _locale = _getDeviceLocale();
        }
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing LocaleProvider: $e');
      _locale = const Locale('ar');
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// الحصول على لغة الجهاز
  Locale _getDeviceLocale() {
    final deviceLocale = ui.PlatformDispatcher.instance.locale;
    // التحقق من أن اللغة مدعومة
    if (supportedLocales
        .any((l) => l.languageCode == deviceLocale.languageCode)) {
      return Locale(deviceLocale.languageCode);
    }
    // الافتراضي للعربية
    return const Locale('ar');
  }

  /// تغيير اللغة
  Future<void> setLocale(Locale locale) async {
    if (!supportedLocales.any((l) => l.languageCode == locale.languageCode)) {
      return;
    }

    _locale = locale;
    _useDeviceLocale = false;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, locale.languageCode);
      await prefs.setBool(_useDeviceLocaleKey, false);
    } catch (e) {
      debugPrint('Error saving locale: $e');
    }

    notifyListeners();
  }

  /// استخدام لغة الجهاز
  Future<void> useSystemLocale() async {
    _useDeviceLocale = true;
    _locale = _getDeviceLocale();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_useDeviceLocaleKey, true);
      await prefs.remove(_localeKey);
    } catch (e) {
      debugPrint('Error setting system locale: $e');
    }

    notifyListeners();
  }

  /// التبديل للعربية
  Future<void> setArabic() async {
    await setLocale(const Locale('ar'));
  }

  /// التبديل للإنجليزية
  Future<void> setEnglish() async {
    await setLocale(const Locale('en'));
  }

  /// هل اللغة الحالية عربية؟
  bool get isArabic => _locale?.languageCode == 'ar';

  /// هل اللغة الحالية إنجليزية؟
  bool get isEnglish => _locale?.languageCode == 'en';

  /// هل اللغة الحالية تستخدم الاتجاه من اليمين لليسار؟
  bool get isRtl => _locale?.languageCode == 'ar';
}
