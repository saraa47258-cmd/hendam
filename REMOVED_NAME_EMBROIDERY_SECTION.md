# ✅ حذف قسم "إضافة تطريز الاسم"

## 🗑️ **ما تم حذفه:**

تم حذف قسم "إضافة تطريز الاسم" بالكامل من صفحة التطريز.

### القسم المحذوف:

```
┌─────────────────────────────────────┐
│  ⚪ إضافة تطريز الاسم (+0.500 ر.ع) │
│     اكتب الاسم المطلوب في الملاحظات │
└─────────────────────────────────────┘
```

## 🔧 **التغييرات التقنية:**

### 1. **حذف المتغير:**
```dart
// حذف
bool _addNameEmbroidery = false;
```

### 2. **حذف من التسعير:**
```dart
// قبل
double get _price {
  double p = widget.basePriceOMR;
  if (_addNameEmbroidery) p += 0.500;  // ❌ محذوف
  p += (_embroideryLines * 0.250);
  return p;
}

// بعد
double get _price {
  double p = widget.basePriceOMR;
  p += (_embroideryLines * 0.250);
  return p;
}
```

### 3. **حذف من UI:**
```dart
// حذف هذا الجزء بالكامل
_ElegantFrame(
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  useBlur: false,
  child: SwitchListTile(
    value: addName,
    onChanged: (v) => onChanged(color, v, lines),
    title: const Text('إضافة تطريز الاسم (+0.500 ر.ع)'),
    subtitle: Text('اكتب الاسم المطلوب في الملاحظات'),
    contentPadding: EdgeInsets.zero,
  ),
),
```

### 4. **تحديث _EmbroideryStep:**

**قبل:**
```dart
class _EmbroideryStep extends StatelessWidget {
  final Color color;
  final bool addName;  // ❌ محذوف
  final int lines;
  final void Function(Color color, bool addName, int lines) onChanged;
  
  const _EmbroideryStep({
    required this.color,
    required this.addName,  // ❌ محذوف
    required this.lines,
    required this.onChanged,
  });
}
```

**بعد:**
```dart
class _EmbroideryStep extends StatelessWidget {
  final Color color;
  final int lines;
  final void Function(Color color, int lines) onChanged;
  
  const _EmbroideryStep({
    required this.color,
    required this.lines,
    required this.onChanged,
  });
}
```

### 5. **تحديث الاستدعاءات:**

**قبل:**
```dart
_EmbroideryStep(
  color: _embroideryColor,
  addName: _addNameEmbroidery,  // ❌ محذوف
  lines: _embroideryLines,
  onChanged: (color, addName, lines) => setState(() {
    _embroideryColor = color;
    _addNameEmbroidery = addName;  // ❌ محذوف
    _embroideryLines = lines;
  }),
)
```

**بعد:**
```dart
_EmbroideryStep(
  color: _embroideryColor,
  lines: _embroideryLines,
  onChanged: (color, lines) => setState(() {
    _embroideryColor = color;
    _embroideryLines = lines;
  }),
)
```

### 6. **تحديث استدعاءات onChanged داخل Widget:**

**قبل:**
```dart
onTap: () => onChanged(c, addName, lines),  // ❌
onChanged(color, addName, v);  // ❌
```

**بعد:**
```dart
onTap: () => onChanged(c, lines),  // ✅
onChanged(color, v);  // ✅
```

## 📊 **قبل وبعد:**

### قبل:
```
┌─────────────────────────────────────┐
│  🎨 لون خيط التطريز                │
│  ⭕⭕⭕⭕⭕⭕⭕⭕                      │
│                                     │
│  ⚪ إضافة تطريز الاسم (+0.500 ر.ع) │
│     اكتب الاسم المطلوب في الملاحظات │
│                                     │
│  عدد الخطوط الزخرفية                │
│  [-]  0  [+]                        │
└─────────────────────────────────────┘

السعر: 6.500 ر.ع (مع تطريز الاسم)
```

### بعد:
```
┌─────────────────────────────────────┐
│  ✨ تصاميم التطريز المتاحة         │
│  [صور التطريز...]                  │
│                                     │
│  🎨 لون خيط التطريز                │
│  ⭕⭕⭕⭕⭕⭕⭕⭕                      │
│                                     │
│  عدد الخطوط الزخرفية                │
│  [-]  0  [+]                        │
└─────────────────────────────────────┘

السعر: 6.000 ر.ع (بدون تطريز الاسم)
```

## ✅ **النتيجة:**

**تم حذف قسم تطريز الاسم بنجاح! ✨**

- ✅ حذف المتغير `_addNameEmbroidery`
- ✅ حذف من التسعير (-0.500 ر.ع)
- ✅ حذف UI Switch بالكامل
- ✅ تحديث signatures
- ✅ تحديث جميع الاستدعاءات
- ✅ لا أخطاء linter

**الآن صفحة التطريز تحتوي على:**
1. ✨ تصاميم التطريز المتاحة
2. 🎨 لون خيط التطريز
3. 📏 عدد الخطوط الزخرفية

**التطبيق جاهز! 🚀**

