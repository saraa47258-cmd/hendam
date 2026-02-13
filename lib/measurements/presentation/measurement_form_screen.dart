import 'dart:async';

import 'package:flutter/material.dart';
import '../../core/styles/responsive.dart';
import '../../l10n/app_localizations.dart';
import '../../core/state/draft_store.dart';

class MeasurementFormScreen extends StatefulWidget {
  const MeasurementFormScreen({super.key});

  @override
  State<MeasurementFormScreen> createState() => _MeasurementFormScreenState();
}

class _MeasurementFormScreenState extends State<MeasurementFormScreen> {
  // قائمة المقاسات العشرة
  final List<MeasurementField> measurements = [
    MeasurementField(id: 1, value: ''),
    MeasurementField(id: 2, value: ''),
    MeasurementField(id: 3, value: ''),
    MeasurementField(id: 4, value: ''),
    MeasurementField(id: 5, value: ''),
    MeasurementField(id: 6, value: ''),
    MeasurementField(id: 7, value: ''),
    MeasurementField(id: 8, value: ''),
    MeasurementField(id: 9, value: ''),
    MeasurementField(id: 10, value: ''),
  ];
  static const String _draftKey = 'measurement-form';
  late final List<TextEditingController> _controllers;
  Timer? _draftTimer;
  bool _restoringDraft = false;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(measurements.length, (i) {
      final controller = TextEditingController(text: measurements[i].value);
      controller.addListener(() {
        measurements[i].value = controller.text;
        _scheduleDraftSave();
      });
      return controller;
    });
    Future.microtask(_loadDraft);
  }

  @override
  void dispose() {
    _draftTimer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  String _getMeasurementLabel(int id, AppLocalizations l10n) {
    switch (id) {
      case 1: return l10n.totalLength;
      case 2: return l10n.shoulder;
      case 3: return l10n.sleeveLength;
      case 4: return l10n.upperSleeve;
      case 5: return l10n.lowerSleeve;
      case 6: return l10n.chest;
      case 7: return l10n.waist;
      case 8: return l10n.bottomCircumference;
      case 9: return l10n.neckCircumference;
      case 10: return l10n.frontEmbroidery;
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFF8B0000), // لون أحمر داكن
      body: SafeArea(
          child: Column(
            children: [
              // العنوان
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(context.responsivePadding()),
                child: Text(
                  l10n.measurementsForm,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: context.responsiveFontSize(24.0),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // شبكة المقاسات
              Expanded(
                child: Container(
                  margin: EdgeInsets.all(context.responsivePadding()),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(context.responsiveRadius()),
                  ),
                  child: _buildMeasurementsGrid(context, l10n),
                ),
              ),

              // أزرار التحكم
              Container(
                padding: EdgeInsets.all(context.responsivePadding()),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF8B0000),
                          padding: EdgeInsets.symmetric(
                            vertical: context.responsiveSpacing(),
                          ),
                        ),
                        child: Text(
                          l10n.cancel,
                          style: TextStyle(
                            fontSize: context.responsiveFontSize(16.0),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: context.responsiveSpacing()),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveMeasurements,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B0000),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: context.responsiveSpacing(),
                          ),
                        ),
                        child: Text(
                          l10n.save,
                          style: TextStyle(
                            fontSize: context.responsiveFontSize(16.0),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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

  Widget _buildMeasurementsGrid(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.all(context.responsivePadding()),
      child: Column(
        children: [
          // الصف الأول - المقاسات 1-5
          Expanded(
            child: Row(
              children: [
                // القائمة اليمنى (1-5)
                Expanded(
                  child: _buildMeasurementsList(
                    context,
                    l10n,
                    measurements.take(5).toList(),
                    isRight: true,
                    startIndex: 0,
                  ),
                ),
                // خط فاصل
                Container(
                  width: 2,
                  color: const Color(0xFF8B0000).withValues(alpha: 0.3),
                  margin: EdgeInsets.symmetric(
                      horizontal: context.responsiveMargin()),
                ),
                // القائمة اليسرى (6-10)
                Expanded(
                  child: _buildMeasurementsList(
                    context,
                    l10n,
                    measurements.skip(5).take(5).toList(),
                    isRight: false,
                    startIndex: 5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementsList(
      BuildContext context,
      AppLocalizations l10n,
      List<MeasurementField> measurementsList,
      {required bool isRight,
      required int startIndex}) {
    return Column(
      children: measurementsList.asMap().entries.map((entry) {
        final index = startIndex + entry.key;
        final measurement = entry.value;
        final controller = _controllers[index];
        return Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(
              vertical: context.responsiveMargin() / 2,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFF8B0000).withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // رقم القياس
                Container(
                  width: context.pick(40.0, tablet: 45.0, desktop: 50.0),
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B0000).withValues(alpha: 0.1),
                  ),
                  child: Center(
                    child: Text(
                      '${measurement.id}',
                      style: TextStyle(
                        color: const Color(0xFF8B0000),
                        fontSize: context.responsiveFontSize(16.0),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // اسم القياس
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.responsiveMargin(),
                    ),
                    child: Text(
                      _getMeasurementLabel(measurement.id, l10n),
                      style: TextStyle(
                        fontSize: context.responsiveFontSize(14.0),
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: isRight ? TextAlign.right : TextAlign.left,
                    ),
                  ),
                ),
                // حقل الإدخال
                Container(
                  width: context.pick(80.0, tablet: 90.0, desktop: 100.0),
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                  ),
                  child: TextField(
                    controller: controller,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      fontSize: context.responsiveFontSize(14.0),
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _saveMeasurements() async {
    // حفظ المقاسات
    final l10n = AppLocalizations.of(context)!;
    final filledMeasurements =
        measurements.where((m) => m.value.isNotEmpty).toList();

    if (filledMeasurements.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.enterAtLeastOneMeasurement,
            style: TextStyle(fontSize: context.responsiveFontSize(14.0)),
          ),
          backgroundColor: const Color(0xFF8B0000),
        ),
      );
      return;
    }

    // إغلاق الشاشة مع النتائج
    await _clearDraft();
    Navigator.of(context).pop({
      'measurements': filledMeasurements.map((m) => m.toMap()).toList(),
    });
  }

  Future<void> _loadDraft() async {
    final data = await DraftStore.read(_draftKey);
    if (data == null) return;
    _restoringDraft = true;
    final values = data['values'];
    if (values is Map) {
      for (var i = 0; i < measurements.length; i++) {
        final key = measurements[i].id.toString();
        final v = values[key];
        if (v is String) {
          measurements[i].value = v;
          _controllers[i].text = v;
        }
      }
    }
    _restoringDraft = false;
  }

  void _scheduleDraftSave() {
    if (_restoringDraft) return;
    _draftTimer?.cancel();
    _draftTimer = Timer(const Duration(milliseconds: 300), () {
      final values = <String, String>{
        for (final m in measurements) m.id.toString(): m.value,
      };
      DraftStore.write(_draftKey, {'values': values});
    });
  }

  Future<void> _clearDraft() async {
    await DraftStore.clear(_draftKey);
  }
}

class MeasurementField {
  final int id;
  String value;

  MeasurementField({
    required this.id,
    required this.value,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'value': value,
    };
  }
}
