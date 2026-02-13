import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hindam/l10n/app_localizations.dart';
import '../models/service_item.dart';

class ServiceListCard extends StatefulWidget {
  final ServiceItem item;
  final VoidCallback? onAdd;

  const ServiceListCard({super.key, required this.item, this.onAdd});

  @override
  State<ServiceListCard> createState() => _ServiceListCardState();
}

class _ServiceListCardState extends State<ServiceListCard> {
  bool fav = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

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
            // خلفية تدرّج (بدون صور)
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
                          onPressed: widget.onAdd,
                          icon: const Icon(Icons.add_shopping_cart_rounded, size: 18),
                          label: Text(l10n.add),
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
