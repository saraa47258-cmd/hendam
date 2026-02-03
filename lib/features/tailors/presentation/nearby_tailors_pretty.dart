// lib/features/tailors/presentation/nearby_tailors_pretty.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  static double preferredHeight(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final textScale = MediaQuery.textScaleFactorOf(context);
    final isShort = size.height < 700;
    double h = 148;
    if (textScale > 1.1) h += 8;
    if (isShort) h -= 8;
    return h;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final w = MediaQuery.sizeOf(context).width;
    final h = preferredHeight(context);

    final cardW = math.max(260.0, w * 0.75);
    final cardH = h - 4;

    if (items.isEmpty) {
      return Container(
        height: h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: cs.outlineVariant.withOpacity(0.2),
            width: 0.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.storefront_outlined,
              size: 32,
              color: cs.onSurfaceVariant.withOpacity(0.4),
            ),
            const SizedBox(height: 8),
            Text(
              'لا توجد محلات قريبة حالياً',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant.withOpacity(0.6),
                  ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: h,
      child: ListView.separated(
        clipBehavior: Clip.none,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
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

class _TailorCard extends StatefulWidget {
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
  State<_TailorCard> createState() => _TailorCardState();
}

class _TailorCardState extends State<_TailorCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        HapticFeedback.lightImpact();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: Container(
          width: widget.width,
          height: widget.height,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: cs.outlineVariant.withOpacity(0.2),
              width: 0.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top row: rating + distance + status
              Row(
                children: [
                  _badge(
                    context,
                    icon: Icons.star_rounded,
                    label: widget.item.rating.toStringAsFixed(1),
                    iconColor: const Color(0xFFF59E0B),
                  ),
                  const SizedBox(width: 6),
                  _badge(
                    context,
                    icon: Icons.place_outlined,
                    label: '${widget.item.distanceKm.toStringAsFixed(1)} كم',
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: widget.item.isOpen
                          ? const Color(0xFF10B981).withOpacity(0.1)
                          : cs.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: widget.item.isOpen
                                ? const Color(0xFF10B981)
                                : cs.error,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.item.isOpen ? 'مفتوح' : 'مغلق',
                          style: tt.labelSmall?.copyWith(
                            color: widget.item.isOpen
                                ? const Color(0xFF10B981)
                                : cs.error,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Name
              Text(
                widget.item.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: tt.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  letterSpacing: -0.2,
                ),
              ),

              const SizedBox(height: 8),

              // Tags
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: widget.item.tags
                      .take(3)
                      .map((t) => _chip(context, t))
                      .toList(),
                ),
              ),

              // Bottom buttons
              Row(
                children: [
                  _actionBtn(
                    context,
                    icon: Icons.call_outlined,
                    label: 'اتصال',
                    onTap: widget.onCall,
                  ),
                  const SizedBox(width: 8),
                  _actionBtn(
                    context,
                    icon: Icons.map_outlined,
                    label: 'خريطة',
                    onTap: widget.onMap,
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: cs.onSurfaceVariant.withOpacity(0.5),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badge(
    BuildContext context, {
    required IconData icon,
    required String label,
    Color? iconColor,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: iconColor ?? cs.primary),
        const SizedBox(width: 3),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 11,
                color: cs.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  Widget _chip(BuildContext context, String text) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
      ),
    );
  }

  Widget _actionBtn(
    BuildContext context, {
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: cs.outlineVariant.withOpacity(0.3),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: cs.primary),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    color: cs.onSurface,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
