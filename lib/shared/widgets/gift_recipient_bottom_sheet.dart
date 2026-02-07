// lib/shared/widgets/gift_recipient_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hindam/l10n/app_localizations.dart';
import 'package:hindam/features/orders/models/order_model.dart';

/// ثوابت شكل موحّد لشاشة بيانات مستلم الهدية
class _Shape {
  static const double radius = 14.0;
  static const double spacing = 16.0;
  static const double paddingH = 20.0;
  static const double inputPaddingV = 16.0;
  static const double inputPaddingH = 16.0;
}

/// Bottom sheet لإدخال بيانات مستلم الهدية
class GiftRecipientBottomSheet extends StatefulWidget {
  final GiftRecipientDetails? initialData;
  final Function(GiftRecipientDetails) onSave;

  const GiftRecipientBottomSheet({
    super.key,
    this.initialData,
    required this.onSave,
  });

  /// عرض Bottom Sheet وإرجاع بيانات المستلم
  static Future<GiftRecipientDetails?> show(
    BuildContext context, {
    GiftRecipientDetails? initialData,
  }) async {
    GiftRecipientDetails? result;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => GiftRecipientBottomSheet(
        initialData: initialData,
        onSave: (data) {
          result = data;
          Navigator.of(ctx).pop();
        },
      ),
    );
    return result;
  }

  @override
  State<GiftRecipientBottomSheet> createState() =>
      _GiftRecipientBottomSheetState();
}

class _GiftRecipientBottomSheetState extends State<GiftRecipientBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _notesCtrl;
  late final TextEditingController _messageCtrl;
  bool _hidePrice = false;

  @override
  void initState() {
    super.initState();
    final data = widget.initialData;
    _nameCtrl = TextEditingController(text: data?.recipientName ?? '');
    _phoneCtrl = TextEditingController(text: data?.recipientPhone ?? '');
    _cityCtrl = TextEditingController(text: data?.city ?? '');
    _addressCtrl = TextEditingController(text: data?.address ?? '');
    _notesCtrl = TextEditingController(text: data?.deliveryNotes ?? '');
    _messageCtrl = TextEditingController(text: data?.giftMessage ?? '');
    _hidePrice = data?.hidePrice ?? false;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _cityCtrl.dispose();
    _addressCtrl.dispose();
    _notesCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();
      return;
    }

    final data = GiftRecipientDetails(
      recipientName: _nameCtrl.text.trim(),
      recipientPhone:
          _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      city: _cityCtrl.text.trim().isEmpty ? null : _cityCtrl.text.trim(),
      address:
          _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
      deliveryNotes:
          _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      giftMessage:
          _messageCtrl.text.trim().isEmpty ? null : _messageCtrl.text.trim(),
      hidePrice: _hidePrice,
    );

    HapticFeedback.lightImpact();
    widget.onSave(data);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(_Shape.radius + 6)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: cs.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.fromLTRB(_Shape.paddingH, _Shape.spacing,
                _Shape.paddingH, _Shape.spacing / 2),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(_Shape.radius),
                  ),
                  child: Icon(Icons.card_giftcard_rounded,
                      color: cs.primary, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.giftRecipientInfo,
                        style: tt.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                        ),
                      ),
                      Text(
                        l10n.enterGiftRecipientDetails,
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close, color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Form
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(_Shape.paddingH, _Shape.spacing,
                  _Shape.paddingH, _Shape.spacing + bottomPadding),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // اسم المستلم (مطلوب)
                    _buildTextField(
                      controller: _nameCtrl,
                      label: l10n.recipientName,
                      hint: l10n.enterRecipientName,
                      icon: Icons.person_outline,
                      required: true,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return l10n.recipientNameRequired;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: _Shape.spacing),

                    // رقم المستلم (مطلوب)
                    _buildTextField(
                      controller: _phoneCtrl,
                      label: l10n.phoneNumberLabel,
                      hint: l10n.enterPhoneNumber,
                      icon: Icons.phone_outlined,
                      required: true,
                      keyboardType: TextInputType.phone,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return l10n.thisFieldRequired;
                        }
                        // التحقق من صيغة رقم الهاتف العُماني
                        final phone = v.trim().replaceAll(RegExp(r'[^\d]'), '');
                        if (phone.length < 8) {
                          return l10n.invalidPhoneFormat;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: _Shape.spacing),

                    // المدينة / المحافظة (مطلوب)
                    _buildTextField(
                      controller: _cityCtrl,
                      label: l10n.recipientCity,
                      hint: l10n.enterCityOrGovernorate,
                      icon: Icons.location_city_outlined,
                      required: true,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return l10n.cityRequired;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: _Shape.spacing),

                    // العنوان الكامل (مطلوب)
                    _buildTextField(
                      controller: _addressCtrl,
                      label: l10n.recipientAddress,
                      hint: l10n.enterFullAddress,
                      icon: Icons.home_outlined,
                      required: true,
                      maxLines: 2,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return l10n.addressRequired;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: _Shape.spacing),

                    // ملاحظات التوصيل (اختياري)
                    _buildTextField(
                      controller: _notesCtrl,
                      label: l10n.deliveryNotesOptional,
                      hint: l10n.deliveryNotesExample,
                      icon: Icons.note_outlined,
                      required: false,
                      maxLines: 2,
                    ),
                    SizedBox(height: _Shape.spacing),

                    // رسالة التهنئة (اختياري)
                    _buildTextField(
                      controller: _messageCtrl,
                      label: l10n.giftMessageOptional,
                      hint: l10n.writeShortMessageToRecipient,
                      icon: Icons.message_outlined,
                      required: false,
                      maxLines: 3,
                    ),
                    SizedBox(height: _Shape.spacing + 4),

                    // خيار إخفاء السعر
                    Container(
                      padding: EdgeInsets.all(_Shape.spacing),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(_Shape.radius),
                        border: Border.all(
                          color: _hidePrice
                              ? cs.primary.withOpacity(0.5)
                              : cs.outlineVariant.withOpacity(0.5),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _hidePrice
                                  ? cs.primary.withOpacity(0.15)
                                  : cs.outlineVariant.withOpacity(0.3),
                              borderRadius:
                                  BorderRadius.circular(_Shape.radius - 2),
                            ),
                            child: Icon(
                              Icons.visibility_off_outlined,
                              size: 22,
                              color: _hidePrice ? cs.primary : cs.onSurface,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              l10n.hidePriceFromRecipient,
                              style: tt.bodyMedium?.copyWith(
                                color: cs.onSurface,
                                fontWeight: _hidePrice
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                          Switch(
                            value: _hidePrice,
                            onChanged: (v) {
                              HapticFeedback.selectionClick();
                              setState(() => _hidePrice = v);
                            },
                            activeTrackColor: cs.primary.withOpacity(0.6),
                            inactiveTrackColor: cs.outlineVariant,
                            activeThumbColor: Colors.white,
                            thumbColor: WidgetStateProperty.resolveWith<Color>(
                                (states) {
                              if (states.contains(WidgetState.selected)) {
                                return Colors.white;
                              }
                              return cs.surface;
                            }),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: _Shape.spacing + 8),

                    // زر الحفظ
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _submit,
                        icon: const Icon(Icons.check_circle_outline, size: 22),
                        label: Text(l10n.saveRecipient),
                        style: FilledButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              vertical: _Shape.inputPaddingV),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(_Shape.radius),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool required,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: tt.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
            if (required) ...[
              const SizedBox(width: 4),
              Text(
                '*',
                style: tt.bodyMedium?.copyWith(
                  color: cs.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: _Shape.spacing / 2),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 22, color: cs.onSurfaceVariant),
            filled: true,
            fillColor: cs.surfaceContainerLow,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_Shape.radius),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_Shape.radius),
              borderSide: BorderSide(
                color: cs.outlineVariant.withOpacity(0.6),
                width: 1.2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_Shape.radius),
              borderSide: BorderSide(color: cs.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_Shape.radius),
              borderSide: BorderSide(color: cs.error, width: 1.2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_Shape.radius),
              borderSide: BorderSide(color: cs.error, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: _Shape.inputPaddingH,
              vertical: _Shape.inputPaddingV,
            ),
          ),
        ),
      ],
    );
  }
}

/// Widget لعرض ملخص بيانات مستلم الهدية
class GiftRecipientSummaryCard extends StatelessWidget {
  final GiftRecipientDetails details;
  final VoidCallback? onEdit;

  const GiftRecipientSummaryCard({
    super.key,
    required this.details,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.all(_Shape.spacing),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cs.primaryContainer.withOpacity(0.3),
            cs.tertiaryContainer.withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(_Shape.radius),
        border: Border.all(
          color: cs.primary.withOpacity(0.3),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(_Shape.radius - 2),
                ),
                child: Icon(
                  Icons.card_giftcard_rounded,
                  color: cs.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.giftRecipientSummary,
                  style: tt.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
              ),
              if (onEdit != null)
                TextButton.icon(
                  onPressed: onEdit,
                  icon: Icon(Icons.edit_outlined, size: 16, color: cs.primary),
                  label: Text(
                    l10n.editRecipient,
                    style: TextStyle(color: cs.primary),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Details
          _buildDetailRow(
            context,
            Icons.person_outline,
            l10n.recipientName,
            details.recipientName,
          ),
          if (details.recipientPhone != null &&
              details.recipientPhone!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildDetailRow(
              context,
              Icons.phone_outlined,
              l10n.phoneNumberLabel,
              details.recipientPhone!,
            ),
          ],
          if (details.city != null && details.city!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildDetailRow(
              context,
              Icons.location_city_outlined,
              l10n.recipientCity,
              details.city!,
            ),
          ],
          if (details.address != null && details.address!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildDetailRow(
              context,
              Icons.home_outlined,
              l10n.recipientAddress,
              details.address!,
            ),
          ],
          if (details.giftMessage != null &&
              details.giftMessage!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(_Shape.spacing / 2 + 4),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(_Shape.radius - 2),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.format_quote, color: cs.primary, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      details.giftMessage!,
                      style: tt.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (details.hidePrice) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: cs.tertiary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.visibility_off_outlined,
                      size: 16, color: cs.tertiary),
                  const SizedBox(width: 6),
                  Text(
                    l10n.hidePriceFromRecipient,
                    style: tt.bodySmall?.copyWith(
                      color: cs.tertiary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: cs.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: tt.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: tt.bodyMedium?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
