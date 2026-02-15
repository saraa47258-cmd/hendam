import 'dart:ui';
import 'package:flutter/material.dart';

/// نموذج بسيط للعرض في القوائم
class ServiceItem {
  final String name;
  final double price;
  final double rating;
  final String variantsLabel;
  const ServiceItem({
    required this.name,
    required this.price,
    required this.rating,
    required this.variantsLabel,
  });
}

/// شاشة عامة تُستخدم لكل قسم
class SectionServicesScreen extends StatelessWidget {
  final String title;
  final List<ServiceItem> items;

  const SectionServicesScreen({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text(title)),
        backgroundColor: cs.surface,
        body: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) => _ServiceListCard(item: items[i]),
        ),
      ),
    );
  }
}

/* ======= بطاقات القائمة ======= */

class _ServiceListCard extends StatefulWidget {
  final ServiceItem item;
  const _ServiceListCard({required this.item});

  @override
  State<_ServiceListCard> createState() => _ServiceListCardState();
}

class _ServiceListCardState extends State<_ServiceListCard> {
  bool fav = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            // صورة/تدرج بديل (بدون أصول)
            SizedBox(
              width: 120,
              height: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _GradientTileBackground(),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.black.withOpacity(.12), Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                  const Center(child: Icon(Icons.checkroom, size: 40)),
                  PositionedDirectional(
                    top: 8,
                    end: 8,
                    child: _IconGlass(
                      icon: fav ? Icons.favorite : Icons.favorite_border,
                      color: fav ? Colors.redAccent : Colors.white,
                      onTap: () => setState(() => fav = !fav),
                    ),
                  ),
                ],
              ),
            ),

            // تفاصيل
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        ...List.generate(
                          5,
                              (i) => Icon(
                            i < widget.item.rating.round()
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            size: 16,
                            color: Colors.amber,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.item.variantsLabel,
                          style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Text(
                          'ر.ع ${widget.item.price.toStringAsFixed(2)}',
                          style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const Spacer(),
                        FilledButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.add_shopping_cart_rounded, size: 18),
                          label: const Text('أضف'),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(0, 40),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
    );
  }
}

class _GradientTileBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primaryContainer, cs.tertiaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}

class _IconGlass extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;
  const _IconGlass({required this.icon, this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Material(
          color: Colors.white.withOpacity(.22),
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: 36,
              height: 36,
              child: Icon(icon, color: color ?? Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

/* ========= صفحات الأقسام (رجالي/عبايات/تاجر صغير) ========= */

class MenServicesScreen extends StatelessWidget {
  const MenServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SectionServicesScreen(
      title: 'الخياطة الرجالي',
      items: [
        ServiceItem(name: 'تفصيل دشداشة عمانية', price: 7.00, rating: 5, variantsLabel: '5 أقمشة'),
        ServiceItem(name: 'تفصيل ثوب سعودي',      price: 8.00, rating: 4, variantsLabel: '3 أقمشة'),
        ServiceItem(name: 'تعديل ياقة وأكمام',    price: 2.50, rating: 4, variantsLabel: '2 أقمشة'),
      ],
    );
  }
}

class AbayaServicesScreen extends StatelessWidget {
  const AbayaServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SectionServicesScreen(
      title: 'العبايات',
      items: [
        ServiceItem(name: 'تفصيل عباية كريب',  price: 9.50, rating: 5, variantsLabel: '6 ألوان'),
        ServiceItem(name: 'تفصيل عباية رسمية', price: 10.00, rating: 4, variantsLabel: '4 ألوان'),
        ServiceItem(name: 'تطريز نقشة',        price: 3.00,  rating: 4, variantsLabel: '8 ألوان'),
      ],
    );
  }
}

class SmallMerchantScreen extends StatelessWidget {
  const SmallMerchantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SectionServicesScreen(
      title: 'التاجر الصغير',
      items: [
        ServiceItem(name: 'تفصيل أطفال (دشداشة)', price: 4.00, rating: 5, variantsLabel: '3 خيارات'),
        ServiceItem(name: 'تقصير/تعديل بسيط',     price: 1.00, rating: 4, variantsLabel: '2 خيارات'),
        ServiceItem(name: 'قبعات/اكسسوارات',      price: 0.80, rating: 4, variantsLabel: '5 خيارات'),
      ],
    );
  }
}
