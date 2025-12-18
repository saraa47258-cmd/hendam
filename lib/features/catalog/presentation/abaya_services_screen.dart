// lib/features/catalog/presentation/abaya_services_screen.dart
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/abaya_item.dart';
import '../services/abaya_service.dart';
import 'product_preview_screen.dart';
import '../../favorites/services/favorite_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/state/cart_scope.dart';

// يفضَّل الاستيراد النسبي لتفادي مشاكل اسم الحزمة
import '../../../shared/widgets/any_image.dart';

/* أوضاع الفرز */
enum _SortMode { popular, priceLow, priceHigh, newest, titleAZ }

class AbayaServicesScreen extends StatefulWidget {
  final String? shopName; // اسم المحل (اختياري للعرض كشارة)
  final String? traderId; // معرف التاجر (لجلب منتجات متجر محدد)
  const AbayaServicesScreen({super.key, this.shopName, this.traderId});

  @override
  State<AbayaServicesScreen> createState() => _AbayaServicesScreenState();
}

class _AbayaServicesScreenState extends State<AbayaServicesScreen> {
  static const _chips = ['الكل', 'عبايات', 'أقمشة', 'أطقم', 'إكسسوارات'];
  int _selectedChip = 1;

  // خدمة Firebase
  final _abayaService = AbayaService();

  // البيانات الأصلية + المعروضة (من Firebase)
  List<AbayaItem> _items = [];
  List<AbayaItem> _shown = [];

  // خيارات الفلترة
  double _minPrice = 0.0, _maxPrice = 100.0;
  late RangeValues _priceRange;
  bool _onlyNew = false;
  List<Color> _colorChoices = [];
  final Set<Color> _selectedColors = {};

  // وضع الفرز
  _SortMode _sort = _SortMode.popular;

  // حالة التحميل
  bool _isLoading = true;
  StreamSubscription<List<AbayaItem>>? _subscription;

  // Tabs (من JavaScript)
  String _selectedTab = 'model'; // 'model' or 'product'

  @override
  void initState() {
    super.initState();
    _priceRange = RangeValues(_minPrice, _maxPrice);

    // الاشتراك في stream لجلب البيانات
    // إذا كان هناك traderId محدد، نجلب منتجات ذلك المتجر فقط
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
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        print('خطأ في جلب بيانات العبايات: $error');
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
      _colorChoices = [];
      return;
    }

    _minPrice = items.map((e) => e.price).reduce(math.min);
    _maxPrice = items.map((e) => e.price).reduce(math.max);
    _priceRange = RangeValues(_minPrice, _maxPrice);

    // ألوان فريدة
    final seen = <int>{};
    final all = <Color>[];
    for (final c in items.expand((i) => i.colors)) {
      if (seen.add(c.value)) all.add(c);
    }
    _colorChoices = all;
  }

  void _applyFiltersAndSort() {
    List<AbayaItem> list = List.of(_items);

    // فلترة السعر
    if (_items.isNotEmpty) {
      list = list
          .where(
              (i) => i.price >= _priceRange.start && i.price <= _priceRange.end)
          .toList();
    }

    // جديد فقط
    if (_onlyNew) list = list.where((i) => i.isNew).toList();

    // فلترة ألوان
    if (_selectedColors.isNotEmpty) {
      list = list
          .where((i) => i.colors
              .any((c) => _selectedColors.any((sc) => sc.value == c.value)))
          .toList();
    }

    // الفرز
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

  String _price(double v) =>
      '${v == v.truncateToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2)} ر.ع';

  @override
  Widget build(BuildContext context) {
    // ألوان من JavaScript
    const primaryBrown = Color(0xFF8B7355);
    const darkGray = Color(0xFF1F2937);
    const mediumGray = Color(0xFF6B7280);
    const dividerGray = Color(0xFFE5E7EB);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(primaryBrown),
                ),
              )
            : Stack(
                children: [
                  CustomScrollView(
                    slivers: [
                      // Header
                      SliverToBoxAdapter(
                        child: SafeArea(
                          bottom: false,
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                20, 16, 20, 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  onPressed: () => Navigator.maybePop(context),
                                  icon: const Icon(
                                    Icons.arrow_back,
                                    size: 24,
                                    color: darkGray,
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                                IconButton(
                                  onPressed: () {},
                                  icon: const Icon(
                                    Icons.search,
                                    size: 24,
                                    color: darkGray,
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Category Pills
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 60,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                20, 0, 20, 10),
                            itemCount: _chips.length,
                            itemBuilder: (context, index) {
                              final isSelected = index == _selectedChip;
                              return Padding(
                                padding:
                                    const EdgeInsetsDirectional.only(end: 10),
                                child: _CategoryPill(
                                  label: _chips[index],
                                  isSelected: isSelected,
                                  onTap: () =>
                                      setState(() => _selectedChip = index),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      // Title
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding:
                              EdgeInsetsDirectional.fromSTEB(20, 20, 20, 16),
                          child: Text(
                            'العبايات',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w700,
                              color: primaryBrown,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                      // Tabs
                      SliverToBoxAdapter(
                        child: Container(
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: dividerGray, width: 1),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                20, 0, 20, 0),
                            child: Row(
                              children: [
                                _TabButton(
                                  label: 'نموذج',
                                  isSelected: _selectedTab == 'model',
                                  onTap: () =>
                                      setState(() => _selectedTab = 'model'),
                                ),
                                const SizedBox(width: 32),
                                _TabButton(
                                  label: 'منتج',
                                  isSelected: _selectedTab == 'product',
                                  onTap: () =>
                                      setState(() => _selectedTab = 'product'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Products Grid
                      if (_shown.isEmpty && !_isLoading)
                        const SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.inventory_2_outlined,
                                  size: 64,
                                  color: mediumGray,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'لا توجد منتجات متاحة',
                                  style: TextStyle(
                                    color: mediumGray,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0, 20, 0, 100),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, i) {
                                final item = _shown[i];
                                return Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      16, 0, 16, 12),
                                  child: _AbayaListItem(
                                    item: item,
                                    priceText: _price(item.price),
                                    heroTag: 'abaya-${item.id}',
                                    imageBuilder: (src) => AnyImage(
                                      src: src,
                                      fit: BoxFit.cover,
                                      filterQuality: FilterQuality.medium,
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          transitionDuration:
                                              const Duration(milliseconds: 200),
                                          reverseTransitionDuration:
                                              const Duration(milliseconds: 150),
                                          pageBuilder: (_, __, ___) =>
                                              ProductPreviewScreen(
                                            productId: item.id,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                              childCount: _shown.length,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  // ============ BottomSheet: فلترة (محذوف - غير مستخدم) ============
  // ignore: unused_element
  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;

        // نسخ محلي للتعديل ثم نطبّق عند "تطبيق"
        RangeValues range = _priceRange;
        bool onlyNew = _onlyNew;

        final localSelected = <int>{};
        for (int i = 0; i < _colorChoices.length; i++) {
          if (_selectedColors.any((c) => c.value == _colorChoices[i].value)) {
            localSelected.add(i);
          }
        }

        final priceDiff = _maxPrice - _minPrice;
        final divisions = priceDiff > 0
            ? math.max(1, math.min(100, (priceDiff * 10).round()))
            : 1;

        return StatefulBuilder(
          builder: (ctx, setLocal) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: cs.outlineVariant,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text('الفلترة',
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          color: cs.onSurface)),
                  const SizedBox(height: 16),

                  // السعر
                  Text('نطاق السعر',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, color: cs.onSurface)),
                  const SizedBox(height: 6),
                  RangeSlider(
                    min: _minPrice,
                    max: _maxPrice,
                    divisions: divisions,
                    values: range,
                    labels: RangeLabels(
                      range.start.toStringAsFixed(2),
                      range.end.toStringAsFixed(2),
                    ),
                    onChanged: (v) => setLocal(() => range = v),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _priceChip('من ${range.start.toStringAsFixed(2)}'),
                      _priceChip('إلى ${range.end.toStringAsFixed(2)}'),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // جديد فقط
                  SwitchListTile(
                    value: onlyNew,
                    onChanged: (v) => setLocal(() => onlyNew = v),
                    title: const Text('جديد فقط'),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 8),

                  // الألوان
                  Text('اللون',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, color: cs.onSurface)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: List.generate(_colorChoices.length, (i) {
                      final color = _colorChoices[i];
                      final selected = localSelected.contains(i);
                      return GestureDetector(
                        onTap: () => setLocal(() {
                          if (!localSelected.add(i)) localSelected.remove(i);
                        }),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color:
                                  selected ? cs.onSurface : cs.outlineVariant,
                              width: selected ? 2 : 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                                color: color, shape: BoxShape.circle),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),

                  // أزرار
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _priceRange = RangeValues(_minPrice, _maxPrice);
                              _onlyNew = false;
                              _selectedColors.clear();
                            });
                            _applyFiltersAndSort();
                            Navigator.pop(ctx);
                          },
                          child: const Text('إعادة تعيين'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6D4C41),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _priceRange = range;
                              _onlyNew = onlyNew;
                              _selectedColors
                                ..clear()
                                ..addAll(
                                    localSelected.map((i) => _colorChoices[i]));
                            });
                            _applyFiltersAndSort();
                            Navigator.pop(ctx);
                          },
                          child: const Text('تطبيق'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _priceChip(String t) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(.7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(t,
          style: TextStyle(fontWeight: FontWeight.w700, color: cs.onSurface)),
    );
  }

  // ============ BottomSheet: فرز (محذوف - غير مستخدم) ============
  // ignore: unused_element
  void _openSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;

        Widget tile(String title, _SortMode mode, IconData icon) {
          final selected = _sort == mode;
          return ListTile(
            leading: Icon(icon,
                color:
                    selected ? const Color(0xFF6D4C41) : cs.onSurfaceVariant),
            title: Text(title,
                style: TextStyle(
                    fontWeight: selected ? FontWeight.w900 : FontWeight.w600)),
            trailing: selected ? const Icon(Icons.check_rounded) : null,
            onTap: () {
              setState(() => _sort = mode);
              _applyFiltersAndSort();
              Navigator.pop(ctx);
            },
          );
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.outlineVariant,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 12),
              tile('الأشهر', _SortMode.popular,
                  Icons.local_fire_department_rounded),
              tile('السعر: الأقل فالأعلى', _SortMode.priceLow,
                  Icons.south_rounded),
              tile('السعر: الأعلى فالأقل', _SortMode.priceHigh,
                  Icons.north_rounded),
              tile('الأحدث', _SortMode.newest, Icons.fiber_new_rounded),
              tile('الاسم: أ ⇢ ي', _SortMode.titleAZ,
                  Icons.sort_by_alpha_rounded),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

/* ===================== بقية الويدجتس ===================== */

// Category Pill (من JavaScript)
class _CategoryPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8B7355) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }
}

// Tab Button (من JavaScript)
class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? const Color(0xFF1F2937)
                    : const Color(0xFF9CA3AF),
              ),
            ),
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 12),
                height: 2,
                color: const Color(0xFF1F2937),
              ),
          ],
        ),
      ),
    );
  }
}

// List Item Design (من الصورة)
class _AbayaListItem extends StatefulWidget {
  final AbayaItem item;
  final String priceText;
  final String heroTag;
  final Widget Function(String src) imageBuilder;
  final VoidCallback onTap;

  const _AbayaListItem({
    required this.item,
    required this.priceText,
    required this.heroTag,
    required this.imageBuilder,
    required this.onTap,
  });

  @override
  State<_AbayaListItem> createState() => _AbayaListItemState();
}

class _AbayaListItemState extends State<_AbayaListItem> {
  int _selectedColor = 0;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    const primaryBrown = Color(0xFF8B7355);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // نقاط السحب (من الصورة)
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 8, top: 4),
                child: Column(
                  children: List.generate(
                      3,
                      (i) => Container(
                            width: 4,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.4),
                              shape: BoxShape.circle,
                            ),
                          )),
                ),
              ),
              // الصورة على اليسار
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Hero(
                        tag: widget.heroTag,
                        child: widget.imageBuilder(item.imageUrl),
                      ),
                    ),
                    // شارة "جديد" في الأعلى
                    if (item.isNew)
                      Positioned(
                        top: 4,
                        left: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: primaryBrown,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'جديد',
                            style: TextStyle(
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
              const SizedBox(width: 12),
              // المعلومات في المنتصف
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // اسم المنتج
                    Text(
                      item.title.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // شارات الألوان
                    if (item.colors.isNotEmpty)
                      SizedBox(
                        height: 24,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: item.colors.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 6),
                          itemBuilder: (_, idx) => _ColorSwatch(
                            color: item.colors[idx],
                            selected: idx == _selectedColor,
                            onTap: () => setState(() => _selectedColor = idx),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // زر دائري على اليمين
              Column(
                children: [
                  // أيقونة المفضلة
                  _FavButton(item: item),
                  const SizedBox(height: 8),
                  // زر إضافة للسلة
                  GestureDetector(
                    onTap: () {
                      try {
                        final cartState = CartScope.of(context);
                        cartState.addAbayaItem(
                          id: item.id,
                          title: item.title,
                          price: item.price,
                          imageUrl: item.imageUrl,
                          subtitle: item.subtitle,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'تمت إضافة ${item.title} إلى السلة',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('حدث خطأ: $e'),
                            backgroundColor: Colors.red,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: primaryBrown,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AbayaCard extends StatefulWidget {
  final AbayaItem item;
  final String priceText;
  final String heroTag;
  final Widget Function(String src) imageBuilder; // أصول/شبكة
  final VoidCallback onTap;

  const _AbayaCard({
    required this.item,
    required this.priceText,
    required this.heroTag,
    required this.imageBuilder,
    required this.onTap,
  });

  @override
  State<_AbayaCard> createState() => _AbayaCardState();
}

class _AbayaCardState extends State<_AbayaCard> {
  int _selectedColor = 0;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // الصورة
            AspectRatio(
              aspectRatio: 0.72,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Hero(
                      tag: widget.heroTag,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: widget.imageBuilder(item.imageUrl),
                      ),
                    ),
                  ),
                  // أيقونة المفضلة في الزاوية اليمنى السفلى
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: _FavButton(item: item),
                  ),
                  // شارة "جديد" في الزاوية اليسرى السفلى
                  if (item.isNew)
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B7355),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'جديد',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            // شارات الألوان (Color Swatches)
            if (item.colors.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: SizedBox(
                  height: 26,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: item.colors.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 6),
                    itemBuilder: (_, idx) => _ColorSwatch(
                      color: item.colors[idx],
                      selected: idx == _selectedColor,
                      onTap: () => setState(() => _selectedColor = idx),
                    ),
                  ),
                ),
              ),
            // اسم المنتج (من JavaScript: productName)
            Flexible(
              child: Text(
                item.title.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280),
                  letterSpacing: 0.4,
                  height: 1.1,
                ),
              ),
            ),
            const SizedBox(height: 2),
            // عنوان المنتج (من JavaScript: productTitle)
            Flexible(
              child: Text(
                item.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1F2937),
                  height: 1.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  const _ColorSwatch(
      {required this.color, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Border.all(
            color: selected ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB),
            width: selected ? 2.0 : 1.0,
          ),
        ),
      ),
    );
  }
}

class _FavButton extends StatefulWidget {
  final AbayaItem item;
  const _FavButton({required this.item});
  @override
  State<_FavButton> createState() => _FavButtonState();
}

class _FavButtonState extends State<_FavButton> {
  final _favoriteService = FavoriteService();
  bool _isLoading = false;
  bool _isFavorite = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) {
      if (mounted) {
        setState(() {
          _isFavorite = false;
          _isInitialized = true;
        });
      }
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
      if (mounted) {
        setState(() {
          _isFavorite = false;
          _isInitialized = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (!_isInitialized) {
      return Material(
        color: Colors.white.withOpacity(0.9),
        shape: const CircleBorder(),
        child: const Padding(
          padding: EdgeInsets.all(6),
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: authProvider.isAuthenticated
          ? () async {
              if (_isLoading) return;
              setState(() => _isLoading = true);

              try {
                if (_isFavorite) {
                  final removed = await _favoriteService.removeFromFavorites(
                    productId: widget.item.id,
                    productType: 'abaya',
                  );
                  if (mounted && removed) {
                    setState(() => _isFavorite = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم إزالة من المفضلة'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
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
                  if (mounted && added) {
                    setState(() => _isFavorite = true);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تمت الإضافة للمفضلة'),
                        duration: Duration(seconds: 2),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('حدث خطأ: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } finally {
                if (mounted) {
                  setState(() => _isLoading = false);
                }
              }
            }
          : () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('يرجى تسجيل الدخول أولاً'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.9),
        ),
        child: _isLoading
            ? const Padding(
                padding: EdgeInsets.all(8),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : Icon(
                _isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                size: 20,
                color: _isFavorite ? Colors.red : const Color(0xFF1F2937),
              ),
      ),
    );
  }
}

/* ===================== شريط سفلي زجاجي (محذوف) ===================== */
