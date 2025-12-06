import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/styles/responsive.dart';
import 'skeletons.dart';

bool _isNetwork(String p) =>
    p.startsWith('http://') || p.startsWith('https://');

String _normalizeLocal(String raw) {
  var x = raw.trim().replaceAll('\\', '/');
  if (x.toLowerCase().startsWith('file://')) x = x.substring(7);
  while (x.startsWith('/')) {
    x = x.substring(1);
  }
  return x;
}

List<String> _assetCandidates(String raw) {
  final p = _normalizeLocal(raw);
  final cands = <String>[];

  void addOnce(String s) {
    if (s.isEmpty) return;
    if (!cands.contains(s)) cands.add(s);
  }

  // كما هو
  addOnce(p);

  // بدائل assets/
  if (p.startsWith('lib/assets/')) {
    addOnce(p.substring(4)); // بدون lib/
  } else if (p.startsWith('assets/')) {
    addOnce(p); // كما هو
  } else {
    addOnce('assets/$p'); // إضافة assets/
  }

  // حالات شائعة
  if (p.startsWith('assets/')) addOnce(p);
  if (p.startsWith('lib/assets/')) addOnce(p.replaceFirst('lib/', ''));

  return cands;
}

class AnyImage extends StatelessWidget {
  final String? src;
  final BoxFit fit;
  final Alignment alignment;
  final Widget? fallback;
  final double? width;
  final double? height;
  final FilterQuality filterQuality;
  final bool gaplessPlayback;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;

  const AnyImage({
    super.key,
    required this.src,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.fallback,
    this.width,
    this.height,
    this.filterQuality = FilterQuality.low,
    this.gaplessPlayback = false,
    this.borderRadius,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final raw = (src ?? '').trim();
    final cs = Theme.of(context).colorScheme;

    // أبعاد متجاوبة - تحسين للأداء
    // إذا لم يتم تحديد الأبعاد، نستخدم قيم افتراضية فقط إذا لم تكن infinity
    final hasWidth = width != null && width!.isFinite;
    final hasHeight = height != null && height!.isFinite;
    
    final effectiveWidth = hasWidth
        ? width!
        : (context.isPhone
            ? 120.0
            : context.isTablet
                ? 150.0
                : 180.0);
    final effectiveHeight = hasHeight
        ? height!
        : (hasWidth ? effectiveWidth : 120.0);
    final effectiveBorderRadius =
        borderRadius ?? BorderRadius.circular(context.responsiveRadius());

    if (raw.isEmpty) {
      return _fallback(
          cs, effectiveWidth, effectiveHeight, effectiveBorderRadius);
    }

    Widget imageWidget;

    if (_isNetwork(raw)) {
      final pixelRatio = MediaQuery.of(context).devicePixelRatio;
      // التحقق من أن القيم ليست Infinity أو NaN قبل التحويل
      final cacheWidth = (effectiveWidth.isFinite && effectiveWidth > 0)
          ? (effectiveWidth * pixelRatio).round()
          : null;
      final cacheHeight = (effectiveHeight.isFinite && effectiveHeight > 0)
          ? (effectiveHeight * pixelRatio).round()
          : null;

      imageWidget = CachedNetworkImage(
        imageUrl: raw,
        fit: fit,
        alignment: alignment,
        width: effectiveWidth.isFinite ? effectiveWidth : null,
        height: effectiveHeight.isFinite ? effectiveHeight : null,
        filterQuality: FilterQuality.low, // تحسين الأداء
        memCacheWidth: cacheWidth,
        memCacheHeight: cacheHeight,
        placeholder: (context, url) {
          final placeholderWidth = hasWidth ? effectiveWidth : 120.0;
          final placeholderHeight = hasHeight ? effectiveHeight : 120.0;
          return _buildLoadingWidget(
              context, placeholderWidth, placeholderHeight, effectiveBorderRadius);
        },
        errorWidget: (context, url, error) {
          final errorWidth = hasWidth ? effectiveWidth : 120.0;
          final errorHeight = hasHeight ? effectiveHeight : 120.0;
          return _fallback(cs, errorWidth, errorHeight, effectiveBorderRadius);
        },
      );
    } else if (raw.endsWith('.svg')) {
      imageWidget = SvgPicture.asset(
        _resolveAssetPath(raw),
        fit: fit,
        alignment: alignment,
        width: hasWidth ? effectiveWidth : null,
        height: hasHeight ? effectiveHeight : null,
        placeholderBuilder: (context) => _buildLoadingWidget(
            context, effectiveWidth, effectiveHeight, effectiveBorderRadius),
      );
    } else {
      final candidates = _assetCandidates(raw);
      imageWidget = _assetWithFallback(
          context, candidates, 0, cs, 
          hasWidth ? effectiveWidth : null, 
          hasHeight ? effectiveHeight : null);
    }

    // تطبيق BorderRadius إذا كان محدد
    // لا نحدد width/height إذا كانت infinity لتسمح للصورة بالتمدد
    final container = effectiveBorderRadius != BorderRadius.zero
        ? ClipRRect(
            borderRadius: effectiveBorderRadius,
            child: Container(
              width: hasWidth ? effectiveWidth : null,
              height: hasHeight ? effectiveHeight : null,
              color: backgroundColor ?? cs.surfaceContainerHighest,
              child: imageWidget,
            ),
          )
        : Container(
            width: hasWidth ? effectiveWidth : null,
            height: hasHeight ? effectiveHeight : null,
            color: backgroundColor ?? cs.surfaceContainerHighest,
            child: imageWidget,
          );

    return container;
  }

  Widget _assetWithFallback(BuildContext context, List<String> candidates,
      int i, ColorScheme cs, double? width, double? height) {
    if (i >= candidates.length) {
      final fallbackWidth = width ?? 120.0;
      final fallbackHeight = height ?? 120.0;
      return _fallback(cs, fallbackWidth, fallbackHeight, BorderRadius.zero);
    }
    final path = candidates[i];
    return Image.asset(
      path,
      fit: fit,
      alignment: alignment,
      width: width,
      height: height,
      filterQuality: filterQuality,
      gaplessPlayback: gaplessPlayback,
      errorBuilder: (_, __, ___) =>
          _assetWithFallback(context, candidates, i + 1, cs, width, height),
    );
  }

  Widget _buildLoadingWidget(BuildContext context, double width, double height,
      BorderRadius borderRadius) {
    return SkeletonContainer(
      width: width,
      height: height,
      borderRadius: borderRadius,
    );
  }

  Widget _fallback(
      ColorScheme cs, double width, double height, BorderRadius borderRadius) {
    return fallback ??
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: borderRadius,
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.image_not_supported_outlined,
            color: cs.onSurfaceVariant,
            size: 24.0,
          ),
        );
  }

  String _resolveAssetPath(String src) {
    // حل مسارات الأصول المختلفة
    if (src.startsWith('assets/')) return src;
    if (src.startsWith('lib/assets/')) return src.substring(4);
    return 'assets/$src';
  }
}

/// للاستخدام مع DecorationImage / CircleAvatar.backgroundImage
ImageProvider<Object>? assetOrNetworkProvider(String? src) {
  final raw = (src ?? '').trim();
  if (raw.isEmpty) return null;
  if (_isNetwork(raw)) return NetworkImage(raw);
  final candidates = _assetCandidates(raw);
  return AssetImage(candidates.first);
}
