// lib/features/shops/presentation/abaya_shops_screen.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/shop.dart';
import '../../catalog/presentation/abaya_services_screen.dart';
import '../../../shared/widgets/skeletons.dart';

/// شاشة محلات العبايات — صور من assets/abaya/
class AbayaShopsScreen extends StatefulWidget {
  const AbayaShopsScreen({super.key});

  @override
  State<AbayaShopsScreen> createState() => _AbayaShopsScreenState();
}

class _AbayaShopsScreenState extends State<AbayaShopsScreen> {
  final TextEditingController _search = TextEditingController();

  // بيانات تجريبية بصور من الأصول
  final List<Shop> _all = [
    Shop(
      id: 's1',
      name: 'عبايات الروز',
      category: 'عبايات',
      city: 'مسقط',
      imageUrl: 'assets/abaya/abaya1.jpeg',
      rating: 4.8,
      reviews: 120,
      minPrice: 9.5,
      servicesCount: 24,
      delivery: true,
      isOpen: true,
    ),
    Shop(
      id: 's2',
      name: 'دار الأناقة',
      category: 'عبايات',
      city: 'السيب',
      imageUrl: 'assets/abaya/abaya2.jpeg',
      rating: 4.6,
      reviews: 95,
      minPrice: 10.0,
      servicesCount: 18,
      delivery: true,
      isOpen: true,
    ),
    Shop(
      id: 's3',
      name: 'بيت العباية',
      category: 'تفصيل',
      city: 'مطرح',
      imageUrl: 'assets/abaya/abaya3.jpeg',
      rating: 4.3,
      reviews: 63,
      minPrice: 8.0,
      servicesCount: 12,
      delivery: false,
      isOpen: false,
    ),
    Shop(
      id: 's4',
      name: 'لمسة حرير',
      category: 'عبايات',
      city: 'العذيبة',
      imageUrl: 'assets/abaya/abaya4.jpeg',
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
              s.name.contains(q) ||
              s.city.contains(q) ||
              s.category.contains(q))
          .toList();
    }
    if (_onlyOpen) list = list.where((s) => s.isOpen).toList();
    if (_onlyDelivery) list = list.where((s) => s.delivery).toList();

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
        body: CustomScrollView(
          slivers: [
            // رأس بتدرّج
            SliverAppBar(
              pinned: true,
              floating: true,
              expandedHeight: 120,
              elevation: 0,
              backgroundColor: cs.surface,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      cs.primaryContainer.withOpacity(.55),
                      cs.tertiaryContainer.withOpacity(.35),
                      cs.surface,
                    ],
                  ),
                ),
                child: FlexibleSpaceBar(
                  expandedTitleScale: 1.15,
                  titlePadding:
                      const EdgeInsetsDirectional.only(start: 16, bottom: 12),
                  title: Text(
                    'محلات العبايات',
                    style: TextStyle(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .3,
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  tooltip: 'فلترة متقدمة',
                  icon: const Icon(Icons.tune_rounded),
                  onPressed: () {},
                ),
              ],
            ),

            // البحث + فلاتر
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                child: Column(
                  children: [
                    TextField(
                      controller: _search,
                      onChanged: (_) => _applyFilters(),
                      decoration: InputDecoration(
                        hintText: 'ابحث عن محل…',
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
                          borderSide: BorderSide(color: cs.primary, width: 1.3),
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
                          avatar: const Icon(Icons.local_shipping_outlined,
                              size: 18),
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

            // قائمة المحلات
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
                        priceText: _price(s.minPrice),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  AbayaServicesScreen(shopName: s.name),
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
  final String priceText;
  final VoidCallback onTap;
  const _ShopCardModern({
    required this.shop,
    required this.priceText,
    required this.onTap,
  });

  bool _isNetworkPath(String p) =>
      p.startsWith('http://') || p.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // نجهّز ويدجت الصورة: شبكة أو أصول مع تحميل ذكي
    Widget buildShopImage(String src) {
      if (_isNetworkPath(src)) {
        return CachedNetworkImage(
          imageUrl: src,
          fit: BoxFit.cover,
          memCacheWidth:
              (132 * MediaQuery.of(context).devicePixelRatio).round(),
          memCacheHeight:
              (140 * MediaQuery.of(context).devicePixelRatio).round(),
          placeholder: (context, url) => const SkeletonContainer(),
          errorWidget: (context, url, error) => Container(
            color: cs.surfaceContainerHighest,
            child: Icon(Icons.image, color: cs.onSurfaceVariant),
          ),
          fadeInDuration: const Duration(milliseconds: 200),
          fadeOutDuration: const Duration(milliseconds: 100),
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
                          // تقييم قابل للتصغير تلقائيًا
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
                                _MiniIconText(
                                  icon: Icons.design_services_outlined,
                                  text: '${shop.servicesCount} خدمة',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          // زر السعر يتقلّص تلقائيًا لو المساحة ضاقت
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: _PriceCTA(text: 'من $priceText'),
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

    // يمنع Overflow حتى لو بقيت مساحة 50–60px فقط
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 0, maxWidth: 80),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerRight,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
              const SizedBox(width: 2),
              Text(
                rate.toStringAsFixed(1),
                style: TextStyle(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(width: 3),
              Text(
                '($reviews)',
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
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

class _MiniIconText extends StatelessWidget {
  final IconData icon;
  final String text;
  const _MiniIconText({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // ✅ هذه كانت سبب الـ overflow: أعطيناه حد أقصى + تصغير تلقائي
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 0, maxWidth: 88),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerRight,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: cs.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w700,
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PriceCTA extends StatelessWidget {
  final String text;
  const _PriceCTA({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF6D4C41),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6D4C41).withOpacity(.18),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
      ),
    );
  }
}
