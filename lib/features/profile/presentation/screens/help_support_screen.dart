// lib/features/profile/presentation/screens/help_support_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hindam/shared/widgets/profile_page_scaffold.dart';
import 'package:hindam/l10n/app_localizations.dart';

/// صفحة المساعدة والدعم
class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return ProfilePageScaffold(
      title: l10n.helpAndSupport,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          _HelpCard(
            icon: Icons.help_outline_rounded,
            title: l10n.faqTitle,
            subtitle: l10n.faqSubtitle,
            onTap: () => _showSnack(context, l10n.faqTitle),
          ),
          const SizedBox(height: 12),
          _HelpCard(
            icon: Icons.chat_bubble_outline_rounded,
            title: l10n.contactUs,
            subtitle: l10n.supportAndInquiries,
            onTap: () => _showSnack(context, l10n.contactUs),
          ),
          const SizedBox(height: 12),
          _HelpCard(
            icon: Icons.mail_outline_rounded,
            title: l10n.email,
            subtitle: 'support@hindam.app',
            onTap: () => _showSnack(context, l10n.email),
          ),
          const SizedBox(height: 12),
          _HelpCard(
            icon: Icons.phone_outlined,
            title: l10n.phone,
            subtitle: '+968 XXXX XXXX',
            onTap: () => _showSnack(context, l10n.phone),
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              l10n.supportAvailableAnytime,
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnack(BuildContext context, String msg) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _HelpCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _HelpCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.outlineVariant.withOpacity(0.4)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: cs.primary, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_left_rounded,
                color: cs.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
