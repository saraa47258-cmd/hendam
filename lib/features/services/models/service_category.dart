enum Gender { men, women, unisex }

class ServiceCategory {
  final String id;
  final String nameAr;
  final Gender gender; // men / women / unisex
  final int sort;
  final String icon; // اختياري

  const ServiceCategory({
    required this.id,
    required this.nameAr,
    required this.gender,
    this.sort = 0,
    this.icon = '',
  });
}
