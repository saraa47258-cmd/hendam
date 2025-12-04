// lib/features/orders/presentation/order_details_screen.dart
import 'package:flutter/material.dart';
import 'package:hindam/core/state/cart_scope.dart';
import 'package:hindam/features/orders/models/order.dart';

class OrderDetailsScreen extends StatelessWidget {
  final String orderId;

  const OrderDetailsScreen({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    final cartState = CartScope.of(context);
    final order = cartState.orders.firstWhere(
      (o) => o.id == orderId,
      orElse: () => Order(
        id: orderId,
        status: 'غير موجود',
        createdAt: DateTime.now(),
        totalOmr: 0,
        items: [],
      ),
    );

    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: cs.surface,
        appBar: AppBar(
          title: Text('طلب #${order.id}'),
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
                        'حالة الطلب',
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
                            order.status,
                            style: tt.bodyLarge?.copyWith(
                              color: _getStatusColor(order.status),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'تاريخ الطلب: ${_formatDate(order.createdAt)}',
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
                        'تفاصيل الطلب',
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
                            'الإجمالي',
                            style: tt.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${order.totalOmr.toStringAsFixed(2)} ر.ع',
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
                          const SnackBar(
                            content: Text('سيتم إضافة هذه الميزة قريباً'),
                          ),
                        );
                      },
                      child: const Text('إعادة الطلب'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('سيتم إضافة تتبع الطلب قريباً'),
                          ),
                        );
                      },
                      child: const Text('تتبع الطلب'),
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

IconData _getStatusIcon(String status) {
  switch (status) {
    case 'قيد المعالجة':
      return Icons.hourglass_empty;
    case 'قيد الشحن':
      return Icons.local_shipping;
    case 'تم التسليم':
      return Icons.check_circle;
    case 'ملغي':
      return Icons.cancel;
    default:
      return Icons.help_outline;
  }
}

Color _getStatusColor(String status) {
  switch (status) {
    case 'قيد المعالجة':
      return Colors.orange;
    case 'قيد الشحن':
      return Colors.blue;
    case 'تم التسليم':
      return Colors.green;
    case 'ملغي':
      return Colors.red;
    default:
      return Colors.grey;
  }
}

String _formatDate(DateTime date) {
  return '${date.day}/${date.month}/${date.year}';
}

