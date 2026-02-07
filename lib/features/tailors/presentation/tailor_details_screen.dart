import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../l10n/app_localizations.dart';
import 'tailor_store_screen.dart';

class TailorDetailsScreen extends StatelessWidget {
  final String tailorId;
  final String tailorName;
  final String? imageUrl;
  final int? reviewsCount;
  final double? serviceFeeOMR;
  final RangeValues? etaMinutes;
  final List<ServiceItem>? services;

  const TailorDetailsScreen({
    super.key,
    required this.tailorId,
    required this.tailorName,
    this.imageUrl,
    this.reviewsCount,
    this.serviceFeeOMR,
    this.etaMinutes,
    this.services,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final heroTag = 'tailor-image-$tailorId';
    final localeProvider = context.watch<LocaleProvider>();
    final l10n = AppLocalizations.of(context)!;
    final textDirection =
        localeProvider.isRtl ? TextDirection.rtl : TextDirection.ltr;

    return Directionality(
      textDirection: textDirection,
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              stretch: true,
              expandedHeight: 220,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(tailorName,
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: heroTag,
                      child: _HeaderImage(url: imageUrl),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: .35)
                          ],
                        ),
                      ),
                    ),
                    PositionedDirectional(
                      end: 12,
                      bottom: 12,
                      child: _ProBadge(color: cs.primary),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: MediaQuery(
                  // يمنع تضخيم الخط داخل الصفحة
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: const TextScaler.linear(1.0)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // تقييم + عدد المراجعات
                      Row(
                        children: [
                          const Icon(Icons.star_rate_rounded,
                              size: 22, color: Color(0xFFFFA000)),
                          const SizedBox(width: 4),
                          Text('4.8',
                              style: tt.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w800)),
                          if (reviewsCount != null) ...[
                            const SizedBox(width: 6),
                            Text('(+$reviewsCount)',
                                style: tt.bodyMedium
                                    ?.copyWith(color: cs.onSurfaceVariant)),
                          ],
                        ],
                      ),
                      const SizedBox(height: 10),

                      // المدينة
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined,
                              size: 20, color: cs.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(l10n.muscat, style: tt.bodyLarge),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // الوسوم
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Chip(
                            label: Text(l10n.fastDeliveryLabel),
                            backgroundColor:
                                cs.secondaryContainer.withValues(alpha: .6),
                            side: BorderSide.none,
                          ),
                          Chip(
                            label: Text(l10n.menDishdashaTailoring),
                            backgroundColor:
                                cs.secondaryContainer.withValues(alpha: .6),
                            side: BorderSide.none,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // رسوم/وقت
                      Row(
                        children: [
                          if (serviceFeeOMR != null)
                            Text(
                                '${l10n.serviceFee}: ${l10n.omr} ${serviceFeeOMR!.toStringAsFixed(3)}',
                                style: tt.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w700)),
                          if (serviceFeeOMR != null && etaMinutes != null)
                            const SizedBox(width: 10),
                          if (etaMinutes != null)
                            Row(
                              children: [
                                const Icon(Icons.access_time, size: 18),
                                const SizedBox(width: 4),
                                Text(
                                    '${l10n.time}: ${etaMinutes!.start.toInt()} - ${etaMinutes!.end.toInt()} ${l10n.minutes}'),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // قائمة الخدمات
                      Text(l10n.availableServices,
                          style: tt.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      _ServicesList(
                          services: services ?? _defaultServices(l10n),
                          l10n: l10n),

                      const SizedBox(height: 24),
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, _) {
                          return FilledButton(
                            onPressed: () {
                              // التحقق من تسجيل الدخول
                              if (!authProvider.isAuthenticated) {
                                // إظهار مربع حوار لتسجيل الدخول
                                showDialog(
                                  context: context,
                                  builder: (context) => Directionality(
                                    textDirection: textDirection,
                                    child: AlertDialog(
                                      title: Row(
                                        children: [
                                          const Icon(Icons.info_outline,
                                              color: Colors.orange),
                                          const SizedBox(width: 8),
                                          Text(l10n.loginRequired),
                                        ],
                                      ),
                                      content: Text(l10n.loginToOrderService),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: Text(l10n.cancel),
                                        ),
                                        FilledButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            context.push('/login');
                                          },
                                          child: Text(l10n.login),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                                return;
                              }

                              // إذا كان مسجل دخول - التنقل إلى صفحة الطلب
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => TailorStoreScreen(
                                    tailorId: tailorId,
                                    tailorName: tailorName,
                                  ),
                                ),
                              );
                            },
                            style: FilledButton.styleFrom(
                                minimumSize: const Size.fromHeight(48)),
                            child: Text(l10n.orderNowButton),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<ServiceItem> _defaultServices(AppLocalizations l10n) => [
        ServiceItem(
            title: l10n.menDishdashaTailoringService,
            price: 6.000,
            duration: '2-3 ${l10n.days}'),
        ServiceItem(
            title: l10n.shorteningAlteration,
            price: 1.500,
            duration: l10n.sameDay),
        ServiceItem(
            title: l10n.wideningNarrowing, price: 2.000, duration: l10n.oneDay),
      ];
}

// عنصر خدمة بسيط
class ServiceItem {
  final String title;
  final double price;
  final String duration;
  ServiceItem(
      {required this.title, required this.price, required this.duration});
}

class _ServicesList extends StatelessWidget {
  final List<ServiceItem> services;
  final AppLocalizations l10n;
  const _ServicesList({required this.services, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Material(
      color: cs.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: services.length,
        separatorBuilder: (_, __) =>
            Divider(height: 1, color: cs.outlineVariant),
        itemBuilder: (context, i) {
          final s = services[i];
          return ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            title: Text(s.title, style: tt.bodyLarge),
            subtitle: Text('${l10n.duration}: ${s.duration}',
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
            trailing: Text('${l10n.omr} ${s.price.toStringAsFixed(3)}',
                style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          );
        },
      ),
    );
  }
}

class _HeaderImage extends StatelessWidget {
  final String? url;
  const _HeaderImage({this.url});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (url == null || url!.isEmpty) {
      return Container(
        color: cs.surfaceContainerHighest,
        alignment: Alignment.center,
        child: Icon(Icons.cut_rounded, size: 48, color: cs.onSurfaceVariant),
      );
    }
    return Image.network(
      url!,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: cs.surfaceContainerHighest,
        alignment: Alignment.center,
        child: Icon(Icons.cut_rounded, size: 48, color: cs.onSurfaceVariant),
      ),
      loadingBuilder: (context, child, progress) => progress == null
          ? child
          : Container(
              color: cs.surfaceContainerHighest,
              alignment: Alignment.center,
              child: const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2)),
            ),
    );
  }
}

class _ProBadge extends StatelessWidget {
  final Color color;
  const _ProBadge({required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      alignment: Alignment.center,
      child: Text('pro',
          style: Theme.of(context)
              .textTheme
              .labelSmall
              ?.copyWith(color: color, fontWeight: FontWeight.w800)),
    );
  }
}
