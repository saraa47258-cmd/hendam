import 'package:flutter/material.dart';
import 'tailoring_design_screen.dart' as design;

class TailorDesignLoaderScreen extends StatelessWidget {
  final String tailorId;
  final String tailorName;
  const TailorDesignLoaderScreen(
      {super.key, required this.tailorId, required this.tailorName});

  @override
  Widget build(BuildContext context) {
    // تم تبسيط الشاشة: الانتقال مباشرة إلى شاشة التفصيل.
    // `FabricStepWidget` سيقوم بجلب الأقمشة من Firestore بنفسه.
    return design.TailoringDesignScreen(
      tailorId: tailorId,
      tailorName: tailorName,
    );
  }
}
