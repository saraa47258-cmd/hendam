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
