// lib/features/profile/presentation/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hindam/shared/widgets/profile_page_scaffold.dart';
import 'package:hindam/l10n/app_localizations.dart';

/// صفحة الإعدادات: إشعارات، عروض، إلخ
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _offersEnabled = true;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return ProfilePageScaffold(
      title: l10n.settings,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          _SectionTitle(title: l10n.notifications),
          const SizedBox(height: 12),
          _SettingsTile(
            icon: Icons.notifications_active_rounded,
            iconColor: cs.primary,
            title: l10n.notifications,
            subtitle: l10n.orderStatusAndOffersAlerts,
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: (v) {
                HapticFeedback.selectionClick();
                setState(() => _notificationsEnabled = v);
              },
              activeColor: cs.primary,
            ),
          ),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.local_offer_rounded,
            iconColor: const Color(0xFF10B981),
            title: l10n.offersAndDiscounts,
            subtitle: l10n.receiveExclusiveOffers,
            trailing: Switch(
              value: _offersEnabled,
              onChanged: (v) {
                HapticFeedback.selectionClick();
                setState(() => _offersEnabled = v);
              },
              activeColor: cs.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        title,
        style: tt.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: cs.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget trailing;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
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
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
