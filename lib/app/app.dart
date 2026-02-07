import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:hindam/app/router.dart';
import 'package:hindam/app/theme.dart' as theme;
import 'package:hindam/core/state/cart_scope.dart' as cart;
import 'package:hindam/core/styles/dimens.dart';
import 'package:hindam/core/providers/locale_provider.dart';
import 'package:hindam/features/auth/providers/auth_provider.dart';
import 'package:hindam/l10n/app_localizations.dart';

class HendamApp extends StatelessWidget {
  const HendamApp({super.key});

  @override
  Widget build(BuildContext context) {
    final cartState = cart.CartState();

    // تحميل البيانات المحفوظة بشكل آمن
    WidgetsBinding.instance.addPostFrameCallback((_) {
      cartState.loadData();
    });

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final authProvider = AuthProvider();
            // تهيئة AuthProvider بعد تأكيد تهيئة Firebase
            WidgetsBinding.instance.addPostFrameCallback((_) {
              authProvider.initialize();
            });
            return authProvider;
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            final localeProvider = LocaleProvider();
            // تهيئة LocaleProvider
            WidgetsBinding.instance.addPostFrameCallback((_) {
              localeProvider.initialize();
            });
            return localeProvider;
          },
        ),
      ],
      child: cart.CartScope(
        state: cartState,
        child: Consumer<LocaleProvider>(
          builder: (context, localeProvider, _) {
            return MaterialApp.router(
              title: 'HINDAM',
              debugShowCheckedModeBanner: false,

              theme: theme.AppTheme.light,
              darkTheme: theme.AppTheme.dark,
              themeMode: ThemeMode.system,

              // استخدام اللغة من المزود
              locale: localeProvider.locale ?? const Locale('ar'),
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,

              // تحسينات متجاوبة مع تحسين الأداء
              builder: (context, child) {
                // تهيئة الأبعاد بشكل آمن
                try {
                  AppDimens.init(context);
                } catch (e) {
                  debugPrint('Error initializing AppDimens: $e');
                }

                final mq = MediaQuery.of(context);
                return MediaQuery(
                  // منع تضخيم النص المفرط
                  data: mq.copyWith(
                    textScaler: mq.textScaler
                        .clamp(maxScaleFactor: 1.2), // تقليل من 1.3 إلى 1.2
                    // إضافة padding آمن للشاشات الكبيرة
                    padding: EdgeInsets.symmetric(
                      horizontal: mq.size.width > 1200
                          ? 24.0
                          : mq.padding.horizontal, // تقليل من 32 إلى 24
                      vertical: mq.padding.vertical,
                    ),
                  ),
                  child: child ?? const SizedBox.shrink(),
                );
              },

              // ✅ هنا توصيل الراوتر
              routerConfig: appRouter,
            );
          },
        ),
      ),
    );
  }
}
