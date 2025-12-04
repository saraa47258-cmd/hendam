import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuthWelcomeScreen extends StatelessWidget {
  const AuthWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: cs.surface,
        body: Stack(
          children: [
            const _BackgroundShapes(),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _HeaderHero(cs: cs, theme: theme),
                    const SizedBox(height: 28),
                    _FeatureList(cs: cs),
                    const SizedBox(height: 28),
                    _ActionButtons(cs: cs),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderHero extends StatelessWidget {
  final ColorScheme cs;
  final ThemeData theme;
  const _HeaderHero({required this.cs, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            onPressed: () {},
            icon: Icon(Icons.person, color: cs.primary),
            style: IconButton.styleFrom(
              backgroundColor: cs.surface.withOpacity(0.6),
              shape: const CircleBorder(),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'هندام',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'تطبيق محلات الخياطة الرجالية',
          style: theme.textTheme.titleMedium?.copyWith(
            color: cs.onSurface.withOpacity(.75),
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          'أفضل الخياطين والمحلات في مكان واحد',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: cs.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              colors: [
                cs.primary.withOpacity(0.12),
                cs.secondary.withOpacity(0.1),
                cs.surface,
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            border: Border.all(color: cs.primary.withOpacity(0.15)),
            boxShadow: [
              BoxShadow(
                color: cs.primary.withOpacity(0.12),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.percent_rounded, color: cs.primary, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'خصم 40% لعملاء التطبيق',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    Text(
                      'ابدأ تجربتك مع أفضل الخياطين الآن',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton.tonal(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('اطلب الآن'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FeatureList extends StatelessWidget {
  final ColorScheme cs;
  const _FeatureList({required this.cs});

  @override
  Widget build(BuildContext context) {
    final features = [
      (
        icon: Icons.store_mall_directory_rounded,
        title: 'استعرض محلات الخياطة القريبة منك',
        subtitle: 'اكتشف أفضل الخياطين في منطقتك',
        color: cs.primaryContainer
      ),
      (
        icon: Icons.design_services_rounded,
        title: 'اختر تصاميمك المفضلة',
        subtitle: 'تصاميم عصرية وأنيقة تناسب ذوقك',
        color: cs.secondaryContainer
      ),
      (
        icon: Icons.shopping_bag_rounded,
        title: 'اطلب وتابع طلباتك بسهولة',
        subtitle: 'تجربة سلسة مع تحديثات مباشرة',
        color: cs.tertiaryContainer
      ),
    ];

    return Column(
      children: [
        for (final feature in features)
          _FeatureCard(
            icon: feature.icon,
            title: feature.title,
            subtitle: feature.subtitle,
            background: feature.color,
          ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color background;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
        color: cs.surface,
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: cs.onSurface, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.chevron_left, color: cs.primary),
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final ColorScheme cs;
  const _ActionButtons({required this.cs});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => context.push('/login'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              'تسجيل الدخول',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.onPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => context.push('/signup'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: cs.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              'إنشاء حساب جديد',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () => context.go('/app'),
          child: Text(
            'الاستمرار كزائر',
            style: textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _BackgroundShapes extends StatelessWidget {
  const _BackgroundShapes();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Positioned.fill(
      child: IgnorePointer(
        ignoring: true,
        child: Stack(
          children: [
            Positioned(
              top: -120,
              left: -60,
              child: _BlurCircle(
                radius: 220,
                color: cs.primary.withOpacity(0.15),
              ),
            ),
            Positioned(
              top: 80,
              right: -80,
              child: _BlurCircle(
                radius: 180,
                color: cs.secondary.withOpacity(0.12),
              ),
            ),
            Positioned(
              bottom: -100,
              left: 40,
              child: _BlurCircle(
                radius: 200,
                color: cs.tertiary.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BlurCircle extends StatelessWidget {
  final double radius;
  final Color color;
  const _BlurCircle({required this.radius, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius,
      height: radius,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: 120,
            spreadRadius: 40,
          ),
        ],
      ),
    );
  }
}

