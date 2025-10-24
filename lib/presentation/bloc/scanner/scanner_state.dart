import 'dart:io';

import 'package:equatable/equatable.dart';

abstract class ScannerState extends Equatable {
  const ScannerState();
}

class ScannerInitial extends ScannerState {
  @override
  List<Object?> get props => throw UnimplementedError();
}

class ScannerLoading extends ScannerState {
  @override
  List<Object?> get props => throw UnimplementedError();
}

class ScannerReady extends ScannerState {
  final bool isTorchOn;
  const ScannerReady({this.isTorchOn = false});

  @override
  List<Object?> get props => [isTorchOn];
}

class ScannerStopped extends ScannerState {
  @override
  List<Object?> get props => [];
}

class ScannerSuccess extends ScannerState {
  final String code;
  final String codeType;
  final File? imageFile; // Add optional image file
  const ScannerSuccess({
    required this.code,
    required this.codeType,
    this.imageFile,
  });

  @override
  List<Object?> get props => [code, codeType, imageFile];
}

class ScannerNoCode extends ScannerState {
  final File? imageFile; // Add optional image file for no-code scenario
  const ScannerNoCode({this.imageFile});

  @override
  List<Object?> get props => [imageFile];
}

class ScannerFailure extends ScannerState {
  final String error;
  const ScannerFailure(this.error);

  @override
  List<Object?> get props => [error];
}
