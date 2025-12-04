// lib/features/tailors/widgets/tailor_row_card.dart
import 'package:flutter/material.dart';
import '../models/tailor.dart';
import '../../../features/favorites/widgets/favorite_button.dart';

class TailorRowCard extends StatelessWidget {
  /// بيانات المتجر
  final Tailor tailor;

  /// قد يكون مسار أصل محلي مثل: 'assets/shops/1.jpg'
  /// أو رابط شبكة يبدأ بـ http
  final String? imageUrl;

  /// شارة قصيرة مثل "خياطة رجالي" (اختياري)
  final String? badge;

  /// عدد المراجعات (اختياري)
  final int? reviewsCount;

  /// رسم الخدمة بالريال العُماني (اختياري)
  final double? serviceFeeOMR;

  /// زمن الوصول المتوقع بالدقائق (اختياري)
  final RangeValues? etaMinutes;

  /// الضغط على كل البطاقة
  final VoidCallback? onTap;

  /// زر "المتجر" الصغير فوق الصورة
  final VoidCallback? onStoreTap;

  const TailorRowCard({
    super.key,
    required this.tailor,
    this.imageUrl,
    this.badge,
    this.reviewsCount,
    this.serviceFeeOMR,
    this.etaMinutes,
    this.onTap,
    this.onStoreTap,
  });

  /// اختيار مزوّد الصورة تلقائيًا
  ImageProvider? _pickImage(String? url) {
    final u = (url ?? '').trim();
    if (u.isEmpty) return null;
    if (u.startsWith('http')) return NetworkImage(u);
    return AssetImage(u);
  }

  String _fmtEta(RangeValues? v) {
    if (v == null) return '';
    final lo = v.start.round();
    final hi = v.end.round();
    return '$lo - $hi دقيقة';
  }

  String _fmtFee(double? v) {
    if (v == null) return '';
    return '${v.toStringAsFixed(3)} ر.ع';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final img = _pickImage(imageUrl);
    final hasBadge = (badge ?? '').isNotEmpty;
    final hasEta = etaMinutes != null;
    final hasFee = serviceFeeOMR != null && serviceFeeOMR! >= 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: cs.outlineVariant.withOpacity(0.7),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // صورة المتجر مع زر "المتجر"
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 84,
                      height: 84,
                      child: img != null
                          ? Image(
                              image: img,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _placeholder(cs),
                            )
                          : _placeholder(cs),
                    ),
                  ),
                  if (onStoreTap != null)
                    PositionedDirectional(
                      bottom: 6,
                      start: 6,
                      child: Material(
                        color: cs.surface.withOpacity(.9),
                        borderRadius: BorderRadius.circular(10),
                        child: InkWell(
                          onTap: onStoreTap,
                          borderRadius: BorderRadius.circular(10),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            child: Row(
                              children: [
                                Icon(Icons.storefront_rounded,
                                    size: 14, color: cs.primary),
                                const SizedBox(width: 4),
                                Text(
                                  'المتجر',
                                  style: tt.labelSmall?.copyWith(
                                    color: cs.primary,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),

              // التفاصيل
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // السطر الأول: الاسم + شارة pro تجميلية + زر المفضلة
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            tailor.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: tt.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              height: 1.1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: cs.primary.withOpacity(.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('pro',
                              style:
                                  tt.labelSmall?.copyWith(color: cs.primary)),
                        ),
                        const SizedBox(width: 8),
                        // زر المفضلة
                        FavoriteButton(
                          productId: tailor.id,
                          productType: 'tailor',
                          productData: {
                            'name': tailor.name,
                            'city': tailor.city,
                            'rating': tailor.rating.toStringAsFixed(1),
                          },
                          iconSize: 22,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    if (hasBadge)
                      Text(
                        badge!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            tt.labelLarge?.copyWith(color: cs.onSurfaceVariant),
                      ),

                    const SizedBox(height: 6),

                    // التقييم + (عدد المراجعات)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star_rate_rounded,
                            size: 18, color: Colors.amber.shade700),
                        const SizedBox(width: 4),
                        Text(
                          tailor.rating.toStringAsFixed(1),
                          style: tt.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        if ((reviewsCount ?? 0) > 0) ...[
                          const SizedBox(width: 6),
                          Text(
                            '($reviewsCount)',
                            style: tt.bodySmall
                                ?.copyWith(color: cs.onSurfaceVariant),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 8),

                    // المدينة + الزمن + الرسوم - محسن مع Flexible لتجنب overflow
                    Row(
                      children: [
                        Flexible(
                          child: _chip(context,
                              icon: Icons.place_rounded, label: tailor.city),
                        ),
                        if (hasEta) ...[
                          const SizedBox(width: 10),
                          Flexible(
                            child: _chip(context,
                                icon: Icons.timer_outlined,
                                label: _fmtEta(etaMinutes)),
                          ),
                        ],
                        if (hasFee) ...[
                          const SizedBox(width: 10),
                          Flexible(
                            child: _chip(context,
                                icon: Icons.attach_money_rounded,
                                label: _fmtFee(serviceFeeOMR)),
                          ),
                        ],
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

  Widget _placeholder(ColorScheme cs) => Container(
        color: cs.surfaceContainerHighest,
        child: const Center(child: Icon(Icons.image_outlined)),
      );

  Widget _chip(BuildContext ctx,
      {required IconData icon, required String? label}) {
    final text = (label ?? '').trim();
    if (text.isEmpty) return const SizedBox.shrink();

    final cs = Theme.of(ctx).colorScheme;
    final tt = Theme.of(ctx).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: cs.onSurfaceVariant),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: tt.labelSmall?.copyWith(color: cs.onSurface),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
