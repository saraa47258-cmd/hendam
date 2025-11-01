// lib/features/home/presentation/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
            child: SingleChildScrollView(
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
                        MaterialPageRoute(builder: (_) => screen),
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
                        MaterialPageRoute(
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
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    final avatarRadius = context.pick(22.0, tablet: 26.0, desktop: 30.0);
    final iconSize = context.pick(22.0, tablet: 24.0, desktop: 26.0);
    final titleSize = context.responsiveFontSize(18.0);

    return Row(
      children: [
        CircleAvatar(
          radius: avatarRadius,
          backgroundColor: cs.primaryContainer,
          child: Icon(Icons.person, size: iconSize),
        ),
        SizedBox(width: context.responsiveSpacing()),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: tt.titleMedium?.copyWith(
                color: cs.onSurface,
                fontSize: titleSize,
              ),
              children: [
                const TextSpan(text: 'مرحباً، '),
                TextSpan(
                  text: 'عميلنا',
                  style: tt.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: titleSize,
                  ),
                ),
              ],
            ),
          ),
        ),
        IconButton(
            onPressed: () {},
            icon: Icon(Icons.notifications_none, size: context.iconSize()),
            tooltip: 'إشعارات'),
        IconButton(
            onPressed: () {},
            icon: Icon(Icons.settings_outlined, size: context.iconSize()),
            tooltip: 'الإعدادات'),
      ],
    );
  }
}

/* ====================== Search & Filter ==================== */
class _SearchAndFilter extends StatelessWidget {
  const _SearchAndFilter();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final buttonSize = context.buttonHeight();
    final borderRadius = context.responsiveRadius();
    final fontSize = context.responsiveFontSize(14.0);

    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'ابحث عن خدمة (دشداشة، عباية، تعديل)',
              hintStyle: tt.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
                fontSize: fontSize,
              ),
              prefixIcon: Icon(Icons.search, size: context.iconSize()),
              filled: true,
              fillColor: cs.surfaceContainerHighest,
              contentPadding: EdgeInsets.symmetric(
                vertical: context.responsiveSpacing(),
                horizontal: context.responsivePadding(),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: BorderSide(color: cs.outlineVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: BorderSide(color: cs.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: BorderSide(color: cs.primary, width: 1.4),
              ),
            ),
          ),
        ),
        SizedBox(width: context.responsiveSpacing()),
        SizedBox(
          height: buttonSize,
          width: buttonSize,
          child: Material(
            color: cs.primary,
            borderRadius: BorderRadius.circular(borderRadius),
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(borderRadius),
              child: Icon(
                Icons.filter_list_rounded,
                color: Colors.white,
                size: context.iconSize(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/* ======================= Promo Banner ====================== */
class _PromoBanner extends StatelessWidget {
  const _PromoBanner();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final bannerHeight = context.pick(140.0, tablet: 160.0, desktop: 180.0);
    final borderRadius = context.responsiveRadius();
    final titleSize = context.responsiveFontSize(24.0);
    final iconSize = context.pick(56.0, tablet: 64.0, desktop: 72.0);
    final padding = context.responsivePadding();

    return Container(
      height: bannerHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [cs.primaryContainer, cs.tertiaryContainer],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white.withOpacity(.08), Colors.transparent],
                ),
              ),
            ),
          ),
          PositionedDirectional(
            start: padding,
            top: padding,
            child: Text(
              'خصم 40%',
              style: tt.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                fontSize: titleSize,
              ),
            ),
          ),
          Center(child: Icon(Icons.content_cut, size: iconSize)),
          PositionedDirectional(
            end: padding,
            bottom: padding,
            child: _CtaPill(text: 'اطلب الآن', onTap: () {}),
          ),
        ],
      ),
    );
  }
}

class _CtaPill extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _CtaPill({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final borderRadius = context.responsiveRadius();
    final fontSize = context.responsiveFontSize(14.0);
    final padding = EdgeInsets.symmetric(
      horizontal: context.responsivePadding(),
      vertical: context.responsiveSpacing(),
    );

    return Material(
      color: cs.primary,
      borderRadius: BorderRadius.circular(borderRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Padding(
          padding: padding,
          child: Text(
            text,
            style: tt.titleSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: fontSize,
            ),
          ),
        ),
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
        'التجّار',
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

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.responsiveMargin()),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: cats.asMap().entries.map((entry) {
            final index = entry.key;
            final c = entry.value;
            final isSelected = selected == c.id;

            final iconColor = c.optional
                ? cs.onSurfaceVariant
                : (isSelected ? c.baseColor : cs.onSurfaceVariant);

            final labelColor = c.optional
                ? cs.onSurfaceVariant
                : (isSelected ? c.baseColor : cs.onSurface);

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () =>
                      c.optional ? onTapOptional(c.label) : onTapMain(c.id),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: context.pick(58.0, tablet: 64.0, desktop: 70.0),
                        height: context.pick(58.0, tablet: 64.0, desktop: 70.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: isSelected
                              ? LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    c.baseColor.withOpacity(.14),
                                    c.baseColor.withOpacity(.04),
                                  ],
                                )
                              : LinearGradient(
                                  colors: [
                                    cs.surfaceContainerHighest,
                                    cs.secondaryContainer,
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
                          ],
                          border: isSelected
                              ? Border.all(color: c.baseColor, width: 2)
                              : null,
                        ),
                        child: _CategoryIcon(
                          svg: c.svg,
                          color: iconColor,
                          fallback: c.fallback,
                          tint: c.tint,
                        ),
                      ),
                      SizedBox(height: context.responsiveMargin()),
                      SizedBox(
                        width: context.pick(72.0, tablet: 80.0, desktop: 88.0),
                        height: context.pick(32.0, tablet: 36.0, desktop: 40.0),
                        child: Text(
                          c.label,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    fontWeight: isSelected
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    color: labelColor,
                                    fontSize: context.responsiveFontSize(12.0),
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (index < cats.length - 1) SizedBox(width: spacing),
              ],
            );
          }).toList(),
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
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: context.responsiveFontSize(20.0),
          ),
    );
  }
}
