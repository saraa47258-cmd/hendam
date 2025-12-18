// lib/features/catalog/presentation/small_merchant_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../shops/models/shop.dart';

// استبدل الاستيراد:
import 'merchant_products_screen.dart';

class SmallMerchantScreen extends StatefulWidget {
  const SmallMerchantScreen({super.key});

  @override
  State<SmallMerchantScreen> createState() => _SmallMerchantScreenState();
}

class _SmallMerchantScreenState extends State<SmallMerchantScreen> {
  final TextEditingController _search = TextEditingController();

  // بيانات تجريبية رجالية
  final List<Shop> _all = [
    Shop(
      id: 'm1',
      name: 'متجر اللمسة الرجالية',
      category: 'مستلزمات رجالية',
      city: 'مسقط',
      imageUrl: 'assets/shops/3.jpg',
      rating: 4.8,
      reviews: 120,
      minPrice: 9.5,
      servicesCount: 24,
      delivery: true,
      isOpen: true,
    ),
    Shop(
      id: 'm2',
      name: 'بيت القماش',
      category: 'أقمشة رجالية',
      city: 'السيب',
      imageUrl: 'assets/shops/4.jpg',
      rating: 4.6,
      reviews: 95,
      minPrice: 10.0,
      servicesCount: 18,
      delivery: true,
      isOpen: true,
    ),
    Shop(
      id: 'm3',
      name: 'أناقة رجالية',
      category: 'تفصيل دشداشة',
      city: 'مطرح',
      imageUrl: 'assets/shops/5.jpg',
      rating: 4.3,
      reviews: 63,
      minPrice: 8.0,
      servicesCount: 12,
      delivery: false,
      isOpen: false,
    ),
    Shop(
      id: 'm4',
      name: 'أطياف ستايل',
      category: 'أحذية وإكسسوارات',
      city: 'العذيبة',
      imageUrl: 'assets/shops/6.jpeg',
      rating: 4.9,
      reviews: 210,
      minPrice: 12.0,
      servicesCount: 30,
      delivery: true,
      isOpen: true,
    ),
  ];

  late List<Shop> _shown = List.of(_all);
  bool _onlyOpen = false;
  bool _onlyDelivery = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final q = _search.text.trim();
    List<Shop> list = _all;

    if (q.isNotEmpty) {
      list = list
          .where((s) =>
      s.name.contains(q) || s.city.contains(q) || s.category.contains(q))
          .toList();
    }
    if (_onlyOpen) list = list.where((s) => s.isOpen).toList();
    if (_onlyDelivery) list = list.where((s) => s.delivery).toList();

    setState(() => _shown = list);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: cs.surface,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xFFF59E0B), // لون كهرماني للتجار
          surfaceTintColor: Colors.transparent,
          leading: CupertinoButton(
            padding: EdgeInsets.zero,
            minSize: 0,
            onPressed: () => Navigator.maybePop(context),
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                CupertinoIcons.back,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
          leadingWidth: 56,
          title: const Text(
            '',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              minSize: 0,
              onPressed: () {},
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  CupertinoIcons.search,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: CustomScrollView(
          slivers: [
            // العنوان الرئيسي
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 12),
                child: Text(
                  'محلات المستلزمات الرجالية',
                  style: TextStyle(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.3,
                    fontSize: 28,
                  ),
                ),
              ),
            ),
            // بحث + فلاتر
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
                child: Column(
                  children: [
                    TextField(
                      controller: _search,
                      onChanged: (_) => _applyFilters(),
                      decoration: InputDecoration(
                        hintText: 'ابحث عن محل رجالي…',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: _search.text.isEmpty
                            ? null
                            : IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () {
                            _search.clear();
                            _applyFilters();
                          },
                        ),
                        filled: true,
                        fillColor: cs.surfaceContainerHighest.withOpacity(.7),
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
                          BorderSide(color: cs.primary, width: 1.3),
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        FilterChip(
                          label: const Text('مفتوح الآن'),
                          selected: _onlyOpen,
                          onSelected: (v) {
                            setState(() => _onlyOpen = v);
                            _applyFilters();
                          },
                          selectedColor: const Color(0xFFE7F6EC),
                          checkmarkColor: const Color(0xFF1B5E20),
                          avatar: const Icon(Icons.schedule_rounded, size: 18),
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text('توصيل'),
                          selected: _onlyDelivery,
                          onSelected: (v) {
                            setState(() => _onlyDelivery = v);
                            _applyFilters();
                          },
                          selectedColor: const Color(0xFFE7F6EC),
                          checkmarkColor: const Color(0xFF1B5E20),
                          avatar:
                          const Icon(Icons.local_shipping_outlined, size: 18),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHighest.withOpacity(.6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_shown.length} نتيجة',
                            style: TextStyle(
                              color: cs.onSurfaceVariant,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // القائمة
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, i) {
                    final s = _shown[i];
                    return Padding(
                      padding: EdgeInsets.only(
                          bottom: i == _shown.length - 1 ? 0 : 12),
                      child: _ShopCardModern(
                        shop: s,
                        // … داخل _ShopCardModern onTap:
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MerchantProductsScreen(shop: s),
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
      ),
    );
  }
}

/* ========================= بطاقة حديثة ========================= */

class _ShopCardModern extends StatelessWidget {
  final Shop shop;
  final VoidCallback onTap;
  const _ShopCardModern({
    required this.shop,
    required this.onTap,
  });

  bool _isNetworkPath(String p) =>
      p.startsWith('http://') || p.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget buildShopImage(String src) {
      if (_isNetworkPath(src)) {
        return Image.network(
          src,
          fit: BoxFit.cover,
          loadingBuilder: (c, child, p) =>
          p == null ? child : Container(color: cs.surfaceContainerHighest),
          errorBuilder: (_, __, ___) =>
              Container(color: cs.surfaceContainerHighest),
        );
      }
      return Image.asset(
        src,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            Container(color: cs.surfaceContainerHighest),
      );
    }

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: cs.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.04),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 140),
          child: Row(
            children: [
              // صورة
              ClipRRect(
                borderRadius: const BorderRadiusDirectional.only(
                  topStart: Radius.circular(18),
                  bottomStart: Radius.circular(18),
                ),
                child: Stack(
                  children: [
                    SizedBox(
                      width: 132,
                      height: 140,
                      child: buildShopImage(shop.imageUrl),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(.05),
                              Colors.transparent
                            ],
                          ),
                        ),
                      ),
                    ),
                    PositionedDirectional(
                      top: 8,
                      start: 8,
                      child: _Pill(
                        text: shop.isOpen ? 'مفتوح' : 'مغلق',
                        bg: shop.isOpen
                            ? const Color(0xFFE7F6EC)
                            : const Color(0xFFFDECEC),
                        fg: shop.isOpen
                            ? const Color(0xFF1B5E20)
                            : const Color(0xFFB71C1C),
                      ),
                    ),
                  ],
                ),
              ),

              // معلومات
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              shop.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: cs.onSurface,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          _Rating(rate: shop.rating, reviews: shop.reviews),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${shop.city} · ${shop.category}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: cs.onSurfaceVariant),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                _Pill(
                                  text: shop.delivery
                                      ? 'توصيل متاح'
                                      : 'لا يوجد توصيل',
                                  bg: shop.delivery
                                      ? const Color(0xFFE7F6EC)
                                      : const Color(0xFFF0F0F0),
                                  fg: shop.delivery
                                      ? const Color(0xFF1B5E20)
                                      : Colors.black54,
                                ),
                                // شارة نصية فقط لعدد الخدمات (بدون أيقونة)
                                _TextPill(text: '${shop.servicesCount} خدمة'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ========================= عناصر صغيرة ========================= */

class _Rating extends StatelessWidget {
  final double rate;
  final int reviews;
  const _Rating({required this.rate, required this.reviews});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
          const SizedBox(width: 2),
          Text(
            rate.toStringAsFixed(1),
            style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w800),
          ),
          const SizedBox(width: 4),
          Text(
            '($reviews)',
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
          ),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration:
      BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(
        text,
        style: TextStyle(color: fg, fontWeight: FontWeight.w800, fontSize: 12),
      ),
    );
  }
}

// شارة نصية بدون أيقونة
class _TextPill extends StatelessWidget {
  final String text;
  const _TextPill({required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: cs.onSurface,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}
