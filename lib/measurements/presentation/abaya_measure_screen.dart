import 'package:flutter/material.dart';
import '../../features/catalog/models/abaya_item.dart';

const _kGuideAsset = 'assets/abaya/abaya_guide.jpeg';
const _brand = Color(0xFF6D4C41);

/// نموذج المقاسات: الطول، طول الكم، العرض + ملاحظات
class AbayaMeasurements {
  final double length; // الطول
  final double sleeve; // طول الكم
  final double width; // العرض
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
  final _widthC = TextEditingController();
  final _notesC = TextEditingController();

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
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // معلومات المنتج
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            widget.item.imageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey[300],
                              child: const Icon(Icons.error),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.item.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.item.subtitle,
                                style: TextStyle(
                                  color: cs.onSurfaceVariant,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${widget.item.price} ر.ع',
                                style: const TextStyle(
                                  color: _brand,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // دليل القياس
                  const MeasurementGuideCard(imageSrc: _kGuideAsset),
                  const SizedBox(height: 16),

                  // حقول المقاسات
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'المقاسات الأساسية',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _numField(context, 'الطول (سم)', _lengthC, 'مثال: 138'),
                        const SizedBox(height: 12),
                        _numField(
                            context, 'طول الكم (سم)', _sleeveC, 'مثال: 58'),
                        const SizedBox(height: 12),
                        _numField(context, 'العرض (سم)', _widthC, 'مثال: 60'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ملاحظات
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ملاحظات إضافية (اختياري)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _notesC,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'مثال: أريدها واسعة قليلًا',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: cs.surface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
        // زر التأكيد
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(16),
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
          child: SafeArea(
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _brand,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'تأكيد المقاسات ومتابعة الطلب',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _numField(
      BuildContext ctx, String label, TextEditingController c, String hint) {
    final cs = Theme.of(ctx).colorScheme;
    return TextFormField(
      controller: c,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: cs.surface,
      ),
      validator: (v) {
        final n = _toNum(c);
        if (n <= 0) return 'يرجى إدخال قيمة صحيحة';
        return null;
      },
    );
  }
}

/// بطاقة دليل القياس
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'دليل القياس',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),

          // أزرار الاختيار
          Row(
            children: [
              Expanded(child: _chip('الطول', 0)),
              const SizedBox(width: 8),
              Expanded(child: _chip('الكم', 1)),
              const SizedBox(width: 8),
              Expanded(child: _chip('العرض', 2)),
            ],
          ),
          const SizedBox(height: 12),

          // الصورة
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              widget.imageSrc,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
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
          const SizedBox(height: 12),

          // وصف المقاس
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _tip,
              style: TextStyle(
                fontWeight: FontWeight.w600,
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
    return GestureDetector(
      onTap: () => setState(() => _selected = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? _brand : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: selected ? _brand : Colors.grey[400]!,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
