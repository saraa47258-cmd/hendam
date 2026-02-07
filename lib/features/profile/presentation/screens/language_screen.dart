// lib/features/profile/presentation/screens/language_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hindam/core/providers/locale_provider.dart';
import 'package:hindam/l10n/app_localizations.dart';
import 'package:hindam/shared/widgets/profile_page_scaffold.dart';

/// صفحة اختيار اللغة
class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  static const List<_LanguageOption> _options = [
    _LanguageOption(code: 'ar', name: 'العربية', native: 'العربية'),
    _LanguageOption(code: 'en', name: 'English', native: 'English'),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = context.watch<LocaleProvider>();
    final currentLocale = localeProvider.locale?.languageCode ?? 'ar';

    return ProfilePageScaffold(
      title: l10n.language,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          Text(
            l10n.chooseLanguage,
            style: tt.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          ...List.generate(_options.length, (i) {
            final option = _options[i];
            final isSelected = currentLocale == option.code;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    HapticFeedback.selectionClick();

                    if (option.code == 'ar') {
                      await localeProvider.setArabic();
                    } else {
                      await localeProvider.setEnglish();
                    }

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            option.code == 'ar'
                                ? l10n.languageChangedToArabic
                                : l10n.languageChangedToEnglish,
                          ),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? cs.primaryContainer.withOpacity(0.4)
                          : cs.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? cs.primary.withOpacity(0.5)
                            : cs.outlineVariant.withOpacity(0.4),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                option.native,
                                style: tt.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: cs.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                option.name,
                                style: tt.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle_rounded,
                            color: cs.primary,
                            size: 24,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _LanguageOption {
  final String code;
  final String name;
  final String native;

  const _LanguageOption({
    required this.code,
    required this.name,
    required this.native,
  });
}
