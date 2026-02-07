// lib/core/utils/photo_permission_helper.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// طلب أذونات الصور/المعرض مع توضيح السبب ومعالجة الرفض الدائم
class PhotoPermissionHelper {
  /// طلب إذن المعرض (الصور). على Android 13+ يستخدم READ_MEDIA_IMAGES،
  /// على Android الأقدم يستخدم READ_EXTERNAL_STORAGE.
  /// يُرجع true إذا مُنح الإذن، false إذا رُفض أو مُنع نهائياً.
  static Future<bool> requestPhotoPermission(BuildContext context) async {
    const Permission permission = Permission.photos;
    final status = await permission.status;
    if (status.isGranted) return true;
    if (status.isPermanentlyDenied) {
      if (context.mounted) {
        await _showPermanentlyDeniedDialog(context, isGallery: true);
      }
      return false;
    }

    final shouldShowRationale = await permission.shouldShowRequestRationale;
    if (shouldShowRationale && context.mounted) {
      await _showRationaleDialog(
        context,
        title: 'الوصول إلى الصور',
        message: 'نحتاج إلى الوصول لمعرض الصور لاختيار صورة للملف الشخصي.',
      );
    }

    var newStatus = await permission.request();
    if (!newStatus.isGranted && Platform.isAndroid) {
      final storageStatus = await Permission.storage.request();
      newStatus = storageStatus;
    }
    if (newStatus.isGranted) return true;
    if (newStatus.isPermanentlyDenied && context.mounted) {
      await _showPermanentlyDeniedDialog(context, isGallery: true);
    }
    return false;
  }

  /// طلب إذن الكاميرا.
  static Future<bool> requestCameraPermission(BuildContext context) async {
    final status = await Permission.camera.status;
    if (status.isGranted) return true;
    if (status.isPermanentlyDenied) {
      await _showPermanentlyDeniedDialog(context, isGallery: false);
      return false;
    }

    final shouldShowRationale =
        await Permission.camera.shouldShowRequestRationale;
    if (shouldShowRationale && context.mounted) {
      await _showRationaleDialog(
        context,
        title: 'الوصول إلى الكاميرا',
        message: 'نحتاج إلى استخدام الكاميرا لالتقاط صورة للملف الشخصي.',
      );
    }

    final newStatus = await Permission.camera.request();
    if (newStatus.isGranted) return true;
    if (newStatus.isPermanentlyDenied && context.mounted) {
      await _showPermanentlyDeniedDialog(context, isGallery: false);
    }
    return false;
  }

  static Future<void> _showRationaleDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('موافق'),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> _showPermanentlyDeniedDialog(
    BuildContext context, {
    required bool isGallery,
  }) async {
    final title = isGallery ? 'الوصول إلى المعرض' : 'الوصول إلى الكاميرا';
    final message = isGallery
        ? 'تم رفض الإذن. يرجى تفعيل الوصول إلى الصور من إعدادات التطبيق.'
        : 'تم رفض الإذن. يرجى تفعيل الوصول إلى الكاميرا من إعدادات التطبيق.';

    if (!context.mounted) return;
    final open = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('فتح الإعدادات'),
            ),
          ],
        ),
      ),
    );
    if (open == true) {
      await openAppSettings();
    }
  }
}
