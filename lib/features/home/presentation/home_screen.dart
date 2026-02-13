
// lib/features/home/presentation/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:hindam/l10n/app_localizations.dart';

// صفحات الأقسام
import '../../catalog/presentation/men_services_screen.dart';
import '../../catalog/presentation/small_merchant_screen.dart';
import '../../shops/presentation/abaya_shops_screen.dart';

import '../../orders/presentation/last_order_card.dart';
import '../../orders/presentation/order_details_screen.dart';
import '../../tailors/presentation/nearby_tailors_pretty.dart';
import '../../tailors/models/tailor_item.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Premium Design System Constants
// ═══════════════════════════════════════════════════════════════════════════

class _Spacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

class _Radius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
}

// ═══════════════════════════════════════════════════════════════════════════
// HomeScreen
// ═══════════════════════════════════════════════════════════════════════════

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selected = 'none';

  List<TailorItem> _getDemoTailors(AppLocalizations l10n) => [
    TailorItem(
      name: l10n.tailorElegance,
      rating: 4.9,
      distanceKm: 0.8,
      isOpen: true,
      tags: [l10n.fastDelivery, l10n.menDishdasha],
    ),
    TailorItem(
      name: l10n.eliteCenter,
      rating: 4.6,
      distanceKm: 1.2,
      isOpen: false,
      tags: [l10n.omaniEmbroidery, l10n.homeMeasurement],
    ),
    TailorItem(
      name: l10n.fashionTouch,
      rating: 4.5,
      distanceKm: 1.9,
      isOpen: true,
      tags: [l10n.abayas, l10n.fineTailoring],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    // Premium background with subtle tint
    final bgColor = Color.lerp(cs.surface, cs.primary, 0.02) ?? cs.surface;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: _Spacing.lg),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: _Spacing.lg),

                    // ═══ Premium Header ═══
                    const _PremiumHeader(),
                    const SizedBox(height: _Spacing.xl),

                    // ═══ Premium Search ═══
                    const _PremiumSearchBar(),
                    const SizedBox(height: _Spacing.xl),

                    // ═══ Promo Banner ═══
                    const _PremiumPromoBanner(),
                    const SizedBox(height: _Spacing.xxl),

                    // ═══ Categories Section ═══
                    _PremiumSectionHeader(title: AppLocalizations.of(context)!.categories),
                    const SizedBox(height: _Spacing.lg),
                    _PremiumCategoriesGrid(
                      selected: _selected,
                      onTap: (id) {
                        HapticFeedback.lightImpact();
                        setState(() => _selected = id);

                        late final Widget screen;
                        switch (id) {
                          case 'men':
                            screen = const MenServicesScreen();
                            break;
                          case 'abaya':
                            screen = const AbayaShopsScreen();
                            break;
                          case 'merchants':
                          default:
                            screen = const SmallMerchantScreen();
                        }
                        Navigator.of(context).push(
                          CupertinoPageRoute(builder: (_) => screen),
                        );
                      },
                    ),
                    const SizedBox(height: _Spacing.xl),

                    // ═══ Last Order ═══
                    LastOrderCard(
                      orderCode: '#A-1024',
                      statusText: AppLocalizations.of(context)!.inProgress,
                      onTrack: () {
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (_) =>
                                const OrderDetailsScreen(orderId: 'A-1024'),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: _Spacing.xxl),

                    // ═══ Nearby Tailors ═══
                    _PremiumSectionHeader(
                      title: AppLocalizations.of(context)!.nearbyTailors,
                      actionText: AppLocalizations.of(context)!.viewAll,
                      onAction: () {},
                    ),
                    const SizedBox(height: _Spacing.lg),
                    NearbyTailorsPretty(
                      items: _getDemoTailors(l10n).take(3).toList(),
                      onTapCard: (t) {},
                      onCall: (t) {},
                      onMap: (t) {},
                    ),
                    const SizedBox(height: _Spacing.xxl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Premium Header
// ═══════════════════════════════════════════════════════════════════════════

class _PremiumHeader extends StatelessWidget {
  const _PremiumHeader();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Row(
      children: [
        // Avatar with subtle gradient
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                cs.primary,
                cs.primary.withOpacity(0.8),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: cs.primary.withOpacity(0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.person_rounded,
            size: 24,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: _Spacing.md),

        // Greeting
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.hello,
                style: tt.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant.withOpacity(0.8),
                  fontSize: 13,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                AppLocalizations.of(context)!.dearCustomer,
                style: tt.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                  color: cs.onSurface,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),

        // Notification button
        _PremiumIconButton(
          icon: Icons.notifications_outlined,
          badge: 3,
          onTap: () {},
        ),
        const SizedBox(width: _Spacing.sm),

        // Favorites button
        _PremiumIconButton(
          icon: Icons.favorite_outline_rounded,
          onTap: () => context.push('/favorites'),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Premium Icon Button
// ═══════════════════════════════════════════════════════════════════════════

class _PremiumIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final int? badge;

  const _PremiumIconButton({
    required this.icon,
    required this.onTap,
    this.badge,
  });

  @override
  State<_PremiumIconButton> createState() => _PremiumIconButtonState();
}

class _PremiumIconButtonState extends State<_PremiumIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.92).animate(
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

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: Stack(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withOpacity(0.6),
                borderRadius: BorderRadius.circular(_Radius.md),
                border: Border.all(
                  color: cs.outlineVariant.withOpacity(0.3),
                  width: 0.5,
                ),
              ),
              child: Icon(
                widget.icon,
                size: 20,
                color: cs.onSurfaceVariant,
              ),
            ),
            if (widget.badge != null && widget.badge! > 0)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: cs.error,
                    shape: BoxShape.circle,
                    border: Border.all(color: cs.surface, width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      '${widget.badge}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
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

// ═══════════════════════════════════════════════════════════════════════════
// Premium Search Bar
// ═══════════════════════════════════════════════════════════════════════════

class _PremiumSearchBar extends StatelessWidget {
  const _PremiumSearchBar();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(_Radius.lg),
        border: Border.all(
          color: cs.outlineVariant.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: _Spacing.lg),
          Icon(
            Icons.search_rounded,
            size: 20,
            color: cs.onSurfaceVariant.withOpacity(0.6),
          ),
          const SizedBox(width: _Spacing.md),
          Expanded(
            child: TextField(
              style: tt.bodyMedium?.copyWith(
                fontSize: 15,
                color: cs.onSurface,
              ),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.searchTailorOrService,
                hintStyle: tt.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant.withOpacity(0.5),
                  fontSize: 15,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(
              horizontal: _Spacing.sm,
              vertical: _Spacing.sm,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: _Spacing.md,
              vertical: _Spacing.sm,
            ),
            decoration: BoxDecoration(
              color: cs.primary,
              borderRadius: BorderRadius.circular(_Radius.sm),
            ),
            child: const Icon(
              Icons.tune_rounded,
              size: 18,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Premium Section Header
// ═══════════════════════════════════════════════════════════════════════════

class _PremiumSectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onAction;

  const _PremiumSectionHeader({
    required this.title,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: tt.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: cs.onSurface,
            letterSpacing: -0.3,
          ),
        ),
        if (actionText != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionText!,
              style: tt.bodySmall?.copyWith(
                color: cs.primary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Premium Promo Banner
// ═══════════════════════════════════════════════════════════════════════════

class _PremiumPromoBanner extends StatefulWidget {
  const _PremiumPromoBanner();

  @override
  State<_PremiumPromoBanner> createState() => _PremiumPromoBannerState();
}

class _PremiumPromoBannerState extends State<_PremiumPromoBanner> {
  final PageController _controller = PageController();
  int _current = 0;

  List<_PromoItem> _getPromos(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      _PromoItem(
        title: l10n.discount40,
        subtitle: l10n.onAllMensTailoring,
        badge: l10n.limitedOffer,
        gradient: const [Color(0xFF667EEA), Color(0xFF764BA2)],
      ),
      _PromoItem(
        title: l10n.freeDelivery,
        subtitle: l10n.forOrdersAbove50,
        badge: l10n.newLabel,
        gradient: const [Color(0xFF11998E), Color(0xFF38EF7D)],
      ),
      _PromoItem(
        title: l10n.eidThobe,
        subtitle: l10n.exclusiveCollection,
        badge: l10n.exclusive,
        gradient: const [Color(0xFFFC466B), Color(0xFF3F5EFB)],
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      final next = (_current + 1) % 3;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      _startAutoScroll();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final promos = _getPromos(context);

    return Column(
      children: [
        SizedBox(
          height: 140,
          child: PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _current = i),
            itemCount: promos.length,
            itemBuilder: (context, i) => _PromoBannerCard(promo: promos[i]),
          ),
        ),
        const SizedBox(height: _Spacing.md),

        // Minimal indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(promos.length, (i) {
            final active = i == _current;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: active
                    ? promos[_current].gradient[0]
                    : cs.onSurfaceVariant.withOpacity(0.2),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _PromoItem {
  final String title;
  final String subtitle;
  final String? badge;
  final List<Color> gradient;

  const _PromoItem({
    required this.title,
    required this.subtitle,
    this.badge,
    required this.gradient,
  });
}

class _PromoBannerCard extends StatelessWidget {
  final _PromoItem promo;

  const _PromoBannerCard({required this.promo});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_Radius.xl),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: promo.gradient,
        ),
        boxShadow: [
          BoxShadow(
            color: promo.gradient[0].withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -25,
            left: 20,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(_Spacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (promo.badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: _Spacing.sm,
                      vertical: _Spacing.xs,
                    ),
                    margin: const EdgeInsets.only(bottom: _Spacing.sm),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(_Radius.sm),
                    ),
                    child: Text(
                      promo.badge!,
                      style: tt.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
                Text(
                  promo.title,
                  style: tt.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 26,
                    height: 1.1,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: _Spacing.xs),
                Text(
                  promo.subtitle,
                  style: tt.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Premium Categories Grid
// ═══════════════════════════════════════════════════════════════════════════

class _PremiumCategoriesGrid extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onTap;

  const _PremiumCategoriesGrid({
    required this.selected,
    required this.onTap,
  });

  static const _iconPath = 'assets/icon/';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final categories = [
      _CategoryData(
        id: 'men',
        label: l10n.menTailor,
        svg: '${_iconPath}omani_icon_traced.svg',
        fallback: Icons.person,
        color: const Color(0xFF0EA5E9),
      ),
      _CategoryData(
        id: 'abaya',
        label: l10n.abayas,
        svg: '${_iconPath}abaya_icon_traced.svg',
        fallback: Icons.woman,
        color: const Color(0xFFE11D48),
      ),
      _CategoryData(
        id: 'merchants',
        label: l10n.merchants,
        svg: '${_iconPath}store-svgrepo-com.svg',
        fallback: Icons.store,
        color: const Color(0xFFF59E0B),
        tint: false,
      ),
      _CategoryData(
        id: 'more',
        label: l10n.more,
        svg: '${_iconPath}grid-circles-svgrepo-com.svg',
        fallback: Icons.apps_rounded,
        color: const Color(0xFF8B5CF6),
      ),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: categories.map((cat) {
        return _PremiumCategoryItem(
          data: cat,
          isSelected: selected == cat.id,
          onTap: () => onTap(cat.id),
        );
      }).toList(),
    );
  }
}

class _CategoryData {
  final String id;
  final String label;
  final String svg;
  final IconData fallback;
  final Color color;
  final bool tint;

  const _CategoryData({
    required this.id,
    required this.label,
    required this.svg,
    required this.fallback,
    required this.color,
    this.tint = true,
  });
}

class _PremiumCategoryItem extends StatefulWidget {
  final _CategoryData data;
  final bool isSelected;
  final VoidCallback onTap;

  const _PremiumCategoryItem({
    required this.data,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_PremiumCategoryItem> createState() => _PremiumCategoryItemState();
}

class _PremiumCategoryItemState extends State<_PremiumCategoryItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.9).animate(
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
    final tt = Theme.of(context).textTheme;

    final iconColor = widget.isSelected
        ? widget.data.color
        : cs.onSurfaceVariant.withOpacity(0.7);

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: widget.isSelected
                    ? widget.data.color.withOpacity(0.12)
                    : cs.surfaceContainerHighest.withOpacity(0.6),
                borderRadius: BorderRadius.circular(_Radius.lg),
                border: Border.all(
                  color: widget.isSelected
                      ? widget.data.color.withOpacity(0.4)
                      : cs.outlineVariant.withOpacity(0.2),
                  width: widget.isSelected ? 1.5 : 0.5,
                ),
                boxShadow: widget.isSelected
                    ? [
                        BoxShadow(
                          color: widget.data.color.withOpacity(0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: SvgPicture.asset(
                  widget.data.svg,
                  width: 28,
                  height: 28,
                  colorFilter: widget.data.tint
                      ? ColorFilter.mode(iconColor, BlendMode.srcIn)
                      : null,
                  placeholderBuilder: (_) => Icon(
                    widget.data.fallback,
                    size: 28,
                    color: iconColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: _Spacing.sm),
            SizedBox(
              width: 72,
              child: Text(
                widget.data.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: tt.labelSmall?.copyWith(
                  fontSize: 11,
                  fontWeight:
                      widget.isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: widget.isSelected
                      ? widget.data.color
                      : cs.onSurfaceVariant.withOpacity(0.8),
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
