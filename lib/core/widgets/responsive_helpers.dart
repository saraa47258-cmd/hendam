import 'package:flutter/material.dart';
import '../styles/responsive.dart';

/// مساعدات الاستجابة العامة
class ResponsiveHelpers {
  /// إنشاء EdgeInsets متجاوب
  static EdgeInsets responsivePadding(
    BuildContext context, {
    double? horizontal,
    double? vertical,
    double? all,
  }) {
    final h = horizontal ?? context.responsivePadding();
    final v = vertical ?? context.responsivePadding();
    final a = all ?? context.responsivePadding();

    if (horizontal != null || vertical != null) {
      return EdgeInsets.symmetric(horizontal: h, vertical: v);
    }
    return EdgeInsets.all(a);
  }

  /// إنشاء SizedBox متجاوب
  static Widget responsiveSizedBox(
    BuildContext context, {
    double? width,
    double? height,
    double? spacing,
  }) {
    final w = width ?? 0;
    final h = height ?? (spacing ?? context.responsiveSpacing());
    return SizedBox(width: w, height: h);
  }

  /// إنشاء Divider متجاوب
  static Widget responsiveDivider(
    BuildContext context, {
    double? thickness,
    double? indent,
    double? endIndent,
    Color? color,
  }) {
    final effectiveThickness = thickness ?? 1.0;
    final effectiveIndent = indent ?? context.responsivePadding();
    final effectiveEndIndent = endIndent ?? context.responsivePadding();

    return Divider(
      thickness: effectiveThickness,
      indent: effectiveIndent,
      endIndent: effectiveEndIndent,
      color: color,
    );
  }

  /// إنشاء Container متجاوب للصور
  static Widget responsiveImageContainer(
    BuildContext context, {
    required Widget child,
    double? width,
    double? height,
    BoxFit? fit,
    BorderRadius? borderRadius,
  }) {
    final effectiveWidth = width ?? context.productImageSize();
    final effectiveHeight = height ?? context.productImageSize();
    final effectiveBorderRadius =
        borderRadius ?? BorderRadius.circular(context.responsiveRadius());

    return Container(
      width: effectiveWidth,
      height: effectiveHeight,
      decoration: BoxDecoration(
        borderRadius: effectiveBorderRadius,
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }

  /// إنشاء قائمة منسدلة متجاوبة
  static Widget responsiveDropdown<T>(
    BuildContext context, {
    required T? value,
    required List<T> items,
    required String Function(T) itemBuilder,
    required ValueChanged<T?> onChanged,
    String? hint,
    String? label,
  }) {
    final hintStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontSize: context.responsiveFontSize(14.0),
        );

    return DropdownButtonFormField<T>(
      value: value,
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(
            itemBuilder(item),
            style: hintStyle,
          ),
        );
      }).toList(),
      onChanged: onChanged,
      hint: hint != null ? Text(hint, style: hintStyle) : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: hintStyle,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.responsiveRadius()),
        ),
        contentPadding: EdgeInsets.all(context.responsivePadding()),
      ),
    );
  }

  /// إنشاء شريط بحث متجاوب
  static Widget responsiveSearchBar(
    BuildContext context, {
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
    String? hintText,
    Widget? suffixIcon,
  }) {
    final hintStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontSize: context.responsiveFontSize(14.0),
        );

    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText ?? 'ابحث...',
        hintStyle: hintStyle,
        prefixIcon: Icon(
          Icons.search,
          size: context.iconSize(),
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.responsiveRadius()),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.all(context.responsivePadding()),
      ),
    );
  }

  /// إنشاء شريط تقدم متجاوب
  static Widget responsiveProgressIndicator(
    BuildContext context, {
    required double value,
    double? height,
    Color? backgroundColor,
    Color? valueColor,
  }) {
    final effectiveHeight =
        height ?? context.pick(8.0, tablet: 10.0, desktop: 12.0);

    return LinearProgressIndicator(
      value: value,
      minHeight: effectiveHeight,
      backgroundColor: backgroundColor,
      valueColor: AlwaysStoppedAnimation<Color>(
        valueColor ?? Theme.of(context).colorScheme.primary,
      ),
    );
  }

  /// إنشاء شريط تبويب متجاوب
  static Widget responsiveTabBar(
    BuildContext context, {
    required List<String> tabs,
    required int selectedIndex,
    required ValueChanged<int> onTap,
  }) {
    return TabBar(
      tabs: tabs
          .map((tab) => Tab(
                child: Text(
                  tab,
                  style: TextStyle(fontSize: context.responsiveFontSize(14.0)),
                ),
              ))
          .toList(),
      onTap: onTap,
      isScrollable: context.isMobile,
      labelPadding:
          EdgeInsets.symmetric(horizontal: context.responsivePadding()),
    );
  }

  /// إنشاء قائمة متجاوبة
  static Widget responsiveListTile(
    BuildContext context, {
    required Widget title,
    Widget? subtitle,
    Widget? leading,
    Widget? trailing,
    VoidCallback? onTap,
    bool? dense,
  }) {
    return ListTile(
      title: title,
      subtitle: subtitle,
      leading: leading,
      trailing: trailing,
      onTap: onTap,
      dense: dense ?? context.isMobile,
      contentPadding: EdgeInsets.symmetric(
        horizontal: context.responsivePadding(),
        vertical: context.responsiveMargin(),
      ),
    );
  }

  /// إنشاء بطاقة معلومات متجاوبة
  static Widget responsiveInfoCard(
    BuildContext context, {
    required String title,
    required String value,
    IconData? icon,
    Color? iconColor,
    VoidCallback? onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      elevation: context.pick(2.0, tablet: 3.0, desktop: 4.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.responsiveRadius()),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(context.responsiveRadius()),
        child: Padding(
          padding: EdgeInsets.all(context.responsivePadding()),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: context.iconSize(),
                      color: iconColor ?? cs.primary,
                    ),
                    SizedBox(width: context.responsiveSpacing()),
                  ],
                  Expanded(
                    child: Text(
                      title,
                      style: tt.titleSmall?.copyWith(
                        fontSize: context.responsiveFontSize(14.0),
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.responsiveMargin()),
              Text(
                value,
                style: tt.headlineSmall?.copyWith(
                  fontSize: context.responsiveFontSize(18.0),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// إنشاء شريط إجراءات متجاوب
  static Widget responsiveActionBar(
    BuildContext context, {
    required List<Widget> actions,
    String? title,
    Widget? leading,
  }) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (context.isMobile) {
      // على الهاتف، اعرض في AppBar
      return AppBar(
        title: title != null ? Text(title) : null,
        leading: leading,
        actions: actions,
        elevation: 1,
      );
    }

    // على الشاشات الأكبر، اعرض كشريط منفصل
    return Container(
      padding: EdgeInsets.all(context.responsivePadding()),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(
          bottom: BorderSide(color: cs.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          if (leading != null) ...[
            leading,
            SizedBox(width: context.responsiveSpacing()),
          ],
          if (title != null) ...[
            Text(
              title,
              style: tt.titleLarge?.copyWith(
                fontSize: context.responsiveFontSize(20.0),
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
          ] else ...[
            const Spacer(),
          ],
          ...actions,
        ],
      ),
    );
  }

  /// إنشاء حاوية محتوى متجاوبة
  static Widget responsiveContentContainer(
    BuildContext context, {
    required Widget child,
    EdgeInsets? padding,
    bool? centerContent,
  }) {
    final effectivePadding =
        padding ?? EdgeInsets.all(context.responsivePadding());
    final shouldCenter = centerContent ?? true;

    Widget content = Padding(
      padding: effectivePadding,
      child: child,
    );

    if (shouldCenter) {
      content = Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: context.maxContentWidth(),
          ),
          child: content,
        ),
      );
    }

    return content;
  }
}

