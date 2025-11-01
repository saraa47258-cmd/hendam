import 'package:flutter/material.dart';
// استخدم استيراد package لتفادي أخطاء المسار
import 'package:hindam/features/measurements/presentation/measurement_form_screen.dart';

// بيانات وهمية (بدون فايربيس حالياً)
import '../data/mock_services.dart';

// امنع تضارب الأسماء: خذ فقط Service من ملفه، و Gender/ServiceCategory من ملف الفئات
import '../models/service.dart' show Service;
import '../models/service_category.dart' show ServiceCategory, Gender;

import '../widgets/service_card.dart';
import '../../../core/styles/responsive.dart';
import '../../../core/widgets/responsive_helpers.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen>
    with SingleTickerProviderStateMixin {
  final _search = TextEditingController();
  String? _selectedCategoryId; // فلتر الفئة المختارة
  late final TabController _tabs =
      TabController(length: 3, vsync: this); // الكل/رجالي/نسائي

  @override
  void dispose() {
    _search.dispose();
    _tabs.dispose();
    super.dispose();
  }

  // Helpers للحصول على النتائج حسب التبويب
  List<ServiceCategory> _catsFor(Gender? g) {
    final list = categories.where((c) {
      if (g == null) return true; // تبويب "الكل"
      return c.gender == g || c.gender == Gender.unisex;
    }).toList()
      ..sort((a, b) => a.sort.compareTo(b.sort));
    return list;
  }

  List<Service> _servicesFor(Gender? g, String? catId, String q) {
    return services.where((s) {
      final okQ = q.isEmpty || s.nameAr.contains(q);
      final okCat = (catId == null) || s.categoryId == catId;
      bool okGender = true;
      if (g != null) {
        final c = categories.firstWhere((c) => c.id == s.categoryId);
        okGender = (c.gender == g || c.gender == Gender.unisex);
      }
      return okQ && okCat && okGender;
    }).toList();
  }

  int _columnsForWidth(double w) {
    return w < 600
        ? 1
        : w < 1024
            ? 2
            : 3;
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final cols = _columnsForWidth(w);

    return Column(
      children: [
        // تبويبات: الكل / رجالي / نسائي
        TabBar(
          controller: _tabs,
          isScrollable: context.isMobile,
          onTap: (_) => setState(() =>
              _selectedCategoryId = null), // امسح فلتر الفئة عند تغيير التبويب
          tabs: [
            Tab(
              child: Text(
                'الكل',
                style: TextStyle(fontSize: context.responsiveFontSize(14.0)),
              ),
            ),
            Tab(
              child: Text(
                'رجالي',
                style: TextStyle(fontSize: context.responsiveFontSize(14.0)),
              ),
            ),
            Tab(
              child: Text(
                'نسائي',
                style: TextStyle(fontSize: context.responsiveFontSize(14.0)),
              ),
            ),
          ],
        ),

        // محتوى كل تبويب
        Expanded(
          child: TabBarView(
            controller: _tabs,
            children: List.generate(3, (tabIndex) {
              final Gender? g = tabIndex == 1
                  ? Gender.men
                  : tabIndex == 2
                      ? Gender.women
                      : null;

              final q = _search.text.trim();
              final cats = _catsFor(g);
              final items = _servicesFor(g, _selectedCategoryId, q);

              return CustomScrollView(
                slivers: [
                  // البحث + فلاتر الفئات
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(context.responsivePadding()),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ResponsiveHelpers.responsiveSearchBar(
                            context,
                            controller: _search,
                            hintText:
                                'ابحث عن خدمة (مثال: عباية، دشداشة، تعديل)',
                            onChanged: (_) => setState(() {}),
                          ),
                          SizedBox(height: context.responsiveSpacing()),
                          SizedBox(
                            height:
                                context.pick(40.0, tablet: 44.0, desktop: 48.0),
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: cats.length + 1,
                              separatorBuilder: (_, __) =>
                                  SizedBox(width: context.responsiveMargin()),
                              itemBuilder: (_, i) {
                                if (i == 0) {
                                  final selected = _selectedCategoryId == null;
                                  return ChoiceChip(
                                    label: Text(
                                      'كل الفئات',
                                      style: TextStyle(
                                          fontSize:
                                              context.responsiveFontSize(12.0)),
                                    ),
                                    selected: selected,
                                    onSelected: (_) => setState(
                                        () => _selectedCategoryId = null),
                                  );
                                }
                                final c = cats[i - 1];
                                final selected = _selectedCategoryId == c.id;
                                return ChoiceChip(
                                  label: Text(
                                    c.nameAr,
                                    style: TextStyle(
                                        fontSize:
                                            context.responsiveFontSize(12.0)),
                                  ),
                                  selected: selected,
                                  onSelected: (_) => setState(
                                      () => _selectedCategoryId = c.id),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // عرض الخدمات: قائمة (موبايل) أو شبكة (أكبر)
                  if (items.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(context.responsivePadding()),
                        child: Center(
                          child: Text(
                            'لا توجد خدمات مطابقة حاليًا',
                            style: TextStyle(
                                fontSize: context.responsiveFontSize(16.0)),
                          ),
                        ),
                      ),
                    )
                  else if (cols == 1)
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) {
                          final s = items[i];
                          return Padding(
                            padding: EdgeInsets.fromLTRB(
                              context.responsivePadding(),
                              0,
                              context.responsivePadding(),
                              context.responsiveSpacing(),
                            ),
                            child: ServiceCard(
                              service: s,
                              onSelect: () async {
                                final ok =
                                    await Navigator.of(context).push<bool>(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const MeasurementFormScreen(),
                                  ),
                                );
                                if (ok == true && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('تم اختيار: ${s.nameAr}'),
                                    ),
                                  );
                                }
                              },
                            ),
                          );
                        },
                        childCount: items.length,
                      ),
                    )
                  else
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                          horizontal: context.responsivePadding()),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (context, i) {
                            final s = items[i];
                            return ServiceCard(
                              service: s,
                              onSelect: () async {
                                final ok =
                                    await Navigator.of(context).push<bool>(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const MeasurementFormScreen(),
                                  ),
                                );
                                if (ok == true && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('تم اختيار: ${s.nameAr}'),
                                    ),
                                  );
                                }
                              },
                            );
                          },
                          childCount: items.length,
                        ),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: cols,
                          mainAxisSpacing: context.responsiveSpacing(),
                          crossAxisSpacing: context.responsiveSpacing(),
                          childAspectRatio: w < 1024 ? 0.88 : 1.0,
                        ),
                      ),
                    ),

                  SliverToBoxAdapter(
                    child: SizedBox(height: context.responsivePadding()),
                  ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}
