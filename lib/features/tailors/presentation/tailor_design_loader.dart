import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hindam/core/services/firebase_service.dart';
import 'tailoring_design_screen.dart' as design;
import '../models/fabric_item.dart' as fabric_model;

class TailorDesignLoaderScreen extends StatelessWidget {
  final String tailorId;
  final String tailorName;
  const TailorDesignLoaderScreen(
      {super.key, required this.tailorId, required this.tailorName});

  Stream<_DesignData> _load() {
    final fs = FirebaseService.firestore;
    final colors$ = fs
        .collection('colors')
        .where('tailorId', isEqualTo: tailorId)
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) =>
                _hexToColor((d.data()['colorHex'] ?? '#FFFFFF').toString()))
            .toList());

    final fabrics$ = fs
        .collection('fabrics')
        .where('tailorId', isEqualTo: tailorId)
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final m = d.data();
              return fabric_model.FabricItem(
                name: (m['fabricName'] ?? m['name'] ?? 'قماش').toString(),
                imageUrl: (m['imageUrl'] ?? m['thumb'] ?? '').toString(),
                tag: (m['tag'] ?? '').toString().trim().isEmpty
                    ? null
                    : (m['tag'] as String),
              );
            }).toList());

    return Rx.combineLatest2<List<Color>, List<fabric_model.FabricItem>,
        _DesignData>(
      colors$,
      fabrics$,
      (c, f) => _DesignData(colors: c, fabrics: f),
    );
  }

  static Color _hexToColor(String hex) {
    var v = hex.replaceAll('#', '').trim();
    if (v.length == 6) v = 'FF$v';
    final n = int.tryParse(v, radix: 16) ?? 0xFFFFFFFF;
    return Color(n);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<_DesignData>(
      stream: _load(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        if (snap.hasError) {
          return const Scaffold(
            body: Center(child: Text('تعذر تحميل الألوان والخامات')),
          );
        }
        final data = snap.data ?? const _DesignData();
        final fabrics = data.fabrics
            .map((x) => design.FabricItem(x.name, x.imageUrl, tag: x.tag))
            .toList();
        return design.TailoringDesignScreen(
          tailorId: tailorId,
          tailorName: tailorName,
          fabrics: fabrics,
        );
      },
    );
  }
}

class _DesignData {
  final List<Color> colors;
  final List<fabric_model.FabricItem> fabrics;
  const _DesignData({this.colors = const [], this.fabrics = const []});
}

// Rx.combineLatest2 helper without importing rxdart
class Rx {
  static Stream<R> combineLatest2<A, B, R>(
      Stream<A> sa, Stream<B> sb, R Function(A, B) combiner) {
    late A? lastA;
    late B? lastB;
    bool hasA = false, hasB = false;
    final controller = StreamController<R>();
    final subA = sa.listen((a) {
      lastA = a;
      hasA = true;
      if (hasA && hasB) controller.add(combiner(lastA as A, lastB as B));
    }, onError: controller.addError);
    final subB = sb.listen((b) {
      lastB = b;
      hasB = true;
      if (hasA && hasB) controller.add(combiner(lastA as A, lastB as B));
    }, onError: controller.addError);
    controller.onCancel = () {
      subA.cancel();
      subB.cancel();
    };
    return controller.stream;
  }
}
