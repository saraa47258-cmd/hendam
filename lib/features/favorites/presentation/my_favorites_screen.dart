// lib/features/favorites/presentation/my_favorites_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../services/favorite_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../shared/widgets/any_image.dart';

class MyFavoritesScreen extends StatelessWidget {
  const MyFavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final authProvider = Provider.of<AuthProvider>(context, listen: true);

    // إذا لم يكن مسجل دخول
    if (!authProvider.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('المفضلة')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite_border, size: 64, color: cs.onSurfaceVariant),
              const SizedBox(height: 16),
              Text(
                'يرجى تسجيل الدخول',
                style: tt.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'عرض المنتجات المفضلة لديك',
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => context.push('/login'),
                icon: const Icon(Icons.login),
                label: const Text('تسجيل الدخول'),
              ),
            ],
          ),
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: cs.surface,
        appBar: AppBar(
          title: const Text('المفضلة'),
          actions: [
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: FavoriteService().getUserFavorites(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Center(
                      child: Text(
                        '${snapshot.data!.length}',
                        style: tt.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: StreamBuilder<List<Map<String, dynamic>>>(
          stream: FavoriteService().getUserFavorites(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: cs.error),
                    const SizedBox(height: 16),
                    Text('حدث خطأ في تحميل المفضلات', style: tt.titleMedium),
                    const SizedBox(height: 8),
                    Text(snapshot.error.toString(), style: tt.bodySmall),
                  ],
                ),
              );
            }

            final favorites = snapshot.data ?? [];

            if (favorites.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite_border,
                        size: 80, color: cs.onSurfaceVariant),
                    const SizedBox(height: 24),
                    Text(
                      'لا توجد مفضلات حالياً',
                      style:
                          tt.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ابدأ بإضافة منتجات للمفضلة',
                      style:
                          tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final favorite = favorites[index];
                return _FavoriteItemCard(
                  favorite: favorite,
                  onRemove: () async {
                    final removed = await FavoriteService().removeFromFavorites(
                      productId: favorite['productId'],
                      productType: favorite['productType'],
                    );
                    if (removed && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم إزالة من المفضلة'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _FavoriteItemCard extends StatelessWidget {
  final Map<String, dynamic> favorite;
  final VoidCallback onRemove;

  const _FavoriteItemCard({
    required this.favorite,
    required this.onRemove,
  });

  bool get _isTailor => favorite['productType'] == 'tailor';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final productData = favorite['productData'] as Map<String, dynamic>? ?? {};

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
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
          // صورة المنتج/الخياط
          ClipRRect(
            borderRadius: const BorderRadiusDirectional.only(
              topStart: Radius.circular(16),
              bottomStart: Radius.circular(16),
            ),
            child: AnyImage(
              src: productData['imageUrl'] ?? '',
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          // معلومات المنتج/الخياط
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          productData['name'] ?? 'عنصر',
                          style: tt.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (_isTailor)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: cs.primaryContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'خياط',
                            style: tt.labelSmall?.copyWith(
                              color: cs.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // للمنتجات العادية
                  if (!_isTailor && productData['type'] != null)
                    Text(
                      productData['type'],
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  // للخياط: المدينة
                  if (_isTailor && productData['city'] != null) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: cs.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          productData['city'],
                          style: tt.bodySmall
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ],
                  // للخياط: التقييم
                  if (_isTailor && productData['rating'] != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rate_rounded,
                          size: 16,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          productData['rating'],
                          style: tt.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  // السعر للمنتجات العادية
                  if (!_isTailor && productData['price'] != null)
                    Text(
                      'ر.ع ${(productData['price'] as num).toStringAsFixed(3)}',
                      style: tt.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.primary,
                      ),
                    ),
                ],
              ),
            ),
          ),
          // زر الإزالة
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.favorite, color: Colors.red),
            tooltip: 'إزالة من المفضلة',
          ),
        ],
      ),
    );
  }
}
