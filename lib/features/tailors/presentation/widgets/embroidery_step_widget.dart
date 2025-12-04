import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/embroidery_service.dart';
import '../../models/embroidery_design.dart';

/// Embroidery Step Widget with Slivers
class EmbroideryStepWidget extends StatelessWidget {
  final Color color;
  final int lines;
  final void Function(Color color, int lines) onChanged;
  final String tailorId;
  final EmbroideryDesign? selectedEmbroidery;
  final ValueChanged<EmbroideryDesign?> onEmbroideryChanged;

  const EmbroideryStepWidget({
    super.key,
    required this.color,
    required this.lines,
    required this.onChanged,
    required this.tailorId,
    required this.selectedEmbroidery,
    required this.onEmbroideryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final colorOptions = [
      const Color(0xFF3F51B5),
      const Color(0xFF009688),
      const Color(0xFFFF5722),
      const Color(0xFF795548),
      const Color(0xFF607D8B),
      const Color(0xFF9C27B0),
      const Color(0xFF1B5E20),
      const Color(0xFFB71C1C),
    ];

    return CustomScrollView(
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Text(
              'اختر تصميم التطريز',
              style: tt.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        // Embroidery Designs Grid
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: _EmbroideryDesignsSliver(
            tailorId: tailorId,
            selectedEmbroidery: selectedEmbroidery,
            onEmbroiderySelected: onEmbroideryChanged,
          ),
        ),

        // Color Selection
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'اختر لون التطريز',
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: colorOptions.map((optionColor) {
                    final isSelected = color == optionColor;
                    return GestureDetector(
                      onTap: () => onChanged(optionColor, lines),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: optionColor,
                          border: Border.all(
                            color: isSelected
                                ? cs.primary
                                : Colors.transparent,
                            width: isSelected ? 3 : 0,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: optionColor.withOpacity(0.5),
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : null,
                        ),
                        child: isSelected
                            ? Icon(Icons.check, color: Colors.white, size: 24)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),

        // Lines Selection
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'عدد خطوط التطريز',
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 0, label: Text('بدون')),
                    ButtonSegment(value: 1, label: Text('خط واحد')),
                    ButtonSegment(value: 2, label: Text('خطان')),
                    ButtonSegment(value: 3, label: Text('ثلاثة خطوط')),
                  ],
                  selected: {lines},
                  onSelectionChanged: (Set<int> newSelection) {
                    onChanged(color, newSelection.first);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Embroidery Designs Sliver with Lazy Loading
class _EmbroideryDesignsSliver extends StatelessWidget {
  final String tailorId;
  final EmbroideryDesign? selectedEmbroidery;
  final ValueChanged<EmbroideryDesign?> onEmbroiderySelected;

  const _EmbroideryDesignsSliver({
    required this.tailorId,
    required this.selectedEmbroidery,
    required this.onEmbroiderySelected,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final embroideryService = EmbroideryService();

    return FutureBuilder<List<EmbroideryDesign>>(
      future: embroideryService.getEmbroideryDesigns(tailorId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasError) {
          return SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline_rounded, color: cs.error),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'حدث خطأ في تحميل تصاميم التطريز',
                      style: TextStyle(color: cs.onErrorContainer),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final designs = snapshot.data ?? [];

        if (designs.isEmpty) {
          return SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(Icons.brush_outlined,
                      size: 64, color: cs.onSurfaceVariant),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد تصاميم تطريز متاحة',
                    style: tt.titleMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.only(bottom: 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final design = designs[index];
                final isSelected = selectedEmbroidery?.id == design.id;

                return _EmbroideryDesignCard(
                  design: design,
                  isSelected: isSelected,
                  onTap: () => onEmbroiderySelected(design),
                );
              },
              childCount: designs.length,
            ),
          ),
        );
      },
    );
  }
}

/// Embroidery Design Card
class _EmbroideryDesignCard extends StatelessWidget {
  final EmbroideryDesign design;
  final bool isSelected;
  final VoidCallback onTap;

  const _EmbroideryDesignCard({
    required this.design,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      cs.primary.withOpacity(0.15),
                      cs.secondary.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected ? null : cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? cs.primary : cs.outlineVariant,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: design.imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: design.imageUrl,
                          fit: BoxFit.cover,
                          memCacheWidth: 300,
                          memCacheHeight: 300,
                          placeholder: (context, url) => Container(
                            color: cs.surfaceContainerHighest,
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: cs.surfaceContainerHighest,
                            child: Icon(Icons.image,
                                size: 40, color: cs.onSurfaceVariant),
                          ),
                        )
                      : Container(
                          color: cs.surfaceContainerHighest,
                          child: Icon(Icons.brush,
                              size: 40, color: cs.onSurfaceVariant),
                        ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      design.name,
                      style: tt.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? cs.primary : cs.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (design.price != null && design.price! > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        'ر.ع ${design.price.toStringAsFixed(3)}',
                        style: tt.labelSmall?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    if (isSelected) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.check_circle,
                              size: 16, color: cs.primary),
                          const SizedBox(width: 4),
                          Text(
                            'محدد',
                            style: tt.labelSmall?.copyWith(
                              color: cs.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
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

