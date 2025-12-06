// lib/features/shops/presentation/abaya_shops_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/shop.dart';
import '../services/abaya_traders_service.dart';
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
  final _abayaTradersService = AbayaTradersService();

  // البيانات من Firebase
  List<Shop> _all = [];
  late List<Shop> _shown = [];
  bool _onlyOpen = false;
  bool _onlyDelivery = false;
  bool _isLoading = true;
  StreamSubscription<List<Shop>>? _subscription;

  @override
  void initState() {
    super.initState();
    // الاشتراك في stream لجلب البيانات
    _subscription = _abayaTradersService.getAbayaTraders().listen(
      (traders) {
        if (mounted) {
          setState(() {
            _all = traders;
            _isLoading = false;
            _applyFilters();
          });
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        print('خطأ في جلب بيانات التجار: $error');
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
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
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color(0xFFE91E63),
                  ),
                ),
              )
            : CustomScrollView(
          slivers: [
            // AppBar بنمط iOS ولون بناتي
            SliverAppBar(
              pinned: true,
              floating: true,
              expandedHeight: 100,
              collapsedHeight: kToolbarHeight,
              elevation: 0,
              backgroundColor: const Color(0xFFE91E63), // لون بناتي جميل
              surfaceTintColor: Colors.transparent,
              shadowColor: Colors.transparent,
              scrolledUnderElevation: 0,
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
              flexibleSpace: const FlexibleSpaceBar(
                expandedTitleScale: 1.1,
                titlePadding:
                    EdgeInsetsDirectional.only(start: 16, bottom: 16),
                centerTitle: false,
                title: Text(
                  'محلات العبايات',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.2,
                    fontSize: 24,
                  ),
                ),
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
                      CupertinoIcons.slider_horizontal_3,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),

            // البحث + فلاتر
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
                        fillColor: cs.surfaceContainerHighest.withOpacity(.8),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: cs.outlineVariant.withOpacity(0.5)),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: cs.outlineVariant.withOpacity(0.5)),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: cs.primary, width: 2.0),
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
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
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              sliver: _shown.isEmpty
                  ? SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.store_outlined,
                              size: 64,
                              color: cs.onSurfaceVariant.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'لا توجد محلات',
                              style: TextStyle(
                                color: cs.onSurfaceVariant,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) {
                          final s = _shown[i];
                          return Padding(
                            padding: EdgeInsets.only(
                                bottom: i == _shown.length - 1 ? 0 : 16),
                            child: _ShopCardModern(
                              shop: s,
                              priceText: _price(s.minPrice),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AbayaServicesScreen(
                                      shopName: s.name,
                                      traderId: s.id, // تمرير معرف التاجر
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
                  padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
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
                                fontSize: 17,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // تقييم قابل للتصغير تلقائيًا
                          _Rating(rate: shop.rating, reviews: shop.reviews),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${shop.city} · ${shop.category}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 10),
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

