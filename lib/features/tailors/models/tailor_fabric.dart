// lib/features/tailors/models/tailor_fabric.dart
import 'dart:ui' show Color;
import 'package:cloud_firestore/cloud_firestore.dart';

/// نموذج قماش الخياط
class TailorFabric {
  final String id;
  final String tailorId;
  final String name;
  final String description;
  final String imageUrl;
  final List<String> availableColors; // ألوان متاحة لهذا القماش
  final double pricePerMeter;
  final String fabricType; // نوع القماش: cotton, silk, wool, etc.
  final String season; // الموسم: summer, winter, all-season
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TailorFabric({
    required this.id,
    required this.tailorId,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.availableColors,
    required this.pricePerMeter,
    required this.fabricType,
    required this.season,
    this.isAvailable = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// تحويل من Firebase Document
  factory TailorFabric.fromFirestore(Map<String, dynamic> data, String id) {
    return TailorFabric(
      id: id,
      tailorId: data['tailorId'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      availableColors: List<String>.from(data['availableColors'] ?? []),
      pricePerMeter: (data['pricePerMeter'] ?? 0.0).toDouble(),
      fabricType: data['fabricType'] ?? '',
      season: data['season'] ?? 'all-season',
      isAvailable: data['isAvailable'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// تحويل إلى Map للـ Firebase
  Map<String, dynamic> toFirestore() {
    return {
      'tailorId': tailorId,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'availableColors': availableColors,
      'pricePerMeter': pricePerMeter,
      'fabricType': fabricType,
      'season': season,
      'isAvailable': isAvailable,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// نسخة محدثة من القماش
  TailorFabric copyWith({
    String? name,
    String? description,
    String? imageUrl,
    List<String>? availableColors,
    double? pricePerMeter,
    String? fabricType,
    String? season,
    bool? isAvailable,
  }) {
    return TailorFabric(
      id: id,
      tailorId: tailorId,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      availableColors: availableColors ?? this.availableColors,
      pricePerMeter: pricePerMeter ?? this.pricePerMeter,
      fabricType: fabricType ?? this.fabricType,
      season: season ?? this.season,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

/// نموذج لون القماش
class FabricColor {
  final String id;
  final String fabricId;
  final String name;
  final String hexCode; // كود اللون مثل #FF5733
  final String imageUrl; // صورة للون على القماش
  final bool isAvailable;
  final DateTime createdAt;

  const FabricColor({
    required this.id,
    required this.fabricId,
    required this.name,
    required this.hexCode,
    required this.imageUrl,
    this.isAvailable = true,
    required this.createdAt,
  });

  /// تحويل من Firebase Document
  factory FabricColor.fromFirestore(Map<String, dynamic> data, String id) {
    return FabricColor(
      id: id,
      fabricId: data['fabricId'] ?? '',
      name: data['name'] ?? '',
      hexCode: data['hexCode'] ?? '#000000',
      imageUrl: data['imageUrl'] ?? '',
      isAvailable: data['isAvailable'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// تحويل إلى Map للـ Firebase
  Map<String, dynamic> toFirestore() {
    return {
      'fabricId': fabricId,
      'name': name,
      'hexCode': hexCode,
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// تحويل hexCode إلى Color object
  Color get color {
    try {
      return Color(int.parse(hexCode.replaceFirst('#', '0xFF')));
    } catch (e) {
      return const Color(0xFF000000); // لون أسود افتراضي
    }
  }
}
