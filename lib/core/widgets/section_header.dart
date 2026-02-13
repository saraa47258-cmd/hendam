import 'package:flutter/material.dart';
import 'package:hindam/l10n/app_localizations.dart';

class SectionHeader extends StatelessWidget {
  final String title; final VoidCallback? onMore;
  const SectionHeader({super.key, required this.title, this.onMore});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const Spacer(),
        if (onMore != null) TextButton(onPressed: onMore, child: Text(l10n.viewAll)),
      ],
    );
  }
}
