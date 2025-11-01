import 'package:flutter/widgets.dart';

class Breakpoints {
  static const double phone = 600; // < 600 = موبايل
  static const double tablet = 1024; // 600..1024 = تابلت
  static const double desktop = 1200; // > 1200 = ديسكتوب
  static const double largeDesktop = 1440; // > 1440 = شاشة كبيرة
}

extension ResponsiveX on BuildContext {
  Size get _size => MediaQuery.sizeOf(this);
  double get w => _size.width;
  double get h => _size.height;
  double get safeAreaTop => MediaQuery.paddingOf(this).top;
  double get safeAreaBottom => MediaQuery.paddingOf(this).bottom;
  double get devicePixelRatio => MediaQuery.devicePixelRatioOf(this);
  bool get isLandscape =>
      MediaQuery.orientationOf(this) == Orientation.landscape;

  bool get isPhone => w < Breakpoints.phone;
  bool get isTablet => w >= Breakpoints.phone && w < Breakpoints.tablet;
  bool get isDesktop =>
      w >= Breakpoints.desktop && w < Breakpoints.largeDesktop;
  bool get isLargeDesktop => w >= Breakpoints.largeDesktop;
  bool get isMobile => isPhone;
  bool get isTabletOrDesktop => isTablet || isDesktop;

  /// قيمة متجاوبة: phone, tablet, desktop, largeDesktop
  T pick<T>(T phone, {T? tablet, T? desktop, T? largeDesktop}) {
    if (isLargeDesktop) return (largeDesktop ?? desktop ?? tablet ?? phone);
    if (isDesktop) return (desktop ?? tablet ?? phone);
    if (isTablet) return (tablet ?? phone);
    return phone;
  }

  /// احسب عدد الأعمدة تلقائيًا حسب عرض الشاشة
  int gridColumns({double minTileWidth = 300, int max = 6}) {
    final cols = (w / minTileWidth).floor();
    return cols.clamp(1, max);
  }

  /// احسب المساحات المتجاوبة
  double responsivePadding() =>
      pick(16.0, tablet: 24.0, desktop: 32.0, largeDesktop: 40.0);
  double responsiveSpacing() =>
      pick(12.0, tablet: 16.0, desktop: 20.0, largeDesktop: 24.0);
  double responsiveRadius() =>
      pick(12.0, tablet: 16.0, desktop: 20.0, largeDesktop: 24.0);
  double responsiveMargin() =>
      pick(8.0, tablet: 12.0, desktop: 16.0, largeDesktop: 20.0);

  /// احسب أحجام النصوص المتجاوبة
  double responsiveFontSize(double baseSize) {
    return pick(
      baseSize,
      tablet: baseSize * 1.1,
      desktop: baseSize * 1.2,
      largeDesktop: baseSize * 1.3,
    );
  }

  /// احسب أبعاد الأزرار المتجاوبة
  double buttonHeight() =>
      pick(44.0, tablet: 48.0, desktop: 52.0, largeDesktop: 56.0);
  double iconSize() =>
      pick(20.0, tablet: 24.0, desktop: 28.0, largeDesktop: 32.0);
  double smallIconSize() =>
      pick(16.0, tablet: 18.0, desktop: 20.0, largeDesktop: 22.0);

  /// احسب أبعاد الصور المتجاوبة
  double productImageSize() =>
      pick(80.0, tablet: 100.0, desktop: 120.0, largeDesktop: 140.0);
  double avatarSize() =>
      pick(40.0, tablet: 48.0, desktop: 56.0, largeDesktop: 64.0);
  double cardImageHeight() =>
      pick(120.0, tablet: 140.0, desktop: 160.0, largeDesktop: 180.0);

  /// احسب أبعاد الحاويات المتجاوبة
  double maxContentWidth() =>
      pick(w, tablet: 800.0, desktop: 1200.0, largeDesktop: 1400.0);
  double sidebarWidth() =>
      pick(0.0, tablet: 0.0, desktop: 280.0, largeDesktop: 320.0);

  /// احسب عدد الأعمدة في الشبكات
  int responsiveGridColumns({double itemWidth = 300.0}) {
    if (isMobile) return 1;
    if (isTablet) return (w / itemWidth).floor().clamp(2, 3);
    if (isDesktop) return (w / itemWidth).floor().clamp(3, 4);
    return (w / itemWidth).floor().clamp(4, 6);
  }
}
