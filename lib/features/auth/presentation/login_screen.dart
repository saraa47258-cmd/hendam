// lib/features/auth/presentation/login_screen.dart
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:hindam/features/auth/providers/auth_provider.dart';
import 'package:hindam/l10n/app_localizations.dart';
import 'package:hindam/core/providers/locale_provider.dart';

// ─────────────────────────────────────────────────────────────────────────
// نظام التصميم - متطابق مع صفحة الترحيب
// ─────────────────────────────────────────────────────────────────────────
abstract class _DS {
  static const Color primary = Color(0xFF0C1B33);
  static const Color primaryLight = Color(0xFF2A5580);
  static const Color accent = Color(0xFFD4A853);
  static const Color accentLight = Color(0xFFE8C97A);
  static const Color textOnDarkMuted = Color(0xFFAFBFD4);
  static const Color surface = Colors.white;

  static const double sm = 8;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;

  static const double radiusSm = 10;
  static const double radiusMd = 14;
  static const double radiusLg = 18;
  static const double radiusXl = 24;
  static const double radiusXxl = 32;
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  late final AnimationController _staggerController;
  late final Animation<double> _logoAnim;
  late final Animation<double> _titleAnim;
  late final Animation<double> _formAnim;
  late final Animation<double> _buttonAnim;
  late final Animation<double> _bottomAnim;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _logoAnim = CurvedAnimation(
      parent: _staggerController,
      curve: const Interval(0.0, 0.30, curve: Curves.easeOutCubic),
    );
    _titleAnim = CurvedAnimation(
      parent: _staggerController,
      curve: const Interval(0.12, 0.42, curve: Curves.easeOutCubic),
    );
    _formAnim = CurvedAnimation(
      parent: _staggerController,
      curve: const Interval(0.30, 0.65, curve: Curves.easeOutCubic),
    );
    _buttonAnim = CurvedAnimation(
      parent: _staggerController,
      curve: const Interval(0.50, 0.80, curve: Curves.easeOutCubic),
    );
    _bottomAnim = CurvedAnimation(
      parent: _staggerController,
      curve: const Interval(0.65, 1.0, curve: Curves.easeOutCubic),
    );

    _staggerController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (mounted) {
      setState(() => _isLoading = false);

      final l10n = AppLocalizations.of(context)!;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  l10n.loginSuccessful,
                  style: GoogleFonts.cairo(),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_DS.radiusMd),
            ),
          ),
        );
        context.go('/app');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AuthProvider.localizeError(authProvider.error, l10n),
                    style: GoogleFonts.cairo(),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_DS.radiusMd),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final l10n = AppLocalizations.of(context)!;
    final isRtl = localeProvider.isRtl;

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: Stack(
          children: [
            // الخلفية المتدرجة الداكنة
            const _PremiumBackground(),

            // المحتوى
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal:
                        MediaQuery.of(context).size.width > 400 ? 32.0 : 24.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),

                      // زر الرجوع
                      _SlideIn(
                        animation: _logoAnim,
                        offsetY: 20,
                        child: Align(
                          alignment:
                              isRtl ? Alignment.centerRight : Alignment.centerLeft,
                          child: _BackButton(isRtl: isRtl),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // الشعار المتحرك
                      _SlideIn(
                        animation: _logoAnim,
                        offsetY: 40,
                        child: const _AnimatedLogo(),
                      ),

                      const SizedBox(height: 28),

                      // العنوان
                      _SlideIn(
                        animation: _titleAnim,
                        offsetY: 30,
                        child: Text(
                          l10n.welcomeBackTitle,
                          style: GoogleFonts.cairo(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: _DS.surface,
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: _DS.sm),

                      // العنوان الفرعي
                      _SlideIn(
                        animation: _titleAnim,
                        offsetY: 20,
                        child: Text(
                          l10n.loginToAccessAccount,
                          style: GoogleFonts.cairo(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: _DS.textOnDarkMuted,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 36),

                      // نموذج تسجيل الدخول
                      _SlideIn(
                        animation: _formAnim,
                        offsetY: 40,
                        child: _buildForm(l10n),
                      ),

                      const SizedBox(height: _DS.xxl),

                      // زر تسجيل الدخول
                      _SlideIn(
                        animation: _buttonAnim,
                        offsetY: 30,
                        child: _LoginActionButton(
                          isLoading: _isLoading,
                          onPressed: _handleLogin,
                          label: l10n.login,
                        ),
                      ),

                      const SizedBox(height: _DS.xl),

                      // نسيان كلمة المرور
                      _SlideIn(
                        animation: _bottomAnim,
                        offsetY: 20,
                        child: Center(
                          child: GestureDetector(
                            onTap: () => context.push('/forgot-password'),
                            child: Text(
                              l10n.forgotPassword,
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _DS.accentLight,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // رابط التسجيل
                      _SlideIn(
                        animation: _bottomAnim,
                        offsetY: 20,
                        child: _buildSignUpCard(l10n),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(AppLocalizations l10n) {
    return Form(
      key: _formKey,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_DS.radiusXxl),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(_DS.xxl),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(_DS.radiusXxl),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // حقل البريد الإلكتروني
                _buildTextField(
                  controller: _emailController,
                  label: l10n.email,
                  hint: l10n.enterYourEmail,
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.pleaseEnterValidEmail;
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return l10n.invalidEmail;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: _DS.xl),

                // حقل كلمة المرور
                _buildTextField(
                  controller: _passwordController,
                  label: l10n.password,
                  hint: l10n.enterYourPassword,
                  icon: Icons.lock_outline_rounded,
                  obscureText: _obscurePassword,
                  suffixIcon: GestureDetector(
                    onTap: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    child: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                      color: _DS.textOnDarkMuted,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.pleaseEnterValidPassword;
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textDirection: TextDirection.ltr,
      style: GoogleFonts.cairo(
        fontSize: 15,
        color: _DS.surface,
        fontWeight: FontWeight.w500,
      ),
      cursorColor: _DS.accent,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: GoogleFonts.cairo(
          fontSize: 14,
          color: _DS.textOnDarkMuted,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: GoogleFonts.cairo(
          fontSize: 14,
          color: _DS.textOnDarkMuted.withValues(alpha: 0.5),
        ),
        prefixIcon: Container(
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _DS.accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(_DS.radiusSm),
          ),
          child: Icon(icon, size: 20, color: _DS.accent),
        ),
        suffixIcon: suffixIcon != null
            ? Padding(
                padding: const EdgeInsets.only(left: 12, right: 12),
                child: suffixIcon,
              )
            : null,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.06),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_DS.radiusLg),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_DS.radiusLg),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_DS.radiusLg),
          borderSide: BorderSide(
            color: _DS.accent.withValues(alpha: 0.6),
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_DS.radiusLg),
          borderSide: const BorderSide(
            color: Color(0xFFEF4444),
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_DS.radiusLg),
          borderSide: const BorderSide(
            color: Color(0xFFEF4444),
            width: 1.5,
          ),
        ),
        errorStyle: GoogleFonts.cairo(
          fontSize: 12,
          color: const Color(0xFFEF4444),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildSignUpCard(AppLocalizations l10n) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(_DS.radiusXl),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: _DS.xl,
            vertical: _DS.lg,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(_DS.radiusXl),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.dontHaveAccount,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: _DS.textOnDarkMuted,
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => context.push('/signup'),
                child: Text(
                  l10n.createNewAccount,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _DS.accent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
// زر الرجوع
// ─────────────────────────────────────────────────────────────────────────
class _BackButton extends StatelessWidget {
  final bool isRtl;
  const _BackButton({required this.isRtl});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.pop(),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(_DS.radiusMd),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Icon(
          isRtl ? Icons.arrow_forward_rounded : Icons.arrow_back_rounded,
          color: _DS.surface,
          size: 22,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// الخلفية الفاخرة - متطابقة مع صفحة الترحيب
// ─────────────────────────────────────────────────────────────────────────
class _PremiumBackground extends StatelessWidget {
  const _PremiumBackground();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return SizedBox.expand(
      child: Stack(
        children: [
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

          // توهج ذهبي
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

          // توهج أزرق
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

          // نقاط زخرفية
          CustomPaint(
            size: size,
            painter: _DotPatternPainter(),
          ),
        ],
      ),
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
    return Center(
      child: AnimatedBuilder(
        animation: _glowController,
        builder: (context, child) {
          final glowAngle = _glowController.value * 2 * math.pi;

          return Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _DS.accent.withValues(alpha: 0.25),
                  blurRadius: 48,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // الحلقة الدوارة
                Transform.rotate(
                  angle: glowAngle,
                  child: Container(
                    width: 110,
                    height: 110,
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
                  width: 102,
                  height: 102,
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

                // الدائرة الداخلية مع الأيقونة
                Container(
                  width: 86,
                  height: 86,
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
                      size: 40,
                      color: _DS.accent,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// زر تسجيل الدخول الذهبي
// ─────────────────────────────────────────────────────────────────────────
class _LoginActionButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onPressed;
  final String label;

  const _LoginActionButton({
    required this.isLoading,
    required this.onPressed,
    required this.label,
  });

  @override
  State<_LoginActionButton> createState() => _LoginActionButtonState();
}

class _LoginActionButtonState extends State<_LoginActionButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;

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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      onTap: widget.isLoading ? null : () {
        HapticFeedback.mediumImpact();
        widget.onPressed();
      },
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
            child: widget.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation(_DS.primary),
                    ),
                  )
                : Text(
                    widget.label,
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: _DS.primary,
                      letterSpacing: 0.3,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
