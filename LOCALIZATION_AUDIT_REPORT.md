# HENDAM — Full Professional Localization Audit Report
### Production-Level App Review | Date: 2025

---

## Executive Summary

| Category | Critical | High | Medium | Low |
|---|---|---|---|---|
| 1. Missing Localization | 33 | — | 10 | 20+ |
| 2. Service Layer Safety | — | 18 | 16 | 45+ |
| 3. RTL/LTR Layout | 7 | — | 14 | 20+ |
| 4. Business Logic Risk | 3 | 3 | 2 | — |
| 5. Dead/Unused L10n Keys | — | — | 55+ | — |
| 6. Performance & Architecture | — | 1 | 1 | 28 |
| **TOTALS** | **43** | **22** | **98+** | **113+** |

### **Overall Score: 52 / 100** ⚠️

The localization migration achieved ~70% coverage. The remaining 30% contains critical business logic risks (pricing, order status), architectural inconsistencies (dual order models), and a significant number of dead localization keys indicating rushed migration with placeholder definitions.

---

## 🔴 PHASE 1 — Missing Localization (Hardcoded UI Strings)

### CRITICAL (33 items)

#### Currency Symbol `ر.ع` — 5 files
| # | File | Line | Code |
|---|---|---|---|
| 1 | [customer_orders_screen.dart](lib/features/orders/presentation/customer_orders_screen.dart#L299) | 299 | `'ر.ع ${...}'` |
| 2 | [customer_orders_screen.dart](lib/features/orders/presentation/customer_orders_screen.dart#L476) | 476 | `'${...} ر.ع'` |
| 3 | [order_details_screen.dart](lib/features/orders/presentation/order_details_screen.dart#L119) | 119 | `'${...} ر.ع'` |
| 4 | [product_preview_screen.dart](lib/features/catalog/presentation/product_preview_screen.dart#L211) | 211 | `'${...} ر.ع'` |
| 5 | [service_card.dart](lib/features/services/widgets/service_card.dart#L190) | 190 | `'${...} ر.ع'` |

**Fix:** Replace all with `l10n.currency(value)` or `l10n.omr` (already defined).

#### Open/Closed Status Labels — Hardcoded Arabic
| # | File | Line | Code |
|---|---|---|---|
| 6 | [shop_card.dart](lib/features/shops/widgets/shop_card.dart#L59) | 59 | `'مفتوح'` / `'مغلق'` |
| 7 | [tailor_card.dart](lib/features/tailors/widgets/tailor_card.dart#L415) | 415 | `'مفتوح الآن'` / `'مغلق'` |

**Fix:** Use `l10n.open` / `l10n.closed` or `l10n.openNow` / `l10n.closedNow`.

#### Distance Unit
| # | File | Line | Code |
|---|---|---|---|
| 8 | [tailor_card.dart](lib/features/tailors/widgets/tailor_card.dart#L102) | 102 | `'كم'` |
| 9 | [nearby_tailors_pretty.dart](lib/features/tailors/presentation/nearby_tailors_pretty.dart#L169) | 169 | `'كم'` |

**Fix:** Use `l10n.km`.

#### Fabric Type Pricing Labels
| # | File | Line | Code |
|---|---|---|---|
| 10 | [tailoring_design_screen.dart](lib/features/tailors/presentation/tailoring_design_screen.dart#L184-L185) | 184-185 | `'فاخر'` / `'شتوي'` |

#### Order Status Arabic switch/case
| # | File | Line | Code |
|---|---|---|---|
| 11-16 | [order_details_screen.dart](lib/features/orders/presentation/order_details_screen.dart#L184-L235) | 184-235 | 3 switch functions with hardcoded Arabic status strings |

#### Router Fallback Strings
| # | File | Line | Code |
|---|---|---|---|
| 17 | [router.dart](lib/app/router.dart#L128) | 128 | `'الخياط'` fallback |
| 18 | [router.dart](lib/app/router.dart#L141) | 141 | `'الخياط'` fallback |

#### Cart Status
| # | File | Line | Code |
|---|---|---|---|
| 19 | [cart_scope.dart](lib/core/state/cart_scope.dart#L253) | 253 | `status: 'قيد المعالجة'` |

#### Error Handler
| # | File | Line | Code |
|---|---|---|---|
| 20 | [error_handler.dart](lib/core/error/error_handler.dart#L55) | 55 | `'حدث خطأ'` |

#### Core Widgets
| # | File | Line | Code |
|---|---|---|---|
| 21 | [responsive_helpers.dart](lib/shared/widgets/responsive_helpers.dart#L134) | 134 | `'ابحث...'` (search hint) |
| 22 | [text_widgets.dart](lib/shared/widgets/text_widgets.dart#L87-L88) | 87-88 | `'عرض المزيد'` / `'عرض أقل'` |
| 23 | [responsive_image.dart](lib/shared/widgets/responsive_image.dart#L240) | 240 | `'إضافة صورة'` |

#### Measurement Guide
| # | File | Line | Code |
|---|---|---|---|
| 24 | [measurement_guide_dialog.dart](lib/features/tailors/presentation/widgets/measurement_guide_dialog.dart#L314) | 314 | Arabic tooltip text |

#### Admin Screen
| # | File | Line | Code |
|---|---|---|---|
| 25 | [tailor_fabric_admin_screen.dart](lib/features/tailors/presentation/tailor_fabric_admin_screen.dart#L344) | 344 | `'...لون متاح'` |

#### Model `labelAr` Extensions (always show Arabic)
| # | File | Line | Notes |
|---|---|---|---|
| 26-33 | [order_model.dart](lib/features/orders/models/order_model.dart#L395-L404) | 395-404 | `OrderStatus.labelAr` used without locale check in some screens |

### MODERATE (10 items)
- l10n fallback strings using `?? 'Arabic fallback'` in [tailoring_design_screen.dart](lib/features/tailors/presentation/tailoring_design_screen.dart) lines 2799, 2810
- Measurement map keys doubling as display labels in 3 files
- `gift_design_screen.dart` line 462 — `labelAr` without locale check

### MINOR (20+ items)
- Mock data in test files, backup files, color maps with Arabic keys

---

## 🔴 PHASE 2 — Service Layer Safety

### HIGH RISK (18 items)

#### Auth Service Firebase Error Messages
[auth_service.dart](lib/features/auth/services/auth_service.dart) — `_handleAuthException` method (lines 213-231) contains **10 hardcoded Arabic Firebase error messages** that bubble directly to UI:

| Code | Arabic Message |
|---|---|
| `wrong-password` | `'كلمة المرور غير صحيحة'` |
| `user-not-found` | `'لا يوجد حساب بهذا البريد'` |
| `email-already-in-use` | `'البريد الإلكتروني مستخدم بالفعل'` |
| `weak-password` | `'كلمة المرور ضعيفة جداً'` |
| `invalid-email` | `'البريد الإلكتروني غير صالح'` |
| `network-request-failed` | `'فشل الاتصال بالإنترنت'` |
| `too-many-requests` | `'محاولات كثيرة، حاول لاحقاً'` |
| `user-disabled` | `'هذا الحساب معطل'` |
| `operation-not-allowed` | `'هذه العملية غير مسموحة'` |
| `default` | `'حدث خطأ غير متوقع'` |

**Plus 4 thrown exception messages:**
- Line 44: `'فشل إنشاء الحساب'`
- Line 93: `'فشل تسجيل الدخول'`
- Line 196: `'لم يتم تسجيل الدخول'`
- Line 104: `'مستخدم جديد'` (fallback name)

**Plus:**
- [profile_photo_service.dart](lib/features/auth/services/profile_photo_service.dart#L33) — `'فشل رفع الصورة'`
- [firebase_service.dart](lib/core/services/firebase_service.dart#L42) — 4 Arabic init error messages

**Recommendation:** Return Firebase error codes, map to `l10n.*` keys in the presentation layer.

### MEDIUM RISK (16 items)
- [embroidery_service.dart](lib/features/tailors/services/embroidery_service.dart) — 8 hardcoded Arabic thread color names as fallback data
- [traders_service.dart](lib/features/catalog/services/traders_service.dart) — default category names in Arabic
- [tailor_services_service.dart](lib/features/tailors/services/tailor_services_service.dart#L55) — `'خدمة بدون اسم'`

### LOW RISK (45+ items)
- `debugPrint` / `print` statements with Arabic text — debug only, not user-facing

---

## 🔴 PHASE 3 — RTL/LTR Layout Integrity

### CRITICAL (7 items)

#### 1. Inverted Back Icon Logic
[edit_profile_screen.dart](lib/features/auth/presentation/edit_profile_screen.dart#L201) — line 201:
```dart
Icon(isRtl ? Icons.arrow_back : Icons.arrow_forward)
```
**BUG:** This is backwards. In RTL, the "back" arrow should be `arrow_forward` (pointing right). In LTR, it should be `arrow_back` (pointing left). Currently shows the **wrong arrow in BOTH directions**.

**Fix:** Swap the ternary: `Icon(isRtl ? Icons.arrow_forward : Icons.arrow_back)` or use `Icons.arrow_back` and let Flutter's Directionality handle it via `Icons.adaptive.arrow_back`.

#### 2-4. Hardcoded `EdgeInsets.only(left:)` in RTL screens
| File | Line | Issue |
|---|---|---|
| [abaya_services_screen.dart](lib/features/catalog/presentation/abaya_services_screen.dart#L477) | 477 | `EdgeInsets.only(left: 16)` |
| [abaya_services_screen.dart](lib/features/catalog/presentation/abaya_services_screen.dart#L837) | 837 | `EdgeInsets.only(left: 8)` |
| [abaya_services_screen.dart](lib/features/catalog/presentation/abaya_services_screen.dart#L852) | 852 | `EdgeInsets.only(left: 4)` |

**Fix:** Use `EdgeInsetsDirectional.only(start: X)`.

#### 5-7. Hardcoded `EdgeInsets.only(left:)` in tailoring screen
| File | Line |
|---|---|
| [tailoring_design_screen.dart](lib/features/tailors/presentation/tailoring_design_screen.dart#L2142) | 2142 |

**Fix:** Same — use `EdgeInsetsDirectional`.

### MODERATE (14 items)
- Asymmetric `EdgeInsets.fromLTRB` in multiple widgets
- Hardcoded `Alignment.centerRight` / `Alignment.centerLeft` in [text_widgets.dart](lib/shared/widgets/text_widgets.dart#L160)

### LOW (20+ items)
- 28+ redundant `Directionality` wrappers across screens. Since `app.dart` already wraps the entire app in a `Directionality` widget (line 76), individual screen-level wrappers are unnecessary and add widget tree overhead.

**Affected files:** tailor_details_screen, tailoring_design_screen, profile_screen (3x), order_tracking_screen, my_orders_screen (4x), my_favorites_screen (2x), cart_screen, signup_screen, login_screen, forgot_password_screen, edit_profile_screen, addresses_screen (4x)

### VERIFIED CORRECT ✅
- [app.dart](lib/app/app.dart#L76) — Root `Directionality` wrapper properly configured based on `currentLocale.languageCode == 'ar'`

---

## 🔴 PHASE 4 — Business Logic Risk

### CRITICAL (3 items)

#### 1. Fabric-Type Pricing Uses Arabic String Comparison
**Risk: Customers charged wrong price**

| File | Lines |
|---|---|
| [tailoring_design_screen.dart](lib/features/tailors/presentation/tailoring_design_screen.dart#L184-L185) | 184-185 |
| [tailoring_design_screen_responsive.dart](lib/features/tailors/presentation/tailoring_design_screen_responsive.dart#L91-L92) | 91-92 |

```dart
if (_fabricType == 'فاخر') price += 1.500;   // "premium"
if (_fabricType == 'شتوي') price += 0.800;   // "winter"
```

If fabric names are ever translated or changed, pricing silently breaks.

**Fix:** Use locale-independent identifiers (`'premium'`, `'winter'`, `'standard'`) or a quality enum.

#### 2. Cart Stores Arabic Status String
[cart_scope.dart](lib/core/state/cart_scope.dart#L253):
```dart
status: 'قيد المعالجة'  // Hardcoded Arabic
```
But `submitCartOrder()` at line 311 uses `'status': 'pending'` for Firestore. **Two incompatible status systems** in one file.

#### 3. Order Details Switches on Raw Arabic/English Strings
[order_details_screen.dart](lib/features/orders/presentation/order_details_screen.dart#L182-L243) — 3 switch functions match `'قيد المعالجة'`, `'Processing'`, `'قيد الشحن'`, `'Shipping'` etc. Neither matches the Firestore `OrderModel` enum values (`pending`, `accepted`).

### HIGH (3 items)

#### 4. Merchant Product Category Filtering Uses Arabic
[merchant_products_screen.dart](lib/features/catalog/presentation/merchant_products_screen.dart#L631-L657) — `_getChipLabel()` matches both Arabic and English category strings with **multiple Arabic spellings** (e.g., `'أقمشة'` vs `'الأقمشة'`).

#### 5. Tailor Orders Shows `labelAr` Regardless of Locale
[tailor_orders_screen.dart](lib/features/orders/presentation/tailor_orders_screen.dart#L332) — Always shows Arabic status even in English mode.

#### 6. Two Incompatible Order Models
| Model | Status Type | Storage |
|---|---|---|
| `Order` (cart) | `String` | Arabic locally, English in Firestore |
| `OrderModel` (orders) | `OrderStatus` enum | Enum name in Firestore |

### MEDIUM (2 items)

#### 7. Hardcoded Currency in 11 Non-L10n Files
Found `ر.ع` in customer_orders_screen, order_details_screen, product_preview_screen, service_card, service_list_card, tailoring_design_screen_backup.

#### 8. Hardcoded Arabic Error Messages in Business Logic
- [product_preview_screen.dart](lib/features/catalog/presentation/product_preview_screen.dart#L86): `'المنتج غير موجود'`
- [tailoring_design_screen_backup.dart](lib/features/tailors/presentation/tailoring_design_screen_backup.dart#L206): `'حدث خطأ: $e'`

---

## 🟠 PHASE 5 — Dead/Unused Localization Keys

**55+ localization keys** defined in `app_localizations.dart` but **never used** anywhere in `lib/` (excluding the l10n files themselves):

### Greetings & Welcome (9 keys)
`goodMorning`, `goodAfternoon`, `goodEvening`, `goodNight`, `hello`, `dearCustomer`, `welcomeBack`, `justNow`, `tomorrow`

### Time (2 keys)
`today`, `tomorrow`

### Cart & Shopping (7 keys)
`shoppingCart`, `subtotal`, `deliveryFee`, `checkout`, `removeFromCart`, `updateCart`, `startShopping`

### Empty States (4 keys)
`emptyOrders`, `emptyFavorites`, `emptyAddresses`, `noServicesAvailable`

### Errors & Messages (8 keys)
`sessionExpired`, `noInternet`, `serverError`, `connectionError`, `warning`, `info`, `noData`, `noResults`

### Validation (5 keys)
`rememberMe`, `invalidInput`, `invalidPhone`, `passwordTooShort`, `pleaseEnterValue`, `pleaseEnterValidPhone`

### Tailoring Design (10 keys)
`selectFabricFirst`, `selectDesignFirst`, `enterMeasurementsFirst`, `fabricPrice`, `tailoringCost`, `embroideryCost`, `orderReview`, `selectedFabric`, `selectedDesign`, `embroideryType`

### Confirmation Dialogs (3 keys)
`confirmDelete`, `confirmCancel`, `areYouSure`

### Addresses (11 keys)
`addAddress`, `editAddress`, `deleteAddress`, `noAddressesYet`, `addressTitle`, `city`, `street`, `building`, `apartment`, `defaultAddress`, `setAsDefault`

### Favorites (2 keys)
`addedToFavorites`, `noFavoritesYet`

### Actions (6 keys)
`apply`, `reset`, `seeMore`, `seeLess`, `buyNow`, `copied`, `cartEmpty`, `cartEmptyMessage`

### Miscellaneous (3 keys)
`softTailoring`, `saveExperimental`, `enterValidMeasurement`, `rating` (note: `ratingLabel` IS used)

### Dead Files
| File | Status |
|---|---|
| [tailoring_design_screen_backup.dart](lib/features/tailors/presentation/tailoring_design_screen_backup.dart) | **DEAD** — ~4000+ line backup file, not imported anywhere. Contains un-migrated hardcoded Arabic strings. Should be deleted. |

---

## 🟡 PHASE 6 — Performance & Architecture

### VERIFIED CORRECT ✅
| Item | Status | Details |
|---|---|---|
| LocaleProvider initialization | ✅ | Pre-initialized in `main.dart` before `runApp()` |
| Provider binding | ✅ | `ChangeNotifierProvider.value(value:)` — no recreation |
| Consumer rebuild scope | ✅ | `Consumer<LocaleProvider>` wraps only `MaterialApp.router` |
| Directionality binding | ✅ | Root-level in `app.dart` builder, locale-aware |
| Locale persistence | ✅ | SharedPreferences with `app_locale` + `use_device_locale` keys |
| Supported locales | ✅ | Properly declared in both `LocaleProvider` and `AppLocalizations` |
| Delegate loading | ✅ | `SynchronousFuture` — no async delay |

### HIGH RISK (1 item)

#### CartState Created Inside `build()`
[app.dart](lib/app/app.dart#L20) — line 20:
```dart
Widget build(BuildContext context) {
  final cartState = cart.CartState();  // ⚠️ Recreated on every build
```
Every time `Consumer<LocaleProvider>` triggers a rebuild (locale change), a **new `CartState` is created**, losing all cart data.

**Fix:** Move `CartState` to a `late final` field or create it in the constructor of `HendamApp`.

### MEDIUM RISK (1 item)

#### `addPostFrameCallback` for CartState & AuthProvider Init
Lines 23-36 in `app.dart` — `loadData()` and `initialize()` are called via `addPostFrameCallback` inside `build()`. On locale changes, these callbacks fire again, potentially causing double-initialization or state corruption.

**Fix:** Use `StatefulWidget` with `initState()`, or move initialization to `main.dart`.

### LOW (28 items)

#### Redundant Directionality Wrappers
28+ screens individually wrap their content in `Directionality(textDirection: ...)` despite `app.dart` already providing this at the root level. Each wrapper:
- Adds unnecessary widget tree depth
- Queries `Provider.of<LocaleProvider>` or `Localizations.localeOf(context)` redundantly
- Risk of direction mismatch if individual wrappers use different logic

**Affected screens (non-exhaustive):** profile_screen (3x), my_orders_screen (4x), addresses_screen (4x), my_favorites_screen (2x), cart_screen, login_screen, signup_screen, forgot_password_screen, edit_profile_screen, order_tracking_screen, tailor_details_screen (2x), tailoring_design_screen (2x)

---

## Priority Fix Order

| Priority | Phase | Issue | Impact |
|---|---|---|---|
| **P0** | 4 | Fabric pricing uses Arabic string comparison | **Money calculation wrong** |
| **P0** | 4 | Cart stores Arabic status + Firestore stores English | **Order status mismatch** |
| **P0** | 4 | Order details switch on raw Arabic strings | **UI status broken** |
| **P0** | 6 | CartState recreated in build() | **Cart data lost on locale change** |
| **P1** | 2 | Auth error messages hardcoded Arabic | Errors untranslated |
| **P1** | 3 | Inverted back arrow icon logic | Wrong arrow direction |
| **P1** | 4 | Dual Order models with incompatible status | Data inconsistency |
| **P1** | 4 | `labelAr` hardcoded on tailor orders screen | Wrong language |
| **P2** | 1 | Currency `ر.ع` in 5 UI files | Display-only |
| **P2** | 1 | Open/Closed hardcoded Arabic | Display-only |
| **P2** | 3 | Hardcoded EdgeInsets.only(left:) | RTL layout broken |
| **P3** | 5 | 55+ dead localization keys | Code bloat |
| **P3** | 6 | 28 redundant Directionality wrappers | Performance overhead |
| **P4** | 5 | Dead backup file (4000+ lines) | Disk waste |

---

## Score Breakdown

| Category | Max Points | Score | Notes |
|---|---|---|---|
| String Coverage | 25 | 15 | ~70% migrated, 33 critical remaining |
| Service Layer | 15 | 8 | Auth errors critical, debug prints acceptable |
| RTL/LTR Correctness | 20 | 12 | Root config excellent, 7 critical layout bugs |
| Business Logic Safety | 20 | 5 | 3 critical pricing/status issues |
| Code Hygiene (dead code) | 10 | 5 | 55+ unused keys, 1 dead backup file |
| Architecture & Performance | 10 | 7 | Locale system excellent, CartState bug |
| **TOTAL** | **100** | **52** | |

---

## Recommendations Summary

1. **Immediate (P0):** Fix fabric pricing comparison, unify order status to enum, move CartState out of build()
2. **Short-term (P1):** Refactor auth error handling to use l10n, fix inverted back arrow, eliminate dual Order models
3. **Medium-term (P2):** Replace all hardcoded `ر.ع` with `l10n.currency()`, fix EdgeInsets to directional
4. **Long-term (P3-P4):** Remove 55+ dead l10n keys, delete backup file, remove redundant Directionality wrappers

---

*Report generated by comprehensive automated audit across all `lib/` files.*
