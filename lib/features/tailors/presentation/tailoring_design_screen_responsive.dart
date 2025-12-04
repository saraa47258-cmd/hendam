import 'package:flutter/material.dart';
import '../models/fabric_item.dart';
import '../../../core/styles/responsive.dart';
import '../../../core/styles/dimens.dart';

bool _isNetworkPath(String p) =>
    p.startsWith('http://') || p.startsWith('https://');

/// ===== وحدات القياس =====
enum MeasurementUnit { cm, inch }

extension MeasurementUnitX on MeasurementUnit {
  String get labelAr => this == MeasurementUnit.cm ? 'سم' : 'إنش';
  String get labelEn => this == MeasurementUnit.cm ? 'cm' : 'in';
}

const Color _brand = Color(0xFF6D4C41);

/// شاشة تفصيل الثوب - متجاوبة مع جميع الأجهزة
class TailoringDesignScreen extends StatefulWidget {
  final String tailorId;
  final String tailorName;
  final double basePriceOMR;
  final List<FabricItem>? fabrics;

  const TailoringDesignScreen({
    super.key,
    required this.tailorId,
    required this.tailorName,
    this.basePriceOMR = 6.0,
    this.fabrics,
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

  // ==== اللون ====
  final List<Color> _palette = const [
    Color(0xFFFAFAFA),
    Color(0xFFEEEEEE),
    Color(0xFFE0E0E0),
    Color(0xFFB0BEC5),
    Color(0xFF90CAF9),
    Color(0xFF80DEEA),
    Color(0xFFC8E6C9),
    Color(0xFFFFF59D),
    Color(0xFFFFCC80),
    Color(0xFFBCAAA4),
  ];
  Color? _fabricColor;
  double _shadeFactor = 1.0; // 0.8..1.2

  // ==== التطريز ====
  Color _embroideryColor = const Color(0xFF795548);
  bool _addNameEmbroidery = false;
  int _embroideryLines = 0; // 0..3

  // ==== الوحدات ====
  MeasurementUnit _unit = MeasurementUnit.cm; // افتراضيًا سم

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
    final base = _fabricColor ?? _brand;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        base,
        base.withOpacity(0.8),
        _brand,
      ],
    );
  }

  @override
  void dispose() {
    _lengthCtrl.dispose();
    _shoulderCtrl.dispose();
    _sleeveCtrl.dispose();
    _upperSleeveCtrl.dispose();
    _lowerSleeveCtrl.dispose();
    _chestCtrl.dispose();
    _waistCtrl.dispose();
    _neckCtrl.dispose();
    _embroideryCtrl.dispose();
    _notesCtrl.dispose();
    _pager.dispose();
    super.dispose();
  }

  // ==== معالجات التنقل ====
  void _nextStep() {
    if (_step < 3) {
      setState(() => _step++);
      _pager.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevStep() {
    if (_step > 0) {
      setState(() => _step--);
      _pager.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _submitOrder() {
    if (!_formKey.currentState!.validate()) return;

    // منطق إرسال الطلب
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تم إرسال الطلب'),
        content: const Text('سيتم التواصل معك قريباً لتأكيد التفاصيل'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // تهيئة الأبعاد المتجاوبة
    AppDimens.init(context);

    final isTablet = context.isTablet;
    final isDesktop = context.isDesktop;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: cs.surface,
        body: SafeArea(
          child: Column(
            children: [
              // ===== الهيدر المتجاوب =====
              Container(
                padding: EdgeInsets.fromLTRB(
                  16,
                  14,
                  16,
                  isTablet ? 20 : 16,
                ),
                decoration: BoxDecoration(
                  gradient: _headerGradient,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(18),
                  ),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isDesktop ? 1200 : 840,
                    ),
                    child: Row(
                      children: [
                        // أيقونة الخياط
                        Container(
                          width: isTablet ? 64 : 56,
                          height: isTablet ? 64 : 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(.5),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(.08),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: CircleAvatar(
                            backgroundColor: Colors.white24,
                            child: Icon(
                              Icons.content_cut,
                              color: Colors.white,
                              size: isTablet ? 30 : 26,
                            ),
                          ),
                        ),
                        SizedBox(width: isTablet ? 16 : 12),

                        // معلومات الخياط
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.tailorName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: isTablet ? 24 : 20,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: isTablet ? 18 : 16,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      'مسقط',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(.9),
                                        fontSize: isTablet ? 16 : 14,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),

                        // زر الإغلاق
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: isTablet ? 28 : 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ===== شريط التقدّم المتجاوب =====
              Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  isTablet ? 16 : 12,
                  16,
                  8,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isDesktop ? 1200 : 840,
                    ),
                    child: _ResponsiveStepperHeader(
                      current: _step,
                      labels: const ['القماش', 'اللون', 'المقاسات', 'التطريز'],
                      isTablet: isTablet,
                    ),
                  ),
                ),
              ),

              // ===== الصفحات المتجاوبة =====
              Expanded(
                child: PageView(
                  controller: _pager,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _FabricStep(
                      items: widget.fabrics,
                      selectedType: _fabricType,
                      onTypeChanged: (v, thumb) => setState(() {
                        _fabricType = v;
                      }),
                      isTablet: isTablet,
                    ),
                    _ColorStep(
                      palette: _palette,
                      selected: _fabricColor,
                      shadeFactor: _shadeFactor,
                      onColorChanged: (c) => setState(() => _fabricColor = c),
                      onShadeChanged: (f) => setState(() => _shadeFactor = f),
                      previewColor: _fabricColor == null
                          ? null
                          : _applyShade(_fabricColor!, _shadeFactor),
                      isTablet: isTablet,
                    ),
                    _MenMeasurementsStep(
                      formKey: _formKey,
                      unit: _unit,
                      onUnitChanged: (u) => setState(() => _unit = u),
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
                      isTablet: isTablet,
                    ),
                    _EmbroideryStep(
                      color: _embroideryColor,
                      addName: _addNameEmbroidery,
                      lines: _embroideryLines,
                      onColorChanged: (c) =>
                          setState(() => _embroideryColor = c),
                      onAddNameChanged: (b) =>
                          setState(() => _addNameEmbroidery = b),
                      onLinesChanged: (i) =>
                          setState(() => _embroideryLines = i),
                      isTablet: isTablet,
                    ),
                  ],
                ),
              ),

              // ===== شريط التنقل السفلي المتجاوب =====
              Container(
                padding: EdgeInsets.all(isTablet ? 20 : 16),
                decoration: BoxDecoration(
                  color: cs.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.1),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isDesktop ? 1200 : 840,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // السعر
                        Container(
                          padding: EdgeInsets.all(isTablet ? 16 : 12),
                          decoration: BoxDecoration(
                            color: _brand.withOpacity(.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.price_check_rounded,
                                color: _brand,
                                size: isTablet ? 24 : 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'التكلفة التقديرية: ${_price.toStringAsFixed(3)} ر.ع',
                                style: TextStyle(
                                  color: _brand,
                                  fontWeight: FontWeight.bold,
                                  fontSize: isTablet ? 18 : 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // أزرار التنقل
                        Row(
                          children: [
                            // زر السابق
                            if (_step > 0)
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _prevStep,
                                  icon: const Icon(Icons.arrow_forward_rounded),
                                  label: const Text('السابق'),
                                  style: OutlinedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                      vertical: isTablet ? 16 : 12,
                                    ),
                                    side: const BorderSide(color: _brand),
                                    foregroundColor: _brand,
                                  ),
                                ),
                              ),
                            if (_step > 0) const SizedBox(width: 12),

                            // زر التالي أو إرسال
                            Expanded(
                              flex: _step > 0 ? 1 : 2,
                              child: ElevatedButton.icon(
                                onPressed: _step < 3 ? _nextStep : _submitOrder,
                                icon: Icon(
                                  _step < 3
                                      ? Icons.arrow_back_rounded
                                      : Icons.send_rounded,
                                ),
                                label:
                                    Text(_step < 3 ? 'التالي' : 'إرسال الطلب'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _brand,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    vertical: isTablet ? 16 : 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
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
  }

  Color _applyShade(Color base, double factor) {
    return Color.fromARGB(
      base.alpha,
      (base.red * factor).clamp(0, 255).round(),
      (base.green * factor).clamp(0, 255).round(),
      (base.blue * factor).clamp(0, 255).round(),
    );
  }
}

/// شريط التقدّم المتجاوب
class _ResponsiveStepperHeader extends StatelessWidget {
  final int current;
  final List<String> labels;
  final bool isTablet;

  const _ResponsiveStepperHeader({
    required this.current,
    required this.labels,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: List.generate(labels.length, (index) {
        final isCompleted = index < current;
        final isCurrent = index == current;

        return Expanded(
          child: Row(
            children: [
              // الرقم
              Container(
                width: isTablet ? 40 : 32,
                height: isTablet ? 40 : 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted || isCurrent
                      ? _brand
                      : cs.surfaceContainerHighest,
                ),
                child: Center(
                  child: isCompleted
                      ? Icon(
                          Icons.check,
                          color: Colors.white,
                          size: isTablet ? 20 : 16,
                        )
                      : Text(
                          '${index + 1}',
                          style: TextStyle(
                            color:
                                isCurrent ? Colors.white : cs.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                            fontSize: isTablet ? 16 : 14,
                          ),
                        ),
                ),
              ),

              // الخط
              if (index < labels.length - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: EdgeInsets.symmetric(horizontal: isTablet ? 8 : 4),
                    decoration: BoxDecoration(
                      color:
                          index < current ? _brand : cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

/// خطوة القماش المتجاوبة
class _FabricStep extends StatelessWidget {
  final List<FabricItem>? items;
  final String? selectedType;
  final Function(String, String) onTypeChanged;
  final bool isTablet;

  const _FabricStep({
    required this.items,
    required this.selectedType,
    required this.onTypeChanged,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isTablet ? 800 : 600,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'اختر نوع القماش',
                style: TextStyle(
                  fontSize: isTablet ? 24 : 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: isTablet ? 24 : 16),

              // قائمة الأقمشة
              if (items != null && items!.isNotEmpty)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isTablet ? 3 : 2,
                    crossAxisSpacing: isTablet ? 20 : 12,
                    mainAxisSpacing: isTablet ? 20 : 12,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: items!.length,
                  itemBuilder: (context, index) {
                    final item = items![index];
                    final isSelected = selectedType == item.name;

                    return GestureDetector(
                      onTap: () => onTypeChanged(item.name, item.imageUrl),
                      child: Container(
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? _brand : cs.outlineVariant,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                                child: _isNetworkPath(item.imageUrl)
                                    ? Image.network(
                                        item.imageUrl,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        errorBuilder: (_, __, ___) => Container(
                                          color: Colors.grey[300],
                                          child: const Icon(Icons.error),
                                        ),
                                      )
                                    : Image.asset(
                                        item.imageUrl,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        errorBuilder: (_, __, ___) => Container(
                                          color: Colors.grey[300],
                                          child: const Icon(Icons.error),
                                        ),
                                      ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(isTablet ? 12 : 8),
                              child: Text(
                                item.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: isTablet ? 16 : 14,
                                  color: isSelected ? _brand : cs.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
              else
                Container(
                  padding: EdgeInsets.all(isTablet ? 40 : 24),
                  child: const Center(
                    child: Text('لا توجد أقمشة متاحة'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// خطوة اللون المتجاوبة
class _ColorStep extends StatelessWidget {
  final List<Color> palette;
  final Color? selected;
  final double shadeFactor;
  final ValueChanged<Color> onColorChanged;
  final ValueChanged<double> onShadeChanged;
  final Color? previewColor;
  final bool isTablet;

  const _ColorStep({
    required this.palette,
    required this.selected,
    required this.shadeFactor,
    required this.onColorChanged,
    required this.onShadeChanged,
    required this.previewColor,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isTablet ? 800 : 600,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'اختر لون القماش',
                style: TextStyle(
                  fontSize: isTablet ? 24 : 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: isTablet ? 24 : 16),

              // لوحة الألوان
              Container(
                padding: EdgeInsets.all(isTablet ? 20 : 16),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isTablet ? 5 : 4,
                    crossAxisSpacing: isTablet ? 16 : 12,
                    mainAxisSpacing: isTablet ? 16 : 12,
                    childAspectRatio: 1,
                  ),
                  itemCount: palette.length,
                  itemBuilder: (context, index) {
                    final color = palette[index];
                    final isSelected = selected?.value == color.value;

                    return GestureDetector(
                      onTap: () => onColorChanged(color),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color,
                          border: Border.all(
                            color: isSelected ? _brand : Colors.grey[300]!,
                            width: isSelected ? 3 : 2,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white)
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// خطوة المقاسات المتجاوبة
class _MenMeasurementsStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final MeasurementUnit unit;
  final ValueChanged<MeasurementUnit> onUnitChanged;
  final TextEditingController lengthCtrl;
  final TextEditingController shoulderCtrl;
  final TextEditingController sleeveCtrl;
  final TextEditingController upperSleeveCtrl;
  final TextEditingController lowerSleeveCtrl;
  final TextEditingController chestCtrl;
  final TextEditingController waistCtrl;
  final TextEditingController neckCtrl;
  final TextEditingController embroideryCtrl;
  final TextEditingController notesCtrl;
  final bool isTablet;

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
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Form(
      key: formKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isTablet ? 24 : 16),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isTablet ? 800 : 600,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // عنوان الوحدة
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'المقاسات',
                      style: TextStyle(
                        fontSize: isTablet ? 24 : 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // تبديل الوحدة
                    Container(
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildUnitButton('سم', MeasurementUnit.cm),
                          _buildUnitButton('إنش', MeasurementUnit.inch),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isTablet ? 24 : 16),

                // حقول المقاسات
                _buildMeasurementsGrid(),
                SizedBox(height: isTablet ? 24 : 16),

                // ملاحظات
                Text(
                  'ملاحظات إضافية (اختياري)',
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: isTablet ? 12 : 8),
                TextFormField(
                  controller: notesCtrl,
                  maxLines: isTablet ? 4 : 3,
                  decoration: InputDecoration(
                    hintText: 'مثال: أريدها واسعة قليلًا...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: cs.surfaceContainerHighest,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUnitButton(String label, MeasurementUnit unitType) {
    final isSelected = unit == unitType;

    return GestureDetector(
      onTap: () => onUnitChanged(unitType),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 16 : 12,
          vertical: isTablet ? 8 : 6,
        ),
        decoration: BoxDecoration(
          color: isSelected ? _brand : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : _brand,
            fontWeight: FontWeight.bold,
            fontSize: isTablet ? 16 : 14,
          ),
        ),
      ),
    );
  }

  Widget _buildMeasurementInput({
    required TextEditingController controller,
    required MeasurementUnit unit,
    required bool isTablet,
    required BuildContext context,
  }) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      height: isTablet ? 60 : 56,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // زر النقصان
          _buildControlButton(
            icon: Icons.remove_rounded,
            onTap: () => _decrementValue(controller, unit),
            isTablet: isTablet,
            cs: cs,
          ),

          // حقل الإدخال - مساحة أكبر بكثير
          Expanded(
            child: Container(
              height: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: isTablet ? 12 : 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: TextFormField(
                  controller: controller,
                  textAlign: TextAlign.center,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: TextStyle(
                    fontSize: isTablet ? 24 : 22,
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                    height: 1.0,
                    letterSpacing: 0.5,
                  ),
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: TextStyle(
                      color: cs.onSurfaceVariant.withOpacity(0.4),
                      fontSize: isTablet ? 22 : 20,
                      fontWeight: FontWeight.w700,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 16 : 12,
                      vertical: isTablet ? 12 : 10,
                    ),
                    isDense: false,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'مطلوب';
                    }
                    final num = double.tryParse(value);
                    if (num == null || num <= 0) {
                      return 'قيمة غير صحيحة';
                    }
                    return null;
                  },
                ),
              ),
            ),
          ),

          // زر الزيادة
          _buildControlButton(
            icon: Icons.add_rounded,
            onTap: () => _incrementValue(controller, unit),
            isTablet: isTablet,
            cs: cs,
          ),

          // زر الوحدة
          Container(
            width: isTablet ? 60 : 55,
            height: double.infinity,
            margin: EdgeInsets.all(isTablet ? 8 : 6),
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: cs.primaryContainer.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                unit.labelAr,
                style: TextStyle(
                  color: cs.onPrimaryContainer,
                  fontWeight: FontWeight.w800,
                  fontSize: isTablet ? 16 : 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isTablet,
    required ColorScheme cs,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isTablet ? 44 : 40,
        height: double.infinity,
        margin: EdgeInsets.all(isTablet ? 8 : 6),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: cs.onSurfaceVariant,
          size: isTablet ? 22 : 20,
        ),
      ),
    );
  }

  void _incrementValue(TextEditingController controller, MeasurementUnit unit) {
    final currentValue = double.tryParse(controller.text) ?? 0.0;
    final step = unit == MeasurementUnit.cm ? 0.5 : 0.25;
    final newValue = currentValue + step;

    // تنسيق الأرقام بناءً على الوحدة
    if (unit == MeasurementUnit.cm) {
      controller.text = newValue.toStringAsFixed(newValue % 1 == 0 ? 0 : 1);
    } else {
      controller.text = newValue.toStringAsFixed(2);
    }
  }

  void _decrementValue(TextEditingController controller, MeasurementUnit unit) {
    final currentValue = double.tryParse(controller.text) ?? 0.0;
    final step = unit == MeasurementUnit.cm ? 0.5 : 0.25;
    final newValue = (currentValue - step).clamp(0.0, double.infinity);

    // تنسيق الأرقام بناءً على الوحدة
    if (unit == MeasurementUnit.cm) {
      controller.text = newValue.toStringAsFixed(newValue % 1 == 0 ? 0 : 1);
    } else {
      controller.text = newValue.toStringAsFixed(2);
    }
  }

  Widget _buildMeasurementsGrid() {
    final measurements = [
      ('الطول الكلي', lengthCtrl, Icons.height),
      ('الكتف', shoulderCtrl, Icons.straighten),
      ('طول الكم', sleeveCtrl, Icons.rule_rounded),
      ('محيط الكم العلوي', upperSleeveCtrl, Icons.fitness_center),
      ('محيط الكم السفلي', lowerSleeveCtrl, Icons.watch),
      ('الصدر', chestCtrl, Icons.accessibility_new),
      ('الخصر', waistCtrl, Icons.straighten),
      ('محيط الرقبة', neckCtrl, Icons.accessibility),
      ('التطريز الامامي', embroideryCtrl, Icons.straighten),
    ];

    return Builder(
      builder: (context) => Column(
        children: measurements.map((measurement) {
          final (label, controller, icon) = measurement;

          return Container(
            margin: EdgeInsets.only(bottom: isTablet ? 16 : 12),
            child: Row(
              children: [
                // العنوان
                Expanded(
                  flex: 2,
                  child: Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: isTablet ? 16 : 14,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),

                // حقل الإدخال
                Expanded(
                  flex: 3,
                  child: _buildMeasurementInput(
                    controller: controller,
                    unit: unit,
                    isTablet: isTablet,
                    context: context,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// خطوة التطريز المتجاوبة
class _EmbroideryStep extends StatelessWidget {
  final Color color;
  final bool addName;
  final int lines;
  final ValueChanged<Color> onColorChanged;
  final ValueChanged<bool> onAddNameChanged;
  final ValueChanged<int> onLinesChanged;
  final bool isTablet;

  const _EmbroideryStep({
    required this.color,
    required this.addName,
    required this.lines,
    required this.onColorChanged,
    required this.onAddNameChanged,
    required this.onLinesChanged,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isTablet ? 800 : 600,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'خيارات التطريز',
                style: TextStyle(
                  fontSize: isTablet ? 24 : 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: isTablet ? 24 : 16),

              // لون التطريز
              Container(
                padding: EdgeInsets.all(isTablet ? 20 : 16),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'لون التطريز',
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: isTablet ? 16 : 12),
                    Wrap(
                      spacing: isTablet ? 16 : 12,
                      runSpacing: isTablet ? 16 : 12,
                      children: [
                        _buildColorOption(const Color(0xFF795548), 'بني'),
                        _buildColorOption(const Color(0xFF000000), 'أسود'),
                        _buildColorOption(const Color(0xFFFFFFFF), 'أبيض'),
                        _buildColorOption(const Color(0xFFFF0000), 'أحمر'),
                        _buildColorOption(const Color(0xFF0000FF), 'أزرق'),
                        _buildColorOption(const Color(0xFF00FF00), 'أخضر'),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: isTablet ? 24 : 16),

              // خيارات إضافية
              Container(
                padding: EdgeInsets.all(isTablet ? 20 : 16),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    // إضافة الاسم
                    SwitchListTile(
                      title: Text(
                        'إضافة الاسم',
                        style: TextStyle(
                          fontSize: isTablet ? 16 : 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: const Text('تطريز الاسم على الثوب'),
                      value: addName,
                      onChanged: onAddNameChanged,
                      activeThumbColor: _brand,
                    ),

                    const Divider(),

                    // عدد خطوط التطريز
                    ListTile(
                      title: Text(
                        'عدد خطوط التطريز',
                        style: TextStyle(
                          fontSize: isTablet ? 16 : 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: lines > 0
                                ? () => onLinesChanged(lines - 1)
                                : null,
                            icon: const Icon(Icons.remove),
                          ),
                          Text(
                            '$lines',
                            style: TextStyle(
                              fontSize: isTablet ? 18 : 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: lines < 3
                                ? () => onLinesChanged(lines + 1)
                                : null,
                            icon: const Icon(Icons.add),
                          ),
                        ],
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
  }

  Widget _buildColorOption(Color colorOption, String label) {
    final isSelected = color.value == colorOption.value;

    return GestureDetector(
      onTap: () => onColorChanged(colorOption),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 16 : 12,
          vertical: isTablet ? 8 : 6,
        ),
        decoration: BoxDecoration(
          color: isSelected ? _brand : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? _brand : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: isTablet ? 20 : 16,
              height: isTablet ? 20 : 16,
              decoration: BoxDecoration(
                color: colorOption,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[400]!),
              ),
            ),
            SizedBox(width: isTablet ? 8 : 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: isTablet ? 14 : 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
