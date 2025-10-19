import '../entities/scan_result.dart';
import '../../domain/repository/scan_repository.dart';

/// Use case for saving scan results to storage
class SaveScanUseCase {
  final ScanRepository repository;

  SaveScanUseCase(this.repository);

  /// Execute save operation
  /// Returns true if saved successfully
  Future<bool> execute(ScanResult scanResult) async {
    try {
      return await repository.saveScan(scanResult);
    } catch (e) {
      print('SaveScanUseCase Error: $e');
      return false;
    }
  }
}
