// lib/features/catalog/presentation/abaya_services_screen.dart
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/abaya_item.dart';
import '../services/abaya_service.dart';
import 'product_preview_screen.dart';
import '../../favorites/services/favorite_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/state/cart_scope.dart';
import '../../../shared/widgets/any_image.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Design System
// ═══════════════════════════════════════════════════════════════════════════

class _DS {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;

  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXxl = 24;
  static const double radiusPill = 999;

  static const Color primaryBrown = Color(0xFF8B7355);
  static const Color darkText = Color(0xFF1F2937);
  static const Color mediumText = Color(0xFF6B7280);
  static const Color lightText = Color(0xFF9CA3AF);
  static const Color background = Color(0xFFFBFBFB);
  static const Color cardBg = Colors.white;
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderLight = Color(0xFFF3F4F6);
}

enum _SortMode { popular, priceLow, priceHigh, newest, titleAZ }

// ═══════════════════════════════════════════════════════════════════════════
// Main Screen
// ═══════════════════════════════════════════════════════════════════════════

class AbayaServicesScreen extends StatefulWidget {
  final String? shopName;
  final String? traderId;
  const AbayaServicesScreen({super.key, this.shopName, this.traderId});

  @override
  State<AbayaServicesScreen> createState() => _AbayaServicesScreenState();
}

class _AbayaServicesScreenState extends State<AbayaServicesScreen> {
  static const _chips = ['الكل', 'عبايات', 'أقمشة', 'أطقم', 'إكسسوارات'];
  int _selectedChip = 1;

  final _abayaService = AbayaService();
  List<AbayaItem> _items = [];
  List<AbayaItem> _shown = [];

  double _minPrice = 0.0, _maxPrice = 100.0;
  late RangeValues _priceRange;
  final bool _onlyNew = false;
  final Set<Color> _selectedColors = {};
  final _SortMode _sort = _SortMode.popular;
  bool _isLoading = true;
  StreamSubscription<List<AbayaItem>>? _subscription;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _priceRange = RangeValues(_minPrice, _maxPrice);
    _loadData();
  }

  void _loadData() {
    final stream = widget.traderId != null && widget.traderId!.isNotEmpty
        ? _abayaService.getAbayaProducts(traderId: widget.traderId)
        : _abayaService.getAbayaProductsSimple();

    _subscription = stream.listen(
      (items) {
        if (mounted) {
          setState(() {
            _items = items;
            _isLoading = false;
            _bootstrapFilters(_items);
            _applyFiltersAndSort();
          });
        }
      },
      onError: (error) {
        if (mounted) setState(() => _isLoading = false);
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _bootstrapFilters(List<AbayaItem> items) {
    if (items.isEmpty) {
      _minPrice = 0.0;
      _maxPrice = 100.0;
      _priceRange = RangeValues(_minPrice, _maxPrice);
      return;
    }
    _minPrice = items.map((e) => e.price).reduce(math.min);
    _maxPrice = items.map((e) => e.price).reduce(math.max);
    _priceRange = RangeValues(_minPrice, _maxPrice);
  }

  void _applyFiltersAndSort() {
    List<AbayaItem> list = List.of(_items);
    if (_items.isNotEmpty) {
      list = list
          .where(
              (i) => i.price >= _priceRange.start && i.price <= _priceRange.end)
          .toList();
    }
    if (_onlyNew) list = list.where((i) => i.isNew).toList();
    if (_selectedColors.isNotEmpty) {
      list = list
          .where((i) => i.colors
              .any((c) => _selectedColors.any((sc) => sc.value == c.value)))
          .toList();
    }
    list.sort((a, b) {
      switch (_sort) {
        case _SortMode.priceLow:
          return a.price.compareTo(b.price);
        case _SortMode.priceHigh:
          return b.price.compareTo(a.price);
        case _SortMode.newest:
          final ai = a.isNew ? 0 : 1;
          final bi = b.isNew ? 0 : 1;
          final cmp = ai.compareTo(bi);
          return cmp != 0 ? cmp : a.price.compareTo(b.price);
        case _SortMode.titleAZ:
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        case _SortMode.popular:
          return 0;
      }
    });
    setState(() => _shown = list);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _DS.background,
      body: _isLoading ? _buildLoading() : _buildContent(),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(_DS.primaryBrown),
        strokeWidth: 2,
      ),
    );
  }

  Widget _buildContent() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        // Premium Header
        SliverToBoxAdapter(
          child: _PremiumHeader(
            onBack: () => Navigator.maybePop(context),
            onSearch: () {},
          ),
        ),

        // Category Chips
        SliverToBoxAdapter(
          child: _CategoryChipsBar(
            chips: _chips,
            selectedIndex: _selectedChip,
            onSelected: (i) => setState(() => _selectedChip = i),
          ),
        ),

        // Title Section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(_DS.xl, _DS.xxl, _DS.xl, _DS.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'العبايات',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: _DS.darkText,
                    letterSpacing: -0.5,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: _DS.xs),
                Text(
                  '${_shown.length} منتج متاح',
                  style: const TextStyle(
                    fontSize: 14,
                    color: _DS.mediumText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Segmented Tabs
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(_DS.xl, _DS.lg, _DS.xl, _DS.lg),
            child: _SegmentedTabs(
              labels: const ['نموذج', 'منتج'],
              selectedIndex: _selectedTab,
              onSelected: (i) => setState(() => _selectedTab = i),
            ),
          ),
        ),

        // Products List
        if (_shown.isEmpty)
          SliverFillRemaining(child: _buildEmptyState())
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(_DS.lg, 0, _DS.lg, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final item = _shown[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: _DS.md),
                    child: _PremiumProductCard(
                      item: item,
                      heroTag: 'abaya-${item.id}',
                      onTap: () => _navigateToProduct(item),
                    ),
                  );
                },
                childCount: _shown.length,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _DS.border.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              size: 36,
              color: _DS.mediumText,
            ),
          ),
          const SizedBox(height: _DS.lg),
          const Text(
            'لا توجد منتجات متاحة',
            style: TextStyle(
              color: _DS.darkText,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: _DS.sm),
          const Text(
            'جرب تغيير الفئة أو البحث',
            style: TextStyle(
              color: _DS.mediumText,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToProduct(AbayaItem item) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (_, __, ___) => ProductPreviewScreen(productId: item.id),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.03),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              )),
              child: child,
            ),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Premium Header
// ═══════════════════════════════════════════════════════════════════════════

class _PremiumHeader extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onSearch;

  const _PremiumHeader({
    required this.onBack,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(_DS.lg, _DS.md, _DS.lg, _DS.sm),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _HeaderIconButton(
              icon: Icons.arrow_back_rounded,
              onTap: onBack,
            ),
            _HeaderIconButton(
              icon: Icons.search_rounded,
              onTap: onSearch,
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
  });

  @override
  State<_HeaderIconButton> createState() => _HeaderIconButtonState();
}

class _HeaderIconButtonState extends State<_HeaderIconButton>
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
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _DS.cardBg,
            shape: BoxShape.circle,
            border: Border.all(color: _DS.border.withOpacity(0.6), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(widget.icon, size: 20, color: _DS.darkText),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Category Chips Bar
// ═══════════════════════════════════════════════════════════════════════════

class _CategoryChipsBar extends StatelessWidget {
  final List<String> chips;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _CategoryChipsBar({
    required this.chips,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: _DS.lg),
        physics: const BouncingScrollPhysics(),
        itemCount: chips.length,
        itemBuilder: (context, i) {
          final isSelected = i == selectedIndex;
          return Padding(
            padding: EdgeInsets.only(left: i < chips.length - 1 ? _DS.sm : 0),
            child: _AnimatedChip(
              label: chips[i],
              isSelected: isSelected,
              onTap: () => onSelected(i),
            ),
          );
        },
      ),
    );
  }
}

class _AnimatedChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _AnimatedChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_AnimatedChip> createState() => _AnimatedChipState();
}

class _AnimatedChipState extends State<_AnimatedChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 80),
      vsync: this,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(
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
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding:
              const EdgeInsets.symmetric(horizontal: _DS.xl, vertical: _DS.md),
          decoration: BoxDecoration(
            color: widget.isSelected ? _DS.primaryBrown : _DS.cardBg,
            borderRadius: BorderRadius.circular(_DS.radiusPill),
            border: Border.all(
              color: widget.isSelected
                  ? _DS.primaryBrown
                  : _DS.border.withOpacity(0.6),
              width: 1,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: _DS.primaryBrown.withOpacity(0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
              color: widget.isSelected ? Colors.white : _DS.mediumText,
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Segmented Tabs
// ═══════════════════════════════════════════════════════════════════════════

class _SegmentedTabs extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _SegmentedTabs({
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _DS.borderLight,
        borderRadius: BorderRadius.circular(_DS.radiusLg),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = (constraints.maxWidth - 8) / labels.length;
          return Stack(
            children: [
              // Animated selection indicator
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                left: selectedIndex * tabWidth,
                top: 0,
                bottom: 0,
                width: tabWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: _DS.cardBg,
                    borderRadius: BorderRadius.circular(_DS.radiusMd),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              // Tab labels
              Row(
                children: List.generate(labels.length, (i) {
                  final isSelected = i == selectedIndex;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        onSelected(i);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected ? _DS.darkText : _DS.mediumText,
                          ),
                          child: Text(labels[i]),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Premium Product Card
// ═══════════════════════════════════════════════════════════════════════════

class _PremiumProductCard extends StatefulWidget {
  final AbayaItem item;
  final String heroTag;
  final VoidCallback onTap;

  const _PremiumProductCard({
    required this.item,
    required this.heroTag,
    required this.onTap,
  });

  @override
  State<_PremiumProductCard> createState() => _PremiumProductCardState();
}

class _PremiumProductCardState extends State<_PremiumProductCard>
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
    _scale = Tween<double>(begin: 1.0, end: 0.98).animate(
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
    final item = widget.item;

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
        child: Container(
          padding: const EdgeInsets.all(_DS.lg),
          decoration: BoxDecoration(
            color: _DS.cardBg,
            borderRadius: BorderRadius.circular(_DS.radiusXxl),
            border: Border.all(color: _DS.border.withOpacity(0.4), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Overflow Menu (leftmost in RTL)
              GestureDetector(
                onTap: () => _showOptionsMenu(context),
                behavior: HitTestBehavior.opaque,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: _DS.xs),
                  child: Icon(
                    Icons.more_vert_rounded,
                    size: 18,
                    color: _DS.lightText,
                  ),
                ),
              ),

              // Image Thumbnail
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(_DS.radiusLg),
                  border:
                      Border.all(color: _DS.border.withOpacity(0.3), width: 1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(_DS.radiusLg - 1),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag: widget.heroTag,
                        child: AnyImage(
                          src: item.imageUrl,
                          fit: BoxFit.cover,
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      if (item.isNew)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _DS.primaryBrown,
                              borderRadius: BorderRadius.circular(_DS.radiusSm),
                            ),
                            child: const Text(
                              'جديد',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: _DS.lg),

              // Content (Title + Colors)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _DS.darkText,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: _DS.sm),
                    if (item.colors.isNotEmpty)
                      SizedBox(
                        height: 16,
                        child: Row(
                          children: [
                            ...item.colors.take(7).map((color) {
                              final isLight = color.computeLuminance() > 0.7;
                              return Container(
                                width: 14,
                                height: 14,
                                margin: const EdgeInsets.only(left: 4),
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isLight
                                        ? _DS.border
                                        : Colors.transparent,
                                    width: 1,
                                  ),
                                ),
                              );
                            }),
                            if (item.colors.length > 7)
                              Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: Text(
                                  '+${item.colors.length - 7}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: _DS.mediumText,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: _DS.md),

              // Actions Column
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _FavButton(item: item),
                  const SizedBox(height: _DS.sm),
                  _AddToCartButton(item: item),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOptionsMenu(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(_DS.radiusXxl)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: _DS.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: _DS.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: _DS.xl),
              ListTile(
                leading: const Icon(Icons.share_outlined, color: _DS.darkText),
                title: const Text('مشاركة'),
                onTap: () => Navigator.pop(ctx),
              ),
              ListTile(
                leading: const Icon(Icons.info_outline, color: _DS.darkText),
                title: const Text('تفاصيل المنتج'),
                onTap: () {
                  Navigator.pop(ctx);
                  widget.onTap();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Add to Cart Button
// ═══════════════════════════════════════════════════════════════════════════

class _AddToCartButton extends StatefulWidget {
  final AbayaItem item;
  const _AddToCartButton({required this.item});

  @override
  State<_AddToCartButton> createState() => _AddToCartButtonState();
}

class _AddToCartButtonState extends State<_AddToCartButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 80),
      vsync: this,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.88).animate(
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
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        _addToCart(context);
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _DS.primaryBrown,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _DS.primaryBrown.withOpacity(0.35),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
        ),
      ),
    );
  }

  void _addToCart(BuildContext context) {
    HapticFeedback.mediumImpact();
    try {
      final cartState = CartScope.of(context);
      cartState.addAbayaItem(
        id: widget.item.id,
        title: widget.item.title,
        price: widget.item.price,
        imageUrl: widget.item.imageUrl,
        subtitle: widget.item.subtitle,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: Colors.white, size: 20),
              const SizedBox(width: _DS.sm),
              Expanded(
                child: Text(
                  'تمت إضافة ${widget.item.title} إلى السلة',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF10B981),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_DS.radiusMd),
          ),
          margin: const EdgeInsets.all(_DS.lg),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Favorite Button
// ═══════════════════════════════════════════════════════════════════════════

class _FavButton extends StatefulWidget {
  final AbayaItem item;
  const _FavButton({required this.item});

  @override
  State<_FavButton> createState() => _FavButtonState();
}

class _FavButtonState extends State<_FavButton>
    with SingleTickerProviderStateMixin {
  final _favoriteService = FavoriteService();
  bool _isLoading = false;
  bool _isFavorite = false;
  bool _isInitialized = false;

  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scale = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _checkFavoriteStatus();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkFavoriteStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) {
      if (mounted) setState(() => _isInitialized = true);
      return;
    }
    try {
      final isFav = await _favoriteService.isFavorite(
        productId: widget.item.id,
        productType: 'abaya',
      );
      if (mounted) {
        setState(() {
          _isFavorite = isFav;
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isInitialized = true);
    }
  }

  Future<void> _toggleFavorite() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى تسجيل الدخول أولاً')),
      );
      return;
    }

    if (_isLoading) return;
    setState(() => _isLoading = true);

    await _controller.forward();
    await _controller.reverse();

    HapticFeedback.lightImpact();

    try {
      if (_isFavorite) {
        final removed = await _favoriteService.removeFromFavorites(
          productId: widget.item.id,
          productType: 'abaya',
        );
        if (mounted && removed) setState(() => _isFavorite = false);
      } else {
        final added = await _favoriteService.addToFavorites(
          productId: widget.item.id,
          productType: 'abaya',
          productData: {
            'name': widget.item.title,
            'subtitle': widget.item.subtitle,
            'imageUrl': widget.item.imageUrl,
            'gallery': widget.item.gallery,
            'price': widget.item.price,
            'colors': widget.item.colors.map((c) => c.value).toList(),
            'isNew': widget.item.isNew,
            'type': 'عباية',
          },
        );
        if (mounted && added) setState(() => _isFavorite = true);
      }
    } catch (e) {
      // Silent error
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          color: _DS.borderLight,
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: _toggleFavorite,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: _DS.borderLight,
            shape: BoxShape.circle,
          ),
          child: _isLoading
              ? const Center(
                  child: SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : Icon(
                  _isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_outline_rounded,
                  size: 18,
                  color: _isFavorite ? Colors.red : _DS.mediumText,
                ),
        ),
      ),
    );
  }
}
