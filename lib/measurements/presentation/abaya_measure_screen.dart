// lib/measurements/presentation/abaya_measure_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../features/catalog/models/abaya_item.dart';
import '../../features/catalog/services/abaya_service.dart';
import '../../features/orders/services/order_service.dart';
import '../../features/orders/models/order_model.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../core/state/cart_scope.dart';
import '../../shared/widgets/any_image.dart';
import '../../shared/widgets/gift_recipient_bottom_sheet.dart';
import '../../l10n/app_localizations.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Design System
// ═══════════════════════════════════════════════════════════════════════════

class _DS {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;

  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusXl = 20;

  static const Color primaryBrown = Color(0xFF8B7355);
  static const Color darkText = Color(0xFF1F2937);
  static const Color mediumText = Color(0xFF6B7280);
  static const Color lightText = Color(0xFF9CA3AF);
  static const Color background = Color(0xFFFAFAFA);
  static const Color cardBg = Colors.white;
  static const Color border = Color(0xFFE5E7EB);
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
}

const _kGuideAsset = 'assets/abaya/abaya_guide.jpeg';

// ═══════════════════════════════════════════════════════════════════════════
// Measurements Model
// ═══════════════════════════════════════════════════════════════════════════

/// نموذج المقاسات: الطول، طول الكم، العرض + ملاحظات
class AbayaMeasurements {
  final double length; // الطول (سم)
  final double sleeve; // طول الكم (سم)
  final double width; // العرض (سم)
  final String notes;

  AbayaMeasurements({
    required this.length,
    required this.sleeve,
    required this.width,
    this.notes = '',
  });

  Map<String, dynamic> toMap() => {
        'length': length,
        'sleeve': sleeve,
        'width': width,
        'notes': notes,
        'unit': 'cm',
      };
}

// ═══════════════════════════════════════════════════════════════════════════
// Main Screen
// ═══════════════════════════════════════════════════════════════════════════

class AbayaMeasureScreen extends StatefulWidget {
  final AbayaItem item;
  final Color? selectedColor;
  final bool isAddToCartMode; // true = إضافة للسلة، false = طلب مباشر

  const AbayaMeasureScreen({
    super.key,
    required this.item,
    this.selectedColor,
    this.isAddToCartMode = false,
  });

  @override
  State<AbayaMeasureScreen> createState() => _AbayaMeasureScreenState();
}

class _AbayaMeasureScreenState extends State<AbayaMeasureScreen> {
  final _formKey = GlobalKey<FormState>();
  final _abayaService = AbayaService();
  bool _isSubmitting = false;

  // Gift state
  bool _isGift = false;
  GiftRecipientDetails? _giftRecipientDetails;

  // Controllers
  final _lengthC = TextEditingController();
  final _sleeveC = TextEditingController();
  final _widthC = TextEditingController();
  final _notesC = TextEditingController();

  // Focus nodes for better UX
  final _lengthFocus = FocusNode();
  final _sleeveFocus = FocusNode();
  final _widthFocus = FocusNode();
  final _notesFocus = FocusNode();

  @override
  void dispose() {
    _lengthC.dispose();
    _sleeveC.dispose();
    _widthC.dispose();
    _notesC.dispose();
    _lengthFocus.dispose();
    _sleeveFocus.dispose();
    _widthFocus.dispose();
    _notesFocus.dispose();
    super.dispose();
  }

  /// تحويل من إنش إلى سنتيمتر
  double _inchToCm(double inch) => inch * 2.54;

  /// تحويل النص إلى رقم
  double _toNum(TextEditingController c) =>
      double.tryParse(c.text.trim().replaceAll(',', '.')) ?? 0;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context)!;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (!authProvider.isAuthenticated || authProvider.currentUser == null) {
      _showSnackBar(l10n.pleaseSignInFirst, isError: true);
      return;
    }

    setState(() => _isSubmitting = true);
    HapticFeedback.mediumImpact();

    try {
      final user = authProvider.currentUser!;
      final customerId = user.uid;
      final customerName = user.name;
      final customerPhone = user.phoneNumber ?? '';

      String? traderId;
      String traderName = l10n.abayaStore;

      try {
        traderId = await _abayaService.getTraderIdByProductId(widget.item.id);
        if (traderId != null) {
          final name = await _abayaService.getTraderName(traderId);
          if (name != null) traderName = name;
        }
      } catch (_) {}

      // تحويل المقاسات من إنش إلى سم قبل الحفظ
      final lengthInch = _toNum(_lengthC);
      final sleeveInch = _toNum(_sleeveC);
      final widthInch = _toNum(_widthC);

      // المقاسات بالسنتيمتر للحفظ في Firebase
      final measurements = <String, double>{
        'length': _inchToCm(lengthInch),
        'sleeve': _inchToCm(sleeveInch),
        'width': _inchToCm(widthInch),
      };

      // إضافة المقاسات بالإنش للملاحظات
      final inchNote =
          l10n.measurementsInInch(lengthInch.toString(), sleeveInch.toString(), widthInch.toString());
      final finalNotes = _notesC.text.trim().isEmpty
          ? inchNote
          : '${_notesC.text.trim()}\n\n$inchNote';

      final orderId = await OrderService.submitAbayaOrder(
        customerId: customerId,
        customerName: customerName,
        customerPhone: customerPhone,
        traderId: traderId ?? 'general',
        traderName: traderName,
        productId: widget.item.id,
        productName: widget.item.title,
        productImageUrl: widget.item.imageUrl,
        productPrice: widget.item.price,
        measurements: measurements,
        notes: finalNotes,
        selectedColor: widget.selectedColor != null
            ? '#${widget.selectedColor!.value.toRadixString(16).substring(2).toUpperCase()}'
            : null,
        isGift: _isGift,
        giftRecipientDetails: _giftRecipientDetails,
      );

      if (!mounted) return;

      if (orderId != null) {
        _showSnackBar(l10n.orderSentSuccessfully, isSuccess: true);

        final m = AbayaMeasurements(
          length: _inchToCm(lengthInch),
          sleeve: _inchToCm(sleeveInch),
          width: _inchToCm(widthInch),
          notes: _notesC.text.trim(),
        );

        Navigator.pop(context, m);
      } else {
        _showSnackBar(l10n.failedToSendOrder,
            isError: true);
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(l10n.unexpectedError, isError: true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  /// إضافة المنتج مع المقاسات للسلة
  void _addToCart() {
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context)!;
    HapticFeedback.mediumImpact();

    try {
      final cartState = CartScope.of(context);

      // المقاسات بالإنش
      final lengthInch = _toNum(_lengthC);
      final sleeveInch = _toNum(_sleeveC);
      final widthInch = _toNum(_widthC);

      // تحويل اللون إلى HEX
      String? colorHex;
      if (widget.selectedColor != null) {
        colorHex =
            '#${widget.selectedColor!.value.toRadixString(16).substring(2).toUpperCase()}';
      }

      cartState.addAbayaWithMeasurements(
        id: widget.item.id,
        title: widget.item.title,
        price: widget.item.price,
        imageUrl: widget.item.imageUrl,
        selectedColor: colorHex,
        length: lengthInch,
        sleeve: sleeveInch,
        width: widthInch,
        unit: 'in',
        notes: _notesC.text.trim().isEmpty ? null : _notesC.text.trim(),
      );

      _showSnackBar(
        l10n.addedWithMeasurements(widget.item.title),
        isSuccess: true,
      );

      // العودة للصفحة السابقة
      Navigator.pop(context);
    } catch (e) {
      _showSnackBar(l10n.errorOccurred, isError: true);
    }
  }

  void _showSnackBar(String message,
      {bool isSuccess = false, bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess
                  ? Icons.check_circle_rounded
                  : (isError ? Icons.error_rounded : Icons.info_rounded),
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: _DS.sm),
            Expanded(child: Text(message)),
          ],
        ),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isSuccess ? _DS.success : (isError ? _DS.error : null),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_DS.radiusMd)),
        margin: const EdgeInsets.all(_DS.lg),
      ),
    );
  }

  /// بناء قسم الهدية
  Widget _buildGiftSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      padding: const EdgeInsets.all(_DS.lg),
      decoration: BoxDecoration(
        color: _DS.cardBg,
        borderRadius: BorderRadius.circular(_DS.radiusMd),
        border: Border.all(
          color: _isGift ? _DS.primaryBrown.withOpacity(0.3) : _DS.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gift Toggle Row
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(_DS.radiusSm),
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() => _isGift = !_isGift);
                
                if (_isGift && _giftRecipientDetails == null) {
                  _showGiftBottomSheet();
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: _DS.sm),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: _isGift
                            ? LinearGradient(
                                colors: [
                                  _DS.primaryBrown,
                                  _DS.primaryBrown.withOpacity(0.8),
                                ],
                              )
                            : null,
                        color: _isGift ? null : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(_DS.radiusSm),
                      ),
                      child: Icon(
                        Icons.card_giftcard_rounded,
                        size: 20,
                        color: _isGift ? Colors.white : _DS.mediumText,
                      ),
                    ),
                    const SizedBox(width: _DS.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.sendAsGift,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: _DS.darkText,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.thisOrderIsAGift,
                            style: TextStyle(
                              fontSize: 13,
                              color: _DS.mediumText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: _isGift,
                      onChanged: (val) {
                        HapticFeedback.lightImpact();
                        setState(() => _isGift = val);
                        
                        if (val && _giftRecipientDetails == null) {
                          _showGiftBottomSheet();
                        }
                      },
                      activeColor: _DS.primaryBrown,
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Gift Recipient Summary
          if (_isGift && _giftRecipientDetails != null) ...[
            const SizedBox(height: _DS.md),
            GiftRecipientSummaryCard(
              details: _giftRecipientDetails!,
              onEdit: _showGiftBottomSheet,
            ),
          ],
          
          // Add recipient button if gift enabled but no details
          if (_isGift && _giftRecipientDetails == null) ...[
            const SizedBox(height: _DS.md),
            OutlinedButton.icon(
              onPressed: _showGiftBottomSheet,
              icon: const Icon(Icons.person_add_rounded, size: 18),
              label: Text(l10n.recipientName),
              style: OutlinedButton.styleFrom(
                foregroundColor: _DS.primaryBrown,
                side: BorderSide(color: _DS.primaryBrown.withOpacity(0.5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(_DS.radiusSm),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// عرض Bottom Sheet لإدخال بيانات المستلم
  void _showGiftBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GiftRecipientBottomSheet(
        initialData: _giftRecipientDetails,
        onSave: (details) {
          setState(() {
            _giftRecipientDetails = details;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _DS.background,
        body: Stack(
          children: [
            // Main Content
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: _MeasurementsHeader(
                    onBack: () => Navigator.maybePop(context),
                  ),
                ),

                // Content
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(_DS.lg, 0, _DS.lg, 120),
                  sliver: SliverToBoxAdapter(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Product Card
                          _SelectedProductCard(item: widget.item),
                          const SizedBox(height: _DS.xl),

                          // Measurement Guide
                          const _MeasurementGuideSegment(
                              imageSrc: _kGuideAsset),
                          const SizedBox(height: _DS.xl),

                          // Measurements Form
                          _MeasurementsForm(
                            lengthController: _lengthC,
                            sleeveController: _sleeveC,
                            widthController: _widthC,
                            lengthFocus: _lengthFocus,
                            sleeveFocus: _sleeveFocus,
                            widthFocus: _widthFocus,
                            notesFocus: _notesFocus,
                          ),
                          const SizedBox(height: _DS.xl),

                          // Notes Field
                          _NotesField(
                            controller: _notesC,
                            focusNode: _notesFocus,
                          ),
                          const SizedBox(height: _DS.xl),

                          // Gift Section
                          _buildGiftSection(context),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Sticky CTA
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _StickyConfirmBar(
                isLoading: _isSubmitting,
                isAddToCartMode: widget.isAddToCartMode,
                onConfirm: _submit,
                onAddToCart: _addToCart,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Header
// ═══════════════════════════════════════════════════════════════════════════

class _MeasurementsHeader extends StatelessWidget {
  final VoidCallback onBack;
  const _MeasurementsHeader({required this.onBack});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(_DS.lg, _DS.md, _DS.lg, _DS.lg),
        child: Row(
          children: [
            _GlassBackButton(onTap: onBack),
            const SizedBox(width: _DS.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.abayaMeasurements,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: _DS.darkText,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.enterMeasurementsInInch,
                    style: const TextStyle(
                      fontSize: 13,
                      color: _DS.mediumText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // Info tooltip
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _DS.primaryBrown.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.straighten_rounded,
                size: 18,
                color: _DS.primaryBrown,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassBackButton extends StatefulWidget {
  final VoidCallback onTap;
  const _GlassBackButton({required this.onTap});

  @override
  State<_GlassBackButton> createState() => _GlassBackButtonState();
}

class _GlassBackButtonState extends State<_GlassBackButton>
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
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _DS.cardBg,
            shape: BoxShape.circle,
            border: Border.all(color: _DS.border.withOpacity(0.5), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.arrow_forward_rounded,
            size: 20,
            color: _DS.darkText,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Selected Product Card
// ═══════════════════════════════════════════════════════════════════════════

class _SelectedProductCard extends StatelessWidget {
  final AbayaItem item;
  const _SelectedProductCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(_DS.lg),
      decoration: BoxDecoration(
        color: _DS.cardBg,
        borderRadius: BorderRadius.circular(_DS.radiusXl),
        border: Border.all(color: _DS.border.withOpacity(0.5), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Product Image
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_DS.radiusMd),
              border: Border.all(color: _DS.border.withOpacity(0.3)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(_DS.radiusMd - 1),
              child: AnyImage(
                src: item.imageUrl,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.zero,
              ),
            ),
          ),
          const SizedBox(width: _DS.lg),

          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Chip
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: _DS.sm,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _DS.primaryBrown.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(_DS.radiusSm),
                  ),
                  child: Text(
                    item.subtitle.isNotEmpty
                        ? item.subtitle
                        : l10n.abayaFallback,
                    style: const TextStyle(
                      color: _DS.primaryBrown,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: _DS.sm),

                // Title
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _DS.darkText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Price
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.price.toStringAsFixed(item.price == item.price.truncateToDouble() ? 0 : 2),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _DS.primaryBrown,
                ),
              ),
              Text(
                l10n.omr,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _DS.mediumText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Measurement Guide Segment
// ═══════════════════════════════════════════════════════════════════════════

class _MeasurementGuideSegment extends StatefulWidget {
  final String imageSrc;
  const _MeasurementGuideSegment({required this.imageSrc});

  @override
  State<_MeasurementGuideSegment> createState() =>
      _MeasurementGuideSegmentState();
}

class _MeasurementGuideSegmentState extends State<_MeasurementGuideSegment> {
  int _selected = 0;

  List<String> _getLabels(AppLocalizations l10n) => [
        l10n.lengthMeasure,
        l10n.sleeveMeasure,
        l10n.widthMeasure,
      ];

  List<String> _getTips(AppLocalizations l10n) => [
        l10n.lengthTip,
        l10n.sleeveTip,
        l10n.widthTip,
      ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final labels = _getLabels(l10n);
    final tips = _getTips(l10n);
    return Container(
      padding: const EdgeInsets.all(_DS.xl),
      decoration: BoxDecoration(
        color: _DS.cardBg,
        borderRadius: BorderRadius.circular(_DS.radiusXl),
        border: Border.all(color: _DS.border.withOpacity(0.5), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(
                Icons.design_services_rounded,
                size: 20,
                color: _DS.primaryBrown,
              ),
              const SizedBox(width: _DS.sm),
              Text(
                l10n.measurementGuide,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _DS.darkText,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: _DS.sm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _DS.border.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(_DS.radiusSm),
                ),
                child: const Text(
                  '1 in = 2.54 cm',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _DS.mediumText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: _DS.lg),

          // Segmented Control
          Container(
            height: 44,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(_DS.radiusMd),
            ),
            child: Row(
              children: List.generate(labels.length, (i) {
                final isSelected = i == _selected;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selected = i);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      decoration: BoxDecoration(
                        color: isSelected ? _DS.cardBg : Colors.transparent,
                        borderRadius: BorderRadius.circular(_DS.radiusSm),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          labels[i],
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                            color:
                                isSelected ? _DS.primaryBrown : _DS.mediumText,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: _DS.lg),

          // Image
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(_DS.radiusMd),
              border: Border.all(color: _DS.border.withOpacity(0.5)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(_DS.radiusMd - 1),
              child: Image.asset(
                widget.imageSrc,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_not_supported_outlined,
                        size: 40,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: _DS.sm),
                      Text(
                        l10n.guideImageNotAvailable,
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: _DS.md),

          // Tip
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Container(
              key: ValueKey(_selected),
              width: double.infinity,
              padding: const EdgeInsets.all(_DS.md),
              decoration: BoxDecoration(
                color: _DS.primaryBrown.withOpacity(0.05),
                borderRadius: BorderRadius.circular(_DS.radiusMd),
                border: Border.all(
                  color: _DS.primaryBrown.withOpacity(0.15),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: _DS.primaryBrown,
                  ),
                  const SizedBox(width: _DS.sm),
                  Expanded(
                    child: Text(
                      tips[_selected],
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: _DS.darkText,
                        height: 1.5,
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
}

// ═══════════════════════════════════════════════════════════════════════════
// Measurements Form
// ═══════════════════════════════════════════════════════════════════════════

class _MeasurementsForm extends StatelessWidget {
  final TextEditingController lengthController;
  final TextEditingController sleeveController;
  final TextEditingController widthController;
  final FocusNode lengthFocus;
  final FocusNode sleeveFocus;
  final FocusNode widthFocus;
  final FocusNode notesFocus;

  const _MeasurementsForm({
    required this.lengthController,
    required this.sleeveController,
    required this.widthController,
    required this.lengthFocus,
    required this.sleeveFocus,
    required this.widthFocus,
    required this.notesFocus,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(_DS.xl),
      decoration: BoxDecoration(
        color: _DS.cardBg,
        borderRadius: BorderRadius.circular(_DS.radiusXl),
        border: Border.all(color: _DS.border.withOpacity(0.5), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(
                Icons.straighten_rounded,
                size: 20,
                color: _DS.primaryBrown,
              ),
              const SizedBox(width: _DS.sm),
              Text(
                l10n.basicMeasurements,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _DS.darkText,
                ),
              ),
            ],
          ),
          const SizedBox(height: _DS.sm),
          Text(
            l10n.allMeasurementsInInch,
            style: const TextStyle(
              fontSize: 12,
              color: _DS.mediumText,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: _DS.xl),

          // Fields
          _InchInputField(
            label: l10n.lengthMeasure,
            hint: l10n.exampleLength,
            controller: lengthController,
            focusNode: lengthFocus,
            nextFocus: sleeveFocus,
            icon: Icons.height_rounded,
          ),
          const SizedBox(height: _DS.lg),

          _InchInputField(
            label: l10n.sleeveLengthLabel,
            hint: l10n.exampleSleeve,
            controller: sleeveController,
            focusNode: sleeveFocus,
            nextFocus: widthFocus,
            icon: Icons.back_hand_outlined,
          ),
          const SizedBox(height: _DS.lg),

          _InchInputField(
            label: l10n.widthMeasure,
            hint: l10n.exampleWidth,
            controller: widthController,
            focusNode: widthFocus,
            nextFocus: notesFocus,
            icon: Icons.open_in_full_rounded,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Inch Input Field
// ═══════════════════════════════════════════════════════════════════════════

class _InchInputField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode? nextFocus;
  final IconData icon;

  const _InchInputField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.focusNode,
    this.nextFocus,
    required this.icon,
  });

  double _toNum() =>
      double.tryParse(controller.text.trim().replaceAll(',', '.')) ?? 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Row(
          children: [
            Icon(icon, size: 16, color: _DS.mediumText),
            const SizedBox(width: _DS.sm),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _DS.darkText,
              ),
            ),
          ],
        ),
        const SizedBox(height: _DS.sm),

        // Input
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction:
              nextFocus != null ? TextInputAction.next : TextInputAction.done,
          onFieldSubmitted: (_) {
            if (nextFocus != null) {
              FocusScope.of(context).requestFocus(nextFocus);
            }
          },
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _DS.darkText,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: _DS.lightText.withOpacity(0.7),
              fontWeight: FontWeight.w400,
            ),
            suffixText: 'in',
            suffixStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _DS.primaryBrown,
            ),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: _DS.lg,
              vertical: _DS.lg,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_DS.radiusMd),
              borderSide: BorderSide(color: _DS.border.withOpacity(0.5)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_DS.radiusMd),
              borderSide: BorderSide(color: _DS.border.withOpacity(0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_DS.radiusMd),
              borderSide: const BorderSide(color: _DS.primaryBrown, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_DS.radiusMd),
              borderSide: const BorderSide(color: _DS.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_DS.radiusMd),
              borderSide: const BorderSide(color: _DS.error, width: 1.5),
            ),
          ),
          validator: (v) {
            final n = _toNum();
            if (n <= 0) return l10n.pleaseEnterValidValue;
            if (n > 100) return l10n.valueTooLarge;
            return null;
          },
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Notes Field
// ═══════════════════════════════════════════════════════════════════════════

class _NotesField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;

  const _NotesField({
    required this.controller,
    required this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(_DS.xl),
      decoration: BoxDecoration(
        color: _DS.cardBg,
        borderRadius: BorderRadius.circular(_DS.radiusXl),
        border: Border.all(color: _DS.border.withOpacity(0.5), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(
                Icons.edit_note_rounded,
                size: 20,
                color: _DS.primaryBrown,
              ),
              const SizedBox(width: _DS.sm),
              Text(
                l10n.additionalNotes,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _DS.darkText,
                ),
              ),
              const SizedBox(width: _DS.sm),
              Text(
                l10n.optionalLabel,
                style: const TextStyle(
                  fontSize: 12,
                  color: _DS.lightText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: _DS.md),

          // Input
          TextFormField(
            controller: controller,
            focusNode: focusNode,
            maxLines: 3,
            style: const TextStyle(
              fontSize: 14,
              color: _DS.darkText,
              height: 1.5,
            ),
            decoration: InputDecoration(
              hintText: l10n.measurementsHintExample,
              hintStyle: TextStyle(
                color: _DS.lightText.withOpacity(0.7),
                fontWeight: FontWeight.w400,
              ),
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              contentPadding: const EdgeInsets.all(_DS.lg),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(_DS.radiusMd),
                borderSide: BorderSide(color: _DS.border.withOpacity(0.5)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(_DS.radiusMd),
                borderSide: BorderSide(color: _DS.border.withOpacity(0.5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(_DS.radiusMd),
                borderSide:
                    const BorderSide(color: _DS.primaryBrown, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Sticky Confirm Bar (Single Action based on mode)
// ═══════════════════════════════════════════════════════════════════════════

class _StickyConfirmBar extends StatelessWidget {
  final bool isLoading;
  final bool isAddToCartMode; // true = إضافة للسلة، false = طلب مباشر
  final VoidCallback onConfirm;
  final VoidCallback onAddToCart;

  const _StickyConfirmBar({
    required this.isLoading,
    required this.isAddToCartMode,
    required this.onConfirm,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(
        _DS.lg,
        _DS.md,
        _DS.lg,
        _DS.md + bottomPadding,
      ),
      decoration: BoxDecoration(
        color: _DS.cardBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: isAddToCartMode
          // وضع الإضافة للسلة - زر واحد فقط
          ? _ActionButton(
              label: l10n.confirmMeasurementsAddCart,
              icon: Icons.shopping_bag_outlined,
              isLoading: isLoading,
              isPrimary: true,
              onTap: isLoading ? null : onAddToCart,
            )
          // وضع الطلب المباشر - زر واحد فقط
          : _ActionButton(
              label: l10n.confirmMeasurementsProceed,
              icon: Icons.check_circle_outline_rounded,
              isLoading: isLoading,
              isPrimary: true,
              onTap: isLoading ? null : onConfirm,
            ),
    );
  }
}

/// زر الإجراء المتحرك
class _ActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isLoading;
  final bool isPrimary;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.isLoading,
    required this.isPrimary,
    this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
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
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
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
    final bgColor = widget.isPrimary
        ? (widget.isLoading
            ? _DS.primaryBrown.withOpacity(0.7)
            : _DS.primaryBrown)
        : _DS.cardBg;
    final fgColor = widget.isPrimary ? Colors.white : _DS.primaryBrown;
    final borderColor =
        widget.isPrimary ? Colors.transparent : _DS.primaryBrown;

    return GestureDetector(
      onTapDown: widget.onTap == null ? null : (_) => _controller.forward(),
      onTapUp: widget.onTap == null
          ? null
          : (_) {
              _controller.reverse();
              HapticFeedback.mediumImpact();
              widget.onTap!();
            },
      onTapCancel: widget.onTap == null ? null : () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(_DS.radiusMd),
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: widget.isPrimary
                ? [
                    BoxShadow(
                      color: _DS.primaryBrown.withOpacity(0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: widget.isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(fgColor),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(widget.icon, size: 18, color: fgColor),
                      const SizedBox(width: 6),
                      Text(
                        widget.label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: fgColor,
                          letterSpacing: 0.2,
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
