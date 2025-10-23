import 'package:flutter/material.dart';
import 'package:qscan_app_flutter/core/theme/app_theme.dart';

class BarcodeDetailsScreen extends StatelessWidget {
  final String code;

  const BarcodeDetailsScreen({super.key, required this.code});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Barcode Details')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.qr_code_2,
                size: 80,
                color: AppTheme.accentColor,
              ),
              const SizedBox(height: 20),
              const Text(
                'Scanned Barcode/Text Data:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              SelectableText(
                code,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, color: Colors.blueGrey),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Return to Scanner'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
