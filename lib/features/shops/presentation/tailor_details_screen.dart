import 'package:flutter/material.dart';
import 'package:hindam/l10n/app_localizations.dart';

import '../../../core/state/cart_scope.dart';
import '../../../measurements/presentation/measurement_form_screen.dart';
import '../../shops/models/tailor.dart';

class TailorDetailsScreen extends StatelessWidget {
  final Tailor tailor;
  const TailorDetailsScreen({super.key, required this.tailor});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final cart = CartScope.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(tailor.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            height: 140,
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                'غطاء المتجر • ${tailor.city}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(tailor.name, style: Theme.of(context).textTheme.titleLarge),
            subtitle: Text('${tailor.city} • ★ ${tailor.rating.toStringAsFixed(1)}'),
          ),
          const SizedBox(height: 8),
          Text('${l10n.services}:', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: tailor.tags.map((e) => Chip(label: Text(e))).toList()),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () async {
              final ok = await Navigator.of(context).push<bool>(
                MaterialPageRoute(builder: (_) => const MeasurementFormScreen()),
              );
              if (ok == true) {
                cart.addService(name: 'تفصيل دشداشة - ${tailor.name}', price: 7.0);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.productAddedToCart)),
                  );
                }
              }
            },
            icon: const Icon(Icons.content_cut),
            label: Text(l10n.orderNow),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.featureComingSoon)),
              );
            },
            icon: const Icon(Icons.store_outlined),
            label: Text(l10n.fabrics),
          ),
        ],
      ),
    );
  }
}
