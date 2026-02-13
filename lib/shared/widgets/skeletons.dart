import 'package:flutter/material.dart';

/// حاوية عامة لعرض تأثير الـ Shimmer أثناء التحميل.
class SkeletonContainer extends StatefulWidget {
  final double? width;
  final double? height;
  final BorderRadiusGeometry borderRadius;
  final EdgeInsetsGeometry? margin;

  const SkeletonContainer({
    super.key,
    this.width,
    this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.margin,
  });

  @override
  State<SkeletonContainer> createState() => _SkeletonContainerState();
}

class _SkeletonContainerState extends State<SkeletonContainer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          width: widget.width,
          height: widget.height,
          margin: widget.margin,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            gradient: LinearGradient(
              begin: Alignment(-1 + _controller.value * 2, 0),
              end: Alignment(_controller.value * 2, 0),
              colors: [
                cs.surfaceContainerHighest.withOpacity(0.25),
                cs.surfaceContainerHighest,
                cs.surfaceContainerHighest.withOpacity(0.25),
              ],
              stops: const [0.2, 0.5, 0.8],
            ),
          ),
        );
      },
    );
  }
}

/// خط أفقي بسيط للهيكل.
class SkeletonLine extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadiusGeometry borderRadius;
  final EdgeInsetsGeometry? margin;

  const SkeletonLine({
    super.key,
    required this.width,
    this.height = 12,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonContainer(
      width: width,
      height: height,
      borderRadius: borderRadius,
      margin: margin,
    );
  }
}

/// كتلة مربعة أو مستطيلة.
class SkeletonBlock extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadiusGeometry borderRadius;
  final EdgeInsetsGeometry? margin;

  const SkeletonBlock({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonContainer(
      width: width,
      height: height,
      borderRadius: borderRadius,
      margin: margin,
    );
  }
}

/// دائرة (Avatar) للهيكل.
class SkeletonCircle extends StatelessWidget {
  final double size;
  final EdgeInsetsGeometry? margin;

  const SkeletonCircle({super.key, this.size = 40, this.margin});

  @override
  Widget build(BuildContext context) {
    return SkeletonContainer(
      width: size,
      height: size,
      borderRadius: BorderRadius.circular(size / 2),
      margin: margin,
    );
  }
}

/// عنصر قائمة مبسّط يتكوّن من صورة رمزية وخطوط نصية.
class SkeletonListTile extends StatelessWidget {
  final double avatarSize;
  final List<double> lineWidths;
  final double lineHeight;
  final double spacing;

  const SkeletonListTile({
    super.key,
    this.avatarSize = 48,
    this.lineWidths = const [0.7, 0.5],
    this.lineHeight = 12,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkeletonCircle(size: avatarSize),
        SizedBox(width: spacing),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: lineWidths
                .map(
                  (factor) => Padding(
                    padding: EdgeInsets.only(bottom: spacing / 2),
                    child: SkeletonLine(
                      width: maxWidth * factor,
                      height: lineHeight,
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

/// قائمة Skeleton بسيطة مشابهة لبطاقات الطلبات.
class OrderSkeletonList extends StatelessWidget {
  final int count;
  const OrderSkeletonList({super.key, this.count = 3});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: count,
      itemBuilder: (_, __) => const OrderSkeletonCard(),
    );
  }
}

class OrderSkeletonCard extends StatelessWidget {
  const OrderSkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: cs.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SkeletonLine(
                    width: double.infinity,
                    height: 18,
                  ),
                ),
                SizedBox(width: 12),
                SkeletonLine(width: 80, height: 20),
              ],
            ),
            SizedBox(height: 12),
            SkeletonLine(width: 200, height: 14),
            SizedBox(height: 12),
            SkeletonLine(width: double.infinity, height: 12),
            SizedBox(height: 8),
            SkeletonLine(width: double.infinity, height: 12),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Product & Catalog Skeletons
// ═══════════════════════════════════════════════════════════════════════════

/// هيكل تحميل لصفحة معاينة المنتج (صورة كبيرة + عنوان + سعر).
class ProductPreviewSkeleton extends StatelessWidget {
  const ProductPreviewSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBlock(
              width: width,
              height: width,
              borderRadius: BorderRadius.zero,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonLine(width: width * 0.7, height: 22),
                  const SizedBox(height: 8),
                  SkeletonLine(width: width * 0.5, height: 16),
                  const SizedBox(height: 16),
                  SkeletonLine(width: width * 0.35, height: 24),
                  const SizedBox(height: 24),
                  const Row(
                    children: [
                      SkeletonBlock(width: 48, height: 48),
                      SizedBox(width: 12),
                      SkeletonBlock(width: 48, height: 48),
                      SizedBox(width: 12),
                      SkeletonLine(width: 80, height: 16),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const SkeletonLine(width: double.infinity, height: 14),
                  const SizedBox(height: 8),
                  const SkeletonLine(width: double.infinity, height: 14),
                  const SizedBox(height: 8),
                  SkeletonLine(width: width * 0.6, height: 14),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// بطاقة هيكل واحدة لمنتج في شبكة.
class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.sizeOf(context).width - 16 * 2 - 14) / 2;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SkeletonBlock(
          width: width,
          height: width,
          borderRadius: BorderRadius.circular(12),
        ),
        const SizedBox(height: 8),
        SkeletonLine(width: width * 0.85, height: 12),
        const SizedBox(height: 4),
        SkeletonLine(width: width * 0.5, height: 10),
        const SizedBox(height: 6),
        SkeletonLine(width: width * 0.4, height: 14),
      ],
    );
  }
}

/// شبكة هيكل لمنتجات (قائمة/كتالوج).
class ProductGridSkeleton extends StatelessWidget {
  final int crossAxisCount;
  final int itemCount;

  const ProductGridSkeleton({
    super.key,
    this.crossAxisCount = 2,
    this.itemCount = 6,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.62,
      ),
      itemCount: itemCount,
      itemBuilder: (_, __) => const ProductCardSkeleton(),
    );
  }
}

/// هيكل قائمة محلات (صورة + اسم + وصف).
class ShopCardSkeleton extends StatelessWidget {
  const ShopCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.sizeOf(context).width;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBlock(
            width: 88,
            height: 88,
            borderRadius: BorderRadius.circular(12),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLine(width: maxWidth * 0.4, height: 16),
                const SizedBox(height: 6),
                SkeletonLine(width: maxWidth * 0.25, height: 12),
                const SizedBox(height: 8),
                const Row(
                  children: [
                    SkeletonLine(width: 60, height: 20),
                    SizedBox(width: 8),
                    SkeletonLine(width: 50, height: 20),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// قائمة هيكل لمحلات.
class ShopListSkeleton extends StatelessWidget {
  final int count;

  const ShopListSkeleton({super.key, this.count = 5});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      itemCount: count,
      itemBuilder: (_, __) => const ShopCardSkeleton(),
    );
  }
}

/// هيكل شاشة عبايات: هيدر + شريط رقائق + شبكة منتجات.
class AbayaServicesSkeleton extends StatelessWidget {
  const AbayaServicesSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return CustomScrollView(
      physics: const NeverScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
            child: Row(
              children: [
                SkeletonBlock(
                    width: 40,
                    height: 40,
                    borderRadius: BorderRadius.circular(12)),
                const Spacer(),
                SkeletonBlock(
                    width: 40,
                    height: 40,
                    borderRadius: BorderRadius.circular(12)),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: List.generate(
                  5,
                  (_) => const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: SkeletonLine(width: 72, height: 36),
                      )),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLine(width: width * 0.5, height: 28),
                const SizedBox(height: 4),
                const SkeletonLine(width: 120, height: 16),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: ProductGridSkeleton(itemCount: 6),
        ),
      ],
    );
  }
}

/// هيكل شاشة منتجات تاجر: هيدر المحل + شبكة منتجات.
class MerchantProductsSkeleton extends StatelessWidget {
  const MerchantProductsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const NeverScrollableScrollPhysics(),
      slivers: [
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBlock(
                  width: 120,
                  height: 96,
                  borderRadius:
                      BorderRadius.horizontal(left: Radius.circular(16)),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonLine(width: 140, height: 18),
                      SizedBox(height: 6),
                      SkeletonLine(width: 100, height: 14),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          SkeletonLine(width: 56, height: 24),
                          SizedBox(width: 8),
                          SkeletonLine(width: 56, height: 24),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: List.generate(
                  4,
                  (_) => const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: SkeletonLine(width: 64, height: 32),
                      )),
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: ProductGridSkeleton(itemCount: 6),
        ),
      ],
    );
  }
}
