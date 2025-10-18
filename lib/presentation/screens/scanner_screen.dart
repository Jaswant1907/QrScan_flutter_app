import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  // MobileScannerController cameraController = MobileScannerController();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Scan QR Code',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: Icon(Icons.arrow_back, color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, color: Colors.grey),
            onPressed: () {
              // Handle profile action
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // // Tab buttons
          // Padding(
          //   padding: const EdgeInsets.symmetric(vertical: 16.0),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: [
          //       _buildTabButton('Scan', true),
          //       const SizedBox(width: 12),
          //       _buildTabButton('History', false),
          //     ],
          //   ),
          // ),

          // Scanner area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Stack(
                  children: [
                    MobileScanner(
                      controller: cameraController,
                      onDetect: (capture) {
                        if (!isScanning) return;
                        final barcodes = capture.barcodes;
                        if (barcodes.isEmpty) return;
                        setState(() => isScanning = false);
                        final code = barcodes.first.rawValue ?? '';
                        _handleScannedCode(code);
                      },
                    ),

                    // Overlay with instruction text
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 40,
                            ),
                            child: const Text(
                              'Point your camera\nat a scanner ',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                shadows: [
                                  Shadow(color: Colors.black45, blurRadius: 10),
                                ],
                              ),
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),

                    // Scanning frame overlay
                    Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        height: MediaQuery.of(context).size.width * 0.7,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 3),
                          borderRadius: BorderRadius.circular(20),
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
            padding: const EdgeInsets.only(bottom: 40.0, top: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildActionButton(
                  icon: Icons.flash_on,
                  onPressed: () {
                    cameraController.toggleTorch();
                  },
                ),
                const SizedBox(width: 60),
                _buildActionButton(
                  icon: Icons.image_outlined,
                  onPressed: () {
                    // Handle image picker
                    _pickImageFromGallery();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String text, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.grey[300],
        borderRadius: BorderRadius.circular(25),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? Colors.black : Colors.grey[600],
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.black, size: 28),
        onPressed: onPressed,
        padding: const EdgeInsets.all(16),
      ),
    );
  }

  void _handleScannedCode(String code) {
    // Show result dialog or navigate to result screen
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('QR Code Scanned'),
        content: Text(code),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                isScanning = true;
              });
            },
            child: const Text('Scan Again'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Handle the scanned data
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _pickImageFromGallery() async {
    // Implement image picker functionality
    // You'll need to add image_picker package
    /*
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      // Process the image for QR code
    }
    */
  }
}
