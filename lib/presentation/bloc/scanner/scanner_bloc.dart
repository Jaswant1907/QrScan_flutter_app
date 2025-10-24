import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'scanner_event.dart';
import 'scanner_state.dart';

class ScannerBloc extends Bloc<ScannerEvent, ScannerState> {
  final CameraController cameraController;
  final BarcodeScanner barcodeScanner;
  String? _lastDetectedCode;
  File? _capturedImage;
  Uint8List? _screenshotBytes;
  bool _isProcessing = false;

  ScannerBloc({required this.cameraController, BarcodeScanner? scanner})
    : barcodeScanner = scanner ?? BarcodeScanner(),
      super(ScannerInitial()) {
    on<ScannerStarted>(_onScannerStarted);
    on<StopScanner>(_onScannerStopped);
    on<BarcodeDetected>(_onBarcodeDetected);
    on<ScreenshotCaptured>(_onScreenshotCaptured);
    on<ScannerToggleFlash>(_onToggleFlash);
    on<ScannerReset>(_onScannerReset);
    on<AnalyzeImage>(_onAnalyzeImage);
  }

  Future<void> _onScannerStarted(
    ScannerStarted event,
    Emitter<ScannerState> emit,
  ) async {
    try {
      emit(ScannerLoading());

      if (!cameraController.value.isInitialized) {
        await cameraController.initialize();
      }

      emit(
        ScannerReady(
          isTorchOn: cameraController.value.flashMode == FlashMode.torch,
        ),
      );
    } catch (e) {
      emit(ScannerFailure(e.toString()));
    }
  }

  Future<void> _onScannerStopped(
    StopScanner event,
    Emitter<ScannerState> emit,
  ) async {
    try {
      if (_screenshotBytes != null) {
        await _saveScreenshotToFile();
      }

      emit(ScannerStopped());

      if (_lastDetectedCode != null && _lastDetectedCode!.isNotEmpty) {
        final codeType = _determineCodeType(_lastDetectedCode!);
        emit(
          ScannerSuccess(
            code: _lastDetectedCode!,
            codeType: codeType,
            imageFile: _capturedImage,
          ),
        );
      } else {
        emit(ScannerNoCode(imageFile: _capturedImage));
      }
    } catch (e) {
      emit(ScannerFailure(e.toString()));
    }
  }

  Future<void> _onBarcodeDetected(
    BarcodeDetected event,
    Emitter<ScannerState> emit,
  ) async {
    try {
      _lastDetectedCode = event.code;
    } catch (e) {
      emit(ScannerFailure(e.toString()));
    }
  }

  Future<void> _onAnalyzeImage(
    AnalyzeImage event,
    Emitter<ScannerState> emit,
  ) async {
    if (_isProcessing) return;

    try {
      _isProcessing = true;
      emit(ScannerLoading());

      final inputImage = InputImage.fromFile(event.imageFile);
      final List<Barcode> barcodes = await barcodeScanner.processImage(
        inputImage,
      );

      if (barcodes.isNotEmpty) {
        final barcode = barcodes.first;
        final code = barcode.rawValue ?? '';

        if (code.isNotEmpty) {
          _lastDetectedCode = code;
          _capturedImage = event.imageFile;

          final codeType = _determineCodeType(code);

          emit(
            ScannerSuccess(
              code: code,
              codeType: codeType,
              imageFile: event.imageFile,
            ),
          );
        } else {
          emit(ScannerNoCode(imageFile: event.imageFile));
        }
      } else {
        emit(ScannerNoCode(imageFile: event.imageFile));
      }
    } catch (e) {
      emit(ScannerFailure('Failed to analyze image: ${e.toString()}'));
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> _onScreenshotCaptured(
    ScreenshotCaptured event,
    Emitter<ScannerState> emit,
  ) async {
    try {
      _screenshotBytes = event.imageBytes;
    } catch (e) {
      //  print('Error storing screenshot: $e');
    }
  }

  Future<void> _saveScreenshotToFile() async {
    try {
      if (_screenshotBytes == null) return;

      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${directory.path}/scan_$timestamp.png';

      final file = File(filePath);
      await file.writeAsBytes(_screenshotBytes!);

      _capturedImage = file;
    } catch (e) {
      //  print('Error saving screenshot to file: $e');
      _capturedImage = null;
    }
  }

  Future<void> _onToggleFlash(
    ScannerToggleFlash event,
    Emitter<ScannerState> emit,
  ) async {
    try {
      final currentFlashMode = cameraController.value.flashMode;

      if (currentFlashMode == FlashMode.off) {
        await cameraController.setFlashMode(FlashMode.torch);
      } else {
        await cameraController.setFlashMode(FlashMode.off);
      }

      emit(
        ScannerReady(
          isTorchOn: cameraController.value.flashMode == FlashMode.torch,
        ),
      );
    } catch (e) {
      emit(ScannerFailure('Failed to toggle flash: ${e.toString()}'));
    }
  }

  Future<void> _onScannerReset(
    ScannerReset event,
    Emitter<ScannerState> emit,
  ) async {
    try {
      _lastDetectedCode = null;
      _capturedImage = null;
      _screenshotBytes = null;
      _isProcessing = false;

      emit(
        ScannerReady(
          isTorchOn: cameraController.value.flashMode == FlashMode.torch,
        ),
      );
    } catch (e) {
      emit(ScannerFailure(e.toString()));
    }
  }

  String _determineCodeType(String code) {
    if (_isUrl(code)) {
      return 'url';
    }
    if (code.toLowerCase().contains('upi') || _isUpiId(code)) {
      return 'upi';
    }
    if (_isNumericOnly(code)) {
      return 'number';
    }
    return 'text';
  }

  bool _isUrl(String text) {
    final urlPattern = RegExp(
      r'^((?:.|\n)*?)((http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?)',
      caseSensitive: false,
    );
    return urlPattern.hasMatch(text);
  }

  bool _isUpiId(String text) {
    final upiPattern = RegExp(r'^[a-zA-Z0-9.\-_]{2,256}@[a-zA-Z]{2,64}$');
    return upiPattern.hasMatch(text);
  }

  bool _isNumericOnly(String text) {
    if (text.isEmpty) return false;
    final numericPattern = RegExp(r'^[0-9]+$');
    return numericPattern.hasMatch(text);
  }

  @override
  Future<void> close() {
    barcodeScanner.close();
    return super.close();
  }
}
