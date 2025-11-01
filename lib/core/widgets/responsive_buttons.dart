import 'package:flutter/material.dart';
import '../styles/responsive.dart';

class ResponsiveButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  final bool isExpanded;
  final IconData? icon;
  final bool isLoading;
  final Widget? loadingWidget;
  
  const ResponsiveButton(
    this.text, {
    super.key,
    this.onPressed,
    this.style,
    this.isExpanded = false,
    this.icon,
    this.isLoading = false,
    this.loadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    final buttonHeight = context.buttonHeight();
    final fontSize = context.responsiveFontSize(16.0);
    final iconSize = context.iconSize();
    
    Widget button = FilledButton(
      onPressed: isLoading ? null : onPressed,
      style: style?.copyWith(
        minimumSize: WidgetStateProperty.all(
          Size(isExpanded ? double.infinity : 0, buttonHeight),
        ),
        textStyle: WidgetStateProperty.all(
          TextStyle(fontSize: fontSize),
        ),
      ) ?? FilledButton.styleFrom(
        minimumSize: Size(isExpanded ? double.infinity : 0, buttonHeight),
        textStyle: TextStyle(fontSize: fontSize),
      ),
      child: isLoading 
        ? loadingWidget ?? _buildLoadingWidget(context, iconSize)
        : icon != null 
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: iconSize),
                SizedBox(width: context.responsiveSpacing() * 0.5),
                Text(text),
              ],
            )
          : Text(text),
    );
    
    return isExpanded 
      ? SizedBox(width: double.infinity, child: button)
      : button;
  }
  
  Widget _buildLoadingWidget(BuildContext context, double iconSize) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: iconSize,
      height: iconSize,
      child: CircularProgressIndicator(
        strokeWidth: 2.0,
        valueColor: AlwaysStoppedAnimation<Color>(cs.onPrimary),
      ),
    );
  }
}

class ResponsiveOutlinedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  final bool isExpanded;
  final IconData? icon;
  final bool isLoading;
  
  const ResponsiveOutlinedButton(
    this.text, {
    super.key,
    this.onPressed,
    this.style,
    this.isExpanded = false,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonHeight = context.buttonHeight();
    final fontSize = context.responsiveFontSize(16.0);
    final iconSize = context.iconSize();
    
    Widget button = OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: style?.copyWith(
        minimumSize: WidgetStateProperty.all(
          Size(isExpanded ? double.infinity : 0, buttonHeight),
        ),
        textStyle: WidgetStateProperty.all(
          TextStyle(fontSize: fontSize),
        ),
      ) ?? OutlinedButton.styleFrom(
        minimumSize: Size(isExpanded ? double.infinity : 0, buttonHeight),
        textStyle: TextStyle(fontSize: fontSize),
      ),
      child: isLoading 
        ? _buildLoadingWidget(context, iconSize)
        : icon != null 
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: iconSize),
                SizedBox(width: context.responsiveSpacing() * 0.5),
                Text(text),
              ],
            )
          : Text(text),
    );
    
    return isExpanded 
      ? SizedBox(width: double.infinity, child: button)
      : button;
  }
  
  Widget _buildLoadingWidget(BuildContext context, double iconSize) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: iconSize,
      height: iconSize,
      child: CircularProgressIndicator(
        strokeWidth: 2.0,
        valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
      ),
    );
  }
}

class ResponsiveIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? color;
  final double? size;
  final bool isLoading;
  
  const ResponsiveIconButton(
    this.icon, {
    super.key,
    this.onPressed,
    this.tooltip,
    this.color,
    this.size,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = size ?? context.iconSize();
    
    Widget button = IconButton(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading 
        ? _buildLoadingWidget(context, iconSize)
        : Icon(icon, size: iconSize, color: color),
      tooltip: tooltip,
    );
    
    return button;
  }
  
  Widget _buildLoadingWidget(BuildContext context, double iconSize) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: iconSize,
      height: iconSize,
      child: CircularProgressIndicator(
        strokeWidth: 2.0,
        valueColor: AlwaysStoppedAnimation<Color>(color ?? cs.primary),
      ),
    );
  }
}

class ResponsiveFloatingActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final bool isExtended;
  final String? label;
  final bool isLoading;
  
  const ResponsiveFloatingActionButton(
    this.icon, {
    super.key,
    this.onPressed,
    this.tooltip,
    this.isExtended = false,
    this.label,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = context.iconSize();
    
    if (isExtended && label != null) {
      return FloatingActionButton.extended(
        onPressed: isLoading ? null : onPressed,
        tooltip: tooltip,
        icon: isLoading 
          ? _buildLoadingWidget(context, iconSize)
          : Icon(icon, size: iconSize),
        label: isLoading ? const SizedBox.shrink() : Text(label!),
      );
    }
    
    return FloatingActionButton(
      onPressed: isLoading ? null : onPressed,
      tooltip: tooltip,
      child: isLoading 
        ? _buildLoadingWidget(context, iconSize)
        : Icon(icon, size: iconSize),
    );
  }
  
  Widget _buildLoadingWidget(BuildContext context, double iconSize) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: iconSize,
      height: iconSize,
      child: CircularProgressIndicator(
        strokeWidth: 2.0,
        valueColor: AlwaysStoppedAnimation<Color>(cs.onPrimary),
      ),
    );
  }
}

class ResponsiveButtonGroup extends StatelessWidget {
  final List<ResponsiveButtonData> buttons;
  final bool isVertical;
  final double? spacing;
  
  const ResponsiveButtonGroup({
    super.key,
    required this.buttons,
    this.isVertical = false,
    this.spacing,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveSpacing = spacing ?? context.responsiveSpacing();
    
    if (isVertical) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: buttons
            .expand((button) => [
              button.build(context),
              SizedBox(height: effectiveSpacing),
            ])
            .take(buttons.length * 2 - 1)
            .toList(),
      );
    }
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: buttons
          .expand((button) => [
            button.build(context),
            SizedBox(width: effectiveSpacing),
          ])
          .take(buttons.length * 2 - 1)
          .toList(),
    );
  }
}

class ResponsiveButtonData {
  final String text;
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  final IconData? icon;
  final bool isLoading;
  final bool isPrimary;
  
  const ResponsiveButtonData({
    required this.text,
    this.onPressed,
    this.style,
    this.icon,
    this.isLoading = false,
    this.isPrimary = true,
  });
  
  Widget build(BuildContext context) {
    if (isPrimary) {
      return ResponsiveButton(
        text,
        onPressed: onPressed,
        style: style,
        icon: icon,
        isLoading: isLoading,
      );
    } else {
      return ResponsiveOutlinedButton(
        text,
        onPressed: onPressed,
        style: style,
        icon: icon,
        isLoading: isLoading,
      );
    }
  }
}
