import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hindam/l10n/app_localizations.dart';
import '../../services/fabric_service.dart';

/// Fabric Step Widget - منفصل للأداء الأفضل
class FabricStepWidget extends StatefulWidget {
  final String tailorId;
  final String? selectedType;
  final String? selectedFabricId;
  final void Function(String? type, String? imageThumb, String? fabricId)
      onTypeChanged;

  const FabricStepWidget({
    super.key,
    required this.tailorId,
    this.selectedType,
    this.selectedFabricId,
    required this.onTypeChanged,
  });

  @override
  State<FabricStepWidget> createState() => _FabricStepWidgetState();
}

class _FabricStepWidgetState extends State<FabricStepWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool _isNetworkPath(String path) {
    return path.startsWith('http://') || path.startsWith('https://');
  }

  Widget _fabricImage(String imageUrl, ColorScheme cs) {
    if (imageUrl.isEmpty) {
      return Container(
        color: cs.surfaceContainerHighest,
        child: Icon(Icons.image, size: 40, color: cs.onSurfaceVariant),
      );
    }

    if (_isNetworkPath(imageUrl)) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        memCacheWidth: 300,
        memCacheHeight: 300,
        placeholder: (context, url) => Container(
          color: cs.surfaceContainerHighest,
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        errorWidget: (context, url, error) => Container(
          color: cs.surfaceContainerHighest,
          child: Icon(Icons.image, size: 40, color: cs.onSurfaceVariant),
        ),
      );
    } else {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: cs.surfaceContainerHighest,
          child: Icon(Icons.image, size: 40, color: cs.onSurfaceVariant),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    // مؤقتاً: جلب جميع الأقمشة المتاحة من المتجر، بغض النظر عن الخياط
    // حتى تتأكد من أن البيانات موجودة في Firebase وتظهر للمستخدم.
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: FabricService.getAllFabrics(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: _ElegantFrame(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.errorLoadingFabrics,
                      style: tt.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        final fabrics = snapshot.data ?? [];

        final selectedFabric = fabrics.firstWhere(
          (fabric) => fabric['id'] == widget.selectedFabricId,
          orElse: () => <String, dynamic>{},
        );

        return CustomScrollView(
          slivers: [
            // ===== حقل البحث فقط (بدون عنوان/وصف) =====
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.25),
                          width: 0.8,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 18),
                          Expanded(
                            child: TextField(
                              textAlign: TextAlign.right,
                              textAlignVertical: TextAlignVertical.center,
                              decoration: InputDecoration(
                                hintText: l10n.searchFabricHint,
                                border: InputBorder.none,
                                isDense: true,
                                hintStyle: tt.bodyLarge?.copyWith(
                                  color: Colors.grey.shade500,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // زر أيقونة البحث دائري وأنيق
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.deepPurple.shade400,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.deepPurple.withOpacity(0.4),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.search_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ===== قسم "Recently viewed" مع كرت كبير أفقي =====
            if (widget.selectedFabricId != null && selectedFabric.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recently viewed',
                        style: tt.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 12),
                      buildRecentlyViewedCard(selectedFabric, cs, tt),
                    ],
                  ),
                ),
              ),

            // ===== صف أفقي من الكروت الصغيرة (أنواع الأقمشة) =====
            if (fabrics.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Browse by type',
                        style: tt.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 140,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: fabrics.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final fabric = fabrics[index];
                            final selected = widget.selectedFabricId != null &&
                                widget.selectedFabricId == fabric['id'];
                            return _fabricHorizontalCard(
                              fabric: fabric,
                              selected: selected,
                              onTap: () => widget.onTypeChanged(
                                fabric['name'],
                                fabric['imageUrl'],
                                fabric['id'],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget buildRecentlyViewedCard(
      Map<String, dynamic> fabric, ColorScheme cs, TextTheme tt) {
    final l10n = AppLocalizations.of(context)!;
    final currentPrice = (fabric['pricePerMeter'] as num?)?.toDouble() ?? 0.0;
    final heroTag = 'fabric-${fabric['id'] ?? fabric['name']}';
    final imageUrl = fabric['imageUrl'] as String? ?? '';

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 280,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // صورة القماش
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Hero(
                    tag: heroTag,
                    child: _fabricImage(imageUrl, cs),
                  ),
                ),
              ),
              // معلومات القماش
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fabric['name'] ?? l10n.fabric,
                      style: tt.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'No trips',
                      style: tt.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: Text(
                        '${l10n.omr} ${currentPrice.toStringAsFixed(3)}',
                        style: tt.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                          color: Colors.deepPurple.shade600,
                        ),
                      ),
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

  Widget buildSelectedFabricDetailCard(Map<String, dynamic> fabric) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final availableColors =
        fabric['availableColors'] as List<dynamic>? ?? <dynamic>[];
    final currentPrice = (fabric['pricePerMeter'] as num?)?.toDouble() ?? 0.0;
    final heroTag = 'fabric-${fabric['id'] ?? fabric['name']}';
    final imageUrl = fabric['imageUrl'] as String? ?? '';

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (child, animation) {
        return ScaleTransition(
          scale: animation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      child: Container(
        key: ValueKey<String>(heroTag),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              cs.primary.withOpacity(0.15),
              cs.secondary.withOpacity(0.12),
              cs.surface,
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: cs.primary.withOpacity(0.4),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: cs.primary.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Hero(
                  tag: heroTag,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: _fabricImage(imageUrl, cs),
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: cs.surface.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          l10n.price,
                          style: tt.labelSmall
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                        Text(
                          '${l10n.omr} ${currentPrice.toStringAsFixed(3)}',
                          style: tt.titleMedium?.copyWith(
                            color: cs.primary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fabric['name'] ?? l10n.fabric,
                        style: tt.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: cs.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (availableColors.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                l10n.availableColors,
                style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: availableColors.take(10).map((colorData) {
                  final colorHex =
                      colorData['colorHex'] as String? ?? '#CCCCCC';
                  Color color;
                  try {
                    color =
                        Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
                  } catch (e) {
                    color = Colors.grey;
                  }
                  return Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _fabricHorizontalCard({
    required Map<String, dynamic> fabric,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final heroTag = 'fabric-${fabric['id'] ?? fabric['name']}';
    final imageUrl = fabric['imageUrl'] as String? ?? '';

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 120,
          decoration: BoxDecoration(
            color:
                selected ? cs.primaryContainer.withOpacity(0.3) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? cs.primary : Colors.grey.shade200,
              width: selected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // صورة القماش
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: Hero(
                    tag: heroTag,
                    child: _fabricImage(imageUrl, cs),
                  ),
                ),
              ),
              // اسم القماش
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  fabric['name'] ?? l10n.fabric,
                  style: tt.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// كادر أنيق
class _ElegantFrame extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const _ElegantFrame({
    required this.child,
    this.padding = const EdgeInsets.all(14),
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            cs.primary.withOpacity(.18),
            cs.tertiary.withOpacity(.18),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: child,
    );
  }
}
