import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hindam/l10n/app_localizations.dart';

/// ══════════════════════════════════════════════════════════════════════════
/// شاشة الترحيب - تصميم فاخر احترافي مع حركات انسيابية
/// ══════════════════════════════════════════════════════════════════════════
class AuthWelcomeScreen extends StatelessWidget {
  const AuthWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return const Scaffold(
      body: _WelcomeBody(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// نظام التصميم
// ─────────────────────────────────────────────────────────────────────────
abstract class _DS {
  // الألوان الأساسية - درجات ذهبية وكحلية فاخرة
  static const Color primary = Color(0xFF0C1B33);
  static const Color primaryLight = Color(0xFF2A5580);
  static const Color accent = Color(0xFFD4A853);
  static const Color accentLight = Color(0xFFE8C97A);

  // النصوص
  static const Color textOnDarkMuted = Color(0xFFAFBFD4);
  static const Color textDark = Color(0xFF0F172A);

  // الأسطح
  static const Color surface = Colors.white;

  // المسافات
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;

  // الأقطار
  static const double radiusSm = 10;
  static const double radiusMd = 14;
  static const double radiusLg = 18;
  static const double radiusXl = 24;
  static const double radiusXxl = 32;
}

// ─────────────────────────────────────────────────────────────────────────
// المحتوى الرئيسي مع Staggered Animations
// ─────────────────────────────────────────────────────────────────────────
class _WelcomeBody extends StatefulWidget {
  const _WelcomeBody();

  @override
  State<_WelcomeBody> createState() => _WelcomeBodyState();
}

class _WelcomeBodyState extends State<_WelcomeBody>
    with TickerProviderStateMixin {
  late final AnimationController _staggerController;
  late final Animation<double> _logoAnim;
  late final Animation<double> _titleAnim;
  late final Animation<double> _subtitleAnim;
  late final Animation<double> _cardAnim;
  late final Animation<double> _trustAnim;

  @override
  void initState() {
    super.initState();

    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _logoAnim = CurvedAnimation(
      parent: _staggerController,
      curve: const Interval(0.0, 0.35, curve: Curves.easeOutBack),
    );
    _titleAnim = CurvedAnimation(
      parent: _staggerController,
      curve: const Interval(0.15, 0.45, curve: Curves.easeOutCubic),
    );
    _subtitleAnim = CurvedAnimation(
      parent: _staggerController,
      curve: const Interval(0.25, 0.55, curve: Curves.easeOutCubic),
    );
    _cardAnim = CurvedAnimation(
      parent: _staggerController,
      curve: const Interval(0.40, 0.75, curve: Curves.easeOutCubic),
    );
    _trustAnim = CurvedAnimation(
      parent: _staggerController,
      curve: const Interval(0.60, 1.0, curve: Curves.easeOutCubic),
    );

    _staggerController.forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Stack(
      children: [
        // الخلفية المتدرجة الداكنة
        const _PremiumBackground(),

        // المحتوى
        SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxHeight < 700;
              final hPad = constraints.maxWidth > 400 ? 32.0 : 24.0;

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints:
                      BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: hPad),
                    child: Column(
                      children: [
                        SizedBox(height: isCompact ? 40 : 64),

                        // الشعار
                        _SlideIn(
                          animation: _logoAnim,
                          offsetY: 40,
                          child: const _AnimatedLogo(),
                        ),

                        SizedBox(height: isCompact ? 24 : 32),

                        // اسم التطبيق
                        _SlideIn(
                          animation: _titleAnim,
                          offsetY: 30,
                          child: Text(
                            l10n.hindam,
                            style: GoogleFonts.cairo(
                              fontSize: 52,
                              fontWeight: FontWeight.w900,
                              color: _DS.surface,
                              letterSpacing: -1,
                              height: 1.0,
                            ),
                          ),
                        ),

                        const SizedBox(height: _DS.md),

                        // الشعار الفرعي
                        _SlideIn(
                          animation: _subtitleAnim,
                          offsetY: 20,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _DS.accent.withValues(alpha: 0.5),
                                width: 1,
                              ),
                              borderRadius:
                                  BorderRadius.circular(_DS.radiusXxl),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.auto_awesome,
                                  size: 14,
                                  color: _DS.accent.withValues(alpha: 0.8),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  l10n.menTailoringShopsApp,
                                  style: GoogleFonts.cairo(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _DS.textOnDarkMuted,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: isCompact ? 36 : 52),

                        // بطاقة الإجراءات
                        _SlideIn(
                          animation: _cardAnim,
                          offsetY: 50,
                          child: const _ActionCard(),
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// SlideIn animation wrapper
// ─────────────────────────────────────────────────────────────────────────
class _SlideIn extends StatelessWidget {
  final Animation<double> animation;
  final double offsetY;
  final Widget child;

  const _SlideIn({
    required this.animation,
    required this.offsetY,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, offsetY * (1 - animation.value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// الخلفية الفاخرة - تدرج كحلي عميق مع تأثيرات ذهبية
// ─────────────────────────────────────────────────────────────────────────
class _PremiumBackground extends StatelessWidget {
  const _PremiumBackground();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return SizedBox.expand(
      child: Stack(
        children: [
          // التدرج الأساسي الداكن
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF05101F),
                  Color(0xFF0C1B33),
                  Color(0xFF162D50),
                  Color(0xFF0C1B33),
                ],
                stops: [0.0, 0.3, 0.65, 1.0],
              ),
            ),
          ),

          // توهج ذهبي - أعلى اليمين
          Positioned(
            top: -size.height * 0.08,
            right: -size.width * 0.15,
            child: Container(
              width: size.width * 0.7,
              height: size.width * 0.7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _DS.accent.withValues(alpha: 0.12),
                    _DS.accent.withValues(alpha: 0.03),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // توهج أزرق - أسفل اليسار
          Positioned(
            bottom: -size.height * 0.1,
            left: -size.width * 0.2,
            child: Container(
              width: size.width * 0.8,
              height: size.width * 0.8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _DS.primaryLight.withValues(alpha: 0.2),
                    _DS.primaryLight.withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),
          ),

          // نقاط زخرفية خفيفة
          const _DecorativePattern(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// نمط زخرفي - نقاط لامعة خفيفة
// ─────────────────────────────────────────────────────────────────────────
class _DecorativePattern extends StatelessWidget {
  const _DecorativePattern();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: MediaQuery.sizeOf(context),
      painter: _DotPatternPainter(),
    );
  }
}

class _DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..style = PaintingStyle.fill;

    const spacing = 40.0;
    const radius = 1.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────
// الشعار المتحرك - مع تأثير توهج دوراني
// ─────────────────────────────────────────────────────────────────────────
class _AnimatedLogo extends StatefulWidget {
  const _AnimatedLogo();

  @override
  State<_AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<_AnimatedLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final glowAngle = _glowController.value * 2 * math.pi;

        return Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _DS.accent.withValues(alpha: 0.25),
                blurRadius: 48,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: _DS.accent.withValues(alpha: 0.15),
                blurRadius: 80,
                spreadRadius: 8,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // الحلقة الدوارة المتوهجة
              Transform.rotate(
                angle: glowAngle,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: [
                        _DS.accent.withValues(alpha: 0.0),
                        _DS.accent.withValues(alpha: 0.6),
                        _DS.accentLight.withValues(alpha: 0.8),
                        _DS.accent.withValues(alpha: 0.0),
                      ],
                      stops: const [0.0, 0.3, 0.5, 1.0],
                    ),
                  ),
                ),
              ),

              // الخلفية الداخلية
              Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF132744),
                      Color(0xFF0C1B33),
                    ],
                  ),
                  border: Border.all(
                    color: _DS.accent.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
              ),

              // الدائرة الداخلية المتدرجة
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _DS.accent.withValues(alpha: 0.15),
                      _DS.accent.withValues(alpha: 0.05),
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.content_cut_rounded,
                    size: 44,
                    color: _DS.accent,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// بطاقة الإجراءات - Glassmorphism على خلفية داكنة
// ─────────────────────────────────────────────────────────────────────────
class _ActionCard extends StatelessWidget {
  const _ActionCard();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(_DS.radiusXxl),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.symmetric(
            horizontal: _DS.xxl,
            vertical: 28,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(_DS.radiusXxl),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              width: 1,
            ),
          ),
          child: const Column(
            children: [
              _LoginButton(),
              SizedBox(height: _DS.lg),
              _SignUpButton(),
              SizedBox(height: _DS.xxl),
              _OrDivider(),
              SizedBox(height: _DS.xl),
              _GuestLink(),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// زر تسجيل الدخول - أنيق مع تأثير ذهبي
// ─────────────────────────────────────────────────────────────────────────
class _LoginButton extends StatefulWidget {
  const _LoginButton();

  @override
  State<_LoginButton> createState() => _LoginButtonState();
}

class _LoginButtonState extends State<_LoginButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  bool _isLoading = false;

  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _onTapUp(TapUpDetails _) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  Future<void> _onTap() async {
    if (_isLoading) return;
    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      setState(() => _isLoading = false);
      context.push('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _isPressed
                  ? [_DS.accent, _DS.accent]
                  : [_DS.accent, _DS.accentLight],
            ),
            borderRadius: BorderRadius.circular(_DS.radiusLg),
            boxShadow: _isPressed
                ? []
                : [
                    BoxShadow(
                      color: _DS.accent.withValues(alpha: 0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: _DS.accent.withValues(alpha: 0.2),
                      blurRadius: 48,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor:
                          AlwaysStoppedAnimation(_DS.textDark),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.login,
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: _DS.primary,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// زر إنشاء حساب جديد - شفاف بإطار أنيق
// ─────────────────────────────────────────────────────────────────────────
class _SignUpButton extends StatefulWidget {
  const _SignUpButton();

  @override
  State<_SignUpButton> createState() => _SignUpButtonState();
}

class _SignUpButtonState extends State<_SignUpButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  bool _isLoading = false;

  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _onTapUp(TapUpDetails _) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  Future<void> _onTap() async {
    if (_isLoading) return;
    HapticFeedback.lightImpact();
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      setState(() => _isLoading = false);
      context.push('/signup');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            color: _isPressed
                ? Colors.white.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(_DS.radiusLg),
            border: Border.all(
              color: _isPressed
                  ? Colors.white.withValues(alpha: 0.4)
                  : Colors.white.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation(_DS.surface),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(_DS.radiusSm),
                        ),
                        child: const Icon(
                          Icons.person_add_alt_1_rounded,
                          size: 18,
                          color: _DS.surface,
                        ),
                      ),
                      const SizedBox(width: _DS.md),
                      Text(
                        l10n.createNewAccount,
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _DS.surface,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// فاصل "أو"
// ─────────────────────────────────────────────────────────────────────────
class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0),
                  Colors.white.withValues(alpha: 0.15),
                ],
              ),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: _DS.lg),
          padding: const EdgeInsets.symmetric(
            horizontal: _DS.lg,
            vertical: _DS.xs,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
            ),
            borderRadius: BorderRadius.circular(_DS.radiusMd),
          ),
          child: Text(
            AppLocalizations.of(context)!.orLabel,
            style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _DS.textOnDarkMuted,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.15),
                  Colors.white.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// رابط المتابعة كزائر
// ─────────────────────────────────────────────────────────────────────────
class _GuestLink extends StatefulWidget {
  const _GuestLink();

  @override
  State<_GuestLink> createState() => _GuestLinkState();
}

class _GuestLinkState extends State<_GuestLink> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        HapticFeedback.selectionClick();
        context.go('/app');
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: _DS.xl,
          vertical: _DS.md,
        ),
        decoration: BoxDecoration(
          color: _isPressed
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(_DS.radiusMd),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.explore_outlined,
              size: 18,
              color: _isPressed ? _DS.accentLight : _DS.textOnDarkMuted,
            ),
            const SizedBox(width: _DS.sm),
            Text(
              l10n.continueAsGuest,
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _isPressed ? _DS.accentLight : _DS.textOnDarkMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// مؤشرات الثقة - تصميم أنيق
// ─────────────────────────────────────────────────────────────────────────
class _TrustIndicators extends StatelessWidget {
  const _TrustIndicators();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      padding: const EdgeInsets.symmetric(
        horizontal: _DS.lg,
        vertical: _DS.xl,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(_DS.radiusXl),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _TrustItem(
            icon: Icons.local_shipping_outlined,
            label: l10n.fastDelivery,
            color: const Color(0xFF34D399),
          ),
          _TrustDivider(),
          _TrustItem(
            icon: Icons.verified_outlined,
            label: l10n.guaranteedQuality,
            color: const Color(0xFF60A5FA),
          ),
          _TrustDivider(),
          _TrustItem(
            icon: Icons.support_agent_outlined,
            label: l10n.continuousSupport,
            color: const Color(0xFFA78BFA),
          ),
        ],
      ),
    );
  }
}

class _TrustItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _TrustItem({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(_DS.radiusMd),
            border: Border.all(
              color: color.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            size: 22,
            color: color,
          ),
        ),
        const SizedBox(height: _DS.sm),
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _DS.textOnDarkMuted,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _TrustDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0),
            Colors.white.withValues(alpha: 0.1),
            Colors.white.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}
