import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class ImagePreviewScreen extends StatelessWidget {
  final File imageFile;
  final String? scannedCode;

  const ImagePreviewScreen({
    super.key,
    required this.imageFile,
    this.scannedCode,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Preview'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(child: Image.file(imageFile, fit: BoxFit.contain)),
          ),

          // Show scanned text if available
          if (scannedCode != null && scannedCode!.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.black87,
              child: Text(
                'Scanned: $scannedCode',
                style: const TextStyle(color: Colors.white, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Cancel Button
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.red,
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      size: 32,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),

                // Save Button
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.green,
                  child: IconButton(
                    icon: const Icon(
                      Icons.check,
                      size: 32,
                      color: Colors.white,
                    ),
                    onPressed: () async {
                      await _saveImage(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveImage(BuildContext context) async {
    try {
      // Request storage permission
      final status = await Permission.storage.request();

      if (status.isGranted || await Permission.photos.isGranted) {
        // Save image to gallery
        final result = await ImageGallerySaverPlus.saveFile(
          imageFile.path,
          isReturnPathOfIOS: true,
        );

        if (result['isSuccess']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image saved to gallery'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          throw Exception('Failed to save image');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Storage permission denied'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving image: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
