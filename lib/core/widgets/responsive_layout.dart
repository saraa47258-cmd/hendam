import 'package:flutter/material.dart';
import '../styles/responsive.dart';

/// مكون تخطيط متجاوب أساسي
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? largeDesktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
  });

  @override
  Widget build(BuildContext context) {
    if (context.isLargeDesktop && largeDesktop != null) {
      return largeDesktop!;
    }
    if (context.isDesktop && desktop != null) {
      return desktop!;
    }
    if (context.isTablet && tablet != null) {
      return tablet!;
    }
    return mobile;
  }
}

/// مكون تخطيط متجاوب مع شريط جانبي
class ResponsiveSidebarLayout extends StatelessWidget {
  final Widget content;
  final Widget? sidebar;
  final double? sidebarWidth;
  final bool sidebarAlwaysVisible;

  const ResponsiveSidebarLayout({
    super.key,
    required this.content,
    this.sidebar,
    this.sidebarWidth,
    this.sidebarAlwaysVisible = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveSidebarWidth = sidebarWidth ?? context.sidebarWidth();

    if (context.isMobile || (!sidebarAlwaysVisible && !context.isDesktop)) {
      // على الهاتف، اعرض المحتوى فقط
      return content;
    }

    if (sidebar == null) {
      return content;
    }

    return Row(
      children: [
        // الشريط الجانبي
        SizedBox(
          width: effectiveSidebarWidth,
          child: sidebar!,
        ),
        // المحتوى الرئيسي
        Expanded(
          child: content,
        ),
      ],
    );
  }
}

/// مكون تخطيط متجاوب للقوائم
class ResponsiveListView extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsets? padding;
  final double? itemSpacing;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final int? maxItemsPerRow;

  const ResponsiveListView({
    super.key,
    required this.children,
    this.padding,
    this.itemSpacing,
    this.shrinkWrap = true,
    this.physics,
    this.maxItemsPerRow,
  });

  @override
  Widget build(BuildContext context) {
    final effectivePadding =
        padding ?? EdgeInsets.all(context.responsivePadding());
    final effectiveSpacing = itemSpacing ?? context.responsiveSpacing();
    final effectivePhysics =
        physics ?? (shrinkWrap ? const NeverScrollableScrollPhysics() : null);

    if (context.isMobile) {
      // على الهاتف، اعرض قائمة عمودية
      return ListView.separated(
        shrinkWrap: shrinkWrap,
        physics: effectivePhysics,
        padding: effectivePadding,
        itemCount: children.length,
        separatorBuilder: (context, index) =>
            SizedBox(height: effectiveSpacing),
        itemBuilder: (context, index) => children[index],
      );
    }

    // على التابلت والديسكتوب، اعرض شبكة
    final columns = context.responsiveGridColumns();
    final maxColumns = maxItemsPerRow ?? columns;
    final actualColumns = columns.clamp(1, maxColumns);

    return Padding(
      padding: effectivePadding,
      child: GridView.builder(
        shrinkWrap: shrinkWrap,
        physics: effectivePhysics,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: actualColumns,
          crossAxisSpacing: effectiveSpacing,
          mainAxisSpacing: effectiveSpacing,
          childAspectRatio: 1.0,
        ),
        itemCount: children.length,
        itemBuilder: (context, index) => children[index],
      ),
    );
  }
}

/// مكون تخطيط متجاوب للنماذج
class ResponsiveFormLayout extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsets? padding;
  final double? spacing;
  final int? maxColumns;

  const ResponsiveFormLayout({
    super.key,
    required this.children,
    this.padding,
    this.spacing,
    this.maxColumns,
  });

  @override
  Widget build(BuildContext context) {
    final effectivePadding =
        padding ?? EdgeInsets.all(context.responsivePadding());
    final effectiveSpacing = spacing ?? context.responsiveSpacing();

    if (context.isMobile) {
      // على الهاتف، اعرض النموذج في عمود واحد
      return Padding(
        padding: effectivePadding,
        child: Column(
          children: children
              .expand((child) => [child, SizedBox(height: effectiveSpacing)])
              .take(children.length * 2 - 1)
              .toList(),
        ),
      );
    }

    // على الشاشات الأكبر، اعرض في شبكة
    final columns = maxColumns ?? context.responsiveGridColumns();

    return Padding(
      padding: effectivePadding,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: effectiveSpacing,
          mainAxisSpacing: effectiveSpacing,
          childAspectRatio: 1.5,
        ),
        itemCount: children.length,
        itemBuilder: (context, index) => children[index],
      ),
    );
  }
}

/// مكون تخطيط متجاوب للعناوين
class ResponsiveHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;
  final EdgeInsets? padding;

  const ResponsiveHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final effectivePadding =
        padding ?? EdgeInsets.all(context.responsivePadding());
    final titleSize = context.responsiveFontSize(24.0);
    final subtitleSize = context.responsiveFontSize(16.0);

    return Padding(
      padding: effectivePadding,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: context.responsiveMargin()),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: subtitleSize,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ],
            ),
          ),
          if (action != null) ...[
            SizedBox(width: context.responsiveSpacing()),
            action!,
          ],
        ],
      ),
    );
  }
}

/// مكون تخطيط متجاوب للأزرار
class ResponsiveButtonBar extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment? mainAxisAlignment;
  final double? spacing;

  const ResponsiveButtonBar({
    super.key,
    required this.children,
    this.mainAxisAlignment,
    this.spacing,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveSpacing = spacing ?? context.responsiveSpacing();

    if (context.isMobile) {
      // على الهاتف، اعرض الأزرار في عمود
      return Column(
        mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
        children: children
            .expand((child) => [child, SizedBox(height: effectiveSpacing)])
            .take(children.length * 2 - 1)
            .toList(),
      );
    }

    // على الشاشات الأكبر، اعرض في صف
    return Row(
      mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
      children: children
          .expand((child) => [child, SizedBox(width: effectiveSpacing)])
          .take(children.length * 2 - 1)
          .toList(),
    );
  }
}

/// مكون تخطيط متجاوب للبطاقات
class ResponsiveCardGrid extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsets? padding;
  final double? spacing;
  final double? childAspectRatio;
  final int? maxColumns;

  const ResponsiveCardGrid({
    super.key,
    required this.children,
    this.padding,
    this.spacing,
    this.childAspectRatio,
    this.maxColumns,
  });

  @override
  Widget build(BuildContext context) {
    final effectivePadding =
        padding ?? EdgeInsets.all(context.responsivePadding());
    final effectiveSpacing = spacing ?? context.responsiveSpacing();
    final effectiveAspectRatio = childAspectRatio ?? 1.2;

    final columns = maxColumns ?? context.responsiveGridColumns();

    return Padding(
      padding: effectivePadding,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: effectiveSpacing,
          mainAxisSpacing: effectiveSpacing,
          childAspectRatio: effectiveAspectRatio,
        ),
        itemCount: children.length,
        itemBuilder: (context, index) => children[index],
      ),
    );
  }
}

