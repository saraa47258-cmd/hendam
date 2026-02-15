import 'package:flutter/material.dart';
import '../../services/presentation/services_screen.dart';
import '../../../core/styles/responsive.dart';
import '../../../core/widgets/responsive_layout.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'الكتالوج',
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
