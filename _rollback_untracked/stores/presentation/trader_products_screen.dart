// lib/features/stores/presentation/trader_products_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/store.dart';
import '../models/category.dart';
import '../../catalog/models/abaya_item.dart';
import '../services/stores_service.dart';
import 'store_product_preview_screen.dart';
import '../../../shared/widgets/any_image.dart';

/// صفحة عرض منتجات التاجر - تصميم Light Theme
class TraderProductsScreen extends StatefulWidget {
  final Store store;

  const TraderProductsScreen({
    super.key,
    required this.store,
  });

  @override
  State<TraderProductsScreen> createState() => _TraderProductsScreenState();
}

class _TraderProductsScreenState extends State<TraderProductsScreen>
    with TickerProviderStateMixin {
  final _storesService = StoresService();
  final PageController _bannerController = PageController();

  List<AbayaItem> _products = [];
  List<AbayaItem> _filteredProducts = [];
  List<TraderCategory> _categories = [];
  Map<String, int> _categoryProductsCount = {}; // عدد المنتجات لكل قسم
  bool _isLoading = true;
  StreamSubscription<List<AbayaItem>>? _productsSubscription;
  StreamSubscription<List<TraderCategory>>? _categoriesSubscription;
  String? _selectedCategoryId; // null يعني "الكل"
  int _currentBannerIndex = 0;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  // ألوان التصميم - من ثيم التطبيق (يدعم الوضع الليلي)
  static Color _bg(BuildContext c) => Theme.of(c).colorScheme.surface;
  static Color _card(BuildContext c) => Theme.of(c).colorScheme.surfaceContainerLow;
  static Color _primary(BuildContext c) => Theme.of(c).colorScheme.primary;
  static Color _onPrimary(BuildContext c) => Theme.of(c).colorScheme.onPrimary;
  static Color _onSurface(BuildContext c) => Theme.of(c).colorScheme.onSurface;
  static Color _onSurfaceVariant(BuildContext c) => Theme.of(c).colorScheme.onSurfaceVariant;
  static Color _shadow(BuildContext c) => Theme.of(c).colorScheme.shadow;
  static Color _surfaceContainerHighest(BuildContext c) => Theme.of(c).colorScheme.surfaceContainerHighest;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    _loadProducts();
  }

  void _loadProducts() {
    debugPrint('🚀 بدء جلب المنتجات للتاجر: ${widget.store.id}');
    setState(() {
      _isLoading = true;
      _products = [];
      _filteredProducts = [];
    });
    
    // جلب الأقسام من Firebase
    _categoriesSubscription = _storesService
        .getTraderCategories(widget.store.id)
        .listen(
      (categories) async {
        debugPrint('📁 تم جلب ${categories.length} قسم للتاجر ${widget.store.id}');
        if (mounted) {
          setState(() {
            _categories = categories;
          });
          
          // جلب عدد المنتجات لكل قسم
          // نستخدم productsCount من Firebase إذا كان موجوداً، وإلا نجلب من subcollection
          final counts = <String, int>{};
          for (final category in categories) {
            // إذا كان productsCount موجوداً في Firebase، نستخدمه مباشرة
            if (category.productsCount > 0) {
              counts[category.id] = category.productsCount;
              debugPrint('📊 القسم ${category.name}: ${category.productsCount} منتج (من Firebase)');
            } else {
              // وإلا نجلب العدد من subcollection
              try {
                final count = await _storesService.getCategoryProductsCount(
                  traderId: widget.store.id,
                  categoryId: category.id,
                );
                counts[category.id] = count;
                debugPrint('📊 القسم ${category.name}: $count منتج (من subcollection)');
              } catch (e) {
                debugPrint('❌ خطأ في جلب عدد منتجات القسم ${category.id}: $e');
                counts[category.id] = 0;
              }
            }
          }
          
          if (mounted) {
            setState(() {
              _categoryProductsCount = counts;
            });
          }
          
          // بعد جلب الأقسام، نجلب المنتجات
          // إذا لم تكن هناك أقسام، نستخدم الطريقة القديمة
          if (categories.isEmpty) {
            debugPrint('⚠️ لا توجد أقسام، استخدام الطريقة البديلة');
            _loadProductsFallback();
          } else {
            debugPrint('✅ جلب المنتجات من الأقسام');
            _loadProductsByCategory();
          }
        }
      },
      onError: (error) {
        debugPrint('❌ خطأ في جلب الأقسام: $error');
        // في حالة الخطأ، نجلب المنتجات بدون أقسام (fallback)
        _loadProductsFallback();
      },
    );
  }

  /// طريقة بديلة لجلب المنتجات من traders/{traderId}/products
  void _loadProductsFallback() {
    debugPrint('استخدام الطريقة البديلة: traders/${widget.store.id}/products');
    _productsSubscription?.cancel();
    _productsSubscription = _storesService
        .getTraderProducts(widget.store.id)
        .listen(
      (products) {
        debugPrint('تم جلب ${products.length} منتج (fallback)');
        if (mounted) {
          setState(() {
            _products = products;
            _filteredProducts = products;
            _isLoading = false;
          });
          _animController.forward();
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() => _isLoading = false);
        }
        debugPrint('خطأ في جلب المنتجات (fallback): $error');
      },
    );
  }

  void _loadProductsByCategory() {
    _productsSubscription?.cancel();

    if (_selectedCategoryId == null) {
      // جلب جميع المنتجات من جميع الأقسام
      debugPrint('جلب جميع المنتجات من جميع الأقسام');
      _productsSubscription = _storesService
          .getTraderProductsFromCategories(widget.store.id)
          .listen(
        (products) {
          debugPrint('✅ تم جلب ${products.length} منتج من جميع الأقسام');
          if (products.isNotEmpty) {
            debugPrint('📦 أول منتج: ${products.first.title}');
            debugPrint('🖼️ الصورة: ${products.first.imageUrl}');
            debugPrint('💰 السعر: ${products.first.price}');
            for (var i = 0; i < products.length && i < 3; i++) {
              debugPrint('  - منتج ${i + 1}: ${products[i].title}');
            }
          } else {
            debugPrint('⚠️ لا توجد منتجات!');
          }
          if (mounted) {
            setState(() {
              _products = products;
              _filteredProducts = products;
              _isLoading = false;
            });
            debugPrint('🔄 تم تحديث الواجهة - isLoading: $_isLoading, products: ${_products.length}, filtered: ${_filteredProducts.length}');
            _animController.forward();
          } else {
            debugPrint('⚠️ Widget غير mounted!');
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() => _isLoading = false);
          }
          debugPrint('خطأ في جلب المنتجات من الأقسام: $error');
          // في حالة الخطأ، نجرب الطريقة البديلة
          _loadProductsFallback();
        },
      );
    } else {
      // جلب المنتجات من قسم محدد
      debugPrint('جلب المنتجات من القسم: $_selectedCategoryId');
      _productsSubscription = _storesService
          .getTraderProductsByCategory(
            traderId: widget.store.id,
            categoryId: _selectedCategoryId!,
          )
          .listen(
        (products) {
          debugPrint('تم جلب ${products.length} منتج من القسم $_selectedCategoryId');
          if (products.isNotEmpty) {
            debugPrint('أول منتج: ${products.first.title}, الصورة: ${products.first.imageUrl}');
          }
          if (mounted) {
            setState(() {
              _products = products;
              _filteredProducts = products;
              _isLoading = false;
            });
            _animController.forward();
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() => _isLoading = false);
          }
          debugPrint('خطأ في جلب منتجات القسم: $error');
        },
      );
    }
  }

  void _applyFilter(String? categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
      _isLoading = true;
    });
    // إعادة جلب المنتجات حسب القسم المحدد
    _loadProductsByCategory();
  }

  @override
  void dispose() {
    _productsSubscription?.cancel();
    _categoriesSubscription?.cancel();
    _animController.dispose();
    _bannerController.dispose();
    super.dispose();
  }

  String _price(double v) =>
      v == v.truncateToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    debugPrint('🔨 بناء الواجهة - isLoading: $_isLoading, products: ${_filteredProducts.length}');
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _bg(context),
        body: _isLoading ? _buildLoadingState() : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    final size = MediaQuery.of(context).size;
    final featuredProducts = _products.take(3).toList();
    
    debugPrint('📊 بناء المحتوى - isLoading: $_isLoading, المنتجات: ${_products.length}, المعروضة: ${_filteredProducts.length}');
    debugPrint('📊 _selectedCategoryId: $_selectedCategoryId');
    debugPrint('📊 _categories: ${_categories.length}');

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: _buildHeader(),
        ),

        // البانر المتحرك للمنتجات المميزة
        if (featuredProducts.isNotEmpty)
          SliverToBoxAdapter(
            child: _buildFeaturedBanner(featuredProducts),
          ),

        // مؤشرات البانر
        if (featuredProducts.length > 1)
          SliverToBoxAdapter(
            child: _buildBannerIndicators(featuredProducts.length),
          ),

        // التبويبات
        SliverToBoxAdapter(
          child: _buildTabs(),
        ),

        // الفلاتر
        SliverToBoxAdapter(
          child: _buildFilters(),
        ),

        // شبكة المنتجات
        _filteredProducts.isEmpty
            ? SliverFillRemaining(
                child: _buildEmptyState(),
              )
            : SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: size.width > 600 ? 3 : 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.75,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index >= _filteredProducts.length) {
                        return const SizedBox.shrink();
                      }
                      final product = _filteredProducts[index];
                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: _ProductCard(
                          product: product,
                          price: _price(product.price),
                          onTap: () => _openProduct(product),
                        ),
                      );
                    },
                    childCount: _filteredProducts.length,
                  ),
                ),
              ),
      ],
    );
  }

  Widget _buildHeader() {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        decoration: BoxDecoration(
          color: _card(context),
          boxShadow: [
            BoxShadow(
              color: _shadow(context).withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // زر الرجوع
            _LightIconBtn(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: () => Navigator.maybePop(context),
            ),
            const Spacer(),
            // معلومات المتجر
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [cs.primary, cs.tertiary],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: widget.store.imageUrl != null &&
                            widget.store.imageUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: widget.store.imageUrl!,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => _buildStoreInitial(),
                          )
                        : _buildStoreInitial(),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  widget.store.name,
                  style: TextStyle(
                    color: _onSurface(context),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Spacer(),
            // عداد الماسات
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _primary(context).withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.diamond_rounded,
                    size: 18,
                    color: _primary(context),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${_products.length}',
                    style: TextStyle(
                      color: _onSurface(context),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreInitial() {
    return Center(
      child: Text(
        widget.store.name.isNotEmpty ? widget.store.name[0].toUpperCase() : 'M',
        style: TextStyle(
          color: _onPrimary(context),
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildFeaturedBanner(List<AbayaItem> featured) {
    return Container(
      height: 280,
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: PageView.builder(
        controller: _bannerController,
        onPageChanged: (index) {
          setState(() => _currentBannerIndex = index);
        },
        itemCount: featured.length,
        itemBuilder: (context, index) {
          final product = featured[index];
          return GestureDetector(
            onTap: () => _openProduct(product),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: _card(context),
                boxShadow: [
                  BoxShadow(
                    color: _primary(context).withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // صورة المنتج
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        color: _surfaceContainerHighest(context),
                        child: AnyImage(
                          src: product.imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  // تدرج للنص
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.6),
                          ],
                          stops: const [0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                  // معلومات المنتج
                  Positioned(
                    bottom: 20,
                    right: 20,
                    left: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.tertiary],
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                Icons.diamond_rounded,
                                size: 14,
                                color: _onPrimary(context),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _price(product.price),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'ر.ع',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
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
    );
  }

  Widget _buildBannerIndicators(int count) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(count, (index) {
          final isActive = index == _currentBannerIndex;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: isActive
                  ? _primary(context)
                  : _onSurfaceVariant(context).withOpacity(0.4),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Row(
        children: [
          _TabItem(label: 'نظرة عامة', isActive: false, onTap: () {}),
          const SizedBox(width: 24),
          _TabItem(label: 'المنتجات', isActive: true, onTap: () {}),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    // إضافة "الكل" كخيار أول
    final allFilters = [
      {'id': null, 'name': 'الكل', 'count': _products.length}
    ];
    
    // إضافة الأقسام من Firebase
    for (final category in _categories) {
      final count = _categoryProductsCount[category.id] ?? 0;
      allFilters.add({
        'id': category.id,
        'name': category.name,
        'count': count,
      });
    }

    return Container(
      height: 56,
      margin: const EdgeInsets.only(top: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: allFilters.length + 1, // +1 للأيقونة
        itemBuilder: (context, index) {
          // أيقونة الترتيب
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Center(
                child: Icon(
                  Icons.swap_vert_rounded,
                  color: _onSurfaceVariant(context),
                  size: 22,
                ),
              ),
            );
          }

          final filter = allFilters[index - 1];
          final categoryId = filter['id'] as String?;
          final filterName = filter['name'] as String;
          final count = filter['count'] as int;
          final isSelected = _selectedCategoryId == categoryId;

          return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                _applyFilter(categoryId);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? _primary(context) : Colors.transparent,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isSelected
                        ? _primary(context)
                        : _onSurfaceVariant(context).withOpacity(0.4),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      filterName,
                      style: TextStyle(
                        color: isSelected ? _onPrimary(context) : _onSurface(context),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (count > 0) ...[
                      const SizedBox(width: 6),
                      Text(
                        '($count)',
                        style: TextStyle(
                          color: isSelected
                              ? _onPrimary(context).withOpacity(0.9)
                              : _onSurfaceVariant(context),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [cs.primary, cs.tertiary],
              ),
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(_onPrimary(context)),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'جاري تحميل المنتجات...',
            style: TextStyle(
              color: _onSurfaceVariant(context),
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _primary(context).withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              size: 56,
              color: _primary(context),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'لا توجد منتجات',
            style: TextStyle(
              color: _onSurface(context),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'سيتم إضافة منتجات قريباً',
            style: TextStyle(
              color: _onSurfaceVariant(context),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

      void _openProduct(AbayaItem product) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StoreProductPreviewScreen(
              productId: product.id,
              traderId: widget.store.id,  // تمرير معرف التاجر
            ),
          ),
        );
      }
}

/* ========================= Tab Item ========================= */

class _TabItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isActive
                  ? _TraderProductsScreenState._onSurface(context)
                  : _TraderProductsScreenState._onSurfaceVariant(context),
              fontSize: 16,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 3,
            width: isActive ? 40 : 0,
            decoration: BoxDecoration(
              color: _TraderProductsScreenState._primary(context),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}

/* ========================= Light Icon Button ========================= */

class _LightIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _LightIconBtn({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _TraderProductsScreenState._bg(context),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          size: 20,
          color: _TraderProductsScreenState._onSurface(context),
        ),
      ),
    );
  }
}

/* ========================= Product Card ========================= */

class _ProductCard extends StatefulWidget {
  final AbayaItem product;
  final String price;
  final VoidCallback onTap;

  const _ProductCard({
    required this.product,
    required this.price,
    required this.onTap,
  });

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
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
    final product = widget.product;
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: _TraderProductsScreenState._card(context),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _TraderProductsScreenState._shadow(context).withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // الصورة
              Expanded(
                flex: 5,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: _TraderProductsScreenState._surfaceContainerHighest(context),
                        ),
                        child: AnyImage(
                          src: product.imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                    ),
                    // شارة جديد
                    if (product.isNew)
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [cs.primary, cs.tertiary],
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'جديد',
                            style: TextStyle(
                              color: cs.onPrimary,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // المعلومات
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // اسم المنتج
                      Text(
                        product.title,
                        style: TextStyle(
                          color: _TraderProductsScreenState._onSurface(context),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // الوصف/الفئة (إذا كان موجوداً)
                      if (product.subtitle.isNotEmpty || product.category.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          product.category.isNotEmpty ? product.category : product.subtitle,
                          style: TextStyle(
                            color: _TraderProductsScreenState._onSurfaceVariant(context),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const Spacer(),
                      // السعر مع أيقونة الماسة
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [cs.primary, cs.tertiary],
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              Icons.diamond_rounded,
                              size: 14,
                              color: cs.onPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.price,
                            style: TextStyle(
                              color: _TraderProductsScreenState._onSurface(context),
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'ر.ع',
                            style: TextStyle(
                              color: _TraderProductsScreenState._onSurfaceVariant(context),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
