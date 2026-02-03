// lib/features/tailors/services/tailor_services_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hindam/core/services/firebase_service.dart';

/// نموذج الخدمة
class TailorService {
  final String id;
  final String name;
  final String? address;
  final String? email;
  final String? description;
  final String? category;
  final double? price;
  final String? difficulty;
  final int? estimatedDays;
  final Map<String, dynamic>? contact;
  final Map<String, dynamic>? location;
  final Map<String, dynamic>? gallery;
  final DateTime? createdAt;
  final DateTime? lastUpdated;
  final String? createdBy;
  final String? authEmail;
  final String? tailorId;

  TailorService({
    required this.id,
    required this.name,
    this.address,
    this.email,
    this.description,
    this.category,
    this.price,
    this.difficulty,
    this.estimatedDays,
    this.contact,
    this.location,
    this.gallery,
    this.createdAt,
    this.lastUpdated,
    this.createdBy,
    this.authEmail,
    this.tailorId,
  });

  factory TailorService.fromMap(Map<String, dynamic> map, String id) {
    return TailorService(
      id: id,
      name: map['name'] ?? 
           map['location']?['name'] ?? 
           'خدمة بدون اسم',
      address: map['address'] ?? 
               map['location']?['address'] ?? 
               '',
      email: map['email'] ?? 
             map['contact']?['email'] ?? 
             '',
      description: map['description'],
      category: map['category'],
      price: map['price'] != null ? (map['price'] as num).toDouble() : null,
      difficulty: map['difficulty'],
      estimatedDays: map['estimatedDays'] != null 
          ? (map['estimatedDays'] as num).toInt() 
          : null,
      contact: map['contact'] as Map<String, dynamic>?,
      location: map['location'] as Map<String, dynamic>?,
      gallery: map['gallery'] as Map<String, dynamic>?,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
      lastUpdated: map['lastUpdated'] != null
          ? (map['lastUpdated'] as Timestamp).toDate()
          : null,
      createdBy: map['createdBy'],
      authEmail: map['authEmail'],
      tailorId: map['tailorId'],
    );
  }

  /// هل الخدمة نشطة؟
  bool get isActive => gallery?['isActive'] ?? true;

  /// هل الخدمة موثقة؟
  bool get isVerified => gallery?['isVerified'] ?? false;

  /// رقم الهاتف
  String? get phone => contact?['phone'];

  /// WhatsApp
  String? get whatsapp => contact?['whatsapp'];

  /// اسم المالك
  String? get ownerName => location?['ownerName'] ?? location?['name'];

  /// خط العرض
  double? get latitude => location?['latitude']?.toDouble();

  /// خط الطول
  double? get longitude => location?['longitude']?.toDouble();
}

/// خدمة جلب خدمات الخياط من Firebase
class TailorServicesService {
  final FirebaseFirestore _firestore = FirebaseService.firestore;

  /// جلب جميع خدمات الخياط من tailors/{tailorId}/services
  Stream<List<TailorService>> getTailorServices(String tailorId) {
    try {
      return _firestore
          .collection('tailors')
          .doc(tailorId)
          .collection('services')
          .snapshots()
          .map((snapshot) {
        final services = <TailorService>[];
        
        for (final doc in snapshot.docs) {
          try {
            final data = doc.data();
            final service = TailorService.fromMap(data, doc.id);
            
            // عرض الخدمات النشطة فقط
            if (service.isActive) {
              services.add(service);
            }
          } catch (e) {
            print('❌ خطأ في تحويل خدمة: ${doc.id} - $e');
          }
        }
        
        return services;
      });
    } catch (e) {
      print('❌ خطأ في جلب خدمات الخياط: $e');
      return Stream.value([]);
    }
  }

  /// جلب خدمة واحدة
  Future<TailorService?> getServiceById(String tailorId, String serviceId) async {
    try {
      final doc = await _firestore
          .collection('tailors')
          .doc(tailorId)
          .collection('services')
          .doc(serviceId)
          .get();
      
      if (doc.exists) {
        return TailorService.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('❌ خطأ في جلب الخدمة: $e');
      return null;
    }
  }
}

