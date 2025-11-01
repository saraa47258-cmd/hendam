import 'package:flutter/material.dart';

class TailorAlterDishdashaScreen extends StatefulWidget {
  final String tailorId;
  final String tailorName;
  final String? imageUrl;
  final double basePriceOMR; // سعر قاعدة للتعديل البسيط
  final String? serviceTitle; // مثلاً: "تقصير/إطالة" إن جئت من بطاقة محددة

  const TailorAlterDishdashaScreen({
    super.key,
    required this.tailorId,
    required this.tailorName,
    this.imageUrl,
    this.basePriceOMR = 1.500,
    this.serviceTitle,
  });

  @override
  State<TailorAlterDishdashaScreen> createState() => _TailorAlterDishdashaScreenState();
}

class _TailorAlterDishdashaScreenState extends State<TailorAlterDishdashaScreen> {
  final _formKey = GlobalKey<FormState>();

  // حقول أساسية
  final _sizeCtrl = TextEditingController();
  final _lengthCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  // خيارات
  String _fabric = 'قماش من العميل';
  bool _pickup = false;   // استلام/تسليم
  bool _urgent = false;   // مستعجل

  // حزم تعديلات (Chip)
  final Map<String, (bool selected, double price)> _options = {
    'تقصير/إطالة': (false, 0.500),
    'توسيع/تضييق': (false, 0.500),
    'تعديل الأكمام': (false, 0.300),
    'تغيير الياقة': (false, 0.400),
    'تركيب أزرار': (false, 0.200),
    'تصغير الفتحة': (false, 0.300),
  };

  double get _total {
    double t = widget.basePriceOMR;
    _options.forEach((_, v) {
      if (v.$1) t += v.$2;
    });
    if (_pickup) t += 0.300; // خدمة استلام/تسليم
    if (_urgent) t += 0.400; // مستعجل
    if (_fabric == 'قماش من المتجر') t += 0.200; // فرق قماش من المتجر (إن لزم)
    return t;
  }

  @override
  void dispose() {
    _sizeCtrl.dispose();
    _lengthCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: cs.surface,
        appBar: AppBar(
          title: const Text('تعديل الدشداشة'),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
              children: [
                // بطاقة الخياط صغيرة
                _TailorHeader(tailorId: widget.tailorId, tailorName: widget.tailorName, imageUrl: widget.imageUrl),

                if (widget.serviceTitle != null) ...[
                  const SizedBox(height: 12),
                  _InfoTile(
                    icon: Icons.edit_note_rounded,
                    title: 'الخدمة المختارة',
                    subtitle: widget.serviceTitle!,
                  ),
                ],

                const SizedBox(height: 12),
                Text('المقاسات', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _TextField(
                        controller: _sizeCtrl,
                        label: 'المقاس (مثال: 54)',
                        type: TextInputType.number,
                        validator: (v) => v == null || v.trim().isEmpty ? 'أدخل المقاس' : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _TextField(
                        controller: _lengthCtrl,
                        label: 'الطول (سم)',
                        type: TextInputType.number,
                        validator: (v) => v == null || v.trim().isEmpty ? 'أدخل الطول' : null,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                Text('نوع القماش', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _fabric,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'اختر نوع القماش',
                  ),
                  items: const [
                    DropdownMenuItem(value: 'قماش من العميل', child: Text('قماش من العميل')),
                    DropdownMenuItem(value: 'قماش من المتجر', child: Text('قماش من المتجر')),
                  ],
                  onChanged: (v) => setState(() => _fabric = v ?? _fabric),
                ),

                const SizedBox(height: 16),
                Text('التعديلات المطلوبة', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _options.entries.map((e) {
                    final selected = e.value.$1;
                    final price = e.value.$2;
                    return FilterChip(
                      label: Text('${e.key} (+${price.toStringAsFixed(3)} ر.ع)'),
                      selected: selected,
                      onSelected: (v) => setState(() => _options[e.key] = (v, price)),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),
                Text('خيارات إضافية', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                SwitchListTile.adaptive(
                  value: _pickup,
                  onChanged: (v) => setState(() => _pickup = v),
                  title: const Text('استلام/تسليم'),
                  subtitle: const Text('خدمة توصيل تزيد السعر (+0.300 ر.ع)'),
                  contentPadding: EdgeInsets.zero,
                ),
                SwitchListTile.adaptive(
                  value: _urgent,
                  onChanged: (v) => setState(() => _urgent = v),
                  title: const Text('مستعجل'),
                  subtitle: const Text('تسليم أسرع يزيد السعر (+0.400 ر.ع)'),
                  contentPadding: EdgeInsets.zero,
                ),

                const SizedBox(height: 16),
                Text('ملاحظات للخياط', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                _TextField(
                  controller: _notesCtrl,
                  label: 'مثال: تقصير 3 سم من الأكمام، وتضييق من الخصر',
                  minLines: 3,
                  maxLines: 5,
                ),

                const SizedBox(height: 16),
                _SummaryCard(base: widget.basePriceOMR, total: _total),
              ],
            ),
          ),
        ),

        // زر تأكيد ثابت بأسفل الصفحة
        bottomSheet: Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            decoration: BoxDecoration(
              color: cs.surface,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(.08), blurRadius: 10, offset: const Offset(0, -2))],
            ),
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: SafeArea(
              top: false,
              child: FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.check_rounded),
                label: Text('تأكيد الطلب — ر.ع ${_total.toStringAsFixed(3)}'),
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // هنا ترسل الطلب لـ API / فايربيس...
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم إرسال طلب تعديل الدشداشة بنجاح')),
    );
    Navigator.pop(context);
  }
}

/* -------------------------- Widgets مساعدة -------------------------- */

class _TailorHeader extends StatelessWidget {
  final String tailorId;
  final String tailorName;
  final String? imageUrl;

  const _TailorHeader({
    required this.tailorId,
    required this.tailorName,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 60,
              height: 60,
              child: imageUrl == null
                  ? Container(
                color: cs.surface,
                alignment: Alignment.center,
                child: Icon(Icons.store_rounded, color: cs.onSurfaceVariant),
              )
                  : Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: cs.surface,
                  alignment: Alignment.center,
                  child: Icon(Icons.store_rounded, color: cs.onSurfaceVariant),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tailorName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 16),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'مسقط',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (true) // دائماً نعرض التقييم
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(.15),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star_rate_rounded, color: Color(0xFFFFA000), size: 18),
                  const SizedBox(width: 2),
                  Text(
                    '4.8',
                    style: tt.labelLarge?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoTile({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: cs.primary.withOpacity(.12),
            child: Icon(icon, color: cs.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(subtitle, style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final double base;
  final double total;
  const _SummaryCard({required this.base, required this.total});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ملخص السعر', style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                Text('السعر الأساسي: ر.ع ${base.toStringAsFixed(3)}',
                    style: tt.bodyMedium?.copyWith(color: cs.onSurface)),
                Text('الإجمالي: ر.ع ${total.toStringAsFixed(3)}',
                    style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          const Icon(Icons.receipt_long_rounded),
        ],
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? type;
  final int? minLines;
  final int? maxLines;
  final String? Function(String?)? validator;

  const _TextField({
    required this.controller,
    required this.label,
    this.type,
    this.minLines,
    this.maxLines,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      minLines: minLines,
      maxLines: maxLines ?? 1,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: validator,
    );
  }
}
