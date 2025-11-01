// lib/core/performance/performance_utils.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PerformanceUtils {
  // تحسين الصور مع التخزين المؤقت
  static Widget buildOptimizedImage(
    String? imageUrl, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return _buildPlaceholder(width, height, errorWidget);
    }

    if (imageUrl.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => placeholder ?? _buildPlaceholder(width, height),
        errorWidget: (context, url, error) => errorWidget ?? _buildPlaceholder(width, height),
        memCacheWidth: width?.toInt(),
        memCacheHeight: height?.toInt(),
        maxWidthDiskCache: 1000,
        maxHeightDiskCache: 1000,
      );
    } else {
      return Image.asset(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => 
            errorWidget ?? _buildPlaceholder(width, height),
      );
    }
  }

  static Widget _buildPlaceholder(double? width, double? height, [Widget? errorWidget]) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: errorWidget ?? const Icon(Icons.image_not_supported, color: Colors.grey),
    );
  }

  // تحسين القوائم مع lazy loading
  static Widget buildOptimizedListView({
    required List<Widget> children,
    ScrollController? controller,
    EdgeInsetsGeometry? padding,
  }) {
    return ListView.builder(
      controller: controller,
      padding: padding,
      itemCount: children.length,
      itemBuilder: (context, index) {
        return children[index];
      },
    );
  }

  // تحسين الشبكة مع lazy loading
  static Widget buildOptimizedGridView({
    required List<Widget> children,
    required int crossAxisCount,
    double childAspectRatio = 1.0,
    ScrollController? controller,
    EdgeInsetsGeometry? padding,
  }) {
    return GridView.builder(
      controller: controller,
      padding: padding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) {
        return children[index];
      },
    );
  }

  // تحسين الذاكرة مع dispose
  static void disposeControllers(List<TextEditingController> controllers) {
    for (var controller in controllers) {
      controller.dispose();
    }
  }

  static void disposeScrollControllers(List<ScrollController> controllers) {
    for (var controller in controllers) {
      controller.dispose();
    }
  }

  // تحسين الأداء مع const constructors
  static const EdgeInsets defaultPadding = EdgeInsets.all(16);
  static const EdgeInsets defaultMargin = EdgeInsets.all(8);
  static const BorderRadius defaultBorderRadius = BorderRadius.all(Radius.circular(12));
  
  // تحسين الألوان مع const
  static const Color primaryColor = Color(0xFF0A5B8A);
  static const Color secondaryColor = Color(0xFFE57373);
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
}

// Mixin لتحسين الأداء
mixin PerformanceMixin<T extends StatefulWidget> on State<T> {
  final List<TextEditingController> _textControllers = [];
  final List<ScrollController> _scrollControllers = [];

  void addTextController(TextEditingController controller) {
    _textControllers.add(controller);
  }

  void addScrollController(ScrollController controller) {
    _scrollControllers.add(controller);
  }

  @override
  void dispose() {
    PerformanceUtils.disposeControllers(_textControllers);
    PerformanceUtils.disposeScrollControllers(_scrollControllers);
    super.dispose();
  }
}
