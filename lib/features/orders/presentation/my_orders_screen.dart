// lib/features/orders/presentation/my_orders_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../services/order_service.dart';
import '../models/order_model.dart';

/// شاشة عرض طلبات العميل الحقيقية
class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  int _selectedTab = 0;
  static const _statusTabs = [
    'الكل',
    'معلقة',
    'مقبولة',
    'قيد التنفيذ',
    'مكتملة',
    'مرفوضة'
  ];

  // مساعد لصياغة التاريخ
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return 'قبل ${diff.inMinutes} دقيقة';
      }
      return 'قبل ${diff.inHours} ساعة';
    } else if (diff.inDays == 1) {
      return 'أمس';
    } else if (diff.inDays < 7) {
      return 'قبل ${diff.inDays} أيام';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  // مساعد لصياغة السعر
  String _price(double v) => '${v.toStringAsFixed(3)} ر.ع';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // التحقق من تسجيل الدخول
        if (!authProvider.isAuthenticated || authProvider.currentUser == null) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              backgroundColor: cs.surface,
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => Navigator.maybePop(context),
                ),
                title: const Text('طلباتي'),
                centerTitle: true,
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.login, size: 60, color: cs.onSurfaceVariant),
                    const SizedBox(height: 16),
                    Text('يرجى تسجيل الدخول لعرض الطلبات',
                        style: TextStyle(color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
            ),
          );
        }

        final userId = authProvider.currentUser!.uid;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: cs.surface,
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.maybePop(context),
              ),
              title: const Text('طلباتي'),
              centerTitle: true,
            ),
            body: Column(
              children: [
                // تبويبات الحالة
                SizedBox(
                  height: 52,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (_, i) {
                      final selected = i == _selectedTab;
                      return ChoiceChip(
                        label: Text(_statusTabs[i]),
                        selected: selected,
                        onSelected: (_) => setState(() => _selectedTab = i),
                        backgroundColor:
                            cs.surfaceContainerHighest.withOpacity(.7),
                        selectedColor: const Color(0xFF6D4C41),
                        labelStyle: TextStyle(
                          color: selected ? Colors.white : cs.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemCount: _statusTabs.length,
                  ),
                ),

                // قائمة الطلبات
                Expanded(
                  child: StreamBuilder<List<OrderModel>>(
                    stream: OrderService.getCustomerOrders(userId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                            child:
                                CircularProgressIndicator(color: cs.primary));
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline,
                                  size: 48, color: cs.error),
                              const SizedBox(height: 16),
                              Text('حدث خطأ: ${snapshot.error}'),
                            ],
                          ),
                        );
                      }

                      final allOrders = snapshot.data ?? [];

                      // فلترة حسب التبويب
                      final filteredOrders = _selectedTab == 0
                          ? allOrders
                          : allOrders.where((order) {
                              switch (_selectedTab) {
                                case 1: // معلقة
                                  return order.status == OrderStatus.pending;
                                case 2: // مقبولة
                                  return order.status == OrderStatus.accepted;
                                case 3: // قيد التنفيذ
                                  return order.status == OrderStatus.inProgress;
                                case 4: // مكتملة
                                  return order.status == OrderStatus.completed;
                                case 5: // مرفوضة
                                  return order.status == OrderStatus.rejected;
                                default:
                                  return true;
                              }
                            }).toList();

                      if (filteredOrders.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.shopping_bag_outlined,
                                  size: 60, color: cs.onSurfaceVariant),
                              const SizedBox(height: 16),
                              Text(
                                'لا توجد طلبات',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: cs.onSurface),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _selectedTab == 0
                                    ? 'لم تقم بإرسال أي طلبات حتى الآن'
                                    : 'لا توجد طلبات في هذه الفئة',
                                style: TextStyle(color: cs.onSurfaceVariant),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        itemBuilder: (_, i) => _OrderCard(
                          order: filteredOrders[i],
                          priceText: _price(filteredOrders[i].totalPrice),
                          dateText: _formatDate(filteredOrders[i].createdAt),
                          onTrack: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'تتبّع الطلب ${filteredOrders[i].id}')),
                            );
                          },
                          onReorder: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'إعادة طلب ${filteredOrders[i].fabricName}')),
                            );
                          },
                        ),
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemCount: filteredOrders.length,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/* ======================= بطاقة الطلب ======================= */

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final String priceText;
  final String dateText;
  final VoidCallback onTrack;
  final VoidCallback onReorder;

  const _OrderCard({
    required this.order,
    required this.priceText,
    required this.dateText,
    required this.onTrack,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Color bg;
    Color fg;
    String statusText;
    IconData statusIcon;

    switch (order.status) {
      case OrderStatus.pending:
        bg = const Color(0xFFFFF4E5);
        fg = const Color(0xFF8D6E63);
        statusText = 'معلقة';
        statusIcon = Icons.hourglass_empty_rounded;
        break;
      case OrderStatus.accepted:
        bg = const Color(0xFFE3F2FD);
        fg = const Color(0xFF0D47A1);
        statusText = 'مقبولة';
        statusIcon = Icons.check_circle_outline_rounded;
        break;
      case OrderStatus.inProgress:
        bg = const Color(0xFFF3E5F5);
        fg = const Color(0xFF4A148C);
        statusText = 'قيد التنفيذ';
        statusIcon = Icons.engineering_rounded;
        break;
      case OrderStatus.completed:
        bg = const Color(0xFFE7F6EC);
        fg = const Color(0xFF1B5E20);
        statusText = 'مكتملة';
        statusIcon = Icons.check_circle_rounded;
        break;
      case OrderStatus.rejected:
        bg = const Color(0xFFFDECEC);
        fg = const Color(0xFFB71C1C);
        statusText = 'مرفوضة';
        statusIcon = Icons.cancel_rounded;
        break;
      case OrderStatus.cancelled:
        bg = const Color(0xFFF5F5F5);
        fg = const Color(0xFF616161);
        statusText = 'ملغية';
        statusIcon = Icons.cancel_rounded;
        break;
    }

    return Ink(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // صورة القماش
          ClipRRect(
            borderRadius: const BorderRadiusDirectional.only(
              topStart: Radius.circular(16),
              bottomStart: Radius.circular(16),
            ),
            child: Container(
              width: 110,
              height: 110,
              color: cs.surfaceContainerHighest,
              child: order.fabricImageUrl.isEmpty
                  ? Center(
                      child: Icon(Icons.checkroom,
                          size: 40, color: cs.onSurfaceVariant))
                  : Image.network(
                      order.fabricImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child: Icon(Icons.broken_image,
                            size: 40, color: cs.onSurfaceVariant),
                      ),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                            child: CircularProgressIndicator(strokeWidth: 2));
                      },
                    ),
            ),
          ),

          // معلومات الطلب
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 14, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // الحالة
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          order.fabricName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: cs.onSurface,
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(statusIcon, size: 14, color: fg),
                            const SizedBox(width: 4),
                            Text(
                              statusText,
                              style: TextStyle(
                                color: fg,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order.tailorName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
                  ),
                  Text(
                    order.fabricType,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    dateText,
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11),
                  ),

                  const SizedBox(height: 8),
                  // السعر + الأزرار
                  OverflowBar(
                    alignment: MainAxisAlignment.spaceBetween,
                    overflowAlignment: OverflowBarAlignment.end,
                    spacing: 8,
                    overflowSpacing: 8,
                    children: [
                      Text(
                        priceText,
                        style: TextStyle(
                          color: cs.onSurface,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: onTrack,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8),
                              minimumSize: const Size(0, 36),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              textStyle: const TextStyle(
                                  fontWeight: FontWeight.w800, fontSize: 13),
                            ),
                            child: const Text('تتبّع'),
                          ),
                          const SizedBox(width: 6),
                          ElevatedButton(
                            onPressed: onReorder,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6D4C41),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              minimumSize: const Size(0, 36),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              textStyle: const TextStyle(
                                  fontWeight: FontWeight.w800, fontSize: 13),
                            ),
                            child: const Text('إعادة الطلب'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
