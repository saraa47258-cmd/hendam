import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../styles/responsive.dart';

class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsets? padding;
  final bool centerContent;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
    this.centerContent = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveMaxWidth = maxWidth ?? context.maxContentWidth();
    final effectivePadding =
        padding ?? EdgeInsets.all(context.responsivePadding());

    Widget content = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: effectiveMaxWidth),
      child: Padding(
        padding: effectivePadding,
        child: child,
      ),
    );

    if (centerContent) {
      return Center(child: content);
    }

    return content;
  }
}

class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double? spacing;
  final double? runSpacing;
  final double? childAspectRatio;
  final double? minTileWidth;
  final int? maxColumns;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing,
    this.runSpacing,
    this.childAspectRatio,
    this.minTileWidth,
    this.maxColumns,
    this.shrinkWrap = true,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    final columns = context
        .responsiveGridColumns(
          itemWidth: minTileWidth ?? 300.0,
        )
        .clamp(1, maxColumns ?? 6);

    final effectiveSpacing = spacing ?? context.responsiveSpacing();
    final effectiveRunSpacing = runSpacing ?? context.responsiveSpacing();
    final effectivePhysics =
        physics ?? (shrinkWrap ? const NeverScrollableScrollPhysics() : null);

    return GridView.builder(
      shrinkWrap: shrinkWrap,
      physics: effectivePhysics,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: effectiveSpacing,
        mainAxisSpacing: effectiveRunSpacing,
        childAspectRatio: childAspectRatio ?? 1.0,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}

class ResponsiveWrap extends StatelessWidget {
  final List<Widget> children;
  final double? spacing;
  final double? runSpacing;
  final WrapAlignment? alignment;
  final WrapCrossAlignment? crossAxisAlignment;

  const ResponsiveWrap({
    super.key,
    required this.children,
    this.spacing,
    this.runSpacing,
    this.alignment,
    this.crossAxisAlignment,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveSpacing = spacing ?? context.responsiveSpacing();
    final effectiveRunSpacing = runSpacing ?? context.responsiveSpacing();

    return Wrap(
      spacing: effectiveSpacing,
      runSpacing: effectiveRunSpacing,
      alignment: alignment ?? WrapAlignment.start,
      crossAxisAlignment: crossAxisAlignment ?? WrapCrossAlignment.start,
      children: children,
    );
  }
}

class ResponsiveRow extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment? mainAxisAlignment;
  final CrossAxisAlignment? crossAxisAlignment;
  final MainAxisSize? mainAxisSize;
  final double? spacing;

  const ResponsiveRow({
    super.key,
    required this.children,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
    this.mainAxisSize,
    this.spacing,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveSpacing = spacing ?? context.responsiveSpacing();

    if (context.isPhone && children.length > 2) {
      // على الهاتف، استخدم Column إذا كان هناك أكثر من عنصرين - محسن لتجنب إعادة البناء
      return Column(
        mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
        crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.start,
        mainAxisSize: mainAxisSize ?? MainAxisSize.min,
        children: children
            .expand((child) => [child, SizedBox(height: effectiveSpacing)])
            .take(children.length * 2 - 1)
            .toList(),
      );
    }

    // محسن: استخدام Row مباشرة لتجنب إعادة البناء غير الضرورية
    return Row(
      mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
      crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.center,
      mainAxisSize: mainAxisSize ?? MainAxisSize.min,
      children: children
          .expand((child) => [child, SizedBox(width: effectiveSpacing)])
          .take(children.length * 2 - 1)
          .toList(),
    );
  }
}

class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final Color? color;
  final double? elevation;
  final VoidCallback? onTap;

  const ResponsiveCard({
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
    final effectiveMargin =
        margin ?? EdgeInsets.all(context.responsiveSpacing());
    final effectivePadding =
        padding ?? EdgeInsets.all(context.responsivePadding());
    final effectiveElevation =
        elevation ?? context.pick(2.0, tablet: 3.0, desktop: 4.0);

    Widget card = Card(
      margin: effectiveMargin,
      elevation: effectiveElevation,
      color: color,
      child: Padding(
        padding: effectivePadding,
        child: child,
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(context.responsiveRadius()),
        child: card,
      );
    }

    return card;
  }
}

/// مكون متجاوب للنصوص
class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final double? fontSize;
  final FontWeight? fontWeight;

  const ResponsiveText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.fontSize,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveStyle =
        (style ?? Theme.of(context).textTheme.bodyMedium)?.copyWith(
      fontSize: fontSize != null ? context.responsiveFontSize(fontSize!) : null,
      fontWeight: fontWeight,
    );

    return Text(
      text,
      style: effectiveStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// مكون متجاوب للأزرار
class ResponsiveButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final ButtonStyle? style;
  final bool isOutlined;
  final double? width;

  const ResponsiveButton(
    this.text, {
    super.key,
    this.onPressed,
    this.icon,
    this.style,
    this.isOutlined = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final buttonHeight = context.buttonHeight();
    final fontSize = context.responsiveFontSize(16.0);

    Widget button;

    if (isOutlined) {
      button = OutlinedButton(
        onPressed: onPressed,
        style: style ??
            OutlinedButton.styleFrom(
              minimumSize: Size(width ?? double.infinity, buttonHeight),
              textStyle: TextStyle(fontSize: fontSize),
            ),
        child: _buildButtonContent(),
      );
    } else {
      button = ElevatedButton(
        onPressed: onPressed,
        style: style ??
            ElevatedButton.styleFrom(
              minimumSize: Size(width ?? double.infinity, buttonHeight),
              textStyle: TextStyle(fontSize: fontSize),
            ),
        child: _buildButtonContent(),
      );
    }

    return SizedBox(
      width: width,
      height: buttonHeight,
      child: button,
    );
  }

  Widget _buildButtonContent() {
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          const SizedBox(width: 8),
          Text(text),
        ],
      );
    }
    return Text(text);
  }
}

/// مكون متجاوب للصور
class ResponsiveImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const ResponsiveImage(
    this.imageUrl, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveWidth = width ?? context.productImageSize();
    final effectiveHeight = height ?? context.productImageSize();

    Widget image = CachedNetworkImage(
      imageUrl: imageUrl,
      width: effectiveWidth,
      height: effectiveHeight,
      fit: fit,
      memCacheWidth:
          (effectiveWidth * MediaQuery.of(context).devicePixelRatio).round(),
      memCacheHeight:
          (effectiveHeight * MediaQuery.of(context).devicePixelRatio).round(),
      placeholder: (context, url) =>
          placeholder ?? _buildDefaultPlaceholder(context),
      errorWidget: (context, url, error) =>
          errorWidget ?? _buildDefaultError(context),
      fadeInDuration: const Duration(milliseconds: 200),
      fadeOutDuration: const Duration(milliseconds: 100),
    );

    if (borderRadius != null) {
      image = ClipRRect(
        borderRadius: borderRadius!,
        child: image,
      );
    }

    return image;
  }

  Widget _buildDefaultPlaceholder(BuildContext context) {
    return Container(
      width: width ?? context.productImageSize(),
      height: height ?? context.productImageSize(),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildDefaultError(BuildContext context) {
    return Container(
      width: width ?? context.productImageSize(),
      height: height ?? context.productImageSize(),
      color: Theme.of(context).colorScheme.errorContainer,
      child: Icon(
        Icons.error_outline,
        color: Theme.of(context).colorScheme.onErrorContainer,
        size: context.iconSize(),
      ),
    );
  }
}

/// مكون متجاوب للبطاقات المحسن
class ResponsiveCardEnhanced extends StatelessWidget {
  final Widget child;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final Color? color;
  final double? elevation;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;

  const ResponsiveCardEnhanced({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.color,
    this.elevation,
    this.onTap,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveMargin =
        margin ?? EdgeInsets.all(context.responsiveMargin());
    final effectivePadding =
        padding ?? EdgeInsets.all(context.responsivePadding());
    final effectiveElevation =
        elevation ?? context.pick(2.0, tablet: 3.0, desktop: 4.0);
    final effectiveBorderRadius =
        borderRadius ?? BorderRadius.circular(context.responsiveRadius());

    Widget card = Card(
      margin: effectiveMargin,
      elevation: effectiveElevation,
      color: color,
      shape: RoundedRectangleBorder(borderRadius: effectiveBorderRadius),
      child: Padding(
        padding: effectivePadding,
        child: child,
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: effectiveBorderRadius,
        child: card,
      );
    }

    return card;
  }
}
