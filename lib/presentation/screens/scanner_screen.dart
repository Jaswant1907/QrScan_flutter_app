import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qscan_app_flutter/presentation/model/history_item.dart';
import 'package:qscan_app_flutter/presentation/repository/history_repo.dart';
import 'package:qscan_app_flutter/presentation/widget/history_card.dart';
import 'package:screenshot/screenshot.dart';
import 'package:qscan_app_flutter/presentation/bloc/scanner/scanner_bloc.dart';
import 'package:qscan_app_flutter/presentation/bloc/scanner/scanner_event.dart';
import 'package:qscan_app_flutter/presentation/bloc/scanner/scanner_state.dart';
import 'package:qscan_app_flutter/core/theme/app_theme.dart';
import 'package:qscan_app_flutter/core/utils/responsive_utils.dart';
import 'package:qscan_app_flutter/presentation/screens/details/barcode_details_screen.dart';
import 'package:qscan_app_flutter/presentation/screens/details/link_details.dart';
import 'package:qscan_app_flutter/presentation/screens/details/payment_details.dart';
import 'package:qscan_app_flutter/presentation/screens/image_preview_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  late final MobileScannerController cameraController;
  late final ScreenshotController screenshotController;
  bool isScanning = true;

  @override
  void initState() {
    super.initState();
    cameraController = MobileScannerController(
      formats: [
        BarcodeFormat.qrCode,
        BarcodeFormat.code128,
        BarcodeFormat.code39,
        BarcodeFormat.ean13,
        BarcodeFormat.ean8,
        BarcodeFormat.upcA,
        BarcodeFormat.upcE,
      ],
      autoStart: true,
    );
    screenshotController = ScreenshotController();
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  Future<void> _navigateToDetailsAndReturn({
    required String code,
    required String codeType,
    File? imageFile,
  }) async {
    if (!mounted) return;

    Widget destination;
    switch (codeType) {
      case 'url':
        destination = LinkDetailsScreen(url: code);
        break;
      case 'upi':
        destination = PaymentDetailsScreen(payee: code);
        break;
      case 'number':
        destination = BarcodeDetailsScreen(code: code);
        break;
      case 'text':
      default:
        if (imageFile != null) {
          destination = ImagePreviewScreen(
            imageFile: imageFile,
            scannedCode: code,
          );
        } else {
          // just show snack and return
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Scanned: $code')));
          // Return back that history was added
          Navigator.pop(context, true);
          return;
        }
        break;
    }

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => destination),
    );

    Navigator.pop(context, true);
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

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveUtil(context);
    final theme = Theme.of(context);

    return BlocProvider(
      create: (_) =>
          ScannerBloc(scannerController: cameraController)
            ..add(ScannerStarted()),
      child: BlocConsumer<ScannerBloc, ScannerState>(
        listener: (context, state) {
          if (state is ScannerSuccess) {
            final code = state.code;
            final codeType = state.codeType;
            final imageFile = state.imageFile;

            _addToHistory(code, codeType); // add history item asynchronously
            _navigateToDetailsAndReturn(
              code: code,
              codeType: codeType,
              imageFile: imageFile,
            );
          } else if (state is ScannerNoCode) {
            if (state.imageFile != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ImagePreviewScreen(
                    imageFile: state.imageFile!,
                    scannedCode: null,
                  ),
                ),
              ).then((_) {
                context.read<ScannerBloc>().add(ScannerReset());
                setState(() => isScanning = true);
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No QR/Barcode detected yet'),
                  duration: Duration(seconds: 2),
                ),
              );
              context.read<ScannerBloc>().add(ScannerReset());
              setState(() => isScanning = true);
            }
          } else if (state is ScannerFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.error}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: AppBar(
              title: Text(
                'Scan QR Code',
                style: theme.textTheme.headlineMedium,
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.flash_on, color: theme.colorScheme.primary),
                  onPressed: () {
                    context.read<ScannerBloc>().add(ScannerToggleFlash());
                  },
                ),
              ],
            ),
            body: Stack(
              children: [
                Screenshot(
                  controller: screenshotController,
                  child: MobileScanner(
                    controller: cameraController,
                    onDetect: (capture) {
                      if (!isScanning) return;

                      final barcodes = capture.barcodes;
                      if (barcodes.isEmpty) return;

                      final code = barcodes.first.rawValue ?? '';
                      if (code.isEmpty) return;

                      context.read<ScannerBloc>().add(BarcodeDetected(code));
                      setState(() => isScanning = false);
                    },
                  ),
                ),
                Center(
                  child: Container(
                    width: responsive.wp(75),
                    height: responsive.wp(75),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.accentColor, width: 4),
                      borderRadius: BorderRadius.circular(responsive.wp(5)),
                    ),
                  ),
                ),
                if (state is ScannerLoading)
                  const Center(child: CircularProgressIndicator()),
                Positioned(
                  bottom: responsive.hp(3),
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed:
                            (state is ScannerStopped || state is ScannerNoCode)
                            ? () {
                                context.read<ScannerBloc>().add(
                                  ScannerStarted(),
                                );
                                setState(() => isScanning = true);
                              }
                            : null,
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('START'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          disabledBackgroundColor: Colors.green.withOpacity(
                            0.5,
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: responsive.wp(8),
                            vertical: responsive.hp(1.5),
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: state is ScannerReady
                            ? () async {
                                setState(() => isScanning = false);
                                final imageBytes = await screenshotController
                                    .capture();
                                if (imageBytes != null) {
                                  context.read<ScannerBloc>().add(
                                    ScreenshotCaptured(imageBytes),
                                  );
                                }
                                context.read<ScannerBloc>().add(StopScanner());
                              }
                            : null,
                        icon: const Icon(Icons.stop),
                        label: const Text('STOP'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          disabledBackgroundColor: Colors.red.withOpacity(0.5),
                          padding: EdgeInsets.symmetric(
                            horizontal: responsive.wp(8),
                            vertical: responsive.hp(1.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
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
      case 'payment code':
        return 'Payment Code';
      default:
        return 'Unknown';
    }
  }
}
