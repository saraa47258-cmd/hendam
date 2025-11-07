import 'package:cloud_firestore/cloud_firestore.dart';

class AddressModel {
  final String id;
  final String userId;
  final String label;
  final String recipientName;
  final String phone;
  final String city;
  final String area;
  final String street;
  final String? building;
  final String additionalDirections;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const AddressModel({
    required this.id,
    required this.userId,
    required this.label,
    required this.recipientName,
    required this.phone,
    required this.city,
    required this.area,
    required this.street,
    required this.building,
    required this.additionalDirections,
    required this.isDefault,
    required this.createdAt,
    this.updatedAt,
  });

  AddressModel copyWith({
    String? id,
    String? userId,
    String? label,
    String? recipientName,
    String? phone,
    String? city,
    String? area,
    String? street,
    String? building,
    String? additionalDirections,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AddressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      label: label ?? this.label,
      recipientName: recipientName ?? this.recipientName,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      area: area ?? this.area,
      street: street ?? this.street,
      building: building ?? this.building,
      additionalDirections: additionalDirections ?? this.additionalDirections,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'label': label,
      'recipientName': recipientName,
      'phone': phone,
      'city': city,
      'area': area,
      'street': street,
      'building': building,
      'additionalDirections': additionalDirections,
      'isDefault': isDefault,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory AddressModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return AddressModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      label: data['label'] ?? '',
      recipientName: data['recipientName'] ?? '',
      phone: data['phone'] ?? '',
      city: data['city'] ?? '',
      area: data['area'] ?? '',
      street: data['street'] ?? '',
      building: data['building'],
      additionalDirections: data['additionalDirections'] ?? '',
      isDefault: data['isDefault'] ?? false,
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}


