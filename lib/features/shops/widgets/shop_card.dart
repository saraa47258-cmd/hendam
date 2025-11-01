import 'package:flutter/material.dart';
import '../models/shop.dart';
import '../../../core/styles/responsive.dart';

class ShopCard extends StatelessWidget {
  final Shop shop;
  final VoidCallback? onTap;

  const ShopCard({super.key, required this.shop, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final borderRadius = context.responsiveRadius();

    return RepaintBoundary(
      child: Material(
        color: cs.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: BorderSide(color: cs.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ===== صورة/لوجو مع تدرّج سفلي وشارتيّن أعلى =====
              AspectRatio(
                aspectRatio: 16 / 11,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _ShopImage(imageUrl: shop.imageUrl),
                    // تدرّج سفلي لتحسين قراءة النص فوق الصورة
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: context.pick(56.0, tablet: 64.0, desktop: 72.0),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.35)
                            ],
                          ),
                        ),
                      ),
                    ),
                    // شارة الحالة
                    PositionedDirectional(
                      top: context.responsiveMargin(),
                      start: context.responsiveMargin(),
                      child: _ChipBadge(
                        label: shop.isOpen ? 'مفتوح' : 'مغلق',
                        bg: shop.isOpen ? Colors.green : cs.outline,
                        fg: Colors.white,
                      ),
                    ),
                    // أيقونة مفضلة شكلية
                    PositionedDirectional(
                      top: context.responsiveMargin() / 2,
                      end: context.responsiveMargin() / 2,
                      child: IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.favorite_border,
                            size: context.smallIconSize()),
                        color: Colors.white,
                        splashRadius: context.responsiveMargin(),
                      ),
                    ),
                    // تقييم فوق الصورة بأسفل اليمين
                    PositionedDirectional(
                      bottom: context.responsiveMargin(),
                      end: context.responsiveMargin(),
                      child: _RatingPill(value: shop.rating),
                    ),
                  ],
                ),
              ),

              // ===== تفاصيل مختصرة وأنيقة =====
              Padding(
                padding: EdgeInsets.fromLTRB(
                  context.responsivePadding(),
                  context.responsiveSpacing(),
                  context.responsivePadding(),
                  context.responsivePadding(),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // الاسم
                    Text(
                      shop.name,
                      style: TextStyle(
                        fontSize: context.responsiveFontSize(15.5),
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: context.responsiveMargin()),
                    // المنطقة/المدينة بشكل Chip خفيف
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: context.smallIconSize(),
                            color: cs.onSurfaceVariant),
                        SizedBox(width: context.responsiveMargin() / 2),
                        Expanded(
                          child: Text(
                            shop.city,
                            style: TextStyle(
                                fontSize: context.responsiveFontSize(12.5),
                                color: cs.onSurfaceVariant),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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

class _ShopImage extends StatelessWidget {
  final String imageUrl;
  const _ShopImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (imageUrl.isEmpty) {
      // لوجو/تدرّج افتراضي بدون أصول
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [cs.secondaryContainer, cs.primaryContainer],
          ),
        ),
        child: Center(
          child: CircleAvatar(
            radius: context.pick(26.0, tablet: 30.0, desktop: 34.0),
            backgroundColor: cs.surface.withOpacity(0.6),
            child: Icon(Icons.store_mall_directory,
                size: context.pick(28.0, tablet: 32.0, desktop: 36.0),
                color: cs.onSecondaryContainer),
          ),
        ),
      );
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      cacheWidth: 900,
      errorBuilder: (_, __, ___) => Container(
        color: cs.surfaceContainerHighest,
        child: Icon(Icons.store_mall_directory,
            size: context.pick(40.0, tablet: 44.0, desktop: 48.0),
            color: cs.onSurfaceVariant),
      ),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return _ShimmerPlaceholder();
      },
    );
  }
}

class _RatingPill extends StatelessWidget {
  final double value;
  const _RatingPill({required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fontSize = context.responsiveFontSize(12.0);
    final iconSize = context.pick(14.0, tablet: 16.0, desktop: 18.0);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.responsiveMargin(),
        vertical: context.responsiveMargin() / 2,
      ),
      decoration: BoxDecoration(
        color: cs.surface.withOpacity(0.85),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, size: iconSize, color: Colors.amber),
          SizedBox(width: context.responsiveMargin() / 2),
          Text(
            value.toStringAsFixed(1),
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipBadge extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  const _ChipBadge({required this.label, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    final fontSize = context.responsiveFontSize(11.0);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.responsiveMargin(),
        vertical: context.responsiveMargin() / 2,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: fontSize, color: fg, fontWeight: FontWeight.w600)),
    );
  }
}

class _ShimmerPlaceholder extends StatefulWidget {
  @override
  State<_ShimmerPlaceholder> createState() => _ShimmerPlaceholderState();
}

class _ShimmerPlaceholderState extends State<_ShimmerPlaceholder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1 + _c.value * 2, 0),
              end: Alignment(_c.value * 2, 0),
              colors: [
                cs.surfaceContainerHighest,
                cs.surfaceContainerLowest,
                cs.surfaceContainerHighest,
              ],
              stops: const [0.25, 0.5, 0.75],
            ),
          ),
        );
      },
    );
  }
}
