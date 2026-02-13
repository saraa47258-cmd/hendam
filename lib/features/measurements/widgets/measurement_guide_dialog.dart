// lib/features/measurements/widgets/measurement_guide_dialog.dart
import 'package:flutter/material.dart';

/// دليل المقاسات التوضيحي
class MeasurementGuideDialog extends StatelessWidget {
  final String measurementName;

  const MeasurementGuideDialog({
    super.key,
    required this.measurementName,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final guide = _getGuide(measurementName);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // العنوان
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.straighten_rounded, color: cs.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          Text(
                            'كيف تقيس',
                            style: tt.labelMedium
                                ?.copyWith(color: cs.onSurfaceVariant),
                          ),
                          Text(
                            measurementName,
                            style: tt.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // الصورة التوضيحية
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  child: guide['image'] != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            guide['image']!,
                            fit: BoxFit.contain,
                          ),
                        )
                      : Center(
                          child: Icon(
                            Icons.straighten_rounded,
                            size: 64,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                ),
                const SizedBox(height: 20),

                // التعليمات
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline_rounded,
                              color: cs.primary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'خطوات القياس:',
                            style: tt.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: cs.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...guide['steps']!.map((step) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('• ',
                                    style: TextStyle(
                                        color: cs.primary,
                                        fontWeight: FontWeight.bold)),
                                Expanded(
                                  child: Text(
                                    step,
                                    style: tt.bodyMedium
                                        ?.copyWith(height: 1.5),
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),

                if (guide['tips'] != null && guide['tips']!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.lightbulb_outline_rounded,
                                color: Colors.amber.shade700, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'نصائح مهمة:',
                              style: tt.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          guide['tips']!,
                          style: tt.bodyMedium?.copyWith(
                            color: Colors.amber.shade900,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    )
  }

  Map<String, dynamic> _getGuide(String name) {
    final guides = {
      'الطول الكلي': {
        'image': null, // يمكن إضافة الصورة لاحقاً
        'steps': [
          'قف بشكل مستقيم على أرضية مستوية',
          'اطلب من شخص آخر المساعدة في القياس',
          'قس من أعلى نقطة في الكتف إلى الأرض',
          'استخدم شريط قياس مرن وغير قابل للتمدد',
          'تأكد من أن الشريط مستقيم وغير ملتوي',
        ],
        'tips':
            'للحصول على قياس دقيق، قم بالقياس وأنت ترتدي الحذاء الذي ستلبسه عادة مع الثوب.',
      },
      'الصدر': {
        'image': null,
        'steps': [
          'لف شريط القياس حول أوسع جزء من الصدر',
          'تأكد من أن الشريط موازٍ للأرض',
          'اجعل الشريط مريحاً وليس مشدوداً جداً',
          'خذ نفساً عادياً أثناء القياس',
          'سجل القياس بالسنتيمتر',
        ],
        'tips': 'أضف 2-3 سم للراحة، خاصة إذا كنت تفضل الملابس الفضفاضة قليلاً.',
      },
      'الخصر': {
        'image': null,
        'steps': [
          'حدد موقع الخصر الطبيعي (أضيق جزء من الجذع)',
          'لف شريط القياس حول الخصر',
          'تأكد من أن الشريط موازٍ للأرض',
          'لا تشد الشريط كثيراً',
          'سجل القياس مباشرة',
        ],
        'tips': 'لا تحبس أنفاسك أثناء القياس، قف بشكل طبيعي.',
      },
      'الكتف': {
        'image': null,
        'steps': [
          'قس من طرف كتف إلى الطرف الآخر',
          'مرر الشريط من الخلف عبر أعلى الظهر',
          'يجب أن يمر الشريط بنقطة التقاء الرقبة والكتف',
          'تأكد من استرخاء الكتفين',
        ],
        'tips': 'هذا القياس مهم جداً لراحة الحركة.',
      },
      'طول الكم': {
        'image': null,
        'steps': [
          'اثنِ ذراعك قليلاً عند المرفق',
          'قس من نقطة الكتف إلى المعصم',
          'مرر الشريط على الجزء الخارجي من الذراع',
          'سجل القياس عند عظمة المعصم',
        ],
        'tips': 'إذا كنت تفضل الأكمام الطويلة، أضف 2-3 سم.',
      },
      'محيط الكم العلوي': {
        'image': null,
        'steps': [
          'قس حول أعرض جزء من العضلة (البايسبس)',
          'اسمح بمساحة صغيرة للراحة',
          'لا تشد الشريط كثيراً',
        ],
        'tips': 'هذا القياس يحدد مدى راحة الكم عند الحركة.',
      },
      'محيط الكم السفلي': {
        'image': null,
        'steps': [
          'قس حول المعصم في أضيق نقطة',
          'أضف 1-2 سم للراحة',
          'يجب أن يكون الشريط مريحاً',
        ],
        'tips': 'تأكد من أن اليد يمكنها المرور بسهولة.',
      },
      'محيط الرقبة': {
        'image': null,
        'steps': [
          'قس حول قاعدة الرقبة',
          'ضع إصبعاً بين الشريط والرقبة',
          'تأكد من أن الشريط ليس مشدوداً',
        ],
        'tips': 'أضف 1-2 سم للراحة عند البلع والحركة.',
      },
      'التطريز الامامي': {
        'image': null,
        'steps': [
          'حدد طول التطريز المرغوب من أعلى الصدر',
          'قس عمودياً من الرقبة للأسفل',
          'القيمة الشائعة: 10-15 سم',
        ],
        'tips': 'هذا قياس تزييني، اختر حسب ذوقك الشخصي.',
      },
    };

    return guides[name] ??
        {
          'image': null,
          'steps': ['اتبع التعليمات المرفقة مع شريط القياس'],
          'tips': 'استعن بشخص آخر للحصول على قياسات دقيقة',
        };
  }
}

/// زر دليل المقاسات
class MeasurementGuideButton extends StatelessWidget {
  final String measurementName;

  const MeasurementGuideButton({
    super.key,
    required this.measurementName,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    
    return IconButton(
      icon: Icon(
        Icons.help_outline_rounded,
        size: 20,
        color: cs.primary,
      ),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => MeasurementGuideDialog(
            measurementName: measurementName,
          ),
        );
      },
      tooltip: 'كيف تقيس $measurementName',
    );
  }
}




