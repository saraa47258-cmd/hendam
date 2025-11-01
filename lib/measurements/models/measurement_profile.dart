class MeasurementProfile {
  final String id;
  final String userId;
  final String serviceId;   // لأي خدمة صُممت هذه القياسات
  final String title;       // "قياسات الدشداشة" / "عباية سادة"
  final Map<String, num> values; // {length: 142, chest: 110, ...}
  final String notes;

  const MeasurementProfile({
    required this.id,
    required this.userId,
    required this.serviceId,
    required this.title,
    required this.values,
    this.notes = '',
  });
}
