# 🔐 نظام تسجيل الدخول والمصادقة - HINDAM

## 📋 نظرة عامة

تم إنشاء نظام مصادقة متكامل باستخدام Firebase Authentication و Firestore لتخزين بيانات المستخدمين.

---

## 🗂️ هيكل الملفات

```
lib/features/auth/
├── models/
│   └── user_model.dart           # نموذج بيانات المستخدم
├── services/
│   └── auth_service.dart         # خدمات المصادقة
├── providers/
│   └── auth_provider.dart        # إدارة حالة المستخدم
└── presentation/
    ├── auth_welcome_screen.dart  # صفحة الترحيب
    ├── login_screen.dart         # صفحة تسجيل الدخول
    ├── signup_screen.dart        # صفحة التسجيل
    └── forgot_password_screen.dart # صفحة نسيان كلمة المرور
```

---

## 📊 قاعدة البيانات (Firestore)

### Collection: `users`

يتم تخزين بيانات المستخدمين في collection اسمه `users` بالهيكل التالي:

```javascript
{
  "uid": "user_firebase_uid",           // معرف المستخدم الفريد من Firebase Auth
  "email": "user@example.com",          // البريد الإلكتروني
  "name": "اسم المستخدم",                // الاسم الكامل
  "phoneNumber": "+968 12345678",       // رقم الهاتف (اختياري)
  "photoUrl": "https://...",            // صورة المستخدم (اختياري)
  "createdAt": Timestamp,               // تاريخ إنشاء الحساب
  "updatedAt": Timestamp,               // تاريخ آخر تحديث (اختياري)
  "role": "customer",                   // نوع الحساب (customer, shopOwner, tailor, admin)
  "isActive": true                      // حالة الحساب (نشط/معطل)
}
```

### أنواع المستخدمين (UserRole):

1. **customer** - عميل
2. **shopOwner** - صاحب محل
3. **tailor** - خياط
4. **admin** - مدير

---

## 🛠️ المميزات المتوفرة

### ✅ المميزات الأساسية:

1. **تسجيل حساب جديد** - مع البريد الإلكتروني وكلمة المرور
2. **تسجيل الدخول** - باستخدام البريد الإلكتروني وكلمة المرور
3. **تسجيل الخروج** - Logout
4. **إعادة تعيين كلمة المرور** - عبر البريد الإلكتروني
5. **تحديث بيانات المستخدم**
6. **حذف الحساب**
7. **تخزين بيانات المستخدم في Firestore**

### 🎨 مميزات واجهة المستخدم:

- ✅ تصميم عصري وجميل
- ✅ دعم كامل للغة العربية (RTL)
- ✅ رسائل خطأ واضحة بالعربية
- ✅ Validation على جميع الحقول
- ✅ إظهار/إخفاء كلمة المرور
- ✅ Loading indicators
- ✅ Responsive design

---

## 🚀 كيفية الاستخدام

### 1. الوصول لصفحات المصادقة:

```dart
// صفحة الترحيب (Welcome)
context.push('/welcome');

// صفحة تسجيل الدخول
context.push('/login');

// صفحة التسجيل
context.push('/signup');

// صفحة نسيان كلمة المرور
context.push('/forgot-password');
```

### 2. استخدام AuthProvider في الكود:

```dart
import 'package:provider/provider.dart';
import 'package:hindam/features/auth/providers/auth_provider.dart';

// الحصول على المستخدم الحالي
final authProvider = context.watch<AuthProvider>();
final user = authProvider.currentUser;

// التحقق من تسجيل الدخول
if (authProvider.isAuthenticated) {
  // المستخدم مسجل دخول
}

// تسجيل دخول
await authProvider.signIn(
  email: 'user@example.com',
  password: 'password123',
);

// تسجيل حساب جديد
await authProvider.signUp(
  email: 'user@example.com',
  password: 'password123',
  name: 'اسم المستخدم',
  phoneNumber: '+968 12345678',
  role: UserRole.customer,
);

// تسجيل خروج
await authProvider.signOut();
```

### 3. استخدام AuthService مباشرة:

```dart
import 'package:hindam/features/auth/services/auth_service.dart';

final authService = AuthService();

// تسجيل دخول
final user = await authService.signIn(
  email: 'user@example.com',
  password: 'password123',
);

// الحصول على المستخدم الحالي
final currentUser = await authService.getCurrentUserData();

// إعادة تعيين كلمة المرور
await authService.resetPassword('user@example.com');
```

---

## 🔧 إعداد Firebase Security Rules

يجب تحديث قواعد Firestore Security Rules للسماح بالقراءة والكتابة:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // قواعد المستخدمين
    match /users/{userId} {
      // السماح بالقراءة للمستخدم نفسه فقط
      allow read: if request.auth != null && request.auth.uid == userId;
      
      // السماح بالكتابة عند إنشاء حساب جديد
      allow create: if request.auth != null && request.auth.uid == userId;
      
      // السماح بالتحديث للمستخدم نفسه فقط
      allow update: if request.auth != null && request.auth.uid == userId;
      
      // السماح بالحذف للمستخدم نفسه فقط
      allow delete: if request.auth != null && request.auth.uid == userId;
    }
    
    // قواعد باقي المجموعات (حسب احتياجك)
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

---

## 📱 إضافة زر تسجيل الدخول في التطبيق

### في صفحة Profile:

```dart
// في lib/features/profile/presentation/profile_screen.dart

// إذا لم يكن المستخدم مسجل دخول
if (!context.watch<AuthProvider>().isAuthenticated) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.person_outline, size: 80),
        SizedBox(height: 24),
        Text('يرجى تسجيل الدخول'),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => context.push('/login'),
          child: Text('تسجيل الدخول'),
        ),
      ],
    ),
  );
}

// إذا كان مسجل دخول
final user = context.watch<AuthProvider>().currentUser!;
return Column(
  children: [
    Text('مرحباً ${user.name}'),
    Text(user.email),
    ElevatedButton(
      onPressed: () => context.read<AuthProvider>().signOut(),
      child: Text('تسجيل الخروج'),
    ),
  ],
);
```

### في AppBar:

```dart
AppBar(
  title: Text('HINDAM'),
  actions: [
    Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isAuthenticated) {
          return IconButton(
            icon: CircleAvatar(
              child: Text(authProvider.currentUser!.name[0]),
            ),
            onPressed: () => context.push('/profile'),
          );
        } else {
          return TextButton(
            onPressed: () => context.push('/login'),
            child: Text('تسجيل الدخول'),
          );
        }
      },
    ),
  ],
)
```

---

## 🎯 أمثلة على الاستخدام المتقدم

### حماية صفحات معينة (Require Authentication):

```dart
// في router.dart
GoRoute(
  path: '/orders',
  name: 'orders',
  builder: (context, state) {
    // التحقق من تسجيل الدخول
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isAuthenticated) {
      // إعادة التوجيه لصفحة تسجيل الدخول
      return const LoginScreen();
    }
    return const OrdersScreen();
  },
)
```

### عرض محتوى مختلف حسب نوع المستخدم:

```dart
final user = context.watch<AuthProvider>().currentUser;

if (user?.role == UserRole.admin) {
  // محتوى خاص بالمدير
  return AdminPanel();
} else if (user?.role == UserRole.tailor) {
  // محتوى خاص بالخياط
  return TailorDashboard();
} else {
  // محتوى خاص بالعميل
  return CustomerHome();
}
```

### الاستماع لتغييرات حالة المستخدم:

```dart
StreamBuilder<User?>(
  stream: authService.authStateChanges,
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      // المستخدم مسجل دخول
      return HomeScreen();
    } else {
      // المستخدم غير مسجل دخول
      return AuthWelcomeScreen();
    }
  },
)
```

---

## 🐛 معالجة الأخطاء

جميع الأخطاء يتم معالجتها وإرجاع رسائل واضحة بالعربية:

- **كلمة المرور ضعيفة جداً** - `weak-password`
- **البريد الإلكتروني مستخدم بالفعل** - `email-already-in-use`
- **البريد الإلكتروني غير صحيح** - `invalid-email`
- **لا يوجد حساب بهذا البريد** - `user-not-found`
- **كلمة المرور غير صحيحة** - `wrong-password`
- **فشل الاتصال بالإنترنت** - `network-request-failed`

---

## 📊 Analytics Events

يتم تسجيل الأحداث التالية في Firebase Analytics:

1. `sign_up` - عند إنشاء حساب جديد
2. `login` - عند تسجيل الدخول
3. `logout` - عند تسجيل الخروج
4. `password_reset` - عند طلب إعادة تعيين كلمة المرور
5. `account_deleted` - عند حذف الحساب

---

## ✅ Validation Rules

### البريد الإلكتروني:
- يجب أن يكون بصيغة صحيحة (example@domain.com)
- لا يمكن أن يكون فارغاً

### كلمة المرور:
- 6 أحرف على الأقل
- لا يمكن أن تكون فارغة

### الاسم:
- 3 أحرف على الأقل
- لا يمكن أن يكون فارغاً

### رقم الهاتف:
- اختياري
- يمكن تركه فارغاً

---

## 🔄 تحديث بيانات المستخدم

```dart
// تحديث بيانات المستخدم
final updatedUser = currentUser.copyWith(
  name: 'اسم جديد',
  phoneNumber: '+968 87654321',
  updatedAt: DateTime.now(),
);

await authProvider.updateUser(updatedUser);
```

---

## 🚫 حذف الحساب

```dart
// حذف الحساب
bool success = await authProvider.deleteAccount();

if (success) {
  // تم حذف الحساب بنجاح
  context.go('/welcome');
}
```

---

## 📝 ملاحظات مهمة

1. **Firebase Authentication** مطلوب تفعيله في Firebase Console
2. **Email/Password** sign-in method يجب أن يكون مفعل
3. **Firestore** يجب أن يكون مفعل
4. **Security Rules** يجب تحديثها للسماح بالقراءة والكتابة
5. جميع البيانات محفوظة بشكل آمن في Firebase
6. كلمات المرور مشفرة بواسطة Firebase Auth

---

## 🎉 جاهز للاستخدام!

النظام جاهز تماماً للاستخدام. يمكنك الآن:

1. تشغيل التطبيق: `flutter run`
2. الانتقال لصفحة `/welcome`
3. إنشاء حساب جديد أو تسجيل الدخول
4. البيانات ستحفظ تلقائياً في Firebase

---

## 📞 الدعم

إذا واجهت أي مشاكل:

1. تحقق من إعدادات Firebase Console
2. تحقق من Security Rules في Firestore
3. تحقق من أن Email/Password method مفعل في Authentication
4. راجع console logs للأخطاء

---

**تم إنشاء النظام بواسطة: AI Assistant**  
**التاريخ: 2025**  
**الإصدار: 1.0.0**


