// lib/features/stores/presentation/stores_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/store.dart';
import '../services/stores_service.dart';
import 'trader_products_screen.dart';

/// شاشة المتاجر - تصميم مشابه للصورة
class StoresScreen extends StatefulWidget {
  const StoresScreen({super.key});

  @override
  State<StoresScreen> createState() => _StoresScreenState();
}

class _StoresScreenState extends State<StoresScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _search = TextEditingController();
  final _storesService = StoresService();

  List<Store> _all = [];
  List<Store> _shown = [];
  bool _isLoading = true;
  String _selectedCategory = 'الكل';
  StreamSubscription<List<Store>>? _subscription;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  // الفئات
  final List<String> _categories = [
    'الكل',
    'ملابس',
    'إلكترونيات',
    'أثاث',
    'مجوهرات',
  ];

  // ألوان التصميم - Light Theme مع تدرجات احترافية
  static const _primaryPurple = Color(0xFF667EEA);
  static const _primaryBlue = Color(0xFF764BA2);
  static const _bgColor = Color(0xFFF8FAFC);
  static const _cardBg = Colors.white;
  static const _textPrimary = Color(0xFF1E293B);
  static const _textSecondary = Color(0xFF64748B);

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

    _loadStores();
  }

  void _loadStores() {
    _subscription = _storesService.getStores().listen(
      (stores) {
        if (mounted) {
          setState(() {
            _all = stores;
            _isLoading = false;
            _applyFilters();
          });
          _animController.forward();
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() => _isLoading = false);
        }
        debugPrint('خطأ في جلب المتاجر: $error');
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _search.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final q = _search.text.trim().toLowerCase();
    List<Store> list = _all;

    // فلتر البحث
    if (q.isNotEmpty) {
      list = list
          .where((s) =>
              s.name.toLowerCase().contains(q) ||
              s.location.toLowerCase().contains(q) ||
              s.category.toLowerCase().contains(q))
          .toList();
    }

    // فلتر الفئة
    if (_selectedCategory != 'الكل') {
      list = list.where((s) => s.category == _selectedCategory).toList();
    }

    setState(() => _shown = list);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _bgColor,
        body: _isLoading
            ? _buildLoadingState()
            : SafeArea(
                child: Column(
                  children: [
                    // Header مع التدرج
                    _buildHeader(),

                    // شريط البحث
                    _buildSearchBar(),

                    // فلاتر الفئات
                    _buildCategoryFilters(),

                    // عدد المتاجر
                    _buildStoreCount(),

                    // قائمة المتاجر
                    Expanded(
                      child: _shown.isEmpty
                          ? _buildEmptyState()
                          : _buildStoresList(),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [_primaryPurple, _primaryBlue],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Row(
            children: [
              // زر الرجوع
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.maybePop(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const Spacer(),
              // العنوان والأيقونة
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.store_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'اكتشف أفضل للمتاجر',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // أيقونة الفلتر
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  // يمكن إضافة وظيفة الفلتر هنا لاحقاً
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.tune_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _search,
        onChanged: (_) {
          setState(() {});
          _applyFilters();
        },
        decoration: InputDecoration(
          hintText: 'ابحث عن متجر...',
          hintStyle: TextStyle(
            color: _textSecondary.withOpacity(0.6),
            fontSize: 15,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: _primaryPurple,
            size: 22,
          ),
          suffixIcon: _search.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, color: _textSecondary),
                  onPressed: () {
                    _search.clear();
                    setState(() {});
                    _applyFilters();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return Container(
      height: 56,
      margin: const EdgeInsets.only(top: 4),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = cat == _selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedCategory = cat);
                _applyFilters();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [_primaryPurple, _primaryBlue],
                        )
                      : null,
                  color: isSelected ? null : _cardBg,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : _textSecondary.withOpacity(0.2),
                    width: 1.5,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: _primaryPurple.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  cat,
                  style: TextStyle(
                    color: isSelected ? Colors.white : _textPrimary,
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStoreCount() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _primaryPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_shown.length} متجر',
              style: const TextStyle(
                color: _primaryPurple,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoresList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      physics: const BouncingScrollPhysics(),
      itemCount: _shown.length,
      itemBuilder: (context, index) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: _StoreCard(
            store: _shown[index],
            onTap: () => _openStore(_shown[index]),
          ),
        );
      },
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
                colors: [_primaryPurple, _primaryBlue],
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
            'جاري تحميل المتاجر...',
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _primaryPurple.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.store_outlined,
              size: 56,
              color: _primaryPurple,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'لا توجد متاجر',
            style: TextStyle(
              color: _textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'جرب البحث بكلمات مختلفة',
            style: TextStyle(
              color: _textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _openStore(Store store) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TraderProductsScreen(store: store),
      ),
    );
  }
}

/* ========================= Store Card ========================= */

class _StoreCard extends StatefulWidget {
  final Store store;
  final VoidCallback onTap;

  const _StoreCard({
    required this.store,
    required this.onTap,
  });

  @override
  State<_StoreCard> createState() => _StoreCardState();
}

class _StoreCardState extends State<_StoreCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  // ألوان متدرجة للبطاقات
  static const List<List<Color>> _cardGradients = [
    [Color(0xFF3B82F6), Color(0xFF2563EB)], // أزرق
    [Color(0xFF8B5CF6), Color(0xFF7C3AED)], // بنفسجي
    [Color(0xFF10B981), Color(0xFF059669)], // أخضر
    [Color(0xFFF59E0B), Color(0xFFD97706)], // برتقالي
  ];

  List<Color> get _gradient {
    final index = widget.store.name.hashCode.abs() % _cardGradients.length;
    return _cardGradients[index];
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _isNetworkPath(String? p) =>
      p != null && (p.startsWith('http://') || p.startsWith('https://'));

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final colors = _gradient;
    final firstLetter =
        store.name.isNotEmpty ? store.name[0].toUpperCase() : 'M';

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
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: _StoresScreenState._cardBg,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // الجزء العلوي - التدرج مع الحرف
              Container(
                height: 180,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: colors,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Stack(
                  children: [
                    // صورة المتجر أو الحرف
                    Positioned.fill(
                      child: store.imageUrl != null &&
                              store.imageUrl!.isNotEmpty &&
                              _isNetworkPath(store.imageUrl)
                          ? ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                              child: CachedNetworkImage(
                                imageUrl: store.imageUrl!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                placeholder: (context, url) => Container(
                                  color: colors[0].withOpacity(0.3),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                                errorWidget: (_, __, ___) => Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topRight,
                                      end: Alignment.bottomLeft,
                                      colors: colors,
                                    ),
                                  ),
                                  child: _buildLetter(firstLetter, colors),
                                ),
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topRight,
                                  end: Alignment.bottomLeft,
                                  colors: colors,
                                ),
                              ),
                              child: _buildLetter(firstLetter, colors),
                            ),
                    ),
                    // شارة الحالة
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: store.isOpen
                              ? const Color(0xFF10B981)
                              : Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: store.isOpen
                                    ? Colors.white
                                    : const Color(0xFFEF4444),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              store.isOpen ? 'مفتوح' : 'مغلق',
                              style: TextStyle(
                                color: store.isOpen
                                    ? Colors.white
                                    : const Color(0xFFEF4444),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // الجزء السفلي - المعلومات
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // اسم المتجر
                    Text(
                      store.name,
                      style: const TextStyle(
                        color: _StoresScreenState._textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // الموقع
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 16,
                          color: colors[0],
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            store.location,
                            style: const TextStyle(
                              color: _StoresScreenState._textSecondary,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // عدد المنتجات والهاتف
                    Row(
                      children: [
                        // عدد المنتجات
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: colors[0].withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.inventory_2_rounded,
                                size: 16,
                                color: colors[0],
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${store.productsCount} منتج',
                                style: TextStyle(
                                  color: colors[0],
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (store.isVerified) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.verified_rounded,
                                  size: 16,
                                  color: Color(0xFF10B981),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'موثق',
                                  style: TextStyle(
                                    color: Color(0xFF10B981),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    // الصف السفلي
                    Row(
                      children: [
                        // أيقونة الهاتف
                        if (store.phone != null && store.phone!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _StoresScreenState._bgColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.phone_rounded,
                              size: 18,
                              color: colors[0],
                            ),
                          ),
                        const Spacer(),
                        // زر عرض المتجر
                        GestureDetector(
                          onTap: widget.onTap,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: colors,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'عرض المتجر',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
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
      ),
    );
  }

  Widget _buildLetter(String letter, List<Color> colors) {
    return Center(
      child: Text(
        letter,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 72,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
