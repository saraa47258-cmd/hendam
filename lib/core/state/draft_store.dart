// lib/core/state/draft_store.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// مخزن المسودات المحلي - لحفظ تقدم المستخدم في النماذج والطلبات
class DraftStore {
  static const String _prefix = 'draft_';

  /// إنشاء مفتاح مسبوق بمعرف المستخدم إذا وُجد
  static String scopedKey(String key, {String? userId}) {
    if (userId != null && userId.isNotEmpty) {
      return '$_prefix${userId}_$key';
    }
    return '$_prefix$key';
  }

  /// قراءة مسودة من التخزين المحلي
  static Future<Map<String, dynamic>?> read(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(key);
      if (jsonString == null || jsonString.isEmpty) return null;
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      // في حالة فشل القراءة، نعيد null
      return null;
    }
  }

  /// كتابة مسودة إلى التخزين المحلي
  static Future<void> write(String key, Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(data);
      await prefs.setString(key, jsonString);
    } catch (e) {
      // تجاهل الأخطاء عند الكتابة
    }
  }

  /// مسح مسودة من التخزين المحلي
  static Future<void> clear(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
    } catch (e) {
      // تجاهل الأخطاء عند المسح
    }
  }

  /// مسح جميع المسودات للمستخدم الحالي
  static Future<void> clearAll({String? userId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      final userPrefix = userId != null ? '$_prefix$userId' : _prefix;
      
      for (final key in keys) {
        if (key.startsWith(userPrefix)) {
          await prefs.remove(key);
        }
      }
    } catch (e) {
      // تجاهل الأخطاء
    }
  }
}
