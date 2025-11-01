class Service {
  final String id;
  final String categoryId;
  final String nameAr;
  final double basePriceOmr;
  final String image; // اختياري
  final Map<String, dynamic> measurementSchema; // للقياسات الديناميكية لاحقًا

  const Service({
    required this.id,
    required this.categoryId,
    required this.nameAr,
    required this.basePriceOmr,
    this.image = '',
    this.measurementSchema = const {},
  });
}
