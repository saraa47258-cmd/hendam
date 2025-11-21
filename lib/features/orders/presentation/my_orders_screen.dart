// lib/features/orders/presentation/my_orders_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../auth/providers/auth_provider.dart';
import '../services/order_service.dart';
import '../models/order_model.dart';
import '../../../shared/widgets/skeletons.dart';

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

        // Debug: طباعة معلومات المستخدم
        print('📱 MyOrdersScreen: User ID = $userId');
        print(
            '📱 MyOrdersScreen: User Name = ${authProvider.currentUser!.name}');

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: cs.surface,
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () async {
                  final localNavigator = Navigator.of(context);
                  if (await localNavigator.maybePop()) {
                    return;
                  }

                  final rootNavigator =
                      Navigator.of(context, rootNavigator: true);
                  if (rootNavigator != localNavigator &&
                      await rootNavigator.maybePop()) {
                    return;
                  }

                  if (!mounted) return;
                  context.go('/app');
                },
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
                            cs.surfaceContainerHighest.withValues(alpha: 0.7),
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
                      // Debug logging
                      print(
                          '📦 StreamBuilder State: ${snapshot.connectionState}');
                      print('📦 Has Error: ${snapshot.hasError}');
                      print('📦 Has Data: ${snapshot.hasData}');
                      if (snapshot.hasData) {
                        print('📦 Orders Count: ${snapshot.data?.length ?? 0}');
                      }
                      if (snapshot.hasError) {
                        print('❌ Error: ${snapshot.error}');
                        print('❌ StackTrace: ${snapshot.stackTrace}');
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const OrderSkeletonList(count: 4);
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline,
                                  size: 48, color: cs.error),
                              const SizedBox(height: 16),
                              const Text(
                                'حدث خطأ في تحميل الطلبات',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 32),
                                child: Text(
                                  '${snapshot.error}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: cs.onSurfaceVariant,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () {
                                  // إعادة بناء الواجهة لإعادة المحاولة
                                  setState(() {});
                                },
                                icon: const Icon(Icons.refresh),
                                label: const Text('إعادة المحاولة'),
                              ),
                            ],
                          ),
                        );
                      }

                      final allOrders = snapshot.data ?? [];
                      print('✅ Successfully loaded ${allOrders.length} orders');

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
                        print(
                            'ℹ️ No orders to display (Tab: $_selectedTab, Total: ${allOrders.length})');
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.shopping_bag_outlined,
                                  size: 80, color: cs.onSurfaceVariant),
                              const SizedBox(height: 24),
                              Text(
                                'لا توجد طلبات',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: cs.onSurface),
                              ),
                              const SizedBox(height: 12),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 40),
                                child: Text(
                                  _selectedTab == 0
                                      ? 'لم تقم بإرسال أي طلبات حتى الآن.\nابدأ بتصفح الخياطين واطلب قطعتك المفصلة!'
                                      : 'لا توجد طلبات في هذه الفئة حالياً',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: cs.onSurfaceVariant,
                                    fontSize: 14,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                              if (_selectedTab == 0) ...[
                                const SizedBox(height: 24),
                                FilledButton.icon(
                                  onPressed: () {
                                    // العودة للصفحة الرئيسية
                                    Navigator.of(context)
                                        .popUntil((route) => route.isFirst);
                                  },
                                  icon: const Icon(Icons.home),
                                  label: const Text('تصفح الخياطين'),
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ],
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
                          onTap: () {
                            // الانتقال لصفحة تفاصيل الطلب
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => _OrderDetailsScreen(
                                  orderId: filteredOrders[i].id,
                                ),
                              ),
                            );
                          },
                          onCancel: filteredOrders[i].status ==
                                      OrderStatus.pending ||
                                  filteredOrders[i].status ==
                                      OrderStatus.accepted
                              ? () async {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => Directionality(
                                      textDirection: TextDirection.rtl,
                                      child: AlertDialog(
                                        title: const Text('إلغاء الطلب'),
                                        content: const Text(
                                            'هل أنت متأكد من إلغاء هذا الطلب؟'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text('لا'),
                                          ),
                                          FilledButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: const Text('نعم، إلغاء'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );

                                  if (confirmed == true) {
                                    final success =
                                        await OrderService.cancelOrder(
                                            filteredOrders[i].id,
                                            'إلغاء من العميل');
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(success
                                              ? '✅ تم إلغاء الطلب بنجاح'
                                              : '❌ فشل إلغاء الطلب'),
                                          backgroundColor: success
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                }
                              : null,
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
  final VoidCallback onTap;
  final VoidCallback? onCancel;

  const _OrderCard({
    required this.order,
    required this.priceText,
    required this.dateText,
    required this.onTap,
    this.onCancel,
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

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                // صورة القماش
                ClipRRect(
                  borderRadius: const BorderRadiusDirectional.only(
                    topStart: Radius.circular(16),
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
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2));
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
                        Row(
                          children: [
                            Icon(Icons.store,
                                size: 12, color: cs.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                order.tailorName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: cs.onSurfaceVariant, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.texture,
                                size: 12, color: cs.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                order.fabricType,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: cs.onSurfaceVariant, fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.access_time,
                                    size: 11, color: cs.onSurfaceVariant),
                                const SizedBox(width: 4),
                                Text(
                                  dateText,
                                  style: TextStyle(
                                      color: cs.onSurfaceVariant, fontSize: 11),
                                ),
                              ],
                            ),
                            Text(
                              priceText,
                              style: TextStyle(
                                color: cs.primary,
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // سبب الرفض إذا كان الطلب مرفوضاً
            if (order.status == OrderStatus.rejected &&
                order.rejectionReason != null &&
                order.rejectionReason!.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFFFDECEC),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.red[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'سبب الرفض: ${order.rejectionReason}',
                        style: TextStyle(
                          color: Colors.red[700],
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // الأزرار
            if (onCancel != null ||
                order.status == OrderStatus.completed ||
                order.updatedAt != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // آخر تحديث
                    if (order.updatedAt != null)
                      Expanded(
                        child: Row(
                          children: [
                            Icon(Icons.update,
                                size: 12, color: cs.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                'آخر تحديث: ${_formatUpdateTime(order.updatedAt!)}',
                                style: TextStyle(
                                  color: cs.onSurfaceVariant,
                                  fontSize: 11,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (order.updatedAt != null && onCancel != null)
                      const SizedBox(width: 8),

                    // زر الإلغاء
                    if (onCancel != null)
                      TextButton.icon(
                        onPressed: onCancel,
                        icon: const Icon(Icons.cancel_outlined, size: 16),
                        label: const Text('إلغاء الطلب'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatUpdateTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 60) {
      return 'قبل ${diff.inMinutes} دقيقة';
    } else if (diff.inHours < 24) {
      return 'قبل ${diff.inHours} ساعة';
    } else if (diff.inDays < 7) {
      return 'قبل ${diff.inDays} يوم';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }
}

/* ======================= صفحة تفاصيل الطلب ======================= */

class _OrderDetailsScreen extends StatelessWidget {
  final String orderId;

  const _OrderDetailsScreen({required this.orderId});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: cs.surface,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('تفاصيل الطلب'),
          centerTitle: true,
        ),
        body: StreamBuilder<OrderModel?>(
          stream: OrderService.getOrderByIdStream(orderId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child: CircularProgressIndicator(color: cs.primary));
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: cs.error),
                    const SizedBox(height: 16),
                    Text('حدث خطأ: ${snapshot.error}'),
                  ],
                ),
              );
            }

            final order = snapshot.data;
            if (order == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_bag_outlined,
                        size: 60, color: cs.onSurfaceVariant),
                    const SizedBox(height: 16),
                    Text('الطلب غير موجود',
                        style: TextStyle(color: cs.onSurfaceVariant)),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // بطاقة الحالة
                  _buildStatusCard(context, order, cs, tt),
                  const SizedBox(height: 16),

                  // تتبع مراحل الطلب
                  _buildOrderTracking(context, order, cs, tt),
                  const SizedBox(height: 16),

                  // تفاصيل القماش
                  _buildFabricDetails(context, order, cs, tt),
                  const SizedBox(height: 16),

                  // تفاصيل المقاسات
                  _buildMeasurementsCard(context, order, cs, tt),
                  const SizedBox(height: 16),

                  // تفاصيل الخياط
                  _buildTailorDetails(context, order, cs, tt),
                  const SizedBox(height: 16),

                  // الملاحظات
                  if (order.notes.isNotEmpty)
                    _buildNotesCard(context, order, cs, tt),

                  // سبب الرفض
                  if (order.status == OrderStatus.rejected &&
                      order.rejectionReason != null &&
                      order.rejectionReason!.isNotEmpty)
                    _buildRejectionCard(context, order, cs, tt),

                  const SizedBox(height: 24),

                  // أزرار العمليات
                  _buildActionButtons(context, order, cs),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatusCard(
      BuildContext context, OrderModel order, ColorScheme cs, TextTheme tt) {
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

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: bg,
                shape: BoxShape.circle,
              ),
              child: Icon(statusIcon, size: 40, color: fg),
            ),
            const SizedBox(height: 16),
            Text(
              'حالة الطلب: $statusText',
              style: tt.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: fg,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'رقم الطلب: #${order.id.substring(0, 8)}',
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 4),
            Text(
              'تاريخ الطلب: ${_formatFullDate(order.createdAt)}',
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
            if (order.updatedAt != null) ...[
              const SizedBox(height: 4),
              Text(
                'آخر تحديث: ${_formatFullDate(order.updatedAt!)}',
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOrderTracking(
      BuildContext context, OrderModel order, ColorScheme cs, TextTheme tt) {
    final steps = [
      {'title': 'معلقة', 'status': OrderStatus.pending},
      {'title': 'مقبولة', 'status': OrderStatus.accepted},
      {'title': 'قيد التنفيذ', 'status': OrderStatus.inProgress},
      {'title': 'مكتملة', 'status': OrderStatus.completed},
    ];

    int currentStep =
        steps.indexWhere((step) => step['status'] == order.status);
    if (currentStep == -1) currentStep = 0;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تتبع الطلب',
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ...List.generate(steps.length, (index) {
              final step = steps[index];
              final isActive = index <= currentStep &&
                  order.status != OrderStatus.rejected &&
                  order.status != OrderStatus.cancelled;
              final isCurrent = index == currentStep;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isActive
                              ? cs.primary
                              : cs.surfaceContainerHighest,
                          border: Border.all(
                            color: isActive ? cs.primary : cs.outlineVariant,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: isActive
                              ? Icon(
                                  isCurrent
                                      ? Icons.radio_button_checked
                                      : Icons.check,
                                  size: 16,
                                  color: Colors.white,
                                )
                              : Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: cs.onSurfaceVariant,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                        ),
                      ),
                      if (index < steps.length - 1)
                        Container(
                          width: 2,
                          height: 40,
                          color: isActive && index < currentStep
                              ? cs.primary
                              : cs.outlineVariant,
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        step['title'] as String,
                        style: tt.bodyLarge?.copyWith(
                          fontWeight:
                              isCurrent ? FontWeight.bold : FontWeight.normal,
                          color: isActive ? cs.onSurface : cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildFabricDetails(
      BuildContext context, OrderModel order, ColorScheme cs, TextTheme tt) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تفاصيل القماش',
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (order.fabricImageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  order.fabricImageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            _buildDetailRow(Icons.label, 'اسم القماش', order.fabricName, cs),
            _buildDetailRow(Icons.category, 'النوع', order.fabricType, cs),
            _buildDetailRow(Icons.palette, 'اللون', order.fabricColor, cs),
            _buildDetailRow(
              Icons.money,
              'السعر الإجمالي',
              '${order.totalPrice.toStringAsFixed(3)} ر.ع',
              cs,
              isPrice: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementsCard(
      BuildContext context, OrderModel order, ColorScheme cs, TextTheme tt) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'المقاسات',
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...order.measurements.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _getMeasurementLabel(entry.key),
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '${entry.value.toStringAsFixed(1)} سم',
                      style: tt.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTailorDetails(
      BuildContext context, OrderModel order, ColorScheme cs, TextTheme tt) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'معلومات الخياط',
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(Icons.store, 'اسم المحل', order.tailorName, cs),
            _buildDetailRow(Icons.person, 'اسم العميل', order.customerName, cs),
            _buildDetailRow(Icons.phone, 'رقم الهاتف', order.customerPhone, cs),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard(
      BuildContext context, OrderModel order, ColorScheme cs, TextTheme tt) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.note_outlined, size: 20, color: cs.primary),
                const SizedBox(width: 8),
                Text(
                  'ملاحظات إضافية',
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              order.notes,
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRejectionCard(
      BuildContext context, OrderModel order, ColorScheme cs, TextTheme tt) {
    return Card(
      elevation: 0,
      color: const Color(0xFFFDECEC),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.red.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.error_outline, size: 20, color: Colors.red[700]),
                const SizedBox(width: 8),
                Text(
                  'سبب الرفض',
                  style: tt.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              order.rejectionReason!,
              style: tt.bodyMedium?.copyWith(color: Colors.red[900]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(
      BuildContext context, OrderModel order, ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // زر إلغاء الطلب (فقط إذا كان معلقاً أو مقبولاً)
        if (order.status == OrderStatus.pending ||
            order.status == OrderStatus.accepted)
          OutlinedButton.icon(
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => Directionality(
                  textDirection: TextDirection.rtl,
                  child: AlertDialog(
                    title: const Text('إلغاء الطلب'),
                    content: const Text('هل أنت متأكد من إلغاء هذا الطلب؟'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('لا'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('نعم، إلغاء'),
                      ),
                    ],
                  ),
                ),
              );

              if (confirmed == true && context.mounted) {
                final success =
                    await OrderService.cancelOrder(order.id, 'إلغاء من العميل');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success
                          ? '✅ تم إلغاء الطلب بنجاح'
                          : '❌ فشل إلغاء الطلب'),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                  if (success) {
                    Navigator.pop(context);
                  }
                }
              }
            },
            icon: const Icon(Icons.cancel_outlined),
            label: const Text('إلغاء الطلب'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: BorderSide(color: Colors.red.shade300),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
      ],
    );
  }

  Widget _buildDetailRow(
      IconData icon, String label, String value, ColorScheme cs,
      {bool isPrice = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: cs.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isPrice ? cs.primary : cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  String _formatFullDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _getMeasurementLabel(String key) {
    const labels = {
      'shoulder': 'عرض الكتف',
      'chest': 'محيط الصدر',
      'waist': 'محيط الخصر',
      'hip': 'محيط الورك',
      'length': 'الطول',
      'sleeve': 'طول الكم',
      'neck': 'محيط الرقبة',
      'arm': 'طول الذراع',
    };
    return labels[key] ?? key;
  }
}
