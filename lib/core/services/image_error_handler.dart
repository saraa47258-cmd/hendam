// lib/core/services/image_error_handler.dart
import 'package:flutter/material.dart';

/// معالج أخطاء الصور لإيقاف رسائل الخطأ في console
class ImageErrorHandler {
  /// إعداد معالج أخطاء عالمي للصور
  static void setupImageErrorHandler() {
    // إيقاف رسائل Flutter Error في الصور
    FlutterError.onError = (FlutterErrorDetails details) {
      // تجاهل أخطاء NetworkImage فقط
      if (details.exception is NetworkImageLoadException) {
        final exception = details.exception as NetworkImageLoadException;
        // تجاهل فقط إذا كان الخطأ 412 (Precondition Failed)
        if (exception.statusCode == 412) {
          // إيقاف رسالة الخطأ - نزول الصورة بشكل صامت
          return;
        }
      }
      // طباعة باقي الأخطاء بشكل عادي
      FlutterError.presentError(details);
    };
  }

  /// معالج خاص لأخطاء الصور في بناء الصور
  static Widget handleImageError({
    required BuildContext context,
    required Exception error,
    required StackTrace stackTrace,
  }) {
    // إيقاف رسائل الخطأ في الصور
    if (error is NetworkImageLoadException) {
      return const SizedBox.shrink(); // إيقاف الرسالة
    }
    // طباعة باقي الأخطاء
    return ErrorWidget(error);
  }
}

/// امتداد لمعالجة أخطاء الصور
extension ImageErrorExtension on BuildContext {
  /// معالج أخطاء صورة آمن
  Widget safeImageErrorHandler(Widget errorWidget) {
    return errorWidget;
  }
}
