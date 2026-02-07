// lib/features/orders/presentation/order_tracking_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../services/order_service.dart';
import '../models/order_model.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../l10n/app_localizations.dart';

class OrderTrackingScreen extends StatelessWidget {
  final String orderId;

  const OrderTrackingScreen({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final localeProvider = context.watch<LocaleProvider>();
    final l10n = AppLocalizations.of(context)!;
    final textDirection =
        localeProvider.isRtl ? TextDirection.rtl : TextDirection.ltr;

    return Directionality(
      textDirection: textDirection,
      child: Scaffold(
        backgroundColor: cs.surface,
        appBar: AppBar(
          title: Text('${l10n.trackOrderTitle} #$orderId'),
          centerTitle: true,
        ),
        body: StreamBuilder<OrderModel?>(
          stream: OrderService.getOrderByIdStream(orderId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: cs.primary),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: cs.error),
                    const SizedBox(height: 16),
                    Text(
                      l10n.errorLoadingOrder,
                      style: tt.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back),
                      label: Text(l10n.back),
                    ),
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
                    Icon(
                      Icons.shopping_bag_outlined,
                      size: 80,
                      color: cs.onSurfaceVariant,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.orderNotFound,
                      style: tt.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.cannotFindOrder,
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back),
                      label: Text(l10n.back),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // معلومات الطلب الأساسية
                  _OrderInfoCard(order: order, cs: cs, tt: tt, l10n: l10n),
                  const SizedBox(height: 20),

                  // خطوات التتبع
                  _TrackingSteps(order: order, cs: cs, tt: tt, l10n: l10n),
                  const SizedBox(height: 20),

                  // معلومات إضافية
                  _AdditionalInfoCard(order: order, cs: cs, tt: tt, l10n: l10n),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _OrderInfoCard extends StatelessWidget {
  final OrderModel order;
  final ColorScheme cs;
  final TextTheme tt;
  final AppLocalizations l10n;

  const _OrderInfoCard({
    required this.order,
    required this.cs,
    required this.tt,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
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
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.receipt_long,
                    color: cs.onPrimaryContainer,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${l10n.order} #${order.id}',
                        style: tt.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${l10n.orderDate}: ${_formatDate(order.createdAt)}',
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: cs.outlineVariant),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.total,
                  style: tt.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${order.totalPrice.toStringAsFixed(3)} ${l10n.omr}',
                  style: tt.titleLarge?.copyWith(
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _TrackingSteps extends StatelessWidget {
  final OrderModel order;
  final ColorScheme cs;
  final TextTheme tt;
  final AppLocalizations l10n;

  const _TrackingSteps({
    required this.order,
    required this.cs,
    required this.tt,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final steps = [
      {
        'title': l10n.waitingStatus,
        'status': OrderStatus.pending,
        'icon': Icons.access_time,
        'description': l10n.orderReceivedWaiting,
      },
      {
        'title': l10n.acceptedStatus,
        'status': OrderStatus.accepted,
        'icon': Icons.check_circle_outline,
        'description': l10n.orderAcceptedPreparing,
      },
      {
        'title': l10n.inProgressStatus,
        'status': OrderStatus.inProgress,
        'icon': Icons.build,
        'description': l10n.orderInProgressProcessing,
      },
      {
        'title': l10n.completedStatus,
        'status': OrderStatus.completed,
        'icon': Icons.done_all,
        'description': l10n.orderCompletedSuccess,
      },
    ];

    // تحديد الخطوة الحالية
    int currentStepIndex = steps.indexWhere(
      (step) => step['status'] == order.status,
    );
    if (currentStepIndex == -1) {
      if (order.status == OrderStatus.rejected) {
        currentStepIndex = 0; // إذا كان مرفوض، نعرض الخطوة الأولى فقط
      } else {
        currentStepIndex = 0;
      }
    }

    final isRejected = order.status == OrderStatus.rejected;
    final isCancelled = order.status == OrderStatus.cancelled;

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
                Icon(Icons.local_shipping, color: cs.primary, size: 24),
                const SizedBox(width: 12),
                Text(
                  l10n.trackOrderTitle,
                  style: tt.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (isRejected || isCancelled) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      isRejected ? Icons.cancel : Icons.block,
                      color: cs.onErrorContainer,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isRejected
                                ? l10n.orderRejected
                                : l10n.orderCancelled,
                            style: tt.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: cs.onErrorContainer,
                            ),
                          ),
                          if (order.rejectionReason != null &&
                              order.rejectionReason!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              order.rejectionReason!,
                              style: tt.bodySmall?.copyWith(
                                color: cs.onErrorContainer,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
            ...List.generate(steps.length, (index) {
              final step = steps[index];
              final isCompleted = index < currentStepIndex;
              final isCurrent =
                  index == currentStepIndex && !isRejected && !isCancelled;
              final isPending = index > currentStepIndex;

              return _TrackingStepItem(
                title: step['title'] as String,
                description: step['description'] as String,
                icon: step['icon'] as IconData,
                isCompleted: isCompleted,
                isCurrent: isCurrent,
                isPending: isPending,
                cs: cs,
                tt: tt,
                isLast: index == steps.length - 1,
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _TrackingStepItem extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isCompleted;
  final bool isCurrent;
  final bool isPending;
  final bool isLast;
  final ColorScheme cs;
  final TextTheme tt;

  const _TrackingStepItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.isCompleted,
    required this.isCurrent,
    required this.isPending,
    required this.isLast,
    required this.cs,
    required this.tt,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = cs.primary;
    final inactiveColor = cs.onSurfaceVariant;
    final currentColor = cs.primaryContainer;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // الخط العمودي
        Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCurrent
                    ? currentColor
                    : isCompleted
                        ? activeColor
                        : cs.surfaceContainerHighest,
                border: Border.all(
                  color: isCompleted || isCurrent ? activeColor : inactiveColor,
                  width: 2,
                ),
              ),
              child: Icon(
                isCompleted
                    ? Icons.check
                    : isCurrent
                        ? icon
                        : icon,
                color: isCompleted || isCurrent ? activeColor : inactiveColor,
                size: 20,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 60,
                color: isCompleted ? activeColor : cs.outlineVariant,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: isCurrent ? 0 : 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: tt.titleMedium?.copyWith(
                    fontWeight: isCurrent || isCompleted
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color:
                        isCurrent || isCompleted ? activeColor : inactiveColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: tt.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AdditionalInfoCard extends StatelessWidget {
  final OrderModel order;
  final ColorScheme cs;
  final TextTheme tt;
  final AppLocalizations l10n;

  const _AdditionalInfoCard({
    required this.order,
    required this.cs,
    required this.tt,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
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
              l10n.additionalInfo,
              style: tt.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _InfoRow(
              icon: Icons.person,
              label: l10n.tailor,
              value: order.tailorName,
              cs: cs,
              tt: tt,
            ),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.inventory_2,
              label: l10n.fabric,
              value: order.fabricName,
              cs: cs,
              tt: tt,
            ),
            if (order.notes.isNotEmpty) ...[
              const SizedBox(height: 12),
              _InfoRow(
                icon: Icons.note,
                label: l10n.notes,
                value: order.notes,
                cs: cs,
                tt: tt,
              ),
            ],
            if (order.completedAt != null) ...[
              const SizedBox(height: 12),
              _InfoRow(
                icon: Icons.event_available,
                label: l10n.completionDate,
                value: _formatDate(order.completedAt!),
                cs: cs,
                tt: tt,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ColorScheme cs;
  final TextTheme tt;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.cs,
    required this.tt,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: cs.primary),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: tt.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: tt.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
