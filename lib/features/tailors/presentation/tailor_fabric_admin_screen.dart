// lib/features/tailors/presentation/tailor_fabric_admin_screen.dart
import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../services/fabric_service.dart';
import '../utils/fabric_migration_helper.dart';

/// شاشة إدارة الأقمشة للخياطين
class TailorFabricAdminScreen extends StatefulWidget {
  final String tailorId;
  final String tailorName;

  const TailorFabricAdminScreen({
    super.key,
    required this.tailorId,
    required this.tailorName,
  });

  @override
  State<TailorFabricAdminScreen> createState() =>
      _TailorFabricAdminScreenState();
}

class _TailorFabricAdminScreenState extends State<TailorFabricAdminScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  Map<String, dynamic>? _statistics;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStatistics() async {
    final stats = await FabricMigrationHelper.getFabricStatistics();
    if (mounted) {
      setState(() {
        _statistics = stats;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
          title: Text(l10n.manageFabricsFor),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _loadStatistics,
            ),
          ],
        ),
        body: Column(
          children: [
            // إحصائيات سريعة
            if (_statistics != null) _buildStatisticsCard(),

            // شريط البحث
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: l10n.searchInFabrics,
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),

            // قائمة الأقمشة
            Expanded(
              child: _searchQuery.isEmpty
                  ? _buildTailorFabricsList()
                  : _buildSearchResults(),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _showAddFabricDialog,
          icon: const Icon(Icons.add_rounded),
          label: Text(l10n.addFabric),
        ),
      );
  }

  Widget _buildStatisticsCard() {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'إحصائيات الأقمشة',
            style: tt.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: cs.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'إجمالي الأقمشة',
                  '${_statistics!['totalFabrics']}',
                  Icons.inventory_rounded,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'أقمشة هذا الخياط',
                  '${_statistics!['tailorCounts'][widget.tailorId] ?? 0}',
                  Icons.person_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(icon, size: 16, color: cs.onPrimaryContainer),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: tt.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: cs.onPrimaryContainer,
              ),
            ),
            Text(
              label,
              style: tt.bodySmall?.copyWith(
                color: cs.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTailorFabricsList() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: FabricService.getTailorFabrics(widget.tailorId),
      builder: (context, snapshot) {
        final l10n = AppLocalizations.of(context)!;
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, size: 64),
                const SizedBox(height: 16),
                Text(l10n.errorLoadingFabrics),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: Text(l10n.retry),
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
                const Icon(Icons.inventory_2_outlined, size: 64),
                const SizedBox(height: 16),
                Text(l10n.noFabricsForTailor),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _showAddFabricDialog,
                  icon: const Icon(Icons.add_rounded),
                  label: Text(l10n.addFirstFabric),
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
            return _buildFabricCard(fabric);
          },
        );
      },
    );
  }

  Widget _buildSearchResults() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: FabricService.searchTailorFabrics(widget.tailorId, _searchQuery),
      builder: (context, snapshot) {
        final l10n = AppLocalizations.of(context)!;
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text(l10n.searchError));
        }

        final fabrics = snapshot.data ?? [];
        if (fabrics.isEmpty) {
          return Center(
            child: Text(l10n.noSearchResults),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: fabrics.length,
          itemBuilder: (context, index) {
            final fabric = fabrics[index];
            return _buildFabricCard(fabric);
          },
        );
      },
    );
  }

  Widget _buildFabricCard(Map<String, dynamic> fabric) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // صورة القماش
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                fabric['imageUrl'] ?? '',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 80,
                    color: cs.surfaceContainerHighest,
                    child: const Icon(Icons.image_not_supported_rounded),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),

            // تفاصيل القماش
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fabric['name'] ?? 'قماش',
                    style: tt.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    fabric['type'] ?? 'غير محدد',
                    style: tt.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ر.ع ${(fabric['pricePerMeter'] ?? 0.0).toStringAsFixed(3)}/متر',
                    style: tt.bodySmall?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (fabric['availableColors'] != null)
                    Text(
                      '${(fabric['availableColors'] as List).length} لون متاح',
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),

            // أزرار الإجراءات
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_rounded),
                  onPressed: () => _showEditFabricDialog(fabric),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_rounded),
                  onPressed: () => _showDeleteFabricDialog(fabric),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddFabricDialog() {
    // TODO: تنفيذ إضافة قماش جديد
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('سيتم تنفيذ إضافة قماش جديد قريباً')),
    );
  }

  void _showEditFabricDialog(Map<String, dynamic> fabric) {
    // TODO: تنفيذ تعديل القماش
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('سيتم تنفيذ تعديل القماش قريباً')),
    );
  }

  void _showDeleteFabricDialog(Map<String, dynamic> fabric) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteFabric),
        content: Text('${l10n.confirmDeleteFabric} "${fabric['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteFabric(fabric['id']);
            },
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteFabric(String fabricId) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final success =
          await FabricService.deleteTailorFabric(widget.tailorId, fabricId);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.fabricDeletedSuccess)),
        );
        _loadStatistics();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.fabricDeleteFailed)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.errorOccurred}: $e')),
      );
    }
  }
}
