// lib/app/nav_shell.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show ValueListenable, ValueNotifier;
import 'package:hindam/l10n/app_localizations.dart';

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
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      color: const Color(0xFF0EA5E9), // أزرق سماوي
      navigator: _TabNavigator(
        navKey: _navKeys[0],
        routes: {
          '/': (_) => const HomeScreen(),
        },
      ),
    ),
    _TabSpec(
      icon: Icons.receipt_long_outlined,
      selectedIcon: Icons.receipt_long_rounded,
      color: const Color(0xFF10B981), // أخضر
      navigator: _TabNavigator(
        navKey: _navKeys[1],
        routes: {'/': (_) => const MyOrdersScreen()},
      ),
    ),
    _TabSpec(
      icon: Icons.shopping_bag_outlined,
      selectedIcon: Icons.shopping_bag_rounded,
      color: const Color(0xFFF59E0B), // برتقالي
      navigator: _TabNavigator(
        navKey: _navKeys[2],
        routes: {'/': (_) => const CartScreen()},
      ),
      badgeListenable: _cartCount,
    ),
    _TabSpec(
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
      color: const Color(0xFF8B5CF6), // بنفسجي
      navigator: _TabNavigator(
        navKey: _navKeys[3],
        routes: {'/': (_) => const ProfileScreen()},
      ),
    ),
  ];

  List<String> _getTabLabels(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [l10n.home, l10n.orders, l10n.cart, l10n.profile];
  }

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
    final tabLabels = _getTabLabels(context);

    // تحديث عدد عناصر السلة تلقائياً
    final cartState = CartScope.of(context);
    _cartCount.value = cartState.count;

    final destinations = _tabs.asMap().entries.map((entry) {
      final i = entry.key;
      final t = entry.value;
      final listenable = t.badgeListenable ?? _zeroBadge;
      return ValueListenableBuilder<int>(
        valueListenable: listenable,
        builder: (context, badge, _) => NavigationDestination(
          icon: _IconWithBadge(
            icon: t.icon,
            badge: badge,
            color: t.color,
          ),
          selectedIcon: _IconWithBadge(
            icon: t.selectedIcon,
            badge: badge,
            color: t.color,
            selected: true,
          ),
          label: tabLabels[i],
        ),
      );
    }).toList();

    // Detect if dark mode
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Clean, minimal background colors
    final navBgColor = isDark
        ? const Color(0xFF1C1C1E) // iOS dark mode gray
        : const Color(0xFFFAFAFA); // Very light off-white

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        extendBody: false,
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

        // ═══════════════════════════════════════════════════════════════
        // Clean, Minimal Bottom Navigation Bar
        // ═══════════════════════════════════════════════════════════════
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: navBgColor,
            // Very subtle top border
            border: Border(
              top: BorderSide(
                color: isDark
                    ? Colors.white.withOpacity(0.08)
                    : Colors.black.withOpacity(0.06),
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: NavigationBarTheme(
              data: NavigationBarThemeData(
                height: 56,
                elevation: 0,
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                indicatorColor: cs.primary.withOpacity(0.1),
                indicatorShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                labelTextStyle: WidgetStateProperty.resolveWith((states) {
                  final selected = states.contains(WidgetState.selected);
                  return TextStyle(
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 11,
                    height: 1.2,
                    letterSpacing: 0.1,
                    color: selected
                        ? cs.primary
                        : cs.onSurfaceVariant.withOpacity(0.9),
                  );
                }),
                iconTheme: WidgetStateProperty.resolveWith((states) {
                  final selected = states.contains(WidgetState.selected);
                  return IconThemeData(
                    size: 22,
                    color: selected ? cs.primary : cs.onSurfaceVariant,
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
  final IconData icon;
  final IconData selectedIcon;
  final Color color;
  final Widget navigator;
  final ValueListenable<int>? badgeListenable;
  _TabSpec({
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

class _IconWithBadge extends StatelessWidget {
  final IconData icon;
  final int badge;
  final Color color;
  final bool selected;
  const _IconWithBadge({
    required this.icon,
    required this.color,
    this.badge = 0,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    // الأيقونة ملونة دائماً، لكن أفتح قليلاً عند عدم التحديد
    final iconColor = selected ? color : color.withOpacity(0.5);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon, size: 22, color: iconColor),
        if (badge > 0)
          PositionedDirectional(
            end: -4,
            top: -5,
            child: _Badge(count: badge, color: color),
          ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final int count;
  final Color color;
  const _Badge({required this.count, required this.color});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDoubleDigit = count > 9;
    return Container(
      constraints: BoxConstraints(
        minWidth: isDoubleDigit ? 18 : 16,
        minHeight: 16,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isDoubleDigit ? 5 : 4,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.surface, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.35),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        count > 99 ? '99+' : '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          height: 1.1,
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}
