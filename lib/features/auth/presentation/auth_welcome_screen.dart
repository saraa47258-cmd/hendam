import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hindam/l10n/app_localizations.dart';

/// ══════════════════════════════════════════════════════════════════════════
/// شاشة الترحيب - تصميم عالمي فاخر (Apple / Google Level)
/// ══════════════════════════════════════════════════════════════════════════
class AuthWelcomeScreen extends StatelessWidget {
  const AuthWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ضبط شريط الحالة
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    return const Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _DS.bgBase,
        body: _WelcomeBody(),
      ),
    );
  }
}

/// ══════════════════════════════════════════════════════════════════════════
/// نظام التصميم - Design System
/// ══════════════════════════════════════════════════════════════════════════
abstract class _DS {
  // === الخلفية ===
  static const Color bgBase = Color(0xFFF8FAFC);
  static const Color bgWarm = Color(0xFFFFFBF7);
  static const Color bgCool = Color(0xFFF0F4FF);

  // === الألوان الأساسية ===
  static const Color primary = Color(0xFF1A365D);
  static const Color primaryLight = Color(0xFF2B4C7E);
  static const Color primarySoft = Color(0xFFE8F0FE);
  static const Color accent = Color(0xFF3B82F6);

  // === النصوص ===
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textOnPrimary = Colors.white;

  // === الأسطح ===
  static const Color surface = Colors.white;
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);

  // === المسافات ===
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  // === الأقطار ===
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 20;
  static const double radiusXxl = 28;

  // === الظلال ===
  static List<BoxShadow> get shadowMedium => [
        BoxShadow(
          color: primary.withOpacity(0.08),
          blurRadius: 40,
          offset: const Offset(0, 16),
        ),
        BoxShadow(
          color: primary.withOpacity(0.04),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get shadowButton => [
        BoxShadow(
          color: primary.withOpacity(0.25),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: accent.withOpacity(0.15),
          blurRadius: 32,
          offset: const Offset(0, 4),
        ),
      ];
}

/// ══════════════════════════════════════════════════════════════════════════
/// المحتوى الرئيسي
/// ══════════════════════════════════════════════════════════════════════════
class _WelcomeBody extends StatelessWidget {
  const _WelcomeBody();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // الخلفية النظيفة
        const _CleanBackground(),

        // المحتوى
        SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxHeight < 700;
              final horizontalPadding =
                  constraints.maxWidth > 400 ? 32.0 : 24.0;

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: Column(
                      children: [
                        SizedBox(height: isCompact ? 48 : 72),

                        // الشعار والعلامة التجارية
                        const _BrandSection(),

                        SizedBox(height: isCompact ? 40 : 56),

                        // بطاقة الإجراءات
                        const _ActionCard(),

                        SizedBox(height: isCompact ? 32 : 48),

                        // شارات الثقة
                        const _TrustIndicators(),

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

/// ══════════════════════════════════════════════════════════════════════════
/// الخلفية النظيفة - بسيطة وأنيقة
/// ══════════════════════════════════════════════════════════════════════════
class _CleanBackground extends StatelessWidget {
  const _CleanBackground();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return SizedBox.expand(
      child: Stack(
        children: [
          // التدرج الأساسي الناعم
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _DS.bgWarm,
                  _DS.bgBase,
                  _DS.bgCool,
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // توهج دافئ - أعلى اليمين
          Positioned(
            top: -size.height * 0.15,
            right: -size.width * 0.3,
            child: Container(
              width: size.width * 0.9,
              height: size.width * 0.9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFFEE2E2).withOpacity(0.5),
                    const Color(0xFFFEE2E2).withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),

          // توهج بارد - أسفل اليسار
          Positioned(
            bottom: -size.height * 0.1,
            left: -size.width * 0.3,
            child: Container(
              width: size.width * 0.8,
              height: size.width * 0.8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFDBEAFE).withOpacity(0.6),
                    const Color(0xFFDBEAFE).withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ══════════════════════════════════════════════════════════════════════════
/// قسم العلامة التجارية
/// ══════════════════════════════════════════════════════════════════════════
class _BrandSection extends StatelessWidget {
  const _BrandSection();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        // الشعار
        const _Logo(),

        const SizedBox(height: _DS.xxxl),

        // اسم التطبيق
        Text(
          l10n.hindam,
          style: GoogleFonts.cairo(
            fontSize: 48,
            fontWeight: FontWeight.w800,
            color: _DS.textPrimary,
            letterSpacing: -1.5,
            height: 1.0,
          ),
        ),

        const SizedBox(height: _DS.md),

        // الوصف
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: _DS.xl,
            vertical: _DS.sm,
          ),
          decoration: BoxDecoration(
            color: _DS.primarySoft.withOpacity(0.6),
            borderRadius: BorderRadius.circular(_DS.radiusXl),
          ),
          child: Text(
            l10n.menTailoringShopsApp,
            style: GoogleFonts.cairo(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: _DS.textSecondary,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ],
    );
  }
}

/// ══════════════════════════════════════════════════════════════════════════
/// الشعار
/// ══════════════════════════════════════════════════════════════════════════
class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _DS.surface,
        boxShadow: [
          BoxShadow(
            color: _DS.primary.withOpacity(0.08),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: _DS.accent.withOpacity(0.1),
            blurRadius: 48,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: _DS.borderLight,
          width: 1,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _DS.primarySoft,
              _DS.primarySoft.withOpacity(0.6),
            ],
          ),
        ),
        child: const Center(
          child: Icon(
            Icons.content_cut_rounded,
            size: 40,
            color: _DS.primary,
          ),
        ),
      ),
    );
  }
}

/// ══════════════════════════════════════════════════════════════════════════
/// بطاقة الإجراءات - Glassmorphism خفيف
/// ══════════════════════════════════════════════════════════════════════════
class _ActionCard extends StatelessWidget {
  const _ActionCard();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(_DS.radiusXxl),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(_DS.xxl),
          decoration: BoxDecoration(
            color: _DS.surface.withOpacity(0.85),
            borderRadius: BorderRadius.circular(_DS.radiusXxl),
            border: Border.all(
              color: _DS.border.withOpacity(0.4),
              width: 1,
            ),
            boxShadow: _DS.shadowMedium,
          ),
          child: const Column(
            children: [
              _LoginButton(),
              SizedBox(height: _DS.lg),
              _SignUpButton(),
              SizedBox(height: _DS.xxl),
              _Divider(),
              SizedBox(height: _DS.xl),
              _GuestLink(),
            ],
          ),
        ),
      ),
    );
  }
}

/// ══════════════════════════════════════════════════════════════════════════
/// زر تسجيل الدخول الأساسي
/// ══════════════════════════════════════════════════════════════════════════
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
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
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
          duration: const Duration(milliseconds: 180),
          width: double.infinity,
          height: 58,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _isPressed
                  ? [_DS.primary, _DS.primary]
                  : [_DS.primary, _DS.primaryLight],
            ),
            borderRadius: BorderRadius.circular(_DS.radiusLg),
            boxShadow: _isPressed
                ? [
                    BoxShadow(
                      color: _DS.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : _DS.shadowButton,
          ),
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation(_DS.textOnPrimary),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.login,
                        style: GoogleFonts.cairo(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: _DS.textOnPrimary,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(width: _DS.md),
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(_DS.radiusSm),
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded, // RTL: السهم يشير لليسار
                          size: 16,
                          color: _DS.textOnPrimary,
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

/// ══════════════════════════════════════════════════════════════════════════
/// زر إنشاء حساب جديد
/// ══════════════════════════════════════════════════════════════════════════
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
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
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
          duration: const Duration(milliseconds: 180),
          width: double.infinity,
          height: 58,
          decoration: BoxDecoration(
            color: _isPressed ? _DS.primarySoft : _DS.surface,
            borderRadius: BorderRadius.circular(_DS.radiusLg),
            border: Border.all(
              color: _isPressed ? _DS.primary : _DS.primary.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: _isPressed
                ? []
                : [
                    BoxShadow(
                      color: _DS.primary.withOpacity(0.06),
                      blurRadius: 12,
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
                      valueColor: AlwaysStoppedAnimation(_DS.primary),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: _DS.primarySoft,
                          borderRadius: BorderRadius.circular(_DS.radiusSm),
                        ),
                        child: const Icon(
                          Icons.person_add_alt_1_rounded,
                          size: 16,
                          color: _DS.primary,
                        ),
                      ),
                      const SizedBox(width: _DS.md),
                      Text(
                        l10n.createNewAccount,
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _DS.primary,
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

/// ══════════════════════════════════════════════════════════════════════════
/// فاصل "أو"
/// ══════════════════════════════════════════════════════════════════════════
class _Divider extends StatelessWidget {
  const _Divider();

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
                  _DS.border.withOpacity(0),
                  _DS.border,
                ],
              ),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: _DS.lg),
          padding: const EdgeInsets.symmetric(
            horizontal: _DS.lg,
            vertical: _DS.sm,
          ),
          decoration: BoxDecoration(
            color: _DS.bgBase,
            borderRadius: BorderRadius.circular(_DS.radiusMd),
            border: Border.all(
              color: _DS.border.withOpacity(0.5),
            ),
          ),
          child: Text(
            'أو',
            style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _DS.textMuted,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _DS.border,
                  _DS.border.withOpacity(0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// ══════════════════════════════════════════════════════════════════════════
/// رابط المتابعة كزائر
/// ══════════════════════════════════════════════════════════════════════════
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
          color: _isPressed ? _DS.bgCool : Colors.transparent,
          borderRadius: BorderRadius.circular(_DS.radiusMd),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.explore_outlined,
              size: 18,
              color: _isPressed ? _DS.primary : _DS.textSecondary,
            ),
            const SizedBox(width: _DS.sm),
            Text(
              l10n.continueAsGuest,
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _isPressed ? _DS.primary : _DS.textSecondary,
              ),
            ),
            const SizedBox(width: _DS.xs),
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              transform: Matrix4.translationValues(_isPressed ? -4 : 0, 0, 0),
              child: Icon(
                Icons.arrow_back_ios_rounded, // RTL: السهم يشير لليسار
                size: 12,
                color: _isPressed ? _DS.primary : _DS.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ══════════════════════════════════════════════════════════════════════════
/// مؤشرات الثقة
/// ══════════════════════════════════════════════════════════════════════════
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
        color: _DS.surface.withOpacity(0.7),
        borderRadius: BorderRadius.circular(_DS.radiusXl),
        border: Border.all(
          color: _DS.border.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _TrustItem(
            icon: Icons.local_shipping_outlined,
            label: l10n.fastDelivery,
            color: const Color(0xFF10B981),
          ),
          _VerticalDivider(),
          _TrustItem(
            icon: Icons.verified_outlined,
            label: l10n.guaranteedQuality,
            color: const Color(0xFF3B82F6),
          ),
          _VerticalDivider(),
          _TrustItem(
            icon: Icons.support_agent_outlined,
            label: l10n.continuousSupport,
            color: const Color(0xFF8B5CF6),
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
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(_DS.radiusMd),
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
            color: _DS.textSecondary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
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
            _DS.border.withOpacity(0),
            _DS.border.withOpacity(0.5),
            _DS.border.withOpacity(0),
          ],
        ),
      ),
    );
  }
}
