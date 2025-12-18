import 'dart:typed_data';
import 'package:flutter/services.dart';

class SignLanguageDetector {
  static const platform = MethodChannel('com.example.hindam/hand_gesture');
  bool _isInitialized = false;

  /// تهيئة المكشاف
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      await platform.invokeMethod('initialize');
      _isInitialized = true;
      print('✅ HandGestureDetector initialized');
    } catch (e) {
      print('❌ خطأ في تهيئة المكشاف: $e');
      throw e;
    }
  }

  /// تحليل الصورة والتعرف على الإشارات
  Future<String> detectSignLanguage(Uint8List imageBytes) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    try {
      final String result = await platform.invokeMethod('detectHand', {
        'imageBytes': imageBytes,
      });
      
      return result;
    } catch (e) {
      print('خطأ في التعرف على الإشارة: $e');
      return '';
    }
  }

  /// إغلاق المكشاف
  Future<void> dispose() async {
    try {
      await platform.invokeMethod('dispose');
      _isInitialized = false;
    } catch (e) {
      print('خطأ في إغلاق المكشاف: $e');
    }
  }
}
