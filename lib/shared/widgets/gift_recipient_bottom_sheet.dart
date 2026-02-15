// lib/shared/widgets/gift_recipient_bottom_sheet.dart
import 'package:flutter/material.dart';
import '../../features/orders/models/order_model.dart';
import '../../l10n/app_localizations.dart';

/// Bottom sheet لإدخال بيانات مستلم الهدية
class GiftRecipientBottomSheet extends StatefulWidget {
  final GiftRecipientDetails? initialData;
  final ValueChanged<GiftRecipientDetails>? onSave;

  const GiftRecipientBottomSheet({
    super.key,
    this.initialData,
    this.onSave,
  });

  /// يعرض Bottom Sheet ويعيد بيانات المستلم أو null إذا تم الإلغاء
  static Future<GiftRecipientDetails?> show(
    BuildContext context, {
    GiftRecipientDetails? initialData,
  }) {
    return showModalBottomSheet<GiftRecipientDetails>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => GiftRecipientBottomSheet(
        initialData: initialData,
        onSave: (details) => Navigator.of(ctx).pop(details),
      ),
    );
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
  late final TextEditingController _messageCtrl;
  late final TextEditingController _notesCtrl;
  bool _hidePrice = false;

  @override
  void initState() {
    super.initState();
    final d = widget.initialData;
    _nameCtrl = TextEditingController(text: d?.recipientName ?? '');
    _phoneCtrl = TextEditingController(text: d?.recipientPhone ?? '');
    _cityCtrl = TextEditingController(text: d?.city ?? '');
    _addressCtrl = TextEditingController(text: d?.address ?? '');
    _messageCtrl = TextEditingController(text: d?.giftMessage ?? '');
    _notesCtrl = TextEditingController(text: d?.deliveryNotes ?? '');
    _hidePrice = d?.hidePrice ?? false;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _cityCtrl.dispose();
    _addressCtrl.dispose();
    _messageCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final details = GiftRecipientDetails(
      recipientName: _nameCtrl.text.trim(),
      recipientPhone:
          _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      city: _cityCtrl.text.trim().isEmpty ? null : _cityCtrl.text.trim(),
      address:
          _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
      giftMessage:
          _messageCtrl.text.trim().isEmpty ? null : _messageCtrl.text.trim(),
      deliveryNotes:
          _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      hidePrice: _hidePrice,
    );
    widget.onSave?.call(details);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: const EdgeInsets.only(top: 48),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Title
                Row(
                  children: [
                    Icon(Icons.card_giftcard_rounded,
                        color: cs.primary, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      l10n.giftRecipientInfo,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.enterGiftRecipientDetails,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 20),

                // Recipient Name (required)
                TextFormField(
                  controller: _nameCtrl,
                  decoration: InputDecoration(
                    labelText: l10n.recipientName,
                    hintText: l10n.enterRecipientName,
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return l10n.recipientNameRequired;
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 14),

                // Recipient Phone (optional)
                TextFormField(
                  controller: _phoneCtrl,
                  decoration: InputDecoration(
                    labelText: l10n.recipientPhoneOptional,
                    prefixIcon: const Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 14),

                // Gift Message (optional)
                TextFormField(
                  controller: _messageCtrl,
                  decoration: InputDecoration(
                    labelText: l10n.giftMessageOptional,
                    prefixIcon: const Icon(Icons.message_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 2,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 14),

                // Delivery Notes (optional)
                TextFormField(
                  controller: _notesCtrl,
                  decoration: InputDecoration(
                    labelText: l10n.deliveryNotesOptional,
                    hintText: l10n.deliveryNotesExample,
                    prefixIcon: const Icon(Icons.note_alt_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 2,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 14),

                // Hide Price toggle
                SwitchListTile.adaptive(
                  value: _hidePrice,
                  onChanged: (v) => setState(() => _hidePrice = v),
                  title: Text(
                    l10n.hidePriceFromRecipient,
                    style: const TextStyle(fontSize: 14),
                  ),
                  secondary: const Icon(Icons.visibility_off_outlined),
                  contentPadding: EdgeInsets.zero,
                  activeColor: cs.primary,
                ),
                const SizedBox(height: 20),

                // Save button
                FilledButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.check_rounded),
                  label: Text(l10n.saveRecipient),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// بطاقة ملخص بيانات مستلم الهدية
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
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: cs.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.card_giftcard_rounded,
                  size: 18, color: cs.primary),
              const SizedBox(width: 6),
              Text(
                l10n.giftRecipientSummary,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: cs.primary,
                ),
              ),
              const Spacer(),
              if (onEdit != null)
                InkWell(
                  onTap: onEdit,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit_outlined,
                            size: 14, color: cs.primary),
                        const SizedBox(width: 4),
                        Text(
                          l10n.editRecipient,
                          style: TextStyle(
                            fontSize: 12,
                            color: cs.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          _infoRow(Icons.person_outline_rounded, details.recipientName),
          if (details.recipientPhone != null &&
              details.recipientPhone!.isNotEmpty)
            _infoRow(Icons.phone_outlined, details.recipientPhone!),
          if (details.city != null && details.city!.isNotEmpty)
            _infoRow(Icons.location_city_outlined, details.city!),
          if (details.address != null && details.address!.isNotEmpty)
            _infoRow(Icons.location_on_outlined, details.address!),
          if (details.giftMessage != null && details.giftMessage!.isNotEmpty)
            _infoRow(Icons.message_outlined, details.giftMessage!),
          if (details.deliveryNotes != null &&
              details.deliveryNotes!.isNotEmpty)
            _infoRow(Icons.note_alt_outlined, details.deliveryNotes!),
          if (details.hidePrice)
            _infoRow(Icons.visibility_off_outlined, l10n.hidePriceFromRecipient),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }
}
