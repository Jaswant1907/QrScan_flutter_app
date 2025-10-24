import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:qscan_app_flutter/core/theme/app_theme.dart';
import 'package:qscan_app_flutter/core/utils/responsive_utils.dart';
import 'package:qscan_app_flutter/presentation/model/history_item.dart';
import 'package:qscan_app_flutter/presentation/repository/history_repo.dart';
import 'package:qscan_app_flutter/presentation/screens/details/barcode_details_screen.dart';
import 'package:qscan_app_flutter/presentation/screens/details/link_details.dart';
import 'package:qscan_app_flutter/presentation/screens/details/payment_details.dart';

class AnalysisResult {
  final File imageFile;
  final String? codeData;
  final String? codeType;
  final BarcodeFormat? barcodeFormat;

  AnalysisResult({
    required this.imageFile,
    this.codeData,
    this.codeType,
    this.barcodeFormat,
  });
}

class AnalysisResultsScreen extends StatefulWidget {
  final List<File> capturedImages;

  const AnalysisResultsScreen({super.key, required this.capturedImages});

  @override
  State<AnalysisResultsScreen> createState() => _AnalysisResultsScreenState();
}

class _AnalysisResultsScreenState extends State<AnalysisResultsScreen> {
  final BarcodeScanner _barcodeScanner = BarcodeScanner();
  List<AnalysisResult> _results = [];
  bool _isAnalyzing = true;

  @override
  void initState() {
    super.initState();
    _analyzeImages();
  }

  Future<void> _analyzeImages() async {
    List<AnalysisResult> results = [];

    for (File imageFile in widget.capturedImages) {
      try {
        final inputImage = InputImage.fromFile(imageFile);
        final List<Barcode> barcodes = await _barcodeScanner.processImage(
          inputImage,
        );

        if (barcodes.isNotEmpty) {
          final barcode = barcodes.first;
          final codeData = barcode.rawValue ?? '';
          final codeType = _getCodeType(barcode);

          results.add(
            AnalysisResult(
              imageFile: imageFile,
              codeData: codeData,
              codeType: codeType,
              barcodeFormat: barcode.format,
            ),
          );

          await _addToHistory(codeData, codeType);
        } else {
          results.add(AnalysisResult(imageFile: imageFile));
        }
      } catch (e) {
        print('Error analyzing image: $e');
        results.add(AnalysisResult(imageFile: imageFile));
      }
    }

    setState(() {
      _results = results;
      _isAnalyzing = false;
    });
  }

  String _getCodeType(Barcode barcode) {
    if (barcode.type == BarcodeType.url) {
      return 'url';
    } else if (barcode.type == BarcodeType.contactInfo) {
      return 'contact';
    } else if (barcode.rawValue?.startsWith('upi://') ?? false) {
      return 'upi';
    } else if (barcode.format == BarcodeFormat.qrCode) {
      return 'qr';
    } else {
      return 'barcode';
    }
  }

  Future<void> _addToHistory(String code, String codeType) async {
    final historyRepo = HistoryRepository();

    final historyItem = HistoryItem(
      scanType: _normalizeScanType(codeType),
      data: code,
      date: DateTime.now(),
      title: codeType,
      subTitle: code,
    );

    await historyRepo.addHistoryItem(historyItem);
  }

  String _normalizeScanType(String type) {
    switch (type.toLowerCase()) {
      case 'qr':
      case 'qrcode':
        return 'QR Code';
      case 'barcode':
        return 'Barcode';
      case 'payment':
      case 'upi':
        return 'Payment Code';
      case 'url':
        return 'URL';
      default:
        return 'Unknown';
    }
  }

  void _navigateToDetails(AnalysisResult result) {
    if (result.codeData == null) {
      // No code detected, just show image
      showDialog(
        context: context,
        builder: (context) => Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.file(result.imageFile),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'No QR/Barcode detected',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      );
      return;
    }

    Widget destination;
    switch (result.codeType) {
      case 'url':
        destination = LinkDetailsScreen(url: result.codeData!);
        break;
      case 'upi':
        destination = PaymentDetailsScreen(payee: result.codeData!);
        break;
      default:
        destination = BarcodeDetailsScreen(code: result.codeData!);
        break;
    }

    Navigator.push(context, MaterialPageRoute(builder: (_) => destination));
  }

  @override
  void dispose() {
    _barcodeScanner.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveUtil(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Analysis Results', style: theme.textTheme.headlineMedium),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.popUntil(context, (route) => route.isFirst);
          },
        ),
      ),
      body: _isAnalyzing
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Analyzing images...'),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(responsive.wp(4)),
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final result = _results[index];
                return Card(
                  margin: EdgeInsets.only(bottom: responsive.hp(2)),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () => _navigateToDetails(result),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: EdgeInsets.all(responsive.wp(3)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image Thumbnail
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              result.imageFile,
                              width: responsive.wp(25),
                              height: responsive.wp(25),
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(width: responsive.wp(4)),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      result.codeData != null
                                          ? Icons.qr_code_scanner
                                          : Icons.image,
                                      color: result.codeData != null
                                          ? Colors.green
                                          : Colors.grey,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      result.codeData != null
                                          ? 'Code Detected'
                                          : 'No Code',
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: result.codeData != null
                                                ? Colors.green
                                                : Colors.grey,
                                          ),
                                    ),
                                  ],
                                ),
                                if (result.codeType != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Type: ${result.codeType?.toUpperCase()}',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                                if (result.codeData != null) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    result.codeData!,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ],
                              ],
                            ),
                          ),

                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: _isAnalyzing
          ? null
          : Container(
              padding: EdgeInsets.all(responsive.wp(4)),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                icon: const Icon(Icons.home),
                label: const Text('Back to Home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentColor,
                  padding: EdgeInsets.symmetric(vertical: responsive.hp(2)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
    );
  }
}
