import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Interactive Body Map Widget
/// خريطة جسم تفاعلية لإدخال المقاسات
class InteractiveBodyMap extends StatefulWidget {
  final Map<String, double?> measurements;
  final ValueChanged<Map<String, double?>> onMeasurementChanged;
  final MeasurementUnit unit;
  final ColorScheme colorScheme;

  const InteractiveBodyMap({
    super.key,
    required this.measurements,
    required this.onMeasurementChanged,
    required this.unit,
    required this.colorScheme,
  });

  @override
  State<InteractiveBodyMap> createState() => _InteractiveBodyMapState();
}

class _InteractiveBodyMapState extends State<InteractiveBodyMap>
    with SingleTickerProviderStateMixin {
  String? _selectedPart;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _onPartTap(String partKey, String label) {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedPart = _selectedPart == partKey ? null : partKey;
    });

    if (_selectedPart != null) {
      _showMeasurementDialog(partKey, label);
    }
  }

  void _showMeasurementDialog(String partKey, String label) {
    final currentValue = widget.measurements[partKey] ?? 0.0;
    final unitLabel = widget.unit == MeasurementUnit.cm ? 'سم' : 'إنش';
    final minValue = widget.unit == MeasurementUnit.cm ? 30.0 : 12.0;
    final maxValue = widget.unit == MeasurementUnit.cm ? 200.0 : 80.0;
    final step = widget.unit == MeasurementUnit.cm ? 0.5 : 0.25;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _MeasurementBottomSheet(
        label: label,
        unitLabel: unitLabel,
        currentValue: currentValue,
        minValue: minValue,
        maxValue: maxValue,
        step: step,
        onValueChanged: (value) {
          final updated = Map<String, double?>.from(widget.measurements);
          updated[partKey] = value;
          widget.onMeasurementChanged(updated);
          setState(() {
            _selectedPart = null;
          });
        },
        colorScheme: widget.colorScheme,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = widget.colorScheme;
    final isSelected = _selectedPart != null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cs.surface,
            cs.surfaceContainerHighest.withOpacity(0.3),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isSelected ? cs.primary : cs.outlineVariant,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            'اضغط على الجزء لإدخال المقاس',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: cs.primary,
                ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: CustomPaint(
              painter: _BodyMapPainter(
                measurements: widget.measurements,
                selectedPart: _selectedPart,
                colorScheme: cs,
                pulseScale: _pulseAnimation.value,
              ),
              child: GestureDetector(
                onTapDown: (details) {
                  final part = _getPartAtPosition(details.localPosition);
                  if (part != null) {
                    _onPartTap(part['key'] as String, part['label'] as String);
                  }
                },
                child: Container(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildMeasurementLegend(cs),
        ],
      ),
    );
  }

  Map<String, dynamic>? _getPartAtPosition(Offset position) {
    // منطق تحديد الجزء بناءً على الموضع
    // يمكن تحسينه باستخدام Path.contains()
    final parts = <Map<String, dynamic>>[
      {'key': 'neck', 'label': 'محيط الرقبة', 'bounds': Rect.fromLTWH(100, 50, 80, 40)},
      {'key': 'shoulder', 'label': 'الكتف', 'bounds': Rect.fromLTWH(60, 90, 160, 30)},
      {'key': 'chest', 'label': 'الصدر', 'bounds': Rect.fromLTWH(70, 120, 140, 60)},
      {'key': 'waist', 'label': 'الخصر', 'bounds': Rect.fromLTWH(80, 180, 120, 40)},
      {'key': 'sleeve', 'label': 'طول الكم', 'bounds': Rect.fromLTWH(20, 100, 40, 100)},
      {'key': 'upperSleeve', 'label': 'محيط الكم العلوي', 'bounds': Rect.fromLTWH(15, 110, 30, 30)},
      {'key': 'lowerSleeve', 'label': 'محيط الكم السفلي', 'bounds': Rect.fromLTWH(15, 170, 30, 30)},
      {'key': 'length', 'label': 'الطول الكلي', 'bounds': Rect.fromLTWH(90, 50, 100, 200)},
    ];

    for (var part in parts) {
      if ((part['bounds'] as Rect).contains(position)) {
        return part;
      }
    }
    return null;
  }

  Widget _buildMeasurementLegend(ColorScheme cs) {
    final entries = widget.measurements.entries
        .where((e) => e.value != null && e.value! > 0)
        .toList();

    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: entries.map((entry) {
        final partNames = {
          'neck': 'الرقبة',
          'shoulder': 'الكتف',
          'chest': 'الصدر',
          'waist': 'الخصر',
          'sleeve': 'الكم',
          'upperSleeve': 'الكم العلوي',
          'lowerSleeve': 'الكم السفلي',
          'length': 'الطول',
        };

        return Chip(
          avatar: CircleAvatar(
            backgroundColor: cs.primaryContainer,
            radius: 12,
            child: Icon(Icons.check, size: 14, color: cs.onPrimaryContainer),
          ),
          label: Text(
            '${partNames[entry.key] ?? entry.key}: ${entry.value!.toStringAsFixed(widget.unit == MeasurementUnit.cm ? 1 : 2)} ${widget.unit == MeasurementUnit.cm ? 'سم' : 'إنش'}',
            style: Theme.of(context).textTheme.labelSmall,
          ),
          backgroundColor: cs.primaryContainer.withOpacity(0.5),
        );
      }).toList(),
    );
  }
}

/// Painter للرسم على Body Map
class _BodyMapPainter extends CustomPainter {
  final Map<String, double?> measurements;
  final String? selectedPart;
  final ColorScheme colorScheme;
  final double pulseScale;

  _BodyMapPainter({
    required this.measurements,
    required this.selectedPart,
    required this.colorScheme,
    required this.pulseScale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = colorScheme.surfaceContainerHighest;

    final selectedPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = colorScheme.primary.withOpacity(0.2);

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = colorScheme.outline
      ..strokeWidth = 2;

    final selectedStrokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = colorScheme.primary
      ..strokeWidth = 3;

    // رسم الجسم (شكل مبسط)
    final bodyPath = Path()
      ..moveTo(size.width * 0.4, size.height * 0.1) // الرأس
      ..lineTo(size.width * 0.6, size.height * 0.1)
      ..lineTo(size.width * 0.65, size.height * 0.15) // الكتف الأيمن
      ..lineTo(size.width * 0.7, size.height * 0.2) // الصدر
      ..lineTo(size.width * 0.68, size.height * 0.4) // الخصر
      ..lineTo(size.width * 0.65, size.height * 0.9) // القدم
      ..lineTo(size.width * 0.6, size.height * 0.95)
      ..lineTo(size.width * 0.4, size.height * 0.95)
      ..lineTo(size.width * 0.35, size.height * 0.9)
      ..lineTo(size.width * 0.32, size.height * 0.4) // الخصر
      ..lineTo(size.width * 0.3, size.height * 0.2) // الصدر
      ..lineTo(size.width * 0.35, size.height * 0.15) // الكتف الأيسر
      ..close();

    // رسم الذراع الأيسر
    final leftArmPath = Path()
      ..moveTo(size.width * 0.35, size.height * 0.15)
      ..lineTo(size.width * 0.2, size.height * 0.2)
      ..lineTo(size.width * 0.15, size.height * 0.5)
      ..lineTo(size.width * 0.2, size.height * 0.55)
      ..lineTo(size.width * 0.25, size.height * 0.5)
      ..lineTo(size.width * 0.3, size.height * 0.25)
      ..close();

    // رسم الذراع الأيمن (مستقبلاً يمكن استخدامه)
    // final rightArmPath = Path()
    //   ..moveTo(size.width * 0.65, size.height * 0.15)
    //   ..lineTo(size.width * 0.8, size.height * 0.2)
    //   ..lineTo(size.width * 0.85, size.height * 0.5)
    //   ..lineTo(size.width * 0.8, size.height * 0.55)
    //   ..lineTo(size.width * 0.75, size.height * 0.5)
    //   ..lineTo(size.width * 0.7, size.height * 0.25)
    //   ..close();

    // تحديد الأجزاء المحددة
    final parts = {
      'neck': Path()..addOval(Rect.fromLTWH(size.width * 0.4, size.height * 0.1, size.width * 0.2, size.height * 0.08)),
      'shoulder': Path()..addRect(Rect.fromLTWH(size.width * 0.3, size.height * 0.12, size.width * 0.4, size.height * 0.06)),
      'chest': Path()..addRect(Rect.fromLTWH(size.width * 0.32, size.height * 0.18, size.width * 0.36, size.height * 0.12)),
      'waist': Path()..addRect(Rect.fromLTWH(size.width * 0.35, size.height * 0.38, size.width * 0.3, size.height * 0.08)),
      'sleeve': leftArmPath,
      'upperSleeve': Path()..addOval(Rect.fromLTWH(size.width * 0.15, size.height * 0.2, size.width * 0.12, size.height * 0.08)),
      'lowerSleeve': Path()..addOval(Rect.fromLTWH(size.width * 0.15, size.height * 0.35, size.width * 0.12, size.height * 0.08)),
      'length': bodyPath,
    };

    // رسم الأجزاء
    for (var entry in parts.entries) {
      final isSelected = selectedPart == entry.key;
      final hasValue = measurements[entry.key] != null && measurements[entry.key]! > 0;

      if (isSelected) {
        canvas.save();
        canvas.translate(size.width / 2, size.height / 2);
        canvas.scale(pulseScale, pulseScale);
        canvas.translate(-size.width / 2, -size.height / 2);
      }

      canvas.drawPath(
        entry.value,
        hasValue || isSelected ? selectedPaint : paint,
      );
      canvas.drawPath(
        entry.value,
        isSelected ? selectedStrokePaint : strokePaint,
      );

      if (isSelected) {
        canvas.restore();
      }

      // رسم قيمة القياس إن وجدت
      if (hasValue && !isSelected) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: measurements[entry.key]!.toStringAsFixed(1),
            style: TextStyle(
              color: colorScheme.onPrimaryContainer,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.rtl,
        );
        textPainter.layout();
        final bounds = entry.value.getBounds();
        textPainter.paint(
          canvas,
          Offset(
            bounds.center.dx - textPainter.width / 2,
            bounds.center.dy - textPainter.height / 2,
          ),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_BodyMapPainter oldDelegate) {
    return oldDelegate.measurements != measurements ||
        oldDelegate.selectedPart != selectedPart ||
        oldDelegate.pulseScale != pulseScale;
  }
}

/// Bottom Sheet لإدخال القياس
class _MeasurementBottomSheet extends StatefulWidget {
  final String label;
  final String unitLabel;
  final double currentValue;
  final double minValue;
  final double maxValue;
  final double step;
  final ValueChanged<double> onValueChanged;
  final ColorScheme colorScheme;

  const _MeasurementBottomSheet({
    required this.label,
    required this.unitLabel,
    required this.currentValue,
    required this.minValue,
    required this.maxValue,
    required this.step,
    required this.onValueChanged,
    required this.colorScheme,
  });

  @override
  State<_MeasurementBottomSheet> createState() => _MeasurementBottomSheetState();
}

class _MeasurementBottomSheetState extends State<_MeasurementBottomSheet> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.currentValue;
  }

  @override
  Widget build(BuildContext context) {
    final cs = widget.colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              widget.label,
              style: tt.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: cs.primary,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filled(
                  onPressed: () {
                    setState(() {
                      _value = (_value - widget.step).clamp(widget.minValue, widget.maxValue);
                    });
                    HapticFeedback.selectionClick();
                  },
                  icon: const Icon(Icons.remove),
                ),
                const SizedBox(width: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${_value.toStringAsFixed(widget.step < 1 ? 2 : 1)} ${widget.unitLabel}',
                    style: tt.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                IconButton.filled(
                  onPressed: () {
                    setState(() {
                      _value = (_value + widget.step).clamp(widget.minValue, widget.maxValue);
                    });
                    HapticFeedback.selectionClick();
                  },
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Slider(
              value: _value,
              min: widget.minValue,
              max: widget.maxValue,
              divisions: ((widget.maxValue - widget.minValue) / widget.step).round(),
              onChanged: (value) {
                setState(() {
                  _value = value;
                });
                HapticFeedback.selectionClick();
              },
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                widget.onValueChanged(_value);
                Navigator.pop(context);
              },
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('تأكيد'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Enum للوحدات
enum MeasurementUnit { cm, inch }

extension MeasurementUnitX on MeasurementUnit {
  String get labelAr => this == MeasurementUnit.cm ? 'سم' : 'إنش';
  String get labelEn => this == MeasurementUnit.cm ? 'cm' : 'in';
}

