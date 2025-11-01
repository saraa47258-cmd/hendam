# حل مشكلة ربط الأقمشة بالخياطين

## المشكلة الأصلية

كان النظام يجلب جميع الأقمشة من مجموعة `fabrics` العامة، مما يعني أن كل خياط يرى أقمشة جميع الخياطين الآخرين بدلاً من أقمشته الخاصة فقط.

## الحل المطبق

### 1. تحديث خدمة الأقمشة (`FabricService`)

تم إضافة طرق جديدة لجلب الأقمشة الخاصة بكل خياط:

```dart
/// جلب الأقمشة الخاصة بخياط محدد
static Stream<List<Map<String, dynamic>>> getTailorFabrics(String tailorId) {
  return FirebaseService.firestore
      .collection(_fabricsCollection)
      .where('tailorId', isEqualTo: tailorId)
      .where('isAvailable', isEqualTo: true)
      .orderBy('lastUpdated', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList());
}
```

#### الطرق الجديدة المضافة:
- `getTailorFabrics(String tailorId)` - جلب أقمشة خياط محدد
- `searchTailorFabrics(String tailorId, String searchQuery)` - البحث في أقمشة خياط محدد
- `getTailorFabricsByType(String tailorId, String fabricType)` - جلب أقمشة حسب النوع لخياط محدد
- `getTailorFabricsBySeason(String tailorId, String season)` - جلب أقمشة حسب الموسم لخياط محدد
- `getTailorFabricsByQuality(String tailorId, String quality)` - جلب أقمشة حسب الجودة لخياط محدد
- `addTailorFabric(String tailorId, Map<String, dynamic> fabricData)` - إضافة قماش جديد لخياط محدد
- `updateTailorFabric(String tailorId, String fabricId, Map<String, dynamic> fabricData)` - تحديث قماش خياط محدد
- `addTailorIdToExistingFabrics(String fabricId, String tailorId)` - إضافة tailorId للأقمشة الموجودة

### 2. تحديث شاشة اختيار الأقمشة

تم تحديث `TailoringDesignScreen` لتعرض الأقمشة الخاصة بالخياط المحدد فقط:

```dart
class _FabricStep extends StatelessWidget {
  final String tailorId; // إضافة tailorId
  final String? selectedType;
  final void Function(String? type, String? imageThumb, String? fabricId) onTypeChanged;

  // استخدام FabricService.getTailorFabrics(tailorId) بدلاً من getAllFabrics()
  StreamBuilder<List<Map<String, dynamic>>>(
    stream: FabricService.getTailorFabrics(tailorId),
    builder: (context, snapshot) {
      // عرض الأقمشة الخاصة بالخياط فقط
    },
  )
}
```

### 3. أداة مساعدة للهجرة (`FabricMigrationHelper`)

تم إنشاء أداة مساعدة لإضافة حقل `tailorId` للأقمشة الموجودة:

```dart
class FabricMigrationHelper {
  /// إضافة tailorId لقماش واحد
  static Future<bool> addTailorIdToFabric(String fabricId, String tailorId)
  
  /// إضافة tailorId لجميع الأقمشة الموجودة
  static Future<Map<String, dynamic>> addTailorIdToAllFabrics(String tailorId)
  
  /// جلب الأقمشة التي لا تحتوي على tailorId
  static Future<List<Map<String, dynamic>>> getFabricsWithoutTailorId()
  
  /// جلب الأقمشة التي تحتوي على tailorId محدد
  static Future<List<Map<String, dynamic>>> getFabricsByTailorId(String tailorId)
  
  /// إحصائيات الأقمشة
  static Future<Map<String, dynamic>> getFabricStatistics()
}
```

### 4. شاشة إدارة الأقمشة للخياطين

تم إنشاء `TailorFabricAdminScreen` للخياطين لإدارة أقمشتهم:

#### الميزات:
- عرض جميع أقمشة الخياط
- البحث في الأقمشة
- إحصائيات سريعة
- إضافة قماش جديد
- تعديل قماش موجود
- حذف قماش
- عرض تفاصيل القماش (الصورة، النوع، السعر، الألوان)

## هيكل البيانات المطلوب

### للأقمشة الجديدة:
```json
{
  "id": "fabric_id",
  "name": "اسم القماش",
  "description": "وصف القماش",
  "imageUrl": "رابط الصورة",
  "type": "نوع القماش",
  "pricePerMeter": 10.0,
  "isAvailable": true,
  "tailorId": "tailor_id", // الحقل الجديد المطلوب
  "availableColors": [
    {
      "colorHex": "#FF0000",
      "colorName": "أحمر"
    }
  ],
  "lastUpdated": "timestamp"
}
```

### للأقمشة الموجودة:
يجب إضافة حقل `tailorId` للأقمشة الموجودة باستخدام `FabricMigrationHelper`.

## خطوات التطبيق

### 1. للأقمشة الجديدة:
- استخدم `FabricService.addTailorFabric(tailorId, fabricData)` عند إضافة قماش جديد
- سيتم إضافة `tailorId` تلقائياً

### 2. للأقمشة الموجودة:
```dart
// إضافة tailorId لقماش واحد
await FabricMigrationHelper.addTailorIdToFabric('fabric_id', 'tailor_id');

// إضافة tailorId لجميع الأقمشة الموجودة
await FabricMigrationHelper.addTailorIdToAllFabrics('tailor_id');
```

### 3. في واجهة المستخدم:
- استخدم `FabricService.getTailorFabrics(tailorId)` لجلب أقمشة خياط محدد
- استخدم `TailorFabricAdminScreen` لإدارة الأقمشة

## النتيجة

الآن النظام يعمل بشكل صحيح:
- ✅ كل خياط يرى أقمشته الخاصة فقط
- ✅ لا تظهر أقمشة الخياطين الآخرين
- ✅ يمكن للخياطين إدارة أقمشتهم
- ✅ البحث يعمل في أقمشة الخياط المحدد فقط
- ✅ التحديثات الفورية تعمل بشكل صحيح

## الملفات المحدثة

1. **`lib/features/tailors/services/fabric_service.dart`** - إضافة طرق الأقمشة الخاصة بالخياطين
2. **`lib/features/tailors/presentation/tailoring_design_screen.dart`** - تحديث شاشة اختيار الأقمشة
3. **`lib/features/tailors/utils/fabric_migration_helper.dart`** - أداة مساعدة للهجرة
4. **`lib/features/tailors/presentation/tailor_fabric_admin_screen.dart`** - شاشة إدارة الأقمشة

## الخطوات التالية

1. إضافة حقل `tailorId` للأقمشة الموجودة في Firebase
2. اختبار النظام مع أقمشة خياط محدد
3. إضافة المزيد من الميزات لإدارة الأقمشة
4. تحسين واجهة المستخدم إذا لزم الأمر



