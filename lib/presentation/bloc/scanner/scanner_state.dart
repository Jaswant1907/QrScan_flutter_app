import 'dart:io';

abstract class ScannerState {
  const ScannerState();
}

class ScannerInitial extends ScannerState {}

class ScannerLoading extends ScannerState {}

class ScannerReady extends ScannerState {
  final bool isTorchOn;
  const ScannerReady({this.isTorchOn = false});
}

class ScannerStopped extends ScannerState {}

class ScannerSuccess extends ScannerState {
  final String code;
  final String codeType;
  final File? imageFile; // Add optional image file
  const ScannerSuccess({
    required this.code,
    required this.codeType,
    this.imageFile,
  });
}

class ScannerNoCode extends ScannerState {
  final File? imageFile; // Add optional image file for no-code scenario
  const ScannerNoCode({this.imageFile});
}

class ScannerFailure extends ScannerState {
  final String error;
  const ScannerFailure(this.error);
}
