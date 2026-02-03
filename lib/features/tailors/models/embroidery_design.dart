/// نموذج لتصميم التطريز
class EmbroideryDesign {
  final String id;
  final String imageUrl;
  final String name;
  final double price;
  final DateTime uploadedAt;

  /// ألوان الخيوط المتاحة لهذا التصميم
  final List<String> availableColors;

  /// الحد الأقصى لعدد الخيوط
  final int maxThreads;

  /// الحد الأدنى لعدد الخيوط
  final int minThreads;

  /// هل يدعم اختيار ألوان متعددة؟
  final bool multiColorSupported;

  EmbroideryDesign({
    required this.id,
    required this.imageUrl,
    required this.name,
    required this.price,
    required this.uploadedAt,
    this.availableColors = const [],
    this.maxThreads = 5,
    this.minThreads = 1,
    this.multiColorSupported = false,
  });

  factory EmbroideryDesign.fromMap(Map<String, dynamic> map, String id) {
    return EmbroideryDesign(
      id: id,
      imageUrl: map['imageUrl'] as String? ?? '',
      name: map['name'] as String? ?? 'تطريز ${id.substring(0, 8)}',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      uploadedAt: map['uploadedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['uploadedAt'] as int)
          : DateTime.now(),
      availableColors: (map['availableColors'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      maxThreads: (map['maxThreads'] as num?)?.toInt() ?? 5,
      minThreads: (map['minThreads'] as num?)?.toInt() ?? 1,
      multiColorSupported: map['multiColorSupported'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'imageUrl': imageUrl,
      'name': name,
      'price': price,
      'uploadedAt': uploadedAt.millisecondsSinceEpoch,
      'availableColors': availableColors,
      'maxThreads': maxThreads,
      'minThreads': minThreads,
      'multiColorSupported': multiColorSupported,
    };
  }

  EmbroideryDesign copyWith({
    String? id,
    String? imageUrl,
    String? name,
    double? price,
    DateTime? uploadedAt,
    List<String>? availableColors,
    int? maxThreads,
    int? minThreads,
    bool? multiColorSupported,
  }) {
    return EmbroideryDesign(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      name: name ?? this.name,
      price: price ?? this.price,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      availableColors: availableColors ?? this.availableColors,
      maxThreads: maxThreads ?? this.maxThreads,
      minThreads: minThreads ?? this.minThreads,
      multiColorSupported: multiColorSupported ?? this.multiColorSupported,
    );
  }
}

/// تفاصيل الخيوط المختارة للتطريز
class ThreadDetails {
  final List<String> selectedColorIds;
  final int threadCount;

  const ThreadDetails({
    required this.selectedColorIds,
    required this.threadCount,
  });

  bool get isValid => selectedColorIds.isNotEmpty && threadCount > 0;

  Map<String, dynamic> toMap() {
    return {
      'selectedColorIds': selectedColorIds,
      'threadCount': threadCount,
    };
  }

  factory ThreadDetails.fromMap(Map<String, dynamic> map) {
    return ThreadDetails(
      selectedColorIds: (map['selectedColorIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      threadCount: (map['threadCount'] as num?)?.toInt() ?? 1,
    );
  }
}
