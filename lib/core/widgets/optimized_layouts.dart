// lib/core/widgets/optimized_layouts.dart
import 'package:flutter/material.dart';

/// مكون محسن للأزرار الأفقية - يتجنب إعادة البناء غير الضرورية
class OptimizedButtonRow extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

  const OptimizedButtonRow({
    super.key,
    required this.children,
    this.spacing = 8.0,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: MainAxisSize.min,
      children: children
          .expand((child) => [
                child,
                if (child != children.last) SizedBox(width: spacing),
              ])
          .toList(),
    );
  }
}

/// مكون محسن للبطاقات الأفقية - يتجنب إعادة البناء غير الضرورية
class OptimizedCardRow extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

  const OptimizedCardRow({
    super.key,
    required this.children,
    this.spacing = 10.0,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: children
          .expand((child) => [
                child,
                if (child != children.last) SizedBox(width: spacing),
              ])
          .toList(),
    );
  }
}

/// مكون محسن للقوائم العمودية - يتجنب إعادة البناء غير الضرورية
class OptimizedCardColumn extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

  const OptimizedCardColumn({
    super.key,
    required this.children,
    this.spacing = 8.0,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: MainAxisSize.min,
      children: children
          .expand((child) => [
                child,
                if (child != children.last) SizedBox(height: spacing),
              ])
          .toList(),
    );
  }
}

/// مكون محسن للشبكات - يستخدم Row/Column بدلاً من GridView عند الإمكان
class OptimizedGrid extends StatelessWidget {
  final List<Widget> children;
  final int crossAxisCount;
  final double spacing;
  final double runSpacing;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const OptimizedGrid({
    super.key,
    required this.children,
    this.crossAxisCount = 2,
    this.spacing = 8.0,
    this.runSpacing = 8.0,
    this.shrinkWrap = true,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    // إذا كان عدد العناصر قليل، استخدم Column بدلاً من GridView
    if (children.length <= 6 && crossAxisCount == 2) {
      return _buildOptimizedColumn();
    }

    // وإلا استخدم GridView العادي
    return GridView.builder(
      shrinkWrap: shrinkWrap,
      physics:
          physics ?? (shrinkWrap ? const NeverScrollableScrollPhysics() : null),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: runSpacing,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }

  Widget _buildOptimizedColumn() {
    final rows = <Widget>[];
    for (int i = 0; i < children.length; i += crossAxisCount) {
      final rowChildren = children.skip(i).take(crossAxisCount).toList();

      // إضافة SizedBox للعناصر المفقودة إذا لزم الأمر
      while (rowChildren.length < crossAxisCount) {
        rowChildren.add(const SizedBox.shrink());
      }

      rows.add(
        Row(
          children: rowChildren
              .expand((child) => [
                    Expanded(child: child),
                    if (child != rowChildren.last) SizedBox(width: spacing),
                  ])
              .toList(),
        ),
      );

      if (i + crossAxisCount < children.length) {
        rows.add(SizedBox(height: runSpacing));
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: rows,
    );
  }
}

/// مكون محسن للقوائم - يستخدم Column بدلاً من ListView عند الإمكان
class OptimizedList extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const OptimizedList({
    super.key,
    required this.children,
    this.spacing = 8.0,
    this.shrinkWrap = true,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    // إذا كان عدد العناصر قليل، استخدم Column بدلاً من ListView
    if (children.length <= 10) {
      return _buildOptimizedColumn();
    }

    // وإلا استخدم ListView العادي
    return ListView.builder(
      shrinkWrap: shrinkWrap,
      physics:
          physics ?? (shrinkWrap ? const NeverScrollableScrollPhysics() : null),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }

  Widget _buildOptimizedColumn() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: children
          .expand((child) => [
                child,
                if (child != children.last) SizedBox(height: spacing),
              ])
          .toList(),
    );
  }
}
