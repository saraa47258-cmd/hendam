import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app/app.dart';
import 'core/services/firebase_service.dart';

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

  runApp(const HendamApp());
}
