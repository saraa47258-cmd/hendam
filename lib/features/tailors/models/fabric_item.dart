/// نموذج القماش
class FabricItem {
  final String name; // مثل: صيفي، شتوي، فاخر...
  final String imageUrl; // مسار asset أو رابط
  final String? tag; // شارة اختيارية
  
  const FabricItem({
    required this.name,
    required this.imageUrl,
    this.tag,
  });
}
