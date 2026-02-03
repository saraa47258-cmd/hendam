// lib/features/about/presentation/about_app_screen.dart
import 'package:flutter/material.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: cs.surface,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('عن التطبيق'),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // شعار التطبيق
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        cs.primary,
                        cs.secondary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: cs.primary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.shopping_bag_rounded,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // اسم التطبيق
              Center(
                child: Text(
                  'هندام',
                  style: tt.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // وصف التطبيق
              Center(
                child: Text(
                  'منصة متكاملة للتسوق والطلب',
                  style: tt.bodyLarge?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // إصدار التطبيق
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'الإصدار 1.0.0 (Build 1)',
                    style: TextStyle(
                      color: cs.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // معلومات التطبيق
              _InfoSection(
                title: 'معلومات التطبيق',
                items: [
                  _InfoItem(
                    icon: Icons.description_rounded,
                    label: 'الوصف',
                    value: 'تطبيق هندام هو منصة متكاملة تتيح لك التسوق وطلب المنتجات من مختلف المتاجر والتجار في السلطنة.',
                    cs: cs,
                  ),
                  _InfoItem(
                    icon: Icons.calendar_today_rounded,
                    label: 'تاريخ الإصدار',
                    value: '2024',
                    cs: cs,
                  ),
                  _InfoItem(
                    icon: Icons.developer_mode_rounded,
                    label: 'المطور',
                    value: 'فريق هندام',
                    cs: cs,
                  ),
                ],
                cs: cs,
              ),

              const SizedBox(height: 24),

              // المميزات
              _InfoSection(
                title: 'مميزات التطبيق',
                items: [
                  _FeatureItem(
                    icon: Icons.local_shipping_rounded,
                    title: 'توصيل سريع',
                    description: 'توصيل لجميع أنحاء السلطنة',
                    color: const Color(0xFF10B981),
                    cs: cs,
                  ),
                  _FeatureItem(
                    icon: Icons.verified_rounded,
                    title: 'جودة مضمونة',
                    description: 'منتجات أصلية من تجار معتمدين',
                    color: const Color(0xFF3B82F6),
                    cs: cs,
                  ),
                  _FeatureItem(
                    icon: Icons.security_rounded,
                    title: 'آمن ومحمي',
                    description: 'بياناتك محمية ومشفرة',
                    color: const Color(0xFF8B5CF6),
                    cs: cs,
                  ),
                  _FeatureItem(
                    icon: Icons.support_agent_rounded,
                    title: 'دعم فني',
                    description: 'خدمة عملاء على مدار الساعة',
                    color: const Color(0xFFF59E0B),
                    cs: cs,
                  ),
                ],
                cs: cs,
              ),

              const SizedBox(height: 24),

              // روابط مهمة
              _InfoSection(
                title: 'روابط مهمة',
                items: [
                  _LinkItem(
                    icon: Icons.privacy_tip_rounded,
                    title: 'سياسة الخصوصية',
                    onTap: () {
                      // يمكن إضافة صفحة سياسة الخصوصية
                    },
                    cs: cs,
                  ),
                  _LinkItem(
                    icon: Icons.description_rounded,
                    title: 'شروط الاستخدام',
                    onTap: () {
                      // يمكن إضافة صفحة شروط الاستخدام
                    },
                    cs: cs,
                  ),
                  _LinkItem(
                    icon: Icons.star_rounded,
                    title: 'قيم التطبيق',
                    onTap: () {
                      // يمكن إضافة وظيفة تقييم التطبيق
                    },
                    cs: cs,
                  ),
                ],
                cs: cs,
              ),

              const SizedBox(height: 32),

              // حقوق النشر
              Center(
                child: Text(
                  '© 2024 هندام. جميع الحقوق محفوظة.',
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 12,
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

class _InfoSection extends StatelessWidget {
  final String title;
  final List<Widget> items;
  final ColorScheme cs;

  const _InfoSection({
    required this.title,
    required this.items,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        ...items,
      ],
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ColorScheme cs;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cs.outlineVariant.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: cs.primary, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    color: cs.onSurface,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final ColorScheme cs;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cs.outlineVariant.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final ColorScheme cs;

  const _LinkItem({
    required this.icon,
    required this.title,
    required this.onTap,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cs.outlineVariant.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: cs.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: cs.primary, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
          ),
        ),
        trailing: Icon(
          Icons.chevron_left_rounded,
          color: cs.onSurfaceVariant,
        ),
        onTap: onTap,
      ),
    );
  }
}

