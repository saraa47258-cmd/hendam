// lib/features/catalog/presentation/merchant_products_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/state/cart_scope.dart';
import '../../../l10n/app_localizations.dart';
import '../../shops/models/shop.dart';
import '../../orders/presentation/my_orders_screen.dart';
import '../../orders/services/order_service.dart';
import '../../orders/models/order_model.dart';
import '../../../shared/widgets/gift_recipient_bottom_sheet.dart';

/// موديل المنتج (مستقل عن أي موديلات أخرى)
class MerchantProduct {
  final String id;
  final String title;
  final String subtitle;
  final double price;
  final String imageUrl; // صورة الغلاف
  final List<String> gallery; // باقي الصور
  final List<Color> colors; // ألوان/خيارات
  final String category; // للتصفية
  final bool isNew;

  const MerchantProduct({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.imageUrl,
    required this.gallery,
    required this.colors,
    required this.category,
    this.isNew = false,
  });

  /// تحويل من Firestore إلى MerchantProduct
  factory MerchantProduct.fromFirestore(Map<String, dynamic> data, String id) {
    // الصور
    String imageUrl = 'assets/shops/3.jpg';
    List<String> gallery = [];

    if (data['imageUrl'] != null && (data['imageUrl'] as String).isNotEmpty) {
      imageUrl = data['imageUrl'];
    } else if (data['images'] != null && (data['images'] as List).isNotEmpty) {
      imageUrl = (data['images'] as List).first.toString();
      gallery = (data['images'] as List).map((e) => e.toString()).toList();
    }

    if (gallery.isEmpty) {
      gallery = [imageUrl];
    }

    // الألوان - يتم عرضها فقط إذا أضافها التاجر
    List<Color> colors = [];
    if (data['colors'] != null && (data['colors'] as List).isNotEmpty) {
      for (var c in (data['colors'] as List)) {
        if (c is int) {
          colors.add(Color(c));
        } else if (c is String) {
          // تحويل HEX string إلى Color
          try {
            final hex = c.replaceFirst('#', '').replaceFirst('0x', '');
            if (hex.length == 6) {
              colors.add(Color(int.parse('FF$hex', radix: 16)));
            } else if (hex.length == 8) {
              colors.add(Color(int.parse(hex, radix: 16)));
            }
          } catch (_) {
            // تجاهل اللون غير الصالح
          }
        } else if (c is Map) {
          // إذا كان اللون عبارة عن map يحتوي على hex أو value
          try {
            final hexValue = c['hex'] ?? c['value'] ?? c['color'];
            if (hexValue != null && hexValue is String) {
              final hex = hexValue.replaceFirst('#', '').replaceFirst('0x', '');
              if (hex.length == 6) {
                colors.add(Color(int.parse('FF$hex', radix: 16)));
              } else if (hex.length == 8) {
                colors.add(Color(int.parse(hex, radix: 16)));
              }
            }
          } catch (_) {}
        }
      }
    }
    // لا نضيف ألوان افتراضية - نعرض فقط ما أضافه التاجر

    // السعر
    double price = 0;
    if (data['price'] != null) {
      price = (data['price'] is int)
          ? (data['price'] as int).toDouble()
          : (data['price'] as num).toDouble();
    }

    // التحقق إذا كان جديد (أقل من 7 أيام)
    bool isNew = false;
    if (data['createdAt'] != null) {
      try {
        final createdAt = (data['createdAt'] as Timestamp).toDate();
        isNew = DateTime.now().difference(createdAt).inDays < 7;
      } catch (_) {}
    }

    return MerchantProduct(
      id: id,
      title: data['name'] as String? ?? data['title'] as String? ?? 'منتج',
      subtitle:
          data['subtitle'] as String? ?? data['description'] as String? ?? '',
      price: price,
      imageUrl: imageUrl,
      gallery: gallery,
      colors: colors,
      category: data['category'] as String? ?? 'all',
      isNew: isNew,
    );
  }
}

class MerchantProductsScreen extends StatefulWidget {
  final Shop shop;
  const MerchantProductsScreen({super.key, required this.shop});

  @override
  State<MerchantProductsScreen> createState() => _MerchantProductsScreenState();
}

class _MerchantProductsScreenState extends State<MerchantProductsScreen> {
  final FirebaseFirestore _firestore = FirebaseService.firestore;

  // الشرائح (أقسام) - يتم تحميلها من Firebase
  List<String> _chips = ['all'];
  int _selectedChip = 0;

  // الفرز
  String _sort = 'newest'; // newest | price_asc | price_desc

  // البحث
  String _query = '';

  // حالة التحميل
  bool _isLoading = true;
  String? _error;

  // مساعدات صور مع Lazy Loading و Caching
  bool _isNet(String p) => p.startsWith('http://') || p.startsWith('https://');

  Widget _img(String src,
      {BoxFit fit = BoxFit.cover, double? width, double? height}) {
    if (_isNet(src)) {
      return CachedNetworkImage(
        imageUrl: src,
        fit: fit,
        width: width,
        height: height,
        memCacheWidth: width != null ? (width * 2).toInt() : 400,
        memCacheHeight: height != null ? (height * 2).toInt() : 400,
        fadeInDuration: const Duration(milliseconds: 200),
        fadeOutDuration: const Duration(milliseconds: 100),
        placeholder: (context, url) => _ShimmerPlaceholder(
          width: width ?? double.infinity,
          height: height ?? double.infinity,
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[200],
          child:
              Icon(Icons.image_not_supported_outlined, color: Colors.grey[400]),
        ),
      );
    }
    return Image.asset(
      src,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (_, __, ___) => Container(
        color: Colors.grey[200],
        child:
            Icon(Icons.image_not_supported_outlined, color: Colors.grey[400]),
      ),
    );
  }

  // بيانات
  List<MerchantProduct> _all = [];
  List<MerchantProduct> _shown = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// تحميل البيانات من Firebase
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // تحميل الفئات
      await _loadCategories();

      // تحميل المنتجات
      await _loadProducts();

      if (mounted) {
        setState(() => _isLoading = false);
        _applyFilters();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'فشل في تحميل المنتجات';
          _isLoading = false;
        });
      }
    }
  }

  /// تحميل الفئات من Firebase
  Future<void> _loadCategories() async {
    try {
      final snapshot = await _firestore
          .collection('traders')
          .doc(widget.shop.id)
          .collection('categories')
          .get();

      final categories = <String>['all'];
      for (var doc in snapshot.docs) {
        final name = doc.data()['name'] as String?;
        if (name != null && name.isNotEmpty) {
          categories.add(name);
        }
      }

      // إذا لم توجد فئات، أضف فئات افتراضية
      if (categories.length == 1) {
        categories.addAll(['clothes', 'fabrics', 'shoes', 'accessories']);
      }

      if (mounted) {
        setState(() => _chips = categories);
      }
    } catch (e) {
      // استخدام فئات افتراضية
      if (mounted) {
        setState(() =>
            _chips = ['all', 'clothes', 'fabrics', 'shoes', 'accessories']);
      }
    }
  }

  /// تحميل المنتجات من Firebase
  Future<void> _loadProducts() async {
    final snapshot = await _firestore
        .collection('traders')
        .doc(widget.shop.id)
        .collection('products')
        .get();

    final products = <MerchantProduct>[];
    for (var doc in snapshot.docs) {
      try {
        final product = MerchantProduct.fromFirestore(doc.data(), doc.id);
        products.add(product);
      } catch (e) {
        print('خطأ في تحويل منتج: ${doc.id} - $e');
      }
    }

    if (mounted) {
      setState(() => _all = products);
    }
  }

  void _applyFilters() {
    List<MerchantProduct> list = List.of(_all);

    // فلترة حسب القسم
    if (_selectedChip != 0) {
      final cat = _chips[_selectedChip];
      list = list.where((p) => p.category == cat).toList();
    }

    // بحث
    if (_query.isNotEmpty) {
      list = list
          .where((p) => p.title.contains(_query) || p.subtitle.contains(_query))
          .toList();
    }

    // فرز
    switch (_sort) {
      case 'price_asc':
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_desc':
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      default: // newest
        list.sort((a, b) {
          final nx = (b.isNew ? 1 : 0) - (a.isNew ? 1 : 0);
          return nx != 0 ? nx : b.id.compareTo(a.id);
        });
    }

    setState(() => _shown = list);
  }

  String _price(double v, AppLocalizations l10n) =>
      '${v == v.truncateToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2)} ${l10n.omr}';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.maybePop(context),
          ),
          title: Text(widget.shop.name, overflow: TextOverflow.ellipsis),
        ),
        body: RefreshIndicator(
          onRefresh: _loadData,
          child: CustomScrollView(
            slivers: [
              // هيدر معلومات المحل
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: _ShopHeader(
                    shop: widget.shop,
                    img: _img(widget.shop.imageUrl, fit: BoxFit.cover),
                  ),
                ),
              ),
              // بحث/فرز/شرائح
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              onChanged: (v) {
                                _query = v.trim();
                                _applyFilters();
                              },
                              decoration: InputDecoration(
                                hintText: l10n.searchInShop(widget.shop.name),
                                prefixIcon: const Icon(Icons.search_rounded),
                                filled: true,
                                fillColor:
                                    cs.surfaceContainerHighest.withOpacity(.7),
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                border: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: cs.outlineVariant),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: cs.outlineVariant),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: cs.primary, width: 1.2),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _SortButton(
                            current: _sort,
                            onSelect: (v) {
                              _sort = v;
                              _applyFilters();
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _ChipsRow(
                        chips: _chips,
                        selectedIndex: _selectedChip,
                        onChanged: (i) {
                          _selectedChip = i;
                          _applyFilters();
                        },
                      ),
                    ],
                  ),
                ),
              ),
              // حالة التحميل
              if (_isLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF6D4C41),
                    ),
                  ),
                )
              // حالة الخطأ
              else if (_error != null)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 64,
                          color: cs.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.failedToLoadProducts,
                          style: TextStyle(
                            color: cs.onSurfaceVariant,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: _loadData,
                          icon: const Icon(Icons.refresh_rounded),
                          label: Text(l10n.retry),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF6D4C41),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              // حالة القائمة فارغة
              else if (_shown.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: cs.onSurfaceVariant.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.noProductsAvailable,
                          style: TextStyle(
                            color: cs.onSurfaceVariant,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.tryChangingSearchCriteria,
                          style: TextStyle(
                            color: cs.onSurfaceVariant.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              // شبكة المنتجات
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: .62,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final item = _shown[i];
                        final hero = 'mprod-${widget.shop.id}-${item.id}';
                        return _ProductCard(
                          item: item,
                          heroTag: hero,
                          imageBuilder: (src) => _img(src, fit: BoxFit.cover),
                          priceText: _price(item.price, l10n),
                          onTap: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                transitionDuration:
                                    const Duration(milliseconds: 280),
                                reverseTransitionDuration:
                                    const Duration(milliseconds: 220),
                                pageBuilder: (_, __, ___) =>
                                    MerchantProductPreviewScreen(
                                  product: item,
                                  shop: widget.shop,
                                  heroTag: hero,
                                ),
                              ),
                            );
                          },
                        );
                      },
                      childCount: _shown.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
  }
}

/* ---------------------- Widgets مساعدة ---------------------- */

class _ShopHeader extends StatelessWidget {
  final Shop shop;
  final Widget img;
  const _ShopHeader({required this.shop, required this.img});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadiusDirectional.only(
              topStart: Radius.circular(16),
              bottomStart: Radius.circular(16),
            ),
            child: SizedBox(width: 120, height: 96, child: img),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 14, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(shop.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: cs.onSurface,
                          fontWeight: FontWeight.w900,
                          fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('${shop.city} · ${shop.category}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: cs.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _Pill(
                        text: shop.isOpen ? l10n.open : l10n.closed,
                        bg: shop.isOpen
                            ? const Color(0xFFE7F6EC)
                            : const Color(0xFFFDECEC),
                        fg: shop.isOpen
                            ? const Color(0xFF1B5E20)
                            : const Color(0xFFB71C1C),
                      ),
                      _Pill(
                        text: shop.delivery
                            ? l10n.deliveryAvailable
                            : l10n.noDelivery,
                        bg: shop.delivery
                            ? const Color(0xFFE7F6EC)
                            : const Color(0xFFF0F0F0),
                        fg: shop.delivery
                            ? const Color(0xFF1B5E20)
                            : Colors.black54,
                      ),
                      _Pill(
                        text: l10n.servicesCount(shop.servicesCount),
                        bg: cs.surfaceContainerHighest,
                        fg: cs.onSurface,
                      ),
                    ],
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

class _ChipsRow extends StatelessWidget {
  final List<String> chips;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  const _ChipsRow({
    required this.chips,
    required this.selectedIndex,
    required this.onChanged,
  });

  String _getChipLabel(String chip, AppLocalizations l10n) {
    switch (chip) {
      case 'all':
      case 'الكل':
        return l10n.allFilter;
      case 'clothes':
      case 'ملابس':
        return l10n.clothes;
      case 'fabrics':
      case 'أقمشة':
      case 'الأقمشة':
        return l10n.fabrics;
      case 'shoes':
      case 'أحذية':
        return l10n.shoes;
      case 'accessories':
      case 'إكسسوارات':
        return l10n.accessories;
      case 'sandals':
      case 'النعلان':
      case 'نعال':
        return l10n.sandals;
      case 'headwear':
      case 'المصار':
      case 'مصار':
        return l10n.headwear;
      default:
        return chip; // Return original for unknown categories
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(chips.length, (i) {
          final selected = i == selectedIndex;
          return Padding(
            padding:
                EdgeInsetsDirectional.only(end: i == chips.length - 1 ? 0 : 8),
            child: ChoiceChip(
              label: Text(_getChipLabel(chips[i], l10n)),
              selected: selected,
              onSelected: (_) => onChanged(i),
              backgroundColor: cs.surfaceContainerHighest.withOpacity(0.7),
              selectedColor: const Color(0xFF6D4C41),
              labelStyle: TextStyle(
                color: selected ? Colors.white : cs.onSurface,
                fontWeight: FontWeight.w600,
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            ),
          );
        }),
      ),
    );
  }
}

class _SortButton extends StatelessWidget {
  final String current;
  final ValueChanged<String> onSelect;
  const _SortButton({required this.current, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PopupMenuButton<String>(
      tooltip: l10n.sortLabel,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: onSelect,
      itemBuilder: (_) => [
        PopupMenuItem(value: 'newest', child: Text(l10n.newest)),
        PopupMenuItem(value: 'price_asc', child: Text(l10n.priceLowToHigh)),
        PopupMenuItem(value: 'price_desc', child: Text(l10n.priceHighToLow)),
      ],
      child: Material(
        color: const Color(0xFF6D4C41),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.sort_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 6),
                Text(l10n.sortLabel,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductCard extends StatefulWidget {
  final MerchantProduct item;
  final String heroTag;
  final String priceText; // نص جاهز
  final Widget Function(String src) imageBuilder;
  final VoidCallback onTap;

  const _ProductCard({
    required this.item,
    required this.heroTag,
    required this.priceText,
    required this.imageBuilder,
    required this.onTap,
  });

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  int _selectedColor = 0;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final item = widget.item;

    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // الصورة
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Hero(
                        tag: widget.heroTag,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: widget.imageBuilder(item.imageUrl),
                        ),
                      ),
                    ),
                    const Positioned(top: 8, left: 8, child: _FavButton()),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // الألوان - تُعرض فقط إذا أضافها التاجر
              if (item.colors.isNotEmpty) ...[
                SizedBox(
                  height: 30,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: item.colors.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, idx) => _ColorDot(
                      color: item.colors[idx],
                      selected: idx == _selectedColor,
                      onTap: () => setState(() => _selectedColor = idx),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
              ],

              if (item.isNew) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6D4C41),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    l10n.newLabel,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12),
                  ),
                ),
                const SizedBox(height: 4),
              ],

              Text(
                item.subtitle.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  fontSize: 11.5,
                ),
              ),
              const SizedBox(height: 2),

              Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 16),
              ),
              const SizedBox(height: 2),

              // السعر كنص جاهز
              Text(
                widget.priceText,
                style: TextStyle(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w800,
                    fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FavButton extends StatefulWidget {
  const _FavButton();
  @override
  State<_FavButton> createState() => _FavButtonState();
}

class _FavButtonState extends State<_FavButton> {
  bool _fav = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: Colors.white.withOpacity(.9),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => setState(() => _fav = !_fav),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
            child: Icon(
              _fav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              key: ValueKey(_fav),
              size: 20,
              color: _fav ? Colors.red : cs.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  const _ColorDot(
      {required this.color, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
              color: selected ? cs.onSurface : cs.outlineVariant,
              width: selected ? 2.0 : 1),
        ),
        alignment: Alignment.center,
        child: Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;
  const _Pill({required this.text, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(text,
          style:
              TextStyle(color: fg, fontWeight: FontWeight.w800, fontSize: 12)),
    );
  }
}

/* ===================== شاشة المعاينة ===================== */

class MerchantProductPreviewScreen extends StatefulWidget {
  final MerchantProduct product;
  final Shop shop;
  final String heroTag;
  const MerchantProductPreviewScreen({
    super.key,
    required this.product,
    required this.shop,
    required this.heroTag,
  });

  @override
  State<MerchantProductPreviewScreen> createState() =>
      _MerchantProductPreviewScreenState();
}

class _MerchantProductPreviewScreenState
    extends State<MerchantProductPreviewScreen>
    with SingleTickerProviderStateMixin {
  late final PageController _pc;
  late final AnimationController _animController;
  int _index = 0;
  bool _wish = false;
  bool _isOrdering = false;
  int _selectedColorIndex = 0;

  // Gift feature state
  bool _isGift = false;
  GiftRecipientDetails? _giftRecipientDetails;

  // Premium color palette
  static const _primaryColor = Color(0xFF2C3E50);
  static const _accentColor = Color(0xFF8B7355);
  static const _goldAccent = Color(0xFFD4AF37);

  bool _isNet(String p) => p.startsWith('http://') || p.startsWith('https://');

  Widget _img(String src, {BoxFit fit = BoxFit.cover}) {
    if (_isNet(src)) {
      return CachedNetworkImage(
        imageUrl: src,
        fit: fit,
        memCacheWidth: 1200,
        memCacheHeight: 1200,
        fadeInDuration: const Duration(milliseconds: 300),
        placeholder: (context, url) => Container(
          color: Colors.grey[100],
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _accentColor,
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[100],
          child: Icon(Icons.image_not_supported_outlined,
              color: Colors.grey[400], size: 48),
        ),
      );
    }
    return Image.asset(src, fit: fit);
  }

  @override
  void initState() {
    super.initState();
    _pc = PageController();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _pc.dispose();
    _animController.dispose();
    super.dispose();
  }

  String _formatPrice(double v, AppLocalizations l10n) =>
      '${v.toStringAsFixed(v == v.truncateToDouble() ? 0 : 2)} ${l10n.omr}';

  Future<void> _submitOrder() async {
    final l10n = AppLocalizations.of(context)!;
    final user = FirebaseService.currentUser;

    if (user == null) {
      _showMessage(l10n.pleaseSignInFirst, isError: true);
      return;
    }

    // التحقق إذا كان هدية ولم يتم إدخال بيانات المستلم
    if (_isGift && _giftRecipientDetails == null) {
      final result = await GiftRecipientBottomSheet.show(context);
      if (result == null) {
        _showMessage(l10n.recipientNameRequired, isError: true);
        return;
      }
      setState(() => _giftRecipientDetails = result);
    }

    setState(() => _isOrdering = true);

    try {
      final selectedColor = widget.product.colors.isNotEmpty
          ? widget.product.colors[_selectedColorIndex]
          : Colors.grey;

      final orderId = await OrderService.submitMerchantProductOrder(
        customerId: user.uid,
        customerName: user.displayName ?? l10n.guest,
        customerPhone: user.phoneNumber ?? '',
        traderId: widget.shop.id,
        traderName: widget.shop.name,
        productId: widget.product.id,
        productName: widget.product.title,
        productSubtitle: widget.product.subtitle,
        productImageUrl: widget.product.imageUrl,
        productPrice: widget.product.price,
        selectedColor: '#${selectedColor.value.toRadixString(16).substring(2)}',
        isGift: _isGift,
        giftRecipientDetails: _giftRecipientDetails,
      );

      if (orderId != null) {
        _showOrderSuccessDialog(orderId);
      } else {
        _showMessage(l10n.failedToSendOrder, isError: true);
      }
    } catch (e) {
      _showMessage(l10n.unexpectedError, isError: true);
    } finally {
      if (mounted) setState(() => _isOrdering = false);
    }
  }

  void _showMessage(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red[700] : _accentColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showOrderSuccessDialog(String orderId) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle_rounded,
                    color: Colors.green[600], size: 56),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.orderSubmittedSuccessfully,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                '${l10n.orderNumber}: #${orderId.substring(0, 8).toUpperCase()}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: _primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(l10n.continueShopping),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MyOrdersScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(l10n.viewOrders),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addToCart() {
    final l10n = AppLocalizations.of(context)!;
    final cartState = CartScope.of(context);

    // الحصول على اللون المختار
    String? selectedColorHex;
    if (widget.product.colors.isNotEmpty) {
      final selectedColor = widget.product.colors[_selectedColorIndex];
      selectedColorHex =
          '#${selectedColor.value.toRadixString(16).substring(2)}';
    }

    // إضافة المنتج للسلة
    cartState.addMerchantProduct(
      id: widget.product.id,
      title: widget.product.title,
      price: widget.product.price,
      imageUrl: widget.product.imageUrl,
      subtitle: widget.product.subtitle,
      selectedColor: selectedColorHex,
      shopId: widget.shop.id,
      shopName: widget.shop.name,
    );

    _showMessage(l10n.productAddedToCart);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;
    final images = widget.product.gallery.isEmpty
        ? [widget.product.imageUrl]
        : widget.product.gallery;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Main content
          CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Immersive image header
                SliverToBoxAdapter(
                  child: Stack(
                    children: [
                      // Product image carousel
                      SizedBox(
                        height: size.height * 0.55,
                        child: PageView.builder(
                          controller: _pc,
                          itemCount: images.length,
                          onPageChanged: (i) => setState(() => _index = i),
                          itemBuilder: (_, i) {
                            final child = ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(32),
                              ),
                              child: _img(images[i], fit: BoxFit.cover),
                            );
                            return i == 0
                                ? Hero(tag: widget.heroTag, child: child)
                                : child;
                          },
                        ),
                      ),

                      // Gradient overlay for top icons
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.4),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Top action bar
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 8,
                        left: 16,
                        right: 16,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildCircleButton(
                              icon: Icons.arrow_forward_rounded,
                              onTap: () => Navigator.maybePop(context),
                            ),
                            _buildCircleButton(
                              icon: Icons.share_rounded,
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),

                      // Image indicators
                      if (images.length > 1)
                        Positioned(
                          bottom: 48,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(images.length, (i) {
                              final active = i == _index;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                width: active ? 24 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: active
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              );
                            }),
                          ),
                        ),

                      // Favorite button
                      Positioned(
                        bottom: 16,
                        left: 20,
                        child: _buildCircleButton(
                          icon: _wish
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          onTap: () => setState(() => _wish = !_wish),
                          color: _wish ? Colors.red : null,
                          size: 52,
                        ),
                      ),
                    ],
                  ),
                ),

                // Product details
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category / Subtitle
                        if (widget.product.subtitle.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              widget.product.subtitle.toUpperCase(),
                              style: const TextStyle(
                                color: _accentColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),

                        const SizedBox(height: 16),

                        // Product name
                        Text(
                          widget.product.title,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: _primaryColor,
                            height: 1.2,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Price
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              _formatPrice(widget.product.price, l10n),
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: _goldAccent,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.taxIncluded,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 28),

                        // Shop info card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: _primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.store_rounded,
                                    color: _primaryColor, size: 24),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.shop.name,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: _primaryColor,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      widget.shop.city,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: widget.shop.isOpen
                                      ? Colors.green[50]
                                      : Colors.red[50],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  widget.shop.isOpen ? l10n.open : l10n.closed,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: widget.shop.isOpen
                                        ? Colors.green[700]
                                        : Colors.red[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Color selection
                        if (widget.product.colors.isNotEmpty) ...[
                          const SizedBox(height: 28),
                          Text(
                            l10n.availableColors,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: _primaryColor,
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            height: 52,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: widget.product.colors.length,
                              itemBuilder: (_, i) {
                                final color = widget.product.colors[i];
                                final selected = i == _selectedColorIndex;
                                return GestureDetector(
                                  onTap: () =>
                                      setState(() => _selectedColorIndex = i),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    margin: EdgeInsetsDirectional.only(
                                        end: i ==
                                                widget.product.colors.length - 1
                                            ? 0
                                            : 12),
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: selected
                                            ? _goldAccent
                                            : Colors.grey[300]!,
                                        width: selected ? 3 : 2,
                                      ),
                                      boxShadow: selected
                                          ? [
                                              BoxShadow(
                                                color: color.withOpacity(0.4),
                                                blurRadius: 12,
                                                offset: const Offset(0, 4),
                                              )
                                            ]
                                          : null,
                                    ),
                                    child: selected
                                        ? Icon(
                                            Icons.check_rounded,
                                            color:
                                                color.computeLuminance() > 0.5
                                                    ? Colors.black
                                                    : Colors.white,
                                            size: 22,
                                          )
                                        : null,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],

                        // Gift Option Section - إرسال كهدية
                        const SizedBox(height: 24),
                        _buildGiftSection(l10n),

                        // Features
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            _buildFeatureChip(
                                Icons.verified_rounded, l10n.qualityGuaranteed),
                            const SizedBox(width: 12),
                            _buildFeatureChip(Icons.local_shipping_rounded,
                                l10n.fastDelivery),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildFeatureChip(
                            Icons.replay_rounded, l10n.returnWithinDays),

                        // Bottom padding for action bar
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Fixed bottom action bar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(
                    20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Add to cart button (secondary)
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: OutlinedButton.icon(
                          onPressed: _addToCart,
                          icon:
                              const Icon(Icons.shopping_bag_outlined, size: 20),
                          label: Text(
                            l10n.addToCart,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _primaryColor,
                            side: const BorderSide(
                                color: _primaryColor, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Order now button (primary)
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isOrdering ? null : _submitOrder,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryColor,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                _primaryColor.withOpacity(0.6),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isOrdering
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  l10n.orderNow,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                  ),
                                ),
                        ),
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

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
    double size = 44,
  }) {
    return Material(
      color: Colors.white.withOpacity(0.95),
      shape: const CircleBorder(),
      elevation: 2,
      shadowColor: Colors.black26,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, color: color ?? _primaryColor, size: size * 0.5),
        ),
      ),
    );
  }

  Widget _buildFeatureChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: _accentColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  /// بناء قسم خيار الهدية
  Widget _buildGiftSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Gift toggle card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: _isGift
                ? LinearGradient(
                    colors: [
                      _goldAccent.withOpacity(0.1),
                      _accentColor.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: _isGift ? null : Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isGift
                  ? _goldAccent.withOpacity(0.5)
                  : Colors.grey[200]!,
              width: _isGift ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _isGift
                      ? _goldAccent.withOpacity(0.2)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.card_giftcard_rounded,
                  color: _isGift ? _goldAccent : Colors.grey[600],
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.sendAsGift,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _isGift ? _goldAccent : _primaryColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.thisOrderIsAGift,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: _isGift,
                onChanged: (v) async {
                  setState(() => _isGift = v);
                  if (v && _giftRecipientDetails == null) {
                    // فتح bottom sheet لإدخال بيانات المستلم
                    final result = await GiftRecipientBottomSheet.show(context);
                    if (result != null) {
                      setState(() => _giftRecipientDetails = result);
                    } else {
                      // إذا ألغى المستخدم، نعيد التبديل
                      setState(() => _isGift = false);
                    }
                  }
                },
                activeColor: _goldAccent,
              ),
            ],
          ),
        ),

        // Gift recipient summary card (if gift is enabled and details exist)
        if (_isGift && _giftRecipientDetails != null) ...[
          const SizedBox(height: 16),
          GiftRecipientSummaryCard(
            details: _giftRecipientDetails!,
            onEdit: () async {
              final result = await GiftRecipientBottomSheet.show(
                context,
                initialData: _giftRecipientDetails,
              );
              if (result != null) {
                setState(() => _giftRecipientDetails = result);
              }
            },
          ),
        ],
      ],
    );
  }
}

/* ===================== Shimmer Placeholder ===================== */

/// عنصر تحميل متحرك (Shimmer Effect)
class _ShimmerPlaceholder extends StatefulWidget {
  final double width;
  final double height;

  const _ShimmerPlaceholder({
    required this.width,
    required this.height,
  });

  @override
  State<_ShimmerPlaceholder> createState() => _ShimmerPlaceholderState();
}

class _ShimmerPlaceholderState extends State<_ShimmerPlaceholder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value + 1, 0),
              colors: const [
                Color(0xFFEEEEEE),
                Color(0xFFF5F5F5),
                Color(0xFFEEEEEE),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

/* ===================== Optimized Network Image ===================== */

/// صورة محسنة مع Caching و Lazy Loading
class OptimizedNetworkImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const OptimizedNetworkImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final image = CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      width: width,
      height: height,
      memCacheWidth: width != null ? (width! * 2).toInt() : 400,
      memCacheHeight: height != null ? (height! * 2).toInt() : 400,
      fadeInDuration: const Duration(milliseconds: 200),
      fadeOutDuration: const Duration(milliseconds: 100),
      placeholder: (context, url) => _ShimmerPlaceholder(
        width: width ?? double.infinity,
        height: height ?? double.infinity,
      ),
      errorWidget: (context, url, error) => Container(
        width: width,
        height: height,
        color: Colors.grey[200],
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Colors.grey[400],
          size: 32,
        ),
      ),
    );

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: image,
      );
    }
    return image;
  }
}
