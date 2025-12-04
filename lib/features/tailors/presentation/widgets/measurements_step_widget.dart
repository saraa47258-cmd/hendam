import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'interactive_body_map.dart' show InteractiveBodyMap, MeasurementUnit;
import '../../../measurements/services/measurement_service.dart';
import '../../../measurements/models/measurement_profile.dart';

// MeasurementUnit is imported from interactive_body_map.dart

const double _cmPerInch = 2.54;

/// Measurements Step Widget with Interactive Body Map & Slivers
class MeasurementsStepWidget extends StatefulWidget {
  final String fabricId;
  final GlobalKey<FormState> formKey;
  final MeasurementUnit unit;
  final ValueChanged<MeasurementUnit> onUnitChanged;
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

  const MeasurementsStepWidget({
    super.key,
    required this.fabricId,
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
  State<MeasurementsStepWidget> createState() => _MeasurementsStepWidgetState();
}

class _MeasurementsStepWidgetState extends State<MeasurementsStepWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool _showBodyMap = true;
  Map<String, double?> _bodyMapMeasurements = {};

  @override
  void initState() {
    super.initState();
    _syncControllersToBodyMap();
  }

  void _syncControllersToBodyMap() {
    setState(() {
      _bodyMapMeasurements = {
        'neck': double.tryParse(widget.neckCtrl.text),
        'shoulder': double.tryParse(widget.shoulderCtrl.text),
        'chest': double.tryParse(widget.chestCtrl.text),
        'waist': double.tryParse(widget.waistCtrl.text),
        'sleeve': double.tryParse(widget.sleeveCtrl.text),
        'upperSleeve': double.tryParse(widget.upperSleeveCtrl.text),
        'lowerSleeve': double.tryParse(widget.lowerSleeveCtrl.text),
        'length': double.tryParse(widget.lengthCtrl.text),
      };
    });
  }

  void _onBodyMapMeasurementChanged(Map<String, double?> measurements) {
    setState(() {
      _bodyMapMeasurements = measurements;
    });

    // تحديث Controllers
    widget.neckCtrl.text = measurements['neck']?.toStringAsFixed(1) ?? '';
    widget.shoulderCtrl.text = measurements['shoulder']?.toStringAsFixed(1) ?? '';
    widget.chestCtrl.text = measurements['chest']?.toStringAsFixed(1) ?? '';
    widget.waistCtrl.text = measurements['waist']?.toStringAsFixed(1) ?? '';
    widget.sleeveCtrl.text = measurements['sleeve']?.toStringAsFixed(1) ?? '';
    widget.upperSleeveCtrl.text = measurements['upperSleeve']?.toStringAsFixed(1) ?? '';
    widget.lowerSleeveCtrl.text = measurements['lowerSleeve']?.toStringAsFixed(1) ?? '';
    widget.lengthCtrl.text = measurements['length']?.toStringAsFixed(1) ?? '';
  }

  double toUnit(double cm) =>
      widget.unit == MeasurementUnit.inch ? cm / _cmPerInch : cm;
  double fromUnit(double value) =>
      widget.unit == MeasurementUnit.inch ? value * _cmPerInch : value;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final decimals = widget.unit == MeasurementUnit.inch ? 2 : 1;

    return CustomScrollView(
      slivers: [
        // Header Sliver
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'المقاسات واللون',
                        style: tt.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SegmentedButton<MeasurementUnit>(
                      segments: const [
                        ButtonSegment(
                          value: MeasurementUnit.cm,
                          label: Text('سم'),
                        ),
                        ButtonSegment(
                          value: MeasurementUnit.inch,
                          label: Text('إنش'),
                        ),
                      ],
                      selected: {widget.unit},
                      onSelectionChanged: (Set<MeasurementUnit> newSelection) {
                        widget.onUnitChanged(newSelection.first);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Toggle Button for Body Map
                FilledButton.tonalIcon(
                  onPressed: () {
                    setState(() {
                      _showBodyMap = !_showBodyMap;
                    });
                    HapticFeedback.lightImpact();
                  },
                  icon: Icon(_showBodyMap ? Icons.list : Icons.accessibility_new),
                  label: Text(_showBodyMap ? 'عرض النموذج التقليدي' : 'عرض خريطة الجسم'),
                ),
              ],
            ),
          ),
        ),

        // Interactive Body Map Sliver
        if (_showBodyMap)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 400,
                child: InteractiveBodyMap(
                  measurements: _bodyMapMeasurements,
                  onMeasurementChanged: _onBodyMapMeasurementChanged,
                  unit: widget.unit,
                  colorScheme: cs,
                ),
              ),
            ),
          ),

        // Traditional Form Sliver
        if (!_showBodyMap)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final rows = <_RowSpec>[
                    _RowSpec('الطول الكلي', widget.lengthCtrl, toUnit(110), toUnit(170)),
                    _RowSpec('الكتف', widget.shoulderCtrl, toUnit(38), toUnit(56)),
                    _RowSpec('طول الكم', widget.sleeveCtrl, toUnit(45), toUnit(75)),
                    _RowSpec('محيط الكم العلوي', widget.upperSleeveCtrl, toUnit(24), toUnit(48)),
                    _RowSpec('محيط الكم السفلي', widget.lowerSleeveCtrl, toUnit(14), toUnit(24)),
                    _RowSpec('الصدر', widget.chestCtrl, toUnit(80), toUnit(140)),
                    _RowSpec('الخصر', widget.waistCtrl, toUnit(70), toUnit(130)),
                    _RowSpec('محيط الرقبة', widget.neckCtrl, toUnit(34), toUnit(48)),
                    _RowSpec('التطريز الامامي', widget.embroideryCtrl, toUnit(10), toUnit(30)),
                  ];

                  if (index >= rows.length) return null;

                  final row = rows[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _MeasurementRow(
                      spec: row,
                      unit: widget.unit,
                      decimals: decimals,
                      onChanged: () => _syncControllersToBodyMap(),
                    ),
                  );
                },
                childCount: 9,
              ),
            ),
          ),

        // Notes Section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Form(
              key: widget.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'ملاحظات إضافية',
                    style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: widget.notesCtrl,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'أضف أي ملاحظات أو متطلبات خاصة...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Save Measurements Button
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: _SaveMeasurementsButton(
              measurements: {
                'الطول الكلي': double.tryParse(widget.lengthCtrl.text) ?? 0,
                'الكتف': double.tryParse(widget.shoulderCtrl.text) ?? 0,
                'طول الكم': double.tryParse(widget.sleeveCtrl.text) ?? 0,
                'محيط الكم العلوي': double.tryParse(widget.upperSleeveCtrl.text) ?? 0,
                'محيط الكم السفلي': double.tryParse(widget.lowerSleeveCtrl.text) ?? 0,
                'الصدر': double.tryParse(widget.chestCtrl.text) ?? 0,
                'الخصر': double.tryParse(widget.waistCtrl.text) ?? 0,
                'محيط الرقبة': double.tryParse(widget.neckCtrl.text) ?? 0,
                'التطريز الامامي': double.tryParse(widget.embroideryCtrl.text) ?? 0,
              },
              notes: widget.notesCtrl.text.trim(),
            ),
          ),
        ),
      ],
    );
  }
}

/// Measurement Row Widget
class _MeasurementRow extends StatelessWidget {
  final _RowSpec spec;
  final MeasurementUnit unit;
  final int decimals;
  final VoidCallback onChanged;

  const _MeasurementRow({
    required this.spec,
    required this.unit,
    required this.decimals,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final unitLabel = unit == MeasurementUnit.cm ? 'سم' : 'إنش';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              spec.label,
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 120,
            child: TextFormField(
              controller: spec.ctrl,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                suffixText: unitLabel,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'مطلوب';
                }
                final num = double.tryParse(value);
                if (num == null || num < spec.min || num > spec.max) {
                  return '${spec.min}-${spec.max}';
                }
                return null;
              },
              onChanged: (_) => onChanged(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: () {
              final current = double.tryParse(spec.ctrl.text) ?? spec.min;
              final newValue = (current - (unit == MeasurementUnit.cm ? 0.5 : 0.25))
                  .clamp(spec.min, spec.max);
              spec.ctrl.text = newValue.toStringAsFixed(decimals);
              onChanged();
              HapticFeedback.selectionClick();
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              final current = double.tryParse(spec.ctrl.text) ?? spec.min;
              final newValue = (current + (unit == MeasurementUnit.cm ? 0.5 : 0.25))
                  .clamp(spec.min, spec.max);
              spec.ctrl.text = newValue.toStringAsFixed(decimals);
              onChanged();
              HapticFeedback.selectionClick();
            },
          ),
        ],
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

/// Save Measurements Button
class _SaveMeasurementsButton extends StatelessWidget {
  final Map<String, double> measurements;
  final String notes;

  const _SaveMeasurementsButton({
    required this.measurements,
    this.notes = '',
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: () async {
        try {
          final service = MeasurementService();
          // سيتم إنشاء الـ id و userId تلقائياً في saveProfile
          final profile = MeasurementProfile(
            id: '', // سيتم إنشاؤه تلقائياً
            userId: '', // سيتم تعبئته في saveProfile
            name: 'مقاسات ${DateTime.now().toString().substring(0, 10)}',
            measurements: measurements,
            notes: notes.isEmpty ? null : notes,
            createdAt: DateTime.now(),
            isDefault: false,
          );

          await service.saveProfile(profile);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 8),
                    Text('تم حفظ المقاسات بنجاح'),
                  ],
                ),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('خطأ في الحفظ: $e')),
            );
          }
        }
      },
      icon: const Icon(Icons.save),
      label: const Text('حفظ المقاسات'),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }
}

