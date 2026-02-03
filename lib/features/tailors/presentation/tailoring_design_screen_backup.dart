import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/widgets/premium_app_bar.dart';
import '../services/fabric_service.dart';
import '../services/embroidery_service.dart';
import '../models/embroidery_design.dart';
import '../../orders/services/order_service.dart';
import '../../orders/models/order_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../measurements/models/measurement_profile.dart';
import '../../measurements/services/measurement_service.dart';

bool _isNetworkPath(String p) =>
    p.startsWith('http://') || p.startsWith('https://');

/// ===== وحدات القياس =====
enum MeasurementUnit { cm, inch }

extension MeasurementUnitX on MeasurementUnit {
  String get labelAr => this == MeasurementUnit.cm ? 'سم' : 'إنش';
  String get labelEn => this == MeasurementUnit.cm ? 'cm' : 'in';
}

const double _cmPerInch = 2.54;

/// شاشة تفصيل الثوب - أنيقة بالعربي
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
  // ==== فورم المقاسات ====
  final _formKey = GlobalKey<FormState>();

  // المقاسات الثمانية فقط (بالعربي):
  final _lengthCtrl = TextEditingController(); // الطول
  final _shoulderCtrl = TextEditingController(); // الكتف
  final _neckCtrl = TextEditingController(); // الرقبة
  final _armLengthCtrl = TextEditingController(); // طول الذراع
  final _wristWidthCtrl = TextEditingController(); // عرض المعصم
  final _chestWidthCtrl = TextEditingController(); // عرض الصدر مع الجانبيين
  final _bottomWidthCtrl = TextEditingController(); // الوسع السفلي
  final _patternLengthCtrl = TextEditingController(); // طول النقشة
  final _notesCtrl = TextEditingController(); // ملاحظات (للطلب)

  // ==== معالج الخطوات ====
  final _pager = PageController();
  int _step = 0; // 0..2 (القماش، المقاسات+اللون، التطريز)

  // ==== القماش ====
  String? _fabricType; // الاسم الظاهر
  String? _fabricThumb; // asset أو رابط
  String? _selectedFabricId; // معرف القماش المحدد

  // ==== التطريز ====
  Color _embroideryColor = const Color(0xFF795548);
  int _embroideryLines = 0; // 0..3
  EmbroideryDesign? _selectedEmbroidery; // التطريز المختار

  // ==== الوحدات ====
  MeasurementUnit _unit = MeasurementUnit.cm; // افتراضيًا سم

  // ==== إرسال الطلب الحقيقي ====
  Future<void> _submitRealOrder() async {
    if (!_formKey.currentState!.validate()) return;

    // التحقق من البيانات المطلوبة
    if (_fabricType == null || _selectedFabricId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار القماش أولاً')),
      );
      return;
    }

    // إظهار مؤشر التحميل
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.currentUser;

      if (currentUser == null) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يرجى تسجيل الدخول أولاً')),
        );
        return;
      }

      final order = OrderModel(
        id: '', // سيتم إنشاؤه تلقائياً
        customerId: currentUser.uid, // معرف المستخدم الحقيقي
        customerName: currentUser.name, // اسم المستخدم الحقيقي
        customerPhone:
            currentUser.phoneNumber ?? '+968 00000000', // رقم المستخدم
        tailorId: widget.tailorId,
        tailorName: widget.tailorName,
        fabricId: _selectedFabricId!,
        fabricName: _fabricType!,
        fabricType: _fabricType!,
        fabricImageUrl: _fabricThumb ?? '',
        fabricColor: '5C6BC0', // لون افتراضي
        fabricColorHex: '#FF5C6BC0',
        measurements: {
          'الطول': double.tryParse(_lengthCtrl.text) ?? 0.0,
          'الكتف': double.tryParse(_shoulderCtrl.text) ?? 0.0,
          'الرقبة': double.tryParse(_neckCtrl.text) ?? 0.0,
          'طول الذراع': double.tryParse(_armLengthCtrl.text) ?? 0.0,
          'عرض المعصم': double.tryParse(_wristWidthCtrl.text) ?? 0.0,
          'عرض الصدر مع الجانبيين':
              double.tryParse(_chestWidthCtrl.text) ?? 0.0,
          'الوسع السفلي': double.tryParse(_bottomWidthCtrl.text) ?? 0.0,
          'طول النقشة': double.tryParse(_patternLengthCtrl.text) ?? 0.0,
        },
        notes: _notesCtrl.text,
        embroideryDesignId: _selectedEmbroidery?.id,
        embroideryDesignName: _selectedEmbroidery?.name,
        embroideryDesignImageUrl: _selectedEmbroidery?.imageUrl,
        embroideryDesignPrice: _selectedEmbroidery?.price,
        totalPrice: _price,
        status: OrderStatus.pending,
        createdAt: DateTime.now(),
      );

      // إرسال الطلب
      final orderId = await OrderService.submitOrder(order);

      // إخفاء مؤشر التحميل
      Navigator.pop(context);

      if (orderId != null) {
        // إظهار رسالة النجاح
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('تم إرسال الطلب بنجاح!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('رقم الطلب: $orderId'),
                const SizedBox(height: 8),
                Text('الخياط: ${widget.tailorName}'),
                const SizedBox(height: 8),
                Text('الإجمالي: ر.ع ${_price.toStringAsFixed(3)}'),
                const SizedBox(height: 8),
                const Text('سيتم التواصل معك قريباً لتأكيد التفاصيل'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context); // العودة للشاشة السابقة
                },
                child: const Text('موافق'),
              ),
            ],
          ),
        );
      } else {
        // إظهار رسالة الخطأ
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('حدث خطأ في إرسال الطلب، يرجى المحاولة مرة أخرى')),
        );
      }
    } catch (e) {
      // إخفاء مؤشر التحميل
      Navigator.pop(context);

      // إظهار رسالة الخطأ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: $e')),
      );
    }
  }

  // ==== التسعير ====
  double get _price {
    double p = widget.basePriceOMR;
    if (_fabricType == 'فاخر') p += 1.500;
    if (_fabricType == 'شتوي') p += 0.800;
    p += (_embroideryLines * 0.250);
    // إضافة سعر تصميم التطريز المختار
    if (_selectedEmbroidery != null && _selectedEmbroidery!.price > 0) {
      p += _selectedEmbroidery!.price;
    }
    return p;
  }

  // الحصول على اسم اللون بالعربي
  String _getColorName(Color color) {
    const colorNames = {
      0xFF3F51B5: 'أزرق',
      0xFF009688: 'تركواز',
      0xFFFF5722: 'برتقالي',
      0xFF795548: 'بني',
      0xFF607D8B: 'رمادي مزرق',
      0xFF9C27B0: 'بنفسجي',
      0xFF1B5E20: 'أخضر داكن',
      0xFFB71C1C: 'أحمر داكن',
    };

    return colorNames[color.value] ?? 'لون مخصص';
  }

  @override
  void dispose() {
    _pager.dispose();
    for (final c in [
      _lengthCtrl,
      _shoulderCtrl,
      _neckCtrl,
      _armLengthCtrl,
      _wristWidthCtrl,
      _chestWidthCtrl,
      _bottomWidthCtrl,
      _patternLengthCtrl,
      _notesCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // ==== تنقّل الخطوات ====
  // ignore: unused_element - يمكن استخدامها لاحقاً من داخل الخطوات أو من مكان آخر
  void _next() async {
    // إخفاء لوحة المفاتيح
    FocusScope.of(context).unfocus();

    // الانتظار قليلاً لإخفاء لوحة المفاتيح
    await Future.delayed(const Duration(milliseconds: 100));

    // التحقق من إمكانية المتابعة
    if (!_canProceed(_step)) return;

    if (_step < 2) {
      // الانتقال للخطوة التالية
      setState(() => _step++);
      await _pager.animateToPage(
        _step,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
      );
      HapticFeedback.lightImpact();
    } else {
      // إرسال الطلب
      _submitOrder();
    }
  }

  void _back() async {
    // إخفاء لوحة المفاتيح
    FocusScope.of(context).unfocus();

    if (_step > 0) {
      // العودة للخطوة السابقة
      setState(() => _step--);
      await _pager.animateToPage(
        _step,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOutCubic,
      );
      HapticFeedback.lightImpact();
    } else {
      // الخروج من الشاشة
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }
  }

  bool _canProceed(int step) {
    final messenger = ScaffoldMessenger.of(context);

    switch (step) {
      case 0:
        // التحقق من اختيار القماش
        if (_fabricType == null || _selectedFabricId == null) {
          HapticFeedback.mediumImpact();
          messenger.showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(child: Text('⚠️ يرجى اختيار نوع القماش أولاً')),
                ],
              ),
              backgroundColor: Colors.orange.shade700,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
          return false;
        }
        return true;

      case 1:
        // التحقق من المقاسات
        if (!(_formKey.currentState?.validate() ?? false)) {
          HapticFeedback.mediumImpact();
          messenger.showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.straighten_rounded, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(
                      child: Text('📏 يرجى إدخال جميع المقاسات بشكل صحيح')),
                ],
              ),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
          return false;
        }
        return true;

      default:
        return true;
    }
  }

  double? _parseNum(String s) {
    final t = s.trim().replaceAll(',', '.');
    return double.tryParse(t.isEmpty ? '' : t);
  }

  /// تحويل الحقول عند تغيير الوحدة
  void _switchUnit(MeasurementUnit newUnit) {
    if (newUnit == _unit) return;

    double? convert(String text) {
      final v = _parseNum(text);
      if (v == null) return null;
      final inCm = _unit == MeasurementUnit.cm ? v : v * _cmPerInch;
      final res = newUnit == MeasurementUnit.cm ? inCm : (inCm / _cmPerInch);
      return res;
    }

    void apply(TextEditingController c) {
      final v = convert(c.text);
      if (v == null) return;
      final dec = newUnit == MeasurementUnit.cm ? 1 : 2;
      c.text = v.toStringAsFixed(dec);
    }

    setState(() {
      for (final c in [
        _lengthCtrl,
        _shoulderCtrl,
        _neckCtrl,
        _armLengthCtrl,
        _wristWidthCtrl,
        _chestWidthCtrl,
        _bottomWidthCtrl,
        _patternLengthCtrl,
      ]) {
        apply(c);
      }
      _unit = newUnit;
    });

    HapticFeedback.selectionClick();
  }

  // ==== الإرسال (مراجعة الطلب) ====
  void _submitOrder() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        final tt = Theme.of(context).textTheme;
        final cs = Theme.of(context).colorScheme;
        const chosenColorHex = 'حسب اختيارك السابق'; // لون تم اختياره مسبقاً
        String fmt(TextEditingController c) =>
            c.text.isEmpty ? '—' : '${c.text} ${_unit.labelAr}';
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 8,
              bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: ListView(
              shrinkWrap: true,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_rounded),
                      tooltip: 'رجوع',
                    ),
                    const SizedBox(width: 6),
                    Text('مراجعة الطلب',
                        style: tt.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900)),
                  ],
                ),
                const SizedBox(height: 10),
                _KV('الخياط', widget.tailorName),
                const _KV('المدينة', 'مسقط'),
                const Divider(height: 24),
                const _KV('مصدر القماش', 'قماش من المتجر'),
                _KV('نوع القماش', _fabricType ?? '—'),
                const _KV('لون القماش', chosenColorHex),
                if (_fabricThumb != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: _isNetworkPath(_fabricThumb!)
                          ? Image.network(
                              _fabricThumb!,
                              height: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _imgErr(cs),
                            )
                          : Image.asset(
                              _fabricThumb!,
                              height: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _imgErr(cs),
                            ),
                    ),
                  ),
                const Divider(height: 24),

                // قسم التطريز
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Text('التطريز',
                      style:
                          tt.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                ),
                const SizedBox(height: 6),

                // نوع تصميم التطريز
                if (_selectedEmbroidery != null) ...[
                  Row(
                    children: [
                      Expanded(
                        child: Text('تصميم التطريز',
                            style: tt.bodyMedium
                                ?.copyWith(color: cs.onSurfaceVariant)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            if (_selectedEmbroidery!.imageUrl.isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: _selectedEmbroidery!.imageUrl,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    width: 50,
                                    height: 50,
                                    color: cs.surfaceContainerHighest,
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                    width: 50,
                                    height: 50,
                                    color: cs.surfaceContainerHighest,
                                    child: Icon(
                                      Icons.image_not_supported_rounded,
                                      color: cs.onSurfaceVariant,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedEmbroidery!.name,
                                    style: tt.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (_selectedEmbroidery!.price > 0)
                                    Text(
                                      '+${_selectedEmbroidery!.price.toStringAsFixed(3)} ر.ع',
                                      style: tt.bodySmall?.copyWith(
                                        color: cs.primary,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ] else
                  const _KV('تصميم التطريز', 'لا يوجد'),

                // لون خيط التطريز
                Row(
                  children: [
                    Expanded(
                      child: Text('لون خيط التطريز',
                          style: tt.bodyMedium
                              ?.copyWith(color: cs.onSurfaceVariant)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: _embroideryColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _getColorName(_embroideryColor),
                            style: tt.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // عدد الخطوط الزخرفية
                _KV('الخطوط الزخرفية',
                    '$_embroideryLines ${_embroideryLines > 0 ? "(+${(_embroideryLines * 0.250).toStringAsFixed(3)} ر.ع)" : ""}'),

                const Divider(height: 24),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Text('المقاسات (رجالي)',
                      style:
                          tt.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                ),
                const SizedBox(height: 6),
                _KV('الطول', fmt(_lengthCtrl)),
                _KV('الكتف', fmt(_shoulderCtrl)),
                _KV('الرقبة', fmt(_neckCtrl)),
                _KV('طول الذراع', fmt(_armLengthCtrl)),
                _KV('عرض المعصم', fmt(_wristWidthCtrl)),
                _KV('عرض الصدر مع الجانبيين', fmt(_chestWidthCtrl)),
                _KV('الوسع السفلي', fmt(_bottomWidthCtrl)),
                _KV('طول النقشة', fmt(_patternLengthCtrl)),
                const Divider(height: 24),
                _KV('ملاحظات', _notesCtrl.text.isEmpty ? '—' : _notesCtrl.text),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text('الإجمالي',
                          style: tt.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w900)),
                    ),
                    Text('ر.ع ${_price.toStringAsFixed(3)}',
                        style: tt.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900)),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_rounded),
                        label: const Text('رجوع'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _submitRealOrder,
                        icon: const Icon(Icons.send_rounded),
                        label: const Text('تأكيد الإرسال'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _imgErr(ColorScheme cs) => Container(
        height: 120,
        color: cs.surfaceContainerHighest,
        alignment: Alignment.center,
        child:
            Icon(Icons.image_not_supported_rounded, color: cs.onSurfaceVariant),
      );

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return PopScope(
      canPop: _step == 0,
      onPopInvoked: (didPop) {
        if (!didPop && _step > 0) {
          _back();
        }
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: cs.surface,
          appBar: PremiumStoreAppBar(
            title: widget.tailorName,
            locationText: 'مسقط',
            onBack: () => Navigator.pop(context),
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
                      constraints: const BoxConstraints(maxWidth: 840),
                      child: _StepperHeader(
                        current: _step,
                        labels: const ['القماش', 'المقاسات و اللون', 'التطريز'],
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
                      _FabricStep(
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
                      _MeasurementsAndColorStep(
                        fabricId: _selectedFabricId ?? '',
                        formKey: _formKey,
                        unit: _unit,
                        onUnitChanged: _switchUnit,
                        lengthCtrl: _lengthCtrl,
                        shoulderCtrl: _shoulderCtrl,
                        neckCtrl: _neckCtrl,
                        armLengthCtrl: _armLengthCtrl,
                        wristWidthCtrl: _wristWidthCtrl,
                        chestWidthCtrl: _chestWidthCtrl,
                        bottomWidthCtrl: _bottomWidthCtrl,
                        patternLengthCtrl: _patternLengthCtrl,
                      ),
                      _EmbroideryStep(
                        color: _embroideryColor,
                        lines: _embroideryLines,
                        onChanged: (color, lines) => setState(() {
                          _embroideryColor = color;
                          _embroideryLines = lines;
                        }),
                        tailorId: widget.tailorId,
                        selectedEmbroidery: _selectedEmbroidery,
                        onEmbroideryChanged: (design) => setState(() {
                          _selectedEmbroidery = design;
                        }),
                      ),
                    ],
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

/* ===================== شريط التقدم (refined, premium) ===================== */
class _StepperHeader extends StatelessWidget {
  final int current;
  final List<String> labels;
  const _StepperHeader({required this.current, required this.labels});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final items = List.generate(labels.length, (i) {
      final active = i <= current;
      final completed = i < current;
      return Expanded(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StepDot(
              index: i + 1,
              label: labels[i],
              active: active,
              completed: completed,
              cs: cs,
              tt: tt,
            ),
            if (i < labels.length - 1)
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeInOutCubic,
                  height: 1.5,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color: active
                        ? cs.primary.withOpacity(0.4)
                        : cs.outlineVariant.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
          ],
        ),
      );
    });
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(children: items),
    );
  }
}

class _StepDot extends StatelessWidget {
  final int index;
  final String label;
  final bool active;
  final bool completed;
  final ColorScheme cs;
  final TextTheme tt;

  const _StepDot({
    required this.index,
    required this.label,
    required this.active,
    required this.completed,
    required this.cs,
    required this.tt,
  });

  @override
  Widget build(BuildContext context) {
    final isCurrent = active && !completed;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeInOutCubic,
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: completed
                ? cs.primary.withOpacity(0.85)
                : active
                    ? cs.surfaceContainerHighest
                    : cs.surfaceContainerLowest,
            border: Border.all(
              color: isCurrent
                  ? cs.primary.withOpacity(0.6)
                  : completed
                      ? cs.primary.withOpacity(0.5)
                      : cs.outlineVariant.withOpacity(0.4),
              width: 1,
            ),
          ),
          alignment: Alignment.center,
          child: completed
              ? Icon(Icons.check_rounded, size: 15, color: cs.onPrimary)
              : Text(
                  '$index',
                  style: tt.labelMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isCurrent
                        ? cs.primary
                        : cs.onSurfaceVariant.withOpacity(0.9),
                  ),
                ),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: tt.labelSmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: active
                  ? cs.onSurface.withOpacity(0.9)
                  : cs.onSurfaceVariant.withOpacity(0.75),
            ),
          ),
        ),
      ],
    );
  }
}

/* ===================== خطوة القماش ===================== */
class _FabricStep extends StatefulWidget {
  final String tailorId;
  final String? selectedType;
  final String? selectedFabricId;
  final void Function(String? type, String? imageThumb, String? fabricId)
      onTypeChanged;
  final VoidCallback? onNext;

  const _FabricStep({
    required this.tailorId,
    required this.selectedType,
    this.selectedFabricId,
    required this.onTypeChanged,
    this.onNext,
  });

  @override
  State<_FabricStep> createState() => _FabricStepState();
}

class _FabricStepState extends State<_FabricStep> {
  final ScrollController _fabricScrollController = ScrollController();
  List<String> _favoriteFabricIds = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorite_fabric_ids') ?? <String>[];
    if (mounted) {
      setState(() {
        _favoriteFabricIds = favorites;
      });
    }
  }

  Future<void> _persistFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorite_fabric_ids', _favoriteFabricIds);
  }

  void _removeFavorite(String fabricId) async {
    HapticFeedback.lightImpact();
    setState(() {
      _favoriteFabricIds.remove(fabricId);
    });
    await _persistFavorites();
  }

  void _onReorderFavorites(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex -= 1;
    setState(() {
      final id = _favoriteFabricIds.removeAt(oldIndex);
      _favoriteFabricIds.insert(newIndex, id);
    });
    await _persistFavorites();
  }

  Widget _fabricImage(String? path, ColorScheme cs) {
    if (path == null || path.isEmpty) {
      return Container(
        color: cs.surfaceContainerHighest,
        child: Icon(Icons.image_outlined,
            color: cs.onSurfaceVariant.withOpacity(0.6), size: 42),
      );
    }
    if (_isNetworkPath(path)) {
      return CachedNetworkImage(
        imageUrl: path,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: cs.surfaceContainerHighest,
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: cs.surfaceContainerHighest,
          child: Icon(Icons.image_not_supported_rounded,
              color: cs.onSurfaceVariant),
        ),
      );
    }
    return Image.asset(
      path,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: cs.surfaceContainerHighest,
        child:
            Icon(Icons.image_not_supported_rounded, color: cs.onSurfaceVariant),
      ),
    );
  }

  /// Premium fabric selection card: soft surface, subtle shadow, clear selection state.
  Widget _PremiumFabricCard({
    required Map<String, dynamic> fabric,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final imageUrl = fabric['imageUrl'] as String? ?? '';
    final name = fabric['name'] as String? ?? 'قماش';
    final type = fabric['type'] as String? ?? '—';
    const radius = 18.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        splashColor: cs.primary.withOpacity(0.08),
        highlightColor: cs.primary.withOpacity(0.04),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            color: selected
                ? cs.primaryContainer.withOpacity(0.25)
                : cs.surfaceContainerLow,
            border: Border.all(
              color:
                  selected ? cs.primary.withOpacity(0.35) : Colors.transparent,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: cs.shadow.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
              if (selected)
                BoxShadow(
                  color: cs.primary.withOpacity(0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _fabricImage(imageUrl, cs),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        name,
                        style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: cs.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        type,
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant.withOpacity(0.85),
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    // عرض بطاقة القماش المختار بالتفصيل
    Widget buildSelectedFabricDetailCard(Map<String, dynamic> fabric) {
      final availableColors =
          fabric['availableColors'] as List<dynamic>? ?? <dynamic>[];
      final heroTag = 'fabric-${fabric['id'] ?? fabric['name']}';
      final imageUrl = fabric['imageUrl'] as String? ?? '';
      final meta = <String>[
        if ((fabric['material'] as String?)?.isNotEmpty ?? false)
          'الخامة: ${fabric['material']}',
        if ((fabric['origin'] as String?)?.isNotEmpty ?? false)
          'المنشأ: ${fabric['origin']}',
        if ((fabric['pattern'] as String?)?.isNotEmpty ?? false)
          'النقشة: ${fabric['pattern']}',
      ];
      final isTablet = MediaQuery.of(context).size.width >= 600;

      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInBack,
        child: AnimatedContainer(
          key: ValueKey<String>(heroTag),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.all(isTablet ? 24 : 22),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                cs.surface,
                cs.surfaceContainerLow.withOpacity(0.5),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(isTablet ? 24 : 22),
            border: Border.all(
              color: cs.outlineVariant.withOpacity(0.25),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: cs.shadow.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Hero(
                    tag: heroTag,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(isTablet ? 20 : 18),
                      child: AspectRatio(
                        aspectRatio: isTablet ? 16 / 6 : 16 / 9,
                        child: _fabricImage(imageUrl, cs),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fabric['name'] ?? 'قماش',
                          style: tt.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                          ),
                        ),
                        if ((fabric['type'] as String?)?.isNotEmpty ??
                            false) ...[
                          const SizedBox(height: 6),
                          Text(
                            fabric['type'] as String,
                            style: tt.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                        const SizedBox(height: 6),
                        Text(
                          fabric['shortDescription'] as String? ??
                              'خيار مثالي لخياطة فاخرة',
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant.withOpacity(0.9),
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.tonal(
                    onPressed: () {
                      widget.onTypeChanged(null, null, null);
                      HapticFeedback.lightImpact();
                    },
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 18 : 14,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('تغيير'),
                  ),
                ],
              ),
              if (meta.isNotEmpty) ...[
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: meta
                      .map(
                        (item) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHighest.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            item,
                            style: tt.labelSmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
              if (availableColors.isNotEmpty) ...[
                const SizedBox(height: 22),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'اللون *',
                      style: tt.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _ColorDropdown(
                      colors: availableColors,
                      onColorSelected: (colorData) {},
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'اختر اللون المناسب لهذا القماش قبل المتابعة',
                      style: tt.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      );
    }

    Widget buildFabricList(List<Map<String, dynamic>> fabrics) {
      final tt = Theme.of(context).textTheme;
      final cs = Theme.of(context).colorScheme;
      if (fabrics.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(48),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutBack,
              builder: (context, value, child) => Transform.scale(
                scale: value,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            cs.primary.withOpacity(0.1),
                            cs.secondary.withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: cs.primary.withOpacity(0.08),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(Icons.checkroom_rounded,
                          size: 96, color: cs.primary.withOpacity(0.7)),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'لا توجد أقمشة متاحة حالياً',
                      textAlign: TextAlign.center,
                      style: tt.headlineSmall?.copyWith(
                        color: cs.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'سيتم إضافة أقمشة جديدة قريباً',
                      textAlign: TextAlign.center,
                      style: tt.bodyLarge?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 32),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('تحديث'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }

      return GridView.builder(
        controller: _fabricScrollController,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.78,
        ),
        itemCount: fabrics.length,
        itemBuilder: (_, i) {
          final fabric = fabrics[i];
          final sel = widget.selectedFabricId != null &&
              widget.selectedFabricId == fabric['id'];

          return _PremiumFabricCard(
            fabric: fabric,
            selected: sel,
            onTap: () => widget.onTypeChanged(
              fabric['name'],
              fabric['imageUrl'],
              fabric['id'],
            ),
          );
        },
      );
    }

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 840),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Section title: clean, medium-bold, RTL-aligned
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 20),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'اختر نوع القماش من المتجر',
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
                // عرض القماش
                StreamBuilder<List<Map<String, dynamic>>>(
                  stream: FabricService.getTailorFabrics(widget.tailorId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      return _ElegantFrame(
                        padding: const EdgeInsets.all(16),
                        useBlur: false,
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline_rounded, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'حدث خطأ في تحميل الأقمشة',
                                style: tt.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    final fabrics = snapshot.data ?? [];

                    final selectedFabric = fabrics.firstWhere(
                      (fabric) => fabric['id'] == widget.selectedFabricId,
                      orElse: () => <String, dynamic>{},
                    );

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 4),
                        if (_favoriteFabricIds.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildFavoritesRow(fabrics, tt, cs),
                              const SizedBox(height: 16),
                            ],
                          ),
                        if (widget.selectedFabricId != null &&
                            selectedFabric.isNotEmpty)
                          buildSelectedFabricDetailCard(selectedFabric)
                        else
                          buildFabricList(fabrics),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),
                // عرض القماش المختار
                if (widget.selectedType != null && widget.onNext != null) ...[
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: widget.onNext,
                      icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                      label: const Text('المتابعة إلى المقاسات'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
  }

  bool _isNetworkPath(String path) {
    return path.startsWith('http://') || path.startsWith('https://');
  }

  Widget _buildFavoritesRow(
      List<Map<String, dynamic>> fabrics, TextTheme tt, ColorScheme cs) {
    final favorites = _favoriteFabricIds
        .map((id) => fabrics.firstWhere(
              (fabric) => fabric['id'] == id,
              orElse: () => <String, dynamic>{},
            ))
        .where((fabric) => fabric.isNotEmpty)
        .toList();

    if (favorites.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.favorite_rounded,
                color: Theme.of(context).colorScheme.onPrimary),
            const SizedBox(width: 8),
            Text(
              'مفضلاتي',
              style: tt.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: cs.primary,
              ),
            ),
            const Spacer(),
            if (_favoriteFabricIds.length > 1)
              Text(
                'اسحب لإعادة الترتيب',
                style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
              ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 150,
          child: ReorderableListView.builder(
            key: ValueKey(_favoriteFabricIds.length),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            onReorder: _onReorderFavorites,
            itemCount: favorites.length,
            buildDefaultDragHandles: false,
            itemBuilder: (context, index) {
              final fabric = favorites[index];
              final fabricId = fabric['id'] as String? ?? 'fav_$index';
              final selected = widget.selectedFabricId == fabricId;
              final imageUrl = fabric['imageUrl'] as String? ?? '';

              return Padding(
                key: ValueKey(fabricId),
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      widget.onTypeChanged(
                        fabric['name'],
                        fabric['imageUrl'],
                        fabric['id'],
                      );
                    },
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: 130,
                          decoration: BoxDecoration(
                            color: selected
                                ? cs.primaryContainer.withOpacity(0.4)
                                : cs.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: selected ? cs.primary : cs.outlineVariant,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: SizedBox(
                                  height: 80,
                                  width: double.infinity,
                                  child: _fabricImage(imageUrl, cs),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                fabric['name'] ?? 'قماش',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: tt.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: selected ? cs.primary : cs.onSurface,
                                ),
                              ),
                              Text(
                                'ر.ع ${(fabric['pricePerMeter'] as num?)?.toStringAsFixed(3) ?? '0.000'}',
                                style: tt.labelSmall?.copyWith(
                                  color: cs.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          right: -6,
                          top: -6,
                          child: IconButton(
                            tooltip: 'إزالة من المفضلات',
                            onPressed: () => _removeFavorite(fabricId),
                            icon: const Icon(Icons.close_rounded, size: 18),
                            style: IconButton.styleFrom(
                              backgroundColor: cs.surface,
                              foregroundColor: cs.onSurfaceVariant,
                              minimumSize: const Size(28, 28),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          bottom: -12,
                          child: ReorderableDragStartListener(
                            index: index,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: cs.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.drag_indicator,
                                      size: 16, color: cs.onSurfaceVariant),
                                  const SizedBox(width: 4),
                                  Text(
                                    'اسحب',
                                    style: tt.labelSmall?.copyWith(
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
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
      ],
    );
  }
}

/* ===================== صورة توضيحية متحركة للمقاس ===================== */
class _AnimatedMeasurementGuide extends StatefulWidget {
  final String measurementName;
  final String imagePath;
  final String description;

  const _AnimatedMeasurementGuide({
    required this.measurementName,
    required this.imagePath,
    required this.description,
  });

  @override
  State<_AnimatedMeasurementGuide> createState() =>
      _AnimatedMeasurementGuideState();
}

class _AnimatedMeasurementGuideState extends State<_AnimatedMeasurementGuide>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // العنوان
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.straighten_rounded, color: cs.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.measurementName,
                    style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // الصورة المتحركة
            Expanded(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Opacity(
                      opacity: _opacityAnimation.value,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: cs.primary, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: cs.primary.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.asset(
                            widget.imagePath,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Container(
                              color: cs.surfaceContainerHighest,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_not_supported_rounded,
                                    size: 80,
                                    color: cs.onSurfaceVariant,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'صورة توضيحية',
                                    style: tt.titleMedium?.copyWith(
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // الوصف
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: cs.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.description,
                      style: tt.bodyMedium,
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

/* ===================== قائمة منسدلة للألوان ===================== */
class _ColorDropdown extends StatefulWidget {
  final List<dynamic> colors;
  final Function(Map<String, dynamic>) onColorSelected;

  const _ColorDropdown({
    required this.colors,
    required this.onColorSelected,
  });

  @override
  State<_ColorDropdown> createState() => _ColorDropdownState();
}

class _ColorDropdownState extends State<_ColorDropdown> {
  Map<String, dynamic>? _selectedColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: cs.surfaceContainerHighest.withOpacity(0.6),
            border: Border.all(
              color: cs.outlineVariant.withOpacity(0.4),
              width: 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Map<String, dynamic>>(
              isExpanded: true,
              value: _selectedColor,
              hint: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Text(
                  'اختر اللون',
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
              ),
              icon: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Icon(Icons.arrow_drop_down, color: cs.onSurfaceVariant),
              ),
              items: widget.colors.map((colorData) {
                final colorName =
                    colorData['colorName'] as String? ?? 'غير محدد';
                final colorHex = colorData['colorHex'] as String? ?? '#CCCCCC';

                Color color;
                try {
                  color = Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
                } catch (e) {
                  color = Colors.grey;
                }
                final isSelected = colorData == _selectedColor;

                return DropdownMenuItem<Map<String, dynamic>>(
                  value: colorData,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? cs.primary.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color,
                            border: Border.all(
                              color:
                                  isSelected ? cs.primary : cs.outlineVariant,
                              width: 1.5,
                            ),
                          ),
                          child: color.computeLuminance() > 0.9
                              ? Icon(
                                  Icons.circle_outlined,
                                  color: cs.onSurfaceVariant,
                                  size: 18,
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            colorName,
                            style: tt.bodyMedium?.copyWith(
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              onChanged: (colorData) {
                setState(() {
                  _selectedColor = colorData;
                });
                if (colorData != null) {
                  widget.onColorSelected(colorData);
                }
              },
              borderRadius: BorderRadius.circular(12),
              dropdownColor: cs.surface,
            ),
          ),
        ),
      ],
    );
  }
}

/* ===================== خطوة المقاسات + اللون (مدمجة) ===================== */
class _MeasurementsAndColorStep extends StatefulWidget {
  final String fabricId;
  final GlobalKey<FormState> formKey;
  final MeasurementUnit unit;
  final ValueChanged<MeasurementUnit> onUnitChanged;

  // المقاسات الثمانية فقط
  final TextEditingController lengthCtrl,
      shoulderCtrl,
      neckCtrl,
      armLengthCtrl,
      wristWidthCtrl,
      chestWidthCtrl,
      bottomWidthCtrl,
      patternLengthCtrl;

  const _MeasurementsAndColorStep({
    required this.fabricId,
    required this.formKey,
    required this.unit,
    required this.onUnitChanged,
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
  State<_MeasurementsAndColorStep> createState() =>
      _MeasurementsAndColorStepState();
}

class _MeasurementsAndColorStepState extends State<_MeasurementsAndColorStep>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  double toUnit(double cm) =>
      widget.unit == MeasurementUnit.inch ? cm / _cmPerInch : cm;
  double step() => widget.unit == MeasurementUnit.inch ? 0.50 : 0.5;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final decimals = widget.unit == MeasurementUnit.inch ? 2 : 1;

    final rows = <_RowSpec>[
      _RowSpec('الطول', widget.lengthCtrl, toUnit(100), toUnit(200)),
      _RowSpec('الكتف', widget.shoulderCtrl, toUnit(30), toUnit(60)),
      _RowSpec('الرقبة', widget.neckCtrl, toUnit(28), toUnit(52)),
      _RowSpec('طول الذراع', widget.armLengthCtrl, toUnit(40), toUnit(90)),
      _RowSpec('عرض المعصم', widget.wristWidthCtrl, toUnit(12), toUnit(28)),
      _RowSpec('عرض الصدر مع الجانبيين', widget.chestWidthCtrl, toUnit(70),
          toUnit(150)),
      _RowSpec('الوسع السفلي', widget.bottomWidthCtrl, toUnit(50), toUnit(120)),
      _RowSpec('طول النقشة', widget.patternLengthCtrl, toUnit(5), toUnit(50)),
    ];

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 840),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
            child: Form(
              key: widget.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ========== قسم المقاسات ==========
                  // زر حفظ/استعادة المقاسات
                  _SavedMeasurementsSection(
                    onLoadProfile: (profile) {
                      widget.lengthCtrl.text =
                          profile.measurements['الطول']?.toString() ?? '';
                      widget.shoulderCtrl.text =
                          profile.measurements['الكتف']?.toString() ?? '';
                      widget.neckCtrl.text =
                          profile.measurements['الرقبة']?.toString() ?? '';
                      widget.armLengthCtrl.text =
                          profile.measurements['طول الذراع']?.toString() ?? '';
                      widget.wristWidthCtrl.text =
                          profile.measurements['عرض المعصم']?.toString() ?? '';
                      widget.chestWidthCtrl.text = profile
                              .measurements['عرض الصدر مع الجانبيين']
                              ?.toString() ??
                          '';
                      widget.bottomWidthCtrl.text =
                          profile.measurements['الوسع السفلي']?.toString() ??
                              '';
                      widget.patternLengthCtrl.text =
                          profile.measurements['طول النقشة']?.toString() ?? '';
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text('✅ تم تحميل مقاسات "${profile.name}" بنجاح'),
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // التبديل بين الوحدات
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SegmentedButton<MeasurementUnit>(
                        segments: const [
                          ButtonSegment(
                            value: MeasurementUnit.cm,
                            label: Text('سنتيمتر (cm)'),
                            icon: Icon(Icons.straighten_rounded, size: 18),
                          ),
                          ButtonSegment(
                            value: MeasurementUnit.inch,
                            label: Text('إنش (in)'),
                            icon: Icon(Icons.straighten_rounded, size: 18),
                          ),
                        ],
                        selected: {widget.unit},
                        onSelectionChanged:
                            (Set<MeasurementUnit> newSelection) {
                          widget.onUnitChanged(newSelection.first);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // الحقول
                  ...rows.map((r) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _PrettyLineField(
                        label: r.label,
                        controller: r.ctrl,
                        min: r.min,
                        max: r.max,
                        step: step(),
                        unitLabel:
                            widget.unit == MeasurementUnit.cm ? 'سم' : 'إنش',
                        decimals: decimals,
                      ),
                    );
                  }),

                  const SizedBox(height: 20),

                  // زر حفظ المقاسات الحالية
                  _SaveMeasurementsButton(
                    measurements: {
                      'الطول': double.tryParse(widget.lengthCtrl.text) ?? 0,
                      'الكتف': double.tryParse(widget.shoulderCtrl.text) ?? 0,
                      'الرقبة': double.tryParse(widget.neckCtrl.text) ?? 0,
                      'طول الذراع':
                          double.tryParse(widget.armLengthCtrl.text) ?? 0,
                      'عرض المعصم':
                          double.tryParse(widget.wristWidthCtrl.text) ?? 0,
                      'عرض الصدر مع الجانبيين':
                          double.tryParse(widget.chestWidthCtrl.text) ?? 0,
                      'الوسع السفلي':
                          double.tryParse(widget.bottomWidthCtrl.text) ?? 0,
                      'طول النقشة':
                          double.tryParse(widget.patternLengthCtrl.text) ?? 0,
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/* ===================== خطوة المقاسات (رجالي) ===================== */
class _MenMeasurementsStep extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final MeasurementUnit unit;
  final ValueChanged<MeasurementUnit> onUnitChanged;

  // controllers
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

  const _MenMeasurementsStep({
    required this.formKey,
    required this.unit,
    required this.onUnitChanged,
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
  });

  @override
  State<_MenMeasurementsStep> createState() => _MenMeasurementsStepState();
}

class _MenMeasurementsStepState extends State<_MenMeasurementsStep>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  double toUnit(double cm) =>
      widget.unit == MeasurementUnit.inch ? cm / _cmPerInch : cm;
  double step() => widget.unit == MeasurementUnit.inch ? 0.50 : 0.5;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final decimals = widget.unit == MeasurementUnit.inch ? 2 : 1;

    final rows = <_RowSpec>[
      _RowSpec('الطول الكلي', widget.lengthCtrl, toUnit(110), toUnit(170)),
      _RowSpec('الكتف', widget.shoulderCtrl, toUnit(38), toUnit(56)),
      _RowSpec('طول الكم', widget.sleeveCtrl, toUnit(45), toUnit(75)),
      _RowSpec(
          'محيط الكم العلوي', widget.upperSleeveCtrl, toUnit(24), toUnit(48)),
      _RowSpec(
          'محيط الكم السفلي', widget.lowerSleeveCtrl, toUnit(14), toUnit(24)),
      _RowSpec('الصدر', widget.chestCtrl, toUnit(80), toUnit(140)),
      _RowSpec('الخصر', widget.waistCtrl, toUnit(70), toUnit(130)),
      _RowSpec('محيط الرقبة', widget.neckCtrl, toUnit(34), toUnit(48)),
      _RowSpec(
          'التطريز الامامي', widget.embroideryCtrl, toUnit(10), toUnit(30)),
    ];

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 840),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
            child: Form(
              key: widget.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // زر حفظ/استعادة المقاسات
                  _SavedMeasurementsSection(
                    onLoadProfile: (profile) {
                      final m = profile.measurements;
                      widget.lengthCtrl.text =
                          (m['الطول الكلي'] ?? 0).toStringAsFixed(1);
                      widget.shoulderCtrl.text =
                          (m['الكتف'] ?? 0).toStringAsFixed(1);
                      widget.sleeveCtrl.text =
                          (m['طول الكم'] ?? 0).toStringAsFixed(1);
                      widget.upperSleeveCtrl.text =
                          (m['محيط الكم العلوي'] ?? 0).toStringAsFixed(1);
                      widget.lowerSleeveCtrl.text =
                          (m['محيط الكم السفلي'] ?? 0).toStringAsFixed(1);
                      widget.chestCtrl.text =
                          (m['الصدر'] ?? 0).toStringAsFixed(1);
                      widget.waistCtrl.text =
                          (m['الخصر'] ?? 0).toStringAsFixed(1);
                      widget.neckCtrl.text =
                          (m['محيط الرقبة'] ?? 0).toStringAsFixed(1);
                      widget.embroideryCtrl.text =
                          (m['التطريز الامامي'] ?? 0).toStringAsFixed(1);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('✅ تم تحميل مقاسات "${profile.name}"'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // شريط تبديل الوحدة
                  _ElegantFrame(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    useBlur: false,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'الوحدة: ${widget.unit.labelAr}',
                            style: tt.bodyMedium?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ToggleButtons(
                          isSelected: [
                            widget.unit == MeasurementUnit.cm,
                            widget.unit == MeasurementUnit.inch,
                          ],
                          onPressed: (i) => widget.onUnitChanged(i == 0
                              ? MeasurementUnit.cm
                              : MeasurementUnit.inch),
                          borderRadius: BorderRadius.circular(10),
                          selectedBorderColor: cs.primary,
                          selectedColor: cs.onPrimary,
                          fillColor: cs.primary,
                          children: const [
                            Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Text('سم')),
                            Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Text('إنش')),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // كروت جميلة لكل قياس
                  ...rows.map(
                    (r) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _PrettyLineField(
                        label: r.label,
                        controller: r.ctrl,
                        min: r.min,
                        max: r.max,
                        step: step(),
                        unitLabel: widget.unit.labelAr,
                        decimals: decimals,
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),
                  _ElegantFrame(
                    useBlur: false,
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ملاحظات إضافية',
                            style: tt.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: widget.notesCtrl,
                          minLines: 3,
                          maxLines: 6,
                          decoration: const InputDecoration(
                            hintText: 'أدخل أي تفاصيل يريدها الخياط…',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // زر حفظ المقاسات
                  _SaveMeasurementsButton(
                    measurements: {
                      'الطول الكلي': _parseDouble(widget.lengthCtrl.text),
                      'الكتف': _parseDouble(widget.shoulderCtrl.text),
                      'طول الكم': _parseDouble(widget.sleeveCtrl.text),
                      'محيط الكم العلوي':
                          _parseDouble(widget.upperSleeveCtrl.text),
                      'محيط الكم السفلي':
                          _parseDouble(widget.lowerSleeveCtrl.text),
                      'الصدر': _parseDouble(widget.chestCtrl.text),
                      'الخصر': _parseDouble(widget.waistCtrl.text),
                      'محيط الرقبة': _parseDouble(widget.neckCtrl.text),
                      'التطريز الامامي':
                          _parseDouble(widget.embroideryCtrl.text),
                    },
                    notes: widget.notesCtrl.text.trim(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _parseDouble(String value) {
    return double.tryParse(value.trim()) ?? 0.0;
  }
}

class _RowSpec {
  final String label;
  final TextEditingController ctrl;
  final double min, max;
  _RowSpec(this.label, this.ctrl, this.min, this.max);
}

/// صف قياس بكارت أنيق: عنوان يمين + مجموعة تحكم يسار
// معلومات الصور التوضيحية للمقاسات (صورة الدشداشة)
const String _measurementGuideImage = 'assets/thobe/simple.jfif';
const Map<String, Map<String, String>> _measurementGuides = {
  'الطول': {
    'image': _measurementGuideImage,
    'description': 'قس من أعلى الكتف إلى الأسفل حتى الطول المطلوب',
  },
  'الكتف': {
    'image': _measurementGuideImage,
    'description': 'قس عرض الكتفين من نهاية كتف إلى الآخر',
  },
  'الرقبة': {
    'image': _measurementGuideImage,
    'description': 'قس محيط الرقبة عند قاعدتها',
  },
  'طول الذراع': {
    'image': _measurementGuideImage,
    'description': 'قس من الكتف إلى المعصم',
  },
  'عرض المعصم': {
    'image': _measurementGuideImage,
    'description': 'قس عرض المعصم',
  },
  'عرض الصدر مع الجانبيين': {
    'image': _measurementGuideImage,
    'description': 'قس عرض الصدر مع الجانبيين',
  },
  'الوسع السفلي': {
    'image': _measurementGuideImage,
    'description': 'قس الوسع السفلي',
  },
  'طول النقشة': {
    'image': _measurementGuideImage,
    'description': 'طول النقشة أو التطريز',
  },
};

class _PrettyLineField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final double min, max, step;
  final String unitLabel;
  final int decimals;
  const _PrettyLineField({
    required this.label,
    required this.controller,
    required this.min,
    required this.max,
    required this.step,
    required this.unitLabel,
    required this.decimals,
  });

  @override
  State<_PrettyLineField> createState() => _PrettyLineFieldState();
}

class _PrettyLineFieldState extends State<_PrettyLineField> {
  double _parse(String v) {
    if (v.trim().isEmpty) return widget.min;
    final t = v.replaceAll(',', '.');
    final d = double.tryParse(t);
    return (d ?? widget.min).clamp(widget.min, widget.max);
  }

  // تحديث آمن للـ controller لتفادي أخطاء "deactivated ancestor"
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

    if (mounted) setState(() {});
  }

  void _inc() {
    if (!mounted) return;
    HapticFeedback.selectionClick();
    _set((_parse(widget.controller.text) + widget.step)
        .clamp(widget.min, widget.max));
  }

  void _dec() {
    if (!mounted) return;
    HapticFeedback.selectionClick();
    _set((_parse(widget.controller.text) - widget.step)
        .clamp(widget.min, widget.max));
  }

  // Measurement row layout: breathable, premium, uniform height
  static const double _rowPaddingVPhone = 16;
  static const double _rowPaddingVTablet = 18;
  static const double _rowPaddingHPhone = 16;
  static const double _rowPaddingHTablet = 20;
  static const double _controlGapPhone = 12;
  static const double _controlGapTablet = 16;
  static const double _btnSize = 48;
  static const double _btnIconSize = 22;
  static const double _controlMinWidth = 0;
  static const double _controlMaxWidth = 320;
  static const double _tightLayoutThreshold = 200;
  static const double _btnSizeTight = 40;
  static const double _gapTight = 8;
  static const double _rowRadius = 18;
  static const double _controlRadius = 18;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    final padH = isTablet ? _rowPaddingHTablet : _rowPaddingHPhone;
    final padV = isTablet ? _rowPaddingVTablet : _rowPaddingVPhone;
    final gap = isTablet ? _controlGapTablet : _controlGapPhone;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      constraints: BoxConstraints(minHeight: isTablet ? 76 : 72),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(isTablet ? 20 : _rowRadius),
        border: Border.all(
          color: cs.outlineVariant.withOpacity(0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
      alignment: Alignment.center,
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.label,
                    style: tt.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant.withOpacity(0.95),
                      fontWeight: FontWeight.w500,
                      fontSize: isTablet ? 15 : 14,
                    ),
                  ),
                ),
                if (_measurementGuides.containsKey(widget.label))
                  IconButton(
                    onPressed: () {
                      final guide = _measurementGuides[widget.label]!;
                      showDialog(
                        context: context,
                        builder: (context) => _AnimatedMeasurementGuide(
                          measurementName: widget.label,
                          imagePath: guide['image']!,
                          description: guide['description']!,
                        ),
                      );
                    },
                    icon: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        _measurementGuideImage,
                        width: 28,
                        height: 28,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.help_outline_rounded,
                          size: 20,
                          color: cs.primary,
                        ),
                      ),
                    ),
                    tooltip: 'عرض الصورة التوضيحية',
                  ),
              ],
            ),
          ),
          SizedBox(width: gap),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Flexible(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                    minWidth: _controlMinWidth, maxWidth: _controlMaxWidth),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final w = constraints.maxWidth;
                    final tight = w < _tightLayoutThreshold;
                    final btnSize = tight ? _btnSizeTight : _btnSize;
                    final innerGap = tight ? _gapTight : gap;
                    final innerPadH = tight ? _gapTight : gap * 0.75;
                    return Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: innerPadH, vertical: 12),
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(_controlRadius),
                        border: Border.all(
                            color: cs.outlineVariant.withOpacity(0.5),
                            width: 1),
                      ),
                      child: Row(
                        children: [
                          _pillBtn(context, Icons.remove_rounded, _dec,
                              size: btnSize),
                          SizedBox(width: innerGap),
                          Expanded(
                            child: TextFormField(
                              controller: widget.controller,
                              textAlign: TextAlign.center,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              style: tt.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                height: 1.25,
                                letterSpacing: 0.15,
                                fontSize: isTablet ? 17 : 16,
                              ),
                              decoration: InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                                hintText: '—',
                                hintStyle: tt.titleMedium?.copyWith(
                                  color: cs.onSurface.withOpacity(0.3),
                                  fontWeight: FontWeight.w500,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 10),
                              ),
                              onEditingComplete: () =>
                                  _set(_parse(widget.controller.text)),
                              validator: (v) {
                                final val = _parse(v ?? '');
                                if ((v ?? '').trim().isEmpty) return 'مطلوب';
                                if (val < widget.min || val > widget.max) {
                                  fmt(x) => x.toStringAsFixed(widget.decimals);
                                  return 'القيمة بين ${fmt(widget.min)} و ${fmt(widget.max)}';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: innerGap),
                          _pillBtn(context, Icons.add_rounded, _inc,
                              size: btnSize),
                          SizedBox(width: innerGap),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: tight ? 6 : 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              widget.unitLabel,
                              style: tt.labelMedium?.copyWith(
                                color: cs.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pillBtn(BuildContext context, IconData icon, VoidCallback onTap,
      {double size = _btnSize}) {
    final cs = Theme.of(context).colorScheme;
    final iconSize = size * (_btnIconSize / _btnSize);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        splashColor: cs.primary.withOpacity(0.08),
        highlightColor: cs.primary.withOpacity(0.05),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withOpacity(0.7),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Icon(icon, size: iconSize, color: cs.onSurfaceVariant),
          ),
        ),
      ),
    );
  }
}

/* ===================== خطوة التطريز ===================== */
class _EmbroideryStep extends StatelessWidget {
  final Color color;
  final int lines;
  final void Function(Color color, int lines) onChanged;
  final String tailorId;
  final EmbroideryDesign? selectedEmbroidery;
  final ValueChanged<EmbroideryDesign?> onEmbroideryChanged;

  const _EmbroideryStep({
    required this.color,
    required this.lines,
    required this.onChanged,
    required this.tailorId,
    required this.selectedEmbroidery,
    required this.onEmbroideryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final options = [
      const Color(0xFF3F51B5),
      const Color(0xFF009688),
      const Color(0xFFFF5722),
      const Color(0xFF795548),
      const Color(0xFF607D8B),
      const Color(0xFF9C27B0),
      const Color(0xFF1B5E20),
      const Color(0xFFB71C1C),
    ];

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 840),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ========== قسم تصاميم التطريز المتاحة ==========
                _EmbroideryDesignsSection(
                  tailorId: tailorId,
                  selectedEmbroidery: selectedEmbroidery,
                  onEmbroiderySelected: onEmbroideryChanged,
                ),
                const SizedBox(height: 16),

                // حاوية بسيطة بدون حواف رمادية لقائمة ألوان التطريز
                Container(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text('لون خيط التطريز',
                                style: tt.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w800)),
                          ),
                          if (options.length > 12)
                            TextButton.icon(
                              onPressed: () {
                                _showAllColors(context, options, color,
                                    (c) => onChanged(c, lines));
                              },
                              icon: const Icon(Icons.palette_rounded, size: 16),
                              label: Text('${options.length} لون'),
                              style: TextButton.styleFrom(
                                foregroundColor: cs.primary,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: options.length > 12 ? 110 : null,
                        child: options.length > 12
                            ? ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: (options.length / 6).ceil(),
                                itemBuilder: (context, pageIndex) {
                                  final startIndex = pageIndex * 6;
                                  final endIndex =
                                      (startIndex + 6).clamp(0, options.length);
                                  final pageColors =
                                      options.sublist(startIndex, endIndex);

                                  return Padding(
                                    padding: const EdgeInsets.only(right: 16),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Wrap(
                                          spacing: 12,
                                          runSpacing: 12,
                                          direction: Axis.vertical,
                                          children: pageColors.map((c) {
                                            final sel = c.value == color.value;
                                            return GestureDetector(
                                              onTap: () => onChanged(c, lines),
                                              child: Container(
                                                width: 44,
                                                height: 44,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: c,
                                                  border: Border.all(
                                                      color: sel
                                                          ? cs.primary
                                                          : Colors.white,
                                                      width: sel ? 3 : 2),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(.08),
                                                      blurRadius: 10,
                                                      offset:
                                                          const Offset(0, 4),
                                                    )
                                                  ],
                                                ),
                                                child: sel
                                                    ? const Icon(Icons.check,
                                                        color: Colors.white,
                                                        size: 20)
                                                    : null,
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              )
                            : Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: options.map((c) {
                                  final sel = c.value == color.value;
                                  return GestureDetector(
                                    onTap: () => onChanged(c, lines),
                                    child: Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: c,
                                        border: Border.all(
                                            color:
                                                sel ? cs.primary : Colors.white,
                                            width: sel ? 3 : 2),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(.08),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          )
                                        ],
                                      ),
                                      child: sel
                                          ? const Icon(Icons.check,
                                              color: Colors.white)
                                          : null,
                                    ),
                                  );
                                }).toList(),
                              ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _ElegantFrame(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                  useBlur: false,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('عدد الخطوط الزخرفية (+0.250 ر.ع لكل خط)',
                                style: tt.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w800)),
                            const SizedBox(height: 8),
                            Text('(حد أقصى 3)', style: tt.bodySmall),
                          ],
                        ),
                      ),
                      _circleBtn(context, icon: Icons.remove_rounded,
                          onTap: () {
                        final v = (lines - 1).clamp(0, 3);
                        onChanged(color, v);
                        HapticFeedback.selectionClick();
                      }),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('$lines',
                            style: tt.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w900)),
                      ),
                      _circleBtn(context, icon: Icons.add_rounded, onTap: () {
                        final v = (lines + 1).clamp(0, 3);
                        onChanged(color, v);
                        HapticFeedback.selectionClick();
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _circleBtn(BuildContext context,
      {required IconData icon, required VoidCallback onTap}) {
    final cs = Theme.of(context).colorScheme;
    return InkResponse(
      onTap: onTap,
      radius: 24,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: cs.primaryContainer,
          shape: BoxShape.circle,
          border: Border.all(color: cs.primaryContainer),
        ),
        child: Icon(icon, color: cs.onPrimaryContainer),
      ),
    );
  }

  // عرض جميع الألوان في Bottom Sheet
  static void _showAllColors(
    BuildContext context,
    List<Color> colors,
    Color selectedColor,
    ValueChanged<Color> onColorSelected,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final cs = Theme.of(context).colorScheme;
        final tt = Theme.of(context).textTheme;

        return Container(
          padding: const EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.onSurfaceVariant.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              // العنوان
              Row(
                children: [
                  Icon(Icons.palette_rounded, color: cs.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'جميع ألوان خيط التطريز (${colors.length})',
                      style: tt.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.primary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Grid الألوان
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1,
                  ),
                  itemCount: colors.length,
                  itemBuilder: (context, index) {
                    final c = colors[index];
                    final sel = c.value == selectedColor.value;

                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        onColorSelected(c);
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: c,
                          border: Border.all(
                            color: sel ? cs.primary : Colors.white,
                            width: sel ? 4 : 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                            if (sel)
                              BoxShadow(
                                color: cs.primary.withOpacity(0.4),
                                blurRadius: 16,
                                spreadRadius: 2,
                              ),
                          ],
                        ),
                        child: sel
                            ? const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 24,
                              )
                            : null,
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

/* ===================== قسم تصاميم التطريز المتاحة ===================== */
class _EmbroideryDesignsSection extends StatelessWidget {
  final String tailorId;
  final EmbroideryDesign? selectedEmbroidery;
  final ValueChanged<EmbroideryDesign?> onEmbroiderySelected;

  const _EmbroideryDesignsSection({
    required this.tailorId,
    required this.selectedEmbroidery,
    required this.onEmbroiderySelected,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final embroideryService = EmbroideryService();

    return FutureBuilder<List<EmbroideryDesign>>(
      future: embroideryService.getEmbroideryDesigns(tailorId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.errorContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline_rounded, color: cs.error),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'حدث خطأ في تحميل تصاميم التطريز',
                    style: TextStyle(color: cs.onErrorContainer),
                  ),
                ),
              ],
            ),
          );
        }

        final designs = snapshot.data ?? [];

        if (designs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, color: cs.onSurfaceVariant),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'لا توجد تصاميم تطريز متاحة حالياً',
                    style: TextStyle(color: cs.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                cs.primaryContainer.withOpacity(0.15),
                cs.secondaryContainer.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.primary.withOpacity(0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [cs.primary, cs.secondary],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: cs.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تصاميم التطريز المتاحة',
                          style: tt.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: cs.primary,
                          ),
                        ),
                        Text(
                          'اختر تصميم التطريز المفضل لديك',
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // عرض التصاميم - PageView مع مؤشرات
              SizedBox(
                height: 280,
                child: Column(
                  children: [
                    Expanded(
                      child: PageView.builder(
                        itemCount: (designs.length / 6).ceil(),
                        onPageChanged: (page) {
                          // يمكن إضافة state management هنا
                        },
                        itemBuilder: (context, pageIndex) {
                          final startIndex = pageIndex * 6;
                          final endIndex =
                              (startIndex + 6).clamp(0, designs.length);
                          final pageDesigns =
                              designs.sublist(startIndex, endIndex);

                          return GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.85,
                            ),
                            itemCount: pageDesigns.length,
                            itemBuilder: (context, indexInPage) {
                              final index = startIndex + indexInPage;
                              final design = designs[index];
                              final isSelected =
                                  selectedEmbroidery?.id == design.id;

                              return GestureDetector(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  onEmbroiderySelected(
                                      isSelected ? null : design);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: cs.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? cs.primary
                                          : cs.outlineVariant,
                                      width: isSelected ? 3 : 1,
                                    ),
                                    boxShadow: [
                                      if (isSelected)
                                        BoxShadow(
                                          color: cs.primary.withOpacity(0.3),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      // الصورة
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius:
                                              const BorderRadius.vertical(
                                            top: Radius.circular(10),
                                          ),
                                          child: Stack(
                                            fit: StackFit.expand,
                                            children: [
                                              CachedNetworkImage(
                                                imageUrl: design.imageUrl,
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) =>
                                                    Container(
                                                  color: cs
                                                      .surfaceContainerHighest,
                                                  child: const Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                            strokeWidth: 2),
                                                  ),
                                                ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Container(
                                                  color: cs
                                                      .surfaceContainerHighest,
                                                  child: Icon(
                                                    Icons
                                                        .image_not_supported_rounded,
                                                    color: cs.onSurfaceVariant,
                                                  ),
                                                ),
                                              ),
                                              if (isSelected)
                                                Positioned(
                                                  top: 6,
                                                  right: 6,
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(4),
                                                    decoration: BoxDecoration(
                                                      color: cs.primary,
                                                      shape: BoxShape.circle,
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withOpacity(0.3),
                                                          blurRadius: 8,
                                                        ),
                                                      ],
                                                    ),
                                                    child: const Icon(
                                                      Icons.check_rounded,
                                                      color: Colors.white,
                                                      size: 16,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),

                                      // المعلومات
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              design.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: tt.bodySmall?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: isSelected
                                                    ? cs.primary
                                                    : cs.onSurface,
                                              ),
                                            ),
                                            if (design.price > 0) ...[
                                              const SizedBox(height: 2),
                                              Text(
                                                '+${design.price.toStringAsFixed(3)} ر.ع',
                                                style: tt.bodySmall?.copyWith(
                                                  color: cs.primary,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),

                    // مؤشرات الصفحات
                    if (designs.length > 6) ...[
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          (designs.length / 6).ceil(),
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: cs.primary.withOpacity(0.3),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // زر "عرض الكل" للتصاميم الكثيرة
              if (designs.length > 12) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    _showAllEmbroideryDesigns(context, designs,
                        selectedEmbroidery, onEmbroiderySelected);
                  },
                  icon: const Icon(Icons.grid_view_rounded, size: 18),
                  label: Text('عرض جميع التصاميم (${designs.length})'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: cs.primary,
                    side: BorderSide(color: cs.primary),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  // عرض جميع التصاميم في Bottom Sheet
  static void _showAllEmbroideryDesigns(
    BuildContext context,
    List<EmbroideryDesign> designs,
    EmbroideryDesign? selectedEmbroidery,
    ValueChanged<EmbroideryDesign?> onSelected,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          final cs = Theme.of(context).colorScheme;
          final tt = Theme.of(context).textTheme;

          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.onSurfaceVariant.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),

                // العنوان
                Row(
                  children: [
                    Icon(Icons.auto_awesome_rounded, color: cs.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'جميع تصاميم التطريز (${designs.length})',
                        style: tt.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: cs.primary,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Grid التصاميم
                Expanded(
                  child: GridView.builder(
                    controller: scrollController,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: designs.length,
                    itemBuilder: (context, index) {
                      final design = designs[index];
                      final isSelected = selectedEmbroidery?.id == design.id;

                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          onSelected(isSelected ? null : design);
                          Navigator.pop(context);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: cs.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  isSelected ? cs.primary : cs.outlineVariant,
                              width: isSelected ? 3 : 1,
                            ),
                            boxShadow: [
                              if (isSelected)
                                BoxShadow(
                                  color: cs.primary.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(10),
                                  ),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      CachedNetworkImage(
                                        imageUrl: design.imageUrl,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            Container(
                                          color: cs.surfaceContainerHighest,
                                          child: const Center(
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Container(
                                          color: cs.surfaceContainerHighest,
                                          child: Icon(
                                            Icons.image_not_supported_rounded,
                                            color: cs.onSurfaceVariant,
                                          ),
                                        ),
                                      ),
                                      if (isSelected)
                                        Positioned(
                                          top: 6,
                                          right: 6,
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: cs.primary,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.3),
                                                  blurRadius: 8,
                                                ),
                                              ],
                                            ),
                                            child: const Icon(
                                              Icons.check_rounded,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      design.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: tt.bodySmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? cs.primary
                                            : cs.onSurface,
                                      ),
                                    ),
                                    if (design.price > 0) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        '+${design.price.toStringAsFixed(3)} ر.ع',
                                        style: tt.bodySmall?.copyWith(
                                          color: cs.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
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
      ),
    );
  }
}

/* ===================== عناصر مساعدة ===================== */

class _KV extends StatelessWidget {
  final String k, v;
  const _KV(this.k, this.v);
  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
              child: Text(k,
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant))),
          Text(v, style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

/// كادر أنيق (بدون تأثير زجاجي إذا useBlur=false)
class _ElegantFrame extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final bool useBlur;
  const _ElegantFrame({
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.useBlur = true,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final gradBorder = LinearGradient(
      colors: [cs.primary.withOpacity(.18), cs.tertiary.withOpacity(.18)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    const radius = 16.0;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: gradBorder,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius - 1),
        child: Stack(
          children: [
            if (useBlur)
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: const SizedBox(),
                ),
              ),
            Container(
              padding: padding,
              color: Theme.of(context).colorScheme.surface.withOpacity(.96),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

/// قسم المقاسات المحفوظة
class _SavedMeasurementsSection extends StatelessWidget {
  final Function(MeasurementProfile) onLoadProfile;

  const _SavedMeasurementsSection({required this.onLoadProfile});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    return StreamBuilder<List<MeasurementProfile>>(
      stream: MeasurementService().streamProfiles(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final profiles = snapshot.data!;
        final defaultProfile = profiles.firstWhere(
          (p) => p.isDefault,
          orElse: () => profiles.first,
        );

        return Container(
          padding: EdgeInsets.all(isTablet ? 18 : 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                cs.secondary.withOpacity(0.12),
                cs.tertiary.withOpacity(0.08),
                cs.primary.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(isTablet ? 20 : 18),
            border: Border.all(
              color: cs.secondary.withOpacity(0.35),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: cs.secondary.withOpacity(0.12),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(isTablet ? 12 : 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [cs.secondary, cs.tertiary],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: cs.secondary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.person_pin_circle_rounded,
                  color: Colors.white,
                  size: isTablet ? 26 : 22,
                ),
              ),
              SizedBox(width: isTablet ? 14 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check_circle,
                                  color: Colors.green, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                'محفوظ',
                                style: tt.labelSmall?.copyWith(
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            defaultProfile.name,
                            style: tt.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: isTablet ? 16 : 14,
                              color: cs.secondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isTablet ? 4 : 3),
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded,
                            size: isTablet ? 14 : 12,
                            color: cs.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(defaultProfile.updatedAt ??
                              defaultProfile.createdAt),
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontSize: isTablet ? 12 : 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: isTablet ? 10 : 8),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [cs.primary, cs.secondary],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: cs.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onLoadProfile(defaultProfile),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 16 : 14,
                        vertical: isTablet ? 12 : 10,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.download_rounded,
                              color: Colors.white, size: isTablet ? 20 : 18),
                          SizedBox(width: isTablet ? 8 : 6),
                          Text(
                            'تحميل',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: isTablet ? 15 : 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'اليوم';
    } else if (diff.inDays == 1) {
      return 'أمس';
    } else if (diff.inDays < 7) {
      return 'قبل ${diff.inDays} أيام';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

/// زر حفظ المقاسات
class _SaveMeasurementsButton extends StatelessWidget {
  final Map<String, double> measurements;
  final String? notes;

  const _SaveMeasurementsButton({
    required this.measurements,
    this.notes,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    // التحقق من صحة المقاسات
    final validationError =
        MeasurementProfile.validateMeasurements(measurements);
    final hasData = measurements.values.any((v) => v > 0);

    if (!hasData) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: validationError == null
              ? [cs.primary.withOpacity(0.1), cs.secondary.withOpacity(0.05)]
              : [
                  Colors.orange.withOpacity(0.1),
                  Colors.orange.withOpacity(0.05)
                ],
        ),
        borderRadius: BorderRadius.circular(isTablet ? 16 : 14),
        border: Border.all(
          color: validationError == null ? cs.primary : Colors.orange,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (validationError == null ? cs.primary : Colors.orange)
                .withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showSaveDialog(context),
          borderRadius: BorderRadius.circular(isTablet ? 16 : 14),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: isTablet ? 16 : 14,
              horizontal: isTablet ? 20 : 16,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  validationError == null
                      ? Icons.save_outlined
                      : Icons.warning_amber_rounded,
                  size: isTablet ? 24 : 22,
                  color: validationError == null ? cs.primary : Colors.orange,
                ),
                SizedBox(width: isTablet ? 12 : 10),
                Text(
                  validationError == null
                      ? 'حفظ مقاساتي للمستقبل'
                      : 'حفظ (مع تحذيرات)',
                  style: TextStyle(
                    fontSize: isTablet ? 17 : 15,
                    fontWeight: FontWeight.bold,
                    color: validationError == null ? cs.primary : Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showSaveDialog(BuildContext context) async {
    // التحقق من المقاسات
    final validationError =
        MeasurementProfile.validateMeasurements(measurements);
    if (validationError != null) {
      await showDialog(
        context: context,
        builder: (context) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            icon: const Icon(Icons.warning_amber_rounded,
                color: Colors.orange, size: 48),
            title: const Text('تحذير في المقاسات'),
            content: Text(validationError),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('تعديل'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  _proceedToSave(context);
                },
                style: FilledButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text('متابعة الحفظ'),
              ),
            ],
          ),
        ),
      );
      return;
    }

    await _proceedToSave(context);
  }

  Future<void> _proceedToSave(BuildContext context) async {
    final nameController = TextEditingController(text: 'مقاساتي الرسمية');

    final result = await showDialog<String>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('حفظ المقاسات'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'اسم ملف المقاسات',
                  hintText: 'مثال: رسمي، يومي، رياضي',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              const Text('سيتم حفظ هذه المقاسات لاستخدامها في الطلبات القادمة'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            FilledButton.icon(
              onPressed: () =>
                  Navigator.pop(context, nameController.text.trim()),
              icon: const Icon(Icons.save_rounded),
              label: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );

    if (result != null && result.isNotEmpty && context.mounted) {
      final profile = MeasurementProfile(
        id: '',
        userId: '',
        name: result,
        measurements: measurements,
        createdAt: DateTime.now(),
        isDefault: true,
        notes: notes,
      );

      try {
        await MeasurementService().saveProfile(profile);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ تم حفظ المقاسات باسم "$result"'),
              backgroundColor: Colors.green,
              action: SnackBarAction(
                label: 'عرض',
                textColor: Colors.white,
                onPressed: () {
                  // يمكن فتح صفحة إدارة المقاسات
                },
              ),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ فشل حفظ المقاسات: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

/// دائرة اختيار اللون (مثل تصميم العبايات)
class _ColorSwatch extends StatefulWidget {
  final Color color;
  final String colorName;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isTablet;

  const _ColorSwatch({
    required this.color,
    required this.colorName,
    required this.isSelected,
    required this.onTap,
    required this.isTablet,
  });

  @override
  State<_ColorSwatch> createState() => _ColorSwatchState();
}

class _ColorSwatchState extends State<_ColorSwatch>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final size = widget.isTablet ? 56.0 : 48.0;

    // تحديد لون الحلقة حسب سطوع اللون
    final brightness = widget.color.computeLuminance();
    final ringColor = widget.isSelected
        ? cs.primary
        : (brightness > 0.5 ? Colors.grey.shade400 : Colors.grey.shade300);

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: widget.isSelected
                        ? cs.primary.withOpacity(0.25)
                        : Colors.black.withOpacity(0.08),
                    blurRadius: widget.isSelected ? 12 : 6,
                    offset: Offset(0, widget.isSelected ? 4 : 2),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // الدائرة الخارجية (الحلقة)
                  Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: ringColor,
                        width: widget.isSelected ? 3.0 : 2.0,
                      ),
                    ),
                  ),
                  // الدائرة الداخلية (اللون)
                  Container(
                    width: size - (widget.isSelected ? 10 : 8),
                    height: size - (widget.isSelected ? 10 : 8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.color,
                      boxShadow: [
                        BoxShadow(
                          color: widget.color.withOpacity(0.4),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  // علامة التحديد
                  if (widget.isSelected)
                    Container(
                      width: size - 10,
                      height: size - 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.9),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        color: brightness > 0.5 ? Colors.black87 : Colors.white,
                        size: widget.isTablet ? 24 : 20,
                      ),
                    ),
                ],
              ),
            ),
            if (widget.colorName.isNotEmpty) ...[
              SizedBox(height: widget.isTablet ? 6 : 4),
              Text(
                widget.colorName,
                style: tt.bodySmall?.copyWith(
                  fontSize: widget.isTablet ? 12 : 10,
                  color: widget.isSelected ? cs.primary : cs.onSurfaceVariant,
                  fontWeight:
                      widget.isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// نموذج القماش
class FabricItem {
  final String title; // مثل: صيفي، شتوي، فاخر...
  final String image; // مسار asset أو رابط
  final String? tag; // شارة اختيارية
  const FabricItem(this.title, this.image, {this.tag});
}
