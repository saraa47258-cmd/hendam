// lib/features/home/presentation/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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
    return RepaintBoundary(
      child: _HeaderGreetingContent(),
    );
  }
}

class _HeaderGreetingContent extends StatelessWidget {
  const _HeaderGreetingContent();

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
    return RepaintBoundary(
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
    return RepaintBoundary(
      child: _PromoBannerContent(),
    );
  }
}

class _PromoBannerContent extends StatelessWidget {
  const _PromoBannerContent();

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
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: context.responsiveFontSize(20.0),
            ),
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
    widget.onTap();
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
