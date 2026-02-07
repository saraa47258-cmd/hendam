// lib/features/cart/presentation/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hindam/core/state/cart_scope.dart';
import 'package:hindam/core/error/error_handler.dart';
import 'package:hindam/core/performance/performance_utils.dart';
import 'package:hindam/core/services/firebase_service.dart';
import 'package:hindam/l10n/app_localizations.dart';
import 'package:hindam/core/providers/locale_provider.dart';
import 'package:hindam/features/orders/presentation/my_orders_screen.dart';

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
    final localeProvider = context.watch<LocaleProvider>();
    final l10n = AppLocalizations.of(context)!;
    final isRtl = localeProvider.isRtl;

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: cs.surface,
        appBar: AppBar(
          title: Text(l10n.cart),
          centerTitle: true,
          actions: [
            if (cartState.items.isNotEmpty)
              TextButton(
                onPressed: () {
                  _showClearCartDialog(context, cartState, l10n);
                },
                child: Text(l10n.clearAll),
              ),
          ],
        ),
        body: cartState.items.isEmpty
            ? _buildEmptyCart(cs, tt, l10n)
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: cartState.items.length,
                      itemBuilder: (context, index) {
                        final item = cartState.items[index];
                        return _buildCartItem(item, cartState, cs, tt, l10n);
                      },
                    ),
                  ),
                  _buildCartSummary(cartState, cs, tt, l10n),
                ],
              ),
      ),
    );
  }

  Widget _buildEmptyCart(ColorScheme cs, TextTheme tt, AppLocalizations l10n) {
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
            l10n.emptyCart,
            style: tt.headlineSmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.addProductsToStart,
            style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {
              // العودة للرئيسية
              Navigator.of(context).pop();
            },
            child: Text(l10n.browseProducts),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(dynamic item, CartState cartState, ColorScheme cs,
      TextTheme tt, AppLocalizations l10n) {
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
                        l10n.currency(item.price.toStringAsFixed(2)),
                        style: tt.bodyMedium?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      // عرض ملخص التخصيص
                      if (hasCustomization) ...[
                        const SizedBox(height: 8),
                        _buildCustomizationSummary(customization, cs, tt, l10n),
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
                  l10n.currency((item.price * item.qty).toStringAsFixed(2)),
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
  Widget _buildCustomizationSummary(dynamic customization, ColorScheme cs,
      TextTheme tt, AppLocalizations l10n) {
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
            l10n.color,
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
            l10n.notes,
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

  Widget _buildCartSummary(CartState cartState, ColorScheme cs, TextTheme tt,
      AppLocalizations l10n) {
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
                l10n.total,
                style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                l10n.currency(cartState.total.toStringAsFixed(2)),
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
                _showPlaceOrderDialog(context, cartState, l10n);
              },
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(l10n.completeOrder),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearCartDialog(
      BuildContext context, CartState cartState, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearCart),
        content: Text(l10n.clearCartConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              cartState.clear();
              Navigator.of(context).pop();
              ErrorHandler.showSuccessSnackBar(context, l10n.cartCleared);
            },
            child: Text(l10n.clear),
          ),
        ],
      ),
    );
  }

  void _showPlaceOrderDialog(
      BuildContext context, CartState cartState, AppLocalizations l10n) {
    final user = FirebaseService.currentUser;

    if (user == null) {
      ErrorHandler.showErrorSnackBar(context, l10n.pleaseSignInFirst);
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.completeOrder),
        content: Text(
            '${l10n.orderTotalAmount}: ${l10n.currency(cartState.total.toStringAsFixed(2))}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(ctx).pop();

              // عرض مؤشر التحميل
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );

              // إرسال الطلب إلى Firebase
              final orderId = await cartState.submitCartOrder(
                customerId: user.uid,
                customerName: user.displayName ?? l10n.guest,
                customerPhone: user.phoneNumber ?? '',
              );

              // إغلاق مؤشر التحميل
              if (context.mounted) {
                Navigator.of(context).pop();
              }

              if (orderId != null && context.mounted) {
                // عرض dialog النجاح
                _showOrderSuccessDialog(context, orderId, l10n);
              } else if (context.mounted) {
                ErrorHandler.showErrorSnackBar(context, l10n.failedToSendOrder);
              }
            },
            child: Text(l10n.confirmOrder),
          ),
        ],
      ),
    );
  }

  void _showOrderSuccessDialog(
      BuildContext context, String orderId, AppLocalizations l10n) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle_rounded,
                    color: Colors.green[600], size: 56),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.orderSubmittedSuccessfully,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                '${l10n.orderNumber}: #${orderId.substring(0, 8).toUpperCase()}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(l10n.continueShopping),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // استخدام navigator reference قبل إغلاق الـ dialog
                        final navigator =
                            Navigator.of(context, rootNavigator: true);
                        Navigator.pop(ctx);
                        navigator.push(
                          MaterialPageRoute(
                            builder: (_) => const MyOrdersScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(l10n.viewOrders),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
