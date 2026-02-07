// lib/app/router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hindam/app/nav_shell.dart';
import 'package:hindam/features/tailors/presentation/tailor_details_screen.dart';
import 'package:hindam/features/tailors/presentation/tailor_store_screen.dart';
import 'package:hindam/features/orders/presentation/order_details_screen.dart';
import 'package:hindam/features/orders/presentation/order_tracking_screen.dart';
import 'package:hindam/features/orders/presentation/customer_orders_screen.dart';
import 'package:hindam/features/catalog/presentation/product_preview_screen.dart';
import 'package:hindam/test_firebase.dart';
import 'package:hindam/features/auth/presentation/auth_welcome_screen.dart';
import 'package:hindam/features/auth/presentation/splash_screen.dart';
import 'package:hindam/features/auth/presentation/login_screen.dart';
import 'package:hindam/features/auth/presentation/signup_screen.dart';
import 'package:hindam/features/auth/presentation/forgot_password_screen.dart';
import 'package:hindam/features/auth/presentation/edit_profile_screen.dart';
import 'package:hindam/features/favorites/presentation/my_favorites_screen.dart';
import 'package:hindam/features/auth/providers/auth_provider.dart';
import 'package:hindam/features/address/presentation/addresses_screen.dart';
import 'package:hindam/features/profile/presentation/screens/settings_screen.dart';
import 'package:hindam/features/profile/presentation/screens/language_screen.dart';
import 'package:hindam/features/profile/presentation/screens/help_support_screen.dart';
import 'package:hindam/features/profile/presentation/screens/about_app_screen.dart';
import 'package:hindam/features/profile/presentation/screens/payment_methods_screen.dart';
import 'package:hindam/features/profile/presentation/screens/privacy_security_screen.dart';
import 'package:provider/provider.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// راوتر متقدم مع إدارة الحالات والتنقل العميق
final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',

  // ═══════════════════════════════════════════════════════════════════════════
  // توجيه ذكي: منع العودة من الرئيسية لتسجيل الدخول
  // ═══════════════════════════════════════════════════════════════════════════
  redirect: (context, state) {
    final authProvider = context.read<AuthProvider>();
    final isAuthenticated = authProvider.isAuthenticated;
    final location = state.matchedLocation;

    // الصفحات التي لا تحتاج حماية (يمكن الوصول إليها دون تسجيل دخول)
    final publicRoutes = [
      '/',
      '/welcome',
      '/login',
      '/signup',
      '/forgot-password'
    ];
    final isPublicRoute = publicRoutes.contains(location);

    // إذا كان المستخدم مسجلاً ويحاول الوصول لصفحات التسجيل/الترحيب
    // → إعادة توجيهه للشاشة الرئيسية
    if (isAuthenticated && isPublicRoute && location != '/') {
      return '/app';
    }

    // لا حاجة لتوجيه
    return null;
  },

  routes: <RouteBase>[
    GoRoute(
      path: '/',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/welcome',
      name: 'welcome',
      builder: (context, state) => const AuthWelcomeScreen(),
    ),

    // صفحة تسجيل الدخول
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),

    // صفحة التسجيل
    GoRoute(
      path: '/signup',
      name: 'signup',
      builder: (context, state) => const SignUpScreen(),
    ),

    // صفحة نسيان كلمة المرور
    GoRoute(
      path: '/forgot-password',
      name: 'forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),

    // صفحة تعديل الملف الشخصي
    GoRoute(
      path: '/edit-profile',
      name: 'edit-profile',
      builder: (context, state) => const EditProfileScreen(),
    ),

    // صفحة المفضلة
    GoRoute(
      path: '/favorites',
      name: 'favorites',
      builder: (context, state) => const MyFavoritesScreen(),
    ),

    // التطبيق الرئيسي
    GoRoute(
      path: '/app',
      name: 'app',
      builder: (BuildContext context, GoRouterState state) {
        return const NavShell();
      },
      routes: [
        // تفاصيل الخياط
        GoRoute(
          path: 'tailor/:id',
          name: 'tailor-details',
          builder: (context, state) {
            final tailorId = state.pathParameters['id']!;
            return TailorDetailsScreen(
              tailorId: tailorId,
              tailorName: state.uri.queryParameters['name'] ?? 'الخياط',
            );
          },
        ),

        // متجر الخياط
        GoRoute(
          path: 'tailor/:id/store',
          name: 'tailor-store',
          builder: (context, state) {
            final tailorId = state.pathParameters['id']!;
            return TailorStoreScreen(
              tailorId: tailorId,
              tailorName: state.uri.queryParameters['name'] ?? 'الخياط',
            );
          },
        ),

        // تفاصيل الطلب
        GoRoute(
          path: 'order/:id',
          name: 'order-details',
          builder: (context, state) {
            final orderId = state.pathParameters['id']!;
            return OrderDetailsScreen(orderId: orderId);
          },
        ),

        // تتبع الطلب
        GoRoute(
          path: 'order/:id/tracking',
          name: 'order-tracking',
          builder: (context, state) {
            final orderId = state.pathParameters['id']!;
            return OrderTrackingScreen(orderId: orderId);
          },
        ),

        // طلبات العميل
        GoRoute(
          path: 'orders',
          name: 'customer-orders',
          builder: (context, state) {
            final authProvider = context.read<AuthProvider>();
            if (!authProvider.isAuthenticated ||
                authProvider.currentUser == null) {
              return const AuthWelcomeScreen();
            }
            final user = authProvider.currentUser!;
            return CustomerOrdersScreen(
              customerId: user.uid,
              customerName: user.name,
            );
          },
        ),

        // معاينة المنتج
        GoRoute(
          path: 'product/:id',
          name: 'product-preview',
          builder: (context, state) {
            final productId = state.pathParameters['id']!;
            return ProductPreviewScreen(productId: productId);
          },
        ),

        GoRoute(
          path: 'addresses',
          name: 'addresses',
          builder: (context, state) => const AddressesScreen(),
        ),

        // صفحات الملف الشخصي
        GoRoute(
          path: 'settings',
          name: 'settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: 'language',
          name: 'language',
          builder: (context, state) => const LanguageScreen(),
        ),
        GoRoute(
          path: 'help-support',
          name: 'help-support',
          builder: (context, state) => const HelpSupportScreen(),
        ),
        GoRoute(
          path: 'about',
          name: 'about',
          builder: (context, state) => const AboutAppScreen(),
        ),
        GoRoute(
          path: 'payment-methods',
          name: 'payment-methods',
          builder: (context, state) => const PaymentMethodsScreen(),
        ),
        GoRoute(
          path: 'privacy-security',
          name: 'privacy-security',
          builder: (context, state) => const PrivacySecurityScreen(),
        ),

        // اختبار Firebase
        GoRoute(
          path: 'test-firebase',
          name: 'test-firebase',
          builder: (context, state) {
            return const FirebaseTestPage();
          },
        ),
      ],
    ),
  ],

  // إدارة الأخطاء
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('خطأ')),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('حدث خطأ في التنقل',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text('الصفحة المطلوبة غير موجودة',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/welcome'),
            child: const Text('العودة للرئيسية'),
          ),
        ],
      ),
    ),
  ),
);
