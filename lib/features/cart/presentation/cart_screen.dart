// lib/features/cart/presentation/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:hindam/core/state/cart_scope.dart';
import 'package:hindam/core/error/error_handler.dart';
import 'package:hindam/core/performance/performance_utils.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> with PerformanceMixin {
  @override
  Widget build(BuildContext context) {
    final cartState = CartScope.of(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: cs.surface,
        appBar: AppBar(
          title: const Text('السلة'),
          centerTitle: true,
          actions: [
            if (cartState.items.isNotEmpty)
              TextButton(
                onPressed: () {
                  _showClearCartDialog(context, cartState);
                },
                child: const Text('مسح الكل'),
              ),
          ],
        ),
        body: cartState.items.isEmpty
            ? _buildEmptyCart(cs, tt)
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: cartState.items.length,
                      itemBuilder: (context, index) {
                        final item = cartState.items[index];
                        return _buildCartItem(item, cartState, cs, tt);
                      },
                    ),
                  ),
                  _buildCartSummary(cartState, cs, tt),
                ],
              ),
      ),
    );
  }

  Widget _buildEmptyCart(ColorScheme cs, TextTheme tt) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 80,
            color: cs.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'السلة فارغة',
            style: tt.headlineSmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'أضف بعض المنتجات لتبدأ التسوق',
            style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {
              // العودة للرئيسية
              Navigator.of(context).pop();
            },
            child: const Text('تصفح المنتجات'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(
      dynamic item, CartState cartState, ColorScheme cs, TextTheme tt) {
    // الحصول على تفاصيل التخصيص
    final customization = item.customization;
    final hasCustomization = customization?.hasCustomization ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // صورة المنتج مع مؤشر اللون
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: PerformanceUtils.buildOptimizedImage(
                        item.imageUrl ?? item.product?.image,
                        width: 70,
                        height: 70,
                        errorWidget: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.image, color: cs.onSurfaceVariant),
                        ),
                      ),
                    ),
                    // مؤشر اللون المختار
                    if (customization?.selectedColor != null)
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: _parseColor(customization!.selectedColor!),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),

                // تفاصيل المنتج
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: tt.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${item.price.toStringAsFixed(2)} ر.ع',
                        style: tt.bodyMedium?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      // عرض ملخص التخصيص
                      if (hasCustomization) ...[
                        const SizedBox(height: 8),
                        _buildCustomizationSummary(customization, cs, tt),
                      ],
                    ],
                  ),
                ),

                // زر الحذف
                IconButton(
                  onPressed: () => cartState.remove(item),
                  icon: const Icon(Icons.close, size: 18),
                  style: IconButton.styleFrom(
                    backgroundColor: cs.surfaceContainerHighest,
                    foregroundColor: cs.onSurfaceVariant,
                    padding: const EdgeInsets.all(6),
                    minimumSize: const Size(28, 28),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // أزرار الكمية
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => cartState.dec(item),
                        icon: const Icon(Icons.remove, size: 18),
                        style: IconButton.styleFrom(
                          foregroundColor: cs.onSurfaceVariant,
                          padding: const EdgeInsets.all(8),
                          minimumSize: const Size(36, 36),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          '${item.qty}',
                          style: tt.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        onPressed: () => cartState.inc(item),
                        icon: const Icon(Icons.add, size: 18),
                        style: IconButton.styleFrom(
                          foregroundColor: cs.primary,
                          padding: const EdgeInsets.all(8),
                          minimumSize: const Size(36, 36),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  '${(item.price * item.qty).toStringAsFixed(2)} ر.ع',
                  style: tt.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// بناء ملخص التخصيص
  Widget _buildCustomizationSummary(
      dynamic customization, ColorScheme cs, TextTheme tt) {
    final parts = <Widget>[];

    // اللون
    if (customization.selectedColor != null) {
      parts.add(Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: _parseColor(customization.selectedColor),
              shape: BoxShape.circle,
              border: Border.all(color: cs.outline.withOpacity(0.3)),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'اللون',
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ));
    }

    // المقاسات
    if (customization.measurements != null) {
      final m = customization.measurements as Map<String, double>;
      final unit = customization.unit ?? 'in';
      final measurementParts = <String>[];
      if (m['length'] != null) measurementParts.add('${m['length']}$unit');
      if (m['sleeve'] != null) measurementParts.add('${m['sleeve']}$unit');
      if (m['width'] != null) measurementParts.add('${m['width']}$unit');

      if (measurementParts.isNotEmpty) {
        parts.add(Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.straighten, size: 12, color: cs.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(
              measurementParts.join(' × '),
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ));
      }
    }

    // الملاحظات
    if (customization.notes != null && customization.notes.isNotEmpty) {
      parts.add(Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.note, size: 12, color: cs.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            'ملاحظات',
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ));
    }

    if (parts.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: parts,
    );
  }

  /// تحويل HEX string إلى Color
  Color _parseColor(String hex) {
    try {
      final cleanHex = hex.replaceFirst('#', '');
      return Color(int.parse('FF$cleanHex', radix: 16));
    } catch (e) {
      return Colors.grey;
    }
  }

  Widget _buildCartSummary(CartState cartState, ColorScheme cs, TextTheme tt) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الإجمالي',
                style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                '${cartState.total.toStringAsFixed(2)} ر.ع',
                style: tt.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: cs.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                _showPlaceOrderDialog(context, cartState);
              },
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('إتمام الطلب'),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearCartDialog(BuildContext context, CartState cartState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('مسح السلة'),
        content: const Text('هل أنت متأكد من مسح جميع العناصر من السلة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              cartState.clear();
              Navigator.of(context).pop();
              ErrorHandler.showSuccessSnackBar(context, 'تم مسح السلة');
            },
            child: const Text('مسح'),
          ),
        ],
      ),
    );
  }

  void _showPlaceOrderDialog(BuildContext context, CartState cartState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إتمام الطلب'),
        content:
            Text('إجمالي الطلب: ${cartState.total.toStringAsFixed(2)} ر.ع'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              cartState.placeOrder();
              Navigator.of(context).pop();
              ErrorHandler.showSuccessSnackBar(context, 'تم إرسال الطلب بنجاح');
            },
            child: const Text('تأكيد الطلب'),
          ),
        ],
      ),
    );
  }
}
