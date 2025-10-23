import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:path_provider/path_provider.dart';
import 'scanner_event.dart';
import 'scanner_state.dart';

class ScannerBloc extends Bloc<ScannerEvent, ScannerState> {
  final MobileScannerController scannerController;
  String? _lastDetectedCode;
  File? _capturedImage;
  Uint8List? _screenshotBytes; // Store screenshot data

  ScannerBloc({required this.scannerController}) : super(ScannerInitial()) {
    on<ScannerStarted>(_onScannerStarted);
    on<StopScanner>(_onScannerStopped);
    on<BarcodeDetected>(_onBarcodeDetected);
    on<ScreenshotCaptured>(_onScreenshotCaptured); // New event
    on<ScannerToggleFlash>(_onToggleFlash);
    on<ScannerReset>(_onScannerReset);
  }

  Future<void> _onScannerStarted(
    ScannerStarted event,
    Emitter<ScannerState> emit,
  ) async {
    try {
      emit(ScannerLoading());

      if (!scannerController.value.isRunning) {
        await scannerController.start();
      }

      emit(
        ScannerReady(
          isTorchOn: scannerController.value.torchState == TorchState.on,
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
      // Save screenshot to file if available
      if (_screenshotBytes != null) {
        await _saveScreenshotToFile();
      }

      if (scannerController.value.isRunning) {
        await scannerController.stop();
      }

      emit(ScannerStopped());

      // If there's a last detected code, emit success state with image
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
        // No code detected, but we have the captured image
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

  // Handle screenshot capture
  Future<void> _onScreenshotCaptured(
    ScreenshotCaptured event,
    Emitter<ScannerState> emit,
  ) async {
    try {
      _screenshotBytes = event.imageBytes;
    } catch (e) {
      print('Error storing screenshot: $e');
    }
  }

  // Save screenshot bytes to file
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
      print('Error saving screenshot to file: $e');
      _capturedImage = null;
    }
  }

  Future<void> _onToggleFlash(
    ScannerToggleFlash event,
    Emitter<ScannerState> emit,
  ) async {
    try {
      await scannerController.toggleTorch();
      emit(
        ScannerReady(
          isTorchOn: scannerController.value.torchState == TorchState.on,
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

      if (!scannerController.value.isRunning) {
        await scannerController.start();
      }

      emit(
        ScannerReady(
          isTorchOn: scannerController.value.torchState == TorchState.on,
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
    return super.close();
  }
}
