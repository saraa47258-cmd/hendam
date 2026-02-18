# RTL/LTR Layout Audit Report

**Project:** `hendam` (HINDAM)  
**Date:** 2026-02-17  
**Scope:** All `.dart` files under `lib/`

---

## Summary

| Severity | Count | Description |
|----------|-------|-------------|
| **CRITICAL** | 7 | Will break or look wrong in RTL |
| **MODERATE** | 14 | May look wrong or inconsistent in RTL |
| **LOW** | 20+ | Mostly redundant wrappers or cosmetic gradient alignments |

---

## ✅ App-Level Directionality Setup

**File:** `lib/app/app.dart` (lines 70–77)

```dart
final isRtl = currentLocale.languageCode == 'ar';
final textDirection = isRtl ? TextDirection.rtl : TextDirection.ltr;
return Directionality(
  textDirection: textDirection,
  child: ...
);
```

**Verdict:** ✅ **Properly configured.** The app wraps the entire widget tree with `Directionality` based on the current locale from `LocaleProvider`. This means individual screens should NOT need their own `Directionality` wrappers.

---

## 1. Hardcoded `EdgeInsets.only(left:/right:)` — CRITICAL

These use physical `left`/`right` instead of logical `start`/`end`. They will appear on the **wrong side** in RTL.

### CRITICAL Issues

| # | File | Line | Code | Fix |
|---|------|------|------|-----|
| 1 | `lib/features/tailors/presentation/tailoring_design_screen_backup.dart` | 1882 | `EdgeInsets.only(left: 12)` | → `EdgeInsetsDirectional.only(start: 12)` |
| 2 | `lib/features/tailors/presentation/tailoring_design_screen_backup.dart` | 2800 | `EdgeInsets.only(right: 16)` | → `EdgeInsetsDirectional.only(end: 16)` |
| 3 | `lib/features/catalog/presentation/abaya_services_screen.dart` | 477 | `EdgeInsets.only(left: _DS.sm)` (chip spacing) | → `EdgeInsetsDirectional.only(start: _DS.sm)` |
| 4 | `lib/features/catalog/presentation/abaya_services_screen.dart` | 837 | `EdgeInsets.only(left: 4)` (color dot margin) | → `EdgeInsetsDirectional.only(start: 4)` |
| 5 | `lib/features/catalog/presentation/abaya_services_screen.dart` | 852 | `EdgeInsets.only(left: 4)` (color count padding) | → `EdgeInsetsDirectional.only(start: 4)` |
| 6 | `lib/features/tailors/presentation/tailoring_design_screen.dart` | 2142–2144 | `EdgeInsets.only(left: _DesignTokens.spaceMD)` (design card spacing) | → `EdgeInsetsDirectional.only(start: _DesignTokens.spaceMD)` |

### MODERATE Issues (left == right, but using physical naming)

These have **equal** left/right values so they work correctly, but should use `EdgeInsets.symmetric` for clarity and safety.

| # | File | Line | Code | Fix |
|---|------|------|------|-----|
| 7 | `lib/shared/widgets/premium_app_bar.dart` | 123–126 | `EdgeInsets.only(left: 20, right: 20, top: ..., bottom: ...)` | → `EdgeInsets.symmetric(horizontal: 20) + top/bottom` or `EdgeInsets.fromLTRB(20, ..., 20, ...)` |
| 8 | `lib/features/tailors/presentation/widgets/interactive_body_map.dart` | 402–406 | `EdgeInsets.only(left: 16, right: 16, ...)` | Same |
| 9 | `lib/features/tailors/presentation/tailor_store_screen.dart` | 318–322 | `EdgeInsets.only(left: 16, right: 16, ...)` | Same |
| 10 | `lib/features/address/presentation/addresses_screen.dart` | 598–602 | `EdgeInsets.only(left: 16, right: 16, ...)` | Same |
| 11 | `lib/features/auth/presentation/login_screen.dart` | 433 | `EdgeInsets.only(left: 12, right: 12)` | → `EdgeInsets.symmetric(horizontal: 12)` |

---

## 2. `EdgeInsets.fromLTRB` with Asymmetric Left/Right — MODERATE

These have **different** L and R values, so padding will be mirrored incorrectly in RTL. Should use `EdgeInsetsDirectional.fromSTEB`.

| # | File | Line | Code | Fix |
|---|------|------|------|-----|
| 1 | `lib/features/shops/presentation/abaya_shops_screen.dart` | 450 | `EdgeInsets.fromLTRB(14, 14, 16, 14)` | → `EdgeInsetsDirectional.fromSTEB(14, 14, 16, 14)` |
| 2 | `lib/features/orders/presentation/my_orders_screen.dart` | 516 | `EdgeInsets.fromLTRB(12, 10, 14, 10)` | → `EdgeInsetsDirectional.fromSTEB(12, 10, 14, 10)` |
| 3 | `lib/features/catalog/presentation/merchant_products_screen.dart` | 561 | `EdgeInsets.fromLTRB(12, 10, 14, 10)` | → `EdgeInsetsDirectional.fromSTEB(12, 10, 14, 10)` |
| 4 | `lib/features/catalog/presentation/small_merchant_screen.dart` | 415 | `EdgeInsets.fromLTRB(12, 12, 14, 12)` | → `EdgeInsetsDirectional.fromSTEB(12, 12, 14, 12)` |

> **Note:** The remaining ~88 `EdgeInsets.fromLTRB` usages have **symmetric** L/R values (e.g., `fromLTRB(16, 12, 16, 24)`). These are functionally RTL-safe but ideally should migrate to `EdgeInsetsDirectional.fromSTEB` for consistency.

---

## 3. Hardcoded `Alignment` (left/right) — MODERATE/CRITICAL

### CRITICAL (used for content alignment)

| # | File | Line | Code | Fix |
|---|------|------|------|-----|
| 1 | `lib/core/widgets/text_widgets.dart` | 160 | `alignment: Alignment.centerLeft` | → `AlignmentDirectional.centerStart` |
| 2 | `lib/features/tailors/presentation/tailoring_design_screen_backup.dart` | 1389 | `alignment: Alignment.centerRight` (RTL text alignment) | → `AlignmentDirectional.centerEnd` |
| 3 | `lib/features/shops/presentation/abaya_shops_screen.dart` | 542 | `alignment: Alignment.centerRight` (rating badge) | → `AlignmentDirectional.centerEnd` |
| 4 | `lib/features/shops/presentation/abaya_shops_screen.dart` | 616 | `alignment: Alignment.centerRight` (icon+text) | → `AlignmentDirectional.centerEnd` |

### LOW (gradient begin/end — decorative)

~50 instances of `Alignment.topLeft` / `Alignment.bottomRight` etc. used in `LinearGradient(begin:..., end:...)`. These are decorative and do NOT need to flip for RTL. **No action required** unless visual design demands mirrored gradients.

Files with gradient alignments (non-exhaustive):
- `home_screen.dart`, `premium_app_bar.dart`, `tailor_tile.dart`, `tailor_card.dart`, `nearby_tailors_pretty.dart`, `fabric_step_widget.dart`, `embroidery_step_widget.dart`, `tailor_store_screen.dart`, `tailoring_design_screen.dart`, `shop_card.dart`, `service_card.dart`, `profile_screen.dart`, `my_favorites_screen.dart`, `signup_screen.dart`, `login_screen.dart`, `auth_welcome_screen.dart`, `edit_profile_screen.dart`, `addresses_screen.dart`, `men_services_screen.dart`, `merchant_products_screen.dart`, `section_services_screens.dart`, `service_list_card.dart`, `last_order_card.dart`

---

## 4. `Positioned(left:/right:)` — ✅ NONE FOUND

No instances of `Positioned(left:` or `Positioned(right:` found. **All clear.**

---

## 5. `TextDirection` Hardcoding

### ✅ Intentional / Acceptable

These hardcode `TextDirection.ltr` for **input fields** that always display LTR content (phone numbers, emails):

| File | Line | Context |
|------|------|---------|
| `login_screen.dart` | 403 | Phone number field |
| `signup_screen.dart` | 362, 416, 461, 528 | Phone/email input fields |
| `forgot_password_screen.dart` | 127 | Phone number field |
| `tailoring_design_screen.dart` | 1768 | Numeric display |
| `tailoring_design_screen_backup.dart` | 2578 | Numeric display |
| `interactive_body_map.dart` | 332 | `TextPainter` for Arabic measurement labels on canvas |

### ⚠️ MODERATE — Hardcoded RTL in non-input contexts

| # | File | Line | Code | Concern |
|---|------|------|------|---------|
| 1 | `tailoring_design_screen_backup.dart` | 420 | `textDirection: TextDirection.rtl` | Hardcoded RTL — won't work if app adds English UI |
| 2 | `tailoring_design_screen_backup.dart` | 688 | `textDirection: TextDirection.rtl` | Same |
| 3 | `tailoring_design_screen_backup.dart` | 4012, 4047 | `textDirection: TextDirection.rtl` | Same |
| 4 | `tailoring_design_screen.dart` | 2623 | `textDirection: TextDirection.rtl` | Same |

---

## 6. Redundant `Directionality` Wrappers — LOW

These screens wrap themselves with `Directionality(textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr)` even though `app.dart` already handles this at the root level. They are **redundant but harmless**.

| # | File | Lines |
|---|------|-------|
| 1 | `tailor_details_screen.dart` | 39 |
| 2 | `profile_screen.dart` | 170, 553, 933 |
| 3 | `order_tracking_screen.dart` | 27 |
| 4 | `my_orders_screen.dart` | 66, 100, 331, 769 |
| 5 | `my_favorites_screen.dart` | 29, 62 |
| 6 | `cart_screen.dart` | 29 |
| 7 | `login_screen.dart` | 176 |
| 8 | `signup_screen.dart` | 139 |
| 9 | `forgot_password_screen.dart` | 71 |
| 10 | `edit_profile_screen.dart` | 176 |
| 11 | `addresses_screen.dart` | 32, 57, 193, 595 |

**Recommendation:** Remove redundant wrappers. If a screen needs to override directionality for dialog/bottom-sheet contexts where the parent Directionality is lost (e.g., `showModalBottomSheet`, `showDialog`), keep those specific wrappers.

---

## 7. Icon Direction Issues

### ⚠️ CRITICAL — Inverted icon logic

| # | File | Line | Code | Issue |
|---|------|------|------|-------|
| 1 | `lib/features/auth/presentation/edit_profile_screen.dart` | 201 | `isRtl ? Icons.arrow_back : Icons.arrow_forward` | **Inverted!** Should be `isRtl ? Icons.arrow_forward : Icons.arrow_back` — In RTL, back (→); in LTR, back (←). Currently shows wrong arrow in both directions. |

### ✅ Correctly handled

| File | Line | Code |
|------|------|------|
| `login_screen.dart` | 585 | `isRtl ? Icons.arrow_forward_rounded : Icons.arrow_back_rounded` ✅ |
| `gift_design_screen.dart` | 761–763, 851–852, 1119–1120 | `Directionality.of(context) == TextDirection.rtl ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded` ✅ |
| `profile_screen.dart` | 840–841 | `isRtl ? Icons.arrow_back_ios_rounded : Icons.arrow_forward_ios_rounded` ✅ |

### MODERATE — Back icons that don't check RTL

These always show `Icons.arrow_back` (←) regardless of text direction. Per Material Design conventions, AppBar back buttons do NOT flip — so these are **acceptable** if inside `AppBar.leading`. However, they are **inconsistent** with the project's other screens that DO flip the icon.

| # | File | Line | Code |
|---|------|------|------|
| 1 | `tailor_details_screen.dart` | 49 | `Icons.arrow_back` (in SliverAppBar leading) |
| 2 | `order_tracking_screen.dart` | 66, 102 | `Icons.arrow_back` |
| 3 | `my_orders_screen.dart` | 72, 106, 775 | `Icons.arrow_back_rounded` |
| 4 | `product_preview_screen.dart` | 256, 479 | `Icons.arrow_back_rounded` |
| 5 | `merchant_products_screen.dart` | 327 | `Icons.arrow_back_rounded` |
| 6 | `abaya_services_screen.dart` | 362 | `Icons.arrow_back_rounded` |
| 7 | `profile_page_scaffold.dart` | 49 | `Icons.arrow_back_rounded` |
| 8 | `premium_app_bar.dart` | 238 | `Icons.arrow_back_rounded` |
| 9 | `my_favorites_screen.dart` | 99 | `Icons.arrow_back_ios_new_rounded` |
| 10 | `addresses_screen.dart` | 94 | `Icons.arrow_back_ios_new_rounded` |

### MODERATE — Forward chevrons that don't flip

These "go to details" chevrons should flip in RTL:

| # | File | Line | Code | Fix |
|---|------|------|------|-----|
| 1 | `last_order_card.dart` | 187 | `Icons.arrow_forward_ios_rounded` | Check `Directionality.of(context)` or use `Icons.chevron_right` |
| 2 | `nearby_tailors_pretty.dart` | 280 | `Icons.arrow_forward_ios_rounded` | Same |
| 3 | `abaya_measure_screen.dart` | 724 | `Icons.arrow_forward_rounded` | Check direction |
| 4 | `tailoring_design_screen_responsive.dart` | 437 | `Icons.arrow_forward_rounded` | Check direction |
| 5 | `tailoring_design_screen_backup.dart` | 1466 | `Icons.arrow_forward_rounded` | Check direction |
| 6 | `tailoring_design_screen.dart` | 781 | `Icons.arrow_forward_rounded` | Check direction |
| 7 | `merchant_products_screen.dart` | 1298 | `Icons.arrow_forward_rounded` | Check direction |
| 8 | `men_services_screen.dart` | 555 | `Icons.arrow_forward_rounded` | Check direction |

---

## 8. `CrossAxisAlignment` / `MainAxisAlignment` — ✅ ALL CLEAR

`CrossAxisAlignment.start/.end` and `MainAxisAlignment.start/.end` are **RTL-aware** by design and do not need changes.

---

## Priority Fix List

### P0 — Fix Immediately (CRITICAL)

1. **`edit_profile_screen.dart:201`** — Inverted back icon logic (shows wrong arrow in BOTH directions)
2. **`abaya_services_screen.dart:477,837,852`** — Chip spacing and color dots use `left` instead of `start`
3. **`tailoring_design_screen.dart:2142`** — Design card spacing uses `left` instead of `start`
4. **`text_widgets.dart:160`** — `Alignment.centerLeft` affects all text widget alignment app-wide

### P1 — Fix Soon (MODERATE)

5. **Asymmetric `EdgeInsets.fromLTRB`** in `abaya_shops_screen.dart:450`, `my_orders_screen.dart:516`, `merchant_products_screen.dart:561`, `small_merchant_screen.dart:415`
6. **`Alignment.centerRight`** in `abaya_shops_screen.dart:542,616` and `tailoring_design_screen_backup.dart:1389`
7. **Hardcoded `TextDirection.rtl`** in backup screen (5 instances)
8. **Inconsistent icon flipping** across screens — pick one convention and apply consistently

### P2 — Clean Up (LOW)

9. Remove ~15 redundant `Directionality` wrappers (or keep only for bottom sheets/dialogs)
10. Convert symmetric `EdgeInsets.fromLTRB` to `EdgeInsets.symmetric` for clarity
11. Convert `EdgeInsets.only(left: X, right: X)` to `EdgeInsets.symmetric(horizontal: X)`

---

## Notes

- The `tailoring_design_screen_backup.dart` file appears to be a backup/archived version. Consider whether it needs fixing or can be excluded.
- The project correctly uses `Directionality` at the app root (`app.dart`), which is the recommended approach.
- Phone number and email fields correctly force `TextDirection.ltr` — this is intentional and correct.
- The `interactive_body_map.dart` hardcoded `TextDirection.rtl` for `TextPainter` on canvas is acceptable since it's rendering Arabic measurement labels.
