// lib/features/measurements/models/measurement_profile.dart
import 'package:cloud_firestore/cloud_firestore.dart';

/// نموذج ملف المقاسات الشخصي
class MeasurementProfile {
  final String id;
  final String userId;
  final String name; // "رسمي", "يومي", "رياضي", "عادي"
  final Map<String, double> measurements;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isDefault;
  final String? notes;

  const MeasurementProfile({
    required this.id,
    required this.userId,
    required this.name,
    required this.measurements,
    required this.createdAt,
    this.updatedAt,
    required this.isDefault,
    this.notes,
  });

  MeasurementProfile copyWith({
    String? id,
    String? userId,
    String? name,
    Map<String, double>? measurements,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDefault,
    String? notes,
  }) {
    return MeasurementProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      measurements: measurements ?? this.measurements,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDefault: isDefault ?? this.isDefault,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'measurements': measurements,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'isDefault': isDefault,
      'notes': notes,
    };
  }

  factory MeasurementProfile.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return MeasurementProfile(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? 'ملف المقاسات',
      measurements: Map<String, double>.from(data['measurements'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      isDefault: data['isDefault'] ?? false,
      notes: data['notes'],
    );
  }

  /// قوالب المقاسات الجاهزة
  static Map<String, double> getTemplate(String size) {
    final templates = {
      'S': {
        'الطول الكلي': 140.0,
        'الكتف': 38.0,
        'طول الكم': 45.0,
        'محيط الكم العلوي': 24.0,
        'محيط الكم السفلي': 14.0,
        'الصدر': 90.0,
        'الخصر': 80.0,
        'محيط الرقبة': 34.0,
        'التطريز الامامي': 10.0,
      },
      'M': {
        'الطول الكلي': 150.0,
        'الكتف': 42.0,
        'طول الكم': 50.0,
        'محيط الكم العلوي': 28.0,
        'محيط الكم السفلي': 16.0,
        'الصدر': 100.0,
        'الخصر': 90.0,
        'محيط الرقبة': 38.0,
        'التطريز الامامي': 12.0,
      },
      'L': {
        'الطول الكلي': 160.0,
        'الكتف': 46.0,
        'طول الكم': 55.0,
        'محيط الكم العلوي': 32.0,
        'محيط الكم السفلي': 18.0,
        'الصدر': 110.0,
        'الخصر': 100.0,
        'محيط الرقبة': 42.0,
        'التطريز الامامي': 14.0,
      },
      'XL': {
        'الطول الكلي': 170.0,
        'الكتف': 50.0,
        'طول الكم': 60.0,
        'محيط الكم العلوي': 36.0,
        'محيط الكم السفلي': 20.0,
        'الصدر': 120.0,
        'الخصر': 110.0,
        'محيط الرقبة': 46.0,
        'التطريز الامامي': 16.0,
      },
    };

    return templates[size] ?? templates['M']!;
  }

  /// التحقق من صحة المقاسات
  static String? validateMeasurements(Map<String, double> m) {
    final length = m['الطول الكلي'] ?? 0;
    final chest = m['الصدر'] ?? 0;
    final waist = m['الخصر'] ?? 0;
    final shoulder = m['الكتف'] ?? 0;
    final upperSleeve = m['محيط الكم العلوي'] ?? 0;
    final lowerSleeve = m['محيط الكم السفلي'] ?? 0;

    // التحققات المنطقية
    if (length < 100 || length > 200) {
      return 'الطول الكلي غير منطقي (يجب أن يكون بين 100-200 سم)';
    }

    if (waist > chest + 15) {
      return 'الخصر لا يمكن أن يكون أكبر من الصدر بأكثر من 15 سم';
    }

    if (shoulder > chest / 2 + 15) {
      return 'عرض الكتف كبير جداً بالنسبة لمحيط الصدر';
    }

    if (upperSleeve > 0 && lowerSleeve > 0 && lowerSleeve >= upperSleeve) {
      return 'محيط الكم السفلي يجب أن يكون أصغر من محيط الكم العلوي';
    }

    if (chest > 0 && chest < 70) {
      return 'محيط الصدر صغير جداً (الحد الأدنى: 70 سم)';
    }

    return null; // كل شيء صحيح
  }
}




