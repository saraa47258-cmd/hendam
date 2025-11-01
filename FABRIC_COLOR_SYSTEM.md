# نظام الأقمشة والألوان الحقيقية للخياطين

## نظرة عامة
تم تطوير نظام شامل لإدارة الأقمشة والألوان الحقيقية التي يرفعها كل خياط في حسابه، بدلاً من الاعتماد على الأقمشة الثابتة من مجلد `assets/fabrics/`.

## المكونات المنفذة

### 1. نماذج البيانات (Models)

#### `TailorFabric` - نموذج قماش الخياط
```dart
class TailorFabric {
  final String id;                    // معرف القماش
  final String tailorId;              // معرف الخياط
  final String name;                  // اسم القماش
  final String description;           // وصف القماش
  final String imageUrl;              // رابط صورة القماش
  final List<String> availableColors; // الألوان المتاحة
  final double pricePerMeter;         // السعر لكل متر
  final String fabricType;            // نوع القماش (قطن، حرير، صوف...)
  final String season;                // الموسم (صيفي، شتوي، جميع المواسم)
  final bool isAvailable;             // هل القماش متاح؟
  final DateTime createdAt;           // تاريخ الإنشاء
  final DateTime updatedAt;           // تاريخ آخر تحديث
}
```

#### `FabricColor` - نموذج لون القماش
```dart
class FabricColor {
  final String id;           // معرف اللون
  final String fabricId;     // معرف القماش
  final String name;         // اسم اللون
  final String hexCode;      // كود اللون (مثل #FF5733)
  final String imageUrl;     // صورة اللون على القماش
  final bool isAvailable;    // هل اللون متاح؟
  final DateTime createdAt;  // تاريخ الإنشاء
}
```

### 2. خدمة Firebase (Service)

#### `TailorFabricService` - خدمة إدارة الأقمشة والألوان
```dart
class TailorFabricService {
  // جلب أقمشة خياط معين
  static Stream<List<TailorFabric>> getTailorFabrics(String tailorId);
  
  // جلب ألوان قماش معين
  static Stream<List<FabricColor>> getFabricColors(String fabricId);
  
  // جلب جميع ألوان خياط معين
  static Stream<List<FabricColor>> getTailorColors(String tailorId);
  
  // إضافة قماش جديد
  static Future<String?> addFabric(TailorFabric fabric);
  
  // إضافة لون جديد
  static Future<String?> addFabricColor(FabricColor color);
  
  // تحديث قماش موجود
  static Future<bool> updateFabric(TailorFabric fabric);
  
  // تحديث لون موجود
  static Future<bool> updateFabricColor(FabricColor color);
  
  // حذف قماش (تعطيله)
  static Future<bool> deleteFabric(String fabricId);
  
  // حذف لون (تعطيله)
  static Future<bool> deleteFabricColor(String colorId);
  
  // البحث في أقمشة الخياط
  static Stream<List<TailorFabric>> searchTailorFabrics(String tailorId, String searchQuery);
  
  // جلب أقمشة حسب النوع
  static Stream<List<TailorFabric>> getFabricsByType(String tailorId, String fabricType);
  
  // جلب أقمشة حسب الموسم
  static Stream<List<TailorFabric>> getFabricsBySeason(String tailorId, String season);
}
```

### 3. واجهات المستخدم المحدثة

#### شاشة اختيار الأقمشة (`_FabricStep`)
- عرض الأقمشة الحقيقية من Firebase بدلاً من الأقمشة الثابتة
- تحديث تلقائي عند إضافة أقمشة جديدة
- عرض معلومات إضافية: السعر، نوع القماش، الموسم
- معالجة الأخطاء والحالات الفارغة

#### شاشة اختيار الألوان (`_ColorStep`)
- عرض الألوان الحقيقية للقماش المحدد من Firebase
- تحديث تلقائي عند إضافة ألوان جديدة
- معالجة الأخطاء والحالات الفارغة
- عرض ألوان مختلفة لكل قماش

#### شاشة إدارة الأقمشة والألوان (`TailorFabricManagementScreen`)
- تبويبات منفصلة للأقمشة والألوان
- عرض قائمة الأقمشة مع الصور والمعلومات
- عرض شبكة الألوان مع معاينة بصرية
- إمكانية إضافة قماش جديد مع:
  - رفع صورة من المعرض
  - إدخال المعلومات الأساسية
  - اختيار نوع القماش والموسم
  - تحديد السعر لكل متر
- إمكانية إضافة لون جديد مع:
  - اختيار القماش المرتبط
  - إدخال اسم اللون وكود اللون
  - معاينة اللون فورياً
- إمكانية تعديل وحذف الأقمشة والألوان

## هيكل البيانات في Firebase

### مجموعة `tailor_fabrics`
```json
{
  "tailorId": "tailor_123",
  "name": "قطن ياباني فاخر",
  "description": "قماش قطني عالي الجودة من اليابان",
  "imageUrl": "https://storage.googleapis.com/...",
  "availableColors": ["color_1", "color_2"],
  "pricePerMeter": 6.5,
  "fabricType": "cotton",
  "season": "all-season",
  "isAvailable": true,
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-01T00:00:00Z"
}
```

### مجموعة `fabric_colors`
```json
{
  "fabricId": "fabric_123",
  "name": "أبيض",
  "hexCode": "#FFFFFF",
  "imageUrl": "https://storage.googleapis.com/...",
  "isAvailable": true,
  "createdAt": "2024-01-01T00:00:00Z"
}
```

## الفهارس المطلوبة في Firebase

### فهرس مركب لمجموعة `tailor_fabrics`
- Fields: `tailorId` (Ascending), `isAvailable` (Ascending), `updatedAt` (Descending)

### فهرس مركب لمجموعة `fabric_colors`
- Fields: `fabricId` (Ascending), `isAvailable` (Ascending), `createdAt` (Ascending)

## كيفية الاستخدام

### للخياطين (إدارة الأقمشة والألوان)
1. افتح شاشة إدارة الأقمشة والألوان
2. انتقل إلى تبويب "الأقمشة"
3. اضغط على زر "إضافة قماش"
4. ارفع صورة القماش
5. أدخل المعلومات المطلوبة
6. احفظ القماش
7. انتقل إلى تبويب "الألوان"
8. اضغط على زر "إضافة لون"
9. اختر القماش المرتبط
10. أدخل اسم اللون وكود اللون
11. احفظ اللون

### للعملاء (اختيار الأقمشة والألوان)
1. افتح شاشة تفصيل الثوب
2. في خطوة "القماش"، ستظهر الأقمشة الحقيقية للخياط
3. اختر القماش المطلوب
4. في خطوة "اللون"، ستظهر الألوان المتاحة لذلك القماش
5. اختر اللون المطلوب
6. أكمل باقي الخطوات

## المميزات

### التحديث التلقائي
- جميع الأقمشة والألوان تتحدث تلقائياً عند إضافة أو تعديل أو حذف
- لا حاجة لإعادة تشغيل التطبيق

### المرونة
- كل خياط يمكنه إضافة أقمشة وألوان مختلفة
- إمكانية تصنيف الأقمشة حسب النوع والموسم
- أسعار مختلفة لكل قماش

### سهولة الاستخدام
- واجهة بسيطة وواضحة لإدارة الأقمشة والألوان
- معاينة فورية للألوان
- رفع الصور بسهولة

### الأداء
- استخدام StreamBuilder للتحديث التلقائي
- تخزين مؤقت محلي للأداء الأفضل
- استعلامات محسّنة لجلب البيانات الضرورية فقط

## التبعيات المطلوبة

### في `pubspec.yaml`
```yaml
dependencies:
  image_picker: ^1.0.4  # لرفع الصور
  cloud_firestore: ^6.0.3  # لقاعدة البيانات
  firebase_storage: ^13.0.3  # لتخزين الصور
```

### أذونات Android (android/app/src/main/AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

### أذونات iOS (ios/Runner/Info.plist)
```xml
<key>NSCameraUsageDescription</key>
<string>This app needs access to camera to take photos of fabrics</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs access to photo library to select fabric images</string>
```

## الخطوات التالية

1. **تثبيت التبعيات**: تشغيل `flutter pub get`
2. **إعداد Firebase Storage**: لرفع صور الأقمشة والألوان
3. **إنشاء الفهارس**: في Firebase Console
4. **اختبار النظام**: إضافة أقمشة وألوان تجريبية
5. **تدريب الخياطين**: على استخدام واجهة الإدارة

## الملاحظات

- النظام يدعم جميع أنواع الأقمشة والألوان
- يمكن إضافة المزيد من التصنيفات حسب الحاجة
- يمكن تطوير نظام تقييم الأقمشة والألوان لاحقاً
- يمكن إضافة نظام إشعارات عند إضافة أقمشة جديدة



