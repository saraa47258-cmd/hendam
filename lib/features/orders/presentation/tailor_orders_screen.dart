// lib/features/orders/presentation/tailor_orders_screen.dart
import 'package:flutter/material.dart';
import 'package:hindam/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: cs.surface,
        appBar: AppBar(
          title: Text(l10n.customerOrdersTitle(widget.tailorName)),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _loadStatistics,
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: l10n.pendingOrders, icon: const Icon(Icons.new_releases_rounded)),
              Tab(text: l10n.acceptedOrders, icon: const Icon(Icons.check_circle_rounded)),
              Tab(text: l10n.inProgressOrders, icon: const Icon(Icons.work_rounded)),
              Tab(text: l10n.completedOrdersTab, icon: const Icon(Icons.done_all_rounded)),
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
                  hintText: l10n.searchOrdersHint,
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
    final l10n = AppLocalizations.of(context)!;

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
          Text(l10n.orderStatistics,
            style: tt.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: cs.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(l10n.totalOrders,
                  '${_statistics!['totalOrders']}',
                  Icons.inventory_rounded,
                ),
              ),
              Expanded(
                child: _buildStatItem(l10n.pendingOrders,
                  '${_statistics!['pendingOrders']}',
                  Icons.new_releases_rounded,
                ),
              ),
              Expanded(
                child: _buildStatItem(l10n.completedOrdersTab,
                  '${_statistics!['completedOrders']}',
                  Icons.done_all_rounded,
                ),
              ),
              Expanded(
                child: _buildStatItem(l10n.revenue,
                  l10n.currency((_statistics!['totalRevenue'] as num).toStringAsFixed(3)),
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
    final l10n = AppLocalizations.of(context)!;
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
                Text(l10n.errorLoadingOrders),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          );
        }

        final orders = snapshot.data ?? [];
        if (orders.isEmpty) {
          final statusLabel = _statusLabel(status, l10n);
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
                  l10n.noOrdersForStatus(statusLabel),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.ordersForStatusAppearHere(statusLabel),
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
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final statusLabel = isArabic ? order.status.labelAr : order.status.labelEn;

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
                      Text('${l10n.order} #${order.id.length >= 8 ? order.id.substring(0, 8) : order.id}',
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
                    statusLabel,
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
                      Text(l10n.currency(order.totalPrice.toStringAsFixed(3)),
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
            Text('${l10n.orderDate}: ${_formatDate(order.createdAt)}',
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
                      label: Text(l10n.reject),
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
                      label: Text(l10n.accept),
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
                      label: Text(l10n.startProcessing),
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
                      label: Text(l10n.complete),
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

  String _statusLabel(OrderStatus status, AppLocalizations l10n) {
    switch (status) {
      case OrderStatus.pending:
        return l10n.pendingOrders;
      case OrderStatus.accepted:
        return l10n.acceptedOrders;
      case OrderStatus.inProgress:
        return l10n.inProgressOrders;
      case OrderStatus.completed:
        return l10n.completedOrdersTab;
      case OrderStatus.rejected:
        return l10n.rejectedOrders;
      case OrderStatus.cancelled:
        return l10n.cancelled;
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
    final l10n = AppLocalizations.of(context)!;
    final success =
        await OrderService.updateOrderStatus(order.id, OrderStatus.accepted);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.orderAcceptedSuccess)),
      );
      _loadStatistics();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.orderAcceptedFailed)),
      );
    }
  }

  Future<void> _rejectOrder(OrderModel order) async {
    final l10n = AppLocalizations.of(context)!;
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.rejectOrderTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.rejectOrderPrompt),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: l10n.orderRejectionReason,
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
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
                  SnackBar(content: Text(l10n.orderRejectedSuccess)),
                );
                _loadStatistics();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.orderRejectedFailed)),
                );
              }
            },
            child: Text(l10n.reject),
          ),
        ],
      ),
    );
  }

  Future<void> _startOrder(OrderModel order) async {
    final l10n = AppLocalizations.of(context)!;
    final success =
        await OrderService.updateOrderStatus(order.id, OrderStatus.inProgress);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.orderStartedSuccess)),
      );
      _loadStatistics();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.orderStartedFailed)),
      );
    }
  }

  Future<void> _completeOrder(OrderModel order) async {
    final l10n = AppLocalizations.of(context)!;
    final success =
        await OrderService.updateOrderStatus(order.id, OrderStatus.completed);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.orderCompletedSuccess)),
      );
      _loadStatistics();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.orderCompletedFailed)),
      );
    }
  }
}
