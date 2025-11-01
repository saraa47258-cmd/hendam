import 'package:flutter/material.dart';
import '../styles/responsive.dart';

class SafeText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;
  
  const SafeText(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: constraints.maxWidth,
          ),
          child: Text(
            text,
            style: style,
            maxLines: maxLines,
            overflow: overflow ?? TextOverflow.ellipsis,
            textAlign: textAlign,
          ),
        );
      },
    );
  }
}

class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;
  
  const ResponsiveText(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    final responsiveStyle = style?.copyWith(
      fontSize: style?.fontSize != null 
        ? context.responsiveFontSize(style!.fontSize!)
        : null,
    );
    
    return SafeText(
      text,
      style: responsiveStyle,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
    );
  }
}

class ExpandableText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final int maxLines;
  final String expandText;
  final String collapseText;
  
  const ExpandableText(
    this.text, {
    super.key,
    this.style,
    this.maxLines = 3,
    this.expandText = 'عرض المزيد',
    this.collapseText = 'عرض أقل',
  });

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _isExpanded = false;
  
  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.text,
          style: widget.style,
          maxLines: _isExpanded ? null : widget.maxLines,
          overflow: _isExpanded ? null : TextOverflow.ellipsis,
        ),
        if (widget.text.length > 100)
          Padding(
            padding: EdgeInsets.only(top: context.responsiveSpacing() * 0.5),
            child: TextButton(
              onPressed: () => setState(() => _isExpanded = !_isExpanded),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                _isExpanded ? widget.collapseText : widget.expandText,
                style: tt.bodySmall?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class AutoSizeText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final double minFontSize;
  final double maxFontSize;
  
  const AutoSizeText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.minFontSize = 12.0,
    this.maxFontSize = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: constraints.maxWidth,
            ),
            child: Text(
              text,
              style: style?.copyWith(
                fontSize: maxFontSize,
              ),
              textAlign: textAlign,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      },
    );
  }
}

class ResponsiveTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  final IconData? icon;
  final bool isExpanded;
  
  const ResponsiveTextButton(
    this.text, {
    super.key,
    this.onPressed,
    this.style,
    this.icon,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    
    Widget button = TextButton(
      onPressed: onPressed,
      style: style ?? TextButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: context.responsivePadding(),
          vertical: context.responsiveSpacing(),
        ),
        textStyle: tt.bodyMedium?.copyWith(
          fontSize: context.responsiveFontSize(14.0),
        ),
      ),
      child: icon != null 
        ? Row(
            mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
            children: [
              Icon(icon, size: context.iconSize()),
              SizedBox(width: context.responsiveSpacing() * 0.5),
              Flexible(child: Text(text)),
            ],
          )
        : Text(text),
    );
    
    return isExpanded 
      ? SizedBox(width: double.infinity, child: button)
      : button;
  }
}
