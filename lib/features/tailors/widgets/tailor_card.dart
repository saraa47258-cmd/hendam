import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hindam/core/services/firebase_service.dart';
import 'package:hindam/l10n/app_localizations.dart';
import '../models/tailor.dart';
import '../presentation/tailor_details_screen.dart';
import 'package:hindam/features/favorites/widgets/favorite_button.dart';

class TailorShopsScreen extends StatefulWidget {
  const TailorShopsScreen({super.key});

  @override
  State<TailorShopsScreen> createState() => _TailorShopsScreenState();
}

class _TailorShopsScreenState extends State<TailorShopsScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  bool _isRefreshing = false;

  // دالة التحديث اليدوي
  Future<void> _refreshTailors() async {
    if (_isRefreshing) return;

    setState(() => _isRefreshing = true);

    try {
      // إعادة تحميل البيانات من Firebase
      await FirebaseService.refreshData();
      await FirebaseService.getTailorsQuery().get();

      // إظهار رسالة نجاح
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تحديث قائمة المحلات بنجاح'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
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

  /// محوّل وثيقة Firestore إلى بيانات البطاقة المستخدمة في العرض
  _ShopRowData _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    Map<String, dynamic> asMap(dynamic v) =>
        v is Map<String, dynamic> ? v : <String, dynamic>{};
    final profile = asMap(data['profile']);
    final services = asMap(data['services']);
    final location = asMap(data['location']);

    final name =
        (services['shopName'] ?? data['ownerName'] ?? 'متجر').toString();
    final cityOrAddress =
        (location['city'] ?? location['address'] ?? '').toString();
    final rating =
        (data['rating'] is num) ? (data['rating'] as num).toDouble() : 0.0;
    final tags = <String>[];
    final badge = (services['specialization'] ?? '').toString().trim();
    if (badge.isNotEmpty) tags.add(badge);

    return _ShopRowData(
      tailor: Tailor(
        id: doc.id,
        name: name,
        city: cityOrAddress.isEmpty ? '—' : cityOrAddress,
        rating: rating,
        tags: tags,
      ),
      imageUrl: (profile['avatar'] ??
              profile['profileImage'] ??
              profile['imageUrl'] ??
              '')
          .toString()
          .trim(),
      badge: badge.isEmpty ? null : badge,
      rating: rating == 0.0 ? null : rating,
      reviewsCount: (services['totalOrders'] is num)
          ? (services['totalOrders'] as num).toInt()
          : null,
      // بإمكانك لاحقًا ملء الرسوم والمدة من حقولك إن وجدت
      serviceFeeOMR: null,
      etaMinutes: null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: cs.surface,
        body: SafeArea(
          child: RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: _refreshTailors,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                const _DealBannerTailor(),
                const SizedBox(height: 12),
                _FiltersBarTailor(
                  onRefresh: _refreshTailors,
                  isRefreshing: _isRefreshing,
                ),
                const SizedBox(height: 12),
                // ===== قائمة حية من فايرستورت مع تحديث محسّن =====
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseService.getTailorsQuery(limit: 50)
                      .snapshots(includeMetadataChanges: true),
                  builder: (context, snapshot) {
                    // معالجة محسّنة للحالات المختلفة
                    if (snapshot.connectionState == ConnectionState.waiting &&
                        !snapshot.hasData) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return _ErrorBox(
                        message: 'حدث خطأ أثناء تحميل المحلات',
                        onRetry: _refreshTailors,
                      );
                    }

                    final docs = snapshot.data?.docs ?? const [];
                    if (docs.isEmpty) {
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
                              child: _TailorRowCard(
                                data: e,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => TailorDetailsScreen(
                                        tailorId: e.tailor.id,
                                        tailorName: e.tailor.name,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// بانر عروض مصمم للخياطة
class _DealBannerTailor extends StatelessWidget {
  const _DealBannerTailor();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: tt.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: cs.onSurface,
              ),
              children: const [
                TextSpan(text: 'وفّر حتى '),
                TextSpan(
                    text: '٣ ر.ع', style: TextStyle(color: Color(0xFFE65100))),
                TextSpan(text: ' على التفصيل'),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'اكتشف خياطين جدد أو جرّب محلات ما طلبت منها من فترة',
            style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Text('14:43', style: tt.labelLarge),
          ),
        ],
      ),
    );
  }
}

/// شريط فلاتر للخياطة مع إمكانية التحديث اليدوي
class _FiltersBarTailor extends StatelessWidget {
  final VoidCallback? onRefresh;
  final bool isRefreshing;

  const _FiltersBarTailor({
    this.onRefresh,
    this.isRefreshing = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    Widget chip(String label, {IconData? icon}) {
      return OutlinedButton.icon(
        onPressed: () {},
        icon: Icon(icon ?? Icons.expand_more,
            size: 18, color: cs.onSurfaceVariant),
        label: Text(label, style: tt.labelLarge?.copyWith(color: cs.onSurface)),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          side: BorderSide(color: cs.outlineVariant),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          backgroundColor: cs.surface,
        ),
      );
    }

    // محسن: استخدام Row مباشرة مع SingleChildScrollView لتجنب إعادة البناء غير الضرورية
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          chip(l10n.ratingFilterLabel, icon: Icons.star_rate_rounded),
          const SizedBox(width: 8),
          chip(l10n.categories), // رجالي، عبايات، أطفال، تعديلات…
          const SizedBox(width: 8),
          chip(l10n.sortBy),
          const SizedBox(width: 8),
          // زر التحديث اليدوي
          if (onRefresh != null)
            OutlinedButton.icon(
              onPressed: isRefreshing ? null : onRefresh,
              icon: isRefreshing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh, size: 18),
              label: Text(
                isRefreshing ? l10n.refreshing : l10n.refresh,
                style: tt.labelLarge?.copyWith(color: cs.onSurface),
              ),
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                side: BorderSide(color: cs.outlineVariant),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                backgroundColor: cs.surface,
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

/// نموذج بيانات صف واحد
class _ShopRowData {
  final Tailor tailor;
  final String? imageUrl;
  final String? badge; // رجالي/عبايات/أطفال/تعديلات
  final double? rating;
  final int? reviewsCount;
  final double? serviceFeeOMR; // رسوم خدمة/توصيل إن وجِد
  final RangeValues? etaMinutes; // زمن التجهيز (ساعات/أيام حسب نظامك)

  _ShopRowData({
    required this.tailor,
    this.imageUrl,
    this.badge,
    this.rating,
    this.reviewsCount,
    this.serviceFeeOMR,
    this.etaMinutes,
  });
}

/// صف بطاقة (صورة يمين + تفاصيل يسار) مطابق لأسلوب الصورة
class _TailorRowCard extends StatelessWidget {
  final _ShopRowData data;
  final VoidCallback? onTap;

  const _TailorRowCard({required this.data, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Material(
      color: cs.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: cs.outlineVariant),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 112,
          child: Row(
            children: [
              // النص يسار
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // الاسم + pro + التقييم + زر المفضلة
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              data.tailor.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: tt.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ),
                          const SizedBox(width: 6),
                          _ProBadge(color: cs.primary),
                          const SizedBox(width: 8),
                          // زر المفضلة
                          FavoriteButton(
                            productId: data.tailor.id,
                            productType: 'tailor',
                            productData: {
                              'name': data.tailor.name,
                              'city': data.tailor.city,
                              'rating': data.rating?.toString() ?? '0',
                              'imageUrl': data.imageUrl ?? '',
                            },
                            iconSize: 22,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (data.rating != null) ...[
                            const Icon(Icons.star_rate_rounded,
                                size: 18, color: Color(0xFFFFA000)),
                            Text(
                              data.rating!.toStringAsFixed(1),
                              style: tt.labelLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            if (data.reviewsCount != null) ...[
                              const SizedBox(width: 4),
                              Text(
                                '(+${data.reviewsCount})',
                                style: tt.bodySmall
                                    ?.copyWith(color: cs.onSurfaceVariant),
                              ),
                            ],
                          ],
                        ],
                      ),
                      const Spacer(),

                      // المدينة + الشارة
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined,
                              size: 16, color: cs.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              data.tailor.city,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: tt.bodySmall
                                  ?.copyWith(color: cs.onSurfaceVariant),
                            ),
                          ),
                          if (data.badge != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              height: 20,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                color: cs.secondaryContainer
                                    .withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                data.badge!,
                                style: tt.labelSmall
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),

                      // الرسوم + الوقت
                      Row(
                        children: [
                          if (data.serviceFeeOMR != null)
                            Text(
                              'ر.ع ${data.serviceFeeOMR!.toStringAsFixed(3)}',
                              style: tt.bodySmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          if (data.serviceFeeOMR != null &&
                              data.etaMinutes != null)
                            Text(' • ', style: tt.bodySmall),
                          if (data.etaMinutes != null) ...[
                            Text(
                              // غيّر "دقيقة" إلى "يوم/ساعة" حسب استخدامك
                              'دقيقة ${data.etaMinutes!.start.toInt()} - ${data.etaMinutes!.end.toInt()}',
                              style: tt.bodySmall,
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.access_time,
                                size: 14, color: cs.onSurfaceVariant),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // الصورة يمين
              ClipRRect(
                borderRadius: const BorderRadiusDirectional.only(
                  topStart: Radius.circular(16),
                  bottomStart: Radius.circular(16),
                ),
                child: SizedBox(
                  width: 112,
                  height: double.infinity,
                  child: _Thumb(url: data.imageUrl),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProBadge extends StatelessWidget {
  final Color color;
  const _ProBadge({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      alignment: Alignment.center,
      child: Text(
        'pro',
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(color: color, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  final String? url;
  const _Thumb({this.url});

  Widget _buildPlaceholder(BuildContext context, ColorScheme cs) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            cs.primaryContainer.withOpacity(0.3),
            cs.secondaryContainer.withOpacity(0.3),
          ],
        ),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.storefront_rounded,
        size: 36,
        color: cs.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (url == null || url!.isEmpty || url!.trim().isEmpty) {
      return _buildPlaceholder(context, cs);
    }

    return Image.network(
      url!,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildPlaceholder(context, cs),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          color: cs.surfaceContainerHighest,
          alignment: Alignment.center,
          child: const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
    );
  }
}
