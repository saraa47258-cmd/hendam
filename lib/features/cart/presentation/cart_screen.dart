// lib/features/cart/presentation/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:hindam/core/state/cart_scope.dart';
import 'package:hindam/core/error/error_handler.dart';
import 'package:hindam/core/performance/performance_utils.dart';
import 'package:hindam/core/widgets/performance_layouts.dart';

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
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // صورة المنتج
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: PerformanceUtils.buildOptimizedImage(
                item.product?.image,
                width: 60,
                height: 60,
                errorWidget: Container(
                  width: 60,
                  height: 60,
                  color: cs.surfaceContainerHighest,
                  child: Icon(Icons.image, color: cs.onSurfaceVariant),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // تفاصيل المنتج
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style:
                        tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
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
                ],
              ),
            ),

            // أزرار الكمية - محسن باستخدام PerformanceRow لتجنب إعادة البناء
            PerformanceRow(
              mainAxisSize: MainAxisSize.min,
              spacing: 8.0,
              children: [
                IconButton(
                  onPressed: () => cartState.inc(item),
                  icon: const Icon(Icons.add),
                  style: IconButton.styleFrom(
                    backgroundColor: cs.primaryContainer,
                    foregroundColor: cs.onPrimaryContainer,
                  ),
                ),
                Text(
                  '${item.qty}',
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => cartState.dec(item),
                  icon: const Icon(Icons.remove),
                  style: IconButton.styleFrom(
                    backgroundColor: cs.errorContainer,
                    foregroundColor: cs.onErrorContainer,
                  ),
                ),
              ],
            ),

            // زر الحذف
            IconButton(
              onPressed: () => cartState.remove(item),
              icon: const Icon(Icons.delete_outline),
              style: IconButton.styleFrom(
                backgroundColor: cs.errorContainer,
                foregroundColor: cs.onErrorContainer,
              ),
            ),
          ],
        ),
      ),
    );
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
