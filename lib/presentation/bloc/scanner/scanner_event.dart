import 'dart:typed_data';

abstract class ScannerEvent {}

class ScannerStarted extends ScannerEvent {}

class StopScanner extends ScannerEvent {}

class BarcodeDetected extends ScannerEvent {
  final String code;
  BarcodeDetected(this.code);
}

class ScreenshotCaptured extends ScannerEvent {
  final Uint8List imageBytes;
  ScreenshotCaptured(this.imageBytes);
}

// Add new event to capture image
class CaptureImage extends ScannerEvent {}

class ScannerToggleFlash extends ScannerEvent {}

class ScannerReset extends ScannerEvent {}
