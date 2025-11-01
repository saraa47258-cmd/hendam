// lib/features/tailors/presentation/nearby_tailors_pretty.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/tailor_item.dart';

class NearbyTailorsPretty extends StatelessWidget {
  final List<TailorItem> items;
  final ValueChanged<TailorItem>? onTapCard;
  final ValueChanged<TailorItem>? onCall;
  final ValueChanged<TailorItem>? onMap;

  const NearbyTailorsPretty({
    super.key,
    required this.items,
    this.onTapCard,
    this.onCall,
    this.onMap,
  });

  /// ارتفاع متكيّف حسب الجهاز وتكبير الخط
  static double preferredHeight(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final textScale = MediaQuery.textScaleFactorOf(context);
    final isShort = size.height < 700;
    double h = 160;              // الأساس
    if (textScale > 1.1) h += 8; // لو الخط مكبّر
    if (isShort) h -= 8;         // أجهزة قصيرة
    return h;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final w = MediaQuery.sizeOf(context).width;
    final h = preferredHeight(context);

    // عرض البطاقة كنسبة من الشاشة + حد أدنى
    final cardW = math.max(260.0, w * 0.78);
    final cardH = h - 4; // هامش صغير يمنع القص

    if (items.isEmpty) {
      return Container(
        height: h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'لا توجد محلات قريبة حالياً',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return SizedBox(
      height: h,
      child: ListView.separated(
        clipBehavior: Clip.none, // لا تقص الظلال خارج البطاقات
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsetsDirectional.only(start: 2, end: 2),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final t = items[i];
          return _TailorCard(
            item: t,
            width: cardW,
            height: cardH,
            onTap: () => onTapCard?.call(t),
            onCall: () => onCall?.call(t),
            onMap: () => onMap?.call(t),
          );
        },
      ),
    );
  }
}

class _TailorCard extends StatelessWidget {
  final TailorItem item;
  final double width;
  final double height;
  final VoidCallback? onTap;
  final VoidCallback? onCall;
  final VoidCallback? onMap;

  const _TailorCard({
    required this.item,
    required this.width,
    required this.height,
    this.onTap,
    this.onCall,
    this.onMap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    const radius = 16.0;

    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(radius),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  cs.surfaceContainerHighest,
                  cs.secondaryContainer.withOpacity(.85),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.06),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
              border: Border.all(color: cs.outlineVariant),
            ),
            // نقصّ المحتوى الداخلي فقط (بدلاً من Ink.clipBehavior)
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // الصف العلوي: التقييم + المسافة + الحالة
                    Row(
                      children: [
                        _badge(
                          context,
                          icon: Icons.star_rounded,
                          label: item.rating.toStringAsFixed(1),
                        ),
                        const SizedBox(width: 8),
                        _badge(
                          context,
                          icon: Icons.place_outlined,
                          label: '${item.distanceKm.toStringAsFixed(1)} كم',
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Icon(
                              Icons.circle,
                              size: 10,
                              color: item.isOpen ? Colors.green : cs.error,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              item.isOpen ? 'مفتوح الآن' : 'مغلق حاليًا',
                              style: tt.labelSmall?.copyWith(
                                color: cs.onSurfaceVariant,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // الاسم
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                    ),

                    const SizedBox(height: 6),

                    // التاجات
                    Flexible(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children:
                          item.tags.take(3).map((t) => _chip(context, t)).toList(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // الأزرار السفلية
                    Row(
                      children: [
                        _pillBtn(
                          context,
                          icon: Icons.call_rounded,
                          label: 'اتصال',
                          onTap: onCall,
                        ),
                        const SizedBox(width: 8),
                        _pillBtn(
                          context,
                          icon: Icons.map_outlined,
                          label: 'خريطة',
                          onTap: onMap,
                        ),
                        const Spacer(),
                        const Icon(Icons.chevron_right_rounded),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _badge(BuildContext context, {required IconData icon, required String label}) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: cs.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, String text) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: cs.onPrimaryContainer,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _pillBtn(BuildContext context,
      {required IconData icon, required String label, VoidCallback? onTap}) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(icon, size: 18, color: cs.primary),
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
