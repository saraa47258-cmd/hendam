import 'package:flutter/material.dart';
import '../../core/styles/responsive.dart';

class MeasurementFormScreen extends StatefulWidget {
  const MeasurementFormScreen({super.key});

  @override
  State<MeasurementFormScreen> createState() => _MeasurementFormScreenState();
}

class _MeasurementFormScreenState extends State<MeasurementFormScreen> {
  // قائمة المقاسات العشرة
  final List<MeasurementField> measurements = [
    MeasurementField(id: 1, label: 'الطول الكلي', value: ''),
    MeasurementField(id: 2, label: 'الكتف', value: ''),
    MeasurementField(id: 3, label: 'طول الكم', value: ''),
    MeasurementField(id: 4, label: 'محيط الكم العلوي', value: ''),
    MeasurementField(id: 5, label: 'محيط الكم السفلي', value: ''),
    MeasurementField(id: 6, label: 'الصدر', value: ''),
    MeasurementField(id: 7, label: 'الخصر', value: ''),
    MeasurementField(id: 8, label: 'المحيط السفلي', value: ''),
    MeasurementField(id: 9, label: 'محيط الرقبة', value: ''),
    MeasurementField(id: 10, label: 'التطريز الامامي', value: ''),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF8B0000), // لون أحمر داكن
        body: SafeArea(
          child: Column(
            children: [
              // العنوان
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(context.responsivePadding()),
                child: Text(
                  'استمارة المقاسات',
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
                  child: _buildMeasurementsGrid(context),
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
                          'إلغاء',
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
                          'حفظ',
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

  Widget _buildMeasurementsGrid(BuildContext context) {
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
                    measurements.take(5).toList(),
                    isRight: true,
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
                    measurements.skip(5).take(5).toList(),
                    isRight: false,
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
      BuildContext context, List<MeasurementField> measurementsList,
      {required bool isRight}) {
    return Column(
      children: measurementsList.map((measurement) {
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
                      measurement.label,
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
                    controller: TextEditingController(text: measurement.value),
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
                    onChanged: (value) {
                      measurement.value = value;
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _saveMeasurements() {
    // حفظ المقاسات
    final filledMeasurements =
        measurements.where((m) => m.value.isNotEmpty).toList();

    if (filledMeasurements.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'يرجى إدخال مقاس واحد على الأقل',
            style: TextStyle(fontSize: context.responsiveFontSize(14.0)),
          ),
          backgroundColor: const Color(0xFF8B0000),
        ),
      );
      return;
    }

    // إغلاق الشاشة مع النتائج
    Navigator.of(context).pop({
      'measurements': filledMeasurements.map((m) => m.toMap()).toList(),
    });
  }
}

class MeasurementField {
  final int id;
  final String label;
  String value;

  MeasurementField({
    required this.id,
    required this.label,
    required this.value,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'value': value,
    };
  }
}
