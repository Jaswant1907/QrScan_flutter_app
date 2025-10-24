import 'dart:io';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';

abstract class ScannerEvent extends Equatable {}

class ScannerStarted extends ScannerEvent {
  @override
  List<Object?> get props => [];
}

class StopScanner extends ScannerEvent {
  @override
  List<Object?> get props => [];
}

class BarcodeDetected extends ScannerEvent {
  final String code;
  BarcodeDetected(this.code);

  @override
  List<Object?> get props => [];
}

class ScreenshotCaptured extends ScannerEvent {
  final Uint8List imageBytes;
  ScreenshotCaptured(this.imageBytes);

  @override
  List<Object?> get props => [imageBytes];
}

class CaptureImage extends ScannerEvent {
  @override
  List<Object?> get props => [];
}

class AnalyzeImage extends ScannerEvent {
  final File imageFile;
  AnalyzeImage(this.imageFile);

  @override
  List<Object?> get props => [imageFile];
}

class ScannerToggleFlash extends ScannerEvent {
  @override
  List<Object?> get props => [];
}

class ScannerReset extends ScannerEvent {
  @override
  List<Object?> get props => [];
}
