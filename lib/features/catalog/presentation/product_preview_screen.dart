import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// نموذج العباية
import '../models/abaya_item.dart';
import '../services/abaya_service.dart';

// شاشة أخذ المقاسات
import '../../../measurements/presentation/abaya_measure_screen.dart';

// الودجت الذكي للصور
import '../../../shared/widgets/any_image.dart';

// حالة السلة
import '../../../core/state/cart_scope.dart';

// خدمة المفضلة
import '../../favorites/services/favorite_service.dart';
import '../../auth/providers/auth_provider.dart';

class ProductPreviewScreen extends StatefulWidget {
  final String productId;

  const ProductPreviewScreen({
    super.key,
    required this.productId,
  });

  @override
  State<ProductPreviewScreen> createState() => _ProductPreviewScreenState();
}

class _ProductPreviewScreenState extends State<ProductPreviewScreen> {
  late final PageController _pc;
  int _index = 0;
  bool _wish = false;
  bool _isLoadingFavorite = false;
  bool _isInitialized = false;
  bool _isLoadingProduct = true;
  String? _error;

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
    // جلب المنتج من Firebase
    _abayaService.getProductById(widget.productId).then((product) {
      if (mounted) {
        setState(() {
          item = product;
          _isLoadingProduct = false;
          _error = product == null ? 'المنتج غير موجود' : null;
        });
        if (product != null) {
          _checkFavoriteStatus();
          
          // بعد جلب المنتج بنجاح، نستمع لتحديثاته إذا كان في collection عام
          try {
            _productSubscription?.cancel();
            _productSubscription = _abayaService
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
            // إذا فشل Stream (مثلاً المنتج في subcollection)، لا بأس
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
          _isInitialized = true;
        });
      }
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
    } catch (e) {
      if (mounted) {
        setState(() {
          _wish = false;
          _isInitialized = true;
        });
      }
    }
  }

  Future<void> _toggleFavorite() async {
    if (item == null) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى تسجيل الدخول أولاً'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_isLoadingFavorite) return;
    setState(() => _isLoadingFavorite = true);

    try {
      if (_wish) {
        final removed = await _favoriteService.removeFromFavorites(
          productId: item!.id,
          productType: 'abaya',
        );
        if (mounted && removed) {
          setState(() => _wish = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إزالة من المفضلة'),
              duration: Duration(seconds: 2),
            ),
          );
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تمت الإضافة للمفضلة'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingFavorite = false);
      }
    }
  }

  @override
  void dispose() {
    _pc.dispose();
    _productSubscription?.cancel();
    super.dispose();
  }

  String _price(double v) =>
      '${v == v.truncateToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2)} ر.ع';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    
    // حالة التحميل
    if (_isLoadingProduct) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.maybePop(context),
            ),
          ),
          body: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    // حالة الخطأ أو المنتج غير موجود
    if (_error != null || item == null) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.maybePop(context),
            ),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  _error ?? 'المنتج غير موجود',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isLoadingProduct = true;
                      _error = null;
                    });
                    _loadProduct();
                  },
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final heroTag = 'product-${widget.productId}';
    final images = item!.gallery.isEmpty
        ? <String>[item!.imageUrl]
        : item!.gallery;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: cs.surface,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.maybePop(context),
          ),
          title: const Text(''),
          actions: [
            IconButton(
              icon: const Icon(Icons.ios_share_rounded),
              onPressed: () {},
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pc,
                    itemCount: images.length,
                    onPageChanged: (i) => setState(() => _index = i),
                    itemBuilder: (_, i) {
                      final img = Center(
                        child: AnyImage(
                          src: images[i],
                          fit: BoxFit.cover, // تغيير من contain إلى cover لملء المساحة
                          width: double.infinity, // ملء العرض بالكامل
                          height: double.infinity, // ملء الارتفاع بالكامل
                        ),
                      );
                      return i == 0 ? Hero(tag: heroTag, child: img) : img;
                    },
                  ),
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: Material(
                      color: Colors.white.withOpacity(0.9),
                      shape: const CircleBorder(),
                      elevation: 2,
                      shadowColor: Colors.black.withOpacity(0.2),
                      child: IconButton(
                        onPressed: _isInitialized ? _toggleFavorite : null,
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
                                color: _wish ? Colors.red : cs.onSurface,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(images.length, (i) {
                  final active = i == _index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: cs.onSurface),
                      color: active ? cs.onSurface : Colors.transparent,
                    ),
                  );
                }),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item!.subtitle.toUpperCase(),
                          style: TextStyle(
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item!.title,
                          style: TextStyle(
                            color: cs.onSurface,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _price(item!.price),
                    style: TextStyle(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            decoration: BoxDecoration(
              color: cs.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, -2),
                )
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: item == null
                        ? null
                        : () {
                            try {
                              final cartState = CartScope.of(context);
                              cartState.addAbayaItem(
                                id: item!.id,
                                title: item!.title,
                                price: item!.price,
                                imageUrl: item!.imageUrl,
                                subtitle: item!.subtitle,
                              );
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        const Icon(
                                          Icons.check_circle,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'تمت إضافة ${item!.title} إلى السلة',
                                            style: const TextStyle(fontSize: 14),
                                          ),
                                        ),
                                      ],
                                    ),
                                    duration: const Duration(seconds: 2),
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: Colors.green,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('حدث خطأ: $e'),
                                    backgroundColor: Colors.red,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            }
                          },
                    icon: const Icon(Icons.shopping_bag_outlined),
                    label: const Text('أضف للسلة'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: item == null ? null : () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AbayaMeasureScreen(item: item!),
                        ),
                      );

                      if (!mounted) return;
                      // الطلب يتم إرساله تلقائياً من صفحة المقاسات
                      // measurements != null يعني أن الطلب تم إرساله بنجاح
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color(0xFF6D4C41),
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontWeight: FontWeight.w800),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('اطلب الآن'),
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
