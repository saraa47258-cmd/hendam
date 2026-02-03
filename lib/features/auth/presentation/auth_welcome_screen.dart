import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hindam/l10n/app_localizations.dart';

/// شاشة الترحيب - تصميم فاخر مستوحى من Apple / Airbnb / Stripe
class AuthWelcomeScreen extends StatelessWidget {
  const AuthWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
        backgroundColor: _LuxuryColors.backgroundBase,
        body: _LuxuryWelcomeBody(),
      ),
    );
  }
}

/// لوحة الألوان الفاخرة المحسّنة
abstract class _LuxuryColors {
  // === الخلفية المتدرجة الأنيقة ===
  static const Color backgroundBase = Color(0xFFF7F8FC);
  static const Color backgroundWarm = Color(0xFFFDF9F6);
  static const Color backgroundCool = Color(0xFFF0F4FA);

  // === الألوان الأساسية - أزرق ملكي عميق ===
  static const Color primaryDeep = Color(0xFF0F2847);
  static const Color primary = Color(0xFF1E3A5F);
  static const Color primarySoft = Color(0xFFDBE9FF);
  static const Color primaryGlow = Color(0xFF3B82F6);

  // === ألوان الأزرار المحسّنة ===
  static const Color buttonPrimaryStart = Color(0xFF1E3A5F);
  static const Color buttonPrimaryEnd = Color(0xFF2D5A87);
  static const Color buttonSecondaryBorder = Color(0xFF1E3A5F);

  // === النصوص - تدرج هرمي واضح ===
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF94A3B8);

  // === عناصر الأجواء والديكور ===
  static const Color glowWarm = Color(0xFFFEF3E7);
  static const Color glowCool = Color(0xFFE0ECFF);
  static const Color glowAccent = Color(0xFFF0E6FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFFCFDFF);
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderSubtle = Color(0xFFF1F5F9);
}

/// المحتوى الرئيسي
class _LuxuryWelcomeBody extends StatelessWidget {
  const _LuxuryWelcomeBody();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // الخلفية المتعددة الطبقات
        const _ElegantBackground(),

        // المحتوى
        SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxHeight < 700;

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: constraints.maxWidth > 400 ? 36 : 28,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: isCompact ? 40 : 60),
                        const _LuxuryBrandSection(),
                        SizedBox(height: isCompact ? 48 : 64),
                        const _LuxuryActionCard(),
                        SizedBox(height: isCompact ? 32 : 48),
                        const _TrustBadges(),
                        const SizedBox(height: 40),
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

/// الخلفية الأنيقة متعددة الطبقات
class _ElegantBackground extends StatelessWidget {
  const _ElegantBackground();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SizedBox.expand(
      child: Stack(
        children: [
          // === الطبقة 1: التدرج الأساسي الناعم ===
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _LuxuryColors.backgroundWarm,
                  _LuxuryColors.backgroundBase,
                  _LuxuryColors.backgroundCool,
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // === الطبقة 2: توهج دافئ كبير - أعلى اليمين ===
          Positioned(
            top: -size.height * 0.2,
            right: -size.width * 0.35,
            child: Container(
              width: size.width * 1.0,
              height: size.width * 1.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _LuxuryColors.glowWarm.withOpacity(0.9),
                    _LuxuryColors.glowWarm.withOpacity(0.4),
                    _LuxuryColors.glowWarm.withOpacity(0.0),
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),
          ),

          // === الطبقة 3: توهج بارد - أسفل اليسار ===
          Positioned(
            bottom: -size.height * 0.15,
            left: -size.width * 0.4,
            child: Container(
              width: size.width * 1.1,
              height: size.width * 1.1,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _LuxuryColors.glowCool.withOpacity(0.85),
                    _LuxuryColors.glowCool.withOpacity(0.3),
                    _LuxuryColors.glowCool.withOpacity(0.0),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // === الطبقة 4: توهج أرجواني خفيف - وسط ===
          Positioned(
            top: size.height * 0.35,
            right: -size.width * 0.2,
            child: Container(
              width: size.width * 0.7,
              height: size.width * 0.7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _LuxuryColors.glowAccent.withOpacity(0.5),
                    _LuxuryColors.glowAccent.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),

          // === الطبقة 5: نمط شبكي خفيف جداً ===
          Positioned.fill(
            child: CustomPaint(
              painter: _SubtleGridPainter(
                color: _LuxuryColors.primary.withOpacity(0.015),
              ),
            ),
          ),

          // === الطبقة 6: أشكال هندسية عائمة ===
          Positioned(
            top: size.height * 0.08,
            left: size.width * 0.06,
            child: _FloatingShape(
              size: 90,
              color: _LuxuryColors.primarySoft.withOpacity(0.4),
              borderRadius: 28,
            ),
          ),
          Positioned(
            top: size.height * 0.52,
            right: size.width * 0.04,
            child: Transform.rotate(
              angle: math.pi / 6,
              child: _FloatingShape(
                size: 70,
                color: _LuxuryColors.glowWarm.withOpacity(0.6),
                borderRadius: 20,
              ),
            ),
          ),
          Positioned(
            bottom: size.height * 0.22,
            left: size.width * 0.08,
            child: Transform.rotate(
              angle: -math.pi / 8,
              child: _FloatingShape(
                size: 55,
                color: _LuxuryColors.glowCool.withOpacity(0.5),
                borderRadius: 16,
              ),
            ),
          ),

          // === الطبقة 7: خطوط ديكورية رقيقة ===
          Positioned(
            top: size.height * 0.15,
            right: size.width * 0.15,
            child: _DecorativeLine(
              length: 80,
              color: _LuxuryColors.primary.withOpacity(0.06),
              angle: math.pi / 4,
            ),
          ),
          Positioned(
            bottom: size.height * 0.3,
            right: size.width * 0.2,
            child: _DecorativeLine(
              length: 60,
              color: _LuxuryColors.primary.withOpacity(0.04),
              angle: -math.pi / 3,
            ),
          ),
        ],
      ),
    );
  }
}

/// رسام شبكة خفيفة
class _SubtleGridPainter extends CustomPainter {
  final Color color;

  _SubtleGridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5;

    const spacing = 60.0;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// شكل عائم ديكوري
class _FloatingShape extends StatelessWidget {
  final double size;
  final Color color;
  final double borderRadius;

  const _FloatingShape({
    required this.size,
    required this.color,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
    );
  }
}

/// خط ديكوري
class _DecorativeLine extends StatelessWidget {
  final double length;
  final Color color;
  final double angle;

  const _DecorativeLine({
    required this.length,
    required this.color,
    required this.angle,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        width: length,
        height: 2,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0),
              color,
              color.withOpacity(0),
            ],
          ),
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}

/// قسم العلامة التجارية الفاخر
class _LuxuryBrandSection extends StatelessWidget {
  const _LuxuryBrandSection();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        // الشعار المحسّن مع توهج
        const _GlowingLogo(),

        const SizedBox(height: 36),

        // اسم التطبيق مع تأثير متدرج
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              _LuxuryColors.primaryDeep,
              _LuxuryColors.primary,
            ],
          ).createShader(bounds),
          child: Text(
            l10n.hindam,
            style: const TextStyle(
              fontSize: 52,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -2,
              height: 1.0,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // الوصف مع خلفية شفافة
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: _LuxuryColors.primarySoft.withOpacity(0.4),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            l10n.menTailoringShopsApp,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: _LuxuryColors.textSecondary,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ],
    );
  }
}

/// الشعار المتوهج
class _GlowingLogo extends StatelessWidget {
  const _GlowingLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          // توهج خارجي كبير
          BoxShadow(
            color: _LuxuryColors.primaryGlow.withOpacity(0.15),
            blurRadius: 60,
            spreadRadius: 10,
          ),
          // ظل متوسط
          BoxShadow(
            color: _LuxuryColors.primary.withOpacity(0.12),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
          // ظل قريب
          BoxShadow(
            color: _LuxuryColors.primary.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _LuxuryColors.surface,
              _LuxuryColors.surfaceElevated,
            ],
          ),
          border: Border.all(
            color: _LuxuryColors.borderSubtle,
            width: 1.5,
          ),
        ),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _LuxuryColors.primarySoft,
                Color(0xFFE8F0FF),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: _LuxuryColors.primary.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.content_cut_rounded,
              size: 48,
              color: _LuxuryColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}

/// بطاقة الإجراءات الفاخرة
class _LuxuryActionCard extends StatelessWidget {
  const _LuxuryActionCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 420),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: _LuxuryColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: _LuxuryColors.border.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          // ظل خارجي ناعم كبير
          BoxShadow(
            color: _LuxuryColors.primary.withOpacity(0.04),
            blurRadius: 40,
            offset: const Offset(0, 20),
            spreadRadius: 0,
          ),
          // ظل متوسط
          BoxShadow(
            color: _LuxuryColors.primary.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          // ظل داخلي خفيف (محاكاة)
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            blurRadius: 0,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: const Column(
        children: [
          _PrimaryActionButton(),
          SizedBox(height: 16),
          _SecondaryActionButton(),
          SizedBox(height: 28),
          _OrDivider(),
          SizedBox(height: 20),
          _GuestButton(),
        ],
      ),
    );
  }
}

/// زر الإجراء الأساسي - تصميم متدرج فاخر
class _PrimaryActionButton extends StatefulWidget {
  const _PrimaryActionButton();

  @override
  State<_PrimaryActionButton> createState() => _PrimaryActionButtonState();
}

class _PrimaryActionButtonState extends State<_PrimaryActionButton> {
  bool _isPressed = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        if (_isLoading) return;
        HapticFeedback.mediumImpact();
        setState(() => _isLoading = true);
        Future.delayed(const Duration(milliseconds: 250), () {
          if (mounted) {
            setState(() => _isLoading = false);
            context.push('/login');
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        width: double.infinity,
        height: 62,
        transform: Matrix4.identity()..scale(_isPressed ? 0.975 : 1.0),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _isPressed
                ? [
                    _LuxuryColors.primaryDeep,
                    _LuxuryColors.buttonPrimaryStart,
                  ]
                : [
                    _LuxuryColors.buttonPrimaryStart,
                    _LuxuryColors.buttonPrimaryEnd,
                  ],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color:
                  _LuxuryColors.primary.withOpacity(_isPressed ? 0.25 : 0.35),
              blurRadius: _isPressed ? 15 : 25,
              offset: Offset(0, _isPressed ? 6 : 12),
              spreadRadius: _isPressed ? -2 : 0,
            ),
            BoxShadow(
              color:
                  _LuxuryColors.primaryGlow.withOpacity(_isPressed ? 0.1 : 0.2),
              blurRadius: 40,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // تأثير لمعان علوي
            Positioned(
              top: 0,
              left: 20,
              right: 20,
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0),
                      Colors.white.withOpacity(0.2),
                      Colors.white.withOpacity(0),
                    ],
                  ),
                ),
              ),
            ),
            // المحتوى
            Center(
              child: _isLoading
                  ? const SizedBox(
                      width: 26,
                      height: 26,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.login,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// زر الإجراء الثانوي - تصميم أنيق متباين
class _SecondaryActionButton extends StatefulWidget {
  const _SecondaryActionButton();

  @override
  State<_SecondaryActionButton> createState() => _SecondaryActionButtonState();
}

class _SecondaryActionButtonState extends State<_SecondaryActionButton> {
  bool _isPressed = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        if (_isLoading) return;
        HapticFeedback.lightImpact();
        setState(() => _isLoading = true);
        Future.delayed(const Duration(milliseconds: 250), () {
          if (mounted) {
            setState(() => _isLoading = false);
            context.push('/signup');
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        width: double.infinity,
        height: 62,
        transform: Matrix4.identity()..scale(_isPressed ? 0.975 : 1.0),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: _isPressed
              ? _LuxuryColors.primarySoft.withOpacity(0.5)
              : _LuxuryColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _isPressed
                ? _LuxuryColors.primary
                : _LuxuryColors.buttonSecondaryBorder.withOpacity(0.4),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  _LuxuryColors.primary.withOpacity(_isPressed ? 0.08 : 0.05),
              blurRadius: _isPressed ? 8 : 15,
              offset: Offset(0, _isPressed ? 3 : 6),
            ),
          ],
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _LuxuryColors.primary,
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _LuxuryColors.primarySoft.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.person_add_alt_1_rounded,
                        size: 18,
                        color: _LuxuryColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      l10n.createNewAccount,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: _LuxuryColors.primary,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// فاصل "أو" أنيق
class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1.5,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _LuxuryColors.border.withOpacity(0),
                  _LuxuryColors.border,
                ],
              ),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _LuxuryColors.backgroundBase,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _LuxuryColors.border.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: const Text(
            'أو',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _LuxuryColors.textMuted,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1.5,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _LuxuryColors.border,
                  _LuxuryColors.border.withOpacity(0),
                ],
              ),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ),
      ],
    );
  }
}

/// زر الزائر
class _GuestButton extends StatefulWidget {
  const _GuestButton();

  @override
  State<_GuestButton> createState() => _GuestButtonState();
}

class _GuestButtonState extends State<_GuestButton> {
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
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        decoration: BoxDecoration(
          color: _isPressed
              ? _LuxuryColors.backgroundCool.withOpacity(0.8)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.explore_outlined,
              size: 20,
              color: _isPressed
                  ? _LuxuryColors.primary
                  : _LuxuryColors.textSecondary,
            ),
            const SizedBox(width: 10),
            Text(
              l10n.continueAsGuest,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _isPressed
                    ? _LuxuryColors.primary
                    : _LuxuryColors.textSecondary,
              ),
            ),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              transform: Matrix4.translationValues(_isPressed ? 4 : 0, 0, 0),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: _isPressed
                    ? _LuxuryColors.primary
                    : _LuxuryColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// شارات الثقة
class _TrustBadges extends StatelessWidget {
  const _TrustBadges();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      constraints: const BoxConstraints(maxWidth: 420),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _LuxuryColors.surface.withOpacity(0.9),
            _LuxuryColors.surfaceElevated.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _LuxuryColors.border.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _LuxuryColors.primary.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _TrustBadge(
            icon: Icons.local_shipping_rounded,
            label: l10n.fastDelivery,
            color: const Color(0xFF059669),
          ),
          _BadgeDivider(),
          _TrustBadge(
            icon: Icons.verified_rounded,
            label: l10n.guaranteedQuality,
            color: const Color(0xFF2563EB),
          ),
          _BadgeDivider(),
          _TrustBadge(
            icon: Icons.headset_mic_rounded,
            label: l10n.continuousSupport,
            color: const Color(0xFF7C3AED),
          ),
        ],
      ),
    );
  }
}

/// شارة ثقة واحدة
class _TrustBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _TrustBadge({
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
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: color.withOpacity(0.15),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            size: 24,
            color: color,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _LuxuryColors.textSecondary,
            letterSpacing: 0.2,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

/// فاصل بين الشارات
class _BadgeDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _LuxuryColors.border.withOpacity(0),
            _LuxuryColors.border.withOpacity(0.5),
            _LuxuryColors.border.withOpacity(0),
          ],
        ),
      ),
    );
  }
}
