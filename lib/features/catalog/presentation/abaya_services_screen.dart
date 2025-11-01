// lib/features/catalog/presentation/abaya_services_screen.dart
import 'dart:math' as math;
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';

import '../models/abaya_item.dart';
import 'product_preview_screen.dart';

// يفضَّل الاستيراد النسبي لتفادي مشاكل اسم الحزمة
import '../../../shared/widgets/any_image.dart';

/* أوضاع الفرز */
enum _SortMode { popular, priceLow, priceHigh, newest, titleAZ }

class AbayaServicesScreen extends StatefulWidget {
  final String? shopName; // اسم المحل (اختياري للعرض كشارة)
  const AbayaServicesScreen({super.key, this.shopName});

  @override
  State<AbayaServicesScreen> createState() => _AbayaServicesScreenState();
}

class _AbayaServicesScreenState extends State<AbayaServicesScreen> {
  static const _chips = ['الكل', 'عبايات', 'أقمشة', 'أطقم', 'إكسسوارات'];
  int _selectedChip = 1;

  // ✅ استخدم مجلد الأصول الجذري assets/ (تأكد من pubspec.yaml)
  String _asset(String name) => 'assets/abaya/$name';

  // البيانات الأصلية + المعروضة
  final List<AbayaItem> _items = [];
  List<AbayaItem> _shown = [];

  // خيارات الفلترة
  late double _minPrice, _maxPrice;
  late RangeValues _priceRange;
  bool _onlyNew = false;
  late List<Color> _colorChoices;
  final Set<Color> _selectedColors = {};

  // وضع الفرز
  _SortMode _sort = _SortMode.popular;

  @override
  void initState() {
    super.initState();
    _seedItems();
    _bootstrapFilters();
    _applyFiltersAndSort();
  }

  void _seedItems() {
    // تقليل عدد العناصر لتحسين الأداء
    _items.addAll([
      AbayaItem(
        id: 'a1',
        title: 'Tank',
        subtitle: 'كريب قطني',
        price: 9.5,
        imageUrl: _asset('abaya1.jpeg'),
        gallery: [
          _asset('abaya1.jpeg'),
          _asset('abaya2.jpeg'),
        ], // تقليل من 3 إلى 2
        colors: const [
          Color(0xFFC0C3C9),
          Color(0xFFE5D3C5),
        ], // تقليل من 4 إلى 2
      ),
      AbayaItem(
        id: 'a2',
        title: 'Tank',
        subtitle: 'كريب قطني',
        price: 10.0,
        imageUrl: _asset('abaya2.jpeg'),
        gallery: [
          _asset('abaya2.jpeg'),
          _asset('abaya1.jpeg'),
        ],
        colors: const [
          Color(0xFFF1D6E5),
          Color(0xFFEAD0C2),
          Color(0xFFC9B1A3),
          Color(0xFF8CA1B2),
          Color(0xFF2F4A5A),
        ],
        isNew: true,
      ),
      AbayaItem(
        id: 'a3',
        title: 'Oversize',
        subtitle: 'كريب ناعم',
        price: 12.0,
        imageUrl: _asset('abaya3.jpeg'),
        gallery: [
          _asset('abaya3.jpeg'),
          _asset('abaya4.jpeg'),
        ],
        colors: const [
          Color(0xFF2F4A5A),
          Color(0xFFC0C3C9),
          Color(0xFFEAD0C2),
        ],
      ),
      AbayaItem(
        id: 'a4',
        title: 'Classic',
        subtitle: 'كريب رسمي',
        price: 14.0,
        imageUrl: _asset('abaya4.jpeg'),
        gallery: [
          _asset('abaya4.jpeg'),
          _asset('abaya5.jpeg'),
          _asset('abaya6.jpeg'),
        ],
        colors: const [
          Color(0xFF111111),
          Color(0xFF696969),
          Color(0xFFE5D3C5),
        ],
      ),
    ]);
  }

  void _bootstrapFilters() {
    _minPrice = _items.map((e) => e.price).reduce(math.min);
    _maxPrice = _items.map((e) => e.price).reduce(math.max);
    _priceRange = RangeValues(_minPrice, _maxPrice);

    // ألوان فريدة
    final seen = <int>{};
    final all = <Color>[];
    for (final c in _items.expand((i) => i.colors)) {
      if (seen.add(c.value)) all.add(c);
    }
    _colorChoices = all;
  }

  void _applyFiltersAndSort() {
    List<AbayaItem> list = List.of(_items);

    // فلترة السعر
    list = list
        .where(
            (i) => i.price >= _priceRange.start && i.price <= _priceRange.end)
        .toList();

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
        default:
          return 0;
      }
    });

    setState(() => _shown = list);
  }

  String _price(double v) =>
      '${v == v.truncateToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2)} ر.ع';

  int _activeFiltersCount() {
    int c = 0;
    if (_onlyNew) c++;
    if (_selectedColors.isNotEmpty) c++;
    final priceChanged = (_priceRange.start > _minPrice + 1e-9) ||
        (_priceRange.end < _maxPrice - 1e-9);
    if (priceChanged) c++;
    return c;
  }

  String _sortTitle(_SortMode s) {
    switch (s) {
      case _SortMode.priceLow:
        return 'الأقل فالأعلى';
      case _SortMode.priceHigh:
        return 'الأعلى فالأقل';
      case _SortMode.newest:
        return 'الأحدث';
      case _SortMode.titleAZ:
        return 'الاسم: أ ⇢ ي';
      case _SortMode.popular:
      default:
        return 'الأشهر';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: cs.surface,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.maybePop(context),
          ),
          title: const Text(''),
          actions: [
            IconButton(
                icon: const Icon(Icons.search_rounded), onPressed: () {}),
          ],
        ),
        body: Stack(
          children: [
            CustomScrollView(
              slivers: [
                // شريط الشرائح
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                    child: _ChipsRow(
                      chips: _chips,
                      selectedIndex: _selectedChip,
                      onChanged: (i) => setState(() => _selectedChip = i),
                    ),
                  ),
                ),
                // العنوان + شارة اسم المتجر
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'العبايات'.toUpperCase(),
                          style: TextStyle(
                            color: cs.onSurface,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            fontSize: 26,
                          ),
                        ),
                        if (widget.shopName != null &&
                            widget.shopName!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color:
                                    cs.surfaceContainerHighest.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text('المتجر: ${widget.shopName!}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700)),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                // الشبكة
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 120),
                  sliver: SliverLayoutBuilder(
                    builder: (context, constraints) {
                      // حساب عدد الأعمدة حسب عرض الشاشة
                      final crossAxisCount =
                          constraints.crossAxisExtent > 600 ? 3 : 2;
                      final childAspectRatio =
                          constraints.crossAxisExtent > 600 ? 0.8 : 0.75;

                      return SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: childAspectRatio,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, i) {
                            final item = _shown[i];
                            return _AbayaCard(
                              item: item,
                              priceText: _price(item.price),
                              heroTag: 'abaya-${item.id}',
                              imageBuilder: (src) => AnyImage(
                                src: src,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                filterQuality: FilterQuality.medium,
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    transitionDuration: const Duration(
                                        milliseconds:
                                            200), // تقليل مدة الانتقال
                                    reverseTransitionDuration:
                                        const Duration(milliseconds: 150),
                                    pageBuilder: (_, __, ___) =>
                                        ProductPreviewScreen(
                                      productId: item.id,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          childCount: _shown.length,
                          addAutomaticKeepAlives: false, // تحسين الذاكرة
                          addRepaintBoundaries: false, // تحسين الأداء
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            // الشريط السفلي الزجاجي (فلترة/فرز)
            Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: SafeArea(
                top: false,
                child: _FilterSortDock(
                  filtersCount: _activeFiltersCount(),
                  sortLabel: _sortTitle(_sort),
                  onFilter: _openFilterSheet,
                  onSort: _openSortSheet,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============ BottomSheet: فلترة ============
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

        final divisions =
            math.max(1, math.min(100, ((_maxPrice - _minPrice) * 10).round()));

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

  // ============ BottomSheet: فرز ============
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

class _ChipsRow extends StatelessWidget {
  final List<String> chips;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  const _ChipsRow({
    required this.chips,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(chips.length, (i) {
          final selected = i == selectedIndex;
          return Padding(
            padding:
                EdgeInsetsDirectional.only(end: i == chips.length - 1 ? 0 : 8),
            child: ChoiceChip(
              label: Text(chips[i]),
              selected: selected,
              onSelected: (_) => onChanged(i),
              backgroundColor: cs.surfaceContainerHighest.withOpacity(0.7),
              selectedColor: const Color(0xFF6D4C41),
              labelStyle: TextStyle(
                color: selected ? Colors.white : cs.onSurface,
                fontWeight: FontWeight.w600,
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            ),
          );
        }),
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
    final cs = Theme.of(context).colorScheme;
    final item = widget.item;

    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      child: InkWell(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Hero(
                        tag: widget.heroTag,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: widget.imageBuilder(item.imageUrl),
                        ),
                      ),
                    ),
                    const Positioned(top: 8, left: 8, child: _FavButton()),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 30,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: item.colors.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, idx) => _ColorDot(
                    color: item.colors[idx],
                    selected: idx == _selectedColor,
                    onTap: () => setState(() => _selectedColor = idx),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              if (item.isNew)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6D4C41),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'جديد',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12),
                  ),
                ),
              if (item.isNew) const SizedBox(height: 4),
              Text(
                item.subtitle.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  fontSize: 11.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 16),
              ),
              const SizedBox(height: 2),
              Text(
                widget.priceText,
                style: TextStyle(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w800,
                    fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  const _ColorDot(
      {required this.color, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
              color: selected ? cs.onSurface : cs.outlineVariant,
              width: selected ? 2.0 : 1),
        ),
        alignment: Alignment.center,
        child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      ),
    );
  }
}

class _FavButton extends StatefulWidget {
  const _FavButton();
  @override
  State<_FavButton> createState() => _FavButtonState();
}

class _FavButtonState extends State<_FavButton> {
  bool _fav = false;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: Colors.white.withOpacity(0.9),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => setState(() => _fav = !_fav),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
            child: Icon(
              _fav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              key: ValueKey(_fav),
              size: 20,
              color: _fav ? Colors.red : cs.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

/* ===================== شريط سفلي زجاجي ===================== */

class _FilterSortDock extends StatelessWidget {
  final int filtersCount;
  final String sortLabel;
  final VoidCallback onFilter;
  final VoidCallback onSort;

  const _FilterSortDock({
    required this.filtersCount,
    required this.sortLabel,
    required this.onFilter,
    required this.onSort,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const brand = Color(0xFF6D4C41);

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: cs.surface.withOpacity(.78),
            border: Border.all(color: cs.outlineVariant),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(.06),
                  blurRadius: 18,
                  offset: const Offset(0, 8)),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _DockButton(
                  label: 'فلترة',
                  icon: Icons.tune_rounded,
                  onTap: onFilter,
                  badge: filtersCount > 0 ? filtersCount : null,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DockButton(
                  label: sortLabel,
                  icon: Icons.sort_rounded,
                  onTap: onSort,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DockButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final int? badge;

  const _DockButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    const brand = Color(0xFF6D4C41);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            // ✅ لا نستخدم const هنا لأننا نعتمد على متغيّر محلي
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [brand, brand],
            ),
            boxShadow: [
              BoxShadow(
                  color: brand.withOpacity(.20),
                  blurRadius: 14,
                  offset: const Offset(0, 6)),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  const SizedBox(width: 0, height: 0), // لتثبيت الارتفاع
                  // ❌ لا نضع const لأن icon متغيّر
                  Icon(icon, size: 18, color: Colors.white),
                  if (badge != null)
                    PositionedDirectional(
                      top: -6,
                      start: -8,
                      child: _CountBadge(count: badge!),
                    ),
                ],
              ),
              const SizedBox(width: 8),
              const Flexible(
                child: Text(
                  ' ',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w800),
                ),
              ),
              // نعرض النص الحقيقي خارج Flexible الثابت
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int count;
  const _CountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF43A047),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF43A047).withOpacity(.28), blurRadius: 8)
        ],
      ),
      child: Text(
        '$count',
        style: const TextStyle(
            color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900),
      ),
    );
  }
}
