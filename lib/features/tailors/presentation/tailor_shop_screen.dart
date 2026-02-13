import 'package:flutter/material.dart';
import 'package:hindam/l10n/app_localizations.dart';
import '../models/tailor.dart';

class TailorShopScreen extends StatelessWidget {
  final Tailor tailor;
  final String? imageUrl;
  final int? reviewsCount;

  const TailorShopScreen({
    super.key,
    required this.tailor,
    this.imageUrl,
    this.reviewsCount,
  });

  bool _isNetwork(String p) => p.startsWith('http://') || p.startsWith('https://');

  /// إن مرّرت اسم ملف فقط سيتم تكميله تلقائيًا إلى assets/fabrics/
  String _resolve(String? p) {
    if (p == null || p.isEmpty) return '';
    if (_isNetwork(p)) return p;
    if (p.startsWith('assets/')) return p;
    if (p.startsWith('lib/assets/')) return p.substring(4); // إزالة lib/
    return 'assets/fabrics/$p';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final products = _demoProducts(); // بدّلها لاحقًا ببياناتك من API/فايربيس

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text('${l10n.store} ${tailor.name}'),
          centerTitle: true,
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            // هيدر الخياط
            _Header(
              tailor: tailor,
              imageUrl: imageUrl,
              reviewsCount: reviewsCount,
              resolve: _resolve,
              isNetwork: _isNetwork,
            ),
            const SizedBox(height: 12),

            // شريط البحث
            _SearchBar(
              hint: l10n.searchInShop(tailor.name),
              onSubmitted: (q) {
                // TODO: اربط البحث الحقيقي
              },
            ),
            const SizedBox(height: 12),

            // شبكة منتجات المتجر
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: products.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: .82,
              ),
              itemBuilder: (_, i) {
                final it = products[i];
                final resolved = _resolve(it.image);
                final image = resolved.isEmpty
                    ? _fallbackBox(context)
                    : (_isNetwork(resolved)
                    ? Image.network(
                  resolved,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _fallbackBox(context),
                )
                    : Image.asset(
                  resolved,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _fallbackBox(context),
                ));

                return Material(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(16),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      // TODO: افتح ورقة تفاصيل/إضافة للسلة
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.addedItemToCart(it.title))),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AspectRatio(aspectRatio: 4 / 3, child: image),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
                          child: Text(
                            it.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                          child: Row(
                            children: [
                              Text(
                                'ر.ع ${it.price.toStringAsFixed(3)}',
                                style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                              ),
                              const Spacer(),
                              IconButton.filledTonal(
                                onPressed: () {
                                  // TODO: أضف إلى السلة مباشرة
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(l10n.addedItemToCart(it.title))),
                                  );
                                },
                                icon: const Icon(Icons.add_shopping_cart_rounded),
                                style: IconButton.styleFrom(padding: const EdgeInsets.all(10)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      );
  }

  Widget _fallbackBox(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      color: cs.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(Icons.shop_2_rounded, size: 28, color: cs.onSurfaceVariant),
    );
  }

  // منتجات تجريبية — استبدلها ببياناتك
  List<_Product> _demoProducts() => const [
    _Product(title: 'قماش صيفي فاخر', price: 8.500, image: 'fabric_summer.jpg'),
    _Product(title: 'أزرار مميزة', price: 0.800, image: 'buttons_gold.png'),
    _Product(title: 'قماش قطني كلاسيك', price: 6.900, image: 'fabric_classic.jpg'),
    _Product(title: 'ياقات جاهزة', price: 1.200, image: 'collars.png'),
  ];
}

class _Product {
  final String title;
  final double price;
  final String image; // اسم ملف أو مسار كامل أو رابط شبكة
  const _Product({required this.title, required this.price, required this.image});
}

/* ======================= Widgets مساعدة ======================= */

class _Header extends StatelessWidget {
  final Tailor tailor;
  final String? imageUrl;
  final int? reviewsCount;
  final String Function(String?) resolve;
  final bool Function(String) isNetwork;

  const _Header({
    required this.tailor,
    required this.imageUrl,
    required this.reviewsCount,
    required this.resolve,
    required this.isNetwork,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final resolved = resolve(imageUrl);
    final avatar = resolved.isEmpty
        ? _avatarFallback(context)
        : (isNetwork(resolved)
        ? Image.network(
      resolved,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _avatarFallback(context),
    )
        : Image.asset(
      resolved,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _avatarFallback(context),
    ));

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: cs.outlineVariant),
            ),
            clipBehavior: Clip.antiAlias,
            child: avatar,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tailor.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 16),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        tailor.city,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rate_rounded, size: 18, color: Color(0xFFFFD54F)),
                const SizedBox(width: 2),
                Text(
                  tailor.rating.toStringAsFixed(1),
                  style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                if (reviewsCount != null) ...[
                  const SizedBox(width: 6),
                  Text('($reviewsCount)', style: tt.bodySmall),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarFallback(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      color: cs.surface,
      alignment: Alignment.center,
      child: Icon(Icons.cut_rounded, size: 26, color: cs.onSurfaceVariant),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final String hint;
  final ValueChanged<String>? onSubmitted;
  const _SearchBar({required this.hint, this.onSubmitted});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: TextField(
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          border: InputBorder.none,
          prefixIcon: const Icon(Icons.search_rounded),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
      ),
    );
  }
}
