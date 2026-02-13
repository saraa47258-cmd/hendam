import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/premium_app_bar.dart';
import '../services/fabric_service.dart';
import '../services/embroidery_service.dart';
import '../models/embroidery_design.dart';
import '../../orders/services/order_service.dart';
import '../../orders/models/order_model.dart';
import '../../auth/providers/auth_provider.dart';

/// شاشة تصميم الهدية - 4 خطوات (القماش، المقاسات، التطريز، بيانات المستلم)
class GiftDesignScreen extends StatefulWidget {
  final String tailorId;
  final String tailorName;
  final double basePriceOMR;

  const GiftDesignScreen({
    super.key,
    required this.tailorId,
    required this.tailorName,
    this.basePriceOMR = 6.0,
  });

  @override
  State<GiftDesignScreen> createState() => _GiftDesignScreenState();
}

class _GiftDesignScreenState extends State<GiftDesignScreen>
    with TickerProviderStateMixin {
  // ==== فورم المقاسات ====
  final _formKey = GlobalKey<FormState>();
  final _giftFormKey = GlobalKey<FormState>();

  // المقاسات
  final _lengthCtrl = TextEditingController();
  final _shoulderCtrl = TextEditingController();
  final _neckCtrl = TextEditingController();
  final _armLengthCtrl = TextEditingController();
  final _wristWidthCtrl = TextEditingController();
  final _chestWidthCtrl = TextEditingController();
  final _bottomWidthCtrl = TextEditingController();
  final _patternLengthCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  // بيانات مستلم الهدية
  final _recipientNameCtrl = TextEditingController();
  final _recipientPhoneCtrl = TextEditingController();
  final _giftMessageCtrl = TextEditingController();
  final _deliveryNotesCtrl = TextEditingController();

  // ==== معالج الخطوات ====
  final _pager = PageController();
  int _step = 0; // 0..3 (القماش، المقاسات+اللون، التطريز، بيانات المستلم)

  // ==== القماش ====
  String? _fabricType;
  String? _fabricThumb;
  String? _selectedFabricId;

  // ==== التطريز ====
  EmbroideryDesign? _selectedEmbroidery;
  List<String> _selectedThreadColorIds = [];
  int _threadCount = 1;

  // ==== الوحدات ====
  MeasurementUnit _unit = MeasurementUnit.cm;

  // ==== إرسال الطلب ====
  bool _isSubmitting = false;

  @override
  void dispose() {
    _pager.dispose();
    _lengthCtrl.dispose();
    _shoulderCtrl.dispose();
    _neckCtrl.dispose();
    _armLengthCtrl.dispose();
    _wristWidthCtrl.dispose();
    _chestWidthCtrl.dispose();
    _bottomWidthCtrl.dispose();
    _patternLengthCtrl.dispose();
    _notesCtrl.dispose();
    _recipientNameCtrl.dispose();
    _recipientPhoneCtrl.dispose();
    _giftMessageCtrl.dispose();
    _deliveryNotesCtrl.dispose();
    super.dispose();
  }

  double get _price {
    double total = widget.basePriceOMR;
    if (_selectedEmbroidery != null) {
      total += _selectedEmbroidery!.price;
    }
    return total;
  }

  void _switchUnit(MeasurementUnit newUnit) {
    if (newUnit == _unit) return;
    setState(() => _unit = newUnit);
  }

  Future<void> _next() async {
    FocusScope.of(context).unfocus();
    await Future.delayed(const Duration(milliseconds: 100));

    if (!_canProceed(_step)) return;

    if (_step < 3) {
      setState(() => _step++);
      await _pager.animateToPage(
        _step,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
      );
      HapticFeedback.lightImpact();
    } else {
      _submitGiftOrder();
    }
  }

  void _back() {
    if (!mounted) return;
    FocusScope.of(context).unfocus();

    if (_step > 0) {
      final newStep = _step - 1;
      setState(() => _step = newStep);
      _pager.jumpToPage(newStep);
      HapticFeedback.lightImpact();
    } else {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }
  }

  bool _canProceed(int step) {
    final messenger = ScaffoldMessenger.of(context);

    switch (step) {
      case 0:
        if (_fabricType == null || _selectedFabricId == null) {
          HapticFeedback.mediumImpact();
          messenger.showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(child: Text('⚠️ يرجى اختيار نوع القماش أولاً')),
                ],
              ),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
            ),
          );
          return false;
        }
        return true;

      case 1:
        if (!_formKey.currentState!.validate()) {
          HapticFeedback.mediumImpact();
          return false;
        }
        return true;

      case 2:
        // إذا تم اختيار تطريز، يجب اختيار لون وعدد خيوط
        if (_selectedEmbroidery != null) {
          if (_selectedThreadColorIds.isEmpty) {
            HapticFeedback.mediumImpact();
            messenger.showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.white),
                    SizedBox(width: 8),
                    Expanded(child: Text('⚠️ يرجى اختيار لون الخيط')),
                  ],
                ),
                backgroundColor: Colors.orange,
                behavior: SnackBarBehavior.floating,
              ),
            );
            return false;
          }
          if (_threadCount < 1) {
            HapticFeedback.mediumImpact();
            messenger.showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.white),
                    SizedBox(width: 8),
                    Expanded(child: Text('⚠️ يرجى تحديد عدد الخيوط')),
                  ],
                ),
                backgroundColor: Colors.orange,
                behavior: SnackBarBehavior.floating,
              ),
            );
            return false;
          }
        }
        return true;

      case 3:
        if (!_giftFormKey.currentState!.validate()) {
          HapticFeedback.mediumImpact();
          return false;
        }
        return true;

      default:
        return true;
    }
  }

  Future<void> _submitGiftOrder() async {
    if (_isSubmitting) return;
    if (!_giftFormKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final l10n = AppLocalizations.of(context)!;

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.pleaseLoginFirst),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isSubmitting = false);
        return;
      }

      final giftRecipientDetails = GiftRecipientDetails(
        recipientName: _recipientNameCtrl.text.trim(),
        recipientPhone: _recipientPhoneCtrl.text.trim().isEmpty
            ? null
            : _recipientPhoneCtrl.text.trim(),
        giftMessage: _giftMessageCtrl.text.trim().isEmpty
            ? null
            : _giftMessageCtrl.text.trim(),
        deliveryNotes: _deliveryNotesCtrl.text.trim().isEmpty
            ? null
            : _deliveryNotesCtrl.text.trim(),
      );

      final order = OrderModel(
        id: '',
        customerId: user.uid,
        customerName: user.name,
        customerPhone: user.phoneNumber ?? '',
        tailorId: widget.tailorId,
        tailorName: widget.tailorName,
        fabricId: _selectedFabricId ?? '',
        fabricName: _fabricType ?? '',
        fabricType: _fabricType ?? '',
        fabricImageUrl: _fabricThumb ?? '',
        fabricColor: '',
        fabricColorHex: '',
        measurements: {
          'الطول': double.tryParse(_lengthCtrl.text) ?? 0,
          'الكتف': double.tryParse(_shoulderCtrl.text) ?? 0,
          'الرقبة': double.tryParse(_neckCtrl.text) ?? 0,
          'طول الذراع': double.tryParse(_armLengthCtrl.text) ?? 0,
          'عرض المعصم': double.tryParse(_wristWidthCtrl.text) ?? 0,
          'عرض الصدر مع الجانبيين': double.tryParse(_chestWidthCtrl.text) ?? 0,
          'الوسع السفلي': double.tryParse(_bottomWidthCtrl.text) ?? 0,
          'طول النقشة': double.tryParse(_patternLengthCtrl.text) ?? 0,
        },
        notes: _notesCtrl.text.trim(),
        embroideryDesignId: _selectedEmbroidery?.id,
        embroideryDesignName: _selectedEmbroidery?.name,
        embroideryDesignImageUrl: _selectedEmbroidery?.imageUrl,
        embroideryDesignPrice: _selectedEmbroidery?.price,
        threadColorIds:
            _selectedThreadColorIds.isNotEmpty ? _selectedThreadColorIds : null,
        threadCount: _selectedEmbroidery != null ? _threadCount : null,
        isGift: true,
        giftRecipientDetails: giftRecipientDetails,
        totalPrice: _price,
        status: OrderStatus.pending,
        createdAt: DateTime.now(),
      );

      await OrderService.submitOrder(order);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.card_giftcard_rounded, color: Colors.white),
                SizedBox(width: 8),
                Text('🎁 تم إرسال طلب الهدية بنجاح!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        Navigator.pop(context);
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
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _back();
      },
      child: Scaffold(
        backgroundColor: cs.surface,
        appBar: PremiumStoreAppBar(
          title: widget.tailorName,
          locationText: 'هدية 🎁',
          gradientColors: const [
            Color(0xFFE91E63),
            Color(0xFFF06292),
            Color(0xFFF8BBD9),
          ],
        ),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              // ===== شريط التقدّم =====
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: _GiftStepperHeader(
                      current: _step,
                      labels: const [
                        'القماش',
                        'المقاسات و اللون',
                        'التطريز',
                        'بيانات المستلم'
                      ],
                    ),
                  ),
                ),
              ),

              // ===== الصفحات =====
              Expanded(
                child: PageView(
                  controller: _pager,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    // الخطوة 1: القماش
                    _GiftFabricStep(
                      tailorId: widget.tailorId,
                      selectedType: _fabricType,
                      selectedFabricId: _selectedFabricId,
                      onTypeChanged: (v, thumb, fabricId) => setState(() {
                        _fabricType = v;
                        _fabricThumb = thumb;
                        _selectedFabricId = fabricId;
                      }),
                      onNext: _next,
                    ),

                    // الخطوة 2: المقاسات واللون
                    _GiftMeasurementsStep(
                      fabricId: _selectedFabricId ?? '',
                      formKey: _formKey,
                      unit: _unit,
                      onUnitChanged: _switchUnit,
                      onNext: _next,
                      lengthCtrl: _lengthCtrl,
                      shoulderCtrl: _shoulderCtrl,
                      neckCtrl: _neckCtrl,
                      armLengthCtrl: _armLengthCtrl,
                      wristWidthCtrl: _wristWidthCtrl,
                      chestWidthCtrl: _chestWidthCtrl,
                      bottomWidthCtrl: _bottomWidthCtrl,
                      patternLengthCtrl: _patternLengthCtrl,
                    ),

                    // الخطوة 3: التطريز
                    _GiftEmbroideryStep(
                      tailorId: widget.tailorId,
                      selectedEmbroidery: _selectedEmbroidery,
                      onEmbroideryChanged: (design) => setState(() {
                        _selectedEmbroidery = design;
                        // إعادة تعيين الخيوط عند تغيير التصميم
                        if (design != null) {
                          _selectedThreadColorIds = [];
                          _threadCount = design.minThreads;
                        }
                      }),
                      selectedThreadColorIds: _selectedThreadColorIds,
                      onThreadColorsChanged: (colors) => setState(() {
                        _selectedThreadColorIds = colors;
                      }),
                      threadCount: _threadCount,
                      onThreadCountChanged: (count) => setState(() {
                        _threadCount = count;
                      }),
                      onNext: _next,
                      totalPrice: _price,
                    ),

                    // الخطوة 4: بيانات مستلم الهدية
                    _GiftRecipientStep(
                      formKey: _giftFormKey,
                      recipientNameCtrl: _recipientNameCtrl,
                      recipientPhoneCtrl: _recipientPhoneCtrl,
                      giftMessageCtrl: _giftMessageCtrl,
                      deliveryNotesCtrl: _deliveryNotesCtrl,
                      onSubmit: _submitGiftOrder,
                      isSubmitting: _isSubmitting,
                      totalPrice: _price,
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
}

// ==================== وحدات القياس ====================
enum MeasurementUnit { cm, inch }

extension MeasurementUnitX on MeasurementUnit {
  String get labelAr => this == MeasurementUnit.cm ? 'سم' : 'إنش';
}

// ==================== شريط التقدم للهدايا ====================
class _GiftStepperHeader extends StatelessWidget {
  final int current;
  final List<String> labels;

  const _GiftStepperHeader({
    required this.current,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Row(
      children: List.generate(labels.length * 2 - 1, (index) {
        if (index.isOdd) {
          // الخط الفاصل
          final stepIndex = index ~/ 2;
          final isCompleted = stepIndex < current;
          return Expanded(
            child: Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isCompleted
                    ? const Color(0xFFE91E63)
                    : cs.outlineVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          );
        }

        // الدائرة
        final stepIndex = index ~/ 2;
        final isActive = stepIndex == current;
        final isCompleted = stepIndex < current;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isActive ? 36 : 28,
              height: isActive ? 36 : 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted || isActive
                    ? const Color(0xFFE91E63)
                    : cs.surfaceContainerHighest,
                border: Border.all(
                  color: isActive
                      ? const Color(0xFFE91E63)
                      : isCompleted
                          ? const Color(0xFFE91E63)
                          : cs.outlineVariant,
                  width: 2,
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: const Color(0xFFE91E63).withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check_rounded,
                        color: Colors.white, size: 16)
                    : Text(
                        '${stepIndex + 1}',
                        style: tt.labelMedium?.copyWith(
                          color: isActive ? Colors.white : cs.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              labels[stepIndex],
              style: tt.labelSmall?.copyWith(
                color: isActive
                    ? const Color(0xFFE91E63)
                    : isCompleted
                        ? cs.onSurface
                        : cs.onSurfaceVariant,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );
      }),
    );
  }
}

// ==================== خطوة القماش للهدايا ====================
class _GiftFabricStep extends StatefulWidget {
  final String tailorId;
  final String? selectedType;
  final String? selectedFabricId;
  final void Function(String type, String? thumb, String? fabricId)
      onTypeChanged;
  final VoidCallback onNext;

  const _GiftFabricStep({
    required this.tailorId,
    required this.selectedType,
    required this.selectedFabricId,
    required this.onTypeChanged,
    required this.onNext,
  });

  @override
  State<_GiftFabricStep> createState() => _GiftFabricStepState();
}

class _GiftFabricStepState extends State<_GiftFabricStep> {
  List<Map<String, dynamic>> _fabrics = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFabrics();
  }

  Future<void> _loadFabrics() async {
    try {
      final fabrics =
          await FabricService.getTailorFabrics(widget.tailorId).first;
      if (mounted) {
        setState(() {
          _fabrics = fabrics;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFE91E63)),
      );
    }

    if (_fabrics.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined,
                size: 64, color: cs.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.noFabricsAvailable, style: tt.titleMedium),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'اختر نوع القماش للهدية',
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: _fabrics.length,
            itemBuilder: (context, index) {
              final fabric = _fabrics[index];
              final isSelected = widget.selectedFabricId == fabric['id'];

              final imageUrl = fabric['imageUrl'] ?? fabric['thumb'];

              return GestureDetector(
                onTap: () {
                  widget.onTypeChanged(
                    fabric['name'] ?? '',
                    imageUrl,
                    fabric['id'],
                  );
                  HapticFeedback.selectionClick();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFE91E63)
                          : cs.outlineVariant.withOpacity(0.3),
                      width: isSelected ? 2.5 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFFE91E63).withOpacity(0.2),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 3,
                          child: imageUrl != null
                              ? Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: cs.surfaceContainerHighest,
                                    child: Icon(Icons.image_not_supported,
                                        color: cs.onSurfaceVariant),
                                  ),
                                )
                              : Container(
                                  color: cs.surfaceContainerHighest,
                                  child: Icon(Icons.checkroom_rounded,
                                      size: 40, color: cs.onSurfaceVariant),
                                ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Container(
                            color: cs.surface,
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  fabric['name'] ?? 'قماش',
                                  style: tt.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  fabric['type'] ?? '',
                                  style: tt.labelSmall?.copyWith(
                                    color: cs.onSurfaceVariant,
                                  ),
                                  maxLines: 1,
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
            },
          ),
        ),
        // زر المتابعة — في RTL السهم لليسار (←)
        Padding(
          padding: const EdgeInsets.all(20),
          child: FilledButton.icon(
            onPressed: widget.selectedFabricId != null ? widget.onNext : null,
            icon: Icon(Directionality.of(context) == TextDirection.rtl
                ? Icons.arrow_back_rounded
                : Icons.arrow_forward_rounded),
            label: Text(AppLocalizations.of(context)!.continueText),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              backgroundColor: const Color(0xFFE91E63),
            ),
          ),
        ),
      ],
    );
  }
}

// ==================== خطوة المقاسات للهدايا ====================
class _GiftMeasurementsStep extends StatelessWidget {
  final String fabricId;
  final GlobalKey<FormState> formKey;
  final MeasurementUnit unit;
  final ValueChanged<MeasurementUnit> onUnitChanged;
  final VoidCallback onNext;
  final TextEditingController lengthCtrl;
  final TextEditingController shoulderCtrl;
  final TextEditingController neckCtrl;
  final TextEditingController armLengthCtrl;
  final TextEditingController wristWidthCtrl;
  final TextEditingController chestWidthCtrl;
  final TextEditingController bottomWidthCtrl;
  final TextEditingController patternLengthCtrl;

  const _GiftMeasurementsStep({
    required this.fabricId,
    required this.formKey,
    required this.unit,
    required this.onUnitChanged,
    required this.onNext,
    required this.lengthCtrl,
    required this.shoulderCtrl,
    required this.neckCtrl,
    required this.armLengthCtrl,
    required this.wristWidthCtrl,
    required this.chestWidthCtrl,
    required this.bottomWidthCtrl,
    required this.patternLengthCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Form(
      key: formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // العنوان
            Text(
              'أدخل مقاسات مستلم الهدية',
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'يمكنك طلب المقاسات من مستلم الهدية أو تخمينها',
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // المقاسات
            _buildMeasurementField('الطول', lengthCtrl, context),
            _buildMeasurementField('الكتف', shoulderCtrl, context),
            _buildMeasurementField('الرقبة', neckCtrl, context),
            _buildMeasurementField('طول الذراع', armLengthCtrl, context),
            _buildMeasurementField('عرض المعصم', wristWidthCtrl, context),
            _buildMeasurementField(
                'عرض الصدر مع الجانبيين', chestWidthCtrl, context),
            _buildMeasurementField('الوسع السفلي', bottomWidthCtrl, context),
            _buildMeasurementField('طول النقشة', patternLengthCtrl, context),

            const SizedBox(height: 24),

            // زر المتابعة — في RTL السهم لليسار (←)
            FilledButton.icon(
              onPressed: onNext,
              icon: Icon(Directionality.of(context) == TextDirection.rtl
                  ? Icons.arrow_back_rounded
                  : Icons.arrow_forward_rounded),
              label: Text(AppLocalizations.of(context)!.continueText),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                backgroundColor: const Color(0xFFE91E63),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementField(
    String label,
    TextEditingController controller,
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          suffixText: unit.labelAr,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE91E63), width: 2),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'مطلوب';
          }
          if (double.tryParse(value) == null) {
            return 'أدخل رقماً صحيحاً';
          }
          return null;
        },
      ),
    );
  }
}

// ==================== خطوة التطريز للهدايا ====================
class _GiftEmbroideryStep extends StatefulWidget {
  final String tailorId;
  final EmbroideryDesign? selectedEmbroidery;
  final ValueChanged<EmbroideryDesign?> onEmbroideryChanged;
  final List<String> selectedThreadColorIds;
  final ValueChanged<List<String>> onThreadColorsChanged;
  final int threadCount;
  final ValueChanged<int> onThreadCountChanged;
  final VoidCallback onNext;
  final double totalPrice;

  const _GiftEmbroideryStep({
    required this.tailorId,
    required this.selectedEmbroidery,
    required this.onEmbroideryChanged,
    required this.selectedThreadColorIds,
    required this.onThreadColorsChanged,
    required this.threadCount,
    required this.onThreadCountChanged,
    required this.onNext,
    required this.totalPrice,
  });

  @override
  State<_GiftEmbroideryStep> createState() => _GiftEmbroideryStepState();
}

class _GiftEmbroideryStepState extends State<_GiftEmbroideryStep> {
  /// Cache: لا نعيد الجلب عند كل فتح للشيت
  List<EmbroideryDesign> _designsCache = [];
  List<ThreadColor> _threadColors = [];
  bool _loadingColors = false;

  @override
  void didUpdateWidget(covariant _GiftEmbroideryStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedEmbroidery?.id != oldWidget.selectedEmbroidery?.id &&
        widget.selectedEmbroidery != null) {
      _loadThreadColors();
    }
  }

  Future<void> _loadThreadColors() async {
    setState(() => _loadingColors = true);
    try {
      final colors = await EmbroideryService().getThreadColors(widget.tailorId);
      if (mounted) {
        setState(() {
          _threadColors = colors;
          _loadingColors = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingColors = false);
      }
    }
  }

  void _showEmbroideryPicker() {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EmbroideryPickerSheet(
        tailorId: widget.tailorId,
        initialDesigns: _designsCache.isEmpty ? null : _designsCache,
        selectedEmbroideryId: widget.selectedEmbroidery?.id,
        onSelect: (design) {
          widget.onEmbroideryChanged(design);
          HapticFeedback.selectionClick();
          Navigator.pop(context);
        },
        onCache: (list) {
          if (mounted) setState(() => _designsCache = list);
        },
        themeColorScheme: cs,
        themeTextTheme: tt,
      ),
    );
  }

  Color _parseHexColor(String hex) {
    final cleanHex = hex.replaceFirst('#', '');
    return Color(int.parse('FF$cleanHex', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final hasEmbroidery = widget.selectedEmbroidery != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'اختر تصميم التطريز',
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'حدد نوع التطريز وألوان الخيوط',
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Material(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: _showEmbroideryPicker,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: hasEmbroidery
                        ? const Color(0xFFE91E63)
                        : cs.outlineVariant.withOpacity(0.5),
                    width: hasEmbroidery ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 88,
                      height: 88,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: hasEmbroidery &&
                                widget.selectedEmbroidery!.imageUrl.isNotEmpty
                            ? Image.network(
                                widget.selectedEmbroidery!.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: cs.surfaceContainerHighest,
                                  child: Icon(
                                    Icons.design_services_rounded,
                                    size: 40,
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                              )
                            : Container(
                                color: cs.surfaceContainerHighest,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.design_services_rounded,
                                        size: 36,
                                        color: cs.onSurfaceVariant,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'اضغط لاختيار',
                                        style: tt.labelSmall?.copyWith(
                                          color: cs.onSurfaceVariant,
                                          fontSize: 10,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 26,
                      color: hasEmbroidery
                          ? const Color(0xFFE91E63)
                          : cs.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (hasEmbroidery) _buildThreadOptions(cs, tt),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFCE4EC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppLocalizations.of(context)!.totalPriceLabel,
                    style:
                        tt.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                Text(
                  '${widget.totalPrice.toStringAsFixed(3)} ر.ع',
                  style: tt.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFE91E63),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _canProceed() ? widget.onNext : null,
            icon: Icon(Directionality.of(context) == TextDirection.rtl
                ? Icons.arrow_back_rounded
                : Icons.arrow_forward_rounded),
            label: Text(AppLocalizations.of(context)!.continueToRecipientData),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              backgroundColor: const Color(0xFFE91E63),
              disabledBackgroundColor: cs.surfaceContainerHighest,
            ),
          ),
          if (hasEmbroidery && !_canProceed()) ...[
            const SizedBox(height: 12),
            Text(
              'يرجى اختيار لون الخيط وعدد الخيوط للمتابعة',
              style: tt.labelSmall?.copyWith(color: Colors.orange),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildThreadOptions(ColorScheme cs, TextTheme tt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFFCE4EC),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.palette_rounded, color: Color(0xFFE91E63)),
              const SizedBox(width: 12),
              Text(
                'تفاصيل الخيوط',
                style: tt.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFAD1457),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'لون الخيط',
          style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        if (_loadingColors)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(color: Color(0xFFE91E63)),
            ),
          )
        else if (_threadColors.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: cs.onSurfaceVariant),
                const SizedBox(width: 12),
                Text(
                  'لا توجد ألوان متاحة',
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          )
        else
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _threadColors.map((color) {
              final isSelected =
                  widget.selectedThreadColorIds.contains(color.id);

              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  List<String> newColors =
                      List.from(widget.selectedThreadColorIds);
                  if (isSelected) {
                    newColors.remove(color.id);
                  } else {
                    if (widget.selectedEmbroidery!.multiColorSupported) {
                      newColors.add(color.id);
                    } else {
                      newColors = [color.id];
                    }
                  }
                  widget.onThreadColorsChanged(newColors);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _parseHexColor(color.hexCode).withOpacity(0.15)
                        : cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isSelected
                          ? _parseHexColor(color.hexCode)
                          : cs.outlineVariant.withOpacity(0.5),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: _parseHexColor(color.hexCode),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: color.hexCode.toLowerCase() == '#ffffff'
                                ? cs.outlineVariant
                                : Colors.transparent,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _parseHexColor(color.hexCode)
                                  .withOpacity(0.3),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: isSelected
                            ? Icon(
                                Icons.check,
                                size: 14,
                                color: color.hexCode.toLowerCase() == '#ffffff'
                                    ? Colors.black
                                    : Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        color.name,
                        style: tt.bodySmall?.copyWith(
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected
                              ? _parseHexColor(color.hexCode)
                              : cs.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        const SizedBox(height: 24),
        Text(
          'عدد الخيوط',
          style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.outlineVariant.withOpacity(0.5)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Material(
                color: widget.threadCount >
                        (widget.selectedEmbroidery?.minThreads ?? 1)
                    ? const Color(0xFFFCE4EC)
                    : cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: widget.threadCount >
                          (widget.selectedEmbroidery?.minThreads ?? 1)
                      ? () {
                          HapticFeedback.selectionClick();
                          widget.onThreadCountChanged(widget.threadCount - 1);
                        }
                      : null,
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: Icon(
                      Icons.remove_rounded,
                      color: widget.threadCount >
                              (widget.selectedEmbroidery?.minThreads ?? 1)
                          ? const Color(0xFFE91E63)
                          : cs.onSurfaceVariant.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  Text(
                    '${widget.threadCount}',
                    style: tt.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFE91E63),
                    ),
                  ),
                  Text(
                    'خيط',
                    style: tt.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              Material(
                color: widget.threadCount <
                        (widget.selectedEmbroidery?.maxThreads ?? 5)
                    ? const Color(0xFFFCE4EC)
                    : cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: widget.threadCount <
                          (widget.selectedEmbroidery?.maxThreads ?? 5)
                      ? () {
                          HapticFeedback.selectionClick();
                          widget.onThreadCountChanged(widget.threadCount + 1);
                        }
                      : null,
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: Icon(
                      Icons.add_rounded,
                      color: widget.threadCount <
                              (widget.selectedEmbroidery?.maxThreads ?? 5)
                          ? const Color(0xFFE91E63)
                          : cs.onSurfaceVariant.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'الحد: ${widget.selectedEmbroidery?.minThreads ?? 1} - ${widget.selectedEmbroidery?.maxThreads ?? 5} خيوط',
          style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  bool _canProceed() {
    if (widget.selectedEmbroidery == null) return true;
    return widget.selectedThreadColorIds.isNotEmpty && widget.threadCount > 0;
  }
}

/// شيت اختيار التطريز: يجلب التصاميم مرة واحدة ويعرض loading / empty / error / success
class _EmbroideryPickerSheet extends StatefulWidget {
  final String tailorId;
  final List<EmbroideryDesign>? initialDesigns;
  final String? selectedEmbroideryId;
  final ValueChanged<EmbroideryDesign> onSelect;
  final ValueChanged<List<EmbroideryDesign>>? onCache;
  final ColorScheme themeColorScheme;
  final TextTheme themeTextTheme;

  const _EmbroideryPickerSheet({
    required this.tailorId,
    required this.initialDesigns,
    required this.selectedEmbroideryId,
    required this.onSelect,
    this.onCache,
    required this.themeColorScheme,
    required this.themeTextTheme,
  });

  @override
  State<_EmbroideryPickerSheet> createState() => _EmbroideryPickerSheetState();
}

class _EmbroideryPickerSheetState extends State<_EmbroideryPickerSheet> {
  late Future<List<EmbroideryDesign>> _future;
  bool _cacheReported = false;

  @override
  void initState() {
    super.initState();
    _loadDesigns();
  }

  void _loadDesigns() {
    _cacheReported = false;
    final cache = widget.initialDesigns;
    _future = (cache != null && cache.isNotEmpty)
        ? Future.value(cache)
        : EmbroideryService().getEmbroideryDesigns(widget.tailorId);
  }

  @override
  Widget build(BuildContext context) {
    final cs = widget.themeColorScheme;
    final tt = widget.themeTextTheme;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: cs.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.design_services_rounded,
                    color: Color(0xFFE91E63)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'اختر تصميم التطريز',
                    style:
                        tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                  color: cs.onSurfaceVariant,
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: FutureBuilder<List<EmbroideryDesign>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFE91E63)),
                  );
                }
                if (snapshot.hasError) {
                  return _ErrorState(
                    message: snapshot.error?.toString() ?? 'حدث خطأ',
                    onRetry: () {
                      setState(() => _loadDesigns());
                    },
                    cs: cs,
                    tt: tt,
                  );
                }
                final designs = snapshot.data ?? [];
                if (designs.isNotEmpty &&
                    widget.onCache != null &&
                    !_cacheReported) {
                  _cacheReported = true;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    widget.onCache!(designs);
                  });
                }
                if (designs.isEmpty) {
                  return _EmptyState(cs: cs, tt: tt);
                }
                return GridView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.95,
                  ),
                  itemCount: designs.length,
                  itemBuilder: (context, index) {
                    final design = designs[index];
                    final isSelected = widget.selectedEmbroideryId == design.id;

                    return Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      child: InkWell(
                        onTap: () => widget.onSelect(design),
                        borderRadius: BorderRadius.circular(20),
                        splashColor: const Color(0xFFE91E63).withOpacity(0.15),
                        highlightColor:
                            const Color(0xFFE91E63).withOpacity(0.08),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: isSelected ? 16 : 10,
                                offset: const Offset(0, 4),
                                spreadRadius: isSelected ? 1 : 0,
                              ),
                              if (isSelected)
                                BoxShadow(
                                  color:
                                      const Color(0xFFE91E63).withOpacity(0.25),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                  spreadRadius: 0,
                                ),
                            ],
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFE91E63)
                                  : Colors.white,
                              width: isSelected ? 2.5 : 1,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                design.imageUrl.isNotEmpty
                                    ? Image.network(
                                        design.imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          color: const Color(0xFFF5F5F5),
                                          child: Icon(
                                            Icons.design_services_rounded,
                                            size: 56,
                                            color: cs.onSurfaceVariant
                                                .withOpacity(0.5),
                                          ),
                                        ),
                                      )
                                    : Container(
                                        color: const Color(0xFFF5F5F5),
                                        child: Icon(
                                          Icons.design_services_rounded,
                                          size: 56,
                                          color: cs.onSurfaceVariant
                                              .withOpacity(0.5),
                                        ),
                                      ),
                                if (isSelected) ...[
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            const Color(0xFFE91E63)
                                                .withOpacity(0.15),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE91E63),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFFE91E63)
                                                .withOpacity(0.4),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.check_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final ColorScheme cs;
  final TextTheme tt;

  const _EmptyState({required this.cs, required this.tt});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.design_services_outlined,
              size: 48, color: cs.onSurfaceVariant),
          const SizedBox(height: 12),
          Text(AppLocalizations.of(context)!.noDesignsAvailable, style: tt.bodyMedium),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final ColorScheme cs;
  final TextTheme tt;

  const _ErrorState({
    required this.message,
    required this.onRetry,
    required this.cs,
    required this.tt,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 48, color: cs.error),
            const SizedBox(height: 16),
            Text(
              'فشل تحميل التصاميم',
              style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(AppLocalizations.of(context)!.retry),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFE91E63),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== خطوة بيانات مستلم الهدية ====================
class _GiftRecipientStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController recipientNameCtrl;
  final TextEditingController recipientPhoneCtrl;
  final TextEditingController giftMessageCtrl;
  final TextEditingController deliveryNotesCtrl;
  final VoidCallback onSubmit;
  final bool isSubmitting;
  final double totalPrice;

  const _GiftRecipientStep({
    required this.formKey,
    required this.recipientNameCtrl,
    required this.recipientPhoneCtrl,
    required this.giftMessageCtrl,
    required this.deliveryNotesCtrl,
    required this.onSubmit,
    required this.isSubmitting,
    required this.totalPrice,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Form(
      key: formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // الأيقونة والعنوان
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFCE4EC), Color(0xFFF8BBD9)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE91E63).withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.card_giftcard_rounded,
                      size: 40,
                      color: Color(0xFFE91E63),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'بيانات مستلم الهدية',
                    style: tt.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFAD1457),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'أدخل معلومات الشخص الذي سيستلم الهدية',
                    style: tt.bodyMedium?.copyWith(
                      color: const Color(0xFFC2185B),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // اسم المستلم (مطلوب)
            TextFormField(
              controller: recipientNameCtrl,
              decoration: InputDecoration(
                labelText: l10n.recipientName,
                hintText: l10n.enterRecipientName,
                prefixIcon: const Icon(Icons.person_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFFE91E63), width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.recipientNameRequired;
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // رقم هاتف المستلم (اختياري)
            TextFormField(
              controller: recipientPhoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: l10n.recipientPhoneOptional,
                hintText: l10n.forDeliveryCoordination,
                prefixIcon: const Icon(Icons.phone_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFFE91E63), width: 2),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // رسالة الهدية (اختياري)
            TextFormField(
              controller: giftMessageCtrl,
              maxLines: 3,
              maxLength: 200,
              decoration: InputDecoration(
                labelText: l10n.giftMessageOptional,
                hintText: l10n.writeShortMessageToRecipient,
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 50),
                  child: Icon(Icons.message_rounded),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFFE91E63), width: 2),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ملاحظات التوصيل (اختياري)
            TextFormField(
              controller: deliveryNotesCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: l10n.deliveryNotesOptional,
                hintText: l10n.deliveryNotesExample,
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 25),
                  child: Icon(Icons.local_shipping_rounded),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFFE91E63), width: 2),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // السعر الإجمالي
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFCE4EC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE91E63).withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.receipt_long_rounded,
                          color: Color(0xFFE91E63)),
                      const SizedBox(width: 8),
                      Text(l10n.totalAmount,
                          style: tt.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  Text(
                    '${totalPrice.toStringAsFixed(3)} ر.ع',
                    style: tt.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFE91E63),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // زر إرسال الطلب
            FilledButton.icon(
              onPressed: isSubmitting ? null : onSubmit,
              icon: isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.card_giftcard_rounded),
              label: Text(isSubmitting ? l10n.sending : l10n.sendGiftRequest),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                backgroundColor: const Color(0xFFE91E63),
                textStyle:
                    tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
