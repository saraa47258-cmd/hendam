import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/address_model.dart';
import '../services/address_service.dart';
import '../../../shared/widgets/skeletons.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/state/draft_store.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  final _service = AddressService();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final authProvider = context.watch<AuthProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final l10n = AppLocalizations.of(context)!;
    final textDirection =
        localeProvider.isRtl ? TextDirection.rtl : TextDirection.ltr;

    if (!authProvider.isAuthenticated) {
      return Directionality(
        textDirection: textDirection,
        child: Scaffold(
          appBar: AppBar(title: Text(l10n.myAddressesTitle)),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_on_outlined,
                    size: 64, color: cs.onSurfaceVariant),
                const SizedBox(height: 16),
                Text(l10n.pleaseLoginToManageAddresses, style: tt.titleMedium),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => context.push('/login'),
                  icon: const Icon(Icons.login_rounded),
                  label: Text(l10n.login),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Directionality(
      textDirection: textDirection,
      child: Scaffold(
        backgroundColor: cs.surface,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(72),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  cs.primary.withOpacity(0.92),
                  cs.secondary.withOpacity(0.75),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            size: 20, color: Colors.white),
                        onPressed: () async {
                          final localNavigator = Navigator.of(context);
                          if (await localNavigator.maybePop()) return;
                          final rootNavigator =
                              Navigator.of(context, rootNavigator: true);
                          if (rootNavigator != localNavigator &&
                              await rootNavigator.maybePop()) {
                            return;
                          }
                          if (!mounted) return;
                          context.pop();
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            l10n.myAddressesTitle,
                            style: tt.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.addAndEditAddresses,
                            style:
                                tt.bodySmall?.copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: StreamBuilder<List<AddressModel>>(
          stream: _service.streamAddresses(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const _AddressSkeletonList();
            }

            if (snapshot.hasError) {
              return _ErrorState(
                message: l10n.errorFetchingAddresses,
                details: snapshot.error.toString(),
                onRetry: () => setState(() {}),
                l10n: l10n,
              );
            }

            final addresses = snapshot.data ?? [];

            if (addresses.isEmpty) {
              return _EmptyState(onCreate: _openAddressSheet, l10n: l10n);
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
              itemBuilder: (context, index) {
                final address = addresses[index];
                return _AddressTile(
                  address: address,
                  onEdit: () => _openAddressSheet(existing: address),
                  onDelete: () => _confirmDelete(address.id, l10n),
                  onMakeDefault: () => _service.setDefault(address.id),
                  l10n: l10n,
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemCount: addresses.length,
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _openAddressSheet(),
          icon: const Icon(Icons.add_location_alt_rounded),
          label: Text(l10n.addAddressButton),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(String id, AppLocalizations l10n) async {
    final localeProvider = context.read<LocaleProvider>();
    final textDirection =
        localeProvider.isRtl ? TextDirection.rtl : TextDirection.ltr;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Directionality(
        textDirection: textDirection,
        child: AlertDialog(
          title: Text(l10n.deleteAddressTitle),
          content: Text(l10n.confirmDeleteAddressMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: Text(l10n.delete),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true) {
      await _service.deleteAddress(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l10n.addressDeleted),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  Future<void> _openAddressSheet({AddressModel? existing}) async {
    final l10n = AppLocalizations.of(context)!;

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _AddressFormSheet(
        existing: existing,
        service: _service,
      ),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(existing == null
            ? l10n.addressAddedSuccess
            : l10n.addressUpdatedSuccess),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ));
    }
  }
}

class _AddressSkeletonList extends StatelessWidget {
  const _AddressSkeletonList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
      itemCount: 3,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => const _AddressSkeletonCard(),
    );
  }
}

class _AddressSkeletonCard extends StatelessWidget {
  const _AddressSkeletonCard();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: SkeletonLine(width: double.infinity, height: 18)),
              SizedBox(width: 12),
              SkeletonLine(width: 60, height: 18),
            ],
          ),
          SizedBox(height: 10),
          SkeletonLine(width: 180, height: 14),
          SizedBox(height: 8),
          SkeletonLine(width: 220, height: 14),
          SizedBox(height: 12),
          SkeletonLine(width: double.infinity, height: 12),
          SizedBox(height: 6),
          SkeletonLine(width: double.infinity, height: 12),
        ],
      ),
    );
  }
}

class _AddressTile extends StatelessWidget {
  final AddressModel address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onMakeDefault;
  final AppLocalizations l10n;

  const _AddressTile({
    required this.address,
    required this.onEdit,
    required this.onDelete,
    required this.onMakeDefault,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: address.isDefault ? cs.primary : cs.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  address.label,
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              if (address.isDefault)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: cs.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(l10n.defaultLabel,
                      style: tt.labelSmall?.copyWith(color: cs.primary)),
                ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      onEdit();
                      break;
                    case 'default':
                      onMakeDefault();
                      break;
                    case 'delete':
                      onDelete();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(value: 'edit', child: Text(l10n.editLabel)),
                  if (!address.isDefault)
                    PopupMenuItem(
                        value: 'default', child: Text(l10n.setAsDefaultLabel)),
                  PopupMenuItem(value: 'delete', child: Text(l10n.deleteLabel)),
                ],
                icon: Icon(Icons.more_vert_rounded, color: cs.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(address.recipientName,
              style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          _InfoRow(icon: Icons.phone_rounded, text: address.phone),
          const SizedBox(height: 4),
          _InfoRow(
              icon: Icons.location_on_outlined,
              text:
                  '${address.city}، ${address.area}، ${address.street}، ${address.building}'),
          if (address.additionalDirections.isNotEmpty) ...[
            const SizedBox(height: 4),
            _InfoRow(
                icon: Icons.map_outlined, text: address.additionalDirections),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: cs.onSurfaceVariant),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreate;
  final AppLocalizations l10n;

  const _EmptyState({required this.onCreate, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_city_rounded,
                size: 72, color: cs.onSurfaceVariant),
            const SizedBox(height: 20),
            Text(l10n.noAddressesYetTitle,
                style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(l10n.addAddressForDelivery,
                textAlign: TextAlign.center,
                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add_location_alt_rounded),
              label: Text(l10n.addAddressButton),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final String details;
  final VoidCallback onRetry;
  final AppLocalizations l10n;

  const _ErrorState({
    required this.message,
    required this.details,
    required this.onRetry,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 72, color: cs.error),
            const SizedBox(height: 16),
            Text(message,
                style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(details,
                textAlign: TextAlign.center,
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.retryButton),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressFormSheet extends StatefulWidget {
  final AddressModel? existing;
  final AddressService service;

  const _AddressFormSheet({required this.service, this.existing});

  @override
  State<_AddressFormSheet> createState() => _AddressFormSheetState();
}

class _AddressFormSheetState extends State<_AddressFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _labelCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _areaCtrl;
  late final TextEditingController _streetCtrl;
  late final TextEditingController _buildingCtrl;
  late final TextEditingController _directionsCtrl;
  bool _isDefault = false;
  bool _processing = false;
  bool _initialized = false;
  Timer? _draftTimer;
  String? _draftKey;
  bool _restoringDraft = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    final userId = context.read<AuthProvider>().currentUser?.uid;
    _draftKey = DraftStore.scopedKey(
      'address:${existing?.id ?? 'new'}',
      userId: userId,
    );
    _labelCtrl = TextEditingController(text: existing?.label ?? '');
    _nameCtrl = TextEditingController(text: existing?.recipientName ?? '');
    _phoneCtrl = TextEditingController(text: existing?.phone ?? '');
    _cityCtrl = TextEditingController(text: existing?.city ?? '');
    _areaCtrl = TextEditingController(text: existing?.area ?? '');
    _streetCtrl = TextEditingController(text: existing?.street ?? '');
    _buildingCtrl = TextEditingController(text: existing?.building ?? '');
    _directionsCtrl =
        TextEditingController(text: existing?.additionalDirections ?? '');
    _isDefault = existing?.isDefault ?? false;
    for (final controller in [
      _labelCtrl,
      _nameCtrl,
      _phoneCtrl,
      _cityCtrl,
      _areaCtrl,
      _streetCtrl,
      _buildingCtrl,
      _directionsCtrl,
    ]) {
      controller.addListener(_scheduleDraftSave);
    }
    Future.microtask(_loadDraft);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized && widget.existing == null && _labelCtrl.text.isEmpty) {
      final l10n = AppLocalizations.of(context);
      if (l10n != null) {
        _labelCtrl.text = l10n.homeLabel;
      }
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _draftTimer?.cancel();
    _labelCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _cityCtrl.dispose();
    _areaCtrl.dispose();
    _streetCtrl.dispose();
    _buildingCtrl.dispose();
    _directionsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final localeProvider = context.watch<LocaleProvider>();
    final l10n = AppLocalizations.of(context)!;
    final textDirection =
        localeProvider.isRtl ? TextDirection.rtl : TextDirection.ltr;

    return Directionality(
      textDirection: textDirection,
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          top: 8,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.existing == null
                    ? l10n.addNewAddressTitle
                    : l10n.editAddressTitle,
                style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(l10n.enterAccurateAddressData,
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
              const SizedBox(height: 12),
              _buildField(
                controller: _labelCtrl,
                label: l10n.addressLabelExample,
                icon: Icons.bookmark_rounded,
                validator: (v) => _notEmpty(v, l10n),
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildField(
                      controller: _nameCtrl,
                      label: l10n.recipientNameLabel,
                      icon: Icons.person_rounded,
                      validator: (v) => _notEmpty(v, l10n),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildField(
                      controller: _phoneCtrl,
                      label: l10n.phoneNumberLabel,
                      icon: Icons.phone_rounded,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l10n.enterPhoneNumber;
                        }
                        if (value.trim().length < 7) {
                          return l10n.invalidPhoneNumber;
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildField(
                      controller: _cityCtrl,
                      label: l10n.cityProvinceLabel,
                      icon: Icons.location_city_rounded,
                      validator: (v) => _notEmpty(v, l10n),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildField(
                      controller: _areaCtrl,
                      label: l10n.areaWilayaLabel,
                      icon: Icons.location_on_rounded,
                      validator: (v) => _notEmpty(v, l10n),
                    ),
                  ),
                ],
              ),
              _buildField(
                controller: _streetCtrl,
                label: l10n.streetApartmentLabel,
                icon: Icons.signpost_rounded,
                validator: (v) => _notEmpty(v, l10n),
              ),
              _buildField(
                controller: _buildingCtrl,
                label: l10n.buildingHouseNumberOptional,
                icon: Icons.home_work_rounded,
              ),
              _buildField(
                controller: _directionsCtrl,
                label: l10n.additionalDirectionsOptional,
                icon: Icons.map_outlined,
                minLines: 2,
                maxLines: 3,
              ),
              const SizedBox(height: 8),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: _isDefault,
                title: Text(l10n.setAsDefaultAddress),
                onChanged: (value) {
                  setState(() => _isDefault = value);
                  _scheduleDraftSave();
                },
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _processing ? null : _submit,
                  icon: _processing
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(cs.onPrimary),
                          ),
                        )
                      : const Icon(Icons.check_circle_rounded),
                  label: Text(widget.existing == null
                      ? l10n.saveAddress
                      : l10n.updateAddress),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int minLines = 1,
    int maxLines = 1,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        minLines: minLines,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: cs.primary),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  String? _notEmpty(String? value, AppLocalizations l10n) {
    if (value == null || value.trim().isEmpty) {
      return l10n.thisFieldRequired;
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _processing = true);

    final existing = widget.existing;
    final base = AddressModel(
      id: existing?.id ?? '',
      userId: existing?.userId ?? '',
      label: _labelCtrl.text.trim(),
      recipientName: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      city: _cityCtrl.text.trim(),
      area: _areaCtrl.text.trim(),
      street: _streetCtrl.text.trim(),
      building: _buildingCtrl.text.trim(),
      additionalDirections: _directionsCtrl.text.trim(),
      isDefault: _isDefault,
      createdAt: existing?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      if (existing == null) {
        await widget.service.addAddress(base);
      } else {
        await widget.service.updateAddress(base);
      }
      await _clearDraft();
      if (mounted) Navigator.pop(context, true);
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  Future<void> _loadDraft() async {
    final key = _draftKey;
    if (key == null) return;
    final data = await DraftStore.read(key);
    if (data == null) return;
    _restoringDraft = true;
    final label = data['label'];
    final name = data['name'];
    final phone = data['phone'];
    final city = data['city'];
    final area = data['area'];
    final street = data['street'];
    final building = data['building'];
    final directions = data['directions'];
    if (label is String) _labelCtrl.text = label;
    if (name is String) _nameCtrl.text = name;
    if (phone is String) _phoneCtrl.text = phone;
    if (city is String) _cityCtrl.text = city;
    if (area is String) _areaCtrl.text = area;
    if (street is String) _streetCtrl.text = street;
    if (building is String) _buildingCtrl.text = building;
    if (directions is String) _directionsCtrl.text = directions;
    final isDefault = data['isDefault'];
    if (isDefault is bool) _isDefault = isDefault;
    _restoringDraft = false;
    if (mounted) setState(() {});
  }

  void _scheduleDraftSave() {
    if (_restoringDraft) return;
    final key = _draftKey;
    if (key == null) return;
    _draftTimer?.cancel();
    _draftTimer = Timer(const Duration(milliseconds: 300), () {
      DraftStore.write(key, {
        'label': _labelCtrl.text,
        'name': _nameCtrl.text,
        'phone': _phoneCtrl.text,
        'city': _cityCtrl.text,
        'area': _areaCtrl.text,
        'street': _streetCtrl.text,
        'building': _buildingCtrl.text,
        'directions': _directionsCtrl.text,
        'isDefault': _isDefault,
      });
    });
  }

  Future<void> _clearDraft() async {
    final key = _draftKey;
    if (key == null) return;
    await DraftStore.clear(key);
  }
}
