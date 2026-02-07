import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:hindam/features/auth/providers/auth_provider.dart';
import 'package:hindam/l10n/app_localizations.dart';

/// شاشة البداية - التحقق من حالة المصادقة والتوجيه المناسب
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // إعداد الأنيميشن
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _animationController.forward();

    // بدء عملية التحقق من المصادقة
    _checkAuthAndNavigate();
  }

  /// التحقق من حالة المصادقة والتوجيه للشاشة المناسبة
  Future<void> _checkAuthAndNavigate() async {
    // انتظار حد أدنى للـ splash (تجربة مستخدم أفضل)
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();

    // تهيئة AuthProvider (جلب بيانات المستخدم إن وجد)
    await authProvider.initialize();

    if (!mounted) return;

    // التوجيه بناءً على حالة المصادقة
    if (authProvider.isAuthenticated) {
      // ✅ المستخدم مسجل دخوله → الذهاب للشاشة الرئيسية (Home)
      context.go('/app');
    } else {
      // ❌ المستخدم غير مسجل → الذهاب لشاشة الترحيب
      context.go('/welcome');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: cs.surface,
      body: Stack(
        children: [
          // الخلفية المتدرجة
          Positioned(
            top: -120,
            left: -80,
            child: _BlurCircle(
              radius: 280,
              color: cs.primary.withOpacity(0.18),
            ),
          ),
          Positioned(
            bottom: -160,
            right: -40,
            child: _BlurCircle(
              radius: 260,
              color: cs.secondary.withOpacity(0.16),
            ),
          ),

          // المحتوى الرئيسي
          Center(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) => Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: child,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // الشعار
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: cs.surface,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.content_cut_rounded,
                      size: 64,
                      color: cs.primary,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // اسم التطبيق
                  Text(
                    l10n.appName,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // الوصف
                  Text(
                    l10n.bestTailorsInOnePlace,
                    style: textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 48),

                  // مؤشر التحميل
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        cs.primary.withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// دائرة ضبابية للخلفية
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
            spreadRadius: 50,
          ),
        ],
      ),
    );
  }
}
