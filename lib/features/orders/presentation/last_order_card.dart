import 'package:flutter/material.dart';

class LastOrderCard extends StatelessWidget {
  final String orderCode;
  final String statusText;
  final VoidCallback? onTrack;

  const LastOrderCard({
    super.key,
    required this.orderCode,
    required this.statusText,
    this.onTrack,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [cs.primaryContainer, cs.tertiaryContainer],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.65),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(Icons.local_shipping_outlined, color: cs.onPrimaryContainer),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('أحدث طلب: $orderCode',
                    style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(statusText, style: tt.bodySmall?.copyWith(color: cs.onSurface)),
              ],
            ),
          ),
          FilledButton.tonal(
            onPressed: onTrack,
            child: const Text('تتبّع'),
          ),
        ],
      ),
    );
  }
}
