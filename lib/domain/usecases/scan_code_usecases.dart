import '../../domain/repository/scan_repository.dart';

/// Use case for scanning QR codes and barcodes
/// Encapsulates the business logic of scanning
class ScanCodeUseCase {
  final ScanRepository repository;

  ScanCodeUseCase(this.repository);

  /// Execute the scan operation
  /// Returns the scanned code value or null if failed/cancelled
  Future<String?> execute() async {
    try {
      return await repository.scanCode();
    } catch (e) {
      // Log error or handle it appropriately
      print('ScanCodeUseCase Error: $e');
      return null;
    }
  }
}
