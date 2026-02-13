// lib/features/auth/presentation/edit_profile_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hindam/features/auth/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:hindam/l10n/app_localizations.dart';
import 'package:hindam/core/providers/locale_provider.dart';
import 'package:hindam/core/state/draft_store.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  Timer? _draftTimer;
  String? _draftKey;
  bool _restoringDraft = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _draftKey = DraftStore.scopedKey('edit-profile', userId: user?.uid);
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');
    _nameController.addListener(_scheduleDraftSave);
    _phoneController.addListener(_scheduleDraftSave);
    Future.microtask(_loadDraft);
  }

  @override
  void dispose() {
    _draftTimer?.cancel();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;

    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final updatedUser = user.copyWith(
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        updatedAt: DateTime.now(),
      );

      final success = await authProvider.updateUser(updatedUser);

      final l10n = AppLocalizations.of(context)!;
      if (success && mounted) {
        await _clearDraft();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(l10n.profileUpdatedSuccessfully),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Text(l10n.profileUpdateFailed),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('${l10n.errorOccurred}: ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadDraft() async {
    final key = _draftKey;
    if (key == null) return;
    final data = await DraftStore.read(key);
    if (data == null) return;
    _restoringDraft = true;
    final name = data['name'];
    final phone = data['phone'];
    if (name is String) _nameController.text = name;
    if (phone is String) _phoneController.text = phone;
    _restoringDraft = false;
  }

  void _scheduleDraftSave() {
    if (_restoringDraft) return;
    final key = _draftKey;
    if (key == null) return;
    _draftTimer?.cancel();
    _draftTimer = Timer(const Duration(milliseconds: 300), () {
      DraftStore.write(key, {
        'name': _nameController.text,
        'phone': _phoneController.text,
      });
    });
  }

  Future<void> _clearDraft() async {
    final key = _draftKey;
    if (key == null) return;
    await DraftStore.clear(key);
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final s = parts.first;
      return s.length >= 2 ? s.substring(0, 2).toUpperCase() : s.toUpperCase();
    }
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }

  Widget _avatarPlaceholder(BuildContext context, dynamic user) {
    final cs = Theme.of(context).colorScheme;
    final name = user?.name ?? _nameController.text;
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cs.primary, cs.secondary],
        ),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: Text(
          _initials(name),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 32,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final user = context.watch<AuthProvider>().currentUser;
    final localeProvider = context.watch<LocaleProvider>();
    final l10n = AppLocalizations.of(context)!;
    final isRtl = localeProvider.isRtl;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.editProfile)),
        body: Center(child: Text(l10n.noUserLoggedIn)),
      );
    }

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: cs.surface,
        body: SafeArea(
          child: Column(
            children: [
              // App Bar
              Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      cs.primary.withOpacity(0.8),
                      cs.secondary.withOpacity(0.6),
                      cs.tertiary.withOpacity(0.4),
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        isRtl ? Icons.arrow_back : Icons.arrow_forward,
                        color: Colors.white,
                      ),
                      onPressed: () => context.pop(),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.editProfile,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // صورة المستخدم (من الملف أو الأحرف الأولى)
                        Center(
                          child: Stack(
                            children: [
                              ClipOval(
                                child: user.photoUrl != null &&
                                        user.photoUrl!.isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: user.photoUrl!,
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.cover,
                                        placeholder: (_, __) =>
                                            _avatarPlaceholder(context, user),
                                        errorWidget: (_, __, ___) =>
                                            _avatarPlaceholder(context, user),
                                      )
                                    : _avatarPlaceholder(context, user),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: cs.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 3,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // حقل الاسم
                        Text(
                          l10n.fullName,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _nameController,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: l10n.enterFullName,
                            prefixIcon:
                                Icon(Icons.person_rounded, color: cs.primary),
                            filled: true,
                            fillColor: cs.surfaceContainerHighest,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide:
                                  BorderSide(color: cs.primary, width: 2),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return l10n.pleaseEnterName;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // حقل البريد الإلكتروني (غير قابل للتعديل)
                        Text(
                          l10n.email,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          initialValue: user.email,
                          enabled: false,
                          decoration: InputDecoration(
                            hintText: l10n.email,
                            prefixIcon:
                                Icon(Icons.email_rounded, color: cs.primary),
                            filled: true,
                            fillColor:
                                cs.surfaceContainerHighest.withOpacity(0.5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.emailCannotBeChanged,
                          style: TextStyle(
                            fontSize: 12,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // حقل رقم الهاتف
                        Text(
                          l10n.phoneNumber,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: '+968 12345678',
                            prefixIcon:
                                Icon(Icons.phone_rounded, color: cs.primary),
                            filled: true,
                            fillColor: cs.surfaceContainerHighest,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide:
                                  BorderSide(color: cs.primary, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // زر الحفظ
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _updateProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: cs.primary,
                              foregroundColor: cs.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 8,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.save_rounded),
                                      const SizedBox(width: 8),
                                      Text(
                                        l10n.saveChanges,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // زر إلغاء
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton(
                            onPressed: _isLoading ? null : () => context.pop(),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: cs.onSurface,
                              side: BorderSide(color: cs.outline, width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              l10n.cancel,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
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
        ),
      ),
    );
  }
}
