// lib/core/error/error_handler.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class ErrorHandler {
  static void handleError(dynamic error, StackTrace? stackTrace, {String? context}) {
    if (kDebugMode) {
      print('خطأ في $context: $error');
      if (stackTrace != null) {
        print('Stack trace: $stackTrace');
      }
    }
    
    // يمكن إضافة تسجيل الأخطاء هنا (Firebase Crashlytics, Sentry, etc.)
  }

  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        action: SnackBarAction(
          label: 'إغلاق',
          textColor: Theme.of(context).colorScheme.onError,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  static Widget buildErrorWidget(String message, {VoidCallback? onRetry}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'حدث خطأ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static Widget buildLoadingWidget({String? message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message),
          ],
        ],
      ),
    );
  }
}

// فئة للأخطاء المخصصة
class AppError implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  AppError(this.message, {this.code, this.originalError});

  @override
  String toString() => 'AppError: $message';
}

// أنواع الأخطاء المختلفة
class NetworkError extends AppError {
  NetworkError(super.message, {super.originalError})
      : super(code: 'NETWORK_ERROR');
}

class ValidationError extends AppError {
  ValidationError(super.message, {super.originalError})
      : super(code: 'VALIDATION_ERROR');
}

class AuthError extends AppError {
  AuthError(super.message, {super.originalError})
      : super(code: 'AUTH_ERROR');
}
