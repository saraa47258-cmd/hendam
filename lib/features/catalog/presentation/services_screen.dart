import 'package:flutter/material.dart';
import 'package:hindam/l10n/app_localizations.dart';
import '../models/service_item.dart';
import '../widgets/service_list_card.dart';

/// شاشة عامة لعرض قائمة خدمات بأي عنوان وأي بيانات.
/// تعيد استخدام نفس ServiceListCard بدون تكرار (DRY).
class ServicesScreen extends StatelessWidget {
  final String title;
  final List<ServiceItem> items;

  const ServicesScreen({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final textDirection = Directionality.of(context);

    return Directionality(
      textDirection: textDirection,
      child: Scaffold(
        appBar: AppBar(title: Text(title)),
        backgroundColor: cs.surface,
        body: items.isEmpty
            ? Center(
          child: Text(l10n.noData, style: TextStyle(color: cs.onSurfaceVariant)),
        )
            : ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) => ServiceListCard(item: items[i]),
        ),
      ),
    );
  }
}
