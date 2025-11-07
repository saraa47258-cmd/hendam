import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/address_model.dart';
import '../services/address_service.dart';

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

    if (!authProvider.isAuthenticated) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(title: const Text('عناويني')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_on_outlined,
                    size: 64, color: cs.onSurfaceVariant),
                const SizedBox(height: 16),
                Text('يرجى تسجيل الدخول لإدارة عناوينك',
                    style: tt.titleMedium),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => context.push('/login'),
                  icon: const Icon(Icons.login_rounded),
                  label: const Text('تسجيل الدخول'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                            'عناويني',
                            style: tt.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'أضف وعدّل عناوين الشحن والاستلام',
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
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return _ErrorState(
                message: 'حدث خطأ في جلب العناوين',
                details: snapshot.error.toString(),
                onRetry: () => setState(() {}),
              );
            }

            final addresses = snapshot.data ?? [];

            if (addresses.isEmpty) {
              return _EmptyState(onCreate: _openAddressSheet);
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
              itemBuilder: (context, index) {
                final address = addresses[index];
                return _AddressTile(
                  address: address,
                  onEdit: () => _openAddressSheet(existing: address),
                  onDelete: () => _confirmDelete(address.id),
                  onMakeDefault: () => _service.setDefault(address.id),
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
          label: const Text('إضافة عنوان'),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('حذف العنوان'),
          content: const Text('هل أنت متأكد من حذف هذا العنوان؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('حذف'),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true) {
      await _service.deleteAddress(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('تم حذف العنوان'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  Future<void> _openAddressSheet({AddressModel? existing}) async {
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
            ? 'تم إضافة العنوان بنجاح'
            : 'تم تحديث العنوان بنجاح'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ));
    }
  }
}

class _AddressTile extends StatelessWidget {
  final AddressModel address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onMakeDefault;

  const _AddressTile({
    required this.address,
    required this.onEdit,
    required this.onDelete,
    required this.onMakeDefault,
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
                  child: Text('افتراضي',
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
                  const PopupMenuItem(value: 'edit', child: Text('تعديل')),
                  if (!address.isDefault)
                    const PopupMenuItem(
                        value: 'default', child: Text('تعيين كافتراضي')),
                  const PopupMenuItem(value: 'delete', child: Text('حذف')),
                ],
                icon: Icon(Icons.more_vert_rounded,
                    color: cs.onSurfaceVariant),
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

  const _EmptyState({required this.onCreate});

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
            Text('لا توجد عناوين بعد',
                style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('أضف عنوانك لتسهيل عملية التوصيل والدفع',
                textAlign: TextAlign.center,
                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add_location_alt_rounded),
              label: const Text('إضافة عنوان جديد'),
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

  const _ErrorState({
    required this.message,
    required this.details,
    required this.onRetry,
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
              label: const Text('إعادة المحاولة'),
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

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _labelCtrl = TextEditingController(text: existing?.label ?? 'المنزل');
    _nameCtrl = TextEditingController(text: existing?.recipientName ?? '');
    _phoneCtrl = TextEditingController(text: existing?.phone ?? '');
    _cityCtrl = TextEditingController(text: existing?.city ?? '');
    _areaCtrl = TextEditingController(text: existing?.area ?? '');
    _streetCtrl = TextEditingController(text: existing?.street ?? '');
    _buildingCtrl = TextEditingController(text: existing?.building ?? '');
    _directionsCtrl =
        TextEditingController(text: existing?.additionalDirections ?? '');
    _isDefault = existing?.isDefault ?? false;
  }

  @override
  void dispose() {
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
    return Directionality(
      textDirection: TextDirection.rtl,
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
                widget.existing == null ? 'إضافة عنوان جديد' : 'تعديل العنوان',
                style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text('يرجى إدخال بيانات عنوان دقيقة',
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
              const SizedBox(height: 12),
              _buildField(
                controller: _labelCtrl,
                label: 'اسم العنوان (مثال: المنزل، المكتب)',
                icon: Icons.bookmark_rounded,
                validator: _notEmpty,
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildField(
                      controller: _nameCtrl,
                      label: 'اسم المستلم',
                      icon: Icons.person_rounded,
                      validator: _notEmpty,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildField(
                      controller: _phoneCtrl,
                      label: 'رقم الهاتف',
                      icon: Icons.phone_rounded,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'أدخل رقم الهاتف';
                        }
                        if (value.trim().length < 7) {
                          return 'رقم غير صالح';
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
                      label: 'المدينة / المحافظة',
                      icon: Icons.location_city_rounded,
                      validator: _notEmpty,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildField(
                      controller: _areaCtrl,
                      label: 'المنطقة / الولاية',
                      icon: Icons.location_on_rounded,
                      validator: _notEmpty,
                    ),
                  ),
                ],
              ),
              _buildField(
                controller: _streetCtrl,
                label: 'الشارع / الشقة',
                icon: Icons.signpost_rounded,
                validator: _notEmpty,
              ),
              _buildField(
                controller: _buildingCtrl,
                label: 'المبنى / رقم المنزل (اختياري)',
                icon: Icons.home_work_rounded,
              ),
              _buildField(
                controller: _directionsCtrl,
                label: 'إرشادات إضافية (اختياري)',
                icon: Icons.map_outlined,
                minLines: 2,
                maxLines: 3,
              ),
              const SizedBox(height: 8),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: _isDefault,
                title: const Text('تعيين كعنوان افتراضي'),
                onChanged: (value) => setState(() => _isDefault = value),
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
                  label: Text(widget.existing == null ? 'حفظ العنوان' : 'تحديث العنوان'),
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

  String? _notEmpty(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'هذا الحقل مطلوب';
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
      if (mounted) Navigator.pop(context, true);
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }
}


