import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app/app.dart';
import 'core/services/firebase_service.dart';
import 'core/providers/locale_provider.dart';
import 'app/theme/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تحسين الأداء: تثبيت اتجاه الشاشة مبكراً
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // تهيئة Firebase بشكل آمن ومحسّن
  try {
    await FirebaseService.initialize();
    debugPrint('✅ Firebase تم تهيئته بنجاح');
  } catch (e) {
    debugPrint('❌ فشل تهيئة Firebase: $e');
  }

  // ✅ تهيئة LocaleProvider قبل تشغيل التطبيق
  final localeProvider = LocaleProvider();
  final themeController = ThemeController();

  // Load persisted state before first frame (avoid theme flicker).
  await Future.wait([
    localeProvider.initialize(),
    themeController.initialize(),
  ]);
  debugPrint('✅ LocaleProvider تم تهيئته - اللغة: ${localeProvider.locale?.languageCode}');

  debugPrint('✅ ThemeController تم تهيئته - mode: ${themeController.mode}');

  runApp(HendamApp(localeProvider: localeProvider, themeController: themeController));
}
