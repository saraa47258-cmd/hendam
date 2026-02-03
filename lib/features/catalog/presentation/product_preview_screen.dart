// lib/features/catalog/presentation/product_preview_screen.dart
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/abaya_item.dart';
import '../services/abaya_service.dart';
import '../../../measurements/presentation/abaya_measure_screen.dart';
import '../../../shared/widgets/any_image.dart';
import '../../favorites/services/favorite_service.dart';
import '../../auth/providers/auth_provider.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Design System
// ═══════════════════════════════════════════════════════════════════════════

class _DS {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusSheet = 28;

  static const Color primaryBrown = Color(0xFF8B7355);
  static const Color darkText = Color(0xFF1F2937);
  static const Color mediumText = Color(0xFF6B7280);
  static const Color lightText = Color(0xFF9CA3AF);
  static const Color background = Color(0xFFFAFAFA);
}

// ═══════════════════════════════════════════════════════════════════════════
// Main Screen
// ═══════════════════════════════════════════════════════════════════════════

class ProductPreviewScreen extends StatefulWidget {
  final String productId;

  const ProductPreviewScreen({
    super.key,
    required this.productId,
  });

  @override
  State<ProductPreviewScreen> createState() => _ProductPreviewScreenState();
}

class _ProductPreviewScreenState extends State<ProductPreviewScreen>
    with SingleTickerProviderStateMixin {
  late final PageController _pc;
  int _index = 0;
  bool _wish = false;
  bool _isLoadingFavorite = false;
  bool _isInitialized = false;
  bool _isLoadingProduct = true;
  String? _error;

  // Selected color state
  Color? _selectedColor;

  final _favoriteService = FavoriteService();
  final _abayaService = AbayaService();
  StreamSubscription<AbayaItem?>? _productSubscription;

  AbayaItem? item;

  @override
  void initState() {
    super.initState();
    _pc = PageController();
    _loadProduct();
  }

  void _loadProduct() {
    _abayaService.getProductById(widget.productId).then((product) {
      if (mounted) {
        setState(() {
          item = product;
          _isLoadingProduct = false;
          _error = product == null ? 'المنتج غير موجود' : null;
        });
        if (product != null) {
          _checkFavoriteStatus();
          try {
            _productSubscription?.cancel();
            _productSubscription =
                _abayaService.getProductByIdStream(widget.productId).listen(
              (updatedProduct) {
                if (mounted && updatedProduct != null) {
                  setState(() => item = updatedProduct);
                }
              },
              onError: (_) {},
            );
          } catch (_) {}
        }
      }
    }).catchError((error) {
      if (mounted) {
        setState(() {
          _isLoadingProduct = false;
          _error = 'حدث خطأ في تحميل المنتج';
        });
      }
    });
  }

  Future<void> _checkFavoriteStatus() async {
    if (item == null) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) {
      if (mounted) setState(() => _isInitialized = true);
      return;
    }
    try {
      final isFav = await _favoriteService.isFavorite(
        productId: item!.id,
        productType: 'abaya',
      );
      if (mounted) {
        setState(() {
          _wish = isFav;
          _isInitialized = true;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isInitialized = true);
    }
  }

  Future<void> _toggleFavorite() async {
    if (item == null) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) {
      _showSnackBar('يرجى تسجيل الدخول أولاً', isError: true);
      return;
    }

    if (_isLoadingFavorite) return;
    setState(() => _isLoadingFavorite = true);
    HapticFeedback.lightImpact();

    try {
      if (_wish) {
        final removed = await _favoriteService.removeFromFavorites(
          productId: item!.id,
          productType: 'abaya',
        );
        if (mounted && removed) {
          setState(() => _wish = false);
          _showSnackBar('تم إزالة من المفضلة');
        }
      } else {
        final added = await _favoriteService.addToFavorites(
          productId: item!.id,
          productType: 'abaya',
          productData: {
            'name': item!.title,
            'title': item!.title,
            'subtitle': item!.subtitle,
            'imageUrl': item!.imageUrl,
            'gallery': item!.gallery,
            'price': item!.price,
            'colors': item!.colors.map((c) => c.value).toList(),
            'isNew': item!.isNew,
            'type': 'عباية',
          },
        );
        if (mounted && added) {
          setState(() => _wish = true);
          _showSnackBar('تمت الإضافة للمفضلة', isSuccess: true);
        }
      }
    } catch (e) {
      _showSnackBar('حدث خطأ', isError: true);
    } finally {
      if (mounted) setState(() => _isLoadingFavorite = false);
    }
  }

  void _showSnackBar(String message,
      {bool isSuccess = false, bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            isSuccess ? const Color(0xFF10B981) : (isError ? Colors.red : null),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(_DS.lg),
      ),
    );
  }

  @override
  void dispose() {
    _pc.dispose();
    _productSubscription?.cancel();
    super.dispose();
  }

  String _formatPrice(double v) =>
      '${v == v.truncateToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2)} ر.ع';

  @override
  Widget build(BuildContext context) {
    if (_isLoadingProduct) return _buildLoadingState();
    if (_error != null || item == null) return _buildErrorState();
    return _buildContent();
  }

  Widget _buildLoadingState() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _DS.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(_DS.primaryBrown),
                strokeWidth: 2,
              ),
              const SizedBox(height: _DS.lg),
              Text(
                'جاري التحميل...',
                style: TextStyle(
                  color: _DS.mediumText,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _DS.background,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(_DS.lg),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: _GlassIconButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => Navigator.maybePop(context),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.error_outline_rounded,
                          size: 40,
                          color: _DS.mediumText,
                        ),
                      ),
                      const SizedBox(height: _DS.xl),
                      Text(
                        _error ?? 'المنتج غير موجود',
                        style: const TextStyle(
                          fontSize: 16,
                          color: _DS.mediumText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: _DS.xxl),
                      _PremiumButton(
                        label: 'إعادة المحاولة',
                        onTap: () {
                          setState(() {
                            _isLoadingProduct = true;
                            _error = null;
                          });
                          _loadProduct();
                        },
                        isOutlined: true,
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

  Widget _buildContent() {
    final heroTag = 'product-${widget.productId}';
    final images =
        item!.gallery.isEmpty ? <String>[item!.imageUrl] : item!.gallery;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final imageHeight = screenHeight * 0.55;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // Main Content
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Hero Image Section
                SliverToBoxAdapter(
                  child: _ImageHero(
                    images: images,
                    heroTag: heroTag,
                    height: imageHeight,
                    currentIndex: _index,
                    pageController: _pc,
                    onPageChanged: (i) => setState(() => _index = i),
                    isFavorite: _wish,
                    isLoadingFavorite: _isLoadingFavorite,
                    isInitialized: _isInitialized,
                    onFavoriteTap: _toggleFavorite,
                  ),
                ),

                // Info Sheet
                SliverToBoxAdapter(
                  child: _InfoSheet(
                    item: item!,
                    formattedPrice: _formatPrice(item!.price),
                    selectedColor: _selectedColor,
                    onColorSelected: (color) {
                      setState(() => _selectedColor = color);
                      HapticFeedback.selectionClick();
                    },
                  ),
                ),

                // Extra space for bottom bar
                const SliverToBoxAdapter(
                  child: SizedBox(height: 120),
                ),
              ],
            ),

            // Overlay App Bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _OverlayAppBar(
                onBack: () => Navigator.maybePop(context),
                onShare: () {},
              ),
            ),

            // Sticky Actions
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _StickyActions(
                onAddToCart: () => _addToCart(),
                onOrderNow: () => _orderNow(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addToCart() {
    // Require color selection if colors are available
    if (item!.colors.isNotEmpty && _selectedColor == null) {
      _showSnackBar('يرجى اختيار اللون أولاً', isError: true);
      return;
    }

    HapticFeedback.mediumImpact();

    // الانتقال لشاشة المقاسات أولاً ثم إضافة للسلة
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (_, __, ___) => AbayaMeasureScreen(
          item: item!,
          selectedColor: _selectedColor,
          isAddToCartMode: true, // وضع الإضافة للسلة
        ),
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
      ),
    );
  }

  void _orderNow() {
    // Require color selection if colors are available
    if (item!.colors.isNotEmpty && _selectedColor == null) {
      _showSnackBar('يرجى اختيار اللون أولاً', isError: true);
      return;
    }

    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (_, __, ___) => AbayaMeasureScreen(
          item: item!,
          selectedColor: _selectedColor,
        ),
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOut)),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Overlay App Bar
// ═══════════════════════════════════════════════════════════════════════════

class _OverlayAppBar extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onShare;

  const _OverlayAppBar({
    required this.onBack,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(_DS.lg, _DS.md, _DS.lg, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back button - uses arrow_back which auto-mirrors for RTL
            _GlassIconButton(
              icon: Icons.arrow_back_rounded,
              onTap: onBack,
            ),
            _GlassIconButton(
              icon: Icons.ios_share_rounded,
              onTap: onShare,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Glass Icon Button
// ═══════════════════════════════════════════════════════════════════════════

class _GlassIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GlassIconButton({
    required this.icon,
    required this.onTap,
  });

  @override
  State<_GlassIconButton> createState() => _GlassIconButtonState();
}

class _GlassIconButtonState extends State<_GlassIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.9).animate(
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
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                widget.icon,
                size: 20,
                color: _DS.darkText,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Image Hero Section
// ═══════════════════════════════════════════════════════════════════════════

class _ImageHero extends StatelessWidget {
  final List<String> images;
  final String heroTag;
  final double height;
  final int currentIndex;
  final PageController pageController;
  final ValueChanged<int> onPageChanged;
  final bool isFavorite;
  final bool isLoadingFavorite;
  final bool isInitialized;
  final VoidCallback onFavoriteTap;

  const _ImageHero({
    required this.images,
    required this.heroTag,
    required this.height,
    required this.currentIndex,
    required this.pageController,
    required this.onPageChanged,
    required this.isFavorite,
    required this.isLoadingFavorite,
    required this.isInitialized,
    required this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        children: [
          // Image PageView
          PageView.builder(
            controller: pageController,
            itemCount: images.length,
            onPageChanged: onPageChanged,
            itemBuilder: (_, i) {
              final img = AnyImage(
                src: images[i],
                fit: BoxFit.cover,
                borderRadius: BorderRadius.zero,
                backgroundColor: const Color(0xFFF5F5F5),
              );
              return i == 0 ? Hero(tag: heroTag, child: img) : img;
            },
          ),

          // Bottom Gradient Overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 120,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.03),
                    Colors.white.withOpacity(0.5),
                    Colors.white,
                  ],
                  stops: const [0.0, 0.3, 0.7, 1.0],
                ),
              ),
            ),
          ),

          // Favorite Button
          Positioned(
            left: _DS.lg,
            bottom: _DS.xxl,
            child: _FavoriteButton(
              isFavorite: isFavorite,
              isLoading: isLoadingFavorite,
              isInitialized: isInitialized,
              onTap: onFavoriteTap,
            ),
          ),

          // Page Indicators
          if (images.length > 1)
            Positioned(
              bottom: _DS.xxl,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(images.length, (i) {
                  final active = i == currentIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: active
                          ? _DS.primaryBrown
                          : _DS.primaryBrown.withOpacity(0.3),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Favorite Button
// ═══════════════════════════════════════════════════════════════════════════

class _FavoriteButton extends StatefulWidget {
  final bool isFavorite;
  final bool isLoading;
  final bool isInitialized;
  final VoidCallback onTap;

  const _FavoriteButton({
    required this.isFavorite,
    required this.isLoading,
    required this.isInitialized,
    required this.onTap,
  });

  @override
  State<_FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<_FavoriteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scale = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_FavoriteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFavorite != oldWidget.isFavorite) {
      _controller.forward().then((_) => _controller.reverse());
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isInitialized ? widget.onTap : null,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: widget.isLoading
              ? const Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(_DS.primaryBrown),
                    ),
                  ),
                )
              : Icon(
                  widget.isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_outline_rounded,
                  size: 26,
                  color: widget.isFavorite ? Colors.red : _DS.mediumText,
                ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Info Sheet
// ═══════════════════════════════════════════════════════════════════════════

class _InfoSheet extends StatelessWidget {
  final AbayaItem item;
  final String formattedPrice;
  final Color? selectedColor;
  final ValueChanged<Color> onColorSelected;

  const _InfoSheet({
    required this.item,
    required this.formattedPrice,
    required this.selectedColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      transform: Matrix4.translationValues(0, -_DS.xxl, 0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(_DS.radiusSheet),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 20,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(_DS.xxl, _DS.xxxl, _DS.xxl, _DS.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Chip
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: _DS.md,
                vertical: _DS.sm - 2,
              ),
              decoration: BoxDecoration(
                color: _DS.primaryBrown.withOpacity(0.1),
                borderRadius: BorderRadius.circular(_DS.radiusMd),
              ),
              child: Text(
                item.subtitle.isNotEmpty ? item.subtitle : 'عباية',
                style: const TextStyle(
                  color: _DS.primaryBrown,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            const SizedBox(height: _DS.md),

            // Title & Price Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: _DS.darkText,
                      height: 1.2,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(width: _DS.lg),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formattedPrice,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: _DS.primaryBrown,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'شامل الضريبة',
                      style: TextStyle(
                        fontSize: 11,
                        color: _DS.lightText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: _DS.xxl),

            // Colors Section with Selection
            if (item.colors.isNotEmpty) ...[
              Row(
                children: [
                  const Text(
                    'الألوان المتاحة',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _DS.darkText,
                    ),
                  ),
                  if (selectedColor == null) ...[
                    const SizedBox(width: _DS.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: _DS.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(_DS.sm),
                      ),
                      child: const Text(
                        'مطلوب',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: _DS.md),
              Wrap(
                spacing: _DS.md,
                runSpacing: _DS.md,
                children: item.colors.map((color) {
                  final isSelected = selectedColor?.value == color.value;
                  return _ColorOptionDot(
                    color: color,
                    isSelected: isSelected,
                    onTap: () => onColorSelected(color),
                  );
                }).toList(),
              ),
              const SizedBox(height: _DS.xxl),
            ],

            // Features
            _buildFeatureRow(Icons.verified_outlined, 'جودة عالية مضمونة'),
            const SizedBox(height: _DS.md),
            _buildFeatureRow(Icons.local_shipping_outlined, 'توصيل سريع'),
            const SizedBox(height: _DS.md),
            _buildFeatureRow(Icons.replay_outlined, 'استرجاع خلال 14 يوم'),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(_DS.sm),
          ),
          child: Icon(icon, size: 16, color: _DS.mediumText),
        ),
        const SizedBox(width: _DS.md),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            color: _DS.mediumText,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Color Option Dot (Reusable)
// ═══════════════════════════════════════════════════════════════════════════

class _ColorOptionDot extends StatefulWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorOptionDot({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_ColorOptionDot> createState() => _ColorOptionDotState();
}

class _ColorOptionDotState extends State<_ColorOptionDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_ColorOptionDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _controller.forward().then((_) => _controller.reverse());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLight = widget.color.computeLuminance() > 0.7;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          // Min tap area 44x44
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: widget.isSelected ? _DS.primaryBrown : Colors.transparent,
              width: 2.5,
            ),
          ),
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              width: widget.isSelected ? 32 : 36,
              height: widget.isSelected ? 32 : 36,
              decoration: BoxDecoration(
                color: widget.color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isLight ? const Color(0xFFE5E7EB) : Colors.transparent,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        widget.color.withOpacity(widget.isSelected ? 0.5 : 0.3),
                    blurRadius: widget.isSelected ? 10 : 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: widget.isSelected
                  ? Icon(
                      Icons.check_rounded,
                      size: 18,
                      color: isLight ? _DS.darkText : Colors.white,
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Sticky Actions
// ═══════════════════════════════════════════════════════════════════════════

class _StickyActions extends StatelessWidget {
  final VoidCallback onAddToCart;
  final VoidCallback onOrderNow;

  const _StickyActions({
    required this.onAddToCart,
    required this.onOrderNow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        _DS.xxl,
        _DS.lg,
        _DS.xxl,
        _DS.lg + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Add to Cart - Outlined
          Expanded(
            child: _PremiumButton(
              label: 'أضف للسلة',
              icon: Icons.shopping_bag_outlined,
              isOutlined: true,
              onTap: onAddToCart,
            ),
          ),
          const SizedBox(width: _DS.md),
          // Order Now - Filled
          Expanded(
            flex: 2,
            child: _PremiumButton(
              label: 'اطلب الآن',
              onTap: onOrderNow,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Premium Button
// ═══════════════════════════════════════════════════════════════════════════

class _PremiumButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final bool isOutlined;
  final VoidCallback onTap;

  const _PremiumButton({
    required this.label,
    this.icon,
    this.isOutlined = false,
    required this.onTap,
  });

  @override
  State<_PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<_PremiumButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(
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
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            color: widget.isOutlined ? Colors.transparent : _DS.primaryBrown,
            borderRadius: BorderRadius.circular(_DS.radiusLg),
            border: widget.isOutlined
                ? Border.all(color: const Color(0xFFE5E7EB), width: 1.5)
                : null,
            boxShadow: widget.isOutlined
                ? null
                : [
                    BoxShadow(
                      color: _DS.primaryBrown.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  size: 20,
                  color: widget.isOutlined ? _DS.darkText : Colors.white,
                ),
                const SizedBox(width: _DS.sm),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: widget.isOutlined ? _DS.darkText : Colors.white,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
