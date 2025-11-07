import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../services/fabric_service.dart';
import '../../orders/services/order_service.dart';
import '../../orders/models/order_model.dart';
import '../../auth/providers/auth_provider.dart';

bool _isNetworkPath(String p) =>
    p.startsWith('http://') || p.startsWith('https://');

/// ===== وحدات القياس =====
enum MeasurementUnit { cm, inch }

extension MeasurementUnitX on MeasurementUnit {
  String get labelAr => this == MeasurementUnit.cm ? 'سم' : 'إنش';
  String get labelEn => this == MeasurementUnit.cm ? 'cm' : 'in';
}

const double _cmPerInch = 2.54;
const Color _brand = Color(0xFF6D4C41);

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
  int _step = 0; // 0..3

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

  Color _applyShade(Color base, double factor) {
    final hsl = HSLColor.fromColor(base);
    final l = (hsl.lightness * factor).clamp(0.0, 1.0);
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
  void _next() {
    FocusScope.of(context).unfocus();
    if (!_canProceed(_step)) return;
    if (_step < 3) {
      setState(() => _step++);
      _pager.animateToPage(
        _step,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
      HapticFeedback.selectionClick();
    } else {
      _submitOrder();
    }
  }

  void _back() {
    FocusScope.of(context).unfocus();
    if (_step > 0) {
      setState(() => _step--);
      _pager.animateToPage(
        _step,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
      HapticFeedback.selectionClick();
    } else {
      Navigator.pop(context);
    }
  }

  bool _canProceed(int step) {
    final messenger = ScaffoldMessenger.of(context);
    switch (step) {
      case 0:
        if (_fabricType == null) {
          messenger.showSnackBar(
              const SnackBar(content: Text('اختر نوع القماش أولاً.')));
          return false;
        }
        return true;
      case 1:
        if (_fabricColor == null) {
          messenger
              .showSnackBar(const SnackBar(content: Text('اختر لون القماش.')));
          return false;
        }
        return true;
      case 2:
        if (!(_formKey.currentState?.validate() ?? false)) return false;
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

    return Directionality(
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
                      labels: const ['القماش', 'اللون', 'المقاسات', 'التطريز'],
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
                    _ColorStep(
                      fabricId: _selectedFabricId ?? '',
                      selected: _fabricColor,
                      shadeFactor: _shadeFactor,
                      onColorChanged: (c) => setState(() => _fabricColor = c),
                      onShadeChanged: (f) => setState(() => _shadeFactor = f),
                      previewColor: _fabricColor == null
                          ? null
                          : _applyShade(_fabricColor!, _shadeFactor),
                    ),
                    _MenMeasurementsStep(
                      formKey: _formKey,
                      unit: _unit,
                      onUnitChanged: _switchUnit,
                      // controllers
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
                            icon: Icon(_step == 3
                                ? Icons.check_circle_rounded
                                : Icons.arrow_forward_rounded),
                            label:
                                Text(_step == 3 ? 'مراجعة وإرسال' : 'التالي'),
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
    );
  }
}

/* ===================== شريط التقدم ===================== */
class _StepperHeader extends StatelessWidget {
  final int current; // 0..3
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
  bool _showDetailView = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    Widget grid(List<Map<String, dynamic>> fabrics) {
      if (fabrics.isEmpty) {
        return _ElegantFrame(
          padding: const EdgeInsets.all(16),
          useBlur: false,
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'لا توجد أقمشة متاحة لهذا الخياط حالياً.',
                  style: tt.bodySmall,
                ),
              ),
            ],
          ),
        );
      }

      // شبكة متجاوبة
      final width = MediaQuery.of(context).size.width;
      int cross = 2;
      if (width >= 360) cross = 3;
      if (width >= 720) cross = 4;
      if (width >= 1000) cross = 5;

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: fabrics.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cross,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: .80,
        ),
        itemBuilder: (_, i) {
          final fabric = fabrics[i];
          // التحقق من الاختيار باستخدام ID بدلاً من الاسم فقط
          final sel = widget.selectedFabricId != null &&
              widget.selectedFabricId == fabric['id'];

          Widget img(String path) => _isNetworkPath(path)
              ? CachedNetworkImage(
                  imageUrl: path,
                  fit: BoxFit.cover,
                  width: double.infinity,
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
                  fadeInDuration: const Duration(milliseconds: 200),
                  fadeOutDuration: const Duration(milliseconds: 100),
                )
              : Image.asset(
                  path,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (_, __, ___) => Container(
                    color: cs.surfaceContainerHighest,
                    child: Icon(Icons.image_not_supported_rounded,
                        color: cs.onSurfaceVariant),
                  ),
                );

          return InkWell(
            onTap: () => widget.onTypeChanged(
                fabric['name'], fabric['imageUrl'], fabric['id']),
            borderRadius: BorderRadius.circular(16),
            child: _ElegantFrame(
              radius: 16,
              useBlur: false,
              child: Column(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(14)),
                      child: img(fabric['imageUrl'] ?? ''),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            fabric['name'] ?? 'قماش',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: tt.labelLarge
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        AnimatedScale(
                          duration: const Duration(milliseconds: 180),
                          scale: sel ? 1.0 : 0.0,
                          child: Icon(Icons.check_circle_rounded,
                              color: cs.primary, size: 20),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'ر.ع ${(fabric['pricePerMeter'] ?? 0.0).toStringAsFixed(3)}/متر',
                            style: tt.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: cs.secondaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            fabric['type'] ?? 'غير محدد',
                            style: tt.labelSmall?.copyWith(
                              color: cs.onSecondaryContainer,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
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
                const SizedBox(height: 12),
                // زر التبديل بين القائمة والتفاصيل
                if (widget.selectedType != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          setState(() => _showDetailView = !_showDetailView);
                        },
                        icon: Icon(
                          _showDetailView ? Icons.grid_view : Icons.info,
                          size: 18,
                        ),
                        label: Text(
                          _showDetailView ? 'عرض الشبكة' : 'عرض التفاصيل',
                          style: tt.labelMedium,
                        ),
                      ),
                    ],
                  ),
                // العرض بناءً على الحالة
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

                    // إذا كان المفروض عرض التفاصيل والقماش مختار
                    if (_showDetailView && widget.selectedType != null) {
                      return _buildDetailView(fabrics, tt, cs);
                    }

                    return grid(fabrics);
                  },
                ),
                const SizedBox(height: 12),
                // عرض القماش المختار بشكل كامل (فقط إذا لم يكن في وضع التفاصيل)
                if (!_showDetailView && widget.selectedType != null)
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

  // بناء عرض التفاصيل المفصلة للقماش المختار
  Widget _buildDetailView(
    List<Map<String, dynamic>> fabrics,
    TextTheme tt,
    ColorScheme cs,
  ) {
    // البحث باستخدام ID أولاً، وإذا لم يوجد فاستخدم الاسم
    final selectedFabric = widget.selectedFabricId != null
        ? fabrics.firstWhere(
            (fabric) => fabric['id'] == widget.selectedFabricId,
            orElse: () => <String, dynamic>{},
          )
        : fabrics.firstWhere(
            (fabric) => fabric['name'] == widget.selectedType,
            orElse: () => <String, dynamic>{},
          );

    if (selectedFabric.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cs.primary.withOpacity(0.2), width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // صورة كبيرة للقماش
            Container(
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: cs.surfaceContainerHighest,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _isNetworkPath(selectedFabric['imageUrl'] ?? '')
                    ? CachedNetworkImage(
                        imageUrl: selectedFabric['imageUrl'] ?? '',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        memCacheWidth: 600,
                        memCacheHeight: 600,
                        placeholder: (context, url) => Container(
                          color: cs.surfaceContainerHighest,
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 3),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: cs.surfaceContainerHighest,
                          child: Icon(
                            Icons.image_not_supported,
                            size: 60,
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
                            Icons.image_not_supported,
                            size: 60,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),

            // الاسم والسعر
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedFabric['name'] ?? widget.selectedType,
                        style: tt.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ر.ع ${(selectedFabric['price'] ?? 0.0).toStringAsFixed(3)}',
                        style: tt.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: cs.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: cs.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check, color: cs.onPrimary),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // معلومات إضافية
            if (selectedFabric['type'] != null) ...[
              _DetailRow(
                icon: Icons.category,
                label: 'النوع',
                value: selectedFabric['type'],
                cs: cs,
                tt: tt,
              ),
              const SizedBox(height: 12),
            ],
            if (selectedFabric['season'] != null) ...[
              _DetailRow(
                icon: Icons.wb_sunny,
                label: 'الموسم',
                value: selectedFabric['season'],
                cs: cs,
                tt: tt,
              ),
              const SizedBox(height: 12),
            ],
            if (selectedFabric['quality'] != null) ...[
              _DetailRow(
                icon: Icons.workspace_premium,
                label: 'الجودة',
                value: selectedFabric['quality'],
                cs: cs,
                tt: tt,
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.square_foot, size: 18, color: cs.primary),
                const SizedBox(width: 8),
                Text(
                  'الوحدة: متر',
                  style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
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
}

/* ===================== خطوة اللون ===================== */
class _ColorStep extends StatelessWidget {
  final String fabricId;
  final Color? selected;
  final double shadeFactor;
  final ValueChanged<Color> onColorChanged;
  final ValueChanged<double> onShadeChanged;
  final Color? previewColor;

  const _ColorStep({
    required this.fabricId,
    required this.selected,
    required this.shadeFactor,
    required this.onColorChanged,
    required this.onShadeChanged,
    required this.previewColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'اختر لون القماش',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // لوحة الألوان من Firebase
          StreamBuilder<Map<String, dynamic>?>(
            stream: Stream.fromFuture(FabricService.getFabricById(fabricId)),
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

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: availableColors.map((colorData) {
                    final colorHex =
                        colorData['colorHex'] as String? ?? '#FFFFFF';

                    // تحويل hex إلى Color
                    Color color;
                    try {
                      color =
                          Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
                    } catch (e) {
                      color = Colors.white;
                    }

                    final sel =
                        selected != null && selected!.value == color.value;
                    return GestureDetector(
                      onTap: () => onColorChanged(color),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color,
                          border: Border.all(
                            color: sel ? _brand : Colors.grey[300]!,
                            width: sel ? 3 : 2,
                          ),
                        ),
                        child: sel
                            ? const Icon(Icons.check, color: Colors.white)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ],
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
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

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(widget.label,
                style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 12),

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

/// صف تفصيلي للمعلومات
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ColorScheme cs;
  final TextTheme tt;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.cs,
    required this.tt,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: cs.onPrimaryContainer),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: tt.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: tt.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
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

/// نموذج القماش
class FabricItem {
  final String title; // مثل: صيفي، شتوي، فاخر...
  final String image; // مسار asset أو رابط
  final String? tag; // شارة اختيارية
  const FabricItem(this.title, this.image, {this.tag});
}
