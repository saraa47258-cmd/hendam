// lib/features/catalog/presentation/merchant_products_screen.dart
import 'package:flutter/material.dart';
import '../../shops/models/shop.dart';
import '../../orders/presentation/my_orders_screen.dart';

/// موديل المنتج (مستقل عن أي موديلات أخرى)
class MerchantProduct {
  final String id;
  final String title;
  final String subtitle;
  final double price;
  final String imageUrl;      // صورة الغلاف
  final List<String> gallery; // باقي الصور
  final List<Color> colors;   // ألوان/خيارات
  final String category;      // للتصفية
  final bool isNew;

  const MerchantProduct({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.imageUrl,
    required this.gallery,
    required this.colors,
    required this.category,
    this.isNew = false,
  });
}

class MerchantProductsScreen extends StatefulWidget {
  final Shop shop;
  const MerchantProductsScreen({super.key, required this.shop});

  @override
  State<MerchantProductsScreen> createState() => _MerchantProductsScreenState();
}

class _MerchantProductsScreenState extends State<MerchantProductsScreen> {
  // الشرائح (أقسام)
  static const _chips = ['الكل', 'ملابس', 'أقمشة', 'أحذية', 'إكسسوارات'];
  int _selectedChip = 0;

  // الفرز
  String _sort = 'الأحدث'; // الأحدث | السعر ↑ | السعر ↓

  // البحث
  String _query = '';

  // مساعدات صور
  bool _isNet(String p) => p.startsWith('http://') || p.startsWith('https://');
  Widget _img(String src, {BoxFit fit = BoxFit.cover}) =>
      _isNet(src) ? Image.network(src, fit: fit) : Image.asset(src, fit: fit);

  String _shopImg(String name) => 'assets/shops/$name';

  // بيانات
  final List<MerchantProduct> _all = [];
  List<MerchantProduct> _shown = [];

  @override
  void initState() {
    super.initState();
    _seedForShop(widget.shop);
    _applyFilters();
  }

  void _seedForShop(Shop s) {
    // منتجات ديمو — صور كلها من assets/shops/
    _all.addAll([
      MerchantProduct(
        id: 'p1',
        title: 'ثوب قطني',
        subtitle: 'خليجي ناعم',
        price: 9.5,
        imageUrl: _shopImg('3.jpg'),
        gallery: [_shopImg('3.jpg'), _shopImg('4.jpg')],
        colors: const [Color(0xFF111111), Color(0xFFC0C3C9), Color(0xFFE5D3C5)],
        category: 'ملابس',
        isNew: true,
      ),
      MerchantProduct(
        id: 'p2',
        title: 'قماش سوبر 150s',
        subtitle: 'مقاس بالمتر',
        price: 12.0,
        imageUrl: _shopImg('4.jpg'),
        gallery: [_shopImg('4.jpg'), _shopImg('6.jpeg')],
        colors: const [Color(0xFF2F4A5A), Color(0xFFEAD0C2)],
        category: 'أقمشة',
      ),
      MerchantProduct(
        id: 'p3',
        title: 'شبشب جلد',
        subtitle: 'جلد طبيعي',
        price: 14.0,
        imageUrl: _shopImg('5.jpg'),
        gallery: [_shopImg('5.jpg'), _shopImg('3.jpg')],
        colors: const [Color(0xFF111111), Color(0xFF696969)],
        category: 'أحذية',
      ),
      MerchantProduct(
        id: 'p4',
        title: 'عقال فاخر',
        subtitle: 'قطن مصري',
        price: 6.0,
        imageUrl: _shopImg('6.jpeg'),
        gallery: [_shopImg('6.jpeg'), _shopImg('5.jpg')],
        colors: const [Color(0xFF2F4A5A), Color(0xFFC7B9AF), Color(0xFFF1D6E5)],
        category: 'إكسسوارات',
      ),
      MerchantProduct(
        id: 'p5',
        title: 'قميص نص كم',
        subtitle: 'خامة صيفية',
        price: 8.0,
        imageUrl: _shopImg('4.jpg'),
        gallery: [_shopImg('4.jpg'), _shopImg('3.jpg')],
        colors: const [Color(0xFFC0C3C9), Color(0xFFE5D3C5)],
        category: 'ملابس',
        isNew: true,
      ),
    ]);
  }

  void _applyFilters() {
    List<MerchantProduct> list = List.of(_all);

    // فلترة حسب القسم
    if (_selectedChip != 0) {
      final cat = _chips[_selectedChip];
      list = list.where((p) => p.category == cat).toList();
    }

    // بحث
    if (_query.isNotEmpty) {
      list = list
          .where((p) => p.title.contains(_query) || p.subtitle.contains(_query))
          .toList();
    }

    // فرز
    switch (_sort) {
      case 'السعر ↑':
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'السعر ↓':
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      default: // الأحدث
        list.sort((a, b) {
          final nx = (b.isNew ? 1 : 0) - (a.isNew ? 1 : 0);
          return nx != 0 ? nx : b.id.compareTo(a.id);
        });
    }

    setState(() => _shown = list);
  }

  String _price(double v) =>
      '${v == v.truncateToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2)} ر.ع';

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
          title: Text(widget.shop.name, overflow: TextOverflow.ellipsis),
        ),
        body: CustomScrollView(
          slivers: [
            // هيدر معلومات المحل
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: _ShopHeader(
                  shop: widget.shop,
                  img: _img(widget.shop.imageUrl, fit: BoxFit.cover),
                ),
              ),
            ),
            // بحث/فرز/شرائح
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            onChanged: (v) {
                              _query = v.trim();
                              _applyFilters();
                            },
                            decoration: InputDecoration(
                              hintText: 'ابحث داخل ${widget.shop.name}…',
                              prefixIcon: const Icon(Icons.search_rounded),
                              filled: true,
                              fillColor:
                              cs.surfaceContainerHighest.withOpacity(.7),
                              contentPadding:
                              const EdgeInsets.symmetric(vertical: 12),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: cs.outlineVariant),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: cs.outlineVariant),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                BorderSide(color: cs.primary, width: 1.2),
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _SortButton(
                          current: _sort,
                          onSelect: (v) {
                            _sort = v;
                            _applyFilters();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _ChipsRow(
                      chips: _chips,
                      selectedIndex: _selectedChip,
                      onChanged: (i) {
                        _selectedChip = i;
                        _applyFilters();
                      },
                    ),
                  ],
                ),
              ),
            ),
            // شبكة المنتجات
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: .62,
                ),
                delegate: SliverChildBuilderDelegate(
                      (context, i) {
                    final item = _shown[i];
                    final hero = 'mprod-${widget.shop.id}-${item.id}';
                    return _ProductCard(
                      item: item,
                      heroTag: hero,
                      imageBuilder: (src) => _img(src, fit: BoxFit.cover),
                      priceText: _price(item.price),
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration:
                            const Duration(milliseconds: 280),
                            reverseTransitionDuration:
                            const Duration(milliseconds: 220),
                            pageBuilder: (_, __, ___) =>
                                MerchantProductPreviewScreen(
                                  product: item,
                                  heroTag: hero,
                                ),
                          ),
                        );
                      },
                    );
                  },
                  childCount: _shown.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ---------------------- Widgets مساعدة ---------------------- */

class _ShopHeader extends StatelessWidget {
  final Shop shop;
  final Widget img;
  const _ShopHeader({required this.shop, required this.img});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadiusDirectional.only(
              topStart: Radius.circular(16),
              bottomStart: Radius.circular(16),
            ),
            child: SizedBox(width: 120, height: 96, child: img),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 14, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(shop.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: cs.onSurface,
                          fontWeight: FontWeight.w900,
                          fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('${shop.city} · ${shop.category}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: cs.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _Pill(
                        text: shop.isOpen ? 'مفتوح' : 'مغلق',
                        bg: shop.isOpen
                            ? const Color(0xFFE7F6EC)
                            : const Color(0xFFFDECEC),
                        fg: shop.isOpen
                            ? const Color(0xFF1B5E20)
                            : const Color(0xFFB71C1C),
                      ),
                      _Pill(
                        text: shop.delivery ? 'توصيل متاح' : 'لا يوجد توصيل',
                        bg: shop.delivery
                            ? const Color(0xFFE7F6EC)
                            : const Color(0xFFF0F0F0),
                        fg: shop.delivery
                            ? const Color(0xFF1B5E20)
                            : Colors.black54,
                      ),
                      _Pill(
                        text: '${shop.servicesCount} خدمة',
                        bg: cs.surfaceContainerHighest,
                        fg: cs.onSurface,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
              padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            ),
          );
        }),
      ),
    );
  }
}

class _SortButton extends StatelessWidget {
  final String current;
  final ValueChanged<String> onSelect;
  const _SortButton({required this.current, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'فرز',
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: onSelect,
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'الأحدث', child: Text('الأحدث')),
        PopupMenuItem(value: 'السعر ↑', child: Text('السعر ↑')),
        PopupMenuItem(value: 'السعر ↓', child: Text('السعر ↓')),
      ],
      child: Material(
        color: const Color(0xFF6D4C41),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.sort_rounded, color: Colors.white, size: 18),
                SizedBox(width: 6),
                Text('فرز',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductCard extends StatefulWidget {
  final MerchantProduct item;
  final String heroTag;
  final String priceText; // نص جاهز
  final Widget Function(String src) imageBuilder;
  final VoidCallback onTap;

  const _ProductCard({
    required this.item,
    required this.heroTag,
    required this.priceText,
    required this.imageBuilder,
    required this.onTap,
  });

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  int _selectedColor = 0;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final item = widget.item;

    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // الصورة
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

              // الألوان
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

              if (item.isNew) ...[
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
                const SizedBox(height: 4),
              ],

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

              // السعر كنص جاهز
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
      color: Colors.white.withOpacity(.9),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => setState(() => _fav = !_fav),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            transitionBuilder: (c, a) =>
                ScaleTransition(scale: a, child: c),
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
          decoration:
          BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;
  const _Pill({required this.text, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(text,
          style: TextStyle(
              color: fg, fontWeight: FontWeight.w800, fontSize: 12)),
    );
  }
}

/* ===================== شاشة المعاينة ===================== */

class MerchantProductPreviewScreen extends StatefulWidget {
  final MerchantProduct product;
  final String heroTag;
  const MerchantProductPreviewScreen(
      {super.key, required this.product, required this.heroTag});

  @override
  State<MerchantProductPreviewScreen> createState() =>
      _MerchantProductPreviewScreenState();
}

class _MerchantProductPreviewScreenState
    extends State<MerchantProductPreviewScreen> {
  late final PageController _pc;
  int _index = 0;
  bool _wish = false;

  bool _isNet(String p) =>
      p.startsWith('http://') || p.startsWith('https://');
  Widget _img(String src, {BoxFit fit = BoxFit.contain}) =>
      _isNet(src) ? Image.network(src, fit: fit) : Image.asset(src, fit: fit);

  @override
  void initState() {
    super.initState();
    _pc = PageController();
  }

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  String _price(double v) =>
      '${v == v.truncateToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2)} ر.ع';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final images = widget.product.gallery.isEmpty
        ? [widget.product.imageUrl]
        : widget.product.gallery;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: cs.surface,
        appBar: AppBar(
          leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.maybePop(context)),
          title:
          Text(widget.product.title, overflow: TextOverflow.ellipsis),
          actions: [
            IconButton(
                icon: const Icon(Icons.ios_share_rounded),
                onPressed: () {})
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pc,
                    itemCount: images.length,
                    onPageChanged: (i) => setState(() => _index = i),
                    itemBuilder: (_, i) {
                      final child = Center(
                        child: _img(images[i], fit: BoxFit.contain),
                      );
                      return i == 0
                          ? Hero(tag: widget.heroTag, child: child)
                          : child;
                    },
                  ),
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: Material(
                      color: Colors.white.withOpacity(0.9),
                      shape: const CircleBorder(),
                      child: IconButton(
                        onPressed: () => setState(() => _wish = !_wish),
                        icon: Icon(
                          _wish
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: _wish ? Colors.red : cs.onSurface,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(images.length, (i) {
                  final active = i == _index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin:
                    const EdgeInsets.symmetric(horizontal: 5),
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: cs.onSurface),
                      color: active ? cs.onSurface : Colors.transparent,
                    ),
                  );
                }),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(widget.product.subtitle.toUpperCase(),
                            style: TextStyle(
                                color: cs.onSurfaceVariant,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                                fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(widget.product.title,
                            style: TextStyle(
                                color: cs.onSurface,
                                fontWeight: FontWeight.w800,
                                fontSize: 18)),
                      ],
                    ),
                  ),
                  Text(_price(widget.product.price),
                      style: TextStyle(
                          color: cs.onSurface,
                          fontWeight: FontWeight.w800,
                          fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Container(
            padding:
            const EdgeInsets.fromLTRB(16, 10, 16, 16),
            decoration: BoxDecoration(
              color: cs.surface,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, -2))
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('تمت إضافة المنتج إلى السلة')),
                      );
                    },
                    icon: const Icon(Icons.shopping_bag_outlined),
                    label: const Text('أضف للسلة'),
                    style: OutlinedButton.styleFrom(
                      padding:
                      const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // هنا الانتقال إلى صفحة الطلبات
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MyOrdersScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding:
                      const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color(0xFF6D4C41),
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(
                          fontWeight: FontWeight.w800),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('اطلب الآن'),
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
