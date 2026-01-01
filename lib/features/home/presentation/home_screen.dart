// lib/features/home/presentation/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

// صفحات الأقسام
import '../../catalog/presentation/men_services_screen.dart';
import '../../catalog/presentation/small_merchant_screen.dart';
import '../../shops/presentation/abaya_shops_screen.dart';

import '../../orders/presentation/last_order_card.dart';
import '../../orders/presentation/order_details_screen.dart';
import '../../tailors/presentation/nearby_tailors_pretty.dart';
import '../../tailors/models/tailor_item.dart';

// مكونات متجاوبة
import '../../../core/widgets/responsive_widgets.dart';
import '../../../core/styles/responsive.dart';
import '../../../core/styles/dimens.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selected = 'none'; // none | men | abaya | merchants

  // بيانات ديمو للخياطين (بدّلها لاحقًا بفايربيس)
  static const List<TailorItem> _demoTailorsPretty = [
    TailorItem(
      name: 'خياط الأناقة',
      rating: 4.9,
      distanceKm: 0.8,
      isOpen: true,
      tags: ['تسليم سريع', 'دشداشة رجالي'],
    ),
    TailorItem(
      name: 'مركز النخبة',
      rating: 4.6,
      distanceKm: 1.2,
      isOpen: false,
      tags: ['تطريز عُماني', 'قياس منزلي'],
    ),
    TailorItem(
      name: 'لمسة فاشن',
      rating: 4.5,
      distanceKm: 1.9,
      isOpen: true,
      tags: ['عبايات', 'خياطة ناعمة'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // تهيئة الأبعاد المتجاوبة
    AppDimens.init(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: cs.surface,
        body: SafeArea(
          child: ResponsiveContainer(
            padding: EdgeInsets.symmetric(
              horizontal: context.responsivePadding(),
              vertical: context.responsiveSpacing(),
            ),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _HeaderGreeting(),
                      SizedBox(height: context.responsiveSpacing()),
                      const _SearchAndFilter(),
                      SizedBox(height: context.responsiveSpacing()),
                      const _PromoBanner(),
                      SizedBox(height: context.responsiveSpacing() * 1.5),

                      // ===== الأقسام =====
                      const _SectionHeader(title: 'الأقسام'),
                      SizedBox(height: context.responsiveSpacing()),
                      _CategoriesBar(
                        selected: _selected,
                        onTapMain: (id) {
                          setState(() => _selected = id);

                          late final Widget screen;
                          switch (id) {
                            case 'men':
                              screen = const MenServicesScreen();
                              break;
                            case 'abaya':
                              screen =
                                  const AbayaShopsScreen(); // افتح شاشة المحلات أولاً
                              break;
                            case 'merchants':
                            default:
                              screen = const SmallMerchantScreen();
                          }
                          Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (_) => screen,
                              fullscreenDialog: false,
                            ),
                          );
                        },
                        onTapOptional: (label) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('خيار قادم لاحقًا: $label'),
                              duration: const Duration(milliseconds: 900),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 12),

                      // ===== آخر طلب =====
                      LastOrderCard(
                        orderCode: '#A-1024',
                        statusText: 'جارٍ التفصيل',
                        onTrack: () {
                          // افتح شاشة تتبّع الطلب
                          Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (context) =>
                                  const OrderDetailsScreen(orderId: 'A-1024'),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 18),

                      // ===== خياطون بالقرب منك =====
                      const _SectionHeader(title: 'خياطون بالقرب منك'),
                      const SizedBox(height: 10),
                      // تحسين الأداء - تقليل عدد العناصر المعروضة
                      NearbyTailorsPretty(
                        items: _demoTailorsPretty
                            .take(3)
                            .toList(), // عرض 3 فقط بدلاً من كل العناصر
                        onTapCard: (t) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('فتح تفاصيل: ${t.name}'),
                              duration: const Duration(
                                  milliseconds: 800), // تقليل مدة العرض
                            ),
                          );
                        },
                        onCall: (t) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('الاتصال بـ ${t.name}'),
                              duration: const Duration(milliseconds: 800),
                            ),
                          );
                        },
                        onMap: (t) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('فتح الخرائط إلى ${t.name}'),
                              duration: const Duration(milliseconds: 800),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 18),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* ========================= Header ========================= */
class _HeaderGreeting extends StatelessWidget {
  const _HeaderGreeting();

  @override
  Widget build(BuildContext context) {
    return const RepaintBoundary(
      child: _HeaderGreetingContent(),
    );
  }
}

class _HeaderGreetingContent extends StatelessWidget {
  const _HeaderGreetingContent();

  // تحية حسب الوقت
  String _getTimeGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'صباح الخير';
    } else if (hour >= 12 && hour < 17) {
      return 'مساء الخير';
    } else if (hour >= 17 && hour < 21) {
      return 'مساء النور';
    } else {
      return 'أهلاً بك';
    }
  }

  // أيقونة حسب الوقت
  String _getTimeEmoji() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return '☀️';
    } else if (hour >= 12 && hour < 17) {
      return '🌤️';
    } else if (hour >= 17 && hour < 21) {
      return '🌅';
    } else {
      return '🌙';
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    final avatarSize = context.pick(52.0, tablet: 58.0, desktop: 64.0);
    final iconSize = context.pick(26.0, tablet: 28.0, desktop: 30.0);
    final titleSize = context.responsiveFontSize(20.0);
    final subtitleSize = context.responsiveFontSize(13.0);

    return Container(
      padding: EdgeInsets.all(context.responsiveSpacing()),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            cs.primaryContainer.withOpacity(0.15),
            cs.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: cs.outlineVariant.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // أفاتار احترافي مع حلقة متدرجة
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  cs.primary,
                  cs.tertiary,
                  cs.secondary,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: cs.primary.withOpacity(0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cs.surface,
                border: Border.all(color: cs.surface, width: 2),
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      cs.primary.withOpacity(0.9),
                      cs.primary.withOpacity(0.6),
                    ],
                  ),
                ),
                child: Icon(
                  Icons.person_rounded,
                  size: iconSize,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(width: context.responsiveSpacing() * 1.4),
          // النص
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // تحية الوقت
                Row(
                  children: [
                    Text(
                      _getTimeGreeting(),
                      style: tt.bodyMedium?.copyWith(
                        color: cs.primary,
                        fontSize: subtitleSize,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _getTimeEmoji(),
                      style: TextStyle(fontSize: subtitleSize + 2),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // اسم المستخدم
                Text(
                  'عميلنا العزيز',
                  style: tt.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: titleSize,
                    color: cs.onSurface,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          // الأزرار
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PremiumIconButton(
                icon: Icons.favorite_border_rounded,
                activeIcon: Icons.favorite_rounded,
                onTap: () => context.push('/favorites'),
                primaryColor: const Color(0xFFE91E63),
              ),
              const SizedBox(width: 10),
              _PremiumIconButton(
                icon: Icons.notifications_none_rounded,
                activeIcon: Icons.notifications_rounded,
                onTap: () {},
                badge: 3,
                primaryColor: cs.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// زر أيقونة احترافي محسّن
class _PremiumIconButton extends StatefulWidget {
  final IconData icon;
  final IconData? activeIcon;
  final VoidCallback onTap;
  final int? badge;
  final Color? primaryColor;

  const _PremiumIconButton({
    required this.icon,
    this.activeIcon,
    required this.onTap,
    this.badge,
    this.primaryColor,
  });

  @override
  State<_PremiumIconButton> createState() => _PremiumIconButtonState();
}

class _PremiumIconButtonState extends State<_PremiumIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final size = context.pick(46.0, tablet: 50.0, desktop: 54.0);
    final iconSize = context.pick(22.0, tablet: 24.0, desktop: 26.0);
    final color = widget.primaryColor ?? cs.primary;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: (_) {
          setState(() => _isPressed = true);
          _controller.forward();
        },
        onTapUp: (_) {
          setState(() => _isPressed = false);
          _controller.reverse();
          widget.onTap();
        },
        onTapCancel: () {
          setState(() => _isPressed = false);
          _controller.reverse();
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: _isPressed
                    ? color.withOpacity(0.15)
                    : cs.surfaceContainerHighest.withOpacity(0.6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isPressed
                      ? color.withOpacity(0.4)
                      : cs.outlineVariant.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: _isPressed
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Icon(
                _isPressed ? (widget.activeIcon ?? widget.icon) : widget.icon,
                size: iconSize,
                color: _isPressed ? color : cs.onSurfaceVariant,
              ),
            ),
            // شارة الإشعارات
            if (widget.badge != null && widget.badge! > 0)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFEF4444),
                        const Color(0xFFDC2626),
                      ],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(color: cs.surface, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFEF4444).withOpacity(0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                  child: Text(
                    widget.badge! > 9 ? '9+' : '${widget.badge}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/* ====================== Search & Filter ==================== */
class _SearchAndFilter extends StatelessWidget {
  const _SearchAndFilter();

  @override
  Widget build(BuildContext context) {
    return const RepaintBoundary(
      child: _SearchAndFilterContent(),
    );
  }
}

class _SearchAndFilterContent extends StatelessWidget {
  const _SearchAndFilterContent();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final buttonSize = context.buttonHeight();
    final borderRadius = context.responsiveRadius();
    final fontSize = context.responsiveFontSize(14.0);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius + 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: cs.outlineVariant.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'ابحث عن خدمة (دشداشة، عباية، تعديل)',
                  hintStyle: tt.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant.withOpacity(0.6),
                    fontSize: fontSize,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      Icons.search_rounded,
                      size: context.iconSize(),
                      color: cs.primary,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: context.responsiveSpacing() * 1.2,
                    horizontal: context.responsivePadding(),
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
          ),
          SizedBox(width: context.responsiveSpacing()),
          Container(
            height: buttonSize,
            width: buttonSize,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  cs.primary,
                  cs.primary.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: [
                BoxShadow(
                  color: cs.primary.withOpacity(0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(borderRadius),
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(borderRadius),
                child: Icon(
                  Icons.tune_rounded,
                  color: Colors.white,
                  size: context.iconSize(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ======================= Promo Banner Carousel ====================== */
class _PromoBanner extends StatelessWidget {
  const _PromoBanner();

  @override
  Widget build(BuildContext context) {
    return const RepaintBoundary(
      child: _PromoBannerCarousel(),
    );
  }
}

// نموذج بيانات الإعلان
class _PromoData {
  final String title;
  final String subtitle;
  final String buttonText;
  final IconData icon;
  final List<Color> gradientColors;
  final String? badge;

  const _PromoData({
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.icon,
    required this.gradientColors,
    this.badge,
  });
}

class _PromoBannerCarousel extends StatefulWidget {
  const _PromoBannerCarousel();

  @override
  State<_PromoBannerCarousel> createState() => _PromoBannerCarouselState();
}

class _PromoBannerCarouselState extends State<_PromoBannerCarousel> {
  final PageController _pageController = PageController(viewportFraction: 1.0);
  int _currentPage = 0;

  // الإعلانات الافتراضية
  static const List<_PromoData> _promos = [
    _PromoData(
      title: 'خصم 40%',
      subtitle: 'على جميع خدمات التفصيل الرجالي',
      buttonText: 'اطلب الآن',
      icon: Icons.content_cut_rounded,
      gradientColors: [Color(0xFF667EEA), Color(0xFF764BA2)],
      badge: '🔥 عرض محدود',
    ),
    _PromoData(
      title: 'توصيل مجاني',
      subtitle: 'للطلبات فوق 50 ريال عُماني',
      buttonText: 'تسوق الآن',
      icon: Icons.local_shipping_rounded,
      gradientColors: [Color(0xFF11998E), Color(0xFF38EF7D)],
      badge: '🚚 جديد',
    ),
    _PromoData(
      title: 'دشداشة العيد',
      subtitle: 'تشكيلة حصرية بأجود الأقمشة',
      buttonText: 'اكتشف المزيد',
      icon: Icons.diamond_rounded,
      gradientColors: [Color(0xFFFC466B), Color(0xFF3F5EFB)],
      badge: '✨ حصري',
    ),
    _PromoData(
      title: 'عباية أنيقة',
      subtitle: 'تصاميم عصرية بلمسة عُمانية',
      buttonText: 'تصفح الآن',
      icon: Icons.auto_awesome,
      gradientColors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    // تغيير تلقائي كل 4 ثواني
    Future.delayed(const Duration(seconds: 4), _autoScroll);
  }

  void _autoScroll() {
    if (!mounted) return;
    final nextPage = (_currentPage + 1) % _promos.length;
    _pageController.animateToPage(
      nextPage,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    );
    Future.delayed(const Duration(seconds: 4), _autoScroll);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bannerHeight = context.pick(165.0, tablet: 180.0, desktop: 200.0);

    return Column(
      children: [
        SizedBox(
          height: bannerHeight,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: _promos.length,
            itemBuilder: (context, index) {
              return _PromoBannerCard(promo: _promos[index]);
            },
          ),
        ),
        const SizedBox(height: 12),
        // مؤشرات الصفحات
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_promos.length, (index) {
            final isActive = index == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: isActive
                    ? _promos[_currentPage].gradientColors[0]
                    : Colors.grey.withOpacity(0.3),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _PromoBannerCard extends StatelessWidget {
  final _PromoData promo;

  const _PromoBannerCard({required this.promo});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final borderRadius = context.pick(20.0, tablet: 24.0, desktop: 28.0);
    final padding = context.responsivePadding();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: promo.gradientColors,
        ),
        boxShadow: [
          BoxShadow(
            color: promo.gradientColors[0].withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // خلفية زخرفية
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -10,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          // الأيقونة الكبيرة
          Positioned(
            left: 20,
            top: 0,
            bottom: 0,
            child: Center(
              child: Icon(
                promo.icon,
                size: 70,
                color: Colors.white.withOpacity(0.15),
              ),
            ),
          ),
          // المحتوى
          Padding(
            padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding * 0.7),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      // الشارة والعنوان
                      Row(
                        children: [
                          if (promo.badge != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              margin: const EdgeInsets.only(left: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                promo.badge!,
                                style: tt.labelSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                        ],
                      ),
                      // العنوان
                      Text(
                        promo.title,
                        style: tt.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          height: 1.0,
                        ),
                      ),
                      // الوصف
                      Text(
                        promo.subtitle,
                        style: tt.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // الزر
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              promo.buttonText,
                              style: tt.labelSmall?.copyWith(
                                color: promo.gradientColors[0],
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 14,
                              color: promo.gradientColors[0],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // أيقونة صغيرة على اليسار
                Icon(
                  promo.icon,
                  size: 48,
                  color: Colors.white.withOpacity(0.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/* ========================= الأقسام (SVG) ========================= */
class _CategoriesBar extends StatelessWidget {
  final String selected; // none | men | abaya | merchants
  final ValueChanged<String> onTapMain;
  final ValueChanged<String> onTapOptional;

  const _CategoriesBar({
    required this.selected,
    required this.onTapMain,
    required this.onTapOptional,
  });

  static const _iconPath = 'assets/icon/';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // ألوان مخصصة + خيار tint لكل قسم
    final cats = <_Cat>[
      _Cat(
        'men',
        'الخياط الرجالي',
        svg: '${_iconPath}omani_icon_traced.svg',
        fallback: Icons.person,
        baseColor: const Color(0xFF0EA5E9), // سماوي
      ),
      _Cat(
        'abaya',
        'العبايات',
        svg: '${_iconPath}abaya_icon_traced.svg',
        fallback: Icons.woman,
        baseColor: const Color(0xFFE11D48), // وردي أحمر
      ),
      _Cat(
        'merchants',
        'المتاجر',
        svg: '${_iconPath}store-svgrepo-com.svg',
        fallback: Icons.store,
        baseColor: const Color(0xFFF59E0B), // كهرماني
        tint: false, // المتجر ملوّن أصليًا
      ),
      _Cat(
        '_more',
        'المزيد',
        svg: '${_iconPath}grid-circles-svgrepo-com.svg',
        fallback: Icons.more_horiz,
        optional: true,
        baseColor: const Color(0xFF8B5CF6), // بنفسجي
      ),
    ];

    // ✅ عرض جميع الأيقونات في صف واحد مع إمكانية التمرير
    final spacing = context.responsiveSpacing();

    // بناء قائمة الأزرار
    final buttons = cats.asMap().entries.map((entry) {
      final index = entry.key;
      final c = entry.value;
      final isSelected = selected == c.id;

      final iconColor = c.optional
          ? cs.onSurfaceVariant
          : (isSelected ? c.baseColor : cs.onSurfaceVariant);

      final labelColor = c.optional
          ? cs.onSurfaceVariant
          : (isSelected ? c.baseColor : cs.onSurface);

      return RepaintBoundary(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Hero(
              tag: 'category_${c.id}',
              child: Material(
                color: Colors.transparent,
                child: _AnimatedCategoryButton(
                  isSelected: isSelected,
                  baseColor: c.baseColor,
                  iconColor: iconColor,
                  labelColor: labelColor,
                  label: c.label,
                  svg: c.svg,
                  fallback: c.fallback,
                  tint: c.tint,
                  cs: cs,
                  onTap: () =>
                      c.optional ? onTapOptional(c.label) : onTapMain(c.id),
                ),
              ),
            ),
            if (index < cats.length - 1) SizedBox(width: spacing),
          ],
        ),
      );
    }).toList();

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: context.responsiveMargin()),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: buttons,
          ),
        ),
      ),
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  final String svg;
  final Color color;
  final IconData fallback;
  final bool tint; // هل نلوّن الـSVG بلون واحد؟

  const _CategoryIcon({
    required this.svg,
    required this.color,
    required this.fallback,
    this.tint = true, // افتراضيًا نلوّن مثل الأيقونات الأحادية
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = context.pick(26.0, tablet: 28.0, desktop: 30.0);

    return Center(
      child: SvgPicture.asset(
        svg,
        width: iconSize,
        height: iconSize,
        fit: BoxFit.scaleDown,
        colorFilter: tint ? ColorFilter.mode(color, BlendMode.srcIn) : null,
        placeholderBuilder: (_) =>
            Icon(fallback, size: iconSize, color: tint ? color : null),
      ),
    );
  }
}

class _Cat {
  final String id;
  final String label;
  final String svg;
  final bool optional;
  final IconData fallback;
  final Color baseColor; // لون القسم الأساسي
  final bool tint; // هل تُلوَّن أيقونة القسم بلون واحد؟

  _Cat(
    this.id,
    this.label, {
    required this.svg,
    this.optional = false,
    required this.fallback,
    required this.baseColor,
    this.tint = true,
  });
}

/* ===================== Section Header Row ================== */
class _SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onAction;
  const _SectionHeader({required this.title, this.actionText, this.onAction});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return RepaintBoundary(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: cs.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: tt.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: context.responsiveFontSize(20.0),
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
          if (actionText != null)
            TextButton(
              onPressed: onAction,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    actionText!,
                    style: tt.labelLarge?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: cs.primary,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// Widget متحرك لزر القسم مع تصميم iOS
class _AnimatedCategoryButton extends StatefulWidget {
  final bool isSelected;
  final Color baseColor;
  final Color iconColor;
  final Color labelColor;
  final String label;
  final String svg;
  final IconData fallback;
  final bool tint;
  final ColorScheme cs;
  final VoidCallback onTap;

  const _AnimatedCategoryButton({
    required this.isSelected,
    required this.baseColor,
    required this.iconColor,
    required this.labelColor,
    required this.label,
    required this.svg,
    required this.fallback,
    required this.tint,
    required this.cs,
    required this.onTap,
  });

  @override
  State<_AnimatedCategoryButton> createState() =>
      _AnimatedCategoryButtonState();
}

class _AnimatedCategoryButtonState extends State<_AnimatedCategoryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _borderAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _borderAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    if (widget.isSelected) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(_AnimatedCategoryButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  void _handleTap() {
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final size = context.pick(58.0, tablet: 64.0, desktop: 70.0);
    final labelWidth = context.pick(72.0, tablet: 80.0, desktop: 88.0);
    final labelHeight = context.pick(32.0, tablet: 36.0, desktop: 40.0);

    return GestureDetector(
      onTap: _handleTap,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: widget.isSelected
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              widget.baseColor.withOpacity(.14),
                              widget.baseColor.withOpacity(.04),
                            ],
                          )
                        : LinearGradient(
                            colors: [
                              widget.cs.surfaceContainerHighest,
                              widget.cs.secondaryContainer,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.06),
                        blurRadius: 10,
                        offset: const Offset(0, 6),
                      ),
                      if (widget.isSelected)
                        BoxShadow(
                          color: widget.baseColor
                              .withOpacity(.3 * _borderAnimation.value),
                          blurRadius: 12 * _borderAnimation.value,
                          spreadRadius: 2 * _borderAnimation.value,
                        ),
                    ],
                    border: widget.isSelected
                        ? Border.all(
                            color: widget.baseColor,
                            width: 2 * _borderAnimation.value,
                          )
                        : null,
                  ),
                  child: _CategoryIcon(
                    svg: widget.svg,
                    color: widget.iconColor,
                    fallback: widget.fallback,
                    tint: widget.tint,
                  ),
                ),
                SizedBox(height: context.responsiveMargin()),
                SizedBox(
                  width: labelWidth,
                  height: labelHeight,
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontWeight: widget.isSelected
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: widget.labelColor,
                              fontSize: context.responsiveFontSize(12.0),
                            ) ??
                        const TextStyle(),
                    child: Text(
                      widget.label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
