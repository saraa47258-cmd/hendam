// lib/features/orders/presentation/order_details_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hindam/core/state/cart_scope.dart';
import 'package:hindam/features/orders/models/order.dart';
import 'package:hindam/l10n/app_localizations.dart';

class OrderDetailsScreen extends StatelessWidget {
  final String orderId;

  const OrderDetailsScreen({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cartState = CartScope.of(context);
    final order = cartState.orders.firstWhere(
      (o) => o.id == orderId,
      orElse: () => Order(
        id: orderId,
        status: l10n.orderNotFound,
        createdAt: DateTime.now(),
        totalOmr: 0,
        items: [],
      ),
    );

    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final statusLabel = _localizeStatus(order.status, l10n);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text('${l10n.order} #${order.id}'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.orderStatus,
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          _getStatusIcon(order.status),
                          color: _getStatusColor(order.status),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          statusLabel,
                          style: tt.bodyLarge?.copyWith(
                            color: _getStatusColor(order.status),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${l10n.orderDate}: ${_formatDate(order.createdAt)}',
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.orderDetails,
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...order.items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.title,
                                style: tt.bodyMedium,
                              ),
                            ),
                            Text(
                              '${item.qty}x',
                              style: tt.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${(item.price * item.qty).toStringAsFixed(2)} ر.ع',
                              style: tt.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.totalLabel,
                          style: tt.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${order.totalOmr.toStringAsFixed(2)} Ø±.Ø¹',
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
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.featureComingSoon)),
                      );
                    },
                    child: Text(l10n.reorder),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      context.push('/app/order/${order.id}/tracking');
                    },
                    child: Text(l10n.trackOrder),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

IconData _getStatusIcon(String status) {
  switch (status) {
    case 'قيد المعالجة':
    case 'Processing':
      return Icons.hourglass_empty;
    case 'قيد الشحن':
    case 'Shipping':
      return Icons.local_shipping;
    case 'تم التسليم':
    case 'Delivered':
      return Icons.check_circle;
    case 'ملغي':
    case 'Cancelled':
      return Icons.cancel;
    default:
      return Icons.help_outline;
  }
}

Color _getStatusColor(String status) {
  switch (status) {
    case 'قيد المعالجة':
    case 'Processing':
      return Colors.orange;
    case 'قيد الشحن':
    case 'Shipping':
      return Colors.blue;
    case 'تم التسليم':
    case 'Delivered':
      return Colors.green;
    case 'ملغي':
    case 'Cancelled':
      return Colors.red;
    default:
      return Colors.grey;
  }
}

String _formatDate(DateTime date) {
  return '${date.day}/${date.month}/${date.year}';
}

String _localizeStatus(String status, AppLocalizations l10n) {
  switch (status) {
    case 'قيد المعالجة':
    case 'Processing':
      return l10n.processingStatus;
    case 'قيد الشحن':
    case 'Shipping':
      return l10n.shippingStatus;
    case 'تم التسليم':
    case 'Delivered':
      return l10n.deliveredStatus;
    case 'ملغي':
    case 'Cancelled':
      return l10n.cancelled;
    default:
      return status;
  }
}

