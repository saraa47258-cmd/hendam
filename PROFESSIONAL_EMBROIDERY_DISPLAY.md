# ✨ عرض احترافي لتصاميم التطريز والألوان

## 🎯 **المشكلة:**
عند وجود عدد كبير من تصاميم التطريز والألوان، يصبح العرض التقليدي:
- ❌ مزدحم ومربك
- ❌ يتطلب scroll طويل
- ❌ صعب التصفح
- ❌ غير احترافي

## ✅ **الحل الاحترافي:**

### 1. **عرض التصاميم بنظام PageView**

#### التصميم:
```
┌─────────────────────────────────────┐
│  ✨ تصاميم التطريز المتاحة         │
│                                     │
│  [📷]  [📷]  [📷]                  │
│  تطريز  تطريز  تطريز              │
│  +2.5   +3.0   +1.5               │
│                                     │
│  [📷]  [📷]  [📷]                  │
│  تطريز  تطريز  تطريز              │
│  +1.0   +2.0   +2.5               │
│                                     │
│  ●●●○○  (مؤشرات الصفحات)          │
│                                     │
│  [📊 عرض جميع التصاميم (24)]      │
└─────────────────────────────────────┘
```

#### المميزات:
- ✅ **PageView**: 6 تصاميم لكل صفحة (3×2)
- ✅ **مؤشرات**: دوائر تظهر عدد الصفحات
- ✅ **زر "عرض الكل"**: يظهر عند أكثر من 12 تصميم
- ✅ **Swipe**: سحب أفقي للتنقل بين الصفحات

### 2. **Bottom Sheet لجميع التصاميم**

عند الضغط على "عرض جميع التصاميم":

```
┌─────────────────────────────────────┐
│  ⎯  (handle)                        │
│                                     │
│  ✨ جميع تصاميم التطريز (24)    ✕ │
│                                     │
│  [📷] [📷] [📷]                    │
│  [📷] [📷] [📷]                    │
│  [📷] [📷] [📷]                    │
│  [📷] [📷] [📷]                    │
│  [📷] [📷] [📷]                    │
│  ...                                │
│  (scrollable)                       │
└─────────────────────────────────────┘
```

#### المميزات:
- ✅ **DraggableScrollableSheet**: قابل للسحب
- ✅ **Grid 3×n**: عرض منظم
- ✅ **Scroll**: تمرير سلس
- ✅ **Handle bar**: مؤشر السحب
- ✅ **Auto-close**: يغلق بعد الاختيار

### 3. **عرض الألوان بنظام Carousel**

#### للألوان القليلة (≤ 12 لون):
```
┌─────────────────────────────────────┐
│  🎨 لون خيط التطريز                │
│                                     │
│  ⭕⭕⭕✓⭕⭕⭕⭕                      │
│  ⭕⭕⭕⭕                            │
└─────────────────────────────────────┘
```

#### للألوان الكثيرة (> 12 لون):
```
┌─────────────────────────────────────┐
│  🎨 لون خيط التطريز    [🎨 50 لون]│
│                                     │
│  ⭕  ⭕  ⭕  ⭕  ⭕  ⭕             │
│  ⭕  ✓  ⭕  ⭕  ⭕  ⭕  →           │
│  ⭕  ⭕  ⭕  ⭕  ⭕  ⭕             │
│                                     │
│  (scroll horizontal)                │
└─────────────────────────────────────┘
```

#### المميزات:
- ✅ **Horizontal ListView**: مجموعات من 6 ألوان
- ✅ **زر العداد**: يظهر عدد الألوان
- ✅ **Scroll**: سلس وسريع

### 4. **Bottom Sheet لجميع الألوان**

عند الضغط على عدد الألوان:

```
┌─────────────────────────────────────┐
│  ⎯  (handle)                        │
│                                     │
│  🎨 جميع ألوان خيط التطريز (50) ✕ │
│                                     │
│  ⭕⭕⭕⭕⭕⭕                        │
│  ⭕⭕✓⭕⭕⭕                        │
│  ⭕⭕⭕⭕⭕⭕                        │
│  ⭕⭕⭕⭕⭕⭕                        │
│  ...                                │
│  (scrollable)                       │
└─────────────────────────────────────┘
```

#### المميزات:
- ✅ **Grid 6×n**: 6 أعمدة
- ✅ **أزرار كبيرة**: سهلة الضغط
- ✅ **Haptic**: اهتزاز عند الاختيار
- ✅ **Auto-close**: يغلق بعد الاختيار

## 📊 **الكود:**

### 1. **PageView للتصاميم:**

```dart
// عرض 6 تصاميم لكل صفحة
SizedBox(
  height: 280,
  child: Column(
    children: [
      Expanded(
        child: PageView.builder(
          itemCount: (designs.length / 6).ceil(),
          itemBuilder: (context, pageIndex) {
            final startIndex = pageIndex * 6;
            final endIndex = (startIndex + 6).clamp(0, designs.length);
            final pageDesigns = designs.sublist(startIndex, endIndex);
            
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.85,
              ),
              itemCount: pageDesigns.length,
              itemBuilder: (context, indexInPage) {
                // عرض التصميم
              },
            );
          },
        ),
      ),
      
      // مؤشرات الصفحات
      if (designs.length > 6)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            (designs.length / 6).ceil(),
            (index) => Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cs.primary.withOpacity(0.3),
              ),
            ),
          ),
        ),
    ],
  ),
),

// زر "عرض الكل"
if (designs.length > 12)
  OutlinedButton.icon(
    onPressed: () => _showAllEmbroideryDesigns(...),
    icon: Icon(Icons.grid_view_rounded),
    label: Text('عرض جميع التصاميم (${designs.length})'),
  ),
```

### 2. **Bottom Sheet للتصاميم:**

```dart
static void _showAllEmbroideryDesigns(
  BuildContext context,
  List<EmbroideryDesign> designs,
  EmbroideryDesign? selectedEmbroidery,
  ValueChanged<EmbroideryDesign?> onSelected,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.onSurfaceVariant.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // العنوان
              Text('جميع تصاميم التطريز (${designs.length})'),
              
              // Grid
              Expanded(
                child: GridView.builder(
                  controller: scrollController,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                  ),
                  itemCount: designs.length,
                  itemBuilder: (context, index) {
                    // عرض التصميم
                  },
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}
```

### 3. **Horizontal Carousel للألوان:**

```dart
SizedBox(
  height: options.length > 12 ? 110 : null,
  child: options.length > 12
      ? ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: (options.length / 6).ceil(),
          itemBuilder: (context, pageIndex) {
            final startIndex = pageIndex * 6;
            final endIndex = (startIndex + 6).clamp(0, options.length);
            final pageColors = options.sublist(startIndex, endIndex);
            
            return Wrap(
              direction: Axis.vertical,
              spacing: 12,
              children: pageColors.map((c) {
                // عرض اللون
              }).toList(),
            );
          },
        )
      : Wrap(
          spacing: 12,
          children: options.map((c) {
            // عرض اللون
          }).toList(),
        ),
),
```

### 4. **Bottom Sheet للألوان:**

```dart
static void _showAllColors(
  BuildContext context,
  List<Color> colors,
  Color selectedColor,
  ValueChanged<Color> onColorSelected,
) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            // Handle bar
            // العنوان: 'جميع ألوان خيط التطريز (${colors.length})'
            
            // Grid 6 أعمدة
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  childAspectRatio: 1,
                ),
                itemCount: colors.length,
                itemBuilder: (context, index) {
                  final c = colors[index];
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onColorSelected(c);
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: c,
                        border: Border.all(...),
                      ),
                      child: sel ? Icon(Icons.check_rounded) : null,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}
```

## 🎨 **المميزات الكاملة:**

### التصاميم:
- ✅ **PageView**: 6 تصاميم/صفحة
- ✅ **Swipe**: انتقال سلس
- ✅ **مؤشرات**: دوائر للصفحات
- ✅ **زر "الكل"**: عند > 12 تصميم
- ✅ **Bottom Sheet**: عرض شامل
- ✅ **DraggableScrollable**: قابل للسحب
- ✅ **Grid 3×n**: منظم
- ✅ **Auto-close**: بعد الاختيار

### الألوان:
- ✅ **Smart Display**: حسب العدد
- ✅ **Horizontal Scroll**: للألوان الكثيرة
- ✅ **مجموعات**: 6 ألوان/مجموعة
- ✅ **زر العداد**: يظهر العدد
- ✅ **Bottom Sheet**: Grid 6×n
- ✅ **Haptic Feedback**: اهتزاز
- ✅ **Auto-close**: بعد الاختيار

## 📱 **تجربة المستخدم:**

### السيناريو 1: القليل من التصاميم (< 6)
```
→ عرض عادي Grid 3×2
→ لا مؤشرات
→ لا زر "الكل"
```

### السيناريو 2: تصاميم متوسطة (6-12)
```
→ PageView مع مؤشرات
→ Swipe للتنقل
→ لا زر "الكل"
```

### السيناريو 3: تصاميم كثيرة (> 12)
```
→ PageView مع مؤشرات
→ زر "عرض الكل" ✨
→ Bottom Sheet شامل
```

### السيناريو 4: ألوان قليلة (≤ 12)
```
→ Wrap عادي
→ جميع الألوان ظاهرة
```

### السيناريو 5: ألوان كثيرة (> 12)
```
→ Horizontal Carousel
→ زر عداد الألوان
→ Bottom Sheet للكل
```

## 🚀 **النتيجة:**

**عرض احترافي يدعم أي عدد من التصاميم والألوان! 🎨**

- ✅ **مرن**: يتكيف مع العدد
- ✅ **سلس**: PageView + Scroll
- ✅ **منظم**: Grids احترافية
- ✅ **سريع**: Bottom Sheets
- ✅ **جميل**: تصميم أنيق
- ✅ **عملي**: سهل الاستخدام
- ✅ **ذكي**: يظهر فقط ما تحتاجه

**التطبيق جاهز لأي عدد من التصاميم والألوان! ✨**

