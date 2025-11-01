import 'dart:ui';
import 'package:flutter/material.dart';

/// موديل الخياط
class TailorItem {
  final String name;
  final double rating;
  final double distanceKm;
  final bool isOpen;
  final List<String> tags; // مثل: ['تطريز', 'تسليم سريع']
  final String? imageUrl;   // إن وُجدت صورة للمتجر

  const TailorItem({
    required this.name,
    required this.rating,
    required this.distanceKm,
    required this.isOpen,
    this.tags = const [],
    this.imageUrl,
  });
}

/// بيانات تجريبية
const List<TailorItem> demoTailors = [
  TailorItem(
    name: 'خياط الأناقة',
    rating: 4.9,
    distanceKm: 0.8,
    isOpen: true,
    tags: ['تسليم سريع', 'دشداشة رجالي'],
  ),
  TailorItem(
    name: 'مركز النخبة',
    rating: 4.6,
    distanceKm: 1.2,
    isOpen: false,
    tags: ['تطريز عُماني', 'قياس منزلي'],
  ),
  TailorItem(
    name: 'لمسة فاشن',
    rating: 4.5,
    distanceKm: 1.9,
    isOpen: true,
    tags: ['عبايات', 'خياطة ناعمة'],
  ),
];

/// القائمة الأفقية الجميلة للخياطين
class NearbyTailorsPretty extends StatelessWidget {
  final List<TailorItem> items;
  final ValueChanged<TailorItem>? onTapCard;
  final void Function(TailorItem)? onCall;
  final void Function(TailorItem)? onMap;

  const NearbyTailorsPretty({
    super.key,
    required this.items,
    this.onTapCard,
    this.onCall,
    this.onMap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return SizedBox(
      height: 190,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        padding: const EdgeInsetsDirectional.only(end: 4),
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final t = items[i];

          return SizedBox(
            width: 260,
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(18),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => onTapCard?.call(t),
                child: Ink(
                  height: 190,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: t.imageUrl == null
                          ? [cs.primaryContainer, cs.tertiaryContainer]
                          : [cs.surfaceContainerHighest, cs.surfaceContainerHighest],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // خلفية صورة إن توفرت
                      if (t.imageUrl != null)
                        Positioned.fill(
                          child: Ink.image(
                            image: NetworkImage(t.imageUrl!),
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                      // أيقونة خفيفة كخلفية
                        Positioned.fill(
                          child: Align(
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.storefront_rounded,
                              size: 80,
                              color: Colors.white.withOpacity(.18),
                            ),
                          ),
                        ),

                      // لمعة خفيفة
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withOpacity(.10),
                                Colors.transparent
                              ],
                            ),
                          ),
                        ),
                      ),

                      // شارة التقييم (أعلى يمين)
                      PositionedDirectional(
                        top: 10,
                        end: 10,
                        child: _GlassPill(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                t.rating.toStringAsFixed(1),
                                style: tt.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // شارة المسافة (أعلى يسار)
                      PositionedDirectional(
                        top: 10,
                        start: 10,
                        child: _GlassPill(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.location_on, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '${t.distanceKm.toStringAsFixed(1)} كم',
                                style: tt.labelMedium,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // الشريط السفلي المثلّج (الاسم + الحالة + الوسوم + أزرار)
                      PositionedDirectional(
                        start: 8,
                        end: 8,
                        bottom: 8,
                        child: _FrostedBar(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // الاسم + الحالة
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      t.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: tt.titleSmall?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _OpenDot(isOpen: t.isOpen),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // الوسوم (إن وجدت)
                              if (t.tags.isNotEmpty)
                                ConstrainedBox(
                                  constraints: const BoxConstraints(maxHeight: 28),
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    itemCount: t.tags.length,
                                    separatorBuilder: (_, __) =>
                                    const SizedBox(width: 6),
                                    itemBuilder: (_, idx) => _TinyTag(t.tags[idx]),
                                  ),
                                ),

                              const SizedBox(height: 10),

                              // أزرار سريعة
                              Row(
                                children: [
                                  _QuickBtn(
                                    icon: Icons.call_rounded,
                                    label: 'اتصال',
                                    onTap: () => onCall?.call(t),
                                  ),
                                  const SizedBox(width: 8),
                                  _QuickBtn(
                                    icon: Icons.directions_rounded,
                                    label: 'خريطة',
                                    onTap: () => onMap?.call(t),
                                  ),
                                  const Spacer(),
                                  const Icon(Icons.chevron_left_rounded,
                                      color: Colors.white),
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
            ),
          );
        },
      ),
    );
  }
}

/* ===================== عناصر مساعدة (داخل الملف) ===================== */

class _GlassPill extends StatelessWidget {
  final Widget child;
  const _GlassPill({required this.child});

  @override
  Widget build(BuildContext context) {
    return _FrostedBar(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: DefaultTextStyle.merge(
        style: Theme.of(context)
            .textTheme
            .labelMedium
            ?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
        child: IconTheme(
          data: IconThemeData(color: Colors.yellow.shade600),
          child: child,
        ),
      ),
    );
  }
}

class _FrostedBar extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const _FrostedBar({
    required this.child,
    this.padding = const EdgeInsets.all(12),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(.25),
            border: Border.all(color: Colors.white.withOpacity(.18)),
            borderRadius: BorderRadius.circular(14),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _OpenDot extends StatelessWidget {
  final bool isOpen;
  const _OpenDot({required this.isOpen});

  @override
  Widget build(BuildContext context) {
    final color = isOpen ? Colors.greenAccent : Colors.redAccent;
    final label = isOpen ? 'مفتوح الآن' : 'مغلق حالياً';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .labelSmall
              ?.copyWith(color: Colors.white),
        ),
      ],
    );
  }
}

class _TinyTag extends StatelessWidget {
  final String text;
  const _TinyTag(this.text);

  @override
  Widget build(BuildContext context) {
    return _FrostedBar(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _QuickBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  const _QuickBtn({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(.14),
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
