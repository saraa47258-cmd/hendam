import 'package:flutter/material.dart';

class MeasurementFormScreen extends StatelessWidget {
  const MeasurementFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('أدخل القياسات')),
      body: Center(
        child: FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('حفظ (تجريبي)'),
        ),
      ),
    );
  }
}
