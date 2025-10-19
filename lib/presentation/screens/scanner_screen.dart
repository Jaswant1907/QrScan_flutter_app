import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_pickers/image_pickers.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qscan_app_flutter/core/theme/app_theme.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  // Use a different picker instance since the original imported one
  // 'image_pickers' doesn't seem to expose a public constructor in its documentation.
  // I will use a mock object or follow the intended usage pattern for 'image_pickers'.
  // As per the provided code, 'final ImagePickers _picker = ImagePickers();' is used.
  final ImagePickers _picker = ImagePickers();

  bool isStarted = true;
  bool isScanning = true;

  final cameraController = MobileScannerController(
    formats: <BarcodeFormat>[
      BarcodeFormat.qrCode,
      BarcodeFormat.code128,
      BarcodeFormat.code39,
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
    ],
  );

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _toggleScanning() {
    setState(() {
      if (isStarted) {
        cameraController.stop();
        isStarted = false;
        isScanning = false;
      } else {
        cameraController.start();
        isStarted = true;
        isScanning = true;
      }
    });
  }

  // Completed implementation for image picking
  void _pickImageFromGallery() async {
    try {
      // Use the 'image_pickers' package to pick a single image
      List<Media>? mediaList = await ImagePickers.pickerPaths(
        galleryMode: GalleryMode.image,
        selectCount: 1,
        showGif: false,
        cropConfig: null, // No cropping
      );

      if (mediaList != null &&
          mediaList.isNotEmpty &&
          mediaList.first.path != null) {
        final File imageFile = File(mediaList.first.path!);

        // Analyze the image using MobileScannerController
        final BarcodeCapture? capture = await cameraController.analyzeImage(
          imageFile.path,
        );

        // Extract barcodes list
        final barcodes = capture?.barcodes ?? [];

        if (barcodes.isNotEmpty) {
          // Use the first detected barcode value
          final String code = barcodes.first.rawValue ?? 'N/A';
          if (!mounted) return;
          _handleScannedCode(code);
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No QR/Barcode found in image')),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  void _handleScannedCode(String code) {
    // Stop camera scanning for a clean dialog presentation
    if (isStarted) {
      _toggleScanning(); // This stops the camera and sets isScanning to false
    }

    showDialog(
      context: context,
      barrierDismissible: false, // Force user action
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          '🎉 Scan Complete',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium!.copyWith(color: AppTheme.primaryColor),
        ),
        content: SelectableText(
          'Code: $code',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Restart scanning logic
              if (!isStarted) {
                _toggleScanning();
              } else {
                setState(() {
                  isScanning = true;
                }); // Start detection if camera is already running
              }
            },
            child: const Text('SCAN AGAIN'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Handle the scanned data (e.g., navigate, copy, etc.)
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text('OKAY'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 28),
        onPressed: onPressed,
        padding: const EdgeInsets.all(18), // Slightly larger tap target
      ),
    );
  }

  // Removed _buildTabButton as it was unused and detracted from the design focus.

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        // Colors are inherited from AppTheme.lightTheme
        title: Text('Scan QR Code', style: theme.textTheme.headlineMedium),
        actions: [
          IconButton(
            icon: Icon(
              Icons.account_circle,
              color: theme
                  .colorScheme
                  .primary, // Use primary color for main actions
              size: 28,
            ),
            onPressed: () {
              // Handle profile action
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Scanner area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0), // Increased padding
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  20,
                ), // Slightly less aggressive curve
                child: Stack(
                  children: [
                    MobileScanner(
                      controller: cameraController,
                      onDetect: (capture) {
                        if (!isScanning) return;
                        final barcodes = capture.barcodes;
                        if (barcodes.isEmpty) return;

                        // Prevent subsequent scans until dismissed
                        setState(() => isScanning = false);

                        final code = barcodes.first.rawValue ?? 'N/A';
                        _handleScannedCode(code);
                      },
                    ),

                    // Scanning Frame Overlay
                    Center(
                      child: Container(
                        width:
                            MediaQuery.of(context).size.width *
                            0.75, // Larger frame
                        height: MediaQuery.of(context).size.width * 0.75,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppTheme.accentColor,
                            width: 4,
                          ), // Accent color frame
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.accentColor.withOpacity(0.4),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Overlay with instruction text
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        margin: const EdgeInsets.symmetric(horizontal: 40),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 10,
                        ),
                        child: const Text(
                          'Align the QR or Barcode within the frame',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom action buttons
          Padding(
            padding: const EdgeInsets.only(bottom: 30.0, top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Flashlight Toggle Button
                _buildActionButton(
                  icon: Icons.flash_on,
                  onPressed: () {
                    cameraController.toggleTorch();
                  },
                  color: theme.colorScheme.secondary,
                ),
                const SizedBox(width: 30),

                // Centered Start/Stop button (Now a FAB style)
                FloatingActionButton.extended(
                  onPressed: _toggleScanning,
                  heroTag: 'scanner_toggle',
                  label: Text(
                    isStarted ? "STOP SCANNING" : "START SCANNING",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  icon: Icon(
                    isStarted
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_fill,
                  ),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 6,
                ),

                const SizedBox(width: 30),

                // Gallery Pick Button
                _buildActionButton(
                  icon: Icons.image_search, // More appropriate icon
                  onPressed: _pickImageFromGallery,
                  color: theme.colorScheme.secondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
