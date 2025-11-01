import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hindam/core/services/firebase_service.dart';
import '../../tailors/widgets/tailor_row_card.dart';
import '../../tailors/models/tailor.dart';
import '../../tailors/presentation/tailor_store_screen.dart'; // صفحة الخدمات/التفصيل
import '../../tailors/presentation/tailor_shop_screen.dart'; // صفحة المتجر الجديدة

class MenServicesScreen extends StatefulWidget {
  const MenServicesScreen({super.key});

  /// اسم المسار ليتوافق مع Navigator تبويب "الرئيسية"
  static const String routeName = '/men';

  @override
  State<MenServicesScreen> createState() => _MenServicesScreenState();
}

class _MenServicesScreenState extends State<MenServicesScreen> {
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

  // محوّل وثيقة فايرستور إلى صف واجهة العرض
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
    final specialization = (services['specialization'] ?? '').toString().trim();

    return _ShopRowData(
      tailor: Tailor(
        id: doc.id,
        name: name,
        city: cityOrAddress.isEmpty ? '—' : cityOrAddress,
        rating: rating,
        tags: specialization.isEmpty ? const [] : [specialization],
      ),
      imageUrl: (profile['avatar'] ?? '').toString(),
      badge: specialization.isEmpty ? null : specialization,
      reviewsCount: (services['totalOrders'] is num)
          ? (services['totalOrders'] as num).toInt()
          : null,
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
        appBar: AppBar(
          title: const Text('الخياطة الرجالية'),
          centerTitle: true,
        ),
        body: SafeArea(
          child: RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: _refreshTailors,
            child: ListView(
              primary:
                  true, // للتمرير لأعلى عند إعادة الضغط على تبويب "الرئيسية"
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
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
                        message: 'تعذر تحميل محلات الخياطة',
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
                                    MaterialPageRoute(
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
                                    MaterialPageRoute(
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// بانر العروض أعلى القائمة
class _DealBannerMen extends StatelessWidget {
  const _DealBannerMen();

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
                TextSpan(text: ' على خياطة الدشداشة'),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'اكتشف محلات جديدة أو جرّب خياطين ما طلبت منهم من فترة',
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
                isRefreshing ? 'جاري التحديث...' : 'تحديث',
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
