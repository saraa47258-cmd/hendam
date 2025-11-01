# 🚀 البدء السريع - نظام المصادقة

## ✅ تم إنشاء ما يلي:

### 📱 الصفحات:
1. **صفحة الترحيب** - `/welcome` - اختيار بين تسجيل دخول أو إنشاء حساب
2. **تسجيل الدخول** - `/login` - البريد الإلكتروني وكلمة المرور
3. **إنشاء حساب** - `/signup` - تسجيل حساب جديد
4. **نسيت كلمة المرور** - `/forgot-password` - إعادة تعيين كلمة المرور

### 💾 قاعدة البيانات:
- **Collection:** `users` في Firestore
- يتم تخزين بيانات المستخدم تلقائياً عند التسجيل

### 👤 أنواع المستخدمين:
- عميل (Customer)
- صاحب محل (Shop Owner)
- خياط (Tailor)
- مدير (Admin)

---

## 🎯 الاستخدام الفوري

### 1️⃣ تجربة الصفحات:

```dart
// في أي مكان في التطبيق
ElevatedButton(
  onPressed: () => context.push('/welcome'),
  child: const Text('تسجيل الدخول'),
)
```

### 2️⃣ التحقق من المستخدم الحالي:

```dart
import 'package:provider/provider.dart';

// في أي widget
final authProvider = context.watch<AuthProvider>();

if (authProvider.isAuthenticated) {
  // مسجل دخول
  print('اسم المستخدم: ${authProvider.currentUser?.name}');
} else {
  // غير مسجل دخول
  context.push('/login');
}
```

### 3️⃣ إضافة زر تسجيل دخول في Profile:

```dart
// في lib/features/profile/presentation/profile_screen.dart

Consumer<AuthProvider>(
  builder: (context, authProvider, child) {
    if (!authProvider.isAuthenticated) {
      return ElevatedButton(
        onPressed: () => context.push('/login'),
        child: const Text('تسجيل الدخول'),
      );
    }
    
    return Column(
      children: [
        Text('مرحباً ${authProvider.currentUser!.name}'),
        ElevatedButton(
          onPressed: () => authProvider.signOut(),
          child: const Text('تسجيل الخروج'),
        ),
      ],
    );
  },
)
```

---

## ⚙️ إعداد Firebase (مهم!)

### 1. تفعيل Email/Password Authentication:

1. افتح [Firebase Console](https://console.firebase.google.com/project/thobi-40dc9)
2. اذهب إلى **Authentication**
3. اضغط على **Sign-in method**
4. فعّل **Email/Password**

### 2. تحديث Firestore Security Rules:

1. اذهب إلى **Firestore Database**
2. اضغط على **Rules**
3. أضف هذه القواعد:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // قواعد المستخدمين
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // باقي المجموعات
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

---

## 🧪 اختبار النظام

### 1. تشغيل التطبيق:
```bash
flutter run
```

### 2. الانتقال لصفحة الترحيب:
- افتح `/welcome`
- أو أضف زر في أي صفحة يفتح `/welcome`

### 3. إنشاء حساب تجريبي:
- اضغط "إنشاء حساب جديد"
- املأ البيانات:
  - الاسم: اسم تجريبي
  - البريد: test@example.com
  - كلمة المرور: 123456
  - النوع: عميل
- اضغط "إنشاء الحساب"

### 4. تحقق من Firebase:
- افتح Firebase Console
- اذهب إلى **Authentication** → سترى المستخدم الجديد
- اذهب إلى **Firestore** → سترى بيانات المستخدم في `users` collection

---

## 🎨 تخصيص الصفحات

### تغيير الألوان:
جميع الصفحات تستخدم Theme الموجود في `lib/app/theme.dart`

### تغيير النصوص:
كل النصوص موجودة في ملفات الصفحات ويمكن تعديلها مباشرة

### إضافة حقول جديدة:
1. عدّل `UserModel` في `lib/features/auth/models/user_model.dart`
2. عدّل الصفحة المناسبة (signup_screen.dart)
3. عدّل `AuthService` لحفظ البيانات الجديدة

---

## 📊 مراقبة البيانات

### في Firebase Console:

**Authentication:**
- عدد المستخدمين المسجلين
- آخر تسجيل دخول
- البريد الإلكتروني المستخدم

**Firestore (users collection):**
```
users/
  └── {userId}/
      ├── email: "user@example.com"
      ├── name: "اسم المستخدم"
      ├── phoneNumber: "+968 12345678"
      ├── role: "customer"
      ├── createdAt: Timestamp
      └── isActive: true
```

**Analytics:**
- sign_up events
- login events
- logout events

---

## 🔥 الخطوات التالية

### المقترحات:

1. **إضافة Google Sign-In** (اختياري)
2. **إضافة Facebook Sign-In** (اختياري)
3. **إضافة Phone Number Auth** (اختياري)
4. **حماية صفحات معينة** - عرض login إذا لم يكن مسجل دخول
5. **إضافة صورة ملف شخصي** - رفع صورة للمستخدم
6. **تعديل الملف الشخصي** - صفحة لتحديث البيانات
7. **قائمة بالمستخدمين** - للمدير فقط

---

## 📞 روابط مفيدة

- [Firebase Console - مشروعك](https://console.firebase.google.com/project/thobi-40dc9)
- [Firebase Auth Documentation](https://firebase.google.com/docs/auth)
- [Firestore Documentation](https://firebase.google.com/docs/firestore)
- [Provider Package](https://pub.dev/packages/provider)

---

## ✅ Checklist

- [x] تم إنشاء User Model
- [x] تم إنشاء Auth Service
- [x] تم إنشاء Auth Provider
- [x] تم إنشاء صفحة تسجيل الدخول
- [x] تم إنشاء صفحة التسجيل
- [x] تم إنشاء صفحة نسيان كلمة المرور
- [x] تم إنشاء صفحة الترحيب
- [x] تم إضافة Routes
- [x] تم دمج Firebase
- [x] تم إضافة Provider في التطبيق
- [ ] تفعيل Email/Password في Firebase Console
- [ ] تحديث Firestore Security Rules
- [ ] اختبار التطبيق

---

**🎉 النظام جاهز للاستخدام!**

فقط فعّل Email/Password في Firebase Console وحدّث Security Rules، ثم ابدأ الاختبار!


