import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/fabric_service.dart';
import '../../orders/services/order_service.dart';
import '../../orders/models/order_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../measurements/models/measurement_profile.dart';
import '../../measurements/services/measurement_service.dart';
import '../../measurements/widgets/measurement_guide_dialog.dart';

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

  // حقول الرجّال بالعربي:
  final _lengthCtrl = TextEditingController(); // الطول الكلي
  final _shoulderCtrl = TextEditingController(); // الكتف
  final _sleeveCtrl = TextEditingController(); // طول الكم
  final _upperSleeveCtrl = TextEditingController(); // محيط الكم العلوي
  final _lowerSleeveCtrl = TextEditingController(); // محيط الكم السفلي
  final _chestCtrl = TextEditingController(); // الصدر
  final _waistCtrl = TextEditingController(); // الخصر
  final _neckCtrl = TextEditingController(); // محيط الرقبة
  final _embroideryCtrl = TextEditingController(); // التطريز الامامي
  final _notesCtrl = TextEditingController(); // ملاحظات

  // ==== معالج الخطوات ====
  final _pager = PageController();
  int _step = 0; // 0..2 (القماش، المقاسات+اللون، التطريز)

  // ==== القماش ====
  String? _fabricType; // الاسم الظاهر
  String? _fabricThumb; // asset أو رابط
  String? _selectedFabricId; // معرف القماش المحدد

  // ==== اللون ====
  Color? _fabricColor;
  double _shadeFactor = 1.0; // 0.8..1.2

  // ==== التطريز ====
  Color _embroideryColor = const Color(0xFF795548);
  bool _addNameEmbroidery = false;
  int _embroideryLines = 0; // 0..3

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

    if (_fabricColor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار لون القماش أولاً')),
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
      // جلب معلومات المستخدم الحالي من AuthProvider
      final authProvider = context.read<AuthProvider>();
      final currentUser = authProvider.currentUser;

      // التحقق من تسجيل الدخول
      if (currentUser == null) {
        Navigator.pop(context); // إخفاء مؤشر التحميل
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('يرجى تسجيل الدخول أولاً لإرسال الطلب'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      print('📦 Creating order for user: ${currentUser.uid} - ${currentUser.name}');

      // إنشاء الطلب
      final order = OrderModel(
        id: '', // سيتم إنشاؤه تلقائياً
        customerId: currentUser.uid, // معرف المستخدم الحقيقي
        customerName: currentUser.name, // اسم المستخدم الحقيقي
        customerPhone: currentUser.phoneNumber ?? '+968 00000000', // رقم المستخدم
        tailorId: widget.tailorId,
        tailorName: widget.tailorName,
        fabricId: _selectedFabricId!,
        fabricName: _fabricType!,
        fabricType: _fabricType!,
        fabricImageUrl: _fabricThumb ?? '',
        fabricColor: _fabricColor!.value.toRadixString(16),
        fabricColorHex:
            '#${_fabricColor!.value.toRadixString(16).padLeft(8, '0').toUpperCase()}',
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
    if (_addNameEmbroidery) p += 0.500;
    p += (_embroideryLines * 0.250);
    return p;
  }

  // ==== ألوان واجهة ديناميكية حسب اللون ====
  LinearGradient get _headerGradient {
    final base = _fabricColor ?? const Color(0xFF5C6BC0);
    final a = _tint(base, 1.00);
    final b = _tint(base, 0.86);
    return LinearGradient(
      colors: [a, b],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }

  Color _tint(Color c, double k) {
    final hsl = HSLColor.fromColor(c);
    final l = (hsl.lightness * k).clamp(0.0, 1.0);
    return hsl.withLightness(l).toColor();
  }


  @override
  void dispose() {
    _pager.dispose();
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

  // ==== تنقّل الخطوات ====
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
        // التحقق من اللون أولاً
        if (_fabricColor == null) {
          HapticFeedback.mediumImpact();
          messenger.showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.palette_rounded, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(child: Text('🎨 يرجى اختيار لون القماش')),
                ],
              ),
              backgroundColor: Colors.deepPurple,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
          return false;
        }
        
        // التحقق من المقاسات
        if (!(_formKey.currentState?.validate() ?? false)) {
          HapticFeedback.mediumImpact();
          messenger.showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.straighten_rounded, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(child: Text('📏 يرجى إدخال جميع المقاسات بشكل صحيح')),
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
        final chosenColorHex = _fabricColor == null
            ? '—'
            : '#${_fabricColor!.value.toRadixString(16).padLeft(8, '0').toUpperCase()}  (درجة: ${_shadeFactor.toStringAsFixed(2)})';
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
                _KV('لون القماش', chosenColorHex),
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
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Text('المقاسات (رجالي)',
                      style:
                          tt.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                ),
                const SizedBox(height: 6),
                _KV('الطول الكلي', fmt(_lengthCtrl)),
                _KV('الكتف', fmt(_shoulderCtrl)),
                _KV('طول الكم', fmt(_sleeveCtrl)),
                _KV('محيط الكم العلوي', fmt(_upperSleeveCtrl)),
                _KV('محيط الكم السفلي', fmt(_lowerSleeveCtrl)),
                _KV('الصدر', fmt(_chestCtrl)),
                _KV('الخصر', fmt(_waistCtrl)),
                _KV('محيط الرقبة', fmt(_neckCtrl)),
                _KV('التطريز الامامي', fmt(_embroideryCtrl)),
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
    final tt = Theme.of(context).textTheme;

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
          body: SafeArea(
          child: Column(
            children: [
              // ===== الهيدر =====
              Container(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                decoration: BoxDecoration(
                  gradient: _headerGradient,
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(18)),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 840),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.white.withOpacity(.5), width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(.08),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: const CircleAvatar(
                            backgroundColor: Colors.white24,
                            child: Icon(Icons.cut_rounded,
                                color: Colors.white, size: 26),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.tailorName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: tt.titleLarge?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined,
                                      size: 16, color: Colors.white),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text('مسقط',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: tt.bodySmall?.copyWith(
                                            color:
                                                Colors.white.withOpacity(.9))),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close_rounded,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ===== شريط التقدّم =====
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
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
                    ),
                    _MeasurementsAndColorStep(
                      fabricId: _selectedFabricId ?? '',
                      selectedColor: _fabricColor,
                      onColorChanged: (c) => setState(() => _fabricColor = c),
                      formKey: _formKey,
                      unit: _unit,
                      onUnitChanged: _switchUnit,
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
                    ),
                    _EmbroideryStep(
                      color: _embroideryColor,
                      addName: _addNameEmbroidery,
                      lines: _embroideryLines,
                      onChanged: (color, addName, lines) => setState(() {
                        _embroideryColor = color;
                        _addNameEmbroidery = addName;
                        _embroideryLines = lines;
                      }),
                    ),
                  ],
                ),
              ),

              // ===== شريط السعر + أزرار =====
              SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    border: Border(top: BorderSide(color: cs.outlineVariant)),
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 840),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('التكلفة التقديرية',
                                    style: tt.labelMedium
                                        ?.copyWith(color: cs.onSurfaceVariant)),
                                const SizedBox(height: 2),
                                Text('ر.ع ${_price.toStringAsFixed(3)}',
                                    style: tt.titleLarge?.copyWith(
                                        fontWeight: FontWeight.w900)),
                              ],
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: _back,
                            icon: const Icon(Icons.arrow_back_rounded),
                            label: Text(_step == 0 ? 'رجوع' : 'السابق'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(116, 46),
                            ),
                          ),
                          const SizedBox(width: 8),
                          FilledButton.icon(
                            onPressed: _next,
                            icon: Icon(_step == 2
                                ? Icons.check_circle_rounded
                                : Icons.arrow_forward_rounded),
                            label:
                                Text(_step == 2 ? 'إرسال الطلب' : 'التالي'),
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(152, 46),
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
        ),
      ),
    ),
    );
  }
}

/* ===================== شريط التقدم ===================== */
class _StepperHeader extends StatelessWidget {
  final int current; // 0..2
  final List<String> labels;
  const _StepperHeader({required this.current, required this.labels});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final items = List.generate(labels.length, (i) {
      final active = i <= current;
      return Expanded(
        child: Row(
          children: [
            _dot(i + 1, labels[i], active, cs),
            if (i < labels.length - 1)
              Expanded(
                child: Container(
                  height: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color: active ? cs.primary : cs.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
          ],
        ),
      );
    });
    return Column(children: [Row(children: items)]);
  }

  Widget _dot(int n, String label, bool active, ColorScheme cs) {
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? cs.primary : cs.surface,
            border: Border.all(
                color: active ? cs.primary : cs.outlineVariant, width: 2),
          ),
          alignment: Alignment.center,
          child: Text(
            '$n',
            style: TextStyle(
              fontSize: 11,
              color: active ? cs.onPrimary : cs.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: active ? cs.onSurface : cs.onSurfaceVariant,
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

  const _FabricStep({
    required this.tailorId,
    required this.selectedType,
    this.selectedFabricId,
    required this.onTypeChanged,
  });

  @override
  State<_FabricStep> createState() => _FabricStepState();
}

class _FabricStepState extends State<_FabricStep> {

  // حفظ القماش كمفضل
  Future<void> _saveFabricAsFavorite(Map<String, dynamic> fabric) async {
    final prefs = await SharedPreferences.getInstance();
    final fabricId = fabric['id'] as String?;
    
    if (fabricId != null) {
      // حفظ ID القماش المفضل
      await prefs.setString('favorite_fabric_id', fabricId);
      await prefs.setString('favorite_fabric_name', fabric['name'] ?? '');
      
      HapticFeedback.mediumImpact();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.favorite_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '💖 تم حفظ "${fabric['name']}" كمفضل!',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.pink.shade400,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'تراجع',
              textColor: Colors.white,
              onPressed: () async {
                await prefs.remove('favorite_fabric_id');
                await prefs.remove('favorite_fabric_name');
              },
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    // عرض بطاقة القماش المختار بالتفصيل
    Widget buildSelectedFabricDetailCard(Map<String, dynamic> fabric) {
      final availableColors = fabric['availableColors'] as List<dynamic>? ?? [];
      final originalPrice = fabric['originalPrice'] as num?;
      final currentPrice = (fabric['pricePerMeter'] as num?)?.toDouble() ?? 0.0;
      final hasDiscount = originalPrice != null && originalPrice > currentPrice;
      
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.primary, width: 2),
          boxShadow: [
            BoxShadow(
              color: cs.primary.withOpacity(0.15),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // العنوان مع زر تغيير القماش
            Row(
              children: [
                Expanded(
                  child: Text(
                    fabric['name'] ?? 'قماش',
                    style: tt.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.primary,
                    ),
                  ),
                ),
                // زر تغيير القماش
                OutlinedButton.icon(
                  onPressed: () {
                    // إلغاء الاختيار لعرض القائمة
                    widget.onTypeChanged(null, null, null);
                    HapticFeedback.lightImpact();
                  },
                  icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                  label: const Text('تغيير'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: cs.primary,
                    side: BorderSide(color: cs.primary),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // السعر
            Row(
              children: [
                Text(
                  'ر.ع ${currentPrice.toStringAsFixed(3)}',
                  style: tt.headlineMedium?.copyWith(
                    color: hasDiscount ? cs.error : cs.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (hasDiscount) ...[
                  const SizedBox(width: 12),
                  Text(
                    'ر.ع ${originalPrice.toStringAsFixed(3)}',
                    style: tt.titleMedium?.copyWith(
                      decoration: TextDecoration.lineThrough,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),
            
            // الوصف
            if (fabric['description'] != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 18, color: cs.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        fabric['description'],
                        style: tt.bodyMedium?.copyWith(color: cs.onSurface),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // اختيار اللون - قائمة منسدلة
            if (availableColors.isNotEmpty) ...[
              Text(
                'اللون *',
                style: tt.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              _ColorDropdown(
                colors: availableColors,
                onColorSelected: (colorData) {
                  // سيتم معالجة اختيار اللون هنا لاحقاً
                },
              ),
              const SizedBox(height: 8),
              Text(
                'اختر',
                style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 20),
              
              // زر حفظ كمفضل
              OutlinedButton.icon(
                onPressed: () {
                  _saveFabricAsFavorite(fabric);
                },
                icon: const Icon(Icons.favorite_border_rounded, size: 20),
                label: const Text('حفظ هذا الاختيار كمفضل'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.pink,
                  side: BorderSide(color: Colors.pink.shade200),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ],
          ],
        ),
      );
    }

    Widget grid(List<Map<String, dynamic>> fabrics) {
      if (fabrics.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.checkroom_outlined, size: 80, color: cs.onSurfaceVariant),
                const SizedBox(height: 16),
                Text(
                  'لا توجد أقمشة متاحة حالياً',
                  style: tt.titleMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        );
      }

      // قائمة عمودية بتصميم بسيط
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: fabrics.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (_, i) {
          final fabric = fabrics[i];
          final sel = widget.selectedFabricId != null &&
              widget.selectedFabricId == fabric['id'];

          Widget img(String path) => _isNetworkPath(path)
              ? CachedNetworkImage(
                  imageUrl: path,
                  fit: BoxFit.cover,
                  memCacheWidth: 300,
                  memCacheHeight: 300,
                  placeholder: (context, url) => Container(
                    color: cs.surfaceContainerHighest,
                    child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: cs.surfaceContainerHighest,
                    child: Icon(Icons.image_not_supported_rounded,
                        color: cs.onSurfaceVariant),
                  ),
                )
              : Image.asset(
                  path,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: cs.surfaceContainerHighest,
                    child: Icon(Icons.image_not_supported_rounded,
                        color: cs.onSurfaceVariant),
                  ),
                );

          final availableColors = fabric['availableColors'] as List<dynamic>? ?? [];
          final currentPrice = (fabric['pricePerMeter'] as num?)?.toDouble() ?? 0.0;
          
          return InkWell(
            onTap: () => widget.onTypeChanged(
                fabric['name'], fabric['imageUrl'], fabric['id']),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: sel ? cs.primary : cs.outlineVariant,
                  width: sel ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  // الصورة
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 80,
                      height: 80,
                      child: Stack(
                        children: [
                          Positioned.fill(child: img(fabric['imageUrl'] ?? '')),
                          if (sel)
                            Positioned(
                              top: 4,
                              right: 4,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: cs.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // المعلومات
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          fabric['name'] ?? 'قماش',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: tt.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: sel ? cs.primary : cs.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ر.ع ${currentPrice.toStringAsFixed(3)}',
                          style: tt.titleSmall?.copyWith(
                            color: cs.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (availableColors.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: availableColors.take(4).map((colorData) {
                              final colorHex = colorData['colorHex'] as String? ?? '#CCCCCC';
                              Color color;
                              try {
                                color = Color(int.parse(
                                    colorHex.replaceFirst('#', '0xFF')));
                              } catch (e) {
                                color = Colors.grey;
                              }
                              
                              return Container(
                                margin: const EdgeInsets.only(left: 4),
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: color,
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    width: 1,
                                  ),
                                ),
                              );
                            }).toList(),
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
                Text('اختر نوع القماش من المتجر',
                    style:
                        tt.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
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
                    
                    // عرض البطاقة التفصيلية إذا تم اختيار قماش
                    if (widget.selectedFabricId != null) {
                      final selectedFabric = fabrics.firstWhere(
                        (fabric) => fabric['id'] == widget.selectedFabricId,
                        orElse: () => <String, dynamic>{},
                      );
                      
                      if (selectedFabric.isNotEmpty) {
                        return buildSelectedFabricDetailCard(selectedFabric);
                      }
                    }
                    
                    return grid(fabrics);
                  },
                ),
                const SizedBox(height: 12),
                // عرض القماش المختار
                if (widget.selectedType != null)
                  _buildSelectedFabricCard(
                    context: context,
                    tailorId: widget.tailorId,
                    selectedType: widget.selectedType!,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // بناء كارد القماش المختار
  Widget _buildSelectedFabricCard({
    required BuildContext context,
    required String tailorId,
    required String selectedType,
  }) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: FabricService.getTailorFabrics(tailorId),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.active) {
          return const SizedBox.shrink();
        }

        final fabrics = snapshot.data ?? [];
        // البحث باستخدام ID أولاً، وإذا لم يوجد فاستخدم الاسم
        final selectedFabric = widget.selectedFabricId != null
            ? fabrics.firstWhere(
                (fabric) => fabric['id'] == widget.selectedFabricId,
                orElse: () => <String, dynamic>{},
              )
            : fabrics.firstWhere(
                (fabric) => fabric['name'] == selectedType,
                orElse: () => <String, dynamic>{},
              );

        if (selectedFabric.isEmpty) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.primary.withOpacity(0.3), width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // رأس الكارد
              Row(
                children: [
                  // صورة القماش المختارة - أكبر حجماً
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: cs.surfaceContainerHighest,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _isNetworkPath(selectedFabric['imageUrl'] ?? '')
                          ? CachedNetworkImage(
                              imageUrl: selectedFabric['imageUrl'] ?? '',
                              fit: BoxFit.cover,
                              width: 80,
                              height: 80,
                              memCacheWidth: 160,
                              memCacheHeight: 160,
                              placeholder: (context, url) => Container(
                                color: cs.surfaceContainerHighest,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: cs.surfaceContainerHighest,
                                child: Icon(
                                  Icons.image,
                                  size: 30,
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            )
                          : Image.asset(
                              selectedFabric['imageUrl'] ?? '',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: cs.surfaceContainerHighest,
                                child: Icon(
                                  Icons.image,
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // معلومات القماش
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // اسم القماش
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                selectedFabric['name'] ?? selectedType,
                                style: tt.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // علامة الاختيار
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: cs.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check,
                                color: cs.onPrimary,
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // السعر
                        Text(
                          'ر.ع ${(selectedFabric['price'] ?? 0.0).toStringAsFixed(3)}',
                          style: tt.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: cs.primary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // نوع القماش + الوحدة
                        Row(
                          children: [
                            // نوع القماش
                            if (selectedFabric['type'] != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: cs.primaryContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  selectedFabric['type'],
                                  style: tt.labelSmall?.copyWith(
                                    color: cs.onPrimaryContainer,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            const SizedBox(width: 8),
                            // الوحدة
                            Text(
                              'متر',
                              style: tt.labelMedium?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // رسالة التأكيد
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cs.primaryContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: cs.primary, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'تم اختيار: ${selectedFabric['name'] ?? selectedType}',
                        style: tt.labelMedium?.copyWith(
                          color: cs.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _isNetworkPath(String path) {
    return path.startsWith('http://') || path.startsWith('https://');
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

    // الحصول على اللون المختار
    Color? selectedColorValue;
    String? selectedColorName;
    if (_selectedColor != null) {
      final colorHex = _selectedColor!['colorHex'] as String? ?? '#CCCCCC';
      selectedColorName = _selectedColor!['colorName'] as String? ?? '';
      try {
        selectedColorValue = Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
      } catch (e) {
        selectedColorValue = Colors.grey;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // القائمة المنسدلة
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Map<String, dynamic>>(
              isExpanded: true,
              value: _selectedColor,
              hint: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
            final colorName = colorData['colorName'] as String? ?? 'غير محدد';
            final colorHex = colorData['colorHex'] as String? ?? '#CCCCCC';
            
            Color color;
            try {
              color = Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
            } catch (e) {
              color = Colors.grey;
            }

            return DropdownMenuItem<Map<String, dynamic>>(
              value: colorData,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    // دائرة اللون
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color,
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: color.computeLuminance() > 0.9
                          ? Icon(
                              Icons.circle_outlined,
                              color: Colors.grey.shade400,
                              size: 20,
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    // اسم اللون
                    Expanded(
                      child: Text(
                        colorName,
                        style: tt.bodyLarge,
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
              borderRadius: BorderRadius.circular(8),
              dropdownColor: cs.surface,
            ),
          ),
        ),
        
        // معاينة اللون المختار
        if (_selectedColor != null && selectedColorValue != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  cs.primaryContainer.withOpacity(0.3),
                  cs.secondaryContainer.withOpacity(0.3),
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.primary.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                // دائرة اللون الكبيرة
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selectedColorValue,
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: selectedColorValue.withOpacity(0.5),
                        blurRadius: 12,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: selectedColorValue.computeLuminance() > 0.9
                      ? Icon(
                          Icons.circle_outlined,
                          color: Colors.grey.shade400,
                          size: 30,
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                
                // معلومات اللون
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            color: cs.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'اللون المختار',
                            style: tt.labelMedium?.copyWith(
                              color: cs.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        selectedColorName ?? '',
                        style: tt.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // أيقونة تأكيد
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cs.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/* ===================== خطوة المقاسات + اللون (مدمجة) ===================== */
class _MeasurementsAndColorStep extends StatefulWidget {
  final String fabricId;
  final Color? selectedColor;
  final ValueChanged<Color> onColorChanged;
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

  const _MeasurementsAndColorStep({
    required this.fabricId,
    required this.selectedColor,
    required this.onColorChanged,
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
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
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
                  // ========== قسم اختيار اللون أولاً ==========
                  StreamBuilder<Map<String, dynamic>?>(
                    stream: Stream.fromFuture(
                        FabricService.getFabricById(widget.fabricId)),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
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
                              const Icon(Icons.error_outline_rounded),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'حدث خطأ في تحميل الألوان',
                                  style: TextStyle(color: cs.onErrorContainer),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final fabric = snapshot.data;
                      if (fabric == null) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'لم يتم العثور على بيانات القماش',
                            textAlign: TextAlign.center,
                          ),
                        );
                      }

                      final availableColors =
                          fabric['availableColors'] as List<dynamic>? ?? [];

                      if (availableColors.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline_rounded),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'لا توجد ألوان متاحة لهذا القماش',
                                  style: TextStyle(color: cs.onSurfaceVariant),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final screenWidth = MediaQuery.of(context).size.width;
                      final isTablet = screenWidth >= 600;

                      return Container(
                        padding: EdgeInsets.all(isTablet ? 20 : 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              cs.surface,
                              cs.surfaceContainerHighest.withValues(alpha: 0.5),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(isTablet ? 16 : 14),
                          border: Border.all(color: cs.outlineVariant),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.palette_rounded,
                                    color: cs.primary,
                                    size: isTablet ? 22 : 20),
                                SizedBox(width: isTablet ? 10 : 8),
                                Expanded(
                                  child: Text(
                                    '🎨 اختر لون القماش',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: isTablet ? 17 : 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: isTablet ? 16 : 14),
                            Wrap(
                              spacing: isTablet ? 14 : 12,
                              runSpacing: isTablet ? 14 : 12,
                              children: availableColors.map((colorData) {
                                final colorHex =
                                    colorData['colorHex'] as String? ?? '#FFFFFF';
                                final colorName =
                                    colorData['colorName'] as String? ?? '';

                                // تحويل hex إلى Color
                                Color color;
                                try {
                                  color = Color(
                                      int.parse(colorHex.replaceFirst('#', '0xFF')));
                                } catch (e) {
                                  color = Colors.white;
                                }

                                final sel = widget.selectedColor != null &&
                                    widget.selectedColor!.value == color.value;

                                return _ColorSwatch(
                                  color: color,
                                  colorName: colorName,
                                  isSelected: sel,
                                  onTap: () => widget.onColorChanged(color),
                                  isTablet: isTablet,
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  Divider(color: cs.outlineVariant, thickness: 1),
                  const SizedBox(height: 20),

                  // ========== قسم المقاسات ==========
                  // قوالب المقاسات الجاهزة
                  _MeasurementTemplatesSection(
                    onTemplateSelected: (template) {
                      widget.lengthCtrl.text =
                          template['الطول الكلي']!.toStringAsFixed(1);
                      widget.shoulderCtrl.text =
                          template['الكتف']!.toStringAsFixed(1);
                      widget.sleeveCtrl.text =
                          template['طول الكم']!.toStringAsFixed(1);
                      widget.upperSleeveCtrl.text =
                          template['محيط الكم العلوي']!.toStringAsFixed(1);
                      widget.lowerSleeveCtrl.text =
                          template['محيط الكم السفلي']!.toStringAsFixed(1);
                      widget.chestCtrl.text =
                          template['الصدر']!.toStringAsFixed(1);
                      widget.waistCtrl.text =
                          template['الخصر']!.toStringAsFixed(1);
                      widget.neckCtrl.text =
                          template['محيط الرقبة']!.toStringAsFixed(1);
                      widget.embroideryCtrl.text =
                          template['التطريز الامامي']!.toStringAsFixed(1);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              '✅ تم تطبيق القالب بنجاح - يمكنك التعديل حسب الحاجة'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // زر حفظ/استعادة المقاسات
                  _SavedMeasurementsSection(
                    onLoadProfile: (profile) {
                      widget.lengthCtrl.text =
                          profile.measurements['الطول الكلي']?.toString() ?? '';
                      widget.shoulderCtrl.text =
                          profile.measurements['الكتف']?.toString() ?? '';
                      widget.sleeveCtrl.text =
                          profile.measurements['طول الكم']?.toString() ?? '';
                      widget.upperSleeveCtrl.text =
                          profile.measurements['محيط الكم العلوي']?.toString() ??
                              '';
                      widget.lowerSleeveCtrl.text =
                          profile.measurements['محيط الكم السفلي']?.toString() ??
                              '';
                      widget.chestCtrl.text =
                          profile.measurements['الصدر']?.toString() ?? '';
                      widget.waistCtrl.text =
                          profile.measurements['الخصر']?.toString() ?? '';
                      widget.neckCtrl.text =
                          profile.measurements['محيط الرقبة']?.toString() ?? '';
                      widget.embroideryCtrl.text =
                          profile.measurements['التطريز الامامي']?.toString() ??
                              '';
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              '✅ تم تحميل مقاسات "${profile.name}" بنجاح'),
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
                        onSelectionChanged: (Set<MeasurementUnit> newSelection) {
                          widget.onUnitChanged(newSelection.first);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // الحقول
                  ...rows.map((r) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _PrettyLineField(
                        label: r.label,
                        controller: r.ctrl,
                        min: r.min,
                        max: r.max,
                        step: step(),
                        unitLabel: widget.unit == MeasurementUnit.cm ? 'سم' : 'إنش',
                        decimals: decimals,
                      ),
                    );
                  }),

                  const SizedBox(height: 12),

                  // ملاحظات إضافية
                  TextFormField(
                    controller: widget.notesCtrl,
                    maxLines: 3,
                    style: theme.textTheme.bodyLarge,
                    decoration: InputDecoration(
                      labelText: 'ملاحظات إضافية (اختياري)',
                      hintText: 'مثال: تفصيلات خاصة، أو ملاحظات للخياط',
                      filled: true,
                      fillColor: cs.surfaceContainerHighest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: cs.primary, width: 2),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // زر حفظ المقاسات الحالية
                  _SaveMeasurementsButton(
                    measurements: {
                      'الطول الكلي':
                          double.tryParse(widget.lengthCtrl.text) ?? 0,
                      'الكتف': double.tryParse(widget.shoulderCtrl.text) ?? 0,
                      'طول الكم':
                          double.tryParse(widget.sleeveCtrl.text) ?? 0,
                      'محيط الكم العلوي':
                          double.tryParse(widget.upperSleeveCtrl.text) ?? 0,
                      'محيط الكم السفلي':
                          double.tryParse(widget.lowerSleeveCtrl.text) ?? 0,
                      'الصدر': double.tryParse(widget.chestCtrl.text) ?? 0,
                      'الخصر': double.tryParse(widget.waistCtrl.text) ?? 0,
                      'محيط الرقبة':
                          double.tryParse(widget.neckCtrl.text) ?? 0,
                      'التطريز الامامي':
                          double.tryParse(widget.embroideryCtrl.text) ?? 0,
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
                  // قوالب المقاسات الجاهزة
                  _MeasurementTemplatesSection(
                    onTemplateSelected: (template) {
                      widget.lengthCtrl.text = template['الطول الكلي']!.toStringAsFixed(1);
                      widget.shoulderCtrl.text = template['الكتف']!.toStringAsFixed(1);
                      widget.sleeveCtrl.text = template['طول الكم']!.toStringAsFixed(1);
                      widget.upperSleeveCtrl.text = template['محيط الكم العلوي']!.toStringAsFixed(1);
                      widget.lowerSleeveCtrl.text = template['محيط الكم السفلي']!.toStringAsFixed(1);
                      widget.chestCtrl.text = template['الصدر']!.toStringAsFixed(1);
                      widget.waistCtrl.text = template['الخصر']!.toStringAsFixed(1);
                      widget.neckCtrl.text = template['محيط الرقبة']!.toStringAsFixed(1);
                      widget.embroideryCtrl.text = template['التطريز الامامي']!.toStringAsFixed(1);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✅ تم تطبيق القالب بنجاح - يمكنك التعديل حسب الحاجة'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // زر حفظ/استعادة المقاسات
                  _SavedMeasurementsSection(
                    onLoadProfile: (profile) {
                      final m = profile.measurements;
                      widget.lengthCtrl.text = (m['الطول الكلي'] ?? 0).toStringAsFixed(1);
                      widget.shoulderCtrl.text = (m['الكتف'] ?? 0).toStringAsFixed(1);
                      widget.sleeveCtrl.text = (m['طول الكم'] ?? 0).toStringAsFixed(1);
                      widget.upperSleeveCtrl.text = (m['محيط الكم العلوي'] ?? 0).toStringAsFixed(1);
                      widget.lowerSleeveCtrl.text = (m['محيط الكم السفلي'] ?? 0).toStringAsFixed(1);
                      widget.chestCtrl.text = (m['الصدر'] ?? 0).toStringAsFixed(1);
                      widget.waistCtrl.text = (m['الخصر'] ?? 0).toStringAsFixed(1);
                      widget.neckCtrl.text = (m['محيط الرقبة'] ?? 0).toStringAsFixed(1);
                      widget.embroideryCtrl.text = (m['التطريز الامامي'] ?? 0).toStringAsFixed(1);
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
                      'محيط الكم العلوي': _parseDouble(widget.upperSleeveCtrl.text),
                      'محيط الكم السفلي': _parseDouble(widget.lowerSleeveCtrl.text),
                      'الصدر': _parseDouble(widget.chestCtrl.text),
                      'الخصر': _parseDouble(widget.waistCtrl.text),
                      'محيط الرقبة': _parseDouble(widget.neckCtrl.text),
                      'التطريز الامامي': _parseDouble(widget.embroideryCtrl.text),
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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.surface,
            cs.surfaceContainerHighest.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(isTablet ? 18 : 16),
        border: Border.all(
          color: cs.outlineVariant,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withOpacity(.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 16 : 12, 
          vertical: isTablet ? 12 : 10),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.label,
                    style: tt.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: isTablet ? 16 : 14,
                    ),
                  ),
                ),
                MeasurementGuideButton(measurementName: widget.label),
              ],
            ),
          ),
          SizedBox(width: isTablet ? 16 : 12),

          // مجموعة التحكم — تم تمديد الحاوية لتستوعب الأرقام الطويلة
          Directionality(
            textDirection: TextDirection.ltr,
            child: Flexible(
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 180, maxWidth: 280),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: cs.primary.withOpacity(.35), width: 1.4),
                  ),
                  child: Row(
                    children: [
                      _pillBtn(context, Icons.remove_rounded, _dec),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: widget.controller,
                          textAlign: TextAlign.center,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          style: tt.titleSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            height: 1.15,
                          ),
                          decoration: const InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            hintText: '—',
                            contentPadding: EdgeInsets.symmetric(vertical: 6),
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
                      const SizedBox(width: 8),
                      _pillBtn(context, Icons.add_rounded, _inc),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: cs.primaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          widget.unitLabel,
                          style: tt.labelSmall?.copyWith(
                              color: cs.onPrimaryContainer,
                              fontWeight: FontWeight.w900),
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
  }

  Widget _pillBtn(BuildContext context, IconData icon, VoidCallback onTap) {
    final cs = Theme.of(context).colorScheme;
    return InkResponse(
      onTap: onTap,
      radius: 18,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: cs.primary.withOpacity(.10),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 18, color: cs.primary),
      ),
    );
  }
}

/* ===================== خطوة التطريز ===================== */
class _EmbroideryStep extends StatelessWidget {
  final Color color;
  final bool addName;
  final int lines;
  final void Function(Color color, bool addName, int lines) onChanged;

  const _EmbroideryStep({
    required this.color,
    required this.addName,
    required this.lines,
    required this.onChanged,
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
                      Text('لون خيط التطريز',
                          style: tt.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: options.map((c) {
                          final sel = c.value == color.value;
                          return GestureDetector(
                            onTap: () => onChanged(c, addName, lines),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: c,
                                border: Border.all(
                                    color: sel ? cs.onPrimary : Colors.white,
                                    width: sel ? 3 : 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(.08),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  )
                                ],
                              ),
                              child: sel
                                  ? const Icon(Icons.check, color: Colors.white)
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _ElegantFrame(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  useBlur: false,
                  child: SwitchListTile(
                    value: addName,
                    onChanged: (v) => onChanged(color, v, lines),
                    title: const Text('إضافة تطريز الاسم (+0.500 ر.ع)'),
                    subtitle: Text('اكتب الاسم المطلوب في الملاحظات',
                        style: tt.bodySmall),
                    contentPadding: EdgeInsets.zero,
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
                        onChanged(color, addName, v);
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
                        onChanged(color, addName, v);
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
  final double radius;
  final EdgeInsets padding;
  final bool useBlur;
  const _ElegantFrame({
    required this.child,
    this.radius = 18,
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

/// قسم قوالب المقاسات الجاهزة
class _MeasurementTemplatesSection extends StatelessWidget {
  final Function(Map<String, double>) onTemplateSelected;

  const _MeasurementTemplatesSection({required this.onTemplateSelected});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    return Container(
      padding: EdgeInsets.all(isTablet ? 18 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primary.withOpacity(0.12),
            cs.secondary.withOpacity(0.08),
            cs.tertiary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(isTablet ? 20 : 18),
        border: Border.all(
          color: cs.primary.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isTablet ? 10 : 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [cs.primary, cs.secondary],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: cs.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.grid_view_rounded,
                  color: Colors.white,
                  size: isTablet ? 22 : 20,
                ),
              ),
              SizedBox(width: isTablet ? 12 : 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'قوالب مقاسات جاهزة',
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: isTablet ? 18 : 16,
                        color: cs.primary,
                      ),
                    ),
                    Text(
                      'ملء سريع ودقيق',
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontSize: isTablet ? 12 : 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 14 : 12),
          Text(
            'اختر قالباً كنقطة بداية، ثم عدّل حسب مقاساتك',
            style: tt.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontSize: isTablet ? 14 : 12,
            ),
          ),
          SizedBox(height: isTablet ? 14 : 12),
          Wrap(
            spacing: isTablet ? 12 : 10,
            runSpacing: isTablet ? 12 : 10,
            children: [
              _TemplateChip(
                label: 'S',
                subtitle: 'صغير',
                onTap: () => onTemplateSelected(MeasurementProfile.getTemplate('S')),
                isTablet: isTablet,
              ),
              _TemplateChip(
                label: 'M',
                subtitle: 'متوسط',
                onTap: () => onTemplateSelected(MeasurementProfile.getTemplate('M')),
                isTablet: isTablet,
              ),
              _TemplateChip(
                label: 'L',
                subtitle: 'كبير',
                onTap: () => onTemplateSelected(MeasurementProfile.getTemplate('L')),
                isTablet: isTablet,
              ),
              _TemplateChip(
                label: 'XL',
                subtitle: 'كبير جداً',
                onTap: () => onTemplateSelected(MeasurementProfile.getTemplate('XL')),
                isTablet: isTablet,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TemplateChip extends StatelessWidget {
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  final bool isTablet;

  const _TemplateChip({
    required this.label,
    required this.subtitle,
    required this.onTap,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: isTablet ? 110 : 80,
        padding: EdgeInsets.symmetric(
          vertical: isTablet ? 16 : 14,
          horizontal: isTablet ? 14 : 10,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cs.surface,
              cs.surfaceContainerHighest.withOpacity(0.5),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: cs.primary.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: cs.primary.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(isTablet ? 10 : 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [cs.primary, cs.secondary],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: cs.primary.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                label,
                style: tt.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: isTablet ? 26 : 22,
                ),
              ),
            ),
            SizedBox(height: isTablet ? 8 : 6),
            Text(
              subtitle,
              style: tt.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                fontSize: isTablet ? 13 : 11,
                fontWeight: FontWeight.w600,
              ),
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
                              Icon(Icons.check_circle,
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
                              color: Colors.white,
                              size: isTablet ? 20 : 18),
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
    final validationError = MeasurementProfile.validateMeasurements(measurements);
    final hasData = measurements.values.any((v) => v > 0);

    if (!hasData) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: validationError == null
              ? [cs.primary.withOpacity(0.1), cs.secondary.withOpacity(0.05)]
              : [Colors.orange.withOpacity(0.1), Colors.orange.withOpacity(0.05)],
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
    final validationError = MeasurementProfile.validateMeasurements(measurements);
    if (validationError != null) {
      await showDialog(
        context: context,
        builder: (context) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            icon: Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 48),
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
              onPressed: () => Navigator.pop(context, nameController.text.trim()),
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
        : (brightness > 0.5
            ? Colors.grey.shade400
            : Colors.grey.shade300);

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
                        color: brightness > 0.5
                            ? Colors.black87
                            : Colors.white,
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
                  color: widget.isSelected
                      ? cs.primary
                      : cs.onSurfaceVariant,
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
