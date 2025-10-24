import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:qscan_app_flutter/core/theme/app_theme.dart';
import 'package:qscan_app_flutter/core/utils/responsive_utils.dart';
import 'package:qscan_app_flutter/presentation/bloc/scanner/scanner_bloc.dart';
import 'package:qscan_app_flutter/presentation/bloc/scanner/scanner_state.dart';
import 'package:qscan_app_flutter/presentation/screens/anlysis_result_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isCameraStarted = false;
  bool _isCapturing = false;
  final List<File> _capturedImages = [];
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializeCameras();
  }

  Future<void> _initializeCameras() async {
    _cameras = await availableCameras();
  }

  Future<void> _startCamera() async {
    if (_cameras == null || _cameras!.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No camera available')));
      return;
    }

    _cameraController = CameraController(
      _cameras![0],
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _cameraController!.initialize();
      setState(() {
        _isCameraInitialized = true;
        _isCameraStarted = true;
      });
    } catch (e) {
      print('Error initializing camera: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to initialize camera: $e')),
      );
    }
  }

  Future<void> _captureImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (_isCapturing) return;

    setState(() {
      _isCapturing = true;
    });

    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String captureDir = path.join(appDir.path, 'captures');
      await Directory(captureDir).create(recursive: true);

      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String filePath = path.join(captureDir, 'IMG_$timestamp.jpg');

      final XFile imageFile = await _cameraController!.takePicture();
      final File savedImage = File(imageFile.path);
      final File finalImage = await savedImage.copy(filePath);

      setState(() {
        _capturedImages.add(finalImage);
        _isCapturing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Image ${_capturedImages.length} captured'),
          duration: const Duration(milliseconds: 500),
        ),
      );
    } catch (e) {
      print('Error capturing image: $e');
      setState(() {
        _isCapturing = false;
      });
    }
  }

  Future<void> _stopAndAnalyze() async {
    if (_capturedImages.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No images to analyze')));
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    await _cameraController?.dispose();
    _cameraController = null;

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              AnalysisResultsScreen(capturedImages: _capturedImages),
        ),
      );
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveUtil(context);
    final theme = Theme.of(context);

    return BlocConsumer<ScannerBloc, ScannerState>(
      listener: (context, state) {
        if (state is ScannerFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${state.error}')));
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            title: Text('Qscan Scanner', style: theme.textTheme.headlineMedium),
            backgroundColor: Colors.black,
            actions: [
              if (_isCameraStarted)
                IconButton(
                  icon: const Icon(Icons.flash_on, color: Colors.white),
                  onPressed: () async {
                    if (_cameraController != null) {
                      final currentFlashMode =
                          _cameraController!.value.flashMode;
                      if (currentFlashMode == FlashMode.off) {
                        await _cameraController!.setFlashMode(FlashMode.torch);
                      } else {
                        await _cameraController!.setFlashMode(FlashMode.off);
                      }
                      setState(() {});
                    }
                  },
                ),
            ],
          ),
          body: Stack(
            children: [
              if (_isCameraInitialized && _cameraController != null)
                SizedBox.expand(child: CameraPreview(_cameraController!))
              else
                Container(
                  color: Colors.grey[900],
                  child: const Center(
                    child: Text(
                      'Press START to begin',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ),

              if (_isCameraStarted)
                Center(
                  child: Container(
                    width: responsive.wp(75),
                    height: responsive.wp(75),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.accentColor, width: 3),
                      borderRadius: BorderRadius.circular(responsive.wp(3)),
                    ),
                  ),
                ),

              if (_isProcessing)
                Container(
                  color: Colors.black54,
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 16),
                        Text(
                          'Analyzing images...',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),

              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.wp(4),
                    vertical: responsive.hp(2),
                  ),
                  color: Colors.black87,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_capturedImages.isNotEmpty)
                        Container(
                          height: responsive.hp(10),
                          margin: EdgeInsets.only(bottom: responsive.hp(2)),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _capturedImages.length,
                            itemBuilder: (context, index) {
                              return Container(
                                width: responsive.hp(10),
                                margin: EdgeInsets.only(
                                  right: responsive.wp(2),
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.file(
                                    _capturedImages[index],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          if (!_isCameraStarted)
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _startCamera,
                                icon: const Icon(Icons.play_arrow, size: 28),
                                label: const Text(
                                  'START',
                                  style: TextStyle(fontSize: 18),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: EdgeInsets.symmetric(
                                    vertical: responsive.hp(2),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),

                          if (_isCameraStarted) ...[
                            ElevatedButton.icon(
                              onPressed: _capturedImages.isEmpty
                                  ? null
                                  : _stopAndAnalyze,
                              icon: const Icon(Icons.stop),
                              label: const Text('STOP'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                disabledBackgroundColor: Colors.red.withOpacity(
                                  0.5,
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: responsive.wp(6),
                                  vertical: responsive.hp(1.5),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),

                            SizedBox(width: responsive.wp(4)),

                            GestureDetector(
                              onTap: _isCapturing ? null : _captureImage,
                              child: Container(
                                width: responsive.wp(20),
                                height: responsive.wp(20),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  border: Border.all(
                                    color: AppTheme.accentColor,
                                    width: 4,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: _isCapturing
                                    ? const Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.camera_alt,
                                        size: 40,
                                        color: Colors.black87,
                                      ),
                              ),
                            ),

                            SizedBox(width: responsive.wp(4)),

                            // Counter Badge
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: responsive.wp(4),
                                vertical: responsive.hp(1.5),
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.accentColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${_capturedImages.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
