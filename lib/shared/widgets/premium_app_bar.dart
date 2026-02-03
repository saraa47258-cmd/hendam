import 'dart:ui';

import 'package:flutter/material.dart';

/// Premium, world-class AppBar for store/shop screens.
/// Apple / Airbnb / Stripe style — luxury, clean, RTL-aware.
///
/// Implements [PreferredSizeWidget] for use as [Scaffold.appBar].
/// Height: 72px content (SafeArea adds to total on notched devices).
class PremiumStoreAppBar extends StatefulWidget implements PreferredSizeWidget {
  const PremiumStoreAppBar({
    super.key,
    required this.title,
    this.locationText,
    this.onBack,
    this.onProfile,
    this.actions,
    this.gradientColors,
  });

  final String title;
  final String? locationText;
  final VoidCallback? onBack;
  final VoidCallback? onProfile;
  final List<Widget>? actions;

  /// Optional gradient colors; if null, derived from [Theme.colorScheme.primary].
  final List<Color>? gradientColors;

  @override
  Size get preferredSize =>
      const Size.fromHeight(_contentHeight + _maxStatusBarHeight);

  static const double _contentHeight = 72.0;

  /// Reserve space for status bar so content is drawn below it.
  static const double _maxStatusBarHeight = 48.0;

  @override
  State<PremiumStoreAppBar> createState() => _PremiumStoreAppBarState();
}

class _PremiumStoreAppBarState extends State<PremiumStoreAppBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 280),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    if (_controller.isAnimating) _controller.stop();
    _controller.dispose();
    super.dispose();
  }

  List<Color> _gradientColors(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (widget.gradientColors != null && widget.gradientColors!.length >= 2) {
      return widget.gradientColors!;
    }
    final base = cs.primary;
    return [
      base,
      Color.lerp(base, cs.primaryContainer, 0.4) ?? base,
      Color.lerp(base, cs.surface, 0.25) ?? base,
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (!mounted) {
      return SizedBox(
        height: PremiumStoreAppBar._contentHeight +
            MediaQuery.paddingOf(context).top,
      );
    }
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final colors = _gradientColors(context);
    final topPadding = MediaQuery.paddingOf(context).top;
    final totalHeight = PremiumStoreAppBar._contentHeight + topPadding;

    return Container(
      height: totalHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.12),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 10 + topPadding,
            bottom: 10,
          ),
          child: Row(
            children: [
              // Back button (RTL: appears on right)
              if (widget.onBack != null)
                _BackCapsule(onBack: widget.onBack!, cs: cs, tt: tt),
              if (widget.onBack != null) const SizedBox(width: 16),
              // Center: title + subtitle (constrained to avoid overflow)
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment:
                      isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tt.titleLarge?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                        height: 1.2,
                        color: Colors.white,
                      ),
                    ),
                    if (widget.locationText != null) ...[
                      const SizedBox(height: 3),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: isRtl
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: 13,
                            color: Colors.white.withOpacity(0.85),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.locationText!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: tt.bodySmall?.copyWith(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (widget.actions != null && widget.actions!.isNotEmpty) ...[
                ...widget.actions!,
                const SizedBox(width: 8),
              ],
              // Profile / avatar (RTL: appears on left)
              if (widget.onProfile != null)
                _ProfileAvatar(onProfile: widget.onProfile!),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackCapsule extends StatelessWidget {
  const _BackCapsule({
    required this.onBack,
    required this.cs,
    required this.tt,
  });

  final VoidCallback onBack;
  final ColorScheme cs;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.18),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onBack,
        borderRadius: BorderRadius.circular(16),
        splashFactory: InkRipple.splashFactory,
        splashColor: Colors.white.withOpacity(0.2),
        highlightColor: Colors.white.withOpacity(0.1),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.4),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'رجوع',
                style: tt.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.onProfile});

  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onProfile,
        borderRadius: BorderRadius.circular(24),
        splashFactory: InkRipple.splashFactory,
        splashColor: Colors.white.withOpacity(0.2),
        highlightColor: Colors.white.withOpacity(0.1),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.2),
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 1.2,
                ),
              ),
              child: const Icon(
                Icons.checkroom_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
