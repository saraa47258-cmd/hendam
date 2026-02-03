// lib/core/providers/locale_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hindam/l10n/app_localizations.dart';

/// مزود اللغة - يدير لغة التطبيق مع الحفظ المستمر
class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'app_locale';
  static const String _useDeviceLocaleKey = 'use_device_locale';

  Locale? _locale;
  bool _useDeviceLocale = true;
  bool _isInitialized = false;

  /// اللغة الحالية (null تعني استخدام لغة الجهاز)
  Locale? get locale => _useDeviceLocale ? null : _locale;

  /// هل يستخدم لغة الجهاز تلقائياً
  bool get useDeviceLocale => _useDeviceLocale;

  /// هل تم تهيئة المزود
  bool get isInitialized => _isInitialized;

  /// اللغات المدعومة
  static const List<Locale> supportedLocales = [
    Locale('ar'), // العربية
    Locale('en'), // الإنجليزية
  ];

  /// أسماء اللغات للعرض
  static const Map<String, String> localeNames = {
    'ar': 'العربية',
    'en': 'English',
  };

  /// تهيئة المزود وتحميل الإعدادات المحفوظة
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      // تحميل إعداد استخدام لغة الجهاز
      _useDeviceLocale = prefs.getBool(_useDeviceLocaleKey) ?? true;

      // تحميل اللغة المحفوظة
      final savedLocale = prefs.getString(_localeKey);
      if (savedLocale != null && savedLocale.isNotEmpty) {
        _locale = Locale(savedLocale);
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading locale preferences: $e');
      _isInitialized = true;
    }
  }

  /// تعيين لغة محددة
  Future<void> setLocale(Locale newLocale) async {
    if (_locale?.languageCode == newLocale.languageCode && !_useDeviceLocale) {
      return;
    }

    _locale = newLocale;
    _useDeviceLocale = false;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, newLocale.languageCode);
      await prefs.setBool(_useDeviceLocaleKey, false);
    } catch (e) {
      debugPrint('Error saving locale: $e');
    }

    notifyListeners();
  }

  /// استخدام لغة الجهاز (الوضع التلقائي)
  Future<void> useSystemLocale() async {
    if (_useDeviceLocale) return;

    _useDeviceLocale = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_useDeviceLocaleKey, true);
    } catch (e) {
      debugPrint('Error saving device locale preference: $e');
    }

    notifyListeners();
  }

  /// الحصول على اللغة الفعلية المستخدمة (للعرض في الإعدادات)
  String getCurrentLanguageName(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_useDeviceLocale) {
      return l10n?.automatic ?? 'تلقائي (لغة الجهاز)';
    }
    if (_locale?.languageCode == 'en') {
      return l10n?.english ?? 'English';
    }
    return l10n?.arabic ?? 'العربية';
  }

  /// الحصول على كود اللغة الحالية
  String get currentLanguageCode {
    if (_useDeviceLocale) {
      return 'auto';
    }
    return _locale?.languageCode ?? 'ar';
  }
}
