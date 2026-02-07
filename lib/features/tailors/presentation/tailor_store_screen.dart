// lib/features/tailors/presentation/tailor_store_screen.dart
import 'package:flutter/material.dart';
import 'tailor_design_loader.dart';
import 'package:hindam/shared/widgets/any_image.dart';

/// الأقسام
enum _Section { tailoring, store }

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
  // ✅ مُساعد لمسارات الأصول داخل assets/fabrics/
  String _fabric(String name) => 'assets/fabrics/$name';

  // عناصر (خدمات/منتجات) مع نوع القسم — كل الصور محليّة من assets/fabrics/
  List<_Item> get _items => [
        // ===== الخدمات =====
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
    final filtered = _items.where((e) => e.kind == _Section.tailoring).toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: cs.surface,

        bottomNavigationBar: null,

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
                          hint: 'ابحث داخل الخدمات',
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

              // عنوان القسم (الخدمات فقط — تم إزالة أيقونتي هدية/الخدمات)
              SliverToBoxAdapter(child: _SectionTitle(title: 'الخدمات')),

              // محتوى القسم — الخدمات فقط
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.0, // بطاقات مربعة
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final it = filtered[i];
                      return _ServiceGridCard(
                        item: it,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TailorDesignLoaderScreen(
                                tailorId: widget.tailorId,
                                tailorName: widget.tailorName,
                              ),
                            ),
                          );
                        },
                      );
                    },
                    childCount: filtered.length,
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

/// بطاقة خدمة مربعة أنيقة للشبكة
class _ServiceGridCard extends StatelessWidget {
  final _Item item;
  final VoidCallback? onTap;
  const _ServiceGridCard({required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: cs.outlineVariant.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 6),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: cs.shadow.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // === صورة الخدمة ===
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      AnyImage(
                        src: item.image,
                        fit: BoxFit.cover,
                        fallback: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                cs.primaryContainer.withOpacity(0.3),
                                cs.primaryContainer.withOpacity(0.1),
                              ],
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.checkroom_rounded,
                            size: 40,
                            color: cs.primary.withOpacity(0.5),
                          ),
                        ),
                      ),
                      // تدرج سفلي للوضوح
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 40,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.15),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // === معلومات الخدمة ===
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // اسم الخدمة
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tt.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // التقييم
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: Color(0xFFFFA000),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          item.rating.toStringAsFixed(1),
                          style: tt.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFE65100),
                          ),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '(${item.reviews})',
                          style: tt.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// بطاقة هدية مربعة أنيقة للشبكة
class _GiftGridCard extends StatelessWidget {
  final _Item item;
  final VoidCallback? onTap;
  const _GiftGridCard({required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFE91E63).withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE91E63).withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
              spreadRadius: 0,
            ),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // === صورة المنتج مع شارة الهدية ===
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      AnyImage(
                        src: item.image,
                        fit: BoxFit.cover,
                        fallback: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFFFCE4EC),
                                const Color(0xFFF8BBD9).withOpacity(0.5),
                              ],
                            ),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.card_giftcard_rounded,
                            size: 40,
                            color: Color(0xFFE91E63),
                          ),
                        ),
                      ),
                      // شارة الهدية
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE91E63),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFE91E63).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.card_giftcard_rounded,
                                size: 12,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'هدية',
                                style: tt.labelSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // تدرج سفلي
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 40,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                const Color(0xFFE91E63).withOpacity(0.1),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // === معلومات المنتج ===
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tt.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: Color(0xFFFFA000),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          item.rating.toStringAsFixed(1),
                          style: tt.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFE65100),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFCE4EC),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${item.price.toStringAsFixed(3)} ر.ع',
                            style: tt.labelSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFE91E63),
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
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
