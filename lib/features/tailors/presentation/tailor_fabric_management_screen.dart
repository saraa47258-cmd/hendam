// lib/features/tailors/presentation/tailor_fabric_management_screen.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/tailor_fabric_service.dart';
import '../models/tailor_fabric.dart';
import 'package:hindam/l10n/app_localizations.dart';

/// شاشة إدارة أقمشة وألوان الخياط
class TailorFabricManagementScreen extends StatefulWidget {
  final String tailorId;
  final String tailorName;

  const TailorFabricManagementScreen({
    super.key,
    required this.tailorId,
    required this.tailorName,
  });

  @override
  State<TailorFabricManagementScreen> createState() =>
      _TailorFabricManagementScreenState();
}

class _TailorFabricManagementScreenState
    extends State<TailorFabricManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text('${l10n.manageFabrics} ${widget.tailorName}'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.fabrics, icon: const Icon(Icons.texture)),
            Tab(text: l10n.colorsLabel, icon: const Icon(Icons.palette)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _FabricsTab(tailorId: widget.tailorId),
          _ColorsTab(tailorId: widget.tailorId),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_tabController.index == 0) {
            _showAddFabricDialog();
          } else {
            _showAddColorDialog();
          }
        },
        icon: const Icon(Icons.add),
        label: Text(_tabController.index == 0 ? l10n.addFabric : l10n.addColor),
      ),
    );
  }

  void _showAddFabricDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddFabricDialog(tailorId: widget.tailorId),
    );
  }

  void _showAddColorDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddColorDialog(tailorId: widget.tailorId),
    );
  }
}

/// تبويب الأقمشة
class _FabricsTab extends StatelessWidget {
  final String tailorId;

  const _FabricsTab({required this.tailorId});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return StreamBuilder<List<TailorFabric>>(
      stream: TailorFabricService.getTailorFabrics(tailorId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: cs.error),
                const SizedBox(height: 16),
                Text(
                  l10n.errorLoadingFabrics,
                  style: tt.titleMedium?.copyWith(color: cs.error),
                ),
              ],
            ),
          );
        }

        final fabrics = snapshot.data ?? [];
        if (fabrics.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.texture, size: 64, color: cs.onSurfaceVariant),
                const SizedBox(height: 16),
                Text(
                  l10n.noFabricsRegistered,
                  style: tt.titleMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.pressAddToAddFabric,
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: fabrics.length,
          itemBuilder: (context, index) {
            final fabric = fabrics[index];
            return _FabricCard(fabric: fabric);
          },
        );
      },
    );
  }
}

/// تبويب الألوان
class _ColorsTab extends StatelessWidget {
  final String tailorId;

  const _ColorsTab({required this.tailorId});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return StreamBuilder<List<FabricColor>>(
      stream: TailorFabricService.getTailorColors(tailorId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: cs.error),
                const SizedBox(height: 16),
                Text(
                  l10n.errorLoadingColors,
                  style: tt.titleMedium?.copyWith(color: cs.error),
                ),
              ],
            ),
          );
        }

        final colors = snapshot.data ?? [];
        if (colors.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.palette, size: 64, color: cs.onSurfaceVariant),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.noColorsRegistered,
                  style: tt.titleMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.pressAddToAddColor,
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1,
          ),
          itemCount: colors.length,
          itemBuilder: (context, index) {
            final color = colors[index];
            return _ColorCard(color: color);
          },
        );
      },
    );
  }
}

/// بطاقة القماش
class _FabricCard extends StatelessWidget {
  final TailorFabric fabric;

  const _FabricCard({required this.fabric});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    fabric.imageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 60,
                      height: 60,
                      color: cs.surfaceContainerHighest,
                      child: Icon(Icons.image_not_supported,
                          color: cs.onSurfaceVariant),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fabric.name,
                        style: tt.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        fabric.description,
                        style:
                            tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: cs.secondaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              fabric.fabricType,
                              style: tt.labelSmall?.copyWith(
                                color: cs.onSecondaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${AppLocalizations.of(context)!.currency} ${fabric.pricePerMeter.toStringAsFixed(3)}/${AppLocalizations.of(context)!.pricePerMeter}',
                            style: tt.bodySmall?.copyWith(
                              color: cs.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditFabricDialog(context, fabric);
                    } else if (value == 'delete') {
                      _showDeleteFabricDialog(context, fabric);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          const Icon(Icons.edit),
                          const SizedBox(width: 8),
                          Text(AppLocalizations.of(context)!.editLabel2),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(Icons.delete, color: Colors.red),
                          const SizedBox(width: 8),
                          Text(AppLocalizations.of(context)!.deleteLabel2, style: const TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEditFabricDialog(BuildContext context, TailorFabric fabric) {
    // TODO: تنفيذ نافذة تعديل القماش
  }

  void _showDeleteFabricDialog(BuildContext context, TailorFabric fabric) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDeleteTitle),
        content: Text(l10n.confirmDeleteFabricMessage(fabric.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await TailorFabricService.deleteFabric(fabric.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.fabricDeletedSnack)),
                );
              }
            },
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

/// بطاقة اللون
class _ColorCard extends StatelessWidget {
  final FabricColor color;

  const _ColorCard({required this.color});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.color,
              border: Border.all(color: cs.outline, width: 2),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            color.name,
            style: tt.bodySmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            color.hexCode,
            style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

/// نافذة إضافة قماش جديد
class _AddFabricDialog extends StatefulWidget {
  final String tailorId;

  const _AddFabricDialog({required this.tailorId});

  @override
  State<_AddFabricDialog> createState() => _AddFabricDialogState();
}

class _AddFabricDialogState extends State<_AddFabricDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imagePicker = ImagePicker();

  String _fabricType = 'cotton';
  String _season = 'all-season';
  File? _selectedImage;
  bool _isLoading = false;

  final List<Map<String, String>> _fabricTypes = const [
    {'value': 'cotton', 'label': 'cotton'},
    {'value': 'silk', 'label': 'silk'},
    {'value': 'wool', 'label': 'wool'},
    {'value': 'linen', 'label': 'linen'},
    {'value': 'polyester', 'label': 'polyester'},
  ];

  final List<Map<String, String>> _seasons = const [
    {'value': 'summer', 'label': 'summer'},
    {'value': 'winter', 'label': 'winter'},
    {'value': 'all-season', 'label': 'all-season'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    String _fabricTypeLabel(String key) {
      switch (key) {
        case 'cotton': return l10n.cottonFabric;
        case 'silk': return l10n.silkFabric;
        case 'wool': return l10n.woolFabric;
        case 'linen': return l10n.linenFabric;
        case 'polyester': return l10n.polyesterFabric;
        default: return key;
      }
    }

    String _seasonLabel(String key) {
      switch (key) {
        case 'summer': return l10n.summerSeason;
        case 'winter': return l10n.winterSeason;
        case 'all-season': return l10n.allSeasonLabel;
        default: return key;
      }
    }

    return AlertDialog(
      title: Text(l10n.addNewFabric),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // صورة القماش
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    border: Border.all(color: cs.outline),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate,
                                color: cs.onSurfaceVariant),
                            const SizedBox(height: 8),
                            Text(
                              l10n.tapToAddImage,
                              style: tt.bodySmall
                                  ?.copyWith(color: cs.onSurfaceVariant),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // اسم القماش
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.fabricNameLabel,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.pleaseEnterFabricName;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // وصف القماش
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: l10n.fabricDescriptionLabel,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.pleaseEnterFabricDescription;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // نوع القماش
              DropdownButtonFormField<String>(
                initialValue: _fabricType,
                decoration: InputDecoration(
                  labelText: l10n.fabricTypeFieldLabel,
                  border: const OutlineInputBorder(),
                ),
                items: _fabricTypes.map((type) {
                  return DropdownMenuItem(
                    value: type['value'],
                    child: Text(_fabricTypeLabel(type['value']!)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _fabricType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // الموسم
              DropdownButtonFormField<String>(
                initialValue: _season,
                decoration: InputDecoration(
                  labelText: l10n.seasonLabel,
                  border: const OutlineInputBorder(),
                ),
                items: _seasons.map((season) {
                  return DropdownMenuItem(
                    value: season['value'],
                    child: Text(_seasonLabel(season['value']!)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _season = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // السعر
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: l10n.pricePerMeterLabel,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.pleaseEnterPrice;
                  }
                  if (double.tryParse(value) == null) {
                    return l10n.pleaseEnterValidNumber;
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveFabric,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.save),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    final XFile? image =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _saveFabric() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseSelectImage)),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: رفع الصورة إلى Firebase Storage
      // ثم إنشاء القماش في Firebase

      final fabric = TailorFabric(
        id: '', // سيتم تعيينه من Firebase
        tailorId: widget.tailorId,
        name: _nameController.text,
        description: _descriptionController.text,
        imageUrl: '', // سيتم تعيينه بعد رفع الصورة
        availableColors: [],
        pricePerMeter: double.parse(_priceController.text),
        fabricType: _fabricType,
        season: _season,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final fabricId = await TailorFabricService.addFabric(fabric);
      if (fabricId != null) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.fabricAddedSuccess)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.fabricAddFailed)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorWithMessage(e.toString()))),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

/// نافذة إضافة لون جديد
class _AddColorDialog extends StatefulWidget {
  final String tailorId;

  const _AddColorDialog({required this.tailorId});

  @override
  State<_AddColorDialog> createState() => _AddColorDialogState();
}

class _AddColorDialogState extends State<_AddColorDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _hexController = TextEditingController();

  String? _selectedFabricId;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _hexController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.addNewColor),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // اختيار القماش
              StreamBuilder<List<TailorFabric>>(
                stream: TailorFabricService.getTailorFabrics(widget.tailorId),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    return DropdownButtonFormField<String>(
                      initialValue: _selectedFabricId,
                      decoration: InputDecoration(
                        labelText: l10n.selectFabricLabel,
                        border: const OutlineInputBorder(),
                      ),
                      items: snapshot.data!.map((fabric) {
                        return DropdownMenuItem(
                          value: fabric.id,
                          child: Text(fabric.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedFabricId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.pleaseSelectFabricField;
                        }
                        return null;
                      },
                    );
                  }
                  return Text(l10n.noFabricsAvailableLabel);
                },
              ),
              const SizedBox(height: 16),

              // اسم اللون
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.colorNameLabel,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.pleaseEnterColorName;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // كود اللون
              TextFormField(
                controller: _hexController,
                decoration: InputDecoration(
                  labelText: l10n.colorCodeLabel,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.pleaseEnterColorCode;
                  }
                  if (!RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(value)) {
                    return l10n.invalidColorCode;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // معاينة اللون
              if (_hexController.text.isNotEmpty)
                Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _getColorFromHex(_hexController.text),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: cs.outline),
                  ),
                  child: Center(
                    child: Text(
                      _nameController.text.isEmpty
                          ? l10n.colorPreview
                          : _nameController.text,
                      style: TextStyle(
                        color: _getContrastColor(
                            _getColorFromHex(_hexController.text)),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveColor,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.save),
        ),
      ],
    );
  }

  Color _getColorFromHex(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.grey;
    }
  }

  Color _getContrastColor(Color color) {
    // حساب اللون المناسب للنص بناءً على لون الخلفية
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  Future<void> _saveColor() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _isLoading = true;
    });

    try {
      final color = FabricColor(
        id: '', // سيتم تعيينه من Firebase
        fabricId: _selectedFabricId!,
        name: _nameController.text,
        hexCode: _hexController.text,
        imageUrl: '', // يمكن إضافة صورة لاحقاً
        createdAt: DateTime.now(),
      );

      final colorId = await TailorFabricService.addFabricColor(color);
      if (colorId != null) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.colorAddedSuccess)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.colorAddFailed)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorWithMessage(e.toString()))),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
