// lib/features/favorites/presentation/my_favorites_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../services/favorite_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../shared/widgets/any_image.dart';
import '../../../shared/widgets/skeletons.dart';
import '../../../core/services/firebase_service.dart';

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
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(76),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  cs.primary.withOpacity(0.92),
                  cs.secondary.withOpacity(0.75),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.20),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            size: 20, color: Colors.white),
                        onPressed: () async {
                          final localNavigator = Navigator.of(context);
                          if (await localNavigator.maybePop()) return;
                          final rootNavigator =
                              Navigator.of(context, rootNavigator: true);
                          if (rootNavigator != localNavigator &&
                              await rootNavigator.maybePop()) return;
                          if (!context.mounted) return;
                          context.go('/app');
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'مفضلتي',
                            style: tt.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'تصفح وحافظ على عناصر تحبها',
                            style: tt.bodySmall?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    StreamBuilder<List<Map<String, dynamic>>>(
                      stream: FavoriteService().getUserFavorites(),
                      builder: (context, snapshot) {
                        final count =
                            snapshot.hasData ? snapshot.data!.length : 0;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.favorite_rounded,
                                  size: 18, color: Colors.white),
                              const SizedBox(width: 6),
                              Text(
                                '$count',
                                style: tt.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: StreamBuilder<List<Map<String, dynamic>>>(
          stream: FavoriteService().getUserFavorites(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const _FavoriteSkeletonList();
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

class _FavoriteSkeletonList extends StatelessWidget {
  const _FavoriteSkeletonList();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (_, __) => const _FavoriteSkeletonCard(),
    );
  }
}

class _FavoriteSkeletonCard extends StatelessWidget {
  const _FavoriteSkeletonCard();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: cs.surface,
        border: Border.all(color: cs.outlineVariant.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: const SkeletonContainer(
                width: 88,
                height: 88,
                borderRadius: BorderRadius.all(Radius.circular(18)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SkeletonLine(width: 160, height: 18),
                  SizedBox(height: 10),
                  SkeletonLine(width: 120, height: 14),
                  SizedBox(height: 10),
                  SkeletonLine(width: 200, height: 12),
                ],
              ),
            ),
            const SizedBox(width: 14),
            const SkeletonCircle(size: 32),
          ],
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
    final imageUrl = productData['imageUrl'] ??
        productData['profileImage'] ??
        productData['coverImage'] ??
        productData['logoUrl'] ??
        productData['logo'] ??
        '';
    final location = productData['city'] ??
        productData['wilaya'] ??
        productData['address'] ??
        productData['location'];
    final rating = productData['rating']?.toString();
    final price = productData['price'] as num?;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.surface,
            cs.surfaceContainerHighest.withOpacity(0.35),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          if (_isTailor) {
            final tailorId = favorite['productId'] as String?;
            if (tailorId != null) {
              context.push('/app/tailor/$tailorId');
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 88,
                height: 88,
                child: Stack(
                  children: [
                    _FavoriteImageBox(
                      initialUrl: imageUrl,
                      isTailor: _isTailor,
                      tailorId:
                          _isTailor ? favorite['productId'] as String? : null,
                    ),
                    Positioned(
                      bottom: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.favorite,
                              size: 14,
                              color: Colors.redAccent.shade100,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              favorite['productType'] == 'tailor'
                                  ? 'خياط'
                                  : 'مفضل',
                              style: tt.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
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
                              color: cs.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          onPressed: onRemove,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                          icon: Icon(
                            Icons.favorite_rounded,
                            color: Colors.red.shade400,
                          ),
                          tooltip: 'إزالة من المفضلة',
                        ),
                      ],
                    ),
                    if (!_isTailor && productData['type'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        productData['type'],
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (_isTailor && location != null) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: cs.onSurfaceVariant,
                          ),
                          Text(
                            location,
                            style: tt.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                    if (_isTailor && rating != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rate_rounded,
                            size: 18,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            rating,
                            style: tt.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'تقييم',
                            style: tt.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (!_isTailor && price != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: cs.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'ر.ع ${price.toStringAsFixed(3)}',
                          style: tt.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: cs.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FavoriteImageBox extends StatelessWidget {
  final String? initialUrl;
  final bool isTailor;
  final String? tailorId;

  const _FavoriteImageBox({
    required this.initialUrl,
    required this.isTailor,
    required this.tailorId,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(18);
    final cs = Theme.of(context).colorScheme;
    final basePlaceholder = Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: borderRadius,
      ),
      alignment: Alignment.center,
      child: Icon(Icons.storefront_rounded, color: cs.onSurfaceVariant),
    );

    final initial = initialUrl?.trim() ?? '';
    final needsRemoteFetch = initial.isEmpty || !initial.startsWith('http');

    if (!needsRemoteFetch) {
      return AnyImage(
        src: initial,
        width: 88,
        height: 88,
        fit: BoxFit.cover,
        borderRadius: borderRadius,
      );
    }

    return FutureBuilder<String?>(
      future:
          isTailor ? _loadTailorImage(initial, tailorId) : _resolveUrl(initial),
      builder: (context, snapshot) {
        final resolved = snapshot.data?.trim() ?? initial;

        if ((snapshot.connectionState == ConnectionState.waiting ||
                snapshot.connectionState == ConnectionState.active) &&
            resolved.isEmpty) {
          return SkeletonContainer(
            width: 88,
            height: 88,
            borderRadius: borderRadius,
          );
        }

        if (resolved.isEmpty) {
          return basePlaceholder;
        }

        return AnyImage(
          src: resolved,
          width: 88,
          height: 88,
          fit: BoxFit.cover,
          borderRadius: borderRadius,
        );
      },
    );
  }

  Future<String?> _loadTailorImage(String initial, String? tailorId) async {
    final url = await _resolveUrl(initial);
    if (url != null) return url;
    if (tailorId == null) return null;

    try {
      final doc = await FirebaseService.firestore
          .collection('tailors')
          .doc(tailorId)
          .get();

      final data = doc.data();
      final profile = data?['profile'];
      String? candidate;
      if (profile is Map<String, dynamic>) {
        candidate = (profile['avatar'] ??
                profile['profileImage'] ??
                profile['profileImageUrl'] ??
                profile['imageUrl'] ??
                profile['image'] ??
                profile['logo'] ??
                profile['photo'])
            ?.toString();
      }

      if ((candidate == null || candidate.trim().isEmpty) && data != null) {
        candidate = (data['coverImage'] ?? data['logoUrl'] ?? data['imageUrl'])
            ?.toString();
      }

      return await _resolveUrl(candidate);
    } catch (_) {
      return null;
    }
  }

  Future<String?> _resolveUrl(String? raw) async {
    final value = raw?.trim();
    if (value == null || value.isEmpty) return null;
    if (value.startsWith('http')) return value;

    try {
      if (value.startsWith('gs://')) {
        return await FirebaseStorage.instance
            .refFromURL(value)
            .getDownloadURL();
      }
      return await FirebaseStorage.instance.ref(value).getDownloadURL();
    } catch (_) {
      return null;
    }
  }
}
