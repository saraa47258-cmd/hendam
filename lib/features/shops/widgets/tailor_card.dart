import 'package:flutter/material.dart';
import 'dart:ui'; // للـ Blur
import 'package:hindam/l10n/app_localizations.dart';
import '../../../features/favorites/widgets/favorite_button.dart';

// ===== النموذج =====
class Tailor {
  final String id;
  final String name;
  final String city;
  final double rating;
  final List<String> tags;
  final String? imageUrl;

  Tailor({
    required this.id,
    required this.name,
    required this.city,
    required this.rating,
    required this.tags,
    this.imageUrl,
  });
}

// ===== البطاقة (تصميم جديد) =====
class TailorCard extends StatelessWidget {
  final Tailor tailor;
  final bool isOpen;
  final double? distanceKm;
  final VoidCallback? onTap;
  final VoidCallback? onBook;
  final VoidCallback? onChat;

  // اختياري: هيرو للصورة إن أحببت
  final String? heroTag;

  const TailorCard({
    super.key,
    required this.tailor,
    this.isOpen = true,
    this.distanceKm,
    this.onTap,
    this.onBook,
    this.onChat,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Card(
      elevation: 6,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: InkWell(
          onTap: onTap,
          splashColor: cs.primary.withOpacity(0.06),
          highlightColor: cs.primary.withOpacity(0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ===== الهيدر (صورة + شرائح معلومات) =====
              _HeaderImage(
                imageUrl: tailor.imageUrl,
                heroTag: heroTag,
                overlayGradient: const [
                  Color(0xCC000000),
                  Color(0x33000000),
                  Colors.transparent,
                ],
                topLeft: _StatusChip(isOpen: isOpen),
                topRight: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // زر المفضلة
                    FavoriteButton(
                      productId: tailor.id,
                      productType: 'tailor',
                      productData: {
                        'name': tailor.name,
                        'city': tailor.city,
                        'rating': tailor.rating.toString(),
                        'imageUrl': tailor.imageUrl ?? '',
                        'tags': tailor.tags.join(', '),
                      },
                      iconColor: Colors.white,
                      iconSize: 24,
                    ),
                    if (distanceKm != null) ...[
                      const SizedBox(width: 8),
                      _GlassPill(
                        child: Row(
                          children: [
                            const Icon(Icons.location_on,
                                color: Colors.white, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${distanceKm!.toStringAsFixed(1)} كم',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                bottomLeft: _GlassPill(
                  child: Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        tailor.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ===== المحتوى السفلي =====
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // الاسم + المدينة
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            tailor.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: tt.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.place_rounded,
                            size: 16, color: cs.onSurfaceVariant),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            tailor.city,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: tt.bodyMedium
                                ?.copyWith(color: cs.onSurfaceVariant),
                          ),
                        ),
                      ],
                    ),

                    // الوسوم (بشكل أفقي أنيق + عدّاد إضافي)
                    if (tailor.tags.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _TagsRow(tags: tailor.tags, maxVisible: 4),
                    ],

                    const SizedBox(height: 14),

                    // الأزرار
                    Row(
                      children: [
                        SizedBox(
                          height: 46,
                          width: 46,
                          child: OutlinedButton(
                            onPressed: onChat,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: cs.outlineVariant),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            child:
                                const Icon(Icons.chat_bubble_outline_rounded),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 46,
                            child: FilledButton.icon(
                              onPressed: onBook,
                              icon: const Icon(Icons.calendar_today_outlined,
                                  size: 18),
                              label: Text(l10n.bookAppointment),
                              style: FilledButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                textStyle: tt.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.1,
                                ),
                              ),
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
    )
  }
}

// ===== مكونات مساعدة =====

class _HeaderImage extends StatelessWidget {
  final String? imageUrl;
  final String? heroTag;
  final List<Color> overlayGradient;
  final Widget? topLeft;
  final Widget? topRight;
  final Widget? bottomLeft;

  const _HeaderImage({
    required this.imageUrl,
    required this.overlayGradient,
    this.heroTag,
    this.topLeft,
    this.topRight,
    this.bottomLeft,
  });

  @override
  Widget build(BuildContext context) {
    final image = _NetworkOrPlaceholderImage(url: imageUrl);

    Widget content = Stack(
      fit: StackFit.expand,
      children: [
        image,

        // تدرّج لوني لتحسين قراءة النص
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: overlayGradient,
              stops: const [0.0, 0.55, 1.0],
            ),
          ),
        ),

        // أعلى
        PositionedDirectional(
          start: 12,
          top: 12,
          child: topLeft ?? const SizedBox.shrink(),
        ),
        PositionedDirectional(
          end: 12,
          top: 12,
          child: topRight ?? const SizedBox.shrink(),
        ),

        // أسفل
        PositionedDirectional(
          start: 12,
          bottom: 12,
          child: bottomLeft ?? const SizedBox.shrink(),
        ),
      ],
    );

    // نسبة أبعاد مرنة للصورة
    content = AspectRatio(aspectRatio: 16 / 9, child: content);

    // دعم الـ Hero اختياري
    if (heroTag != null && heroTag!.isNotEmpty) {
      content = Hero(tag: heroTag!, child: content);
    }
    return content;
  }
}

class _NetworkOrPlaceholderImage extends StatelessWidget {
  final String? url;
  const _NetworkOrPlaceholderImage({this.url});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (url == null || url!.isEmpty) {
      return _PlaceholderBanner(
          color1: cs.primaryContainer, color2: cs.tertiaryContainer);
    }
    return Image.network(
      url!,
      fit: BoxFit.cover,
      // Fade-in بسيط عند تحميل الإطار الأول
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
          child: child,
        );
      },
      // مؤشر تحميل وFallback عند الخطأ
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Stack(
          fit: StackFit.expand,
          children: [
            _PlaceholderBanner(
                color1: cs.primaryContainer, color2: cs.tertiaryContainer),
            const Center(child: CircularProgressIndicator(strokeWidth: 2.4)),
          ],
        );
      },
      errorBuilder: (_, __, ___) {
        return _PlaceholderBanner(
            color1: cs.errorContainer, color2: cs.tertiaryContainer);
      },
    );
  }
}

class _PlaceholderBanner extends StatelessWidget {
  final Color color1;
  final Color color2;
  const _PlaceholderBanner({required this.color1, required this.color2});

  @override
  Widget build(BuildContext context) {
    final onPrimary =
        Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.6);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color1, color2],
        ),
      ),
      child: Icon(Icons.storefront_rounded, size: 64, color: onPrimary),
    );
  }
}

class _GlassPill extends StatelessWidget {
  final Widget child;
  const _GlassPill({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.22),
            borderRadius: BorderRadius.circular(20),
            border:
                Border.all(color: Colors.white.withOpacity(0.35), width: 0.8),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final bool isOpen;
  const _StatusChip({required this.isOpen});

  @override
  Widget build(BuildContext context) {
    final color = isOpen ? Colors.greenAccent : Colors.redAccent;
    return _GlassPill(
      child: Row(
        children: [
          Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(
            isOpen ? 'مفتوح الآن' : 'مغلق',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _TagsRow extends StatelessWidget {
  final List<String> tags;
  final int maxVisible;
  const _TagsRow({required this.tags, this.maxVisible = 4});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final visible = tags.take(maxVisible).toList();
    final remain = tags.length - visible.length;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          ...visible.map(
            (t) => Container(
              margin: const EdgeInsetsDirectional.only(end: 8),
              child: Chip(
                label: Text(t, maxLines: 1, overflow: TextOverflow.ellipsis),
                labelStyle: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                side: BorderSide.none,
                backgroundColor: cs.secondaryContainer.withOpacity(0.55),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ),
          if (remain > 0)
            Container(
              margin: const EdgeInsetsDirectional.only(end: 8),
              child: Chip(
                label: Text('+$remain',
                    style: Theme.of(context).textTheme.labelMedium),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                side: BorderSide.none,
                backgroundColor: cs.surfaceContainerHighest.withOpacity(0.6),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
            ),
        ],
      ),
    );
  }
}
