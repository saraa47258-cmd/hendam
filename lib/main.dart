import 'package:flutter/material.dart';
import 'app/app.dart';
import 'core/services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة Firebase بشكل آمن
  try {
    await FirebaseService.initialize();
    debugPrint('✅ Firebase تم تهيئته بنجاح');
  } catch (e) {
    debugPrint('❌ فشل تهيئة Firebase: $e');
  }

  // إيقاف رسائل أخطاء الصور في console
  // هذه الرسائل غير ضرورية ولا تؤثر على عمل التطبيق
  // ignore: avoid_print
  debugPrint('');

  runApp(const HendamApp());
}
