// lib/app/nav_shell.dart
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

class _NavShellState extends State<NavShell> {
  int _index = 0;

  final ValueNotifier<int> _cartCount = ValueNotifier<int>(0);
  final ValueNotifier<int> _zeroBadge = ValueNotifier<int>(0);

  final List<GlobalKey<NavigatorState>> _navKeys =
      List.generate(4, (_) => GlobalKey<NavigatorState>());

  // ScrollController لكل تبويب (للـ scroll-to-top)
  final List<ScrollController> _tabScrollCtrls =
      List.generate(4, (_) => ScrollController());

  late final List<_TabSpec> _tabs = [
    _TabSpec(
      label: 'الرئيسية',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
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
      navigator: _TabNavigator(
        navKey: _navKeys[1],
        routes: {'/': (_) => const MyOrdersScreen()},
      ),
    ),
    _TabSpec(
      label: 'السلة',
      icon: Icons.shopping_bag_outlined,
      selectedIcon: Icons.shopping_bag_rounded,
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
      navigator: _TabNavigator(
        navKey: _navKeys[3],
        routes: {'/': (_) => const ProfileScreen()},
      ),
    ),
  ];

  @override
  void dispose() {
    for (final c in _tabScrollCtrls) {
      c.dispose();
    }
    _cartCount.dispose();
    _zeroBadge.dispose();
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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // تحديث عدد عناصر السلة تلقائياً
    final cartState = CartScope.of(context);
    _cartCount.value = cartState.count;

    final destinations = _tabs.map((t) {
      final listenable = t.badgeListenable ?? _zeroBadge;
      return ValueListenableBuilder<int>(
        valueListenable: listenable,
        builder: (context, badge, _) => NavigationDestination(
          icon: _IconWithBadge(icon: t.icon, badge: badge),
          selectedIcon: _IconWithBadge(
              icon: t.selectedIcon, badge: badge, selected: true),
          label: t.label,
        ),
      );
    }).toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          // ✅ خله افتراضيًا false عشان ما يتمدّد المحتوى خلف الشريط
          extendBody: false,
          backgroundColor: cs.surface,

          // ✅ بدون أي Padding سفلي إضافي
          body: IndexedStack(
            index: _index,
            children: List.generate(_tabs.length, (i) {
              return PrimaryScrollController(
                controller: _tabScrollCtrls[i],
                child: _tabs[i].navigator,
              );
            }),
          ),

          bottomNavigationBar: SafeArea(
            top: false,
            child: NavigationBarTheme(
              data: NavigationBarThemeData(
                height: 64, // 👈 اختياري لتقليل الارتفاع (يمكن تغييره/حذفه)
                backgroundColor: cs.surface,
                indicatorColor: cs.primary.withOpacity(.12),
                labelTextStyle: WidgetStateProperty.resolveWith((states) {
                  final selected = states.contains(WidgetState.selected);
                  return TextStyle(
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  );
                }),
              ),
              child: NavigationBar(
                selectedIndex: _index,
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                destinations: destinations,
                onDestinationSelected: (i) async {
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
                    setState(() => _index = i);
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/* ======================= نماذج داخلية ======================= */

class _TabSpec {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final Widget navigator;
  final ValueListenable<int>? badgeListenable;
  _TabSpec({
    required this.label,
    required this.icon,
    required this.selectedIcon,
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

class _IconWithBadge extends StatelessWidget {
  final IconData icon;
  final int badge;
  final bool selected;
  const _IconWithBadge(
      {required this.icon, this.badge = 0, this.selected = false});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = selected ? cs.primary : cs.onSurface;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon, size: selected ? 26 : 24, color: color),
        if (badge > 0)
          PositionedDirectional(end: -6, top: -6, child: _Badge(count: badge)),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final int count;
  const _Badge({required this.count});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: cs.primary,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(color: cs.primary.withOpacity(.28), blurRadius: 10)
        ],
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            height: 1),
      ),
    );
  }
}
