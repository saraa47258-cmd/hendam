// lib/app/nav_shell.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show ValueListenable, ValueNotifier;

import '../features/home/presentation/home_screen.dart';
import '../features/orders/presentation/my_orders_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/cart/presentation/cart_screen.dart';
import '../core/state/cart_scope.dart';

class NavShell extends StatefulWidget {
  const NavShell({super.key});
  @override
  State<NavShell> createState() => _NavShellState();
}

class _NavShellState extends State<NavShell> with TickerProviderStateMixin {
  int _index = 0;

  final ValueNotifier<int> _cartCount = ValueNotifier<int>(0);

  final List<GlobalKey<NavigatorState>> _navKeys =
      List.generate(4, (_) => GlobalKey<NavigatorState>());

  // ScrollController لكل تبويب (للـ scroll-to-top)
  final List<ScrollController> _tabScrollCtrls =
      List.generate(4, (_) => ScrollController());

  // Animation controllers for each tab
  late List<AnimationController> _animControllers;
  late List<Animation<double>> _scaleAnimations;

  late final List<_TabSpec> _tabs = [
    _TabSpec(
      label: 'الرئيسية',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      color: const Color(0xFF3B82F6),
      navigator: _TabNavigator(
        navKey: _navKeys[0],
        routes: {
          '/': (_) => const HomeScreen(),
        },
      ),
    ),
    _TabSpec(
      label: 'الطلبات',
      icon: Icons.receipt_long_outlined,
      selectedIcon: Icons.receipt_long_rounded,
      color: const Color(0xFF8B5CF6),
      navigator: _TabNavigator(
        navKey: _navKeys[1],
        routes: {'/': (_) => const MyOrdersScreen()},
      ),
    ),
    _TabSpec(
      label: 'السلة',
      icon: Icons.shopping_bag_outlined,
      selectedIcon: Icons.shopping_bag_rounded,
      color: const Color(0xFF10B981),
      navigator: _TabNavigator(
        navKey: _navKeys[2],
        routes: {'/': (_) => const CartScreen()},
      ),
      badgeListenable: _cartCount,
    ),
    _TabSpec(
      label: 'الملف',
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
      color: const Color(0xFFF59E0B),
      navigator: _TabNavigator(
        navKey: _navKeys[3],
        routes: {'/': (_) => const ProfileScreen()},
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animControllers = List.generate(
      4,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
      ),
    );
    _scaleAnimations = _animControllers.map((c) {
      return Tween<double>(begin: 1.0, end: 1.15).animate(
        CurvedAnimation(parent: c, curve: Curves.easeOutBack),
      );
    }).toList();

    // تشغيل أنيميشن التبويب الأول
    _animControllers[0].forward();
  }

  @override
  void dispose() {
    for (final c in _tabScrollCtrls) {
      c.dispose();
    }
    for (final c in _animControllers) {
      c.dispose();
    }
    _cartCount.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    final nav = _navKeys[_index].currentState;
    if (nav != null && nav.canPop()) {
      nav.pop();
      return false;
    }
    if (_index != 0) {
      setState(() => _index = 0);
      return false;
    }
    return true;
  }

  void _onTabTap(int i) async {
    HapticFeedback.selectionClick();
    if (_index == i) {
      // رجوع لأول صفحة + تمرير لأعلى
      _navKeys[i].currentState?.popUntil((r) => r.isFirst);
      final c = _tabScrollCtrls[i];
      if (c.hasClients) {
        await c.animateTo(
          0,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
        );
      }
    } else {
      // إيقاف الأنيميشن القديم وتشغيل الجديد
      _animControllers[_index].reverse();
      _animControllers[i].forward();
      setState(() => _index = i);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // تحديث عدد عناصر السلة تلقائياً
    final cartState = CartScope.of(context);
    _cartCount.value = cartState.count;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          extendBody: true,
          backgroundColor: cs.surface,
          body: IndexedStack(
            index: _index,
            children: List.generate(_tabs.length, (i) {
              return PrimaryScrollController(
                controller: _tabScrollCtrls[i],
                child: _tabs[i].navigator,
              );
            }),
          ),
          bottomNavigationBar: _PremiumBottomNav(
            tabs: _tabs,
            currentIndex: _index,
            animControllers: _animControllers,
            scaleAnimations: _scaleAnimations,
            cartCount: _cartCount,
            onTap: _onTabTap,
          ),
        ),
      ),
    );
  }
}

// شريط التنقل السفلي الاحترافي
class _PremiumBottomNav extends StatelessWidget {
  final List<_TabSpec> tabs;
  final int currentIndex;
  final List<AnimationController> animControllers;
  final List<Animation<double>> scaleAnimations;
  final ValueNotifier<int> cartCount;
  final Function(int) onTap;

  const _PremiumBottomNav({
    required this.tabs,
    required this.currentIndex,
    required this.animControllers,
    required this.scaleAnimations,
    required this.cartCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      margin: const EdgeInsets.only(
        left: 12,
        right: 12,
        bottom: 4,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 30,
            offset: const Offset(0, 10),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: cs.primary.withOpacity(0.08),
            blurRadius: 50,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 75,
            decoration: BoxDecoration(
              color: cs.surface.withOpacity(0.85),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: cs.outlineVariant.withOpacity(0.15),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(tabs.length, (i) {
                final tab = tabs[i];
                final isSelected = i == currentIndex;
                final badge = tab.badgeListenable;

                return Expanded(
                  child: _NavItem(
                    tab: tab,
                    isSelected: isSelected,
                    scaleAnimation: scaleAnimations[i],
                    badge: badge,
                    onTap: () => onTap(i),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

// عنصر التنقل الواحد
class _NavItem extends StatelessWidget {
  final _TabSpec tab;
  final bool isSelected;
  final Animation<double> scaleAnimation;
  final ValueListenable<int>? badge;
  final VoidCallback onTap;

  const _NavItem({
    required this.tab,
    required this.isSelected,
    required this.scaleAnimation,
    required this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: scaleAnimation,
        builder: (context, child) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // الأيقونة مع المؤشر
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  // خلفية متدرجة للأيقونة المختارة
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    width: isSelected ? 50 : 40,
                    height: isSelected ? 32 : 28,
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                tab.color.withOpacity(0.2),
                                tab.color.withOpacity(0.05),
                              ],
                            )
                          : null,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  // الأيقونة
                  Transform.scale(
                    scale: scaleAnimation.value,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        isSelected ? tab.selectedIcon : tab.icon,
                        key: ValueKey(isSelected),
                        size: isSelected ? 26 : 24,
                        color: isSelected ? tab.color : cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                  // شارة العدد
                  if (badge != null)
                    ValueListenableBuilder<int>(
                      valueListenable: badge!,
                      builder: (context, count, _) {
                        if (count <= 0) return const SizedBox.shrink();
                        return Positioned(
                          top: -4,
                          right: -8,
                          child: _AnimatedBadge(count: count, color: tab.color),
                        );
                      },
                    ),
                ],
              ),
              const SizedBox(height: 4),
              // النص
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: isSelected ? 11 : 10,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? tab.color : cs.onSurfaceVariant,
                  letterSpacing: 0.2,
                ),
                child: Text(tab.label),
              ),
              // المؤشر السفلي
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                margin: const EdgeInsets.only(top: 4),
                width: isSelected ? 20 : 0,
                height: 3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [tab.color, tab.color.withOpacity(0.5)],
                  ),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: tab.color.withOpacity(0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/* ======================= نماذج داخلية ======================= */

class _TabSpec {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final Color color;
  final Widget navigator;
  final ValueListenable<int>? badgeListenable;
  _TabSpec({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.color,
    required this.navigator,
    this.badgeListenable,
  });
}

class _TabNavigator extends StatelessWidget {
  final GlobalKey<NavigatorState> navKey;
  final Map<String, WidgetBuilder> routes;
  const _TabNavigator({
    required this.navKey,
    required this.routes,
  });

  static const String _initial = '/';

  @override
  Widget build(BuildContext context) {
    final WidgetBuilder homeBuilder =
        routes[_initial] ?? routes['/'] ?? ((_) => const SizedBox.shrink());

    return Navigator(
      key: navKey,
      pages: [
        MaterialPage(
          child: homeBuilder(context),
          name: _initial,
        ),
      ],
      onPopPage: (route, result) {
        if (!route.didPop(result)) return false;
        return true;
      },
      onGenerateRoute: (settings) {
        final name = settings.name ?? _initial;
        final builder = routes[name] ?? routes['/'];
        return MaterialPageRoute(
            builder: (builder ?? homeBuilder), settings: settings);
      },
    );
  }
}

// شارة متحركة احترافية
class _AnimatedBadge extends StatelessWidget {
  final int count;
  final Color color;
  const _AnimatedBadge({required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFEF4444),
              const Color(0xFFDC2626),
            ],
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFEF4444).withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        constraints: const BoxConstraints(minWidth: 18),
        child: Text(
          count > 99 ? '99+' : '$count',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            height: 1.1,
          ),
        ),
      ),
    );
  }
}
