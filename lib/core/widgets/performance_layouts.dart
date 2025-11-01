// lib/core/widgets/performance_layouts.dart
import 'package:flutter/material.dart';

/// مكون محسن للأداء - يتجنب إعادة البناء غير الضرورية باستخدام const constructors
class PerformanceRow extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  final double? spacing;

  const PerformanceRow({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.min,
    this.spacing,
  });

  @override
  Widget build(BuildContext context) {
    if (spacing != null && spacing! > 0) {
      return Row(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        mainAxisSize: mainAxisSize,
        children: children
            .expand((child) => [
                  child,
                  if (child != children.last) SizedBox(width: spacing!),
                ])
            .toList(),
      );
    }

    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: children,
    );
  }
}

/// مكون محسن للأداء - يتجنب إعادة البناء غير الضرورية باستخدام const constructors
class PerformanceColumn extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  final double? spacing;

  const PerformanceColumn({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.min,
    this.spacing,
  });

  @override
  Widget build(BuildContext context) {
    if (spacing != null && spacing! > 0) {
      return Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        mainAxisSize: mainAxisSize,
        children: children
            .expand((child) => [
                  child,
                  if (child != children.last) SizedBox(height: spacing!),
                ])
            .toList(),
      );
    }

    return Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: children,
    );
  }
}

/// مكون محسن للبطاقات - يتجنب إعادة البناء غير الضرورية
class PerformanceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final Color? color;
  final double? elevation;
  final VoidCallback? onTap;

  const PerformanceCard({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.color,
    this.elevation,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = Card(
      margin: margin,
      elevation: elevation,
      color: color,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: card,
      );
    }

    return card;
  }
}

/// مكون محسن للقوائم - يستخدم ListView.builder عند الحاجة
class PerformanceList extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsets? padding;
  final ScrollController? controller;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const PerformanceList({
    super.key,
    required this.children,
    this.padding,
    this.controller,
    this.shrinkWrap = true,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    // إذا كان عدد العناصر قليل، استخدم Column
    if (children.length <= 5) {
      return Padding(
        padding: padding ?? EdgeInsets.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      );
    }

    // وإلا استخدم ListView.builder للأداء الأفضل
    return ListView.builder(
      controller: controller,
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics:
          physics ?? (shrinkWrap ? const NeverScrollableScrollPhysics() : null),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}

/// مكون محسن للشبكات - يستخدم GridView.builder عند الحاجة
class PerformanceGrid extends StatelessWidget {
  final List<Widget> children;
  final int crossAxisCount;
  final double spacing;
  final double runSpacing;
  final EdgeInsets? padding;
  final ScrollController? controller;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const PerformanceGrid({
    super.key,
    required this.children,
    this.crossAxisCount = 2,
    this.spacing = 8.0,
    this.runSpacing = 8.0,
    this.padding,
    this.controller,
    this.shrinkWrap = true,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: controller,
      padding: padding,
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
}

/// مكون محسن للنصوص - يتجنب إعادة البناء غير الضرورية
class PerformanceText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const PerformanceText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// مكون محسن للأزرار - يتجنب إعادة البناء غير الضرورية
class PerformanceButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final ButtonStyle? style;
  final bool isOutlined;

  const PerformanceButton(
    this.text, {
    super.key,
    this.onPressed,
    this.icon,
    this.style,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget child = icon != null
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon),
              const SizedBox(width: 8),
              Text(text),
            ],
          )
        : Text(text);

    if (isOutlined) {
      return OutlinedButton(
        onPressed: onPressed,
        style: style,
        child: child,
      );
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: style,
      child: child,
    );
  }
}
