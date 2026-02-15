// lib/features/orders/presentation/tailor_orders_screen.dart
import 'package:flutter/material.dart';
import '../services/order_service.dart';
import '../models/order_model.dart';

/// شاشة عرض طلبات الخياط
class TailorOrdersScreen extends StatefulWidget {
  final String tailorId;
  final String tailorName;

  const TailorOrdersScreen({
    super.key,
    required this.tailorId,
    required this.tailorName,
  });

  @override
  State<TailorOrdersScreen> createState() => _TailorOrdersScreenState();
}

class _TailorOrdersScreenState extends State<TailorOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  Map<String, dynamic>? _statistics;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadStatistics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStatistics() async {
    final stats = await OrderService.getTailorOrderStatistics(widget.tailorId);
    if (mounted) {
      setState(() {
        _statistics = stats;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: cs.surface,
        appBar: AppBar(
          title: Text('طلبات ${widget.tailorName}'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _loadStatistics,
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'جديدة', icon: Icon(Icons.new_releases_rounded)),
              Tab(text: 'مقبولة', icon: Icon(Icons.check_circle_rounded)),
              Tab(text: 'قيد التنفيذ', icon: Icon(Icons.work_rounded)),
              Tab(text: 'مكتملة', icon: Icon(Icons.done_all_rounded)),
            ],
          ),
        ),
        body: Column(
          children: [
            // إحصائيات سريعة
            if (_statistics != null) _buildStatisticsCard(),

            // شريط البحث
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'البحث في الطلبات...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),

            // قائمة الطلبات
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOrdersList(OrderStatus.pending),
                  _buildOrdersList(OrderStatus.accepted),
                  _buildOrdersList(OrderStatus.inProgress),
                  _buildOrdersList(OrderStatus.completed),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCard() {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'إحصائيات الطلبات',
            style: tt.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: cs.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'إجمالي الطلبات',
                  '${_statistics!['totalOrders']}',
                  Icons.inventory_rounded,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'في الانتظار',
                  '${_statistics!['pendingOrders']}',
                  Icons.new_releases_rounded,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'مكتملة',
                  '${_statistics!['completedOrders']}',
                  Icons.done_all_rounded,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'الإيرادات',
                  'ر.ع ${(_statistics!['totalRevenue'] as num).toStringAsFixed(3)}',
                  Icons.attach_money_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      children: [
        Icon(icon, size: 20, color: cs.onPrimaryContainer),
        const SizedBox(height: 4),
        Text(
          value,
          style: tt.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: cs.onPrimaryContainer,
          ),
        ),
        Text(
          label,
          style: tt.bodySmall?.copyWith(
            color: cs.onPrimaryContainer,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildOrdersList(OrderStatus status) {
    return StreamBuilder<List<OrderModel>>(
      stream: _searchQuery.isEmpty
          ? OrderService.getTailorOrdersByStatus(widget.tailorId, status)
          : OrderService.searchOrders(_searchQuery).map((orders) => orders
              .where((order) =>
                  order.tailorId == widget.tailorId && order.status == status)
              .toList()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, size: 64),
                const SizedBox(height: 16),
                const Text('حدث خطأ في تحميل الطلبات'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }

        final orders = snapshot.data ?? [];
        if (orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getEmptyStateIcon(status),
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  _getEmptyStateMessage(status),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getEmptyStateDescription(status),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return _buildOrderCard(order);
          },
        );
      },
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // هيدر الطلب
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'طلب #${order.id.length >= 8 ? order.id.substring(0, 8) : order.id}',
                        style: tt.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        order.customerName,
                        style: tt.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    order.status.labelAr,
                    style: tt.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // تفاصيل القماش
            Row(
              children: [
                // صورة القماش
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    order.fabricImageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 60,
                        height: 60,
                        color: cs.surfaceContainerHighest,
                        child: const Icon(Icons.image_not_supported_rounded),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),

                // تفاصيل القماش
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.fabricName,
                        style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        order.fabricType,
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        'ر.ع ${order.totalPrice.toStringAsFixed(3)}',
                        style: tt.bodySmall?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // تاريخ الطلب
            Text(
              'تاريخ الطلب: ${_formatDate(order.createdAt)}',
              style: tt.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),

            // أزرار الإجراءات
            if (order.status == OrderStatus.pending) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _rejectOrder(order),
                      icon: const Icon(Icons.close_rounded),
                      label: const Text('رفض'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: cs.error,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _acceptOrder(order),
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('قبول'),
                    ),
                  ),
                ],
              ),
            ] else if (order.status == OrderStatus.accepted) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _startOrder(order),
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('بدء التنفيذ'),
                    ),
                  ),
                ],
              ),
            ] else if (order.status == OrderStatus.inProgress) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _completeOrder(order),
                      icon: const Icon(Icons.done_all_rounded),
                      label: const Text('إكمال'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getEmptyStateIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.new_releases_rounded;
      case OrderStatus.accepted:
        return Icons.check_circle_outline_rounded;
      case OrderStatus.inProgress:
        return Icons.work_outline_rounded;
      case OrderStatus.completed:
        return Icons.done_all_rounded;
      default:
        return Icons.inbox_rounded;
    }
  }

  String _getEmptyStateMessage(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'لا توجد طلبات جديدة';
      case OrderStatus.accepted:
        return 'لا توجد طلبات مقبولة';
      case OrderStatus.inProgress:
        return 'لا توجد طلبات قيد التنفيذ';
      case OrderStatus.completed:
        return 'لا توجد طلبات مكتملة';
      default:
        return 'لا توجد طلبات';
    }
  }

  String _getEmptyStateDescription(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'الطلبات الجديدة ستظهر هنا';
      case OrderStatus.accepted:
        return 'الطلبات المقبولة ستظهر هنا';
      case OrderStatus.inProgress:
        return 'الطلبات قيد التنفيذ ستظهر هنا';
      case OrderStatus.completed:
        return 'الطلبات المكتملة ستظهر هنا';
      default:
        return '';
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.accepted:
        return Colors.blue;
      case OrderStatus.inProgress:
        return Colors.purple;
      case OrderStatus.completed:
        return Colors.green;
      case OrderStatus.rejected:
        return Colors.red;
      case OrderStatus.cancelled:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _acceptOrder(OrderModel order) async {
    final success =
        await OrderService.updateOrderStatus(order.id, OrderStatus.accepted);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم قبول الطلب')),
      );
      _loadStatistics();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل في قبول الطلب')),
      );
    }
  }

  Future<void> _rejectOrder(OrderModel order) async {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('رفض الطلب'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('يرجى إدخال سبب الرفض:'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'سبب الرفض',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await OrderService.updateOrderStatus(
                order.id,
                OrderStatus.rejected,
                rejectionReason: reasonController.text,
              );
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم رفض الطلب')),
                );
                _loadStatistics();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('فشل في رفض الطلب')),
                );
              }
            },
            child: const Text('رفض'),
          ),
        ],
      ),
    );
  }

  Future<void> _startOrder(OrderModel order) async {
    final success =
        await OrderService.updateOrderStatus(order.id, OrderStatus.inProgress);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم بدء تنفيذ الطلب')),
      );
      _loadStatistics();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل في بدء تنفيذ الطلب')),
      );
    }
  }

  Future<void> _completeOrder(OrderModel order) async {
    final success =
        await OrderService.updateOrderStatus(order.id, OrderStatus.completed);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إكمال الطلب')),
      );
      _loadStatistics();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل في إكمال الطلب')),
      );
    }
  }
}
