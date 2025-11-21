// lib/features/profile/presentation/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:hindam/features/auth/providers/auth_provider.dart';
import 'package:hindam/features/auth/models/user_model.dart';
import 'package:hindam/features/favorites/services/favorite_service.dart';
import 'package:hindam/features/orders/services/order_service.dart';
import 'package:hindam/features/orders/models/order_model.dart';
import 'package:hindam/shared/widgets/skeletons.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  bool _notifEnabled = true;
  bool _offersEnabled = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final authProvider = context.watch<AuthProvider>();

    // إذا لم يكن مسجل دخول
    if (!authProvider.isAuthenticated) {
      return _buildLoginPrompt(context, cs);
    }

    // إذا كان مسجل دخول
    final user = authProvider.currentUser!;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: cs.surface,
        body: CustomScrollView(
          slivers: [
            // App Bar احترافي مع خلفية متدرجة
            _buildProfessionalAppBar(cs),

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
                    child: _buildAdvancedStats(context, cs, user),
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
                      child: _buildSettingsSection(cs, authProvider),
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

  Widget _buildProfessionalAppBar(ColorScheme cs) {
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
                    const Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'حسابي',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'إدارة بياناتك وطلباتك',
                          style: TextStyle(
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

  Widget _buildAdvancedStats(
      BuildContext context, ColorScheme cs, UserModel user) {
    return StreamBuilder<List<OrderModel>>(
      stream: OrderService.getCustomerOrders(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const _ProfileStatsSkeleton();
        }

        final orders = snapshot.data ?? [];
        final totalOrders = orders.length;
        final activeOrders = orders
            .where((o) =>
                o.status == OrderStatus.pending ||
                o.status == OrderStatus.accepted ||
                o.status == OrderStatus.inProgress)
            .length;
        final completedOrders =
            orders.where((o) => o.status == OrderStatus.completed).length;
        final cancelledOrders = orders
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
                    'إحصائياتي',
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
                      label: 'إجمالي الطلبات',
                      value: totalOrders.toString(),
                      subtitle: 'كل الطلبات التي قمت بها',
                      color: cs.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _AdvancedStatCard(
                      icon: Icons.timelapse_rounded,
                      label: 'طلبات نشطة',
                      value: activeOrders.toString(),
                      subtitle: 'قيد المتابعة حالياً',
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
                      label: 'طلبات مكتملة',
                      value: completedOrders.toString(),
                      subtitle: 'تم تسليمها بنجاح',
                      color: cs.tertiary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _AdvancedStatCard(
                      icon: Icons.cancel_presentation_rounded,
                      label: 'ملغاة / مرفوضة',
                      value: cancelledOrders.toString(),
                      subtitle: 'تم إلغاؤها أو رفضها',
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _FavoritesCard(
                color: cs.primary,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingsSection(ColorScheme cs, AuthProvider authProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader('الإعدادات الشخصية'),
        const SizedBox(height: 12),

        // إعدادات الإشعارات
        _ModernSwitchTile(
          icon: Icons.notifications_active_rounded,
          title: 'الإشعارات',
          subtitle: 'تنبيهات حالة الطلب والعروض',
          value: _notifEnabled,
          onChanged: (v) => setState(() => _notifEnabled = v),
        ),

        _ModernSwitchTile(
          icon: Icons.local_offer_rounded,
          title: 'عروض وتخفيضات',
          subtitle: 'استقبال العروض الحصرية',
          value: _offersEnabled,
          onChanged: (v) => setState(() => _offersEnabled = v),
        ),

        const SizedBox(height: 20),
        const _SectionHeader('إدارة الحساب'),
        const SizedBox(height: 12),

        _ModernNavTile(
          icon: Icons.shopping_bag_rounded,
          title: 'طلباتي',
          subtitle: 'عرض ومتابعة الطلبات',
          onTap: () {
            if (authProvider.isAuthenticated &&
                authProvider.currentUser != null) {
              context.pushNamed('customer-orders');
            } else {
              _snack('يرجى تسجيل الدخول أولاً');
            }
          },
        ),

        _ModernNavTile(
          icon: Icons.favorite_rounded,
          title: 'المفضلة',
          subtitle: 'عرض المنتجات المفضلة',
          onTap: () {
            if (authProvider.isAuthenticated &&
                authProvider.currentUser != null) {
              context.push('/favorites');
            } else {
              _snack('يرجى تسجيل الدخول أولاً');
            }
          },
        ),

        _ModernNavTile(
          icon: Icons.location_on_outlined,
          title: 'عناويني',
          subtitle: 'إدارة العناوين المحفوظة',
          onTap: () {
            if (authProvider.isAuthenticated &&
                authProvider.currentUser != null) {
              context.pushNamed('addresses');
            } else {
              _snack('يرجى تسجيل الدخول أولاً');
            }
          },
        ),

        _ModernNavTile(
          icon: Icons.credit_card_rounded,
          title: 'طرق الدفع',
          subtitle: 'إدارة البطاقات والدفع',
          onTap: () => _snack('فتح طرق الدفع'),
        ),

        _ModernNavTile(
          icon: Icons.security_rounded,
          title: 'الخصوصية والأمان',
          subtitle: 'إعدادات الأمان والخصوصية',
          onTap: () => _snack('فتح إعدادات الخصوصية'),
        ),

        const SizedBox(height: 20),
        const _SectionHeader('المساعدة والدعم'),
        const SizedBox(height: 12),

        _ModernNavTile(
          icon: Icons.help_outline_rounded,
          title: 'مركز المساعدة',
          subtitle: 'الأسئلة الشائعة والدعم',
          onTap: () => _snack('فتح مركز المساعدة'),
        ),

        _ModernNavTile(
          icon: Icons.info_outline_rounded,
          title: 'عن التطبيق',
          subtitle: 'إصدار التطبيق ومعلومات إضافية',
          onTap: () => _snack('فتح نبذة التطبيق'),
        ),

        const SizedBox(height: 20),

        // زر تسجيل الخروج المحسن
        _ModernDangerTile(
          title: 'تسجيل الخروج',
          subtitle: 'إنهاء الجلسة الحالية',
          onTap: () => _confirmLogout(context, context.read<AuthProvider>()),
        ),

        const SizedBox(height: 30),
      ],
    );
  }

  // واجهة تسجيل الدخول المحسنة
  Widget _buildLoginPrompt(BuildContext context, ColorScheme cs) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                cs.primary.withOpacity(0.1),
                cs.secondary.withOpacity(0.05),
                cs.tertiary.withOpacity(0.1),
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32.0),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // أيقونة محسنة
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                cs.primary,
                                cs.secondary,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: cs.primary.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.person_outline_rounded,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // العنوان المحسن
                        Text(
                          'مرحباً بك!',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: cs.onSurface,
                              ),
                        ),
                        const SizedBox(height: 12),

                        // الوصف المحسن
                        Text(
                          'سجل دخولك للوصول إلى حسابك\nومتابعة طلباتك ومفضلاتك',
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: cs.onSurface.withOpacity(0.7),
                                  ),
                        ),
                        const SizedBox(height: 48),

                        // زر تسجيل الدخول المحسن
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: () => context.push('/login'),
                            icon: const Icon(Icons.login_rounded),
                            label: const Text('تسجيل الدخول'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: cs.primary,
                              foregroundColor: cs.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 8,
                              shadowColor: cs.primary.withOpacity(0.3),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // زر إنشاء حساب محسن
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton.icon(
                            onPressed: () => context.push('/signup'),
                            icon: const Icon(Icons.person_add_rounded),
                            label: const Text('إنشاء حساب جديد'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: cs.primary,
                              side: BorderSide(color: cs.primary, width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // روابط إضافية محسنة
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: TextButton(
                            onPressed: () => context.push('/welcome'),
                            child: const Text('عرض المزيد من الخيارات'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
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

  Future<void> _confirmLogout(
      BuildContext context, AuthProvider authProvider) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.logout_rounded, color: Colors.red),
              SizedBox(width: 8),
              Text('تأكيد تسجيل الخروج'),
            ],
          ),
          content: const Text('هل تريد تسجيل الخروج من حسابك؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء'),
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
              child: const Text('تسجيل الخروج'),
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
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('تم تسجيل الخروج بنجاح'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        context.go('/');
      }
    }
  }
}

/* ===================== Widgets احترافية ===================== */

class _ProfessionalProfileCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onEdit;

  const _ProfessionalProfileCard({
    required this.user,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    String initials() {
      final parts = user.name.trim().split(' ');
      if (parts.length == 1) return parts.first.characters.take(2).toString();
      return (parts.first.characters.first + parts.last.characters.first)
          .toUpperCase();
    }

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
          // صورة المستخدم المحسنة
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  cs.primary,
                  cs.secondary,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: cs.primary.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: Text(
                initials(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
            ),
          ),
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

  const _FavoritesCard({required this.color});

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
                'المفضلة',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'منتجات مفضلة',
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonLine(width: 120, height: 20),
          const SizedBox(height: 16),
          Row(
            children: const [
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
          const SizedBox(height: 12),
          Row(
            children: const [
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
          const SizedBox(height: 12),
          const SkeletonContainer(
            height: 90,
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ],
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

class _ModernSwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ModernSwitchTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Row(
        children: [
          Container(
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
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 12,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: cs.primary,
          ),
        ],
      ),
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
