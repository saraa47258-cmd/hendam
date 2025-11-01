import 'package:flutter/material.dart';
import 'responsive.dart';

class AppDimens {
  static late double w, h, dp;
  static late EdgeInsets safeArea;
  static late BuildContext context;

  static void init(BuildContext ctx) {
    context = ctx;
    final mq = MediaQuery.of(ctx);
    w = mq.size.width;
    h = mq.size.height;
    dp = mq.devicePixelRatio;
    safeArea = mq.padding;
  }

  // دوال مساعدة للحصول على القيم المتجاوبة
  static bool get isPhone => context.isPhone;
  static bool get isTablet => context.isTablet;
  static bool get isDesktop => context.isDesktop;
  static bool get isLargeDesktop => context.isLargeDesktop;

  // مساحات متجاوبة - استخدام النظام المحسن
  static double get horizontalPadding => context.responsivePadding();
  static double get verticalPadding => context.responsiveSpacing();
  static double get cardSpacing => context.responsiveSpacing();
  static double get margin => context.responsiveMargin();

  // أحجام متجاوبة
  static double get cardRadius => context.responsiveRadius();
  static double get buttonHeight => context.buttonHeight();
  static double get iconSize => context.iconSize();
  static double get smallIconSize => context.smallIconSize();

  // أبعاد الشبكات
  static int get gridColumns => context.responsiveGridColumns();
  static double get gridSpacing => context.responsiveSpacing();

  // أبعاد الصور
  static double get productImageSize => context.productImageSize();
  static double get avatarSize => context.avatarSize();
  static double get cardImageHeight => context.cardImageHeight();

  // مساحات النصوص
  static double get textSpacing => context.responsiveSpacing();
  static double get lineHeight => isPhone
      ? 1.4
      : isTablet
          ? 1.5
          : 1.6;

  // أحجام الخطوط المتجاوبة
  static double responsiveFontSize(double baseSize) =>
      context.responsiveFontSize(baseSize);

  // مساحة آمنة للشاشات الكبيرة
  static double get maxContentWidth => context.maxContentWidth();
  static double get sidebarWidth => context.sidebarWidth();

  // دوال مساعدة للـ spacing
  static double gap([double v = 12]) => v;
  static double spacing([double multiplier = 1.0]) =>
      context.responsiveSpacing() * multiplier;

  // نصف القطر الافتراضي
  static double get radius => cardRadius;
}
