import 'package:flutter/material.dart';
import 'dart:ui' as ui; // لاستخدام ImageFilter
import '../models/service_item.dart'; // << استخدم الموديل الموجود عندك
import '../../../core/styles/responsive.dart';

/// ServiceCard - Professional Version
/// (تمت إعادة تسمية ProServiceCard إلى ServiceCard للحفاظ على التوافق)
class ServiceCard extends StatelessWidget {
  final ServiceItem item;
  final String? imageUrl; // صورة كخلفية/غلاف (اختياري)
  final IconData serviceIcon; // أيقونة مخصصة للخدمة (اختياري)
  final VoidCallback? onOpen; // زر السهم
  final VoidCallback? onTap; // ضغطة البطاقة

  const ServiceCard({
    super.key,
    required this.item,
    this.imageUrl,
    this.serviceIcon = Icons.local_laundry_service_rounded,
    this.onOpen,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = context.responsiveRadius();
    final elevation = context.pick(5.0, tablet: 6.0, desktop: 7.0);

    // نثبت textScaleFactor للحفاظ على اتساق التصميم
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Card(
          elevation: elevation,
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius)),
          shadowColor: Colors.black.withOpacity(0.1),
          child: InkWell(
            onTap: onTap,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(imageUrl: imageUrl, serviceIcon: serviceIcon),
                _Body(item: item, onOpen: onOpen),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- ويدجتس فرعية ---

class _Header extends StatelessWidget {
  final String? imageUrl;
  final IconData serviceIcon;

  const _Header({this.imageUrl, required this.serviceIcon});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final headerHeight = context.pick(100.0, tablet: 110.0, desktop: 120.0);
    final iconContainerSize = context.pick(60.0, tablet: 65.0, desktop: 70.0);
    final iconSize = context.pick(30.0, tablet: 32.0, desktop: 34.0);

    return SizedBox(
      height: headerHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _BlurredBackground(imageUrl: imageUrl),
          Center(
            child: Container(
              width: iconContainerSize,
              height: iconContainerSize,
              decoration: BoxDecoration(
                color: cs.surface.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(serviceIcon, size: iconSize, color: cs.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final ServiceItem item;
  final VoidCallback? onOpen;

  const _Body({required this.item, this.onOpen});

  String _formatPrice(double p) {
    final isInteger = (p % 1) == 0;
    return 'ر.ع ${p.toStringAsFixed(isInteger ? 0 : 2)}';
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final padding = context.responsivePadding();
    final spacing = context.responsiveSpacing();

    return Padding(
      padding: EdgeInsets.fromLTRB(padding, spacing, padding, padding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان
          Text(
            item.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: tt.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              height: 1.2,
              fontSize: context.responsiveFontSize(16.0),
            ),
          ),
          SizedBox(height: spacing),

          // السعر والتقييم
          Row(
            children: [
              _InfoChip(
                  icon: Icons.sell_outlined, label: _formatPrice(item.price)),
              SizedBox(width: spacing),
              _InfoChip(
                icon: Icons.star_rounded,
                label: item.rating.toString(), // يعمل مع int أو double
                iconColor: Colors.amber.shade700,
              ),
              const Spacer(),
              SizedBox(
                height: context.pick(44.0, tablet: 48.0, desktop: 52.0),
                width: context.pick(44.0, tablet: 48.0, desktop: 52.0),
                child: FilledButton.tonal(
                  onPressed: onOpen,
                  style: FilledButton.styleFrom(
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(context.responsiveRadius())),
                  ),
                  child: Icon(Icons.chevron_left_rounded,
                      size: context.pick(24.0, tablet: 26.0, desktop: 28.0)),
                ),
              ),
            ],
          ),

          if ((item.variantsLabel ?? '').isNotEmpty) ...[
            SizedBox(height: spacing),
            Chip(
              label: Text(
                item.variantsLabel,
                style: tt.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: context.responsiveFontSize(12.0),
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: spacing),
              labelStyle: tt.labelSmall?.copyWith(fontWeight: FontWeight.w600),
              side: BorderSide.none,
              backgroundColor: cs.secondaryContainer.withOpacity(0.7),
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(context.responsiveRadius())),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? iconColor;

  const _InfoChip({required this.icon, required this.label, this.iconColor});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final iconSize = context.pick(16.0, tablet: 18.0, desktop: 20.0);
    final fontSize = context.responsiveFontSize(12.0);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: iconSize, color: iconColor ?? cs.onSurfaceVariant),
        SizedBox(width: context.responsiveMargin() / 2),
        Text(
          label,
          style: tt.bodySmall?.copyWith(
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            fontSize: fontSize,
          ),
        ),
      ],
    );
  }
}

class _BlurredBackground extends StatelessWidget {
  final String? imageUrl;
  const _BlurredBackground({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [cs.primaryContainer, cs.secondaryContainer],
          ),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          imageUrl!,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Container(color: cs.surfaceContainerHighest);
          },
          errorBuilder: (_, __, ___) => Container(color: cs.errorContainer),
        ),
        ClipRect(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
            child: Container(color: Colors.black.withOpacity(0.2)),
          ),
        ),
      ],
    );
  }
}
