import 'package:flutter/material.dart';
import 'package:hindam/l10n/app_localizations.dart';

class MeasurementFormScreen extends StatelessWidget {
  const MeasurementFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.enterMeasurements)),
      body: Center(
        child: FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.saveExperimental),
        ),
      ),
    );
  }
}
