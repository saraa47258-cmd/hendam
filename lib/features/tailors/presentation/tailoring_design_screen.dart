import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../services/fabric_service.dart';
import '../services/embroidery_service.dart';
import '../models/embroidery_design.dart';
import '../../orders/services/order_service.dart';
import '../../orders/models/order_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../measurements/models/measurement_profile.dart';
import '../../../shared/widgets/gift_recipient_bottom_sheet.dart';
import '../../../l10n/app_localizations.dart';

bool _isNetworkPath(String p) =>
    p.startsWith('http://') || p.startsWith('https://');

// ═══════════════════════════════════════════════════════════════════════════
// PREMIUM DESIGN SYSTEM - Luxury Tailoring App
// Calm, Confident, Modern, Elegant, Timeless
// ═══════════════════════════════════════════════════════════════════════════

/// Premium color palette - Refined, elegant colors
class _DesignTokens {
  // Primary palette - Deep sophisticated blue
  static const Color primaryDark = Color(0xFF1A2F4B);
  static const Color primary = Color(0xFF2C4A6E);
  static const Color primaryLight = Color(0xFF4A6B8F);
  static const Color primarySoft = Color(0xFF6B8AAE);

  // Accent - Warm gold for elegance
  static const Color accent = Color(0xFFB8860B);
  static const Color accentLight = Color(0xFFD4A84B);

  // Surfaces - Clean, calm backgrounds
  static const Color surfacePure = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFFAFBFC);
  static const Color surfaceMuted = Color(0xFFF5F7FA);
  static const Color surfaceDim = Color(0xFFEEF1F5);

  // Text hierarchy
  static const Color textPrimary = Color(0xFF1A1F2E);
  static const Color textSecondary = Color(0xFF4A5568);
  static const Color textTertiary = Color(0xFF718096);
  static const Color textMuted = Color(0xFFA0AEC0);

  // Borders - Subtle, refined
  static const Color borderLight = Color(0xFFF0F2F5);
  static const Color borderDefault = Color(0xFFE2E8F0);
  static const Color borderStrong = Color(0xFFCBD5E0);

  // Semantic colors
  static const Color success = Color(0xFF38A169);
  static const Color warning = Color(0xFFD69E2E);
  static const Color error = Color(0xFFE53E3E);

  // Spacing scale
  static const double spaceXS = 4.0;
  static const double spaceSM = 8.0;
  static const double spaceMD = 16.0;
  static const double spaceLG = 24.0;
  static const double spaceXL = 32.0;
  static const double space2XL = 48.0;

  // Border radius scale
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 20.0;
  static const double radius2XL = 24.0;
}

/// ===== وحدات القياس =====
enum MeasurementUnit { cm, inch }

extension MeasurementUnitX on MeasurementUnit {
  String get labelAr => this == MeasurementUnit.cm ? 'سم' : 'إنش';
  String get labelEn => this == MeasurementUnit.cm ? 'cm' : 'in';
}

const double _cmPerInch = 2.54;

// ═══════════════════════════════════════════════════════════════════════════
// MAIN SCREEN - Premium Tailoring Experience
// ═══════════════════════════════════════════════════════════════════════════

class TailoringDesignScreen extends StatefulWidget {
  final String tailorId;
  final String tailorName;
  final double basePriceOMR;
  final List<FabricItem>? fabrics;
  final String? customerId;
  final String? customerName;
  final String? customerPhone;

  const TailoringDesignScreen({
    super.key,
    required this.tailorId,
    required this.tailorName,
    this.basePriceOMR = 6.0,
    this.fabrics,
    this.customerId,
    this.customerName,
    this.customerPhone,
  });

  @override
  State<TailoringDesignScreen> createState() => _TailoringDesignScreenState();
}

class _TailoringDesignScreenState extends State<TailoringDesignScreen>
    with TickerProviderStateMixin {
  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _lengthCtrl = TextEditingController();
  final _shoulderCtrl = TextEditingController();
  final _sleeveCtrl = TextEditingController();
  final _upperSleeveCtrl = TextEditingController();
  final _lowerSleeveCtrl = TextEditingController();
  final _chestCtrl = TextEditingController();
  final _waistCtrl = TextEditingController();
  final _neckCtrl = TextEditingController();
  final _embroideryCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  // Navigation state
  final _pageController = PageController();
  int _currentStep = 0;

  // Selection state
  String? _fabricType;
  String? _fabricThumb;
  String? _selectedFabricId;
  Color _embroideryColor = const Color(0xFF4A5568);
  int _embroideryLines = 0;
  EmbroideryDesign? _selectedEmbroidery;
  MeasurementUnit _unit = MeasurementUnit.cm;

  // Gift feature state
  bool _isGift = false;
  GiftRecipientDetails? _giftRecipientDetails;

  // Animation controllers
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutQuart,
    );
    _fadeController.forward();

    // Set status bar style
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
  }

  double get _totalPrice {
    double price = widget.basePriceOMR;
    if (_fabricType == 'فاخر') price += 1.500;
    if (_fabricType == 'شتوي') price += 0.800;
    price += (_embroideryLines * 0.250);
    if (_selectedEmbroidery != null && _selectedEmbroidery!.price > 0) {
      price += _selectedEmbroidery!.price;
    }
    return price;
  }

  String _getColorName(Color color) {
    const names = {
      0xFF1A2F4B: 'كحلي',
      0xFF2C4A6E: 'أزرق',
      0xFF4A5568: 'رمادي',
      0xFF38A169: 'أخضر',
      0xFFB8860B: 'ذهبي',
      0xFF8B4513: 'بني',
      0xFF553C9A: 'بنفسجي',
      0xFF1A1F2E: 'أسود',
      0xFFC0C0C0: 'فضي',
    };
    return names[color.value] ?? 'لون مخصص';
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pageController.dispose();
    for (final c in [
      _lengthCtrl,
      _shoulderCtrl,
      _sleeveCtrl,
      _upperSleeveCtrl,
      _lowerSleeveCtrl,
      _chestCtrl,
      _waistCtrl,
      _neckCtrl,
      _embroideryCtrl,
      _notesCtrl
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════════
  // NAVIGATION
  // ═══════════════════════════════════════════════════════════════════════

  Future<void> _goToNextStep() async {
    FocusScope.of(context).unfocus();
    await Future.delayed(const Duration(milliseconds: 100));

    if (!_validateCurrentStep()) return;

    if (_currentStep < 2) {
      setState(() => _currentStep++);
      await _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
      HapticFeedback.lightImpact();
    } else {
      _showOrderReview();
    }
  }

  Future<void> _goToPreviousStep() async {
    FocusScope.of(context).unfocus();

    if (_currentStep > 0) {
      setState(() => _currentStep--);
      await _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
      HapticFeedback.lightImpact();
    } else {
      Navigator.pop(context);
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        if (_fabricType == null || _selectedFabricId == null) {
          HapticFeedback.mediumImpact();
          _showSnackBar('يرجى اختيار نوع القماش', isError: true);
          return false;
        }
        return true;
      case 1:
        if (!(_formKey.currentState?.validate() ?? false)) {
          HapticFeedback.mediumImpact();
          _showSnackBar('يرجى إدخال المقاسات بشكل صحيح', isError: true);
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  void _switchUnit(MeasurementUnit newUnit) {
    if (newUnit == _unit) return;

    double? convert(String text) {
      final v = double.tryParse(text.trim().replaceAll(',', '.'));
      if (v == null) return null;
      final inCm = _unit == MeasurementUnit.cm ? v : v * _cmPerInch;
      return newUnit == MeasurementUnit.cm ? inCm : (inCm / _cmPerInch);
    }

    void apply(TextEditingController c) {
      final v = convert(c.text);
      if (v == null) return;
      c.text = v.toStringAsFixed(newUnit == MeasurementUnit.cm ? 1 : 2);
    }

    setState(() {
      for (final c in [
        _lengthCtrl,
        _shoulderCtrl,
        _sleeveCtrl,
        _upperSleeveCtrl,
        _lowerSleeveCtrl,
        _chestCtrl,
        _waistCtrl,
        _neckCtrl,
        _embroideryCtrl
      ]) {
        apply(c);
      }
      _unit = newUnit;
    });
    HapticFeedback.selectionClick();
  }

  // ═══════════════════════════════════════════════════════════════════════
  // ORDER SUBMISSION
  // ═══════════════════════════════════════════════════════════════════════

  void _showOrderReview() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _OrderReviewSheet(
        tailorName: widget.tailorName,
        fabricType: _fabricType,
        fabricThumb: _fabricThumb,
        embroideryColor: _embroideryColor,
        embroideryLines: _embroideryLines,
        selectedEmbroidery: _selectedEmbroidery,
        lengthCtrl: _lengthCtrl,
        shoulderCtrl: _shoulderCtrl,
        sleeveCtrl: _sleeveCtrl,
        upperSleeveCtrl: _upperSleeveCtrl,
        lowerSleeveCtrl: _lowerSleeveCtrl,
        chestCtrl: _chestCtrl,
        waistCtrl: _waistCtrl,
        neckCtrl: _neckCtrl,
        embroideryCtrl: _embroideryCtrl,
        notesCtrl: _notesCtrl,
        unit: _unit,
        price: _totalPrice,
        getColorName: _getColorName,
        isGift: _isGift,
        giftRecipientDetails: _giftRecipientDetails,
        onGiftToggle: (value) async {
          if (value && _giftRecipientDetails == null) {
            final result = await GiftRecipientBottomSheet.show(context);
            if (result != null) {
              setState(() {
                _isGift = true;
                _giftRecipientDetails = result;
              });
              if (mounted) Navigator.pop(context);
              _showOrderReview();
            }
          } else {
            setState(() {
              _isGift = value;
              if (!value) _giftRecipientDetails = null;
            });
            if (mounted) Navigator.pop(context);
            _showOrderReview();
          }
        },
        onEditGiftRecipient: () async {
          final result = await GiftRecipientBottomSheet.show(
            context,
            initialData: _giftRecipientDetails,
          );
          if (result != null) {
            setState(() => _giftRecipientDetails = result);
            if (mounted) Navigator.pop(context);
            _showOrderReview();
          }
        },
        onConfirm: _submitOrder,
      ),
    );
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;
    if (_fabricType == null || _selectedFabricId == null) {
      _showSnackBar('يرجى اختيار القماش', isError: true);
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _LoadingOverlay(),
    );

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.currentUser;

      if (currentUser == null) {
        Navigator.pop(context);
        _showSnackBar('يرجى تسجيل الدخول', isError: true);
        return;
      }

      final order = OrderModel(
        id: '',
        customerId: currentUser.uid,
        customerName: currentUser.name,
        customerPhone: currentUser.phoneNumber ?? '+968 00000000',
        tailorId: widget.tailorId,
        tailorName: widget.tailorName,
        fabricId: _selectedFabricId!,
        fabricName: _fabricType!,
        fabricType: _fabricType!,
        fabricImageUrl: _fabricThumb ?? '',
        fabricColor: '5C6BC0',
        fabricColorHex: '#FF5C6BC0',
        measurements: {
          'الطول الكلي': double.tryParse(_lengthCtrl.text) ?? 0.0,
          'الكتف': double.tryParse(_shoulderCtrl.text) ?? 0.0,
          'طول الكم': double.tryParse(_sleeveCtrl.text) ?? 0.0,
          'محيط الكم العلوي': double.tryParse(_upperSleeveCtrl.text) ?? 0.0,
          'محيط الكم السفلي': double.tryParse(_lowerSleeveCtrl.text) ?? 0.0,
          'الصدر': double.tryParse(_chestCtrl.text) ?? 0.0,
          'الخصر': double.tryParse(_waistCtrl.text) ?? 0.0,
          'محيط الرقبة': double.tryParse(_neckCtrl.text) ?? 0.0,
          'التطريز الامامي': double.tryParse(_embroideryCtrl.text) ?? 0.0,
        },
        notes: _notesCtrl.text,
        embroideryDesignId: _selectedEmbroidery?.id,
        embroideryDesignName: _selectedEmbroidery?.name,
        embroideryDesignImageUrl: _selectedEmbroidery?.imageUrl,
        embroideryDesignPrice: _selectedEmbroidery?.price,
        isGift: _isGift,
        giftRecipientDetails: _giftRecipientDetails,
        totalPrice: _totalPrice,
        status: OrderStatus.pending,
        createdAt: DateTime.now(),
      );

      final orderId = await OrderService.submitOrder(order);
      Navigator.pop(context); // Close loading

      if (orderId != null) {
        _showSuccessDialog(orderId);
      } else {
        _showSnackBar('حدث خطأ في إرسال الطلب', isError: true);
      }
    } catch (e) {
      Navigator.pop(context);
      _showSnackBar('حدث خطأ: $e', isError: true);
    }
  }

  void _showSuccessDialog(String orderId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _SuccessDialog(
        orderId: orderId,
        tailorName: widget.tailorName,
        price: _totalPrice,
        onDismiss: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        backgroundColor: isError ? _DesignTokens.error : _DesignTokens.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_DesignTokens.radiusMD),
        ),
        margin: const EdgeInsets.all(_DesignTokens.spaceMD),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return PopScope(
      canPop: _currentStep == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _currentStep > 0) _goToPreviousStep();
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: isDark ? cs.surface : _DesignTokens.surfaceLight,
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // App Bar
                _AppBar(
                  tailorName: widget.tailorName,
                  onBack: () => Navigator.pop(context),
                ),

                // Progress Indicator
                _ProgressIndicator(
                  currentStep: _currentStep,
                  steps: const ['القماش', 'المقاسات و اللون', 'التطريز'],
                ),

                // Content
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _FabricSelectionStep(
                        tailorId: widget.tailorId,
                        selectedType: _fabricType,
                        selectedFabricId: _selectedFabricId,
                        onFabricSelected: (type, thumb, id) => setState(() {
                          _fabricType = type;
                          _fabricThumb = thumb;
                          _selectedFabricId = id;
                        }),
                      ),
                      _MeasurementsStep(
                        formKey: _formKey,
                        unit: _unit,
                        onUnitChanged: _switchUnit,
                        controllers: _MeasurementControllers(
                          length: _lengthCtrl,
                          shoulder: _shoulderCtrl,
                          sleeve: _sleeveCtrl,
                          upperSleeve: _upperSleeveCtrl,
                          lowerSleeve: _lowerSleeveCtrl,
                          chest: _chestCtrl,
                          waist: _waistCtrl,
                          neck: _neckCtrl,
                          embroidery: _embroideryCtrl,
                          notes: _notesCtrl,
                        ),
                      ),
                      _EmbroideryStep(
                        tailorId: widget.tailorId,
                        color: _embroideryColor,
                        lines: _embroideryLines,
                        selectedDesign: _selectedEmbroidery,
                        onColorChanged: (c) =>
                            setState(() => _embroideryColor = c),
                        onLinesChanged: (l) =>
                            setState(() => _embroideryLines = l),
                        onDesignChanged: (d) =>
                            setState(() => _selectedEmbroidery = d),
                      ),
                    ],
                  ),
                ),

                // Bottom Bar
                _BottomActionBar(
                  price: _totalPrice,
                  step: _currentStep,
                  onBack: _goToPreviousStep,
                  onNext: _goToNextStep,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// APP BAR
// ═══════════════════════════════════════════════════════════════════════════

class _AppBar extends StatelessWidget {
  final String tailorName;
  final VoidCallback onBack;

  const _AppBar({required this.tailorName, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.fromLTRB(
        _DesignTokens.spaceLG,
        topPadding + _DesignTokens.spaceMD,
        _DesignTokens.spaceLG,
        _DesignTokens.spaceLG,
      ),
      decoration: BoxDecoration(
        color: isDark ? cs.surface : _DesignTokens.surfacePure,
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? cs.outlineVariant.withOpacity(0.15)
                : _DesignTokens.borderLight,
          ),
        ),
      ),
      child: Row(
        children: [
          // Back button
          _IconButton(
            icon: Icons.arrow_forward_rounded,
            onTap: onBack,
          ),
          const SizedBox(width: _DesignTokens.spaceMD),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tailorName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? cs.onSurface : _DesignTokens.textPrimary,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: isDark
                          ? cs.onSurfaceVariant
                          : _DesignTokens.textTertiary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'مسقط',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? cs.onSurfaceVariant
                            : _DesignTokens.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PROGRESS INDICATOR
// ═══════════════════════════════════════════════════════════════════════════

class _ProgressIndicator extends StatelessWidget {
  final int currentStep;
  final List<String> steps;

  const _ProgressIndicator({required this.currentStep, required this.steps});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        _DesignTokens.spaceLG,
        _DesignTokens.spaceLG,
        _DesignTokens.spaceLG,
        _DesignTokens.spaceMD,
      ),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (index) {
          if (index.isOdd) {
            final beforeStep = index ~/ 2;
            final isActive = beforeStep < currentStep;
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                height: 2,
                margin: const EdgeInsets.symmetric(
                    horizontal: _DesignTokens.spaceSM),
                decoration: BoxDecoration(
                  color: isActive
                      ? (isDark ? cs.primary : _DesignTokens.primary)
                      : (isDark
                          ? cs.outlineVariant.withOpacity(0.2)
                          : _DesignTokens.borderDefault),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            );
          }

          final stepIndex = index ~/ 2;
          final isActive = stepIndex <= currentStep;
          final isCurrent = stepIndex == currentStep;
          final isCompleted = stepIndex < currentStep;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                width: isCurrent ? 34 : 30,
                height: isCurrent ? 34 : 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive
                      ? (isDark ? cs.primary : _DesignTokens.primary)
                      : Colors.transparent,
                  border: Border.all(
                    color: isActive
                        ? (isDark ? cs.primary : _DesignTokens.primary)
                        : (isDark
                            ? cs.outlineVariant
                            : _DesignTokens.borderDefault),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: isCompleted
                      ? Icon(Icons.check_rounded,
                          size: 16, color: isDark ? cs.onPrimary : Colors.white)
                      : Text(
                          '${stepIndex + 1}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isActive
                                ? (isDark ? cs.onPrimary : Colors.white)
                                : (isDark
                                    ? cs.onSurfaceVariant
                                    : _DesignTokens.textTertiary),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: _DesignTokens.spaceSM),
              Text(
                steps[stepIndex],
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                  color: isActive
                      ? (isDark ? cs.primary : _DesignTokens.primary)
                      : (isDark
                          ? cs.onSurfaceVariant
                          : _DesignTokens.textTertiary),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// BOTTOM ACTION BAR
// ═══════════════════════════════════════════════════════════════════════════

class _BottomActionBar extends StatelessWidget {
  final double price;
  final int step;
  final VoidCallback onBack;
  final VoidCallback onNext;

  const _BottomActionBar({
    required this.price,
    required this.step,
    required this.onBack,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(
        _DesignTokens.spaceLG,
        _DesignTokens.spaceMD,
        _DesignTokens.spaceLG,
        bottomPadding + _DesignTokens.spaceMD,
      ),
      decoration: BoxDecoration(
        color: isDark ? cs.surface : _DesignTokens.surfacePure,
        border: Border(
          top: BorderSide(
            color: isDark
                ? cs.outlineVariant.withOpacity(0.15)
                : _DesignTokens.borderLight,
          ),
        ),
      ),
      child: Row(
        children: [
          // Price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'التكلفة التقديرية',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? cs.onSurfaceVariant
                        : _DesignTokens.textTertiary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'ر.ع ${price.toStringAsFixed(3)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isDark ? cs.onSurface : _DesignTokens.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),

          // Back button
          _OutlinedButton(
            label: step == 0 ? 'رجوع' : 'السابق',
            onTap: onBack,
          ),
          const SizedBox(width: _DesignTokens.spaceMD),

          // Next button
          _FilledButton(
            label: step == 2 ? 'إرسال الطلب' : 'التالي',
            icon: step == 2 ? Icons.check_rounded : Icons.arrow_back_rounded,
            onTap: onNext,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// STEP 1: FABRIC SELECTION
// ═══════════════════════════════════════════════════════════════════════════

class _FabricSelectionStep extends StatelessWidget {
  final String tailorId;
  final String? selectedType;
  final String? selectedFabricId;
  final void Function(String? type, String? thumb, String? id) onFabricSelected;

  const _FabricSelectionStep({
    required this.tailorId,
    required this.selectedType,
    required this.selectedFabricId,
    required this.onFabricSelected,
  });

  Widget _buildImage(String? path, ColorScheme cs) {
    if (path == null || path.isEmpty) {
      return Container(
        color: cs.surfaceContainerHighest,
        child: Icon(Icons.image_outlined, color: cs.onSurfaceVariant, size: 32),
      );
    }
    if (_isNetworkPath(path)) {
      return CachedNetworkImage(
        imageUrl: path,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          color: cs.surfaceContainerHighest,
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        errorWidget: (_, __, ___) => Container(
          color: cs.surfaceContainerHighest,
          child: Icon(Icons.broken_image_outlined, color: cs.onSurfaceVariant),
        ),
      );
    }
    return Image.asset(path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
              color: cs.surfaceContainerHighest,
              child:
                  Icon(Icons.broken_image_outlined, color: cs.onSurfaceVariant),
            ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(_DesignTokens.spaceLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          _SectionCard(
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: (isDark ? cs.primary : _DesignTokens.primary)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(_DesignTokens.radiusMD),
                  ),
                  child: Icon(
                    Icons.style_outlined,
                    color: isDark ? cs.primary : _DesignTokens.primary,
                  ),
                ),
                const SizedBox(width: _DesignTokens.spaceMD),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'اختر نوع القماش',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color:
                              isDark ? cs.onSurface : _DesignTokens.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'تصفح الأقمشة المتوفرة',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? cs.onSurfaceVariant
                              : _DesignTokens.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: _DesignTokens.spaceLG),

          // Fabric Grid
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: FabricService.getTailorFabrics(tailorId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(_DesignTokens.space2XL),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final fabrics = snapshot.data ?? [];

              if (fabrics.isEmpty) {
                return _SectionCard(
                  child: Column(
                    children: [
                      Icon(
                        Icons.style_outlined,
                        size: 48,
                        color: isDark
                            ? cs.onSurfaceVariant
                            : _DesignTokens.textTertiary,
                      ),
                      const SizedBox(height: _DesignTokens.spaceMD),
                      Text(
                        'لا توجد أقمشة متاحة',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color:
                              isDark ? cs.onSurface : _DesignTokens.textPrimary,
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Show selected fabric detail
              if (selectedFabricId != null) {
                final selected = fabrics.firstWhere(
                  (f) => f['id'] == selectedFabricId,
                  orElse: () => <String, dynamic>{},
                );
                if (selected.isNotEmpty) {
                  return _buildSelectedCard(selected, cs, isDark);
                }
              }

              return _buildGrid(fabrics, cs, isDark);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(
      List<Map<String, dynamic>> fabrics, ColorScheme cs, bool isDark) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: _DesignTokens.spaceMD,
        mainAxisSpacing: _DesignTokens.spaceMD,
        childAspectRatio: 0.82,
      ),
      itemCount: fabrics.length,
      itemBuilder: (context, i) {
        final fabric = fabrics[i];
        final isSelected = selectedFabricId == fabric['id'];
        final imageUrl = fabric['imageUrl'] as String? ?? '';
        final price = (fabric['pricePerMeter'] as num?)?.toDouble() ?? 0.0;

        return Material(
          color:
              isDark ? cs.surfaceContainerHighest : _DesignTokens.surfacePure,
          borderRadius: BorderRadius.circular(_DesignTokens.radiusXL),
          child: InkWell(
            onTap: () => onFabricSelected(
                fabric['name'], fabric['imageUrl'], fabric['id']),
            borderRadius: BorderRadius.circular(_DesignTokens.radiusXL),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(_DesignTokens.radiusXL),
                border: Border.all(
                  color: isSelected
                      ? (isDark ? cs.primary : _DesignTokens.primary)
                      : (isDark
                          ? cs.outlineVariant.withOpacity(0.15)
                          : _DesignTokens.borderLight),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(_DesignTokens.radiusXL - 1),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          _buildImage(imageUrl, cs),
                          if (isSelected)
                            Positioned(
                              top: _DesignTokens.spaceMD,
                              right: _DesignTokens.spaceMD,
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? cs.primary
                                      : _DesignTokens.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.check_rounded,
                                    color: Colors.white, size: 16),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(_DesignTokens.spaceMD),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fabric['name'] ?? 'قماش',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? cs.onSurface
                                : _DesignTokens.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ر.ع ${price.toStringAsFixed(3)}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? cs.primary
                                : _DesignTokens.primaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectedCard(
      Map<String, dynamic> fabric, ColorScheme cs, bool isDark) {
    final imageUrl = fabric['imageUrl'] as String? ?? '';
    final price = (fabric['pricePerMeter'] as num?)?.toDouble() ?? 0.0;

    return _SectionCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(_DesignTokens.radiusXL - 1),
            ),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildImage(imageUrl, cs),
                  Positioned(
                    top: _DesignTokens.spaceMD,
                    right: _DesignTokens.spaceMD,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: _DesignTokens.spaceMD,
                        vertical: _DesignTokens.spaceSM,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(_DesignTokens.radiusMD),
                      ),
                      child: Text(
                        'ر.ع ${price.toStringAsFixed(3)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _DesignTokens.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(_DesignTokens.spaceLG),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: _DesignTokens.success,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check_rounded,
                                color: Colors.white, size: 12),
                          ),
                          const SizedBox(width: _DesignTokens.spaceSM),
                          const Text(
                            'تم الاختيار',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: _DesignTokens.success,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: _DesignTokens.spaceSM),
                      Text(
                        fabric['name'] ?? 'قماش',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color:
                              isDark ? cs.onSurface : _DesignTokens.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                _OutlinedButton(
                  label: 'تغيير',
                  onTap: () => onFabricSelected(null, null, null),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// STEP 2: MEASUREMENTS
// ═══════════════════════════════════════════════════════════════════════════

class _MeasurementControllers {
  final TextEditingController length;
  final TextEditingController shoulder;
  final TextEditingController sleeve;
  final TextEditingController upperSleeve;
  final TextEditingController lowerSleeve;
  final TextEditingController chest;
  final TextEditingController waist;
  final TextEditingController neck;
  final TextEditingController embroidery;
  final TextEditingController notes;

  _MeasurementControllers({
    required this.length,
    required this.shoulder,
    required this.sleeve,
    required this.upperSleeve,
    required this.lowerSleeve,
    required this.chest,
    required this.waist,
    required this.neck,
    required this.embroidery,
    required this.notes,
  });
}

class _MeasurementsStep extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final MeasurementUnit unit;
  final ValueChanged<MeasurementUnit> onUnitChanged;
  final _MeasurementControllers controllers;

  const _MeasurementsStep({
    required this.formKey,
    required this.unit,
    required this.onUnitChanged,
    required this.controllers,
  });

  @override
  State<_MeasurementsStep> createState() => _MeasurementsStepState();
}

class _MeasurementsStepState extends State<_MeasurementsStep>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  double _toUnit(double cm) =>
      widget.unit == MeasurementUnit.inch ? cm / _cmPerInch : cm;

  double get _step => widget.unit == MeasurementUnit.inch ? 0.5 : 0.5;
  int get _decimals => widget.unit == MeasurementUnit.inch ? 2 : 1;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final c = widget.controllers;

    final measurements = [
      _MeasurementSpec(
          'الطول', c.length, _toUnit(110), _toUnit(170), Icons.height_rounded),
      _MeasurementSpec('الكتف', c.shoulder, _toUnit(38), _toUnit(56),
          Icons.straighten_rounded),
      _MeasurementSpec(
          'الرقبة', c.neck, _toUnit(34), _toUnit(48), Icons.circle_outlined),
      _MeasurementSpec('طول الذراع', c.sleeve, _toUnit(45), _toUnit(75),
          Icons.back_hand_outlined),
      _MeasurementSpec('الصدر', c.chest, _toUnit(80), _toUnit(140),
          Icons.favorite_border_rounded),
      _MeasurementSpec('الخصر', c.waist, _toUnit(70), _toUnit(130),
          Icons.horizontal_rule_rounded),
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(_DesignTokens.spaceLG),
      child: Form(
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Unit selector
            _SectionCard(
              child: Row(
                children: [
                  Icon(
                    Icons.straighten_rounded,
                    color: isDark ? cs.primary : _DesignTokens.primary,
                    size: 20,
                  ),
                  const SizedBox(width: _DesignTokens.spaceMD),
                  Expanded(
                    child: Text(
                      'وحدة القياس',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color:
                            isDark ? cs.onSurface : _DesignTokens.textPrimary,
                      ),
                    ),
                  ),
                  _UnitToggle(
                      unit: widget.unit, onChanged: widget.onUnitChanged),
                ],
              ),
            ),

            const SizedBox(height: _DesignTokens.spaceLG),

            // Measurement fields
            ...measurements.map((m) => Padding(
                  padding: const EdgeInsets.only(bottom: _DesignTokens.spaceMD),
                  child: _MeasurementField(
                    label: m.label,
                    controller: m.controller,
                    min: m.min,
                    max: m.max,
                    step: _step,
                    unit: widget.unit.labelAr,
                    decimals: _decimals,
                    icon: m.icon,
                  ),
                )),

            // Notes
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ملاحظات إضافية',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isDark ? cs.onSurface : _DesignTokens.textPrimary,
                    ),
                  ),
                  const SizedBox(height: _DesignTokens.spaceMD),
                  TextField(
                    controller: c.notes,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'أدخل أي تفاصيل إضافية...',
                      hintStyle: TextStyle(
                        color: isDark
                            ? cs.onSurfaceVariant
                            : _DesignTokens.textTertiary,
                      ),
                      filled: true,
                      fillColor:
                          isDark ? cs.surface : _DesignTokens.surfaceMuted,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(_DesignTokens.radiusMD),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          const EdgeInsets.all(_DesignTokens.spaceMD),
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
}

class _MeasurementSpec {
  final String label;
  final TextEditingController controller;
  final double min, max;
  final IconData icon;
  _MeasurementSpec(this.label, this.controller, this.min, this.max, this.icon);
}

class _UnitToggle extends StatelessWidget {
  final MeasurementUnit unit;
  final ValueChanged<MeasurementUnit> onChanged;

  const _UnitToggle({required this.unit, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? cs.surface : _DesignTokens.surfaceMuted,
        borderRadius: BorderRadius.circular(_DesignTokens.radiusSM),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildOption('سم', MeasurementUnit.cm, isDark, cs),
          _buildOption('إنش', MeasurementUnit.inch, isDark, cs),
        ],
      ),
    );
  }

  Widget _buildOption(
      String label, MeasurementUnit value, bool isDark, ColorScheme cs) {
    final isSelected = unit == value;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: _DesignTokens.spaceMD,
          vertical: _DesignTokens.spaceSM,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? cs.primary : _DesignTokens.primary)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(_DesignTokens.radiusSM - 2),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected
                ? Colors.white
                : (isDark ? cs.onSurfaceVariant : _DesignTokens.textSecondary),
          ),
        ),
      ),
    );
  }
}

class _MeasurementField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final double min, max, step;
  final String unit;
  final int decimals;
  final IconData icon;

  const _MeasurementField({
    required this.label,
    required this.controller,
    required this.min,
    required this.max,
    required this.step,
    required this.unit,
    required this.decimals,
    required this.icon,
  });

  @override
  State<_MeasurementField> createState() => _MeasurementFieldState();
}

class _MeasurementFieldState extends State<_MeasurementField> {
  double _parse(String v) {
    if (v.trim().isEmpty) return widget.min;
    final d = double.tryParse(v.replaceAll(',', '.'));
    return (d ?? widget.min).clamp(widget.min, widget.max);
  }

  void _set(double value) {
    if (!mounted) return;
    final snapped = (value / widget.step).round() * widget.step;
    final v = snapped.toStringAsFixed(widget.decimals);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.controller.value = TextEditingValue(
        text: v,
        selection: TextSelection.collapsed(offset: v.length),
      );
    });
    setState(() {});
  }

  void _increment() {
    HapticFeedback.selectionClick();
    _set((_parse(widget.controller.text) + widget.step)
        .clamp(widget.min, widget.max));
  }

  void _decrement() {
    HapticFeedback.selectionClick();
    _set((_parse(widget.controller.text) - widget.step)
        .clamp(widget.min, widget.max));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(_DesignTokens.spaceMD),
      decoration: BoxDecoration(
        color: isDark ? cs.surfaceContainerHighest : _DesignTokens.surfacePure,
        borderRadius: BorderRadius.circular(_DesignTokens.radiusLG),
        border: Border.all(
          color: isDark
              ? cs.outlineVariant.withOpacity(0.15)
              : _DesignTokens.borderLight,
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (isDark ? cs.primary : _DesignTokens.primary)
                  .withOpacity(0.08),
              borderRadius: BorderRadius.circular(_DesignTokens.radiusSM),
            ),
            child: Icon(
              widget.icon,
              size: 20,
              color: isDark ? cs.primary : _DesignTokens.primaryLight,
            ),
          ),
          const SizedBox(width: _DesignTokens.spaceMD),

          // Label
          Expanded(
            child: Text(
              widget.label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: isDark ? cs.onSurface : _DesignTokens.textPrimary,
              ),
            ),
          ),

          // Controls
          Directionality(
            textDirection: TextDirection.ltr,
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? cs.surface : _DesignTokens.surfaceMuted,
                borderRadius: BorderRadius.circular(_DesignTokens.radiusMD),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ControlBtn(icon: Icons.remove_rounded, onTap: _decrement),
                  SizedBox(
                    width: 52,
                    child: TextFormField(
                      controller: widget.controller,
                      textAlign: TextAlign.center,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color:
                            isDark ? cs.onSurface : _DesignTokens.textPrimary,
                      ),
                      decoration: const InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      validator: (v) {
                        if ((v ?? '').trim().isEmpty) return '';
                        final val = _parse(v ?? '');
                        if (val < widget.min || val > widget.max) return '';
                        return null;
                      },
                    ),
                  ),
                  _ControlBtn(icon: Icons.add_rounded, onTap: _increment),
                ],
              ),
            ),
          ),
          const SizedBox(width: _DesignTokens.spaceMD),

          // Unit
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: _DesignTokens.spaceSM + 2,
              vertical: _DesignTokens.spaceXS + 2,
            ),
            decoration: BoxDecoration(
              color: (isDark ? cs.primary : _DesignTokens.primary)
                  .withOpacity(0.08),
              borderRadius: BorderRadius.circular(_DesignTokens.radiusSM),
            ),
            child: Text(
              widget.unit,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? cs.primary : _DesignTokens.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ControlBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return InkResponse(
      onTap: onTap,
      radius: 20,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color:
              isDark ? cs.surfaceContainerHighest : _DesignTokens.surfacePure,
          borderRadius: BorderRadius.circular(_DesignTokens.radiusSM),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isDark ? cs.onSurfaceVariant : _DesignTokens.textSecondary,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// STEP 3: EMBROIDERY
// ═══════════════════════════════════════════════════════════════════════════

class _EmbroideryStep extends StatelessWidget {
  final String tailorId;
  final Color color;
  final int lines;
  final EmbroideryDesign? selectedDesign;
  final ValueChanged<Color> onColorChanged;
  final ValueChanged<int> onLinesChanged;
  final ValueChanged<EmbroideryDesign?> onDesignChanged;

  const _EmbroideryStep({
    required this.tailorId,
    required this.color,
    required this.lines,
    required this.selectedDesign,
    required this.onColorChanged,
    required this.onLinesChanged,
    required this.onDesignChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    final colors = [
      const Color(0xFF1A2F4B),
      const Color(0xFF4A5568),
      const Color(0xFF38A169),
      const Color(0xFFB8860B),
      const Color(0xFF8B4513),
      const Color(0xFF553C9A),
      const Color(0xFF1A1F2E),
      const Color(0xFFC0C0C0),
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(_DesignTokens.spaceLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Embroidery designs
          _EmbroideryDesignsCard(
            tailorId: tailorId,
            selectedDesign: selectedDesign,
            onSelected: onDesignChanged,
          ),

          const SizedBox(height: _DesignTokens.spaceLG),

          // Thread color
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'لون خيط التطريز',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: isDark ? cs.onSurface : _DesignTokens.textPrimary,
                  ),
                ),
                const SizedBox(height: _DesignTokens.spaceMD),
                Wrap(
                  spacing: _DesignTokens.spaceMD,
                  runSpacing: _DesignTokens.spaceMD,
                  children: colors.map((c) {
                    final isSelected = c.value == color.value;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        onColorChanged(c);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? (isDark ? cs.primary : _DesignTokens.primary)
                                : Colors.white,
                            width: isSelected ? 3 : 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: c.withOpacity(0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: isSelected
                            ? Icon(
                                Icons.check_rounded,
                                color: c.computeLuminance() > 0.5
                                    ? Colors.black
                                    : Colors.white,
                                size: 20,
                              )
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: _DesignTokens.spaceMD),

          // Decorative lines
          _SectionCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الخطوط الزخرفية',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color:
                              isDark ? cs.onSurface : _DesignTokens.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '+0.250 ر.ع لكل خط',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? cs.onSurfaceVariant
                              : _DesignTokens.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? cs.surface : _DesignTokens.surfaceMuted,
                    borderRadius: BorderRadius.circular(_DesignTokens.radiusMD),
                  ),
                  child: Row(
                    children: [
                      _ControlBtn(
                        icon: Icons.remove_rounded,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          onLinesChanged((lines - 1).clamp(0, 3));
                        },
                      ),
                      SizedBox(
                        width: 44,
                        child: Center(
                          child: Text(
                            '$lines',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? cs.onSurface
                                  : _DesignTokens.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      _ControlBtn(
                        icon: Icons.add_rounded,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          onLinesChanged((lines + 1).clamp(0, 3));
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmbroideryDesignsCard extends StatelessWidget {
  final String tailorId;
  final EmbroideryDesign? selectedDesign;
  final ValueChanged<EmbroideryDesign?> onSelected;

  const _EmbroideryDesignsCard({
    required this.tailorId,
    required this.selectedDesign,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final service = EmbroideryService();

    return FutureBuilder<List<EmbroideryDesign>>(
      future: service.getEmbroideryDesigns(tailorId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _SectionCard(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(_DesignTokens.spaceLG),
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        final designs = snapshot.data ?? [];

        if (designs.isEmpty) {
          return _SectionCard(
            child: Row(
              children: [
                Icon(Icons.info_outline,
                    color: isDark
                        ? cs.onSurfaceVariant
                        : _DesignTokens.textTertiary),
                const SizedBox(width: _DesignTokens.spaceMD),
                Text(
                  'لا توجد تصاميم متاحة',
                  style: TextStyle(
                      color: isDark
                          ? cs.onSurfaceVariant
                          : _DesignTokens.textTertiary),
                ),
              ],
            ),
          );
        }

        return _SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'تصاميم التطريز',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isDark ? cs.onSurface : _DesignTokens.textPrimary,
                ),
              ),
              const SizedBox(height: _DesignTokens.spaceMD),
              SizedBox(
                height: 130,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: designs.length,
                  itemBuilder: (_, i) {
                    final design = designs[i];
                    final isSelected = selectedDesign?.id == design.id;

                    return Padding(
                      padding: EdgeInsets.only(
                          left: i < designs.length - 1
                              ? _DesignTokens.spaceMD
                              : 0),
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          onSelected(isSelected ? null : design);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 100,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(_DesignTokens.radiusMD),
                            border: Border.all(
                              color: isSelected
                                  ? (isDark
                                      ? cs.primary
                                      : _DesignTokens.primary)
                                  : (isDark
                                      ? cs.outlineVariant.withOpacity(0.2)
                                      : _DesignTokens.borderDefault),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(
                                        _DesignTokens.radiusMD - 1),
                                  ),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      CachedNetworkImage(
                                        imageUrl: design.imageUrl,
                                        fit: BoxFit.cover,
                                        placeholder: (_, __) => Container(
                                          color: isDark
                                              ? cs.surfaceContainerHighest
                                              : _DesignTokens.surfaceMuted,
                                        ),
                                        errorWidget: (_, __, ___) => Container(
                                          color: isDark
                                              ? cs.surfaceContainerHighest
                                              : _DesignTokens.surfaceMuted,
                                          child: Icon(Icons.image_outlined,
                                              color: cs.onSurfaceVariant),
                                        ),
                                      ),
                                      if (isSelected)
                                        Positioned(
                                          top: _DesignTokens.spaceXS,
                                          right: _DesignTokens.spaceXS,
                                          child: Container(
                                            width: 20,
                                            height: 20,
                                            decoration: BoxDecoration(
                                              color: isDark
                                                  ? cs.primary
                                                  : _DesignTokens.primary,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                                Icons.check_rounded,
                                                color: Colors.white,
                                                size: 12),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.all(_DesignTokens.spaceSM),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      design.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: isDark
                                            ? cs.onSurface
                                            : _DesignTokens.textPrimary,
                                      ),
                                    ),
                                    if (design.price > 0) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        '+${design.price.toStringAsFixed(3)}',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                          color: isDark
                                              ? cs.primary
                                              : _DesignTokens.primaryLight,
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
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SHARED COMPONENTS
// ═══════════════════════════════════════════════════════════════════════════

class _SectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const _SectionCard({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: padding ?? const EdgeInsets.all(_DesignTokens.spaceLG),
      decoration: BoxDecoration(
        color: isDark ? cs.surfaceContainerHighest : _DesignTokens.surfacePure,
        borderRadius: BorderRadius.circular(_DesignTokens.radiusXL),
        border: Border.all(
          color: isDark
              ? cs.outlineVariant.withOpacity(0.15)
              : _DesignTokens.borderLight,
        ),
      ),
      child: child,
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: isDark ? cs.surfaceContainerHighest : _DesignTokens.surfaceMuted,
      borderRadius: BorderRadius.circular(_DesignTokens.radiusMD),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_DesignTokens.radiusMD),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            icon,
            size: 20,
            color: isDark ? cs.onSurface : _DesignTokens.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _FilledButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;

  const _FilledButton({required this.label, this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: isDark ? cs.primary : _DesignTokens.primary,
      borderRadius: BorderRadius.circular(_DesignTokens.radiusMD),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_DesignTokens.radiusMD),
        child: Container(
          height: 48,
          padding:
              const EdgeInsets.symmetric(horizontal: _DesignTokens.spaceLG),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? cs.onPrimary : Colors.white,
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: _DesignTokens.spaceSM),
                Icon(icon,
                    size: 18, color: isDark ? cs.onPrimary : Colors.white),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _OutlinedButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _OutlinedButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(_DesignTokens.radiusMD),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_DesignTokens.radiusMD),
        child: Container(
          height: 48,
          padding:
              const EdgeInsets.symmetric(horizontal: _DesignTokens.spaceLG),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_DesignTokens.radiusMD),
            border: Border.all(
              color: isDark ? cs.outlineVariant : _DesignTokens.borderDefault,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: isDark ? cs.onSurface : _DesignTokens.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// DIALOGS & OVERLAYS
// ═══════════════════════════════════════════════════════════════════════════

class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(_DesignTokens.spaceXL),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(_DesignTokens.radiusXL),
        ),
        child: const CircularProgressIndicator(),
      ),
    );
  }
}

class _SuccessDialog extends StatelessWidget {
  final String orderId;
  final String tailorName;
  final double price;
  final VoidCallback onDismiss;

  const _SuccessDialog({
    required this.orderId,
    required this.tailorName,
    required this.price,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: isDark ? cs.surface : _DesignTokens.surfacePure,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_DesignTokens.radius2XL),
      ),
      child: Padding(
        padding: const EdgeInsets.all(_DesignTokens.spaceXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: _DesignTokens.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                size: 36,
                color: _DesignTokens.success,
              ),
            ),
            const SizedBox(height: _DesignTokens.spaceLG),
            Text(
              'تم إرسال الطلب بنجاح',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? cs.onSurface : _DesignTokens.textPrimary,
              ),
            ),
            const SizedBox(height: _DesignTokens.spaceLG),
            _buildRow('رقم الطلب', orderId, isDark, cs),
            _buildRow('الخياط', tailorName, isDark, cs),
            _buildRow(
                'الإجمالي', 'ر.ع ${price.toStringAsFixed(3)}', isDark, cs),
            const SizedBox(height: _DesignTokens.spaceMD),
            Text(
              'سيتم التواصل معك قريباً',
              style: TextStyle(
                fontSize: 13,
                color:
                    isDark ? cs.onSurfaceVariant : _DesignTokens.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: _DesignTokens.spaceLG),
            SizedBox(
              width: double.infinity,
              child: _FilledButton(label: 'موافق', onTap: onDismiss),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, bool isDark, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: _DesignTokens.spaceXS + 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? cs.onSurfaceVariant : _DesignTokens.textTertiary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? cs.onSurface : _DesignTokens.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderReviewSheet extends StatelessWidget {
  final String tailorName;
  final String? fabricType;
  final String? fabricThumb;
  final Color embroideryColor;
  final int embroideryLines;
  final EmbroideryDesign? selectedEmbroidery;
  final TextEditingController lengthCtrl,
      shoulderCtrl,
      sleeveCtrl,
      upperSleeveCtrl,
      lowerSleeveCtrl,
      chestCtrl,
      waistCtrl,
      neckCtrl,
      embroideryCtrl,
      notesCtrl;
  final MeasurementUnit unit;
  final double price;
  final String Function(Color) getColorName;
  final bool isGift;
  final GiftRecipientDetails? giftRecipientDetails;
  final void Function(bool) onGiftToggle;
  final VoidCallback onEditGiftRecipient;
  final VoidCallback onConfirm;

  const _OrderReviewSheet({
    required this.tailorName,
    required this.fabricType,
    required this.fabricThumb,
    required this.embroideryColor,
    required this.embroideryLines,
    required this.selectedEmbroidery,
    required this.lengthCtrl,
    required this.shoulderCtrl,
    required this.sleeveCtrl,
    required this.upperSleeveCtrl,
    required this.lowerSleeveCtrl,
    required this.chestCtrl,
    required this.waistCtrl,
    required this.neckCtrl,
    required this.embroideryCtrl,
    required this.notesCtrl,
    required this.unit,
    required this.price,
    required this.getColorName,
    required this.isGift,
    this.giftRecipientDetails,
    required this.onGiftToggle,
    required this.onEditGiftRecipient,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    String fmt(TextEditingController c) =>
        c.text.isEmpty ? '—' : '${c.text} ${unit.labelAr}';

    return Container(
      decoration: BoxDecoration(
        color: isDark ? cs.surface : _DesignTokens.surfacePure,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(_DesignTokens.radius2XL),
        ),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(_DesignTokens.spaceLG),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark
                          ? cs.outlineVariant
                          : _DesignTokens.borderDefault,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: _DesignTokens.spaceLG),

                // Title
                Text(
                  'مراجعة الطلب',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: isDark ? cs.onSurface : _DesignTokens.textPrimary,
                  ),
                ),
                const SizedBox(height: _DesignTokens.spaceLG),

                // Sections
                _ReviewSection(title: 'الخياط', rows: [
                  _ReviewItem('الاسم', tailorName),
                  _ReviewItem('المدينة', 'مسقط'),
                ]),
                _ReviewSection(title: 'القماش', rows: [
                  _ReviewItem('النوع', fabricType ?? '—'),
                ]),
                _ReviewSection(title: 'التطريز', rows: [
                  _ReviewItem('التصميم', selectedEmbroidery?.name ?? 'لا يوجد'),
                  _ReviewItem('لون الخيط', getColorName(embroideryColor)),
                  _ReviewItem('الخطوط', '$embroideryLines'),
                ]),
                _ReviewSection(title: 'المقاسات', rows: [
                  _ReviewItem('الطول', fmt(lengthCtrl)),
                  _ReviewItem('الكتف', fmt(shoulderCtrl)),
                  _ReviewItem('الذراع', fmt(sleeveCtrl)),
                  _ReviewItem('الصدر', fmt(chestCtrl)),
                  _ReviewItem('الخصر', fmt(waistCtrl)),
                  _ReviewItem('الرقبة', fmt(neckCtrl)),
                ]),

                // Gift Section
                _buildGiftSection(context, isDark, cs),

                // Total
                Container(
                  padding: const EdgeInsets.all(_DesignTokens.spaceLG),
                  decoration: BoxDecoration(
                    color: (isDark ? cs.primary : _DesignTokens.primary)
                        .withOpacity(0.05),
                    borderRadius: BorderRadius.circular(_DesignTokens.radiusLG),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'الإجمالي',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color:
                              isDark ? cs.onSurface : _DesignTokens.textPrimary,
                        ),
                      ),
                      Text(
                        'ر.ع ${price.toStringAsFixed(3)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isDark ? cs.primary : _DesignTokens.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: _DesignTokens.spaceLG),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: _OutlinedButton(
                        label: 'رجوع',
                        onTap: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: _DesignTokens.spaceMD),
                    Expanded(
                      flex: 2,
                      child: _FilledButton(
                        label: 'تأكيد الإرسال',
                        icon: Icons.send_rounded,
                        onTap: () {
                          Navigator.pop(context);
                          onConfirm();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGiftSection(BuildContext context, bool isDark, ColorScheme cs) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: _DesignTokens.spaceLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gift toggle
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: isGift
                  ? LinearGradient(
                      colors: [
                        _DesignTokens.accent.withOpacity(0.1),
                        _DesignTokens.accentLight.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isGift
                  ? null
                  : (isDark ? cs.surfaceContainerLow : _DesignTokens.surfaceMuted),
              borderRadius: BorderRadius.circular(_DesignTokens.radiusLG),
              border: Border.all(
                color: isGift
                    ? _DesignTokens.accent.withOpacity(0.5)
                    : (isDark ? cs.outlineVariant : _DesignTokens.borderDefault),
                width: isGift ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isGift
                        ? _DesignTokens.accent.withOpacity(0.2)
                        : (isDark ? cs.surfaceContainerHigh : _DesignTokens.surfaceDim),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.card_giftcard_rounded,
                    color: isGift
                        ? _DesignTokens.accent
                        : (isDark ? cs.onSurfaceVariant : _DesignTokens.textTertiary),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n?.sendAsGift ?? 'إرسال كهدية',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isGift
                              ? _DesignTokens.accent
                              : (isDark ? cs.onSurface : _DesignTokens.textPrimary),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n?.thisOrderIsAGift ?? 'هذا الطلب هدية',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? cs.onSurfaceVariant : _DesignTokens.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: isGift,
                  onChanged: onGiftToggle,
                  activeColor: _DesignTokens.accent,
                ),
              ],
            ),
          ),

          // Gift recipient summary
          if (isGift && giftRecipientDetails != null) ...[
            const SizedBox(height: 12),
            GiftRecipientSummaryCard(
              details: giftRecipientDetails!,
              onEdit: onEditGiftRecipient,
            ),
          ],
        ],
      ),
    );
  }
}

class _ReviewSection extends StatelessWidget {
  final String title;
  final List<_ReviewItem> rows;

  const _ReviewSection({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: _DesignTokens.spaceLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? cs.primary : _DesignTokens.primaryLight,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: _DesignTokens.spaceMD),
          ...rows.map((r) => Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: _DesignTokens.spaceXS + 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      r.label,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? cs.onSurfaceVariant
                            : _DesignTokens.textTertiary,
                      ),
                    ),
                    Text(
                      r.value,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color:
                            isDark ? cs.onSurface : _DesignTokens.textPrimary,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _ReviewItem {
  final String label;
  final String value;
  _ReviewItem(this.label, this.value);
}

// ═══════════════════════════════════════════════════════════════════════════
// MODELS
// ═══════════════════════════════════════════════════════════════════════════

class FabricItem {
  final String title;
  final String image;
  final String? tag;
  const FabricItem(this.title, this.image, {this.tag});
}
