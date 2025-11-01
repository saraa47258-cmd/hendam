// lib/features/tailors/presentation/tailor_store_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../auth/providers/auth_provider.dart';
import 'tailor_design_loader.dart';
import 'tailor_alter_dishdasha_screen.dart';
import 'package:hindam/shared/widgets/any_image.dart';

/// الأقسام الثلاثة
enum _Section { tailoring, alter, store }

class TailorStoreScreen extends StatefulWidget {
  final String tailorId;
  final String tailorName;
  final String? imageUrl;
  final int? reviewsCount;
  final double? serviceFeeOMR;

  const TailorStoreScreen({
    super.key,
    required this.tailorId,
    required this.tailorName,
    this.imageUrl,
    this.reviewsCount,
    this.serviceFeeOMR,
  });

  @override
  State<TailorStoreScreen> createState() => _TailorStoreScreenState();
}

class _TailorStoreScreenState extends State<TailorStoreScreen> {
  _Section _selected = _Section.tailoring;

  // ✅ مُساعد لمسارات الأصول داخل assets/fabrics/
  String _fabric(String name) => 'assets/fabrics/$name';

  // عناصر (خدمات/منتجات) مع نوع القسم — كل الصور محليّة من assets/fabrics/
  List<_Item> get _items => [
        // ===== التفصيل =====
        _Item(
          title: 'تفصيل دشداشة رجالي',
          price: 6.000,
          rating: 4.8,
          reviews: 320,
          image: _fabric('japanese_cotton.jpg'),
          kind: _Section.tailoring,
          pro: true,
        ),
        _Item(
          title: 'تفصيل دشداشة أطفال',
          price: 4.000,
          rating: 4.7,
          reviews: 140,
          image: _fabric('winter_wool.jpg'),
          kind: _Section.tailoring,
        ),

        // ===== التعديل =====
        _Item(
          title: 'تقصير/إطالة',
          price: 1.500,
          rating: 4.6,
          reviews: 210,
          image: _fabric('4.jpg'),
          kind: _Section.alter,
        ),
        _Item(
          title: 'توسيع/تضييق',
          price: 2.000,
          rating: 4.5,
          reviews: 180,
          image: _fabric('5.jpg'),
          kind: _Section.alter,
        ),

        // ===== المتجر =====
        _Item(
          title: 'قماش صيفي فاخر',
          price: 8.500,
          rating: 4.4,
          reviews: 95,
          image: _fabric('lux_silk.jpg'),
          kind: _Section.store,
        ),
        _Item(
          title: 'قماش قطني ياباني',
          price: 6.800,
          rating: 4.3,
          reviews: 60,
          image: _fabric('japanese_cotton.jpg'),
          kind: _Section.store,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final filtered = _items.where((e) => e.kind == _selected).toList();

    // زر الإجراء حسب القسم
    String ctaLabel;
    VoidCallback ctaAction;
    switch (_selected) {
      case _Section.tailoring:
        ctaLabel = 'تصميم وطلب الدشداشة';
        ctaAction = () {
          // التحقق من تسجيل الدخول
          final authProvider =
              Provider.of<AuthProvider>(context, listen: false);
          if (!authProvider.isAuthenticated) {
            // إظهار مربع حوار لتسجيل الدخول
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('تسجيل الدخول مطلوب'),
                  ],
                ),
                content: const Text(
                  'لطلب الخدمة، يرجى تسجيل الدخول أولاً.\n'
                  'يمكنك إنشاء حساب جديد في ثوانٍ.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('إلغاء'),
                  ),
                  FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.push('/login');
                    },
                    child: const Text('تسجيل الدخول'),
                  ),
                ],
              ),
            );
            return;
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TailorDesignLoaderScreen(
                  tailorId: widget.tailorId, tailorName: widget.tailorName),
            ),
          );
        };
        break;
      case _Section.alter:
        ctaLabel = 'طلب تعديل دشداشة';
        ctaAction = () {
          // التحقق من تسجيل الدخول
          final authProvider =
              Provider.of<AuthProvider>(context, listen: false);
          if (!authProvider.isAuthenticated) {
            // إظهار مربع حوار لتسجيل الدخول
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('تسجيل الدخول مطلوب'),
                  ],
                ),
                content: const Text(
                  'لطلب الخدمة، يرجى تسجيل الدخول أولاً.\n'
                  'يمكنك إنشاء حساب جديد في ثوانٍ.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('إلغاء'),
                  ),
                  FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.push('/login');
                    },
                    child: const Text('تسجيل الدخول'),
                  ),
                ],
              ),
            );
            return;
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TailorAlterDishdashaScreen(
                tailorId: widget.tailorId,
                tailorName: widget.tailorName,
                imageUrl: widget.imageUrl,
                basePriceOMR: 1.500,
                serviceTitle: 'تعديل دشداشة',
              ),
            ),
          );
        };
        break;
      case _Section.store:
        ctaLabel = 'إضافة منتج من المتجر';
        ctaAction = () {
          final firstStore = _items.firstWhere(
            (e) => e.kind == _Section.store,
            orElse: () => filtered.first,
          );
          _openProductSheet(context, firstStore);
        };
        break;
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: cs.surface,

        // ✅ زر الإجراء أصبح في bottomNavigationBar بدل Positioned داخل Stack
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: FilledButton.icon(
              onPressed: ctaAction,
              icon: Icon(
                _selected == _Section.store
                    ? Icons.add_shopping_cart_rounded
                    : Icons.shopping_bag_rounded,
              ),
              label: Text(ctaLabel),
              style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52)),
            ),
          ),
        ),

        // ✅ Scroll واحدة أساسية باستخدام Slivers
        body: SafeArea(
          child: CustomScrollView(
            primary: true,
            slivers: [
              // خلفية عليا متدرجة + هيدر
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFFF7A00), Color(0xFFFF6F00)],
                    ),
                  ),
                  child: Column(
                    children: [
                      // هيدر: صورة + اسم + مدينة + تقييم
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                        child: Row(
                          children: [
                            _Avatar(imageUrl: widget.imageUrl),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.tailorName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: tt.titleLarge?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on_outlined,
                                          size: 16, color: Colors.white),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          'مسقط',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: tt.bodySmall?.copyWith(
                                            color: Colors.white.withOpacity(.9),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            _RatingPill(
                              rating: 4.5,
                              reviews: widget.reviewsCount,
                            ),
                          ],
                        ),
                      ),

                      // شريط بحث
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _SearchBar(
                          hint: 'ابحث داخل ${_sectionTitle(_selected)}',
                          onSubmitted: (_) {},
                        ),
                      ),

                      const SizedBox(height: 18),
                      // حافة علوية للمحتوى الأبيض
                      Container(
                        height: 18,
                        decoration: BoxDecoration(
                          color: cs.surface,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(28)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(.04),
                              blurRadius: 12,
                              offset: const Offset(0, -2),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- دوائر الأقسام الثلاثة ---
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: _SectionCircles(
                    selected: _selected,
                    onSelect: (s) {
                      if (s == _Section.tailoring) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TailorDesignLoaderScreen(
                                tailorId: widget.tailorId,
                                tailorName: widget.tailorName),
                          ),
                        );
                      } else {
                        setState(() => _selected = s);
                      }
                    },
                  ),
                ),
              ),

              // عنوان القسم
              SliverToBoxAdapter(
                  child: _SectionTitle(title: _sectionTitle(_selected))),

              // محتوى القسم
              if (_selected == _Section.store)
                // ✅ منتجات المتجر كـ SliverGrid (أفضل أداء وتمرير واحد)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverLayoutBuilder(
                    builder: (context, constraints) {
                      final isNarrow = constraints.crossAxisExtent < 380;
                      final ratio = isNarrow ? 0.72 : 0.76;
                      return SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: ratio,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, i) {
                            final it = filtered[i];
                            return _StoreTile(
                              item: it,
                              onAdd: () => _openProductSheet(context, it),
                            );
                          },
                          childCount: filtered.length,
                        ),
                      );
                    },
                  ),
                )
              else
                // ✅ خدمات (تفصيل/تعديل) داخل SliverToBoxAdapter
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 244,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (_, i) => _ServiceCard(
                        item: filtered[i],
                        onTap: () {
                          if (filtered[i].kind == _Section.tailoring) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TailorDesignLoaderScreen(
                                    tailorId: widget.tailorId,
                                    tailorName: widget.tailorName),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TailorAlterDishdashaScreen(
                                  tailorId: widget.tailorId,
                                  tailorName: widget.tailorName,
                                  imageUrl: widget.imageUrl,
                                  basePriceOMR: filtered[i].price,
                                  serviceTitle: filtered[i].title,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ),

              // مسافة سفليّة بسيطة (لأن الزر صار في bottomNavigationBar)
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
            ],
          ),
        ),
      ),
    );
  }

  String _sectionTitle(_Section s) {
    switch (s) {
      case _Section.tailoring:
        return 'التفصيل';
      case _Section.alter:
        return 'التعديل دشداشة';
      case _Section.store:
        return 'المتجر';
    }
  }

  // ورقة إضافة منتج (قسم المتجر)
  void _openProductSheet(BuildContext context, _Item item) {
    final tt = Theme.of(context).textTheme;
    final qtyCtrl = TextEditingController(text: '1');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 8,
              bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    style:
                        tt.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'السعر: ر.ع ${item.price.toStringAsFixed(3)}',
                        style: tt.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    SizedBox(
                      width: 120,
                      child: TextField(
                        controller: qtyCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'الكمية',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('أُضيف "${item.title}" إلى السلة')),
                    );
                  },
                  icon: const Icon(Icons.add_shopping_cart_rounded),
                  label: const Text('إضافة إلى السلة'),
                  style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/* ======================= Widgets مساعدة ======================= */

class _Avatar extends StatelessWidget {
  final String? imageUrl;
  const _Avatar({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(.5), width: 2),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(.08),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: ClipOval(
        child: AnyImage(
          src: imageUrl,
          fit: BoxFit.cover,
          fallback: Container(
            color: cs.surfaceContainerHighest,
            alignment: Alignment.center,
            child:
                Icon(Icons.cut_rounded, size: 26, color: cs.onSurfaceVariant),
          ),
        ),
      ),
    );
  }
}

class _RatingPill extends StatelessWidget {
  final double rating;
  final int? reviews;
  const _RatingPill({required this.rating, this.reviews});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          const Icon(Icons.star_rate_rounded, color: Color(0xFFFFD54F)),
          const SizedBox(width: 2),
          Text(rating.toStringAsFixed(1),
              style: tt.titleMedium
                  ?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
          if (reviews != null) ...[
            const SizedBox(width: 6),
            Text('($reviews)',
                style: tt.bodySmall
                    ?.copyWith(color: Colors.white.withOpacity(.9))),
          ],
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final String hint;
  final ValueChanged<String>? onSubmitted;
  const _SearchBar({required this.hint, this.onSubmitted});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(.06),
              blurRadius: 12,
              offset: const Offset(0, 6))
        ],
      ),
      child: TextField(
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          border: InputBorder.none,
          prefixIcon: const Icon(Icons.search_rounded),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Row(
        children: [
          Text(title,
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
          const Spacer(),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              foregroundColor: cs.primary,
            ),
            child: const Text('عرض الكل'),
          ),
        ],
      ),
    );
  }
}

class _Item {
  final String title;
  final double price;
  final double rating;
  final int reviews;
  final String image; // أصل محلي من assets/fabrics/
  final _Section kind;
  final bool pro;
  _Item({
    required this.title,
    required this.price,
    required this.rating,
    required this.reviews,
    required this.image,
    required this.kind,
    this.pro = false,
  });
}

class _ServiceCard extends StatelessWidget {
  final _Item item;
  final VoidCallback? onTap;
  const _ServiceCard({required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 220,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 136,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AnyImage(
                      src: item.image,
                      fit: BoxFit.cover,
                      fallback: Container(
                        color: cs.surfaceContainerHighest,
                        alignment: Alignment.center,
                        child: Icon(Icons.cut_rounded,
                            size: 28, color: cs.onSurfaceVariant),
                      ),
                    ),
                    if (item.pro)
                      PositionedDirectional(
                        start: 8,
                        top: 8,
                        child: Container(
                          height: 22,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: cs.primary.withOpacity(.12),
                            borderRadius: BorderRadius.circular(6),
                            border:
                                Border.all(color: cs.primary.withOpacity(.22)),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'PRO',
                            style: tt.labelSmall?.copyWith(
                              color: cs.primary,
                              fontWeight: FontWeight.w900,
                              letterSpacing: .5,
                            ),
                          ),
                        ),
                      ),
                    PositionedDirectional(
                      end: 8,
                      top: 8,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(.08),
                                blurRadius: 10,
                                offset: const Offset(0, 4))
                          ],
                        ),
                        child: const SizedBox(
                          width: 34,
                          height: 34,
                          child: Icon(Icons.favorite_border_rounded, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 10),
                child: Row(
                  children: [
                    const Icon(Icons.star_rate_rounded,
                        size: 18, color: Color(0xFFFFA000)),
                    const SizedBox(width: 2),
                    Text(item.rating.toStringAsFixed(1),
                        style: tt.labelLarge
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(width: 4),
                    Text('(${item.reviews})',
                        style:
                            tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: Text('ر.ع ${item.price.toStringAsFixed(3)}',
                    style:
                        tt.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// بطاقة منتج للمتجر تُستخدم داخل SliverGrid
class _StoreTile extends StatelessWidget {
  final _Item item;
  final VoidCallback onAdd;
  const _StoreTile({required this.item, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onAdd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AnyImage(
                src: item.image,
                fit: BoxFit.cover,
                fallback: Container(
                  color: cs.surfaceContainerHighest,
                  alignment: Alignment.center,
                  child: Icon(Icons.shop_2_rounded,
                      size: 22, color: cs.onSurfaceVariant),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
              child: Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'ر.ع ${item.price.toStringAsFixed(3)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          tt.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                    ),
                  ),
                  IconButton.filledTonal(
                    onPressed: onAdd,
                    icon: const Icon(Icons.add_shopping_cart_rounded, size: 20),
                    style: IconButton.styleFrom(
                      fixedSize: const Size(38, 38),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCircles extends StatelessWidget {
  final _Section selected;
  final ValueChanged<_Section> onSelect;
  const _SectionCircles({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    const items = [
      (_Section.tailoring, Icons.checkroom_rounded, 'التفصيل'),
      (_Section.alter, Icons.cut_rounded, 'التعديل دشداشة'),
      (_Section.store, Icons.shop_two_rounded, 'المتجر'),
    ];

    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final circle = w >= 360 ? 78.0 : 72.0;

        return Row(
          children: List.generate(items.length, (i) {
            final (section, icon, label) = items[i];
            return Expanded(
              child: _CircleSectionButton(
                icon: icon,
                label: label,
                isSelected: selected == section,
                size: circle,
                onTap: () => onSelect(section),
              ),
            );
          }),
        );
      },
    );
  }
}

class _CircleSectionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final double size;
  final VoidCallback onTap;

  const _CircleSectionButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected ? cs.primaryContainer : cs.surface,
            border: Border.all(
                color: isSelected ? cs.primary : cs.outlineVariant,
                width: isSelected ? 2 : 1),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                    color: cs.primary.withOpacity(.18),
                    blurRadius: 16,
                    offset: const Offset(0, 6))
            ],
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onTap,
              child: Icon(
                icon,
                size: isSelected ? 30 : 26,
                color: isSelected ? cs.onPrimaryContainer : cs.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: size + 12,
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: tt.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface),
          ),
        ),
      ],
    );
  }
}
