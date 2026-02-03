// lib/features/stores/presentation/store_product_preview_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// نموذج المنتج
import '../../catalog/models/abaya_item.dart';
import '../services/stores_service.dart';

// الودجت الذكي للصور
import '../../../shared/widgets/any_image.dart';

// حالة السلة
import '../../../core/state/cart_scope.dart';
import '../../cart/presentation/cart_screen.dart';

// خدمة المفضلة
import '../../favorites/services/favorite_service.dart';
import '../../auth/providers/auth_provider.dart';

/// صفحة تفاصيل منتج المتجر - خاصة بقسم المتاجر
class StoreProductPreviewScreen extends StatefulWidget {
  final String productId;
  final String? traderId;  // معرف التاجر (اختياري)

  const StoreProductPreviewScreen({
    super.key,
    required this.productId,
    this.traderId,
  });

  @override
  State<StoreProductPreviewScreen> createState() => _StoreProductPreviewScreenState();
}

class _StoreProductPreviewScreenState extends State<StoreProductPreviewScreen>
    with TickerProviderStateMixin {
  late final PageController _pc;
  int _index = 0;
  bool _wish = false;
  bool _isLoadingFavorite = false;
  bool _isLoadingProduct = true;
  String? _error;

  final _favoriteService = FavoriteService();
  final _storesService = StoresService();
  StreamSubscription<AbayaItem?>? _productSubscription;

  AbayaItem? item;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // ألوان التصميم - Light Theme للمتاجر
  static const _primaryBlue = Color(0xFF3B82F6);
  static const _primaryPurple = Color(0xFF8B5CF6);
  static const _bgLight = Color(0xFFF8FAFC);
  static const _cardLight = Colors.white;
  static const _textPrimary = Color(0xFF1E293B);
  static const _textSecondary = Color(0xFF64748B);

  @override
  void initState() {
    super.initState();
    _pc = PageController();

    // Initialize animations
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _loadProduct();
  }

  void _loadProduct() {
    _storesService.getProductById(widget.productId).then((product) {
      if (mounted) {
        setState(() {
          item = product;
          _isLoadingProduct = false;
          _error = product == null ? 'المنتج غير موجود' : null;
        });
        if (product != null) {
          _checkFavoriteStatus();
          _fadeController.forward();
          _slideController.forward();

          try {
            _productSubscription?.cancel();
                _productSubscription = _storesService
                    .getProductByIdStream(widget.productId)
                .listen(
              (updatedProduct) {
                if (mounted && updatedProduct != null) {
                  setState(() {
                    item = updatedProduct;
                  });
                }
              },
              onError: (error) {
                print('خطأ في تحديث المنتج: $error');
              },
            );
          } catch (e) {
            print('لا يمكن الاستماع لتحديثات المنتج: $e');
          }
        }
      }
    }).catchError((error) {
      if (mounted) {
        setState(() {
          _isLoadingProduct = false;
          _error = 'حدث خطأ في تحميل المنتج';
        });
        print('خطأ في جلب المنتج: $error');
      }
    });
  }

  Future<void> _checkFavoriteStatus() async {
    if (item == null) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (!authProvider.isAuthenticated) {
        if (mounted) {
          setState(() {
            _wish = false;
          });
        }
        return;
      }

      try {
        final isFav = await _favoriteService.isFavorite(
          productId: item!.id,
          productType: 'store_product',
        );
        if (mounted) {
          setState(() {
            _wish = isFav;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _wish = false;
          });
        }
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

    try {
      if (_wish) {
        final removed = await _favoriteService.removeFromFavorites(
          productId: item!.id,
          productType: 'store_product',
        );
        if (mounted && removed) {
          setState(() => _wish = false);
          _showSnackBar('تم إزالة من المفضلة');
        }
      } else {
        final added = await _favoriteService.addToFavorites(
          productId: item!.id,
          productType: 'store_product',
          productData: {
            'name': item!.title,
            'title': item!.title,
            'subtitle': item!.subtitle,
            'imageUrl': item!.imageUrl,
            'gallery': item!.gallery,
            'price': item!.price,
            'colors': item!.colors.map((c) => c.value).toList(),
            'isNew': item!.isNew,
            'type': 'منتج متجر',
          },
        );
        if (mounted && added) {
          setState(() => _wish = true);
          _showSnackBar('تمت الإضافة للمفضلة', isSuccess: true);
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('حدث خطأ: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingFavorite = false);
      }
    }
  }

  void _showSnackBar(String message,
      {bool isSuccess = false, bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess
                  ? Icons.check_circle_rounded
                  : isError
                      ? Icons.error_outline_rounded
                      : Icons.info_outline_rounded,
              color: Colors.white,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            isSuccess ? Colors.green : (isError ? Colors.red : _primaryBlue),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _pc.dispose();
    _productSubscription?.cancel();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  String _price(double v) =>
      v == v.truncateToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _bgLight,
        body: _isLoadingProduct
            ? _buildLoadingState()
            : _error != null
                ? _buildErrorState()
                : item == null
                    ? _buildErrorState()
                    : _buildContent(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_primaryBlue, _primaryPurple],
              ),
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'جاري تحميل المنتج...',
            style: TextStyle(
              color: _textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _primaryBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  size: 64,
                  color: _primaryBlue,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _error ?? 'المنتج غير موجود',
                style: const TextStyle(
                  color: _textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'حدث خطأ في تحميل المنتج',
                style: TextStyle(
                  color: _textSecondary,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isLoadingProduct = true;
                    _error = null;
                  });
                  _loadProduct();
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('إعادة المحاولة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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
    final images = [item!.imageUrl, ...item!.gallery].where((i) => i.isNotEmpty).toList();
    if (images.isEmpty) images.add('');

    return SafeArea(
      bottom: false,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              // Header
              _buildHeader(),

              // صور المنتج
              Expanded(
                child: PageView.builder(
                  controller: _pc,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemCount: images.length,
                  itemBuilder: (context, i) {
                    return Container(
                      color: _cardLight,
                      child: AnyImage(
                        src: images[i],
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    );
                  },
                ),
              ),

              // مؤشرات الصور
              if (images.length > 1) _buildImageIndicators(images.length),

              // معلومات المنتج
              _buildProductInfo(),

              // الأزرار
              _buildBottomButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _cardLight,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.maybePop(context),
            color: _textPrimary,
          ),
          const Spacer(),
          // أيقونة المفضلة
          IconButton(
            icon: _isLoadingFavorite
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    _wish
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: _wish ? Colors.red : _textPrimary,
                  ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
    );
  }

  Widget _buildImageIndicators(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(count, (i) {
          final isActive = i == _index;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: isActive
                  ? _primaryBlue
                  : _textSecondary.withOpacity(0.3),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildProductInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان
          Text(
            item!.title,
            style: const TextStyle(
              color: _textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              height: 1.3,
            ),
          ),
          if (item!.subtitle.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              item!.subtitle,
              style: const TextStyle(
                color: _textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: 20),
          // السعر
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_primaryBlue, _primaryPurple],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.diamond_rounded,
                  size: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _price(item!.price),
                style: const TextStyle(
                  color: _textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'ر.ع',
                style: TextStyle(
                  color: _textSecondary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: _cardLight,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // زر إضافة للسلة
            Expanded(
              flex: 2,
              child: _buildAddToCartButton(),
            ),
            const SizedBox(width: 12),
            // زر طلب الآن
            Expanded(
              flex: 3,
              child: _buildOrderButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddToCartButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _primaryBlue.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            try {
              final cartState = CartScope.of(context);
              cartState.addAbayaItem(
                id: item!.id,
                title: item!.title,
                price: item!.price,
                imageUrl: item!.imageUrl,
                subtitle: item!.subtitle,
              );
              _showSnackBar(
                  'تمت إضافة ${item!.title} إلى السلة',
                  isSuccess: true);
            } catch (e) {
              _showSnackBar('حدث خطأ: $e', isError: true);
            }
          },
          borderRadius: BorderRadius.circular(14),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Icon(
              Icons.shopping_bag_outlined,
              color: _primaryBlue,
              size: 26,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_primaryBlue, _primaryPurple],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _primaryBlue.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            try {
              // إضافة المنتج للسلة
              final cartState = CartScope.of(context);
              cartState.addAbayaItem(
                id: item!.id,
                title: item!.title,
                price: item!.price,
                imageUrl: item!.imageUrl,
                subtitle: item!.subtitle,
              );
              
              // فتح صفحة السلة
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CartScreen(),
                ),
              );
              
              _showSnackBar(
                'تمت إضافة ${item!.title} إلى السلة',
                isSuccess: true,
              );
            } catch (e) {
              _showSnackBar('حدث خطأ: $e', isError: true);
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_cart_checkout_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                SizedBox(width: 10),
                Text(
                  'اطلب الآن',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

