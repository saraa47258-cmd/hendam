import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../styles/responsive.dart';

class ResponsiveImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  
  const ResponsiveImage({
    super.key,
    this.imageUrl,
    this.width,
    this.height,
    this.fit,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveWidth = width ?? context.productImageSize();
    final effectiveHeight = height ?? effectiveWidth;
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(context.responsiveRadius());
    
    return Container(
      width: effectiveWidth,
      height: effectiveHeight,
      decoration: BoxDecoration(
        borderRadius: effectiveBorderRadius,
        color: backgroundColor ?? Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: ClipRRect(
        borderRadius: effectiveBorderRadius,
        child: _buildImage(context),
      ),
    );
  }
  
  Widget _buildImage(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return placeholder ?? _defaultPlaceholder(context);
    }
    
    if (_isNetwork(imageUrl!)) {
      return CachedNetworkImage(
        imageUrl: imageUrl!,
        fit: fit ?? BoxFit.cover,
        placeholder: (context, url) => placeholder ?? _defaultPlaceholder(context),
        errorWidget: (context, url, error) => errorWidget ?? _defaultErrorWidget(context),
      );
    }
    
    if (imageUrl!.endsWith('.svg')) {
      return SvgPicture.asset(
        _resolveAssetPath(imageUrl!),
        fit: fit ?? BoxFit.contain,
        placeholderBuilder: (context) => placeholder ?? _defaultPlaceholder(context),
      );
    }
    
    return Image.asset(
      _resolveAssetPath(imageUrl!),
      fit: fit ?? BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => errorWidget ?? _defaultErrorWidget(context),
    );
  }
  
  bool _isNetwork(String src) => src.startsWith('http');
  
  String _resolveAssetPath(String src) {
    // حل مسارات الأصول المختلفة
    if (src.startsWith('assets/')) return src;
    if (src.startsWith('lib/assets/')) return src.substring(4);
    return 'assets/$src';
  }
  
  Widget _defaultPlaceholder(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      color: cs.surfaceContainerHighest,
      child: Icon(
        Icons.image,
        color: cs.onSurfaceVariant,
        size: context.iconSize(),
      ),
    );
  }
  
  Widget _defaultErrorWidget(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      color: cs.surfaceContainerHighest,
      child: Icon(
        Icons.broken_image,
        color: cs.onSurfaceVariant,
        size: context.iconSize(),
      ),
    );
  }
}

class ResponsiveAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double? size;
  final Color? backgroundColor;
  final Color? foregroundColor;
  
  const ResponsiveAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.size,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveSize = size ?? context.avatarSize();
    final cs = Theme.of(context).colorScheme;
    
    return CircleAvatar(
      radius: effectiveSize / 2,
      backgroundColor: backgroundColor ?? cs.primaryContainer,
      foregroundColor: foregroundColor ?? cs.onPrimaryContainer,
      backgroundImage: imageUrl != null && imageUrl!.isNotEmpty
        ? (_isNetwork(imageUrl!) 
          ? CachedNetworkImageProvider(imageUrl!)
          : AssetImage(_resolveAssetPath(imageUrl!)) as ImageProvider)
        : null,
      child: imageUrl == null || imageUrl!.isEmpty
        ? Text(
            name?.isNotEmpty == true ? name![0].toUpperCase() : '?',
            style: TextStyle(
              fontSize: effectiveSize * 0.4,
              fontWeight: FontWeight.bold,
            ),
          )
        : null,
    );
  }
  
  bool _isNetwork(String src) => src.startsWith('http');
  
  String _resolveAssetPath(String src) {
    if (src.startsWith('assets/')) return src;
    if (src.startsWith('lib/assets/')) return src.substring(4);
    return 'assets/$src';
  }
}

class ResponsiveImageGrid extends StatelessWidget {
  final List<String> imageUrls;
  final int? maxColumns;
  final double? spacing;
  final double? aspectRatio;
  final VoidCallback? onTap;
  final VoidCallback? onAddMore;
  
  const ResponsiveImageGrid({
    super.key,
    required this.imageUrls,
    this.maxColumns,
    this.spacing,
    this.aspectRatio,
    this.onTap,
    this.onAddMore,
  });

  @override
  Widget build(BuildContext context) {
    final columns = context.gridColumns(
      minTileWidth: 200.0,
      max: maxColumns ?? 4,
    );
    final effectiveSpacing = spacing ?? context.responsiveSpacing();
    final effectiveAspectRatio = aspectRatio ?? 1.0;
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: effectiveSpacing,
        mainAxisSpacing: effectiveSpacing,
        childAspectRatio: effectiveAspectRatio,
      ),
      itemCount: imageUrls.length + (onAddMore != null ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= imageUrls.length) {
          // زر إضافة المزيد
          return _buildAddMoreButton(context);
        }
        
        return GestureDetector(
          onTap: onTap,
          child: ResponsiveImage(
            imageUrl: imageUrls[index],
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }
  
  Widget _buildAddMoreButton(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onAddMore,
      borderRadius: BorderRadius.circular(context.responsiveRadius()),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: cs.outline,
            style: BorderStyle.solid,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(context.responsiveRadius()),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate,
              color: cs.onSurfaceVariant,
              size: context.iconSize() * 1.5,
            ),
            SizedBox(height: context.responsiveSpacing() * 0.5),
            Text(
              'إضافة صورة',
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontSize: context.responsiveFontSize(12.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
