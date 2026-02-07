// lib/features/profile/presentation/screens/about_app_screen.dart
import 'package:flutter/material.dart';
import 'package:hindam/shared/widgets/profile_page_scaffold.dart';
import 'package:hindam/l10n/app_localizations.dart';

/// صفحة عن التطبيق
class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    const appVersion = '1.0.0';

    return ProfilePageScaffold(
      title: l10n.aboutApp,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        children: [
          Center(
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: cs.primaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: cs.primary.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                Icons.content_cut_rounded,
                size: 44,
                color: cs.primary,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              l10n.appName,
              style: tt.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: cs.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              l10n.appVersion(appVersion),
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.outlineVariant.withOpacity(0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.aboutAppDescription,
                  style: tt.bodyMedium?.copyWith(
                    color: cs.onSurface,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _AboutRow(
            label: l10n.appVersionLabel,
            value: appVersion,
            tt: tt,
            cs: cs,
          ),
          _AboutRow(
            label: l10n.email,
            value: 'info@hindam.app',
            tt: tt,
            cs: cs,
          ),
          _AboutRow(
            label: l10n.website,
            value: 'www.hindam.app',
            tt: tt,
            cs: cs,
          ),
        ],
      ),
    );
  }
}

class _AboutRow extends StatelessWidget {
  final String label;
  final String value;
  final TextTheme tt;
  final ColorScheme cs;

  const _AboutRow({
    required this.label,
    required this.value,
    required this.tt,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
          Text(
            value,
            style: tt.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
