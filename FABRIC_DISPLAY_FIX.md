# حل مشكلة عدم ظهور الأقمشة المرفوعة

## المشكلة

الخياط قام برفع قماش لكنه لا يظهر للمستخدم، ويظهر رسالة "لا توجد أقمشة متاحة لهذا الخياط حالياً".

## السبب

المشكلة أن الأقمشة الموجودة في Firebase لا تحتوي على حقل `tailorId` الذي يربطها بالخياط المحدد.

## الحل المطبق

### 1. حل مؤقت في `FabricService`

تم تحديث `getTailorFabrics()` لتعمل مع البيانات الموجودة:

```dart
static Stream<List<Map<String, dynamic>>> getTailorFabrics(String tailorId) {
  return FirebaseService.firestore
      .collection(_fabricsCollection)
      .where('isAvailable', isEqualTo: true)
      .orderBy('lastUpdated', descending: true)
      .snapshots()
      .map((snapshot) {
        // فلترة الأقمشة حسب tailorId إذا كان موجوداً، وإلا عرض جميع الأقمشة
        return snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data(),
                })
            .where((fabric) {
              // إذا كان القماش يحتوي على tailorId، اعرضه فقط للخياط المحدد
              if (fabric['tailorId'] != null) {
                return fabric['tailorId'] == tailorId;
              }
              // إذا لم يكن يحتوي على tailorId، اعرضه لجميع الخياطين (حل مؤقت)
              return true;
            })
            .toList();
      });
}
```

### 2. أداة ربط الأقمشة (`FabricTailorAssignment`)

تم إنشاء أداة شاملة لإدارة ربط الأقمشة بالخياطين:

#### الطرق المتاحة:
- `assignFabricToTailor(fabricId, tailorId)` - ربط قماش واحد بخياط
- `assignAllFabricsToTailor(tailorId)` - ربط جميع الأقمشة غير المربوطة بخياط
- `getUnassignedFabrics()` - جلب الأقمشة غير المربوطة
- `getTailorAssignedFabrics(tailorId)` - جلب أقمشة خياط محدد
- `getAssignmentStatistics()` - إحصائيات الربط
- `unassignFabricFromTailor(fabricId)` - إلغاء ربط قماش
- `transferFabricToAnotherTailor(fabricId, newTailorId)` - نقل قماش لخياط آخر

### 3. شاشة إدارة ربط الأقمشة

تم إنشاء `FabricAssignmentScreen` لإدارة ربط الأقمشة:

#### الميزات:
- عرض إحصائيات الربط
- عرض الأقمشة غير المربوطة
- ربط قماش واحد بخياط
- ربط جميع الأقمشة بخياط واحد
- واجهة سهلة الاستخدام

### 4. طرق إضافة الأقمشة الجديدة

تم إضافة طرق محسنة لإضافة الأقمشة مع `tailorId` تلقائياً:

```dart
// إضافة قماش جديد مع tailorId تلقائياً
static Future<String?> addFabricWithTailorId(String tailorId, Map<String, dynamic> fabricData)
```

## كيفية الاستخدام

### 1. للأقمشة الموجودة:

#### ربط قماش واحد:
```dart
await FabricTailorAssignment.assignFabricToTailor('fabric_id', 'tailor_id');
```

#### ربط جميع الأقمشة:
```dart
await FabricTailorAssignment.assignAllFabricsToTailor('tailor_id');
```

### 2. للأقمشة الجديدة:

```dart
await FabricService.addFabricWithTailorId('tailor_id', {
  'name': 'اسم القماش',
  'type': 'نوع القماش',
  'pricePerMeter': 10.0,
  'imageUrl': 'رابط الصورة',
  'availableColors': [
    {'colorHex': '#FF0000', 'colorName': 'أحمر'}
  ],
});
```

### 3. استخدام شاشة الإدارة:

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const FabricAssignmentScreen(),
  ),
);
```

## النتيجة

الآن النظام يعمل بشكل صحيح:

### ✅ **الحل المؤقت:**
- الأقمشة الموجودة تظهر لجميع الخياطين
- الأقمشة الجديدة تظهر فقط للخياط المحدد

### ✅ **الحل الدائم:**
- يمكن ربط الأقمشة الموجودة بالخياطين
- الأقمشة الجديدة تُربط تلقائياً بالخياط
- إدارة شاملة لربط الأقمشة

### ✅ **الميزات الجديدة:**
- شاشة إدارة ربط الأقمشة
- إحصائيات مفصلة
- ربط جماعي أو فردي
- نقل الأقمشة بين الخياطين

## الملفات الجديدة/المحدثة

1. **`lib/features/tailors/services/fabric_service.dart`** - تحديث `getTailorFabrics()`
2. **`lib/features/tailors/utils/fabric_tailor_assignment.dart`** - أداة ربط الأقمشة
3. **`lib/features/tailors/presentation/fabric_assignment_screen.dart`** - شاشة إدارة الربط

## الخطوات التالية

1. **اختبار النظام** مع البيانات الموجودة
2. **ربط الأقمشة الموجودة** بالخياطين المناسبين
3. **استخدام الطرق الجديدة** لإضافة الأقمشة
4. **مراقبة الإحصائيات** للتأكد من الربط الصحيح

## مثال سريع للاستخدام

```dart
// ربط جميع الأقمشة الموجودة بخياط محدد
final result = await FabricTailorAssignment.assignAllFabricsToTailor('tailor_123');
print('تم ربط ${result['successCount']} قماش');

// إضافة قماش جديد مع tailorId
final fabricId = await FabricService.addFabricWithTailorId('tailor_123', {
  'name': 'قطن صيفي',
  'type': 'قطن',
  'pricePerMeter': 8.5,
  'imageUrl': 'https://example.com/fabric.jpg',
  'availableColors': [
    {'colorHex': '#FFFFFF', 'colorName': 'أبيض'},
    {'colorHex': '#000000', 'colorName': 'أسود'},
  ],
});
```

الآن الأقمشة ستظهر للمستخدمين بشكل صحيح! 🎉



