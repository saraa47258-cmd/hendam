import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hindam/core/services/firebase_service.dart';
import '../../tailors/widgets/tailor_row_card.dart';
import '../../tailors/models/tailor.dart';
import '../../tailors/presentation/tailor_store_screen.dart'; // صفحة الخدمات/التفصيل
import '../../tailors/presentation/tailor_shop_screen.dart'; // صفحة المتجر الجديدة
import 'package:hindam/shared/widgets/skeletons.dart';

class MenServicesScreen extends StatefulWidget {
  const MenServicesScreen({super.key});

  /// اسم المسار ليتوافق مع Navigator تبويب "الرئيسية"
  static const String routeName = '/men';

  @override
  State<MenServicesScreen> createState() => _MenServicesScreenState();
}

class _MenServicesScreenState extends State<MenServicesScreen> {
  bool _isRefreshing = false;

  // دالة التحديث اليدوي
  Future<void> _refreshTailors() async {
    if (_isRefreshing) return;

    setState(() => _isRefreshing = true);

    try {
      // إعادة تحميل البيانات من Firebase
      await FirebaseService.refreshData();
      
      // محاولة جلب البيانات مباشرة
      final snapshot = await FirebaseService.getTailorsQuery().get();
      final count = snapshot.docs.length;
      
      print('📊 عدد المحلات بعد التحديث: $count');
      
      if (count == 0) {
        print('⚠️ لا توجد محلات في collection "tailors"');
        print('💡 تأكد من:');
        print('   1. وجود collection باسم "tailors" في Firestore');
        print('   2. وجود محلات مع isActive: true');
        print('   3. وجود index للـ query (where + orderBy)');
      }

      // إظهار رسالة نجاح
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم تحديث قائمة المحلات بنجاح (عدد المحلات: $count)'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e, stackTrace) {
      print('❌ خطأ في تحديث المحلات: $e');
      print('📍 Stack trace: $stackTrace');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في تحديث القائمة: ${e.toString()}'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  // محوّل وثيقة فايرستور إلى صف واجهة العرض
  _ShopRowData _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    try {
      final data = doc.data() ?? {};
      Map<String, dynamic> asMap(dynamic v) =>
          v is Map<String, dynamic> ? v : <String, dynamic>{};
      final profile = asMap(data['profile']);
      final services = asMap(data['services']);
      final location = asMap(data['location']);
      final business = asMap(data['business']);

      // استخراج اسم المحل (وليس اسم صاحب المحل)
      // الأولوية: services.shopName > business.shopName > shopName > name (وليس ownerName)
      final name =
          (services['shopName'] ?? 
           business['shopName'] ??
           data['shopName'] ??
           data['name'] ?? 
           'متجر').toString();
      final cityOrAddress =
          (location['city'] ?? 
           location['address'] ?? 
           data['city'] ?? 
           '').toString();
      final rating =
          (data['rating'] is num) ? (data['rating'] as num).toDouble() : 0.0;
      final specialization = (services['specialization'] ?? 
                              data['specialization'] ?? 
                              '').toString().trim();

      return _ShopRowData(
        tailor: Tailor(
          id: doc.id,
          name: name,
          city: cityOrAddress.isEmpty ? '—' : cityOrAddress,
          rating: rating,
          tags: specialization.isEmpty ? const [] : [specialization],
        ),
        imageUrl: (profile['avatar'] ?? 
                   data['avatar'] ?? 
                   data['imageUrl'] ?? 
                   '').toString(),
        badge: specialization.isEmpty ? null : specialization,
        reviewsCount: (services['totalOrders'] is num)
            ? (services['totalOrders'] as num).toInt()
            : ((data['totalOrders'] is num) ? (data['totalOrders'] as num).toInt() : null),
        serviceFeeOMR: null,
        etaMinutes: null,
      );
    } catch (e) {
      print('❌ خطأ في تحويل وثيقة المحل: ${doc.id} - $e');
      // إرجاع بيانات افتراضية في حالة الخطأ
      return _ShopRowData(
        tailor: Tailor(
          id: doc.id,
          name: 'متجر',
          city: '—',
          rating: 0.0,
          tags: const [],
        ),
        imageUrl: null,
        badge: null,
        reviewsCount: null,
        serviceFeeOMR: null,
        etaMinutes: null,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: cs.surface,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xFF0EA5E9), // لون سماوي للخياطة الرجالية
          surfaceTintColor: Colors.transparent,
          leading: CupertinoButton(
            padding: EdgeInsets.zero,
            minSize: 0,
            onPressed: () => Navigator.maybePop(context),
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                CupertinoIcons.back,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
          leadingWidth: 56,
          title: const Text(
            '',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              minSize: 0,
              onPressed: () {},
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  CupertinoIcons.search,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            CupertinoSliverRefreshControl(
              onRefresh: _refreshTailors,
            ),
            // العنوان الرئيسي
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 12),
                child: Text(
                  'الخياطة الرجالية',
                  style: TextStyle(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.3,
                    fontSize: 28,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const _DealBannerMen(),
                  const SizedBox(height: 12),
                  _FiltersBarMen(
                    onRefresh: _refreshTailors,
                    isRefreshing: _isRefreshing,
                  ),
                  const SizedBox(height: 12),

                  // القائمة من فايرستور مع تحديث تلقائي محسّن
                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseService.getTailorsQuery()
                        .snapshots(includeMetadataChanges: false),
                    builder: (context, snapshot) {
                      // معالجة محسّنة للحالات المختلفة
                      if (snapshot.connectionState == ConnectionState.waiting &&
                          !snapshot.hasData) {
                        return const _TailorSkeletonList();
                      }

                      if (snapshot.hasError) {
                        print('❌ خطأ في جلب محلات الخياطة: ${snapshot.error}');
                        print('📍 Stack trace: ${snapshot.stackTrace}');
                        return _ErrorBox(
                          message: 'تعذر تحميل محلات الخياطة: ${snapshot.error}',
                          onRetry: _refreshTailors,
                        );
                      }

                      final docs = snapshot.data?.docs ?? const [];
                      
                      // Debug: طباعة عدد المستندات
                      print('📊 عدد محلات الخياطة: ${docs.length}');
                      
                      if (docs.isEmpty) {
                        print('⚠️ لا توجد محلات في collection "tailors"');
                        return _EmptyBox(
                          message: 'لا توجد محلات مسجلة حالياً',
                          onRefresh: _refreshTailors,
                        );
                      }

                      final items = docs.map(_fromDoc).toList();
                      return Column(
                        children: items
                            .map(
                              (e) => Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: TailorRowCard(
                                  tailor: e.tailor,
                                  reviewsCount: e.reviewsCount,
                                  serviceFeeOMR: e.serviceFeeOMR,
                                  etaMinutes: e.etaMinutes,
                                  badge: e.badge,
                                  imageUrl: e.imageUrl,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                        builder: (_) => TailorStoreScreen(
                                          tailorId: e.tailor.id,
                                          tailorName: e.tailor.name,
                                          imageUrl: e.imageUrl,
                                          reviewsCount: e.reviewsCount,
                                          serviceFeeOMR: e.serviceFeeOMR,
                                        ),
                                      ),
                                    );
                                  },
                                  onStoreTap: () {
                                    Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                        builder: (_) => TailorShopScreen(
                                          tailor: e.tailor,
                                          imageUrl: e.imageUrl,
                                          reviewsCount: e.reviewsCount,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// بانر العروض أعلى القائمة
class _DealBannerMen extends StatefulWidget {
  const _DealBannerMen();

  @override
  State<_DealBannerMen> createState() => _DealBannerMenState();
}

class _DealBannerMenState extends State<_DealBannerMen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _shimmerAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1A237E), // أزرق داكن
                  Color(0xFF283593),
                  Color(0xFF3949AB),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1A237E).withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                // دوائر ديكورية
                Positioned(
                  top: -40,
                  right: -30,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.08),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -50,
                  left: -20,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.06),
                    ),
                  ),
                ),
                // أيقونة المقص الكبيرة
                Positioned(
                  left: 15,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Icon(
                      Icons.content_cut_rounded,
                      size: 80,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ),
                // تأثير لامع متحرك
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: _shimmerAnimation.value * 400 - 100,
                  width: 80,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0),
                          Colors.white.withOpacity(0.15),
                          Colors.white.withOpacity(0),
                        ],
                      ),
                    ),
                  ),
                ),
                // المحتوى
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // شارة العرض
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6D00).withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF6D00).withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.local_fire_department_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'عرض حصري',
                              style: tt.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // العنوان الرئيسي
                      RichText(
                        text: TextSpan(
                          style: tt.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 1.2,
                          ),
                          children: const [
                            TextSpan(text: 'وفّر حتى '),
                            TextSpan(
                              text: '٣ ر.ع',
                              style: TextStyle(
                                color: Color(0xFFFFD54F),
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            TextSpan(text: '\nعلى خياطة الدشداشة'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // الوصف
                      Text(
                        'اكتشف محلات جديدة أو جرّب خياطين ما طلبت منهم من فترة',
                        style: tt.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                      const SizedBox(height: 14),
                      // صف الزر والمؤقت
                      Row(
                        children: [
                          // زر اكتشف الآن
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'اكتشف الآن',
                                  style: tt.labelLarge?.copyWith(
                                    color: const Color(0xFF1A237E),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 18,
                                  color: Color(0xFF1A237E),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          // المؤقت
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.timer_outlined,
                                  size: 16,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '14:43',
                                  style: tt.labelLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
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

/// شريط فلاتر بسيط مع إمكانية التحديث اليدوي
class _FiltersBarMen extends StatelessWidget {
  final VoidCallback? onRefresh;
  final bool isRefreshing;

  const _FiltersBarMen({
    this.onRefresh,
    this.isRefreshing = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    Widget chip(String label, {IconData? icon}) {
      return RepaintBoundary(
        child: CupertinoButton(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          minSize: 0,
          onPressed: () {},
          color: cs.surface,
          borderRadius: BorderRadius.circular(20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: cs.onSurfaceVariant),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: tt.labelLarge?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (icon == null) ...[
                const SizedBox(width: 4),
                Icon(Icons.expand_more, size: 18, color: cs.onSurfaceVariant),
              ],
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          chip('4.0+ تقييم', icon: Icons.star_rate_rounded),
          const SizedBox(width: 8),
          chip('الأقسام'),
          const SizedBox(width: 8),
          chip('رتّب حسب'),
          const SizedBox(width: 8),
          // زر التحديث اليدوي
          if (onRefresh != null)
            RepaintBoundary(
              child: CupertinoButton(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                minSize: 0,
                onPressed: isRefreshing ? null : onRefresh,
                color: cs.surface,
                borderRadius: BorderRadius.circular(20),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isRefreshing)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CupertinoActivityIndicator(radius: 8),
                      )
                    else
                      const Icon(Icons.refresh, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      isRefreshing ? 'جاري التحديث...' : 'تحديث',
                      style: tt.labelLarge?.copyWith(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w500,
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

class _ErrorBox extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const _ErrorBox({
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.errorContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.error),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: cs.error),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(color: cs.onErrorContainer),
                ),
              ),
            ],
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.error,
                foregroundColor: cs.onError,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyBox extends StatelessWidget {
  final String message;
  final VoidCallback? onRefresh;

  const _EmptyBox({
    required this.message,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message),
          if (onRefresh != null) ...[
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('تحديث القائمة'),
            ),
          ],
        ],
      ),
    );
  }
}

/// هياكل تحميل (Skeleton) تعرض بطاقة متجر بشكل وهمي أثناء انتظار البيانات
class _TailorSkeletonList extends StatelessWidget {
  const _TailorSkeletonList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (index) => const _TailorSkeletonCard(),
      ),
    );
  }
}

class _TailorSkeletonCard extends StatelessWidget {
  const _TailorSkeletonCard();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        const double imageSize = 76.0;
        const double horizontalPadding = 16.0;
        const double spacing = 12.0;
        final double textWidth =
            (constraints.maxWidth - imageSize - horizontalPadding * 2 - spacing)
                .clamp(0.0, constraints.maxWidth);

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: cs.outlineVariant.withOpacity(0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(horizontalPadding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: const SizedBox(
                  width: imageSize,
                  height: imageSize,
                  child: SkeletonContainer(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(width: spacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLine(width: textWidth * 0.6, height: 18),
                    const SizedBox(height: 12),
                    SkeletonLine(width: textWidth * 0.35, height: 14),
                    const SizedBox(height: 10),
                    SkeletonLine(width: textWidth * 0.7, height: 14),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        SkeletonLine(
                          width: textWidth * 0.25,
                          height: 24,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        const SizedBox(width: 8),
                        SkeletonLine(
                          width: textWidth * 0.18,
                          height: 24,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// نموذج بيانات داخلي يمثل كل صف في القائمة
class _ShopRowData {
  final Tailor tailor;
  final String? imageUrl; // أصل أو رابط
  final String? badge;
  final int? reviewsCount;
  final double? serviceFeeOMR;
  final RangeValues? etaMinutes;

  _ShopRowData({
    required this.tailor,
    this.imageUrl,
    this.badge,
    this.reviewsCount,
    this.serviceFeeOMR,
    this.etaMinutes,
  });
}
