import 'package:flutter/material.dart';
import '../models/tailor.dart';
import 'package:hindam/l10n/app_localizations.dart';

class TailorTile extends StatelessWidget {
  final Tailor tailor;
  final bool isOpen;
  final VoidCallback? onTap;

  const TailorTile({
    super.key,
    required this.tailor,
    this.isOpen = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: cs.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 116,
          child: Row(
            children: [
              // صورة مربعة
              AspectRatio(
                aspectRatio: 1,
                child: _TileImage(imageUrl: tailor.imageUrl),
              ),
              const SizedBox(width: 14),

              // تفاصيل
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(end: 14, top: 12, bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // الاسم + الحالة
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              tailor.name,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isOpen ? Colors.green : cs.outline,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              isOpen ? l10n.open : l10n.closed,
                              style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // التقييم
                      Row(
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(tailor.rating.toStringAsFixed(1),
                              style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // المدينة
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 16, color: cs.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              tailor.city,
                              style: TextStyle(fontSize: 12.5, color: cs.onSurfaceVariant),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),

                      // وسوم مختصرة (اختياري)
                      if (tailor.tags.isNotEmpty)
                        Text(
                          tailor.tags.take(3).join(' • '),
                          style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _TileImage extends StatelessWidget {
  final String? imageUrl;
  const _TileImage({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [cs.secondaryContainer, cs.primaryContainer],
          ),
        ),
        child: Center(
          child: Icon(Icons.storefront_rounded, size: 28, color: cs.onSecondaryContainer),
        ),
      );
    }

    return Image.network(
      imageUrl!,
      fit: BoxFit.cover,
      cacheWidth: 600,
      errorBuilder: (_, __, ___) =>
          Container(color: cs.surfaceContainerHighest, child: Icon(Icons.storefront_rounded, size: 28, color: cs.onSurfaceVariant)),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          color: cs.surfaceContainerHighest,
          alignment: Alignment.center,
          child: const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
        );
      },
    );
  }
}
