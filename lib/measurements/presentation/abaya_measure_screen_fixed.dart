import 'package:flutter/material.dart';
import '../../features/catalog/models/abaya_item.dart';

const _kGuideAsset = 'assets/abaya/abaya_guide.jpeg';
const _brand = Color(0xFF6D4C41);
const _contentMaxWidth = 960.0;
const _gap = 12.0;

/// نموذج المقاسات: الطول، طول الكم، العرض + ملاحظات
class AbayaMeasurements {
  final double length;   // الطول
  final double sleeve;   // طول الكم
  final double width;    // العرض
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

/// شاشة أخذ المقاسات
class AbayaMeasureScreen extends StatefulWidget {
  final AbayaItem item;
  const AbayaMeasureScreen({super.key, required this.item});

  @override
  State<AbayaMeasureScreen> createState() => _AbayaMeasureScreenState();
}

class _AbayaMeasureScreenState extends State<AbayaMeasureScreen> {
  final _formKey = GlobalKey<FormState>();

  // الحقول
  final _lengthC = TextEditingController();
  final _sleeveC = TextEditingController();
  final _widthC  = TextEditingController();
  final _notesC  = TextEditingController();

  @override
  void dispose() {
    _lengthC.dispose();
    _sleeveC.dispose();
    _widthC.dispose();
    _notesC.dispose();
    super.dispose();
  }

  // ===== Helpers =====
  double _toNum(TextEditingController c) =>
      double.tryParse(c.text.trim().replaceAll(',', '.')) ?? 0;

  bool _isHttp(String s) => s.startsWith('http://') || s.startsWith('https://');

  /// يطبّع أي مسار أصول ليوافق assets/
  String _normalizeAsset(String path) {
    if (path.startsWith('lib/assets/')) {
      return path.replaceFirst('lib/', '');
    }
    if (!path.startsWith('assets/')) {
      return 'assets/$path';
    }
    return path;
  }

  Widget _buildImage(String src, {double? w, double? h, BoxFit fit = BoxFit.cover, BorderRadius? radius}) {
    final normalized = _normalizeAsset(src);
    
    if (_isHttp(normalized)) {
      return ClipRRect(
        borderRadius: radius ?? BorderRadius.zero,
        child: Image.network(
          normalized,
          width: w,
          height: h,
          fit: fit,
          loadingBuilder: (c, child, p) => p == null ? child : Container(
            width: w,
            height: h,
            color: Colors.grey[300],
            child: const Center(child: CircularProgressIndicator()),
          ),
          errorBuilder: (_, __, ___) => Container(
            width: w,
            height: h,
            color: Colors.grey[300],
            child: const Icon(Icons.error, color: Colors.grey),
          ),
        ),
      );
    }
    
    return ClipRRect(
      borderRadius: radius ?? BorderRadius.zero,
      child: Image.asset(
        normalized,
        width: w,
        height: h,
        fit: fit,
        errorBuilder: (_, __, ___) => Container(
          width: w,
          height: h,
          color: Colors.grey[300],
          child: const Icon(Icons.error, color: Colors.grey),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final m = AbayaMeasurements(
      length: _toNum(_lengthC),
      sleeve: _toNum(_sleeveC),
      width: _toNum(_widthC),
      notes: _notesC.text.trim(),
    );

    Navigator.pop(context, m);
  }

  // يحسب عدد الأعمدة حسب العرض (1/2/3)
  int _fieldColumns(double w) {
    if (w >= 1100) return 3;
    if (w >= 680)  return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: cs.surface,
        appBar: AppBar(
          title: const Text('مقاسات العباية'),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: _contentMaxWidth,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _ProductHeader(
                        item: widget.item,
                        buildImage: _buildImage,
                      ),
                      const SizedBox(height: 12),

                      // دليل القياس (ريسبونسف)
                      const MeasurementGuideCard(imageSrc: _kGuideAsset),

                      const SizedBox(height: 14),

                      // ===== المقاسات الأساسية =====
                      LayoutBuilder(builder: (ctx, inner) {
                        final cols = _fieldColumns(inner.maxWidth);
                        final fieldWidth = (inner.maxWidth - _gap * (cols - 1)) / cols;

                        return _SectionCard(
                          title: 'المقاسات الأساسية',
                          child: Wrap(
                            spacing: _gap,
                            runSpacing: _gap,
                            children: [
                              SizedBox(
                                width: fieldWidth,
                                child: _numField(
                                  context,
                                  'الطول',
                                  _lengthC,
                                  hint: 'مثال: 138',
                                  icon: Icons.height,
                                ),
                              ),
                              SizedBox(
                                width: fieldWidth,
                                child: _numField(
                                  context,
                                  'طول الكم',
                                  _sleeveC,
                                  hint: 'مثال: 58',
                                  icon: Icons.rule_rounded,
                                ),
                              ),
                              SizedBox(
                                width: fieldWidth,
                                child: _numField(
                                  context,
                                  'العرض',
                                  _widthC,
                                  hint: 'مثال: 60',
                                  icon: Icons.swap_horiz_rounded,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 14),

                      _SectionCard(
                        title: 'ملاحظات إضافية (اختياري)',
                        child: TextFormField(
                          controller: _notesC,
                          maxLines: 4,
                          decoration: _dec(
                            context,
                            'ملاحظات',
                            hint: 'مثال: أريدها واسعة قليلًا، وإضافة جيوب داخلية',
                            icon: Icons.edit_note_rounded,
                          ),
                        ),
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        // زر التأكيد
        bottomNavigationBar: SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            decoration: BoxDecoration(
              color: cs.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.06),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.check_circle_outline_rounded),
                label: const Text('تأكيد المقاسات ومتابعة الطلب'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _brand,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _dec(BuildContext ctx, String label, {String? hint, IconData? icon}) {
    final cs = Theme.of(ctx).colorScheme;
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon) : null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cs.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _brand, width: 2),
      ),
      filled: true,
      fillColor: cs.surfaceContainerHighest.withOpacity(0.5),
    );
  }

  Widget _numField(BuildContext ctx, String label, TextEditingController c, {String? hint, IconData? icon}) {
    return TextFormField(
      controller: c,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: _dec(ctx, label, hint: hint, icon: icon),
      validator: (v) {
        final n = _toNum(c);
        if (n <= 0) return 'يرجى إدخال قيمة صحيحة';
        return null;
      },
    );
  }
}

/// بطاقة رأس المنتج — تتكيّف مع الصورة والمسار
class _ProductHeader extends StatelessWidget {
  final AbayaItem item;
  final Widget Function(String src, {double? w, double? h, BoxFit fit, BorderRadius? radius}) buildImage;

  const _ProductHeader({required this.item, required this.buildImage});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.subtitle,
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${item.price} ر.ع',
                  style: const TextStyle(
                    color: _brand,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: buildImage(
              item.imageUrl,
              w: 80,
              h: 80,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}

/// كارت قسم موحّد
class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.w900, fontSize: 16)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

/// بطاقة دليل القياس بالصورة + نقاط تفاعلية + تكبير (ريسبونسف)
class MeasurementGuideCard extends StatefulWidget {
  final String imageSrc;
  const MeasurementGuideCard({super.key, required this.imageSrc});

  @override
  State<MeasurementGuideCard> createState() => _MeasurementGuideCardState();
}

class _MeasurementGuideCardState extends State<MeasurementGuideCard> {
  // 0 الطول — 1 الكم — 2 العرض
  int _selected = 0;

  String get _tip {
    switch (_selected) {
      case 0:
        return 'الطول: من أعلى الكتف حتى أسفل العباية.';
      case 1:
        return 'الكم: من بداية فتحة الرقبة مرورًا بالكتف حتى نهاية الكم.';
      default:
        return 'العرض: المسافة الأفقية بين الجانبين عند مستوى الصدر.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLandscape = MediaQuery.orientationOf(context) == Orientation.landscape;

    // غيّر الأسبكت حسب الاتجاه: مربع على الهاتف عمودي، أوسع أفقيًا
    final aspect = isLandscape ? (16 / 9) : 1.0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _chip('الطول', 0),
                    _chip('الكم', 1),
                    _chip('العرض', 2),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'تكبير الصورة',
                onPressed: _openZoom,
                icon: const Icon(Icons.open_in_full_rounded),
              ),
            ],
          ),
          const SizedBox(height: 10),

          AspectRatio(
            aspectRatio: aspect,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    widget.imageSrc,
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_not_supported,
                              size: 48,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'لم يتم العثور على الصورة',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                // النقاط التفاعلية
                Positioned(
                  left: 50,
                  top: 60,
                  child: _HotDot(
                    active: _selected == 0,
                    label: 'الطول',
                    color: const Color(0xFF6D4C41),
                    onTap: () => setState(() => _selected = 0),
                  ),
                ),
                Positioned(
                  left: 30,
                  top: 80,
                  child: _HotDot(
                    active: _selected == 1,
                    label: 'الكم',
                    color: const Color(0xFF2196F3),
                    onTap: () => setState(() => _selected = 1),
                  ),
                ),
                Positioned(
                  left: 70,
                  top: 70,
                  child: _HotDot(
                    active: _selected == 2,
                    label: 'العرض',
                    color: const Color(0xFF4CAF50),
                    onTap: () => setState(() => _selected = 2),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withOpacity(0.7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _tip,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, int index) {
    final selected = _selected == index;
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _selected = index),
      backgroundColor: Colors.transparent,
      selectedColor: _brand.withOpacity(0.2),
      checkmarkColor: _brand,
      labelStyle: TextStyle(
        color: selected ? _brand : Colors.black87,
        fontWeight: FontWeight.w700,
      ),
      side: BorderSide(
        color: selected ? _brand : Colors.grey[400]!,
        width: 1.5,
      ),
    );
  }

  void _openZoom() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: .8,
          minChildSize: .6,
          builder: (_, controller) {
            return Material(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('دليل القياس — تكبير',
                      style: TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  Expanded(
                    child: InteractiveViewer(
                      minScale: 1,
                      maxScale: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            widget.imageSrc,
                            fit: BoxFit.contain,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image_not_supported,
                                      size: 48,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'لم يتم العثور على الصورة',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w600,
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
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _HotDot extends StatelessWidget {
  final bool active;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _HotDot({
    required this.active,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active ? color : Colors.white,
          border: Border.all(color: color, width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: active
            ? const Icon(
                Icons.check,
                size: 16,
                color: Colors.white,
              )
            : null,
      ),
    );
  }
}
