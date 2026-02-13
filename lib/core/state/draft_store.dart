import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight draft persistence for preserving in-progress edits.
class DraftStore {
  static const String _prefix = 'draft:';
  static const int _version = 1;

  static String scopedKey(String key, {String? userId}) {
    if (userId == null || userId.isEmpty) return key;
    return '$key:$userId';
  }

  static Future<Map<String, dynamic>?> read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_prefix$key');
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = json.decode(raw);
      if (decoded is Map<String, dynamic>) {
        final data = decoded['data'];
        if (data is Map<String, dynamic>) {
          return Map<String, dynamic>.from(data);
        }
      }
    } catch (_) {}
    return null;
  }

  static Future<void> write(String key, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = <String, dynamic>{
      'v': _version,
      'updatedAt': DateTime.now().toIso8601String(),
      'data': data,
    };
    await prefs.setString('$_prefix$key', json.encode(payload));
  }

  static Future<void> clear(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_prefix$key');
  }
}
