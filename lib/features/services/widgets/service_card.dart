import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hindam/l10n/app_localizations.dart';
import '../models/service.dart';

class ServiceCard extends StatelessWidget {
  final Service service;
  final VoidCallback? onSelect;
  final VoidCallback? onInfo;

  const ServiceCard({
    super.key,
    required this.service,
    this.onSelect,
    this.onInfo,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: cs.outlineVariant.withOpacity(.7)),
      ),
      child: InkWell(
          onTap: onSelect,
          splashColor: cs.primary.withOpacity(0.06),
          highlightColor: cs.primary.withOpacity(0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(service: service),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // اسم الخدمة
                    Text(
                      service.nameAr,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // أزرار التفاصيل والاختيار
                    Row(
                      children: [
                        if (onInfo != null)
                          OutlinedButton.icon(
                            onPressed: onInfo,
                            icon: const Icon(Icons.info_outline, size: 18),
                            label: Text(l10n.details),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide(color: cs.outlineVariant),
                              textStyle: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                        if (onInfo != null) const SizedBox(width: 8),
                        Expanded(
                          child: SizedBox(
                            height: 46,
                            child: FilledButton(
                              onPressed: onSelect,
                              style: FilledButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                textStyle: tt.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: .1,
                                ),
                              ),
                            child: Text(l10n.select),
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

class _Header extends StatelessWidget {
  final Service service;
  const _Header({required this.service});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final measureCount = service.measurementSchema.length;

    // خلفية: Network أو Asset أو Placeholder
    final bool hasImage = service.image.isNotEmpty;
    final bool isNetwork = hasImage && service.image.startsWith('http');

    Widget imageWidget;
    if (!hasImage) {
      imageWidget = _Placeholder(cs: cs);
    } else if (isNetwork) {
      imageWidget = Image.network(
        service.image,
        fit: BoxFit.cover,
        frameBuilder: (context, child, frame, wasSync) {
          if (wasSync) return child;
          return AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            child: child,
          );
        },
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Stack(
            fit: StackFit.expand,
            children: [
              _Placeholder(cs: cs),
              const Center(child: CircularProgressIndicator(strokeWidth: 2.2)),
            ],
          );
        },
        errorBuilder: (_, __, ___) => _Placeholder(cs: cs),
      );
    } else {
      imageWidget = Image.asset(
        service.image,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _Placeholder(cs: cs),
      );
    }

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          imageWidget,

          // تدرّج علوي/سفلي لتحسين التباين فوق الصورة
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(.28),
                    Colors.transparent,
                    Colors.black.withOpacity(.18),
                  ],
                  stops: const [0, 0.55, 1],
                ),
              ),
            ),
          ),

          // شارة السعر (أعلى-يمين في RTL)
          PositionedDirectional(
            top: 8,
            start: 8,
            child: _GlassPill(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.payments_outlined, size: 14, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    '${service.basePriceOmr.toStringAsFixed(2)} ر.ع',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // عدّاد القياسات (أسفل-يسار في RTL)
          if (measureCount > 0)
            PositionedDirectional(
              bottom: 8,
              end: 8,
              child: _GlassPill(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.straighten, size: 14, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      '$measureCount قياس',
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
        ],
      ),
    );
  }
}

// ======= عناصر مساعدة =======

class _Placeholder extends StatelessWidget {
  final ColorScheme cs;
  const _Placeholder({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primaryContainer, cs.tertiaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(
        Icons.content_cut,
        size: 40,
        color: cs.onPrimaryContainer.withOpacity(.6),
      ),
    );
  }
}

class _GlassPill extends StatelessWidget {
  final Widget child;
  const _GlassPill({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.22),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(.35), width: .8),
          ),
          child: child,
        ),
      ),
    );
  }
}
