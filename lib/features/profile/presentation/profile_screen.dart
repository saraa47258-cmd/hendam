// lib/features/profile/presentation/profile_screen.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:hindam/features/auth/providers/auth_provider.dart';
import 'package:hindam/features/auth/models/user_model.dart';
import 'package:hindam/features/auth/services/profile_photo_service.dart';
import 'package:hindam/features/favorites/services/favorite_service.dart';
import 'package:hindam/features/orders/services/order_service.dart';
import 'package:hindam/features/orders/models/order_model.dart';
import 'package:hindam/core/utils/photo_permission_helper.dart';
import 'package:hindam/shared/widgets/skeletons.dart';
import 'package:hindam/core/providers/locale_provider.dart';
import 'package:hindam/l10n/app_localizations.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isUploadingPhoto = false;
  final ProfilePhotoService _profilePhotoService = ProfilePhotoService();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// فتح خيارات تغيير صورة الملف الشخصي (معرض / كاميرا)
  Future<void> _onChangeProfilePhoto() async {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;
    if (user == null) return;

    HapticFeedback.lightImpact();
    final source = await showModalBottomSheet<ImageSource?>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _PhotoSourceBottomSheet(),
    );
    if (source == null || !mounted) return;

    final hasPermission = source == ImageSource.camera
        ? await PhotoPermissionHelper.requestCameraPermission(context)
        : await PhotoPermissionHelper.requestPhotoPermission(context);
    if (!hasPermission || !mounted) return;

    final picked = await _imagePicker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;

    setState(() => _isUploadingPhoto = true);
    try {
      final file = File(picked.path);
      final url = await _profilePhotoService.uploadProfilePhoto(
        userId: user.uid,
        file: file,
      );
      final updated = user.copyWith(photoUrl: url, updatedAt: DateTime.now());
      await authProvider.updateUser(updated);
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Text(l10n.profilePhotoUpdated),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                    child:
                        Text('${l10n.failedToUploadPhoto}: ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final authProvider = context.watch<AuthProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final l10n = AppLocalizations.of(context)!;
    final isRtl = localeProvider.locale?.languageCode == 'ar';

    // إذا لم يكن مسجل دخول
    if (!authProvider.isAuthenticated) {
      return _buildLoginPrompt(context, cs, l10n, isRtl);
    }

    // إذا كان مسجل دخول
    final user = authProvider.currentUser!;

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: cs.surface,
        body: CustomScrollView(
          slivers: [
            // App Bar احترافي مع خلفية متدرجة
            _buildProfessionalAppBar(cs, l10n),

            // بطاقة الملف الشخصي المحسنة
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                    child: _ProfessionalProfileCard(
                      user: user,
                      onEdit: () => context.push('/edit-profile'),
                      onPhotoTap: _onChangeProfilePhoto,
                      isPhotoLoading: _isUploadingPhoto,
                    ),
                  ),
                ),
              ),
            ),

            // إحصائيات متقدمة
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: _buildAdvancedStats(context, cs, user, l10n),
                  ),
                ),
              ),
            ),

            // قائمة الإعدادات المحسنة
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: _buildSettingsSection(cs, authProvider, l10n),
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalAppBar(ColorScheme cs, AppLocalizations l10n) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 130,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final t = ((constraints.biggest.height - kToolbarHeight) /
                  (130 - kToolbarHeight))
              .clamp(0.0, 1.0);

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  cs.primary.withOpacity(0.85),
                  cs.secondary.withOpacity(0.6),
                  cs.surface.withOpacity(0.0),
                ],
              ),
            ),
            child: FlexibleSpaceBar(
              centerTitle: false,
              titlePadding:
                  const EdgeInsetsDirectional.only(start: 20, bottom: 12),
              title: Opacity(
                opacity: 0.7 + (0.3 * (1 - t)),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.myAccount,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.manageYourDataAndOrders,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAdvancedStats(BuildContext context, ColorScheme cs,
      UserModel user, AppLocalizations l10n) {
    return StreamBuilder<List<OrderModel>>(
      stream: OrderService.getCustomerOrders(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const _ProfileStatsSkeleton();
        }

        final orders = snapshot.data ?? [];
        final totalOrdersCount = orders.length;
        final activeOrdersCount = orders
            .where((o) =>
                o.status == OrderStatus.pending ||
                o.status == OrderStatus.accepted ||
                o.status == OrderStatus.inProgress)
            .length;
        final completedOrdersCount =
            orders.where((o) => o.status == OrderStatus.completed).length;
        final cancelledOrdersCount = orders
            .where((o) =>
                o.status == OrderStatus.rejected ||
                o.status == OrderStatus.cancelled)
            .length;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                cs.surface,
                cs.surfaceContainerHighest.withOpacity(0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.analytics_rounded,
                    color: cs.primary,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.myStatistics,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _AdvancedStatCard(
                      icon: Icons.list_alt_rounded,
                      label: l10n.totalOrders,
                      value: totalOrdersCount.toString(),
                      subtitle: l10n.allOrdersMade,
                      color: cs.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _AdvancedStatCard(
                      icon: Icons.timelapse_rounded,
                      label: l10n.activeOrders,
                      value: activeOrdersCount.toString(),
                      subtitle: l10n.currentlyTracking,
                      color: cs.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _AdvancedStatCard(
                      icon: Icons.check_circle_rounded,
                      label: l10n.completedOrders,
                      value: completedOrdersCount.toString(),
                      subtitle: l10n.successfullyDelivered,
                      color: cs.tertiary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _AdvancedStatCard(
                      icon: Icons.cancel_presentation_rounded,
                      label: l10n.cancelledRejected,
                      value: cancelledOrdersCount.toString(),
                      subtitle: l10n.cancelledOrRejected,
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _FavoritesCard(
                color: cs.primary,
                l10n: l10n,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingsSection(
      ColorScheme cs, AuthProvider authProvider, AppLocalizations l10n) {
    final isAuth =
        authProvider.isAuthenticated && authProvider.currentUser != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(l10n.infoAndAccount),
        const SizedBox(height: 12),
        _ModernNavTile(
          icon: Icons.person_outline_rounded,
          title: l10n.personalInfo,
          subtitle: l10n.editNameAndPhone,
          onTap: () {
            if (isAuth) {
              context.push('/edit-profile');
            } else {
              _snack(l10n.pleaseLoginFirst);
            }
          },
        ),
        _ModernNavTile(
          icon: Icons.shopping_bag_rounded,
          title: l10n.myOrders,
          subtitle: l10n.viewAndTrackOrders,
          onTap: () {
            if (isAuth) {
              context.push('/app/orders');
            } else {
              _snack(l10n.pleaseLoginFirst);
            }
          },
        ),
        _ModernNavTile(
          icon: Icons.favorite_rounded,
          title: l10n.favorites,
          subtitle: l10n.viewFavoriteProducts,
          onTap: () {
            if (isAuth) {
              context.push('/favorites');
            } else {
              _snack(l10n.pleaseLoginFirst);
            }
          },
        ),
        _ModernNavTile(
          icon: Icons.location_on_outlined,
          title: l10n.myAddresses,
          subtitle: l10n.manageSavedAddresses,
          onTap: () {
            if (isAuth) {
              context.push('/app/addresses');
            } else {
              _snack(l10n.pleaseLoginFirst);
            }
          },
        ),
        const SizedBox(height: 20),
        _SectionHeader(l10n.settings),
        const SizedBox(height: 12),
        _ModernNavTile(
          icon: Icons.settings_rounded,
          title: l10n.settings,
          subtitle: l10n.notificationsAndOffers,
          onTap: () => context.push('/app/settings'),
        ),
        _ModernNavTile(
          icon: Icons.language_rounded,
          title: l10n.language,
          subtitle: l10n.appLanguage,
          onTap: () => context.push('/app/language'),
        ),
        _ModernNavTile(
          icon: Icons.credit_card_rounded,
          title: l10n.paymentMethods,
          subtitle: l10n.manageCardsAndPayment,
          onTap: () => context.push('/app/payment-methods'),
        ),
        _ModernNavTile(
          icon: Icons.security_rounded,
          title: l10n.privacyAndSecurity,
          subtitle: l10n.securityAndPrivacySettings,
          onTap: () => context.push('/app/privacy-security'),
        ),
        const SizedBox(height: 20),
        _SectionHeader(l10n.helpAndSupport),
        const SizedBox(height: 12),
        _ModernNavTile(
          icon: Icons.help_outline_rounded,
          title: l10n.helpCenter,
          subtitle: l10n.faqAndSupport,
          onTap: () => context.push('/app/help-support'),
        ),
        _ModernNavTile(
          icon: Icons.info_outline_rounded,
          title: l10n.aboutApp,
          subtitle: l10n.appVersionAndInfo,
          onTap: () => context.push('/app/about'),
        ),
        const SizedBox(height: 20),
        _ModernDangerTile(
          title: l10n.logout,
          subtitle: l10n.logoutFromAccount,
          onTap: () =>
              _confirmLogout(context, context.read<AuthProvider>(), l10n),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  // واجهة تسجيل الدخول الاحترافية
  Widget _buildLoginPrompt(
      BuildContext context, ColorScheme cs, AppLocalizations l10n, bool isRtl) {
    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: Stack(
          children: [
            // خلفية متدرجة احترافية
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF1A1A2E),
                    Color(0xFF16213E),
                    Color(0xFF0F3460),
                  ],
                ),
              ),
            ),
            // نمط دوائر ديكورية
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      cs.primary.withOpacity(0.3),
                      cs.primary.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -50,
              left: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      cs.tertiary.withOpacity(0.2),
                      cs.tertiary.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
            // المحتوى الرئيسي
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      children: [
                        const SizedBox(height: 60),
                        // الأفاتار الاحترافي
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            // الحلقة الخارجية المتوهجة
                            Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: SweepGradient(
                                  colors: [
                                    cs.primary,
                                    cs.tertiary,
                                    cs.secondary,
                                    cs.primary,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: cs.primary.withOpacity(0.4),
                                    blurRadius: 30,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                            ),
                            // الدائرة الداخلية
                            Container(
                              width: 125,
                              height: 125,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF2D2D44),
                                    Color(0xFF1A1A2E),
                                  ],
                                ),
                              ),
                              child: Icon(
                                Icons.person_rounded,
                                size: 55,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),

                        // العنوان الرئيسي
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Colors.white, Colors.white70],
                          ).createShader(bounds),
                          child: Text(
                            l10n.welcomeTitle,
                            style: Theme.of(context)
                                .textTheme
                                .headlineLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.joinUsAndEnjoy,
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.white60,
                                    height: 1.6,
                                  ),
                        ),
                        const SizedBox(height: 40),

                        // مميزات التطبيق
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          child: Column(
                            children: [
                              _buildFeatureItem(
                                icon: Icons.local_shipping_outlined,
                                title: l10n.fastDelivery,
                                subtitle: l10n.toAllOman,
                                color: const Color(0xFF4CAF50),
                              ),
                              const SizedBox(height: 16),
                              _buildFeatureItem(
                                icon: Icons.verified_outlined,
                                title: l10n.guaranteedQuality,
                                subtitle: l10n.originalProducts100,
                                color: const Color(0xFF2196F3),
                              ),
                              const SizedBox(height: 16),
                              _buildFeatureItem(
                                icon: Icons.support_agent_outlined,
                                title: l10n.continuousSupport,
                                subtitle: l10n.customerService247,
                                color: const Color(0xFFFF9800),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),

                        // زر تسجيل الدخول
                        Container(
                          width: double.infinity,
                          height: 58,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              colors: [cs.primary, cs.tertiary],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: cs.primary.withOpacity(0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () => context.push('/login'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.login_rounded,
                                    color: Colors.white),
                                const SizedBox(width: 10),
                                Text(
                                  l10n.login,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // زر إنشاء حساب
                        Container(
                          width: double.infinity,
                          height: 58,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: TextButton(
                            onPressed: () => context.push('/signup'),
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.person_add_alt_1_rounded,
                                    color: Colors.white.withOpacity(0.9)),
                                const SizedBox(width: 10),
                                Text(
                                  l10n.createNewAccount,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: Colors.white.withOpacity(0.9),
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // تصفح كزائر
                        TextButton(
                          onPressed: () => context.push('/welcome'),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                l10n.browseAsGuest,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                isRtl
                                    ? Icons.arrow_back_ios_rounded
                                    : Icons.arrow_forward_ios_rounded,
                                size: 14,
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // عنصر ميزة في قائمة المميزات
  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        Icon(
          Icons.check_circle_rounded,
          color: color.withOpacity(0.7),
          size: 20,
        ),
      ],
    );
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(milliseconds: 900),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, AuthProvider authProvider,
      AppLocalizations l10n) async {
    final localeProvider = context.read<LocaleProvider>();
    final isRtl = localeProvider.locale?.languageCode == 'ar';

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(Icons.logout_rounded, color: Colors.red),
              const SizedBox(width: 8),
              Text(l10n.confirmLogout),
            ],
          ),
          content: Text(l10n.logoutConfirmation),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(l10n.logout),
            ),
          ],
        ),
      ),
    );

    if (ok == true && mounted) {
      await authProvider.signOut();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(l10n.logoutSuccess),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        context.go('/welcome');
      }
    }
  }
}

/* ===================== Widgets احترافية ===================== */

class _ProfessionalProfileCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onEdit;
  final VoidCallback? onPhotoTap;
  final bool isPhotoLoading;

  const _ProfessionalProfileCard({
    required this.user,
    required this.onEdit,
    this.onPhotoTap,
    this.isPhotoLoading = false,
  });

  String _initials() {
    final parts = user.name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final s = parts.first;
      return s.length >= 2 ? s.substring(0, 2).toUpperCase() : s.toUpperCase();
    }
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final avatar = ClipOval(
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: cs.primaryContainer.withOpacity(0.5),
          boxShadow: [
            BoxShadow(
              color: cs.primary.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: isPhotoLoading
            ? const Center(
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              )
            : (user.photoUrl != null && user.photoUrl!.isNotEmpty)
                ? CachedNetworkImage(
                    imageUrl: user.photoUrl!,
                    fit: BoxFit.cover,
                    width: 80,
                    height: 80,
                    placeholder: (_, __) => Center(
                      child: Text(
                        _initials(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: cs.primary,
                        ),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Center(
                      child: Text(
                        _initials(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: cs.primary,
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      _initials(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: cs.primary,
                      ),
                    ),
                  ),
      ),
    );

    final avatarWithTap = onPhotoTap == null
        ? avatar
        : GestureDetector(
            onTap: isPhotoLoading ? null : onPhotoTap,
            child: Stack(
              alignment: Alignment.center,
              children: [
                avatar,
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: cs.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: cs.surface, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      size: 16,
                      color: cs.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          );

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.surface,
            cs.surfaceContainerHighest.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          avatarWithTap,
          const SizedBox(width: 20),

          // معلومات المستخدم المحسنة
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: TextStyle(
                    color: cs.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 6),

                // شارة الدور
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: cs.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified_user_rounded,
                        size: 16,
                        color: cs.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        user.role.displayName,
                        style: TextStyle(
                          color: cs.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // معلومات الاتصال
                if (user.phoneNumber != null) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.phone_rounded,
                        size: 16,
                        color: cs.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        user.phoneNumber!,
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],

                Row(
                  children: [
                    Icon(
                      Icons.email_rounded,
                      size: 16,
                      color: cs.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        user.email,
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // زر التعديل المحسن
          Container(
            decoration: BoxDecoration(
              color: cs.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: onEdit,
              icon: Icon(
                Icons.edit_rounded,
                color: cs.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdvancedStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String subtitle;
  final Color color;

  const _AdvancedStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// بطاقة المفضلة مع البيانات الحقيقية من Firebase
class _FavoritesCard extends StatelessWidget {
  final Color color;
  final AppLocalizations l10n;

  const _FavoritesCard({required this.color, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: FavoriteService().getUserFavorites(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const _FavoritesCardSkeleton();
        }
        final favoritesCount = snapshot.data?.length ?? 0;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.outlineVariant.withOpacity(0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.favorite_rounded,
                      color: color,
                      size: 20,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    favoritesCount.toString(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                l10n.favorites,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                l10n.favoriteProducts,
                style: TextStyle(
                  fontSize: 12,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FavoritesCardSkeleton extends StatelessWidget {
  const _FavoritesCardSkeleton();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SkeletonCircle(size: 36),
              Spacer(),
              SkeletonLine(width: 40, height: 20),
            ],
          ),
          SizedBox(height: 10),
          SkeletonLine(width: 80, height: 14),
          SizedBox(height: 6),
          SkeletonLine(width: 120, height: 12),
        ],
      ),
    );
  }
}

class _ProfileStatsSkeleton extends StatelessWidget {
  const _ProfileStatsSkeleton();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonLine(width: 120, height: 20),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SkeletonContainer(
                  height: 110,
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: SkeletonContainer(
                  height: 110,
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SkeletonContainer(
                  height: 110,
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: SkeletonContainer(
                  height: 110,
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          SkeletonContainer(
            height: 90,
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet لاختيار مصدر الصورة (معرض / كاميرا)
class _PhotoSourceBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.changeProfilePhoto,
                style: tt.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.photo_library_rounded, color: cs.primary),
                ),
                title: Text(l10n.chooseFromGallery),
                subtitle: Text(l10n.chooseFromGallery),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.camera_alt_rounded, color: cs.primary),
                ),
                title: Text(l10n.takePhoto),
                subtitle: Text(l10n.useCamera),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: cs.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: cs.onSurface,
          ),
        ),
      ],
    );
  }
}

class _ModernNavTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _ModernNavTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cs.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: cs.primary,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 12,
                  color: cs.onSurfaceVariant,
                ),
              )
            : null,
        trailing: Icon(
          Icons.chevron_left_rounded,
          color: cs.onSurfaceVariant,
        ),
        onTap: onTap,
      ),
    );
  }
}

class _ModernDangerTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _ModernDangerTile({
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.logout_rounded,
            color: Colors.red,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.red,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red.withOpacity(0.7),
                ),
              )
            : null,
        trailing: const Icon(
          Icons.chevron_left_rounded,
          color: Colors.red,
        ),
        onTap: onTap,
      ),
    );
  }
}
