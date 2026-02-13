// lib/core/utils/photo_permission_helper.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hindam/l10n/app_localizations.dart';
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
      final l10n = AppLocalizations.of(context)!;
      await _showRationaleDialog(
        context,
        title: l10n.galleryPermissionRequired,
        message: l10n.galleryAccessNeeded,
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
      final l10n = AppLocalizations.of(context)!;
      await _showRationaleDialog(
        context,
        title: l10n.cameraPermissionRequired,
        message: l10n.cameraAccessNeeded,
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
    final l10n = AppLocalizations.of(context)!;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }

  static Future<void> _showPermanentlyDeniedDialog(
    BuildContext context, {
    required bool isGallery,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final title = isGallery ? l10n.galleryPermissionRequired : l10n.cameraPermissionRequired;
    final message = isGallery
        ? l10n.permissionDenied
        : l10n.permissionDenied;

    if (!context.mounted) return;
    final open = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.openSettings),
          ),
        ],
      ),
    );
    if (open == true) {
      await openAppSettings();
    }
  }
}
