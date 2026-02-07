import 'package:flutter/material.dart';
import '../../services/presentation/services_screen.dart';
import '../../../core/styles/responsive.dart';
import '../../../core/widgets/responsive_layout.dart';
import 'package:hindam/l10n/app_localizations.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.catalog,
          style: TextStyle(fontSize: context.responsiveFontSize(20.0)),
        ),
        elevation: context.isMobile ? 1 : 0,
      ),
      body: const ResponsiveLayout(
        mobile: ServicesScreen(),
        tablet: ServicesScreen(),
        desktop: ServicesScreen(),
      ),
    );
  }
}
