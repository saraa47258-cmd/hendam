// lib/features/profile/presentation/screens/payment_methods_screen.dart
import 'package:flutter/material.dart';
import 'package:hindam/shared/widgets/profile_page_scaffold.dart';

/// صفحة طرق الدفع
class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ProfilePageScaffold(
      title: 'طرق الدفع',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          Text(
            'إدارة البطاقات وطرق الدفع المحفوظة',
            style: tt.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.outlineVariant.withOpacity(0.4)),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.credit_card_off_rounded,
                  size: 48,
                  color: cs.onSurfaceVariant.withOpacity(0.6),
                ),
                const SizedBox(height: 16),
                Text(
                  'لا توجد طرق دفع محفوظة',
                  style: tt.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'أضف بطاقة أو طريقة دفع عند إتمام طلبك في المرة القادمة',
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add_rounded, size: 20),
                  label: const Text('إضافة طريقة دفع'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
