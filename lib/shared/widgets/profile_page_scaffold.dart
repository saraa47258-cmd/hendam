// lib/shared/widgets/profile_page_scaffold.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// سقالة موحدة لصفحات الملف الشخصي: AppBar + محتوى
/// تصميم نظيف، RTL صحيح، انتقالات سلسة
class ProfilePageScaffold extends StatelessWidget {
  const ProfilePageScaffold({
    super.key,
    required this.title,
    required this.child,
    this.actions,
  });

  final String title;
  final Widget child;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: cs.surface,
        appBar: AppBar(
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
          backgroundColor: cs.surface,
          elevation: 0,
          scrolledUnderElevation: 0.5,
          centerTitle: false,
          title: Text(
            title,
            style: tt.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          leading: IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop();
            },
            icon: Icon(
              Icons.arrow_back_rounded,
              color: cs.onSurface,
            ),
          ),
          actions: actions,
        ),
        body: SafeArea(
          top: false,
          child: child,
        ),
      ),
    );
  }
}
