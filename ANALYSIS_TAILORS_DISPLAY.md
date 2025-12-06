# تحليل آلية عرض محلات الخياطة

## 📊 نظرة عامة

يعرض تطبيق محلات الخياطة من **Firebase Firestore** باستخدام **StreamBuilder** للتحديثات الفورية.

---

## 🔄 تدفق البيانات (Data Flow)

```
Firestore Collection: "tailors"
    ↓
FirebaseService.getTailorsQuery()
    ↓
StreamBuilder → QuerySnapshot
    ↓
DocumentSnapshot → _fromDoc() → _ShopRowData
    ↓
Tailor Model
    ↓
TailorRowCard Widget → UI
```

---

## 1️⃣ المصدر: Firestore Collection

### Collection Name: `tailors`

### الشروط المطلوبة في Firestore:
```javascript
{
  isActive: true,        // المحلات النشطة فقط
  createdAt: Timestamp,  // للترتيب
  updatedAt: Timestamp,  // (اختياري)
}
```

### البنية المتوقعة للمستند:
```javascript
{
  // الحقول الأساسية
  isActive: true,
  createdAt: Timestamp,
  updatedAt: Timestamp,
  
  // بيانات الملف الشخصي
  profile: {
    avatar: "url أو path"
  },
  
  // بيانات الخدمات
  services: {
    shopName: "اسم المتجر",
    specialization: "التخصص",
    totalOrders: 123
  },
  
  // الموقع
  location: {
    city: "المدينة",
    address: "العنوان"
  },
  
  // بيانات إضافية (بدائل)
  ownerName: "اسم المالك",
  name: "اسم المتجر",
  rating: 4.5,
  city: "المدينة",
  specialization: "التخصص",
  totalOrders: 123,
  avatar: "url",
  imageUrl: "url"
}
```

---

## 2️⃣ الاستعلام: FirebaseService.getTailorsQuery()

### الموقع: `lib/core/services/firebase_service.dart`

### الاستعلام الأساسي:
```dart
firestore
  .collection('tailors')
  .where('isActive', isEqualTo: true)      // فلترة: المحلات النشطة فقط
  .orderBy('createdAt', descending: true)  // الترتيب: الأحدث أولاً
```

### آلية معالجة الأخطاء:
1. **المحاولة الأولى**: `where('isActive', isEqualTo: true) + orderBy('createdAt')`
   - يتطلب **index** في Firestore
   - إذا فشل → المحاولة الثانية
   
2. **المحاولة الثانية**: `orderBy('createdAt')` فقط (بدون where)
   - لا يحتاج index
   
3. **المحاولة الثالثة**: query بسيط بدون فلترة أو ترتيب
   - يجلب جميع المحلات

---

## 3️⃣ الواجهة: StreamBuilder

### الموقع: `lib/features/catalog/presentation/men_services_screen.dart`

### الاستخدام:
```dart
StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
  stream: FirebaseService.getTailorsQuery()
      .snapshots(includeMetadataChanges: false),
  builder: (context, snapshot) {
    // معالجة الحالات
  }
)
```

### حالات StreamBuilder:

#### أ) حالة التحميل (Loading):
```dart
if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
  return const _TailorSkeletonList();  // عرض skeleton cards
}
```

#### ب) حالة الخطأ (Error):
```dart
if (snapshot.hasError) {
  return _ErrorBox(
    message: 'تعذر تحميل محلات الخياطة',
    onRetry: _refreshTailors,
  );
}
```

#### ج) حالة فارغة (Empty):
```dart
if (docs.isEmpty) {
  return _EmptyBox(
    message: 'لا توجد محلات مسجلة حالياً',
    onRefresh: _refreshTailors,
  );
}
```

#### د) حالة النجاح (Success):
```dart
final items = docs.map(_fromDoc).toList();
return Column(
  children: items.map((e) => TailorRowCard(...)).toList(),
);
```

---

## 4️⃣ التحويل: _fromDoc()

### وظيفة: تحويل `DocumentSnapshot` إلى `_ShopRowData`

### الخوارزمية:

1. **استخراج البيانات المتداخلة**:
   ```dart
   final profile = asMap(data['profile']);
   final services = asMap(data['services']);
   final location = asMap(data['location']);
   ```

2. **استخراج الاسم** (مع بدائل متعددة):
   ```dart
   services['shopName'] ?? 
   data['ownerName'] ?? 
   data['name'] ?? 
   'متجر'
   ```

3. **استخراج المدينة** (مع بدائل):
   ```dart
   location['city'] ?? 
   location['address'] ?? 
   data['city'] ?? 
   ''
   ```

4. **استخراج التقييم**:
   ```dart
   (data['rating'] is num) ? (data['rating'] as num).toDouble() : 0.0
   ```

5. **استخراج التخصص**:
   ```dart
   services['specialization'] ?? 
   data['specialization'] ?? 
   ''
   ```

6. **إنشاء كائن Tailor**:
   ```dart
   Tailor(
     id: doc.id,
     name: name,
     city: cityOrAddress.isEmpty ? '—' : cityOrAddress,
     rating: rating,
     tags: specialization.isEmpty ? [] : [specialization],
   )
   ```

### معالجة الأخطاء:
- إذا فشل التحويل → يُرجع بيانات افتراضية
- طباعة رسالة خطأ في console

---

## 5️⃣ النموذج: Tailor Model

### الموقع: `lib/features/tailors/models/tailor.dart`

### البنية:
```dart
class Tailor {
  final String id;
  final String name;
  final String city;
  final double rating;
  final List<String> tags;
  final String? imageUrl;
}
```

---

## 6️⃣ عرض البطاقة: TailorRowCard

### الموقع: `lib/features/tailors/widgets/tailor_row_card.dart`

### المكونات المعروضة:

#### أ) الصورة:
- الحجم: 84×84
- المصدر: `NetworkImage` (URL) أو `AssetImage` (path محلي)
- fallback: أيقونة placeholder

#### ب) زر "المتجر":
- موضع: أسفل الصورة (يسار)
- النقر: `onStoreTap`

#### ج) المعلومات:
1. **الاسم**: بخط عريض
2. **شارة "pro"**: خلفية فاتحة
3. **زر المفضلة**: `FavoriteButton`
4. **التخصص** (badge): إذا موجود
5. **التقييم**: نجمة + الرقم + (عدد المراجعات)
6. **الرقائق (Chips)**:
   - المدينة (📍)
   - زمن الوصول (⏱️) - إذا موجود
   - الرسوم (💰) - إذا موجود

### التفاعل:
- **النقر على البطاقة**: `onTap` → يفتح `TailorStoreScreen`
- **النقر على زر "المتجر"**: `onStoreTap` → يفتح `TailorShopScreen`

---

## 7️⃣ التحديث اليدوي: _refreshTailors()

### الوظيفة:
1. تفعيل الشبكة: `FirebaseService.refreshData()`
2. جلب البيانات مباشرة: `getTailorsQuery().get()`
3. طباعة عدد المحلات في console
4. عرض رسالة نجاح/خطأ

---

## 📋 ملخص الشروط المطلوبة في Firestore

### ⚠️ شروط إلزامية:
- Collection باسم: `tailors`
- حقل: `isActive: true` (للمحلات المراد عرضها)
- حقل: `createdAt: Timestamp` (للترتيب)

### ✅ حقول موصى بها:
- `profile.avatar` أو `avatar` أو `imageUrl` (لصورة المتجر)
- `services.shopName` أو `ownerName` أو `name` (لاسم المتجر)
- `location.city` أو `city` (للمدينة)
- `rating` (للتقييم)
- `services.specialization` أو `specialization` (للتخصص)
- `services.totalOrders` أو `totalOrders` (لعدد المراجعات)

### 🔑 Index مطلوب في Firestore:
```
Collection: tailors
Fields: isActive (Ascending), createdAt (Descending)
```

**ملاحظة**: إذا لم يكن الـ index موجوداً، سيستخدم الكود query بدون `where`.

---

## 🐛 المشاكل المحتملة والحلول

### 1️⃣ لا توجد محلات معروضة:
- **السبب**: Collection فارغة أو `isActive: false`
- **الحل**: تأكد من وجود محلات مع `isActive: true`

### 2️⃣ خطأ "Index required":
- **السبب**: Firestore يحتاج index لـ `where + orderBy`
- **الحل**: أنشئ index أو اترك الكود يستخدم fallback

### 3️⃣ الصور لا تظهر:
- **السبب**: `imageUrl` فارغ أو غير صحيح
- **الحل**: تأكد من صحة الروابط في Firestore

### 4️⃣ البيانات غير مكتملة:
- **السبب**: الحقول المطلوبة غير موجودة
- **الحل**: الكود يستخدم بدائل، لكن يفضل إضافة جميع الحقول

---

## 📊 إحصائيات Debug

الكود يطبع المعلومات التالية في console:
- `📊 عدد محلات الخياطة: X`
- `⚠️ لا توجد محلات في collection "tailors"`
- `❌ خطأ في جلب محلات الخياطة: ...`
- `❌ خطأ في تحويل وثيقة المحل: ...`

---

## 🎯 النتيجة النهائية

القائمة تعرض:
- ✅ جميع المحلات النشطة (`isActive: true`)
- ✅ مرتبة حسب `createdAt` (الأحدث أولاً)
- ✅ تحديث فوري عند التغيير في Firestore
- ✅ معالجة شاملة للأخطاء
- ✅ واجهة مستخدم جذابة مع skeleton loading

